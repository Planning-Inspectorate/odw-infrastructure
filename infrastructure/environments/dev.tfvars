bastion_host_enabled = true
bastion_vm_username  = "basadmin"
bastion_vm_size      = "Standard_F2s_v2"
bastion_vm_image = {
  publisher = "microsoft-dsvm"
  offer     = "dsvm-win-2019"
  sku       = "winserver-2019"
  version   = "latest"
}

daily_log_cap = 0.2

data_lake_role_assignments = {
  "Storage Blob Data Contributor" = [
    "ebcc4498-4abe-4457-8970-7fa08bf87543", # pins-odw-dev-administrators
    "48bd5755-6d7d-4a17-b044-7522c54e9c7d", # pins-odw-dev-dataengineers
    "875e931a-ee45-425e-acde-1ec24a8a290d"  # Azure DevOps Pipelines - ODW Dev - Infrastructure"
  ]
}

data_lake_storage_containers_to_import = [
  "insights-logs-builtinsqlreqsended",
  "logging",
  "odw-config-db",
  "odw-curated-migration",
  "odw-standardised-delta",
  "s51-advice-backup",
  "saphrspdata-to-odw"
]

environment = "dev"

horizon_integration_config = {
  networking = {
    resource_group_name  = "PREHZN"
    vnet_name            = "VNPRE-10.0.0.0-16"
    database_subnet_name = "SN-VNPRE-DB-10.0.3.0-24"
  }
}
#Evagelos new horizon migration storage account
horizon_migration = {
  rg             = "pins-rg-data-odw-dev-uks"
  service_name   = "mpesc"
  container_name = ["mpesc"]
}

deploy_s62a_migration_storage = true

logic_app_enabled = false

key_vault_role_assignments = {
  "Key Vault Administrator" = [
    "ebcc4498-4abe-4457-8970-7fa08bf87543" # pins-odw-dev-administrators
  ],
  "Key Vault Secrets Officer" = [
    "48bd5755-6d7d-4a17-b044-7522c54e9c7d" # pins-odw-dev-dataengineers
  ]
}

message_storage_account = "https://pinsstodwdevuks9h80mb.blob.core.windows.net"

message_storage_container = "odw-raw/ServiceBus"

network_watcher_enabled = false

/*
# openlineage POC
openlineage_function_app = {
  enabled               = true
  function_app_receiver = "oljsonreceiver"
  function_app_parser   = "oljsonparser"
  site_config = {
    application_stack = {
      python_version = "3.11"
    }
  }
}

openlineage_storage_account = {
  container_name = [
    "openlineage-events",
    "openlineage-badpayloads"
  ]
  tables = [
    "LineageJobs"
  ]
}
*/

service_bus_premium_enabled = true
service_bus_role_assignments = {
  "Azure Service Bus Data Owner" = {
    groups = ["pins-odw-dev-administrators"]
  }
}

spark_pool_version = "3.4"

sql_server_enabled = true

synapse_aad_administrator = {
  username  = "pins-odw-data-dev-syn-ws-sqladmins"
  object_id = "1c996957-30e4-40fe-b0b4-82d40f13c058"
}

synapse_role_assignments = [
  { # pins-odw-data-dev-syn-ws-administrators
    role_definition_name = "Synapse Administrator",
    principal_id         = "6a38f212-3834-4e2e-93fb-f81bb3a3fe49"
  },
  { # Azure DevOps Pipelines - ODW DEV - Infrastructure
    role_definition_name = "Synapse Administrator",
    principal_id         = "875e931a-ee45-425e-acde-1ec24a8a290d",
    principal_type       = "User"
  },
  { # pins-odw-data-dev-syn-ws-contributors
    role_definition_name = "Synapse Contributor",
    principal_id         = "0a5073e3-b8e9-4786-8e1f-39f2c277aeb2"
  },
  { # pins-odw-data-dev-syn-ws-computeoperators
    role_definition_name = "Synapse Compute Operator",
    principal_id         = "a66ee73a-c31b-451d-b13e-19b4e92c0c25"
  }
]

vnet_base_cidr_block          = "10.70.0.0/24"
vnet_base_cidr_block_failover = "10.70.1.0/24"

external_resource_links_enabled = true

link_purview_account = true
