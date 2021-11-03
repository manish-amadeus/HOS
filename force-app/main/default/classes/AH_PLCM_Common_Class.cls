/***********************************************************************************************
Name            : AH_PLCM_Common_Class
Author          : Sanjay Parmar
Created Date    : 21-May-2019
Last Mod Date   : 21-May-2019
Last Mod By     : Sanjay Parmar
NICC Reference  : 
Description     : Class for Property page
************************************************************************************************/
public abstract class AH_PLCM_Common_Class {
    //Pages Name
    public class AH_PLCM_Page_Names {
        public string TermsAndConditionPage = '/apex/AH_PLCM_Terms_And_Conditions';
        public string IntroductionPage = '/apex/AH_PLCM_Introduction';
        public string PropertyPage = '/apex/AH_PLCM_Property';
        public string CreateUserPage = '/apex/AH_PLCM_Create_User';
        public string TransferUserPage = '/apex/AH_PLCM_User_Xref';
        public string ThankYouPage = '/apex/AH_PLCM_Thank_You';
        public string ErrorPage = '/apex/AH_PLCM_Error_Page';
    }

    //Portal Progress Status
    public class AH_PLCM_Project_Portal_Status {
        public string PropertyUpdated = 'Property Details Complete';
        public string UsersCreated = 'Migration Users Complete';
        public string XrefCompleted = 'Cross-Reference Complete';
        public string CustomerInputCompleted = 'Customer Inputs Complete';
        public boolean IsPropertyUpdated { get; set; }
        public boolean IsUsersCreated { get; set; }
        public boolean IsXrefCompleted { get; set; }
        public integer PerecentageCompleted { get; set; }
    }

    //Bubble Help Popup Status
    public class AH_PLCM_Project_Bubble_Status {
        public boolean IsPropertyBubbleSkipped { get; set; }
        public boolean IsUserBubbleSkipped { get; set; }
        public boolean IsXrefBubbleSkipped { get; set; }
    }

    //Properties Declaration
    public AH_PLCM_Page_Names PageNames { get { return new AH_PLCM_Page_Names(); } }
    public AH_PLCM_Project_Portal_Status ProjectPortalStatus { get; set; }
    public AH_PLCM_Project_Bubble_Status ProjectBubbleStatus { get; set; }    
    public String ProjectId { get; set; }
    public String UserName { get; set; }
    public String BaseUrl { get; set; }
    public String CommunityUrl { get; set; }
    public boolean IsTestClass { get; set; } 
    public boolean IsErrorOccurred { get; set; }
    public Exception ErrorDetails { get; set; }
    public boolean IsTargetUserExist { 
        get {
            List<AH_PLCM_TargetOrg_User__c> lstSalesforceUsers = null;
            try {
                if(IsTargetUserExist == null) {
                    //Check if target users exist or not for the project
                    lstSalesforceUsers = new List<AH_PLCM_TargetOrg_User__c>([SELECT Id FROM AH_PLCM_TargetOrg_User__c WHERE PLCM_Migration_Project_Name__c = : ProjectId]);
                    return lstSalesforceUsers != null && lstSalesforceUsers.size() > 0;
                }
                else {
                    return IsTargetUserExist;
                }
            }
            catch(Exception ex) {
                throw ex;
            }
            finally {
                //Release object's memory
                lstSalesforceUsers = null;
            }
        }
    }

    public AH_PLCM_Common_Class() {
        try {
            IsErrorOccurred = false;
            //Get Logged In User Name
            UserName = UserInfo.getName();
            IsTestClass = false;

            //If terms and condition page, then no need to set variables value
            if(ApexPages.currentPage().getUrl().indexOf('AH_PLCM_Terms_And_Conditions') == -1) {
                //Fetch Project Status and Update Variables Value
                SetVariablesValue();
            }
        }
        catch(Exception ex) {
            throw ex;
        }
    }


