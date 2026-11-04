#!/usr/bin/env python3
"""List running Happy (phone remote-control) sessions and take one over locally."""

import argparse
import glob
import json
import os
import re
import signal
import subprocess
import sys
import time
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Optional

HOME = Path.home()
SESSIONS_DIR = HOME / ".claude" / "sessions"
PROJECTS_DIR = HOME / ".claude" / "projects"

HEADERS = ["#", "DIR", "NAME", "MODE", "STATUS", "STARTED", "ORIGIN", "ID"]
NAME_WIDTH = 40
DIR_WIDTH = 36
ID_PREFIX_MIN = 4    # minimum length of a happy-id prefix target
STOP_TIMEOUT = 20    # seconds to wait for a stopped session's pid to exit
SCAN_CHUNK = 1 << 20         # last_model() reads transcripts backwards in chunks
SCAN_CAP = 64 * 1024 * 1024  # ... at most this many bytes from the end


@dataclass
class Session:
    happy_pid: int
    happy_id: str
    origin: str                          # "daemon" (phone) or "terminal"
    claude_pid: Optional[int] = None
    chain_pids: list[int] = field(default_factory=list)  # intermediates + claude pid
    name: Optional[str] = None
    file_name: Optional[str] = None
    cwd: Optional[str] = None
    started_at: Optional[int] = None     # ms epoch
    mode: Optional[str] = None           # "phone" or "local"
    status: Optional[str] = None
    transcript: Optional[Path] = None


def fail(msg):
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


def scan_procs():
    """Map pid -> ppid for all live processes (exited zombies excluded)."""
    procs = {}
    for name in os.listdir("/proc"):
        if not name.isdigit():
            continue
        try:
            stat = Path(f"/proc/{name}/stat").read_text()
        except OSError:
            continue
        fields = stat.rpartition(")")[2].split()
        try:
            ppid = int(fields[1])
        except (IndexError, ValueError):
            continue
        if fields[0] != "Z":
            procs[int(name)] = ppid
    return procs


def pid_alive(pid):
    """True if pid exists and has not exited yet (zombies count as dead)."""
    try:
        stat = Path(f"/proc/{pid}/stat").read_text()
    except OSError:
        return False
    return stat.rpartition(")")[2].split()[0] != "Z"


def find_claude_chain(happy_pid, kids):
    """Find the pid chain from happy_pid down to its Claude process (depth <= 3).

    Returns the intermediate pids (e.g. the local-mode claude_local_launcher)
    plus the Claude pid itself, or None if no descendant owns a session file.
    """
    frontier = [(happy_pid, [])]
    for _ in range(3):
        nxt = []
        for pid, path in frontier:
            for child in kids.get(pid, []):
                if (SESSIONS_DIR / f"{child}.json").is_file():
                    return path + [child]
                nxt.append((child, path + [child]))
        frontier = nxt
    return None


def load_claude_session(claude_pid):
    try:
        return json.loads((SESSIONS_DIR / f"{claude_pid}.json").read_text())
    except (OSError, json.JSONDecodeError):
        return None


def transcript_path(cwd, session_id):
    """Locate the transcript JSONL for a Claude session id."""
    if not session_id:
        return None
    if cwd:
        slug = re.sub(r"[^a-zA-Z0-9]", "-", cwd)
        primary = PROJECTS_DIR / slug / f"{session_id}.jsonl"
        if primary.is_file():
            return primary
    for hit in sorted(glob.glob(str(PROJECTS_DIR / "*" / f"{session_id}.jsonl"))):
        return Path(hit)
    return None


def last_titles(transcript):
    """Stream the transcript; return the last custom (/rename) and AI titles."""
    custom = ai = None
    try:
        with open(transcript, encoding="utf-8", errors="replace") as fh:
            for line in fh:
                if '"custom-title"' not in line and '"ai-title"' not in line:
                    continue
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if entry.get("type") == "custom-title" and entry.get("customTitle"):
                    custom = entry["customTitle"]
                elif entry.get("type") == "ai-title" and entry.get("aiTitle"):
                    ai = entry["aiTitle"]
    except OSError:
        pass
    return custom, ai


