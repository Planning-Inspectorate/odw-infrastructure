# S62A Storage Account
module "storage_account_s62a_migration" {

  count = var.deploy_s62a_migration_storage ? 1 : 0

  source = "./modules/storage-account"

  resource_group_name                     = azurerm_resource_group.data.name
  service_name                            = "s62a"
  environment                             = var.environment
  location                                = module.azure_region.location_cli
  tags                                    = local.tags
  container_name                          = ["s62a"]
  network_rule_virtual_network_subnet_ids = concat([module.synapse_network.vnet_subnets[local.functionapp_subnet_name], module.synapse_network.vnet_subnets[local.compute_subnet_name]])
}

resource "azurerm_private_endpoint" "s62a_endpoint" {
  count = var.deploy_s62a_migration_storage ? 1 : 0

  name                = "pins-pe-odw-s62a-${var.environment}"
  resource_group_name = azurerm_resource_group.network.name
  location            = module.azure_region.location_cli
  subnet_id           = module.synapse_network.vnet_subnets[local.compute_subnet_name]

  private_dns_zone_group {
    name                 = "sts62aprivateendpoint"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.tooling_storage["blob"].id]
  }

  private_service_connection {
    name                           = "privateendpointconnection"
    private_connection_resource_id = module.storage_account_s62a_migration[0].storage_id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
  tags = local.tags
}
