#S62A Horizon Migration Storage Account
module "storage_account_s62a" {
  count  = var.s62a_migration.enabled ? 1 : 0
  source = "./modules/storage-account"

  resource_group_name                     = azurerm_resource_group.data.name
  service_name                            = var.s62a_migration.service_name
  environment                             = var.environment
  location                                = module.azure_region.location_cli
  tags                                    = local.tags
  container_name                          = var.s62a_migration.container_name
  public_network_access_enabled           = false
  network_rule_virtual_network_subnet_ids = concat([module.synapse_network.vnet_subnets[local.functionapp_subnet_name], module.synapse_network.vnet_subnets[local.compute_subnet_name]])
}

resource "azurerm_private_endpoint" "s62a_tooling" {
  for_each = var.s62a_migration.enabled ? toset(["blob", "dfs"]) : toset([])

  name                = "pins-pe-s62a-${each.key}-tooling-${var.environment}"
  resource_group_name = azurerm_resource_group.network.name
  location            = module.azure_region.location_cli
  subnet_id           = module.synapse_network.vnet_subnets[local.synapse_subnet_name]

  private_dns_zone_group {
    name                 = "storagePrivateDnsZone${each.key}"
    private_dns_zone_ids = [local.tooling_storage_dns_zone_ids[each.key]]
  }

  private_service_connection {
    name                           = "storagePrivateServiceConnection${each.key}"
    is_manual_connection           = false
    private_connection_resource_id = one(module.storage_account_s62a[*].storage_id)
    subresource_names              = [each.key]
  }

  tags = local.tags
}