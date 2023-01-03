/****************************************************************************************
Name            : NI_CreateHRMOrg Class 
Author          : Suzanne LeDuc
Created Date    : 
Last Mod Date   : 3/30/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     :  This class is used as the Controller for the NI_Create_HRM_Org Page
                :  It is used to Create a new Org for a given HRM Opportunity
                : 
                : 
******************************************************************************************/
public class NI_CreateHRMOrg
{
    
    // GLOBAL VARIABLES 
    private Opportunity opportunity = null;
    public String selectedTemplate {get; set;}
    public String selectedCurrency {get; set;}
    public String selectedTimeZone {get; set;}
    public String selectedCountry  {get; set;}
    public String caseNotes {get; set;}
    public String signUpId {get; set;}
    public Boolean InvalidOrgId {get; set;}    
    private NI_HRM_SignUp_Request_Settings__c hrmSettings;  
    public NI_Org_Details__c orgDetails;
    public Boolean disableCreateButton {get; set;}
        
    // TRIALFORCE TEMPLATE OPTIONS 
    public List<SelectOption> templateOptions
    {
        get
        {            
            List<HRM_Template__c> templates = [SELECT Id, Name, Template_Id__c FROM HRM_Template__c];
            List<SelectOption> selectTemplates = new List<SelectOption>();
            selectTemplates.add(new SelectOption('', 'Please Choose'));
            
            for (HRM_Template__c template : templates)
            {
system.debug(' *************** HRM Pick List Value = ' + template.template_Id__c + ', ' + template.Name);                 
                selectTemplates.add(new SelectOption(template.template_Id__c, template.Name));
            }
            
            return selectTemplates;            
        }        
        set;
    }
    
    
    // THIS METHOD IS USED TO GENERATE A PICKLIST BASED ON DATA FROM AN EXISTING SALESFORCE OBJECT AND FIELD
    public list<SelectOption> getPicklistValues(string objectName, String myField)
    {
        
        list<SelectOption> options = new list<SelectOption>();         
        sObjectType objectType = Schema.getGlobalDescribe().get(objectName); 
        
        if (objectType == null)
        {
            return options;
        }

        Schema.DescribeSObjectResult objDescribe = objectType.getDescribe(); 
        Schema.SObjectField theField = objDescribe.fields.getMap().get(myField); 
        
        if (theField == null)
        {
            return options;
        }

        for (Schema.PicklistEntry a :theField.getDescribe().getPickListValues())
        {
            options.add(new SelectOption(a.getValue(), a.getLabel())); 
        }
		
        return options; 
        
    }

    public List<SelectOption> currencyOptions
    {
        get
        {             
            return getPickListValues('User', 'CurrencyISoCode');
        }        
        set;
    }
    
    public List<SelectOption> timeZoneOptions
    {
        get
        { 
            return getPickListValues('User', 'TimeZoneSidKey');
        }        
        set;
    }

    public NI_Org_Details__c getOrgDetails()
    {
        return orgDetails;
    }

    public Opportunity getOpportunity()
    {
        return opportunity;
    }

