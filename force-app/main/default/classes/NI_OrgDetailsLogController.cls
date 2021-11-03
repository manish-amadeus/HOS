/****************************************************************************************
Name            : NI_OrgDetailsLogController Class
Author          : Stuart Emery
Created Date    : 9/7/2013
Last Mod Date   : 7/29/2015 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-007649
Description     : Controller Extension for the NI_OrgDetails VF Page 
                : 
                : 
******************************************************************************************/

public class NI_OrgDetailsLogController 
{
    
    private static final string strInvalidMsg = 'The Admin Login Name, Admin Password or Security Token is invalid for this NI Org Details record.';
    
    //ADD AN INSTANCE VARIABLE FOR THE STANDARD CONTROLLER
    private ApexPages.StandardController controller {get; set;}
    
    //CREATE THE VARIABLE FOR THE VF PAGEMESSAGE IF THE ORG DETAILS CREDENTIALS ARE INVALID
    Public String inValidCredPopupMsg {get;set;}
    
    //CREATE THE VARIABLE FOR THE CREDENTIALS STATUS FIELD ON THE ORG LOG RECORD
    Public String CredMsgLog {get;set;} 
    
    //CREATE THE VARIABLE FOR THE USERNAME
    Public String strUserName {get;set;}
    
    //CREATE THE VARIABLE FOR THE PASSWORD
    Public String strPassword {get;set;}
    
    //CREATE THE VARIABLE FOR THE SECURITY TOKEN
    Public String strSecToken {get;set;}
    
    //CREATE THE VARIABLE FOR THE PASSWORD + SECURITY TOKEN
    Public String strPwdSecToken {get;set;}  
    
    //CREATE THE VARIABLE FOR THE ENDPOINT FOR THE HTTPREQUEST
    Public String strEndPoint {get;set;}
    
    //CREATE THE VARIABLE FOR THE SALESFORCE URL
    Public String strSFurl {get;set;}         
    
    //ADD THE INSTANCE VARIABLE BEING PASSED BY ID ON THE URL
    private NI_Org_Details__c od {get;set;}
    
    //SET THE ID OF THE RECORD THAT IS CREATED -- USED BY THE TEST CLASS
    public ID newRecordId {get;set;}
    
    //SET TO HOLD THE RECORD TYPE IDs THAT SHOULD USE THE VISUALFORCE EDIT PAGE
    public Set<Id> setRecordTypeIds = new Set<Id>(); 
    
    //LIST TO HOLD THE VALUES FROM THE Org Details Record Type VF View Page CUSTOM SETTING  
    List<Org_Details_Record_Type_VF_View_Page__c> lstCSRecordType = Org_Details_Record_Type_VF_View_Page__c.getAll().values();
    Set<String> setCSRecordTypeName = new Set<String>();
    Map<String,String> mapCSRecordType = new Map<String,String>();
    
    //INITIALIZE THE CONTROLLER
    public NI_OrgDetailsLogController(ApexPages.StandardController controller) 
    {
        // System.debug('CONSTRUCTOR EXECUTES****');         
        // initialize the standard controller
        this.controller = controller;
        
        //LOAD THE CURRENT RECORD
        od = (NI_Org_Details__c)controller.getRecord();
        
        for(Org_Details_Record_Type_VF_View_Page__c csRtype : lstCSRecordType)
        {
            setCSRecordTypeName.add(csRtype.Name);
            System.debug('CUSTOM SETTING RECORD TYPE: ' + csRtype.Name);
        }
        
        //GET THE JOB REQUISITION RECORD TYPE 
        for(String strRecordTypeName : setCSRecordTypeName)
        {
            if(bRecordTypeFound(strRecordTypeName) == true)
            {
                setRecordTypeIds.add(NI_TestClassData.getRecordTypeId('NI_Org_Details__c', strRecordTypeName));
            }    
        } 
        System.debug('NUMBER OF RECORD TYPE IDs: ' + setRecordTypeIds.size());
        
        // INITIALIZE ACCESS VARIABLES ====================================================
        displayButton = NI_FUNCTIONS.hasAccessByPublicGroup(UserInfo.getUserId(), 'Org Details - Login Button');
        displayPasswordReader = NI_FUNCTIONS.hasAccessByPublicGroup(UserInfo.getUserId(), 'Org Details - Password Read');
        displayPasswordAdmin = NI_FUNCTIONS.hasAccessByPublicGroup(UserInfo.getUserId(), 'Org Details - Password Read Write');
        
        if (displayPasswordAdmin == true)
        {
            displayButton = true;
            displayPasswordReader = true;
        }
        if (displayPasswordReader == true)
        {
            displayButton = true;
        }
        
         //od = [SELECT Id, AdminLoginName__c, AdminPassword__c, SecurityToken__c, Org_Login_Authorized__c,
        //      Org_Type__c, LOD_SF_Login_URL__c,RecordTypeId,Admin_Login_Name_Encrypted__c,Admin_Password_Encrypted__c,
        //      Security_Answer_Encrypted__c,Security_Token_Encrypted__c
        //      FROM NI_Org_Details__c 
        //      WHERE Id = :od.id];
              
        //CHANGED TO QUERY ENCRYPTED FIELDS PER NICC-015316
        od = [SELECT Id, Org_Login_Authorized__c,
              Org_Type__c, LOD_SF_Login_URL__c,RecordTypeId,Admin_Login_Name_Encrypted__c,Admin_Password_Encrypted__c,
              Security_Answer_Encrypted__c,Security_Token_Encrypted__c
              FROM NI_Org_Details__c 
              WHERE Id = :od.id];
        
    }
    
