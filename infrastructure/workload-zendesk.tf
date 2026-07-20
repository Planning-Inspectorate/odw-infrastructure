# These resources are all related to Zendesk and MAY be needed in the future. This has been moved to
# its own module and disabled for now

resource "azurerm_resource_group" "zendesk" {
  count = var.zendesk_enabled ? 1 : 0

  name     = "pins-rg-logic-app-${local.resource_suffix}"
  location = module.azure_region.location_cli

  tags = local.tags
}

resource "azurerm_resource_group" "zendesk_failover" {
  count = var.failover_deployment ? 1 : 0

  name     = "pins-rg-logic-app-${local.resource_suffix_failover}"
  location = module.azure_region.paired_location.location_cli

  tags = local.tags
}

module "zendesk" {
  count = var.zendesk_enabled ? 1 : 0

  source = "./modules/zendesk"

  environment                           = var.environment
  resource_group_name                   = azurerm_resource_group.zendesk[0].name
  resource_group_id                     = azurerm_resource_group.zendesk[0].id
  location                              = module.azure_region.location_cli
  logic_app_enabled                     = var.zendesk_enabled
  key_vault_id                          = module.synapse_data_lake.key_vault_id
  service_name                          = local.service_name
  service_bus_primary_connection_string = module.synapse_ingestion.service_bus_primary_connection_string

  tags = local.tags
}

module "zendesk_failover" {
  count = var.zendesk_enabled && var.failover_deployment ? 1 : 0

  source = "./modules/zendesk"

  environment                           = var.environment
  resource_group_name                   = azurerm_resource_group.zendesk_failover[0].name
  resource_group_id                     = azurerm_resource_group.zendesk_failover[0].id
  location                              = module.azure_region.paired_location.location_cli
  logic_app_enabled                     = var.zendesk_enabled
  key_vault_id                          = module.synapse_data_lake.key_vault_id
  service_name                          = local.service_name
  service_bus_primary_connection_string = module.synapse_ingestion_failover[0].service_bus_primary_connection_string

  tags = local.tags
}