    //Constructor - Gets the Custom Settings, Values from the Opportunity and Calls Setup Org Details
    public NI_CreateHRMOrg()
    {
        hrmSettings = NI_HRM_SignUp_Request_Settings__c.getInstance('HRMSignUpSettings');
        String oppId = ApexPages.currentPage().getParameters().get('OppId');
        if (oppId != null)
        {
            opportunity = [SELECT Name, Opportunity_Number__c, AccountId, OwnerID, CloseDate, CurrencyIsoCode, Target_HRM_Org__c,                       
                           (SELECT op.Id, op.Quantity, op.UnitPrice, op.TotalPrice, op.ServiceDate, op.LOD_Licensed_Property__c, op.Service_Order__c,
                            op.PricebookEntry.Name, op.OpportunityId, op.PricebookEntry.ProductCode, op.Release_Date__c, op.Deferred__c,          
                            op.PricebookEntry.Product2.Family, op.CurrencyIsoCode, op.Discount__c, op.Family__c, op.LineType__c, op.ListPrice, op.PricebookEntryId
                            FROM OpportunityLineItems op)
                           FROM Opportunity 
                           WHERE Id =: oppId];       
            disableCreateButton = false; 
        }
        
        setupOrgDetails();
        
        //Default the timezone to Eastern and Currency to USD
        selectedTimeZone = 'America/New_York';
        selectedCurrency = 'USD';
        
    }
    
    
    //The data from the Apex Page will represent an Org Details record for the Org that is being created.
    //This method sets up the basic information that will be needed
    public void setupOrgDetails()
    {
        orgDetails = new NI_Org_Details__c();
        orgDetails.Org_Type__c = 'Salesforce Production';
        orgDetails.Org_Status__c = 'Trial';
        //orgDetails.License_Type__c = 'Embedded Plus';
        //Get Record Type
        RecordType rType = [SELECT Id FROM RecordType WHERE Name =: hrmSettings.Org_Details_Record_Type__c];
        orgDetails.RecordTypeId = rType.Id;
        
        if (opportunity != null)
        {
            //Get the Account, this will make life easier
            System.debug('opportunity account ' + opportunity.AccountId);
            Account oppAccount = [SELECT Name,BillingCountry, CurrencyIsoCode FROM Account WHERE Id =: Opportunity.AccountId];
            
            if (oppAccount.BillingCountry != '' && oppAccount.BillingCountry != null)
            {
                selectedCountry = oppAccount.BillingCountry;
            }

            orgDetails.Org_Name__c = oppAccount.Name;
            
            String adminName = oppAccount.Name.replaceAll('[^a-zA-Z0-9]','');
            adminName = adminName.replaceAll( '\\s+', '') + 'Support@newmarketinc.com';
            
            orgDetails.AdminLoginName__c = adminName;

            //Get The project contact from the Opportunity
            List<OpportunityContactRole> contactRoles = [SELECT ContactId, Role FROM OpportunityContactRole WHERE OpportunityId =: Opportunity.Id];
            for (OpportunityContactRole cRole : contactRoles)
            {
                if (cRole.Role =='Customer Project Contact')
                {
                    OrgDetails.Contact__c = cRole.ContactId;
                }                    
            }
            
            //What kind of licenses are on the opp?
            List<OpportunityLineItem> lineItems = [SELECT  Product2.Salesforce_com_Subscription_Type__c   FROM OpportunityLineItem WHERE OpportunityId = :Opportunity.Id AND Product2.Salesforce_com_Subscription_Type__c != '' LIMIT 1];
            if (!lineItems.IsEmpty())
            {
                orgDetails.License_Type__c = lineItems[0].Product2.Salesforce_com_Subscription_Type__c.Replace('Edition', '');
            }
        }
        
    }
    
    //Command Button
    //Validates that the Email address is in the correct format and calls CreateSignupRequest from the HRM Signup Request Class
    //If the HRM Signup Request class returns an Id, it will then call GetSignUpRequestOrgId to get the Org Id that was created.
    //If an Id is Returned this method calls SaveOrgDetailsRecord and CreateCase
    public void CreateOrg()
    {
        
        if (!validateEmail(orgDetails.AdminLoginName__c))
        {
            string message = 'Admin Login is not in a correct email format.\n';
            ApexPages.Message myMsg = new ApexPages.Message( ApexPages.Severity.ERROR, message );
            ApexPages.addMessage(myMsg);
            disableCreateButton = true;
        }
        
        string message = 'Your org was created successfully.\n';
        ApexPages.Message myMsg = new ApexPages.Message( ApexPages.Severity.INFO, message );        
        
        NI_HRM_SignUpRequest signupRequest = new NI_HRM_SignUpRequest();

        //Is Test running Test is used here because Callouts are not supported in test classes. For some reason the Mock test does not work correctly when the callout is two classes deep
        if (!Test.isRunningTest()) 
        {
            signUpId = signupRequest.CreateSignUpRequest(selectedTemplate, hrmSettings.SignUp_Request_Email__c, orgDetails.AdminLoginName__c, selectedCountry, orgDetails.Org_Name__c, 'User');
        }
//        else // THIS CAUSES: "System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out"
//        {
//            signUpId = '00D300000006ABCXXXXXXXXXXXXXXXXXXXXX';
//        }
        
        if (signUpId != null)
        {
            
            // Get the Org Id
            String orgId = signupRequest.GetSignUpRequestOrgId(signUpId.Substring(0, 15));            
            integer count = 0;
            
            while (orgId == null && count < 20)
            {
                orgId = signupRequest.GetSignUpRequestOrgId(signUpId.Substring(0, 15));
                count += 1;
            }
            
            CreateCase();
            
            if (orgId == null || orgId.contains('Error'))
            {
                InvalidOrgId = true;
                myMsg = new ApexPages.Message( ApexPages.Severity.INFO, 'The OrgId was not returned. Please wait a few minutes and click the Get Org Id button to retreive it.');
            }
            else
            {
                SaveOrgDetailsRecord(OrgId);
                InvalidOrgId = false;
            }   
            
            ApexPages.addMessage(myMsg);
            disableCreateButton = true;
            
        }
        else
        {
            message = 'A problem occured when creating the org.\n';
            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message);
        }

