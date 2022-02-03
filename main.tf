terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.7.4"
    }
  }
}


resource "null_resource" "bastion_iso_gen" {

  provisioner "local-exec" {
    command = "./sno-iso.sh"

    environment = {
      DOMAIN        = var.domain
      CLUSTER       = var.cluster
      OCP_VERSION   = var.ocp_version
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://192.168.2.4:8006/api2/json"
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "resource-name" {
  name        = "snocp"
  target_node = "pve"
  iso         = "local:iso/sno.iso"
  agent       = 0
  memory      = 32768
  guest_agent_ready_timeout = 5
  sockets     = 4
  cores	      = 1
  bootdisk     = "scsi0"
  boot        = "order=scsi0;ide2;net0"
  network     {
    model     = "virtio"
    firewall  = true
    bridge    = "vmbr0"
  }
  scsihw      = "virtio-scsi-pci"
  disk {
    type      = "scsi"
    size      = "100G"
    storage   = "local-lvm"
  }
  depends_on = [null_resource.bastion_iso_gen]
}

