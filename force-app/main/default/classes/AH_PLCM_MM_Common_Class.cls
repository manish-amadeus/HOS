/***********************************************************************************************
Name            : AH_PLCM_MM_Common_Class
Author          : Tushar Gupta
Created Date    : 06-June-2020
Last Mod Date   : 06-June-2020
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Class for Property page
************************************************************************************************/
public abstract class AH_PLCM_MM_Common_Class {
    //Pages Name
    public class AH_PLCM_MM_Page_Names {
        public string TermsAndConditionPage = '/apex/AH_PLCM_MM_Terms_And_Conditions';
        public string WelcomePage = '/apex/AH_PLCM_MM_Welcome';
        public string FunctionRoomPage = '/apex/AH_PLCM_MM_Function_Room';
        public string RoomCapacitiesPage = '/apex/AH_PLCM_MM_Room_Capacities';
        public string InventoryPage = '/apex/AH_PLCM_MM_Inventory';
        public string ThankYouPage = '/apex/AH_PLCM_MM_Thank_You';
        public string ErrorPage = '/apex/AH_PLCM_MM_Error_Page';
    }

    //Portal Progress Status
    public class AH_PLCM_MM_Project_Portal_Status {
        public string PropertyInformationConfirmed = 'Property Information Confirmed';
        public string FunctionRoomInfomationProvided = 'Function Room Information Provided';
        public string RoomCapacityInformationProvided = 'Room Capacity Information Provided';
        public string InventoryInformationProvided = 'Inventory Information Provided';
        public string CustomerInputCompleted = 'Customer Inputs Complete';
        public boolean IsPropertyInformationConfirmed { get; set; }
        public boolean IsFunctionRoomInfomationProvided { get; set; }
        public boolean IsRoomCapacityInformationProvided { get; set; }
        public boolean IsInventoryInformationProvided { get; set; }
        public integer PerecentageCompleted { get; set; }
    }

    //Bubble Help Popup Status
    public class AH_PLCM_MM_Project_Bubble_Status {
        public boolean IsFunctionRoomBubbleSkipped { get; set; }
        public boolean IsRoomCapacityBubbleSkipped { get; set; }
        public boolean IsInventoryBubbleSkipped { get; set; }
    }
    
    // For Inventory Default Values
    public class AH_PLCM_MM_Inventory_Default_Wrapper {
        public string MM_Default_Chair_Description {get;set;}
        public integer MM_Default_Chair_Height {get;set;}
        public integer MM_Default_Chair_Length {get;set;}
        public integer MM_Default_Chair_Width {get;set;}
        public boolean MM_Default_Chair_Is_Default {get;set;}

        public string MM_Default_Conference_Chair_Description {get;set;}
        public integer MM_Default_Conference_Chair_Height {get;set;}
        public integer MM_Default_Conference_Chair_Length {get;set;}
        public integer MM_Default_Conference_Chair_Width {get;set;}
        public boolean MM_Default_Conference_Chair_Is_Default {get;set;}

        public string MM_Default_Dance_Floor_Description {get;set;}
        public integer MM_Default_Dance_Floor_Height {get;set;}
        public integer MM_Default_Dance_Floor_Length {get;set;}
        public integer MM_Default_Dance_Floor_Width {get;set;}
        public boolean MM_Default_Dance_Floor_Is_Default {get;set;}

        public string MM_Default_Rectangular_Table_Description {get;set;}
        public integer MM_Default_Rectangular_Table_Height {get;set;}
        public integer MM_Default_Rectangular_Table_Length {get;set;}
        public integer MM_Default_Rectangular_Table_Width {get;set;}
        public boolean MM_Default_Rectangular_Table_Is_Default {get;set;}

        public string MM_Default_Riser_Stage_Description {get;set;}
        public integer MM_Default_Riser_Stage_Height {get;set;}
        public integer MM_Default_Riser_Stage_Length {get;set;}
        public integer MM_Default_Riser_Stage_Width {get;set;}
        public boolean MM_Default_Riser_Stage_Is_Default {get;set;}

        public string MM_Default_Round_Table_Description {get;set;}
        public integer MM_Default_Round_Table_Height {get;set;}
        public integer MM_Default_Round_Table_Length {get;set;}
        public integer MM_Default_Round_Table_Width {get;set;}
        public boolean MM_Default_Round_Table_Is_Default {get;set;}

