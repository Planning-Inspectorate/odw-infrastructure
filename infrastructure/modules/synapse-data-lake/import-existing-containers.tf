resource "azurerm_storage_container" "insights_logs_builtinsqlreqsended" {
  # checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
  name                  = "insights-logs-builtinsqlreqsended"
  storage_account_name  = azurerm_storage_account.synapse.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "logging" {
  # checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
  name                  = "logging"
  storage_account_name  = azurerm_storage_account.synapse.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "odw_config_db" {
  # checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
  name                  = "odw-config-db"
  storage_account_name  = azurerm_storage_account.synapse.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "odw_curated_migration" {
  # checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
  name                  = "odw-curated-migration"
  storage_account_name  = azurerm_storage_account.synapse.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "odw_standardised_delta" {
  # checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
  name                  = "odw-standardised-delta"
  storage_account_name  = azurerm_storage_account.synapse.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "s51_advice_backup" {
  # checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
  name                  = "s51-advice-backup"
  storage_account_name  = azurerm_storage_account.synapse.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "saphrspdata_to_odw" {
  # checkov:skip=CKV2_AZURE_21 reason="Blob service logging is set at the storage account level, not container level"
  name                  = "saphrspdata-to-odw"
  storage_account_name  = azurerm_storage_account.synapse.id
  container_access_type = "private"
}
