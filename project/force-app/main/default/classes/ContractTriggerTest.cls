@isTest
public class ContractTriggerTest {
    @isTest
    static void testCalculateAccountRevenue() {
        // 1. Setup Test Data
        Account acc = new Account(Name = 'Test Account', Revenue__c = 0);
        insert acc;
        
        // 2. Perform actions inside Test.startTest() / Test.stopTest() to reset limits
        Test.startTest();
        
        Contract c1 = new Contract(
            AccountId = acc.Id, 
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 12,
            Rental_Price_1__c = 1000
        );
        Contract c2 = new Contract(
            AccountId = acc.Id, 
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 12,
            Rental_Price_1__c = 2000
        );
        insert new List<Contract>{c1, c2};
        
        // 3. Verify Insert
        Account updatedAcc = [SELECT Revenue__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(3000, updatedAcc.Revenue__c, 'Revenue should be sum of contracts (1000 + 2000)');
        
        // Update
        c1.Rental_Price_1__c = 1500;
        update c1;
        
        updatedAcc = [SELECT Revenue__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(3500, updatedAcc.Revenue__c, 'Revenue should be updated to 3500 (1500 + 2000)');
        
        // Delete
        delete c2;
        
        updatedAcc = [SELECT Revenue__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(1500, updatedAcc.Revenue__c, 'Revenue should drop to 1500 after deleting c2');
        
        Test.stopTest();
    }
}
