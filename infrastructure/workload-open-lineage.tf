locals {
  open_lineage_function_app_names = toset(var.open_lineage_enabled ? ["oljsonreceiver", "oljsonparser"] : [])
}


resource "azurerm_resource_group" "open_lineage_resource_group" {
  count    = var.open_lineage_enabled ? 1 : 0
  location = module.azure_region.location_cli
  name     = "pins-rg-openlineage-odw-${var.environment}-uks"
}


resource "azurerm_application_insights" "open_lineage_insights" {
  for_each = local.open_lineage_function_app_names

  name                = "pins-${each.key}-${local.resource_suffix}-app-insights"
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

module "open_lineage_service_plan" {
  count = var.open_lineage_enabled ? 1 : 0

  source = "./modules/service-plan"

  resource_group_name = azurerm_resource_group.open_lineage_resource_group[0].name
  service_name        = "${local.service_name}-ol"
  environment         = var.environment
  location            = module.azure_region.location_cli
  tags                = local.tags
}



resource "azurerm_linux_function_app" "open_lineage_function_app" {
  #checkov:skip=CKV_AZURE_221: "Ensure that Azure Function App public network access is disabled"
  for_each            = local.open_lineage_function_app_names
  name                = "pins-${each.key}-odw-${var.environment}-uks"
  resource_group_name = azurerm_resource_group.open_lineage_resource_group[0].name
  location            = module.azure_region.location_cli

  storage_account_name       = module.storage_account_openlineage[0].storage_name
  storage_account_access_key = module.storage_account_openlineage[0].primary_access_key
  service_plan_id            = module.open_lineage_service_plan[0].id
  https_only                 = true
  tags                       = local.tags
  app_settings = {
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = "DefaultEndpointsProtocol=https;AccountName=${module.storage_account_openlineage[0].storage_name};AccountKey=${module.storage_account_openlineage[0].primary_access_key};EndpointSuffix=core.windows.net"
    "WEBSITE_CONTENTSHARE"                     = "pins-${each.key}-odw-${var.environment}-uks",
    "SCM_DO_BUILD_DURING_DEPLOYMENT"           = "true",
    "WEBSITE_RUN_FROM_PACKAGE"                 = 1,
    "STORAGE_CONNECTION"                       = "DefaultEndpointsProtocol=https;AccountName=${module.storage_account_openlineage[0].storage_name};AccountKey=${module.storage_account_openlineage[0].primary_access_key};EndpointSuffix=core.windows.net",
    "EVENTS_CONTAINER"                         = "openlineage-events",
    "DEADLETTER_CONTAINER"                     = "openlineage-deadletter",
    "TABLE_NAME"                               = "LineageJobs",
    "ALLOWED_EVENT_TYPES"                      = "COMPLETE",
    "ALLOW_SQL_ONLY"                           = "true",
    "MAX_CONTENT_LENGTH"                       = 8388608,
    "WRITE_TABLE"                              = "true",
    "PURVIEW_NAME"                             = "pins-pview",
    "WEBSITE_CONTENTOVERVNET"                  = 1
  }

  site_config {
    always_on                = true
    application_insights_key = azurerm_application_insights.open_lineage_insights[each.key].instrumentation_key
    http2_enabled            = true
    vnet_route_all_enabled   = true
    application_stack {
      python_version = "3.11"
    }
    cors {
      allowed_origins     = ["https://portal.azure.com"]
      support_credentials = false
    }
  }

  identity {
    type         = "SystemAssigned"
    identity_ids = null
  }
}



# Role assignments
resource "azurerm_role_assignment" "open_lineage_storage_contributors" {
  for_each             = toset(var.open_lineage_enabled ? var.odw_contributors : [])
  scope                = module.storage_account_openlineage[0].storage_id
  role_definition_name = "Contributor"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "open_lineage_storage_blob_data_contributors" {
  for_each             = toset(var.open_lineage_enabled ? var.odw_contributors : [])
  scope                = module.storage_account_openlineage[0].storage_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.key
}


resource "azurerm_role_assignment" "open_lineage_function_app_contributors" {
  for_each = {
    # A map of function_app => user object id
    for val in setproduct(local.open_lineage_function_app_names, var.odw_contributors) :
    "${val[0]}-${val[1]}" => val
  }
  scope                = azurerm_linux_function_app.open_lineage_function_app[each.value[0]].id
  role_definition_name = "Contributor"
  principal_id         = each.value[1]
}

resource "azurerm_role_assignment" "open_lineage_function_app_website_contributors" {
  for_each = {
    # A map of function_app => user object id
    for val in setproduct(local.open_lineage_function_app_names, var.odw_contributors) :
    "${val[0]}-${val[1]}" => val
  }
  scope                = azurerm_linux_function_app.open_lineage_function_app[each.value[0]].id
  role_definition_name = "Website contributor"
  principal_id         = each.value[1]
}

resource "azurerm_role_assignment" "open_lineage_function_app_storage_contributors" {
  for_each             = azurerm_linux_function_app.open_lineage_function_app
  scope                = module.storage_account_openlineage[0].storage_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value.identity[0].principal_id
}

# Note: Purview RBAC is managed within the Purview Portal, which is done manually
#resource "azurerm_role_assignment" "open_lineage_parser_function_app_purview_contributor" {
#  count                = var.open_lineage_enabled ? 1 : 0
#  scope                = var.purview_id
#  role_definition_name = "Contributor"
#  principal_id         = azurerm_linux_function_app.open_lineage_function_app["oljsonparser"].identity[0].principal_id
#}



# Private endpoints
/*
resource "azurerm_private_endpoint" "open_lineage_storage" {
  for_each = var.open_lineage_enabled ? {
    "blob" : azurerm_private_dns_zone.blob.id,
    "table" : azurerm_private_dns_zone.table.id,
  } : {}

  name                = "pins-pe-st-open-lineage-${each.key}-${local.resource_suffix}"
  resource_group_name = "pins-rg-network-odw-${var.environment}-uks"
  location            = module.azure_region.location_cli
  subnet_id           = module.synapse_network.vnet_subnets["ComputeSubnet"]

  private_dns_zone_group {
    name = "storageOpenlineagePrivateDnsZone"
    private_dns_zone_ids = [
      each.value
    ]
  }

  private_service_connection {
    name                           = "storageOpenLineagePrivateServiceConnection"
    is_manual_connection           = false
    private_connection_resource_id = module.storage_account_openlineage[0].storage_id
    subresource_names              = [each.key]
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "tooling_open_lineage_storage" {
  for_each = toset(var.open_lineage_enabled ? ["blob", "file", "queue", "table", "web"] : [])

  name                = "pins-pe-st-open-lineage-${each.key}-tooling-${local.resource_suffix}"
  resource_group_name = "pins-rg-network-odw-${var.environment}-uks"
  location            = module.azure_region.location_cli
  subnet_id           = module.synapse_network.vnet_subnets["ComputeSubnet"]

  private_dns_zone_group {
    name = "storageToolingOpenlineagePrivateDnsZone"
    private_dns_zone_ids = [
      local.tooling_storage_dns_zone_ids[each.key]
    ]
  }

  private_service_connection {
    name                           = "storageToolingOpenLineagePrivateServiceConnection"
    is_manual_connection           = false
    private_connection_resource_id = module.storage_account_openlineage[0].storage_id
    subresource_names              = [each.key]
  }

  tags = local.tags
}
*/
