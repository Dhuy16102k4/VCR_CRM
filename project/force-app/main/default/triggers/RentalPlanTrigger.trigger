trigger RentalPlanTrigger on Rental_Plan__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            RentalPlanTriggerHandler.checkDuplicates(Trigger.new, Trigger.oldMap);
        }
    }
}
