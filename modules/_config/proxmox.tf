locals {
  proxmox_default_node       = "proxmox-1"   
  proxmox_endpoint           = "https://10.111.1.11:8006"
  proxmox_datastore_hdd      = "lab-hdd" 
  proxmox_datastore_isos     = "lab-hdd"
  proxmox_datastore_snippets = "lab-hdd"
  proxmox_datastore_ssd      = "local-nvme"
  proxmox_insecure           = true
  proxmox_ssh_user           = "root"
}
