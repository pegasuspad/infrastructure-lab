# infrastructure-lab

Terraform module defining the Pegasus homelab infrastructure.

## Patterns and Conventions

### Glossary

- `data VM`: a data VM is a Proxmox virtual machine with no OS installed which is never intended to be booted. Instead, it is used to provisions disks that are attached to another (bootable) VM. The purpose of this is to allowable the bootable VM to be destroyed and recreated without losing the persistent disks. This pattern is illustrated in the documentation for our Terraform provider: https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm#example-attached-disks

### Naming Conventions

- Module names ending in `-vm` create a Proxmox VM. The VM name is the module name, excluding this suffix.

## Modules

### _config

Data module that has outputs for configuration options shared by all resources in the "lab"
environment, such as Proxmox connection details, datastore types, user ssh keys, etc.

### data-attached-disk-config

Data module that exports the necessary configuration to attach the disks from a data VM to another virtual machine. This configuration includes a description of the exported disks (mountpoint, size, path on the Proxmox node, etc.) as well as a cloud-init task that will properly format and mount those disks.

For more information see the module's outputs, as well as the following variables of the `proxmox_virtual_machine` module: `cloud_init_tasks`, `data_disk_config`.

### github-config-store

Creates a Github repository to hold configuration data for the `lab` environment. Intended for use with the `util-config-load`, `util-config-save`, `data-attached-disk-config`, and similar modules.

See the [pegasuspad/infrastructure-lab-config](https://github.com/pegasuspad/infrastructure-lab-config) repository.

### lab-ansible-vm

Creates an Ansible control node that can be used to manage lab resources, as well as test
Ansible provisioning changes before they are promoted to another environment.

### lab-ansible-data-vm

Creates the data VM for the `lab-ansible` resource. This is used to persist Ansible configuration, .ssh keys, and other resources for the lab-ansible node.

### lab-coder-vm (WIP)

Creates a VM to run [Coder](https://coder.com/). This VM is currently being used to test a new mechanism for provisioning Dockerized applications.

### lab-nginx-vm (WIP)

Creates a VM to run an nginx proxy for other lab services.

### proxmox-os-images

Downloads OS ISO images (defined by the `_config` module), and installs them in the appropriate Proxmox data store so they can be used to create VMs.
