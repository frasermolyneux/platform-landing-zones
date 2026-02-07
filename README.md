# Platform Landing Zones

[![Build Status](https://dev.azure.com/frasermolyneux/Personal-Public/_apis/build/status%2Fplatform-landing-zones.DevOpsSecureScanning?branchName=main)](https://dev.azure.com/frasermolyneux/Personal-Public/_build/latest?definitionId=208&branchName=main)
[![Build Status](https://dev.azure.com/frasermolyneux/Personal-Public/_apis/build/status%2Fplatform-landing-zones.OnePipeline?repoName=frasermolyneux%2Fplatform-landing-zones&branchName=main&stageName=build)](https://dev.azure.com/frasermolyneux/Personal-Public/_build/latest?definitionId=170&repoName=frasermolyneux%2Fplatform-landing-zones&branchName=main)
[![Build Status](https://dev.azure.com/frasermolyneux/Personal-Public/_apis/build/status%2Fplatform-landing-zones.OnePipeline?repoName=frasermolyneux%2Fplatform-landing-zones&branchName=main&stageName=deploy_dev_platform)](https://dev.azure.com/frasermolyneux/Personal-Public/_build/latest?definitionId=170&repoName=frasermolyneux%2Fplatform-landing-zones&branchName=main)
[![Build Status](https://dev.azure.com/frasermolyneux/Personal-Public/_apis/build/status%2Fplatform-landing-zones.OnePipeline?repoName=frasermolyneux%2Fplatform-landing-zones&branchName=main&stageName=deploy_prd_platform)](https://dev.azure.com/frasermolyneux/Personal-Public/_build/latest?definitionId=170&repoName=frasermolyneux%2Fplatform-landing-zones&branchName=main)
---

## Documentation

* [manual-steps](docs/manual-steps.md)

---

## Overview

This repository contains the resource configuration and associated Azure DevOps pipelines for the MX tenant azure landing zones.

It is largely based off of the [Azure/ALZ-Bicep](https://github.com/Azure/ALZ-Bicep) Azure Landing Zones Bicep repo.

---

## Solution

Currently Bicep is being used to:

* Create the Azure Landing Zone management groups
  * Excluding the `corp` and `online` under the `Landing Zones` as it is not required for the workloads I have on there.
* Setup the custom policy and role definitions
* Create a central logging and monitoring capability
* Perform subscription placement for all of the subscriptions in the tenant
* Perform some *basic* policy assignments to the management groups

---

## Azure Pipelines

The `one-pipeline` is within the `.azure-pipelines` folder and output is visible on the [frasermolyneux/Personal-Public](https://dev.azure.com/frasermolyneux/Personal-Public/_build?definitionId=172) Azure DevOps project. The pipeline will:

* Execute Bicep linting
* Perform preflight and what-if checks
* Deploy the Bicep to Azure

---

## Contributing

Please read the [contributing](CONTRIBUTING.md) guidance; this is a learning and development project.

---

## Security

Please read the [security](SECURITY.md) guidance; I am always open to security feedback through email or opening an issue.
