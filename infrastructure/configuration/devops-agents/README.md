# ODW Azure DevOps Agent Python Runtime

## Document control

| Field | Value |
| --- | --- |
| Change | Upgrade ODW Azure DevOps agents from Python 3.10 to Python 3.11 |
| Work item | THEODW-3528 |
| Repository | `odw-infrastructure` |
| Implementation commit | `ae57d0d923eb8c1c54bdb2982d054f7f458b44a2` |
| Implementation date | 2 September 2026 |
| Status | Implemented; environment deployment and validation required |

## Summary

The Python runtime in the ODW self-hosted Azure DevOps agent image has been upgraded from Python 3.10 to Python 3.11. This keeps the build and deployment platform on a supported Python release and aligns tests executed by Azure DevOps agents with the Python 3.11 runtime used by Synapse Spark 3.5.

The change is made once in the shared Packer image and applies to these primary agent pools when the image is deployed:

| Environment | Azure DevOps agent pool |
| --- | --- |
| Build | `pins-agent-pool-odw-build-uks` |
| Development | `pins-agent-pool-odw-dev-uks` |
| Test | `pins-agent-pool-odw-test-uks` |
| Production | `pins-agent-pool-odw-prod-uks` |

Each pool has a default base agent count of two. Azure DevOps manages the scale-set capacity after registration, so the Terraform VM scale-set resource ignores subsequent instance-count changes.

No Synapse workspace package configuration was changed. Synapse Spark 3.5 already provides Python 3.11.

## Implementation details

The agent image is defined in `infrastructure/configuration/devops-agents`. The Packer build uses Ubuntu 22.04 LTS and executes `tools.sh` to install the tools required by ODW pipelines.

Previously, the script installed the unversioned Ubuntu packages `python3`, `python3-distutils`, and `python3-pip`. On Ubuntu 22.04, the default `python3` package resolves to Python 3.10.

The implementation now:

1. Uses the existing Deadsnakes package repository.
2. Installs `python3.11`, `python3.11-distutils`, and `python3.11-venv` explicitly.
3. Creates `/usr/local/bin/python3` as a symbolic link to `/usr/bin/python3.11`.
4. Bootstraps pip for the selected interpreter using the official `get-pip.py` script.
5. Stops the Packer build unless `python3 --version` reports Python 3.11.
6. Installs test requirements, Poetry, Checkov, and ODW Common through Python 3.11.

The link is created under `/usr/local/bin` instead of replacing Ubuntu's `/usr/bin/python3`. This allows agent jobs to select Python 3.11 through the normal `PATH` order without changing the operating system's Python link.

The version assertion used during image creation is:

```bash
python3 --version | grep -q '^Python 3\.11\.'
```

Because `tools.sh` runs with `bash -e`, a failed assertion terminates the image build.

## Deployment procedure

### Prerequisites

- The change has been merged into the branch used to run the deployment pipeline.
- The Azure DevOps variable groups `Terraform Build`, `Terraform Dev`, `Terraform Test`, and `Terraform Prod` contain valid deployment values.
- The deployment identity can create managed images and update the agent VM scale sets.
- Required environment approvals are available.
- A recent successful pipeline duration is recorded as the comparison baseline.

### Deploy the image and pools

Use the Azure DevOps pipeline defined by `pipelines/devops-agent-deploy.yaml`.

Deploy in this order:

1. Run the pipeline with `Environment: Build` and `Failover Deployment: false`.
2. Confirm that the Image Build, Agent Pool Plan, and Agent Pool Apply stages succeed.
3. Wait for the Build pool agents to come online and verify Python 3.11 as described below.
4. Run the infrastructure CI pipeline on `pins-agent-pool-odw-build-uks` before continuing.
5. Repeat the agent deployment for `Dev`, then `Test`, then `Prod`.
6. Observe the normal approval and change-management controls for Test and Production.
7. After each deployment, wait for both base agents to report Online in Azure DevOps before validating dependent pipelines.

For a failover pool deployment, run the same pipeline with `Failover Deployment: true`. Failover deployment is separate from the four UK South pools in the scope of this change.

## Validation

### Confirm the runtime

Run the following as a pipeline script on each updated pool:

```yaml
- script: |
    set -e
    python3 --version
    python3 -m pip --version
    python3 -c "import sys; assert sys.version_info[:2] == (3, 11), sys.version"
  displayName: Verify Python 3.11
```

Expected results:

- `python3 --version` reports `Python 3.11.x`.
- pip reports a path associated with Python 3.11.
- The assertion exits successfully.

Do not rely only on the Azure DevOps agent capability display. Execute the commands in a job so that validation uses the same `PATH`, identity, and working environment as ODW pipelines.

### Validation matrix

Complete this table and attach links to pipeline runs when recording evidence in Confluence.

| Environment | Pool | Runtime check | CI/unit tests | Deployment/smoke tests | Duration compared with baseline | Result |
| --- | --- | --- | --- | --- | --- | --- |
| Build | `pins-agent-pool-odw-build-uks` | Pending | Pending | N/A | Pending | Pending |
| Dev | `pins-agent-pool-odw-dev-uks` | Pending | Pending | Pending | Pending | Pending |
| Test | `pins-agent-pool-odw-test-uks` | Pending | Pending | Pending | Pending | Pending |
| Prod | `pins-agent-pool-odw-prod-uks` | Pending | Pending | Pending | Pending | Pending |

Validation is complete when:

