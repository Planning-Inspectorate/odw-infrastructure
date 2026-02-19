alert_group_platform_enabled             = true
alert_group_synapse_enabled              = true
alert_scope_service_health               = "/subscriptions/ff442a29-fc06-4a13-8e3e-65fd5da513b3"
alert_threshold_data_lake_capacity_bytes = 10995116277760 # 10TiB

apim_enabled         = false
apim_publisher_email = "alex.delany@planninginspectorate.gov.uk"
apim_publisher_name  = "Alex Delany"
apim_sku_name        = "Developer_1"

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

data_lake_account_tier     = "Standard"
data_lake_replication_type = "LRS"
data_lake_retention_days   = 7
data_lake_role_assignments = {
  "Storage Blob Data Contributor" = [
    "ebcc4498-4abe-4457-8970-7fa08bf87543", # pins-odw-dev-administrators
    "48bd5755-6d7d-4a17-b044-7522c54e9c7d", # pins-odw-dev-dataengineers
    "875e931a-ee45-425e-acde-1ec24a8a290d"  # Azure DevOps Pipelines - ODW Dev - Infrastructure"
  ]
}
data_lake_storage_containers = [
  "backup-logs",
  "odw-curated",
  "odw-raw",
  "odw-standardised",
  "odw-harmonised",
  "odw-config",
  "odw-meta-db"
]

data_lake_storage_containers_to_import = [
  "insights-logs-builtinsqlreqsended",
  "logging",
  "odw-config-db",
  "odw-curated-migration",
  "odw-standardised-delta",
  "s51-advice-backup",
  "saphrspdata-to-odw"
]

devops_agent_pool_resource_group_name          = "pins-rg-devops-odw-dev-uks"
devops_agent_pool_resource_group_name_failover = "pins-rg-devops-odw-dev-ukw"

environment = "dev"

function_app_enabled = true
function_app = [
  {
    name = "fnapp01"
    connection_strings = [
      {
        name  = "SqlConnectionString",
        type  = "SQLAzure",
        value = "Server=tcp:pins-synw-odw-dev-uks-ondemand.sql.azuresynapse.net,1433;Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Database=odw_curated_db;Authentication=Active Directory Managed Identity;"
      },
      {
        name  = "SqlConnectionString2",
        type  = "SQLAzure",
        value = "Server=tcp:pins-synw-odw-dev-uks-ondemand.sql.azuresynapse.net,1433;Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Database=odw_harmonised_db;Authentication=Active Directory Managed Identity;"
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

location = "uk-south"

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

odt_back_office_service_bus_enabled                      = true
odt_back_office_service_bus_failover_enabled             = false
odt_back_office_service_bus_name                         = "pins-sb-back-office-dev-ukw-001"
odt_back_office_service_bus_name_failover                = "pins-sb-back-office-dev-uks-001"
odt_back_office_service_bus_resource_group_name          = "pins-rg-back-office-dev-ukw-001"
odt_back_office_service_bus_resource_group_name_failover = "pins-rg-back-office-dev-uks-001"
odt_backoffice_sb_topic_subscriptions = [
  {
    subscription_name = "odw-service-user-sub"
    topic_name        = "service-user"
  },
  {
    subscription_name = "odw-nsip-project-sub"
    topic_name        = "nsip-project"
  },
  {
    subscription_name = "odw-nsip-exam-timetable-sub"
    topic_name        = "nsip-exam-timetable"
  },
  {
    subscription_name = "odw-nsip-document-sub"
    topic_name        = "nsip-document"
  },
  {
    subscription_name = "odw-nsip-representation-sub"
    topic_name        = "nsip-representation"
  },
  {
    subscription_name = "odw-nsip-s51-advice-sub"
    topic_name        = "nsip-s51-advice"
  },
  {
    subscription_name = "odw-nsip-project-update-sub"
    topic_name        = "nsip-project-update"
  },
  {
    subscription_name = "odw-nsip-subscription-sub"
    topic_name        = "nsip-subscription"
  },
  {
    subscription_name = "odw-folder-sub"
    topic_name        = "folder"
  }
]

## Appeals Back Office
odt_appeals_back_office = {
  resource_group_name = "pins-rg-appeals-bo-dev"
  service_bus_enabled = true
  service_bus_name    = "pins-sb-appeals-bo-dev"
}

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

service_bus_failover_enabled = false
service_bus_premium_enabled  = true
service_bus_role_assignments = {
  "Azure Service Bus Data Owner" = {
    groups = ["pins-odw-dev-administrators"]
  }
  "Azure Service Bus Data Reader" = {
    service_principals = ["Azure DevOps Pipelines - ODW - Infrastructure DEV"]
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
      "odw-service-user-sub" = {}
    }
  },
  {
    name = "nsip-project"
    subscriptions = {
      "odw-nsip-project-sub" = {}
    }
  },
  {
    name = "nsip-exam-timetable"
    subscriptions = {
      "odw-nsip-exam-timetable-sub" = {}
    }
  },
  {
    name = "nsip-document"
    subscriptions = {
      "odw-nsip-document-sub" = {}
    }
  },
  {
    name = "nsip-representation"
    subscriptions = {
      "odw-nsip-representation-sub" = {}
    }
  },
  {
    name = "nsip-s51-advice"
    subscriptions = {
      "odw-nsip-s51-advice-sub" = {},
    }
  },
  {
    name = "pins-inspector"
    subscriptions = {
      "pins-inspector-odw-sub" = {}
    }
  }
]

spark_pool_enabled         = true
spark_pool_max_node_count  = 12
spark_pool_min_node_count  = 3
spark_pool_node_size       = "Small"
spark_pool_timeout_minutes = 60
spark_pool_version         = "3.4"
new_spark_pool_version     = "3.4"

spark_pool_preview_enabled = true
spark_pool_preview_version = "3.4"

sql_pool_collation = "SQL_Latin1_General_CP1_CI_AS"
sql_pool_enabled   = false
sql_pool_sku_name  = "DW100c"

sql_server_administrator_username = "sqladmin"
sql_server_enabled                = true

synapse_aad_administrator = {
  username  = "pins-odw-data-dev-syn-ws-sqladmins"
  object_id = "1c996957-30e4-40fe-b0b4-82d40f13c058"
}

synapse_data_exfiltration_enabled  = false
synapse_sql_administrator_username = "synadmin"

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

tags = {}

tenant_id = "5878df98-6f88-48ab-9322-998ce557088d"

vnet_base_cidr_block          = "10.70.0.0/24"
vnet_base_cidr_block_failover = "10.70.1.0/24"
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
    service_endpoints                 = []
    service_delegation                = []
    private_endpoint_network_policies = "Disabled"
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
