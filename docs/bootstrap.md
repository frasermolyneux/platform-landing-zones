# Bootstrap Guide

## Context

**Platform Landing Zones is the inception point for the entire Azure tenant.** It is the first project that runs — before `platform-workloads`, before `platform-connectivity`, before anything else. It establishes the management group hierarchy that every other subscription and workload is organized under.

Because this project is the starting point, it cannot rely on `platform-workloads` to provision its deployment identity or Terraform state storage. These must be created manually as a one-time bootstrap process.

### Dependency Order

```
1. platform-landing-zones  ← YOU ARE HERE (bootstrap manually, then Terraform)
2. platform-workloads      ← provisions identities, state storage, and config for all other projects
3. platform-connectivity   ← DNS, networking (uses identity from platform-workloads)
4. platform-monitoring     ← monitoring, alerts (uses identity from platform-workloads)
5. All other workloads     ← application repos (use identities from platform-workloads)
```

## Prerequisites

- Azure CLI installed and authenticated as a **Global Administrator** or **User Access Administrator** at the tenant root
- PowerShell 7+
- Access to the GitHub repository settings for `frasermolyneux/platform-landing-zones`

## Step 1 — Create Terraform State Storage

The Terraform state file needs a storage account. This is provisioned in the **sub-platform-management** subscription, following the org naming convention.

Run the bootstrap script:

```powershell
./scripts/bootstrap-state-storage.ps1
```

This creates:
- Resource group: `rg-tf-platform-landing-zones-prd-uksouth`
- Storage account: `satflz<unique>` (name output by script)
- Blob container: `tfstate`

**After running**, update `terraform/backends/prd.backend.hcl` with the storage account name output by the script.

## Step 2 — Create Deployment Identity

The deployment identity is an Azure AD application with a service principal that has permissions to manage management groups at the tenant root scope. It uses OIDC federation with GitHub Actions (no client secrets).

Run the bootstrap script:

```powershell
./scripts/bootstrap-identity.ps1
```

This creates:
- Azure AD application: `spn-platform-landing-zones-prd`
- Service principal with **Management Group Contributor** and **Reader** roles at tenant root scope
- **Storage Blob Data Contributor** and **Reader** roles on the state storage resource group
- OIDC federated credential for GitHub Actions (`repo:frasermolyneux/platform-landing-zones:environment:Production`)

## Step 3 — Configure GitHub Environments

After the identity is created, configure the GitHub repository:

1. Create a **Production** environment in the repository settings
2. Set the following environment variables:

| Variable | Value |
|---|---|
| `AZURE_CLIENT_ID` | Client ID of `spn-platform-landing-zones-prd` (output by script) |
| `AZURE_TENANT_ID` | `e56a6947-bb9a-4a6e-846a-1f118d1c3a14` |
| `AZURE_SUBSCRIPTION_ID` | `7760848c-794d-4a19-8cb2-52f71a21ac2b` (sub-platform-management) |

## Step 4 — First Apply (Imports)

The `terraform/imports.tf` file contains `import {}` blocks for all existing management groups and subscription placements. The break-glass role assignments also need importing, but their Azure resource IDs contain server-generated GUIDs that must be discovered first.

Generate the role assignment import blocks:

```powershell
./scripts/generate-role-assignment-imports.ps1 >> terraform/imports.tf
```

Review `terraform/imports.tf` to confirm the generated blocks look correct, then run the first apply:

```shell
terraform -chdir=terraform init -backend-config=backends/prd.backend.hcl
terraform -chdir=terraform plan -var-file=tfvars/prd.tfvars
terraform -chdir=terraform apply -var-file=tfvars/prd.tfvars
```

Once the import apply succeeds and all resources are in state, delete `terraform/imports.tf` and commit — the blocks are no longer needed.

> **Note:** The break-glass role assignments use `lifecycle { prevent_destroy = true }`. If a subscription is later removed from the tfvars lists, Terraform will refuse to destroy the corresponding role assignment. You must manually remove it from state with `terraform state rm` and optionally delete it from Azure separately.

## Step 5 — Verify

Run a Terraform plan locally to verify everything is wired up:

```shell
terraform -chdir=terraform init -backend-config=backends/prd.backend.hcl
terraform -chdir=terraform plan -var-file=tfvars/prd.tfvars
```

The plan should show no changes (or only expected drift) if all imports were successful.

## Step 6 — Teardown Legacy Bicep Resources

The original Bicep templates deployed policy definitions, policy assignments, custom roles, and logging resources that are **not** carried over to the Terraform configuration. These must be removed separately.

Preview what will be removed:

```powershell
./scripts/teardown-legacy-bicep.ps1 -WhatIf
```

Execute the teardown (policy and custom roles only):

```powershell
./scripts/teardown-legacy-bicep.ps1
```

To also remove logging resources (if already migrated to `platform-monitoring`) and break-glass role assignments:

```powershell
./scripts/teardown-legacy-bicep.ps1 -IncludeLogging -IncludeRoleAssignments
```

The script removes resources in dependency order: assignments → initiatives → definitions → roles.
