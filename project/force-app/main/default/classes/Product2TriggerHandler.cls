 public class Product2TriggerHandler {
    /**
     * @description Updates Business_Entity__c occupancy metrics when RO (Product2) status or area changes.
     * Related Spec: A1 — Auto-Update BE Occupancy khi RO thay đổi
     * @param newList List of new/updated Product2 records
     * @param oldMap Map of old Product2 records
     */
    public static void updateBEOccupancy(List<Product2> newList, Map<Id, Product2> oldMap) {
        Set<Id> beIds = new Set<Id>();
        
        for (Product2 prod : newList) {
            Product2 oldProd = oldMap != null ? oldMap.get(prod.Id) : null;
            
            // Collect BEs if Inventory Status, Area Indoor, or Area Outdoor changed
            if (prod.Business_Entity__c != null) {
                Boolean isChanged = oldProd == null 
                    || prod.Inventory_Status__c != oldProd.Inventory_Status__c 
                    || prod.Area_Indoor__c != oldProd.Area_Indoor__c 
                    || prod.Area_Outdoor__c != oldProd.Area_Outdoor__c;
                    
                if (isChanged) {
                    beIds.add(prod.Business_Entity__c);
                }
            }
        }
        
        if (beIds.isEmpty()) return;
        
        // Query all related products for the affected BEs
        List<Product2> relatedProducts = [
            SELECT Id, Business_Entity__c, RecordType.DeveloperName, Total_Area__c, Inventory_Status__c
            FROM Product2
            WHERE Business_Entity__c IN :beIds
        ];
        
        Map<Id, Business_Entity__c> beUpdates = new Map<Id, Business_Entity__c>();
        
        for (Id beId : beIds) {
            Decimal totalCommittedLeasedArea = 0;
            Decimal totalAdCount = 0;
            Decimal committedAdCount = 0;
            
            for (Product2 prod : relatedProducts) {
                if (prod.Business_Entity__c == beId) {
                    // Shopping Mall RO logic
                    if (prod.RecordType.DeveloperName == 'RO_TTTM' || prod.RecordType.DeveloperName == 'Shop_KPTM') {
                        if (prod.Inventory_Status__c == 'Committed' || prod.Inventory_Status__c == 'Deposited' || prod.Inventory_Status__c == 'Leased') {
                            totalCommittedLeasedArea += (prod.Total_Area__c != null ? prod.Total_Area__c : 0);
                        }
                    }
                    // Ad Location logic
                    if (prod.RecordType.DeveloperName == 'Ad_Location') {
                        totalAdCount++;
                        if (prod.Inventory_Status__c == 'Committed' || prod.Inventory_Status__c == 'Deposited' || prod.Inventory_Status__c == 'Leased') {
                            committedAdCount++;
                        }
                    }
                }
            }
            
            beUpdates.put(beId, new Business_Entity__c(
                Id = beId,
                Total_Committed_Leased_Area__c = totalCommittedLeasedArea,
                Total_Ad_Location_Count__c = totalAdCount,
                Committed_Ad_Location_Count__c = committedAdCount
            ));
        }
        
        if (!beUpdates.isEmpty()) {
            update beUpdates.values();
        }
    }
}
