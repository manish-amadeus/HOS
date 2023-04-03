/************************************************************************************************************************
Name            : AH_SF_SourceSync_MockVR Class
Author          : Sean Harris
Created Date    : 06/04/2018
Last Mod Date   : 06/04/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description		: 
     			: 
*************************************************************************************************************************/
@isTest
global class AH_SF_SourceSync_MockVR implements HttpCalloutMock 
{
    
    global HTTPResponse respond(HTTPRequest req)
    {
        
        string strJSON = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"ValidationRule",';
        strJSON += '"records":[';
        strJSON += '{"attributes":{"type":"ValidationRule","url":"/services/data/v41.0/tooling/sobjects/ValidationRule/03d600000008pRyAAI"},';
        strJSON += '"Id":"03d600000008pRyAAI",';
        strJSON += '"LastModifiedDate":"2014-04-18T01:04:57.000+0000",';
        strJSON += '"LastModifiedById":"005600000011GFWAA2",';
        strJSON += '"EntityDefinitionId":"Asset",';
        strJSON += '"ValidationName":"Account_May_Not_Be_Changed",';
        strJSON += '"Description":"My_Description"';
        strJSON += '}]}';         

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(strJSON);
        res.setStatusCode(200);
        return res;
        
    }        
    
}