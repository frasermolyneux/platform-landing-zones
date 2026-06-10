# Copilot Instructions

> Shared conventions: see [`.github-copilot/.github/instructions/terraform.instructions.md`](../../.github-copilot/.github/instructions/terraform.instructions.md) (sibling repo) for the standard Terraform layout, providers, validation commands, and CI/CD workflows.

## Project Overview

This repository manages Azure Landing Zones for the MX tenant using Terraform. It is the **inception point** for the entire Azure tenant — the first project that runs before `platform-workloads` or any other infrastructure. It provisions the management group hierarchy and places subscriptions into the appropriate management groups. Deployments target the Azure tenant scope via the `azurerm` provider.

Because this project predates `platform-workloads`, its Terraform state storage and deployment identity are bootstrapped manually, and it does **not** consume `platform-workloads` remote state. See [docs/bootstrap.md](docs/bootstrap.md) for the one-time setup process.

## Repository Specifics

- `terraform/management-groups.tf` — Management group hierarchy (3-level tree under root prefix `alz`).
- `terraform/subscription-placement.tf` — `azurerm_management_group_subscription_association` resources.
- `scripts/bootstrap-state-storage.ps1` — One-time script to create Terraform state storage account.
- `scripts/bootstrap-identity.ps1` — One-time script to create deployment and plan-only service principals with OIDC federation.
- `docs/bootstrap.md` — Step-by-step guide for the one-time tenant bootstrap process.
- `docs/terraform-import.md` — Commands to import existing Azure resources into Terraform state.
- Production-only stack: `backends/prd.backend.hcl` and `tfvars/prd.tfvars` only — no Dev environment.

## Key Conventions

- Management group prefix: `alz` — all group names start with this prefix.
- Keep subscription ID lists in `terraform/tfvars/prd.tfvars` current when onboarding or removing subscriptions.

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

## Org conventions via MCP (when available)

If a `frasermolyneux-copilot` MCP server is configured in your client (`.vscode/mcp.json`, the GitHub Copilot coding-agent MCP config at `.github/copilot/mcp_config.json`, or an equivalent stdio MCP wire-up), **prefer its tools** over your own assumptions when answering questions about org standards, branching, workflows, Terraform, .NET projects, Azure patterns, or shared library / platform consumption contracts. The tool surface is `list_instructions`, `get_instruction`, `search_instructions`, plus the matching `_prompts` and `_agents` equivalents (seven tools total). The catalog source-of-truth lives in `frasermolyneux/.github-copilot` — see `mcp-server/README.md` there for the tool contract.

This is **complementary** to the file-load model: if `./.github-copilot/` is checked out in the runner (per `copilot-setup-steps.yml`), continue to read those files directly. If both are available, prefer MCP for freshness. If no MCP server is configured in your client, treat this section as a no-op and fall back to the file paths above.
