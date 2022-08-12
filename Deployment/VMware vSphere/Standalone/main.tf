# =================== #
# Deploying VMware VM #
# =================== #

terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.2.0"
    }
  }
}

# Connect to VMware vSphere vCenter
provider "vsphere" {
  vim_keep_alive = 30
  user           = var.vsphere-user
  password       = var.vsphere-password
  vsphere_server = var.vsphere-server
  allow_unverified_ssl = "true"
}

## Define VMware vSphere specifics
 data "vsphere_datacenter" "dc" {
  name = var.vsphere-datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vm-datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

#data "vsphere_compute_cluster" "cluster" {
#  name          = var.vsphere-cluster
#  datacenter_id = data.vsphere_datacenter.dc.id
#}
data "vsphere_resource_pool" "pool" {
  name          = var.vsphere-resource-pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.vsphere-host
  datacenter_id = data.vsphere_datacenter.dc.id
}

# VM Networking
data "vsphere_network" "prod-data" {
  name          = var.network-data1
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "prod-mgmt" {
  name          = var.network-data1
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "prod-HA" {
  name          = var.network-ha1
  datacenter_id = data.vsphere_datacenter.dc.id
}

################################################################################

data "vsphere_ovf_vm_template" "ovf" {
  name             = "${var.prefix}-anvil-tmpl.${var.vm-domain}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  host_system_id   = data.vsphere_host.host.id
  local_ovf_path   = var.hammerspace-ova-url
#  remote_ovf_url   = var.hammerspace-ova-url

  ovf_network_map = {
    "VM Network" = data.vsphere_network.prod-data.id
    "VM Network 2" = data.vsphere_network.prod-mgmt.id
    "VM Network 3" = data.vsphere_network.prod-HA.id
  }
}

# Create standalone anvil VM
resource "vsphere_virtual_machine" "anvil_vm" {
  count = 1
  name             = "${var.prefix}-anvil.${var.vm-domain}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  host_system_id   = data.vsphere_host.host.id
  folder           = var.vm-folder
  num_cpus         = var.anvil-cpu
  memory           = var.anvil-mem
  guest_id = var.hammerspace-vm-guest-id
  datacenter_id = data.vsphere_datacenter.dc.id


  network_interface {
    network_id = data.vsphere_network.prod-data.id
  }
  network_interface {
    network_id = data.vsphere_network.prod-mgmt.id
  }
  network_interface {
    network_id = data.vsphere_network.prod-HA.id
  }


  disk {
    label = "${var.prefix}-disk1"
    thin_provisioned = true
    size  = var.anvil-bootdisk
  }

  disk {
    label = "${var.prefix}-disk2"
    thin_provisioned = true
    unit_number = 1
    size = var.anvil-metadatadisk
  }

  ovf_deploy {
    disk_provisioning    = "thin"
    ip_protocol          = "IPV4"
    ip_allocation_policy = "STATIC_MANUAL"
    local_ovf_path  = data.vsphere_ovf_vm_template.ovf.local_ovf_path
#    remote_ovf_url  = data.vsphere_ovf_vm_template.ovf.remote_ovf_url
    ovf_network_map = data.vsphere_ovf_vm_template.ovf.ovf_network_map

  }

  extra_config = {
    "guestinfo.ovfEnv" = <<EOT
{
      "cluster": {
           "gateway": {
               "ipv4_default": "${var.default-gateway}"
                   },
        "domainname": "${var.vm-domain}",
        "dns_servers": ["${var.dns-servers}"],
        "ntp_servers": ["${var.ntp-servers}"],
        "password": "${var.admin-password}"
      },
      "node": {
        "ha_mode": "Standalone",
        "hostname": "${var.prefix}-${var.anvil-hostname}",
        "networks": {
              "ens160": {
                 "ips": ["${var.anvil-ip}"],
                 "mtu": 1500
            }
      }
     }
    }
EOT
  }
}

# Create DSX VMs
resource "vsphere_virtual_machine" "dsx_vm" {
  count            = var.dsx-count
  name             = "${var.prefix}-dsx-${count.index + 1}.${var.vm-domain}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  host_system_id   = data.vsphere_host.host.id
  folder           = var.vm-folder
  num_cpus         = var.DSX-cpu
  memory           = var.DSX-mem
  guest_id         = var.hammerspace-vm-guest-id
  datacenter_id    = data.vsphere_datacenter.dc.id

  network_interface {
    network_id = data.vsphere_network.prod-data.id
  }
  network_interface {
    network_id = data.vsphere_network.prod-data.id
  }
  network_interface {
    network_id = data.vsphere_network.prod-data.id
  }

  disk {
    label = "${var.prefix}-disk1"
    thin_provisioned = true
    size  = var.DSX-bootdisk
  }

  disk {
    label = "${var.prefix}-disk2"
    thin_provisioned = true
    unit_number = 1
    size  = var.DSX-datadisk
  }

  ovf_deploy {
    disk_provisioning    = "thin"
    ip_protocol          = "IPV4"
    ip_allocation_policy = "STATIC_MANUAL"
    local_ovf_path  = data.vsphere_ovf_vm_template.ovf.local_ovf_path
#    remote_ovf_url  = data.vsphere_ovf_vm_template.ovf.remote_ovf_url
    ovf_network_map = data.vsphere_ovf_vm_template.ovf.ovf_network_map
  }

  extra_config = {
    "guestinfo.ovfEnv" = <<EOT
{
      "cluster": {
        "domainname": "${var.vm-domain}",
        "dns_servers": ["${var.dns-servers}"],
        "ntp_servers": ["${var.ntp-servers}"],
        "metadata": {
          "ips": ["${var.anvil-ip}"]
        },
        "gateway": {
            "ipv4_default": "${var.default-gateway}"
        },
        "password": "${var.admin-password}"
      },
      "node": {
        "add_volumes" : true,
        "features": ["storage", "portal"],
        "hostname": "${var.prefix}-dsx-${count.index + 1}",
        "networks": {
              "ens160": {
                  "roles" : ["data", "mgmt"],
                  "ips": ["${lookup(var.dsx-ips, count.index)}"],
                  "dhcp": false
            },
            "ens192": {
                "roles": [],
                "dhcp": false
            },
            "ens224": {
                "roles": [],
                "dhcp": false
            }
      }
     }
   }
EOT
  }
}
