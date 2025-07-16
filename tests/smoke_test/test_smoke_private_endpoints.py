from pipelines.scripts.private_endpoint.private_endpoint_manager import PrivateEndpointManager
from pipelines.scripts.private_endpoint.storage_private_endpoint_manager import StoragePrivateEndpointManager
from pipelines.scripts.private_endpoint.synapse_private_endpoint_manager import SynapsePrivateEndpointManager
from pipelines.scripts.private_endpoint.synapse_private_link_hubs_private_endpoint_manager import SynapsePrivateLinkHubsPrivateEndpointManager
from pipelines.scripts.private_endpoint.key_vault_private_endpoint_manager import KeyVaultPrivateEndpointManager
from pipelines.scripts.private_endpoint.service_bus_private_endpoint_manager import ServiceBusPrivateEndpointManager
from pipelines.scripts.private_endpoint.sql_server_private_endpoint_manager import SSQLServerPrivateEndpointManager
from tests.util.conftest_util import ConftestUtil
from tests.util.config import TEST_CONFIG
from tests.util.test_case import TestCase
from typing import Type, List, Dict, Any
import traceback
import pytest
import json


class TestSmokePrivateEndpoints(TestCase):
    SUBSCRIPTION_ID = TEST_CONFIG["SUBSCRIPTION_ID"]
    ENV = TEST_CONFIG["ENV"].lower()
    DATA_LAKE_STORAGE = TEST_CONFIG["DATA_LAKE_STORAGE"]
    _ENDPOINT_CACHE = dict()

    def validate_private_endpoint(self, all_endpoints: List[Dict[str, Any]], endpoint_name: str):        
        relevant_private_endpoints = [
            x
            for x in all_endpoints
            if x.get("properties", dict()).get("privateEndpoint", dict()).get("id", "").endswith(endpoint_name)
        ]
        assert relevant_private_endpoints, f"Could not find any private endpoints ending with name '{endpoint_name}'"
        assert len(relevant_private_endpoints) == 1, f"Expected a single private endpoint with name ending with {endpoint_name}"
        provisioning_state = relevant_private_endpoints[0].get("properties", dict()).get("provisioningState", None)
        assert provisioning_state == "Succeeded", f"Expected private endpoint provisioning state to be 'Succeeded' but was '{provisioning_state}'"
        approval_state = relevant_private_endpoints[0].get("properties", dict()).get("privateLinkServiceConnectionState", dict()).get("status", None)
        assert approval_state == "Approved", f"Expected private endpoint approval state to be 'Approved' but was '{approval_state}'"

    def get_all_endpoints(
            self,
            private_endpoint_manager_class: Type[PrivateEndpointManager],
            resource_group_name: str,
            resource_name: str
    ) -> List[Dict[str, Any]]:
        """
            Return all private endpoints for the given manager, resource group, and resource combination.

            The result is cached to boost the performance of subsequent calls
        """
        exception_message = ""
        key = (private_endpoint_manager_class, resource_group_name, resource_name)
        if key not in self._ENDPOINT_CACHE:
            raised_exception = None
            try:
                self._ENDPOINT_CACHE[key] = private_endpoint_manager_class().get_all(resource_group_name, resource_name)
            except RuntimeError as e:
                raised_exception = e
                exception_message = (
                    f"Could not get the private endpoint in resource group '{resource_group_name}' for resource '{resource_name}'. "
                    f"The following exception was raised: {traceback.format_exc()}"
                )
            assert not raised_exception, exception_message
        return self._ENDPOINT_CACHE[key]

    @pytest.mark.skipif(ENV == "dev", reason="Dev environment does not have this private endpoint")
    def test_odt_backoffice_private_endpoints(self):
        all_endpoints = self.get_all_endpoints(
            ServiceBusPrivateEndpointManager,
            f"pins-rg-appeals-bo-{self.ENV}",
            f"pins-sb-appeals-bo-{self.ENV}"
        )
        self.validate_private_endpoint(all_endpoints, f"pins-pe-appeals-backoffice-sb-odw-{self.ENV}-uks")

    @pytest.mark.parametrize(
        "endpoint_name",
        [
            f"pins-pe-{DATA_LAKE_STORAGE}",
            f"pins-pe-syn-blob-tooling-odw-{ENV}-uks",
            f"pins-pe-syn-dfs-tooling-odw-{ENV}-uks",
            f"pins-pe-syn-file-tooling-odw-{ENV}-uks",
            f"pins-pe-syn-queue-tooling-odw-{ENV}-uks",
            f"pins-pe-syn-table-tooling-odw-{ENV}-uks",
            f"pins-pe-syn-web-tooling-odw-{ENV}-uks"
        ]
    )
    def test_odw_datalake_private_endpoints(self, endpoint_name: str):
        all_endpoints = self.get_all_endpoints(StoragePrivateEndpointManager, f"pins-rg-data-odw-{self.ENV}-uks", self.DATA_LAKE_STORAGE)
        self.validate_private_endpoint(all_endpoints, endpoint_name)
    
    @pytest.mark.parametrize(
        "endpoint_name",
        [
            f"pins-pe-pinskvsynwodw{ENV}uks",
            f"pins-pe-pinskvsynwodw{ENV}uks-tooling"
        ]
    )
    def test_odw_keyvault_private_endpoints(self, endpoint_name: str):
        all_endpoints = self.get_all_endpoints(KeyVaultPrivateEndpointManager, f"pins-rg-data-odw-{self.ENV}-uks", f"pinskvsynwodw{self.ENV}uks")
        self.validate_private_endpoint(all_endpoints, endpoint_name)

    @pytest.mark.parametrize(
        "endpoint_name",
        [
            f"pins-pe-pinskvmgmtodw{ENV}uks"
        ]
    )
    def test_management_keyvault_private_endpoints(self, endpoint_name: str):
        all_endpoints = self.get_all_endpoints(KeyVaultPrivateEndpointManager, f"pins-rg-datamgmt-odw-{self.ENV}-uks", f"pinskvmgmtodw{self.ENV}uks")
        self.validate_private_endpoint(all_endpoints, endpoint_name)

    @pytest.mark.parametrize(
        "endpoint_name",
        [
            f"pins-pe-syn-devops-odw-{ENV}-uks",
            f"pins-pe-syn-ssql-odw-{ENV}-uks",
            f"pins-pe-syn-devops-tooling-odw-{ENV}-uks",
        ]
    )
    def test_odw_synapse_private_endpoints(self, endpoint_name: str):
        all_endpoints = self.get_all_endpoints(SynapsePrivateEndpointManager, f"pins-rg-data-odw-{self.ENV}-uks", f"pins-synw-odw-{self.ENV}-uks")
        self.validate_private_endpoint(all_endpoints, endpoint_name)

    @pytest.mark.parametrize(
        "endpoint_name",
        [
            f"pins-pe-syn-ws-odw-{ENV}-uks",
            f"pins-pe-syn-ws-tooling-odw-{ENV}-uks"
        ]
    )
    def test_odw_synapse_private_endpoints(self, endpoint_name: str):
        all_endpoints = self.get_all_endpoints(
            SynapsePrivateLinkHubsPrivateEndpointManager,
            f"pins-rg-network-odw-{self.ENV}-uks",
            f"pinsplsynwsodw{self.ENV}uks"
        )
        self.validate_private_endpoint(all_endpoints, endpoint_name)
