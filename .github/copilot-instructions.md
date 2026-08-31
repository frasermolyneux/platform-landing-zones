# Copilot Instructions

## Repository purpose

`platform-landing-zones` creates the Azure tenant management-group hierarchy and assigns subscriptions to management groups. It runs before other platform repositories and owns its bootstrap state storage and deployment identity.

## Terraform layout and boundaries

- `terraform/management-groups.tf` defines the hierarchy rooted at `alz`.
- `terraform/subscription-placement.tf` associates subscriptions with management groups.
- `terraform/tfvars/prd.tfvars` contains the production subscription lists.
- `terraform/backends/prd.backend.hcl` selects the manually bootstrapped state backend.
- `scripts/` and `docs/bootstrap.md` cover the one-time state, identity, and import process.

This is a production-only tenant-scope stack. There is no `dev` environment and no `platform-workloads` remote-state dependency.

Terraform requires `>= 1.15.6`; AzureRM is constrained to `~> 5.0.0` in `terraform/providers.tf`. Do not change these constraints as part of unrelated work.

Preserve the `alz` prefix and established hierarchy. Subscription onboarding and removal belong in `terraform/tfvars/prd.tfvars`.

## Validation and planning

Documentation and Copilot configuration changes require `git diff --check` and link review; they do not require a Terraform plan.

For Terraform changes:

```pwsh
terraform -chdir=terraform fmt -check -recursive
terraform -chdir=terraform init -backend=false -upgrade
terraform -chdir=terraform validate
```

Run a state-backed plan only for infrastructure-affecting changes:

```pwsh
terraform -chdir=terraform init -reconfigure -backend-config=backends/prd.backend.hcl
terraform -chdir=terraform plan -var-file=tfvars/prd.tfvars
```

## Safety

- Treat management-group and subscription-placement changes as tenant-wide.
- Preserve backend and import contracts; do not create a platform remote-state dependency.
- Break-glass role assignments use lifecycle protection. Follow the documented state procedure rather than forcing destruction.
- Do not apply, import, move, or remove state unless explicitly requested.
- Use OIDC; never add client secrets, tokens, or connection strings.
- `.terraform.lock.hcl` is generated locally, ignored, and never committed.

Follow [docs/bootstrap.md](../docs/bootstrap.md) for bootstrap, imports, and protected-resource handling.
