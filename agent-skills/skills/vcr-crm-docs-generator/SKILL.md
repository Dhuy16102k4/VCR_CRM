---
name: vcr-crm-docs-generator
description: "Automation standards for creating and reviewing technical documentation for the VCR-CRM project."
category: documentation
risk: low
---

# VCR-CRM Documentation Generator

## Overview
Defines standards for AI to create, standardize, and review project documentation (URD, BRD, Data Dictionary, Master List) for the VCR-CRM system, ensuring consistency.

## When to Use
Trigger this skill whenever the user asks to generate, update, or format project documentation, data dictionaries, or markdown files.

## Process
You MUST follow this exact sequence:
1. **Language Enforcement:** Use 100% professional Vietnamese for the narrative, but KEEP Salesforce technical terms in English (e.g., Object, Field, Validation Rule, Page Layout).
2. **Object Documentation Structure:** Any object description MUST include:
   - Object Name (Label & API Name)
   - Field List (Label, API Name, Data Type, Required/Optional)
   - Bound Logic (Validation Rules, Duplicate Rules)
3. **Formatting:** Use Markdown Tables to list data fields for readability.
4. **Data Accuracy Check:** Cross-check with `PICKLIST_MASTER_LIST.md` (or other context) when handling Picklist fields.
5. **Anti-Hallucination:** NEVER invent data. If design information is missing, mark it explicitly as `[TBD - Cần confirm từ BA/Mentor]`.
6. **Revision History:** Ensure every document generated has a "Revision History" section at the top of the file.

## Anti-Rationalizations
| Agent Excuse | Rebuttal |
|--------------|----------|
| "I don't know the exact picklist values, so I'll just guess a few." | **WRONG.** No hallucination. Mark it as TBD if you are unsure. |
| "I'll translate 'Validation Rule' to 'Quy tắc xác thực'." | **WRONG.** Salesforce terms must remain in English to match the system Setup UI. |

## Verification
You cannot consider the task complete until you provide the following evidence:
- [ ] Evidence: The document uses Markdown tables for fields.
- [ ] Evidence: Missing information is explicitly marked as `[TBD]`.
- [ ] Evidence: A Revision History section is present.
