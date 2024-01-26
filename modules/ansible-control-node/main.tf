locals {
  // extract useful global config values
  assigned_ips        = module.config.ip_addresses
  assigned_vmids      = module.config.vmids
  config_repository   = module.config.config_repository
  datastore_cloudinit = module.config.proxmox_datastore_hdd
  datastore_snippets  = module.config.proxmox_datastore_snippets
  datastore_ssd       = module.config.proxmox_datastore_ssd
  iso_ids             = module.config.iso_ids
  proxmox_node        = module.config.proxmox_default_node
  human_users_only    = module.config.human_users_only

  // module specific config
  boot_disk_datastore = local.datastore_ssd
  data_vm_name        = "lab-ansible-data"
  ip_address          = lookup(local.assigned_ips, local.vm_name, null)
  users               = local.human_users_only
  vm_name             = "lab-ansible"
  vmid                = lookup(local.assigned_vmids, local.vm_name, null)

  network_config = local.ip_address == null ? null : {
    ip_address        = local.ip_address
    gateway           = "10.111.1.1"
    dns_search_domain = "home.pegasuspad.com"
  }

  ansible_init_task = {
    apt_sources = {
      "ansible-jammy.list" = {
        keyid = "6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367",
        source ="deb http://ppa.launchpad.net/ansible/ansible/ubuntu jammy main"
      }
    }
    packages = [
      "ansible",
      "git",
      "python3-pip",
    ]
    runcmd = [
      "cp /var/lib/ansible/ssh-keys/* /home/sean/.ssh/",
      "chown sean:sean /home/sean/.ssh/id_ed25519"
    ]
  }
}

module "config" {
  source = "../_config"
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
  cloud_init_tasks     = [module.attached_disk_config.cloud_init_task, local.ansible_init_task]
  data_disk_config     = module.attached_disk_config.data.attached_disks
  name                 = local.vm_name
  network_config       = local.network_config
  proxmox_node         = local.proxmox_node
  snippets_datastore   = local.datastore_snippets
  tags                 = ["devsecops", "lab"]
  users                = local.users
  vmid                 = local.vmid

  boot_disk = {
    datastore = local.boot_disk_datastore
    size      = 32
    ssd       = local.boot_disk_datastore == local.datastore_ssd
  }
}
