/****************************************************************************************
Name            : AH_SCIM_UserSyncCallout Class
Author          : Ganesh Bora
Created Date    : 05/01/2022
Last Mod Date   :  
Last Mod By     : 
NICC Reference  :  NICC-056411
Description     : class for user sync up SCIM User resource type, 
                : class is used to create and parse SCIM user object request response.
                : 
****************************************************************************************/
public class AH_SCIM_UserSyncCallout 
{
	public String companyId;
	public String clientSecret;
	public String clientPassword;
	public String clientId;
    public string baseUrl;
    public boolean sfuserIsActive;
	public boolean ValamisfetchedUserActiveStatus;    
    
    //Start : Inner Classes =============================
    public class ResponseToken 
    {
        public String access_token;
        public String expires_in;
        public String token_type;
    }
    public class AH_SCIM_Users{
		public Integer count{get;set;}
		public Integer startIndex{get;set;}
		public list<AH_SCIM_User> resources{get;set;}
		public Integer totalResults{get;set;}
    }
    //End : Inner Classes =================================
    
    // CLASS CONTROLLER. SETS THE NEEDED VARIABLES BASED ON CUSTOM SETTINGS  
    public AH_SCIM_UserSyncCallout() 
    {
        ValamisAPISignUpSettings__c sr  = ValamisAPISignUpSettings__c.getOrgDefaults();
        
        companyId = sr.companyId__c;
        clientSecret = sr.clientSecret__c;
        clientPassword = sr.clientPassword__c;
        clientId = sr.clientId__c;
        baseUrl = sr.baseUrl__c;
        
    } 
    public void ping() 
    {
        string endpoint = '/o/scim-rest/scim/ping';
        String restAPIURL = this.baseUrl+''+endpoint;
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('GET');  
        httpRequest.setEndpoint(restAPIURL); 
        String response = '';
        try 
        {  
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            if (httpResponse.getStatusCode() == 200 ) {  
                System.debug(' httpResponse ' + httpResponse.getStatusCode() +''+httpResponse.getBody() ); 
            } 
            else {  
                System.debug(' httpResponse '+ httpResponse.getStatusCode() +''+ httpResponse.getBody() );  
                throw new CalloutException( httpResponse.getStatusCode() +''+ httpResponse.getBody() );  
            }   
        } 
        catch( System.Exception e) 
        {  
            System.debug('ERROR: '+ e);  
            String strExDetails = 'ERROR: '+ e.getMessage();
            DTS_Integration_Logger.WriteToLog(strExDetails, 'user', 'AH_SCIM_UserSyncCallout', 'update','Error');                  
            throw e;  
        }  
    }

    /* 
     * Function to check user present in valamis or not.
     * if matching user found it returns the user UUID
     */ 
   
