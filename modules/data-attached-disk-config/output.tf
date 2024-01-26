output "cloud_init_task" {
  description = <<EOT
A cloud-init task that will ensure the disks described by the returned configuration will be properly formatted
and mounted. The value is suitable for use as a value passed to the `proxmox-virtual-machine` module's 
`cloud_init_tasks` variable, assuming that the config data`s "attached_disks" value is set as the virtual
machine's `data_disk_config`.
EOT
  value = module.disk_setup_task
}

output "data" {
  description = <<EOT
Config data for the requested VM. Will have the following properties:

  - attached_disks: array of disk configs, which matches the structure of proxmox_virtual_environment_vm.disk
  - vmid: vmid of the data disk vm
EOT
  value       = local.loaded_config
}
