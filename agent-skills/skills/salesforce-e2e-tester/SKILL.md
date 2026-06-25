---
name: salesforce-e2e-tester
description: "Design End-to-End (E2E) Testing scenarios and Mock Data for the Salesforce VCR-CRM project."
category: testing
risk: low
---

# Salesforce E2E Testing Guidelines

## Overview
Generates practical test scenarios (Test Cases) or Mock Data generation scripts to prove that Validation Rules, Dependent Picklists, and Record Types work smoothly on the Salesforce UI. This is mandatory for User Acceptance Testing (UAT).

## When to Use
Trigger this skill whenever the user asks for test cases, UAT scenarios, or scripts to generate mock data.

## Process
You MUST follow this exact sequence:
1. **Realistic Mock Data Generation:** Create data that reflects real business contexts (e.g., Names like "Vincom Retail", "Advertising Business", Phone "0901234567"). NEVER use garbage data like "Test 1" or "ABC".
2. **Dependency Management:** When testing child objects (like Business Entity), ensure you first create the parent object data (Account/Brand).
3. **Negative Scenarios (Error Catching):** Include at least 2 test scenarios that intentionally violate Validation Rules (e.g., Phone contains letters, Brand is blank when the Record Type requires it) to prove the system correctly blocks invalid data.
4. **Output Generation:** 
   - Present test steps in a standard structure: `Pre-conditions` -> `Test Steps` -> `Expected Result`.
   - Provide an Apex Anonymous Script or SOQL Script so the Developer can easily copy, run, and generate data quickly.

## Anti-Rationalizations
| Agent Excuse | Rebuttal |
|--------------|----------|
| "I'll just use 'Test Account' to save time." | **WRONG.** Garbage data makes UAT look unprofessional. Use realistic Vietnamese business data. |
| "I only need to test the happy path." | **WRONG.** You must include negative scenarios to prove validation rules work. |

## Verification
You cannot consider the task complete until you provide the following evidence:
- [ ] Evidence: At least 2 negative test scenarios are included.
- [ ] Evidence: A runnable Apex Anonymous script or SOQL snippet is provided for mock data generation.
