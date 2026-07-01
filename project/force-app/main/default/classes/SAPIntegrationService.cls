public class SAPIntegrationService {
    
    /**
     * @description Synchronizes Account data to SAP S4/HANA via REST API callout.
     * @param accountIds Set of Account Ids to synchronize
     */
    @future(callout=true)
    public static void syncAccountToSAP(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) return;
        
        List<Account> accounts = [
            SELECT Id, Name, Tax_Code__c, Enterprise_Code_Certificate__c, Phone, Email__c, 
                   BillingStreet, BillingCity, BillingCountry
            FROM Account 
            WHERE Id IN :accountIds
        ];
        
        List<Integration_Log__c> logsToInsert = new List<Integration_Log__c>();
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Account acc : accounts) {
            Integration_Log__c log = new Integration_Log__c(
                Target_Account__c = acc.Id,
                Integration_Type__c = 'SAP Account Sync',
                Direction__c = 'Outbound'
            );
            
            try {
                // 1. Build Payload
                Map<String, Object> payloadMap = new Map<String, Object>{
                    'SalesforceId' => acc.Id,
                    'CustomerName' => acc.Name,
                    'TaxID' => acc.Tax_Code__c,
                    'CompanyRegistrationNumber' => acc.Enterprise_Code_Certificate__c,
                    'Telephone' => acc.Phone,
                    'EmailAddress' => acc.Email__c,
                    'Address' => new Map<String, String>{
                        'Street' => acc.BillingStreet,
                        'City' => acc.BillingCity,
                        'Country' => acc.BillingCountry
                    }
                };
                
                String jsonPayload = JSON.serialize(payloadMap);
                log.Request_Payload__c = jsonPayload;
                
                // 2. Perform HTTP Callout
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:SAP_S4HANA_API/api/customer/sync');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(jsonPayload);
                req.setTimeout(120000); // 2 minutes
                
                Http http = new Http();
                HttpResponse res = http.send(req);
                
                // 3. Process Response
                log.Response_Payload__c = res.getBody();
                
                if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                    log.Status__c = 'Success';
                    
                    // Parse response to extract SAP Customer ID
                    try {
                        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        if (responseMap.containsKey('sapCustomerId')) {
                            String sapId = (String) responseMap.get('sapCustomerId');
                            accountsToUpdate.add(new Account(
                                Id = acc.Id,
                                SAP_Account_ID__c = sapId
                            ));
                        }
                    } catch (Exception e) {
                        System.debug('Error parsing SAP response: ' + e.getMessage());
                    }
                } else {
                    log.Status__c = 'Failed';
                    log.Error_Message__c = 'HTTP ' + res.getStatusCode() + ': ' + res.getStatus();
                }
                
            } catch (Exception e) {
                log.Status__c = 'Failed';
                log.Error_Message__c = e.getMessage() + '\n' + e.getStackTraceString();
            }
            
            logsToInsert.add(log);
        }
        
        if (!logsToInsert.isEmpty()) {
            insert logsToInsert;
        }
        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
