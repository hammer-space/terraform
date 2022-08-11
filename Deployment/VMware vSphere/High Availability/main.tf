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

# Create HA anvil VMs
resource "vsphere_virtual_machine" "anvil1_vm" {
  count            = 1
  name             = "${var.prefix}-anvil1.${var.vm-domain}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  host_system_id   = data.vsphere_host.host.id
  folder           = var.vm-folder
  num_cpus         = var.HA-anvil-cpu
  memory           = var.HA-anvil-mem
  guest_id         = var.hammerspace-vm-guest-id
  datacenter_id    = data.vsphere_datacenter.dc.id
  wait_for_guest_net_timeout = 0


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
    size  = var.HA-anvil-bootdisk
  }
  disk {
    label = "${var.prefix}-disk2"
    thin_provisioned = true
    unit_number = 1
    size  = var.HA-anvil-metadatadisk
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
        "domainname": ${var.vm-domain},
        "dns_servers": ["${var.dns-servers}"],
        "ntp_servers": ["${var.ntp-servers}"],
        "gateway": {
            "ipv4_default": "${var.default-gateway}"
        },
        "computer_name": ${var.cluster-name},
        "password": ${var.admin-password}
      },
      "nodes": {
        0: {
            "hostname": ${var.HA-anvil1-hostname},
            "features": ["metadata"],
            "ha_mode": "Secondary",
            "networks": {
                "ens160": {
                    "roles": ["data", "mgmt"],
                    "cluster_ips": ["${var.cluster-ip}"],
                    "ips" : ["${var.HA_anvil1-ip}"],
                    "dhcp": false
                },
                "ens192": {
                    "roles": [],
                    "dhcp": false
                },
                "ens224": {
                    "roles": ["ha"],
                    "dhcp": false
                }
            }
        },
        1: {
            "hostname": ${var.HA-anvil2-hostname},
            "features": ["metadata"],
            "ha_mode": "Primary",
            "networks": {
                "ens160": {
                    "roles": ["data", "mgmt"],
                    "cluster_ips": ["${var.cluster-ip}"],
                    "ips" : ["${var.HA_anvil2-ip}"],
                    "dhcp": false
                },
                "ens192": {
                    "roles": [],
                    "dhcp": false
                },
                "ens224": {
                    "roles": ["ha"],
                    "dhcp": false
                }
            }
        }
      },
      "node_index": "0"
    }
EOT
  }
}

resource "vsphere_virtual_machine" "anvil2_vm" {
  count            = 1
  name             = "${var.prefix}-anvil2.${var.vm-domain}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  host_system_id   = data.vsphere_host.host.id
  folder           = var.vm-folder
  num_cpus         = var.HA-anvil-cpu
  memory           = var.HA-anvil-mem
  guest_id         = var.hammerspace-vm-guest-id
  datacenter_id    = data.vsphere_datacenter.dc.id
  wait_for_guest_net_timeout = 0


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
    size  = var.HA-anvil-bootdisk
  }

  disk {
    label = "${var.prefix}-disk2"
    thin_provisioned = true
    unit_number = 1
    size  = var.HA-anvil-metadatadisk
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
        "domainname": ${var.vm-domain},
        "dns_servers": ["${var.dns-servers}"],
        "ntp_servers": ["${var.ntp-servers}"],
        "gateway": {
            "ipv4_default": "${var.default-gateway}"
        },
        "computer_name": ${var.cluster-name},
        "password": ${var.admin-password}
      },
      "nodes": {
        0: {
            "hostname": ${var.HA-anvil1-hostname},
            "features": ["metadata"],
            "ha_mode": "Secondary",
            "networks": {
                "ens160": {
                    "roles": ["data", "mgmt"],
                    "cluster_ips": ["${var.cluster-ip}"],
                    "ips" : ["${var.HA_anvil1-ip}"],
                    "dhcp": false
                },
                "ens192": {
                    "roles": [],
                    "dhcp": false
                },
                "ens224": {
                    "roles": ["ha"],
                    "dhcp": false
                }
            }
        },
        1: {
            "hostname": ${var.HA-anvil2-hostname},
            "features": ["metadata"],
            "ha_mode": "Primary",
            "networks": {
                "ens160": {
                    "roles": ["data", "mgmt"],
                    "cluster_ips": ["${var.cluster-ip}"],
                    "ips" : ["${var.HA_anvil2-ip}"],
                    "dhcp": false
                },
                "ens192": {
                    "roles": [],
                    "dhcp": false
                },
                "ens224": {
                    "roles": ["ha"],
                    "dhcp": false
                }
            }
        }
      },
      "node_index": "1"
    }
EOT
  }
}

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
        "domainname": ${var.vm-domain},
        "dns_servers": ["${var.dns-servers}"],
        "ntp_servers": ["${var.ntp-servers}"],
        "computer_name": ${var.cluster-name},
        "gateway": {
            "ipv4_default": "${var.default-gateway}"
        },
        "password": ${var.admin-password}
      },
      "node": {
        "add_volumes": true,
        "features": ["storage", "portal"],
        "hostname": "${var.prefix}-dsx-${count.index + 1}",
        "networks": {
            "ens160": {
                "roles": ["data", "mgmt"],
                "ips" : ["${lookup(var.dsx-ips, count.index)}"],
                "dhcp": false,
                "cluster_ips": ["${var.cluster-ip}"]
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
