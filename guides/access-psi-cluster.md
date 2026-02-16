1. SSH connection
ssh -l cloud-user -i ~/.ssh/cnv-qe-jenkins.key ocp-ipi-executor.rhos-psi.cnv-qe.rhood.us

2. Find kubeconfig
find / -name kubeconfig -type f -regex .*iholder.* 2>/dev/null

3. Grab relevant files
scp -i ~/.ssh/cnv-qe-jenkins.key cloud-user@ocp-ipi-executor.rhos-psi.cnv-qe.rhood.us:<PATH>/* .

4. For UI:
oc whoami --show-console
Password in the kubeadmin-password file


