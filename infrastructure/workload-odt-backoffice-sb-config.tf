locals {
  odt_nsips_back_office = {
    service_bus_name    = "pins-sb-back-office-${var.environment}-ukw-001"
    resource_group_name = "pins-rg-back-office-${var.environment}-ukw-001"


  }
  odt_nsips_back_office_service_bus_id = join("/", [
    "/subscriptions",
    var.odt_subscription_id,
    "resourceGroups",
    local.odt_nsips_back_office.resource_group_name,
    "providers/Microsoft.ServiceBus/namespaces",
    local.odt_nsips_back_office.service_bus_name
  ])

  odt_appeals_back_office = {
    resource_group_name  = "pins-rg-appeals-bo-${var.environment}"
    service_bus_enabled  = true
    service_bus_name     = "pins-sb-appeals-bo-${var.environment}"
    virtual_network_name = "pins-vnet-appeals-bo-${var.environment}"

    topics_to_subscribe = [
      "appeal-has",
      "appeal-s78",
      "appeal-document",
      "appeal-event",
      "appeal-service-user",
      "appeal-representation",
      "appeal-event-estimate"
    ]
  }
  odt_appeals_back_office_service_bus_id = join("/", [
    "/subscriptions",
    var.odt_subscription_id,
    "resourceGroups",
    local.odt_appeals_back_office.resource_group_name,
    "providers/Microsoft.ServiceBus/namespaces",
    local.odt_appeals_back_office.service_bus_name
  ])
  # A map containing the configuration for Service Bus Subscriptions to be created in the Appeals Back Office Service Bus Namespace.
  # based on the topics list above - since we have the same set of subscriptions per topic
  odt_appeals_back_office_sb_topic_subscriptions = concat(
    [
      # create an odw-subscription for each topic
      for topic in local.odt_appeals_back_office.topics_to_subscribe : {
        subscription_name = "${topic}-odw-sub"
        topic_name        = topic
      }
    ],
    [
      # create an odw-wake- subscription for each topic
      for topic in local.odt_appeals_back_office.topics_to_subscribe : {
        subscription_name                         = "${topic}-odw-wake-sub"
        topic_name                                = topic
        enable_batched_operations                 = true
        dead_lettering_on_filter_evaluation_error = false
        max_delivery_count                        = 1
      }
    ]
  )
}