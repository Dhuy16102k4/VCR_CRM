@IsTest
public class SalesTargetsTest {
    
    @TestSetup
    static void setupTestData() {
        // Create a user for Sales_Man__c
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='sales_target_user@vcr.com');
        insert u;
    }

    @IsTest
    static void testSalesActivityTarget() {
        User u = [SELECT Id FROM User WHERE UserName='sales_target_user@vcr.com' LIMIT 1];
        Test.startTest();
        // Insert Activity Target (Name is AutoNumber)
        Sales_Activity_Target__c sat = new Sales_Activity_Target__c(
            Sales_Man__c = u.Id,
            Date__c = Date.today(),
            Target_Month__c = Date.today(),
            New_Account_Target__c = 10,
            Sales_Call_Target__c = 20,
            Status__c = 'New'
        );
        insert sat;
        
        System.assertNotEquals(null, sat.Id, 'Sales Activity Target should be inserted successfully.');
        Test.stopTest();
    }
    
    @IsTest
    static void testSalesT3AchievementTarget() {
        User u = [SELECT Id FROM User WHERE UserName='sales_target_user@vcr.com' LIMIT 1];
        Test.startTest();
        // Insert T+3 Achievement Target (Name is AutoNumber)
        Sales_T_3_Achievement_Target__c t3Target = new Sales_T_3_Achievement_Target__c(
            Sales_Director__c = u.Id,
            Start_Date__c = Date.today(),
            Target_Month__c = Date.today(),
            Target_Type__c = 'TBD',
            Closing_Date__c = Date.today().addDays(10),
            Area_m2__c = 100,
            Unit_Price_VND_m2_Month__c = 500000
        );
        insert t3Target;
        
        System.assertNotEquals(null, t3Target.Id, 'Sales T+3 Achievement Target should be inserted successfully.');
        Test.stopTest();
    }
    
    @IsTest
    static void testSalesAdvertisingTarget() {
        User u = [SELECT Id FROM User WHERE UserName='sales_target_user@vcr.com' LIMIT 1];
        Test.startTest();
        // Insert Advertising Target (Name is Text)
        Sales_Advertising_Target__c adTarget = new Sales_Advertising_Target__c(
            Name = 'Advertising Target 2026',
            Sales_Man__c = u.Id,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(30),
            Target_Revenue__c = 1000000
        );
        insert adTarget;
        
        System.assertNotEquals(null, adTarget.Id, 'Sales Advertising Target should be inserted successfully.');
        Test.stopTest();
    }
}
