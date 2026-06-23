public class RentalPlanTriggerHandler {
    public static void checkDuplicates(List<Rental_Plan__c> newRecords, Map<Id, Rental_Plan__c> oldMap) {
        Set<Id> roIds = new Set<Id>();
        
        for (Rental_Plan__c plan : newRecords) {
            if (plan.RO_Name__c != null) {
                roIds.add(plan.RO_Name__c);
            }
        }
        
        if (roIds.isEmpty()) return;
        
        List<Rental_Plan__c> existingPlans = [
            SELECT Id, RO_Name__c 
            FROM Rental_Plan__c 
            WHERE RO_Name__c IN :roIds
        ];
        
        Map<Id, Id> roToPlan = new Map<Id, Id>();
        for (Rental_Plan__c existing : existingPlans) {
            roToPlan.put(existing.RO_Name__c, existing.Id);
        }
        
        for (Rental_Plan__c plan : newRecords) {
            if (plan.RO_Name__c != null) {
                Id existingId = roToPlan.get(plan.RO_Name__c);
                if (existingId != null && existingId != plan.Id) {
                    plan.RO_Name__c.addError('An active Rental Plan already exists for this RO.');
                }
            }
        }
    }
}
