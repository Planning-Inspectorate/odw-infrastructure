from odw_common.util.synapse_workspace_manager import SynapseWorkspaceManager
from pipelines.scripts.deploy_packages import ODWPackageDeployer
import mock


def create_odw_package_deployer():
    """
    Create an instance of the ODWPackageDeployer
    """
    with mock.patch.object(SynapseWorkspaceManager, "__init__", return_value=None):
        mock_workspace_manager = SynapseWorkspaceManager("", "", "")
        return ODWPackageDeployer(mock_workspace_manager, "mock_env")


def test__odw_package_deployer__get_non_odw_workspace_packages():
    """
    Test that a list of workspace packages can be filtered to include only the non-odw packages
    """
    package_deployer = create_odw_package_deployer()
    mock_packages = [
        {
            "id": "some/path/to/some_package.jar",
            "name": "some_package.jar",
            "type": "Microsoft.Synapse/workspaces/libraries",
            "properties": {}
        },
        {
            "id": "some/path/to/odw_some_package.jar",
            "name": "odw_some_package.jar",
            "type": "Microsoft.Synapse/workspaces/libraries",
            "properties": {}
        },
        {
            "id": "some/path/to/some_other_package.jar",
            "name": "some_other_package.jar",
            "type": "Microsoft.Synapse/workspaces/libraries",
            "properties": {}
        }
    ]
    expected_non_odw_packages = [mock_packages[0], mock_packages[2]]
    with mock.patch.object(SynapseWorkspaceManager, "get_workspace_packages", return_value=mock_packages):
        actual_non_odw_packages = package_deployer.get_non_odw_workspace_packages()
        assert actual_non_odw_packages == expected_non_odw_packages


def test__odw_package_deployer__get_non_odw_spark_pool_custom_libraries():
    """
    Test that a list of spark pool custom libraries can be filtered to contain only the non-odw packages
    """
    mock_custom_libraries = [
        {
            "name": "odw-package.whl",
            "path": "some/path/to/odw-package.whl",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "whl"
        },
        {
            "name": "other-package.whl",
            "path": "some/path/to/other-package.whl",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "whl"
        },
        {
            "name": "another-package.jar",
            "path": "some/path/to/another-package.jar",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "jar"
        }
    ]
    expected_packages = [mock_custom_libraries[1], mock_custom_libraries[2]]
    mock_pool = {
        "properties": {
            "customLibraries": mock_custom_libraries
        }
    }
    package_deployer = create_odw_package_deployer()
    actual_packages = package_deployer.get_non_odw_spark_pool_custom_libraries(mock_pool)
    assert actual_packages == expected_packages


def test__odw_package_deployer__get_local_workspace_packages():
    """
    Test that only the package names are returned under `infrastructure/configuration/workspace-packages`
    """
    package_deployer = create_odw_package_deployer()
    local_packages = package_deployer.get_local_workspace_packages()
    for package in local_packages:
        assert not package.startswith("infrastructure/configuration/workspace-packages")


def test__odw_package_deployer__get_workspace_packages_to_add():
    """
    Given a workspace holds `some_package.jar` and `some_other_package.jar`
    When I have `some_package.jar` and `a_package_to_add.jar` defined locally
    Then `a_package_to_add.jar` should be identified as a new package to add to the workspace packages
    """
    mock_workspace_packages = [
        {
            "id": "some/path/to/some_package.jar",
            "name": "some_package.jar",
            "type": "Microsoft.Synapse/workspaces/libraries",
            "properties": {}
        },
        {
            "id": "some/path/to/some_other_package.jar",
            "name": "some_other_package.jar",
            "type": "Microsoft.Synapse/workspaces/libraries",
            "properties": {}
        }
    ]
    mock_local_package_names = {
        "some_package.jar",
        "a_package_to_add.jar"
    }
    package_deployer = create_odw_package_deployer()
    expected_return_value = {"a_package_to_add.jar"}
    with mock.patch.object(ODWPackageDeployer, "get_non_odw_workspace_packages", return_value=mock_workspace_packages):
        with mock.patch.object(ODWPackageDeployer, "get_local_workspace_packages", return_value=mock_local_package_names):
            actual_return_value = package_deployer.get_workspace_packages_to_add()
            assert actual_return_value == expected_return_value


