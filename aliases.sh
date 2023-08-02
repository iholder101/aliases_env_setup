#
# ~~ Itamar Holder's aliases ~~
#
#

### GENERAL ALIAS CONFIGS ###
THIS_FILE_PATH="/home/iholder/.env/aliases_env_setup/aliases.sh"
ENV_FILE_PATH="/home/iholder/.env/aliases_env_setup/env_setup.sh"

#Alises
alias update="source ${THIS_FILE_PATH} && source ${ENV_FILE_PATH}"
alias show="vi ${THIS_FILE_PATH}" #show this file
alias envshow="vi ${ENV_FILE_PATH}" 
alias envupdate="source ${ENV_FILE_PATH}"
alias aliasupdate="source ${THIS_FILE_PATH}"
alias backup-env='cp ~/ENV/aliases.sh ~/ENV/backup/aliases_$(date +"%Y-%m-%d").sh; \
		  cp ${ENV_FILE_PATH} ~/ENV/backup/env_setup_$(date +"%Y-%m-%d").sh;'

#Linux apps
alias vi='vim'
alias ne='nedit'
alias ge='geany'
alias diff='meld'
alias p3='python3'
alias p2='python2'
alias grep='grep -HnsI --color=auto'
alias grep_src='grep --include=*.go --include=*.yaml --include=*.yml --include=*.sh --include=*.cpp --include=*.h --include=*.py --include=*.pl --include=*.c --include=*.hpp --include=*.i'
alias grep_sh='function temp_func { grep $1 . -R --include=*.sh ; } ; temp_func'
alias mk='make'
alias mkc='make clean; make'
alias docker='podman'

#Sed patterns
alias sed-remove-colors="sed 's/\x1b\[[0-9;]*m//g'"
alias sed-remove-trailing-spaces="sed 's/^\s*//g'"

#General Git
alias gm='git merge'
alias s='git status'
alias b='git branch'
alias bb='b | grep -v archive | grep -v backup'
alias c='bb'
alias bf='git branch | grep feature/'
alias bc='git checkout'
alias a='git add .'
alias m='git commit --signoff'
alias ma='m -a'
alias mm='m -m'
alias mam='m --amend'
alias lc='git log -2'
alias lco='lc --oneline'
alias gs='git stash'
alias gsp='git stash pop'
alias gr='git rebase'
alias gcp='git cherry-pick'
alias grm='gr main'
alias gdiff='git difftool -y'
alias git-show-commit-files='git diff-tree --no-commit-id --name-only -r'

#Remote Git
alias gpl='git pull'
alias gps='git push'
alias gf='git fetch'
alias gfu='gf upstream'
alias gpu='gpl --rebase upstream main:main'
alias gpum='gpl --rebase upstream master:master'
alias refetch-branch='function temp_func { a; git reset --hard; bc main; b -D $1; gf; bc $1 ; } ; temp_func'
alias mrefetch-branch='function temp_func { a; git reset --hard; bc master; b -D $1; gf; bc $1 ; } ; temp_func'
# $1: PR number, $2: branch name
alias checkout-pr='function temp_func { git fetch origin pull/${1}/head:${2} ; git checkout $2 ; } ; temp_func'

# Add git completion to aliases
__git_complete g __git_main
__git_complete bc _git_checkout
__git_complete gm _git_merge
__git_complete gpl _git_pull
__git_complete b _git_branch
__git_complete gr _git_rebase

