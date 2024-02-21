# certbot is generating certs
# and uploading them as secrets

# certbot guide - https://eff-certbot.readthedocs.io/en/latest/using.html#renewing-certificates
# webhooks guide - https://github.com/adnanh/webhook/blob/master/docs/Hook-Definition.md
# run ansible in cron guide - https://ansible-runner-role.readthedocs.io/en/latest/example1-cron.html#example-1-run-ansible-playbooks-in-cron

# next steps:
#   x verify full certbot config and all options -- stop using geerling?
#   x preserve account info?
#   - install certs in nginx
#   - allow putting multiple secrets at once via webhook
#   - create persistent disk for letsencrypt files
#   - revoke test certs and cleanup vault
#   - diagram the flow here, including port 80 redir
#   - redirect "502 Bad Gateways" on port 80 (certbot down?) to HTTPS?

locals {
  // extract useful global config values
  ansible_control_node_url = module.config.ansible_control_node_url
  assigned_vmids           = module.config.vmids
  config_repository        = module.config.config_repository
  datastore_cloudinit      = module.config.proxmox_datastore_hdd
  datastore_hdd            = module.config.proxmox_datastore_hdd
  datastore_snippets       = module.config.proxmox_datastore_snippets
  datastore_ssd            = module.config.proxmox_datastore_ssd
  harbormaster_repository  = module.config.github_harbormaster_repository_url
  iso_ids                  = module.config.iso_ids
  proxmox_node             = module.config.proxmox_default_node
  all_users                = module.config.all_users

  // module specific config
  boot_disk_datastore = local.datastore_hdd
  data_vm_name        = "lab-certbot-data"
  users               = local.all_users
  vm_name             = "lab-certbot"
  vmid                = lookup(local.assigned_vmids, local.vm_name, null)
}

module "config" {
  source = "../_config"
}

module "attached_disk_config" {
  source = "github.com/pegasuspad/tf-modules.git//modules/pegasus-attached-disk-config?ref=main"

  name       = local.data_vm_name
  repository = local.config_repository
}

module "virtual_machine" {
  source = "github.com/pegasuspad/tf-modules.git//modules/proxmox-virtual-machine?ref=main"

  boot_iso_id          = local.iso_ids.ubuntu_2204_20240126
  cloud_init_datastore = local.datastore_cloudinit
  cloud_init_tasks     = [module.attached_disk_config.cloud_init_task, local.ansible_provisioning_task]
  data_disk_config     = module.attached_disk_config.data.attached_disks
  mac_address          = "aa:c3:79:ba:a5:e6"
  memory               = 512
  name                 = local.vm_name
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
