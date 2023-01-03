/****************************************************************************************
Name            : AH_Rally_AttachmentJSON  
Author          : Sean Harris
Created Date    : 11/25/2020
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Mock response for test classes
				: 
				: 
******************************************************************************************/
@isTest
global class AH_Rally_MockResponse implements HttpCalloutMock 
{
   
    global HTTPResponse respond(HTTPRequest req) 
    {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        //res.setBody('{"successes":[{"namespace":null,"name":"NI_IMT_AutomationTest","methodName":"checkGlobalManagerImtContactPermission","time":50.0,"seeAllData":false}],"failures":[{"namespace":null,"name":"NI_IMT_AutomationTest","methodName":"checkGlobalManagerSchedulingSetPermission","time":3048.0,"seeAllData":false}],"totalTime":5772.0,"numFailures":0}');
        //res.setBody('{"foo":"bar", "firstName":"John"}');
        res.setBody('{"AH_Rally_AttachmentJSON":[{"Content":"Hello"}]}');
        res.setStatusCode(200);
        return res;
    }
    
}