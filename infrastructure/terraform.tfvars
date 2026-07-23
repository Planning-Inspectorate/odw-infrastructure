# common variables loaded by default
# see https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files

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

odt_appeals_back_office_sb_topic_subscriptions = [
  {
    subscription_name = "appeal-has-odw-sub"
    topic_name        = "appeal-has"
  },
  {
    subscription_name = "appeal-s78-odw-sub"
    topic_name        = "appeal-s78"
  },
  {
    subscription_name = "appeal-document-odw-sub"
    topic_name        = "appeal-document"
  },
  {
    subscription_name = "appeal-event-odw-sub"
    topic_name        = "appeal-event"
  },
  {
    subscription_name = "appeal-service-user-odw-sub"
    topic_name        = "appeal-service-user"
  },
  {
    subscription_name = "appeal-representation-odw-sub"
    topic_name        = "appeal-representation"
  },
  {
    subscription_name = "appeal-event-estimate-odw-sub"
    topic_name        = "appeal-event-estimate"
  },
  {
    subscription_name                         = "appeal-document-odw-wake-sub"
    topic_name                                = "appeal-document"
    enable_batched_operations                 = true
    dead_lettering_on_filter_evaluation_error = false
    max_delivery_count                        = 1
  },
  {
    subscription_name                         = "appeal-event-odw-wake-sub"
    topic_name                                = "appeal-event"
    enable_batched_operations                 = true
    dead_lettering_on_filter_evaluation_error = false
    max_delivery_count                        = 1
  },
  {
    subscription_name                         = "appeal-event-estimate-odw-wake-sub"
    topic_name                                = "appeal-event-estimate"
    enable_batched_operations                 = true
    dead_lettering_on_filter_evaluation_error = false
    max_delivery_count                        = 1
  },
  {
    subscription_name                         = "appeal-has-odw-wake-sub"
    topic_name                                = "appeal-has"
    enable_batched_operations                 = true
    dead_lettering_on_filter_evaluation_error = false
    max_delivery_count                        = 1
  },
  {
    subscription_name                         = "appeal-representation-odw-wake-sub"
    topic_name                                = "appeal-representation"
    enable_batched_operations                 = true
    dead_lettering_on_filter_evaluation_error = false
    max_delivery_count                        = 1
  },
  {
    subscription_name                         = "appeal-s78-odw-wake-sub"
    topic_name                                = "appeal-s78"
    enable_batched_operations                 = true
    dead_lettering_on_filter_evaluation_error = false
    max_delivery_count                        = 1
  },
  {
    subscription_name                         = "appeal-service-user-odw-wake-sub"
    topic_name                                = "appeal-service-user"
    enable_batched_operations                 = true
    dead_lettering_on_filter_evaluation_error = false
    max_delivery_count                        = 1
  }
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
odt_backoffice_sb_topic_subscriptions_to_import = [
  {
    subscription_name = "folder-odw-wake-sub"
    topic_name        = "folder"
  },
  {
    subscription_name = "odw-nsip-document-wake-sub"
    topic_name        = "nsip-document"
  },
  {
    subscription_name = "odw-nsip-exam-timetable-wake-sub"
    topic_name        = "nsip-exam-timetable"
  },
  {
    subscription_name = "odw-nsip-project-wake-sub"
    topic_name        = "nsip-project"
  },
  {
    subscription_name = "odw-nsip-project-update-wake-sub"
    topic_name        = "nsip-project-update"
  },
  {
    subscription_name = "odw-nsip-representation-wake-sub"
    topic_name        = "nsip-representation"
  },
  {
    subscription_name = "odw-nsip-s51-advice-wake-sub"
    topic_name        = "nsip-s51-advice"
  },
  {
    subscription_name = "odw-nsip-subscription-wake-sub"
    topic_name        = "nsip-subscription"
  },
  {
    subscription_name = "odw-service-user-wake-sub"
    topic_name        = "service-user"
  }
]

odt_appeals_backoffice_sb_topic_subscriptions_to_import = [
  {
    subscription_name = "appeal-document-odw-wake-sub"
    topic_name        = "appeal-document"
  },
  {
    subscription_name = "appeal-event-odw-wake-sub"
    topic_name        = "appeal-event"
  },
  {
    subscription_name = "appeal-event-estimate-odw-wake-sub"
    topic_name        = "appeal-event-estimate"
  },
  {
    subscription_name = "appeal-has-odw-wake-sub"
    topic_name        = "appeal-has"
  },
  {
    subscription_name = "appeal-representation-odw-wake-sub"
    topic_name        = "appeal-representation"
  },
  {
    subscription_name = "appeal-s78-odw-wake-sub"
    topic_name        = "appeal-s78"
  },
  {
    subscription_name = "appeal-service-user-odw-wake-sub"
    topic_name        = "appeal-service-user"
  }
]