def test__odw_package_deployer__get_workspace_packages_to_remove():
    """
    Given a workspace holds `some_package.jar` and `some_other_package.jar`
    When I have `some_package.jar` and `a_package_to_add.jar` defined locally
    Then `some_other_package.jar` should be identified as a package to remove
    """
    mock_workspace_packages = [
        {
            "id": "some/path/to/some_package.jar",
            "name": "some_package.jar",
            "type": "Microsoft.Synapse/workspaces/libraries",
            "properties": {}
        },
        {
            "id": "some/path/to/some_other_package.jar",
            "name": "some_other_package.jar",
            "type": "Microsoft.Synapse/workspaces/libraries",
            "properties": {}
        }
    ]
    mock_local_package_names = {
        "some_package.jar",
        "a_package_to_add.jar"
    }
    package_deployer = create_odw_package_deployer()
    expected_return_value = {"some_other_package.jar"}
    with mock.patch.object(ODWPackageDeployer, "get_non_odw_workspace_packages", return_value=mock_workspace_packages):
        with mock.patch.object(ODWPackageDeployer, "get_local_workspace_packages", return_value=mock_local_package_names):
            actual_return_value = package_deployer.get_workspace_packages_to_remove()
            assert actual_return_value == expected_return_value


def test__odw_package_deployer__get_spark_pool_packages_to_keep():
    """
    Given a spark pool with custom libraries `odw-package.whl`, `other-package.whl` and `another-package.jar`
    When the local config contains `other-package.whl`
    Then the packages to keep should be `odw-package.whl` and `other-package.whl`
    """
    mock_custom_libraries = [
        {
            "name": "odw-package.whl",
            "path": "some/path/to/odw-package.whl",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "whl"
        },
        {
            "name": "other-package.whl",
            "path": "some/path/to/other-package.whl",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "whl"
        },
        {
            "name": "another-package.jar",
            "path": "some/path/to/another-package.jar",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "jar"
        }
    ]
    expected_packages_to_keep = [mock_custom_libraries[0], mock_custom_libraries[1]]
    mock_local_packages = {"other-package.whl"}
    package_deployer = create_odw_package_deployer()
    with mock.patch.object(ODWPackageDeployer, "get_local_workspace_packages", return_value=mock_local_packages):
        actual_packages_to_keep = package_deployer.get_spark_pool_packages_to_keep(mock_custom_libraries)
        assert actual_packages_to_keep == expected_packages_to_keep


def test__odw_package_deployer__get_spark_pool_packages_to_add():
    """
    Given a spark pool has packages `other-package/whl` and `another-package.jar`
    When we have new packages `new-python-package.whl` and `new-java-package.jar` configured locally
    Then both new packages should be identified to be added to the spark pool
    """
    mock_custom_libraries = [
        {
            "name": "other-package.whl",
            "path": "some/path/to/other-package.whl",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "whl"
        },
        {
            "name": "another-package.jar",
            "path": "some/path/to/another-package.jar",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "jar"
        }
    ]
    expected_return_value = [
        {
            "name": "new-python-package.whl",
            "path": f"pins-synw-odw-mock_env-uks/libraries/new-python-package.whl",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "whl"
        },
        {
            "name": "new-java-package.jar",
            "path": f"pins-synw-odw-mock_env-uks/libraries/new-java-package.jar",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "jar"
        }
    ]
    mock_local_packages = {"new-python-package.whl", "new-java-package.jar"}
    package_deployer = create_odw_package_deployer()
    with mock.patch.object(ODWPackageDeployer, "get_local_workspace_packages", return_value=mock_local_packages):
        actual_return_value = package_deployer.get_spark_pool_packages_to_add(mock_custom_libraries)
        actual_return_value = sorted(actual_return_value, key=lambda package: package["name"])
        expected_return_value = sorted(expected_return_value, key=lambda package: package["name"])
        assert actual_return_value == expected_return_value


def test__odw_package_deployer__generate_new_spark_pool_json__no_modifications():
    """
    Given a spark pool json
    When there are no modifications detected
    Them generate_new_spark_pool_json should return None
    """
    package_deployer = create_odw_package_deployer()
    mock_spark_pool = {"name": "mock_spark_pool"}
    with mock.patch.object(SynapseWorkspaceManager, "get_spark_pool", return_value=mock_spark_pool):
        with mock.patch.object(ODWPackageDeployer, "_is_spark_pool_requirements_modified", return_value=False):
            with mock.patch.object(ODWPackageDeployer, "_is_spark_pool_custom_libraries_modified", return_value=False):
                assert package_deployer.generate_new_spark_pool_json("mock_spark_pool") is None