    //Set values of common variables
    public void SetVariablesValue() {
        List<NI_Documentation__c> lstProjects = null;
        try {
            //Get base url
            BaseUrl = URL.getSalesforceBaseUrl().toExternalForm();

            //Get Project Id From Parameters
            ProjectId = GetParameterValue('ProjectId');
            
            //Initialize project portal status object with default values
            ProjectPortalStatus = new AH_PLCM_Project_Portal_Status();
            ProjectPortalStatus.IsPropertyUpdated = false;
            ProjectPortalStatus.IsUsersCreated = false;
            ProjectPortalStatus.IsXrefCompleted = false;
            ProjectPortalStatus.PerecentageCompleted = 0;

            //Initialize bubble help status object with default values
            ProjectBubbleStatus = new AH_PLCM_Project_Bubble_Status();
            ProjectBubbleStatus.IsPropertyBubbleSkipped = false;
            ProjectBubbleStatus.IsUserBubbleSkipped = false;
            ProjectBubbleStatus.IsXrefBubbleSkipped = false;
            
            //Fetch project portal status and bubble help status to set variables value
            lstProjects = new List<NI_Documentation__c>([SELECT AH_PLCM_Portal_Progress__c, AH_PLCM_Is_Property_Bubble_Help_Skipped__c, AH_PLCM_Is_User_Bubble_Help_Skipped__c, AH_PLCM_Is_User_XRef_Bubble_Help_Skipped__c FROM NI_Documentation__c WHERE Id = :ProjectId]);
            
            if(lstProjects.size() > 0) {
                if(lstProjects.get(0).AH_PLCM_Portal_Progress__c == ProjectPortalStatus.PropertyUpdated) {
                    ProjectPortalStatus.IsPropertyUpdated = true;
                    //Property detail updated so set progress bar percentage 25%
                    ProjectPortalStatus.PerecentageCompleted = 25;
                }
                else if(lstProjects.get(0).AH_PLCM_Portal_Progress__c == ProjectPortalStatus.UsersCreated) {
                    ProjectPortalStatus.IsPropertyUpdated = true;
                    ProjectPortalStatus.IsUsersCreated = true;
                    //Users created updated so set progress bar percentage 25%
                    ProjectPortalStatus.PerecentageCompleted = 50;
                }
                else if(lstProjects.get(0).AH_PLCM_Portal_Progress__c == ProjectPortalStatus.XrefCompleted || lstProjects.get(0).AH_PLCM_Portal_Progress__c == ProjectPortalStatus.CustomerInputCompleted) {
                    ProjectPortalStatus.IsPropertyUpdated = true;
                    ProjectPortalStatus.IsUsersCreated = true;
                    ProjectPortalStatus.IsXrefCompleted = true;
                    //User Cross Reference Mapping is complete so set progress bar percentage 25%
                    ProjectPortalStatus.PerecentageCompleted = 100;
                }

                //Set Bubble Help Status Variables Value
                ProjectBubbleStatus.IsPropertyBubbleSkipped = boolean.valueOf(lstProjects.get(0).AH_PLCM_Is_Property_Bubble_Help_Skipped__c);
                ProjectBubbleStatus.IsUserBubbleSkipped = boolean.valueOf(lstProjects.get(0).AH_PLCM_Is_User_Bubble_Help_Skipped__c);
                ProjectBubbleStatus.IsXrefBubbleSkipped = boolean.valueOf(lstProjects.get(0).AH_PLCM_Is_User_XRef_Bubble_Help_Skipped__c);
                
            }
        }
        catch(Exception ex) {
            throw ex;
        }
        finally {
            //Release object's memory
            lstProjects = null;
        }
    }

    //Request from Test Class
    public boolean setIsTestClassAsTrue(){
        this.IsTestClass = true;
        return this.IsTestClass;
    }

