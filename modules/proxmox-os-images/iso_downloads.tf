module "iso_config" {
  source = "../data-proxmox-iso-config"
}

resource "proxmox_virtual_environment_download_file" "iso" {
  for_each = module.iso_config.iso_sources

  checksum           = each.value.checksum
  checksum_algorithm = "sha256"
  content_type       = "iso"
  datastore_id       = module.iso_config.iso_datastore_id
  file_name          = each.value.file_name
  node_name          = module.environment.proxmox_default_node
  overwrite          = true
  url                = each.value.url
}
