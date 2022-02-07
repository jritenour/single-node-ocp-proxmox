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

echo Downloading latest CoreOS live kernel

sudo wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.9/latest/rhcos-4.9.0-x86_64-live-kernel-x86_64 -P /var/www/html 

echo Downloading latest CoreOS live root file system 
sudo wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.9/latest/rhcos-4.9.0-x86_64-live-rootfs.x86_64.img -P /var/www/html

echo Downloading latest CoreOS live init image

sudo wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.9/latest/rhcos-4.9.0-x86_64-live-initramfs.x86_64.img -P /var/www/html

echo Copying ignition to www root

sudo cp ./sno-working/bootstrap-in-place-for-live-iso.ign /var/www/html/sno.ign
