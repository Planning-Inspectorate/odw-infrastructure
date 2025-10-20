from odw_common.util.synapse_workspace_manager import SynapseWorkspaceManager
from pipelines.scripts.config import CONFIG
import argparse
from typing import List, Dict, Any, Set, Union
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime
import logging
import os
import json


"""
Module for managing the packages deployed to a Synapse workspace, and binding to spark pools.
Note this does not affect the `ODW Package`, which is managed by the `odw-synapse-workspace` repository

Example usage

`python3 pipelines/scripts/deploy_packages.py -e dev -d`  # Which would deploy to the dev environment
`pipelines/scripts/deploy_packages.py -e dev`  # Which would only validate the config, instead of deploying to Synapse
"""

logging.basicConfig(level=logging.INFO)


class ODWPackageDeployer():
    """
    Class for managing the deployment of the ODW Python Package
    """
    SPARK_POOL_REQUIREMENTS_MAP = {
        "pinssynspodwpr": "requirements-preview.txt",
        "pinssynspodw34": "requirements-preview.txt"
    }
    """
    Map of spark pools to their associated requirements.txt files
    """

    def __init__(self, workspace_manager: SynapseWorkspaceManager, env: str):
        self.workspace_manager = workspace_manager
        self.env = env

    def get_non_odw_workspace_packages(self) -> List[Dict[str, Any]]:
        """
        Return all workspace packages that are not the ODW package (this is managed by a different repository)
        """
        packages = self.workspace_manager.get_workspace_packages()
        return [package for package in packages if not package["name"].startswith("odw")]
    
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
        allowed_extensions = ["whl", "jar"]
        return set(
            x
            for x in os.listdir("infrastructure/configuration/workspace-packages")
            if any(x.endswith(y) for y in allowed_extensions)
        )

    def get_workspace_packages_to_add(self) -> Set[str]:
        """
        Identify packages that exist in the local configuration that do not exist in the live workspace
        """
        live_workspace = self.get_non_odw_workspace_packages()
        live_workspace_file_names = set(x["name"] for x in live_workspace)
        local_workspace_file_names = self.get_local_workspace_packages()
        return local_workspace_file_names.difference(live_workspace_file_names)

    def get_workspace_packages_to_remove(self) -> Set[str]:
        """
        Identify packages that exist in the live workspace that do not exist locally
        """
        live_workspace = self.get_non_odw_workspace_packages()
        live_workspace_file_names = set(x["name"] for x in live_workspace)
        local_workspace_file_names = self.get_local_workspace_packages()
        return live_workspace_file_names.difference(local_workspace_file_names)
    
    def get_spark_pool_packages_to_keep(self, spark_pool_packages: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
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
    
    def get_spark_pool_packages_to_add(self, spark_pool_packages: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
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
            if package not in package_names
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
            requirements_file_name = self.SPARK_POOL_REQUIREMENTS_MAP[spark_pool_name]
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
        library_requirements = spark_pool.get("properties").get("libraryRequirements", dict())
        expected_library_requirements = {
            "filename": requirements_file_name,
            "content": requirements_file_content
        }
        library_requirements_cleaned = {
            k: v
            for k, v in library_requirements.items()
            if k in expected_library_requirements
        }
        library_requirements_cleaned["content"] = library_requirements_cleaned["content"].replace("\r", "")
        return expected_library_requirements != library_requirements_cleaned

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
        return custom_library_names != expected_custom_library_names

    def update_packages(self, deploy: bool):
        """
            Update spark pool packages

            1. Add new packages (.whl and .jar files) to the workspace
            2. Update package and requirements.txt assignments to the spark pools
            3. Remove packages no longer referenced by the local config
        """
        logging.info("Applying package settings as defined in 'infrastructure/configuration/'")
        # Preprocessing
        workspace_packages_to_add = self.get_workspace_packages_to_add()
        workspace_packages_to_remove = self.get_workspace_packages_to_remove()
        new_spark_pool_map = dict()
        for spark_pool_name in self.SPARK_POOL_REQUIREMENTS_MAP.keys():
            new_spark_pool_json = self.generate_new_spark_pool_json(spark_pool_name)
            if new_spark_pool_json:
                new_spark_pool_map[spark_pool_name] = new_spark_pool_json
        logging.info(f"The following packages will be added to the workspace: {json.dumps(list(workspace_packages_to_add), indent=4)}")
        logging.info(f"The following packages will be removed from the workspace: {json.dumps(list(workspace_packages_to_remove), indent=4)}")
        logging.info(f"The following spark pools will be updated: {json.dumps(new_spark_pool_map, indent=4)}")
        if deploy:
            # Add new packages to the workspace
            for package in workspace_packages_to_add:
                logging.info(f"Uploading package '{package}' to the workspace")
                self.workspace_manager.upload_workspace_package(f"infrastructure/configuration/workspace-packages/{package}")
            # Update spark pools. Note this is a very slow operation, so it is done in parallel for all pools
            with ThreadPoolExecutor() as tpe:
                # Update all relevant spark pools in parallel to boost performance
                [
                    thread_response
                    for thread_response in tpe.map(
                        self.workspace_manager.update_spark_pool,
                        new_spark_pool_map.keys(),
                        new_spark_pool_map.values()
                    )
                    if thread_response
                ]
            # Remove workspace packages that are not defined in the configuration
            for package in workspace_packages_to_remove:
                self.workspace_manager.remove_workspace_package(package)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-e", "--env", required=True, help="The environment to target")
    parser.add_argument("-d", "--deploy", action=argparse.BooleanOptionalAction, default=False)
    args = parser.parse_args()
    env = args.env
    deploy = args.deploy
    workspace_name = f"pins-synw-odw-{env}-uks"
    subscription = CONFIG["SUBSCRIPTION_ID"]
    resource_group = f"pins-rg-data-odw-{env}-uks"
    synapse_workspace_manager = SynapseWorkspaceManager(workspace_name, subscription, resource_group)
    package_deployer = ODWPackageDeployer(synapse_workspace_manager, env)
    package_deployer.update_packages(deploy)
