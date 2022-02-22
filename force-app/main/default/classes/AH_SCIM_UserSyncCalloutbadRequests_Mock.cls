/************************************************************************************************************************
Name            : AH_SCIM_UserSyncCalloutbadRequests_Mock Test Mock Class
Author          : Ganesh Bora
Created Date    : 25/01/2022
Last Mod Date   : 25/01/2022
Last Mod By     : Ganesh Bora
NICC Reference  : 
Description		: Mock Class for Handling SCIM User Sync Http Callout Bad Requsts 
     			: 
*************************************************************************************************************************/
@isTest
public class AH_SCIM_UserSyncCalloutbadRequests_Mock implements HttpCalloutMock 
{
    public HTTPResponse respond(HTTPRequest req) 
    {
        HttpResponse res = new HttpResponse();
        
        if (req.getEndpoint().contains('oauth2/token')) 
        {
            res = AH_SCIM_UserSyncCallout_Mock.getAccessToken();
        } 
        else 
        {
        	string strJSON = '';
        	res.setHeader('Content-Type', 'application/json');
        	res.setBody(strJSON);
        	res.setStatusCode(409);    
        }
        return res;
    }
    
    //Generating responce for Token Method
    public static HTTPResponse getAccessToken()
    {
        HttpResponse res = new HttpResponse();
        string strJSON = '{"access_token": "cb358dd75b094cef24bfb91b12d2d3cf14e050072931e27c7473ac477148b8da31707b658675b5337e131c54078b2d824d8a0d8bb14475c254e19160b8754a7f_4801713d0b2e7e34","token_type": "bearer","expires_in": 3600}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(strJSON);
        res.setStatusCode(200);
        return res;
    }
}