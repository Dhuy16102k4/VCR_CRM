---
name: salesforce-metadata-auditor
description: "Audit and review Salesforce XML metadata before deploying."
category: devops
risk: medium
---

# Salesforce Metadata Auditor

## Overview
Reviews Salesforce configuration XML files (like `.field-meta.xml`, `.object-meta.xml`, `package.xml`) to ensure there are no syntax errors, missing field definitions, or incorrect formatting before pushing to an Org.

## When to Use
Trigger this skill whenever the user asks you to review, audit, or generate Salesforce XML metadata files or `package.xml`.

## Process
You MUST follow this exact sequence:
1. **XML Standardization Check:** Verify that every XML file starts with the mandatory header `<?xml version="1.0" encoding="UTF-8"?>`.
2. **Naming Convention Check:** 
   - Ensure custom object and custom field API Names have the `__c` suffix.
   - Ensure custom relationships (Master-Detail, Lookup) use the `__r` or `__c` suffix depending on the query context.
3. **Package.xml Validation:** Ensure that any newly added components (e.g., CustomField, Layout) are explicitly defined in `package.xml` so they aren't missed during CLI/MCP deployments.
4. **Cross-Check with Requirements:** Compare the metadata lengths and data types against the provided Excel or requirement files.
5. **Issue Reporting:** If errors are found, DO NOT rewrite the entire file. Print only the erroneous snippet and provide the corrected code block.

## Anti-Rationalizations
| Agent Excuse | Rebuttal |
|--------------|----------|
| "The XML looks mostly right, I'll just rewrite the whole file for them." | **WRONG.** Rewriting large XML files wastes tokens and causes diff issues. Only provide the snippet that needs fixing. |
| "It's just a standard object, I don't need to check the suffix." | **WRONG.** Standard objects don't need `__c`, but custom fields on standard objects do. Check carefully. |

## Verification
You cannot consider the task complete until you provide the following evidence:
- [ ] Evidence: You have printed the exact lines of code that contain errors.
- [ ] Evidence: You have cross-checked the metadata types against the business requirements.
