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
alias grep='grep -sI --color=auto' # add -Hn for file+line number
alias grep_src='grep --include=*.go --include=*.yaml --include=*.yml --include=*.sh --include=*.cpp --include=*.h --include=*.py --include=*.pl --include=*.c --include=*.hpp --include=*.i'
alias grep_here='function temp_func { grep $1 . -R; } ; temp_func'
alias grep_sh='grep_here --include=*.sh'
alias mk='make'
alias mkc='make clean; make'
alias docker='podman'
alias scale-text='function temp_func { gsettings set org.gnome.desktop.interface text-scaling-factor $1; } ; temp_func'
alias cls='cl; s'

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
# git checkout, but that trims username and columns.
# This is helpful for when copying a branch name from git, i.e. iholder101:branch-name
alias bc='function temp_func { git checkout `echo "$1" | cut -d":" -f2-`; } ; temp_func'
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
alias git-get-this-branch='git rev-parse --abbrev-ref HEAD'

#Remote Git
alias gpl='git pull'
alias gps='git push'
alias gf='git fetch'
alias gfu='gf upstream'
alias gpu='gpl --rebase upstream main:main'
alias gpum='gpl --rebase upstream master:master'
alias refetch-branch='function temp_func { BRANCH=${1:-$(git-get-this-branch)}; git clean -fd; a; git reset --hard; bc main; b -D $BRANCH; gf; bc $BRANCH ; } ; temp_func'
alias mrefetch-branch='function temp_func { BRANCH=${1:-$(git-get-this-branch)}; echo BRANCH: $BRANCH; git clean -fd; a; git reset --hard; bc master; b -D $BRANCH; gf; bc $BRANCH ; } ; temp_func'
# $1: PR number, $2: branch name
alias checkout-pr='function temp_func { git fetch origin pull/${1}/head:${2} ; git checkout $2 ; } ; temp_func'

# Add git completion to aliases
__git_complete g __git_main
__git_complete bc _git_checkout
__git_complete gm _git_merge
__git_complete gpl _git_pull
__git_complete b _git_branch
__git_complete gr _git_rebase
alias add-kubectl-completion="echo 'source <(kubectl completion bash)' >>~/.bashrc"

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

# Tools and conversions
alias human-bytes='function temp_func { numfmt --to=iec-i --format="%.2f" $1 ; } ; temp_func '
alias human-si='function temp_func { numfmt --to=si --format="%.2f" $1 ; } ; temp_func '

# Kubevirt & Kubernetes
alias kk="${KUBEVIRT_REPO}/kubevirtci/cluster-up/kubectl.sh"
alias k='kk'
alias vv="${KUBEVIRT_REPO}/kubevirtci/cluster-up/virtctl.sh"
alias v="${KUBEVIRT_REPO}/kubevirtci/cluster-up/virtctl.sh"
alias d="${KUBEVIRT_REPO}/hack/dockerized"
alias init-cluser='make cluster-down && make cluster-up && make cluster-sync'
alias set-nodes-number='function temp_func { export KUBEVIRT_NUM_NODES=$1 ; } ; temp_func'
alias get-nodes-number='echo Number of nodes: $KUBEVIRT_NUM_NODES'
alias switch-repo1='REPO2_ADDITION=1; KUBEVIRT_REPO="/home/iholder/Work/Repos/kubevirt"; aliasupdate'
alias switch-repo2='REPO2_ADDITION=2; KUBEVIRT_REPO="/home/iholder/Work/Repos/kubevirt2"; aliasupdate'
alias get-artifacts='\
function temp_func { \
    TMP_URL=$( echo "${1}" | sed "s/.*kubevirt-prow/kubevirt-prow/g" | sed "s/artifacts.*/artifacts/g"); \
    gsutil -m cp -r "gs://$TMP_URL" .; \
    echo "$1" > ./artifacts/TAKEN_FROM.URL; \
} ; temp_func '
alias test-no-fmt='d "CI=${CI} ARTIFACTS=${ARTIFACTS} hack/bazel-test.sh"'
alias set-cgroup-v1='unset KUBEVIRT_CGROUPV2'
alias set-cgroup-v2='export KUBEVIRT_CGROUPV2="true"'
alias node-ssh="${KUBEVIRT_REPO}/kubevirtci/cluster-up/ssh.sh"

