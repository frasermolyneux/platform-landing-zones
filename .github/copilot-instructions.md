# Copilot Instructions

## Project Overview

This repository contains tenant-scoped Azure Landing Zones for the MX tenant, built with Bicep and aligned to Azure/ALZ-Bicep patterns. Deployments run at Azure tenant scope.

## Repository Layout

- `bicep/main.bicep` — orchestrator that wires all modules together.
- `bicep/managementGroups/` — management group hierarchy (top-level prefix `alz`; corp/online children disabled).
- `bicep/policy/definitions/` — custom policy definitions scoped to `managementGroup('alz')`.
- `bicep/customRoleDefinitions/` — custom role definitions scoped to `managementGroup('alz')`.
- `bicep/policyAssignments/` — policy assignments bound to the Log Analytics workspace output.
- `bicep/logging/` — Log Analytics (30-day retention, 1 GB/day cap), Automation Account, AzureActivity solution.
- `bicep/subscriptionPlacement/` — assigns subscription ID arrays into platform, connectivity, identity, landing-zone, and sandbox management groups.
- `bicep/roleAssignments/` — Owner role for a break-glass principal across all subscriptions.
- `bicep/resourceGroup/` — resource group creation helper.
- `params/` — parameter files; `platform.prd.json` supplies prod values (uksouth, instance 01).
- `.azure-pipelines/` — Azure DevOps CI/CD (lint, validate, what-if, deploy).
- `.github/workflows/` — GitHub Actions for code quality, PR verification, and dependency management.
- `docs/` — documentation; `manual-steps.md` covers deploy principal and service connection setup.

## Key Conventions

- Naming seed: `uniqueString('alz', parEnvironment, parInstance)`.
- Resource naming: `rg-platform-logging-{env}-{location}-{instance}`, `log-platform-*`, `aa-platform-*`.
- Key parameters: `parEnvironment`, `parLocation`, `parInstance`, `parLoggingSubscriptionId`, `parTags`.
- Keep subscription ID lists in `main.bicep` current when onboarding or removing subscriptions.

## Local Development

```shell
az deployment tenant validate --template-file bicep/main.bicep --parameters @params/platform.prd.json --location uksouth
az deployment tenant what-if   --template-file bicep/main.bicep --parameters @params/platform.prd.json --location uksouth
az deployment tenant create    --template-file bicep/main.bicep --parameters @params/platform.prd.json --location uksouth
```

## CI/CD

- **Azure DevOps**: `release-to-production.yml` triggers on main and weekly; runs lint, validate/what-if, then deploy stages.
- **GitHub Actions**: `build-and-test.yml`, `codequality.yml`, `pr-verify.yml`, `dependabot-automerge.yml`, `copilot-setup-steps.yml`.
