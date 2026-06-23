for(Schema.PicklistEntry pe : Sales_T_3_Achievement_Target__c.Target_Type__c.getDescribe().getPicklistValues()) {
    System.debug(pe.getValue());
}
