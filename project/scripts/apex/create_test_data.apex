// ─── STEP 1: Create Brand ───────────────────────────────────────────────────
Brand__c brand = new Brand__c(
    Name             = 'Zara Vietnam',
    Brand_Name__c    = 'Zara Vietnam',
    Main_Category__c = 'Fashion',
    Sub_Category__c  = 'Fast Fashion',
    Mobile__c        = '0901234567',
    Email__c         = 'contact@zara-vn.com',
    Status__c        = 'Active'
);
insert brand;
System.debug('✅ Brand ID: ' + brand.Id);

// ─── STEP 2: Create Account (Business Tenant) ────────────────────────────────
Id rtBiz = Schema.SObjectType.Account
    .getRecordTypeInfosByDeveloperName()
    .get('Business_Tenant')
    .getRecordTypeId();

Account acc = new Account(
    Name                           = 'Zara Vietnam Co., Ltd',
    RecordTypeId                   = rtBiz,
    Phone                          = '02812345678',
    Status__c                      = 'Active',
    Brand__c                       = brand.Id,
    Tax_Code__c                    = '0312345678',
    Enterprise_Code_Certificate__c = 'ENT2024001',
    Email__c                       = 'legal@zara-vn.com',
    Website                        = 'https://www.zara.com/vn',
    Account_Short_Name__c          = 'Zara VN',
    Address_1__c                   = '123 Nguyen Hue, District 1',
    Province_1__c                  = 'Ho Chi Minh City',
    District_1__c                  = 'District 1',
    Number_Of_RO_In_Vietnam__c     = 5,
    Number_Of_RO_In_Vincom__c      = 3
);
insert acc;
System.debug('✅ Account ID: ' + acc.Id);

// ─── STEP 3: Create Business Entity (Building) ───────────────────────────────
Id rtKPTM = Schema.SObjectType.Business_Entity__c
    .getRecordTypeInfosByDeveloperName()
    .get('KPTM')
    .getRecordTypeId();

Business_Entity__c building = new Business_Entity__c(
    Name         = 'Vincom Center Ba Trieu',
    RecordTypeId = rtKPTM,
    BE_Type__c   = 'KPTM'
);
insert building;
System.debug('✅ Building ID: ' + building.Id);

// ─── STEP 4: Create Opportunity at stage "Negotiation" ───────────────────────
Id rtOppNewLease = Schema.SObjectType.Opportunity
    .getRecordTypeInfosByDeveloperName()
    .get('New_Lease_TTTM')
    .getRecordTypeId();

Opportunity opp = new Opportunity(
    Name           = '[TEST] Zara VN - Negotiation - Vincom Ba Trieu',
    RecordTypeId   = rtOppNewLease,
    AccountId      = acc.Id,
    Building__c    = building.Id,
    Brand_Name__c  = brand.Id,
    StageName      = 'Negotiation', // Đây là Stage hợp lệ trên org
    CloseDate      = Date.today().addDays(60),
    Rental_Area__c = 500,
    Duration_Month__c = 36,
    Start_Date__c = Date.today().addDays(90),
    End_Date__c = Date.today().addDays(90).addMonths(36),
    Rent_Price__c = 1500000,
    Service_Fee__c = 250000,
    Customer_Interest_Level__c = 'High',
    LeadSource = 'Partner Referral',
    RO_Handover_Date__c = Date.today().addDays(30),
    Description = 'Khách hàng quan tâm thuê mặt bằng rộng để làm Flagship Store tại Vincom Ba Triệu.'
);
insert opp;
System.debug('✅ Opportunity ID: ' + opp.Id);

System.debug('');
System.debug('=== TÓM TẮT DỮ LIỆU TEST ===');
System.debug('Brand       : ' + brand.Id + ' | Zara Vietnam');
System.debug('Account     : ' + acc.Id   + ' | Zara Vietnam Co., Ltd');
System.debug('Building    : ' + building.Id + ' | Vincom Center Ba Trieu');
System.debug('Opportunity : ' + opp.Id   + ' | Stage: Negotiation');
