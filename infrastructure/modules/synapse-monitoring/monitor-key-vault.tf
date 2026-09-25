resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  name                       = "KeyVault"
  target_resource_id         = var.key_vault_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.synapse.id

  enabled_metric {
    category = "AllMetrics"
  }

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }
}
