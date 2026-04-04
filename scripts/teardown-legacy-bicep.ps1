<#
.SYNOPSIS
    Teardown script to remove all legacy Bicep-deployed policy configuration.

.DESCRIPTION
    This script removes the policy assignments, custom policy definitions, custom
    policy set definitions (initiatives), and custom role definitions that were
    originally deployed by the Bicep templates in platform-landing-zones.

    These resources are NOT managed by Terraform and must be cleaned up separately.
    The script removes resources in the correct dependency order:
    1. Policy assignments (depend on definitions)
    2. Custom policy set definitions (initiatives, depend on policy definitions)
    3. Custom policy definitions
    4. Custom role definitions

    Optionally removes logging resources (now managed by platform-monitoring).

.NOTES
    Prerequisites:
    - Azure CLI installed and authenticated with sufficient permissions
    - Management Group Contributor or Owner at the 'alz' management group scope
    - Run with -WhatIf to preview changes before executing
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [switch]$IncludeLogging
)

$ErrorActionPreference = "Stop"
$ManagementGroupId = "alz"

Write-Host "=== Platform Landing Zones - Legacy Bicep Teardown ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script removes all policy configuration deployed by the legacy Bicep templates." -ForegroundColor Yellow
Write-Host "Management Group scope: $ManagementGroupId" -ForegroundColor Yellow
Write-Host ""

# ============================================================================
# Step 1: Remove Policy Assignments
# ============================================================================

Write-Host "--- Step 1: Policy Assignments ---" -ForegroundColor Magenta

$PolicyAssignments = @(
    @{ Name = "Deny-Storage-http";  Scope = "/providers/Microsoft.Management/managementGroups/alz-landingzones" }
    @{ Name = "Enforce-TLS-SSL";    Scope = "/providers/Microsoft.Management/managementGroups/alz-landingzones" }
    @{ Name = "Deny-Public-IP";     Scope = "/providers/Microsoft.Management/managementGroups/alz-platform-identity" }
)

foreach ($assignment in $PolicyAssignments) {
    $name = $assignment.Name
    $scope = $assignment.Scope

    Write-Host "  Checking assignment: $name at $scope" -ForegroundColor Gray

    $existing = az policy assignment show --name $name --scope $scope 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($existing) {
        if ($PSCmdlet.ShouldProcess("$name at $scope", "Delete policy assignment")) {
            az policy assignment delete --name $name --scope $scope --output none
            Write-Host "  Deleted: $name" -ForegroundColor Green
        }
    }
    else {
        Write-Host "  Not found (already removed): $name" -ForegroundColor DarkGray
    }
}

# ============================================================================
# Step 2: Remove Custom Policy Set Definitions (Initiatives)
# ============================================================================

Write-Host ""
Write-Host "--- Step 2: Custom Policy Set Definitions (Initiatives) ---" -ForegroundColor Magenta

$PolicySetDefinitions = @(
    "Enforce-EncryptTransit"
    "Deny-PublicPaaSEndpoints"
    "Deploy-Diagnostics-LogAnalytics"
    "Audit-UnusedResourcesCostOptimization"
)

foreach ($setDef in $PolicySetDefinitions) {
    Write-Host "  Checking initiative: $setDef" -ForegroundColor Gray

    $existing = az policy set-definition show --name $setDef --management-group $ManagementGroupId 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($existing) {
        if ($PSCmdlet.ShouldProcess($setDef, "Delete policy set definition")) {
            az policy set-definition delete --name $setDef --management-group $ManagementGroupId --output none
            Write-Host "  Deleted: $setDef" -ForegroundColor Green
        }
    }
    else {
        Write-Host "  Not found (already removed): $setDef" -ForegroundColor DarkGray
    }
}

# ============================================================================
# Step 3: Remove Custom Policy Definitions
# ============================================================================

Write-Host ""
Write-Host "--- Step 3: Custom Policy Definitions ---" -ForegroundColor Magenta

