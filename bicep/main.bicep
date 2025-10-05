targetScope = 'tenant'

// Parameters
@description('Allows for a parallel deployment of the environment.')
param parInstance string

param parLocation string
param parEnvironment string
param parLoggingSubscriptionId string
param parTags object

// Variables
var varEnvironmentUniqueId = uniqueString('alz', parEnvironment, parInstance)
var varDeploymentPrefix = 'platform-${varEnvironmentUniqueId}' //Prevent deployment naming conflicts

var varLoggingResourceGroupName = 'rg-platform-logging-${parEnvironment}-${parLocation}-${parInstance}'
var varLogAnalyticsWorkspaceName = 'log-platform-${parEnvironment}-${parLocation}-${parInstance}'
var varAutomationAccountName = 'aa-platform-${parEnvironment}-${parLocation}-${parInstance}'

var varManagementSubscriptionIds = [
  '7760848c-794d-4a19-8cb2-52f71a21ac2b' //sub-platform-management
]

var varConnectivitySubscriptionIds = [
  'db34f572-8b71-40d6-8f99-f29a27612144' //sub-platform-connectivity
]

var varIdentitySubscriptionIds = [
  'c391a150-f992-41a6-bc81-ebc22bc64376' //sub-platform-identity
]

var varLandingZoneSubscriptionIds = [
  '655da25d-da46-40c0-8e81-5debe2dcd024' //sub-mx-consulting-prd
  '845766d6-b73f-49aa-a9f6-eaf27e20b7a8' //sub-xi-demomanager-prd
  'f857cea2-c7c0-4aef-b6b6-0c1ed18aafde' //Personal-Pay-As-You-Go
  'd3b204ab-7c2b-47f7-8d5a-de19e85591e7' //sub-fm-geolocation-prd
  '903b6685-c12a-4703-ac54-7ec1ff15ca43' //sub-platform-strategic
  '32444f38-32f4-409f-889c-8e8aa2b5b4d1' //sub-xi-portal-prd
  '02174fb6-b8f3-4bd7-8be8-99f271c3dc20' //sub-xi-dedi-server-prd
  '1b5b28ed-1365-4a48-b285-80f80a6aaa1b' //sub-enterprise-devtest-legacy
  'd68448b0-9947-46d7-8771-baa331a3063a' //sub-visualstudio-enterprise
  'e1e5de62-3573-4b44-a52b-0f1431675929' //sub-talkwithtiles
  '957a7d34-8562-4098-bb4c-072e08386d07' //sub-finances-prd
  'ef3cc6c2-159e-4890-9193-13673dded835' //sub-molyneux-me-dev
  '3cc59319-eb1e-4b52-b19e-09a49f9db2e7' //sub-molyneux-me-prd
]

var varSandboxSubscriptionIds = [
  '4ebd4bf2-7dd9-40b0-b2a4-e687ded49112' //Pay-As-You-Go Dev/Test
]

var varAllSubscriptionIds = union(
  [parLoggingSubscriptionId],
  varManagementSubscriptionIds,
  varConnectivitySubscriptionIds,
  varIdentitySubscriptionIds,
  varLandingZoneSubscriptionIds,
  varSandboxSubscriptionIds
)

// Platform
module managementGroups 'managementGroups/managementGroups.bicep' = {
  name: '${varDeploymentPrefix}-managementGroups'
  scope: tenant()
  params: {
    parTopLevelManagementGroupPrefix: 'alz'
    parLandingZoneMgAlzDefaultsEnable: false
    parTelemetryOptOut: true
  }
}

module customPolicyDefinitions 'policy/definitions/customPolicyDefinitions.bicep' = {
  dependsOn: [
    managementGroups
  ]
  name: '${varDeploymentPrefix}-customPolicyDefinitions'
  scope: managementGroup('alz')
  params: {
    parTelemetryOptOut: true
  }
}

module customRoleDefinitions 'customRoleDefinitions/customRoleDefinitions.bicep' = {
  dependsOn: [
    managementGroups
  ]
  name: '${varDeploymentPrefix}-customRoleDefinitions'
  scope: managementGroup('alz')
  params: {
    parAssignableScopeManagementGroupId: 'alz'
    parTelemetryOptOut: true
  }
}

