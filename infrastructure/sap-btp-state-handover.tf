# OAuth secrets are now managed manually.
# Stop tracking this secret without deleting it from Azure Key Vault.
removed {
  from = azurerm_key_vault_secret.sap_btp_tenant_id

  lifecycle {
    destroy = false
  }
}