$PolicyDefinitions = @(
    # Append policies
    "Append-AppService-httpsonly"
    "Append-AppService-latestTLS"
    "Append-KV-SoftDelete"
    "Append-Redis-disableNonSslPort"
    "Append-Redis-sslEnforcement"

    # Audit policies
    "Audit-AzureHybridBenefit"
    "Audit-Disks-UnusedResourcesCostOptimization"
    "Audit-MachineLearning-PrivateEndpointId"
    "Audit-PrivateLinkDnsZones"
    "Audit-PublicIpAddresses-UnusedResourcesCostOptimization"
    "Audit-ServerFarms-UnusedResourcesCostOptimization"

    # Deny policies
    "Deny-AA-child-resources"
    "Deny-AppGW-Without-WAF"
    "Deny-AppServiceApiApp-http"
    "Deny-AppServiceFunctionApp-http"
    "Deny-AppServiceWebApp-http"
    "Deny-Databricks-NoPublicIp"
    "Deny-Databricks-Sku"
    "Deny-Databricks-VirtualNetwork"
    "Deny-FileServices-InsecureAuth"
    "Deny-FileServices-InsecureKerberos"
    "Deny-FileServices-InsecureSmbChannel"
    "Deny-FileServices-InsecureSmbVersions"
    "Deny-MachineLearning-Aks"
    "Deny-MachineLearning-Compute-SubnetId"
    "Deny-MachineLearning-Compute-VmSize"
    "Deny-MachineLearning-ComputeCluster-RemoteLoginPortPublicAccess"
    "Deny-MachineLearning-ComputeCluster-Scale"
    "Deny-MachineLearning-HbiWorkspace"
    "Deny-MachineLearning-PublicAccessWhenBehindVnet"
    "Deny-MachineLearning-PublicNetworkAccess"
    "Deny-MgmtPorts-From-Internet"
    "Deny-MySql-http"
    "Deny-PostgreSql-http"
    "Deny-Private-DNS-Zones"
    "Deny-PublicEndpoint-MariaDB"
    "Deny-PublicIP"
    "Deny-PublicPaaSEndpoints"
    "Deny-RDP-From-Internet"
    "Deny-Redis-http"
    "Deny-Sql-minTLS"
    "Deny-SqlMi-minTLS"
    "Deny-Storage-minTLS"
    "Deny-Storage-SFTP"
    "Deny-StorageAccount-CustomDomain"
    "Deny-Subnet-Without-Nsg"
    "Deny-Subnet-Without-Penp"
    "Deny-Subnet-Without-Udr"
    "Deny-UDR-With-Specific-NextHop"
    "Deny-VNET-Peer-Cross-Sub"
    "Deny-VNet-Peering"
    "Deny-VNET-Peering-To-Non-Approved-VNETs"

    # Deploy policies
    "Deploy-ASC-SecurityContacts"
    "Deploy-Budget"
    "Deploy-Custom-Route-Table"
    "Deploy-DDoSProtection"
    "Deploy-Diagnostics-AA"
    "Deploy-Diagnostics-ACI"
    "Deploy-Diagnostics-ACR"
    "Deploy-Diagnostics-AnalysisService"
    "Deploy-Diagnostics-ApiForFHIR"
    "Deploy-Diagnostics-APIMgmt"
    "Deploy-Diagnostics-ApplicationGateway"
    "Deploy-Diagnostics-AVDScalingPlans"
    "Deploy-Diagnostics-Bastion"
    "Deploy-Diagnostics-CDNEndpoints"
    "Deploy-Diagnostics-CognitiveServices"
    "Deploy-Diagnostics-CosmosDB"
    "Deploy-Diagnostics-Databricks"
    "Deploy-Diagnostics-DataExplorerCluster"
    "Deploy-Diagnostics-DataFactory"
    "Deploy-Diagnostics-DLAnalytics"
    "Deploy-Diagnostics-EventGridSub"
    "Deploy-Diagnostics-EventGridSystemTopic"
    "Deploy-Diagnostics-EventGridTopic"
    "Deploy-Diagnostics-ExpressRoute"
    "Deploy-Diagnostics-Firewall"
    "Deploy-Diagnostics-FrontDoor"
    "Deploy-Diagnostics-Function"
    "Deploy-Diagnostics-HDInsight"
    "Deploy-Diagnostics-iotHub"
    "Deploy-Diagnostics-LoadBalancer"
    "Deploy-Diagnostics-LogAnalytics"
    "Deploy-Diagnostics-LogicAppsISE"
    "Deploy-Diagnostics-MariaDB"
    "Deploy-Diagnostics-MediaService"
    "Deploy-Diagnostics-MlWorkspace"
    "Deploy-Diagnostics-MySQL"
    "Deploy-Diagnostics-NetworkSecurityGroups"
    "Deploy-Diagnostics-NIC"
    "Deploy-Diagnostics-PostgreSQL"
    "Deploy-Diagnostics-PowerBIEmbedded"
    "Deploy-Diagnostics-RedisCache"
    "Deploy-Diagnostics-Relay"
    "Deploy-Diagnostics-SignalR"
    "Deploy-Diagnostics-SQLElasticPools"
    "Deploy-Diagnostics-SQLMI"
    "Deploy-Diagnostics-TimeSeriesInsights"
    "Deploy-Diagnostics-TrafficManager"
    "Deploy-Diagnostics-VirtualNetwork"
    "Deploy-Diagnostics-VM"
    "Deploy-Diagnostics-VMSS"
    "Deploy-Diagnostics-VNetGW"
    "Deploy-Diagnostics-VWanS2SVPNGW"
    "Deploy-Diagnostics-WebServerFarm"
    "Deploy-Diagnostics-Website"
    "Deploy-Diagnostics-WVDAppGroup"
    "Deploy-Diagnostics-WVDHostPools"
    "Deploy-Diagnostics-WVDWorkspace"
    "Deploy-FirewallPolicy"
    "Deploy-MDFC-Config"
    "Deploy-MySQL-sslEnforcement"
    "Deploy-Nsg-FlowLogs"
    "Deploy-Nsg-FlowLogs-to-LA"
    "Deploy-PostgreSQL-sslEnforcement"
    "Deploy-Private-DNS-Zones"
    "Deploy-Sql-AuditingSettings"
    "Deploy-SQL-minTLS"
    "Deploy-Sql-Security"
    "Deploy-Sql-SecurityAlertPolicies"
    "Deploy-Sql-Tde"
    "Deploy-Sql-vulnerabilityAssessments"
    "Deploy-Sql-vulnerabilityAssessments_20230706"
    "Deploy-SqlMi-minTLS"
    "Deploy-Storage-sslEnforcement"
    "Deploy-Vm-autoShutdown"
    "Deploy-VNET-HubSpoke"
    "Deploy-Windows-DomainJoin"

    # Enforce policies
    "Enforce-ACSB"
    "Enforce-ALZ-Decomm"
    "Enforce-ALZ-Sandbox"
    "Enforce-Encryption-CMK"
    "Enforce-Guardrails-KeyVault"
)

