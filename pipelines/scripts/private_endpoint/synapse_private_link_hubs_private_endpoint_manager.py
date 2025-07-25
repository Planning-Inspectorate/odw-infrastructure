from pipelines.scripts.private_endpoint.managed_private_endpoint_manager import ManagedPrivateEndpointManager
import requests
import json
import os

class SynapsePrivateLinkHubsPrivateEndpointManager(ManagedPrivateEndpointManager):
    """
        Class to interact with Synapse Private Link private endpoints

        Note: API/CLI support for this kind of endpoint is quite limited. Only getting endpoints is available
    """
    _token = None

    def __init__(self, private_link_name: str, subscription_id: str, resource_group_name: str):
        self.ENDPOINT = (
            f"https://management.azure.com/subscriptions/{subscription_id}/"
            f"resourceGroups/{resource_group_name}/providers/Microsoft.Synapse/privateLinkHubs/{private_link_name}/"
        )

    @classmethod
    def _get_token(cls) -> str:
        if not (cls._token):
            cls._token = json.loads(os.popen("az account get-access-token --output json").read())["accessToken"]
        return cls._token
    

    def get(self, private_endpoint_name: str):
        return requests.get(
            f"{self.ENDPOINT}/privateEndpointConnections/{private_endpoint_name}?api-version=2021-06-01",
            headers={'Authorization': f'Bearer {self._get_token()}'}
        ).json()
    
    def get_all(self):
        return requests.get(
            f"{self.ENDPOINT}/privateEndpointConnections?api-version=2021-06-01",
            headers={'Authorization': f'Bearer {self._get_token()}'}
        ).json()["value"]
