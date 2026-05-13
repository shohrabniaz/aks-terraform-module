output "workspace_id" {
  description = "Log Analytics workspace ID. Returns null when enabled = false."
  value       = var.enabled ? azurerm_log_analytics_workspace.this[0].id : null
}