        public string MM_Default_Square_Table_Description {get;set;}
        public integer MM_Default_Square_Table_Height {get;set;}
        public integer MM_Default_Square_Table_Length {get;set;}
        public integer MM_Default_Square_Table_Width {get;set;}
        public boolean MM_Default_Square_Table_Is_Default {get;set;}
    }

    //Properties Declaration
    public AH_PLCM_MM_Page_Names PageNames { get { return new AH_PLCM_MM_Page_Names(); } }
    public AH_PLCM_MM_Project_Portal_Status ProjectPortalStatus { get; set; }
    public AH_PLCM_MM_Project_Bubble_Status ProjectBubbleStatus { get; set; }    
    public String ProjectId { get; set; }
    public String UserName { get; set; }
    public String BaseUrl { get; set; }
    public String CommunityUrl { get; set; }
    public boolean IsTestClass { get; set; } 
    public boolean IsErrorOccurred { get; set; }

    public AH_PLCM_MM_Common_Class() {
        try {
            IsErrorOccurred = false;
            //Get Logged In User Name
            UserName = UserInfo.getName();
            IsTestClass = false;

            //If terms and condition page, then no need to set variables value
            if(ApexPages.currentPage().getUrl().indexOf('AH_PLCM_MM_Terms_And_Conditions') == -1) {
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
            ProjectPortalStatus = new AH_PLCM_MM_Project_Portal_Status();
            ProjectPortalStatus.IsPropertyInformationConfirmed = false;
            ProjectPortalStatus.IsFunctionRoomInfomationProvided = false;
            ProjectPortalStatus.IsRoomCapacityInformationProvided = false;
            ProjectPortalStatus.IsInventoryInformationProvided = false;
            ProjectPortalStatus.PerecentageCompleted = 0;

            //Initialize bubble help status object with default values
            ProjectBubbleStatus = new AH_PLCM_MM_Project_Bubble_Status();
            ProjectBubbleStatus.IsFunctionRoomBubbleSkipped = false;
            ProjectBubbleStatus.IsRoomCapacityBubbleSkipped = false;
            ProjectBubbleStatus.IsInventoryBubbleSkipped = false;
            
            //Fetch project portal status and bubble help status to set variables value
            lstProjects = new List<NI_Documentation__c>([SELECT AH_PLCM_Portal_Progress__c, AH_PLCM_MM_Is_Function_Room_Bubble_Skip__c, AH_PLCM_MM_Is_Room_Capacity_Bubble_Skip__c, AH_PLCM_MM_Is_Inventory_Bubble_Skip__c FROM NI_Documentation__c WHERE Id = :ProjectId]);
            
            if(lstProjects.size() > 0) {
                if(lstProjects.get(0).AH_PLCM_Portal_Progress__c == ProjectPortalStatus.PropertyInformationConfirmed) {
                    ProjectPortalStatus.IsPropertyInformationConfirmed = true;
                    //Property Information Confirmed so set progress bar percentage 25%
                    ProjectPortalStatus.PerecentageCompleted = 25;
                }

                if(lstProjects.get(0).AH_PLCM_Portal_Progress__c == ProjectPortalStatus.FunctionRoomInfomationProvided) {
                    ProjectPortalStatus.IsPropertyInformationConfirmed = true;

                    ProjectPortalStatus.IsFunctionRoomInfomationProvided = true;
                    //Function room detail updated so set progress bar percentage 50%
                    ProjectPortalStatus.PerecentageCompleted = 50;
                }
                else if(lstProjects.get(0).AH_PLCM_Portal_Progress__c == ProjectPortalStatus.RoomCapacityInformationProvided) {
                    ProjectPortalStatus.IsPropertyInformationConfirmed = true;
                    ProjectPortalStatus.IsFunctionRoomInfomationProvided = true;
                    ProjectPortalStatus.IsRoomCapacityInformationProvided = true;
                    //room capacity details created updated so set progress bar percentage 75%
                    ProjectPortalStatus.PerecentageCompleted = 75;
                }
                else if(lstProjects.get(0).AH_PLCM_Portal_Progress__c == ProjectPortalStatus.InventoryInformationProvided || lstProjects.get(0).AH_PLCM_Portal_Progress__c == ProjectPortalStatus.CustomerInputCompleted) {
                    ProjectPortalStatus.IsPropertyInformationConfirmed = true;
                    ProjectPortalStatus.IsFunctionRoomInfomationProvided = true;
                    ProjectPortalStatus.IsRoomCapacityInformationProvided = true;
                    ProjectPortalStatus.IsInventoryInformationProvided = true;
                    //Inventory is complete so set progress bar percentage 100%
                    ProjectPortalStatus.PerecentageCompleted = 100;
                }

                //Set Bubble Help Status Variables Value
                ProjectBubbleStatus.IsFunctionRoomBubbleSkipped = boolean.valueOf(lstProjects.get(0).AH_PLCM_MM_Is_Function_Room_Bubble_Skip__c);
                ProjectBubbleStatus.IsRoomCapacityBubbleSkipped = boolean.valueOf(lstProjects.get(0).AH_PLCM_MM_Is_Room_Capacity_Bubble_Skip__c);
                ProjectBubbleStatus.IsInventoryBubbleSkipped = boolean.valueOf(lstProjects.get(0).AH_PLCM_MM_Is_Inventory_Bubble_Skip__c);
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

            // if(!IsTestClass) { //This code is not supported in test class
            //     String networkId = Network.getNetworkId();
            //     ConnectApi.Community comm = ConnectApi.Communities.getCommunity(networkId);
            //     CommunityUrl = comm.siteUrl;
            // }

            // if(CommunityUrl.indexOf('neighborhood') > -1) { //Only for Neighborhood Community
            //     string strTabName = GetParameterValue('sfdc.tabName');
            //     if(strTabName != null && strTabName != '') { //Page opened from neighborhood community
            //         //Add tab name in query string parameters
            //         pageRef.getParameters().put('sfdc.tabName', strTabName);
            //     }
            // }
            // else {
            //     for(String key: ApexPages.currentPage().getParameters().keySet()) {
            //         if(key.toLowerCase().indexOf('viewstate') == -1
            //             && key.toLowerCase().indexOf('frm') == -1
            //             && key.toLowerCase().indexOf('ddl') == -1
            //             && key.toLowerCase().indexOf('projectid') == -1) { //Do not add post parameters
            //             string value = ApexPages.currentPage().getParameters().get(key);
            //             pageRef.getParameters().put(key, value);
            //         }
            //     }

            //     // string strCurrentUrl = CommunityUrl + strPageName;// + '?' + getAllQueryString();
            //     // pageRef = new PageReference(strCurrentUrl);
            // }
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
                lstAllProjects = new List<NI_Documentation__c>([SELECT Id, Name, Document_Name__c, AH_PLCM_IsTerms_and_Conditions_Accepted__c, AH_PLCM_Terms_and_Cndtions_Accepted_Date__c, AH_PLCM_IsOpt_Out_of_Social_Media__c  FROM NI_Documentation__c WHERE RecordType.Name = 'PLCM MM Conversion' AND AH_PLCM_IsTerms_and_Conditions_Accepted__c = false]);
            }   
            else {
                //Get all projects from salesforce object
                lstAllProjects = new List<NI_Documentation__c>([SELECT Id, Name, Document_Name__c, AH_PLCM_Portal_Progress__c, AH_PLCM_Portal_Completion_Due_Date__c, DRC_Call_Date__c, AH_PLCM_IsTerms_and_Conditions_Accepted__c, AH_PLCM_Terms_and_Cndtions_Accepted_Date__c  FROM NI_Documentation__c WHERE RecordType.Name = 'PLCM MM Conversion' ORDER BY Document_Name__c]);
            }          
                        
            lstProjectIds = new List<string>();
            for (NI_Documentation__c obj : lstAllProjects) {
                //Fill Project Ids in list
                lstProjectIds.add(obj.Id);
            }
            
            //Get record access details based on project ids
            lstUserAccess = new List<UserRecordAccess>([SELECT RecordId, HasReadAccess, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId IN :lstProjectIds]);
            lstProjects = new List<NI_Documentation__c>();

            if(lstUserAccess != null && lstUserAccess.size() > 0) {
                for (NI_Documentation__c objProj : lstAllProjects) {
                    for (UserRecordAccess obj : lstUserAccess) {
                        //Check if user has access of the project or not
                        if(obj.HasReadAccess == true && obj.HasEditAccess == true && obj.RecordId == objProj.Id) {
                            lstProjects.add(objProj);
                        }
                    }
                }
            }
            return lstProjects;
        }
        catch(Exception ex) {           
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
            return RedirectToErrorPage('Error From Constructor',null);
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


    //Send error notification via email
    public void SendErrorNotification(string MethodName,Exception ex) {
        string EmailBody = '', strPageName = ApexPages.currentPage().getUrl().replaceAll('\\?.*', '').replaceAll('/apex/', '');
        EmailBody = EmailBody +'<html><body><table  style="width:750px;border-collapse: collapse;border: 1px solid #ddd" >';
        EmailBody = EmailBody +'<tr style="background-color: #f2f2f2;"><td colspan=2 style="word-break:break-all;font-weight:bold;text-align:center">Error Details</td></tr>';
        EmailBody = EmailBody +'<tr><td style="width:150px;word-break:break-all;border: 1px solid #ddd">Date</td><td style="border: 1px solid #ddd;word-break:break-all;">' + system.now() + '</td></tr>';
        EmailBody = EmailBody +'<tr style="background-color: #f2f2f2;"><td style="border: 1px solid #ddd;word-break:break-all;">Project Id</td><td style="border: 1px solid #ddd;word-break:break-all;">' + ProjectId + '</td></tr>';
        EmailBody = EmailBody +'<tr><td style="border: 1px solid #ddd;word-break:break-all;">User Name</td><td style="border: 1px solid #ddd;word-break:break-all;">' + UserName + '</td></tr>';
        EmailBody = EmailBody +'<tr style="background-color: #f2f2f2;"><td style="border: 1px solid #ddd;word-break:break-all;">Page URL</td><td style="border: 1px solid #ddd;word-break:break-all;">' + strPageName + '</td></tr>';
        EmailBody = EmailBody +'<tr><td style="border: 1px solid #ddd;word-break:break-all;">Method Name</td><td style="border: 1px solid #ddd;word-break:break-all;">' + MethodName + '</td></tr>';
        EmailBody = EmailBody +'<tr style="background-color: #f2f2f2;"><td style="border: 1px solid #ddd;word-break:break-all;">Error Line</td><td style="border: 1px solid #ddd;word-break:break-all;">' + ex.getLineNumber()+ '</td></tr>';
        EmailBody = EmailBody +'<tr><td style="border: 1px solid #ddd;word-break:break-all;">Error Dscription</td><td style="border: 1px solid #ddd;word-break:break-all;">' + string.valueOf(ex) + '</td></tr>';
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

    //Get Property Name of MM Project
    public String GetMMPropertyName() {
        NI_Documentation__c objNIDoc = null;
        String strPropertyName = '';
        try {
            objNIDoc = [SELECT Document_Name__c FROM NI_Documentation__c WHERE Id =: ProjectId];
            if(objNIDoc != null) {
                strPropertyName = objNIDoc.Document_Name__c;
            }
            return strPropertyName;
        }
        catch(Exception ex) {
            throw ex;
        }
        finally {
            objNIDoc = null;
            strPropertyName = null;
        }
    }

    //Get picklist value from the object
    //Pass the object name and fieldname
    public List<Schema.PicklistEntry> GetPickListValueFromObject(string ObjectName, string FieldName) {
        Schema.SObjectType sObjectType = null;
        Schema.DescribeSObjectResult sObjectResult = null;
        Map<String,Schema.SObjectField> lstFields = null;
        Schema.DescribeFieldResult fieldResult = null;
        try {
            sObjectType = Schema.getGlobalDescribe().get(ObjectName) ;
            sObjectResult = sObjectType.getDescribe() ;
            lstFields = sObjectResult.fields.getMap() ;
            fieldResult = lstFields.get(FieldName).getDescribe();  
            return fieldResult.getPicklistValues();
        }
        catch(Exception ex) {
            throw ex;
        }
        finally {
            sObjectType = null;
            sObjectResult = null;
            lstFields = null;
            fieldResult = null;
        }
    }

    //Get amadeus defualt standard values of room capacities
    public AH_PLCM_MM_Seating_Capacity__c GetDefaultRoomCapacityValues() {
        AH_PLCM_MM_Seating_Capacity__c objDefaultValues = null;
        try {
            objDefaultValues = new AH_PLCM_MM_Seating_Capacity__c();
            //Assign ProjectId 
            objDefaultValues.MM_NI_Doc_Record__c = ProjectId;

            //THEATER
            objDefaultValues.MM_THE_Center_Aisle_s_quantity__c = 1; //Number of Center Aisle(s)
            objDefaultValues.MM_THE_Center_Aisle_s_Width__c = 5; //Center Aisle(s) Width (in feet)
            objDefaultValues.MM_THE_Cross_Aisle_s_quantity__c = 0; //Number of Cross Aisle(s)
            objDefaultValues.MM_THE_Cross_Aisle_s_Width__c = 5; //Cross Aisle(s) Width (in feet)
            objDefaultValues.MM_THE_Distance_Between_Chairs__c = 1; //Distance between Chairs (in feet)
            objDefaultValues.MM_THE_Distance_Between_Rows_of_Chairs__c = 18; //Distance between Rows of Chairs (in inches)
            objDefaultValues.MM_THE_Default_Chair_Size_Length__c     = 18; //Default Chair Length (in inches)
            objDefaultValues.MM_THE_Default_Chair_Size_Width__c = 23; //Default Chair Width (in inches)

            //THEATER CHEVRON
            objDefaultValues.MM_THC_Center_Aisle_s_quantity__c = 1; //Number of Center Aisle(s)
            objDefaultValues.MM_THC_Center_Aisle_s_Width__c = 5; //Center Aisle(s) Width (in feet)
            objDefaultValues.MM_THC_Cross_Aisle_s_quantity__c   = 0; //Number of Cross Aisle(s)
            objDefaultValues.MM_THC_Cross_Aisle_s_Width__c = 5; //Cross Aisle(s) Width (in feet)
            objDefaultValues.MM_THC_Distance_Between_Chairs__c = 1; //Distance between Chairs (in feet)
            objDefaultValues.MM_THC_Distance_Between_Rows_of_Chairs__c = 18; //Distance between Rows of Chairs (in inches)
            objDefaultValues.MM_THC_Default_Chair_Size_Length__c = 18; //Default Chair Length (in inches)
            objDefaultValues.MM_THC_Default_Chair_Size_Width__c = 23; //Default Chair Width (in inches)

            //CLASSROOM
            objDefaultValues.MM_CLA_Center_Aisle_s_quantity__c = 1; // Number of Center Aisle(s)
            objDefaultValues.MM_CLA_Center_Aisle_s_Width__c = 5; //Center Aisle(s) Width (in feet)
            objDefaultValues.MM_CLA_Cross_Aisle_s_quantity__c = 0; //Number of Cross Aisle(s)
            objDefaultValues.MM_CLA_Cross_Aisle_s_Width__c = 5; //Cross Aisle(s) Width (in feet)
            objDefaultValues.MM_CLA_Distance_Between_Rows_of_Tables__c = 36; // Distance between Rows of Tables (in inches)
            objDefaultValues.MM_CLA_Distance_Between_Tables__c = 0; //Distance between Tables (in inches)
            objDefaultValues.MM_CLA_Default_Table_Size_Length__c = 6; //Default Table Length (in feet)
            objDefaultValues.MM_CLA_Default_Table_Size_Width__c = 18; //Default Table Width (in inches)
            objDefaultValues.MM_CLA_Default_Chair_Size_Length__c = 18; //Default Chair Length (in inches)
            objDefaultValues.MM_CLA_Default_Chair_Size_Width__c = 23; //Default Chair Width (in inches)
            objDefaultValues.MM_CLA_Seats_per_Table__c = 3; //Number of Seats per table

            //CLASSROOM CHEVRON
            objDefaultValues.MM_CLC_Center_Aisle_s_quantity__c = 1; //Number of Center Aisle(s)
            objDefaultValues.MM_CLC_Center_Aisle_s_Width__c = 5; //Center Aisle(s) Width (in feet)
            objDefaultValues.MM_CLC_Cross_Aisle_s_quantity__c = 0; //Number of Cross Aisle(s)
            objDefaultValues.MM_CLC_Cross_Aisle_s_Width__c = 5; //Cross Aisle(s) Width (in feet)
            objDefaultValues.MM_CLC_Distance_Between_Rows_of_Tables__c = 36; // Distance between Rows of Tables (in inches)
            objDefaultValues.MM_CLC_Distance_Between_Tables__c = 0; // Distance between Tables (in inches)
            objDefaultValues.MM_CLC_Default_Table_Size_Length__c = 6; // Default Table Length (in feet)
            objDefaultValues.MM_CLC_Default_Table_Size_Width__c = 18; // Default Table Width (in inches)
            objDefaultValues.MM_CLC_Default_Chair_Size_Length__c = 18; // Default Chair Length (in inches)
            objDefaultValues.MM_CLC_Default_Chair_Size_Width__c = 23; // Default Chair Width (in inches)
            objDefaultValues.MM_CLC_Seats_per_Table__c = 3; // Number of Seats per table

            //BANQUET
            objDefaultValues.MM_BAN_Center_Aisle_s_quantity__c = 0; // Number of Center Aisle(s)
            objDefaultValues.MM_BAN_Center_Aisle_s_Width__c = 5; //Center Aisle(s) Width (in feet)
            objDefaultValues.MM_BAN_Cross_Aisle_s_quantity__c = 0; //Number of Cross Aisle(s)
            objDefaultValues.MM_BAN_Cross_Aisle_s_Width__c = 5; //Cross Aisle(s) Width (in feet)
            objDefaultValues.MM_BAN_Distance_Between_Rows_of_Tables__c = 60; // Distance between Rows of Tables (in inches)
            objDefaultValues.MM_BAN_Distance_Between_Tables__c = 60; //Distance between Tables (in inches)
            objDefaultValues.MM_BAN_Default_Table_Size_Width__c = 6; //Default Round Table Size (in feet):
            objDefaultValues.MM_BAN_Default_Chair_Size_Length__c = 18; //Default Chair Length (in inches)
            objDefaultValues.MM_BAN_Default_Chair_Size_Width__c = 23; //Default Chair Width (in inches)
            objDefaultValues.MM_BAN_Seats_per_Table__c = 10; //Number of Seats per table

            //BANQUET STAGGERED
            objDefaultValues.MM_BAS_Center_Aisle_s_quantity__c = 0; // Number of Center Aisle(s)
            objDefaultValues.MM_BAS_Center_Aisle_s_Width__c = 5; //Center Aisle(s) Width (in feet)
            objDefaultValues.MM_BAS_Cross_Aisle_s_quantity__c = 0; //Number of Cross Aisle(s)
            objDefaultValues.MM_BAS_Cross_Aisle_s_Width__c = 5; //Cross Aisle(s) Width (in feet)
            objDefaultValues.MM_BAS_Distance_Between_Rows_of_Tables__c = 60; // Distance between Rows of Tables (in inches)
            objDefaultValues.MM_BAS_Distance_Between_Tables__c = 60; //Distance between Tables (in inches)
            objDefaultValues.MM_BAS_Default_Table_Size_Width__c = 6; //Default Round Table Size (in feet):
            objDefaultValues.MM_BAS_Default_Chair_Size_Length__c = 18; //Default Chair Length (in inches)
            objDefaultValues.MM_BAS_Default_Chair_Size_Width__c = 23; //Default Chair Width (in inches)
            objDefaultValues.MM_BAS_Seats_per_Table__c = 10; //Number of Seats per table

            //CONFERENCE
            objDefaultValues.MM_CON_Default_Table_Size_Length__c = 6; // Default Table Length (in feet)
            objDefaultValues.MM_CON_Default_Table_Size_Width__c = 30; // Default Table Width (in inches)
            objDefaultValues.MM_CON_Default_Chair_Size_Length__c = 18; // Default Chair Length (in inches)
            objDefaultValues.MM_CON_Default_Chair_Size_Width__c = 23; // Default Chair Width (in inches)
            objDefaultValues.MM_CON_Seats_per_Table__c = 3; // Number of Seats per table

            //U-SHAPE
            objDefaultValues.MM_USH_Default_Table_Size_Length__c = 6; // Default Table Length (in feet)
            objDefaultValues.MM_USH_Default_Table_Size_Width__c = 30; // Default Table Width (in inches)
            objDefaultValues.MM_USH_Default_Chair_Size_Length__c = 18; // Default Chair Length (in inches)
            objDefaultValues.MM_USH_Default_Chair_Size_Width__c = 23; // Default Chair Width (in inches)
            objDefaultValues.MM_USH_Seats_per_Table__c = 3; // Number of Seats per table

            //HOLLOW SQUARE
            objDefaultValues.MM_HSQ_Default_Table_Size_Length__c = 6; // Default Table Length (in feet)
            objDefaultValues.MM_HSQ_Default_Table_Size_Width__c = 30; // Default Table Width (in inches)
            objDefaultValues.MM_HSQ_Default_Chair_Size_Length__c = 18; // Default Chair Length (in inches)
            objDefaultValues.MM_HSQ_Default_Chair_Size_Width__c = 23; // Default Chair Width (in inches)
            objDefaultValues.MM_HSQ_Seats_per_Table__c = 3; // Number of Seats per table

            //RECEPTION
            objDefaultValues.MM_REC_Room_Total_Length__c = 0; // Total Room Length (in feet)
            objDefaultValues.MM_REC_Room_Total_Width__c = 0; // Total Room Width (in feet)

            return objDefaultValues;
        }
        catch(Exception ex) {
            throw ex;
        }
        finally {
            objDefaultValues = null;
        }
    }
    
    public AH_PLCM_MM_Inventory_Default_Wrapper SetDefaultInventoryValue() {
        AH_PLCM_MM_Inventory_Default_Wrapper inventory = new AH_PLCM_MM_Inventory_Default_Wrapper();
        try {
            inventory.MM_Default_Chair_Description = 'AHD Default Chair';
            inventory.MM_Default_Chair_Width = 17;
            inventory.MM_Default_Chair_Length = 18;
            inventory.MM_Default_Chair_Height = 37;
            inventory.MM_Default_Chair_Is_Default = true;
            
            inventory.MM_Default_Conference_Chair_Description = 'AHD Default Conference Chair';
            inventory.MM_Default_Conference_Chair_Width = 30;
            inventory.MM_Default_Conference_Chair_Length = 30;
            inventory.MM_Default_Conference_Chair_Is_Default = true;

            inventory.MM_Default_Rectangular_Table_Description = 'AHD Default Banquet Rectangle Table';
            inventory.MM_Default_Rectangular_Table_Width = 6;
            inventory.MM_Default_Rectangular_Table_Length = 30;
            inventory.MM_Default_Rectangular_Table_Is_Default = true;

            inventory.MM_Default_Square_Table_Description = 'AHD Default Square Table';
            inventory.MM_Default_Square_Table_Width = 3;
            inventory.MM_Default_Square_Table_Length = 3;        
            inventory.MM_Default_Square_Table_Is_Default = true;

            inventory.MM_Default_Round_Table_Description = 'AHD Default 8-person Banquet Round';
            inventory.MM_Default_Round_Table_Width = 5;
            inventory.MM_Default_Round_Table_Is_Default = true;

            inventory.MM_Default_Riser_Stage_Description = 'AHD Default Riser';
            inventory.MM_Default_Riser_Stage_Width = 6;
            inventory.MM_Default_Riser_Stage_Length = 8;
            inventory.MM_Default_Riser_Stage_Height = 24;
            inventory.MM_Default_Riser_Stage_Is_Default = true;

            inventory.MM_Default_Dance_Floor_Description = 'AHD Default Dance Floor Tile';
            inventory.MM_Default_Dance_Floor_Width = 3;
            inventory.MM_Default_Dance_Floor_Length = 3;
            inventory.MM_Default_Dance_Floor_Is_Default = true;
            return inventory;
        }
        catch(Exception ex) {
            throw ex;
        }
        finally {
            inventory = null;
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
        
        //Get more details from ContentVersion
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id];
        
        ContentDocumentLink cdl = new ContentDocumentLink(); //Salesforce standard object ContentDocumentLink
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = parentId;
        cdl.ShareType = 'V';
        insert cdl;
        
        ContentDistribution cd = new ContentDistribution();
        cd.Name = fileName;
        cd.ContentVersionId = cv.id;
        cd.RelatedRecordId = parentId;
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesAllowOriginalDownload = true;
        cd.PreferencesLinkLatestVersion = true;
        cd.PreferencesNotifyOnVisit = false;
        cd.PreferencesPasswordRequired = false;
        insert cd;
    }
}