    public string checkUserExistsByUserName(string UserName)    
    {
        string accessToken = '';
		string endpoint = '/o/scim-rest/scim/Users';
        
        //New Filter Parameter search by externalID as userIdentifier custom field
		string filterParameter = 'urn:ietf:params:scim:schemas:extension:valamis:2.0:User:custom co {"key":"userIdentifier", "value": "'+UserName+'"}';
        //string filter = 'filter='+EncodingUtil.URLENCODE('UserName eq "'+UserName+'"','UTF-8');       
        string filter = 'filter='+EncodingUtil.URLENCODE(filterParameter,'UTF-8');       
        String restAPIURL = this.baseUrl+''+endpoint+'?'+filter;
        
		//Get Access Token
        accessToken = this.getAccessToken();
        if(accessToken == null) return null;
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('GET');             
        httpRequest.setHeader('Authorization', 'Bearer ' + accessToken);
		httpRequest.setEndpoint(restAPIURL);
        String response = '';
        AH_SCIM_UserSyncCallout.AH_SCIM_Users records = null;
        
        try 
        { 
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            if (httpResponse.getStatusCode() == 200 ) 
            {  
                System.debug(' httpResponse ' + httpResponse.getBody());
                String responseBody = httpResponse.getBody();
                records = (AH_SCIM_UserSyncCallout.AH_SCIM_Users)JSON.deserialize(httpResponse.getBody(),AH_SCIM_UserSyncCallout.AH_SCIM_Users.class);
                if(records.totalResults == 1)
                {   
                    //fetching original valamis side status of user record.
                    this.ValamisfetchedUserActiveStatus = records.resources[0].active;
                    //matching user found return user ID
                    return records.resources[0].id;   
                } 
                else
                {
                    return null;
                } 
            } 
            else 
            {  
                System.debug('httpResponse ' + httpResponse.getBody());
                throw new CalloutException( httpResponse.getStatusCode() +''+ httpResponse.getBody());
            }   
        } 
        catch( System.Exception e) 
        {
            String strExDetails = 'ERROR: '+ e.getMessage();
            DTS_Integration_Logger.WriteToLog(strExDetails, 'user', 'AH_SCIM_UserSyncCallout', 'update','Error');                  
            throw e;  
        }       
    }
    /* 
     * Function get the access token from valamis system.
     */
    public string getAccessToken() 
    {
        string endpoint = '/o/scim-rest/scim/oauth2/token';
        String restAPIURL = this.baseUrl+''+endpoint;
        String requestBody = 'grant_type=password&client_id='+ this.ClientId +'&client_secret='+ this.ClientSecret;
        system.debug(requestBody);
        AH_SCIM_UserSyncCallout.ResponseToken logintoken = null;
        String response = '';
        
        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setMethod('POST');  
        httpRequest.setHeader('Content-Type','application/x-www-form-urlencoded');
        httpRequest.setEndpoint(restAPIURL);
        httpRequest.setBody(requestBody);     
        try 
        { 
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);  
            if (httpResponse.getStatusCode() == 200 ) 
            {  
                String responseBody = httpResponse.getBody(); 
                logintoken = (AH_SCIM_UserSyncCallout.ResponseToken)JSON.deserialize(httpResponse.getBody(),AH_SCIM_UserSyncCallout.ResponseToken.class);  

                return logintoken.access_token;
            } 
            else 
            {  
                throw new CalloutException( httpResponse.getStatusCode() +''+ httpResponse.getBody());
            }   
        } 
        catch( System.Exception e) 
        {  
            String strExDetails = 'ERROR: '+ e.getMessage();
            DTS_Integration_Logger.WriteToLog(strExDetails, 'user', 'AH_SCIM_UserSyncCallout', 'update','Error'); 
        }  
        return null;
    }
    /*
     * function provide functionality to sync user data with valamis.
     */ 
    public void syncUser(AH_SCIM_User userData) 
    {
        string userUUID = null;

        /* check if user already present, if present update the same user with UUID
         * if not present create the user with provided user data
         */ 
        //Get Access Token
        string accessToken = this.getAccessToken();
        if(accessToken == null) {
            system.debug('Environment is not accessible or credentials are not matching');
         	return;   
        }
        
        
        //userUUID = this.checkUserExistsByUserName(userData.UserName);        
        userUUID = this.checkUserExistsByUserName(userData.externalId);
        system.debug(userUUID);
        if(userUUID != null) 
        {
            this.updateUser(userData,userUUID);
        } 
        else 
        {	
            this.createUser(userData);
        } 
    }

    public AH_SCIM_User getDummySCIMUserDataObject()
    {
        AH_SCIM_User userData = new AH_SCIM_User();
        
        userData.name = new AH_SCIM_User.Name();
        userData.name.formatted = '';
        userData.name.familyName = '';
        userData.name.givenName = '';
        
        userData.userName = '';
        
        userdata.urn_ietf_params_scim_schemas_extension_valamis_2_0_User = new AH_SCIM_User.cls_urn_ietf_params_scim_schemas_extension_valamis_2_0_User();
        userData.meta = new AH_SCIM_User.Meta(); 
        userData.meta.resourceType = 'User';
        
        userData.schemas = new List <string>();
        userData.schemas.add('urn:ietf:params:scim:schemas:core:2.0:User');
        userData.schemas.add('urn:ietf:params:scim:schemas:extension:enterprise:2.0:User');
        userData.schemas.add('urn:ietf:params:scim:schemas:extension:valamis:2.0:User');

        return userData;
    } 
    public void createUser(AH_SCIM_User userData) 
    {
        string endpoint = '/o/scim-rest/scim/Users';
        String restAPIURL = this.baseUrl+''+endpoint;
        string accessToken = '';
        String response = '';
        
        //Mark User as inactive while creating it.
        userdata.active = false; 
        System.Debug('Create User Status' + userdata.active);
        
        //Get Access Token
        accessToken = this.getAccessToken();
        if(accessToken == null) return;
        
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('POST');             
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setHeader('Authorization', 'Bearer ' + accessToken);
		httpRequest.setEndpoint(restAPIURL);
        
        String jsonBody = json.serialize(userData);
        
        if (jsonBody != null) 
        {
            jsonBody = jsonBody.replace('urn_ietf_params_scim_schemas_extension_valamis_2_0_User', 'urn:ietf:params:scim:schemas:extension:valamis:2.0:User');
            httpRequest.setBody(jsonBody);
            httpRequest.setHeader('Content-length',string.valueOf(jsonBody.length()));
        }
        
        try 
        { 
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest); 
            
            if (httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201) 
            {  
                String responseBody = httpResponse.getBody();
                AH_SCIM_user user = (AH_SCIM_user)JSON.deserialize(httpResponse.getBody(),AH_SCIM_user.class);
                this.updateLMSUserAccessFieldStatus(userData.externalId);
            } 
            else if (httpResponse.getStatusCode() == 409) 
            {  
                //Conflict User allredy Present
                system.debug('Conflict User allredy Present');
                System.debug(httpResponse.getBody());
                System.debug(' httpResponse ' + httpResponse.getBody());
            }
            else 
            {  
                throw new CalloutException( httpResponse.getStatusCode() +''+ httpResponse.getBody());
            }   
        } 
        catch( System.Exception e) 
        {  
            String strExDetails = 'ERROR: '+ e.getMessage();
            DTS_Integration_Logger.WriteToLog(strExDetails, 'user', 'AH_SCIM_UserSyncCallout', 'update','Error'); 
        } 
    }
    
    public void updateUser(AH_SCIM_User userData,string userUUID)
    {
        string endpoint = '/o/scim-rest/scim/Users';
        String restAPIURL = this.baseUrl+''+endpoint+'/'+userUUID;
        system.debug('restAPIURL'+restAPIURL);
        string accessToken = '';
        String response = '';
        
        //For UPDATE  use UUID
		//string endpoint = '/o/scim-rest/scim/Users/6994177c-a4a4-1967-360d-33e7123c09a9';
		
        //Get Access Token
        accessToken = this.getAccessToken();
        if(accessToken == null) 
        {
         	return;   
        }
        //preserve user status at valamis side
        if(this.sfuserIsActive == false ) 
        {
            //if user deactivated at SF side mark it deactive at valamis side.
        	userData.active = false;
        } 
        else 
        {
            system.debug('ValamisfetchedUserActiveStatus'+ValamisfetchedUserActiveStatus);
            //if user is active at SF side preserve user status at valamis side. 
            userdata.active =  this.ValamisfetchedUserActiveStatus;    
        }
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('PUT');             
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setHeader('Authorization', 'Bearer ' + accessToken);
		httpRequest.setEndpoint(restAPIURL);
        
        String jsonBody = json.serialize(userData);
        if (jsonBody != null) 
        {
            jsonBody = jsonBody.replace('urn_ietf_params_scim_schemas_extension_valamis_2_0_User', 'urn:ietf:params:scim:schemas:extension:valamis:2.0:User');
            system.debug('json:'+jsonBody);
            httpRequest.setBody(jsonBody);
            httpRequest.setHeader('Content-length',string.valueOf(jsonBody.length()));
        }
        
        try 
        { 
            Http http = new Http();   
			HttpResponse httpResponse = http.send(httpRequest);  
            if (httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201) 
            {  
                String responseBody = httpResponse.getBody(); system.debug('user updated');
                AH_SCIM_user user = (AH_SCIM_user)JSON.deserialize(httpResponse.getBody(),AH_SCIM_user.class);
            } 
			else 
		    {  
				throw new CalloutException( httpResponse.getStatusCode() +''+ httpResponse.getBody());
            }   
        } 
        catch( System.Exception e) 
        {  
            String strExDetails = 'ERROR: '+ e.getMessage();
            DTS_Integration_Logger.WriteToLog(strExDetails, 'user', 'AH_SCIM_UserSyncCallout', 'update','Error'); 
        } 
    } 
    public void updateLMSUserAccessFieldStatus(string username)
    {
        User u1 = [SELECT id, Username, LMS_User_Access__c FROM user WHERE Username = :username];
        u1.LMS_User_Access__c = 'User Created in LMS';
        update u1;
    }
}