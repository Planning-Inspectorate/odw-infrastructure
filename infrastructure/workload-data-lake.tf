resource "azurerm_resource_group" "data" {
  name     = "pins-rg-data-${local.resource_suffix}"
  location = module.azure_region.location_cli

  tags = local.tags
}

resource "azurerm_resource_group" "data_failover" {
  name     = "pins-rg-data-${local.resource_suffix_failover}"
  location = module.azure_region.paired_location.location_cli

  tags = local.tags
}

module "synapse_data_lake" {
  source = "./modules/synapse-data-lake"

  environment         = var.environment
  resource_group_name = azurerm_resource_group.data.name
  location            = module.azure_region.location_cli
  service_name        = local.service_name

  data_lake_account_tier                 = var.data_lake_account_tier
  data_lake_private_endpoint_dns_zone_id = azurerm_private_dns_zone.data_lake.id
  data_lake_lifecycle_rules              = jsondecode(file(local.lifecycle_policy_file_path))
  data_lake_replication_type             = var.data_lake_replication_type
  data_lake_retention_days               = var.data_lake_retention_days
  data_lake_role_assignments             = var.data_lake_role_assignments
  data_lake_storage_containers           = var.data_lake_storage_containers
  devops_agent_subnet_name               = module.synapse_network.devops_agent_subnet_name
  firewall_allowed_ip_addresses          = local.firewall_allowed_ip_addresses
  function_app_principal_ids             = local.function_app_identity
  horizon_integration_config             = var.horizon_integration_config
  key_vault_role_assignments             = var.key_vault_role_assignments
  key_vault_private_endpoint_dns_zone_id = azurerm_private_dns_zone.key_vault.id
  network_resource_group_name            = azurerm_resource_group.network.name
  synapse_private_endpoint_subnet_name   = module.synapse_network.synapse_private_endpoint_subnet_name
  tenant_id                              = var.tenant_id
  external_resource_links_enabled        = var.external_resource_links_enabled
  tooling_config = {
    key_vault_private_dns_zone_id = data.azurerm_private_dns_zone.tooling_key_vault.id
    storage_private_dns_zone_id   = local.tooling_storage_dns_zone_ids
  }
  vnet_subnet_ids          = module.synapse_network.vnet_subnets
  vnet_subnet_ids_failover = module.synapse_network_failover.vnet_subnets

  tags = local.tags

  providers = {
    azurerm         = azurerm,
    azurerm.horizon = azurerm.horizon
  }
}

module "synapse_data_lake_failover" {
  source = "./modules/synapse-data-lake"

  environment         = var.environment
  resource_group_name = azurerm_resource_group.data_failover.name
  location            = module.azure_region.paired_location.location_cli
  service_name        = local.service_name

  data_lake_account_tier                 = var.data_lake_account_tier
  data_lake_private_endpoint_dns_zone_id = azurerm_private_dns_zone.data_lake.id
  data_lake_lifecycle_rules              = jsondecode(file(local.lifecycle_policy_file_path))
  data_lake_replication_type             = var.data_lake_replication_type
  data_lake_retention_days               = var.data_lake_retention_days
  data_lake_role_assignments             = var.data_lake_role_assignments
  data_lake_storage_containers           = var.data_lake_storage_containers
  devops_agent_subnet_name               = module.synapse_network_failover.devops_agent_subnet_name
  firewall_allowed_ip_addresses          = local.firewall_allowed_ip_addresses
  function_app_principal_ids             = local.function_app_identity
  horizon_integration_config             = var.horizon_integration_config
  key_vault_private_endpoint_dns_zone_id = azurerm_private_dns_zone.key_vault.id
  key_vault_role_assignments             = var.key_vault_role_assignments
  network_resource_group_name            = azurerm_resource_group.network_failover.name
  synapse_private_endpoint_subnet_name   = module.synapse_network_failover.synapse_private_endpoint_subnet_name
  tenant_id                              = var.tenant_id
  external_resource_links_enabled        = var.external_resource_links_enabled
  tooling_config = {
    key_vault_private_dns_zone_id = data.azurerm_private_dns_zone.tooling_key_vault.id
    storage_private_dns_zone_id   = local.tooling_storage_dns_zone_ids
  }
  vnet_subnet_ids          = module.synapse_network_failover.vnet_subnets
  vnet_subnet_ids_failover = module.synapse_network.vnet_subnets

