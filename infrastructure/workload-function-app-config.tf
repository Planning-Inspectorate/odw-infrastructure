locals {
  function_app = [
    {
      name = "fnapp01"
      connection_strings = [
        {
          name  = "SqlConnectionString",
          type  = "SQLAzure",
          value = "Server=tcp:pins-synw-odw-${var.environment}-uks-ondemand.sql.azuresynapse.net,1433;Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Database=odw_curated_db;Authentication=Active Directory Managed Identity;"
        },
        {
          name  = "SqlConnectionString2",
          type  = "SQLAzure",
          value = "Server=tcp:pins-synw-odw-${var.environment}-uks-ondemand.sql.azuresynapse.net,1433;Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Database=odw_harmonised_db;Authentication=Active Directory Managed Identity;"
        }

      ]
      site_config = {
        application_stack = {
          python_version = "3.11"
        }
      }
    }
  ]
  message_storage_account = substr(module.synapse_data_lake.data_lake_blob_endpoint, 0, length(module.synapse_data_lake.data_lake_blob_endpoint) - 1)
}