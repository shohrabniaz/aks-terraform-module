output "pool_ids" {
  description = "Map of pool name -> Azure resource ID."
  value       = { for k, p in azurerm_kubernetes_cluster_node_pool.this : k => p.id }
}