module loggingResourceGroup 'resourceGroup/resourceGroup.bicep' = {
  name: '${varDeploymentPrefix}-loggingResourceGroup'
  scope: subscription(parLoggingSubscriptionId)
  params: {
    parLocation: parLocation
    parResourceGroupName: varLoggingResourceGroupName
    parTags: parTags
    parTelemetryOptOut: true
  }
}

module logging 'logging/logging.bicep' = {
  dependsOn: [
    loggingResourceGroup
  ]
  name: '${varDeploymentPrefix}-logging'
  scope: resourceGroup(parLoggingSubscriptionId, varLoggingResourceGroupName)
  params: {
    parLogAnalyticsWorkspaceName: varLogAnalyticsWorkspaceName
    parLogAnalyticsWorkspaceLocation: parLocation
    parLogAnalyticsWorkspaceLogRetentionInDays: 30
    parLogAnalyticsWorkspaceDailyCapInGB: '1'
    parAutomationAccountName: varAutomationAccountName
    parAutomationAccountLocation: parLocation
    parTags: parTags
    parTelemetryOptOut: true
    parLogAnalyticsWorkspaceSolutions: ['AzureActivity']
  }
}

module managementSubscriptionPlacement 'subscriptionPlacement/subscriptionPlacement.bicep' = {
  name: '${varDeploymentPrefix}-managementSubscriptionPlacement'
  scope: managementGroup('alz')
  params: {
    parSubscriptionIds: varManagementSubscriptionIds
    parTargetManagementGroupId: managementGroups.outputs.outPlatformManagementGroupName
    parTelemetryOptOut: true
  }
}

module connectivitySubscriptionPlacement 'subscriptionPlacement/subscriptionPlacement.bicep' = {
  name: '${varDeploymentPrefix}-connectivitySubscriptionPlacement'
  scope: managementGroup('alz')
  params: {
    parSubscriptionIds: varConnectivitySubscriptionIds
    parTargetManagementGroupId: managementGroups.outputs.outPlatformConnectivityManagementGroupName
    parTelemetryOptOut: true
  }
}

module identitySubscriptionPlacement 'subscriptionPlacement/subscriptionPlacement.bicep' = {
  name: '${varDeploymentPrefix}-identitySubscriptionPlacement'
  scope: managementGroup('alz')
  params: {
    parSubscriptionIds: varIdentitySubscriptionIds
    parTargetManagementGroupId: managementGroups.outputs.outPlatformIdentityManagementGroupName
    parTelemetryOptOut: true
  }
}

module landingZoneSubscriptionPlacement 'subscriptionPlacement/subscriptionPlacement.bicep' = {
  name: '${varDeploymentPrefix}-landingZoneSubscriptionPlacement'
  scope: managementGroup('alz')
  params: {
    parSubscriptionIds: varLandingZoneSubscriptionIds
    parTargetManagementGroupId: managementGroups.outputs.outLandingZonesManagementGroupName
    parTelemetryOptOut: true
  }
}

module sandboxSubscriptionPlacement 'subscriptionPlacement/subscriptionPlacement.bicep' = {
  name: '${varDeploymentPrefix}-sandboxSubscriptionPlacement'
  scope: managementGroup('alz')
  params: {
    parSubscriptionIds: varSandboxSubscriptionIds
    parTargetManagementGroupId: managementGroups.outputs.outSandboxManagementGroupName
    parTelemetryOptOut: true
  }
}

module ownerRoleAssignments 'roleAssignments/roleAssignmentSubscriptionMany.bicep' = {
  name: '${varDeploymentPrefix}-ownerRoleAssignments'
  scope: managementGroup('alz')
  params: {
    parSubscriptionIds: varAllSubscriptionIds
    parRoleDefinitionId: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635' // Owner
    parAssigneePrincipalType: 'ServicePrincipal'
    parAssigneeObjectId: 'de0ae7da-6642-464e-81ea-b32986d88579'
    parTelemetryOptOut: true
  }
}

module policyAssignments 'policyAssignments/policyAssignments.bicep' = {
  dependsOn: [
    customPolicyDefinitions
  ]
  name: '${varDeploymentPrefix}-policyAssignments'
  scope: managementGroup('alz')
  params: {
    parTopLevelManagementGroupPrefix: 'alz'
    parLogAnalyticsWorkspaceResourceID: logging.outputs.outLogAnalyticsWorkspaceId
    parTelemetryOptOut: true
  }
}
