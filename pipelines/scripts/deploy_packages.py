from odw_common.util.synapse_workspace_manager import SynapseWorkspaceManager
from odw_common.util.exceptions import ConcurrentWheelUploadException
from concurrent.futures import ThreadPoolExecutor
from pipelines.scripts.config import CONFIG
import argparse
from typing import List, Dict, Any, Set, Union
from datetime import datetime
import logging
import os


logging.basicConfig(level=logging.INFO)


class ODWPackageDeployer():
    """
    Class for managing the deployment of the ODW Python Package
    """
    SPARK_POOL_REQUIREMENTS_MAP = {
        "pinssynspodwpr": "requirements-preview.txt",
        "pinssynspodw34": "requirements.txt"
    }

    def __init__(self, workspace_manager: SynapseWorkspaceManager, env: str):
        self.workspace_manager = workspace_manager
        self.env = env

    def get_non_odw_workspace_packages(self) -> List[Dict[str, Any]]:
        """
        Return all workspace packages that are not the ODW package (this is managed by a different repository)
        """
        packages = self.workspace_manager.get_workspace_packages()
        odw_packages = [package for package in packages if not package["name"].startswith("odw")]
        return sorted(
            odw_packages,
            key=lambda package: datetime.strptime(package["properties"]["uploadedTimestamp"].replace("+00:00", "")[:-8], "%Y-%m-%dT%H:%M:%S")
        )
    
    def get_non_odw_spark_pool_custom_libraries(self, spark_pool: Dict[str, Any]) -> List[Dict[str, Any]]:
        """
        Return all custom liraries that are not for the odw package
        """
        custom_libraries = spark_pool["properties"].get("customLibraries", [])
        return [
            package
            for package in custom_libraries
            if not package["name"].startswith("odw")
        ]

    def get_local_workspace_packages(self) -> Set[str]:
        """
        Return the names of the packages that are defined in the local configuration
        """
        return set(os.listdir("infrastructure/configuration/workspace-packages"))

    def get_workspace_packages_to_add(self) -> Set[str]:
        """
        Identify packages that exist in the local configuration that do not exist in the live workspace
        """
        live_workspace = self.get_non_odw_workspace_packages()
        live_workspace_file_names = set(x["name"] for x in live_workspace)
        local_workspace_file_names = self.get_local_workspace_packages()
        return local_workspace_file_names.difference(live_workspace_file_names)

    def get_workspace_packages_to_remove(self):
        """
        Identify packages that exist in the live workspace that do not exist locally
        """
        live_workspace = self.get_non_odw_workspace_packages()
        live_workspace_file_names = set(x["name"] for x in live_workspace)
        local_workspace_file_names = self.get_local_workspace_packages()
        return live_workspace_file_names.difference(local_workspace_file_names)
    
    def get_spark_pool_packages_to_keep(self, spark_pool_packages: List[Dict[str, Any]]) -> List[str, Any]:
        """
        Return a list of custom libraries assigned to the spark pool that should be kept

        i.e. ODW Packages + any package that is also defined locally
        """
        odw_packages = [
            package
            for package in spark_pool_packages
            if package["name"].startswith("odw")
        ]
        non_odw_packages = [
            package
            for package in spark_pool_packages
            if not package["name"].startswith("odw")
        ]
        expected_packages = self.get_local_workspace_packages()
        non_odw_packages_to_keep = [
            package
            for package in non_odw_packages
            if package["name"] in expected_packages
        ]
        return odw_packages + non_odw_packages_to_keep
    
    def get_spark_pool_packages_to_add(self, spark_pool_packages: List[Dict[str, Any]]) -> List[str, Any]:
        """
        Generate a new list of packages that should be added from the local config to the live spark pool package list
        """
        package_names = {package["name"] for package in spark_pool_packages}
        expected_packages = self.get_local_workspace_packages()
        return [
            {
                "name": package,
                "path": f"pins-synw-odw-{self.env}-uks/libraries/{package}",
                "containerName": "prep",
                "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
                "type": "whl" if package.endswith("whl") else "jar"
            }
            for package in expected_packages
            if package in package_names
        ]

    def generate_new_spark_pool_json(self, spark_pool_name: str) -> Union[Dict[str, Any], None]:
        """
        Generate new json for the spark pool (i.e. add the requirements and packages as defined in the configuration)

        :param spark_pool_name: The name of the spark pool to generate the json for
        :return: The enriched json with updated packages and requirements, or `None` if there are no changes
        """
        spark_pool = self.workspace_manager.get_spark_pool(spark_pool_name)
        modified = False
        if self._is_spark_pool_requirements_modified(spark_pool_name, spark_pool):
            modified = True
            requirements_file_name = self.SPARK_POOL_REQUIREMENTS_MAP[spark_pool]
            with open(f"infrastructure/configuration/spark-pool/{requirements_file_name}", "r") as f:
                requirements_file_content = f.read()
            spark_pool["properties"]["libraryRequirements"] = {
                "filename": requirements_file_name,
                "content": requirements_file_content,
                "time": datetime.now().strftime("%Y-%m-%dT%H:%M:%S.%fZ")
            }
        if self._is_spark_pool_custom_libraries_modified(spark_pool):
            modified = True
            packages = spark_pool["properties"]["customLibraries"]
            new_packages = self.get_spark_pool_packages_to_keep(packages) + self.get_spark_pool_packages_to_add(packages)
            spark_pool["properties"]["customLibraries"] = new_packages
        if modified:
            return spark_pool
        return None

    def _is_spark_pool_requirements_modified(self, spark_pool_name: str, spark_pool: Dict[str, Any]) -> bool:
        """
        Return True if the `libraryRequirements` property of the given spark pool is different to the local configuration,
        False otherwise
        """
        if spark_pool_name not in self.SPARK_POOL_REQUIREMENTS_MAP:
            return False
        requirements_file_name = self.SPARK_POOL_REQUIREMENTS_MAP[spark_pool_name]
        with open(f"infrastructure/configuration/spark-pool/{requirements_file_name}", "r") as f:
            requirements_file_content = f.read()
        if "properties" not in spark_pool:
            raise ValueError(f"'properties' attribute is expected on the spark pool with name '{spark_pool}, but was missing")
        library_requirements = spark_pool.get().get("libraryRequirements", dict())
        expected_library_requirements = {
            "filename": requirements_file_name,
            "content": requirements_file_content
        }
        library_requirements_cleaned = {
            k: v
            for k, v in library_requirements.items()
            if k in expected_library_requirements
        }
        return library_requirements == library_requirements_cleaned

    def _is_spark_pool_custom_libraries_modified(self, spark_pool: Dict[str, Any]) -> bool:
        """
        Return True if the `customLibraries` property of the given spark pool is different to the local configuration,
        False otherwise
        """
        if "properties" not in spark_pool:
            raise ValueError(f"'properties' attribute is expected on the spark pool with name '{spark_pool}, but was missing")
        custom_libraries = self.get_non_odw_spark_pool_custom_libraries(spark_pool)
        custom_library_names = {
            package["name"]
            for package in custom_libraries
        }
        expected_custom_library_names = self.get_local_workspace_packages()
        assert custom_library_names == expected_custom_library_names

    def upload_requirements_file(self):
        """
            Update spark pool packages
        """
        # TODO use the above functions to upload new packages like TF does
        


workspace_name = f"pins-synw-odw-dev-uks"
subscription = CONFIG["SUBSCRIPTION_ID"]
resource_group = f"pins-rg-data-odw-dev-uks"
synapse_workspace_manager = SynapseWorkspaceManager(workspace_name, subscription, resource_group)
d = ODWPackageDeployer(synapse_workspace_manager)

pool = synapse_workspace_manager.get_spark_pool("pinssynspodwpr")
import json
print(json.dumps(pool, indent=4))
#if __name__ == "__main__":
#    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
#    parser.add_argument("-e", "--env", required=True, help="The environment to target")
#    parser.add_argument("-wn", "--new_wheel_name", required=True, help="The name of the new odw wheel to deploy")
#    args = parser.parse_args()
#    env = args.env
#    new_wheel_name = args.new_wheel_name
#    ODWPackageDeployer().upload_new_wheel(env, new_wheel_name)
