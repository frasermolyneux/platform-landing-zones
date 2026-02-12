# Platform Landing Zones

[![Build and Test](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/build-and-test.yml)
[![Code Quality](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/codequality.yml/badge.svg)](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/codequality.yml)
[![Copilot Setup Steps](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/copilot-setup-steps.yml/badge.svg)](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/copilot-setup-steps.yml)
[![Dependabot Auto-Merge](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/dependabot-automerge.yml/badge.svg)](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/dependabot-automerge.yml)
[![PR Verify](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/pr-verify.yml/badge.svg)](https://github.com/frasermolyneux/platform-landing-zones/actions/workflows/pr-verify.yml)

## Documentation

- [Manual Steps](docs/manual-steps.md) - Notes on provisioning deploy principals and Azure DevOps service connections

## Overview

Platform landing zones for the MX tenant built with tenant-scoped Bicep templates inspired by Azure/ALZ-Bicep. The solution provisions the management group hierarchy, custom policy and role definitions, central logging (Log Analytics + Automation Account), and assigns subscriptions into management groups for platform, landing zone, and sandbox estates. Azure DevOps pipelines run linting, validation, what-if, and deploy stages against parameterized environments. GitHub Actions workflows handle code quality checks, PR verification, and automated dependency management.

## Contributing

Please read the [contributing](CONTRIBUTING.md) guidance; this is a learning and development project.

## Security

Please read the [security](SECURITY.md) guidance; I am always open to security feedback through email or opening an issue.