    public boolean displayPopup {get; set;}
    
    public pagereference verifyCred()
    {
        
        // PREVENT REFRESH
        if (inValidCredPopupMsg == strInvalidMsg)
        {
            return null;
        }
        
        inValidCredPopupMsg = null;
        
        //od = [SELECT Id, AdminLoginName__c, AdminPassword__c, SecurityToken__c, Org_Login_Authorized__c,
        //      Org_Type__c, LOD_SF_Login_URL__c,RecordTypeId 
        //      FROM NI_Org_Details__c 
        //      WHERE Id = :od.id];    
        
        //SET THE STRUSERNAME AND STRPASSWORD VARIABLES     
        //strUserName = od.AdminLoginName__c;
        //strPassword = od.AdminPassword__c;
        //strSecToken = od.SecurityToken__c;
        //strPwdSecToken = strPassword + strSecToken;
        
        //ENCRYPTED FIELDS. SET THE STRUSERNAME AND STRPASSWORD VARIABLES  CHANGED PER NICC-015316
        strUserName = od.Admin_Login_Name_Encrypted__c;
        strPassword = od.Admin_Password_Encrypted__c;
        strSecToken = od.Security_Token_Encrypted__c;
        strPwdSecToken = strPassword + strSecToken;  
        
        //SET THE strEndPoint AND strSFurl VARIABLES BASED ON THE ORG TYPE
        if (od.Org_Type__c == 'Salesforce Production')
        {
            strEndPoint = 'https://login.salesforce.com/services/oauth2/token';
            strSFurl = 'https://login.salesforce.com/?un=' + EncodingUtil.urlEncode(strUserName,'UTF-8') + '&pw=' + EncodingUtil.urlEncode(strPassword,'UTF-8');
            System.debug('SALESFORCE LOGIN URL: ' + strSFurl);
        }                 
        
        if (od.Org_Type__c.contains('Salesforce Sandbox'))
        {
            strEndPoint = 'https://test.salesforce.com/services/oauth2/token';
            strSFurl = 'https://test.salesforce.com/?un=' + EncodingUtil.urlEncode(strUserName,'UTF-8') + '&pw=' + EncodingUtil.urlEncode(strPassword,'UTF-8');
            System.debug('SALESFORCE LOGIN URL: ' + strSFurl);
        } 
        
        // DISPLAY AN ERROR MESSAGE IF THE CREDENTIALS ARE NOT VALID   
        
        //CALL THE VALIDATEUSERCREDENTIALS FUNCTION TO VALIDATE THE CUSTOMER ORG USERNAME AND PASSWORD             
        boolean hasValidCreds = validateUserCredentials(strUserName, strPwdSecToken, strEndPoint); 
        
        if (!hasValidCreds)
        {          
            inValidCredPopupMsg = strInvalidMsg;
            CredMsgLog = 'Invalid Credentials';
            System.debug(inValidCredPopupMsg); 
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,inValidCredPopupMsg));
            createLog();
            return null;      
        }
        else              
        {
            inValidCredPopupMsg = null;
            CredMsgLog = 'Valid Credentials';
            showPopup();
            return null;
        }   
    }
    
    //DISPLAY POPUP MESSAGE BEFORE LOGGING INTO THE CUSTOMER ORG
    public void showPopup() 
    {
        displayPopup = true;
    } 
    
    //CLOSE THE POPUP MESSAGE
    public void closePopup() 
    {
        displayPopup = false;      
    }
    
    //METHOD CALLED FROM THE VF ACTION ATTRIBUTE TO CREATE THE LOG RECORD AND LOG THE USER INTO THE CUSTOMER ORG
    public PageReference createLog() 
    {           
        //CLOSE THE POPUP MESSAGE
        closePopup();
        
        NI_Org_Details_Log__c newR = new NI_Org_Details_Log__c();        
        
        // GET THE IP ADDRESS OF THE CURRENT USER
        String ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        
        try
        {                            
            newR.NI_Org_Details__c = od.id;
            newR.Org_Login_Authorized__c = od.Org_Login_Authorized__c;
            newR.Source_Ip__c = ipAddress;
            newR.Credentials_Status__c = CredMsgLog;        
            
            //INSERT THE ORG DETAILS LOG RECORD
            Database.insert(newR);
            
        }  catch(System.DMLException e){
            System.debug('ERROR: -----' + e);                  
        }
        
        //GET THE ID OF THE NEW NI ORG DETAILS LOG RECORD FOR TESTING
        newRecordId = newR.Id;
        
        //LOG INTO THE CUSTOMER ORG                       
        System.debug('ORG LOGIN URL: ' + strSFurl);
        return new PageReference(strSFurl); 
    } 
    
    //WEB SERVICES REST CALL TO VALIDATE THE ORG DETAILS CREDENTIALS BEFORE LOGGING INTO THE CUSTOMER ORG
    private boolean validateUserCredentials(String UserName, String UserPassword, String sEndPoint)
    {   
        Httprequest req = new HttpRequest();    
        req.setMethod('POST');    
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        
        String ClientId = '3MVG9ahGHqp.k2_yu4fK6DiHO_sxE0VHw3r1mBpaoyvq3FY84g7BEsNCYed2glUWmm_SJoWYFkGNi8VDncqt1';
        String ClientSecret = '856436911471828417';                        
        
        req.setBody('grant_type=password' + 
                    '&client_id=' + ClientId + 
                    '&client_secret=' + ClientSecret + 
                    '&username=' + EncodingUtil.urlEncode(UserName,'UTF-8') + 
                    '&password=' + EncodingUtil.urlEncode(UserPassword,'UTF-8'));     
        req.setEndpoint(sEndPoint);         
        Http http = new Http();
        HttpResponse res;
        
        system.debug(res);
        
        try {
            
            if(!Test.isRunningTest())
            { 
                res = http.send(req);
            }                  
            if((Test.isRunningTest()) && (NI_TriggerManager.isValidOrgDetails = false))
            {
                res = http.send(req);
            }
            if((Test.isRunningTest()) && (NI_TriggerManager.isValidOrgDetails = true))
            {   
                return true;
            } 
            
        }
        catch(system.CalloutException e)
        {
            ApexPages.addMessage(new ApexPages.Message
                                 
                                 (ApexPages.Severity.ERROR, e.getMessage()));
            NI_TriggerManager.isValidOrgDetails = true;
            return false;          
        }
        
        if(res.getStatusCode() > 300)
            return false;         
        
        return true;                    
        
    }
    
    
    
    
    
    // PASSWORD VIEWER ================================================================================
    // PASSWORD VIEWER VARIABLES 
    public boolean displayPwdPopup {get; set;}
    public boolean displayButton {get; set;}
    public boolean displayPasswordReader {get; set;}
    public boolean displayPasswordAdmin {get; set;}
    
    public void showPwdPopup() 
    {
        displayPwdPopup = true;
    } 
    
    public pagereference closePwdPopup() 
    {
        PageReference newPage;
        displayPwdPopup = false; 
        newPage = new PageReference('/' + od.id);
        newPage.getParameters().put('id', od.id);
        return newPage.setRedirect(true);
       
    }   
    
    public pagereference showPwd()
    {
        
        // CREATE LOG ACTIVITY WHEN USER VIEWS PASSWORD 
        NI_Org_Details_Log__c newR = new NI_Org_Details_Log__c();        
        
        // GET THE IP ADDRESS OF THE CURRENT USER
        String ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        
        try
        {        
            newR.NI_Org_Details__c = od.id;
            newR.Org_Login_Authorized__c = od.Org_Login_Authorized__c;
            newR.Source_Ip__c = ipAddress;
            newR.Credentials_Status__c = 'Viewed Credentials';        
            
            //INSERT THE ORG DETAILS LOG RECORD
            Database.insert(newR);            
        }  
        catch (System.DMLException e)
        {
        }       
        
        showPwdPopup();
        return null;
        
    }
    
    public boolean bIsButtonUser
    {
        get 
        {        
            return displayButton;
        }
        set;
    }
    
    public boolean bIsPwdRead
    {
        get 
        {        
            return displayPasswordReader;
        }
        set;
    }
    
    public boolean bIsPwdReadWrite
    {
        get 
        {        
            return displayPasswordAdmin;
        }
        set;
    }
    
    //**************************************************************************************************
    //                                       PAGE REDIRECT METHODS
    //**************************************************************************************************
    
    //METHOD TO REDIRECT THE USER TO THE STANDARD VIEW PAGE OR CUSTOM VISUALFORCE PAGE
    public PageReference redirectViewPage() 
    { 
        
        
        //GET THE OBJECT PREFEX CODE FOR THE ORG DETAILS OBJECT  
        String rType = od.RecordTypeId;
        
        PageReference newPage;
        
        if(setRecordTypeIds.size()>0 && setRecordTypeIds.contains(rType))
        {     
            System.debug('Record Type Id: ' + rType);
            newPage = page.NI_OrgDetails; 
        } 
        else 
        {
            System.debug('Record Type Id: ' + rType);
            newPage = new PageReference('/' + od.id);
            newPage.getParameters().put('nooverride', '1');
        }
        
        newPage.getParameters().put('id', od.id);
        return newPage.setRedirect(true);
        
    }
    
    //**************************************************************************************************
    //                                       FUNCTIONS
    //**************************************************************************************************                                          
    
    public boolean bRecordTypeFound(String strRtype)
    {
        List<RecordType> lstRecordTypes = [SELECT Id FROM RecordType WHERE Name =:strRtype];
        If(lstRecordTypes.size()>0)
        {
            Return true; 
        }
        else
        {
            Return false;  
        }  
    }
    
}