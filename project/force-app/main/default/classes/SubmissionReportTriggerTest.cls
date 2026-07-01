/**
 * @description Test class for SubmissionReportTriggerHandler.
 * Covers all scenarios from the BCC Approval Process Spec:
 *   docs/07_automation/05_bcc_approval_process_spec.md
 *
 * Test Map:
 *   testRollupActiveBccToOpportunity      → SECTION 1: rollup logic
 *   testValidateEntryOnInsert_MissingOpp  → R1 — missing Opportunity on insert
 *   testValidateEntryOnInsert_MissingAcc  → R1 — missing Account on insert
 *   testValidateEntryPassesWhenValid      → happy path insert
 *   testValidateEntryOnStatusChange       → R1 — Account cleared before status change
 *   testPreventEditOppWhileInReview       → R2 — block Opp change on locked record (non-admin)
 *   testAdminCanEditWhileInReview         → Admin bypass — always allowed
 *   testAllowEditWhenDraft               → no restriction on Draft records
 */
@isTest
private class SubmissionReportTriggerTest {

    // ─────────────────────────────────────────────────────────────────────────
    // TEST DATA FACTORY
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * @description Creates the minimum set of records required for BCC tests.
     * Returns a map with keys: 'account', 'opportunity'.
     */
    private static Map<String, SObject> createBaseData() {
        Brand__c brand = new Brand__c(
            Name          = 'Test Brand',
            Brand_Name__c = 'Test Brand',
            Main_Category__c = 'Fashion',
            Sub_Category__c  = 'Fast Fashion',
            Mobile__c     = '0901111222',
            Email__c      = 'test@example.com'
        );
        insert brand;

        Id rtBiz = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get('Business_Tenant')
            .getRecordTypeId();
        Account acc = new Account(
            Name         = 'Test Account',
            RecordTypeId = rtBiz,
            Phone        = '0912345678',
            Status__c    = 'Active',
            Brand__c     = brand.Id,
            Tax_Code__c  = 'TX12345678',
            Enterprise_Code_Certificate__c = 'ENT123456'
        );
        insert acc;

        Id rtKPTM = Schema.SObjectType.Business_Entity__c
            .getRecordTypeInfosByDeveloperName()
            .get('KPTM')
            .getRecordTypeId();
        Business_Entity__c building = new Business_Entity__c(
            Name         = 'Test Building',
            RecordTypeId = rtKPTM,
            BE_Type__c   = 'KPTM'
        );
        insert building;

        Opportunity opp = new Opportunity(
            Name      = 'Test Opp',
            AccountId = acc.Id,
            Building__c = building.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        return new Map<String, SObject>{
            'account'     => acc,
            'opportunity' => opp,
            'building'    => building
        };
    }

    /** @description Creates a non-admin Standard User for permission boundary tests. */
    private static User createStandardUser(String suffix) {
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias             = 'sr' + suffix,
            Email             = 'salesrep' + suffix + '@test.com',
            EmailEncodingKey  = 'UTF-8',
            LastName          = 'SalesRep' + suffix,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey      = 'en_US',
            ProfileId         = stdProfile.Id,
            TimeZoneSidKey    = 'America/Los_Angeles',
            UserName          = 'salesrep' + suffix + '_vcr' + DateTime.now().getTime() + '@test.com'
        );
        insert u;
        return u;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // SECTION 1: ROLLUP TESTS
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * @description Verifies Active_BCC_Count__c on Opportunity is correctly
     * maintained across insert, status change, and delete operations.
     * Covers Spec Scenarios: T01, T06.
     */
    @isTest
    static void testRollupActiveBccToOpportunity() {
        Map<String, SObject> base = createBaseData();
        Opportunity opp = (Opportunity) base.get('opportunity');
        Account acc     = (Account) base.get('account');

        Test.startTest();

        // Insert 1 Active BCC (Status != 'Rejected')
        Submission_Report__c bcc1 = new Submission_Report__c(
            Opportunity__c = opp.Id,
            Account__c     = acc.Id,
            Status__c      = 'Draft'
        );
        insert bcc1;

        Opportunity result = [SELECT Active_BCC_Count__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(1, result.Active_BCC_Count__c, 'Count should be 1 after inserting Active BCC');

        // Insert 1 Rejected BCC — should NOT increase count
        Submission_Report__c bcc2 = new Submission_Report__c(
            Opportunity__c = opp.Id,
            Account__c     = acc.Id,
            Status__c      = 'Rejected'
        );
        insert bcc2;

        result = [SELECT Active_BCC_Count__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(1, result.Active_BCC_Count__c, 'Count should remain 1 after inserting Rejected BCC');

        // Change Rejected BCC → Approved → becomes active
        bcc2.Status__c = 'Approved';
        update bcc2;

        result = [SELECT Active_BCC_Count__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(2, result.Active_BCC_Count__c, 'Count should be 2 after Rejected → Approved');

        // Delete first BCC
        delete bcc1;

        result = [SELECT Active_BCC_Count__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(1, result.Active_BCC_Count__c, 'Count should be 1 after deleting one Active BCC');

        Test.stopTest();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // SECTION 2: ENTRY VALIDATION TESTS (Addresses Spec Risks R1 & R2)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * @description T09 — Inserting a BCC without Opportunity must throw a meaningful error.
     * Addresses Risk R1: prevents orphaned BCC from entering the approval process.
     */
    @isTest
    static void testValidateEntryOnInsert_MissingOpportunity() {
        Map<String, SObject> base = createBaseData();
        Account acc = (Account) base.get('account');

        Test.startTest();
        Submission_Report__c bcc = new Submission_Report__c(
            Account__c = acc.Id,
            Status__c  = 'Draft'
            // Opportunity__c intentionally omitted
        );
        try {
            insert bcc;
            System.assert(false, 'Expected DmlException was not thrown');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('BCC phải được gắn với một Opportunity'),
                'Error should mention Opportunity requirement. Got: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    /**
     * @description T09 — Inserting a BCC without Account must throw a meaningful error.
     */
    @isTest
    static void testValidateEntryOnInsert_MissingAccount() {
        Map<String, SObject> base = createBaseData();
        Opportunity opp = (Opportunity) base.get('opportunity');

        Test.startTest();
        Submission_Report__c bcc = new Submission_Report__c(
            Opportunity__c = opp.Id,
            Status__c      = 'Draft'
            // Account__c intentionally omitted
        );
        try {
            insert bcc;
            System.assert(false, 'Expected DmlException was not thrown');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('BCC phải được gắn với một Khách Thuê'),
                'Error should mention Account requirement. Got: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    /**
     * @description T01 — Happy path: inserting a valid BCC (with Opp + Account) should succeed.
     */
    @isTest
    static void testValidateEntryPassesWhenValid() {
        Map<String, SObject> base = createBaseData();
        Opportunity opp = (Opportunity) base.get('opportunity');
        Account acc     = (Account) base.get('account');

        Test.startTest();
        Submission_Report__c bcc = new Submission_Report__c(
            Opportunity__c = opp.Id,
            Account__c     = acc.Id,
            Status__c      = 'Draft'
        );
        insert bcc;
        System.assertNotEquals(null, bcc.Id, 'Valid BCC should be inserted successfully');
        Test.stopTest();
    }

    /**
     * @description T08 — Programmatically changing Status to 'In Review' without Account must be blocked.
     * Simulates an API/integration bypass of the Approval Process entry criteria.
     */
    @isTest
    static void testValidateEntryOnStatusChange_MissingAccount() {
        Map<String, SObject> base = createBaseData();
        Opportunity opp = (Opportunity) base.get('opportunity');
        Account acc     = (Account) base.get('account');

        // Insert valid BCC first
        Submission_Report__c bcc = new Submission_Report__c(
            Opportunity__c = opp.Id,
            Account__c     = acc.Id,
            Status__c      = 'Draft'
        );
        insert bcc;

        Test.startTest();
        // Attempt to clear Account AND change Status — should fail validation
        bcc.Account__c = null;
        bcc.Status__c  = 'In Review';
        try {
            update bcc;
            System.assert(false, 'Expected DmlException was not thrown');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('BCC phải được gắn với một Khách Thuê'),
                'Error should mention Account requirement on status change. Got: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // SECTION 3: LOCK GUARD TESTS
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * @description T10 — A non-admin user must NOT be able to change Opportunity
     * on a BCC that is 'In Review'. Addresses R2 — API-level lock bypass prevention.
     */
    @isTest
    static void testPreventEditOppWhileInReview() {
        Map<String, SObject> base = createBaseData();
        Opportunity opp = (Opportunity) base.get('opportunity');
        Account acc     = (Account) base.get('account');

        // Create second Opportunity to try to switch to (Building__c required by org VR)
        Business_Entity__c building2 = new Business_Entity__c(
            Name         = 'Second Building',
            RecordTypeId = Schema.SObjectType.Business_Entity__c
                .getRecordTypeInfosByDeveloperName().get('KPTM').getRecordTypeId(),
            BE_Type__c   = 'KPTM'
        );
        insert building2;

        Opportunity opp2 = new Opportunity(
            Name        = 'Second Opp',
            AccountId   = acc.Id,
            Building__c = building2.Id,
            StageName   = 'Prospecting',
            CloseDate   = Date.today().addDays(60)
        );
        insert opp2;

        // Admin inserts BCC and sets it In Review (simulating Approval Process initial action)
        Submission_Report__c bcc = new Submission_Report__c(
            Opportunity__c     = opp.Id,
            Account__c         = acc.Id,
            Status__c          = 'Draft'
        );
        insert bcc;

        bcc.Status__c          = 'In Review';
        bcc.Approval_Status__c = 'Request submitted';
        update bcc;

        User salesRep = createStandardUser('1');

        Test.startTest();
        System.runAs(salesRep) {
            bcc.Opportunity__c = opp2.Id; // Attempt to switch Opportunity
            try {
                update bcc;
                System.assert(false, 'Expected DmlException for non-admin editing locked BCC');
            } catch (DmlException e) {
                System.assert(
                    e.getMessage().contains('Không thể thay đổi Opportunity'),
                    'Error should mention Opportunity lock. Got: ' + e.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Admin should be able to edit any field on a locked BCC.
     * Admin bypass is critical for emergency data corrections.
     */
    @isTest
    static void testAdminCanEditWhileInReview() {
        Map<String, SObject> base = createBaseData();
        Opportunity opp = (Opportunity) base.get('opportunity');
        Account acc     = (Account) base.get('account');

        Submission_Report__c bcc = new Submission_Report__c(
            Opportunity__c     = opp.Id,
            Account__c         = acc.Id,
            Status__c          = 'In Review',
            Approval_Status__c = 'Request submitted'
        );
        insert bcc;

        // Create second Account to try to switch to (Brand__c required by org VR)
        Brand__c brand2 = new Brand__c(
            Name             = 'Admin Brand',
            Brand_Name__c    = 'Admin Brand',
            Main_Category__c = 'Fashion',
            Sub_Category__c  = 'Fast Fashion',
            Mobile__c        = '0909111222',
            Email__c         = 'admin@test.com'
        );
        insert brand2;

        Id rtBiz = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get('Business_Tenant')
            .getRecordTypeId();
        Account acc2 = new Account(
            Name         = 'Admin Test Account',
            RecordTypeId = rtBiz,
            Phone        = '0999888777',
            Status__c    = 'Active',
            Brand__c     = brand2.Id,
            Enterprise_Code_Certificate__c = 'ENT123',
            Tax_Code__c  = '123456789'
        );
        insert acc2;

        Test.startTest();
        // Running as current Admin user in test context — should succeed
        bcc.Account__c = acc2.Id;
        update bcc; // Must NOT throw

        Submission_Report__c updated = [SELECT Account__c FROM Submission_Report__c WHERE Id = :bcc.Id];
        System.assertEquals(acc2.Id, updated.Account__c, 'Admin should be able to change Account even when In Review');
        Test.stopTest();
    }

    /**
     * @description Draft BCC should be fully editable — no lock guard restrictions apply.
     */
    @isTest
    static void testAllowEditWhenDraft() {
        Map<String, SObject> base = createBaseData();
        Opportunity opp = (Opportunity) base.get('opportunity');
        Account acc     = (Account) base.get('account');

        Submission_Report__c bcc = new Submission_Report__c(
            Opportunity__c = opp.Id,
            Account__c     = acc.Id,
            Status__c      = 'Draft'
        );
        insert bcc;

        User salesRep = createStandardUser('2');

        Test.startTest();
        System.runAs(salesRep) {
            // Draft BCC — Sales Rep should be able to edit freely
            bcc.Description__c = 'Updated description';
            update bcc; // Must NOT throw
        }

        Submission_Report__c updated = [SELECT Description__c FROM Submission_Report__c WHERE Id = :bcc.Id];
        System.assertEquals('Updated description', updated.Description__c,
            'Draft BCC should be freely editable by Sales Rep');
        Test.stopTest();
    }
}
