// **Parameters**
// Parameters are used to pass in values to the various policy assignment modules.

@description('Prefix for the management group hierarchy. DEFAULT VALUE = alz')
@minLength(2)
@maxLength(10)
param parTopLevelManagementGroupPrefix string = 'alz'

@description('Log Analytics Workspace Resource ID. - DEFAULT VALUE: Empty String ')
param parLogAnalyticsWorkspaceResourceID string = ''

@description('Set Parameter to true to Opt-out of deployment telemetry')
param parTelemetryOptOut bool = false

// **Variables**
// Orchestration Module Variables
var varDeploymentNameWrappers = {
  basePrefix: 'ALZBicep'
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced. See https://github.com/Azure/ALZ-Bicep/wiki/FAQ#why-are-some-linter-rules-disabled-via-the-disable-next-line-bicep-function for more information
  baseSuffixTenantAndManagementGroup: '${deployment().location}-${uniqueString(deployment().location, parTopLevelManagementGroupPrefix)}'
}

var varModuleDeploymentNames = {
  modPolicyAssignmentIntRootDeployAzActivityLog: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployAzActivityLog-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIdentDenyPublicIP: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyPublicIP-ident-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLZsDenyStorageHttp: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyStorageHttp-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLZsEnforceTLSSSL: take('${varDeploymentNameWrappers.basePrefix}-polAssi-enforceTLSSSL-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
}

// Policy Assignments Modules Variables
var varPolicyAssignmentDenyPublicIP = {
  definitionID: '${varTopLevelManagementGroupResourceID}/providers/Microsoft.Authorization/policyDefinitions/Deny-PublicIP'
  libDefinition: json(loadTextContent('lib/policy_assignments/policy_assignment_es_deny_public_ip.tmpl.json'))
}

var varPolicyAssignmentDenyStoragehttp = {
  definitionID: '/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9'
  libDefinition: json(loadTextContent('lib/policy_assignments/policy_assignment_es_deny_storage_http.tmpl.json'))
}

var varPolicyAssignmentDeployAzActivityLog = {
  definitionID: '/providers/Microsoft.Authorization/policyDefinitions/2465583e-4e78-4c15-b6be-a36cbc7c8b0f'
  libDefinition: json(loadTextContent('lib/policy_assignments/policy_assignment_es_deploy_azactivity_log.tmpl.json'))
}

var varPolicyAssignmentEnforceTLSSSL = {
  definitionID: '${varTopLevelManagementGroupResourceID}/providers/Microsoft.Authorization/policySetDefinitions/Enforce-EncryptTransit'
  libDefinition: json(loadTextContent('lib/policy_assignments/policy_assignment_es_enforce_tls_ssl.tmpl.json'))
}

// RBAC Role Definitions Variables - Used For Policy Assignments
var varRBACRoleDefinitionIDs = {
  owner: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  networkContributor: '4d97b98b-1d4f-4787-a291-c67834d212e7'
  aksContributor: 'ed7f3fbd-7b88-4dd4-9017-9adb7ce333f8'
}

// Managment Groups Varaibles - Used For Policy Assignments
var varManagementGroupIDs = {
  intRoot: parTopLevelManagementGroupPrefix
  platform: '${parTopLevelManagementGroupPrefix}-platform'
  platformManagement: '${parTopLevelManagementGroupPrefix}-platform-management'
  platformConnectivity: '${parTopLevelManagementGroupPrefix}-platform-connectivity'
  platformIdentity: '${parTopLevelManagementGroupPrefix}-platform-identity'
  landingZones: '${parTopLevelManagementGroupPrefix}-landingzones'
  decommissioned: '${parTopLevelManagementGroupPrefix}-decommissioned'
  sandbox: '${parTopLevelManagementGroupPrefix}-sandbox'
}

var varTopLevelManagementGroupResourceID = '/providers/Microsoft.Management/managementGroups/${varManagementGroupIDs.intRoot}'

// **Scope**
targetScope = 'managementGroup'

/// --- ALZ - managementGroup(varManagementGroupIDs.intRoot)
// Deploy-AzActivity-Log
module modPolicyAssignmentIntRootDeployAzActivityLog '../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.intRoot)
  name: varModuleDeploymentNames.modPolicyAssignmentIntRootDeployAzActivityLog
  params: {
    parPolicyAssignmentDefinitionId: varPolicyAssignmentDeployAzActivityLog.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDeployAzActivityLog.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDeployAzActivityLog.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDeployAzActivityLog.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDeployAzActivityLog.libDefinition.properties.parameters
    parPolicyAssignmentParameterOverrides: {
      logAnalytics: {
        value: parLogAnalyticsWorkspaceResourceID
      }
    }
    parPolicyAssignmentIdentityType: varPolicyAssignmentDeployAzActivityLog.libDefinition.identity.type
    parPolicyAssignmentIdentityRoleDefinitionIds: [
      varRBACRoleDefinitionIDs.owner
    ]
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDeployAzActivityLog.libDefinition.properties.enforcementMode
    parTelemetryOptOut: parTelemetryOptOut
  }
}