    //Update project portal status
    public void UpdatePortalStatus(string strStatus) {
        List<NI_Documentation__c> lstProjects = null;
        try {
            //Get project portal status values
            lstProjects = new List<NI_Documentation__c>([SELECT AH_PLCM_Portal_Progress__c FROM NI_Documentation__c WHERE Id = :ProjectId]);

            if(lstProjects.size() > 0) {
                //Update Completed Status
                lstProjects[0].AH_PLCM_Portal_Progress__c = strStatus;
                update lstProjects;
            }           
        }
        catch(Exception ex) {
            throw ex;
        }
        finally {
            //Release object's memory
            lstProjects = null;
        }
    }

    //Redirect to error page while error generate
    public PageReference RedirectToErrorPage(string MethodName,Exception ex) {  
        try {      
            //send error notification
            SendErrorNotification(MethodName,ex);
            //Redirect to Error Page
            return RedirectToPage(PageNames.ErrorPage, null);
        }
        catch(Exception ErrorException) {
            throw ErrorException;
        }
    }

    //Redirect to specific page
    public PageReference RedirectToPage(string strPageName, Map<string, string> lstParameters) {
        PageReference pageRef = null;
        try {
            //Prepare page reference object
            pageRef = new PageReference(strPageName);

            if(lstParameters != null && lstParameters.size() > 0) {
                for (string key : lstParameters.keySet()) {
                    //Add parameters
                    pageRef.getParameters().put(key, lstParameters.get(key));
                }
            }

            if(!IsTestClass) { //This code is not supported in test class
                String networkId = Network.getNetworkId();
                ConnectApi.Community comm = ConnectApi.Communities.getCommunity(networkId);
                CommunityUrl = comm.siteUrl;
            }

            if(CommunityUrl.indexOf('neighborhood') > -1) { //Only for Neighborhood Community
                string strTabName = GetParameterValue('sfdc.tabName');
                if(strTabName != null && strTabName != '') { //Page opened from neighborhood community
                    //Add tab name in query string parameters
                    pageRef.getParameters().put('sfdc.tabName', strTabName);
                }
            }
            else {
                for(String key: ApexPages.currentPage().getParameters().keySet()) {
                    if(key.toLowerCase().indexOf('viewstate') == -1
                        && key.toLowerCase().indexOf('frm') == -1
                        && key.toLowerCase().indexOf('ddl') == -1
                        && key.toLowerCase().indexOf('projectid') == -1) { //Do not add post parameters
                        string value = ApexPages.currentPage().getParameters().get(key);
                        pageRef.getParameters().put(key, value);
                    }
                }

                // string strCurrentUrl = CommunityUrl + strPageName;// + '?' + getAllQueryString();
                // pageRef = new PageReference(strCurrentUrl);
            }
            pageRef.setRedirect(true);
            return pageRef;
        }
        catch(Exception ex) {
            throw ex;
        }
        finally {
            //Release object's memory
            pageRef = null;
        }
    }

    //Get parameter value based on name
    public string GetParameterValue(string strParamName) {
        try {
            if (ApexPages.currentPage().getParameters().containsKey(strParamName)) {
                //Get parameter value and return
                return string.valueOf(ApexPages.currentPage().getParameters().get(strParamName));
            }
            return '';
        }
        catch(Exception ex) {
            throw ex;
        }
    }

    //Get string of all query string values
    public String getAllQueryString() {
        String strQueryString = '';
        for(String key: ApexPages.currentPage().getParameters().keySet()) {
            if(key.toLowerCase().indexOf('iframe') > -1) { //Do not add post parameters
                strQueryString += (strQueryString != '' ? '&' : '') + key + '=' + ApexPages.currentPage().getParameters().get(key);
            }
        }
        return strQueryString;
    }

