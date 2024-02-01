locals {
  // extract useful global config values
  assigned_vmids          = module.config.vmids
  config_repository       = module.config.config_repository
  datastore_cloudinit     = module.config.proxmox_datastore_hdd
  datastore_snippets      = module.config.proxmox_datastore_snippets
  datastore_ssd           = module.config.proxmox_datastore_ssd
  harbormaster_repository = module.config.github_harbormaster_repository_url
  playbook_repository     = module.config.ansible_playbook_repository
  iso_ids                 = module.config.iso_ids
  proxmox_node            = module.config.proxmox_default_node
  human_users_only        = module.config.human_users_only

  // module specific config
  boot_disk_datastore = local.datastore_ssd
  data_vm_name        = "lab-ansible-data"
  admin_username      = "ops"
  users               = [
    {
      ssh_authorized_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1NsV1++UEBvGxN4IzWleJL1mCo9+ipfJ8w1NE2pCR3 skleinjung@node"]
      sudo                = true
      username            = local.admin_username
    }
  ]
  vm_name             = "lab-ansible"
  vmid                = lookup(local.assigned_vmids, local.vm_name, null)

  install_ansible_task = {
    apt_sources = {
      "ansible-jammy.list" = {
        keyid = "6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367",
        source ="deb http://ppa.launchpad.net/ansible/ansible/ubuntu jammy main"
      }
    }
    packages = [
      "ansible",
      "git",
      "python3-pip",
    ]
    runcmd = [
      "cp /var/lib/ansible/ssh-keys/* /home/${local.admin_username}/.ssh/",
      "chown ${local.admin_username}:${local.admin_username} /home/${local.admin_username}/.ssh/id_ed25519"
    ]
  }

  # checkout our ansible repository, and run the playbook against this host one time
  # it is expected that the playbook will perform any configuration necessary for future runs
  bootstrap_ansible_task = {
    runcmd = [
      "cd /run",
      "git clone '${local.playbook_repository}' ansible-bootstrap",
      "cd ansible-bootstrap",
      "ansible-galaxy install -r project/requirements.yml",
      "ansible-playbook -i inventory -l '${local.vm_name}' --vault-id lab@/var/lib/ansible/vault-password project/playbook.yml >>/var/log/ansible-bootstrap.log 2>&1",
      "rm -rf /run/ansible-bootstrap"
    ],
    write_files = [
      {
        content = "export PROJECT_REPOSITORY_URL=${local.playbook_repository}"
        owner   = "root:root"
        path    = "/etc/ansible-runner/environment.sh"
        permissions = "0755"
      }
    ]
  }
}

module "config" {
  source = "../_config"
}

module "attached_disk_config" {
  source = "github.com/pegasuspad/tf-modules.git//modules/pegasus-attached-disk-config?ref=main"

  name       = local.data_vm_name
  repository = local.config_repository
}

module "virtual_machine" {
  source = "github.com/pegasuspad/tf-modules.git//modules/proxmox-virtual-machine?ref=main"

  boot_iso_id          = local.iso_ids.ubuntu_2204_20231026
  cloud_init_datastore = local.datastore_cloudinit
  cloud_init_tasks     = [module.attached_disk_config.cloud_init_task, local.install_ansible_task, local.bootstrap_ansible_task]
  data_disk_config     = module.attached_disk_config.data.attached_disks
  mac_address          = "aa:28:91:f5:3d:16"
  name                 = local.vm_name
  proxmox_node         = local.proxmox_node
  snippets_datastore   = local.datastore_snippets
  tags                 = ["devsecops", "lab"]
  users                = local.users
  vmid                 = local.vmid

  boot_disk = {
    datastore = local.boot_disk_datastore
    size      = 32
    ssd       = local.boot_disk_datastore == local.datastore_ssd
  }
}
