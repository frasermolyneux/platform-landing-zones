# AGENTS.md - platform-landing-zones

This repository is the Terraform inception point for the Azure tenant. It owns the management-group hierarchy and subscription placement; it does not consume `platform-workloads` remote state.

## Key locations

- `terraform/management-groups.tf` - tenant management-group hierarchy.
- `terraform/subscription-placement.tf` - subscription associations.
- `terraform/tfvars/prd.tfvars` - production subscription placement.
- `terraform/backends/prd.backend.hcl` - production state backend.
- `scripts/` and `docs/bootstrap.md` - one-time state and identity bootstrap.

## Validation

For documentation or Copilot-configuration-only changes:

```pwsh
git diff --check
```

For Terraform changes:

```pwsh
terraform -chdir=terraform fmt -check -recursive
terraform -chdir=terraform init -backend=false -upgrade
terraform -chdir=terraform validate
```

Run the production state-backed plan only when Terraform behavior changes:

```pwsh
terraform -chdir=terraform init -reconfigure -backend-config=backends/prd.backend.hcl
terraform -chdir=terraform plan -var-file=tfvars/prd.tfvars
```

## Guardrails

- This is a production-only, tenant-scope stack with no development environment.
- Preserve the `alz` hierarchy and keep subscription lists in `prd.tfvars` authoritative.
- Do not introduce a dependency on `platform-workloads`.
- Bootstrap identities use OIDC; never add client secrets or credentials.
- Management-group, subscription-placement, import, and break-glass changes have tenant-wide blast radius.
- `.terraform.lock.hcl` is local generated state, ignored, and not committed.

See [README.md](README.md) and [docs/bootstrap.md](docs/bootstrap.md).
