/****************************************************************************************
Name            : MockHttpResponseGenerator Class
Author          : Stu Emery
Created Date    : 11/03/2015
Last Mod Date   : 05/03/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : NI_CreateHRMOrgTest
Description     : Mock response generator for Test class of AH_FetchTrailExpirationBatch.
                : Because Callouts are not allowed in test classes, this creates a "mock" callout so that the code can still be tested.
				: This Mock test class is used by both the NI_CreateHRMOrgTest and NI_HRM_SignupRequestTest
				: "Mocking" the response from the Login Callout and the SignupRequest Call out.
******************************************************************************************/
@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock 
{
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) 
    {
        
        string endpoint = req.getEndpoint();
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        // Create a fake response for org creation
        if (endpoint.contains('Signup'))
        {
            NI_HRM_SignUpRequest.OrgCreateResponse orgRes = new NI_HRM_SignUpRequest.OrgCreateResponse();
            List<String> errors = new List<String>();
            orgRes.Id = '00D610000007PcZ';
            orgRes.Success = true;
            orgRes.Errors = errors;
            res.setBody(JSON.Serialize(orgRes));
        }
        
        if (endpoint.contains('oauth'))
        {
            
            //Response for Login
            NI_HRM_SignUpRequest.ResponseToken loginToken = new NI_HRM_SignupRequest.ResponseToken();
            
            String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
            loginToken.instance_Url = baseURL;
            loginToken.access_token = '00Di0000000hRFw!ARMAQKu1WkxDHefa3TsIyiVpyoKrLVSWYdRCt4OPX1guJZrz066z3qbCq82aGOXlqdqhHQMFjJ78sUyETYoVUXOG2AewfYXM';
            res.setBody(JSON.Serialize( loginToken ));
            
        }
        
        return res;
        
    }
    
}