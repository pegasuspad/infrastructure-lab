locals {
  legacy_ip_assignments = {
    "10.111.1.1"   = "opnsense"
    "10.111.1.2"   = "pihole-01"
    "10.111.1.3"   = "pihole-02"
    "10.111.1.5"   = "proxy"
    "10.111.1.10"  = "proxmox-optiplex"
    "10.111.1.11"  = "proxmox-typhon"
    "10.111.1.201" = "archon-04"
    "10.111.1.202" = "basement-pc"
    "10.111.1.203" = "nfs-blue"
    "10.111.1.204" = "coco"
    "10.111.1.205" = "lms-00"
    "10.111.1.206" = "gitea-green"
    "10.111.1.207" = "nextcloud-green"
    "10.111.1.208" = "freshrss-blue"
    "10.111.1.209" = "terraform-state"
    "10.111.1.210" = "collabora-code"
    "10.111.1.211" = "coder-blue"
  }
  
  # Reserved: 1-20
  # DHCP range: 100-199
  # Legacy static assignments: 201-211 (201+)
  # Available for static assignment: 21-99
  # Each id maps to assigned numbers as follows:
  #   - IP: 10.111.1.<id_suffix>
  #   - VMID: 111001<id_suffix> (i.e., the ip address, 111.001.<id_suffix>)
  #   - VMID (datadisk): 9000000000 + vmid for primary VM
  assigned_id_suffixes = {
    21  = "lab-coder"
    22  = "lab-ansible"
    23  = null
    24  = null
    25  = null
    26  = null
    27  = null
    28  = null
    29  = null
    # ... etc.
    # 199 = "last-address"
  }

  subnet_id_prefixes = {
    "10.111.1" = "5001"
  }
  subnet_id_prefix = local.subnet_id_prefixes["10.111.1"]

  # merge our assigned ids from above with the map of legacy assignments in use
  assigned_ip_addresses = merge(
    { 
      for id_suffix, host in local.assigned_id_suffixes : "10.111.1.${id_suffix}" => host
      if host != null
    },
    local.legacy_ip_assignments
  )

  # convert our assignments from "value => host" to "host => value"
  ip_assignments        = { for ip, host in local.assigned_ip_addresses : host => ip }
}