# Docker inside Podman
# NOTE: In current setting all docker metadata is ephemeral. This causes a relatively large warm-up.
# In the future this needs to be solved by sharing lib/docker dir ("-v kubevirt-docker:/var/lib/docker").
# Another (ugly) option is to copy this directory into container at build time which will save *some* of the downloads.

# In zeus:
#DOCKER_IN_DOCKER_ARGS="-it -d --user 0 --privileged --pids-limit=0 -v /root/Repos/kubevirt_in_docker${REPO2_ADDITION}:/home/iholder/kubevirt -v /root/docker-in-podman-data/repo${REPO2_ADDITION}:/var/lib/docker"
DOCKER_IN_DOCKER_ARGS="-it -d --user 0 --privileged --pids-limit=0 -v ${KUBEVIRT_REPO}:/kubevirt -v /home/iholder/Work/Repos/docker-in-container-data/kubevirt${REPO2_ADDITION}:/var/lib/docker"
PODMAN_IN_DOCKER_TAG="10-03-24"
alias new-repo-container='function temp_func { sudo podman run --name=k${REPO2_ADDITION} $DOCKER_IN_DOCKER_ARGS quay.io/mabekitzur/kubevirtci:${PODMAN_IN_DOCKER_TAG} ; } ; temp_func'
alias into-container='function temp_func { sudo podman exec -it --privileged --user "iholder" $1 /bin/bash; }; temp_func'
alias into-container-root='function temp_func { sudo podman exec -it --privileged --user 0 $1 /bin/bash; }; temp_func'
alias kill-podman='function temp_func { podman stop $1; podman rm $1; }; temp_func'
# TODO: 1) automate chmod for docker socket 2) get .inputrc + .vimrc into container 3) enable completion
alias into-zeus='function temp_func { ssh root@zeus15.lab.eng.tlv2.redhat.com ; } ; temp_func '
alias zeus-sshutle='sshuttle --dns -vr root@zeus15.lab.eng.tlv2.redhat.com 192.168.127.0/2'
alias edit-kubevirt="k edit -n kubevirt kubevirt kubevirt"

# Remote Zeus
RSYNC_INCLUDE_LIST='--include='*.yaml' --include='*.go' --include='BUILD.bazel' --include='*.json' --include='*.sh' --include='go.mod' --include='WORKSPACE' --include='api.proto''
RSYNC_EXCLUDE_LIST='--exclude='vendor/' --exclude='_out/' --exclude='output/' --exclude='_ci-configs/' --exclude='.idea/' --exclude-from='.gitignore' --exclude='.git/''
RSYNC_FILE_LIST="${RSYNC_EXCLUDE_LIST} ${RSYNC_INCLUDE_LIST} --include='*/' --exclude='*'"
ZEUS_USER_NUMBER="1000"
RSYNC_CORE_PARAMS="-pamh" #"--chown=${ZEUS_USER_NUMBER}:${ZEUS_USER_NUMBER} -pamh"
RSYNC_ZEUS_ID='root@zeus15.lab.eng.tlv2.redhat.com'
RSYNC_PARAMS="${RSYNC_CORE_PARAMS} ${RSYNC_FILE_LIST}"
RSYNC_TEXT="Executing rsync with params ${RSYNC_PARAMS} and " # expected to follow with "echo $2" in functions below
alias send-to-zeus='function temp_func { echo -n "${RSYNC_TEXT}"; echo "${2}"; rsync ${2} ${RSYNC_PARAMS} . ${RSYNC_ZEUS_ID}:${1} ; } ; temp_func '
alias fetch-from-zeus='function temp_func { echo -n "${RSYNC_TEXT}"; echo "${2}"; rsync ${2} ${RSYNC_PARAMS} ${RSYNC_ZEUS_ID}:${1}/* . ; } ; temp_func '
alias into-k8s='cd ${KUBERNETES_REPO_DIR}; source ${KUBERNETES_ENV_FILE};'

