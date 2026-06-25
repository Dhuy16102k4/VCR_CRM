---
name: salesforce-apex-dev
description: "Apex programming and optimization standards (Classes, Triggers, Unit Tests) for the Salesforce project."
category: development
risk: medium
---

# Salesforce Apex Development

## Overview
Ensures that all Apex code generated or reviewed by the AI (e.g., business logic for Account, Brand, Opportunity) meets Salesforce's strict standards: Secure, Bulkified, and Maintainable.

## When to Use
Trigger this skill whenever the user asks you to write, modify, or review Apex code (`.cls`, `.trigger` files) or Unit Tests.

## Process
You MUST follow this exact sequence:

1. **Governor Limit Analysis:** Before writing any code, output a brief thought process analyzing potential data volumes (SOQL/DML limits, Heap size constraints). 
2. **Bulkification Implementation:** 
   - Write the code ensuring NO SOQL or DML operations occur inside a `for` loop.
   - Use `List`, `Set`, and `Map` collections to gather data before performing DML.
3. **Trigger Pattern Enforcement:**
   - If writing a Trigger, strictly follow the "One Trigger Per Object" pattern.
   - Delegate all logic to a separate Handler class (e.g., `AccountTriggerHandler`).
4. **Documentation:** Automatically add standard JavaDoc/Docstring comments at the top of every Class and Method to explain the business logic.
5. **Test-Driven Verification:** Write the corresponding Unit Test class using `@isTest`.
   - Use `Test.startTest()` and `Test.stopTest()`.
   - Include meaningful `System.assertEquals()` or `System.assertNotEquals()` statements.
6. **Reference Security:** Cross-check your code against `references/apex-security-checklist.md` to ensure sharing rules and FLS are handled.

## Anti-Rationalizations
| Agent Excuse | Rebuttal |
|--------------|----------|
| "This logic only updates one record, so I don't need collections." | **WRONG.** In Salesforce, a trigger might process 200 records at once via DataLoader. Everything must be bulkified. |
| "Writing assertions takes too much token output, I'll just run it for coverage." | **WRONG.** Tests without assertions are useless. You must prove the logic works. |
| "The user didn't ask for a Handler class, so I'll put the logic in the Trigger." | **WRONG.** The One Trigger Per Object pattern is non-negotiable. Delegate the logic. |

## Verification
You cannot consider the task complete until you provide the following evidence:
- [ ] Evidence: You have successfully executed the `run_apex_test` MCP tool on the newly written test class.
- [ ] Evidence: The output of the test execution is `PASS` and the code coverage is `>= 80%`. (Print the exact test results for the user to see).
