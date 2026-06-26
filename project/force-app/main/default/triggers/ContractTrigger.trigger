trigger ContractTrigger on Contract (after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUndelete) {
            ContractTriggerHandler.calculateAccountRevenue(Trigger.new, null);
        }
        if (Trigger.isUpdate) {
            ContractTriggerHandler.calculateAccountRevenue(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            ContractTriggerHandler.calculateAccountRevenue(Trigger.old, null);
        }
    }
}
