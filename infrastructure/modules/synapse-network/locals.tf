locals {
  module_name     = "synapse-network"
  resource_suffix = "${var.service_name}-${var.environment}-${module.azure_region.location_short}"

  nsg_path = "providers/Microsoft.Network/networkSecurityGroups"

  subnets = {
    for subnet in var.vnet_subnets : subnet.name => {
      new_bits                                      = subnet.new_bits
      cidr_block                                    = module.subnets.network_cidr_blocks[subnet.name]
      service_endpoints                             = subnet.service_endpoints
      service_delegation                            = subnet.service_delegation
      private_endpoint_network_policies             = subnet.private_endpoint_network_policies
      private_link_service_network_policies_enabled = subnet.private_link_service_network_policies_enabled
    }
  }

  tags = merge(
    var.tags,
    {
      ModuleName = local.module_name
    }
  )
}
