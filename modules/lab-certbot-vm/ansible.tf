locals {
  ansible_cert_content  = file(module.config.ansible_control_node_cert)

  ca_certs_config = {
    trusted = [local.ansible_cert_content]
  }

  phone_home_config = {
    tries = 1
    url   = "${local.ansible_control_node_url}/hooks/provision?host=${local.vm_name}"
  }

  extra_config = yamlencode({
    ca_certs   = local.ca_certs_config
    phone_home = local.phone_home_config
  })

  ansible_provisioning_task = {
    extra_config = local.extra_config
  }
}

