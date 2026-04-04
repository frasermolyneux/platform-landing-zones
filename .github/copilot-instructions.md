# Copilot Instructions

## Project Overview

This repository manages Azure Landing Zones for the MX tenant using Terraform. It is the **inception point** for the entire Azure tenant — the first project that runs before `platform-workloads` or any other infrastructure. It provisions the management group hierarchy and places subscriptions into the appropriate management groups. Deployments target the Azure tenant scope via the `azurerm` provider.

Because this project predates `platform-workloads`, its Terraform state storage and deployment identity are bootstrapped manually. See [docs/bootstrap.md](docs/bootstrap.md) for the one-time setup process.

## Repository Layout

- `terraform/providers.tf` — Terraform and azurerm provider configuration with Azure backend.
- `terraform/variables.tf` — Variable declarations for environment config and subscription lists.
- `terraform/locals.tf` — Computed subscription-to-management-group placement map.
- `terraform/management-groups.tf` — Management group hierarchy (3-level tree under root prefix `alz`).
- `terraform/subscription-placement.tf` — `azurerm_management_group_subscription_association` resources.
- `terraform/backends/prd.backend.hcl` — Backend state storage configuration for production.
- `terraform/tfvars/prd.tfvars` — Production variable values including all subscription IDs.
- `scripts/bootstrap-state-storage.ps1` — One-time script to create Terraform state storage account.
- `scripts/bootstrap-identity.ps1` — One-time script to create deployment and plan-only service principals with OIDC federation.
- `docs/bootstrap.md` — Step-by-step guide for the one-time tenant bootstrap process.
- `docs/terraform-import.md` — Commands to import existing Azure resources into Terraform state.
- `.github/workflows/` — GitHub Actions for CI/CD: terraform plan, apply, code quality, and dependency management.

## Key Conventions

- Management group prefix: `alz` — all group names start with this prefix.
- Resource naming follows org standard: `{resource}-{project}-{environment}-{location}-{instance}`.
- Always set `tags = var.tags` on taggable Terraform resources.
- Keep subscription ID lists in `terraform/tfvars/prd.tfvars` current when onboarding or removing subscriptions.
- OIDC federation for all GitHub Actions authentication — no client secrets.

## Management Group Hierarchy

```
Tenant Root Group
└── alz (Azure Landing Zones)
    ├── alz-platform (Platform)
    │   ├── alz-platform-management (Management)
    │   ├── alz-platform-connectivity (Connectivity)
    │   └── alz-platform-identity (Identity)
    ├── alz-landingzones (Landing Zones)
    ├── alz-sandbox (Sandbox)
    └── alz-decommissioned (Decommissioned)
```

## Local Development

```shell
terraform -chdir=terraform init -backend-config=backends/prd.backend.hcl
terraform -chdir=terraform plan -var-file=tfvars/prd.tfvars
terraform -chdir=terraform apply -var-file=tfvars/prd.tfvars
terraform fmt -recursive
```

## CI/CD

- **Deploy Prd** (`deploy-prd.yml`): Triggers on main push, weekly schedule (Thursday), and manual dispatch. Runs terraform plan and apply against production.
- **Build and Test** (`build-and-test.yml`): Terraform plan on feature/bugfix/hotfix branches.
- **PR Verify** (`pr-verify.yml`): Terraform plan with PR comments on pull requests.
- **Code Quality** (`codequality.yml`): SonarCloud, security scanning, and dependency review.
- **Destroy Environment** (`destroy-environment.yml`): Manual dispatch for terraform destroy.
