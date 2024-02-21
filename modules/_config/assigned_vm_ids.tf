locals {
  legacy_vmid_assignments = {
    101    = "coco"
    110    = "vrising-04"
    111    = "vrising-05"
    1012   = "proxy"
    9003   = "patchwork-blue"
    9005   = "archon-template"
    9007   = "archon-04"
    11000  = "nfs-blue"
    11010  = "prod-ansible"
    21001  = "gitea-green"
    21110  = "terraform-state"
    29000  = "coder-blue"
    42100  = "freshrss-blue"
    60000  = "nextcloud-blue"
    60001  = "nextcloud-green"
    60002  = "lms-00"
    60003  = "collabora-code"
    911000 = "nfs-disks"
    911010 = "prod-ansible-disks"
    921000 = "gitea-disks"
    921010 = "lab-ansible-disks"
    921110 = "terraform-state-disks"
    929000 = "coder-disks"
    942100 = "freshrss-disks"
    # not legacy, but ... manual
    5000000 = "lab-proxy"
    5000001 = "lab-certbot"
    95000001 = "lab-certbot-data"
  }

  # add data vm and legacy vmid assignments
  assigned_vmids = merge(
    {
      for id_suffix, host in local.assigned_id_suffixes : "9${local.subnet_id_prefix}${format("%03s", id_suffix)}" => "${host}-data"
      if host != null
    },
    {
      for id_suffix, host in local.assigned_id_suffixes : "${local.subnet_id_prefix}${format("%03s", id_suffix)}" => host
      if host != null
    },
    local.legacy_vmid_assignments
  )

  # convert our assignments from "value => host" to "host => value"
  vmid_assignments      = { for vmid, host in local.assigned_vmids : host => vmid }
}