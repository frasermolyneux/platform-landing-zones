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
  dependsOn: [
    managementGroups
  ]
  name: '${varDeploymentPrefix}-managementSubscriptionPlacement'
  scope: managementGroup('alz')
  params: {
    parSubscriptionIds: [
      '7760848c-794d-4a19-8cb2-52f71a21ac2b' //sub-platform-management
    ]
    parTargetManagementGroupId: managementGroups.outputs.outPlatformManagementGroupName
    parTelemetryOptOut: true
  }
}

module connectivitySubscriptionPlacement 'subscriptionPlacement/subscriptionPlacement.bicep' = {
  dependsOn: [
    managementGroups
  ]
  name: '${varDeploymentPrefix}-connectivitySubscriptionPlacement'
  scope: managementGroup('alz')
  params: {
    parSubscriptionIds: [
      'db34f572-8b71-40d6-8f99-f29a27612144' //sub-platform-connectivity
    ]
    parTargetManagementGroupId: managementGroups.outputs.outPlatformConnectivityManagementGroupName
    parTelemetryOptOut: true
  }
}

module identitySubscriptionPlacement 'subscriptionPlacement/subscriptionPlacement.bicep' = {
  dependsOn: [
    managementGroups
  ]
  name: '${varDeploymentPrefix}-identitySubscriptionPlacement'
  scope: managementGroup('alz')
  params: {
    parSubscriptionIds: [
      'c391a150-f992-41a6-bc81-ebc22bc64376' //sub-platform-identity
    ]
    parTargetManagementGroupId: managementGroups.outputs.outPlatformIdentityManagementGroupName
    parTelemetryOptOut: true
  }
}

module landingZoneSubscriptionPlacement 'subscriptionPlacement/subscriptionPlacement.bicep' = {
  dependsOn: [
    managementGroups
  ]
  name: '${varDeploymentPrefix}-landingZoneSubscriptionPlacement'
  scope: managementGroup('alz')
  params: {
    parSubscriptionIds: [
      '655da25d-da46-40c0-8e81-5debe2dcd024' //sub-mx-consulting-prd
      '845766d6-b73f-49aa-a9f6-eaf27e20b7a8' //sub-xi-demomanager-prd
      'f857cea2-c7c0-4aef-b6b6-0c1ed18aafde' //Personal-Pay-As-You-Go
      'd3b204ab-7c2b-47f7-8d5a-de19e85591e7' //sub-fm-geolocation-prd
      '903b6685-c12a-4703-ac54-7ec1ff15ca43' //sub-platform-strategic
      '32444f38-32f4-409f-889c-8e8aa2b5b4d1' //sub-xi-portal-prd
      '1b5b28ed-1365-4a48-b285-80f80a6aaa1b' //sub-enterprise-devtest-legacy
      'd68448b0-9947-46d7-8771-baa331a3063a' //sub-visualstudio-enterprise
      'e1e5de62-3573-4b44-a52b-0f1431675929' //sub-talkwithtiles
      '957a7d34-8562-4098-bb4c-072e08386d07' //sub-finances-prd
      'ef3cc6c2-159e-4890-9193-13673dded835' //sub-molyneux-me-dev
      '3cc59319-eb1e-4b52-b19e-09a49f9db2e7' //sub-molyneux-me-prd
    ]
    parTargetManagementGroupId: managementGroups.outputs.outLandingZonesManagementGroupName
    parTelemetryOptOut: true
  }
}

module sandboxSubscriptionPlacement 'subscriptionPlacement/subscriptionPlacement.bicep' = {
  dependsOn: [
    managementGroups
  ]
  name: '${varDeploymentPrefix}-sandboxSubscriptionPlacement'
  scope: managementGroup('alz')
  params: {
    parSubscriptionIds: [
      '4ebd4bf2-7dd9-40b0-b2a4-e687ded49112' //Pay-As-You-Go Dev/Test
    ]
    parTargetManagementGroupId: managementGroups.outputs.outSandboxManagementGroupName
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
