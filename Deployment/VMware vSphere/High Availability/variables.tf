#============================#
# vCenter connection details #
#============================#

variable "vsphere-user" {
  type        = string
  description = "VMWare vSphere cluster admin user"
}

variable "vsphere-password" {
  type        = string
  description = "VMWare vSphere admin user password"
  sensitive   = true
}

variable "vsphere-server" {
  type        = string
  description = "VMWare vCenter FQDN or IP address"
}

variable "vsphere-datacenter" {
  type        = string
  description = "VMWare vSphere Datacenter"
}
variable "vsphere-resource-pool" {
  type        = string
  description = "VMWare Resource Pool"
}

# Not currently used for the examples
variable "vsphere-cluster" {
  type        = string
  description = "VMWare vSphere cluster."
}

variable "vsphere-host" {
  type        = string
  description = "VMWare host"
}

# Optional
variable "vsphere-template-folder" {
  type        = string
  description = "Template folder path."
}

variable "network-data1" {
  type        = string
  description = "VMware Prod/Management network name"
}

# Only needs to be used when separating management traffic
variable "network-data2" {
  type        = string
  description = "VMware production network 2"
  default     = null
}

variable "network-ha1" {
  type        = string
  description = "VMware production HA network 1"
}

#=================================== #
# Hammerspace deployment details      #
#=================================== #

variable "ntp-servers" {
  type = string
  description = "NTP server"
  default = "time.google.com"
}

variable "dns-servers" {
  type = string
  description = "Comma separated list of DNS servers"
}

variable "default-gateway" {
  type = string
  description = "Default gateway"
}
variable "admin-password" {
  type        = string
  description = "Password for Hammerspace admin user"
#  sensitive  = true
}

variable "cluster-name" {
  type        = string
  description = "Site, Cluster and SMB Server name"
}

variable "cluster-ip" {
  type    = string
  description = "management IP, e.g. 192.168.1.3"
}

variable "hammerspace-vm-guest-id" {
  type        = string
  description = "The ID of virtual machines operating system"
  default = "rhel7_64Guest"
}

variable "hammerspace-template-name" {
  type        = string
  description = "Hammerspace template name"
  default     = null
}

variable "hammerspace-ova-url" {
  type        = string
  description = "Hammerspace OVA url"
}

# Please see the installation guide for sizing recommendations
variable "HA-anvil-cpu" {
  type = number
  description = "CPU count for Anvil"
  default = 16
}

# Please see the installation guide for sizing recommendations
variable "HA-anvil-mem" {
  type = number
  description = "Amount of memory for Anvil"
  default = 32768
}

# Please see the installation guide for sizing recommendations
variable "HA-anvil-bootdisk" {
  type = number
  description = "Anvil boot disk (GB)"
  default = 200
}

# Please see the installation guide for sizing recommendations
variable "HA-anvil-metadatadisk" {
  type = number
  description = "Metadata disk (GB)"
  default = 300
}

# Anvil 1 settings
variable "HA_anvil1-ip" {
  type = string
  description = "IP/NETMASK, e.g. 192.168.1.1/22"
}

variable "HA-anvil1-hostname" {
  type = string
  description = "Hostname for Anvil 1"
  default = "tf-anvil1"
}

# Anvil 2 settings
variable "HA_anvil2-ip" {
  type = string
  description = "IP/NETMASK, e.g. 192.168.1.2/22"
}

variable "HA-anvil2-hostname" {
  type = string
  description = "Hostname for Anvil 2"
  default = "tf-anvil2"
}

# DSX
# The number of nodes must be the same or less than the number of dsx-ips listed
variable "dsx-count" {
  type = number
  description = "Number of DSX nodes"
  default = 2
}

variable "dsx-ips" {
  type        = map(any)
  description = "Map of IPs to use for the DSX nodes"
  default = {
    "0" = "192.168.1.4/22",
    "1" = "192.168.1.5/22"
  }
}

# Please see the installation guide for sizing recommendations
variable "DSX-cpu" {
  type = number
  description = "Amount of CPU for DSX"
  default = 2
}

# Please see the installation guide for sizing recommendations
variable "DSX-mem" {
  type = number
  description = "Amount of memory for DSX"
  default = 16384
}
variable "DSX-bootdisk" {
  type = number
  description = "DSX boot disk (GB)"
  default = 200
}

# This disk provides storage from the DSX, size it to your environment
variable "DSX-datadisk" {
  type = number
  description = "DSX data disk (GB)"
  default = 200
}
#=============================== #
# Global virtual machine details #
#=============================== #

variable "vm-domain" {
  type        = string
  description = "Domain name for the VMs."
}

variable "prefix" {
  type        = string
  description = "Prefix for VMs. Example: first-last-setup01"
}

variable "vm-folder" {
  type = string
  description = "Folder where the provisioned VM will go"
}

variable "vm-datastore" {
  type        = string
  description = "Datastore used for all of the virtual machines"
}
