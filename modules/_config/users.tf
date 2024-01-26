locals {
  user_ansible = {
    ssh_authorized_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJL4OsAjfkVCXSf6rlt3csDpyM6Anl0cvkbqFd6uZ1lK ansible user (lab-ansible)"]
    sudo                = true
    username            = "ansible"
  }

  user_sean = {
    ssh_authorized_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1NsV1++UEBvGxN4IzWleJL1mCo9+ipfJ8w1NE2pCR3 skleinjung@node"]
    sudo                = true
    username            = "sean"
  }

  all_users         = [local.user_ansible, local.user_sean]
  ansible_user_only = [local.user_ansible]
  human_users_only  = [local.user_sean]
}