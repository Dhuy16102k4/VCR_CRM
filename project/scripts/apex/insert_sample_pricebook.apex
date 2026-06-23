// 1. Lấy ID của RecordType
RecordType tttmRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Business_Entity__c' AND DeveloperName = 'TTTM' LIMIT 1];
RecordType roRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Product2' AND DeveloperName = 'RO_TTTM' LIMIT 1];

// 2. Tạo Business Entity (Dự Án / TTTM) mẫu
Business_Entity__c be = new Business_Entity__c(
    Name = 'Vincom Mega Mall Smart City',
    RecordTypeId = tttmRT.Id,
    BE_Type__c = 'TTTM',
    TTTM_Model__c = 'VMM',
    Province__c = 'Hà Nội',
    Opening_Date__c = Date.newInstance(2022, 4, 28)
);
insert be;
System.debug('✅ Created Business Entity: ' + be.Name);

// 3. Tạo Gian Hàng (Product2) mẫu
List<Product2> products = new List<Product2>{
    new Product2(
        Name = 'VMM SC L1-01',
        RecordTypeId = roRT.Id,
        Business_Entity__c = be.Id,
        Floor__c = 'L1',
        Inventory_Status__c = 'Vacant',
        IsActive = true
    ),
    new Product2(
        Name = 'VMM SC L2-15',
        RecordTypeId = roRT.Id,
        Business_Entity__c = be.Id,
        Floor__c = 'L2',
        Inventory_Status__c = 'Vacant',
        IsActive = true
    )
};
insert products;
System.debug('✅ Created 2 Products (Gian Hàng)');

// 4. Lấy Standard Pricebook ID
Pricebook2 standardPb;
try {
    standardPb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
} catch (Exception e) {
    // Nếu chưa có thì tạo mới
    standardPb = new Pricebook2(Id=Test.getStandardPricebookId()); 
    // Trick: Trong Apex thường Query ra, ở org thật IsStandard=true luôn có 1 dòng ẩn.
}

// 5. Tạo Standard Pricebook Entry (Bắt buộc phải có trước khi tạo Custom Pricebook Entry)
List<PricebookEntry> stdPbes = new List<PricebookEntry>();
for(Product2 prod : products) {
    stdPbes.add(new PricebookEntry(
        Pricebook2Id = standardPb.Id,
        Product2Id = prod.Id,
        UnitPrice = 0, // Standard giá thường để 0
        IsActive = true
    ));
}
insert stdPbes;
System.debug('✅ Created Standard Pricebook Entries');

// 6. Tạo Custom Pricebook (Bảng Giá Kinh Doanh 2026)
Pricebook2 customPb = new Pricebook2(
    Name = 'Bảng Giá Cho Thuê VCR 2026',
    Description = 'Bảng giá áp dụng cho năm 2026',
    IsActive = true
);
insert customPb;

// 7. Tạo Custom Pricebook Entry (Giá thuê hàng tháng)
List<PricebookEntry> customPbes = new List<PricebookEntry>{
    new PricebookEntry(
        Pricebook2Id = customPb.Id,
        Product2Id = products[0].Id,
        UnitPrice = 150000000, // Giá 150 triệu
        IsActive = true
    ),
    new PricebookEntry(
        Pricebook2Id = customPb.Id,
        Product2Id = products[1].Id,
        UnitPrice = 85000000,  // Giá 85 triệu
        IsActive = true
    )
};
insert customPbes;
System.debug('✅ Created Custom Pricebook & Entries');
