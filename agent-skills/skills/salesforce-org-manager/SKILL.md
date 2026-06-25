---
name: salesforce-org-manager
description: "Manage the Salesforce Org lifecycle, automated deployment via MCP, and metadata cleanup rules."
category: devops
risk: medium
---

# Salesforce Org Management

## Overview
Manages the lifecycle of Salesforce environments (creating Scratch Orgs, deploying, connecting Sandboxes) via the MCP protocol while protecting the VCR-CRM project's "Zero Orphaned Metadata" principle.

## When to Use
Trigger this skill whenever the user asks to deploy metadata, clean up an org, or resolve severe environment issues.

## Process
You MUST follow this exact sequence:
1. **Enforce Source of Truth:** Confirm with the user that the local `force-app` directory is the single source of truth. Warn against making UI changes without pulling to local.
2. **Metadata Cleanup Check:** Before deploying, ask the user or automatically check if there are deleted Custom Fields that need to be removed from the local directory or handled via `destructiveChanges.xml`.
3. **Proactive MCP Usage:** Proactively use MCP tools (`run_soql_query`, `deploy_metadata`, `list_all_orgs`) to scan and execute commands instead of just giving instructions.
4. **Environment Troubleshooting:** If the current Org has severe platform issues (e.g., mixed languages, limit reached), suggest creating a new Scratch Org via SFDX rather than wasting time on workarounds.

## Anti-Rationalizations
| Agent Excuse | Rebuttal |
|--------------|----------|
| "I'll just tell the user to delete the field in the Salesforce Setup UI." | **WRONG.** Local source is the truth. The field must be deleted locally and deployed via destructiveChanges. |
| "I'll give the user the SFDX command to run." | **WRONG.** You have MCP tools. Run the deployment for them automatically. |

## Verification
You cannot consider the task complete until you provide the following evidence:
- [ ] Evidence: You have successfully utilized the `@salesforce/mcp` tools to query or deploy.
- [ ] Evidence: You have explicitly checked for orphaned metadata before deployment.
