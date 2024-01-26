locals {
  proxmox_default_node       = "proxmox-1"   
  proxmox_endpoint           = "https://10.111.1.11:8006"
  proxmox_datastore_hdd      = "local-hdd" 
  proxmox_datastore_isos     = "local-hdd"
  proxmox_datastore_snippets = "local-hdd"
  proxmox_datastore_ssd      = "local-nvme"
  proxmox_insecure           = true
  proxmox_ssh_user           = "root"
}
