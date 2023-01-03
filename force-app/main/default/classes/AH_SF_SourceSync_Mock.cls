/************************************************************************************************************************
Name            : AH_SF_SourceSync_Mock Test Mock Class
Author          : Sean Harris
Created Date    : 06/04/2018
Last Mod Date   : 06/04/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description		: 
     			: 
*************************************************************************************************************************/
@isTest
public class AH_SF_SourceSync_Mock implements HttpCalloutMock 
{
    public HTTPResponse respond(HTTPRequest req) 
    {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json'); 
        string strJSON = '{"records":[{';
        strJSON += '"Id":"01p32000000VSoeAAG",';
        strJSON += '"Active":"true",';
        strJSON += '"NamespacePrefix":"",';
        strJSON += '"DeveloperName":"My_Developer_Name",';
        strJSON += '"Description":"My_Description",';
        strJSON += '"ActiveVersionId":"3010d0000004ZHPAA2",';
        strJSON += '"LastModifiedDate":"2017-05-10T14:19:53.000+0000",';
        strJSON += '"LastModifiedById":"005600000011GFWAA2",';
        strJSON += '"EntityDefinitionId":"01I60000000BCaV",';
        strJSON += '"ValidationName":"My_Validation_Name"';
        strJSON += '}]}'; 
        res.setBody(strJSON);
        res.setStatusCode(200);
        system.assertEquals('GET', req.getMethod());
      
        return res;
        
    }
    
}