def resolve_name(data, transcript):
    """Pick the display name: /rename title, explicit name, AI title, derived name."""
    custom = ai = None
    if transcript:
        custom, ai = last_titles(transcript)
    if custom:
        return custom
    if data.get("name") and data.get("nameSource") != "derived":
        return data["name"]
    if ai:
        return ai
    return data.get("name")


def last_model(transcript):
    """Return the model id of the last real assistant entry in the transcript.

    Reads the file backwards in chunks (a partial line at a chunk's left edge
    is carried into the next chunk), so large transcripts stay fast.
    """
    if not transcript:
        return None

    def line_model(raw):
        try:
            entry = json.loads(raw)
        except ValueError:  # invalid UTF-8 / JSON (partial line, binary junk)
            return None
        if entry.get("type") != "assistant" or entry.get("isSidechain"):
            return None
        model = (entry.get("message") or {}).get("model")
        return model if model and model != "<synthetic>" else None

    try:
        size = os.path.getsize(transcript)
        with open(transcript, "rb") as fh:
            carry = b""
            end = size
            floor = max(0, size - SCAN_CAP)
            while end > floor:
                step = min(SCAN_CHUNK, end - floor)
                end -= step
                fh.seek(end)
                parts = (fh.read(step) + carry).split(b"\n")
                carry = parts.pop(0)
                for raw in reversed(parts):
                    model = line_model(raw)
                    if model:
                        return model
            return line_model(carry)
    except OSError:
        return None


def daemon_list():
    """Return the happy daemon's session entries (empty list if none)."""
    try:
        proc = subprocess.run(
            ["happy", "daemon", "list"], capture_output=True, text=True, timeout=30)
    except FileNotFoundError:
        fail("happy binary not found in PATH")
    except subprocess.TimeoutExpired:
        fail("'happy daemon list' timed out")
    out = proc.stdout + proc.stderr
    if "No daemon running" in out:
        fail("no happy daemon running")
    start = out.find("[")
    if start < 0:
        fail(f"unexpected 'happy daemon list' output:\n{out.strip()}")
    try:
        entries, _ = json.JSONDecoder().raw_decode(out, start)
    except json.JSONDecodeError:
        fail(f"cannot parse 'happy daemon list' output:\n{out.strip()}")
    return entries if isinstance(entries, list) else []


def collect_sessions():
    """Gather live happy sessions with their Claude metadata, sorted by start time."""
    procs = scan_procs()
    kids = {}
    for pid in sorted(procs):
        kids.setdefault(procs[pid], []).append(pid)

    sessions = []
    for entry in daemon_list():
        if not isinstance(entry, dict):
            continue
        pid = entry.get("pid")
        happy_id = entry.get("happySessionId") or ""
        if not isinstance(pid, int) or not happy_id or pid not in procs:
            continue
        session = Session(
            happy_pid=pid,
            happy_id=happy_id,
            origin="daemon" if entry.get("startedBy") == "daemon" else "terminal",
        )
        chain = find_claude_chain(pid, kids)
        if chain:
            data = load_claude_session(chain[-1])
            if data:
                session.claude_pid = chain[-1]
                session.chain_pids = chain
                session.cwd = data.get("cwd")
                session.started_at = data.get("startedAt")
                session.status = data.get("status")
                session.mode = {"remote_mobile": "phone", "cli": "local"}.get(
                    data.get("entrypoint"), data.get("entrypoint"))
                session.file_name = data.get("name")
                session.transcript = transcript_path(session.cwd, data.get("sessionId"))
                session.name = resolve_name(data, session.transcript)
        sessions.append(session)

    sessions.sort(key=lambda s: (s.started_at is None, s.started_at or 0))
    return sessions


def tilde(path):
    if path and path.startswith(str(HOME)):
        return "~" + path[len(str(HOME)):]
    return path


def shorten(text, width):
    text = str(text)
    return text if len(text) <= width else text[: width - 3] + "..."