/// --- ALZ - Decommissioned - managementGroup(varManagementGroupIDs.decommissioned) 

/// --- ALZ - Landing Zones - managementGroup(varManagementGroupIDs.landingZones) 
// Deny-Storage-http 
module modPolicyAssignmentLZsDenyStorageHttp '../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.landingZones)
  name: varModuleDeploymentNames.modPolicyAssignmentLZsDenyStorageHttp
  params: {
    parPolicyAssignmentDefinitionId: varPolicyAssignmentDenyStoragehttp.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDenyStoragehttp.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDenyStoragehttp.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDenyStoragehttp.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDenyStoragehttp.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentDenyStoragehttp.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDenyStoragehttp.libDefinition.properties.enforcementMode
    parTelemetryOptOut: parTelemetryOptOut
  }
}

// Enforce-TLS-SSL
module modPolicyAssignmentLZsEnforceTLSSSL '../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.landingZones)
  name: varModuleDeploymentNames.modPolicyAssignmentLZsEnforceTLSSSL
  params: {
    parPolicyAssignmentDefinitionId: varPolicyAssignmentEnforceTLSSSL.definitionID
    parPolicyAssignmentName: varPolicyAssignmentEnforceTLSSSL.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentEnforceTLSSSL.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentEnforceTLSSSL.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentEnforceTLSSSL.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentEnforceTLSSSL.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentEnforceTLSSSL.libDefinition.properties.enforcementMode
    parTelemetryOptOut: parTelemetryOptOut
  }
}

/// --- ALZ - Landing Zones - Corp - managementGroup(varManagementGroupIDs.landingZonesCorp) 

/// --- ALZ - Landing Zones - Online - managementGroup(varManagementGroupIDs.landingZonesOnline) 

/// --- ALZ - Platform - Connectivity - managementGroup(varManagementGroupIDs.platformConnectivity) 

/// --- ALZ - Platform - Identity - managementGroup(varManagementGroupIDs.platformIdentity) 
// Deny-Public-IP
module modPolicyAssignmentIdentDenyPublicIP '../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.platformIdentity)
  name: varModuleDeploymentNames.modPolicyAssignmentIdentDenyPublicIP
  params: {
    parPolicyAssignmentDefinitionId: varPolicyAssignmentDenyPublicIP.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDenyPublicIP.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDenyPublicIP.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDenyPublicIP.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDenyPublicIP.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentDenyPublicIP.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDenyPublicIP.libDefinition.properties.enforcementMode
    parTelemetryOptOut: parTelemetryOptOut
  }
}

/// --- ALZ - Platform - Management - managementGroup(varManagementGroupIDs.platformManagement) 

/// --- ALZ - Sandbox - managementGroup(varManagementGroupIDs.sandbox) 
