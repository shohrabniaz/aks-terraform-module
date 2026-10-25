################################################################################
# User node pools
#
# Pool names must be 1-12 chars, lowercase. Pool key in the map is used as the
# pool name (and validated by AKS at apply time).
################################################################################

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  # Documented Checkov risk-acceptance (see modules/cluster/main.tf for rationale):
  # checkov:skip=CKV_AZURE_227:Host-based encryption (EncryptionAtHost) needs the subscription-level feature and is unsupported on some VM sizes; left to the caller rather than forced on every pool.
  # checkov:skip=CKV_AZURE_168:Azure CNI Overlay default max_pods (250) already exceeds the 50-pod minimum; max_pods is intentionally not pinned.
  for_each = var.pools

  name                  = each.key
  kubernetes_cluster_id = var.cluster_id
  vnet_subnet_id        = var.vnet_subnet_id

  vm_size             = each.value.vm_size
  zones               = each.value.availability_zones
  enable_auto_scaling = true
  min_count           = each.value.min_count
  max_count           = each.value.max_count
  os_disk_size_gb     = each.value.os_disk_size_gb
  os_disk_type        = "Ephemeral"
  node_labels         = each.value.node_labels
  node_taints         = each.value.node_taints
  mode                = "User"

  # Spot config — only meaningful for non-critical workloads.
  priority        = each.value.spot_enabled ? "Spot" : "Regular"
  eviction_policy = each.value.spot_enabled ? "Delete" : null
  spot_max_price  = each.value.spot_enabled ? each.value.spot_max_price : null

  upgrade_settings {
    max_surge = "33%"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      node_count, # autoscaling owns this
    ]
  }
}
