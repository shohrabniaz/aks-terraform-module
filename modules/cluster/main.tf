################################################################################
# AKS cluster
#
# Security defaults worth flagging:
#   - role_based_access_control_enabled is implicit (AKS no longer supports non-RBAC).
#   - local_account_disabled = true forces all kubectl access through Azure AD.
#   - private_cluster_enabled defaults true; do NOT expose the API server publicly
#     unless you have explicit authorized_ip_ranges set.
#   - azure_policy_enabled wires up Gatekeeper (OPA) for admission policy.
#   - oidc + workload identity must be on together — federated SAs depend on both.
################################################################################

resource "azurerm_kubernetes_cluster" "this" {
  # Checkov risk-acceptance notes. These are documented, auditable suppressions,
  # not blanket exemptions: any new finding still fails CI. Each control below is
  # either a false positive from static analysis or a deliberate scope decision.
  # checkov:skip=CKV_AZURE_117:OS disks are Ephemeral and encrypted with platform-managed keys. Customer-managed disk encryption sets need a caller-owned Key Vault + DiskEncryptionSet, which is intentionally out of scope for this bring-your-own-infra module.
  # checkov:skip=CKV_AZURE_227:Host-based encryption (EncryptionAtHost) requires the subscription-level feature to be registered and is unsupported on several VM sizes; forcing it unconditionally would break applies, so it is left to the caller.
  # checkov:skip=CKV_AZURE_232:only_critical_addons_enabled is driven by var.system_node_pool.only_critical_addons and defaults to true. Checkov cannot resolve the optional-object default statically, so this is a false positive.
  # checkov:skip=CKV_AZURE_171:The Kubernetes minor version is operator-controlled by design and pinned via var.kubernetes_version; an automatic upgrade channel is intentionally not forced so version bumps stay an explicit operator decision.
  # checkov:skip=CKV_AZURE_168:Azure CNI in Overlay mode is used, whose default max_pods (250) already exceeds the 50-pod minimum; max_pods is deliberately not pinned so the overlay default applies.
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.name

  kubernetes_version = var.kubernetes_version
  sku_tier           = var.sku_tier

  private_cluster_enabled   = var.private_cluster_enabled
  local_account_disabled    = true
  azure_policy_enabled      = var.enable_azure_policy
  oidc_issuer_enabled       = var.enable_workload_identity
  workload_identity_enabled = var.enable_workload_identity

  api_server_access_profile {
    authorized_ip_ranges = var.private_cluster_enabled ? null : var.authorized_ip_ranges
  }

  azure_active_directory_role_based_access_control {
    admin_group_object_ids = var.azure_ad_admin_group_object_ids
    azure_rbac_enabled     = true
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    load_balancer_sku   = "standard"
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
  }

  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_pool.vm_size
    vnet_subnet_id               = var.vnet_subnet_id
    zones                        = var.system_node_pool.availability_zones
    only_critical_addons_enabled = var.system_node_pool.only_critical_addons
    os_disk_size_gb              = var.system_node_pool.os_disk_size_gb
    os_disk_type                 = "Ephemeral"
    enable_auto_scaling          = true
    min_count                    = var.system_node_pool.min_count
    max_count                    = var.system_node_pool.max_count
    type                         = "VirtualMachineScaleSets"
    upgrade_settings {
      max_surge = "33%"
    }
    tags = var.tags
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    msi_auth_for_monitoring_enabled = true
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.enable_key_vault_secrets_provider ? [1] : []
    content {
      secret_rotation_enabled  = true
      secret_rotation_interval = "5m"
    }
  }

  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    duration    = var.maintenance_window.duration
    day_of_week = var.maintenance_window.day
    start_time  = format("%02d:00", var.maintenance_window.start_hour)
    utc_offset  = "+00:00"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # AKS bumps patch versions automatically; ignore so it doesn't fight us.
      kubernetes_version,
      # Default pool node count can drift from autoscaling.
      default_node_pool[0].node_count,
    ]
  }
}
