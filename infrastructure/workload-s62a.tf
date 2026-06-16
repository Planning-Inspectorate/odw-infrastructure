#S62A Horizon Migration Storage Account
module "storage_account_s62a" {
  count  = var.s62a_migration != null ? 1 : 0
  source = "./modules/storage-account"

  resource_group_name                     = var.s62a_migration.rg
  service_name                            = var.s62a_migration.service_name
  environment                             = var.environment
  location                                = module.azure_region.location_cli
  tags                                    = local.tags
  container_name                          = var.s62a_migration.container_name
  network_rule_virtual_network_subnet_ids = concat([module.synapse_network.vnet_subnets[local.functionapp_subnet_name], module.synapse_network.vnet_subnets[local.compute_subnet_name]])
}