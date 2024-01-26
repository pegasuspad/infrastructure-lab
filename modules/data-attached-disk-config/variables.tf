variable "name" {
  description = "Name of the data disk VM whose config should be loaded."
  nullable    = false
  type        = string
}

variable "repository" {
  description = "Name of the repository to which the configuration data was saved."
  nullable    = false
  type        = string
}
