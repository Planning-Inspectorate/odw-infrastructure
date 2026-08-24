module "azure_region" {
  #checkov:skip=CKV_TF_1: Ensure Terraform module sources use a commit hash (checkov v3)
  source  = "claranet/regions/azurerm"
  version = "9.0.0"

  azure_region = local.location
}
