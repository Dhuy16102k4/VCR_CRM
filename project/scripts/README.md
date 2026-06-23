# VCR-CRM Deployment Scripts

Collection of PowerShell scripts to automate Salesforce deployment tasks.

## Scripts

### 1. deploy-master-data.ps1
Deploy Master Data objects to Salesforce org.

**Usage:**
```powershell
# Verify metadata (default)
.\scripts\deploy-master-data.ps1

# Deploy specific object
.\scripts\deploy-master-data.ps1 -Target business-entity
.\scripts\deploy-master-data.ps1 -Target product
.\scripts\deploy-master-data.ps1 -Target junctions

# Deploy all Master Data objects
.\scripts\deploy-master-data.ps1 -Target all

# Specify org alias
.\scripts\deploy-master-data.ps1 -Target all -OrgAlias "MyOrg"
```

**Targets:**
- `verify` (default) - Validate metadata without deploying
- `business-entity` - Deploy Business_Entity__c only
- `product` - Deploy Product2 customizations only
- `junctions` - Deploy both junction objects
- `all` - Deploy all Master Data objects

**Requirements:**
- Salesforce CLI installed
- Connected to Salesforce org (`sf org login web`)

## Prerequisites

### Install Salesforce CLI
```powershell
# Using Windows Package Manager
winget install Salesforce.CLI

# Or download from:
# https://developer.salesforce.com/tools/salesforcecli
```

### Connect to Salesforce Org
```powershell
# Login to org
sf org login web --alias VCR-CRM

# Verify connection
sf org display --target-org VCR-CRM

# List all orgs
sf org list
```

## Common Commands

### Deploy Specific Objects
```powershell
# Deploy single object
sf project deploy start --source-dir force-app/main/default/objects/Business_Entity__c

# Deploy specific metadata types
sf project deploy start --metadata Layout:Business_Entity__c-TTTM Layout

# Deploy multiple objects
sf project deploy start --source-dir force-app/main/default/objects/Business_Entity__c,force-app/main/default/objects/Product2
```

### Retrieve Metadata
```powershell
# Retrieve specific object
sf project retrieve start --metadata CustomObject:Business_Entity__c

# Retrieve all metadata
sf project retrieve start --target-org VCR-CRM
```

### Validate Before Deploy
```powershell
# Validate deployment
sf project deploy validate --source-dir force-app/main/default

# Check for errors
sf project deploy report
```

## Troubleshooting

### Common Issues

**Issue:** "Entity is not api accessible"
- Solution: Make sure object deployment status is "Deployed" in metadata

**Issue:** "No changes to deploy"
- Solution: Metadata already exists in org or no changes detected

**Issue:** "insufficient access rights on cross-reference id"
- Solution: Check user permissions or profile settings

**Issue:** "Layout not found"
- Solution: Deploy object first, then deploy layouts

### Debug Mode
```powershell
# Enable debug output
$env:SF_LOG_LEVEL="debug"
sf project deploy start --source-dir force-app/main/default

# View logs
sf project deploy report --use-most-recent
```

## Best Practices

1. **Always verify first:**
   ```powershell
   .\scripts\deploy-master-data.ps1 -Target verify
   ```

2. **Deploy one object at a time** (first time):
   - Easier to troubleshoot
   - Can fix issues before proceeding

3. **Check deployment status:**
   ```powershell
   sf project deploy report
   ```

4. **Use version control:**
   - Commit metadata before deploying
   - Tag successful deployments

5. **Test in sandbox first:**
   - Never deploy directly to production
   - Validate in development/staging environment

## Additional Resources

- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)
- [Salesforce Metadata API](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/)
- [Deployment Best Practices](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_deploy.htm)

---

**Last Updated:** 2026-06-09  
**Project:** HC-SF-I24-VCR-CRM  
**Version:** 1.0
