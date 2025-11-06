data "azuread_group" "odw_data_engineers" {
  display_name = "pins-odw-preprod-dataengineers"
}


resource "azurerm_resource_group" "open_lineage_resource_group" {
  count    = var.open_lineage_enabled ? 1 : 0
  location = module.azure_region.location_cli
  name     = "pins-rg-openlineage-odw-${var.environment}-uks"
}


resource "azurerm_application_insights" "open_lineage_insights" {
  count = var.open_lineage_enabled ? 1 : 0

  name                = "pins-oljsonreceiver-${local.resource_suffix}-app-insights"
  location            = module.azure_region.location_cli
  resource_group_name = azurerm_resource_group.monitoring.name
  application_type    = "web"
  retention_in_days   = 30
  workspace_id        = module.synapse_monitoring.log_analytics_workspace_id

  tags = local.tags
}


module "storage_account_openlineage" {
  count = var.open_lineage_enabled ? 1 : 0

  source = "./modules/storage-account"

  resource_group_name                     = azurerm_resource_group.open_lineage_resource_group[0].name
  service_name                            = local.service_name
  environment                             = var.environment
  location                                = module.azure_region.location_cli
  tags                                    = local.tags
  network_rules_enabled                   = true
  network_rule_virtual_network_subnet_ids = concat([module.synapse_network.vnet_subnets[local.functionapp_subnet_name], module.synapse_network.vnet_subnets[local.compute_subnet_name]])
  container_name = [
    "openlineage-events",
    "openlineage-deadletter"
  ]
  tables = [
    "LineageJobs"
  ]
  shares = []
}

module "open_lineage_receiver_service_plan" {
  count = var.open_lineage_enabled ? 1 : 0

  source = "./modules/service-plan"

  resource_group_name = azurerm_resource_group.open_lineage_resource_group[0].name
  service_name        = local.service_name
  environment         = var.environment
  location            = module.azure_region.location_cli
  tags                = local.tags
}



module "open_lineage_receiver_function_app" {
  count  = var.open_lineage_enabled ? 1 : 0
  source = "./modules/function-app"

  resource_group_name        = azurerm_resource_group.open_lineage_resource_group[0].name
  function_app_name          = "oljsonreceiver"
  service_name               = local.service_name
  service_plan_id            = module.open_lineage_receiver_service_plan[0].id
  storage_account_name       = module.storage_account_openlineage[0].storage_name
  storage_account_access_key = module.storage_account_openlineage[0].primary_access_key
  environment                = var.environment
  location                   = module.azure_region.location_cli
  tags                       = local.tags
  application_insights_key   = azurerm_application_insights.open_lineage_insights["oljsonreceiver"].instrumentation_key
  synapse_vnet_subnet_names  = module.synapse_network.vnet_subnets
  app_settings               = null
  connection_strings         = []
  site_config = {
    application_stack = {
      python_version = "3.11"
    }
  }
  file_share_name              = "pins-oljsonreceiver-${local.resource_suffix}"
  servicebus_namespace         = null
  servicebus_namespace_appeals = null
  message_storage_account      = var.message_storage_account
  message_storage_container    = var.message_storage_container
}



# Role assignments
resource "azurerm_role_assignment" "open_lineage_storage_contributors" {
  count                = var.open_lineage_enabled ? 1 : 0
  scope                = module.storage_account_openlineage[0].storage_id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_group.odw_data_engineers.object_id
}

resource "azurerm_role_assignment" "open_lineage_storage_blob_data_contributors" {
  count                = var.open_lineage_enabled ? 1 : 0
  scope                = module.storage_account_openlineage[0].storage_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_group.odw_data_engineers.object_id
}


resource "azurerm_role_assignment" "open_lineage_receiver_contributors" {
  count                = var.open_lineage_enabled ? 1 : 0
  scope                = module.open_lineage_receiver_function_app[0].id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_group.odw_data_engineers.object_id
}


# Private endpoints
resource "azurerm_private_endpoint" "tooling_open_lineage_storage" {
  count = var.open_lineage_enabled ? 1 : 0

  name                = "pins-pe-st-open-lineage-tooling-${local.resource_suffix}"
  resource_group_name = "pins-rg-network-odw-${var.environment}-uks"
  location            = var.location
  subnet_id           = var.vnet_subnet_ids["FunctionAppSubnet"]

  private_dns_zone_group {
    name                 = "storageOpenlineagePrivateDnsZone${each.key}"
    private_dns_zone_ids = [var.tooling_config.storage_private_dns_zone_id[each.key]]
  }

  private_service_connection {
    name                           = "storagePrivateServiceConnection${each.key}"
    is_manual_connection           = false
    private_connection_resource_id = module.storage_account_openlineage[0].storage_account_idid
    subresource_names              = ["blob", "file", "queue", "table", "web"]
  }

  tags = local.tags
}
