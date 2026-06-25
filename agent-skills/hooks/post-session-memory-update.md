# Hook: Post-Session Memory Update

## Purpose
Ensure that work progress, newly discovered bugs, and next actions are recorded in `MEMORY.md` before the session ends. This prevents the AI in the next session from losing context.

## When to Trigger
- When the user says "Done with this part", "End session", or when a major module (like deploying a Phase) is completed.

## Process
1. **Analyze Changes:** Review the components coded, modified, or deployed in this session.
2. **Update MEMORY.md:**
   - Move completed tasks to the `✅ COMPLETED` section (along with created/updated files).
   - If new bugs are found, add them to `Known Script Bugs` or `Bug tracking`.
   - If a task is delayed or needs to continue, push it to `🚀 NEXT ACTIONS`.
3. **Propose to User:** Do not overwrite the file without asking. Show the proposed markdown snippet to be inserted into `MEMORY.md` and ask: "Would you like me to update MEMORY.md with this content?"

## Verification
- [ ] Evidence: Print the modified text for `MEMORY.md` on the chat screen.
- [ ] Evidence: Only execute the file edit tool when the user explicitly agrees.
