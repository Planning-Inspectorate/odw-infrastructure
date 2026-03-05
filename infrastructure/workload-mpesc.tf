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
  tooling_config = {
    storage_private_dns_zone_id = local.tooling_storage_dns_zone_ids
  }
  network_resource_group_name          = azurerm_resource_group.network.name
  vnet_subnet_ids                      = module.synapse_network.vnet_subnets
  synapse_private_endpoint_subnet_name = module.synapse_network.synapse_private_endpoint_subnet_name
  synapse_msi_id                       = module.synapse_workspace_private.synapse_workspace_principal_id
  dlg2fs                               = ["synapse"]
  network_default_action               = "Allow"
}


