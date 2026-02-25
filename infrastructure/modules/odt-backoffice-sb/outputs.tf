output "subscription_ids" {
  description = "A map of Subscription Name to Subscription Keys (used for consumer RBAC assignments)"
  value = {
    for key, subscription in azurerm_servicebus_subscription.odt_backoffice_subscriptions :
    subscription.name => subscription.id
  }
}
