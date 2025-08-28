import {
  to = module.synapse_data_lake.azurerm_storage_container.insights_logs_builtinsqlreqsended
  id = "https://${module.synapse_data_lake.azurerm_storage_account.synapse.name}.blob.core.windows.net/insights-logs-builtinsqlreqsended"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.logging
  id = "https://${module.synapse_data_lake.azurerm_storage_account.synapse.name}.blob.core.windows.net/logging"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.odw_config_db
  id = "https://${module.synapse_data_lake.azurerm_storage_account.synapse.name}.blob.core.windows.net/odw-config-db"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.odw_curated_migration
  id = "https://${module.synapse_data_lake.azurerm_storage_account.synapse.name}.blob.core.windows.net/odw-curated-migration"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.odw_standardised_delta
  id = "https://${module.synapse_data_lake.azurerm_storage_account.synapse.name}.blob.core.windows.net/odw-standardised-delta"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.s51_advice_backup
  id = "https://${module.synapse_data_lake.azurerm_storage_account.synapse.name}.blob.core.windows.net/s51-advice-backup"
}

import {
  to = module.synapse_data_lake.azurerm_storage_container.saphrspdata_to_odw
  id = "https://${module.synapse_data_lake.azurerm_storage_account.synapse.name}.blob.core.windows.net/saphrspdata-to-odw"
}

# This one is auto-created by Synapse when synapse is linked to the storage account, so you dont need to import it
#import {
#  to = module.synapse_data_lake.azurerm_storage_container.synapse["synapse"]
#  id = "https://${module.synapse_data_lake.azurerm_storage_account.synapse.name}.blob.core.windows.net/synapse"
#}
