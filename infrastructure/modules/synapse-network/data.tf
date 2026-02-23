data "azurerm_private_dns_resolver" "tooling" {
  name                = "pins-dns-resolver-vpn-shared-tooling-uks"
  resource_group_name = var.tooling_config.network_rg
}

data "azurerm_private_dns_resolver_inbound_endpoint" "tooling" {
  name                    = "pins-snet-vpn-resolver-shared-tooling-uks"
  private_dns_resolver_id = data.azurerm_private_dns_resolver.tooling.id
}