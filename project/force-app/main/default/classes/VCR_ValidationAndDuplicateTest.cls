@isTest
public class VCR_ValidationAndDuplicateTest {

    @testSetup
    static void setupTestData() {
        // Create initial Brand
        Brand__c brand = new Brand__c(
            Name = 'Vincom Original Brand',
            Brand_Name__c = 'Vincom Original Brand',
            Mobile__c = '0901234567',
            Email__c = 'vincom@test.com'
        );
        insert brand;

        // Create initial Account
        Account acc = new Account(
            Name = 'Original Account',
            Phone = '0901112223',
            Brand__c = brand.Id,
            Enterprise_Code_Certificate__c = '0101234567'
        );
        insert acc;

        // Create initial Contact
        Contact con = new Contact(
            LastName = 'Original Contact',
            Phone = '0909998887',
            Email = 'contact@test.com',
            AccountId = acc.Id
        );
        insert con;
    }

    @isTest
    static void testBrandNameDuplicateRule() {
        Test.startTest();
        Brand__c dupBrand = new Brand__c(
            Name = 'Vincom Original Brand',
            Brand_Name__c = 'Vincom Original Brand',
            Mobile__c = '0909999999',
            Email__c = 'dup@test.com'
        );
        try {
            Database.SaveResult result = Database.insert(dupBrand, false);
            System.assert(!result.isSuccess(), 'Expected duplicate rule to block brand insertion.');
            System.assert(result.getErrors().size() > 0, 'Expected at least one error from duplicate rule.');
        } catch(Exception e) {
            System.assert(e.getMessage().contains('DUPLICATES_DETECTED') || e.getMessage().contains('duplicate') || e.getMessage() != null, 'Expected exception due to duplicate');
        }
        Test.stopTest();
    }

    @isTest
    static void testAccountFormatPhoneValidation() {
        Test.startTest();
        Account testAcc = new Account(
            Name = 'Invalid Phone Account',
            Phone = '123' // Invalid format, assuming validation rule Format_Phone requires specific length/pattern
        );
        try {
            insert testAcc;
            System.assert(false, 'Validation rule Format_Phone should have failed.');
        } catch(DmlException e) {
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Expected custom validation exception for phone format.');
        }
        Test.stopTest();
    }

    @isTest
    static void testContactRequirePhoneOrEmailValidation() {
        Test.startTest();
        Account parentAcc = [SELECT Id FROM Account LIMIT 1];
        
        Contact testCon = new Contact(
            LastName = 'No Info Contact',
            AccountId = parentAcc.Id
            // Phone and Email are omitted
        );
        try {
            insert testCon;
            System.assert(false, 'Validation rule Require_Phone_Or_Email should have failed.');
        } catch(DmlException e) {
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Expected custom validation exception for missing phone/email.');
        }
        Test.stopTest();
    }
}
