#============================#
# vCenter connection details #
#============================#

variable "vsphere-user" {
  type        = string
  description = "VMWare vSphere cluster admin user"
  default     = "<vSphere admin-level user>"
}

variable "vsphere-password" {
  type        = string
  description = "VMWare vSphere admin user password"
  default     = "<password>"
# Turn on for production use. Will hide the entire custom variable entry
#  sensitive   = true
}

variable "vsphere-server" {
  type        = string
  description = "VMWare vCenter FQDN or IP address"
  default     = "<vCenter address>"
}

variable "vsphere-datacenter" {
  type        = string
  description = "VMWare vSphere Datacenter"
  default     = "<Datacenter>"
}
variable "vsphere-resource-pool" {
  type        = string
  description = "VMWare Resource Pool"
  default     = "<Select a resource pool>"
}

# Not currently used for the examples
variable "vsphere-cluster" {
  type        = string
  description = "VMWare vSphere cluster."
  default     = "<Cluster name>"
}

variable "vsphere-host" {
  type        = string
  description = "VMWare host"
  default     = "<ESX host to deploy on>"
}

# Optional
variable "vsphere-template-folder" {
  type        = string
  description = "Template folder"
  default     = "/<Path to >/Templates"
}

variable "network-data1" {
  type        = string
  description = "VMware production network 1"
  default     = "<Prod/Management network name>"
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
  default     = "<HA network name>"
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
  description = "DNS server list"
  default = "<Comma separated list of DNS servers>"
}

variable "default-gateway" {
  type = string
  description = "Default gateway"
  default = "<default gateway>"
}
variable "admin-password" {
  type        = string
  description = "Password for Hammerspace admin user"
  default     = "<password>"
#  sensitive  = true
}

variable "cluster-name" {
  type        = string
  description = "Site, Cluster and SMB Server name"
  default     = "<Hammerspace cluster name>"
}

variable "cluster-ip" {
  type    = string
  default = "<management IP, i.e. 192.168.1.3>"
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
  default     = "<path to Hammerspace OVA>"
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
  default = "<IP/NETMASK, i.e. 192.168.1.1/22>"
}

variable "HA-anvil1-hostname" {
  type = string
  description = "Hostname for Anvil 1"
  default = "<hostname, i.e. tf-anvil1>"
}

# Anvil 2 settings
variable "HA_anvil2-ip" {
  type = string
  default = "<IP/NETMASK, i.e. 192.168.1.2/22>"
}

variable "HA-anvil2-hostname" {
  type = string
  description = "Hostname for Anvil 2"
  default = "<hostname, i.e. tf-anvil2>"
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
  description = "List of IPs used for the DSX nodes"
  default = {
    "0" = "<IP/NETMASK, i.e. 192.168.1.4/22>",
    "1" = "<IP/NETMASK, i.e. 192.168.1.5/22>"
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
  description = "Linux virtual machine domain name for the machine"
  default     = "<Domain name>"
}

variable "prefix" {
  type        = string
  description = "Prefix for vm name and DSX hostname"
  default = "<string prefix, i.e. tf"
}

variable "vm-folder" {
  type = string
  description = "Folder where the provisioned VM will go"
  default = "/<ESX Folder>/"
}

variable "vm-datastore" {
  type        = string
  description = "Datastore used for all of the virtual machines"
  default     = "<Selected datastore>"
}
