public class ROHandoverTriggerHandler {
    public static void checkDuplicates(List<RO_Handover__c> newRecords, Map<Id, RO_Handover__c> oldMap) {
        Set<Id> oppIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();
        
        for (RO_Handover__c ro : newRecords) {
            // Only check if Stage is not 'RO Completed'
            if (ro.Stage__c != 'RO Completed') {
                if (ro.Opportunity__c != null) oppIds.add(ro.Opportunity__c);
                if (ro.Contract__c != null) contractIds.add(ro.Contract__c);
            }
        }
        
        if (oppIds.isEmpty() && contractIds.isEmpty()) return;
        
        // Query existing active handovers
        List<RO_Handover__c> existingHandovers = [
            SELECT Id, Opportunity__c, Contract__c 
            FROM RO_Handover__c 
            WHERE (Opportunity__c IN :oppIds OR Contract__c IN :contractIds)
            AND Stage__c != 'RO Completed'
        ];
        
        Map<Id, Id> oppToHandover = new Map<Id, Id>();
        Map<Id, Id> contractToHandover = new Map<Id, Id>();
        
        for (RO_Handover__c existing : existingHandovers) {
            if (existing.Opportunity__c != null) oppToHandover.put(existing.Opportunity__c, existing.Id);
            if (existing.Contract__c != null) contractToHandover.put(existing.Contract__c, existing.Id);
        }
        
        for (RO_Handover__c ro : newRecords) {
            if (ro.Stage__c != 'RO Completed') {
                Id existingIdByOpp = ro.Opportunity__c != null ? oppToHandover.get(ro.Opportunity__c) : null;
                Id existingIdByContract = ro.Contract__c != null ? contractToHandover.get(ro.Contract__c) : null;
                
                if (existingIdByOpp != null && existingIdByOpp != ro.Id) {
                    ro.Opportunity__c.addError('An active RO Handover already exists for this Opportunity.');
                }
                else if (existingIdByContract != null && existingIdByContract != ro.Id) {
                    ro.Contract__c.addError('An active RO Handover already exists for this Contract.');
                }
            }
        }
    }
}
