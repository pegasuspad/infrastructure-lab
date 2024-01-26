locals {
  boot_disk_datastore = local.datastore_ssd
  data_vm_name        = "lab-ansible-data"
  vm_name             = "lab-ansible"
  ip_address          = lookup(local.assigned_ips, local.vm_name, null)
  vmid                = lookup(local.assigned_vmids, local.vm_name, null)

  network_config = local.ip_address == null ? null : {
    ip_address        = local.ip_address
    gateway           = "10.111.1.1"
    dns_search_domain = "home.pegasuspad.com"
  }
}

module "attached_disk_config" {
  source = "../data-attached-disk-config"

  name       = local.data_vm_name
  repository = local.config_repository
}

module "virtual_machine" {
  source = "github.com/pegasuspad/tf-modules.git//modules/proxmox-virtual-machine?ref=main"

  boot_iso_id          = local.iso_ids.ubuntu_2204_20231026
  cloud_init_datastore = local.datastore_cloudinit
  cloud_init_tasks     = [module.attached_disk_config.cloud_init_task]
  data_disk_config     = module.attached_disk_config.data.attached_disks
  name                 = local.vm_name
  network_config       = local.network_config
  proxmox_node         = local.proxmox_node
  snippets_datastore   = local.datastore_snippets
  tags                 = ["devsecops", "lab"]
  vmid                 = local.vmid

  boot_disk = {
    datastore = local.boot_disk_datastore
    size      = 32
    ssd       = local.boot_disk_datastore == local.datastore_ssd
  }

  users = [
    {
      ssh_authorized_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1NsV1++UEBvGxN4IzWleJL1mCo9+ipfJ8w1NE2pCR3 skleinjung@node"]
      sudo     = true
      username = "sean"
    }
  ]
}
