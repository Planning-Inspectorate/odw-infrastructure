# DevOps Agent Image – Python Configuration

This folder contains the Packer configuration used to build the Azure DevOps agent image for the ODW agent pools (`pins-agent-pool-odw-<env>-uks`, backed by VM scale sets).

| File | Purpose |
| --- | --- |
| `build.pkr.hcl` | Packer build definition (Ubuntu 22.04 base image, runs `tools.sh`) |
| `tools.sh` | Provisioning script that installs all tools on the image, including Python |

---

## How Python is set up on the agents

There are **two** Python installations on the image:

| Python | Location | Used by |
| --- | --- | --- |
| **System Python** (3.10 on Ubuntu 22.04) | `/usr/bin/python3` | Ubuntu tooling (`apt`, `add-apt-repository`) and `waagent`. **Do not remove or replace.** |
| **pyenv Python** (currently 3.11) | `/opt/pyenv/versions/<version>` | Pipelines, tests, Checkov, Poetry, ODW Common |

### Why the pyenv shims are linked into `/usr/local/bin`

Azure DevOps runs pipeline script steps with `bash --noprofile --norc`, so `/etc/profile.d/pyenv.sh` is **not** loaded and pyenv is not on the agent `PATH`.

The agent `PATH` is:

```
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
```

Because `/usr/local/bin` comes before `/usr/bin`, `tools.sh` symlinks every pyenv shim (`python3`, `pip`, `checkov`, `poetry`, ...) into `/usr/local/bin`. Pipelines therefore pick up the pyenv Python, while `/usr/bin/python3` stays on the system version.

> **Important:** The shim-linking step must run **after** the last `pip install` in `tools.sh`, otherwise tools installed later (e.g. Checkov) will not be on the agent `PATH`.

> **Note:** Do not use `sudo python3 ...` in `tools.sh`. `sudo` resets `PATH`, so it would install packages into the system Python instead of pyenv.

---

## Changing the Python version (e.g. 3.11 → 3.12)

### 1. Code change

Update only these two lines in `tools.sh`:

```bash
pyenv install -s 3.12
pyenv global 3.12
```

Nothing else needs changing; the shim links follow the pyenv global version automatically.

**Do not change:**

- `python3-distutils` in `tools.sh` – it belongs to the system Python.
- `python_version` in `infrastructure/workload-function-app-config.tf` and `infrastructure/environments/*.tfvars` – these are the **Azure Function App** runtimes, not the agents.

### 2. Checks before raising the PR

- [ ] Confirm the following support the new Python version:
  - packages in `tests/requirements.txt`
  - `poetry`, `checkov`, `pyopenssl`, the pinned `packaging` version
  - `odw-common`
- [ ] Python 3.12 removed `distutils` from the standard library – this is the most common cause of install failures.
- [ ] Optional: in a local virtual environment on the new version, run `pip install -r tests/requirements.txt` plus the tools above.

### 3. Deploy to the Build pool first

Run the **devops-agent-deploy** pipeline from your branch with `environment = Build` and let all three stages complete. Image Build runs on the hosted pool. Plan and Apply run on the self-hosted pool for the selected environment. UK South pools are used normally; UK West pools are used for failover deployments. Build has no UK West pool, so it always uses `pins-agent-pool-odw-build-uks`.

Because Apply runs on the pool whose scale set it updates, an image rollout could interrupt the Apply job if Azure removes or replaces its agent during the deployment. Confirm the pool has enough capacity and monitor the rollout. If Apply is interrupted, rerun the deployment after the new agents are online; Terraform can continue from the updated infrastructure state.

1. **Image Build** – builds the new image with Packer
2. **Agent Pool Plan** – Terraform plan
3. **Agent Pool Apply** – points the scale set at the new image

### 4. Checks after deploying

**a. Packer Build log**

Go to stage **Image Build**, then step **Packer Build**, and search for `Installed Python version`. Expected output:

```
python3 path: /opt/pyenv/shims/python3
Python 3.12.x
pyenv global: 3.12
System python3: Python 3.10.12
/usr/local/bin/python3: Python 3.12.x
checkov path: /usr/local/bin/checkov
```

`System python3: 3.10.x` is expected and correct.

**b. On a running agent**

Run a pipeline on the target pool with a step such as:

```yaml
- script: |
    echo "Agent: $(Agent.Name)"
    echo "python3 path: $(command -v python3)"
    python3 --version
    python3 -m pip --version
    echo "checkov path: $(command -v checkov)"
    checkov --version
  displayName: 'Print Python version'
```

Expected: `python3 path: /usr/local/bin/python3` and the new version.

**c. Dependent pipelines**

Re-run the pipelines that use the agents, for example:

- Infrastructure Agents PR (`pipelines/devops-agents-ci.yaml`)
- Terraform CI (`pipelines/terraform-ci.yaml`)
- CodeQL (`pipelines/ado-infrastructure-codeql.yml`)
- Any pipeline running the smoke tests or using Poetry

### 5. Roll out to other environments

Repeat steps 3 and 4 for **Dev**, then **Test**, then **Prod**.

### Rollback

Re-run **devops-agent-deploy** from the previous commit for the affected environment to restore the previous image.

---

## Azure PowerShell modules

The image installs `Az` and explicitly installs `Az.Synapse` for the Synapse
deployment pipeline's SQL pool check, resume, and pause steps. Both use `AllUsers`
scope so the modules are available to the agent account, not just the image
builder.

Module installation uses `$ErrorActionPreference = "Stop"` so installation errors
fail the Packer build. A separate `pwsh -NoProfile -NonInteractive` process imports
`Az.Synapse` and checks that `Get-AzSynapseSqlPool`, `Resume-AzSynapseSqlPool`, and
`Suspend-AzSynapseSqlPool` are available before image capture. Packer runs the
provisioning script with `bash -e`, so a failed PowerShell check stops the build.

Terraform version changes rebuild the entire image, including the unpinned
PowerShell modules. A successful Terraform deployment does not by itself verify
that a dependent pipeline's PowerShell commands are available.

### Validating in Build

1. Run **devops-agent-deploy** from the fix branch with `environment = Build` and
   `failover_deployment = false`.
2. Confirm **Image Build**, **Agent Pool Plan**, and **Agent Pool Apply** complete.
   Review the plan before approving Apply. In the Packer log, check that the
   module import succeeds and all three SQL pool commands are listed.
3. Confirm the Build agents are using the new image.
4. Rerun the Synapse pipeline against Build with its module diagnostic enabled.
   Verify `Az.Synapse` is listed and its import and command checks succeed before
   the SQL pool check. If successful, the pipeline continues with deployment.

To check module availability on an agent without Azure authentication or changing
SQL pool state, run:

```powershell
$ErrorActionPreference = 'Stop'
Get-Module -ListAvailable Az, Az.Accounts, Az.Synapse |
    Select-Object Name, Version, Path
Import-Module Az.Synapse -ErrorAction Stop
Get-Command Get-AzSynapseSqlPool, Resume-AzSynapseSqlPool, Suspend-AzSynapseSqlPool -Module Az.Synapse -ErrorAction Stop
```

If the module is listed but import fails, retain the import error to investigate
dependency or runtime compatibility. If it is not listed, check the image build
logs and module search paths on that agent.

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `Get-AzSynapseSqlPool` is not recognized | `Az.Synapse` is missing, not discoverable, or cannot load on the agent | Run the module diagnostic above; rebuild and deploy the image with explicit module installation and validation, then confirm the affected agents use the new image |
| Pipelines still show the old Python version | Existing scale set instances are still on the old image | Temporarily set **Standby agents** to 0 on the agent pool, or reimage the VMSS instances in the Azure portal |
| `checkov: command not found` (or `poetry`, etc.) | The tool isn't linked into `/usr/local/bin`, or the agent is on an old image | Make sure the shim-linking step in `tools.sh` runs after all `pip install` commands, then rebuild and redeploy |
| `plan file was created by Terraform X, but this is Y` | Plan and Apply used agents with different Terraform versions | Keep Plan and Apply on the same stable, non-target pool. Check `terraform -version` in both jobs and regenerate the plan after correcting the pool/image mismatch |
| `No plan found for identifier ...` when running a new pipeline | The pipeline is not authorised to use the agent pool, or the pool has no online agents | Permit the pipeline under **Agent pools**, then the pool, then **Security**, then **Pipeline permissions**, and check that agents are online |
| `A template expression is not allowed in this context` | `${{ parameters.* }}` used in a top-level `pool:` | Define the pool at job level instead |
