List<Brand__c> brands = new List<Brand__c>{
    new Brand__c(Name = 'Nike', Brand_Name__c = 'Nike', Brand_Code__c = 'BR-NIKE-01', Brand_Category__c = 'Fashion', Brand_Type__c = 'International', Country_of_Origin__c = 'USA', Active__c = true),
    new Brand__c(Name = 'Highlands Coffee', Brand_Name__c = 'Highlands Coffee', Brand_Code__c = 'BR-HL-02', Brand_Category__c = 'F&B', Brand_Type__c = 'National', Country_of_Origin__c = 'Vietnam', Active__c = true),
    new Brand__c(Name = 'Samsung', Brand_Name__c = 'Samsung', Brand_Code__c = 'BR-SAM-03', Brand_Category__c = 'Electronics', Brand_Type__c = 'International', Country_of_Origin__c = 'South Korea', Active__c = true),
    new Brand__c(Name = 'CGV Cinemas', Brand_Name__c = 'CGV Cinemas', Brand_Code__c = 'BR-CGV-04', Brand_Category__c = 'Entertainment', Brand_Type__c = 'International', Country_of_Origin__c = 'South Korea', Active__c = true),
    new Brand__c(Name = 'WinMart', Brand_Name__c = 'WinMart', Brand_Code__c = 'BR-WM-05', Brand_Category__c = 'Supermarket', Brand_Type__c = 'National', Country_of_Origin__c = 'Vietnam', Active__c = true)
};
insert brands;
System.debug('Inserted ' + brands.size() + ' sample brands.');
