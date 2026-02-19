from tests.util.test_case import TestCase
from azure.servicebus.aio import ServiceBusClient
from azure.identity.aio import (
    AzureCliCredential,
    ManagedIdentityCredential,
    ChainedTokenCredential,
)
import asyncio
import os
import traceback


class TestSmokeServiceBus(TestCase):
    async def _extract_service_bus_messages(self, topic_name: str, subscription: str):
        """
        Asynchronously receive messages from the service bus
        """
        # Note: The sync API/SDKs do not seem to work - this must be done asynchronously
        service_bus_name = os.environ.get("SERVICE_BUS_NAME", None)
        if not service_bus_name:
            raise RuntimeError("No 'SERVICE_BUS_NAME' environment variable is defined")
        credential = ChainedTokenCredential(
            ManagedIdentityCredential(), AzureCliCredential()
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
                    new_messages = await receiver.peek_messages(max_message_count=500)
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

    def check_service_bus(self, topic: str, subscription: str):
        service_bus_exception = None
        try:
            asyncio.run(self._extract_service_bus_messages(topic, subscription))
        except Exception as e:
            service_bus_exception = "".join(
                traceback.TracebackException.from_exception(e).format()
            )
        assert not service_bus_exception, (
            f"Service bus peek failed with the following exception: '{service_bus_exception}'"
        )

    def test_service_bus_connection(self):
        self.check_service_bus("nsip-document", "odw-nsip-document-sub")
