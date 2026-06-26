/**
 * @description Handler for Submission_Report__c trigger. Enforces One Trigger Per Object pattern.
 * Performs bulkified operations such as rolling up active BCC counts to Opportunity.
 */
public class SubmissionReportTriggerHandler {
    
    /**
     * @description Calculates the number of Active Submission Reports and updates the parent Opportunity.
     * "Active" is defined as Status__c != 'Rejected'.
     * @param newList List of new/updated Submission Reports
     * @param oldMap Map of old Submission Reports before update
     */
    public static void rollupActiveBccToOpportunity(List<Submission_Report__c> newList, Map<Id, Submission_Report__c> oldMap) {
        Set<Id> oppIds = new Set<Id>();
        
        // 1. Gather all affected Opportunity Ids
        if (newList != null) {
            for (Submission_Report__c bcc : newList) {
                if (bcc.Opportunity__c != null) {
                    if (oldMap == null) {
                        // Insert
                        oppIds.add(bcc.Opportunity__c);
                    } else {
                        // Update - check if Opportunity__c or Status__c changed
                        Submission_Report__c oldBcc = oldMap.get(bcc.Id);
                        if (bcc.Opportunity__c != oldBcc.Opportunity__c || bcc.Status__c != oldBcc.Status__c) {
                            oppIds.add(bcc.Opportunity__c);
                            if (oldBcc.Opportunity__c != null && bcc.Opportunity__c != oldBcc.Opportunity__c) {
                                oppIds.add(oldBcc.Opportunity__c); // Recalculate old opportunity if reparented
                            }
                        }
                    }
                } else if (oldMap != null && oldMap.get(bcc.Id).Opportunity__c != null) {
                     // For reparented to null
                     oppIds.add(oldMap.get(bcc.Id).Opportunity__c);
                }
            }
        }
        
        if (oldMap != null && newList == null) {
            // Delete
            for (Submission_Report__c bcc : oldMap.values()) {
                if (bcc.Opportunity__c != null) {
                    oppIds.add(bcc.Opportunity__c);
                }
            }
        }
        
        // 2. Perform ONE bulk SOQL query to aggregate values
        if (!oppIds.isEmpty()) {
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            Map<Id, Integer> oppBccCountMap = new Map<Id, Integer>();
            
            // Initialize with 0
            for (Id oppId : oppIds) {
                oppBccCountMap.put(oppId, 0);
            }
            
            // Query count of active BCCs
            for (AggregateResult ar : [
                SELECT Opportunity__c, COUNT(Id) totalBcc 
                FROM Submission_Report__c 
                WHERE Opportunity__c IN :oppIds 
                AND Status__c != 'Rejected'
                GROUP BY Opportunity__c
            ]) {
                oppBccCountMap.put((Id)ar.get('Opportunity__c'), (Integer)ar.get('totalBcc'));
            }
            
            // 3. Perform ONE bulk DML update
            for (Id oppId : oppBccCountMap.keySet()) {
                oppsToUpdate.add(new Opportunity(
                    Id = oppId,
                    Active_BCC_Count__c = oppBccCountMap.get(oppId)
                ));
            }
            
            if (!oppsToUpdate.isEmpty()) {
                update oppsToUpdate;
            }
        }
    }
}
