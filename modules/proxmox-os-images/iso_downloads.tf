locals {
  // extract useful global config values
  datastore_isos      = module.config.proxmox_datastore_isos
  iso_sources         = module.config.iso_sources
  proxmox_node        = module.config.proxmox_default_node
}

module "config" {
  source = "../_config"
}

resource "proxmox_virtual_environment_download_file" "iso" {
  for_each = local.iso_sources

  checksum           = each.value.checksum
  checksum_algorithm = "sha256"
  content_type       = "iso"
  datastore_id       = local.datastore_isos
  file_name          = each.value.file_name
  node_name          = local.proxmox_node
  overwrite          = true
  url                = each.value.url
}
