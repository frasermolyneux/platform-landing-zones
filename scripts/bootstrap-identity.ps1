<#
.SYNOPSIS
    Bootstrap script to create the deployment identity for platform-landing-zones.

.DESCRIPTION
    This is a one-time bootstrap script that creates the Azure AD applications and
    service principals needed to deploy the platform-landing-zones project via
    GitHub Actions with OIDC federation.

    Platform-landing-zones is the inception point for the tenant - it runs before
    platform-workloads, so its deployment identity must be provisioned manually.

    Resources created:
    - Azure AD application registration (spn-platform-landing-zones-prd)
    - Service principal
    - Management Group Contributor role at tenant root scope
    - Storage Blob Data Contributor + Reader on state storage RG
    - OIDC federated credential for GitHub Actions (Production environment)

    This script is idempotent- safe to run multiple times. Existing resources
    are detected and reused rather than duplicated.

.NOTES
    Prerequisites:
    - Azure CLI installed and authenticated as Global Administrator
    - The state storage must already exist (run bootstrap-state-storage.ps1 first)
    - Update $StateStorageResourceGroup below if different from the default
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$StateStorageResourceGroup = "rg-tf-platform-landing-zones-prd-uksouth"
)

$ErrorActionPreference = "Stop"

# Configuration
$TenantId = "e56a6947-bb9a-4a6e-846a-1f118d1c3a14"
$SubscriptionId = "7760848c-794d-4a19-8cb2-52f71a21ac2b"  # sub-platform-management
$GitHubOrg = "frasermolyneux"
$GitHubRepo = "platform-landing-zones"
$DeployAppName = "spn-platform-landing-zones-prd"
# Azure built-in role IDs
$ManagementGroupContributorRoleId = "5d58bcaf-24a5-4b20-bdb6-eed9f69fbe4c"
$StorageBlobDataContributorRoleId = "ba92f5b4-2d11-453d-a403-e96b0029c9fe"
$ReaderRoleId = "acdd72a7-3385-48ef-bd42-f606fba81ae7"

$StateStorageScope = "/subscriptions/$SubscriptionId/resourceGroups/$StateStorageResourceGroup"

function Get-OrCreateApp {
    param([string]$DisplayName)

    $existing = az ad app list --display-name $DisplayName --query "[?displayName=='$DisplayName']" --output json 2>$null | ConvertFrom-Json
    if ($existing -and $existing.Count -gt 0) {
        Write-Host "  Application already exists: $($existing[0].appId) (reusing)" -ForegroundColor DarkGray
        return $existing[0]
    }

    $app = az ad app create --display-name $DisplayName --output json | ConvertFrom-Json
    Write-Host "  Application created: $($app.appId)" -ForegroundColor Green
    return $app
}

function Get-OrCreateSp {
    param([string]$AppId)

    $existing = az ad sp show --id $AppId --output json 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "  Service principal already exists: $($existing.id) (reusing)" -ForegroundColor DarkGray
        return $existing
    }

    $sp = az ad sp create --id $AppId --output json | ConvertFrom-Json
    Write-Host "  Service principal created: $($sp.id)" -ForegroundColor Green
    return $sp
}

function Add-FederatedCredentialIfNotExists {
    param([string]$AppObjectId, [string]$CredentialName, [string]$Subject, [string]$Description)

    $existing = az ad app federated-credential show --id $AppObjectId --federated-credential-id $CredentialName 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "  OIDC credential '$CredentialName' already exists (skipping)" -ForegroundColor DarkGray
        return
    }

    $credential = @{
        name        = $CredentialName
        issuer      = "https://token.actions.githubusercontent.com"
        subject     = $Subject
        audiences   = @("api://AzureADTokenExchange")
        description = $Description
    } | ConvertTo-Json

    $tempFile = [System.IO.Path]::GetTempFileName()
    try {
        Set-Content -Path $tempFile -Value $credential -Encoding utf8
        az ad app federated-credential create --id $AppObjectId --parameters "@$tempFile" --output none
        if ($LASTEXITCODE -ne 0) { throw "Failed to create federated credential: $CredentialName" }
        Write-Host "  OIDC credential '$CredentialName' created" -ForegroundColor Green
    }
    finally {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    }
}

function Add-RoleAssignmentIfNotExists {
    param([string]$PrincipalId, [string]$RoleId, [string]$Scope, [string]$RoleLabel)

    $existing = az role assignment list `
        --assignee $PrincipalId `
        --role $RoleId `
        --scope $Scope `
        --query "[0]" `
        --output json 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue

    if ($existing) {
        Write-Host "  $RoleLabel already assigned (skipping)" -ForegroundColor DarkGray
        return
    }

    az role assignment create `
        --assignee-object-id $PrincipalId `
        --assignee-principal-type ServicePrincipal `
        --role $RoleId `
        --scope $Scope `
        --output none
    if ($LASTEXITCODE -ne 0) { throw "Failed to assign role: $RoleLabel" }
    Write-Host "  $RoleLabel assigned" -ForegroundColor Green
}

Write-Host "=== Platform Landing Zones - Bootstrap Deployment Identity ===" -ForegroundColor Cyan
Write-Host ""

# Set subscription context
az account set --subscription $SubscriptionId
if ($LASTEXITCODE -ne 0) { throw "Failed to set subscription context" }

# --- Deploy Identity ---

Write-Host "Deploy identity: $DeployAppName" -ForegroundColor Yellow

$DeployApp = Get-OrCreateApp -DisplayName $DeployAppName
$DeployAppId = $DeployApp.appId
$DeployObjectId = $DeployApp.id

$DeploySp = Get-OrCreateSp -AppId $DeployAppId
$DeploySpObjectId = $DeploySp.id

Add-FederatedCredentialIfNotExists `
    -AppObjectId $DeployObjectId `
    -CredentialName "github-actions-production" `
    -Subject "repo:${GitHubOrg}/${GitHubRepo}:environment:Production" `
    -Description "GitHub Actions OIDC for Production environment"

Write-Host "  Ensuring role assignments..." -ForegroundColor Yellow
Add-RoleAssignmentIfNotExists -PrincipalId $DeploySpObjectId -RoleId $ManagementGroupContributorRoleId -Scope "/" -RoleLabel "Management Group Contributor at /"
Add-RoleAssignmentIfNotExists -PrincipalId $DeploySpObjectId -RoleId $ReaderRoleId -Scope "/" -RoleLabel "Reader at / (enumerate subscriptions)"
Add-RoleAssignmentIfNotExists -PrincipalId $DeploySpObjectId -RoleId $StorageBlobDataContributorRoleId -Scope $StateStorageScope -RoleLabel "Storage Blob Data Contributor on state RG"
Add-RoleAssignmentIfNotExists -PrincipalId $DeploySpObjectId -RoleId $ReaderRoleId -Scope $StateStorageScope -RoleLabel "Reader on state RG"

# --- Output Summary ---

Write-Host ""
Write-Host "=== Bootstrap Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configure GitHub repository environment variables:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Create a 'Production' environment in GitHub repo settings" -ForegroundColor White
Write-Host ""
Write-Host "2. Production environment variables:" -ForegroundColor White
Write-Host "   AZURE_CLIENT_ID       = $DeployAppId"
Write-Host "   AZURE_TENANT_ID       = $TenantId"
Write-Host "   AZURE_SUBSCRIPTION_ID = $SubscriptionId"
Write-Host ""