def test__odw_package_deployer__generate_new_spark_pool_json__with_modified_requirements():
    """
    Given a spark pool with a set requirements file
    When new requirements content is provided
    Then the spark pool should be modified to contain the new content
    """
    package_deployer = create_odw_package_deployer()
    mock_spark_pool = {
        "name": "test_spark_pool",
        "properties": {
            "libraryRequirements": {
                "filename": "old_requirements_file.txt",
                "content": "old_content",
                "time": ""
            }
        }
    }
    expected_return_value = {
        "name": "test_spark_pool",
        "properties": {
            "libraryRequirements": {
                "filename": "test_requirements_file.txt",
                "content": "mock_content",
                "time": None
            }
        }
    }
    mock_requirements_content = "mock_content"
    mock_requirements_map = {
        "test_spark_pool": "test_requirements_file.txt"
    }
    with mock.patch.object(SynapseWorkspaceManager, "get_spark_pool", return_value=mock_spark_pool):
        with mock.patch.object(ODWPackageDeployer, "_is_spark_pool_requirements_modified", return_value=True):
            with mock.patch.object(ODWPackageDeployer, "_is_spark_pool_custom_libraries_modified", return_value=False):
                with mock.patch("builtins.open", mock.mock_open(read_data=mock_requirements_content)):
                    with mock.patch(
                        "pipelines.scripts.deploy_packages.ODWPackageDeployer.SPARK_POOL_REQUIREMENTS_MAP",
                        mock_requirements_map
                    ):
                        actual_return_value = package_deployer.generate_new_spark_pool_json("test_spark_pool")
                        # Cannot compare dates, because we cannot mock datetime which is immutable
                        reqs = actual_return_value.get("properties", dict()).get("libraryRequirements", dict())
                        if "time" in reqs:
                            reqs["time"] = None
                        assert actual_return_value == expected_return_value


def test__odw_package_deployer__generate_new_spark_pool_json__with_modified_libraries():
    """
    Given a spark pool with set custom libraries
    When new packages are provided
    Then the spark pool libraries should be updated with the new packages
    """
    package_deployer = create_odw_package_deployer()
    mock_custom_libraries = [
        {
            "name": "odw-package.whl",
            "path": "some/path/to/odw-package.whl",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "whl"
        },
        {
            "name": "other-package.whl",
            "path": "some/path/to/other-package.whl",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "whl"
        },
        {
            "name": "another-package.jar",
            "path": "some/path/to/another-package.jar",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "jar"
        }
    ]
    mock_spark_pool = {
        "name": "test_spark_pool",
        "properties": {
            "customLibraries": mock_custom_libraries
        }
    }
    mock_libraries_to_keep = ["a"]
    mock_packages_to_add = ["b", "c"]
    expected_return_value = {
        "name": "test_spark_pool",
        "properties": {
            "customLibraries": mock_libraries_to_keep + mock_packages_to_add
        }
    }
    with mock.patch.object(SynapseWorkspaceManager, "get_spark_pool", return_value=mock_spark_pool):
        with mock.patch.object(ODWPackageDeployer, "_is_spark_pool_requirements_modified", return_value=False):
            with mock.patch.object(ODWPackageDeployer, "_is_spark_pool_custom_libraries_modified", return_value=True):
                with mock.patch.object(ODWPackageDeployer, "get_spark_pool_packages_to_keep", return_value=mock_libraries_to_keep):
                    with mock.patch.object(ODWPackageDeployer, "get_spark_pool_packages_to_add", return_value=mock_packages_to_add):
                        actual_return_value = package_deployer.generate_new_spark_pool_json("mock_spark_pool")
                        assert actual_return_value == expected_return_value


def test__odw_package_deployer__is_spark_pool_requirements_modified__modified():
    """
    Given a spark pool
    When the local configuration's requirements file content does not match the spark pool'
    Then the spark pool is marked as modified. (Returns True)
    """
    package_deployer = create_odw_package_deployer()
    mock_spark_pool = {
        "name": "test_spark_pool",
        "properties": {
            "libraryRequirements": {
                "filename": "requirements_file.txt",
                "content": "old_content",
                "time": ""
            }
        }
    }
    mock_requirements_content = "new_content"
    mock_requirements_map = {"test_spark_pool": "requirements_file.txt"}
    with mock.patch.object(SynapseWorkspaceManager, "get_spark_pool", return_value=mock_spark_pool):
        with mock.patch("builtins.open", mock.mock_open(read_data=mock_requirements_content)):
            with mock.patch(
                "pipelines.scripts.deploy_packages.ODWPackageDeployer.SPARK_POOL_REQUIREMENTS_MAP",
                mock_requirements_map
            ):
                assert package_deployer._is_spark_pool_requirements_modified("test_spark_pool", mock_spark_pool)


