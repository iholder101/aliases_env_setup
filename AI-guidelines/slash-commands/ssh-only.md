# ssh-only

Please avoid editing any local files.
I repeat - NO LOCAL FILE EDITS - EVERYTHING IS VIA SSH!!! this is a hard requirement!

Instead, do everything over SSH.

You should use "ssh root@zeus15.lab.eng.tlv2.redhat.com".

Important paths:
Kubernetes repository: /root/Repos/kubernetes.
Kubevirt repository: /root/Repos/kubevirt_in_docker1.

Kubernetes information regarding running tests:
To run e2e tests, use this command as a template:

make test-e2e-node REMOTE=false CLEANUP=true FOCUS="ihol3" SKIP="dummy" CONTAINER_RUNTIME_ENDPOINT=unix:///var/run/crio/crio.sock TEST_ARGS='--kubelet-flags="--cgroup-driver=systemd --fail-swap-on=false" --feature-gates=ImageVolume=true,ImageVolumeWithDigest=true --service-feature-gates="ImageVolume=true,ImageVolumeWithDigest=true"'

FOCUS should be used to target only relevant tests, I usually inject "ihol3" to the test name that I wish to run.
You might want to "systemctl start crio" before running the tests, as it's not always running by default. You can check that with "systemctl status crio".

To run unit tests, run: "make test WHAT=...." while replacing .... with relevant packages.

To build, run "make".


Kubevirt information:
will be added in the future.

Key point:
DO NOT EDIT ANYTHING LOCALLY, USE ONLY SSH COMMANDS TO EDIT FILES REMOTELY AND RUN TESTS REMOTELY.

