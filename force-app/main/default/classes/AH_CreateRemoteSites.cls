/************************************************************************************************
Name            : AH_CreateRemoteSites Class
Author          : Shashikant Nikam 
Created Date    : 4/19/2019
Last Mod By     : Shashikant Nikam
Last Mod Date   : 5/7/2019
NICC Reference  : NICC-034473
Description     : Class to create remote sites through AH_Batch_CreateRemoteSites class.
                : 
                : 
*************************************************************************************************/

public class AH_CreateRemoteSites {

    private String sessionId;
    private String serverUrl;
	private String orgId;     
    private String origLocale;    
    private String userId;    
    private String remoteSiteName;
    private String Endpoint_URL;
    private PollingResult__c pollingResult;
    public List<MetadataService.SaveResult> results;
    public List<MetadataService.SaveResult> results1;
    public MetadataService.ListMetadataQuery remoteSites;
    
    public AH_CreateRemoteSites()
    { }
        
	public AH_CreateRemoteSites(PollingResult__c p, String endURL)
    { 
        this.pollingResult = p;
        
        String s = endURL.substringBefore('.salesforce.com');
		this.Endpoint_URL = s + '.salesforce.com';
        system.debug('Endpoint_URL : '+Endpoint_URL);
        
        this.remoteSiteName = Endpoint_URL.replace('https://', '');
        remoteSiteName = remoteSiteName.replace('.salesforce.com', '');
        system.debug('remoteSiteName : '+remoteSiteName);
    }
    
    // LOGIN TO REMOTE ORG 
    public void login() 
    {   
        string sEndPoint = 'https://login.salesforce.com/services/Soap/u/55.0'; 
        
        if (pollingResult.AccountId__r.Org_Type__c.Contains('Salesforce Sandbox'))
        {   
            sEndPoint = 'https://test.salesforce.com/services/Soap/u/55.0'; 
        }

        PartnerRemote.Soap soap = new PartnerRemote.Soap();
        PartnerRemote.LoginResult loginResult = soap.login(pollingResult.AccountId__r.Admin_Login_Name_Encrypted__c, pollingResult.AccountId__r.Admin_Password_Encrypted__c.trim() + pollingResult.AccountId__r.Security_Token_Encrypted__c.trim(), sEndPoint);
        soap.endpoint_x = loginResult.serverUrl; 
        serverUrl = loginResult.serverUrl.split('/services')[0]; 
        sessionId = loginResult.sessionId; 
        orgId = loginResult.userInfo.organizationId; 
        origLocale = loginResult.userInfo.userLocale; 
        userId = loginResult.userInfo.userId; 
        
        system.debug('Login successful...');
        
        createRemoteSites();
    }

    // CREATE REMOTE SITE SETTING FOR THE FAILED ENDPOINTS
    public void createRemoteSites()
    {        
		String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        baseUrl = baseUrl.replace('visual.force', 'salesforce');
        baseUrl = baseUrl.replace('https://c.', 'https://');
		MetadataService.SERVER_URL = baseUrl;
        
        String userId = UserInfo.getUserId();
        sessionId = UserInfo.getSessionId();
        String userName = UserInfo.getName();
        
        system.debug('baseUrl '+baseUrl);
        system.debug('MetadataService.SERVER_URL : '+MetadataService.SERVER_URL);

        // READ EXISTING REMOTE SITE SETTINGS
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();        
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = sessionId; 
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        remoteSites = new MetadataService.ListMetadataQuery();
        remoteSites.type_x = 'RemoteSiteSetting';
        
        queries.add(remoteSites);
        MetadataService.FileProperties[] prop = service.listMetadata(queries, 28);
        System.debug('readResult : '+prop);
        
        Set<String> siteNames = new Set<String>();
        for (MetadataService.FileProperties p : prop)
        {
            siteNames.add(p.fullName);
        }
        
        remoteSiteName = remoteSiteName.replace('.my', '');
        remoteSiteName = remoteSiteName.replace('-', '_');
        
        system.debug('Final remoteSiteName : '+remoteSiteName);
        
        if (!siteNames.contains(remoteSiteName))
        {
            
            // CREATE NEW REMOTE SITE SETTING
            MetadataService.MetadataPort service1 = createService();
            MetadataService.RemoteSiteSetting remoteSiteSettings = new MetadataService.RemoteSiteSetting();
            remoteSiteSettings.fullName = remoteSiteName;
            remoteSiteSettings.url = Endpoint_URL;
            remoteSiteSettings.description = 'Automatically created by automated process based on Polling Result unauthorized endpoint error messages.';
            remoteSiteSettings.isActive = true;
            remoteSiteSettings.disableProtocolSecurity = false;
            
            results = new List<MetadataService.SaveResult>();
            results = service1.createMetadata(new MetadataService.Metadata[] { remoteSiteSettings });
            system.debug('Metadata API response : ' + results );
            
            Endpoint_URL = Endpoint_URL.replace('.salesforce.com', '-api.salesforce.com');
            
            // CREATE NEW REMOTE SITE SETTING FOR API
            MetadataService.MetadataPort service2 = createService();
            MetadataService.RemoteSiteSetting remoteSiteSettings1 = new MetadataService.RemoteSiteSetting();
            remoteSiteSettings1.fullName = remoteSiteName + '_API';
            remoteSiteSettings1.url = Endpoint_URL;
            remoteSiteSettings1.description = 'Automatically created by automated process based on Polling Result unauthorized endpoint error messages.';
            remoteSiteSettings1.isActive = true;
            remoteSiteSettings1.disableProtocolSecurity = false;
            
            results1 = new List<MetadataService.SaveResult>();
            results1 = service2.createMetadata(new MetadataService.Metadata[] { remoteSiteSettings1 });
            system.debug('Metadata API response : ' + results1 );
        }
    }


    public MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = sessionId;
        return service;		
    }
    
    public void WriteToLog(string ordDetailId, String errorMessage, string strObjectName, string strClassName, string strDMLType)    
    {
        system.debug('errorMessage : '+errorMessage);
           
        NI_Admin_Error_Log__c err = new NI_Admin_Error_Log__c();
        
        err.Message__c = errorMessage; 
        err.Object_Name__c = strObjectName; 
        err.Apex_Class_Name__c = strClassName;
        err.DML_Type__c = strDMLType;
        err.NI_Org_Details__c = ordDetailId; 
        
        database.insert(err, false);
    }
}