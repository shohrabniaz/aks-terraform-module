variable "enabled" {
  description = "If false, the module does nothing — the caller supplied an existing workspace."
  type        = bool
}

variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "retention_in_days" { type = number }
variable "tags" { type = map(string) }
