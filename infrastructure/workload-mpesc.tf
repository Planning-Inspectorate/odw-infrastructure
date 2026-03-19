#Evangelos - Added for Horizon Migration Function App Storage Account
module "storage_account_horizon_migration" {

  count = var.horizon_migration != null ? 1 : 0

  source = "./modules/storage-account"

  resource_group_name                     = var.horizon_migration.rg
  service_name                            = var.horizon_migration.service_name
  environment                             = var.environment
  location                                = module.azure_region.location_cli
  tags                                    = local.tags
  container_name                          = var.horizon_migration.container_name
  network_rule_virtual_network_subnet_ids = concat([module.synapse_network.vnet_subnets[local.functionapp_subnet_name], module.synapse_network.vnet_subnets[local.compute_subnet_name]])
}


