@IsTest
public class LegalRecordsTest {

    @TestSetup
    static void setupTestData() {
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
            Name = 'Test Legal Account',
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

        // Setup Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Legal Opportunity',
            AccountId = acc.Id,
            Building__c = building.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
    }

    @IsTest
    static void testLegalRecordRule() {
        Test.startTest();
        // Insert Legal Record Rule
        Legal_Record_Rule__c rule = new Legal_Record_Rule__c(
            Customer__c = 'Tenant',
            Process_Name__c = 'Leasing',
            Stage_Name__c = 'Signing',
            Legal_Type__c = 'Business Registration',
            Legal_Type_Level_1__c = 'Business Registration'
        );
        insert rule;
        
        System.assertNotEquals(null, rule.Id, 'Legal Record Rule should be inserted successfully.');
        Test.stopTest();
    }
    
    @IsTest
    static void testLegalRecord() {
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Name = 'Test Legal Opportunity' LIMIT 1];
        
        Test.startTest();
        // Insert Legal Record
        Legal_Record__c lr = new Legal_Record__c(
            Account__c = opp.AccountId,
            Opportunity__c = opp.Id,
            Legal_Type__c = 'Business Registration',
            Legal_Type_Level_1__c = 'Business Registration',
            Legal_Record_Status__c = 'Not Submitted',
            Note__c = 'Test Note'
        );
        insert lr;
        
        System.assertNotEquals(null, lr.Id, 'Legal Record should be inserted successfully.');
        Test.stopTest();
    }
}
