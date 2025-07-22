module "azure_region" {
  #checkov:skip=CKV_TF_1: Ensure Terraform module sources use a commit hash (checkov v3)
  source  = "claranet/regions/azurerm"
  version = "8.0.2"

  azure_region = local.location
}

module "odw_datalake_region" {
  #checkov:skip=CKV_TF_1: Ensure Terraform module sources use a commit hash (checkov v3)
  source  = "claranet/regions/azurerm"
  version = "8.0.2"

  azure_region = local.datalake_location
}
