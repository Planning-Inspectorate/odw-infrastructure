terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "> 3.74.0, < 6.0.0"
      configuration_aliases = [azurerm, azurerm.odt, azurerm.training]
    }
  }
}