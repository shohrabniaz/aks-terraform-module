################################################################################
# Resource group
#
# Created with a lifecycle.prevent_destroy so an accidental `terraform destroy`
# won't take out anything the operator may have manually placed in it.
################################################################################

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

################################################################################
# Log Analytics (created when caller did not pass one in)
################################################################################

module "monitoring" {
  source = "./modules/monitoring"

  enabled                    = var.log_analytics_workspace_id == null
  name                       = "${var.name}-laws"
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  retention_in_days          = var.log_retention_days
  tags                       = var.tags
}

locals {
  log_analytics_workspace_id = coalesce(var.log_analytics_workspace_id, module.monitoring.workspace_id)
}

################################################################################
# AKS cluster (system node pool only)
################################################################################

module "cluster" {
  source = "./modules/cluster"

  name                              = var.name
  location                          = azurerm_resource_group.this.location
  resource_group_name               = azurerm_resource_group.this.name
  kubernetes_version                = var.kubernetes_version
  sku_tier                          = var.sku_tier
  private_cluster_enabled           = var.private_cluster_enabled
  authorized_ip_ranges              = var.authorized_ip_ranges
  azure_ad_admin_group_object_ids   = var.azure_ad_admin_group_object_ids
  vnet_subnet_id                    = var.vnet_subnet_id
  service_cidr                      = var.service_cidr
  dns_service_ip                    = var.dns_service_ip
  system_node_pool                  = var.system_node_pool
  log_analytics_workspace_id        = local.log_analytics_workspace_id
  enable_key_vault_secrets_provider = var.enable_key_vault_secrets_provider
  enable_azure_policy               = var.enable_azure_policy
  enable_workload_identity          = var.enable_workload_identity
  maintenance_window                = var.maintenance_window
  tags                              = var.tags
}

################################################################################
# User (workload) node pools
################################################################################

module "node_pools" {
  source = "./modules/node-pools"

  cluster_id     = module.cluster.id
  vnet_subnet_id = var.vnet_subnet_id
  pools          = var.user_node_pools
  tags           = var.tags
}
