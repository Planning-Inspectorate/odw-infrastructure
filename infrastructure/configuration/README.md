# Configuration Files
The configuration files in this folder are used by the Terraform root module for deploying ODW infrastructure. Please see below details before updating any configuration files.

## Data Lifecycle
The `data-lifecycle` directory contains a `policies.json` file which describes the data lifecycle policies that should be applied to the Data Lake Storage Account. The policy file is formatted as a a list of JSON objects, for example:
```bash
[
  {
    "rule_name" : "example_rule",
    "prefix_match" : [
      "container1/folder1",
      "container1/folder2",
      "container2/folder1"
    ],
    "blob" : {
      "cool_tier_since_modified_days" : 30,
      "archive_tier_since_modified_days" : 60,
      "delete_since_modified_days" : 90
    },
    "snapshot" : {
      "cool_tier_since_created_days" : 30,
      "archive_tier_since_created_days" : 60,
      "delete_since_created_days" : 90
    },
    "version" : {
      "cool_tier_since_created_days" : 30,
      "archive_tier_since_created_days" : 60,
      "delete_since_created_days" : 90
    }
  }
]
```

For each of the `blob`, `snapshot`, and `version` sub-objects, attributes are optional. If any attribute is omitted from the policy then the action will not be performed. For example, omitting `archive_tier_since_modified_days` will mean that the respective data type will not be archieved but would be moved to cool storage and eventually deleted.

## Firewall Rules
The `allowed_ip_addresses.yaml` file in this directory is a placeholder file. IP addresses are subject to GDPR restrictions and as such this file should **not** be updated here to include any IP addresses. To update the list of allowed IP addresses, navigate to the [ODW Azure DevOps project](https://dev.azure.com/planninginspectorate/operational-data-warehouse/_library?itemType=SecureFiles) and upload a new secure file with the following format (a YAML list containing a list of IP addresses or ranges with comments):

```yaml
- "192.168.10.10"     # Single addresses should not have a prefix
- "192.168.10.0/24"   # Ranges of addresses require a CIDR prefix
```

More information can also be found in the onboarding guide in Confluence here - [Onboarding engineers](https://pins-ds.atlassian.net/wiki/spaces/ODTDO/pages/1369899009/Onboarding+Data+Engineers+-+Groups+Permissions+and+adding+an+IP+to+the+Firewall)  

This file here remains empty and is overwritten by a pipeline task which downloads the secure file from the Azure DevOps library and overwrites this before being applied in further tasks.

## Spark Pool
The `spark-requirements.txt` file in this directory is used as an input for the Synapse Workspace and defines which Python packages (and optionally, their version) should be installed and made available for use within the Spark pool environment. The format for this file is outlined below:

```bash
# Package with a specified version:
<packageName>==<versionNumber>
# Package with no specified version (latest):
<packageName>
```