def fmt_when(ms):
    when = datetime.fromtimestamp(ms / 1000)
    if when.date() == datetime.now().date():
        return when.strftime("%H:%M")
    return when.strftime("%b %d %H:%M")


def session_row(num, s):
    return [
        str(num),
        shorten(tilde(s.cwd) or "?", DIR_WIDTH),
        shorten(s.name or "?", NAME_WIDTH),
        s.mode or "?",
        s.status or "?",
        fmt_when(s.started_at) if s.started_at else "?",
        s.origin,
        s.happy_id[:8],
    ]


def print_sessions(pairs):
    """Print the table for (row_number, session) pairs."""
    if not pairs:
        print("no running happy sessions")
        return
    rows = [session_row(num, s) for num, s in pairs]
    widths = [max(len(h), *(len(r[i]) for r in rows)) for i, h in enumerate(HEADERS)]
    print("  ".join(h.ljust(w) for h, w in zip(HEADERS, widths)).rstrip())
    for row in rows:
        print("  ".join(c.ljust(w) for c, w in zip(row, widths)).rstrip())


def no_match(sessions, msg, matches=None):
    """Report a target-resolution failure and show the candidates; exit 1."""
    print(f"error: {msg}", file=sys.stderr)
    pairs = [(i + 1, s) for i, s in enumerate(sessions)
             if matches is None or s in matches]
    print_sessions(pairs)
    sys.exit(1)


def tty_of(pid):
    try:
        out = subprocess.run(["ps", "-o", "tty=", "-p", str(pid)],
                             capture_output=True, text=True, timeout=10).stdout
    except (OSError, subprocess.TimeoutExpired):
        return "?"
    return out.strip() or "?"


def name_matches(session, target, exact):
    """True if target equals (exact) or is contained in (not exact) any of the
    session's names: the display name and the raw sessions-file name."""
    wanted = target.lower()
    names = [n for n in (session.name, session.file_name) if n]
    if exact:
        return any(n.lower() == wanted for n in names)
    return any(wanted in n.lower() for n in names)


def resolve_target(sessions, target):
    """Resolve a takeover target: row number, exact name, happy-id prefix, or name substring."""
    if target.isdigit():
        row = int(target)
        if 1 <= row <= len(sessions):
            return sessions[row - 1]
        no_match(sessions, f"row {row} is out of range (1-{len(sessions)})")

    matches = [s for s in sessions if name_matches(s, target, exact=True)]
    if matches:
        if len(matches) == 1:
            return matches[0]
        no_match(sessions, f"multiple sessions are named '{target}'", matches)

    if len(target) >= ID_PREFIX_MIN:
        matches = [s for s in sessions if s.happy_id.startswith(target)]
        if matches:
            if len(matches) == 1:
                return matches[0]
            no_match(sessions, f"happy id prefix '{target}' matches multiple sessions", matches)

    matches = [s for s in sessions if name_matches(s, target, exact=False)]
    if matches:
        if len(matches) == 1:
            return matches[0]
        no_match(sessions, f"'{target}' matches multiple sessions", matches)

    no_match(sessions, f"no session matches '{target}'")


def pick_by_cwd(sessions):
    """Pick the single session running in the current directory, if there is exactly one."""
    cwd = os.path.realpath(os.getcwd())
    matches = [s for s in sessions if s.cwd and os.path.realpath(s.cwd) == cwd]
    if len(matches) == 1:
        return matches[0]
    if not matches:
        no_match(sessions, "no happy session is running in this directory")
    no_match(sessions, "multiple happy sessions are running in this directory", matches)


def cmd_list(_args):
    print_sessions(list(enumerate(collect_sessions(), 1)))


