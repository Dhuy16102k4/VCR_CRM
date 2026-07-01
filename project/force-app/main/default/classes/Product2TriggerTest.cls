@isTest
private class Product2TriggerTest {
    
    @testSetup
    static void setupTestData() {
        // Create Business Entity
        Business_Entity__c be = new Business_Entity__c(
            Name = 'Vincom Test Mall'
        );
        insert be;
        
        // Get RO_TTTM record type
        Id roRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('RO_TTTM').getRecordTypeId();
        Id adRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Ad_Location').getRecordTypeId();
        
        List<Product2> products = new List<Product2>{
            new Product2(
                Name = 'Shop A01',
                RecordTypeId = roRecordTypeId,
                Business_Entity__c = be.Id,
                Inventory_Status__c = 'Vacant',
                Total_Area__c = 100,
                IsActive = true
            ),
            new Product2(
                Name = 'Shop A02',
                RecordTypeId = roRecordTypeId,
                Business_Entity__c = be.Id,
                Inventory_Status__c = 'Vacant',
                Total_Area__c = 150,
                IsActive = true
            ),
            new Product2(
                Name = 'Ad Location 01',
                RecordTypeId = adRecordTypeId,
                Business_Entity__c = be.Id,
                Inventory_Status__c = 'Vacant',
                IsActive = true
            )
        };
        insert products;
    }
    
    @isTest
    static void testUpdateBEOccupancy_WhenRoBecomesLeased() {
        Business_Entity__c be = [SELECT Id FROM Business_Entity__c LIMIT 1];
        Product2 shop = [SELECT Id FROM Product2 WHERE Name = 'Shop A01' LIMIT 1];
        
        Test.startTest();
        shop.Inventory_Status__c = 'Leased';
        update shop;
        Test.stopTest();
        
        Business_Entity__c updatedBe = [SELECT Total_Committed_Leased_Area__c FROM Business_Entity__c WHERE Id = :be.Id];
        System.assertEquals(100, updatedBe.Total_Committed_Leased_Area__c, 'BE occupancy should include leased shop area');
    }
    
    @isTest
    static void testUpdateBEOccupancy_AdLocationCommitted() {
        Business_Entity__c be = [SELECT Id FROM Business_Entity__c LIMIT 1];
        Product2 ad = [SELECT Id FROM Product2 WHERE Name = 'Ad Location 01' LIMIT 1];
        
        Test.startTest();
        ad.Inventory_Status__c = 'Committed';
        update ad;
        Test.stopTest();
        
        Business_Entity__c updatedBe = [SELECT Committed_Ad_Location_Count__c, Total_Ad_Location_Count__c FROM Business_Entity__c WHERE Id = :be.Id];
        System.assertEquals(1, updatedBe.Total_Ad_Location_Count__c, 'Total Ad count should be 1');
        System.assertEquals(1, updatedBe.Committed_Ad_Location_Count__c, 'Committed Ad count should be 1');
    }
    
    @isTest
    static void testUpdateBEOccupancy_NoChangeWhenStatusUnchanged() {
        Business_Entity__c be = [SELECT Total_Committed_Leased_Area__c FROM Business_Entity__c LIMIT 1];
        Product2 shop = [SELECT Id FROM Product2 WHERE Name = 'Shop A01' LIMIT 1];
        
        Test.startTest();
        // Update a different field that does not trigger occupancy recalc
        shop.Name = 'Shop A01 Updated';
        update shop;
        Test.stopTest();
        
        Business_Entity__c updatedBe = [SELECT Total_Committed_Leased_Area__c FROM Business_Entity__c WHERE Id = :be.Id];
        System.assertEquals(be.Total_Committed_Leased_Area__c, updatedBe.Total_Committed_Leased_Area__c, 'Occupancy should not change');
    }
}
