#!/bin/bash
# This scrip will generate everything needed to create an ISO that will deploy a single node OpenShift instance using UPI, with a bootstrap server in place on the node. Portions of the script were derived from https://github.com/eranco74/bootstrap-in-place-poc

echo Downloading OpenShift install and  CLI binaries

curl -k https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-$OCP_VERSION/openshift-client-linux.tar.gz > oc.tar.gz

curl -k https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-$OCP_VERSION/openshift-install-linux.tar.gz > openshift-install-linux.tar.gz
echo Extracting binaries to /usr/local/bin
sudo tar zxf oc.tar.gz -C /usr/local/bin
sudo tar zxf openshift-install-linux.tar.gz -C /usr/local/bin
sudo chmod +x /usr/local/bin/oc
sudo chmod +x /usr/local/bin/openshift-install
echo Creating the working directory 'sno-working'
mkdir -p sno-working

echo Instantiating the install-config.yaml using env variables

cat >sno-working/install-config.yaml << EOF

apiVersion: v1
baseDomain: ${DOMAIN}
compute:
- architecture: amd64
  hyperthreading: Enabled
  name: worker
  platform: {}
  replicas: 0
controlPlane:
  architecture: amd64
  hyperthreading: Enabled
  name: master
  platform: {}
  replicas: 1
metadata:
  creationTimestamp: null
  name: ${CLUSTER}
platform:
  none: {}
BootstrapInPlace:
  InstallationDisk: /dev/sda
publish: External
pullSecret: '${PULL_SECRET}'
sshKey: '${SSH_KEY}'
EOF

echo Generating manifests...

openshift-install create manifests --dir=sno-working

echo Generating single node ignition config

openshift-install create single-node-ignition-config --dir=sno-working

echo Downloading CoreOS Live ISO to 'sno-working/base.iso'

ISO_URL=$(openshift-install coreos print-stream-json | grep location | grep x86_64 | grep iso | cut -d\" -f4)

curl $ISO_URL --retry 5 -o sno-working/base.iso 
echo Pulling and running coreos-installer container image to generate custom live ISO.

export ISO_PATH=sno-working/base.iso
export IGNITION_PATH=sno-working/bootstrap-in-place-for-live-iso.ign
export OUTPUT_PATH=sno-working/embedded.iso

podman run \
    --pull=always \
    --privileged \
    --rm \
    -v /dev:/dev \
    -v /run/udev:/run/udev \
    -v $(realpath $(dirname "$ISO_PATH")):/data:Z \
    -v $(realpath $(dirname "$IGNITION_PATH")):/ignition_data:Z \
    -v $(realpath $(dirname "$OUTPUT_PATH")):/output_data:Z \
    --workdir /data \
    quay.io/coreos/coreos-installer:release \
    iso ignition embed /data/$(basename "$ISO_PATH") \
    --force \
    --ignition-file /ignition_data/$(basename "$IGNITION_PATH") \
    --output /output_data/$(basename "$OUTPUT_PATH")

# Set Proxmox PVE IP as the $PROXMOXIP.  Will move this to Terraform & set a proper variable soon 
scp sno-working/embedded.iso root@$PROXMOXIP:/var/lib/vz/template/iso/sno.iso
