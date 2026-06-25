---
name: python-excel-automation
description: "Standards for writing secure, clean, and high-performance Python code for Excel processing."
category: development
risk: low
---

# Python Excel Automation

## Overview
Ensures that Python source code for reading/writing Excel files (like `read_excel.py`, `update_excel.py`) achieves high performance, is easy to maintain, and prevents memory leaks.

## When to Use
Trigger this skill whenever the user asks you to generate or review Python scripts that interact with Excel files or data manipulation.

## Process
You MUST follow this exact sequence:
1. **Library Selection:**
   - Use `pandas` for analyzing and aggregating large datasets.
   - Use `openpyxl` when you need to preserve Excel formatting and colors.
2. **Error Handling Implementation:** Wrap all file I/O operations in a `try...except` block. Catch specific errors like `FileNotFoundError` or `PermissionError` (when the file is open in another app).
3. **Resource Management:** Ensure streams are closed automatically by using context managers like `with pd.ExcelWriter(...)`.
4. **Code Quality Enhancements:**
   - Add Python Type Hinting (e.g., `def process(file_path: str) -> bool:`).
   - Add Docstrings explaining the function's purpose.
   - Use the `logging` module instead of `print()` to track the process of reading/writing rows.
5. **Modularity Check:** Propose splitting the function if a single function exceeds 50 lines of code.

## Anti-Rationalizations
| Agent Excuse | Rebuttal |
|--------------|----------|
| "I'll just use print() for debugging, it's faster." | **WRONG.** Professional code requires the `logging` module for traceability. |
| "I'll just use open(file) without a context manager." | **WRONG.** Always use `with` statements to prevent resource and memory leaks. |

## Verification
You cannot consider the task complete until you provide the following evidence:
- [ ] Evidence: Type hints and docstrings are present in all functions.
- [ ] Evidence: The `logging` module is used instead of `print()`.
- [ ] Evidence: File I/O uses context managers (`with` statements) and `try...except` blocks.
