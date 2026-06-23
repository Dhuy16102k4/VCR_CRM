List<Bankey__c> banks = new List<Bankey__c>{
    new Bankey__c(Name = 'Vietcombank', Bank_Code__c = 'VCB', Bank_Full_Name__c = 'Ngân hàng TMCP Ngoại thương Việt Nam', Swift_Code__c = 'BFTVVNVX', Active__c = true),
    new Bankey__c(Name = 'Techcombank', Bank_Code__c = 'TCB', Bank_Full_Name__c = 'Ngân hàng TMCP Kỹ thương Việt Nam', Swift_Code__c = 'VTCBVNVX', Active__c = true),
    new Bankey__c(Name = 'MBBank', Bank_Code__c = 'MBB', Bank_Full_Name__c = 'Ngân hàng TMCP Quân đội', Swift_Code__c = 'MSCBVNVX', Active__c = true),
    new Bankey__c(Name = 'ACB', Bank_Code__c = 'ACB', Bank_Full_Name__c = 'Ngân hàng TMCP Á Châu', Swift_Code__c = 'ASCBVNVX', Active__c = true),
    new Bankey__c(Name = 'BIDV', Bank_Code__c = 'BIDV', Bank_Full_Name__c = 'Ngân hàng TMCP Đầu tư và Phát triển Việt Nam', Swift_Code__c = 'BIDVVNVX', Active__c = true)
};
insert banks;
System.debug('Inserted ' + banks.size() + ' sample banks.');
