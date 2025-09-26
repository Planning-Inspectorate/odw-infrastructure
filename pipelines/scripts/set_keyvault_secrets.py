from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from dotenv import load_dotenv
import argparse
import os


load_dotenv(verbose=True, override=True)

SECRET_ENV_VAR_MAP = {
    "app-insights-instrumentation-key": ""
}


class KeyVaultManager():
    def __init__(self, key_vault_name: str):
        credential = DefaultAzureCredential()
        self.secret_client = SecretClient(vault_url=f"https://{key_vault_name}.vault.azure.net/", credential=credential)

    def set_secret(self, secret_name: str, secret_value: str) -> None:
        self.secret_client.set_secret(secret_name, secret_value)
        return print(f"{secret_name} created")


def get_env_variable(variable_name: str) -> str:
    if variable_name in os.environ:
        return os.environ.get(variable_name)
    raise ValueError(f"Could not find value for environment variable '{variable_name}'")


def initialise_secrets(vault_name: str):
    secret_values = {
        k: get_env_variable(v)
        for k, v in SECRET_ENV_VAR_MAP.items()
    }
    key_vault_manager = KeyVaultManager(vault_name)
    for secret_name, secret_value in secret_values:
        key_vault_manager.set_secret(secret_name, secret_value)


if __name__ == "__main__":
    # Load command line arguments
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-kvn", "--key_vault_name", help="The keyvault to set the secrets for", required=True)
    args = parser.parse_args()
    key_vault_name = args.key_vault_name
    initialise_secrets(key_vault_name)
