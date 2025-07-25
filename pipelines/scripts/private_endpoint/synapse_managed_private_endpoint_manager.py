from pipelines.scripts.private_endpoint.managed_private_endpoint_manager import ManagedPrivateEndpointManager
from azure.identity import AzureCliCredential, ChainedTokenCredential
from typing import Dict, List, Any
import requests


class SynapseManagedPrivateEndpointManager(ManagedPrivateEndpointManager):
    """
        Class for fetching managed private endpoints from synapse
    """
    credential = None
    _token = None

    def __init__(self, synapse_name: str):
        self.SYNAPSE_ENDPOINT = f"https://{synapse_name}.dev.azuresynapse.net"

    @classmethod
    def _get_token(cls) -> str:
        if not (cls.credential and cls._token):
            cls.credential = ChainedTokenCredential(
                # ManagedIdentityCredential(),
                AzureCliCredential()
            )
            cls._token = cls.credential.get_token("https://dev.azuresynapse.net").token
        return cls._token

    def get(self, private_endpoint_name: str) -> Dict[str, Any]:
        api_call_headers = {'Authorization': 'Bearer ' + self._get_token()}
        return requests.get(
            f"{self.SYNAPSE_ENDPOINT}/managedVirtualNetworks/default/managedPrivateEndpoints/{private_endpoint_name}?api-version=2020-12-01",
            headers=api_call_headers
        ).json()
    
    def get_all(self) -> List[Dict[str, Any]]:
        api_call_headers = {'Authorization': 'Bearer ' + self._get_token()}
        return requests.get(
            f"{self.SYNAPSE_ENDPOINT}/managedVirtualNetworks/default/managedPrivateEndpoints?api-version=2020-12-01",
            headers=api_call_headers
        ).json()["value"]
