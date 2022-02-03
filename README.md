# single-node-ocp-proxmox
Terraform + Shellscript for deploying OpenShift on Proxmox. This is intended to serve as an example more than something you'd actually use but if it helps, go for it!

This is the beginnings of a Terraform module that deploy a single node OpenShift environment in Proxmox using bootstrap in place.  

Set the variables to suit your environment.

You will need to manually create DNS records for api.cluster.domain, api-int.cluster.domain, and \*.apps.cluster.domain.  I would also advise doing a PTR record for your node's IP to a fqdn other than "localhost" as the OpenShift install process doesn't like nodes to be named localhost.  Alternatively, you could set a DHCP reservation with the name supplied through a DHCP option.

As it stands today, set the PROXMOXIP using an environment variable. This will be addressed next time I update this repo. 