#General Unix
alias l='ls -lh'
alias ll='l --all'
alias cl='clear -x'
alias cll='clear'
alias q='show | grep -i'
alias lk='ls | grep -i'
alias tl='| less'
alias p='pwd'
alias rp='realpath'
alias my-top='top -u $USERNAME'
alias du='du -h'
alias dus='du -s'
alias f='function temp_func { find . -name $1 ; } ; temp_func '
alias ff='function temp_func { find . -name $1 -type f ; } ; temp_func '
alias fd='function temp_func { find . -name $1 -type d ; } ; temp_func '
alias fii='function temp_func { find . -iname $1 ; } ; temp_func '
alias fr='function temp_func { find . -regex .*${1}.* ; } ; temp_func '
alias fri='function temp_func { find . -iregex .*${1}.* ; } ; temp_func '
alias word-wrap-on='setterm -linewrap on'
alias word-wrap-off='setterm -linewrap off'
alias cdk='function temp_func {  mkdir -p -- "$1" && cd -P -- "$1" ; } ; temp_func '
alias doloop='function temp_func { for i in {1.. ${1} }; do $2 ; done ; } ; temp_func '
# bug in Fedora
alias disable-pipewire='systemctl --user disable --now pipewire'

# Kubevirt & Kubernetes
alias kk="${KUBEVIRT_REPO}/cluster-up/kubectl.sh"
alias k='kk'
alias vv="${KUBEVIRT_REPO}/cluster-up/virtctl.sh"
alias v="${KUBEVIRT_REPO}/cluster-up/virtctl.sh"
alias d="${KUBEVIRT_REPO}/hack/dockerized"
alias init-cluser='make cluster-down && make cluster-up && make cluster-sync'
alias set-nodes-number='function temp_func { export KUBEVIRT_NUM_NODES=$1 ; } ; temp_func'
alias get-nodes-number='echo Number of nodes: $KUBEVIRT_NUM_NODES'
alias switch-repo1='KUBEVIRT_REPO="/home/iholder/Work/KubeVirt/kubevirt_repo/"; aliasupdate'
alias switch-repo2='KUBEVIRT_REPO="/home/iholder/Work/KubeVirt/kubevirt_repo2/"; aliasupdate'
alias get-artifacts='\
function temp_func { \
    TMP_URL=$( echo "${1}" | sed "s/.*kubevirt-prow/kubevirt-prow/g" | sed "s/artifacts.*/artifacts/g"); \
    gsutil -m cp -r "gs://$TMP_URL" .; \
    echo "$1" > ./artifacts/TAKEN_FROM.URL; \
} ; temp_func '
alias test-no-fmt='d "CI=${CI} ARTIFACTS=${ARTIFACTS} hack/bazel-test.sh"'
alias set-cgroup-v1='unset KUBEVIRT_CGROUPV2'
alias set-cgroup-v2='export KUBEVIRT_CGROUPV2="true"'

# Docker inside Podman
# NOTE: In current setting all docker metadata is ephemeral. This causes a relatively large warm-up.
# In the future this needs to be solved by sharing lib/docker dir ("-v kubevirt-docker:/var/lib/docker").
# Another (ugly) option is to copy this directory into container at build time which will save *some* of the downloads.

# In zeus:
#DOCKER_IN_DOCKER_ARGS="-it -d --user 0 --privileged --pids-limit=0 -v /root/Repos/kubevirt_in_docker${REPO2_ADDITION}:/home/iholder/kubevirt -v /root/docker-in-podman-data/repo${REPO2_ADDITION}:/var/lib/docker"
DOCKER_IN_DOCKER_ARGS="-it -d --user 0 --privileged --pids-limit=0 -v ${KUBEVIRT_REPO}:/kubevirt"
PODMAN_IN_DOCKER_TAG="16-07-23"
alias new-repo-container='function temp_func { sudo podman run $DOCKER_IN_DOCKER_ARGS quay.io/mabekitzur/kubevirtci:${PODMAN_IN_DOCKER_TAG} ; } ; temp_func'
alias into-container='function temp_func { sudo podman exec -it --user "iholder" $1 /bin/bash; }; temp_func'
alias into-container-root='function temp_func { sudo podman exec -it --user 0 $1 /bin/bash; }; temp_func'
alias kill-podman='function temp_func { podman stop $1; podman rm $1; }; temp_func'
# TODO: 1) automate chmod for docker socket 2) get .inputrc + .vimrc into container 3) enable completion
alias into-zeus='function temp_func { ssh root@zeus15.lab.eng.tlv2.redhat.com ; } ; temp_func '
alias zeus-sshutle='sshuttle --dns -vr root@zeus15.lab.eng.tlv2.redhat.com 192.168.127.0/2'
alias edit-kubevirt="k edit -n kubevirt kubevirt kubevirt"

