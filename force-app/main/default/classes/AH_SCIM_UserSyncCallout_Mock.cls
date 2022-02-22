/************************************************************************************************************************
Name            : AH_SCIM_UserSyncCallout_Mock Test Mock Class
Author          : Ganesh Bora
Created Date    : 25/01/2022
Last Mod Date   : 
Last Mod By     : Ganesh Bora
NICC Reference  : NICC-056411
Description		: Mock Http Callout for SCIM user sync test
     			: 
*************************************************************************************************************************/
@isTest
public class AH_SCIM_UserSyncCallout_Mock implements HttpCalloutMock 
{
    public HTTPResponse respond(HTTPRequest req) 
    {
        HttpResponse res = new HttpResponse();
        system.debug(req.getEndpoint());
        if (req.getEndpoint().contains('login')) 
        {
            //res = AH_SCIM_UserSyncCallout_Mock.getResponseLogin();
            
        }
        if (req.getEndpoint().contains('oauth2/token')) 
        {
            res = AH_SCIM_UserSyncCallout_Mock.getAccessToken();
        }
        if (req.getEndpoint().contains('ping')) 
        {
            res = AH_SCIM_UserSyncCallout_Mock.getResponsePing();
        }
        if (req.getEndpoint().contains('Users') && req.getMethod() == 'POST') 
        {
            res = AH_SCIM_UserSyncCallout_Mock.getResponseUserCreated();
        }
        if (req.getEndpoint().contains('Users') && req.getMethod() == 'PUT') 
        {
            res = AH_SCIM_UserSyncCallout_Mock.getResponseUserUpdated();
        }
        if (req.getEndpoint().contains('Users') && req.getMethod() == 'GET') 
        {
            if(req.getEndpoint().contains('donald.duck01'))
            {
              	res = AH_SCIM_UserSyncCallout_Mock.getResponseUserNotExists();   
            }
            /*if(req.getEndpoint().contains('donald.duck02'))
            {
               res = AH_SCIM_UserSyncCallout_Mock.getResponseUserExists(); 
            }*/ 
            else 
            {
                res = AH_SCIM_UserSyncCallout_Mock.getResponseUserExists(); 
            } 
        }
        
        return res;        
    }
    public static HTTPResponse getResponsePing()
    {
        HttpResponse res = new HttpResponse();
        string strJSON = 'ok, company id 20155 with scim enabled';
        res.setHeader('Content-Type', 'application/text');
        res.setBody(strJSON);
        res.setStatusCode(200);
        return res;
    }
    public static HTTPResponse getAccessToken()
    {
        HttpResponse res = new HttpResponse();
        string strJSON = '{"access_token": "cb358dd75b094cef24bfb91b12d2d3cf14e050072931e27c7473ac477148b8da31707b658675b5337e131c54078b2d824d8a0d8bb14475c254e19160b8754a7f_4801713d0b2e7e34","token_type": "bearer","expires_in": 3600}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(strJSON);
        res.setStatusCode(200);
        return res;
    }
    public static HTTPResponse getResponseUserNotExists()
    {
        HttpResponse res = new HttpResponse();
        string strJSON = '{"totalResults":0,"startIndex":1,"count":0,"Resources":[]}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(strJSON);
        res.setStatusCode(200);
        return res;
    }
    public static HTTPResponse getResponseUserExists()
    {
        HttpResponse res = new HttpResponse();
        string strJSON = '{"totalResults":1,"startIndex":1,"count":1,"Resources":[{"addresses":[],"preferredLanguage":"en_US","displayName":"donald.duck.7","timezone":"UTC","roles":[{"display":"User","type":"1","value":"d3a69ad7-0ce0-42c6-8398-56181ca624b6","primary":false}],"externalId":"","groups":[],"urn:ietf:params:scim:schemas:extension:valamis:2.0:User":{"companyId":20155,"gender":"male","custom":[],"organizations":[],"dateOfBirth":"1970-02-01T12:00:00","userId":727337780},"active":false,"screenName":"fname test1","userName":"donald.duck@valamis.comtest02","title":"","phoneNumbers":[],"urn:ietf:params:scim:schemas:extension:enterprise:2.0:User":{"manager":{},"department":20155},"emails":[{"value":"donald.duck@valamis.comtest02","primary":true}],"meta":{"created":"2022-01-11T17:57Z","location":"http://amadeusdry.prod.valamis.io/o/scim-rest/scim/Users/a79cc255-d6f2-2b2b-fd10-51349ae013fe","lastModified":"2022-01-12T14:24Z","version":"W/7","resourceType":"User"},"schemas":["urn:ietf:params:scim:schemas:core:2.0:User","urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"],"name":{"formatted":"fname test1","givenName":"fname","familyName":"test1","middleName":""},"id":"a79cc255-d6f2-2b2b-fd10-51349ae013fe"}]}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(strJSON);
        res.setStatusCode(200);
        return res;
    }
    public static HTTPResponse getResponseUserCreated()
    {
        HttpResponse res = new HttpResponse();
        string strJSON = '{"addresses":[{"country":"finland","streetAddress":"Market street","postalCode":"80110","locality":"Joensuu","region":"","primary":true}],"preferredLanguage":"fi_FI","displayName":"donald.duck.9","timezone":"UTC","roles":[{"display":"User","type":"1","value":"d3a69ad7-0ce0-42c6-8398-56181ca624b6","primary":false},{"display":"Learner","type":"1","value":"8d6cd6b6-5b03-702f-7dab-5b2cc25549b2","primary":false}],"externalId":"ccbd2a89-f64a-48b7-963b-f9556bf2bd79","groups":[{"reference":"http://amadeusdry.prod.valamis.io/o/scim-rest/scim/Groups/d77ea9b2-cd82-1df5-f090-6fe9acc19124","display":"e9e30dba-f08f-4109-8486-d5c6a331660a","name":"e9e30dba-f08f-4109-8486-d5c6a331660a","value":"d77ea9b2-cd82-1df5-f090-6fe9acc19124"}],"urn:ietf:params:scim:schemas:extension:valamis:2.0:User":{"companyId":20155,"gender":"male","custom":[],"organizations":[],"dateOfBirth":"1970-02-01T12:00:00","userId":727477620},"active":true,"screenName":"Donald Duck","userName":"donald.duck@valamis.com","title":"","phoneNumbers":[],"urn:ietf:params:scim:schemas:extension:enterprise:2.0:User":{"manager":{},"department":20155},"emails":[{"value":"donald.duck@valamis.com","primary":true}],"meta":{"created":"2022-01-31T17:23Z","location":"http://amadeusdry.prod.valamis.io/o/scim-rest/scim/Users/ccc0f97f-db9d-f5b1-6aea-813c3bab4c45","lastModified":"2022-01-31T17:23Z","version":"W/4","resourceType":"User"},"schemas":["urn:ietf:params:scim:schemas:core:2.0:User","urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"],"name":{"formatted":"Donald Duck","givenName":"Donald","familyName":"Duck","middleName":""},"id":"ccc0f97f-db9d-f5b1-6aea-813c3bab4c45"}}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(strJSON);
        res.setStatusCode(200);
        return res;
    }
    public static HTTPResponse getResponseUserUpdated()
    {
        HttpResponse res = new HttpResponse();
        string strJSON = '{"addresses":[{"country":"finland","streetAddress":"Market street","postalCode":"80110","locality":"Joensuu","region":"","primary":true}],"preferredLanguage":"fi_FI","displayName":"donald.duck.9","timezone":"UTC","roles":[{"display":"User","type":"1","value":"d3a69ad7-0ce0-42c6-8398-56181ca624b6","primary":false},{"display":"Learner","type":"1","value":"8d6cd6b6-5b03-702f-7dab-5b2cc25549b2","primary":false}],"externalId":"ccbd2a89-f64a-48b7-963b-f9556bf2bd79","groups":[{"reference":"http://amadeusdry.prod.valamis.io/o/scim-rest/scim/Groups/d77ea9b2-cd82-1df5-f090-6fe9acc19124","display":"e9e30dba-f08f-4109-8486-d5c6a331660a","name":"e9e30dba-f08f-4109-8486-d5c6a331660a","value":"d77ea9b2-cd82-1df5-f090-6fe9acc19124"}],"urn:ietf:params:scim:schemas:extension:valamis:2.0:User":{"companyId":20155,"gender":"male","custom":[],"organizations":[],"dateOfBirth":"1970-02-01T12:00:00","userId":727477620},"active":true,"screenName":"Donald Duck","userName":"donald.duck@valamis.com","title":"","phoneNumbers":[],"urn:ietf:params:scim:schemas:extension:enterprise:2.0:User":{"manager":{},"department":20155},"emails":[{"value":"donald.duck@valamis.com","primary":true}],"meta":{"created":"2022-01-31T17:23Z","location":"http://amadeusdry.prod.valamis.io/o/scim-rest/scim/Users/ccc0f97f-db9d-f5b1-6aea-813c3bab4c45","lastModified":"2022-01-31T17:23Z","version":"W/4","resourceType":"User"},"schemas":["urn:ietf:params:scim:schemas:core:2.0:User","urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"],"name":{"formatted":"Donald Duck","givenName":"Donald","familyName":"Duck","middleName":""},"id":"ccc0f97f-db9d-f5b1-6aea-813c3bab4c45"}}';
        res.setHeader('Content-Type', 'application/json');
        res.setBody(strJSON);
        res.setStatusCode(200);
        return res;
    }
}