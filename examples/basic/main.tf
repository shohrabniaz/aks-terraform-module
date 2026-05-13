terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
}

provider "azurerm" {
  features {}
}

# Bring-your-own VNet — the module deliberately does NOT create networking
# because in production this almost always belongs to a separate platform team.
data "azurerm_subnet" "aks" {
  name                 = "aks-nodes"
  virtual_network_name = "platform-vnet"
  resource_group_name  = "platform-network"
}

module "aks" {
  source = "../../"

  name                = "demo-aks"
  location            = "australiaeast"
  resource_group_name = "demo-aks-rg"

  vnet_subnet_id                  = data.azurerm_subnet.aks.id
  azure_ad_admin_group_object_ids = ["00000000-0000-0000-0000-000000000000"]

  user_node_pools = {
    apps = {
      vm_size   = "Standard_D4s_v5"
      min_count = 2
      max_count = 10
      node_labels = {
        "workload" = "apps"
      }
    }
    spot = {
      vm_size      = "Standard_D4s_v5"
      min_count    = 0
      max_count    = 20
      spot_enabled = true
      node_taints  = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
      node_labels = {
        "workload" = "batch"
      }
    }
  }

  tags = {
    environment = "demo"
    owner       = "platform"
  }
}

output "cluster_name" {
  value = module.aks.cluster_name
}
