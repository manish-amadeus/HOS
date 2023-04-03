/************************************************************************************************************************
Name            : AH_SF_SourceSync_MockPB Class
Author          : Sean Harris
Created Date    : 06/04/2018
Last Mod Date   : 06/04/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description		: 
     			: 
*************************************************************************************************************************/
@isTest
global class AH_SF_SourceSync_MockPB implements HttpCalloutMock 
{
    
    global HTTPResponse respond(HTTPRequest req)
    {
        
        string strJSON = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"FlowDefinition",';
        strJSON += '"records":[{';
        strJSON += '"attributes":{"type":"FlowDefinition","url":"/services/data/v41.0/tooling/sobjects/FlowDefinition/3000d000000GrOoAAK"},';
        strJSON += '"ActiveVersionId":"3010d0000004ZHPAA2",';
        strJSON += '"DeveloperName":"Cost",';
        strJSON += '"ActiveVersion":';
        strJSON += '{"attributes":{"type":"Flow","url":"/services/data/v41.0/tooling/sobjects/Flow/3010d0000004ZHPAA2"},';
        strJSON += '"LastModifiedDate":"2017-09-19T14:14:50.000+0000",';
        strJSON += '"LastModifiedById":"005600000011GFWAA2",';
        strJSON += '"Description":"When cost cr field is updated notify user and create task"';
        strJSON += '}}]}';   
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(strJSON);
        res.setStatusCode(200);
        return res;
        
    }        
    
}