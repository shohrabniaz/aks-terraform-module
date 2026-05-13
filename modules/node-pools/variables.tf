variable "cluster_id" {
  description = "Resource ID of the AKS cluster the pools attach to."
  type        = string
}

variable "vnet_subnet_id" {
  description = "Subnet for the workload pools. Can be same as system pool or a separate subnet."
  type        = string
}

variable "pools" {
  description = "Map of workload pools keyed by pool name."
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
}

variable "tags" {
  type = map(string)
}