# Avoid password with SSH:
# ssh-copy-id -i ~/.ssh/id_ed25519.pub root@zeus15.lab.eng.tlv2.redhat.com

# Run k8s test on GCP (project ID is openshift-gce-devel)
#
# A fresh GCP instance:
# export KUBE_SSH_USER=core && make test-e2e-node FOCUS="iholder" INSTANCE_PREFIX="iholder-swap" CLEANUP=false SSH_USER="core" KUBE_SSH_USER=core REMOTE=true RUNTIME=remote USE_DOCKERIZED_BUILD=false IMAGE_CONFIG_FILE="/workspace/test-infra/jobs/e2e_node/swap/image-config-swap-fedora.yaml" CONTAINER_RUNTIME_ENDPOINT="unix:///var/run/crio/crio.sock" TEST_ARGS='--kubelet-flags="--fail-swap-on=false --cgroup-driver=systemd --cgroups-per-qos=true --cgroup-root=/  --runtime-cgroups=/system.slice/crio.service --kubelet-cgroups=/system.slice/kubelet.service" --extra-log="{\"name\": \"crio.log\", \"journalctl\": [\"-u\", \"crio\"]}" --feature-gates=NodeSwap=true --service-feature-gates="NodeSwap=true"'
#
# Change config file to /workspace/test-infra/jobs/e2e_node/crio/latest/image-config-cgrpv2.yaml to make INSTANCE_PREFIX= to work but with a slightly different machine than CI
#
# Other useful flags: DELETE_INSTANCES=true CLEANUP=true
#
# An old GCP instance:
# export KUBE_SSH_USER=core && make test-e2e-node FOCUS="iholder" HOSTS="n1-standard-2-fedora-coreos-39-20240210-3-0-gcp-x86-64-de4f4820" CLEANUP=true SSH_USER="core" KUBE_SSH_USER=core REMOTE=true RUNTIME=remote USE_DOCKERIZED_BUILD=false IMAGE_CONFIG_FILE="/workspace/test-infra/jobs/e2e_node/swap/image-config-swap-fedora.yaml" CONTAINER_RUNTIME_ENDPOINT="unix:///var/run/crio/crio.sock" TEST_ARGS='--kubelet-flags="--fail-swap-on=false --cgroup-driver=systemd --cgroups-per-qos=true --cgroup-root=/  --runtime-cgroups=/system.slice/crio.service --kubelet-cgroups=/system.slice/kubelet.service" --extra-log="{\"name\": \"crio.log\", \"journalctl\": [\"-u\", \"crio\"]}" --feature-gates=NodeSwap=true --service-feature-gates="NodeSwap=true" 
#
# Please notice HOSTS that exists here instead of INSTANCE_PREFIX.
#
# Local testing (SELinux might get in the way):
# make test-e2e-node REMOTE=false CLEANUP=true FOCUS="SwapConformance" CONTAINER_RUNTIME_ENDPOINT=unix:///var/run/crio/crio.sock TEST_ARGS='--kubelet-flags="--cgroup-driver=systemd --fail-swap-on=false" --feature-gates=NodeSwap=true --service-feature-gates="NodeSwap=true"'
#
# For Serial testing, add: PARALLELISM=1 SKIP="dummy"
#
# Fix problem of kubelet not cleaned up: kill -9 `netstat -tulpn | grep 10255 | tr -s " " | cut -d" " -f8 | cut -d"/" -f1`
#
# Zeus Specific
# The below is sometimes needed for cluster in containers to work on beaker
# modprobe ip_tables && echo ip_tables > /etc/modules-load.d/ip_tables.conf
# gcloud init (project ID is openshift-gce-devel)
# Change kubelet's systemd to not fail on swap
#
# To run non-node tests on kind run:
# ./_output/bin/e2e.test -context kind-k8s-dev -ginkgo.focus=".*iholder.*" -provider=local -num-nodes=2 #-ginkgo.vv
#
# If ping doesn't work, do sudo sysctl -w net.ipv4.ping_group_range="0 2000"
alias ssh-gcloud='function temp_func { gcloud compute ssh core@${1}; }; temp_func'

