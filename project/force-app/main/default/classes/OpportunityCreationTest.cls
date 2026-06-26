@isTest
public class OpportunityCreationTest {
    @testSetup
    static void setupTestData() {
        // Create a Brand
        Brand__c brand = new Brand__c(
            Name = 'Test Brand'
        );
        insert brand;

        // Create an Account
        Account acc = new Account(
            Name = 'Test Account for Wizard',
            Tax_Code__c = '1234567890',
            Brand__c = brand.Id
        );
        insert acc;
    }

    @isTest
    static void testOpportunityCreationViaWizardLogic() {
        // This test simulates the DML performed by the Opportunity_Creation_Wizard Screen Flow.
        // It ensures that validation rules and triggers do not block the creation of an Opportunity
        // with the fields typically populated by the Wizard.
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Brand__c brand = [SELECT Id FROM Brand__c LIMIT 1];
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity from Wizard',
            StageName = 'Chào Khách',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            Brand_Name__c = brand.Id
        );
        
        Test.startTest();
        // Simulating the Create Records element in the Screen Flow
        insert opp;
        Test.stopTest();
        
        // Assert that the Opportunity was successfully created
        Opportunity insertedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertNotEquals(null, insertedOpp.Id, 'Opportunity should be created successfully.');
        System.assertEquals('Chào Khách', insertedOpp.StageName, 'Stage should be Chào Khách.');
    }
}
