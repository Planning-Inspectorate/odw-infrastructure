alert_group_platform_enabled             = true
alert_group_synapse_enabled              = true
alert_scope_service_health               = "/subscriptions/a82fd28d-5989-4e06-a0bb-1a5d859f9e0c"
alert_threshold_data_lake_capacity_bytes = 10995116277760 # 10TiB

apim_enabled         = false
apim_publisher_email = "alex.delany@planninginspectorate.gov.uk"
apim_publisher_name  = "Alex Delany"
apim_sku_name        = "Developer_1"

bastion_host_enabled = false
bastion_vm_username  = "basadmin"
bastion_vm_size      = "Standard_F2s_v2"
bastion_vm_image = {
  publisher = "microsoft-dsvm"
  offer     = "dsvm-win-2019"
  sku       = "winserver-2019"
  version   = "latest"
}

data_lake_account_tier     = "Standard"
data_lake_replication_type = "RAGRS"
data_lake_retention_days   = 28
data_lake_role_assignments = {
  "Storage Blob Data Contributor" = [
    "1fa42635-5dc3-43bc-b5da-77578f3dabb7", # pins-odw-prod-administrators
    "5c56c7a0-6845-43e7-877c-c8dd527107a3", # pins-odw-prod-dataengineers
    "0cad1989-27de-4242-a06b-7cad373497e7"  # Azure DevOps Pipelines - ODW Prod - Infrastructure
  ]
}
data_lake_storage_containers = [
  "backup-logs",
  "odw-curated",
  "odw-raw",
  "odw-standardised",
  "odw-harmonised",
  "odw-config"
]

devops_agent_pool_resource_group_name          = "pins-rg-devops-odw-prod-uks"
devops_agent_pool_resource_group_name_failover = "pins-rg-devops-odw-prod-ukw"

environment = "prod"

function_app_enabled = true
function_app = [
  {
    name = "fnapp01"
    connection_strings = [
      {
        name  = "SqlConnectionString",
        type  = "SQLAzure",
        value = "Server=tcp:pins-synw-odw-prod-uks-ondemand.sql.azuresynapse.net,1433;Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Database=odw_curated_db;Authentication=Active Directory Managed Identity;"
      },
      {
        name  = "SqlConnectionString2",
        type  = "SQLAzure",
        value = "Server=tcp:pins-synw-odw-prod-uks-ondemand.sql.azuresynapse.net,1433;Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Database=odw_harmonised_db;Authentication=Active Directory Managed Identity;"
      }
    ]
    site_config = {
      application_stack = {
        python_version = "3.11"
      }
    }
  }
]

horizon_integration_config = {
  networking = {
    resource_group_name  = "PRDHZN"
    vnet_name            = "VNPRD-192.168.0.0-16"
    database_subnet_name = "SN-VNPRD-DB-192.168.3.0-24"
  }
}

location = "uk-south"

logic_app_enabled = false

key_vault_role_assignments = {
  "Key Vault Administrator" = [
    "1fa42635-5dc3-43bc-b5da-77578f3dabb7" # pins-odw-prod-administrators
  ],
  "Key Vault Secrets Officer" = [
    "5c56c7a0-6845-43e7-877c-c8dd527107a3" # pins-odw-prod-dataengineers
  ]
}

message_storage_account = "https://pinsstodwprodukson83nw.blob.core.windows.net"

message_storage_container = "odw-raw/ServiceBus"

network_watcher_enabled = false

odt_back_office_service_bus_enabled                      = true
odt_back_office_service_bus_failover_enabled             = false
odt_back_office_service_bus_name                         = "pins-sb-back-office-prod-ukw-001"
odt_back_office_service_bus_name_failover                = "pins-sb-back-office-prod-uks-001"
odt_back_office_service_bus_resource_group_name          = "pins-rg-back-office-prod-ukw-001"
odt_back_office_service_bus_resource_group_name_failover = "pins-rg-back-office-prod-uks-001"
odt_backoffice_sb_topic_subscriptions = [
  {
    subscription_name = "service-user"
    topic_name        = "service-user"
  },
  {
    subscription_name = "nsip-project"
    topic_name        = "nsip-project"
  },
  {
    subscription_name = "nsip-exam-timetable"
    topic_name        = "nsip-exam-timetable"
  },
  {
    subscription_name = "nsip-document"
    topic_name        = "nsip-document"
  },
  {
    subscription_name = "nsip-representation"
    topic_name        = "nsip-representation"
  },
  {
    subscription_name = "nsip-s51-advice"
    topic_name        = "nsip-s51-advice"
  },
  {
    subscription_name = "nsip-project-update"
    topic_name        = "nsip-project-update"
  },
  {
    subscription_name = "nsip-subscription"
    topic_name        = "nsip-subscription"
  },
  {
    subscription_name = "folder"
    topic_name        = "folder"
  }
]

