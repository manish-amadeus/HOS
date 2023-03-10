/****************************************************************************************
Name            : NI_HRM_SignUpRequest Class 
Author          : Suzanne LeDuc
Created Date    : 
Last Mod Date   : 7/26/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : This class is used to create an HRM Org by Posting a SignupRequest to a Trialforce Source Org (TSO )
                : A SignupRequest is a Salesforce object that represents a request for a new Trialforce signup
                : This will be used to create an HRM Org from an Opportunity by another class. 
                : The other class will call CreateSignUpRequest to create the request and then 
                : Call the method GetSignUpRequestOrgId to retrieve the Org Id from the Signup Request Object
                : 
                : NICC-060073 - Uncommented system.debug line to see JSON response in debug
******************************************************************************************/
public class NI_HRM_SignUpRequest 
{
    
    private String SERVER;
    private String USERNAME;
    private String PASSWORD;
    private String CLIENTID;
    private String CLIENTSECRET;
    private String AUTHENDPOINT;
    private String SIGNUPREQUESTURL;
    private String SIGNUPREQUESTGETURL;
    
    // CLASS CONTROLLER. SETS THE NEEDED VARIABLES BASED ON CUSTOM SETTINGS  
    public NI_HRM_SignUpRequest()
    {

        NI_HRM_SignUp_Request_Settings__c sr  = NI_HRM_SignUp_Request_Settings__c.getInstance('HRMSignUpSettings');
        
        SERVER = sr.TSO_Server__c;
        USERNAME = sr.TSO_User_Name__c;
        PASSWORD = sr.TSO_Password__c;
        CLIENTID = sr.TSO_CLientID__c;
        CLIENTSECRET = sr.TSO_CLient_Secret__C;
        AUTHENDPOINT = sr.TSO_Auth_Endpoint__C;
        SIGNUPREQUESTURL = sr.SignUp_Request_URL__C;
        SIGNUPREQUESTGETURL = sr.SignUp_Request_Get_URL__c;
        
    }

    // AUTHENTICATES WITH THE TSO ORG AND RETURNS A TOKEN THAT CAN BE USED FOR SUBSEQUENT CALLS
    public ResponseToken login()
    {
        
        ResponseToken rToken = null;
        HttpRequest req = new HttpRequest();
        String requestString;
        
        req.setMethod('POST');             
        req.setHeader('Content-Length','0');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');    
        req.setHeader('Accept','application/json');
        req.setHeader('Code','Code');
        
        requestString = 'grant_type=password&redirect_uri=https://login.salesforce.com&response_type=code';
        requestString += '&client_id=' + CLIENTID;
        requestString += '&client_secret=' + CLIENTSECRET;
        requestString += '&username=' + USERNAME;
        requestSTring += '&password=' + PASSWORD;
        
        req.setBody(requestString);       
        
        req.setEndpoint(AUTHENDPOINT);     
//        system.debug('req ' + req);
//        system.debug('req body' + req.getBody());

        Http http = new Http();    
        HttpResponse res; 
        
        res = http.send(req);
        Integer statuscode = res.getStatusCode();
        String statustext = res.getStatus();
        
//        system.debug('Response Body ' + res.getBody());
//        system.debug(res);
        rToken = (ResponseToken)JSON.deserialize(res.getBody(), ResponseToken.class);
//        system.debug( rToken );
//        system.debug(' Token ' + rToken.access_token);   
        return rToken;
        
    }

    // WITH PROVIDED VARIABLES, CALLS METHODS LOGIN AND ORGCREATERESPONSE TO CREATE A SIGN UP REQUEST
    public String CreateSignUpRequest(String templateId, string SignupEmail, String UserName, String Country, String Company, String LastName)
    {
        
        String returnValue = null;
        ResponseToken token = Login();
        
        if (token != null)
        {
//            system.Debug('Sign up Token ' + token);
            if (token.access_Token != null)
            {
                OrgCreateResponse suRequest = create(token.instance_Url, token.access_Token, templateId, SignupEmail, UserName, Country, Company, LastName);
                if (suRequest != null)
                {
                    if (suRequest.Errors.size() > 0)
                    {
                        returnValue = suRequest.Errors[0];
                    }
                    else
                    {
                        returnValue = suRequest.Id;
                    }
                }
            }
            
//            system.debug('NI_HRM_SignUpRequest.CreateSignUpRequest() Return Value ' + returnValue);
        }
        
        return returnValue;
        
    }
    
    // THIS METHOD QUERIES THE TSO ORG FOR THE ORG ID OF THE ORG THAT WAS CREATED VIA THE SIGN UP REQUEST WITH THE PROVIDED ID
    public String GetSignUpRequestOrgId(String signupRequestId)
    {
        
        ResponseToken token = Login();
        HttpRequest req = new HttpRequest();
        String requestString;
        String returnValue ='';

        req.setMethod('GET');             
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'OAuth ' + token.access_Token);
        req.setEndPoint(token.instance_Url + SIGNUPREQUESTGETURL + signUpRequestId);
        
