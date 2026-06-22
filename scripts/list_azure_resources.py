import os
import json
from typing import List, Dict, Any, Tuple


SUBSCRIPTION = "FILL IN"


def cli_command(command: str):
    result = os.popen(command).read()
    exception = None
    try:
        return json.loads(result)
    except Exception as e:
        print(f"Exception raised when running command '{command}'")
        exception = e
    raise exception


def extract_ids(resources: List[Dict[str, Any]]) -> List[str]:
    for elem in resources:
        if not isinstance(elem, dict):
            raise ValueError(f"Not a dictionary: {json.dumps(elem, indent=4)}")
        if "id" not in elem:
            raise ValueError(
                f"'id' attribute could not be found in {json.dumps(elem, indent=4)}"
            )
    return [x["id"] for x in resources]


def no_ids(resources: List[Dict[str, Any]]):
    return [x for x in resources if "id" not in x]


def get_resource_groups(subscription_id: str):
    return cli_command(f"az group list --subscription {subscription_id}")


def get_resources(resource_group: str):
    return cli_command(f"az resource list --resource-group {resource_group}")


def get_all_resources_for_subscription(
    subscription_id: str, rg_name_starts_with_filter: str
) -> List[Tuple[str, str]]:
    # type
    resource_group_ids = [
        x
        for x in extract_ids(get_resource_groups(subscription_id))
        if x.startswith(rg_name_starts_with_filter)
    ]
    resource_group_names = [r_id.split("/")[-1] for r_id in resource_group_ids]
    return [
        (r_id["type"], r_id["id"])
        for r_name in resource_group_names
        for r_id in get_resources(r_name)
    ]


def load_tf_objects():
    with open("tfobjects.txt", "r") as f:
        lines = f.readlines()
    cleaned_lines = []
    for line in lines:
        if "[id=" in line:
            id = line.split("[id=")[-1].replace("]", "").rstrip()
            if "azurerm" in line:
                is_data_reference = "data." in line
                cleaned_lines.append((is_data_reference, id))
    return cleaned_lines


def identify_missing_resources(
    azure_resources: List[str], tf_resources: List[Tuple[bool, str]], subscription: str
):
    resource_type_map = {
        resource[1].lower(): resource[0] for resource in azure_resources
    }
    azure_resources_ids = [x[1] for x in azure_resources]
    azure_resources_set = set([x.lower() for x in azure_resources_ids])
    tf_resources_lower = [(x[0], x[1].lower()) for x in tf_resources]
    tf_data_resources = [x[1] for x in tf_resources_lower if x[0]]
    tf_provisioned_resources = [x[1] for x in tf_resources_lower if not x[0]]
    tf_provisioned_resources_set = set(tf_provisioned_resources)
    azure_resources_missing_from_tf = azure_resources_set.difference(
        tf_provisioned_resources_set
    )
    return (
        [
            (resource_id, resource_type_map[resource_id])
            for resource_id in sorted(list(azure_resources_missing_from_tf))
        ],
        [
            (resource_id, resource_type_map.get(resource_id, "NOT FOUND"))
            for resource_id in sorted(tf_data_resources)
        ],
    )


def filter_out_irrelevant_resource_types(resources: List[Tuple[str, str]]):
    irrelevant_types = {
        "Microsoft.Network/networkInterfaces",
        "Microsoft.Compute/virtualMachines/extensions",
    }
    return [x for x in resources if x[1] not in irrelevant_types]


def get_role_asignments(resource_id: str) -> List[str]:
    return cli_command(f'az role assignment list --scope "{resource_id}"')


def get_sb_queues(namespace: str, rg: str) -> List[str]:
    return cli_command(
        f"az servicebus queue list --namespace-name {namespace} --resource-group {rg}"
    )


def get_sb_topics(namespace: str, rg: str) -> List[str]:
    return cli_command(
        f"az servicebus topic list --namespace-name {namespace} --resource-group {rg}"
    )


def get_sb_topic_subscriptions(namespace: str, rg: str, topic: str):
    return cli_command(
        f"az servicebus topic subscription list --namespace-name {namespace} --resource-group {rg} --topic-name {topic}"
    )


def get_sb_subresources(resource_id: str) -> List[str]:
    namespace_name = resource_id.split("Microsoft.ServiceBus/namespaces/")[-1].split(
        "/providers"
    )[0]
    rg = resource_id.split("resourceGroups/")[-1].split("/providers/")[0]
    queues = get_sb_queues(namespace_name, rg)
    topic = get_sb_topics(namespace_name, rg)
    topic_subscriptions = [
        subscription
        for topic in topic
        for subscription in get_sb_topic_subscriptions(
            namespace_name, rg, topic["name"]
        )
    ]
    return queues + topic + topic_subscriptions


def get_kv_subresources(resource_id: str) -> List[str]:
    vault_name = resource_id.split("Microsoft.KeyVault/vaults/")[-1].split(
        "/providers"
    )[0]
    return cli_command(f"az keyvault secret list --vault-name {vault_name}")


def get_sa_subresources(resource_id: str) -> List[str]:
    storage_name = resource_id.split("Microsoft.Storage/storageAccounts/")[-1].split(
        "/providers"
    )[0]
    containers = cli_command(
        f"az storage container-rm list --storage-account {storage_name}"
    )
    return containers


def expand_resource(resource_id: str, resource_type: str) -> list[str]:
    if "odw" in resource_id:
        role_assignments = get_role_asignments(resource_id)
        role_assignment_ids = extract_ids(role_assignments)
        role_assignment_ids = [
            (resource["type"], resource["id"]) for resource in role_assignments
        ]
        type_map = {
            "Microsoft.ServiceBus/namespaces": get_sb_subresources,
            "Microsoft.KeyVault/vaults": get_kv_subresources,
            "Microsoft.Storage/storageAccounts": get_sa_subresources,
        }
        extra_resource_ids = []
        if resource_type in type_map:
            extra_resources = type_map[resource_type](resource_id)
            extra_resource_ids = [
                (resource.get("type", "UNKNOWN"), resource["id"])
                for resource in extra_resources
            ]
        return role_assignment_ids + extra_resource_ids
    return []


def expand_all_resources(
    azure_resources: List[Tuple[str, str]],
) -> List[Tuple[str, str]]:
    expanded_resources = [
        subresource
        for resource in azure_resources
        for subresource in expand_resource(resource[1], resource[0])
    ]
    print(f"total expanded_resources: {len(expanded_resources)}")
    return azure_resources + expanded_resources


azure_resources = get_all_resources_for_subscription(
    SUBSCRIPTION, f"/subscriptions/{SUBSCRIPTION}/resourceGroups/pins-rg"
)
azure_resources = expand_all_resources(azure_resources)
# unique_resource_types = list(set([x[0] for x in azure_resources]))

tf_resources = load_tf_objects()


missing, potential_extra = identify_missing_resources(
    azure_resources, tf_resources, SUBSCRIPTION
)
missing = filter_out_irrelevant_resource_types(missing)
potential_extra = filter_out_irrelevant_resource_types(potential_extra)
print("The below resources are defined in Azure but are not managed by Terraform")
print(json.dumps(missing, indent=4))
print()
print(
    "The below resources are managed by data blocks in Terraform, please review these"
)
print(json.dumps(potential_extra, indent=4))
