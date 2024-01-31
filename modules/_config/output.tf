output "all_users" {
  description = "Set of all user configs suitable for passing to a virtual machine module."
  value       = local.all_users
}

output "ansible_user_only" {
  description = "Set of  user configs suitable for passing to a virtual machine module. This set only includes the Ansible management user."
  value       = local.ansible_user_only
}

output "config_repository" {
  description = "Name of the config repository (for use with the util-config-save module) for this environment."
  value       = local.github_config_repository_name
}

output "github_harbormaster_repository_url" {
  description = "Name of the repository containing Harbormaster app configurations, for use with the cloudinit-harbormaster-install module."
  value       = local.github_harbormaster_repository_url
}

output "github_playbook_repository" {
  description = "Name of the repository containing Ansible playbooks, for use with the cloudinit-ansible-auto-provision module."
  value       = local.github_playbook_repository
}

output "github_repository_owner" {
  description = "Name of the organization which owns the Github repositories for this environment."
  value       = local.github_repository_owner
}

output "human_users_only" {
  description = "Set of  user configs suitable for passing to a virtual machine module. This set only includes the human user accounts."
  value       = local.human_users_only
}

output "ip_addresses" {
  description = "Map associating VM names to assigned IP addresses, if any."
  value       = local.ip_assignments
}

output "iso_datastore_id" {
  description = "Proxmox data store on which ISOs are stored."
  value       = local.iso_datastore_id
}

output "iso_sources" {
  description = "Details of all ISOs which are installed to the Proxmox cluster."
  value       = {
    # due to a bug in the version of cloud-init, this ISO cannot be used with the ansible provisioner
    ubuntu_2204_20231026 = {
      checksum  = "054db2d88c454bb0ad8dfd8883955e3946b57d2b0bf0d023f3ade3c93cdd14e5"
      file_name = "ubuntu-22.04-server-cloudimg-amd64-20231026.img"
      url       = "https://cloud-images.ubuntu.com/releases/22.04/release-20231026/ubuntu-22.04-server-cloudimg-amd64.img" 
    }
    ubuntu_2204_20240126 = {
      checksum  = "9f8a0d84b81a1d481aafca2337cb9f0c1fdf697239ac488177cf29c97d706c25"
      file_name = "ubuntu-22.04-server-cloudimg-amd64-20240126.img"
      url       = "https://cloud-images.ubuntu.com/releases/22.04/release-20240126/ubuntu-22.04-server-cloudimg-amd64.img" 
    }
  }
}

# @todo - build this dynamically from the same source as "iso_sources"
# ID is simply: <datastore_id>:iso/<file_name>
output "iso_ids" {
  description = "Map of available ISOs. The key is the logical ISO name, and the value is the ID."
  value       = {
    ubuntu_2204_20231026 = "${local.iso_datastore_id}:iso/ubuntu-22.04-server-cloudimg-amd64-20231026.img"
    ubuntu_2204_20240126 = "${local.iso_datastore_id}:iso/ubuntu-22.04-server-cloudimg-amd64-20240126.img"
  }
}

output "proxmox_datastore_hdd" {
  description = "ID of the default datastore backed by HDDs (slower but larger)."
  value       = local.proxmox_datastore_hdd
}

output "proxmox_datastore_isos" {
  description = "ID of the default datastore containing ISOs."
  value       = local.proxmox_datastore_isos
}

output "proxmox_datastore_snippets" {
  description = "ID of the default datastore containing snippets."
  value       = local.proxmox_datastore_snippets
}

output "proxmox_datastore_ssd" {
  description = "ID of the default datastore backed by SSDs (faster but smaller)."
  value       = local.proxmox_datastore_ssd
}

output "proxmox_default_node" {
  description = "Default node of the Proxmox cluster to which VMs are deployed."
  value       = local.proxmox_default_node
}

output "proxmox_endpoint" {
  description = "URL of the Proxmox API endpoint for this environment."
  value       = local.proxmox_endpoint
}

output "proxmox_insecure" {
  description = "Whether insecure TLS (i.e. untrusted self-signed certs) are allowed in this environment."
  value       = local.proxmox_insecure
}

output "proxmox_ssh_user" {
  description = "Username for ssh authentication to the Proxmox node."
  value       = local.proxmox_ssh_user
}

output "vmids" {
  description = "Map associating VM names to assigned VMIDs, if any."
  value       = local.vmid_assignments
}
