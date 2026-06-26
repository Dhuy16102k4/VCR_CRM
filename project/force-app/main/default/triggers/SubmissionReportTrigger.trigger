trigger SubmissionReportTrigger on Submission_Report__c (after insert, after update, after delete, after undelete) {
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
