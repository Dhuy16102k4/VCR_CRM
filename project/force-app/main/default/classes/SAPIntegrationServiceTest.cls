@isTest
private class SAPIntegrationServiceTest {
    
    @testSetup
    static void setupTestData() {
        Brand__c brand = new Brand__c(
            Name = 'Test Brand',
            Brand_Name__c = 'Test Brand VCR',
            Mobile__c = '0901234560',
            Email__c = 'testbrand@vcr.com'
        );
        insert brand;

        Account testAcc = new Account(
            Name = 'Test Vincom Retail',
            Tax_Code__c = '0101234567',
            Enterprise_Code_Certificate__c = '0101234567',
            Phone = '0901234567',
            Email__c = 'test@vincom.com.vn',
            BillingStreet = '72 Le Thanh Ton',
            BillingCity = 'Ho Chi Minh',
            Brand__c = brand.Id
        );
        insert testAcc;
    }
    
    @isTest
    static void testSyncAccountToSAP_Success() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new SAPIntegrationServiceMock(true));
        
        Test.startTest();
        SAPIntegrationService.syncAccountToSAP(new Set<Id>{acc.Id});
        Test.stopTest();
        
        List<Integration_Log__c> logs = [SELECT Id, Status__c, Request_Payload__c, Response_Payload__c FROM Integration_Log__c];
        System.assertEquals(1, logs.size(), 'Should create exactly 1 log');
        System.assertEquals('Success', logs[0].Status__c, 'Status should be Success');
        System.assert(logs[0].Request_Payload__c.contains('0101234567'), 'Payload should contain Tax Code');
    }
    
    @isTest
    static void testSyncAccountToSAP_Failed() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new SAPIntegrationServiceMock(false));
        
        Test.startTest();
        SAPIntegrationService.syncAccountToSAP(new Set<Id>{acc.Id});
        Test.stopTest();
        
        List<Integration_Log__c> logs = [SELECT Id, Status__c, Error_Message__c FROM Integration_Log__c];
        System.assertEquals(1, logs.size(), 'Should create exactly 1 log');
        System.assertEquals('Failed', logs[0].Status__c, 'Status should be Failed');
        System.assert(logs[0].Error_Message__c.contains('HTTP 400'), 'Error message should contain HTTP 400');
    }
}
