@isTest
public class SubmissionReportTriggerTest {
    @isTest
    static void testRollupActiveBccToOpportunity() {
        // Setup Brand
        Brand__c brand = new Brand__c(
            Name = 'Test Brand',
            Brand_Name__c = 'Test Brand',
            Main_Category__c = 'Fashion',
            Sub_Category__c = 'Fast Fashion',
            Mobile__c = '0901111222',
            Email__c = 'test@example.com'
        );
        insert brand;

        // Setup Account
        Id rtBiz = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Tenant').getRecordTypeId();
        Account acc = new Account(
            Name = 'Test Account',
            RecordTypeId = rtBiz,
            Phone = '0912345678',
            Status__c = 'Active',
            Brand__c = brand.Id
        );
        insert acc;
        
        // Setup Business Entity
        Id rtKPTM = Schema.SObjectType.Business_Entity__c.getRecordTypeInfosByDeveloperName().get('KPTM').getRecordTypeId();
        Business_Entity__c building = new Business_Entity__c(
            Name = 'Test Building',
            RecordTypeId = rtKPTM,
            BE_Type__c = 'KPTM'
        );
        insert building;

        // Create an Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = acc.Id,
            Building__c = building.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
        
        Test.startTest();
        // Insert 1 Active BCC (Status != 'Rejected', e.g. 'Draft')
        Submission_Report__c bcc1 = new Submission_Report__c(
            Opportunity__c = opp.Id,
            Status__c = 'Draft'
        );
        insert bcc1;
        
        // Assert count is 1
        Opportunity oppResult = [SELECT Active_BCC_Count__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(1, oppResult.Active_BCC_Count__c, 'BCC Count should be 1 after inserting an Active BCC');
        
        // Insert 1 Rejected BCC
        Submission_Report__c bcc2 = new Submission_Report__c(
            Opportunity__c = opp.Id,
            Status__c = 'Rejected'
        );
        insert bcc2;
        
        // Assert count is still 1
        oppResult = [SELECT Active_BCC_Count__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(1, oppResult.Active_BCC_Count__c, 'BCC Count should remain 1 after inserting a Rejected BCC');
        
        // Update the Rejected BCC to Approved
        bcc2.Status__c = 'Approved';
        update bcc2;
        
        // Assert count is 2
        oppResult = [SELECT Active_BCC_Count__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(2, oppResult.Active_BCC_Count__c, 'BCC Count should be 2 after changing Rejected to Approved');
        
        // Delete a BCC
        delete bcc1;
        
        // Assert count is 1
        oppResult = [SELECT Active_BCC_Count__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(1, oppResult.Active_BCC_Count__c, 'BCC Count should be 1 after deleting an Active BCC');
        
        Test.stopTest();
    }
}
