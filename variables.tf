variable "domain" {
  description = "The root domain OpenShift will use for DNS"
  type        = string
  default     = "home.lab"
}

variable "cluster" {
  description = "The cluster name - will be a sub-domain of the domain var."
  type        = string
  default     = "test"
}

variable "ocp_version" {
  description = "The release of OpenShift to deploy."
  type        = string
  default     = "4.9"
}

variable "pull-secret" {
  description = "Secret used to grab OCP images from quay.io.  Currently not used"
  type	      = string
  default     = ""
}

variable "ssh-key" {
  description = "Key for SSHing into core account on OpenShift node. Should only be done for troubleshooting. Currently not used"
  type        = string
  default     = " "
}

variable "base_image" {
  description = "Base image used to install OpenShift"
  type        = string
  default     = "https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.9/4.9.0/rhcos-4.9.0-x86_64-live.x86_64.iso"
}

