# Copilot Instructions

- Purpose: tenant-scoped Azure Landing Zones baseline for the MX tenant, built with Bicep and aligned to Azure/ALZ-Bicep patterns.
- Layout: bicep/main.bicep orchestrates modules in bicep/ (managementGroups, policy/definitions, customRoleDefinitions, logging, resourceGroup, subscriptionPlacement, roleAssignments, policyAssignments).
- Target scope: deployments run at tenant scope; key parameters are parEnvironment, parLocation, parInstance, parLoggingSubscriptionId, and parTags.
- Naming: uniqueString('alz', parEnvironment, parInstance) seeds names; logging resources follow rg-platform-logging-{env}-{location}-{instance}, log-platform-*, and aa-platform-* patterns.
- Management groups: managementGroups/managementGroups.bicep builds the hierarchy with top-level prefix alz and disables default Landing Zone children not needed (corp/online).
- Policy/roles: policy/definitions/customPolicyDefinitions.bicep and customRoleDefinitions/customRoleDefinitions.bicep scope to managementGroup('alz'); policyAssignments/policyAssignments.bicep binds to the Log Analytics workspace output.
- Subscription placement: subscriptionPlacement/subscriptionPlacement.bicep assigns subscription ID arrays into platform, connectivity, identity, landing zone, and sandbox management groups; keep the ID lists in main.bicep current.
- Access: roleAssignments/roleAssignmentSubscriptionMany.bicep assigns Owner to a break-glass principal across all subscriptions listed in varAllSubscriptionIds.
- Logging: logging/logging.bicep deploys Log Analytics with 30-day retention, 1 GB/day cap, Automation Account, and AzureActivity solution; scope set by parLoggingSubscriptionId.
- Parameters: params/platform.prd.json supplies prod values (uksouth, instance 01, logging subscription ID, default tags including Git URL).
- Pipelines: Azure DevOps pipelines live under .azure-pipelines/. release-to-production.yml triggers on main and weekly; runs bicep lint via ado-pipeline-templates then validate/what-if and deploy stages using AzureCLI with params/platform.{env}.json. devops-secure-scanning.yml runs weekly and on main for security scanning.
- Pipeline dependencies: templates/bicep-environment-validation.yml performs az deployment tenant validate and what-if; templates/deploy-environment.yml performs az deployment tenant create.
- Local workflow: from repo root run `az deployment tenant validate --template-file bicep/main.bicep --parameters @params/platform.prd.json --location <loc>` then `az deployment tenant what-if ...` and `az deployment tenant create ...` when ready; login with permissions and correct tenant.
- Documentation: docs/manual-steps.md notes manual creation of deploy principals and Azure DevOps service connections.
- GitHub Actions: none are defined; CI/CD relies on Azure DevOps service connections such as spn-platform-landing-zones-production.
