################################################################################
# General
################################################################################

variable "name" {
  description = "Base name for the cluster and related resources. Must be 1-30 chars."
  type        = string

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 30
    error_message = "name must be between 1 and 30 characters."
  }
}

variable "location" {
  description = "Azure region for all resources (e.g. australiaeast)."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will contain the cluster. Created if it does not exist."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource the module creates."
  type        = map(string)
  default     = {}
}

################################################################################
# Cluster
################################################################################

variable "kubernetes_version" {
  description = "Kubernetes minor version (e.g. \"1.29\"). Patch version is managed by AKS automatic upgrades."
  type        = string
  default     = "1.29"
}

variable "sku_tier" {
  description = "AKS control plane tier. Use \"Standard\" or \"Premium\" for production (SLA-backed)."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "sku_tier must be one of: Free, Standard, Premium."
  }
}

variable "private_cluster_enabled" {
  description = "If true, the API server is reachable only from the VNet (no public endpoint)."
  type        = bool
  default     = true
}

variable "authorized_ip_ranges" {
  description = "CIDR ranges allowed to reach the public API server. Ignored when private_cluster_enabled = true."
  type        = list(string)
  default     = []
}

variable "azure_ad_admin_group_object_ids" {
  description = "Azure AD group object IDs that get cluster-admin via AKS-managed AAD integration."
  type        = list(string)
}

################################################################################
# Networking
################################################################################

variable "vnet_subnet_id" {
  description = "Resource ID of the subnet the system node pool will live in. Must allow at least /24."
  type        = string
}

variable "service_cidr" {
  description = "CIDR for in-cluster Kubernetes services. Must not overlap with any VNet."
  type        = string
  default     = "10.96.0.0/16"
}

variable "dns_service_ip" {
  description = "IP of the in-cluster CoreDNS service. Must sit inside service_cidr."
  type        = string
  default     = "10.96.0.10"
}

################################################################################
# Node pools
################################################################################

variable "system_node_pool" {
  description = "Configuration for the system (CriticalAddonsOnly) node pool."
  type = object({
    vm_size              = optional(string, "Standard_D4s_v5")
    min_count            = optional(number, 2)
    max_count            = optional(number, 4)
    availability_zones   = optional(list(string), ["1", "2", "3"])
    only_critical_addons = optional(bool, true)
    os_disk_size_gb      = optional(number, 64)
  })
  default = {}
}

variable "user_node_pools" {
  description = "Map of workload node pools to attach to the cluster, keyed by pool name."
  type = map(object({
    vm_size            = string
    min_count          = number
    max_count          = number
    availability_zones = optional(list(string), ["1", "2", "3"])
    node_labels        = optional(map(string), {})
    node_taints        = optional(list(string), [])
    os_disk_size_gb    = optional(number, 128)
    spot_enabled       = optional(bool, false)
    spot_max_price     = optional(number, -1)
  }))
  default = {}
}

################################################################################
# Add-ons & integrations
################################################################################

variable "log_analytics_workspace_id" {
  description = "Existing Log Analytics workspace ID for Container Insights. If null, the module creates one."
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Retention for the Log Analytics workspace created by the module."
  type        = number
  default     = 30
}

variable "enable_key_vault_secrets_provider" {
  description = "Enable the Azure Key Vault Secrets Provider (CSI driver)."
  type        = bool
  default     = true
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy add-on for AKS (Gatekeeper / OPA)."
  type        = bool
  default     = true
}

variable "enable_workload_identity" {
  description = "Enable OIDC issuer + Workload Identity. Required for federated pod identity."
  type        = bool
  default     = true
}

variable "maintenance_window" {
  description = "Default maintenance window for control plane upgrades (UTC)."
  type = object({
    day        = optional(string, "Sunday")
    start_hour = optional(number, 18)
    duration   = optional(number, 4)
  })
  default = {}
}
