# ============================================================================
# VCR-CRM Master Data Deployment Script
# ============================================================================
# Description: Deploy all Master Data objects to Salesforce org
# Usage: .\scripts\deploy-master-data.ps1
# Requirements: Salesforce CLI (sf)
# ============================================================================

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("all", "business-entity", "product", "junctions", "verify")]
    [string]$Target = "verify",
    
    [Parameter(Mandatory=$false)]
    [string]$OrgAlias = "VCR-CRM"
)

$ErrorActionPreference = "Stop"
$projectRoot = "e:\SalesForce\dự án intern\project"

# Colors for output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Header {
    param([string]$Message)
    Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  $Message" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
}

function Test-SalesforceConnection {
    Write-Header "Checking Salesforce Connection"
    
    try {
        $result = sf org display --target-org $OrgAlias --json 2>&1 | ConvertFrom-Json
        if ($result.status -eq 0) {
            Write-ColorOutput "✅ Connected to org: $($result.result.alias)" "Green"
            Write-ColorOutput "   Username: $($result.result.username)" "White"
            Write-ColorOutput "   Org ID: $($result.result.id)" "White"
            return $true
        }
    }
    catch {
        Write-ColorOutput "❌ Not connected to Salesforce org" "Red"
        Write-ColorOutput "   Please run: sf org login web --alias $OrgAlias" "Yellow"
        return $false
    }
}

function Deploy-Object {
    param(
        [string]$ObjectPath,
        [string]$ObjectName
    )
    
    Write-ColorOutput "`n🚀 Deploying $ObjectName..." "Yellow"
    
    try {
        $deployCmd = "sf project deploy start --source-dir `"$ObjectPath`" --target-org $OrgAlias"
        Write-ColorOutput "   Command: $deployCmd" "Gray"
        
        $result = Invoke-Expression $deployCmd
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "   ✅ $ObjectName deployed successfully!" "Green"
            return $true
        } else {
            Write-ColorOutput "   ❌ $ObjectName deployment failed" "Red"
            Write-ColorOutput "   $result" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "   ❌ Error deploying $ObjectName : $_" "Red"
        return $false
    }
}

function Deploy-BusinessEntity {
    Write-Header "Deploying Business_Entity__c"
    
    $objectPath = Join-Path $projectRoot "force-app\main\default\objects\Business_Entity__c"
    $layoutsPath = Join-Path $projectRoot "force-app\main\default\layouts"
    
    # Deploy object
    Deploy-Object -ObjectPath $objectPath -ObjectName "Business_Entity__c"
    Start-Sleep -Seconds 2
    
    # Deploy layouts
    Write-ColorOutput "`n🚀 Deploying Business Entity Layouts..." "Yellow"
    sf project deploy start --metadata "Layout:Business_Entity__c-TTTM Layout,Layout:Business_Entity__c-KPTM Layout" --target-org $OrgAlias
}

function Deploy-Product2 {
    Write-Header "Deploying Product2 (Gian Hàng/RO)"
    
    $objectPath = Join-Path $projectRoot "force-app\main\default\objects\Product2"
    Deploy-Object -ObjectPath $objectPath -ObjectName "Product2 (RO)"
}

function Deploy-JunctionObjects {
    Write-Header "Deploying Junction Objects"
    
    # Account_Brand_Relationship__c
    $abrPath = Join-Path $projectRoot "force-app\main\default\objects\Account_Brand_Relationship__c"
    Deploy-Object -ObjectPath $abrPath -ObjectName "Account_Brand_Relationship__c"
    Start-Sleep -Seconds 2
    
    # Account_Contact_Relationship__c
    $acrPath = Join-Path $projectRoot "force-app\main\default\objects\Account_Contact_Relationship__c"
    Deploy-Object -ObjectPath $acrPath -ObjectName "Account_Contact_Relationship__c"
}

function Deploy-All {
    Write-Header "Deploying All Master Data Objects"
    
    Write-ColorOutput "This will deploy:" "Cyan"
    Write-ColorOutput "  - Business_Entity__c (Custom Object)" "White"
    Write-ColorOutput "  - Product2 (Customizations)" "White"
    Write-ColorOutput "  - Account_Brand_Relationship__c (Junction Object)" "White"
    Write-ColorOutput "  - Account_Contact_Relationship__c (Junction Object)" "White"
    Write-ColorOutput "`nContinue? (Y/N): " "Yellow" -NoNewline
    
    $confirm = Read-Host
    if ($confirm -ne "Y" -and $confirm -ne "y") {
        Write-ColorOutput "Deployment cancelled." "Yellow"
        return
    }
    
    # Deploy in order
    Deploy-BusinessEntity
    Start-Sleep -Seconds 3
    
    Deploy-Product2
    Start-Sleep -Seconds 3
    
    Deploy-JunctionObjects
    
    Write-Header "Deployment Complete"
    Write-ColorOutput "✅ All objects deployed successfully!" "Green"
    Write-ColorOutput "`nNext steps:" "Cyan"
    Write-ColorOutput "  1. Assign page layouts to record types" "White"
    Write-ColorOutput "  2. Enable field history tracking" "White"
    Write-ColorOutput "  3. Add related lists to parent objects" "White"
    Write-ColorOutput "  4. Load sample data" "White"
}

function Verify-Deployment {
    Write-Header "Verifying Metadata"
    
    Write-ColorOutput "🔍 Validating metadata files..." "Yellow"
    
    try {
        $validateCmd = "sf project deploy validate --source-dir `"$projectRoot\force-app\main\default`" --target-org $OrgAlias"
        Write-ColorOutput "   Running validation..." "Gray"
        
        $result = Invoke-Expression $validateCmd
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ Metadata validation passed!" "Green"
            Write-ColorOutput "   All files are ready for deployment." "White"
        } else {
            Write-ColorOutput "❌ Metadata validation failed" "Red"
            Write-ColorOutput "   $result" "Red"
        }
    }
    catch {
        Write-ColorOutput "❌ Validation error: $_" "Red"
    }
}

# ============================================================================
# Main Execution
# ============================================================================

Write-Header "VCR-CRM Master Data Deployment"

# Check SF CLI
try {
    $sfVersion = sf version 2>&1
    Write-ColorOutput "Salesforce CLI: $sfVersion" "Gray"
}
catch {
    Write-ColorOutput "❌ Salesforce CLI not found. Please install it first." "Red"
    exit 1
}

# Check connection
if (-not (Test-SalesforceConnection)) {
    Write-ColorOutput "`nPlease connect to your Salesforce org first:" "Yellow"
    Write-ColorOutput "  sf org login web --alias $OrgAlias" "Cyan"
    exit 1
}

# Execute based on target
switch ($Target) {
    "verify" {
        Verify-Deployment
    }
    "business-entity" {
        Deploy-BusinessEntity
    }
    "product" {
        Deploy-Product2
    }
    "junctions" {
        Deploy-JunctionObjects
    }
    "all" {
        Deploy-All
    }
}

Write-ColorOutput "`n✨ Script execution complete!`n" "Green"
