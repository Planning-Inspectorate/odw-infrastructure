from tests.util.test_case import TestCase
from azure.servicebus.aio import ServiceBusClient
from azure.mgmt.servicebus import ServiceBusManagementClient
import azure.identity.aio as async_azure_identity
import azure.identity as sync_azure_identity
import asyncio
import os
import traceback
import pytest
from typing import List, Tuple


RELEVANT_SERVICE_BUS_MAP = {
    "BUILD": {"pins-sb-odw-"},
    "DEV": {"pins-sb-appeals-bo-", "pins-sb-odw-"},
    "TEST": {"pins-sb-appeals-bo-", "pins-sb-odw-"},
    "PROD": {"pins-sb-appeals-bo-", "pins-sb-odw-"},
}


def generate_test_case_tuple(
    management_client: ServiceBusManagementClient,
    service_bus_name: str,
    resource_group: str,
):
    """
    Extract the first topic that has a subscription from the service bus
    """
    topics = [
        x.name
        for x in management_client.topics.list_by_namespace(
            resource_group, service_bus_name
        )
    ]
    for topic in topics:
        subscriptions = list(
            management_client.subscriptions.list_by_topic(
                resource_group, service_bus_name, topic
            )
        )
        if subscriptions:
            return (service_bus_name, topic, subscriptions[0].name)
    return (service_bus_name, None, None)


def generate_test_cases() -> List[Tuple[str, str, str]]:
    """
    Generate a test case for each service bus that the ODW needs to connect to.
    Each test case has the form <service_bus_name, topic_name, subscription_name>.
    """
    env = os.environ.get("ENV", None)
    if not env:
        raise RuntimeError("Expected an 'ENV' environment variable is defined")
    relevant_service_buses = RELEVANT_SERVICE_BUS_MAP.get(env.upper(), None)
    if relevant_service_buses is None:
        raise RuntimeError(
            f"No relevant service buses defined for environment '{env}'. Please review this test"
        )
    odw_subscription_id = os.environ.get("SUBSCRIPTION_ID", None)
    if not odw_subscription_id:
        raise RuntimeError("No 'SUBSCRIPTION_ID' environment variable is defined")
    odt_subscription_id = os.environ.get("ODT_SUBSCRIPTION_ID", None)
    if not odt_subscription_id:
        raise RuntimeError("No 'ODT_SUBSCRIPTION_ID' environment variable is defined")
    credential = sync_azure_identity.ChainedTokenCredential(
        sync_azure_identity.ManagedIdentityCredential(),
        sync_azure_identity.AzureCliCredential(),
    )
    odw_mgmt_client = ServiceBusManagementClient(credential, odw_subscription_id)
    odt_mgmt_client = ServiceBusManagementClient(credential, odt_subscription_id)
    service_bus_namespaces = [x.id for x in odw_mgmt_client.namespaces.list()] + [
        x.id for x in odt_mgmt_client.namespaces.list()
    ]
    # Ensure only service buses that match RELEVANT_SERVICE_BUSES are included
    service_bus_namespaces = [
        x for x in service_bus_namespaces if any(y in x for y in relevant_service_buses)
    ]
    test_cases = []
    for service_bus_id in service_bus_namespaces:
        id_split = service_bus_id.split("/")
        resource_group = id_split[4]
        namespace = id_split[-1]
        mgmt_client = (
            odw_mgmt_client
            if odw_subscription_id in service_bus_id
            else odt_mgmt_client
        )
        test_case = generate_test_case_tuple(mgmt_client, namespace, resource_group)
        test_cases.append(test_case)
    mising_test_cases = [
        (x, ValueError(), ValueError())
        for x in relevant_service_buses
        if not any(x in y for y in service_bus_namespaces)
    ]
    return test_cases + mising_test_cases


class TestSmokeServiceBus(TestCase):
    async def _extract_service_bus_messages(
        self, service_bus_name: str, topic_name: str, subscription: str
    ):
        """
        Asynchronously peek messages from the service bus
        """
        # Note: The sync API/SDKs do not seem to work - this must be done asynchronously
        credential = async_azure_identity.ChainedTokenCredential(
            async_azure_identity.ManagedIdentityCredential(),
            async_azure_identity.AzureCliCredential(),
        )
        async with ServiceBusClient(
            fully_qualified_namespace=f"{service_bus_name}.servicebus.windows.net",
            credential=credential,
            logging_enable=True,
        ) as service_bus_client:
            try:
                # Get a Topic Sender object to send messages to the topic
                receiver = service_bus_client.get_subscription_receiver(
                    topic_name, subscription
                )
                async with receiver:
                    new_messages = await receiver.peek_messages(max_message_count=1)
                    all_messages = new_messages
                    while new_messages:
                        from_seq_num = new_messages[-1].sequence_number + 1
                        new_messages = await receiver.peek_messages(
                            max_message_count=100, sequence_number=from_seq_num
                        )
                        if new_messages:
                            all_messages.extend(new_messages)
                    return all_messages
                # Close credential when no longer needed.
            except Exception:
                raise
            finally:
                await credential.close()

    def check_service_bus(self, service_bus_name: str, topic: str, subscription: str):
        service_bus_exception = None
        try:
            asyncio.run(
                self._extract_service_bus_messages(
                    service_bus_name, topic, subscription
                )
            )
        except Exception as e:
            service_bus_exception = "".join(
                traceback.TracebackException.from_exception(e).format()
            )
        assert not service_bus_exception, (
            f"Failed to peek the service bus '{service_bus_name}' with topic '{topic}' and subscription '{subscription}': '{service_bus_exception}'"
        )

    @pytest.mark.parametrize(
        "service_bus_name,topic_name,subscription_name", generate_test_cases()
    )
    def test_service_bus_connection(
        self, service_bus_name, topic_name, subscription_name
    ):
        if not (topic_name or subscription_name):
            assert False, (
                f"No topics and subscriptions could be used to test connectivity for service bus '{service_bus_name}'"
            )
        if isinstance(topic_name, ValueError) or isinstance(
            subscription_name, ValueError
        ):
            assert False, (
                f"No servce bus could be found with name containing '{service_bus_name}', but this was expected to be found"
            )
        self.check_service_bus(service_bus_name, topic_name, subscription_name)