def test__odw_package_deployer__is_spark_pool_requirements_modified__unmodified():
    """
    Given a spark pool
    When the local configuration's requirements file content matches the spark pool'
    Then the spark pool is marked as unmodified. (Returns False)
    """
    package_deployer = create_odw_package_deployer()
    mock_spark_pool = {
        "name": "test_spark_pool",
        "properties": {
            "libraryRequirements": {
                "filename": "requirements_file.txt",
                "content": "old_content",
                "time": ""
            }
        }
    }
    mock_requirements_content = "old_content"
    mock_requirements_map = {"test_spark_pool": "requirements_file.txt"}
    with mock.patch.object(SynapseWorkspaceManager, "get_spark_pool", return_value=mock_spark_pool):
        with mock.patch("builtins.open", mock.mock_open(read_data=mock_requirements_content)):
            with mock.patch(
                "pipelines.scripts.deploy_packages.ODWPackageDeployer.SPARK_POOL_REQUIREMENTS_MAP",
                mock_requirements_map
            ):
                assert not package_deployer._is_spark_pool_requirements_modified("test_spark_pool", mock_spark_pool)


def test__odw_package_deployer__is_spark_pool_custom_libraries_modified__modified():
    """
    Given a spark pool
    When the local configuration's package list does not match the spark pool'
    Then the spark pool is marked as modified. (Returns True)
    """
    package_deployer = create_odw_package_deployer()
    mock_custom_libraries = [
        {
            "name": "a.whl",
            "path": "some/path/to/a.whl",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "whl"
        },
        {
            "name": "b.jar",
            "path": "some/path/to/b.jar",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "jar"
        }
    ]
    mock_spark_pool = {
        "name": "test_spark_pool",
        "properties": {
            "customLibraries": mock_custom_libraries
        }
    }
    mock_local_package_names = {
        "c.whl"
    }
    with mock.patch.object(ODWPackageDeployer, "get_non_odw_spark_pool_custom_libraries", return_value=mock_custom_libraries):
        with mock.patch.object(ODWPackageDeployer, "get_local_workspace_packages", return_value=mock_local_package_names):
            assert package_deployer._is_spark_pool_custom_libraries_modified(mock_spark_pool)


def test__odw_package_deployer__is_spark_pool_custom_libraries_modified__unmodified():
    """
    Given a spark pool
    When the local configuration's package list matches the spark pool'
    Then the spark pool is marked as unmodified. (Returns False)
    """
    package_deployer = create_odw_package_deployer()
    mock_custom_libraries = [
        {
            "name": "a.whl",
            "path": "some/path/to/a.whl",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "whl"
        },
        {
            "name": "b.jar",
            "path": "some/path/to/b.jar",
            "containerName": "prep",
            "uploadedTimestamp": "0001-01-01T00:00:00+00:00",
            "type": "jar"
        }
    ]
    mock_spark_pool = {
        "name": "test_spark_pool",
        "properties": {
            "customLibraries": mock_custom_libraries
        }
    }
    mock_local_package_names = {
        "a.whl", "b.jar"
    }
    with mock.patch.object(ODWPackageDeployer, "get_non_odw_spark_pool_custom_libraries", return_value=mock_custom_libraries):
        with mock.patch.object(ODWPackageDeployer, "get_local_workspace_packages", return_value=mock_local_package_names):
            assert not package_deployer._is_spark_pool_custom_libraries_modified(mock_spark_pool)


