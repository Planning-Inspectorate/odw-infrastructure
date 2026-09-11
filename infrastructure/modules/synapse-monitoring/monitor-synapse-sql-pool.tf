resource "azurerm_monitor_diagnostic_setting" "synapse_sql_pool" {
  count = var.sql_pool_enabled ? 1 : 0

  name                       = "SynapseDedicatedSqlPool"
  target_resource_id         = var.synapse_sql_pool_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.synapse.id

  enabled_metric {
    category = "AllMetrics"
  }

  enabled_log {
    category = "DmsWorkers"
  }

  enabled_log {
    category = "ExecRequests"
  }

  enabled_log {
    category = "RequestSteps"
  }

  enabled_log {
    category = "SQLSecurityAuditEvents"
  }

  enabled_log {
    category = "SqlRequests"
  }

  enabled_log {
    category = "Waits"
  }
}
