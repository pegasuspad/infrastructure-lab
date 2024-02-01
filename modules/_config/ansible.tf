locals {
  ansible_control_node_cert   = "${path.module}/certs/lab-ansible.crt"
  ansible_control_node_url    = "https://lab-ansible:9000"
  ansible_playbook_repository = "https://github.com/pegasuspad/lab-infrastructure-ansible.git"
}
