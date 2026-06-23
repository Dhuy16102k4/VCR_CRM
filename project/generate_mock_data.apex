// Clean up existing data first
delete [SELECT Id FROM OpportunityContactRole];
delete [SELECT Id FROM Opportunity];
delete [SELECT Id FROM Account_Brand_Relationship__c];
delete [SELECT Id FROM Brand__c];
delete [SELECT Id FROM Contact];
delete [SELECT Id FROM Account];
delete [SELECT Id FROM Bankey__c];
delete [SELECT Id FROM Product2];
delete [SELECT Id FROM Business_Entity__c];

Id busTenantRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Tenant').getRecordTypeId();
Id indTenantRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Tenant').getRecordTypeId();

Id kptmRT = Schema.SObjectType.Business_Entity__c.getRecordTypeInfosByDeveloperName().get('KPTM').getRecordTypeId();
Id tttmRT = Schema.SObjectType.Business_Entity__c.getRecordTypeInfosByDeveloperName().get('TTTM').getRecordTypeId();

// 1. Create Bankeys
List<Bankey__c> bankeys = new List<Bankey__c>();
bankeys.add(new Bankey__c(Name = 'VCB', Bank_Full_Name__c = 'Vietcombank', Bank_Key_Code__c = 'VCB001', Swift_Code__c = 'BFTVVNVX', Active__c = true));
bankeys.add(new Bankey__c(Name = 'TCB', Bank_Full_Name__c = 'Techcombank', Bank_Key_Code__c = 'TCB002', Swift_Code__c = 'VTCBVNVX', Active__c = true));
insert bankeys;

// 2. Create Accounts
List<Account> accounts = new List<Account>();
Account acc1 = new Account(
    Name = 'Công ty CP Vincom Retail',
    RecordTypeId = busTenantRT,
    Customer_Type__c = 'Bên Ngoài',
    Enterprise_Code_Certificate__c = '0105850244',
    Tax_Code__c = '0105850244',
    Type = 'Customer',
    Phone = '02439749999',
    Website = 'www.vincom.com.vn'
);
acc1.put('Bankey_Name__c', bankeys[0].Id);
accounts.add(acc1);

Account acc2 = new Account(
    Name = 'Công ty TNHH Highlands Coffee',
    RecordTypeId = busTenantRT,
    Customer_Type__c = 'Bên Ngoài',
    Enterprise_Code_Certificate__c = '0106201010',
    Tax_Code__c = '0106201010',
    Type = 'Customer',
    Phone = '02838446688',
    Website = 'www.highlandscoffee.com.vn'
);
acc2.put('Bankey_Name__c', bankeys[1].Id);
accounts.add(acc2);

Account acc3 = new Account(
    Name = 'Nguyễn Trần Vĩ',
    RecordTypeId = indTenantRT,
    Customer_Type__c = 'Bên Ngoài',
    ID_Number_Passport__c = '079090123456',
    Type = 'Customer',
    Phone = '0901234567'
);
accounts.add(acc3);
insert accounts;

// 3. Create Contacts
List<Contact> contacts = new List<Contact>();
contacts.add(new Contact(AccountId = accounts[0].Id, LastName = 'Trần', FirstName = 'Hùng', Title = 'Giám Đốc', Phone = '0901112222', Email = 'hung.tran@vincom.com.vn'));
contacts.add(new Contact(AccountId = accounts[1].Id, LastName = 'Lê', FirstName = 'Hoa', Title = 'Trưởng Phòng Phát Triển', Phone = '0903334444', Email = 'hoa.le@highlands.com'));
contacts.add(new Contact(AccountId = accounts[2].Id, LastName = 'Nguyễn Trần Vĩ', Phone = '0901234567', Email = 'vinguyen@gmail.com'));
insert contacts;

// 4. Create Brands
List<Brand__c> brands = new List<Brand__c>();
Brand__c b1 = new Brand__c(Active__c = true, Country_of_Origin__c = 'Vietnam');
b1.put('Brand_Name__c', 'Highlands Coffee');
b1.put('Email__c', 'contact@highlands.com');
b1.put('Mobile__c', '0903334444');
b1.put('Contact__c', contacts[1].Id);
brands.add(b1);

