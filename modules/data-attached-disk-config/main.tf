terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 5.0"
    }
  }
}

locals {
  loaded_config = yamldecode(data.github_repository_file.config_file.content)
}

data "github_repository" "config" {
  name = var.repository
}

data "github_repository_file" "config_file" {
  repository          = data.github_repository.config.name
  branch              = "main"
  file                = "data-disk-vms/${var.name}.yml"
}

module "disk_setup_task" {
  source = "github.com/pegasuspad/tf-modules.git//modules/proxmox-cloudinit-disk-setup-task?ref=main"
  disk_config = local.loaded_config.attached_disks
}
