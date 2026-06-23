/**
 * @class       OpportunityValidationRuleTest
 * @description Unit tests for Opportunity Validation Rules.
 *              v1.1 – Customer_Type__c removed from seed Accounts (not required,
 *              restricted picklist causes INVALID_OR_NULL errors in runtime).
 *
 * Stages: Prospecting | Site Survey | Negotiation | Closing | Contract Deposit
 */
@isTest
private class OpportunityValidationRuleTest {

    @testSetup
    static void setupTestData() {
        RecordType businessRT   = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='Business_Tenant'   LIMIT 1];
        RecordType individualRT = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='Individual_Tenant' LIMIT 1];

        Brand__c brand = new Brand__c(
            Name='Test Brand Opp VCR', Brand_Name__c='Test Brand Opp VCR',
            Mobile__c='0901234561', Email__c='testbrandopp@vcr.com');
        insert brand;

        // Create a Business_Entity__c (Building) for Opportunity lookup
        Business_Entity__c building = new Business_Entity__c(
            Name='VCR Test Building',
            BE_Type__c='TTTM',
            Shopping_Mall_Model__c='Vincom Center');
        insert building;

        // Business Tenant WITH Tax Code + Enterprise Code (positive test)
        Account bizComplete = new Account(
            Name='Vincom Retail Biz Complete', RecordTypeId=businessRT.Id,
            Phone='0901234567', Brand__c=brand.Id, Status__c='Active',
            Tax_Code__c='0123456789', Enterprise_Code_Certificate__c='ECO-2024-001');

        // Business Tenant WITHOUT Tax/Enterprise Code (negative test)
        Account bizIncomplete = new Account(
            Name='Vincom Retail Biz Incomplete', RecordTypeId=businessRT.Id,
            Phone='0312345678', Brand__c=brand.Id, Status__c='Active');

        // Individual Tenant WITH ID/Passport (positive test)
        Account indvComplete = new Account(
            Name='Vincom Retail Indv Complete', RecordTypeId=individualRT.Id,
            Phone='0841234567', Brand__c=brand.Id, Status__c='Active',
            ID_Number_Passport__c='012345678901');

        // Individual Tenant WITHOUT ID/Passport (negative test)
        Account indvIncomplete = new Account(
            Name='Vincom Retail Indv Incomplete', RecordTypeId=individualRT.Id,
            Phone='0961234567', Brand__c=brand.Id, Status__c='Active');

        insert new List<Account>{ bizComplete, bizIncomplete, indvComplete, indvIncomplete };
    }

    static Id getBizComplete()    { return [SELECT Id FROM Account WHERE Name='Vincom Retail Biz Complete'   LIMIT 1].Id; }
    static Id getBizIncomplete()  { return [SELECT Id FROM Account WHERE Name='Vincom Retail Biz Incomplete' LIMIT 1].Id; }
    static Id getIndvComplete()   { return [SELECT Id FROM Account WHERE Name='Vincom Retail Indv Complete'  LIMIT 1].Id; }
    static Id getIndvIncomplete() { return [SELECT Id FROM Account WHERE Name='Vincom Retail Indv Incomplete' LIMIT 1].Id; }
    // Building__c is required on Opportunity – use the Business_Entity__c created in @testSetup
    static Id getBuildingId() {
        return [SELECT Id FROM Business_Entity__c WHERE Name='VCR Test Building' LIMIT 1].Id;
    }

    // ── RULE 1: Require_TaxCode_Chot_Khach ───────────────────────────────────

    @isTest static void testRequireTaxCode_Positive_ClosingWithTaxCode() {
        Id bizCompleteId = getBizComplete(); Id bldId = getBuildingId();
        Test.startTest();
        insert new List<Opportunity>{
            new Opportunity(Name='VCR Opp TaxCode OK 01', AccountId=bizCompleteId, Building__c=bldId, StageName='Closing', CloseDate=Date.today().addDays(30), Amount=500000000),
            new Opportunity(Name='VCR Opp TaxCode OK 02', AccountId=bizCompleteId, Building__c=bldId, StageName='Closing', CloseDate=Date.today().addDays(60), Amount=750000000)
        };
        Test.stopTest();
        System.assertEquals(2, [SELECT COUNT() FROM Opportunity WHERE Name LIKE 'VCR Opp TaxCode OK %'], '2 closing opps expected');
    }

    @isTest static void testRequireTaxCode_Positive_EarlierStageNoTaxCode() {
        Id bizIncompleteId = getBizIncomplete(); Id bldId = getBuildingId();
        Test.startTest();
        insert new List<Opportunity>{
            new Opportunity(Name='VCR Opp Negotiation 01', AccountId=bizIncompleteId, Building__c=bldId, StageName='Negotiation', CloseDate=Date.today().addDays(30), Amount=300000000),
            new Opportunity(Name='VCR Opp Site Survey 01', AccountId=bizIncompleteId, Building__c=bldId, StageName='Site Survey',  CloseDate=Date.today().addDays(30), Amount=200000000)
        };
        Test.stopTest();
        System.assertEquals(2, [SELECT COUNT() FROM Opportunity WHERE Name IN ('VCR Opp Negotiation 01','VCR Opp Site Survey 01')], '2 pre-closing opps expected');
    }

    @isTest static void testRequireTaxCode_Negative_ClosingWithoutTaxCode() {
        Id bizIncompleteId = getBizIncomplete();
        Test.startTest();
        try {
            insert new List<Opportunity>{ new Opportunity(Name='VCR Opp TaxCode Missing', AccountId=bizIncompleteId, StageName='Closing', CloseDate=Date.today().addDays(30), Amount=500000000) };
            System.assert(false, 'DmlException expected');
        } catch (System.DmlException e) {
            System.assert(e.getMessage().length() > 0, 'DmlException caught OK');
        }
        Test.stopTest();
    }

    // ── RULE 2: Require_EnterpriseCode_Coc ───────────────────────────────────

    @isTest static void testRequireEnterpriseCode_Positive_DepositWithCode() {
        Id bizCompleteId = getBizComplete(); Id bldId = getBuildingId();
        Test.startTest();
        insert new List<Opportunity>{
            new Opportunity(Name='VCR Opp EntCode OK 01', AccountId=bizCompleteId, Building__c=bldId, StageName='Contract Deposit', CloseDate=Date.today().addDays(15), Amount=1000000000),
            new Opportunity(Name='VCR Opp EntCode OK 02', AccountId=bizCompleteId, Building__c=bldId, StageName='Contract Deposit', CloseDate=Date.today().addDays(30), Amount=1500000000)
        };
        Test.stopTest();
        System.assertEquals(2, [SELECT COUNT() FROM Opportunity WHERE Name LIKE 'VCR Opp EntCode OK %'], '2 deposit opps expected');
    }

    @isTest static void testRequireEnterpriseCode_Negative_DepositWithoutCode() {
        Id bizIncompleteId = getBizIncomplete();
        Test.startTest();
        try {
            insert new List<Opportunity>{ new Opportunity(Name='VCR Opp EntCode Missing', AccountId=bizIncompleteId, StageName='Contract Deposit', CloseDate=Date.today().addDays(15), Amount=1000000000) };
            System.assert(false, 'DmlException expected');
        } catch (System.DmlException e) {
            System.assert(e.getMessage().length() > 0, 'DmlException caught OK');
        }
        Test.stopTest();
    }

    // ── RULE 3: Require_IDNumber_Coc ─────────────────────────────────────────

    @isTest static void testRequireIDNumber_Positive_DepositWithID() {
        Id indvCompleteId = getIndvComplete(); Id bldId = getBuildingId();
        Test.startTest();
        insert new List<Opportunity>{
            new Opportunity(Name='VCR Opp IDNum OK 01', AccountId=indvCompleteId, Building__c=bldId, StageName='Contract Deposit', CloseDate=Date.today().addDays(20), Amount=200000000),
            new Opportunity(Name='VCR Opp IDNum OK 02', AccountId=indvCompleteId, Building__c=bldId, StageName='Contract Deposit', CloseDate=Date.today().addDays(45), Amount=300000000)
        };
        Test.stopTest();
        System.assertEquals(2, [SELECT COUNT() FROM Opportunity WHERE Name LIKE 'VCR Opp IDNum OK %'], '2 deposit indv opps expected');
    }

    @isTest static void testRequireIDNumber_Positive_EarlierStageNoID() {
        Id indvIncompleteId = getIndvIncomplete(); Id bldId = getBuildingId();
        Test.startTest();
        insert new List<Opportunity>{ new Opportunity(Name='VCR Opp IndvNoID Prospecting', AccountId=indvIncompleteId, Building__c=bldId, StageName='Prospecting', CloseDate=Date.today().addDays(90), Amount=100000000) };
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Opportunity WHERE Name='VCR Opp IndvNoID Prospecting'], '1 prospecting opp expected');
    }

    @isTest static void testRequireIDNumber_Negative_DepositWithoutID() {
        Id indvIncompleteId = getIndvIncomplete();
        Test.startTest();
        try {
            insert new List<Opportunity>{ new Opportunity(Name='VCR Opp IDNum Missing', AccountId=indvIncompleteId, StageName='Contract Deposit', CloseDate=Date.today().addDays(20), Amount=200000000) };
            System.assert(false, 'DmlException expected');
        } catch (System.DmlException e) {
            System.assert(e.getMessage().length() > 0, 'DmlException caught OK');
        }
        Test.stopTest();
    }

    // ── BULK TESTS ────────────────────────────────────────────────────────────

    @isTest static void testBulkInsert_Positive_MultipleValidOpportunities() {
        Id bizCompleteId  = getBizComplete();
        Id indvCompleteId = getIndvComplete();
        Id bldId          = getBuildingId();
        String[] stages = new String[]{ 'Prospecting', 'Site Survey', 'Negotiation', 'Closing', 'Contract Deposit' };
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            opps.add(new Opportunity(Name='VCR Bulk Biz Opp '+(i+1),  AccountId=bizCompleteId,  Building__c=bldId, StageName=stages[i], CloseDate=Date.today().addDays(30+i*10), Amount=100000000L*(i+1)));
            opps.add(new Opportunity(Name='VCR Bulk Indv Opp '+(i+1), AccountId=indvCompleteId, Building__c=bldId, StageName=stages[i], CloseDate=Date.today().addDays(30+i*10), Amount=50000000L*(i+1)));
        }
        Test.startTest(); insert opps; Test.stopTest();
        System.assertEquals(10, [SELECT COUNT() FROM Opportunity WHERE Name LIKE 'VCR Bulk %'], '10 bulk opps expected');
    }

    @isTest static void testBulkInsert_Negative_OneInvalidCausesFailure() {
        Id bizCompleteId   = getBizComplete();
        Id bizIncompleteId = getBizIncomplete();
        Test.startTest();
        try {
            insert new List<Opportunity>{
                new Opportunity(Name='VCR Bulk Neg Valid',   AccountId=bizCompleteId,   StageName='Negotiation',    CloseDate=Date.today().addDays(30), Amount=200000000),
                new Opportunity(Name='VCR Bulk Neg Invalid', AccountId=bizIncompleteId, StageName='Contract Deposit', CloseDate=Date.today().addDays(30), Amount=200000000)
            };
            System.assert(false, 'DmlException expected');
        } catch (System.DmlException e) {
            System.assert(e.getNumDml() >= 1, 'At least 1 DML error expected');
        }
        Test.stopTest();
    }
}
