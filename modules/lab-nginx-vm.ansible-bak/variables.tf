variable "ansible_vault_secret" {
  default     = null
  description = "Secret used to access Vault-encrypted values in the Ansible configuration."
  sensitive   = true
  type        = string
}