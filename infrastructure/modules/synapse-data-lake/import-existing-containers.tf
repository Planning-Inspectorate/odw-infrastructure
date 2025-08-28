resource "azurerm_storage_container" "insights_logs_builtinsqlreqsended" {
  # checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
  name                  = "insights-logs-builtinsqlreqsended"
  storage_account_name  = azurerm_storage_account.synapse.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "logging" {
  # checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
  name                  = "logging"
  storage_account_name  = azurerm_storage_account.synapse.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "odw_config_db" {
  # checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
  name                  = "odw-config-db"
  storage_account_name  = azurerm_storage_account.synapse.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "odw_curated_migration" {
  # checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
  name                  = "odw-curated-migration"
  storage_account_name  = azurerm_storage_account.synapse.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "odw_standardised_delta" {
  # checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
  name                  = "odw-standardised-delta"
  storage_account_name  = azurerm_storage_account.synapse.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "s51_advice_backup" {
  # checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
  name                  = "s51-advice-backup"
  storage_account_name  = azurerm_storage_account.synapse.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "saphrspdata_to_odw" {
  # checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
  name                  = "saphrspdata-to-odw"
  storage_account_name  = azurerm_storage_account.synapse.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "synapse" {
  # checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
  name                  = "synapse"
  storage_account_name  = azurerm_storage_account.synapse.name
  container_access_type = "private"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.insights_logs_builtinsqlreqsended
  id = "https://pinsstodwdevuks9h80mb.blob.core.windows.net/insights-logs-builtinsqlreqsended"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.logging
  id = "https://pinsstodwdevuks9h80mb.blob.core.windows.net/logging"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.odw_config_db
  id = "https://pinsstodwdevuks9h80mb.blob.core.windows.net/odw-config-db"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.odw_curated_migration
  id = "https://pinsstodwdevuks9h80mb.blob.core.windows.net/odw-curated-migration"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.odw_standardised_delta
  id = "https://pinsstodwdevuks9h80mb.blob.core.windows.net/odw-standardised-delta"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.s51_advice_backup
  id = "https://pinsstodwdevuks9h80mb.blob.core.windows.net/s51-advice-backup"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.saphrspdata_to_odw
  id = "https://pinsstodwdevuks9h80mb.blob.core.windows.net/saphrspdata-to-odw"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.synapse
  id = "https://pinsstodwdevuks9h80mb.blob.core.windows.net/synapse"
}
