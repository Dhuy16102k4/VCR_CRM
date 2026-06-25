# Apex Security & Performance Checklist

This is the standard checklist that ALL Apex development or review skills MUST reference. Do not skip any item.

## 1. SOQL & DML Limits (Bulkification)
- [ ] NO SOQL `[SELECT...]` statements inside `for` loops.
- [ ] NO DML statements (`insert`, `update`, `delete`, `upsert`) inside `for` loops.
- [ ] Use Collections (`List`, `Set`, `Map`) to gather IDs and perform DML outside of loops.

## 2. Security
- [ ] Added `with sharing` or `inherited sharing` keyword to class declaration.
- [ ] Checked FLS (Field-Level Security) and Object CRUD permissions before DML (Use `Schema.sObjectType...isCreateable()` or `stripInaccessible()`).
- [ ] Sanitized inputs when building Dynamic SOQL to prevent SOQL Injection (Use `String.escapeSingleQuotes()`).

## 3. Test Coverage & Quality
- [ ] Code coverage must be above 80%.
- [ ] Create Mock Data in test classes (use `@TestSetup`), do not use `@isTest(SeeAllData=true)`.
- [ ] Must contain `System.assertEquals()` or `System.assertNotEquals()` to validate behavior, not just run for coverage.

## 4. Error Handling
- [ ] Use `try-catch` blocks when calling External APIs or performing complex DML operations.
- [ ] Log errors instead of swallowing them (swallowing is catching an Exception but doing nothing).