def test__odw_package_deployer__update_packages__deployment_false():
    package_deployer = create_odw_package_deployer()
    mock_packages_to_add = {"a.whl", "b.jar"}
    mock_packages_to_remove = {"c.jar"}
    mock_requirements_map = {
        "test_pool_a": "reqs_a.txt",
        "test_pool_b": "reqs_b.txt"
    }
    spark_pool_side_effects = [
        {
            "name": "test_pool_a",
            "properties": {}
        },
        {
            "name": "test_pool_b",
            "properties": {}
        }
    ]
    with mock.patch.object(ODWPackageDeployer, "get_workspace_packages_to_add", return_value=mock_packages_to_add):
        with mock.patch.object(ODWPackageDeployer, "get_workspace_packages_to_remove", return_value=mock_packages_to_remove):
            with mock.patch.object(ODWPackageDeployer, "generate_new_spark_pool_json", side_effect=spark_pool_side_effects):
                with mock.patch(
                    "pipelines.scripts.deploy_packages.ODWPackageDeployer.SPARK_POOL_REQUIREMENTS_MAP",
                    mock_requirements_map
                ):
                    with mock.patch.object(SynapseWorkspaceManager, "upload_workspace_package", return_value=None):
                        with mock.patch.object(SynapseWorkspaceManager, "update_spark_pool", return_value=None):
                            with mock.patch.object(SynapseWorkspaceManager, "remove_workspace_package", return_value=None):
                                package_deployer.update_packages(False)
                                ODWPackageDeployer.get_workspace_packages_to_add.assert_called_once()
                                ODWPackageDeployer.get_workspace_packages_to_remove.assert_called_once()
                                ODWPackageDeployer.generate_new_spark_pool_json.assert_has_calls(
                                    [
                                        mock.call("test_pool_a"),
                                        mock.call("test_pool_b")
                                    ]
                                )
                                assert not SynapseWorkspaceManager.upload_workspace_package.called
                                assert not SynapseWorkspaceManager.update_spark_pool.called
                                assert not SynapseWorkspaceManager.remove_workspace_package.called


def test__odw_package_deployer__update_packages__deployment_true():
    package_deployer = create_odw_package_deployer()
    mock_packages_to_add = {"a.whl", "b.jar"}
    mock_packages_to_remove = {"c.jar"}
    mock_requirements_map = {
        "test_pool_a": "reqs_a.txt",
        "test_pool_b": "reqs_b.txt",
        "test_pool_c": "reqs_b.txt"
    }
    spark_pool_side_effects = [
        {
            "name": "test_pool_a",
            "properties": {}
        },
        {
            "name": "test_pool_b",
            "properties": {}
        },
        None
    ]
    with mock.patch.object(ODWPackageDeployer, "get_workspace_packages_to_add", return_value=mock_packages_to_add):
        with mock.patch.object(ODWPackageDeployer, "get_workspace_packages_to_remove", return_value=mock_packages_to_remove):
            with mock.patch.object(ODWPackageDeployer, "generate_new_spark_pool_json", side_effect=spark_pool_side_effects):
                with mock.patch(
                    "pipelines.scripts.deploy_packages.ODWPackageDeployer.SPARK_POOL_REQUIREMENTS_MAP",
                    mock_requirements_map
                ):
                    with mock.patch.object(SynapseWorkspaceManager, "upload_workspace_package", return_value=None):
                        with mock.patch.object(SynapseWorkspaceManager, "update_spark_pool", return_value=None):
                            with mock.patch.object(SynapseWorkspaceManager, "remove_workspace_package", return_value=None):
                                package_deployer.update_packages(True)
                                ODWPackageDeployer.get_workspace_packages_to_add.assert_called_once()
                                ODWPackageDeployer.get_workspace_packages_to_remove.assert_called_once()
                                ODWPackageDeployer.generate_new_spark_pool_json.assert_has_calls(
                                    [
                                        mock.call("test_pool_a"),
                                        mock.call("test_pool_b")
                                    ]
                                )
                                SynapseWorkspaceManager.upload_workspace_package.assert_has_calls(
                                    [
                                        mock.call("infrastructure/configuration/workspace-packages/a.whl"),
                                        mock.call("infrastructure/configuration/workspace-packages/b.jar")
                                    ],
                                    any_order=True
                                )
                                SynapseWorkspaceManager.update_spark_pool.assert_has_calls(
                                    [
                                        mock.call(spark_pool_side_effects[0]["name"], spark_pool_side_effects[0]),
                                        mock.call(spark_pool_side_effects[1]["name"], spark_pool_side_effects[1])
                                    ],
                                    any_order=True
                                )
                                SynapseWorkspaceManager.remove_workspace_package.assert_has_calls(
                                    [
                                        mock.call("c.jar")
                                    ]
                                )