    //Get assigned projects for logged in user
    public List<NI_Documentation__c> GetProjectsByUser(boolean IsTermsAndConditionsPage) {
        List<NI_Documentation__c> lstProjects = null;
        List<NI_Documentation__c> lstAllProjects = null;
        List<UserRecordAccess> lstUserAccess = null;
        List<string> lstProjectIds = null;
        try {       
            if(IsTermsAndConditionsPage) {
                //Get all projects for which terms and conditions are not accepted
                lstAllProjects = new List<NI_Documentation__c>([SELECT Id, AH_PLCM_IsTerms_and_Conditions_Accepted__c, AH_PLCM_Terms_and_Cndtions_Accepted_Date__c, AH_PLCM_IsOpt_Out_of_Social_Media__c 
                                                                FROM NI_Documentation__c 
                                                                WHERE RecordType.Name = 'PLCM Migrations' AND AH_PLCM_IsTerms_and_Conditions_Accepted__c = false]);
            }   
            else {
                //Get all projects from salesforce object
                lstAllProjects = new List<NI_Documentation__c>([SELECT Id, Name, Document_Name__c, AH_PLCM_Portal_Progress__c, AH_PLCM_Portal_Completion_Due_Date__c, AH_PLCM_Migration_Date__c, AH_PLCM_Proposed_Migration_Date__c, AH_PLCM_IsTerms_and_Conditions_Accepted__c, AH_PLCM_Terms_and_Cndtions_Accepted_Date__c 
                                                                FROM NI_Documentation__c 
                                                                WHERE RecordType.Name = 'PLCM Migrations' AND AH_PLCM_IsTerms_and_Conditions_Accepted__c = true AND AH_PLCM_MigrationProgress__c <> 'Migration Complete' 
                                                                ORDER BY Document_Name__c]);
            }
            
            // managing the projectids in chunks
            Integer totalChunks = 0;
            if(lstAllProjects != null && lstAllProjects.size() > 0) {
                totalChunks = lstAllProjects.size() / 200;
                Integer mod = Math.mod(lstAllProjects.size(), 200);
                if(mod > 0)
                    totalChunks++;
            }
            System.debug('totalChunks => ' + totalChunks);
            
            lstUserAccess = new List<UserRecordAccess>();
            for(Integer i = 0; i < totalChunks; i++) {
                lstProjectIds = new List<string>();
                for(Integer j = (i * 200); j < ((i + 1) * 200); j++) {
                    if(j >= lstAllProjects.size()) 
                        break;
                    else {
                        //Fill Project Ids in list
                        lstProjectIds.add(lstAllProjects.get(j).Id);
                    }
                }
                
                System.debug('lstProjectIds.size() => ' + lstProjectIds.size());
                if(lstProjectIds != null && lstProjectIds.size() > 0) {
                    //Get record access details based on project ids
                    lstUserAccess.addAll([
                        SELECT RecordId, HasReadAccess, HasEditAccess
                        FROM UserRecordAccess
                        WHERE UserId = :UserInfo.getUserId() AND RecordId IN :lstProjectIds
                    ]);
                }
            }
            
            lstProjects = new List<NI_Documentation__c>();
            if(lstUserAccess != null && lstUserAccess.size() > 0) {
                System.debug('lstUserAccess.size() => ' + lstUserAccess.size());
                for (NI_Documentation__c objProj : lstAllProjects) {
                    for (UserRecordAccess obj : lstUserAccess) {
                        //Check if user has access of the project or not
                        if(obj.HasReadAccess == true && obj.HasEditAccess == true && obj.RecordId == objProj.Id) {
                            lstProjects.add(objProj);
                        }
                    }
                }
                System.debug('lstProjects.size() => ' + lstProjects.size());
            }
            return lstProjects;
        }
        catch(Exception ex) {
            system.debug('GetProjectsByUser->error'+ ex);
            throw ex;
        }
        finally {
            //Release memory of unused objects
            lstProjects = null;
            lstAllProjects= null;
            lstUserAccess = null;
            lstProjectIds = null;
        }
    }

    //Redirect to terms and condition page if not accepted
    public PageReference CheckTermsAndConditionStatus() {
        if(IsErrorOccurred) {
            //If error occurred then redirect to error page
            return RedirectToErrorPage('Error From Constructor', ErrorDetails);
        }

        List<NI_Documentation__c> lstProjects = null;        
        try {
            //Get all assigned projects for logged in user
            lstProjects = GetProjectsByUser(true);

            if(lstProjects != null && lstProjects.size() > 0) {
                //Redirect to terms and condition page because user have access of one or more projects for which terms and condition does not accepted                                         
                return RedirectToPage(PageNames.TermsAndConditionPage, null);
            }
            return null;            
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('CheckTermsAndConditionStatus',ex);
        }
        finally {
            //Release object's memory
            lstProjects = null;
        }        
    }

