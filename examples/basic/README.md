# Example: basic

Minimal end-to-end example showing how to consume the module.

Assumptions baked into this example:

- The VNet and the `aks-nodes` subnet already exist (typical platform-team pattern). The subnet must have a `/24` or larger free range for the system pool.
- You know the object ID of an Azure AD group that should get cluster-admin. The group must already exist.
- You're applying from a workstation/CI runner with **Contributor** on the target subscription and **User Access Administrator** on the resource group (needed for the role assignments AKS does internally).

## Usage

```bash
az login
az account set --subscription <subscription-id>

terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

## Cleaning up

Note: `azurerm_resource_group.this` has `prevent_destroy = true` in the module. To tear down a demo environment you'll either need to remove that lifecycle block first, or `terraform state rm` the resource group and delete it manually with `az group delete`.
