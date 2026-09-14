resource "azurerm_network_security_group" "nsg" {
  # Skip AzureBastionSubnet (Bastion service manages its own NSG) and
  # SapPlsSubnet (workload-sap-btp-pls.tf owns a purpose-built NSG with
  # LB/PLS rules; a second module-owned NSG would conflict on association).
  for_each = { for k, v in azurerm_subnet.synapse : k => v.id if !startswith(k, "Azure") && k != "SapPlsSubnet" }

  name                = "pins-nsg-${lower(replace(each.key, "Subnet", ""))}-${local.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "nsg" {
  for_each = { for k, v in azurerm_subnet.synapse : k => v.id if !startswith(k, "Azure") && k != "SapPlsSubnet" }

  network_security_group_id = "${var.resource_group_id}/${local.nsg_path}/pins-nsg-${lower(replace(each.key, "Subnet", ""))}-${local.resource_suffix}"
  subnet_id                 = each.value

  depends_on = [
    azurerm_network_security_group.nsg
  ]
}
