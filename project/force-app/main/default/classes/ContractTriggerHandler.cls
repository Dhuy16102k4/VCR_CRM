public class ContractTriggerHandler {
    /**
     * @description Bulkified method to roll up Contract Revenue to the Account's Revenue__c field.
     * Evaluates only contracts that have changed to save DML operations.
     */
    public static void calculateAccountRevenue(List<Contract> newContracts, Map<Id, Contract> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        
        // 1. Gather all affected Account Ids
        for (Contract c : newContracts) {
            if (c.AccountId != null) {
                // For insert (oldMap == null) or update where revenue changes
                if (oldMap == null || c.Rental_Price_1__c != oldMap.get(c.Id).Rental_Price_1__c || c.AccountId != oldMap.get(c.Id).AccountId) {
                    accountIds.add(c.AccountId);
                    if (oldMap != null && oldMap.get(c.Id).AccountId != null && c.AccountId != oldMap.get(c.Id).AccountId) {
                        accountIds.add(oldMap.get(c.Id).AccountId); // Recalculate old account if reparented
                    }
                }
            } else if (oldMap != null && oldMap.get(c.Id).AccountId != null) {
                // For delete or reparented to null
                accountIds.add(oldMap.get(c.Id).AccountId);
            }
        }
        
        // 2. Perform ONE bulk SOQL query to aggregate values
        if (!accountIds.isEmpty()) {
            List<Account> accsToUpdate = new List<Account>();
            
            // Map to store results to ensure we update accounts that drop to 0 revenue
            Map<Id, Decimal> accountRevMap = new Map<Id, Decimal>();
            for (Id accId : accountIds) {
                accountRevMap.put(accId, 0); // Initialize with 0
            }
            
            for (AggregateResult ar : [
                SELECT AccountId, SUM(Rental_Price_1__c) totalRev 
                FROM Contract 
                WHERE AccountId IN :accountIds AND Rental_Price_1__c != null 
                GROUP BY AccountId
            ]) {
                accountRevMap.put((Id)ar.get('AccountId'), (Decimal)ar.get('totalRev'));
            }
            
            // 3. Perform ONE bulk DML update
            for (Id accId : accountRevMap.keySet()) {
                accsToUpdate.add(new Account(
                    Id = accId,
                    Revenue__c = accountRevMap.get(accId)
                ));
            }
            
            if (!accsToUpdate.isEmpty()) {
                update accsToUpdate;
            }
        }
    }
}
