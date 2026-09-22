data "azurerm_subnet" "compute" {
  name                 = "ComputeSubnet"
  resource_group_name  = "pins-rg-network-odw-${var.environment}-uks"
  virtual_network_name = "vnet-odw-${var.environment}-uks"
}

data "azurerm_subnet" "compute_failover" {
  name                 = "ComputeSubnet"
  resource_group_name  = "pins-rg-network-odw-${var.environment}-ukw"
  virtual_network_name = "vnet-odw-${var.environment}-ukw"
}