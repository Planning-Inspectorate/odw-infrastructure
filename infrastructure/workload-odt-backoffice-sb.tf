resource "azurerm_resource_group" "odt_backoffice_sb" {
  count = var.odt_back_office_service_bus_enabled ? 1 : 0

  name     = "pins-rg-odt-bo-sb-${local.resource_suffix}"
  location = module.azure_region.location_cli

  tags = local.tags
}

resource "azurerm_resource_group" "odt_backoffice_sb_failover" {
  count = var.odt_back_office_service_bus_enabled && var.failover_deployment ? 1 : 0

  name     = "pins-rg-odt-bo-sb-${local.resource_suffix_failover}"
  location = module.azure_region.paired_location.location_cli

  tags = local.tags
}

module "odt_backoffice_sb" {
  count = var.odt_back_office_service_bus_enabled && var.external_resource_links_enabled ? 1 : 0

  source = "./modules/odt-backoffice-sb"

  environment                             = var.environment
  location                                = module.azure_region.location_cli
  service_name                            = local.service_name
  odt_backoffice_sb_topic_subscriptions   = local.odt_nsips_back_office_sb_topic_subscriptions
  odt_back_office_service_bus_id          = local.odt_nsips_back_office_service_bus_id
  synapse_workspace_failover_principal_id = try(module.synapse_workspace_private_failover.synapse_workspace_principal_id, null)
  synapse_workspace_principal_id          = module.synapse_workspace_private.synapse_workspace_principal_id

  tags = local.tags

  providers = {
    azurerm     = azurerm,
    azurerm.odt = azurerm.odt
  }
}

module "odt_backoffice_sb_failover" {
  count = var.odt_back_office_service_bus_enabled && var.failover_deployment && var.external_resource_links_enabled ? 1 : 0

  source = "./modules/odt-backoffice-sb"

  environment                             = var.environment
  location                                = module.azure_region.location_cli
  service_name                            = local.service_name
  odt_backoffice_sb_topic_subscriptions   = local.odt_nsips_back_office_sb_topic_subscriptions
  odt_back_office_service_bus_id          = local.odt_nsips_back_office_service_bus_id
  synapse_workspace_failover_principal_id = try(module.synapse_workspace_private_failover.synapse_workspace_principal_id, null)
  synapse_workspace_principal_id          = module.synapse_workspace_private.synapse_workspace_principal_id

  tags = local.tags

  providers = {
    azurerm     = azurerm,
    azurerm.odt = azurerm.odt
  }
}


module "odt_appeals_back_office_sb" {
  count = local.odt_appeals_back_office.service_bus_enabled && var.external_resource_links_enabled ? 1 : 0

  source = "./modules/odt-backoffice-sb"

  back_office_name                        = "appeals-backoffice"
  environment                             = var.environment
  location                                = module.azure_region.location_cli
  service_name                            = local.service_name
  odt_backoffice_sb_topic_subscriptions   = local.odt_appeals_back_office_sb_topic_subscriptions
  odt_back_office_service_bus_id          = local.odt_appeals_back_office_service_bus_id
  synapse_workspace_failover_principal_id = try(module.synapse_workspace_private_failover.synapse_workspace_principal_id, null)
  synapse_workspace_principal_id          = module.synapse_workspace_private.synapse_workspace_principal_id
  topics_to_send                          = ["listed-building"]

  tags = local.tags

  providers = {
    azurerm     = azurerm,
    azurerm.odt = azurerm.odt
  }
}

resource "azurerm_role_assignment" "appeals_vnet_odw_ado_network_contributor" {
  count                = var.environment != "build" ? 1 : 0
  scope                = data.azurerm_virtual_network.appeals[0].id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
  provider             = azurerm.odt
}

resource "azurerm_role_assignment" "backoffice_vnet_odw_ado_network_contributor" {
  count                = var.environment != "build" ? 1 : 0
  scope                = data.azurerm_virtual_network.backoffice[0].id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
  provider             = azurerm.odt
}
