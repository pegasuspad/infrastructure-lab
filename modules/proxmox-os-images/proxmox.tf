locals {
  // extract useful global config values
  github_owner        = module.config.github_repository_owner
  proxmox_endpoint    = module.config.proxmox_endpoint
  proxmox_insecure    = module.config.proxmox_insecure
  proxmox_ssh_user    = module.config.proxmox_ssh_user
}

terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.45.0"
    }
  }
}

provider "proxmox" {
  endpoint   = local.proxmox_endpoint
  insecure   = local.proxmox_insecure

  ssh {
    agent    = true
    username = local.proxmox_ssh_user
  }
}
