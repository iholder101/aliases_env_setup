#
# ~~ Itamar Holder's aliases ~~
#
#

### GENERAL ALIAS CONFIGS ###
THIS_FILE_PATH="~/ENV/aliases.sh"
ENV_FILE_PATH="~/ENV/env_setup.sh"

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
alias grep='grep -Hns'
alias grep_src='grep --include=*.go --include=*.yaml --include=*.yml --include=*.sh --include=*.cpp --include=*.h --include=*.py --include=*.pl --include=*.c --include=*.hpp --include=*.i'
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
alias grm='gr main'
alias gdiff='git difftool'
alias git-show-commit-files='git diff-tree --no-commit-id --name-only -r'

#Remote Git
alias gpl='git pull'
alias gps='git push'
alias gf='git fetch'
alias gfu='gf upstream'
alias gpu='gpl --rebase upstream main:main'

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
alias grep='grep --color=auto'
alias f='function temp_func { find . -name $1 ; } ; temp_func '
alias fii='function temp_func { find . -iname $1 ; } ; temp_func '
alias fr='function temp_func { find . -regex .*${1}.* ; } ; temp_func '
alias fri='function temp_func { find . -iregex .*${1}.* ; } ; temp_func '
alias word-wrap-on='setterm -linewrap on'
alias word-wrap-off='setterm -linewrap off'
alias cdk='function temp_func {  mkdir -p -- "$1" && cd -P -- "$1" ; } ; temp_func '
alias doloop='function temp_func { for i in {1.. ${1} }; do $2 ; done ; } ; temp_func '
# bug in Fedora
alias fix-sound='pulseaudio -k && sudo alsa force-reload && systemctl --user restart pipewire'

# Kubevirt & Kubernetes
alias kk="${KUBEVIRT_REPO}/cluster-up/kubectl.sh"
alias k='kk'
alias vv="${KUBEVIRT_REPO}/cluster-up/virtctl.sh"
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

# Docker inside Podman
# NOTE: In current setting all docker metadata is ephemeral. This causes a relatively large warm-up.
# In the future this needs to be solved by sharing lib/docker dir ("-v kubevirt-docker:/var/lib/docker").
# Another (ugly) option is to copy this directory into container at build time which will save *some* of the downloads.
DOCKER_IN_DOCKER_ARGS="-it -d --user 0 --privileged --pids-limit=0 -v ${KUBEVIRT_REPO}:${KUBEVIRT_REPO}"
PODMAN_IN_DOCKER_TAG="12-07-2021"
alias new-repo-container='function temp_func { sudo podman run $DOCKER_IN_DOCKER_ARGS kubevirt-dev:${PODMAN_IN_DOCKER_TAG} ; } ; temp_func'
alias into-container='function temp_func { sudo podman exec -it --user "iholder" $1 /bin/bash; }; temp_func'
alias into-container-root='function temp_func { sudo podman exec -it --user 0 $1 /bin/bash; }; temp_func'
# TODO: 1) automate chmod for docker socket 2) get .inputrc + .vimrc into container 3) enable completion

# Misc
alias quayio-login='docker login -u="mabekitzur" -p="FfgbBoCu+V8sKaLOBgIFCeqkrb3fZ2734jrJZD/2u93EeV6hr9DMep8gEk2SNIpz" quay.io'
alias bazel='bazelisk'
alias goland='~/.local/bin/goland'

# Gotos
alias goto-kubevirt="cd $KUBEVIRT_REPO"
alias goto-buf="cd ~/Work/KubeVirt/buf"

# Clean up
unset THIS_FILE_PATH

