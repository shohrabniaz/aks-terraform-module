variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "kubernetes_version" { type = string }
variable "sku_tier" { type = string }
variable "private_cluster_enabled" { type = bool }
variable "authorized_ip_ranges" { type = list(string) }
variable "azure_ad_admin_group_object_ids" { type = list(string) }
variable "vnet_subnet_id" { type = string }
variable "service_cidr" { type = string }
variable "dns_service_ip" { type = string }

variable "system_node_pool" {
  type = object({
    vm_size              = optional(string, "Standard_D4s_v5")
    min_count            = optional(number, 2)
    max_count            = optional(number, 4)
    availability_zones   = optional(list(string), ["1", "2", "3"])
    only_critical_addons = optional(bool, true)
    os_disk_size_gb      = optional(number, 64)
  })
}

variable "log_analytics_workspace_id" { type = string }
variable "enable_key_vault_secrets_provider" { type = bool }
variable "enable_azure_policy" { type = bool }
variable "enable_workload_identity" { type = bool }

variable "maintenance_window" {
  type = object({
    day        = optional(string, "Sunday")
    start_hour = optional(number, 18)
    duration   = optional(number, 4)
  })
}

variable "tags" { type = map(string) }
