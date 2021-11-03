@isTest
global class NI_IMT_TestAutomationRunCtrlMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"successes":[{"namespace":null,"name":"NI_IMT_AutomationTest","methodName":"checkGlobalManagerImtContactPermission","time":50.0,"seeAllData":false}],"failures":[{"namespace":null,"name":"NI_IMT_AutomationTest","methodName":"checkGlobalManagerSchedulingSetPermission","time":3048.0,"seeAllData":false}],"totalTime":5772.0,"numFailures":0}');
        //res.setBody('{"foo":"bar", "firstName":"John"}');
        res.setStatusCode(200);
        return res;
    }
}