  tags = local.tags

  providers = {
    azurerm         = azurerm,
    azurerm.horizon = azurerm.horizon
  }
}

#resource "azurerm_storage_container" "synapse" {
#  # checkov:skip=CKV2_AZURE_21 reason="Blob logging is managed at the storage account level, not container level"
#  for_each = toset([
#    "insights-logs-builtinsqlreqsended",
#    "logging",
#    "odw-config-db",
#    "odw-curated-migration",
#    "odw-standardised-delta",
#    "s51-advice-backup",
#    "saphrsdata-to-odw",
#    "synapse"
#  ])
#
#  name                  = each.key
#  storage_account_name  = "pinsstoddwdevuks9h80mb"
#  container_access_type = "private"
#}

# checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
resource "azurerm_storage_container" "synapse_insights" {
  name                  = "insights-logs-builtinsqlreqsended"
  storage_account_name  = "pinsstoddwdevuks9h80mb"
  container_access_type = "private"
}

# checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
resource "azurerm_storage_container" "synapse_logging" {
  name                  = "logging"
  storage_account_name  = "pinsstoddwdevuks9h80mb"
  container_access_type = "private"
}

# checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
resource "azurerm_storage_container" "synapse_odw_config" {
  name                  = "odw-config-db"
  storage_account_name  = "pinsstoddwdevuks9h80mb"
  container_access_type = "private"
}

# checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
resource "azurerm_storage_container" "synapse_odw_curated" {
  name                  = "odw-curated-migration"
  storage_account_name  = "pinsstoddwdevuks9h80mb"
  container_access_type = "private"
}

# checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
resource "azurerm_storage_container" "synapse_odw_standardised" {
  name                  = "odw-standardised-delta"
  storage_account_name  = "pinsstoddwdevuks9h80mb"
  container_access_type = "private"
}

# checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
resource "azurerm_storage_container" "synapse_backup" {
  name                  = "s51-advice-backup"
  storage_account_name  = "pinsstoddwdevuks9h80mb"
  container_access_type = "private"
}

# checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
resource "azurerm_storage_container" "synapse_saph" {
  name                  = "saphrsdata-to-odw"
  storage_account_name  = "pinsstoddwdevuks9h80mb"
  container_access_type = "private"
}

# checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
resource "azurerm_storage_container" "synapse_synapse" {
  name                  = "synapse"
  storage_account_name  = "pinsstoddwdevuks9h80mb"
  container_access_type = "private"
}


resource "azurerm_role_assignment" "ado_blob_reader" {
  scope                = "/subscriptions/ff442a29-fc06-4a13-8e3e-65fd5da513b3/resourceGroups/pins-rg-data-odw-dev-uks/providers/Microsoft.Storage/storageAccounts/pinsstoddwdevuks9h80mb"
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = "9d7c0f07-9839-4928-8927-bfc19f9f6bd2"
}

import {
  to = azurerm_storage_container.synapse_insights
  id = "https://pinsstoddwdevuks9h80mb.blob.core.windows.net/insights-logs-builtinsqlreqsended"
}

import {
  to = azurerm_storage_container.synapse_logging
  id = "https://pinsstoddwdevuks9h80mb.blob.core.windows.net/logging"
}

import {
  to = azurerm_storage_container.synapse_odw_config
  id = "https://pinsstoddwdevuks9h80mb.blob.core.windows.net/odw-config-db"
}

import {
  to = azurerm_storage_container.synapse_odw_curated
  id = "https://pinsstoddwdevuks9h80mb.blob.core.windows.net/odw-curated-migration"
}

import {
  to = azurerm_storage_container.synapse_odw_standardised
  id = "https://pinsstoddwdevuks9h80mb.blob.core.windows.net/odw-standardised-delta"
}

import {
  to = azurerm_storage_container.synapse_backup
  id = "https://pinsstoddwdevuks9h80mb.blob.core.windows.net/s51-advice-backup"
}

import {
  to = azurerm_storage_container.synapse_saph
  id = "https://pinsstoddwdevuks9h80mb.blob.core.windows.net/saphrsdata-to-odw"
}

import {
  to = azurerm_storage_container.synapse_synapse
  id = "https://pinsstoddwdevuks9h80mb.blob.core.windows.net/synapse"
}