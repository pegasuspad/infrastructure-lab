terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.45.0"
    }
  }
}

provider "proxmox" {
  endpoint   = module.environment.proxmox_endpoint
  insecure   = module.environment.proxmox_insecure

  ssh {
    agent    = true
    username = module.environment.proxmox_ssh_user
  }
}
