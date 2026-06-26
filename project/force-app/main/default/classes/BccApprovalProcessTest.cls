@isTest
public class BccApprovalProcessTest {
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
        
        // Create 2 Users for Approvers
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User approver1 = new User(Alias = 'app1', Email='approver1@test.com', 
            EmailEncodingKey='UTF-8', LastName='Approver 1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='approver1_vcr' + DateTime.now().getTime() + '@test.com');
            
        User approver2 = new User(Alias = 'app2', Email='approver2@test.com', 
            EmailEncodingKey='UTF-8', LastName='Approver 2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='approver2_vcr' + DateTime.now().getTime() + '@test.com');
            
        insert new List<User>{approver1, approver2};
        
        Submission_Report__c bcc = new Submission_Report__c(
            Opportunity__c = opp.Id,
            Status__c = 'Draft',
            Approval_Status__c = 'Request not submitted',
            Approver_Level_1__c = approver1.Id,
            Approver_Level_2__c = approver2.Id
        );
        insert bcc;
    }

    @isTest
    static void testBccApprovalProcess() {
        Submission_Report__c bcc = [SELECT Id, Status__c, Approval_Status__c, Approver_Level_1__c FROM Submission_Report__c LIMIT 1];
        System.assertEquals('Draft', bcc.Status__c, 'Initial status should be Draft');
        
        Test.startTest();
        // Submit for approval
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for approval.');
        req.setObjectId(bcc.Id);
        Approval.ProcessResult result = Approval.process(req);
        
        System.assert(result.isSuccess(), 'Submission should be successful');
        
        bcc = [SELECT Id, Status__c, Approval_Status__c FROM Submission_Report__c WHERE Id = :bcc.Id];
        System.assertEquals('In Review', bcc.Status__c, 'Status should be In Review');
        System.assertEquals('Request submitted', bcc.Approval_Status__c, 'Approval Status should be Request submitted');
        
        // Approve Level 1
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request L1.');
        req2.setAction('Approve');
        req2.setWorkitemId(newWorkItemIds.get(0));
        Approval.ProcessResult result2 = Approval.process(req2);
        
        System.assert(result2.isSuccess(), 'Approval L1 should be successful');
        
        bcc = [SELECT Id, Status__c, Approval_Status__c FROM Submission_Report__c WHERE Id = :bcc.Id];
        System.assertEquals('Approved Level 1', bcc.Approval_Status__c, 'Approval Status should be Approved Level 1');
        
        // Approve Level 2
        newWorkItemIds = result2.getNewWorkitemIds();
        Approval.ProcessWorkitemRequest req3 = new Approval.ProcessWorkitemRequest();
        req3.setComments('Approving request L2.');
        req3.setAction('Approve');
        req3.setWorkitemId(newWorkItemIds.get(0));
        Approval.ProcessResult result3 = Approval.process(req3);
        
        System.assert(result3.isSuccess(), 'Approval L2 should be successful');
        
        // Since there is no Level 3, it should be final approved
        bcc = [SELECT Id, Status__c, Approval_Status__c FROM Submission_Report__c WHERE Id = :bcc.Id];
        System.assertEquals('Approved Level 2', bcc.Approval_Status__c, 'Approval status should be Level 2 since Level 3 was skipped');
        System.assertEquals('Approved', bcc.Status__c, 'Status should be Approved');
        
        Test.stopTest();
    }
}
