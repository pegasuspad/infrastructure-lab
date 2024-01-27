locals {
  // extract useful global config values
  assigned_ips        = module.config.ip_addresses
  assigned_vmids      = module.config.vmids
  config_repository   = module.config.config_repository
  datastore_cloudinit = module.config.proxmox_datastore_hdd
  datastore_snippets  = module.config.proxmox_datastore_snippets
  datastore_ssd       = module.config.proxmox_datastore_ssd
  iso_ids             = module.config.iso_ids
  playbook_repository = module.config.github_playbook_repository
  proxmox_node        = module.config.proxmox_default_node
  all_users           = module.config.all_users

  // module specific config
  boot_disk_datastore = local.datastore_ssd
  data_vm_name        = "lab-nginx-data"
  ip_address          = lookup(local.assigned_ips, local.vm_name, null)
  users               = local.all_users
  vm_name             = "lab-nginx"
  vmid                = lookup(local.assigned_vmids, local.vm_name, null)

  network_config = local.ip_address == null ? null : {
    ip_address        = local.ip_address
    gateway           = "10.111.1.1"
    dns_search_domain = "home.pegasuspad.com"
  }
}

module "config" {
  source = "../_config"
}

module "ansible" {
  source = "github.com/pegasuspad/tf-modules.git//modules/cloudinit-ansible-auto-provision?ref=main"

  host_name    = local.vm_name
  repository   = local.playbook_repository
  vault_secret = var.ansible_vault_secret

  galaxy_collections = [
    "git+https://github.com/pegasuspad/ansible-roles.git,main",
    "community.docker:>=3.6.0"
  ]

  galaxy_roles = [
    "geerlingguy.docker,7.0.1",
    "geerlingguy.pip,2.2.0",
    "stefangweichinger.ansible_rclone,0.1.2"
  ]
}

module "virtual_machine" {
  source = "github.com/pegasuspad/tf-modules.git//modules/proxmox-virtual-machine?ref=main"

  boot_iso_id          = local.iso_ids.ubuntu_2204_20240126
  cloud_init_datastore = local.datastore_cloudinit
  cloud_init_tasks     = [module.ansible.task]
  memory               = 2048
  name                 = local.vm_name
  network_config       = local.network_config
  proxmox_node         = local.proxmox_node
  snippets_datastore   = local.datastore_snippets
  tags                 = ["infrastructure", "lab"]
  users                = local.users
  vmid                 = local.vmid

  boot_disk = {
    datastore = local.boot_disk_datastore
    size      = 32
    ssd       = local.boot_disk_datastore == local.datastore_ssd
  }
}
