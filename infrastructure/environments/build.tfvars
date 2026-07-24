bastion_host_enabled = false

daily_log_cap = 0.2

data_lake_role_assignments = {
  "Storage Blob Data Contributor" = [
    "8274feca-09ef-41b1-9b4e-5eedc3384df4", # pins-odw-preprod-administrators
    "7c906e1b-ffbb-44d3-89a1-6772b9c9c148", # pins-odw-preprod-dataengineers
    "9d7c0f07-9839-4928-8927-bfc19f9f6bd2"  # Azure DevOps Pipelines - ODW Build - Infrastructure
  ]
}
data_lake_storage_containers = [
  "backup-logs",
  "odw-curated",
  "odw-raw",
  "odw-standardised",
  "odw-harmonised",
  "odw-config",
  "odw-curated-migration", # This container seems to be manually created in the other envs. This should be reviewed
  "odw-config-db",         # This container seems to be manually created in the other envs. This should be reviewed
  "odw-meta-db"
]

devops_agent_failover_enabled = false

environment = "build"

horizon_integration_config = {
  networking = {
    resource_group_name  = "PREHZN"
    vnet_name            = "VNPRE-10.0.0.0-16"
    database_subnet_name = "SN-VNPRE-DB-10.0.3.0-24"
  }
}

logic_app_enabled = false

key_vault_role_assignments = {
  "Key Vault Administrator" = [
    "8274feca-09ef-41b1-9b4e-5eedc3384df4" # pins-odw-preprod-administrators
  ],
  "Key Vault Secrets Officer" = [
    "7c906e1b-ffbb-44d3-89a1-6772b9c9c148" # pins-odw-preprod-dataengineers
  ]
}

message_storage_account = "https://pinsstodwbuildukslu4d8k.blob.core.windows.net"

message_storage_container = "odw-raw/ServiceBus"

network_watcher_enabled = false

service_bus_role_assignments = {
  "Azure Service Bus Data Owner" = {
    groups = [] # "pins-odw-preprod-administrators"
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
]

spark_pool_version = "3.4"

synapse_aad_administrator = {
  username  = "pins-odw-data-preprod-syn-ws-sqladmins"
  object_id = "ba5af92f-a1bf-4332-a3c9-613a0a8f1b12"
}

synapse_role_assignments = [
  { # pins-odw-data-preprod-syn-ws-administrators
    role_definition_name = "Synapse Administrator",
    principal_id         = "be52cb0c-858f-4698-8c40-3a5ec793a2e3"
  },
  # This one seems to be automatically assigned when the Synapse workspace is created
  #{ # Azure DevOps Pipelines - ODW Build - Infrastructure
  #  role_definition_name = "Synapse Administrator",
  #  principal_id         = "9d7c0f07-9839-4928-8927-bfc19f9f6bd2"
  #},
  { # pins-odw-data-preprod-syn-ws-contributors
    role_definition_name = "Synapse Contributor",
    principal_id         = "d59a3e85-58db-4b70-8f88-3f4a4a82ee27"
  },
  { # pins-odw-data-preprod-syn-ws-computeoperators
    role_definition_name = "Synapse Compute Operator",
    principal_id         = "f9c580cd-cab0-4c49-9f50-290194ade29e"
  }
]

vnet_base_cidr_block          = "10.100.0.0/24"
vnet_base_cidr_block_failover = "10.100.1.0/24"

external_resource_links_enabled = false

link_purview_account = false

create_service_bus_resources = false

devops_agent_vm_sku = "Standard_D4as_v4"

specialist_case_validation_check_logic_app_enabled = false