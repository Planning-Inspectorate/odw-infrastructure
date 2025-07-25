resource "azurerm_synapse_private_link_hub" "synapse_workspace" {
  name                = replace("pins-pl-syn-ws-${local.resource_suffix}", "-", "")
  resource_group_name = var.network_resource_group_name
  location            = var.location

  tags = local.tags
}

resource "azurerm_private_endpoint" "synapse_dedicated_sql_pool" {
  count = var.sql_pool_enabled ? 1 : 0

  name                = "pins-pe-syn-dsql-${local.resource_suffix}"
  resource_group_name = var.network_resource_group_name
  location            = var.location
  subnet_id           = var.synapse_private_endpoint_vnet_subnets[var.synapse_private_endpoint_subnet_name]

  private_dns_zone_group {
    name                 = "synapsePrivateDnsZone"
    private_dns_zone_ids = [var.synapse_private_endpoint_dns_zone_id]
  }

  private_service_connection {
    name                           = "synapseDedicatedSql"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_synapse_workspace.synapse.id
    subresource_names              = ["SQL"]
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "synapse_development" {
  name                = "pins-pe-syn-devops-${local.resource_suffix}"
  resource_group_name = var.network_resource_group_name
  location            = var.location
  subnet_id           = var.synapse_private_endpoint_vnet_subnets[var.synapse_private_endpoint_subnet_name]

  private_dns_zone_group {
    name                 = "synapsePrivateDnsZone"
    private_dns_zone_ids = [var.synapse_private_endpoint_dns_zone_id]
  }

  private_service_connection {
    name                           = "synapseDevelopment"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_synapse_workspace.synapse.id
    subresource_names              = ["DEV"]
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "synapse_serverless_sql_pool" {
  name                = "pins-pe-syn-ssql-${local.resource_suffix}"
  resource_group_name = var.network_resource_group_name
  location            = var.location
  subnet_id           = var.synapse_private_endpoint_vnet_subnets[var.synapse_private_endpoint_subnet_name]

  private_dns_zone_group {
    name                 = "synapsePrivateDnsZone"
    private_dns_zone_ids = [var.synapse_private_endpoint_dns_zone_id]
  }

  private_service_connection {
    name                           = "synapseServerlessSql"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_synapse_workspace.synapse.id
    subresource_names              = ["SqlOnDemand"]
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "synapse_workspace" {
  name                = "pins-pe-syn-ws-${local.resource_suffix}"
  resource_group_name = var.network_resource_group_name
  location            = var.location
  subnet_id           = var.synapse_private_endpoint_vnet_subnets[var.synapse_private_endpoint_subnet_name]

  private_dns_zone_group {
    name                 = "synapsePrivateDnsZone"
    private_dns_zone_ids = [var.synapse_private_endpoint_dns_zone_id]
  }

  private_service_connection {
    name                           = "synapseWorkspace"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_synapse_private_link_hub.synapse_workspace.id
    subresource_names              = ["Web"]
  }

  tags = local.tags
}

resource "azurerm_synapse_managed_private_endpoint" "data_lake" {
  name                 = "synapse-st-dfs--${var.data_lake_account_name}"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  target_resource_id   = var.data_lake_account_id
  subresource_name     = "dfs"

  depends_on = [
    azurerm_synapse_workspace.synapse,
    time_sleep.firewall_delay
  ]
}

resource "azurerm_synapse_managed_private_endpoint" "data_lake_failover" {
  name                 = "synapse-st-dfs--${var.data_lake_account_name_failover}"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  target_resource_id   = var.data_lake_account_id_failover
  subresource_name     = "dfs"

  depends_on = [
    azurerm_synapse_workspace.synapse,
    time_sleep.firewall_delay
  ]
}

resource "azurerm_synapse_managed_private_endpoint" "synapse_mpe_kv" {
  name                 = "synapse-mpe-kv--${local.resource_suffix}"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  target_resource_id   = var.key_vault_id
  subresource_name     = "vault"

  depends_on = [
    azurerm_synapse_workspace.synapse,
    time_sleep.firewall_delay
  ]
}

#
# synapse PE for connecting to the Appeals BO Service Bus instance when running in the Azure integration runtime
#

resource "azurerm_synapse_managed_private_endpoint" "synapse_mpe_appeals_bo_sb" {
  count = var.create_service_bus_resources ? 1 : 0

  name                 = "synapse-mpe-appeals-bo--${local.resource_suffix}"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  target_resource_id   = var.odt_appeals_back_office_service_bus_id
  subresource_name     = "namespace"

  depends_on = [
    azurerm_synapse_workspace.synapse,
    time_sleep.firewall_delay
  ]
}

# private endpoints in tooling

resource "azurerm_private_endpoint" "synapse_development_tooling" {
  name                = "pins-pe-syn-devops-tooling-${local.resource_suffix}"
  resource_group_name = var.network_resource_group_name
  location            = var.location
  subnet_id           = var.synapse_private_endpoint_vnet_subnets[var.synapse_private_endpoint_subnet_name]

  private_dns_zone_group {
    name                 = "synapsePrivateDnsZone"
    private_dns_zone_ids = [var.tooling_config.synapse_dev_private_dns_zone_id]
  }

  private_service_connection {
    name                           = "synapseDevelopment"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_synapse_workspace.synapse.id
    subresource_names              = ["DEV"]
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "synapse_workspace_tooling" {
  name                = "pins-pe-syn-ws-tooling-${local.resource_suffix}"
  resource_group_name = var.network_resource_group_name
  location            = var.location
  subnet_id           = var.synapse_private_endpoint_vnet_subnets[var.synapse_private_endpoint_subnet_name]

  private_dns_zone_group {
    name                 = "synapsePrivateDnsZone"
    private_dns_zone_ids = [var.tooling_config.synapse_private_dns_zone_id]
  }

  private_service_connection {
    name                           = "synapseWorkspace"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_synapse_private_link_hub.synapse_workspace.id
    subresource_names              = ["Web"]
  }

  tags = local.tags
}

# private endpoints for Purview

resource "azurerm_synapse_managed_private_endpoint" "synapse_mpe_purview_account" {
  count = var.create_service_bus_resources && var.purview_id != null ? 1 : 0

  name                 = "synapse-mpe-purview-account--${local.resource_suffix}"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  target_resource_id   = var.purview_id
  subresource_name     = "account"

  depends_on = [
    azurerm_synapse_workspace.synapse,
    time_sleep.firewall_delay
  ]
}

resource "azurerm_synapse_managed_private_endpoint" "synapse_mpe_purview_storage_blob" {
  count = var.create_service_bus_resources && var.purview_storage_id != null ? 1 : 0

  name                 = "synapse-mpe-purview-storage-blob--${local.resource_suffix}"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  target_resource_id   = var.purview_storage_id
  subresource_name     = "blob"

  depends_on = [
    azurerm_synapse_workspace.synapse,
    time_sleep.firewall_delay
  ]
}

resource "azurerm_synapse_managed_private_endpoint" "synapse_mpe_purview_storage_queue" {
  count = var.create_service_bus_resources && var.purview_storage_id != null ? 1 : 0

  name                 = "synapse-mpe-purview-storage-queue--${local.resource_suffix}"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  target_resource_id   = var.purview_storage_id
  subresource_name     = "queue"

  depends_on = [
    azurerm_synapse_workspace.synapse,
    time_sleep.firewall_delay
  ]
}

resource "azurerm_synapse_managed_private_endpoint" "synapse_mpe_purview_event_hubs" {
  count = var.create_service_bus_resources && var.purview_event_hub_id != null ? 1 : 0

  name                 = "synapse-mpe-purview-event-hubs--${local.resource_suffix}"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  target_resource_id   = var.purview_event_hub_id
  subresource_name     = "namespace"

  depends_on = [
    azurerm_synapse_workspace.synapse,
    time_sleep.firewall_delay
  ]
}