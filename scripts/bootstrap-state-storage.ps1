<#
.SYNOPSIS
    Bootstrap script to create Terraform state storage for platform-landing-zones.

.DESCRIPTION
    This is a one-time bootstrap script that creates the Azure resources needed to
    store the Terraform state file for the platform-landing-zones project.

    Platform-landing-zones is the inception point for the tenant - it runs before
    platform-workloads, so its state storage must be provisioned manually.

    Resources created:
    - Resource group: rg-tf-platform-landing-zones-prd-uksouth
    - Storage account: satflz<random> (globally unique name)
    - Blob container: tfstate

    All resources are created in the sub-platform-management subscription.
    This script is idempotent - safe to run multiple times.

.NOTES
    Prerequisites:
    - Azure CLI installed and authenticated
    - Permissions to create resources in sub-platform-management subscription
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

# Configuration
$SubscriptionId = "7760848c-794d-4a19-8cb2-52f71a21ac2b"  # sub-platform-management
$ResourceGroupName = "rg-tf-platform-landing-zones-prd-uksouth"
$Location = "uksouth"
$ContainerName = "tfstate"
$Tags = "Environment=prd Workload=platform-landing-zones DeployedBy=Manual-Bootstrap Git=https://github.com/frasermolyneux/platform-landing-zones"

Write-Host "=== Platform Landing Zones - Bootstrap State Storage ===" -ForegroundColor Cyan
Write-Host ""

# Set subscription context
Write-Host "Setting subscription context to sub-platform-management..." -ForegroundColor Yellow
az account set --subscription $SubscriptionId
if ($LASTEXITCODE -ne 0) { throw "Failed to set subscription context" }

# Create resource group (az group create is idempotent - updates if exists)
Write-Host ""
Write-Host "Creating resource group: $ResourceGroupName..." -ForegroundColor Yellow
az group create `
    --name $ResourceGroupName `
    --location $Location `
    --tags $Tags.Split(" ") `
    --output none
if ($LASTEXITCODE -ne 0) { throw "Failed to create resource group" }
Write-Host "Resource group created." -ForegroundColor Green

# Check if a storage account already exists in the resource group
$existingAccounts = az storage account list `
    --resource-group $ResourceGroupName `
    --query "[].name" `
    --output json 2>$null | ConvertFrom-Json

if ($existingAccounts -and $existingAccounts.Count -gt 0) {
    $StorageAccountName = $existingAccounts[0]
    Write-Host ""
    Write-Host "Storage account already exists: $StorageAccountName (skipping creation)" -ForegroundColor DarkGray
}
else {
    # Generate a unique storage account name
    $RandomSuffix = -join ((48..57) + (97..122) | Get-Random -Count 10 | ForEach-Object { [char]$_ })
    $StorageAccountName = "satflz$RandomSuffix"

    # Ensure storage account name is valid (3-24 chars, lowercase alphanumeric)
    if ($StorageAccountName.Length -gt 24) {
        $StorageAccountName = $StorageAccountName.Substring(0, 24)
    }

    Write-Host ""
    Write-Host "Creating storage account: $StorageAccountName..." -ForegroundColor Yellow
    az storage account create `
        --name $StorageAccountName `
        --resource-group $ResourceGroupName `
        --location $Location `
        --sku Standard_LRS `
        --kind StorageV2 `
        --min-tls-version TLS1_2 `
        --allow-blob-public-access false `
        --allow-shared-key-access false `
        --tags $Tags.Split(" ") `
        --output none
    if ($LASTEXITCODE -ne 0) { throw "Failed to create storage account" }
    Write-Host "Storage account created." -ForegroundColor Green
}

# Create blob container (idempotent - succeeds if already exists)
Write-Host ""
Write-Host "Ensuring blob container exists: $ContainerName..." -ForegroundColor Yellow
az storage container create `
    --name $ContainerName `
    --account-name $StorageAccountName `
    --auth-mode login `
    --output none
if ($LASTEXITCODE -ne 0) { throw "Failed to create blob container" }
Write-Host "Blob container ready." -ForegroundColor Green

# Output summary
Write-Host ""
Write-Host "=== Bootstrap Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Update terraform/backends/prd.backend.hcl with:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  subscription_id      = `"$SubscriptionId`""
Write-Host "  resource_group_name  = `"$ResourceGroupName`""
Write-Host "  storage_account_name = `"$StorageAccountName`""
Write-Host "  container_name       = `"$ContainerName`""
Write-Host "  key                  = `"terraform.tfstate`""
Write-Host "  use_oidc             = true"
Write-Host "  use_azuread_auth     = true"
Write-Host "  tenant_id            = `"e56a6947-bb9a-4a6e-846a-1f118d1c3a14`""
Write-Host ""