# Remote Zeus
RSYNC_INCLUDE_LIST='--include='*.yaml' --include='*.go' --include='BUILD.bazel' --include='*.json' --include='*.sh' --include='go.mod' --include='WORKSPACE' --include='api.proto''
RSYNC_EXCLUDE_LIST='--exclude='vendor/' --exclude='_out/' --exclude='output/' --exclude='_ci-configs/' --exclude='.idea/' --exclude-from='.gitignore' --exclude='.git/''
RSYNC_FILE_LIST="${RSYNC_EXCLUDE_LIST} ${RSYNC_INCLUDE_LIST} --include='*/' --exclude='*'"
RSYNC_CORE_PARAMS='--chown=1000:1000 -pavmh'
RSYNC_ZEUS_ID='root@zeus15.lab.eng.tlv2.redhat.com'
RSYNC_PARAMS="${RSYNC_CORE_PARAMS} ${RSYNC_FILE_LIST}"
RSYNC_TEXT="Executing rsync with params ${RSYNC_PARAMS} and " # expected to follow with "echo $2" in functions below
alias send-to-zeus='function temp_func { echo -n "${RSYNC_TEXT}"; echo "${2}"; rsync ${2} ${RSYNC_PARAMS} . ${RSYNC_ZEUS_ID}:${1} ; } ; temp_func '
alias fetch-from-zeus='function temp_func { echo -n "${RSYNC_TEXT}"; echo "${2}"; rsync ${2} ${RSYNC_PARAMS} ${RSYNC_ZEUS_ID}:${1}/* . ; } ; temp_func '
alias into-k8s='cd ${KUBERNETES_REPO_DIR}; source ${KUBERNETES_ENV_FILE};'

# Zeus Specific
# The below is sometimes needed for cluster in containers to work on beaker
# modprobe ip_tables && echo ip_tables > /etc/modules-load.d/ip_tables.conf

# Docker and containers
alias stop-all-containers='docker stop `docker ps | tail -n+2 | tr -s " " | cut -d" " -f1 | xargs`'

# Custom containers
DEBUG_CONTAINER_TAG='17-07-23'
alias debug-container='\
function temp_func { \
	DIR_TO_COPY=$1; \
	CONTAINER_ID=`podman run -it -d --rm quay.io/mabekitzur/debug-fedora:${DEBUG_CONTAINER_TAG}`; \
	echo "CONTAINER ID: ${CONTAINER_ID:0:12}. DIR_TO_COPY: ${DIR_TO_COPY}"; \
	if [ -n "$DIR_TO_COPY" ]; then \
		podman cp "$DIR_TO_COPY" $CONTAINER_ID:/home/iholder; \
	fi; \
	podman exec -it "${CONTAINER_ID}" bash; \
	podman kill "${CONTAINER_ID}" > /dev/null; \
	podman rm --force "${CONTAINER_ID}" > /dev/null; \
} ; temp_func '

# Misc
alias quayio-login='docker login -u="mabekitzur" -p="ApOtc4szRbgfg/7h1+uRBb9wYdRj8UOJomItV7lsPtBKtGpnkAkNCQZ+yoLwAkOu" quay.io'
alias bazel='bazelisk'
alias goland='~/.local/bin/goland'

# Kubevirt Testing
alias test-reset-args='unset FUNC_TEST_ARGS'
alias test-run-until-fails='export FUNC_TEST_ARGS="--until-it-fails"'
alias test-run-N-times='function temp_func { export FUNC_TEST_ARGS="--repeat=${1}"; }; temp_func'

# Gotos
alias goto-kubevirt="cd $KUBEVIRT_REPO"
alias goto-buf="cd ~/Work/KubeVirt/buf"

# Clean up
unset THIS_FILE_PATH

