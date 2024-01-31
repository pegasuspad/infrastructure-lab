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

# next step -- download proxies from ac onfig repo? figure out lets encrypt? in docker?!
# https://www.nginx.com/blog/deploying-nginx-nginx-plus-docker/
# also allow hard-coding a mac address, so the dhcp lease persists
# assign vmid without an ip?

module "harbormaster" {
  source = "github.com/pegasuspad/tf-modules.git//modules/cloudinit-harbormaster-install?ref=main"

  host_name  = "lab-nginx"
  repository = "https://github.com/pegasuspad/infrastructure-lab-harbormaster.git"
}

module "virtual_machine" {
  source = "github.com/pegasuspad/tf-modules.git//modules/proxmox-virtual-machine?ref=main"

  boot_iso_id          = local.iso_ids.ubuntu_2204_20240126
  cloud_init_datastore = local.datastore_cloudinit
  cloud_init_tasks     = module.harbormaster.tasks
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