Brand__c b2 = new Brand__c(Active__c = true, Country_of_Origin__c = 'Vietnam');
b2.put('Brand_Name__c', 'VinMart');
b2.put('Email__c', 'cskh@vinmart.com');
b2.put('Mobile__c', '0901112222');
b2.put('Contact__c', contacts[0].Id);
brands.add(b2);
insert brands;

// 5. Create Account Brand Relationship
List<Account_Brand_Relationship__c> abrs = new List<Account_Brand_Relationship__c>();
Account_Brand_Relationship__c abr1 = new Account_Brand_Relationship__c(Account__c = accounts[1].Id, Brand__c = brands[0].Id, Start_Date__c = Date.today().addDays(-1000));
abr1.put('Status__c', 'Active');
abrs.add(abr1);

Account_Brand_Relationship__c abr2 = new Account_Brand_Relationship__c(Account__c = accounts[0].Id, Brand__c = brands[1].Id, Start_Date__c = Date.today().addDays(-500));
abr2.put('Status__c', 'Active');
abrs.add(abr2);
insert abrs;

// 6. Create Business Entities
List<Business_Entity__c> bes = new List<Business_Entity__c>();
Business_Entity__c be1 = new Business_Entity__c(Name = 'Vincom Center Landmark 81', RecordTypeId = tttmRT, Address_1__c = '72A Điện Biên Phủ', Opening_Date__c = Date.newInstance(2018, 7, 26));
be1.put('Company_Code__c', 'VCL81');
be1.put('Province_1__c', 'Hồ Chí Minh');
be1.put('Shopping_Mall_Model__c', 'Vincom Center');
be1.put('BE_Type__c', 'TTTM');
bes.add(be1);

Business_Entity__c be2 = new Business_Entity__c(Name = 'KPTM Grand World Phú Quốc', RecordTypeId = kptmRT, Address_1__c = 'Gành Dầu, Phú Quốc', Opening_Date__c = Date.newInstance(2020, 10, 15));
be2.put('Company_Code__c', 'GW_PQ');
be2.put('Province_1__c', 'Kiên Giang');
be2.put('BE_Type__c', 'KPTM');
bes.add(be2);
insert bes;

// 7. Create Product2 (RO)
List<Product2> prods = new List<Product2>();
Product2 p1 = new Product2(Name = 'VCL81-L1-01', Business_Entity__c = bes[0].Id, IsActive = true);
p1.put('Floor__c', 'L1');
p1.put('Area_Indoor__c', 250);
prods.add(p1);

Product2 p2 = new Product2(Name = 'GW-SH-10', Business_Entity__c = bes[1].Id, IsActive = true);
p2.put('Floor__c', 'Tầng Trệt');
p2.put('Area_Indoor__c', 120);
prods.add(p2);
insert prods;

// 8. Create Opportunity
List<Opportunity> opps = new List<Opportunity>();
Opportunity opp1 = new Opportunity(
    Name = 'Thuê mặt bằng Highlands Landmark 81',
    AccountId = accounts[1].Id,
    StageName = 'Negotiation',
    CloseDate = Date.today().addDays(30)
);
opp1.put('Building__c', bes[0].Id);
opp1.put('RO__c', prods[0].Id);
opps.add(opp1);

Opportunity opp2 = new Opportunity(
    Name = 'Thuê shophouse VinMart Grand World',
    AccountId = accounts[0].Id,
    StageName = 'Prospecting',
    CloseDate = Date.today().addDays(60)
);
opp2.put('Building__c', bes[1].Id);
opp2.put('RO__c', prods[1].Id);
opps.add(opp2);
insert opps;

// 9. Create OpportunityContactRole
List<OpportunityContactRole> ocrs = new List<OpportunityContactRole>();
ocrs.add(new OpportunityContactRole(OpportunityId = opps[0].Id, ContactId = contacts[1].Id, Role = 'Business User', IsPrimary = true));
ocrs.add(new OpportunityContactRole(OpportunityId = opps[1].Id, ContactId = contacts[0].Id, Role = 'Decision Maker', IsPrimary = true));
insert ocrs;

System.debug('Mock data with DEEP RELATIONS created successfully!');
