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