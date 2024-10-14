@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock  {
    // implement http mock callout
    // 
     global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response.
       HttpResponse res = new HttpResponse();
         // Set response values, and 
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"_id":"55d66226726b611100aaf741","replacement":false,"quantity":5,"name":"Generator 1000 kW","maintenanceperiod":365,"lifespan":120,"cost":5000,"sku":"123"},{"_id":"55d66226726b611100aaf742","replacement":true,"quantity":183,"name":"Cooling Fan","maintenanceperiod":0,"lifespan":0,"cost":300,"sku":"124"}]');
        res.setStatusCode(200);
         
       // return response
        return res;
    }
}