## Appeals Back Office
odt_appeals_back_office = {
  resource_group_name = "pins-rg-appeals-bo-prod"
  service_bus_enabled = true
  service_bus_name    = "pins-sb-appeals-bo-prod"
}

service_bus_failover_enabled = false
service_bus_role_assignments = {
  "Azure Service Bus Data Owner" = {
    groups = ["pins-odw-prod-administrators"]
  }
}

service_bus_topics_and_subscriptions = [
  {
    name = "employee"
    subscriptions = {
      "employee"        = {},
      "employee-verify" = {}
    }
  },
  {
    name = "zendesk"
    subscriptions = {
      "zendesk"        = {},
      "zendesk-verify" = {}
    }
  },
  {
    name = "service-user"
    subscriptions = {
      "service-user" = {},
    }
  },
  {
    name = "nsip-project"
    subscriptions = {
      "nsip-project" = {},
    }
  },
  {
    name = "nsip-exam-timetable"
    subscriptions = {
      "nsip-exam-timetable" = {},
    }
  },
  {
    name = "nsip-document"
    subscriptions = {
      "nsip-document" = {},
    }
  },
  {
    name = "nsip-representation"
    subscriptions = {
      "nsip-representation" = {},
    }
  },
  {
    name = "nsip-s51-advice"
    subscriptions = {
      "nsip-s51-advice" = {},
    }
  },
]

spark_pool_enabled         = true
spark_pool_max_node_count  = 12
spark_pool_min_node_count  = 3
spark_pool_node_size       = "Small"
spark_pool_timeout_minutes = 60
spark_pool_version         = "3.3"
new_spark_pool_version     = "3.4"

spark_pool_preview_enabled = true
spark_pool_preview_version = "3.4"

sql_pool_collation = "SQL_Latin1_General_CP1_CI_AS"
sql_pool_enabled   = false
sql_pool_sku_name  = "DW100c"

sql_server_administrator_username = "sqladmin"
sql_server_enabled                = false

synapse_aad_administrator = {
  username  = "pins-odw-data-prod-syn-ws-sqladmins"
  object_id = "f0e4d89f-3288-48c9-ada9-1227a069c76e"
}

synapse_data_exfiltration_enabled  = false
synapse_sql_administrator_username = "synadmin"

synapse_role_assignments = [
  { # pins-odw-data-prod-syn-ws-administrators
    role_definition_name = "Synapse Administrator",
    principal_id         = "a2568721-f55c-4cbe-8cef-3d4fa2e1cee7"
  },
  { # Azure DevOps Pipelines - ODW Prod - Infrastructure
    role_definition_name = "Synapse Administrator",
    principal_id         = "0cad1989-27de-4242-a06b-7cad373497e7"
  },
  { # pins-odw-data-prod-syn-ws-contributors
    role_definition_name = "Synapse Contributor",
    principal_id         = "76259388-176a-4db7-a5b7-db2861ef7220"
  },
  { # pins-odw-data-prod-syn-ws-computeoperators
    role_definition_name = "Synapse Compute Operator",
    principal_id         = "df8e79ba-3f7b-457c-936a-dada88cb178a"
  }
]

tags = {}

tenant_id = "5878df98-6f88-48ab-9322-998ce557088d"

vnet_base_cidr_block          = "10.90.0.0/24"
vnet_base_cidr_block_failover = "10.90.1.0/24"
vnet_subnets = [
  {
    "name" : "AzureBastionSubnet",
    "new_bits" : 4 # /28
    service_endpoints  = []
    service_delegation = []
  },
  {
    "name" : "FunctionAppSubnet",
    "new_bits" : 4 # /28
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ServiceBus"]
    service_delegation = [
      {
        delegation_name = "Microsoft.Web/serverFarms"
        actions         = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    ]
  },
  {
    "name" : "SynapseEndpointSubnet",
    "new_bits" : 2 # /26
    service_endpoints  = []
    service_delegation = []
  },
  {
    "name" : "ComputeSubnet"
    "new_bits" : 2 # /26
    service_endpoints  = ["Microsoft.Storage", "Microsoft.KeyVault"]
    service_delegation = []
  },
  {
    "name" : "ApimSubnet",
    "new_bits" : 2 # /26
    service_endpoints  = []
    service_delegation = []
  },
]

external_resource_links_enabled = true

link_purview_account = true

run_shir_setup_script = false