def cmd_takeover(args):
    sessions = collect_sessions()
    if not sessions:
        fail("no running happy sessions")

    if args.target:
        target = resolve_target(sessions, args.target)
    else:
        target = pick_by_cwd(sessions)

    if target.origin == "terminal" and not args.force:
        tty = tty_of(target.happy_pid)
        print(f"error: session '{target.name or '?'}' is still attached to terminal {tty};",
              file=sys.stderr)
        print("error: press Space twice in that terminal to switch it back to local mode,", file=sys.stderr)
        print("error: or pass --force to stop it and resume it here", file=sys.stderr)
        sys.exit(1)

    if target.claude_pid is None and not args.force:
        fail(f"session '{target.happy_id}' has no running Claude process yet (no message sent?), so there is nothing to resume; pass --force to try anyway")

    print(f"Taking over session '{target.name or '?'}' in {tilde(target.cwd) or '?'} "
          f"(happy id {target.happy_id})")

    # 'happy resume' takes no model argument, so the last-used model is passed
    # through the env; otherwise the resumed session falls back to the settings
    # default model, because the ANTHROPIC_DEFAULT_*_MODEL pins disable
    # transcript-model restore.
    env = dict(os.environ)
    if env.get("ANTHROPIC_MODEL"):
        print(f"Model: {env['ANTHROPIC_MODEL']} (from ANTHROPIC_MODEL)")
    else:
        model = last_model(target.transcript)
        if model:
            print(f"Restoring model: {model}")
            env["ANTHROPIC_MODEL"] = model
        else:
            print("Model: default (none recorded)")

    stop_cmd = ["happy", "daemon", "stop-session", target.happy_id]
    resume_cmd = ["happy", "resume", target.happy_id]
    print("  $ " + " ".join(stop_cmd))
    model_env = f"ANTHROPIC_MODEL={env['ANTHROPIC_MODEL']} " if "ANTHROPIC_MODEL" in env else ""
    print(f"  $ {model_env}" + " ".join(resume_cmd))
    if args.dry_run:
        print("dry run: nothing executed")
        return

    print("Stopping the remote session...")
    try:
        proc = subprocess.run(stop_cmd, capture_output=True, text=True, timeout=30)
    except subprocess.TimeoutExpired:
        fail("'happy daemon stop-session' timed out; not resuming")
    out = (proc.stdout + proc.stderr).strip()
    if proc.returncode != 0 or "Session stopped" not in out:
        fail(f"could not stop session: {out or f'exit code {proc.returncode}'}")
    print(out)

    # stop-session only signals the happy pid; in local mode the launcher and
    # Claude processes under it survive as orphans. They must be gone too, or
    # the resumed session would share its transcript with a still-running writer.
    pids = [target.happy_pid, *target.chain_pids]

    grace = time.monotonic() + 3
    while any(pid_alive(p) for p in pids) and time.monotonic() < grace:
        time.sleep(0.25)

    leftovers = [p for p in target.chain_pids if pid_alive(p)]
    if leftovers:
        print(f"Stopping leftover Claude process(es): {leftovers}")
        for pid in leftovers:
            try:
                os.kill(pid, signal.SIGTERM)
            except ProcessLookupError:
                pass

    deadline = time.monotonic() + STOP_TIMEOUT
    while any(pid_alive(p) for p in pids):
        if time.monotonic() > deadline:
            alive = [p for p in pids if pid_alive(p)]
            fail(f"pid(s) {alive} still alive after {STOP_TIMEOUT}s; not resuming")
        time.sleep(0.25)

    print("Resuming locally...")
    try:
        os.execvpe("happy", ["happy", "resume", target.happy_id], env)
    except OSError as exc:
        fail(f"could not run 'happy resume': {exc}")


def main():
    parser = argparse.ArgumentParser(
        prog="hpy.py",
        description="List running Happy sessions and take one over from this computer.")
    sub = parser.add_subparsers(dest="command", required=True)

    p_list = sub.add_parser("list", help="list running happy sessions")
    p_list.set_defaults(func=cmd_list)

    p_take = sub.add_parser("takeover", help="stop a happy session and resume it locally")
    p_take.add_argument("target", nargs="?",
                        help="row number from 'list', session name, happy id prefix, "
                             "or name substring")
    p_take.add_argument("--force", action="store_true",
                        help="also take over sessions started from a terminal")
    p_take.add_argument("--dry-run", action="store_true",
                        help="show what would be done without doing it")
    p_take.set_defaults(func=cmd_takeover)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
