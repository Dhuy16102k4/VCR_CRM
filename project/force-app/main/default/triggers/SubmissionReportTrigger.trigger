trigger SubmissionReportTrigger on Submission_Report__c (
    before insert,
    before update,
    after insert,
    after update,
    after delete,
    after undelete
) {
    // ── BEFORE ────────────────────────────────────────────────────────────────
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            // Validate entry criteria on new BCC creation
            SubmissionReportTriggerHandler.validateEntryBeforeSubmission(Trigger.new, null);
        }
        if (Trigger.isUpdate) {
            // Validate entry criteria when Status changes away from Draft
            SubmissionReportTriggerHandler.validateEntryBeforeSubmission(Trigger.new, Trigger.oldMap);
            // Block edits on protected fields while record is In Review / Approved
            SubmissionReportTriggerHandler.preventEditWhileInReview(Trigger.new, Trigger.oldMap);
        }
    }

    // ── AFTER ─────────────────────────────────────────────────────────────────
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUndelete) {
            SubmissionReportTriggerHandler.rollupActiveBccToOpportunity(Trigger.new, null);
        }
        if (Trigger.isUpdate) {
            SubmissionReportTriggerHandler.rollupActiveBccToOpportunity(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            SubmissionReportTriggerHandler.rollupActiveBccToOpportunity(null, Trigger.oldMap);
        }
    }
}