# Docker and containers
alias stop-all-containers='docker stop `docker ps | tail -n+2 | tr -s " " | cut -d" " -f1 | xargs`'
alias docker-delete-everything='docker rm -f $(docker ps -a -q); docker rmi -f $(docker images -q); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q)'

# Kind
KIND_IMAGE_NAME="iholder-node-image:latest"
CLUSTER_NAME="k8s-dev"
KIND_CONFIG_FILE_PATH="/root/Repos/kind.config"
alias kind-setup-git-version="cd ${KUBERNETES_REPO}; export KUBE_GIT_VERSION=`git rev-parse HEAD`; cd -; echo KUBE_GIT_VERSION=$KUBE_GIT_VERSION"
alias kind-build-node-image="kind build node-image ${KUBERNETES_REPO} --image ${KIND_IMAGE_NAME}"
alias kind-create-cluster="kind delete cluster --name ${CLUSTER_NAME}; kind create cluster --config ${KIND_CONFIG_FILE_PATH} --image ${KIND_IMAGE_NAME} --name ${CLUSTER_NAME}; alias k=kubectl"
alias kind-init-cluster="kind-build-node-image; kind-create-cluster"
alias into-kind='export KUBE_GIT_VERSION="v1.30.0"; cd /root/Repos/; alias k=/root/Repos/kubernetes/_output/local/go/bin/kubectl'

# Custom containers
DEBUG_CONTAINER_TAG='17-07-23'
alias debug-container='\
function temp_func { \
	DIR_TO_COPY="$1"; \
	EXTRA_PODMAN_ARGS="$2"; \
	CONTAINER_ID=`podman run -it -d --rm ${EXTRA_PODMAN_ARGS} quay.io/mabekitzur/debug-fedora:${DEBUG_CONTAINER_TAG}`; \
	echo "CONTAINER ID: ${CONTAINER_ID:0:12}. DIR_TO_COPY: ${DIR_TO_COPY}. EXTRA PODMAN ARGS: ${EXTRA_PODMAN_ARGS}"; \
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
# Use this to find cluster's kubeconfig. Search kubeconfigs on that node
alias ssh-executor='ssh -l cloud-user -i ~/.ssh/cnv-qe-jenkins.key ocp-ipi-executor.cnv-qe.rhcloud.com'

# Kubevirt Testing
alias test-reset-args='unset FUNC_TEST_ARGS'
alias test-run-until-fails='export FUNC_TEST_ARGS="--until-it-fails"'
alias test-run-N-times='function temp_func { export FUNC_TEST_ARGS="--repeat=${1}"; }; temp_func'
alias install-metric-server='k apply -f https://raw.githubusercontent.com/pythianarora/total-practice/master/sample-kubernetes-code/metrics-server.yaml'

# Gotos
alias goto-kubevirt="cd $KUBEVIRT_REPO"
alias goto-k8s="cd $KUBERNETES_REPO"
alias goto-buf="cd ~/Work/KubeVirt/buf"
alias goto-repos="cd $KUBEVIRT_REPO/.."
alias goto-env="cd `dirname ${THIS_FILE_PATH}`"

# Clean up
unset THIS_FILE_PATH

