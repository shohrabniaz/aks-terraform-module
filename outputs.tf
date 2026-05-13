output "cluster_id" {
  description = "Resource ID of the AKS cluster."
  value       = module.cluster.id
}

output "cluster_name" {
  description = "Name of the AKS cluster."
  value       = module.cluster.name
}

output "kube_config_raw" {
  description = "Raw kubeconfig for the cluster. Sensitive — write to a file or stream to a secrets store."
  value       = module.cluster.kube_config_raw
  sensitive   = true
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet managed identity. Use this for AcrPull / Key Vault role assignments."
  value       = module.cluster.kubelet_identity_object_id
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL — needed when configuring federated workload identity in Azure AD."
  value       = module.cluster.oidc_issuer_url
}

output "log_analytics_workspace_id" {
  description = "Workspace used for Container Insights (either passed in or created by the module)."
  value       = local.log_analytics_workspace_id
}

output "resource_group_name" {
  description = "Name of the resource group the cluster lives in."
  value       = azurerm_resource_group.this.name
}