    //Attach file into NI Documentation Files section
    public void SaveFile(Id parentId, String fileName, Blob base64Data) {
        ContentVersion cv = new ContentVersion(); //Salesforce standard object ContentVersion
        cv.ContentLocation = 'S';
        cv.VersionData = base64Data;
        cv.Title = fileName;
        cv.PathOnClient = filename;
        insert cv;           
        
        ContentDocumentLink cdl = new ContentDocumentLink(); //Salesforce standard object ContentDocumentLink
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = parentId;
        cdl.ShareType = 'V';
        insert cdl;
    } 

    public void SendErrorNotification(string MethodName,Exception ex) {
        system.debug('SendErrorNotification'+ex);
        String intLineNumber = ex != null ? String.valueOf(ex.getLineNumber()) : 'Line number not available';
        String strErrorDetails = ex != null ? string.valueOf(ex) : 'Error details not available';
        string EmailBody = '', strPageName = ApexPages.currentPage().getUrl().replaceAll('\\?.*', '').replaceAll('/apex/', '');
        EmailBody = EmailBody +'<html><body><table  style="width:750px;border-collapse: collapse;border: 1px solid #ddd" >';
        EmailBody = EmailBody +'<tr style="background-color: #f2f2f2;"><td colspan=2 style="word-break:break-all;font-weight:bold;text-align:center">Error Details</td></tr>';
        EmailBody = EmailBody +'<tr><td style="width:150px;word-break:break-all;border: 1px solid #ddd">Date</td><td style="border: 1px solid #ddd;word-break:break-all;">' + system.now() + '</td></tr>';
        EmailBody = EmailBody +'<tr style="background-color: #f2f2f2;"><td style="border: 1px solid #ddd;word-break:break-all;">Project Id</td><td style="border: 1px solid #ddd;word-break:break-all;">' + ProjectId + '</td></tr>';
        EmailBody = EmailBody +'<tr><td style="border: 1px solid #ddd;word-break:break-all;">User Name</td><td style="border: 1px solid #ddd;word-break:break-all;">' + UserName + '</td></tr>';
        EmailBody = EmailBody +'<tr style="background-color: #f2f2f2;"><td style="border: 1px solid #ddd;word-break:break-all;">Page URL</td><td style="border: 1px solid #ddd;word-break:break-all;">' + strPageName + '</td></tr>';
        EmailBody = EmailBody +'<tr><td style="border: 1px solid #ddd;word-break:break-all;">Method Name</td><td style="border: 1px solid #ddd;word-break:break-all;">' + MethodName + '</td></tr>';
        EmailBody = EmailBody +'<tr style="background-color: #f2f2f2;"><td style="border: 1px solid #ddd;word-break:break-all;">Error Line</td><td style="border: 1px solid #ddd;word-break:break-all;">' + intLineNumber + '</td></tr>';
        EmailBody = EmailBody +'<tr><td style="border: 1px solid #ddd;word-break:break-all;">Error Dscription</td><td style="border: 1px solid #ddd;word-break:break-all;">' + strErrorDetails + '</td></tr>';
        EmailBody = EmailBody +'</table></body></html>';
    
    
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        // below line is commented for further use when we will start sending mail vie OrgWideEmailAddress
        //OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'hospitality.no-reply@amadeus.com'];
        // if ( owea.size() > 0 ) {
        //     message.setOrgWideEmailAddressId(owea.get(0).Id);
        // }
        
        message.toAddresses = new String[] { 'Hospitality.PLCM@amadeus.com' };
        message.optOutPolicy = 'FILTER';
        message.subject = 'Project Transformer - Error Notification';
        message.setHtmlBody(EmailBody);
        //message.plainTextBody = EmailBody;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
}