1. The runtime check succeeds on every pool.
2. Infrastructure CI completes successfully on the Build pool.
3. All applicable unit tests complete successfully under Python 3.11.
4. Development and Test deployments, including smoke tests, complete successfully.
5. The Production deployment completes successfully.
6. Image build, test, and deployment durations remain within their normal operating ranges, or any variance is understood and accepted.
7. Both expected base agents are online in each pool, with no unexpected offline agents or repeated job failures.

Record the old baseline, new duration, difference, and percentage difference for each representative pipeline. Investigate material regressions using the team's existing operational threshold rather than introducing a new threshold for this change.

## Future Python version upgrades

Use the following process when moving from Python 3.11 to a later minor version.

### 1. Assess compatibility

1. Confirm that the target Python release is supported by Synapse/Spark and the ODW support policy.
2. Confirm that the target interpreter packages are available for the Ubuntu version used by `build.pkr.hcl`.
3. Review `tests/requirements.txt`, Poetry, Checkov, ODW Common, Azure SDK packages, and any packages with native extensions for target-version support.
4. Review Python release notes for removed or changed standard-library modules.
5. Decide whether the Ubuntu base image also needs upgrading. Treat an operating-system upgrade as a separate risk and test it explicitly.

### 2. Update the Packer provisioning script

In `infrastructure/configuration/devops-agents/tools.sh`:

1. Replace all versioned Python package names with the target minor version.
2. Update the `/usr/local/bin/python3` symbolic-link target.
3. Keep pip installation tied to `python3` by using `python3 -m pip`.
4. Update the image-build version assertion.
5. Search the repository for the old version and review every remaining occurrence before committing.

Example for a hypothetical target version `<major.minor>`:

```bash
sudo apt-get install -y --no-install-recommends \
  python<major.minor> \
  python<major.minor>-venv

sudo ln -sf /usr/bin/python<major.minor> /usr/local/bin/python3
curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python3

python3 --version | grep -q '^Python <major>\.<minor>\.'
```

Package names vary between Python and Ubuntu releases. Verify package availability instead of assuming that `distutils` or other packages used by the previous version still exist.

### 3. Validate before deployment

Run the available local checks:

```bash
bash -n infrastructure/configuration/devops-agents/tools.sh
packer fmt -check infrastructure/configuration/devops-agents
git diff --check
```

Review the change to confirm that it does not replace `/usr/bin/python3` and that all Python package installations use `python3 -m pip`.

### 4. Build and promote progressively

1. Build and deploy the new image to the Build pool.
2. Verify the interpreter, pip, agent health, CI, and unit tests.
3. Promote to Dev and execute deployment and smoke tests.
4. Promote to Test and repeat the checks.
5. Promote to Prod only after lower-environment evidence is accepted.
6. Retain the previous managed image until Production validation and the agreed observation period are complete.

### 5. Record evidence

For each environment, record:

- Pipeline run URL and date.
- Managed image name or ID.
- Output from the Python and pip version checks.
- Unit-test and smoke-test results.
- Agent count and health.
- Pipeline duration compared with baseline.
- Approval or change reference.
- Exceptions, failures, and their resolution.

## Rollback

Rollback should use a newly built image from a revert commit or a controlled update that selects the previous managed image. Do not modify running agents manually because replacement scale-set instances would lose that change.

1. Stop promotion to later environments.
2. Retain logs and identify whether the failure is caused by Python, a dependency, image creation, or pool registration.
3. Revert the Python provisioning change to the last known-good version and rebuild the managed image, or configure the scale set to use the retained previous image according to the approved operational process.
4. Run `devops-agent-deploy.yaml` for the affected environment.
5. Confirm that both base agents are online and report the previous Python version.
6. Rerun the failed validation pipeline.
7. Record the rollback and follow-up action against the work item and Confluence evidence table.

## Troubleshooting

| Symptom | Checks and action |
| --- | --- |
| Packer cannot find the target Python package | Confirm the package repository was added successfully and supports the Ubuntu release and target Python version. |
| `python3` reports the old version | Check `command -v python3`, `echo "$PATH"`, and the `/usr/local/bin/python3` link from an agent pipeline job. |
| pip installs into the wrong interpreter | Use `python3 -m pip`; do not call an unqualified `pip` executable. |
| A dependency installation fails | Check target-version support and available wheels. Pin or upgrade the dependency only after compatibility testing. |
| Pool agents do not come online | Check the VM scale-set instance state, Azure DevOps pool configuration, network access, and agent registration logs. |
| Pipeline duration increases | Compare stage and task timings with the recorded baseline. Separate one-time package download or image-build variance from repeatable runtime regression. |

## Relevant repository files

| File | Purpose |
| --- | --- |
| `infrastructure/configuration/devops-agents/build.pkr.hcl` | Defines the Ubuntu-based managed image and invokes the provisioning script. |
| `infrastructure/configuration/devops-agents/tools.sh` | Installs Python and the other tools included in the agent image. |
| `pipelines/devops-agent-deploy.yaml` | Builds the image and plans/applies the agent pool for the selected environment. |
| `pipelines/steps/devops-agent-build.yaml` | Runs Packer with the Azure build parameters. |
| `infrastructure/workload-agent-pool.tf` | Instantiates the primary and failover agent-pool modules. |
| `infrastructure/modules/devops-agent-pool/agent-vmss.tf` | Defines the VM scale set and selects the managed agent image. |
| `infrastructure/variables.tf` | Defines the default base agent count of two. |
| `tests/requirements.txt` | Defines Python dependencies installed for ODW tests. |