        system.debug(toStr(req));
        Http http = new Http();    
        HttpResponse res;    
        Integer statuscode;
        String statustext;
req.setTimeout(120000); 
        res = http.send(req);
        statuscode = res.getStatusCode();
        statustext = res.getStatus();
        
        system.debug('Response Body ' + res.getBody());
        
        SignupRequestResponse srResponse = (SignupRequestResponse)JSON.deserialize(res.getBody(), SignupRequestResponse.class);
        system.Debug('FIND ME ' + srResponse);
        returnValue = srResponse.CreatedOrgId;
        
        if (srResponse.Status == 'Error')
        {
            returnValue = 'Error: ' + srResponse.ErrorCode;            
        }
        return returnValue;
        
    }

    // THIS METHOD POSTS TO THE TSO ORG TO CREATE A SIGN UP REQUEST
    private OrgCreateResponse create(String instanceUrl, String accessToken, String templateId, string SignupEmail, String UserName, String Country, String Company, String LastName)
    {
        OrgCreateResponse rToken = null;
        HttpRequest req = new HttpRequest();
        req.setMethod('POST'); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setTimeout(120000);
        
        Map<String, String> reqBody = new Map<String, String>();
        reqBody.put('TemplateId', templateId);
        reqBody.put('SignupEmail', SignupEmail);
        reqBody.put('UserName', UserName);
        reqBody.put('Country', Country);
        reqBody.put('Company', Company);
        reqBody.put('LastName', LastName);
        
        req.setBody(JSON.Serialize(reqBody));       
        req.setEndpoint(instanceUrl + SIGNUPREQUESTURL);     

        system.debug('*^* req body = ' + req.getBody());
        system.debug('*^* req = ' + req); 
        system.debug('*^* header = ' + req.getheader('Authorization'));        
        system.debug('*^* toStr(req) = ' + toStr(req));
        
        Http http = new Http();    
        HttpResponse res;    
        Integer statuscode;
        String statustext;
req.setTimeout(120000);
        res = http.send(req);
        statuscode = res.getStatusCode();
        statustext = res.getStatus();

        system.debug('Response Body ' + res.getBody());        // NICC-060073
        
        if (res != null)
        {  
//            system.Debug(res);
//            system.Debug(res.GetBody());
            rToken = (OrgCreateResponse)JSON.deserialize(res.getBody(), OrgCreateResponse.class);
//            system.debug(' Token ' + rToken.Id); 
        }
        
        return rToken;
    }

    public class AuthenticationRequest 
    {
        public String grant_type;
        public String client_id;
        public String client_secret;
        public String username;
        public String password;
        public String redirect_uri;
        public String response_type;
    }

    // THIS CLASS REPRESENTS THE REPONSE FROM THE LOGIN POST
    public class ResponseToken 
    {
        public String instance_url;
        public String access_token;
    }

    // THIS REPRESENTS THE RESPONSE FROM THE SIGNUP REQUEST POST
    public class OrgCreateResponse 
    {
        public String Id {get; set;}
        public Boolean Success {get; set;}
        public String[] Errors {get; set;}
    }    
    
    // REPRESENTS THE RESPONSE FROM THE POST TO QUERY FOR THE SIGNUP REQUEST RECORD
    public class SignUpRequestResponse 
    {
            
        public String Company {get; set;}
        public String Country {get; set;}
        public String CreatedBy {get; set;}
        public String CreatedById {get; set;}
        public DateTime CreatedDate {get; set;}
        public String CreatedOrgId {get; set;}
        public String ErrorCode {get; set;}
        public String FirstName {get; set;}
        public Boolean IsDeleted {get; set;}
        public String LastModifiedBy {get; set;}
        public DateTime LastModifiedDate {get; set;}
        public String LastName {get; set;}
        public String Name {get; set;}
        public String Owner {get; set;}
        public String OwnerId {get; set;}
        public String ProcessInstances {get; set;}
        public String ProcessSteps {get; set;}
        public String SignupEmail {get; set;}
        public String Status {get; set;}
        public String systemModStamp {get; set;}
        public String TemplateDescription {get; set;}
        public String TemplateId {get; set;}
        public Integer TrialDays {get; set;}
        public String TrialSourceOrgId {get; set;}
        public String UserName {get; set;}
        
    }
    
    // THIS METHOD IS USED TO SHOW THE REQUEST IN DEBUG IN A MORE READABLE FORMAT
    public static String toStr(HttpRequest request)
    {
        
        String returnValue = '';
        
        if (request != null)
        {
            returnValue = '\n';
            returnValue += '\n###########################################################';
            returnValue += '\nHTTP REQUEST: '; 
            returnValue += '\n###########################################################';
            returnValue += '\nCompressed: ' + request.getCompressed();
            returnValue += '\nEndpoint: ' + request.getEndpoint();
            returnValue += '\nMethod: ' + request.getMethod();
            returnValue += '\nHeader: ' + request.getHeader('Content-Type');
            returnValue += '\nHeader: ' + request.getHeader('Authorization');
            returnValue += '\nBody: ';
            returnValue += '\n' + request.getBody();
            returnValue += '\n';
            returnValue += '\n';
        }
        
        return returnValue;
        
    }
 
}