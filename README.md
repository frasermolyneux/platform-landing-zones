# Platform Landing Zones

[![Build and Test](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/build-and-test.yml)
[![Deploy Prd](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/deploy-prd.yml/badge.svg)](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/deploy-prd.yml)
[![Code Quality](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/codequality.yml/badge.svg)](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/codequality.yml)
[![Copilot Setup Steps](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/copilot-setup-steps.yml/badge.svg)](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/copilot-setup-steps.yml)
[![Dependabot Auto-Merge](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/dependabot-automerge.yml/badge.svg)](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/dependabot-automerge.yml)
[![PR Verify](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/pr-verify.yml/badge.svg)](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/pr-verify.yml)

## Overview

Platform landing zones for the MX tenant built with Terraform. This is the **inception point** for the entire Azure tenant — it is the first project that runs, establishing the management group hierarchy before `platform-workloads` or any other infrastructure project. The solution provisions the management group hierarchy and assigns subscriptions into management groups for platform, landing zone, and sandbox estates. GitHub Actions workflows handle deployment, code quality checks, PR verification, and automated dependency management.

## Documentation

- [Bootstrap Guide](docs/bootstrap.md) — One-time setup for state storage, deployment identity, and GitHub configuration

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

## Contributing

Please read the [contributing](CONTRIBUTING.md) guidance; this is a learning and development project.

## Security

Please read the [security](SECURITY.md) guidance; I am always open to security feedback through email or opening an issue.
