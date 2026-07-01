@isTest
global class SAPIntegrationServiceMock implements HttpCalloutMock {
    global Boolean isSuccess = true;
    
    global SAPIntegrationServiceMock(Boolean isSuccess) {
        this.isSuccess = isSuccess;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        // Assert we are calling the correct endpoint
        System.assertEquals('callout:SAP_S4HANA_API/api/customer/sync', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        if (isSuccess) {
            res.setBody('{"status": "success", "sapCustomerId": "SAP-123456"}');
            res.setStatusCode(200);
        } else {
            res.setBody('{"status": "error", "message": "Invalid TaxID format"}');
            res.setStatusCode(400);
        }
        return res;
    }
}
