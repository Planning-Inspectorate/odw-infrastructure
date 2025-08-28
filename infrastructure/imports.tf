resource "azurerm_role_assignment" "ado_blob_reader" {
  scope                = "/subscriptions/ff442a29-fc06-4a13-8e3e-65fd5da513b3/resourceGroups/pins-rg-data-odw-dev-uks/providers/Microsoft.Storage/storageAccounts/pinsstodwdevuks9h80mb"
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = "2a302373-df67-4c1e-91a1-f6301b87f42b"
}

resource "azurerm_role_assignment" "ado_storage_reader_management_plane" {
  scope                = "/subscriptions/ff442a29-fc06-4a13-8e3e-65fd5da513b3/resourceGroups/pins-rg-data-odw-dev-uks/providers/Microsoft.Storage/storageAccounts/pinsstodwdevuks9h80mb"
  role_definition_name = "Reader"
  principal_id         = "2a302373-df67-4c1e-91a1-f6301b87f42b"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.insights_logs_builtinsqlreqsended
  id = "/subscriptions/ff442a29-fc06-4a13-8e3e-65fd5da513b3/resourceGroups/pins-rg-data-odw-dev-uks/providers/Microsoft.Storage/storageAccounts/pinsstodwdevuks9h80mb/blobServices/default/containers/insights-logs-builtinsqlreqsended"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.logging
  id = "/subscriptions/ff442a29-fc06-4a13-8e3e-65fd5da513b3/resourceGroups/pins-rg-data-odw-dev-uks/providers/Microsoft.Storage/storageAccounts/pinsstodwdevuks9h80mb/blobServices/default/containers/logging"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.odw_config_db
  id = "/subscriptions/ff442a29-fc06-4a13-8e3e-65fd5da513b3/resourceGroups/pins-rg-data-odw-dev-uks/providers/Microsoft.Storage/storageAccounts/pinsstodwdevuks9h80mb/blobServices/default/containers/odw-config-db"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.odw_curated_migration
  id = "/subscriptions/ff442a29-fc06-4a13-8e3e-65fd5da513b3/resourceGroups/pins-rg-data-odw-dev-uks/providers/Microsoft.Storage/storageAccounts/pinsstodwdevuks9h80mb/blobServices/default/containers/odw-curated-migration"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.odw_standardised_delta
  id = "/subscriptions/ff442a29-fc06-4a13-8e3e-65fd5da513b3/resourceGroups/pins-rg-data-odw-dev-uks/providers/Microsoft.Storage/storageAccounts/pinsstodwdevuks9h80mb/blobServices/default/containers/odw-standardised-delta"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.s51_advice_backup
  id = "/subscriptions/ff442a29-fc06-4a13-8e3e-65fd5da513b3/resourceGroups/pins-rg-data-odw-dev-uks/providers/Microsoft.Storage/storageAccounts/pinsstodwdevuks9h80mb/blobServices/default/containers/s51-advice-backup"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.saphrspdata_to_odw
  id = "/subscriptions/ff442a29-fc06-4a13-8e3e-65fd5da513b3/resourceGroups/pins-rg-data-odw-dev-uks/providers/Microsoft.Storage/storageAccounts/pinsstodwdevuks9h80mb/blobServices/default/containers/saphrspdata-to-odw"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.synapse["synapse"]
  id = "/subscriptions/ff442a29-fc06-4a13-8e3e-65fd5da513b3/resourceGroups/pins-rg-data-odw-dev-uks/providers/Microsoft.Storage/storageAccounts/pinsstodwdevuks9h80mb/blobServices/default/containers/synapse"
}
