trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            OpportunityTriggerHandler.validateClosedWonFields(Trigger.new, Trigger.oldMap);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            OpportunityTriggerHandler.syncInventoryStatus(Trigger.new, Trigger.oldMap);
            OpportunityTriggerHandler.triggerSAPAccountSync(Trigger.new, Trigger.oldMap);
        }
    }
}
