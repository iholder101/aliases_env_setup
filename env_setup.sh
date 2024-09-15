# Global paths
REPO_DIR="/home/${USER}/Work/Repos/"
KUBEVIRT_REPO="${REPO_DIR}/kubevirt/"
KUBERNETES_REPO="${REPO_DIR}/kubernetes/"

# Kubevirt/Kubernetes setup
export KUBEVIRT_PROVIDER=k8s-1.30 # this is also the default if no KUBEVIRT_PROVIDER is set
export KUBECONFIG=${KUBEVIRT_REPO}/_ci-configs/${KUBEVIRT_PROVIDER}/.kubeconfig
export KUBEVIRT_NUM_NODES=2
export KUBEVIRT_STORAGE=rook-ceph-default
export KUBEVIRTCI_PODMAN_SOCKET=/usr/lib/systemd/system/podman.socket
#export GOOGLE_APPLICATION_CREDENTIALS="/home/iholder/ENV/gcp-service-account-creds.json"

# Auto-completion key bindings
complete -F __start_kubectl k # To enable kubectl auto-completion. Also supports "k" alias
complete -F __start_kubectl kk

# Command-Prompt
# *Note* - invisible characters need to be wrapped with \[ and \] in order for the terminal to wrap text correctly.
NAME_ON_CMD_PROMPT="iholder"
purple="\[\033[1;95m\]"
blue="\[\033[1;94m\]"
end="\[\033[0m\]"
PS1="${blue}${NAME_ON_CMD_PROMPT}[${purple}\w${blue}]${end}> "
unset purple blue end

# Enable git completion
source "$(pkg-config --variable=completionsdir bash-completion)"/git

# Set vim as default editor
export VISUAL=vim
export EDITOR="$VISUAL"

# Zeus-related
export KUBERNETES_ENV_FILE='/root/Repos/kubernetes.env'
export KUBERNETES_REPO_DIR='/root/Repos/kubernetes'

# Gnome settings
gsettings set org.gnome.mutter workspaces-only-on-primary true

export REPO2_ADDITION=1
