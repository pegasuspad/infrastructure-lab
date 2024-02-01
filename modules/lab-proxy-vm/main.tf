locals {
  // extract useful global config values
  ansible_control_node_cert = module.config.ansible_control_node_cert
  ansible_control_node_url  = module.config.ansible_control_node_url
  assigned_ips              = module.config.ip_addresses
  assigned_vmids            = module.config.vmids
  config_repository         = module.config.config_repository
  datastore_cloudinit       = module.config.proxmox_datastore_hdd
  datastore_snippets        = module.config.proxmox_datastore_snippets
  datastore_ssd             = module.config.proxmox_datastore_ssd
  iso_ids                   = module.config.iso_ids
  proxmox_node              = module.config.proxmox_default_node
  all_users                 = module.config.all_users

  // module specific config
  boot_disk_datastore = local.datastore_ssd
  data_vm_name        = "lab-proxy-data"
  ip_address          = lookup(local.assigned_ips, local.vm_name, null)
  users               = local.all_users
  vm_name             = "lab-proxy"
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

# nextcloud - cron broken
# assign vmid without an ip?

module "virtual_machine" {
  source = "github.com/pegasuspad/tf-modules.git//modules/proxmox-virtual-machine?ref=main"

  boot_iso_id          = local.iso_ids.ubuntu_2204_20240126
  cloud_init_datastore = local.datastore_cloudinit
  mac_address          = "aa:59:b5:53:b6:2f"
  memory               = 512
  name                 = local.vm_name
  network_config       = local.network_config
  proxmox_node         = local.proxmox_node
  snippets_datastore   = local.datastore_snippets
  startup_phase        = "infrastructure"
  tags                 = ["lab"]
  users                = local.users
  vmid                 = local.vmid

  boot_disk = {
    datastore = local.boot_disk_datastore
    size      = 32
    ssd       = local.boot_disk_datastore == local.datastore_ssd
  }
}

# rerun Ansible provsioning whenever the revision ID of our VM changes
resource "terraform_data" "trigger_ansible" {
  triggers_replace = [ 
    module.virtual_machine.revision_id 
  ]

  provisioner "local-exec" {
    command = "curl -s --cacert '${local.ansible_control_node_cert}' '${local.ansible_control_node_url}/hooks/provision?host=${local.vm_name}'"
  }
}