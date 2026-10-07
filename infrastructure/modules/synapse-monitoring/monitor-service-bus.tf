resource "azurerm_monitor_diagnostic_setting" "service_bus_namespace" {
  name                       = "ServiceBusNamespace"
  target_resource_id         = var.service_bus_namespace_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.synapse.id

  enabled_metric {
    category = "AllMetrics"
  }

  enabled_log {
    category = "ApplicationMetricsLogs"
  }

  enabled_log {
    category = "OperationalLogs"
  }

  enabled_log {
    category = "RuntimeAuditLogs"
  }

  enabled_log {
    category = "VNetAndIPFilteringLogs"
  }
}
