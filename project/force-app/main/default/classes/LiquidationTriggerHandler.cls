public class LiquidationTriggerHandler {
    public static void checkDuplicates(List<Liquidation__c> newRecords, Map<Id, Liquidation__c> oldMap) {
        Set<Id> contractIds = new Set<Id>();
        
        for (Liquidation__c liq : newRecords) {
            if (liq.Contract__c != null) {
                contractIds.add(liq.Contract__c);
            }
        }
        
        if (contractIds.isEmpty()) return;
        
        List<Liquidation__c> existingLiquidation = [
            SELECT Id, Contract__c 
            FROM Liquidation__c 
            WHERE Contract__c IN :contractIds
        ];
        
        Map<Id, Id> contractToLiquidation = new Map<Id, Id>();
        for (Liquidation__c existing : existingLiquidation) {
            contractToLiquidation.put(existing.Contract__c, existing.Id);
        }
        
        for (Liquidation__c liq : newRecords) {
            if (liq.Contract__c != null) {
                Id existingId = contractToLiquidation.get(liq.Contract__c);
                if (existingId != null && existingId != liq.Id) {
                    liq.Contract__c.addError('A Liquidation record already exists for this Contract.');
                }
            }
        }
    }
}
