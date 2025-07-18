# Synapse Workspace Private
This module deploys a Synapse Workspace with private virtual network enabled. Private endpoints are established and provisioned in the chosen virtual network subnet. An optional Apache Spark pool and/or dedicated SQL pool may be provisioned as requied. Git-enabling the Synapse Workspace will cause the workspace to automatically pull in data pipelines, linked services, etc from the target repository.

### Table of Contents
- [Synapse Workspace Private](#synapse-workspace-private)
    - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)

## Usage
The below module definition provides an example of usage. This module is designed to depend on the outputs from the associated `synapse_network` and `synapse_management` modules. These associate modules provision the Synapse virtual network components as well as Azure Purview.

```
module "synapse_workspace_private" {
  source = "./modules/synapse-workspace-private"

  environment         = "dev"
  resource_group_name = azurerm_resource_group.data.name
  location            = module.azure_region.location_cli
  service_name        = "odw"

  data_lake_account_tier                = "Standard"
  data_lake_replication_type            = "GRS"
  data_lake_role_assignments            = {}
  data_lake_storage_containers          = ["odw-default"]
  key_vault_role_assignments            = {}
  purview_id                            = module.synapse_management.purview_id
  spark_pool_enabled                    = true
  spark_pool_max_node_count             = 12
  spark_pool_min_node_count             = 3
  spark_pool_node_size                  = "Small"
  spark_pool_version                    = "2.4"
  sql_pool_enabled                      = true
  sql_pool_collation                    = "SQL_Latin1_General_CP1_CI_AS"
  sql_pool_sku_name                     = "DW100c"
  synapse_aad_administrator             = {}
  synapse_private_endpoint_dns_zone_id  = module.synapse_network.synapse_private_dns_zone_id
  synapse_private_endpoint_subnet_name  = "SynapseEndpointSubnet"
  synapse_private_endpoint_vnet_subnets = module.synapse_network.vnet_subnets
  synapse_sql_administrator_username    = "synadmin"
  synapse_role_assignments              = {}

  depends_on = [
    module.synapse_network,
    module.synapse_management
  ]

  tags = local.tags
}

```

