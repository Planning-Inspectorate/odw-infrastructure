# common variables loaded by default
# see https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files

data_lake_storage_containers = [
  "backup-logs",
  "odw-curated",
  "odw-raw",
  "odw-standardised",
  "odw-harmonised",
  "odw-config",
  "odw-meta-db"
]

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
  },
  {
  name = "applications-notify-email"
  subscriptions = {
    "applications-notify-email-sub"      = {},
    "applications-notify-email-wake-sub" = {}
  }
  },
  {
  name = "applications-representation"
  subscriptions = {
    "applications-representation-sub"      = {},
    "applications-representation-wake-sub" = {}
  }
}
]

tooling_config = {
  network_name    = "pins-vnet-shared-tooling-uks"
  network_rg      = "pins-rg-shared-tooling-uks"
  subscription_id = "edb1ff78-90da-4901-a497-7e79f966f8e2"
}

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