        ApexPages.addMessage(myMsg);
        disableCreateButton = true;
        
    }
    
    
    public void QueryOrgId()
    {
        
        string message = '';
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, message);
        
        NI_HRM_SignUpRequest signupRequest = new NI_HRM_SignUpRequest();
system.debug('   ***************************** signUpId.Substring(0, 15) = ' + signUpId.Substring(0, 15));
        String orgId = signupRequest.GetSignUpRequestOrgId(signUpId.Substring(0, 15));
        
        if (orgId != null)
        {
            if (orgId.contains('Error'))
                message = 'There was an error creating the org: ' + orgId;
            else
            {
                SaveOrgDetailsRecord(OrgId);
                message = 'The Org Id was found and the Org Details Record updated. You can now order licenses for this new Org. The Org Id is: ' + orgId;
            }
        }
        else
        {
            message = 'The Org Id was not retreived, please wait a minute and try again.';
        }
        
        myMsg = new ApexPages.Message(ApexPages.Severity.INFO, message);
        ApexPages.addMessage(myMsg);
    }
    
    
    
    
    //This method creates a case that will be used to notify someone that an org has been created
    Public void CreateCase()
    {
        //Create a case
        Case signupRequestCase = new Case();
        signupRequestCase.Description = 'HRM New Org Configuration. TimeZone ' + selectedTimeZone + ' Currency ' + selectedCurrency + ' Notes ' + caseNotes;
        signupRequestCase.Subject = 'HRM New Org Configuration for Org ' + orgDetails.Org_Name__c;
        signupRequestCase.Origin = 'Email';
        signupRequestCase.Status = 'New';
        signupRequestCase.Has_No_Di__c = true;
        
        if (opportunity != null)
        {
            signupRequestCase.AccountId = Opportunity.AccountId;            
        }

        //Get the case owner        
        Group caseQueue = [SELECT Id FROM Group WHERE Name =: hrmSettings.SignUp_Request_Case_Owner__c];
        signupRequestCase.ownerId = caseQueue.Id;
        
        insert signupRequestCase;
        
    }    
    
    //This method saves the org Details Record and links the account that is associated to the Opportunity
    public void SaveOrgDetailsRecord(string orgId)
    {
        
        orgDetails.Org_Id__c = OrgId;
        orgDetails.SignUpId__c = signUpId;     
        HRM_Template__c template = [SELECT Name, Template_Id__c, Id FROM HRM_Template__c WHERE Template_Id__c =: selectedTemplate];
        
        orgDetails.Template__c = template.Id;
        insert orgDetails;
        
        //Link the account
        if (opportunity != null)
        {
            NI_Org_Details_To_Accounts__c orgDetailsToAccount = new NI_Org_Details_To_Accounts__c();
            orgDetailsToAccount.AccountId__c = Opportunity.AccountId;
            orgDetailsToAccount.NIOrgDetailsID__c = orgDetails.Id;
            insert orgDetailsToAccount;
        }
        
    }
    
    //Validates the email address of the admin user 
    public static Boolean validateEmail(String email) 
    {
        
        Boolean res = true;

        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        
        if (!MyMatcher.matches()) 
        {
            res = false;            
        }

        return res; 
    }
  
}