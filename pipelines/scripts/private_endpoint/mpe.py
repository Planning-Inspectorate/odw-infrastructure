from azure.identity import AzureCliCredential, ChainedTokenCredential, ManagedIdentityCredential
import requests


class MPE():
    credential = None
    _token = None

    def __init__(self, workspace_name: str):
        """
            :param workspace_name: The name of the Synapse workspace
        """
        self.workspace_name = workspace_name
        self.synapse_endpoint = f"https://{self.workspace_name}.dev.azuresynapse.net"

    @classmethod
    def _get_token(cls) -> str:
        if not (cls.credential and cls._token):
            cls.credential = ChainedTokenCredential(
                # ManagedIdentityCredential(),
                AzureCliCredential()
            )
            cls._token = cls.credential.get_token("https://dev.azuresynapse.net").token
        return cls._token
    
    def get(self, endpoint: str):
        api_call_headers = {'Authorization': 'Bearer ' + self._get_token()}
        endpoint = f"{self.synapse_endpoint}/managedVirtualNetworks/default/managedPrivateEndpoints/{endpoint}?api-version=2020-12-01"
        return requests.get(endpoint, headers=api_call_headers).json()
    
    def delete(self, endpoint: str):
        api_call_headers = {'Authorization': 'Bearer ' + self._get_token()}
        endpoint = f"{self.synapse_endpoint}/managedVirtualNetworks/default/managedPrivateEndpoints/{endpoint}?api-version=2020-12-01"
        resp: requests.Response = requests.delete(endpoint, headers=api_call_headers)
        print(resp)
        print(resp.text)
        return resp.json()

    def create(self, endpoint: str, ep_json):
        api_call_headers = {'Authorization': 'Bearer ' + self._get_token()}
        endpoint = f"{self.synapse_endpoint}/managedVirtualNetworks/default/managedPrivateEndpoints/{endpoint}?api-version=2020-12-01"
        resp: requests.Response = requests.put(endpoint, json=ep_json, headers=api_call_headers)
        return resp.json()

mpe = {
    "properties": {
        "privateLinkResourceId": "/subscriptions/12806449-ae7c-4754-b104-65bcdc7b28c8/resourceGroups/pins-rg-data-odw-build-uks/providers/Microsoft.Storage/storageAccounts/pinsstodwbuildukslu4d8k",
        "groupId": "dfs"
    }
}
print("running deletion code")
#import json
#eps = MPE("pins-synw-odw-build-uks").get("synapse-st-dfs--pinsstodwbuildukslu4d8k")
#print(json.dumps(eps, indent=4))
#print("got endpoint, posting now")
#resp = MPE("pins-synw-odw-build-uks").create("synapse-st-dfs--pinsstodwbuildukslu4d8k", mpe)
#print("finished post")
#print(json.dumps(resp, indent=4))