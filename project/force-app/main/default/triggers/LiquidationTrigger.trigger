trigger LiquidationTrigger on Liquidation__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            LiquidationTriggerHandler.checkDuplicates(Trigger.new, Trigger.oldMap);
        }
    }
}
