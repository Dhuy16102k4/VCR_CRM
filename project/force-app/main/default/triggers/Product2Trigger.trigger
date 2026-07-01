trigger Product2Trigger on Product2 (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            Product2TriggerHandler.updateBEOccupancy(Trigger.new, Trigger.oldMap);
        }
    }
}