$deletedCount = 0
$notFoundCount = 0

foreach ($policyDef in $PolicyDefinitions) {
    $existing = az policy definition show --name $policyDef --management-group $ManagementGroupId 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($existing) {
        if ($PSCmdlet.ShouldProcess($policyDef, "Delete policy definition")) {
            az policy definition delete --name $policyDef --management-group $ManagementGroupId --output none
            if ($LASTEXITCODE -eq 0) {
                $deletedCount++
            }
            else {
                Write-Host "  Failed to delete: $policyDef (may have active assignments)" -ForegroundColor Red
            }
        }
    }
    else {
        $notFoundCount++
    }
}

Write-Host "  Deleted: $deletedCount | Already removed: $notFoundCount | Total: $($PolicyDefinitions.Count)" -ForegroundColor Green

# ============================================================================
# Step 4: Remove Custom Role Definitions
# ============================================================================

Write-Host ""
Write-Host "--- Step 4: Custom Role Definitions ---" -ForegroundColor Magenta

$CustomRoles = @(
    "Subscription owner"
    "Application owners (DevOps/AppOps)"
    "Network management (NetOps)"
    "Security operations (SecOps)"
)

foreach ($roleName in $CustomRoles) {
    Write-Host "  Checking role: $roleName" -ForegroundColor Gray

    $existing = az role definition list --custom-role-only --name $roleName 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($existing -and $existing.Count -gt 0) {
        $roleId = $existing[0].name
        if ($PSCmdlet.ShouldProcess($roleName, "Delete custom role definition")) {
            az role definition delete --name $roleId --output none
            Write-Host "  Deleted: $roleName" -ForegroundColor Green
        }
    }
    else {
        Write-Host "  Not found (already removed): $roleName" -ForegroundColor DarkGray
    }
}

# ============================================================================
# Step 5 (Optional): Remove Logging Resources
# ============================================================================

if ($IncludeLogging) {
    Write-Host ""
    Write-Host "--- Step 5: Logging Resources ---" -ForegroundColor Magenta
    Write-Host "  These resources are now managed by platform-monitoring." -ForegroundColor Yellow

    $LoggingSubscriptionId = "7760848c-794d-4a19-8cb2-52f71a21ac2b"
    $LoggingResourceGroup = "rg-platform-logging-prd-uksouth-01"

    Write-Host "  Checking resource group: $LoggingResourceGroup in $LoggingSubscriptionId" -ForegroundColor Gray

    $existing = az group show --name $LoggingResourceGroup --subscription $LoggingSubscriptionId 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($existing) {
        if ($PSCmdlet.ShouldProcess("$LoggingResourceGroup", "Delete logging resource group")) {
            az group delete --name $LoggingResourceGroup --subscription $LoggingSubscriptionId --yes --output none
            Write-Host "  Deleted: $LoggingResourceGroup" -ForegroundColor Green
        }
    }
    else {
        Write-Host "  Not found (already removed): $LoggingResourceGroup" -ForegroundColor DarkGray
    }
}

# ============================================================================
# Summary
# ============================================================================

Write-Host ""
Write-Host "=== Teardown Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Removed legacy Bicep-deployed resources:" -ForegroundColor Yellow
Write-Host "  - Policy assignments (3)"
Write-Host "  - Policy set definitions / initiatives (4)"
Write-Host "  - Custom policy definitions (~101)"
Write-Host "  - Custom role definitions (4)"
if ($IncludeLogging) { Write-Host "  - Logging resource group" }
Write-Host ""
Write-Host "These resources are no longer managed by Terraform." -ForegroundColor Gray
Write-Host "Policy will be re-implemented in a future phase." -ForegroundColor Gray
Write-Host "Break-glass role assignments are now managed by Terraform." -ForegroundColor Gray
Write-Host ""
