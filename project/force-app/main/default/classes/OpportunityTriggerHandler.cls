/**
 * @description Handler for Opportunity Trigger. Enforces validation rules and bulkified logic.
 */
public class OpportunityTriggerHandler {
    
    /**
     * @description Validates that required fields are populated when Opportunity moves to Closed Won.
     * This prevents runtime errors in the 'Opportunity Closed Won Automation' Flow which maps these fields to Contract.
     * @param newList List of new/updated Opportunities
     * @param oldMap Map of old Opportunities
     */
    public static void validateClosedWonFields(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        for (Opportunity opp : newList) {
            Opportunity oldOpp = oldMap != null ? oldMap.get(opp.Id) : null;
            
            // Check if stage is changing to Closed Won
            Boolean isChangingToClosedWon = (opp.StageName == 'Closed Won') && 
                                            (oldOpp == null || oldOpp.StageName != 'Closed Won');
                                            
            if (isChangingToClosedWon) {
                if (opp.Duration_Month__c == null) {
                    opp.Duration_Month__c.addError('Vui lòng nhập Duration (Month) trước khi chuyển sang Closed Won để tự động tạo Contract.');
                }
                if (opp.RO_Handover_Date__c == null) {
                    opp.RO_Handover_Date__c.addError('Vui lòng nhập RO Handover Date trước khi chuyển sang Closed Won để tự động tạo Contract.');
                }
            }
        }
    }
    
    /**
     * @description Synchronizes the Inventory Status of the related RO (Product2) based on Opportunity Stage changes.
     * Related Spec: A3 — Auto-Update Inventory_Status khi Opp đổi Stage
     * @param newList List of new/updated Opportunities
     * @param oldMap Map of old Opportunities
     */
    public static void syncInventoryStatus(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Map<Id, Product2> productsToUpdate = new Map<Id, Product2>();

        for (Opportunity opp : newList) {
            Opportunity oldOpp = oldMap != null ? oldMap.get(opp.Id) : null;
            
            // StageName is changed and RO__c is not null
            if (opp.RO__c != null && opp.StageName != null && 
                (oldOpp == null || opp.StageName != oldOpp.StageName)) {
                
                String newStatus = null;
                Boolean isClosedLost = false;

                switch on opp.StageName {
                    when 'Prospecting', 'Site Survey' {
                        newStatus = 'Vacant';
                    }
                    when 'Negotiation' {
                        newStatus = 'Negotiating';
                    }
                    when 'Closing' {
                        newStatus = 'Committed';
                    }
                    when 'Contract Deposit' {
                        newStatus = 'Deposited';
                    }
                    when 'Closed Won' {
                        newStatus = 'Leased';
                    }
                    when 'Closed Lost' {
                        newStatus = 'Vacant';
                        isClosedLost = true;
                    }
                }

                if (newStatus != null) {
                    Product2 prod = productsToUpdate.containsKey(opp.RO__c) 
                        ? productsToUpdate.get(opp.RO__c) 
                        : new Product2(Id = opp.RO__c);
                    
                    prod.Inventory_Status__c = newStatus;
                    
                    if (isClosedLost) {
                        prod.Latest_Committed_Date__c = Date.today();
                    }
                    
                    productsToUpdate.put(prod.Id, prod);
                }
            }
        }

        if (!productsToUpdate.isEmpty()) {
            update productsToUpdate.values();
        }
    }
    
    /**
     * @description Synchronizes Account data to SAP when Opportunity moves to 'Cọc'
     * @param newList List of new/updated Opportunities
     * @param oldMap Map of old Opportunities
     */
    public static void triggerSAPAccountSync(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> accountIdsToSync = new Set<Id>();
        
        for (Opportunity opp : newList) {
            Opportunity oldOpp = oldMap != null ? oldMap.get(opp.Id) : null;
            
            // If stage changed to 'Contract Deposit'
            if (opp.StageName == 'Contract Deposit' && (oldOpp == null || oldOpp.StageName != 'Contract Deposit')) {
                if (opp.AccountId != null) {
                    accountIdsToSync.add(opp.AccountId);
                }
            }
        }
        
        if (!accountIdsToSync.isEmpty()) {
            SAPIntegrationService.syncAccountToSAP(accountIdsToSync);
        }
    }
}
