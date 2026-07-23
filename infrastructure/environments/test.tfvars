alert_group_platform_enabled             = true
alert_group_synapse_enabled              = true
alert_scope_service_health               = "/subscriptions/6b18ba9d-2399-48b5-a834-e0f267be122d"
alert_threshold_data_lake_capacity_bytes = 10995116277760 # 10TiB

bastion_host_enabled = false

daily_log_cap = 0.2

data_lake_account_tier     = "Standard"
data_lake_replication_type = "GRS"
data_lake_retention_days   = 7
data_lake_role_assignments = {
  "Storage Blob Data Contributor" = [
    "8274feca-09ef-41b1-9b4e-5eedc3384df4", # pins-odw-preprod-administrators
    "7c906e1b-ffbb-44d3-89a1-6772b9c9c148", # pins-odw-preprod-dataengineers
    "9d4c68d1-c43d-4502-b35f-74f31c497757"  # Azure DevOps Pipelines - ODW Test - Infrastructure
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
  "logging",
  "odw-curated-migration"
]

devops_agent_pool_resource_group_name          = "pins-rg-devops-odw-test-uks"
devops_agent_pool_resource_group_name_failover = "pins-rg-devops-odw-test-ukw"

environment = "test"

deploy_s62a_migration_storage = true

function_app_enabled = true
function_app = [
  {
    name = "fnapp01"
    connection_strings = [
      {
        name  = "SqlConnectionString",
        type  = "SQLAzure",
        value = "Server=tcp:pins-synw-odw-test-uks-ondemand.sql.azuresynapse.net,1433;Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Database=odw_curated_db;Authentication=Active Directory Managed Identity;"
      },
      {
        name  = "SqlConnectionString2",
        type  = "SQLAzure",
        value = "Server=tcp:pins-synw-odw-test-uks-ondemand.sql.azuresynapse.net,1433;Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Database=odw_harmonised_db;Authentication=Active Directory Managed Identity;"
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

location = "uk-south"

logic_app_enabled = false

key_vault_role_assignments = {
  "Key Vault Administrator" = [
    "8274feca-09ef-41b1-9b4e-5eedc3384df4" # pins-odw-preprod-administrators
  ],
  "Key Vault Secrets Officer" = [
    "7c906e1b-ffbb-44d3-89a1-6772b9c9c148" # pins-odw-preprod-dataengineers
  ]
}

message_storage_account = "https://pinsstodwtestukswic3ai.blob.core.windows.net"

message_storage_container = "odw-raw/ServiceBus"

network_watcher_enabled = false

odt_back_office_service_bus_enabled                      = true
odt_back_office_service_bus_failover_enabled             = false
odt_back_office_service_bus_name                         = "pins-sb-back-office-test-ukw-001"
odt_back_office_service_bus_name_failover                = "pins-sb-back-office-test-uks-001"
odt_back_office_service_bus_resource_group_name          = "pins-rg-back-office-test-ukw-001"
odt_back_office_service_bus_resource_group_name_failover = "pins-rg-back-office-test-uks-001"
odt_backoffice_sb_topic_subscriptions = [
  {
    subscription_name = "odw-service-user-sub"
    topic_name        = "service-user"
  },
  {
    subscription_name                         = "odw-service-user-wake-sub"
    topic_name                                = "service-user"
    enable_batched_operations                 = true
    dead_lettering_on_filter_evaluation_error = false
    max_delivery_count                        = 1
  },
  {
    subscription_name = "odw-nsip-project-sub"
    topic_name        = "nsip-project"
  },
  {
    subscription_name                         = "odw-nsip-project-wake-sub"
    topic_name                                = "nsip-project"
    enable_batched_operations                 = true
    dead_lettering_on_filter_evaluation_error = false
    max_delivery_count                        = 1
  },
  {
    subscription_name = "odw-nsip-exam-timetable-sub"
    topic_name        = "nsip-exam-timetable"
  },
  {
    subscription_name                         = "odw-nsip-exam-timetable-wake-sub"
    topic_name                                = "nsip-exam-timetable"
    enable_batched_operations                 = true
    dead_lettering_on_filter_evaluation_error = false
    max_delivery_count                        = 1
  },
  {
    subscription_name = "odw-nsip-document-sub"
    topic_name        = "nsip-document"
  },
  {
    subscription_name                         = "odw-nsip-document-wake-sub"
    topic_name                                = "nsip-document"
    enable_batched_operations                 = true
    dead_lettering_on_filter_evaluation_error = false
    max_delivery_count                        = 1
  },
  {
    subscription_name = "odw-nsip-representation-sub"
    topic_name        = "nsip-representation"
  },
  {
    subscription_name                         = "odw-nsip-representation-wake-sub"
    topic_name                                = "nsip-representation"
    enable_batched_operations                 = true
    dead_lettering_on_filter_evaluation_error = false
    max_delivery_count                        = 1
  },
  {
    subscription_name = "odw-nsip-s51-advice-sub"
    topic_name        = "nsip-s51-advice"
  },
  {
    subscription_name                         = "odw-nsip-s51-advice-wake-sub"
    topic_name                                = "nsip-s51-advice"
    enable_batched_operations                 = true
    dead_lettering_on_filter_evaluation_error = false
    max_delivery_count                        = 1
  },
  {
    subscription_name = "odw-nsip-project-update-sub"
    topic_name        = "nsip-project-update"
  },
  {
    subscription_name                         = "odw-nsip-project-update-wake-sub"
    topic_name                                = "nsip-project-update"
    enable_batched_operations                 = true
    dead_lettering_on_filter_evaluation_error = false
    max_delivery_count                        = 1
  },
  {
    subscription_name = "odw-nsip-subscription-sub"
    topic_name        = "nsip-subscription"
  },
  {
    subscription_name                         = "odw-nsip-subscription-wake-sub"
    topic_name                                = "nsip-subscription"
    enable_batched_operations                 = true
    dead_lettering_on_filter_evaluation_error = false
    max_delivery_count                        = 1
  },
  {
    subscription_name = "odw-folder-sub"
    topic_name        = "folder"
  },
  {
    subscription_name                         = "folder-odw-wake-sub"
    topic_name                                = "folder"
    enable_batched_operations                 = true
    dead_lettering_on_filter_evaluation_error = false
    max_delivery_count                        = 1
  }
]

## Appeals Back Office
odt_appeals_back_office = {
  resource_group_name  = "pins-rg-appeals-bo-test"
  service_bus_enabled  = true
  service_bus_name     = "pins-sb-appeals-bo-test"
  virtual_network_name = "pins-vnet-appeals-bo-test"
}

service_bus_failover_enabled = false
service_bus_premium_enabled  = true
service_bus_role_assignments = {
  "Azure Service Bus Data Owner" = {
    groups = ["pins-odw-preprod-administrators"]
  }
}

service_bus_topics_and_subscriptions = [
  {
    name          = "pins-inspector"
    subscriptions = {}
  },
  {
    name = "application-update"
    subscriptions = {
      "planning-environmental-specialist-odw-sub"      = {},
      "planning-environmental-specialist-odw-wake-sub" = {}
    }
  }
]

spark_pool_version = "3.4"

synapse_aad_administrator = {
  username  = "pins-odw-data-preprod-syn-ws-sqladmins"
  object_id = "ba5af92f-a1bf-4332-a3c9-613a0a8f1b12"
}

synapse_data_exfiltration_enabled     = false
synapse_sql_administrator_username    = "synadmin"
synapse_public_network_access_enabled = false

synapse_role_assignments = [
  { # pins-odw-data-preprod-syn-ws-administrators
    role_definition_name = "Synapse Administrator",
    principal_id         = "be52cb0c-858f-4698-8c40-3a5ec793a2e3"
  },
  { # Azure DevOps Pipelines - ODW Test - Infrastructure
    role_definition_name = "Synapse Administrator",
    principal_id         = "9d4c68d1-c43d-4502-b35f-74f31c497757"
  },
  { # pins-odw-data-preprod-syn-ws-contributors
    role_definition_name = "Synapse Contributor",
    principal_id         = "d59a3e85-58db-4b70-8f88-3f4a4a82ee27"
  },
  { # pins-odw-data-preprod-syn-ws-computeoperators
    role_definition_name = "Synapse Compute Operator",
    principal_id         = "f9c580cd-cab0-4c49-9f50-290194ade29e"
  }
]

tags = {}

tenant_id = "5878df98-6f88-48ab-9322-998ce557088d"

vnet_base_cidr_block          = "10.80.0.0/24"
vnet_base_cidr_block_failover = "10.80.1.0/24"
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

