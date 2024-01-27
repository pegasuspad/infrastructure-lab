locals {
  // extract useful global config values
  github_owner        = module.config.github_repository_owner
  proxmox_endpoint    = module.config.proxmox_endpoint
  proxmox_insecure    = module.config.proxmox_insecure
  proxmox_ssh_user    = module.config.proxmox_ssh_user
}

terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "~> 5.45"
    }

    proxmox = {
      source = "bpg/proxmox"
      version = "0.38.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# GITHUB_TOKEN must be set in the environment
provider "github" {
  owner = local.github_owner
}

provider "proxmox" {
  endpoint   = local.proxmox_endpoint
  insecure   = local.proxmox_insecure

  ssh {
    agent    = true
    username = local.proxmox_ssh_user
  }
}

provider "random" {}