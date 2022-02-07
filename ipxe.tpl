#!ipxe

set STREAM stable
set VERSION 4.9

set console console=ttyS1,115200n8

set BASEURL http://${BASTION_IP}

kernel ${BASEURL}/rhcos-4.9.0-x86_64-live-kernel-x86_64 initrd=main coreos.live.rootfs_url=${BASEURL}/rhcos-4.9.0-x86_64-live-rootfs.x86_64.img ignition.firstboot ignition.platform.id=metal ignition.config.url=${BASEURL}/sno.ign console=ttyS1,115200 systemd.unified_cgroup_hierarchy=0
initrd --name main ${BASEURL}/rhcos-4.9.0-x86_64-live-initramfs.x86_64.img

boot
