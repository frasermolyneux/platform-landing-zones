# Platform Landing Zones

GitHub Actions workflows are not configured for this repository; Azure DevOps pipelines handle validation and deployment.

## Documentation

- [Manual Steps](docs/manual-steps.md) - Notes on provisioning deploy principals and Azure DevOps service connections

## Overview

Platform landing zones for the MX tenant built with tenant-scoped Bicep templates inspired by Azure/ALZ-Bicep. The solution provisions the management group hierarchy, custom policy and role definitions, central logging (Log Analytics + Automation Account), and assigns subscriptions into management groups for platform, landing zone, and sandbox estates. Azure DevOps pipelines run linting, validation, what-if, and deploy stages against parameterized environments.

## Contributing

Please read the [contributing](CONTRIBUTING.md) guidance; this is a learning and development project.

## Security

Please read the [security](SECURITY.md) guidance; I am always open to security feedback through email or opening an issue.