| :scroll: Note |
|----------|
| This module can take >20 minutes to deploy. |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | > 3.74.0, <5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.14.0 |
| <a name="provider_azurerm.odt"></a> [azurerm.odt](#provider\_azurerm.odt) | 4.14.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.12.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azure_region"></a> [azure\_region](#module\_azure\_region) | claranet/regions/azurerm | 5.1.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_secret.synapse_sql_administrator_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.synapse_sql_administrator_username](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_private_endpoint.synapse_dedicated_sql_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.synapse_development](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.synapse_serverless_sql_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.synapse_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.synapse_msi_data_lake](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.synapse_msi_data_lake_failover](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.synapse_msi_key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_synapse_firewall_rule.allow_all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_firewall_rule) | resource |
| [azurerm_synapse_firewall_rule.allow_all_azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_firewall_rule) | resource |
| [azurerm_synapse_firewall_rule.allowed_ips](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_firewall_rule) | resource |
| [azurerm_synapse_managed_private_endpoint.data_lake](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_managed_private_endpoint) | resource |
| [azurerm_synapse_managed_private_endpoint.data_lake_failover](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_managed_private_endpoint) | resource |
| [azurerm_synapse_managed_private_endpoint.synapse_mpe_appeals_bo_sb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_managed_private_endpoint) | resource |
| [azurerm_synapse_managed_private_endpoint.synapse_mpe_kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_managed_private_endpoint) | resource |
| [azurerm_synapse_private_link_hub.synapse_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_private_link_hub) | resource |
| [azurerm_synapse_role_assignment.synapse](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_role_assignment) | resource |
| [azurerm_synapse_spark_pool.synapse](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_spark_pool) | resource |
| [azurerm_synapse_spark_pool.synapse_preview](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_spark_pool) | resource |
| [azurerm_synapse_sql_pool.synapse](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_sql_pool) | resource |
| [azurerm_synapse_workspace.synapse](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace) | resource |
| [azurerm_synapse_workspace_aad_admin.synapse](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace_aad_admin) | resource |
| [random_password.synapse_sql_administrator_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [time_sleep.firewall_delay](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azurerm_servicebus_namespace.appeals_back_office](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/servicebus_namespace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_lake_account_id"></a> [data\_lake\_account\_id](#input\_data\_lake\_account\_id) | The ID of the Data Lake Storage Account | `string` | n/a | yes |
| <a name="input_data_lake_account_id_failover"></a> [data\_lake\_account\_id\_failover](#input\_data\_lake\_account\_id\_failover) | The ID of the Data Lake Storage Account used for backup and failover | `string` | n/a | yes |
| <a name="input_data_lake_account_name"></a> [data\_lake\_account\_name](#input\_data\_lake\_account\_name) | The name of the Data Lake Storage Account | `string` | n/a | yes |
| <a name="input_data_lake_account_name_failover"></a> [data\_lake\_account\_name\_failover](#input\_data\_lake\_account\_name\_failover) | The name of the Data Lake Storage Account used for backup and failover | `string` | n/a | yes |
| <a name="input_data_lake_filesystem_id"></a> [data\_lake\_filesystem\_id](#input\_data\_lake\_filesystem\_id) | The ID of the Data Lake Gen2 filesystem | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment in which resources will be deployed | `string` | n/a | yes |
| <a name="input_firewall_allowed_ip_addresses"></a> [firewall\_allowed\_ip\_addresses](#input\_firewall\_allowed\_ip\_addresses) | A list of CIDR ranges to be permitted access to the data lake Storage Account | `list(string)` | `[]` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The ID of the Key Vault to use for secret storage | `string` | n/a | yes |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | The name of the Key Vault to use for secret storage | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The short-format Azure region into which resources will be deployed | `string` | n/a | yes |
| <a name="input_network_resource_group_name"></a> [network\_resource\_group\_name](#input\_network\_resource\_group\_name) | The name of the resource group into which private endpoints will be deployed | `string` | n/a | yes |
| <a name="input_odt_appeals_back_office_service_bus_id"></a> [odt\_appeals\_back\_office\_service\_bus\_id](#input\_odt\_appeals\_back\_office\_service\_bus\_id) | The id of the Appeals BO Service Bus namespace | `string` | `null` | no |`null` | no |
| <a name="input_purview_id"></a> [purview\_id](#input\_purview\_id) | The ID of the Purview account to link with the Synapse Workspace | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group into which resources will be deployed | `string` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The short-format name of the overarching service being deployed | `string` | n/a | yes |
| <a name="input_spark_pool_enabled"></a> [spark\_pool\_enabled](#input\_spark\_pool\_enabled) | Determines whether a Synapse-linked Spark pool should be deployed | `bool` | `false` | no |
| <a name="input_spark_pool_max_node_count"></a> [spark\_pool\_max\_node\_count](#input\_spark\_pool\_max\_node\_count) | The maximum number of nodes the Synapse-linked Spark pool can autoscale to | `number` | `9` | no |
| <a name="input_spark_pool_min_node_count"></a> [spark\_pool\_min\_node\_count](#input\_spark\_pool\_min\_node\_count) | The minimum number of nodes the Synapse-linked Spark pool can autoscale to | `number` | `3` | no |
| <a name="input_spark_pool_node_size"></a> [spark\_pool\_node\_size](#input\_spark\_pool\_node\_size) | The size of nodes comprising the Synapse-linked Spark pool | `string` | `"Small"` | no |
| <a name="input_spark_pool_preview_enabled"></a> [spark\_pool\_preview\_enabled](#input\_spark\_pool\_preview\_enabled) | Determines whether a Synapse-linked preview Spark pool should be deployed | `bool` | `false` | no |
| <a name="input_spark_pool_preview_requirements"></a> [spark\_pool\_preview\_requirements](#input\_spark\_pool\_preview\_requirements) | File contents containing a list of packages required by the Spark pool preview | `string` | `null` | no |
| <a name="input_spark_pool_preview_version"></a> [spark\_pool\_preview\_version](#input\_spark\_pool\_preview\_version) | The version of Spark running on the Synapse-linked preview Spark pool | `string` | `"3.3"` | no |
| <a name="input_spark_pool_requirements"></a> [spark\_pool\_requirements](#input\_spark\_pool\_requirements) | File contents containing a list of packages required by the Spark pool | `string` | `null` | no |
| <a name="input_spark_pool_timeout_minutes"></a> [spark\_pool\_timeout\_minutes](#input\_spark\_pool\_timeout\_minutes) | The time buffer in minutes to wait before the Spark pool is paused due to inactivity | `number` | `15` | no |
| <a name="input_spark_pool_version"></a> [spark\_pool\_version](#input\_spark\_pool\_version) | The version of Spark running on the Synapse-linked Spark pool | `string` | `"3.2"` | no |
| <a name="input_sql_pool_collation"></a> [sql\_pool\_collation](#input\_sql\_pool\_collation) | The collation of the Synapse-linked dedicated SQL pool | `string` | `"SQL_Latin1_General_CP1_CI_AS"` | no |
| <a name="input_sql_pool_enabled"></a> [sql\_pool\_enabled](#input\_sql\_pool\_enabled) | Determines whether a Synapse-linked dedicated SQL pool should be deployed | `bool` | `false` | no |
| <a name="input_sql_pool_sku_name"></a> [sql\_pool\_sku\_name](#input\_sql\_pool\_sku\_name) | The SKU of the Synapse-linked dedicated SQL pool | `string` | `"DW100c"` | no |
| <a name="input_synapse_aad_administrator"></a> [synapse\_aad\_administrator](#input\_synapse\_aad\_administrator) | A map describing the username and Azure AD object ID for the Syanapse administrator account | `map(string)` | n/a | yes |
| <a name="input_synapse_data_exfiltration_enabled"></a> [synapse\_data\_exfiltration\_enabled](#input\_synapse\_data\_exfiltration\_enabled) | Determines whether the Synapse Workspace should have data exfiltration protection enabled | `bool` | `false` | no |
| <a name="input_synapse_private_endpoint_dns_zone_id"></a> [synapse\_private\_endpoint\_dns\_zone\_id](#input\_synapse\_private\_endpoint\_dns\_zone\_id) | The ID of the Private DNS Zone hosting privatelink.azuresynapse.net | `string` | n/a | yes |
| <a name="input_synapse_private_endpoint_subnet_name"></a> [synapse\_private\_endpoint\_subnet\_name](#input\_synapse\_private\_endpoint\_subnet\_name) | The name of the subnet into which Synapse private endpoints should be deployed | `string` | `"SynapseEndpointSubnet"` | no |
| <a name="input_synapse_private_endpoint_vnet_subnets"></a> [synapse\_private\_endpoint\_vnet\_subnets](#input\_synapse\_private\_endpoint\_vnet\_subnets) | A map of subnet names and IDs comprising the linked Virtual Network for private endpoint deployment | `map(string)` | n/a | yes |
| <a name="input_synapse_role_assignments"></a> [synapse\_role\_assignments](#input\_synapse\_role\_assignments) | A list of RBAC roles assignments for the Synapse Workspace | <pre>list(object({<br>    role_definition_name = string<br>    principal_id         = string<br>    principal_type       = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_synapse_sql_administrator_username"></a> [synapse\_sql\_administrator\_username](#input\_synapse\_sql\_administrator\_username) | The SQL administrator username for the Synapse Workspace | `string` | `"synadmin"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A collection of tags to assign to taggable resources | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The ID of the Azure AD tenant containing the identities used for RBAC assignments | `string` | n/a | yes |
| <a name="input_create_service_bus_resources"></a> [create\_service\_bus\_resources](#input\_create\_service\_bus\_resources) | If we should create extra resources related to the service bus | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_synapse_endpoints"></a> [synapse\_endpoints](#output\_synapse\_endpoints) | A list of connectivity endpoints associated with the Synapse Workspace |
| <a name="output_synapse_spark_pool_id"></a> [synapse\_spark\_pool\_id](#output\_synapse\_spark\_pool\_id) | The ID of the Synapse Spark Pool |
| <a name="output_synapse_sql_pool_id"></a> [synapse\_sql\_pool\_id](#output\_synapse\_sql\_pool\_id) | The ID of the Synapse SQL Pool |
| <a name="output_synapse_workspace_id"></a> [synapse\_workspace\_id](#output\_synapse\_workspace\_id) | The ID of the Synapse Workspace |
| <a name="output_synapse_workspace_name"></a> [synapse\_workspace\_name](#output\_synapse\_workspace\_name) | The name of the Synapse Workspace |
| <a name="output_synapse_workspace_principal_id"></a> [synapse\_workspace\_principal\_id](#output\_synapse\_workspace\_principal\_id) | The managed identity of the Synapse Workspace |
<!-- END_TF_DOCS -->
