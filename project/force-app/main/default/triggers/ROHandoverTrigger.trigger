trigger ROHandoverTrigger on RO_Handover__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            ROHandoverTriggerHandler.checkDuplicates(Trigger.new, Trigger.oldMap);
        }
    }
}
