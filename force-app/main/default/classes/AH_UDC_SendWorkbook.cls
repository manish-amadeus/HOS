<<<<<<< HEAD
<<<<<<< HEAD
/***********************************************************************************************
  Name            : AH_UDC_SendWorkbook
  Author          : Umang Ankleshwaria
  Created Date    : 22-Jan-2021
  Last Mod Date   : 08-Fab-2021
  Last Mod By     : Umang Ankleshwaria
  NICC Reference  : 
  Description     : Controller class for UDC SendWorkbook page of UDC 
  Change History  :
  1. 590043 - Refactoring Code - Changed by Umang Ankleshwaria on 8-Feb-2021
  2. 594855 - Refactoring Code - Changed by Tushar Gupta on 23-Feb-2021
 ************************************************************************************************/
public with sharing class AH_UDC_SendWorkbook {

   // In v30 and higher (at least through v52) Salesforce broke use of the standard datepicker that is rendered using code like this:
   //
   // <apex:inputText id="dueDateinput" label="Workbook Due Date" value="{!DueDate}"
   //                 onfocus="DatePicker.pickDate(false, 'SendWorkbookPage:frmSendWorkbook:pbSendWorkbook:dueDateinput', false);"
   //                 html-autocomplete="off" />
   //
   // The date picker will not render unless there is at least on <apex:inputField> reference to a date field on the page.
   //
   // This NI_Documentation__c instance is used to put a hidden div on the page that will cause SF to load the required JS
   // necessary for rendering the DatePicker
   private NI_Documentation__c m_niDoc = new NI_Documentation__c();
   public NI_Documentation__c bugfix_niDoc { get { return m_niDoc; } set { m_niDoc = value; } }
   public Date DueDate { get { return bugfix_niDoc.AH_UDC_WorkbookDueDate__c; } set { bugfix_niDoc.AH_UDC_WorkbookDueDate__c = value; } }

   public String SelectedProduct { get; set; }
   public Boolean ProductSelected { get { return false; } set; }
   public Boolean IsCommunityUserCreated { get; set; } { IsCommunityUserCreated = false; }
   public Boolean IsCopyWorkbook { get; set; } // This is for New UDC Copy Exisiting Workbook  
   public Boolean IsUDCWorkbookAccessed { get; set; } { IsUDCWorkbookAccessed = AH_UDC_ConfigHelper.GetBoolean('AH_UDC_WorkbookAccessedDefaultValue', false); } //This is for Workbook Accessed  status flags
   public Boolean IsUDCWorkbookCompleted { get; set; } { IsUDCWorkbookCompleted = AH_UDC_ConfigHelper.GetBoolean('AH_UDC_WorkbookCompletedDefaultValue', false); } //This is for Workbook Completed status flags
   public Boolean IsUDCWorkbookStepCompleted { get; set; } { IsUDCWorkbookStepCompleted = AH_UDC_ConfigHelper.GetBoolean('AH_UDC_WorkbookStepCompletedDefaultValue', false); } //This is for Workbook Step Completed status flags
   public String SelectedWorkbook { get; set; }
   public String NiDocumentName { get; set; }
   public String CurrentUserDateSeparator { get { return AH_UDC_DateFormat.DateSeparator(); } }
   public String CurrentUserDateFormatString { get { return AH_UDC_DateFormat.DateFormatString(); } }
   public Id SelectedEmailTemplateId { get; set; }
   public String SelectedEmailTemplateName { get; set; }
   public List<SelectOption> WorkbookProducts { get; set; }
   public List<SelectOption> EnabledProductWorkbooks { get; set; }
   public Contact SelectedContact { get; set; }
   public Id SelectedNIDocIdCopy { get; set; }
   public Id SelectedNIDocIdNew { get; set; }
   public String ParentWorkbookName { get; set; }
   public Id ContactId { get; set; }
   public Id ProjectId { get; set; }
   public String ProjectName { get; set; }
   public Id NewNIDocId { get; set; } //New inserted NI Doc Id
   public Boolean IsErrorOccurred { get; set; } { IsErrorOccurred = false; } //To display error on page 
   public Boolean SendEmailFailed { get; set; } //It will be true only if error occurred while sending an email
   public String UserLocale { get; set; }
   public Id SelectedContactId { get; set; }
   public List<ContactLookupWrapper> ContactLookupList { get; set; } { ContactLookupList = new List<ContactLookupWrapper> (); }
   public String SelectedUserEmail { get; set; }
   public Integer AddContactLimit { get; set; } { AddContactLimit = AH_UDC_ConfigHelper.GetInteger('AH_UDC_AddContactLimit', 5); } //Maximum number of contacts allowed
   public String AddContactLimitString { get { return String.valueOf(AddContactLimit); } } //Maximum number of contacts allowed
   public Id propertyAccountId { get; set; }
   public Boolean isSendWorkbookEnabled { get { return AH_UDC_ConfigHelper.GetBoolean('AH_UDC_SendWorkbookEnabled', false); } }
   public Boolean AllowSend { get; set; } { AllowSend = true; }
   public String SendNotAllowedMessage { get; set; }

   public class ContactLookupWrapper {
      public Integer Index { get; set; }
      public Id Id { get; set; }
      public string Name { get; set; }
      public string ErrorMessage { get; set; }
   }

   @TestVisible private string LogFunctionalArea = 'AH_UDC_SendWorkbook'; //This is used for AH_UDC_Log Entries being written on this page
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }
   //This is used client side to determine if AH_UDC_Log Messages need to be written from the Page Load
   public Boolean HasPageLoadLogMessages {
      get {
         AH_UDC_LogHelper.Debug('PageLoadLogMessages: ' + PageLoadLogMessages);
         return PageLoadLogMessages != null && PageLoadLogMessages.size() > 0;
      }
   }

   public AH_UDC_SendWorkbook(ApexPages.StandardController controller) {
      List<User> externalUser = null;
      try {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;

         //Determine if the current user has the UDC System Admin permission set assigned to them
         String UDCSystemAdminPermissionSetName = AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetUDCSystemAdministrator', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN);
         Boolean isUDCSysAdmin = 0 < (Integer) [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :System.UserInfo.getUserId() AND PermissionSet.Name = :UDCSystemAdminPermissionSetName];

         //Alert the user if sending workbooks is disabled; UDC System Admins are excluded
         if (!isUDCSysAdmin && !isSendWorkbookEnabled) {
            AllowSend = false;
            SendNotAllowedMessage = AH_UDC_ConfigHelper.GetString('AH_UDC_SendWorkbookDisabledMessage', 'Send Workbook is currently disabled.');
            return;
         }

         //Refactored to send as Service User //TODO: Remove in V2.2
         ////Alert the user if their profile does not allow creating Community Users
         //Id profileId = userinfo.getProfileId();
         //List<Profile> userProfiles = AH_UDC_SystemContext.query('Select Id,Name from Profile where Id=\'' + profileId + '\'');
         //if (userProfiles[0].Name != 'System Administrator')
         //{
            //List<Create_External_User_Setting__mdt> ceuSettings = AH_UDC_SystemContext.query('SELECT id from Create_External_User_Setting__mdt where Running_Users_Profile__c = \'' + userProfiles[0].Name + '\'');
            //if (!Test.isRunningTest() && ceuSettings.size() == 0) {
               //AllowSend = false;
               //SendNotAllowedMessage = Label.AH_UDC_Send_Workbook_Profile_Unable_To_Create_Community_Users;
               //return;
            //}
         //}

         IsCopyWorkbook = false;
         SelectedContact = new Contact();
         ContactId = apexpages.currentpage().getparameters().get('Id');
         ProjectId = apexpages.currentpage().getparameters().get('ProjectId');
         UserLocale = UserInfo.getLocale();
         ParentWorkbookName = '';
         AH_UDC_LogHelper.Debug('ContactId: ' + ContactId);
         AH_UDC_LogHelper.Debug('ProjectId: ' + ProjectId);

         if (String.isBlank(String.valueOf(ContactId)) && String.isBlank(String.valueOf(ProjectId))) {
            LogException('Constructor', 'ContactId or ProjectId not found in the parameters', null, null);
            return;
         }

         List<Contact> lstContacts = null;
         if (String.isNotBlank(String.valueOf(ContactId))) {
            //Get current contact's details
            lstContacts = [SELECT Id, FirstName, Name, Email, AccountId, Account.Name
                           FROM Contact
                           WHERE Id = :ContactId AND Status__c = 'Active'];
            if (lstContacts.size() > 0)
            {
               SelectedContact = lstContacts[0];
            }
            else {
               LogException('Constructor', 'Contact record not found with the Id ' + ContactId, null, null);
               return;
            }
         }
         else if (String.isNotBlank(String.valueOf(ProjectId))) {
            List<pse__Proj__c> lstProjects = [SELECT Id, Name, Customer_Project_Contact__c, pse__Account__c, pse__Account__r.Name
                                              FROM pse__Proj__c
                                              WHERE Id = :ProjectId];
            AH_UDC_LogHelper.Debug('lstProjects: ' + lstProjects);
            if (lstProjects.size() == 0) {
               LogException('Constructor', 'Project record not found with the Id ' + ProjectId, null, null);
               return;
            }
            else if (String.isBlank(String.valueOf(lstProjects[0].Customer_Project_Contact__c))) {
               AllowSend = false;
               SendNotAllowedMessage = Label.AH_UDC_SendWorkbookProjectWithoutContactErrorMessage;
               return;
            }
            else {
               ProjectName = lstProjects[0].Name;
               lstContacts = [SELECT Id, FirstName, Name, Email, AccountId, Account.Name
                              FROM Contact
                              WHERE Id = :lstProjects[0].Customer_Project_Contact__c AND Status__c = 'Active'];

               if (lstContacts.size() > 0) {
                  ContactId = lstContacts[0].Id;
                  SelectedContact = lstContacts[0];
                  if (String.isNotBlank(String.valueOf(lstProjects[0].pse__Account__c))) {
                     //Use account details from project record if Account is associated
                     SelectedContact.AccountId = lstProjects[0].pse__Account__c;
                     SelectedContact.Account.Id = lstProjects[0].pse__Account__c;
                     SelectedContact.Account.Name = lstProjects[0].pse__Account__r.Name;
                  }
               }
               else {
                  LogException('Constructor', 'Contact record not found with the Id ' + lstProjects[0].Customer_Project_Contact__c, null, null);
                  return;
               }
            }
         }

         if (String.isBlank(SelectedContact.Email)) { //Check Contact has email address or not
            AllowSend = false;
            SendNotAllowedMessage = Label.AH_UDC_Send_Workbook_Contact_Email_Required_Message;
         }
         else if (String.isBlank(SelectedContact.FirstName)) {
            AllowSend = false;
            SendNotAllowedMessage = Label.AH_UDC_Send_Workbook_First_Name_Required;
         }
         else {
            GetProductList(); //Get available product list
            if (IsErrorOccurred == false) { //If error occurred in GetEnabledProductWorkbooks() then do not call other methods
               GetDefaultEmailTemplateDetails(); //Get default email template details to fill in the lookup field
            }
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred loading Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('Constructor', strErrorMessage, ex, null);
      }
      finally {
         externalUser = null;

         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   //Get available product list
   public void GetProductList() {
      Schema.DescribeFieldResult fieldResult = null;
      List<Schema.PicklistEntry> pickListEntry = null;
      try {
         WorkbookProducts = new List<SelectOption> ();
         fieldResult = AH_UDC_Workbook__c.Product__c.getDescribe();

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         if (fieldResult == null) {
            LogException('GetProductList', 'Metadata details not found for the field - Product__c', null, null);
            return;
         }

         pickListEntry = fieldResult.getPicklistValues();
         if (pickListEntry != null && pickListEntry.size() > 0) {
            WorkbookProducts.add(new SelectOption('', Label.AH_UDC_Send_Workbook_SelectProduct_Label));
            for (Schema.PicklistEntry option : pickListEntry) {
               WorkbookProducts.add(new SelectOption(option.getValue(), option.getLabel()));
            }
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred getting product list - Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetProductList', strErrorMessage, ex, null);
      }
   }

   //Get enabled workbook list for selected product
   public void GetEnabledProductWorkbooks() {
      Id workbookRecordTypeId = null;
      List<AH_UDC_Workbook__c> lstWorkbook = null;
      try {
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         EnabledProductWorkbooks = new List<SelectOption> ();
         workbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
         if (String.isNotBlank(String.valueOf(workbookRecordTypeId))) {
            EnabledProductWorkbooks.add(new SelectOption('', Label.AH_UDC_Send_Workbook_SelectWorkbook_Label));

            AggregateResult[] result = [SELECT Workbook__c, Workbook__r.Name WorkbookName, COUNT(Id) StepCount
                                        FROM AH_UDC_WorkbookStep__c
                                        WHERE Workbook__r.Product__c = :SelectedProduct
                                        AND Workbook__r.Enabled__c = true
                                        AND Workbook__r.RecordTypeId = :workbookRecordTypeId
                                        AND Enabled__c = true
                                        GROUP BY Workbook__c, Workbook__r.Name
                                        HAVING COUNT(Id) > 0];

            for (AggregateResult objWorkbook : result) {
               EnabledProductWorkbooks.add(new SelectOption((Id) objWorkbook.get('Workbook__c'), String.valueOf(objWorkbook.get('WorkbookName'))));
            }
         }
         else {
            LogException('GetEnabledProductWorkbooks', 'AH_UDC_Workbook Record Type No Found', null, null);
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred getting enable product workbook - Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetEnabledProductWorkbooks', strErrorMessage, ex, null);
      }
   }

   //Get default email template details based on developer name
   public void GetDefaultEmailTemplateDetails() {
      List<EmailTemplate> lstEmailTemplates = null;
      try {
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         //Get default email template details from the object based on developer name
         lstEmailTemplates = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = :Label.AH_UDC_Send_Workbook_Default_Email_Template];

         if (lstEmailTemplates != null && lstEmailTemplates.size() > 0) {
            SelectedEmailTemplateId = lstEmailTemplates[0].Id;
            SelectedEmailTemplateName = lstEmailTemplates[0].Name;
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred getting Default Email Template Details - Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetDefaultEmailTemplateDetails', strErrorMessage, ex, null);
      }
   }

   //Create community users before sending workbooks
   public void CreateCommunityUsers() {
      try {
         //NOTE: This method calls DML executed against SETUP objects ... thus no other objects can be inserted (like Log Messages)
         AH_UDC_LogHelper.QueueLogs = true;

         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceSendWorkbookCreateCommunityUserException', FALSE)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'Send Workbook Create Community Users'));

         //Create the primary contact's Community User
         Boolean IsAllUsersCreated = AH_UDC_SharedWithoutSharing.SetupCommunityAccess(ContactId);

         //Create any other contact Community User's
         AH_UDC_LogHelper.Debug('CreateCommunityUsers-ContactLookupList: ' + ContactLookupList);
         AH_UDC_LogHelper.Debug('CreateCommunityUsers-ContactLookupList.size(): ' + ContactLookupList.size());
         if (ContactLookupList != null && ContactLookupList.size() > 0) {
            for (ContactLookupWrapper objContact : ContactLookupList) {
               if (String.isNotBlank(String.valueOf(objContact.Id)) && String.isBlank(objContact.ErrorMessage)) {
                  Boolean IsAddUserCreated = AH_UDC_SharedWithoutSharing.SetupCommunityAccess(objContact.Id);
                  AH_UDC_LogHelper.Debug('CreateCommunityUsers : IsAddUserCreated: ' + IsAddUserCreated);
                  if (!IsAddUserCreated) {
                     IsAllUsersCreated = false;
                  }
               }
            }
         }
         IsCommunityUserCreated = IsAllUsersCreated;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred creating community user - Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         System.debug('Exception occurred: ' + strErrorMessage);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'CreateCommunityUsers', strErrorMessage,
                              ex, null, null);
      }
      finally {
         //Write any queued log messages since it can't be written due to the SETUP DML above
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();

         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   //Create required objects like NIDoc, UDC contact , workbook, workbook step & property account etc
   public void SendWorkbook() {
      Id accountId = null;
      Id workbookId = null;

      Account accountData = null;
      AH_UDC_Contact__c objUDCContact = null;

      //Prepare database save point for rollback transaction BEFORE any records are inserted
      Savepoint objSavePoint = Database.setSavepoint();

      try {
         //Alert the user if sending workbooks is disabled; buttons will be hidden too
         if (!isSendWorkbookEnabled) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, AH_UDC_ConfigHelper.GetString('AH_UDC_SendWorkbookDisabledMessage', 'Send Workbook is currently disabled.')));
            return;
         }

         if (String.isBlank(SelectedWorkbook)) {
            LogException('SendWorkbook', 'Workbook not selected', null, null);
            return;
         }

         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestSendWorkbookError', FALSE)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'Send Workbook'));

         //The the account ID for the active contact
         accountId = SelectedContact.Account.Id;

         //Insert NI Doc record
         NewNIDocId = CreateNIDocRecord(accountId, objSavePoint);
         AH_UDC_LogHelper.Debug('SendWorkbook : NewNIDocId: ' + String.valueOf(NewNIDocId));
         if (IsErrorOccurred || String.isBlank(String.valueOf(NewNIDocId))) return; //CreateNIDocRecord() will show the Error to the user and the rollback will occur if it can't insert a record

         //Insert property account record and map with inserted NI Doc record - this must happen before creating the steps
         CreatePropertyAccountRecord(objSavePoint, accountId);
         AH_UDC_LogHelper.Debug('SendWorkbook : propertyAccountId: ' + String.valueOf(propertyAccountId));
         AH_UDC_LogHelper.Debug('SendWorkbook : IsErrorOccurred: ' + IsErrorOccurred);
         if (IsErrorOccurred) return; //CreatePropertyAccountRecord() will show the Error to the user and the rollback will occur if it can't insert a record

         //Insert Workbook Sent record
         workbookId = CreateWorkbookSentRecord(objSavePoint);
         AH_UDC_LogHelper.Debug('SendWorkbook : workbookId' + String.valueOf(workbookId));
         if (IsErrorOccurred || String.isBlank(String.valueOf(workbookId))) return; //CreateWorkbookSentRecord() will show the Error to the user and the rollback will occur if it can't insert a record

         //Insert Workbook Step Sent records
         CreateWorkbookStepSentRecord(objSavePoint, SelectedWorkbook, workbookId);
         AH_UDC_LogHelper.Debug('SendWorkbook : CreateWorkbookStepSentRecord - IsErrorOccurred: ' + IsErrorOccurred);
         //Do not proceed further if error occurred
         if (IsErrorOccurred) return; //CreateWorkbookStepSentRecord() will show the Error to the user and the rollback will occur if it can't insert a record

         CreateFollowForCurrentUser(objSavePoint);
         AH_UDC_LogHelper.Debug('SendWorkbook : CreateFollowForCurrentUser - IsErrorOccurred: ' + IsErrorOccurred);
         if (IsErrorOccurred) return; //CreateFollowForCurrentUser() will show the Error to the user and the rollback will occur if it can't insert a record

         //Create primary AH_UDC_Contact record
         CreateUDCContacts(objSavePoint);
         AH_UDC_LogHelper.Debug('SendWorkbook : CreateUDCContacts - IsErrorOccurred: ' + IsErrorOccurred);
         if (IsErrorOccurred) return; //CreateUDCContacts() will show the Error to the user and the rollback will occur if it can't insert a record

         //Send welcome email to all selected contacts
         SendEmailToContacts();

         if (!IsCommunityUserCreated) {
            //If there is an error in creating community users then display message to user 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, Label.AH_UDC_CreateCommunityUserErrorMessage));
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred send workbook page for user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('SendWorkbook', strErrorMessage, ex, objSavepoint);
      }
   }

   //Create NI Doc record based on values provided
   private Id CreateNIDocRecord(Id accountId, Savepoint objSavepoint) {
      Id NIDocRecordTypeId = null;
      NI_Documentation__c objNIDoc = null;
      try {
         //Get record type id to insert NI Doc record
         NIDocRecordTypeId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
         if (String.isBlank(String.valueOf(NIDocRecordTypeId))) {
            LogException('CreateNIDocRecord', 'AH_UDC_Workbook Record Type Not Found', null, null);
            return null;
         }

         objNIDoc = new NI_Documentation__c(RecordTypeId = NIDocRecordTypeId, Document_Name__c = NiDocumentName.trim(), Account__c = accountId, AH_UDC_WorkbookDueDate__c = DueDate, OwnerId = Userinfo.getUserId(), AH_UDC_ChatterWorkbookAccessed__c = IsUDCWorkbookAccessed, AH_UDC_ChatterWorkbookCompleted__c = IsUDCWorkbookCompleted, AH_UDC_ChatterWorkbookStepCompleted__c = IsUDCWorkbookStepCompleted);
         if (String.isNotBlank(ProjectId))
         objNIDoc.Project__c = ProjectId;
         AH_UDC_SystemContext.CreateObject(objNIDoc);
         return objNIDoc.Id;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred create NI Doc Record - send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CreateNIDocRecord', strErrorMessage, ex, objSavepoint);
         return null;
      }
   }

   //Create Workbook Sent record based on selected workbook
   private Id CreateWorkbookSentRecord(Savepoint objSavepoint) {
      Id workbookSentRecordTypeId = null;
      List<AH_UDC_Workbook__c> lstWorkbooks = null;
      List<AH_UDC_Workbook__c> lstParentWorkbooks = null;
      AH_UDC_Workbook__c objWorkbookClone = null;
      try {
         //Get record type id to insert NI Doc record
         workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
         if (String.isNotBlank(String.valueOf(workbookSentRecordTypeId))) {
            lstWorkbooks = [SELECT CompletedDate__c, Description__c, Enabled__c, Id, Name, OwnerId, Product__c, RecordTypeId, RelatedToDocName__c, RelatedTo__c, SentDate__c, SentStatus__c, StepsinOrder__c, CompletedBy__c, WorkbookSentDueDate__c, ParentWorkbookSent__c, OriginalWorkbook__c
                            FROM AH_UDC_Workbook__c
                            WHERE Id = :SelectedWorkbook];

            if (lstWorkbooks != null && lstWorkbooks.size() > 0) {
               objWorkbookClone = lstWorkbooks[0].clone(false, false, false, false);
               objWorkbookClone.RecordTypeId = workbookSentRecordTypeId;
               objWorkbookClone.RelatedTo__c = NewNIDocId;
               objWorkbookClone.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
               objWorkbookClone.SentDate__c = Datetime.now();
               objWorkbookClone.CompletedDate__c = null;
               objWorkbookClone.CompletedBy__c = null;
               objWorkbookClone.OwnerId = UserInfo.getUserId();
               objWorkbookClone.SecurityCode__c = AH_UDC_Shared.GetSecurityCode(); //Security Code for each Workbook Sent must be unique
               AH_UDC_LogHelper.Debug('CreateWorkbookSentRecord => IsCopyWorkbook: ' + IsCopyWorkbook);
               if (IsCopyWorkbook == false) { //Only if New Workbook option is selected
                  objWorkbookClone.OriginalWorkbook__c = SelectedWorkbook;
                  if (String.isNotBlank(String.valueOf(SelectedNIDocIdNew))) { //If parent Workbook NI Doc is selected then set value in the field
                     lstParentWorkbooks = [SELECT Id
                                           FROM AH_UDC_Workbook__c
                                           WHERE RelatedTo__c = :SelectedNIDocIdNew];
                     if (lstParentWorkbooks != null && lstParentWorkbooks.size() > 0) {
                        objWorkbookClone.ParentWorkbookSent__c = lstParentWorkbooks[0].Id;
                     }
                     else {
                        LogException('CreateWorkbookSentRecord', 'Selected NI Doc record do not workbook associated', null, objSavepoint);
                     }
                  }
               }
               if (objWorkbookClone != null) {
                  AH_UDC_SystemContext.CreateObject(objWorkbookClone);
                  return objWorkbookClone.Id;
               }
               return '';
            }
            else {
               LogException('CreateWorkbookSentRecord', 'Selected Workbook Record Not Found', null, objSavepoint);
               return '';
            }
         }
         else {
            LogException('CreateWorkbookSentRecord', 'AH_UDC_Workbook Record Type Not Found', null, objSavepoint);
            return '';
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CreateWorkbookSentRecord', strErrorMessage, ex, objSavepoint);
         return objWorkbookClone != null ? objWorkbookClone.Id : '';
      }
   }

   //Create Workboook Step Sent record based on values provided
   private void CreateWorkbookStepSentRecord(Savepoint objSavepoint, Id originalWorkbookId, Id newWorkbookId) {
      Id workbookStepSentRecordTypeId = null;
      Id workbookRecordTypeId = null;
      try {
         //Get record type id to insert Workboook Step Sent record
         workbookStepSentRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
         if (IsCopyWorkbook) {
            workbookRecordTypeId = workbookStepSentRecordTypeId;
         }
         else {
            workbookRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();
         }
         if (String.isNotBlank(String.valueOf(workbookStepSentRecordTypeId)) && String.isNotBlank(String.valueOf(workbookRecordTypeId))) {
            List<AH_UDC_WorkbookStep__c> lstNewWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ();
            Map<Decimal, Decimal> stepSortOrderMapPrereq = new Map<Decimal, Decimal> (); //It will hold sort order along with sort order of it's prequisite step
            List<AH_UDC_WorkbookStep__c> lstOriginalWorkbookSteps = [SELECT Id, Name, CurrencyIsoCode, Description__c, Enabled__c, Form__c, Help__c, Prerequisite_Step__c,
                                                                     RecordTypeId, SortOrder__c, StepCompleted__c, StepStatus__c, URL__c, StepCompletedBy__c, Workbook__c,
                                                                     Form__r.FormType__c, Form__r.CopyResponseWhenSendingNew__c
                                                                     FROM AH_UDC_WorkbookStep__c
                                                                     WHERE Workbook__c = :originalWorkbookId AND RecordTypeId = :workbookRecordTypeId
                                                                     AND Enabled__c = true //Only Copy enabled steps to Sent Workbook
                                                                     ORDER BY SortOrder__c];
            AH_UDC_LogHelper.Debug('CreateWorkbookStepSentRecord => Total Steps to be created: ' + lstOriginalWorkbookSteps.size());
            Map<Id, Decimal> stepIdSortOrderMap = new Map<Id, Decimal> (); //It will hold StepId and it's Sort Order
            for (AH_UDC_WorkbookStep__c objOriginalStep : lstOriginalWorkbookSteps) {
               AH_UDC_WorkbookStep__c objNewStep = objOriginalStep.clone(false, false, false, false);
               objNewStep.RecordTypeId = workbookStepSentRecordTypeId;
               objNewStep.Workbook__c = newWorkbookId;
               objNewStep.StepStatus__c = AH_UDC_Constants.STEP_STATUS_NEW;
               objNewStep.StepCompleted__c = null;
               objNewStep.StepCompletedBy__c = null;
               objNewStep.CreatedById = UserInfo.getUserId();
               objNewStep.CreatedDate = DateTime.now();
               objNewStep.LastModifiedById = UserInfo.getUserId();
               objNewStep.LastModifiedDate = DateTime.now();
               if (String.isNotBlank(objOriginalStep.Prerequisite_Step__c)) {
                  objNewStep.Prerequisite_Step__c = null;
                  stepSortOrderMapPrereq.put(objOriginalStep.SortOrder__c, stepIdSortOrderMap.get(objOriginalStep.Prerequisite_Step__c));
               }
               stepIdSortOrderMap.put(objOriginalStep.Id, objOriginalStep.SortOrder__c);
               lstNewWorkbookSteps.add(objNewStep);
            }

            if (lstNewWorkbookSteps != null && lstNewWorkbookSteps.size() > 0) {
               AH_UDC_LogHelper.Debug('CreateWorkbookStepSentRecord => lstNewWorkbookSteps.size(): ' + lstNewWorkbookSteps.size());
               AH_UDC_SystemContext.CreateObjects(lstNewWorkbookSteps);

               //Map of SortOrder and StepId for which copy of form responses is pending
               Map<Decimal, Id> mapNewInsertedStepIdAndSortOrder = new Map<Decimal, Id> ();
               for (AH_UDC_WorkbookStep__c objInsertedStep : lstNewWorkbookSteps) {
                  mapNewInsertedStepIdAndSortOrder.put(objInsertedStep.SortOrder__c, objInsertedStep.Id);
                  if (stepSortOrderMapPrereq.containsKey(objInsertedStep.SortOrder__c)) {
                     Decimal sortOrderOfPrereqStep = stepSortOrderMapPrereq.get(objInsertedStep.SortOrder__c);
                     //Get prerequisite stepid based on it's sort order
                     objInsertedStep.Prerequisite_Step__c = mapNewInsertedStepIdAndSortOrder.get(sortOrderOfPrereqStep);
                  }
               }

               AH_UDC_LogHelper.Debug('CreateWorkbookStepSentRecord => mapNewInsertedStepIdAndSortOrder: ' + mapNewInsertedStepIdAndSortOrder);
               AH_UDC_LogHelper.Debug('CreateWorkbookStepSentRecord => stepSortOrderMapPrereq: ' + stepSortOrderMapPrereq);
               if (stepSortOrderMapPrereq != null && stepSortOrderMapPrereq.size() > 0) {
                  //Update inserted steps to set prerequisite step
                  AH_UDC_SystemContext.UpdateObjects(lstNewWorkbookSteps);
               }

               //Copy responses for new inserted steps
               CopyStepResponses(objSavepoint, lstOriginalWorkbookSteps, mapNewInsertedStepIdAndSortOrder);
            }
         }
         else {
            LogException('CreateWorkbookStepSentRecord', 'AH_UDC_WorkbookStep Or AH_UDC_WorkbookStepSent Record Type Not Found', null, objSavepoint);
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CreateWorkbookStepSentRecord', strErrorMessage, ex, objSavepoint);
      }
   }

   //Insert responses into junction object AH_UDC_WorkbookStepResponse__c
   private void CopyStepResponses(Savepoint objSavepoint, List<AH_UDC_WorkbookStep__c> lstOriginalWorkbookSteps, Map<Decimal, Id> mapNewInsertedStepIdAndSortOrder) {
      try {
         //Determine which forms are Shared/Central, or product form, where CopyResponseWhenSendingNew__c checkbox is checked
         Map<Id, Decimal> mapFormIdAndSortOrder = new Map<Id, Decimal> ();
         for (AH_UDC_WorkbookStep__c wbStep : lstOriginalWorkbookSteps) {
            if (wbStep.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_CENTRAL
                || wbStep.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_SHARED
                || wbStep.Form__r.CopyResponseWhenSendingNew__c) {
               mapFormIdAndSortOrder.put(wbStep.Form__c, wbStep.SortOrder__c);
            }
         }
         AH_UDC_LogHelper.Debug('CopyStepResponses : mapFormIdAndSortOrder: ' + mapFormIdAndSortOrder);
         AH_UDC_LogHelper.Debug('CopyStepResponses : propertyAccountId: ' + propertyAccountId);

         List<AH_UDC_WorkbookStepResponse__c> lstStepResponses = new List<AH_UDC_WorkbookStepResponse__c> ();

         // Has the Form IDs of all the Step Responses that are already in lstStepResponses, so that we can filter
         // out the ones that have already been added to the list of responses that are to be copied when
         // performing the query on ProductFormResponses
         List<Id> lstIdOfFormWithStepResponsesBeingCopied = new List<Id> ();

         if (mapFormIdAndSortOrder.size() > 0) {
            //Get shared & central forms responses as well as product form responses if checkbox CopyResponseWhenSendingNew__c is checked
            AggregateResult[] groupedResults = [SELECT WorkbookStep__r.Form__c FormId, max(Response__c) maxResponseId
                                                FROM AH_UDC_WorkbookStepResponse__c
                                                WHERE WorkbookStep__r.Form__c IN :mapFormIdAndSortOrder.keySet()
                                                AND IsMostRecentResponse__c = true
                                                AND WorkbookStep__r.Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c = :propertyAccountId
                                                GROUP BY WorkbookStep__r.Form__c];

            for (AggregateResult result : groupedResults) {
               Id formId = (Id) result.get('FormId');
               Id responseId = (Id) result.get('maxResponseId');
               if (mapFormIdAndSortOrder.containsKey(formId) && mapNewInsertedStepIdAndSortOrder.containsKey(mapFormIdAndSortOrder.get(formId))) {
                  lstIdOfFormWithStepResponsesBeingCopied.add(formId);
                  lstStepResponses.add(new AH_UDC_WorkbookStepResponse__c(WorkbookStep__c = mapNewInsertedStepIdAndSortOrder.get(mapFormIdAndSortOrder.get(formId)),
                                                                          Response__c = responseId));
               }
            }
            AH_UDC_LogHelper.Debug('CopyStepResponses : lstStepResponses - Shared & Central Forms: ' + lstStepResponses);
         }

         if (IsCopyWorkbook) {
            //For copy workbook option get responses of product forms
            List<AH_UDC_WorkbookStepResponse__c> lstProductFormResponses = [SELECT WorkbookStep__c, WorkbookStep__r.SortOrder__c, Response__c
                                                                            FROM AH_UDC_WorkbookStepResponse__c
                                                                            WHERE WorkbookStep__c IN :lstOriginalWorkbookSteps
                                                                            AND WorkbookStep__r.Form__c NOT IN :lstIdOfFormWithStepResponsesBeingCopied
                                                                            AND IsMostRecentResponse__c = true
                                                                            AND WorkbookStep__r.Form__r.FormType__c = :AH_UDC_Constants.FORM_TYPE_PRODUCT];

            AH_UDC_LogHelper.Debug('CopyStepResponses : lstProductFormResponses: ' + lstProductFormResponses);
            for (AH_UDC_WorkbookStepResponse__c objStepResp : lstProductFormResponses) {
               if (mapNewInsertedStepIdAndSortOrder.containsKey(objStepResp.WorkbookStep__r.SortOrder__c)) {
                  lstStepResponses.add(new AH_UDC_WorkbookStepResponse__c(WorkbookStep__c = mapNewInsertedStepIdAndSortOrder.get(objStepResp.WorkbookStep__r.SortOrder__c),
                                                                          Response__c = objStepResp.Response__c));
               }
            }
            AH_UDC_LogHelper.Debug('CopyStepResponses : lstStepResponses - Copy Workbook Option: ' + lstStepResponses);
         }

         if (lstStepResponses.size() > 0) {
            //Insert records into the object AH_UDC_WorkbookStepResponse__c
            AH_UDC_SystemContext.CreateObjects(lstStepResponses);
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CopyStepResponses', strErrorMessage, ex, objSavepoint);
      }
   }

   //Create Property Account record based on values provided
   private Id CreatePropertyAccountRecord(Savepoint objSavepoint, Id accountId) {
      AH_UDC_LogHelper.Debug('CreatePropertyAccountRecord : accountId: ' + accountId);

      List<AH_UDC_PropertyAccount__c> lstPropertyAccounts = null;
      NI_Documentation__c objNIDoc = null;
      List<Account> lstAccounts = null;
      AH_UDC_PropertyAccount__c objPropertyaccount = null;
      propertyAccountId = null;
      try {
         if (String.isNotBlank(String.valueOf(accountId))) {
            lstPropertyAccounts = [SELECT Id
                                   FROM AH_UDC_PropertyAccount__c
                                   WHERE Account__r.Id = :accountId];
            if (lstPropertyAccounts.size() > 0) {
               //Map inserted NI Doc record with existing property account record
               propertyAccountId = lstPropertyAccounts[0].Id;
            }
            else {
               //Get details of selected account from the object and use them to create AH_UDC_PropertyAccount record
               lstAccounts = [SELECT Id, Name,
                              ShippingStreet, ShippingState, ShippingCity, ShippingPostalCode, ShippingCountry,
                              BillingStreet, BillingState, BillingCity, BillingPostalCode, BillingCountry, Phone
                              FROM Account
                              WHERE Id = :accountId];
               if (lstAccounts.size() > 0) {
                  objPropertyaccount = new AH_UDC_PropertyAccount__c(
                                                                     Account__c = lstAccounts[0].Id,
                                                                     PropertyName__c = lstAccounts[0].Name,
                                                                     Address__c = (String.isNotBlank(lstAccounts[0].ShippingStreet) ? lstAccounts[0].ShippingStreet : lstAccounts[0].BillingStreet),
                                                                     City__c = (String.isNotBlank(lstAccounts[0].ShippingCity) ? lstAccounts[0].ShippingCity : lstAccounts[0].BillingCity),
                                                                     StateProvince__c = (String.isNotBlank(lstAccounts[0].ShippingState) ? lstAccounts[0].ShippingState : lstAccounts[0].BillingState),
                                                                     PostalCode__c = (String.isNotBlank(lstAccounts[0].ShippingPostalCode) ? lstAccounts[0].ShippingPostalCode : lstAccounts[0].BillingPostalCode),
                                                                     Country__c = (String.isNotBlank(lstAccounts[0].ShippingCountry) ? lstAccounts[0].ShippingCountry : lstAccounts[0].BillingCountry),
                                                                     Phone__c = lstAccounts[0].Phone,
                                                                     OwnerId = Userinfo.getUserId());
                  AH_UDC_SystemContext.CreateObject(objPropertyaccount);
                  propertyAccountId = objPropertyaccount.Id;
               }
               else {
                  LogException('CreatePropertyAccountRecord', 'Account details not found', null, objSavepoint);
                  return '';
               }
            }
         }
         else { //If account not selected then create property account record with empty field values
            objPropertyAccount = new AH_UDC_PropertyAccount__c(
                                                               Address__c = '',
                                                               City__c = '',
                                                               StateProvince__c = '',
                                                               PostalCode__c = '',
                                                               Country__c = '',
                                                               Phone__c = '');
            AH_UDC_SystemContext.CreateObject(objPropertyAccount);
            propertyAccountId = objPropertyAccount.Id;
         }
         AH_UDC_LogHelper.Debug('CreatePropertyAccountRecord : objPropertyAccount: ' + objPropertyAccount);

         if (String.isBlank(propertyAccountId)) {
            LogException('CreatePropertyAccountRecord', 'Property Account record not inserted', null, objSavepoint);
            return '';
         }

         //Update the already created NIDoc with the AH_UDC_PropertyAccount record id
         objNIDoc = new NI_Documentation__c(
                                            Id = NewNIDocId,
                                            AH_UDC_PropertyAccount__c = propertyAccountId);
         AH_UDC_Security.UpdateObject(objNIDoc);

         AH_UDC_LogHelper.Debug('CreatePropertyAccountRecord : propertyAccountId :' + propertyAccountId);
         return propertyAccountId;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred in  Create Property Account Record - send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CreatePropertyAccountRecord', strErrorMessage, ex, objSavepoint);
         return propertyAccountId;
      }
   }

   //Create a Follow for the current user on the NI Document
   private void CreateFollowForCurrentUser(Savepoint objSavepoint) {
      try {
         //TODO:ROBDEV fix with MOCK
         if (!Test.isRunningTest()) ConnectApi.Subscription subscriptionToRecord = ConnectApi.ChatterUsers.follow(null, Userinfo.getUserId(), NewNIDocId);
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred creating a Follow for user Id (' + Userinfo.getUserId() + ') NIDocument Id (' + NewNIDocId + ') : ' + ex.getMessage();
         if (Test.isRunningTest()) {
            //Can not set IsErrorOccurred = true for test class because of following error, so directly calling LogException method of log helper class
            //System.UnsupportedOperationException: ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true)
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC, LogFunctionalArea, 'CreateFollowForCurrentUser', strErrorMessage, ex, null, null);
         } else {
            LogException('CreateFollowForCurrentUser', strErrorMessage, ex, objSavepoint);
         }
         return;
      }
   }

   //Create a Follow for the current user on the NI Document
   private void CreateUDCContacts(Savepoint objSavepoint) {
      try {
         List<AH_UDC_Contact__c> lstUDCContact = new List<AH_UDC_Contact__c> ();

         //Add the primary UDC Contact
         lstUDCContact.add(new AH_UDC_Contact__c(Contact__c = ContactId, Document__c = NewNIDocId));

         //Add any additional UDC Contacts
         if (ContactLookupList != null && ContactLookupList.size() > 0) {
            AH_UDC_LogHelper.Debug('SendWorkbook : CreateUDCContacts - ContactLookupList.size(): ' + ContactLookupList.size());

            for (ContactLookupWrapper objContact : ContactLookupList) {
               if (String.isNotBlank(String.valueOf(objContact.Id)) && String.isBlank(objContact.ErrorMessage)) {
                  lstUDCContact.add(new AH_UDC_Contact__c(Contact__c = objContact.Id, Document__c = NewNIDocId));
               }
            }
         }

         //Insert the UDC contact records
         if (lstUDCContact.size() > 0) {
            AH_UDC_SystemContext.CreateObjects(lstUDCContact);
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred creating UDC Contacts: ' + ex.getMessage();
         LogException('CreateUDCContacts', strErrorMessage, ex, objSavepoint);
         return;
      }
   }

   //Send email to contact after sending workbook
   @TestVisible private void SendEmailToContacts() {
      try {
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         if (SelectedContact != null && String.isNotBlank(SelectedContact.Email) && String.isNotBlank(String.valueOf(NewNIDocId))) {
            List<string> lstToAddresses = new List<string> ();
            lstToAddresses.add(SelectedContact.Email); //Prepare to email addresses list            

            if (ContactLookupList != null && ContactLookupList.size() > 0) {
               List<Contact> lstContacts = new List<Contact> ();
               for (ContactLookupWrapper objUDCContact : ContactLookupList) {
                  if (String.isNotBlank(String.valueOf(objUDCContact.Id)) && String.isBlank(objUDCContact.ErrorMessage)) {
                     //Prepare Contact id list to pass in query for getting contact email addresses
                     lstContacts.add(new Contact(Id = objUDCContact.Id));
                  }
               }

               if (lstContacts != null && lstContacts.size() > 0) {
                  for (Contact objContact :[SELECT Email FROM Contact WHERE Id IN :lstContacts]) {
                     if (String.isNotBlank(objContact.Email)) {
                        lstToAddresses.add(objContact.Email); //Add additional contact's email in to email addresses list
                     }
                  }
               }
            }

            Boolean IsEmailSent = AH_UDC_SharedWithoutSharing.SendEmailToContacts(LogFunctionalArea, lstToAddresses, SelectedEmailTemplateId, SelectedContact.Id, NewNIDocId);
            if (IsEmailSent) {
               AH_UDC_LogHelper.Debug('Email has been sent successfully.');
            }
            else {
               IsErrorOccurred = true;
               SendEmailFailed = true;
            }
         }
      }
      catch(Exception ex) {
         IsErrorOccurred = true;

         String strErrorMessage = 'An exception occurred while sending email to the contact - Logged-In User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, 'SendEmailToContacts', strErrorMessage, Label.AH_UDC_Send_Email_Error_Message, ex);
      }
   }

   //Add new contact lookup on click of Add Contact button
   public void AddContactLookup() {
      if (ContactLookupList.size() >= AddContactLimit) return;

      ContactLookupWrapper objContact = null;
      try {
         objContact = new ContactLookupWrapper();
         objContact.ErrorMessage = '';
         objContact.Index = ContactLookupList != null && ContactLookupList.size() > 0 ? ContactLookupList.size() : 0;
         ContactLookupList.add(objContact);
         AH_UDC_LogHelper.Debug('ContactLookupList ' + ContactLookupList);
      }
      catch(Exception ex) {
         String strErrorMessage = System.Label.AH_UDC_Send_Email_Error_Message + '- Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('AddContactLookup', strErrorMessage, ex, null);
      }
   }

   //Check Contact has external User or not   
   public void ValidateContact() {
      Integer lookupIndex = 0;
      Map<Id, Contact> userContactMap = null;
      Set<Id> contactIDList = null;
      try {
         AH_UDC_LogHelper.Debug('ValidateContact : SelectedContactId: ' + SelectedContactId);
         AH_UDC_LogHelper.Debug('ValidateContact : ContactLookupList: ' + ContactLookupList);

         contactIDList = new Set<Id> ();
         for (ContactLookupWrapper CLW : ContactLookupList) {
            contactIDList.add(CLW.Id);
         }

         if (contactIDList != null && contactIDList.size() > 0) {
            userContactMap = new Map<ID, Contact> ([SELECT Id, Email
                                                   FROM Contact
                                                   WHERE Id IN :contactIDList]);
         }

         for (Integer index = 0; index<ContactLookupList.size(); index++) {
            ContactLookupWrapper objContact = ContactLookupList[index];
            if (String.isNotBlank(objContact.Id)) {

               if (userContactMap != null && userContactMap.size()> 0) {
                  SelectedUserEmail = userContactMap.get(objContact.Id).Email;
               }

               if (String.isBlank(SelectedUserEmail)) {
                  SetErrorMessageForSelectedContact(index, Label.AH_UDC_Send_Workbook_Additional_Contact_Email_Required_Message);
               } else if (ContactId.equals(objContact.Id) || IsContactAlreadySelected(index, objContact.Id)) {
                  SetErrorMessageForSelectedContact(index, Label.AH_UDC_Duplicate_Contact_Added_For_Send_Workbook_Message);
               } else {
                  //Remove error message if no error found
                  SetErrorMessageForSelectedContact(index, '');
               }
            } else {
               //Remove error message if contact value removed from lookup field or incorrect contact name text entered                        
               SetErrorMessageForSelectedContact(index, '');
            }
         }
         AH_UDC_LogHelper.Debug('ValidateContact : ContactLookupList: ' + ContactLookupList);
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred Validate Contact - send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('ValidateContact', strErrorMessage, ex, null);
      }
   }

   //Check if same contact selected more that once     
   private Boolean IsContactAlreadySelected(Integer lookupIndex, Id ContactId) {
      Integer duplicateCount = 0;
      for (Integer index = 0; index<ContactLookupList.size(); index++) {
         ContactLookupWrapper objContact = ContactLookupList[index];

         if (String.isNotBlank(ContactId) && index != lookupIndex && objContact.Id == ContactId) {
            duplicateCount++;
         }
      }
      return duplicateCount> 0;
   }

   //Set error message for selected contactgg
   private void SetErrorMessageForSelectedContact(Integer lookupIndex, String strMessage) {
      if (ContactLookupList != null && ContactLookupList.size() >= lookupIndex) {
         ContactLookupList[lookupIndex].ErrorMessage = strMessage;
      }
   }

   //Get workbook sent record deatils based on NI Doc Id
   public void GetWorkbookSentDetails() {
      Id NIDocIDForWorkbook = null;
      List<AH_UDC_Workbook__c> lstCopyWorkbookSent = null;
      try {
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         if (IsCopyWorkbook) {
            NIDocIDForWorkbook = SelectedNIDocIdCopy;
         }
         else {
            NIDocIDForWorkbook = SelectedNIDocIdNew;
         }

         if (String.isNotBlank(String.valueOf(NIDocIDForWorkbook))) {
            lstCopyWorkbookSent = [SELECT Id, Name, Product__c, RelatedTo__r.Account__c, RelatedTo__r.AH_UDC_WorkbookDueDate__c, ParentWorkbookSent__r.Name,
                                   RelatedTo__r.AH_UDC_ChatterWorkbookAccessed__c, RelatedTo__r.AH_UDC_ChatterWorkbookCompleted__c, RelatedTo__r.AH_UDC_ChatterWorkbookStepCompleted__c
                                   FROM AH_UDC_Workbook__c
                                   WHERE RelatedTo__c = :NIDocIDForWorkbook];

            if (lstCopyWorkbookSent != null && lstCopyWorkbookSent.size() > 0) {
               ParentWorkbookName = lstCopyWorkbookSent[0].ParentWorkbookSent__r.Name;
               m_niDoc.AH_UDC_WorkbookDueDate__c = lstCopyWorkbookSent[0].RelatedTo__r.AH_UDC_WorkbookDueDate__c;
               SelectedProduct = lstCopyWorkbookSent[0].Product__c;
               SelectedWorkbook = lstCopyWorkbookSent[0].Id;
               IsUDCWorkbookCompleted = true;
               EnabledProductWorkbooks = new List<SelectOption> ();
               EnabledProductWorkbooks.add(new SelectOption(lstCopyWorkbookSent[0].Id, lstCopyWorkbookSent[0].Name));
            }
         }
         else {
            m_niDoc.AH_UDC_WorkbookDueDate__c = null;
            SelectedProduct = null;
            SelectedWorkbook = null;
            SelectedContact.AccountId = null;
            EnabledProductWorkbooks = new List<SelectOption> ();
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred Get Workbook Sent Details - send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetWorkbookSentDetails', strErrorMessage, ex, null);
      }
      finally {
         lstCopyWorkbookSent = null;
      }
   }

   //Log exception and display error message to user
   private void LogException(String strMethodName, String strErrorMessage, Exception exc, Savepoint objSavepoint) {
      IsErrorOccurred = true;
      AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, strMethodName, strErrorMessage, System.Label.AH_UDC_Common_Error_Message_Backend, exc, objSavepoint);
   }

   //This method is used by a client side actionfunction to log AH_UDC_Log entries that couldn't be created by the page load due to SOQL DML retrictions
   public void ServerLogMessages() {
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages');
      try {
         if (PageLoadLogMessages != null && PageLoadLogMessages.size() > 0) {
            insert(PageLoadLogMessages);
         }
         PageLoadLogMessages = new List<AH_UDC_Log__c> ();

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
      }
      catch(Exception ex) {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages - Exception: ' + ex);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'ServerLogMessages',
                              'An exception occurred logging Page Load AH_UDC_Log entries',
                              ex, null, null);
      }
   }
=======
/***********************************************************************************************
  Name            : AH_UDC_SendWorkbook
  Author          : Umang Ankleshwaria
  Created Date    : 22-Jan-2021
  Last Mod Date   : 08-Fab-2021
  Last Mod By     : Umang Ankleshwaria
  NICC Reference  : 
  Description     : Controller class for UDC SendWorkbook page of UDC 
  Change History  :
  1. 590043 - Refactoring Code - Changed by Umang Ankleshwaria on 8-Feb-2021
  2. 594855 - Refactoring Code - Changed by Tushar Gupta on 23-Feb-2021
 ************************************************************************************************/
public with sharing class AH_UDC_SendWorkbook {

   // In v30 and higher (at least through v52) Salesforce broke use of the standard datepicker that is rendered using code like this:
   //
   // <apex:inputText id="dueDateinput" label="Workbook Due Date" value="{!DueDate}"
   //                 onfocus="DatePicker.pickDate(false, 'SendWorkbookPage:frmSendWorkbook:pbSendWorkbook:dueDateinput', false);"
   //                 html-autocomplete="off" />
   //
   // The date picker will not render unless there is at least on <apex:inputField> reference to a date field on the page.
   //
   // This NI_Documentation__c instance is used to put a hidden div on the page that will cause SF to load the required JS
   // necessary for rendering the DatePicker
   private NI_Documentation__c m_niDoc = new NI_Documentation__c();
   public NI_Documentation__c bugfix_niDoc { get { return m_niDoc; } set { m_niDoc = value; } }
   public Date DueDate { get { return bugfix_niDoc.AH_UDC_WorkbookDueDate__c; } set { bugfix_niDoc.AH_UDC_WorkbookDueDate__c = value; } }

   public String SelectedProduct { get; set; }
   public Boolean ProductSelected { get { return false; } set; }
   public Boolean IsCommunityUserCreated { get; set; } { IsCommunityUserCreated = false; }
   public Boolean IsCopyWorkbook { get; set; } // This is for New UDC Copy Exisiting Workbook  
   public Boolean IsUDCWorkbookAccessed { get; set; } { IsUDCWorkbookAccessed = AH_UDC_ConfigHelper.GetBoolean('AH_UDC_WorkbookAccessedDefaultValue', false); } //This is for Workbook Accessed  status flags
   public Boolean IsUDCWorkbookCompleted { get; set; } { IsUDCWorkbookCompleted = AH_UDC_ConfigHelper.GetBoolean('AH_UDC_WorkbookCompletedDefaultValue', false); } //This is for Workbook Completed status flags
   public Boolean IsUDCWorkbookStepCompleted { get; set; } { IsUDCWorkbookStepCompleted = AH_UDC_ConfigHelper.GetBoolean('AH_UDC_WorkbookStepCompletedDefaultValue', false); } //This is for Workbook Step Completed status flags
   public String SelectedWorkbook { get; set; }
   public String NiDocumentName { get; set; }
   public String CurrentUserDateSeparator { get { return AH_UDC_DateFormat.DateSeparator(); } }
   public String CurrentUserDateFormatString { get { return AH_UDC_DateFormat.DateFormatString(); } }
   public Id SelectedEmailTemplateId { get; set; }
   public String SelectedEmailTemplateName { get; set; }
   public List<SelectOption> WorkbookProducts { get; set; }
   public List<SelectOption> EnabledProductWorkbooks { get; set; }
   public Contact SelectedContact { get; set; }
   public Id SelectedNIDocIdCopy { get; set; }
   public Id SelectedNIDocIdNew { get; set; }
   public String ParentWorkbookName { get; set; }
   public Id ContactId { get; set; }
   public Id ProjectId { get; set; }
   public String ProjectName { get; set; }
   public Id NewNIDocId { get; set; } //New inserted NI Doc Id
   public Boolean IsErrorOccurred { get; set; } { IsErrorOccurred = false; } //To display error on page 
   public Boolean SendEmailFailed { get; set; } //It will be true only if error occurred while sending an email
   public String UserLocale { get; set; }
   public Id SelectedContactId { get; set; }
   public List<ContactLookupWrapper> ContactLookupList { get; set; } { ContactLookupList = new List<ContactLookupWrapper> (); }
   public String SelectedUserEmail { get; set; }
   public Integer AddContactLimit { get; set; } { AddContactLimit = AH_UDC_ConfigHelper.GetInteger('AH_UDC_AddContactLimit', 5); } //Maximum number of contacts allowed
   public String AddContactLimitString { get { return String.valueOf(AddContactLimit); } } //Maximum number of contacts allowed
   public Id propertyAccountId { get; set; }
   public Boolean isSendWorkbookEnabled { get { return AH_UDC_ConfigHelper.GetBoolean('AH_UDC_SendWorkbookEnabled', false); } }
   public Boolean AllowSend { get; set; } { AllowSend = true; }
   public String SendNotAllowedMessage { get; set; }
   public Boolean ReleaseWorkbook { get; set; } { ReleaseWorkbook = true; }
   
   public class ContactLookupWrapper {
      public Integer Index { get; set; }
      public Id Id { get; set; }
      public string Name { get; set; }
      public string ErrorMessage { get; set; }
   }

   @TestVisible private string LogFunctionalArea = 'AH_UDC_SendWorkbook'; //This is used for AH_UDC_Log Entries being written on this page
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }
   //This is used client side to determine if AH_UDC_Log Messages need to be written from the Page Load
   public Boolean HasPageLoadLogMessages {
      get {
         AH_UDC_LogHelper.Debug('PageLoadLogMessages: ' + PageLoadLogMessages);
         return PageLoadLogMessages != null && PageLoadLogMessages.size() > 0;
      }
   }

   public AH_UDC_SendWorkbook(ApexPages.StandardController controller) {
      List<User> externalUser = null;
      try {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;

         //Determine if the current user has the UDC System Admin permission set assigned to them
         String UDCSystemAdminPermissionSetName = AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetUDCSystemAdministrator', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN);
         Boolean isUDCSysAdmin = 0 < (Integer) [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :System.UserInfo.getUserId() AND PermissionSet.Name = :UDCSystemAdminPermissionSetName];

         //Alert the user if sending workbooks is disabled; UDC System Admins are excluded
         if (!isUDCSysAdmin && !isSendWorkbookEnabled) {
            AllowSend = false;
            SendNotAllowedMessage = AH_UDC_ConfigHelper.GetString('AH_UDC_SendWorkbookDisabledMessage', 'Send Workbook is currently disabled.');
            return;
         }

         IsCopyWorkbook = false;
         SelectedContact = new Contact();
         ContactId = apexpages.currentpage().getparameters().get('Id');
         ProjectId = apexpages.currentpage().getparameters().get('ProjectId');
         UserLocale = UserInfo.getLocale();
         ParentWorkbookName = '';
         AH_UDC_LogHelper.Debug('ContactId: ' + ContactId);
         AH_UDC_LogHelper.Debug('ProjectId: ' + ProjectId);

         if (String.isBlank(String.valueOf(ContactId)) && String.isBlank(String.valueOf(ProjectId))) {
            LogException('Constructor', 'ContactId or ProjectId not found in the parameters', null, null);
            return;
         }

         List<Contact> lstContacts = null;
         if (String.isNotBlank(String.valueOf(ContactId))) {
            //Get current contact's details
            lstContacts = [SELECT Id, FirstName, Name, Email, AccountId, Account.Name
                           FROM Contact
                           WHERE Id = :ContactId AND Status__c = 'Active'];
            if (lstContacts.size() > 0)
            {
               SelectedContact = lstContacts[0];
            }
            else {
               LogException('Constructor', 'Contact record not found with the Id ' + ContactId, null, null);
               return;
            }
         }
         else if (String.isNotBlank(String.valueOf(ProjectId))) {
            List<pse__Proj__c> lstProjects = [SELECT Id, Name, Customer_Project_Contact__c, pse__Account__c, pse__Account__r.Name
                                              FROM pse__Proj__c
                                              WHERE Id = :ProjectId];
            AH_UDC_LogHelper.Debug('lstProjects: ' + lstProjects);
            if (lstProjects.size() == 0) {
               LogException('Constructor', 'Project record not found with the Id ' + ProjectId, null, null);
               return;
            }
            else if (String.isBlank(String.valueOf(lstProjects[0].Customer_Project_Contact__c))) {
               AllowSend = false;
               SendNotAllowedMessage = Label.AH_UDC_SendWorkbookProjectWithoutContactErrorMessage;
               return;
            }
            else {
               ProjectName = lstProjects[0].Name;
               lstContacts = [SELECT Id, FirstName, Name, Email, AccountId, Account.Name, Status__c
                              FROM Contact
                              WHERE Id = :lstProjects[0].Customer_Project_Contact__c];

               if (lstContacts.size() > 0) {
                  if (lstContacts[0].Status__c != 'Active') {
                     AllowSend = false;
                     SendNotAllowedMessage = Label.AH_UDC_SendWorkbookProjectWithInActiveContactErrorMessage;
                     return;
                  }
                  ContactId = lstContacts[0].Id;
                  SelectedContact = lstContacts[0];
                  if (String.isNotBlank(String.valueOf(lstProjects[0].pse__Account__c))) {
                     //Use account details from project record if Account is associated
                     SelectedContact.AccountId = lstProjects[0].pse__Account__c;
                     SelectedContact.Account.Id = lstProjects[0].pse__Account__c;
                     SelectedContact.Account.Name = lstProjects[0].pse__Account__r.Name;
                  }
               }
               else {
                  LogException('Constructor', 'Contact record not found with the Id ' + lstProjects[0].Customer_Project_Contact__c, null, null);
                  return;
               }
            }
         }

         if (String.isBlank(SelectedContact.Email)) { //Check Contact has email address or not
            AllowSend = false;
            SendNotAllowedMessage = Label.AH_UDC_Send_Workbook_Contact_Email_Required_Message;
         }
         else if (String.isBlank(SelectedContact.FirstName)) {
            AllowSend = false;
            SendNotAllowedMessage = Label.AH_UDC_Send_Workbook_First_Name_Required;
         }
         else {
            GetProductList(); //Get available product list
            if (IsErrorOccurred == false) { //If error occurred in GetEnabledProductWorkbooks() then do not call other methods
               GetDefaultEmailTemplateDetails(); //Get default email template details to fill in the lookup field
            }
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred loading Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('Constructor', strErrorMessage, ex, null);
      }
      finally {
         externalUser = null;

         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   //Get available product list
   public void GetProductList() {
      Schema.DescribeFieldResult fieldResult = null;
      List<Schema.PicklistEntry> pickListEntry = null;
      try {
         WorkbookProducts = new List<SelectOption> ();
         fieldResult = AH_UDC_Workbook__c.Product__c.getDescribe();

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         if (fieldResult == null) {
            LogException('GetProductList', 'Metadata details not found for the field - Product__c', null, null);
            return;
         }

         pickListEntry = fieldResult.getPicklistValues();
         if (pickListEntry != null && pickListEntry.size() > 0) {
            WorkbookProducts.add(new SelectOption('', Label.AH_UDC_Send_Workbook_SelectProduct_Label));
            for (Schema.PicklistEntry option : pickListEntry) {
               WorkbookProducts.add(new SelectOption(option.getValue(), option.getLabel()));
            }
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred getting product list - Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetProductList', strErrorMessage, ex, null);
      }
   }

   //Get enabled workbook list for selected product
   public void GetEnabledProductWorkbooks() {
      Id workbookRecordTypeId = null;
      List<AH_UDC_Workbook__c> lstWorkbook = null;
      try {
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         EnabledProductWorkbooks = new List<SelectOption> ();
         workbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
         if (String.isNotBlank(String.valueOf(workbookRecordTypeId))) {
            EnabledProductWorkbooks.add(new SelectOption('', Label.AH_UDC_Send_Workbook_SelectWorkbook_Label));

            AggregateResult[] result = [SELECT Workbook__c, Workbook__r.Name WorkbookName, COUNT(Id) StepCount
                                        FROM AH_UDC_WorkbookStep__c
                                        WHERE Workbook__r.Product__c = :SelectedProduct
                                        AND Workbook__r.Enabled__c = true
                                        AND Workbook__r.RecordTypeId = :workbookRecordTypeId
                                        AND Enabled__c = true
                                        GROUP BY Workbook__c, Workbook__r.Name
                                        HAVING COUNT(Id) > 0];

            for (AggregateResult objWorkbook : result) {
               EnabledProductWorkbooks.add(new SelectOption((Id) objWorkbook.get('Workbook__c'), String.valueOf(objWorkbook.get('WorkbookName'))));
            }
         }
         else {
            LogException('GetEnabledProductWorkbooks', 'AH_UDC_Workbook Record Type No Found', null, null);
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred getting enable product workbook - Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetEnabledProductWorkbooks', strErrorMessage, ex, null);
      }
   }

   //Called by action function to set the Email Template for the selected workbook
   public void SetEmailTemplate(){
      AH_UDC_LogHelper.Debug('SetEmailTemplate - Start');
      if (String.isNotEmpty(SelectedWorkbook)){
         AH_UDC_LogHelper.Debug('SetEmailTemplate - SelectedWorkbookID: ' + SelectedWorkbook);
         List<AH_UDC_Workbook__c> workbooks = [SELECT Id, EmailTemplate__c from AH_UDC_Workbook__c where ID=:SelectedWorkbook and RecordType.DeveloperName = :AH_UDC_Constants.RECORD_TYPE_WORKBOOK];
         List<EmailTemplate> lstEmailTemplates = null;
         if(workbooks.size() ==0 || workbooks[0].EmailTemplate__c ==null)
         {
            AH_UDC_LogHelper.Debug('SetEmailTemplate - L2');
            lstEmailTemplates = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = :Label.AH_UDC_Send_Workbook_Default_Email_Template];
         }
         else {
            AH_UDC_LogHelper.Debug('SetEmailTemplate - L3');
            lstEmailTemplates = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = :workbooks[0].EmailTemplate__c];
         }
         SelectedEmailTemplateId = (lstEmailTemplates.size()!= 1? null : lstEmailTemplates[0].Id);
         SelectedEmailTemplateName = (lstEmailTemplates.size()!= 1? null : lstEmailTemplates[0].Name);
         AH_UDC_LogHelper.Debug('SetEmailTemplate - SelectedEmailTemplateId: ' + SelectedEmailTemplateId);
         AH_UDC_LogHelper.Debug('SetEmailTemplate - SelectedEmailTemplateName: ' +  SelectedEmailTemplateName);
      }
      AH_UDC_LogHelper.Debug('SetEmailTemplate - Stop');
   }

   //Get default email template details based on developer name
   public void GetDefaultEmailTemplateDetails() {
      List<EmailTemplate> lstEmailTemplates = null;
      try {
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         //Get default email template details from the object based on developer name
         lstEmailTemplates = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = :Label.AH_UDC_Send_Workbook_Default_Email_Template];

         if (lstEmailTemplates != null && lstEmailTemplates.size() > 0) {
            SelectedEmailTemplateId = lstEmailTemplates[0].Id;
            SelectedEmailTemplateName = lstEmailTemplates[0].Name;
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred getting Default Email Template Details - Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetDefaultEmailTemplateDetails', strErrorMessage, ex, null);
      }
   }

   //Create community users before sending workbooks
   public void CreateCommunityUsers() {
      try {
         //NOTE: This method calls DML executed against SETUP objects ... thus no other objects can be inserted (like Log Messages)
         AH_UDC_LogHelper.QueueLogs = true;

         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceSendWorkbookCreateCommunityUserException', FALSE, true)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'Send Workbook Create Community Users'));

         //Create the primary contact's Community User
         Boolean IsAllUsersCreated = true;
         if (ReleaseWorkbook) IsAllUsersCreated = AH_UDC_SharedWithoutSharing.SetupCommunityAccess(ContactId);

         //Create any other contact Community User's
         AH_UDC_LogHelper.Debug('CreateCommunityUsers-ContactLookupList: ' + ContactLookupList);
         AH_UDC_LogHelper.Debug('CreateCommunityUsers-ContactLookupList.size(): ' + ContactLookupList.size());
         if (ContactLookupList != null && ContactLookupList.size() > 0) {
            for (ContactLookupWrapper objContact : ContactLookupList) {
               if (String.isNotBlank(String.valueOf(objContact.Id)) && String.isBlank(objContact.ErrorMessage)) {
                  Boolean IsAddUserCreated = true;
                  if (ReleaseWorkbook) IsAddUserCreated = AH_UDC_SharedWithoutSharing.SetupCommunityAccess(objContact.Id);
                  AH_UDC_LogHelper.Debug('CreateCommunityUsers : IsAddUserCreated: ' + IsAddUserCreated);
                  if (!IsAddUserCreated) IsAllUsersCreated = false;
               }
            }
         }
         IsCommunityUserCreated = IsAllUsersCreated;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred creating community user - Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         System.debug('Exception occurred: ' + strErrorMessage);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'CreateCommunityUsers', strErrorMessage,
                              ex, null, null);
      }
      finally {
         //Write any queued log messages since it can't be written due to the SETUP DML above
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();

         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   //Create required objects like NIDoc, UDC contact , workbook, workbook step & property account etc
   public void SendWorkbook() {
      Id accountId = null;
      Id workbookId = null;

      Account accountData = null;
      AH_UDC_Contact__c objUDCContact = null;

      //Prepare database save point for rollback transaction BEFORE any records are inserted
      Savepoint objSavePoint = Database.setSavepoint();

      try {
         //Alert the user if sending workbooks is disabled; buttons will be hidden too
         String UDCSystemAdminPermissionSetName = AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetUDCSystemAdministrator', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN);
         Boolean isUDCSysAdmin = 0 < (Integer) [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :System.UserInfo.getUserId() AND PermissionSet.Name = :UDCSystemAdminPermissionSetName];

         if (!isUDCSysAdmin && !isSendWorkbookEnabled) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, AH_UDC_ConfigHelper.GetString('AH_UDC_SendWorkbookDisabledMessage', 'Send Workbook is currently disabled.')));
            return;
         }

         if (String.isBlank(SelectedWorkbook)) {
            LogException('SendWorkbook', 'Workbook not selected', null, null);
            return;
         }

         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestSendWorkbookError', FALSE, true)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'Send Workbook'));

         //The the account ID for the active contact
         accountId = SelectedContact.Account.Id;

         //Insert NI Doc record
         NewNIDocId = CreateNIDocRecord(accountId, objSavePoint);
         AH_UDC_LogHelper.Debug('SendWorkbook : NewNIDocId: ' + String.valueOf(NewNIDocId));
         if (IsErrorOccurred || String.isBlank(String.valueOf(NewNIDocId))) return; //CreateNIDocRecord() will show the Error to the user and the rollback will occur if it can't insert a record

         //Insert property account record and map with inserted NI Doc record - this must happen before creating the steps
         CreatePropertyAccountRecord(objSavePoint, accountId);
         AH_UDC_LogHelper.Debug('SendWorkbook : propertyAccountId: ' + String.valueOf(propertyAccountId));
         AH_UDC_LogHelper.Debug('SendWorkbook : IsErrorOccurred: ' + IsErrorOccurred);
         if (IsErrorOccurred) return; //CreatePropertyAccountRecord() will show the Error to the user and the rollback will occur if it can't insert a record

         //Insert Workbook Sent record
         workbookId = CreateWorkbookSentRecord(objSavePoint);
         AH_UDC_LogHelper.Debug('SendWorkbook : workbookId' + String.valueOf(workbookId));
         if (IsErrorOccurred || String.isBlank(String.valueOf(workbookId))) return; //CreateWorkbookSentRecord() will show the Error to the user and the rollback will occur if it can't insert a record

         //Insert Workbook Step Sent records
         CreateWorkbookStepSentRecord(objSavePoint, SelectedWorkbook, workbookId);
         AH_UDC_LogHelper.Debug('SendWorkbook : CreateWorkbookStepSentRecord - IsErrorOccurred: ' + IsErrorOccurred);
         //Do not proceed further if error occurred
         if (IsErrorOccurred) return; //CreateWorkbookStepSentRecord() will show the Error to the user and the rollback will occur if it can't insert a record

         CreateFollowForCurrentUser(objSavePoint);
         AH_UDC_LogHelper.Debug('SendWorkbook : CreateFollowForCurrentUser - IsErrorOccurred: ' + IsErrorOccurred);
         if (IsErrorOccurred) return; //CreateFollowForCurrentUser() will show the Error to the user and the rollback will occur if it can't insert a record

         //Create primary AH_UDC_Contact record
         CreateUDCContacts(objSavePoint);
         AH_UDC_LogHelper.Debug('SendWorkbook : CreateUDCContacts - IsErrorOccurred: ' + IsErrorOccurred);
         if (IsErrorOccurred) return; //CreateUDCContacts() will show the Error to the user and the rollback will occur if it can't insert a record

         //Send welcome email to all selected contacts
         if (ReleaseWorkbook){
            SendEmailToContacts();
         }
         if (!IsCommunityUserCreated) {
            //If there is an error in creating community users then display message to user 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, Label.AH_UDC_CreateCommunityUserErrorMessage));
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred send workbook page for user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('SendWorkbook', strErrorMessage, ex, objSavepoint);
      }
   }

   //Create NI Doc record based on values provided
   private Id CreateNIDocRecord(Id accountId, Savepoint objSavepoint) {
      Id NIDocRecordTypeId = null;
      NI_Documentation__c objNIDoc = null;
      try {
         //Get record type id to insert NI Doc record
         NIDocRecordTypeId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
         if (String.isBlank(String.valueOf(NIDocRecordTypeId))) {
            LogException('CreateNIDocRecord', 'AH_UDC_Workbook Record Type Not Found', null, null);
            return null;
         }

         objNIDoc = new NI_Documentation__c(RecordTypeId = NIDocRecordTypeId, Document_Name__c = NiDocumentName.trim(), Account__c = accountId, AH_UDC_WorkbookDueDate__c = DueDate, OwnerId = Userinfo.getUserId(), AH_UDC_ChatterWorkbookAccessed__c = IsUDCWorkbookAccessed, AH_UDC_ChatterWorkbookCompleted__c = IsUDCWorkbookCompleted, AH_UDC_ChatterWorkbookStepCompleted__c = IsUDCWorkbookStepCompleted);
         if (String.isNotBlank(ProjectId))
         objNIDoc.Project__c = ProjectId;
         AH_UDC_SystemContext.CreateObject(objNIDoc);
         return objNIDoc.Id;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred create NI Doc Record - send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CreateNIDocRecord', strErrorMessage, ex, objSavepoint);
         return null;
      }
   }

   //Create Workbook Sent record based on selected workbook
   private Id CreateWorkbookSentRecord(Savepoint objSavepoint) {
      Id workbookSentRecordTypeId = null;
      List<AH_UDC_Workbook__c> lstWorkbooks = null;
      List<AH_UDC_Workbook__c> lstParentWorkbooks = null;
      AH_UDC_Workbook__c objWorkbookClone = null;
      try {
         //Get record type id to insert NI Doc record
         workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
         if (String.isNotBlank(String.valueOf(workbookSentRecordTypeId))) {
            lstWorkbooks = [SELECT CompletedDate__c, Description__c, Enabled__c, Id, Name, OwnerId, Product__c, RecordTypeId,
                            RelatedToDocName__c, RelatedTo__c, SentDate__c,
                            SentStatus__c, StepsinOrder__c, CompletedBy__c, DueDate__c, ParentWorkbookSent__c, OriginalWorkbook__c,
                            Reminder1Enabled__c,Reminder1Days__c,Reminder1EmailTemplate__c,
                            Reminder2Enabled__c,Reminder2Days__c,Reminder2EmailTemplate__c,
                            Reminder3Enabled__c,Reminder3Days__c,Reminder3EmailTemplate__c,
                            Reminder4Enabled__c,Reminder4Days__c,Reminder4EmailTemplate__c
                            FROM AH_UDC_Workbook__c
                            WHERE Id = :SelectedWorkbook];

            if (lstWorkbooks != null && lstWorkbooks.size() > 0) {
               objWorkbookClone = lstWorkbooks[0].clone(false, false, false, false);
               //Set Email Template
               List<EmailTemplate> wbTemplates = [select Id, DeveloperName from EmailTemplate where ID = :SelectedEmailTemplateId];
               objWorkbookClone.EmailTemplate__c = wbTemplates[0].DeveloperName;
               //Setup Reminders
               objWorkbookClone.Reminder1Sent__c = null;
               objWorkbookClone.Reminder2Sent__c = null;
               objWorkbookClone.Reminder3Sent__c = null;
               objWorkbookClone.Reminder4Sent__c = null;
               List<String> ReminderEmailTemplates = new List<String>();
               if (String.isNotBlank(objWorkbookClone.Reminder1EmailTemplate__c)) ReminderEmailTemplates.add(objWorkbookClone.Reminder1EmailTemplate__c);
               if (String.isNotBlank(objWorkbookClone.Reminder2EmailTemplate__c)) ReminderEmailTemplates.add(objWorkbookClone.Reminder2EmailTemplate__c);
               if (String.isNotBlank(objWorkbookClone.Reminder3EmailTemplate__c)) ReminderEmailTemplates.add(objWorkbookClone.Reminder3EmailTemplate__c);
               if (String.isNotBlank(objWorkbookClone.Reminder4EmailTemplate__c)) ReminderEmailTemplates.add(objWorkbookClone.Reminder4EmailTemplate__c);
               List<EmailTemplate> templates = new List<EmailTemplate>();
               If (ReminderEmailTemplates.size() > 0) templates= [select id, DeveloperName from EmailTemplate where DeveloperName in :ReminderEmailTemplates];
               objWorkbookClone.Reminder1Enabled__c = checkReminderEnabled(objWorkbookClone.Reminder1Enabled__c,objWorkbookClone.Reminder1Days__c, objWorkbookClone.Reminder1EmailTemplate__c, DueDate, templates);
               objWorkbookClone.Reminder2Enabled__c = checkReminderEnabled(objWorkbookClone.Reminder2Enabled__c,objWorkbookClone.Reminder2Days__c, objWorkbookClone.Reminder2EmailTemplate__c, DueDate, templates);
               objWorkbookClone.Reminder3Enabled__c = checkReminderEnabled(objWorkbookClone.Reminder3Enabled__c,objWorkbookClone.Reminder3Days__c, objWorkbookClone.Reminder3EmailTemplate__c, DueDate, templates);
               objWorkbookClone.Reminder4Enabled__c = checkReminderEnabled(objWorkbookClone.Reminder4Enabled__c,objWorkbookClone.Reminder4Days__c, objWorkbookClone.Reminder4EmailTemplate__c, DueDate, templates);
               objWorkbookClone.RecordTypeId = workbookSentRecordTypeId;
               objWorkbookClone.RelatedTo__c = NewNIDocId;
               if (ReleaseWorkbook) objWorkbookClone.Released__c = true;
               objWorkbookClone.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
               objWorkbookClone.SentDate__c = Datetime.now();
               objWorkbookClone.CompletedDate__c = null;
               objWorkbookClone.CompletedBy__c = null;
               objWorkbookClone.OwnerId = UserInfo.getUserId();
               objWorkbookClone.SecurityCode__c = AH_UDC_Shared.GetSecurityCode(); //Security Code for each Workbook Sent must be unique
               objWorkbookClone.OriginalWorkbook__c = SelectedWorkbook;
               AH_UDC_LogHelper.Debug('CreateWorkbookSentRecord => IsCopyWorkbook: ' + IsCopyWorkbook);
               if (IsCopyWorkbook == false && String.isNotBlank(String.valueOf(SelectedNIDocIdNew))) { //If parent Workbook NI Doc is selected then set value in the field
                  lstParentWorkbooks = [SELECT Id
                                          FROM AH_UDC_Workbook__c
                                          WHERE RelatedTo__c = :SelectedNIDocIdNew];
                  if (lstParentWorkbooks != null && lstParentWorkbooks.size() > 0) {
                     objWorkbookClone.ParentWorkbookSent__c = lstParentWorkbooks[0].Id;
                  }
                  else {
                     LogException('CreateWorkbookSentRecord', 'Selected NI Doc record do not workbook associated', null, objSavepoint);
                  }
               }
               if (objWorkbookClone != null) {
                  AH_UDC_SystemContext.CreateObject(objWorkbookClone);
                  return objWorkbookClone.Id;
               }
               return '';
            }
            else {
               LogException('CreateWorkbookSentRecord', 'Selected Workbook Record Not Found', null, objSavepoint);
               return '';
            }
         }
         else {
            LogException('CreateWorkbookSentRecord', 'AH_UDC_Workbook Record Type Not Found', null, objSavepoint);
            return '';
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CreateWorkbookSentRecord', strErrorMessage, ex, objSavepoint);
         return objWorkbookClone != null ? objWorkbookClone.Id : '';
      }
   }

   //Determine if Reminder on Sent Workbook should be enabled
   private Boolean checkReminderEnabled(Boolean ReminderEnabled, Decimal ReminderDays, string ReminderEmailTemplate, Date wbDueDate, List<EmailTemplate> templates)
   {
      if (!ReminderEnabled || ReminderDays ==null || wbDueDate == null) return false;
      //Determine if template is specified and valid
      if (String.isEmpty(ReminderEmailTemplate)) return false;
      Boolean isValidTemplate = false;
      for(EmailTemplate et : templates)
      {
         if(et.DeveloperName == ReminderEmailTemplate) {
            isValidTemplate = true;
            break;
         }
      }
      if (!isValidTemplate) return false;
      if (ReminderDays > -1)
      {
         If ((system.today()).daysBetween(Date.valueOf(wbDueDate)) > ReminderDays) return true;
      }
      else
      {
         If ((system.today()).daysBetween(Date.valueOf(wbDueDate)) > ReminderDays) return true;
      }
      return false;
   }

   //Create Workboook Step Sent record based on values provided
   private void CreateWorkbookStepSentRecord(Savepoint objSavepoint, Id originalWorkbookId, Id newWorkbookId) {
      try {
         //Get record type id to insert Workboook Step Sent record
         Id workbookStepSentRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
         Id workbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
         if (String.isBlank(String.valueOf(workbookStepSentRecordTypeId)) || String.isBlank(String.valueOf(workbookStepRecordTypeId))) {
            LogException('CreateWorkbookStepSentRecord', 'AH_UDC_WorkbookStep Or AH_UDC_WorkbookStepSent Record Type Not Found', null, objSavepoint);
            return;
         }
         
         List<AH_UDC_WorkbookStep__c> lstNewWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ();
         Map<Decimal, Decimal> stepSortOrderMapPrereq = new Map<Decimal, Decimal> (); //It will hold sort order along with sort order of it's prequisite step
         List<AH_UDC_WorkbookStep__c> lstOriginalWorkbookSteps = [SELECT Id, Name, CurrencyIsoCode, Description__c, Enabled__c, Form__c, Help__c, Prerequisite_Step__c,
                                                                  RecordTypeId, SortOrder__c, StepCompleted__c, StepStatus__c, URL__c, StepCompletedBy__c, Workbook__c,
                                                                  Form__r.FormType__c, Form__r.CopyResponseWhenSendingNew__c
                                                                  FROM AH_UDC_WorkbookStep__c
                                                                  WHERE Workbook__c = :originalWorkbookId AND RecordTypeId = :workbookStepRecordTypeId
                                                                  AND Enabled__c = true //Only Copy enabled steps to Sent Workbook
                                                                  ORDER BY SortOrder__c];
         AH_UDC_LogHelper.Debug('CreateWorkbookStepSentRecord => Total Steps to be created: ' + lstOriginalWorkbookSteps.size());
         Map<Id, Decimal> stepIdSortOrderMap = new Map<Id, Decimal> (); //It will hold StepId and it's Sort Order
         for (AH_UDC_WorkbookStep__c objOriginalStep : lstOriginalWorkbookSteps) {
            AH_UDC_WorkbookStep__c objNewStep = objOriginalStep.clone(false, false, false, false);
            objNewStep.RecordTypeId = workbookStepSentRecordTypeId;
            objNewStep.Workbook__c = newWorkbookId;
            objNewStep.StepStatus__c = AH_UDC_Constants.STEP_STATUS_NEW;
            objNewStep.StepCompleted__c = null;
            objNewStep.StepCompletedBy__c = null;
            objNewStep.CreatedById = UserInfo.getUserId();
            objNewStep.CreatedDate = DateTime.now();
            objNewStep.LastModifiedById = UserInfo.getUserId();
            objNewStep.LastModifiedDate = DateTime.now();
            if (String.isNotBlank(objOriginalStep.Prerequisite_Step__c)) {
               objNewStep.Prerequisite_Step__c = null;
               stepSortOrderMapPrereq.put(objOriginalStep.SortOrder__c, stepIdSortOrderMap.get(objOriginalStep.Prerequisite_Step__c));
            }
            stepIdSortOrderMap.put(objOriginalStep.Id, objOriginalStep.SortOrder__c);
            lstNewWorkbookSteps.add(objNewStep);
         }

         if (lstNewWorkbookSteps != null && lstNewWorkbookSteps.size() > 0) {
            AH_UDC_LogHelper.Debug('CreateWorkbookStepSentRecord => lstNewWorkbookSteps.size(): ' + lstNewWorkbookSteps.size());
            AH_UDC_SystemContext.CreateObjects(lstNewWorkbookSteps);

            //Map of SortOrder and StepId for which copy of form responses is pending
            Map<Decimal, Id> mapNewInsertedStepIdAndSortOrder = new Map<Decimal, Id> ();
            Map<Id, Id> mapNewInsertedStepIdAndFormId = new Map<Id, Id> ();
            for (AH_UDC_WorkbookStep__c objInsertedStep : lstNewWorkbookSteps) {
               if(String.isNotBlank(String.valueOf(objInsertedStep.Form__c)))
                  mapNewInsertedStepIdAndFormId.put(objInsertedStep.Form__c, objInsertedStep.Id);
               mapNewInsertedStepIdAndSortOrder.put(objInsertedStep.SortOrder__c, objInsertedStep.Id);
               if (stepSortOrderMapPrereq.containsKey(objInsertedStep.SortOrder__c)) {
                  Decimal sortOrderOfPrereqStep = stepSortOrderMapPrereq.get(objInsertedStep.SortOrder__c);
                  //Get prerequisite stepid based on it's sort order
                  objInsertedStep.Prerequisite_Step__c = mapNewInsertedStepIdAndSortOrder.get(sortOrderOfPrereqStep);
               }
            }

            AH_UDC_LogHelper.Debug('CreateWorkbookStepSentRecord => mapNewInsertedStepIdAndSortOrder: ' + mapNewInsertedStepIdAndSortOrder);
            AH_UDC_LogHelper.Debug('CreateWorkbookStepSentRecord => stepSortOrderMapPrereq: ' + stepSortOrderMapPrereq);
            if (stepSortOrderMapPrereq != null && stepSortOrderMapPrereq.size() > 0) {
               //Update inserted steps to set prerequisite step
               AH_UDC_SystemContext.UpdateObjects(lstNewWorkbookSteps);
            }

            //Copy responses for new inserted steps
            CopyStepResponses(objSavepoint, lstOriginalWorkbookSteps, mapNewInsertedStepIdAndFormId);
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CreateWorkbookStepSentRecord', strErrorMessage, ex, objSavepoint);
      }
   }

   //Insert responses into junction object AH_UDC_WorkbookStepResponse__c
   private void CopyStepResponses(Savepoint objSavepoint, List<AH_UDC_WorkbookStep__c> lstOriginalWorkbookSteps, Map<Id, Id> mapNewInsertedStepIdAndFormId) {
      try {
         //Determine which forms are Shared/Central, or product form, where CopyResponseWhenSendingNew__c checkbox is checked
         Set<Id> formIdsToCopyResponses = new Set<Id> ();
         Set<Id> formIdsWithProductTypeWithoutCopyData = new Set<Id> ();
         for (AH_UDC_WorkbookStep__c wbStep : lstOriginalWorkbookSteps) {
            if(String.isBlank(String.valueOf(wbStep.Form__c)))
               continue;

            if (wbStep.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_CENTRAL
                || wbStep.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_SHARED
                || wbStep.Form__r.CopyResponseWhenSendingNew__c) {
               formIdsToCopyResponses.add(wbStep.Form__c);
            }
            else {
               //Create list of forms with product type to copy responses from workbook sent record
               formIdsWithProductTypeWithoutCopyData.add(wbStep.Form__c);
            }
         }
         AH_UDC_LogHelper.Debug('CopyStepResponses : formIdsToCopyResponses: ' + formIdsToCopyResponses);
         AH_UDC_LogHelper.Debug('CopyStepResponses : propertyAccountId: ' + propertyAccountId);

         List<AH_UDC_WorkbookStepResponse__c> lstStepResponses = new List<AH_UDC_WorkbookStepResponse__c> ();

         // Has the Form IDs of all the Step Responses that are already in lstStepResponses, so that we can filter
         // out the ones that have already been added to the list of responses that are to be copied when
         // performing the query on ProductFormResponses
         List<Id> lstIdOfFormWithStepResponsesBeingCopied = new List<Id> ();

         if (formIdsToCopyResponses.size() > 0) {
            //Get shared & central forms responses as well as product form responses if checkbox CopyResponseWhenSendingNew__c is checked
            AggregateResult[] groupedResults = [SELECT WorkbookStep__r.Form__c FormId, max(Response__c) maxResponseId
                                                FROM AH_UDC_WorkbookStepResponse__c
                                                WHERE WorkbookStep__r.Form__c IN :formIdsToCopyResponses
                                                AND IsMostRecentResponse__c = true
                                                AND WorkbookStep__r.Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c = :propertyAccountId
                                                GROUP BY WorkbookStep__r.Form__c];

            for (AggregateResult result : groupedResults) {
               Id formId = (Id) result.get('FormId');
               Id responseId = (Id) result.get('maxResponseId');
               if (mapNewInsertedStepIdAndFormId.containsKey(formId)) {
                  lstIdOfFormWithStepResponsesBeingCopied.add(formId);
                  lstStepResponses.add(new AH_UDC_WorkbookStepResponse__c(WorkbookStep__c = mapNewInsertedStepIdAndFormId.get(formId),
                                                                          Response__c = responseId));
               }
            }
            AH_UDC_LogHelper.Debug('CopyStepResponses : lstStepResponses.size() - Shared & Central Forms: ' + lstStepResponses.size());
         }

         if (IsCopyWorkbook && formIdsWithProductTypeWithoutCopyData.size() > 0) {
            //For copy workbook option get responses of product forms
            List<AH_UDC_WorkbookStepResponse__c> lstProductFormResponses = [SELECT WorkbookStep__c, WorkbookStep__r.SortOrder__c, Response__c, WorkbookStep__r.Form__c
                                                                            FROM AH_UDC_WorkbookStepResponse__c
                                                                            WHERE WorkbookStep__r.Form__c IN :formIdsWithProductTypeWithoutCopyData
                                                                            AND WorkbookStep__r.Workbook__r.RelatedTo__c = :SelectedNIDocIdCopy
                                                                            AND IsMostRecentResponse__c = true
                                                                            AND WorkbookStep__r.Form__r.FormType__c = :AH_UDC_Constants.FORM_TYPE_PRODUCT];

            AH_UDC_LogHelper.Debug('CopyStepResponses : lstProductFormResponses.size(): ' + lstProductFormResponses.size());
            for (AH_UDC_WorkbookStepResponse__c objStepResp : lstProductFormResponses) {
               if (mapNewInsertedStepIdAndFormId.containsKey(objStepResp.WorkbookStep__r.Form__c)) {
                  lstIdOfFormWithStepResponsesBeingCopied.add(objStepResp.WorkbookStep__r.Form__c);
                  lstStepResponses.add(new AH_UDC_WorkbookStepResponse__c(WorkbookStep__c = mapNewInsertedStepIdAndFormId.get(objStepResp.WorkbookStep__r.Form__c),
                                                                          Response__c = objStepResp.Response__c));
               }
            }
            AH_UDC_LogHelper.Debug('CopyStepResponses : lstStepResponses.size() - After adding product form responses: ' + lstStepResponses.size());
         }

         //This will copy the default responses
         if (lstStepResponses.size() != lstOriginalWorkbookSteps.size())
         {
            List<AH_UDC_WorkbookStepResponse__c> lstDefaultResponses = [SELECT WorkbookStep__c, WorkbookStep__r.SortOrder__c, Response__c, WorkbookStep__r.Form__c
                                                                        FROM AH_UDC_WorkbookStepResponse__c
                                                                        WHERE WorkbookStep__c IN :lstOriginalWorkbookSteps
                                                                        AND WorkbookStep__r.Form__c NOT IN :lstIdOfFormWithStepResponsesBeingCopied
                                                                        AND IsMostRecentResponse__c = true
                                                                        AND(WorkbookStep__r.Form__r.FormType__c = :AH_UDC_Constants.FORM_TYPE_PRODUCT OR
                                                                            WorkbookStep__r.Form__r.FormType__c = :AH_UDC_Constants.FORM_TYPE_SHARED)];

            AH_UDC_LogHelper.Debug('DefaultStepResponses : lstDefaultResponses.size(): ' + lstDefaultResponses.size());
            for (AH_UDC_WorkbookStepResponse__c objStepResp : lstDefaultResponses) {
               if (mapNewInsertedStepIdAndFormId.containsKey(objStepResp.WorkbookStep__r.Form__c)) {
                  lstStepResponses.add(new AH_UDC_WorkbookStepResponse__c(WorkbookStep__c = mapNewInsertedStepIdAndFormId.get(objStepResp.WorkbookStep__r.Form__c),
                                                                          Response__c = objStepResp.Response__c));
               }
            }
            AH_UDC_LogHelper.Debug('CopyStepResponses : lstStepResponses.size() - After adding default responses: ' + lstStepResponses.size());
         }

         if (lstStepResponses.size() > 0) {
            //Insert records into the object AH_UDC_WorkbookStepResponse__c
            AH_UDC_SystemContext.CreateObjects(lstStepResponses);
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CopyStepResponses', strErrorMessage, ex, objSavepoint);
      }
   }

   //Create Property Account record based on values provided
   private Id CreatePropertyAccountRecord(Savepoint objSavepoint, Id accountId) {
      AH_UDC_LogHelper.Debug('CreatePropertyAccountRecord : accountId: ' + accountId);

      List<AH_UDC_PropertyAccount__c> lstPropertyAccounts = null;
      NI_Documentation__c objNIDoc = null;
      List<Account> lstAccounts = null;
      AH_UDC_PropertyAccount__c objPropertyaccount = null;
      propertyAccountId = null;
      try {
         if (String.isNotBlank(String.valueOf(accountId))) {
            lstPropertyAccounts = [SELECT Id
                                   FROM AH_UDC_PropertyAccount__c
                                   WHERE Account__r.Id = :accountId];
            if (lstPropertyAccounts.size() > 0) {
               //Map inserted NI Doc record with existing property account record
               propertyAccountId = lstPropertyAccounts[0].Id;
            }
            else {
               //Get details of selected account from the object and use them to create AH_UDC_PropertyAccount record
               lstAccounts = [SELECT Id, Name,
                              ShippingStreet, ShippingState, ShippingCity, ShippingPostalCode, ShippingCountry,
                              BillingStreet, BillingState, BillingCity, BillingPostalCode, BillingCountry, Phone
                              FROM Account
                              WHERE Id = :accountId];
               if (lstAccounts.size() > 0) {
                  objPropertyaccount = new AH_UDC_PropertyAccount__c(
                                                                     Account__c = lstAccounts[0].Id,
                                                                     PropertyName__c = lstAccounts[0].Name,
                                                                     Address__c = (String.isNotBlank(lstAccounts[0].ShippingStreet) ? lstAccounts[0].ShippingStreet : lstAccounts[0].BillingStreet),
                                                                     City__c = (String.isNotBlank(lstAccounts[0].ShippingCity) ? lstAccounts[0].ShippingCity : lstAccounts[0].BillingCity),
                                                                     StateProvince__c = (String.isNotBlank(lstAccounts[0].ShippingState) ? lstAccounts[0].ShippingState : lstAccounts[0].BillingState),
                                                                     PostalCode__c = (String.isNotBlank(lstAccounts[0].ShippingPostalCode) ? lstAccounts[0].ShippingPostalCode : lstAccounts[0].BillingPostalCode),
                                                                     Country__c = (String.isNotBlank(lstAccounts[0].ShippingCountry) ? lstAccounts[0].ShippingCountry : lstAccounts[0].BillingCountry),
                                                                     Phone__c = lstAccounts[0].Phone,
                                                                     OwnerId = Userinfo.getUserId());
                  AH_UDC_SystemContext.CreateObject(objPropertyaccount);
                  propertyAccountId = objPropertyaccount.Id;
               }
               else {
                  LogException('CreatePropertyAccountRecord', 'Account details not found', null, objSavepoint);
                  return '';
               }
            }
         }
         else { //If account not selected then create property account record with empty field values
            objPropertyAccount = new AH_UDC_PropertyAccount__c(
                                                               Address__c = '',
                                                               City__c = '',
                                                               StateProvince__c = '',
                                                               PostalCode__c = '',
                                                               Country__c = '',
                                                               Phone__c = '');
            AH_UDC_SystemContext.CreateObject(objPropertyAccount);
            propertyAccountId = objPropertyAccount.Id;
         }
         AH_UDC_LogHelper.Debug('CreatePropertyAccountRecord : objPropertyAccount: ' + objPropertyAccount);

         if (String.isBlank(propertyAccountId)) {
            LogException('CreatePropertyAccountRecord', 'Property Account record not inserted', null, objSavepoint);
            return '';
         }

         //Update the already created NIDoc with the AH_UDC_PropertyAccount record id
         objNIDoc = new NI_Documentation__c(
                                            Id = NewNIDocId,
                                            AH_UDC_PropertyAccount__c = propertyAccountId);
         AH_UDC_Security.UpdateObject(objNIDoc);

         AH_UDC_LogHelper.Debug('CreatePropertyAccountRecord : propertyAccountId :' + propertyAccountId);
         return propertyAccountId;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred in  Create Property Account Record - send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CreatePropertyAccountRecord', strErrorMessage, ex, objSavepoint);
         return propertyAccountId;
      }
   }

   //Create a Follow for the current user on the NI Document
   private void CreateFollowForCurrentUser(Savepoint objSavepoint) {
      try {
         //TODO:ROBDEV fix with MOCK
         if (!Test.isRunningTest()) ConnectApi.Subscription subscriptionToRecord = ConnectApi.ChatterUsers.follow(null, Userinfo.getUserId(), NewNIDocId);
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred creating a Follow for user Id (' + Userinfo.getUserId() + ') NIDocument Id (' + NewNIDocId + ') : ' + ex.getMessage();
         if (Test.isRunningTest()) {
            //Can not set IsErrorOccurred = true for test class because of following error, so directly calling LogException method of log helper class
            //System.UnsupportedOperationException: ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true)
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC, LogFunctionalArea, 'CreateFollowForCurrentUser', strErrorMessage, ex, null, null);
         } else {
            LogException('CreateFollowForCurrentUser', strErrorMessage, ex, objSavepoint);
         }
         return;
      }
   }

   //Create AH_UDC_Contact records
   private void CreateUDCContacts(Savepoint objSavepoint) {
      try {
         List<AH_UDC_Contact__c> lstUDCContact = new List<AH_UDC_Contact__c> ();

         //Add the primary UDC Contact
         lstUDCContact.add(new AH_UDC_Contact__c(Contact__c = ContactId, Document__c = NewNIDocId));

         //Add any additional UDC Contacts
         if (ContactLookupList != null && ContactLookupList.size() > 0) {
            AH_UDC_LogHelper.Debug('SendWorkbook : CreateUDCContacts - ContactLookupList.size(): ' + ContactLookupList.size());

            for (ContactLookupWrapper objContact : ContactLookupList) {
               if (String.isNotBlank(String.valueOf(objContact.Id)) && String.isBlank(objContact.ErrorMessage)) {
                  lstUDCContact.add(new AH_UDC_Contact__c(Contact__c = objContact.Id, Document__c = NewNIDocId));
               }
            }
         }

         //Insert the UDC contact records
         if (lstUDCContact.size() > 0) {
            AH_UDC_SystemContext.CreateObjects(lstUDCContact);
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred creating UDC Contacts: ' + ex.getMessage();
         LogException('CreateUDCContacts', strErrorMessage, ex, objSavepoint);
         return;
      }
   }

   //Send email to contact after sending workbook
   @TestVisible private void SendEmailToContacts() {
      try {
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         if (SelectedContact != null && String.isNotBlank(SelectedContact.Email) && String.isNotBlank(String.valueOf(NewNIDocId))) {
            List<Contact> sendContacts = new List<Contact> ();
            sendContacts.add(SelectedContact); //Prepare to email addresses list            

            if (ContactLookupList != null && ContactLookupList.size() > 0) {
               List<Contact> lstContactIds = new List<Contact> ();
               for (ContactLookupWrapper objUDCContact : ContactLookupList) {
                  if (String.isNotBlank(String.valueOf(objUDCContact.Id)) && String.isBlank(objUDCContact.ErrorMessage)) {
                     //Prepare Contact id list to pass in query for getting contact email addresses
                     lstContactIds.add(new Contact(Id = objUDCContact.Id));
                  }
               }
               if (lstContactIds.size() > 0) {
                  for (Contact objContact :[SELECT Email FROM Contact WHERE Id IN :lstContactIds]) {
                     if (String.isNotBlank(objContact.Email)) {
                        sendContacts.add(objContact); //Add additional contact's email in to email addresses list
                     }
                  }
               }
            }

            Boolean IsEmailSent = AH_UDC_SharedWithoutSharing.SendEmailToContacts(LogFunctionalArea, sendContacts, SelectedEmailTemplateId, NewNIDocId, null);
            if (IsEmailSent) {
               AH_UDC_LogHelper.Debug('Email has been sent successfully.');
            }
            else {
               IsErrorOccurred = true;
               SendEmailFailed = true;
            }
         }
      }
      catch(Exception ex) {
         IsErrorOccurred = true;

         String strErrorMessage = 'An exception occurred while sending email to the contact - Logged-In User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, 'SendEmailToContacts', strErrorMessage, Label.AH_UDC_Send_Email_Error_Message, ex);
      }
   }

   //Add new contact lookup on click of Add Contact button
   public void AddContactLookup() {
      if (ContactLookupList.size() >= AddContactLimit) return;

      ContactLookupWrapper objContact = null;
      try {
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         objContact = new ContactLookupWrapper();
         objContact.ErrorMessage = '';
         objContact.Index = ContactLookupList != null && ContactLookupList.size() > 0 ? ContactLookupList.size() : 0;
         ContactLookupList.add(objContact);
         AH_UDC_LogHelper.Debug('ContactLookupList ' + ContactLookupList);
      }
      catch(Exception ex) {
         String strErrorMessage = System.Label.AH_UDC_Send_Email_Error_Message + '- Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('AddContactLookup', strErrorMessage, ex, null);
      }
   }

   //Check Contact has external User or not   
   public void ValidateContact() {
      Integer lookupIndex = 0;
      Map<Id, Contact> userContactMap = null;
      Set<Id> contactIDList = null;
      try {
         AH_UDC_LogHelper.Debug('ValidateContact : SelectedContactId: ' + SelectedContactId);
         AH_UDC_LogHelper.Debug('ValidateContact : ContactLookupList: ' + ContactLookupList);
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         contactIDList = new Set<Id> ();
         for (ContactLookupWrapper CLW : ContactLookupList) {
            contactIDList.add(CLW.Id);
         }

         if (contactIDList != null && contactIDList.size() > 0) {
            userContactMap = new Map<ID, Contact> ([SELECT Id, Email
                                                   FROM Contact
                                                   WHERE Id IN :contactIDList]);
         }

         for (Integer index = 0; index<ContactLookupList.size(); index++) {
            ContactLookupWrapper objContact = ContactLookupList[index];
            if (String.isNotBlank(objContact.Id)) {

               if (userContactMap != null && userContactMap.size()> 0) {
                  SelectedUserEmail = userContactMap.get(objContact.Id).Email;
               }

               if (String.isBlank(SelectedUserEmail)) {
                  SetErrorMessageForSelectedContact(index, Label.AH_UDC_Send_Workbook_Additional_Contact_Email_Required_Message);
               } else if (ContactId.equals(objContact.Id) || IsContactAlreadySelected(index, objContact.Id)) {
                  SetErrorMessageForSelectedContact(index, Label.AH_UDC_Duplicate_Contact_Added_For_Send_Workbook_Message);
               } else {
                  //Remove error message if no error found
                  SetErrorMessageForSelectedContact(index, '');
               }
            } else {
               //Remove error message if contact value removed from lookup field or incorrect contact name text entered                        
               SetErrorMessageForSelectedContact(index, '');
            }
         }
         AH_UDC_LogHelper.Debug('ValidateContact : ContactLookupList: ' + ContactLookupList);
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred Validate Contact - send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('ValidateContact', strErrorMessage, ex, null);
      }
   }

   //Check if same contact selected more that once     
   private Boolean IsContactAlreadySelected(Integer lookupIndex, Id ContactId) {
      Integer duplicateCount = 0;
      for (Integer index = 0; index<ContactLookupList.size(); index++) {
         ContactLookupWrapper objContact = ContactLookupList[index];

         if (String.isNotBlank(ContactId) && index != lookupIndex && objContact.Id == ContactId) {
            duplicateCount++;
         }
      }
      return duplicateCount> 0;
   }

   //Set error message for selected contactgg
   private void SetErrorMessageForSelectedContact(Integer lookupIndex, String strMessage) {
      if (ContactLookupList != null && ContactLookupList.size() >= lookupIndex) {
         ContactLookupList[lookupIndex].ErrorMessage = strMessage;
      }
   }

   //Get workbook sent record deatils based on NI Doc Id
   public void GetWorkbookSentDetails() {
      Id NIDocIDForWorkbook = null;
      List<AH_UDC_Workbook__c> lstCopyWorkbookSent = null;
      try {
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         if (IsCopyWorkbook) {
            NIDocIDForWorkbook = SelectedNIDocIdCopy;
         }
         else {
            NIDocIDForWorkbook = SelectedNIDocIdNew;
         }

         if (String.isNotBlank(String.valueOf(NIDocIDForWorkbook))) {
            lstCopyWorkbookSent = [SELECT Id, Name, OriginalWorkbook__c, OriginalWorkbook__r.Name, OriginalWorkbook__r.Product__c, RelatedTo__r.Account__c, RelatedTo__r.AH_UDC_WorkbookDueDate__c, ParentWorkbookSent__r.Name,
                                   RelatedTo__r.AH_UDC_ChatterWorkbookAccessed__c, RelatedTo__r.AH_UDC_ChatterWorkbookCompleted__c, RelatedTo__r.AH_UDC_ChatterWorkbookStepCompleted__c
                                   FROM AH_UDC_Workbook__c
                                   WHERE RelatedTo__c = :NIDocIDForWorkbook];
            AH_UDC_LogHelper.Debug('GetWorkbookSentDetails => lstCopyWorkbookSent: ' + lstCopyWorkbookSent);
            if (lstCopyWorkbookSent != null && lstCopyWorkbookSent.size() > 0) {
               ParentWorkbookName = lstCopyWorkbookSent[0].ParentWorkbookSent__r.Name;
               m_niDoc.AH_UDC_WorkbookDueDate__c = lstCopyWorkbookSent[0].RelatedTo__r.AH_UDC_WorkbookDueDate__c;
               SelectedProduct = lstCopyWorkbookSent[0].OriginalWorkbook__r.Product__c;
               SelectedWorkbook = lstCopyWorkbookSent[0].OriginalWorkbook__c;
               IsUDCWorkbookCompleted = true;
               EnabledProductWorkbooks = new List<SelectOption> ();
               EnabledProductWorkbooks.add(new SelectOption(lstCopyWorkbookSent[0].OriginalWorkbook__c, lstCopyWorkbookSent[0].OriginalWorkbook__r.Name));
            }
         }
         else {
            m_niDoc.AH_UDC_WorkbookDueDate__c = null;
            SelectedProduct = null;
            SelectedWorkbook = null;
            SelectedContact.AccountId = null;
            EnabledProductWorkbooks = new List<SelectOption> ();
         }
      }
      catch(Exception ex) {
         AH_UDC_LogHelper.Debug('Error occurred in the method GetWorkbookSentDetails. ' + ex.getMessage() + ' at line number ' + ex.getLineNumber());
         String strErrorMessage = 'An exception occurred Get Workbook Sent Details - send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetWorkbookSentDetails', strErrorMessage, ex, null);
      }
      finally {
         lstCopyWorkbookSent = null;
      }
   }

   //Log exception and display error message to user
   private void LogException(String strMethodName, String strErrorMessage, Exception exc, Savepoint objSavepoint) {
      IsErrorOccurred = true;
      AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, strMethodName, strErrorMessage, System.Label.AH_UDC_Common_Error_Message_Backend, exc, objSavepoint);
   }

   //This method is used by a client side actionfunction to log AH_UDC_Log entries that couldn't be created by the page load due to SOQL DML retrictions
   public void ServerLogMessages() {
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages');
      try {
         if (PageLoadLogMessages != null && PageLoadLogMessages.size() > 0) {
            insert(PageLoadLogMessages);
         }
         PageLoadLogMessages = new List<AH_UDC_Log__c> ();

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
      }
      catch(Exception ex) {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages - Exception: ' + ex);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'ServerLogMessages',
                              'An exception occurred logging Page Load AH_UDC_Log entries',
                              ex, null, null);
      }
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
/***********************************************************************************************
  Name            : AH_UDC_SendWorkbook
  Author          : Umang Ankleshwaria
  Created Date    : 22-Jan-2021
  Last Mod Date   : 08-Fab-2021
  Last Mod By     : Umang Ankleshwaria
  NICC Reference  : 
  Description     : Controller class for UDC SendWorkbook page of UDC 
  Change History  :
  1. 590043 - Refactoring Code - Changed by Umang Ankleshwaria on 8-Feb-2021
  2. 594855 - Refactoring Code - Changed by Tushar Gupta on 23-Feb-2021
 ************************************************************************************************/
public with sharing class AH_UDC_SendWorkbook {

   // In v30 and higher (at least through v52) Salesforce broke use of the standard datepicker that is rendered using code like this:
   //
   // <apex:inputText id="dueDateinput" label="Workbook Due Date" value="{!DueDate}"
   //                 onfocus="DatePicker.pickDate(false, 'SendWorkbookPage:frmSendWorkbook:pbSendWorkbook:dueDateinput', false);"
   //                 html-autocomplete="off" />
   //
   // The date picker will not render unless there is at least on <apex:inputField> reference to a date field on the page.
   //
   // This NI_Documentation__c instance is used to put a hidden div on the page that will cause SF to load the required JS
   // necessary for rendering the DatePicker
   private NI_Documentation__c m_niDoc = new NI_Documentation__c();
   public NI_Documentation__c bugfix_niDoc { get { return m_niDoc; } set { m_niDoc = value; } }
   public Date DueDate { get { return bugfix_niDoc.AH_UDC_WorkbookDueDate__c; } set { bugfix_niDoc.AH_UDC_WorkbookDueDate__c = value; } }

   public String SelectedProduct { get; set; }
   public Boolean ProductSelected { get { return false; } set; }
   public Boolean IsCommunityUserCreated { get; set; } { IsCommunityUserCreated = false; }
   public Boolean IsCopyWorkbook { get; set; } // This is for New UDC Copy Exisiting Workbook  
   public Boolean IsUDCWorkbookAccessed { get; set; } { IsUDCWorkbookAccessed = AH_UDC_ConfigHelper.GetBoolean('AH_UDC_WorkbookAccessedDefaultValue', false); } //This is for Workbook Accessed  status flags
   public Boolean IsUDCWorkbookCompleted { get; set; } { IsUDCWorkbookCompleted = AH_UDC_ConfigHelper.GetBoolean('AH_UDC_WorkbookCompletedDefaultValue', false); } //This is for Workbook Completed status flags
   public Boolean IsUDCWorkbookStepCompleted { get; set; } { IsUDCWorkbookStepCompleted = AH_UDC_ConfigHelper.GetBoolean('AH_UDC_WorkbookStepCompletedDefaultValue', false); } //This is for Workbook Step Completed status flags
   public String SelectedWorkbook { get; set; }
   public String NiDocumentName { get; set; }
   public String CurrentUserDateSeparator { get { return AH_UDC_DateFormat.DateSeparator(); } }
   public String CurrentUserDateFormatString { get { return AH_UDC_DateFormat.DateFormatString(); } }
   public Id SelectedEmailTemplateId { get; set; }
   public String SelectedEmailTemplateName { get; set; }
   public List<SelectOption> WorkbookProducts { get; set; }
   public List<SelectOption> EnabledProductWorkbooks { get; set; }
   public Contact SelectedContact { get; set; }
   public Id SelectedNIDocIdCopy { get; set; }
   public Id SelectedNIDocIdNew { get; set; }
   public String ParentWorkbookName { get; set; }
   public Id ContactId { get; set; }
   public Id ProjectId { get; set; }
   public String ProjectName { get; set; }
   public Id NewNIDocId { get; set; } //New inserted NI Doc Id
   public Boolean IsErrorOccurred { get; set; } { IsErrorOccurred = false; } //To display error on page 
   public Boolean SendEmailFailed { get; set; } //It will be true only if error occurred while sending an email
   public String UserLocale { get; set; }
   public Id SelectedContactId { get; set; }
   public List<ContactLookupWrapper> ContactLookupList { get; set; } { ContactLookupList = new List<ContactLookupWrapper> (); }
   public String SelectedUserEmail { get; set; }
   public Integer AddContactLimit { get; set; } { AddContactLimit = AH_UDC_ConfigHelper.GetInteger('AH_UDC_AddContactLimit', 5); } //Maximum number of contacts allowed
   public String AddContactLimitString { get { return String.valueOf(AddContactLimit); } } //Maximum number of contacts allowed
   public Id propertyAccountId { get; set; }
   public Boolean isSendWorkbookEnabled { get { return AH_UDC_ConfigHelper.GetBoolean('AH_UDC_SendWorkbookEnabled', false); } }
   public Boolean AllowSend { get; set; } { AllowSend = true; }
   public String SendNotAllowedMessage { get; set; }
   public Boolean ReleaseWorkbook { get; set; } { ReleaseWorkbook = true; }
   
   public class ContactLookupWrapper {
      public Integer Index { get; set; }
      public Id Id { get; set; }
      public string Name { get; set; }
      public string ErrorMessage { get; set; }
   }

   @TestVisible private string LogFunctionalArea = 'AH_UDC_SendWorkbook'; //This is used for AH_UDC_Log Entries being written on this page
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }
   //This is used client side to determine if AH_UDC_Log Messages need to be written from the Page Load
   public Boolean HasPageLoadLogMessages {
      get {
         AH_UDC_LogHelper.Debug('PageLoadLogMessages: ' + PageLoadLogMessages);
         return PageLoadLogMessages != null && PageLoadLogMessages.size() > 0;
      }
   }

   public AH_UDC_SendWorkbook(ApexPages.StandardController controller) {
      List<User> externalUser = null;
      try {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;

         //Determine if the current user has the UDC System Admin permission set assigned to them
         String UDCSystemAdminPermissionSetName = AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetUDCSystemAdministrator', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN);
         Boolean isUDCSysAdmin = 0 < (Integer) [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :System.UserInfo.getUserId() AND PermissionSet.Name = :UDCSystemAdminPermissionSetName];

         //Alert the user if sending workbooks is disabled; UDC System Admins are excluded
         if (!isUDCSysAdmin && !isSendWorkbookEnabled) {
            AllowSend = false;
            SendNotAllowedMessage = AH_UDC_ConfigHelper.GetString('AH_UDC_SendWorkbookDisabledMessage', 'Send Workbook is currently disabled.');
            return;
         }

         IsCopyWorkbook = false;
         SelectedContact = new Contact();
         ContactId = apexpages.currentpage().getparameters().get('Id');
         ProjectId = apexpages.currentpage().getparameters().get('ProjectId');
         UserLocale = UserInfo.getLocale();
         ParentWorkbookName = '';
         AH_UDC_LogHelper.Debug('ContactId: ' + ContactId);
         AH_UDC_LogHelper.Debug('ProjectId: ' + ProjectId);

         if (String.isBlank(String.valueOf(ContactId)) && String.isBlank(String.valueOf(ProjectId))) {
            LogException('Constructor', 'ContactId or ProjectId not found in the parameters', null, null);
            return;
         }

         List<Contact> lstContacts = null;
         if (String.isNotBlank(String.valueOf(ContactId))) {
            //Get current contact's details
            lstContacts = [SELECT Id, FirstName, Name, Email, AccountId, Account.Name
                           FROM Contact
                           WHERE Id = :ContactId AND Status__c = 'Active'];
            if (lstContacts.size() > 0)
            {
               SelectedContact = lstContacts[0];
            }
            else {
               LogException('Constructor', 'Contact record not found with the Id ' + ContactId, null, null);
               return;
            }
         }
         else if (String.isNotBlank(String.valueOf(ProjectId))) {
            List<pse__Proj__c> lstProjects = [SELECT Id, Name, Customer_Project_Contact__c, pse__Account__c, pse__Account__r.Name
                                              FROM pse__Proj__c
                                              WHERE Id = :ProjectId];
            AH_UDC_LogHelper.Debug('lstProjects: ' + lstProjects);
            if (lstProjects.size() == 0) {
               LogException('Constructor', 'Project record not found with the Id ' + ProjectId, null, null);
               return;
            }
            else if (String.isBlank(String.valueOf(lstProjects[0].Customer_Project_Contact__c))) {
               AllowSend = false;
               SendNotAllowedMessage = Label.AH_UDC_SendWorkbookProjectWithoutContactErrorMessage;
               return;
            }
            else {
               ProjectName = lstProjects[0].Name;
               lstContacts = [SELECT Id, FirstName, Name, Email, AccountId, Account.Name, Status__c
                              FROM Contact
                              WHERE Id = :lstProjects[0].Customer_Project_Contact__c];

               if (lstContacts.size() > 0) {
                  if (lstContacts[0].Status__c != 'Active') {
                     AllowSend = false;
                     SendNotAllowedMessage = Label.AH_UDC_SendWorkbookProjectWithInActiveContactErrorMessage;
                     return;
                  }
                  ContactId = lstContacts[0].Id;
                  SelectedContact = lstContacts[0];
                  if (String.isNotBlank(String.valueOf(lstProjects[0].pse__Account__c))) {
                     //Use account details from project record if Account is associated
                     SelectedContact.AccountId = lstProjects[0].pse__Account__c;
                     SelectedContact.Account.Id = lstProjects[0].pse__Account__c;
                     SelectedContact.Account.Name = lstProjects[0].pse__Account__r.Name;
                  }
               }
               else {
                  LogException('Constructor', 'Contact record not found with the Id ' + lstProjects[0].Customer_Project_Contact__c, null, null);
                  return;
               }
            }
         }

         if (String.isBlank(SelectedContact.Email)) { //Check Contact has email address or not
            AllowSend = false;
            SendNotAllowedMessage = Label.AH_UDC_Send_Workbook_Contact_Email_Required_Message;
         }
         else if (String.isBlank(SelectedContact.FirstName)) {
            AllowSend = false;
            SendNotAllowedMessage = Label.AH_UDC_Send_Workbook_First_Name_Required;
         }
         else {
            GetProductList(); //Get available product list
            if (IsErrorOccurred == false) { //If error occurred in GetEnabledProductWorkbooks() then do not call other methods
               GetDefaultEmailTemplateDetails(); //Get default email template details to fill in the lookup field
            }
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred loading Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('Constructor', strErrorMessage, ex, null);
      }
      finally {
         externalUser = null;

         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   //Get available product list
   public void GetProductList() {
      Schema.DescribeFieldResult fieldResult = null;
      List<Schema.PicklistEntry> pickListEntry = null;
      try {
         WorkbookProducts = new List<SelectOption> ();
         fieldResult = AH_UDC_Workbook__c.Product__c.getDescribe();

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         if (fieldResult == null) {
            LogException('GetProductList', 'Metadata details not found for the field - Product__c', null, null);
            return;
         }

         pickListEntry = fieldResult.getPicklistValues();
         if (pickListEntry != null && pickListEntry.size() > 0) {
            WorkbookProducts.add(new SelectOption('', Label.AH_UDC_Send_Workbook_SelectProduct_Label));
            for (Schema.PicklistEntry option : pickListEntry) {
               WorkbookProducts.add(new SelectOption(option.getValue(), option.getLabel()));
            }
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred getting product list - Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetProductList', strErrorMessage, ex, null);
      }
   }

   //Get enabled workbook list for selected product
   public void GetEnabledProductWorkbooks() {
      Id workbookRecordTypeId = null;
      List<AH_UDC_Workbook__c> lstWorkbook = null;
      try {
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         EnabledProductWorkbooks = new List<SelectOption> ();
         workbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
         if (String.isNotBlank(String.valueOf(workbookRecordTypeId))) {
            EnabledProductWorkbooks.add(new SelectOption('', Label.AH_UDC_Send_Workbook_SelectWorkbook_Label));

            AggregateResult[] result = [SELECT Workbook__c, Workbook__r.Name WorkbookName, COUNT(Id) StepCount
                                        FROM AH_UDC_WorkbookStep__c
                                        WHERE Workbook__r.Product__c = :SelectedProduct
                                        AND Workbook__r.Enabled__c = true
                                        AND Workbook__r.RecordTypeId = :workbookRecordTypeId
                                        AND Enabled__c = true
                                        GROUP BY Workbook__c, Workbook__r.Name
                                        HAVING COUNT(Id) > 0];

            for (AggregateResult objWorkbook : result) {
               EnabledProductWorkbooks.add(new SelectOption((Id) objWorkbook.get('Workbook__c'), String.valueOf(objWorkbook.get('WorkbookName'))));
            }
         }
         else {
            LogException('GetEnabledProductWorkbooks', 'AH_UDC_Workbook Record Type No Found', null, null);
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred getting enable product workbook - Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetEnabledProductWorkbooks', strErrorMessage, ex, null);
      }
   }

   //Called by action function to set the Email Template for the selected workbook
   public void SetEmailTemplate(){
      AH_UDC_LogHelper.Debug('SetEmailTemplate - Start');
      if (String.isNotEmpty(SelectedWorkbook)){
         AH_UDC_LogHelper.Debug('SetEmailTemplate - SelectedWorkbookID: ' + SelectedWorkbook);
         List<AH_UDC_Workbook__c> workbooks = [SELECT Id, EmailTemplate__c from AH_UDC_Workbook__c where ID=:SelectedWorkbook and RecordType.DeveloperName = :AH_UDC_Constants.RECORD_TYPE_WORKBOOK];
         List<EmailTemplate> lstEmailTemplates = null;
         if(workbooks.size() ==0 || workbooks[0].EmailTemplate__c ==null)
         {
            AH_UDC_LogHelper.Debug('SetEmailTemplate - L2');
            lstEmailTemplates = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = :Label.AH_UDC_Send_Workbook_Default_Email_Template];
         }
         else {
            AH_UDC_LogHelper.Debug('SetEmailTemplate - L3');
            lstEmailTemplates = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = :workbooks[0].EmailTemplate__c];
         }
         SelectedEmailTemplateId = (lstEmailTemplates.size()!= 1? null : lstEmailTemplates[0].Id);
         SelectedEmailTemplateName = (lstEmailTemplates.size()!= 1? null : lstEmailTemplates[0].Name);
         AH_UDC_LogHelper.Debug('SetEmailTemplate - SelectedEmailTemplateId: ' + SelectedEmailTemplateId);
         AH_UDC_LogHelper.Debug('SetEmailTemplate - SelectedEmailTemplateName: ' +  SelectedEmailTemplateName);
      }
      AH_UDC_LogHelper.Debug('SetEmailTemplate - Stop');
   }

   //Get default email template details based on developer name
   public void GetDefaultEmailTemplateDetails() {
      List<EmailTemplate> lstEmailTemplates = null;
      try {
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         //Get default email template details from the object based on developer name
         lstEmailTemplates = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = :Label.AH_UDC_Send_Workbook_Default_Email_Template];

         if (lstEmailTemplates != null && lstEmailTemplates.size() > 0) {
            SelectedEmailTemplateId = lstEmailTemplates[0].Id;
            SelectedEmailTemplateName = lstEmailTemplates[0].Name;
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred getting Default Email Template Details - Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetDefaultEmailTemplateDetails', strErrorMessage, ex, null);
      }
   }

   //Create community users before sending workbooks
   public void CreateCommunityUsers() {
      try {
         //NOTE: This method calls DML executed against SETUP objects ... thus no other objects can be inserted (like Log Messages)
         AH_UDC_LogHelper.QueueLogs = true;

         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceSendWorkbookCreateCommunityUserException', FALSE, true)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'Send Workbook Create Community Users'));

         //Create the primary contact's Community User
         Boolean IsAllUsersCreated = true;
         if (ReleaseWorkbook) IsAllUsersCreated = AH_UDC_SharedWithoutSharing.SetupCommunityAccess(ContactId);

         //Create any other contact Community User's
         AH_UDC_LogHelper.Debug('CreateCommunityUsers-ContactLookupList: ' + ContactLookupList);
         AH_UDC_LogHelper.Debug('CreateCommunityUsers-ContactLookupList.size(): ' + ContactLookupList.size());
         if (ContactLookupList != null && ContactLookupList.size() > 0) {
            for (ContactLookupWrapper objContact : ContactLookupList) {
               if (String.isNotBlank(String.valueOf(objContact.Id)) && String.isBlank(objContact.ErrorMessage)) {
                  Boolean IsAddUserCreated = true;
                  if (ReleaseWorkbook) IsAddUserCreated = AH_UDC_SharedWithoutSharing.SetupCommunityAccess(objContact.Id);
                  AH_UDC_LogHelper.Debug('CreateCommunityUsers : IsAddUserCreated: ' + IsAddUserCreated);
                  if (!IsAddUserCreated) IsAllUsersCreated = false;
               }
            }
         }
         IsCommunityUserCreated = IsAllUsersCreated;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred creating community user - Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         System.debug('Exception occurred: ' + strErrorMessage);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'CreateCommunityUsers', strErrorMessage,
                              ex, null, null);
      }
      finally {
         //Write any queued log messages since it can't be written due to the SETUP DML above
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();

         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   //Create required objects like NIDoc, UDC contact , workbook, workbook step & property account etc
   public void SendWorkbook() {
      Id accountId = null;
      Id workbookId = null;

      Account accountData = null;
      AH_UDC_Contact__c objUDCContact = null;

      //Prepare database save point for rollback transaction BEFORE any records are inserted
      Savepoint objSavePoint = Database.setSavepoint();

      try {
         //Alert the user if sending workbooks is disabled; buttons will be hidden too
         String UDCSystemAdminPermissionSetName = AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetUDCSystemAdministrator', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN);
         Boolean isUDCSysAdmin = 0 < (Integer) [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :System.UserInfo.getUserId() AND PermissionSet.Name = :UDCSystemAdminPermissionSetName];

         if (!isUDCSysAdmin && !isSendWorkbookEnabled) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, AH_UDC_ConfigHelper.GetString('AH_UDC_SendWorkbookDisabledMessage', 'Send Workbook is currently disabled.')));
            return;
         }

         if (String.isBlank(SelectedWorkbook)) {
            LogException('SendWorkbook', 'Workbook not selected', null, null);
            return;
         }

         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestSendWorkbookError', FALSE, true)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'Send Workbook'));

         //The the account ID for the active contact
         accountId = SelectedContact.Account.Id;

         //Insert NI Doc record
         NewNIDocId = CreateNIDocRecord(accountId, objSavePoint);
         AH_UDC_LogHelper.Debug('SendWorkbook : NewNIDocId: ' + String.valueOf(NewNIDocId));
         if (IsErrorOccurred || String.isBlank(String.valueOf(NewNIDocId))) return; //CreateNIDocRecord() will show the Error to the user and the rollback will occur if it can't insert a record

         //Insert property account record and map with inserted NI Doc record - this must happen before creating the steps
         CreatePropertyAccountRecord(objSavePoint, accountId);
         AH_UDC_LogHelper.Debug('SendWorkbook : propertyAccountId: ' + String.valueOf(propertyAccountId));
         AH_UDC_LogHelper.Debug('SendWorkbook : IsErrorOccurred: ' + IsErrorOccurred);
         if (IsErrorOccurred) return; //CreatePropertyAccountRecord() will show the Error to the user and the rollback will occur if it can't insert a record

         //Insert Workbook Sent record
         workbookId = CreateWorkbookSentRecord(objSavePoint);
         AH_UDC_LogHelper.Debug('SendWorkbook : workbookId' + String.valueOf(workbookId));
         if (IsErrorOccurred || String.isBlank(String.valueOf(workbookId))) return; //CreateWorkbookSentRecord() will show the Error to the user and the rollback will occur if it can't insert a record

         //Insert Workbook Step Sent records
         CreateWorkbookStepSentRecord(objSavePoint, SelectedWorkbook, workbookId);
         AH_UDC_LogHelper.Debug('SendWorkbook : CreateWorkbookStepSentRecord - IsErrorOccurred: ' + IsErrorOccurred);
         //Do not proceed further if error occurred
         if (IsErrorOccurred) return; //CreateWorkbookStepSentRecord() will show the Error to the user and the rollback will occur if it can't insert a record

         CreateFollowForCurrentUser(objSavePoint);
         AH_UDC_LogHelper.Debug('SendWorkbook : CreateFollowForCurrentUser - IsErrorOccurred: ' + IsErrorOccurred);
         if (IsErrorOccurred) return; //CreateFollowForCurrentUser() will show the Error to the user and the rollback will occur if it can't insert a record

         //Create primary AH_UDC_Contact record
         CreateUDCContacts(objSavePoint);
         AH_UDC_LogHelper.Debug('SendWorkbook : CreateUDCContacts - IsErrorOccurred: ' + IsErrorOccurred);
         if (IsErrorOccurred) return; //CreateUDCContacts() will show the Error to the user and the rollback will occur if it can't insert a record

         //Send welcome email to all selected contacts
         if (ReleaseWorkbook){
            SendEmailToContacts();
         }
         if (!IsCommunityUserCreated) {
            //If there is an error in creating community users then display message to user 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, Label.AH_UDC_CreateCommunityUserErrorMessage));
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred send workbook page for user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('SendWorkbook', strErrorMessage, ex, objSavepoint);
      }
   }

   //Create NI Doc record based on values provided
   private Id CreateNIDocRecord(Id accountId, Savepoint objSavepoint) {
      Id NIDocRecordTypeId = null;
      NI_Documentation__c objNIDoc = null;
      try {
         //Get record type id to insert NI Doc record
         NIDocRecordTypeId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
         if (String.isBlank(String.valueOf(NIDocRecordTypeId))) {
            LogException('CreateNIDocRecord', 'AH_UDC_Workbook Record Type Not Found', null, null);
            return null;
         }

         objNIDoc = new NI_Documentation__c(RecordTypeId = NIDocRecordTypeId, Document_Name__c = NiDocumentName.trim(), Account__c = accountId, AH_UDC_WorkbookDueDate__c = DueDate, OwnerId = Userinfo.getUserId(), AH_UDC_ChatterWorkbookAccessed__c = IsUDCWorkbookAccessed, AH_UDC_ChatterWorkbookCompleted__c = IsUDCWorkbookCompleted, AH_UDC_ChatterWorkbookStepCompleted__c = IsUDCWorkbookStepCompleted);
         if (String.isNotBlank(ProjectId))
         objNIDoc.Project__c = ProjectId;
         AH_UDC_SystemContext.CreateObject(objNIDoc);
         return objNIDoc.Id;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred create NI Doc Record - send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CreateNIDocRecord', strErrorMessage, ex, objSavepoint);
         return null;
      }
   }

   //Create Workbook Sent record based on selected workbook
   private Id CreateWorkbookSentRecord(Savepoint objSavepoint) {
      Id workbookSentRecordTypeId = null;
      List<AH_UDC_Workbook__c> lstWorkbooks = null;
      List<AH_UDC_Workbook__c> lstParentWorkbooks = null;
      AH_UDC_Workbook__c objWorkbookClone = null;
      try {
         //Get record type id to insert NI Doc record
         workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
         if (String.isNotBlank(String.valueOf(workbookSentRecordTypeId))) {
            lstWorkbooks = [SELECT CompletedDate__c, Description__c, Enabled__c, Id, Name, OwnerId, Product__c, RecordTypeId,
                            RelatedToDocName__c, RelatedTo__c, SentDate__c,
                            SentStatus__c, StepsinOrder__c, CompletedBy__c, DueDate__c, ParentWorkbookSent__c, OriginalWorkbook__c,
                            Reminder1Enabled__c,Reminder1Days__c,Reminder1EmailTemplate__c,
                            Reminder2Enabled__c,Reminder2Days__c,Reminder2EmailTemplate__c,
                            Reminder3Enabled__c,Reminder3Days__c,Reminder3EmailTemplate__c,
                            Reminder4Enabled__c,Reminder4Days__c,Reminder4EmailTemplate__c
                            FROM AH_UDC_Workbook__c
                            WHERE Id = :SelectedWorkbook];

            if (lstWorkbooks != null && lstWorkbooks.size() > 0) {
               objWorkbookClone = lstWorkbooks[0].clone(false, false, false, false);
               //Set Email Template
               List<EmailTemplate> wbTemplates = [select Id, DeveloperName from EmailTemplate where ID = :SelectedEmailTemplateId];
               objWorkbookClone.EmailTemplate__c = wbTemplates[0].DeveloperName;
               //Setup Reminders
               objWorkbookClone.Reminder1Sent__c = null;
               objWorkbookClone.Reminder2Sent__c = null;
               objWorkbookClone.Reminder3Sent__c = null;
               objWorkbookClone.Reminder4Sent__c = null;
               List<String> ReminderEmailTemplates = new List<String>();
               if (String.isNotBlank(objWorkbookClone.Reminder1EmailTemplate__c)) ReminderEmailTemplates.add(objWorkbookClone.Reminder1EmailTemplate__c);
               if (String.isNotBlank(objWorkbookClone.Reminder2EmailTemplate__c)) ReminderEmailTemplates.add(objWorkbookClone.Reminder2EmailTemplate__c);
               if (String.isNotBlank(objWorkbookClone.Reminder3EmailTemplate__c)) ReminderEmailTemplates.add(objWorkbookClone.Reminder3EmailTemplate__c);
               if (String.isNotBlank(objWorkbookClone.Reminder4EmailTemplate__c)) ReminderEmailTemplates.add(objWorkbookClone.Reminder4EmailTemplate__c);
               List<EmailTemplate> templates = new List<EmailTemplate>();
               If (ReminderEmailTemplates.size() > 0) templates= [select id, DeveloperName from EmailTemplate where DeveloperName in :ReminderEmailTemplates];
               objWorkbookClone.Reminder1Enabled__c = checkReminderEnabled(objWorkbookClone.Reminder1Enabled__c,objWorkbookClone.Reminder1Days__c, objWorkbookClone.Reminder1EmailTemplate__c, DueDate, templates);
               objWorkbookClone.Reminder2Enabled__c = checkReminderEnabled(objWorkbookClone.Reminder2Enabled__c,objWorkbookClone.Reminder2Days__c, objWorkbookClone.Reminder2EmailTemplate__c, DueDate, templates);
               objWorkbookClone.Reminder3Enabled__c = checkReminderEnabled(objWorkbookClone.Reminder3Enabled__c,objWorkbookClone.Reminder3Days__c, objWorkbookClone.Reminder3EmailTemplate__c, DueDate, templates);
               objWorkbookClone.Reminder4Enabled__c = checkReminderEnabled(objWorkbookClone.Reminder4Enabled__c,objWorkbookClone.Reminder4Days__c, objWorkbookClone.Reminder4EmailTemplate__c, DueDate, templates);
               objWorkbookClone.RecordTypeId = workbookSentRecordTypeId;
               objWorkbookClone.RelatedTo__c = NewNIDocId;
               if (ReleaseWorkbook) objWorkbookClone.Released__c = true;
               objWorkbookClone.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
               objWorkbookClone.SentDate__c = Datetime.now();
               objWorkbookClone.CompletedDate__c = null;
               objWorkbookClone.CompletedBy__c = null;
               objWorkbookClone.OwnerId = UserInfo.getUserId();
               objWorkbookClone.SecurityCode__c = AH_UDC_Shared.GetSecurityCode(); //Security Code for each Workbook Sent must be unique
               objWorkbookClone.OriginalWorkbook__c = SelectedWorkbook;
               AH_UDC_LogHelper.Debug('CreateWorkbookSentRecord => IsCopyWorkbook: ' + IsCopyWorkbook);
               if (IsCopyWorkbook == false && String.isNotBlank(String.valueOf(SelectedNIDocIdNew))) { //If parent Workbook NI Doc is selected then set value in the field
                  lstParentWorkbooks = [SELECT Id
                                          FROM AH_UDC_Workbook__c
                                          WHERE RelatedTo__c = :SelectedNIDocIdNew];
                  if (lstParentWorkbooks != null && lstParentWorkbooks.size() > 0) {
                     objWorkbookClone.ParentWorkbookSent__c = lstParentWorkbooks[0].Id;
                  }
                  else {
                     LogException('CreateWorkbookSentRecord', 'Selected NI Doc record do not workbook associated', null, objSavepoint);
                  }
               }
               if (objWorkbookClone != null) {
                  AH_UDC_SystemContext.CreateObject(objWorkbookClone);
                  return objWorkbookClone.Id;
               }
               return '';
            }
            else {
               LogException('CreateWorkbookSentRecord', 'Selected Workbook Record Not Found', null, objSavepoint);
               return '';
            }
         }
         else {
            LogException('CreateWorkbookSentRecord', 'AH_UDC_Workbook Record Type Not Found', null, objSavepoint);
            return '';
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CreateWorkbookSentRecord', strErrorMessage, ex, objSavepoint);
         return objWorkbookClone != null ? objWorkbookClone.Id : '';
      }
   }

   //Determine if Reminder on Sent Workbook should be enabled
   private Boolean checkReminderEnabled(Boolean ReminderEnabled, Decimal ReminderDays, string ReminderEmailTemplate, Date wbDueDate, List<EmailTemplate> templates)
   {
      if (!ReminderEnabled || ReminderDays ==null || wbDueDate == null) return false;
      //Determine if template is specified and valid
      if (String.isEmpty(ReminderEmailTemplate)) return false;
      Boolean isValidTemplate = false;
      for(EmailTemplate et : templates)
      {
         if(et.DeveloperName == ReminderEmailTemplate) {
            isValidTemplate = true;
            break;
         }
      }
      if (!isValidTemplate) return false;
      if (ReminderDays > -1)
      {
         If ((system.today()).daysBetween(Date.valueOf(wbDueDate)) > ReminderDays) return true;
      }
      else
      {
         If ((system.today()).daysBetween(Date.valueOf(wbDueDate)) > ReminderDays) return true;
      }
      return false;
   }

   //Create Workboook Step Sent record based on values provided
   private void CreateWorkbookStepSentRecord(Savepoint objSavepoint, Id originalWorkbookId, Id newWorkbookId) {
      try {
         //Get record type id to insert Workboook Step Sent record
         Id workbookStepSentRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
         Id workbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
         if (String.isBlank(String.valueOf(workbookStepSentRecordTypeId)) || String.isBlank(String.valueOf(workbookStepRecordTypeId))) {
            LogException('CreateWorkbookStepSentRecord', 'AH_UDC_WorkbookStep Or AH_UDC_WorkbookStepSent Record Type Not Found', null, objSavepoint);
            return;
         }
         
         List<AH_UDC_WorkbookStep__c> lstNewWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ();
         Map<Decimal, Decimal> stepSortOrderMapPrereq = new Map<Decimal, Decimal> (); //It will hold sort order along with sort order of it's prequisite step
         List<AH_UDC_WorkbookStep__c> lstOriginalWorkbookSteps = [SELECT Id, Name, CurrencyIsoCode, Description__c, Enabled__c, Form__c, Help__c, Prerequisite_Step__c,
                                                                  RecordTypeId, SortOrder__c, StepCompleted__c, StepStatus__c, URL__c, StepCompletedBy__c, Workbook__c,
                                                                  Form__r.FormType__c, Form__r.CopyResponseWhenSendingNew__c
                                                                  FROM AH_UDC_WorkbookStep__c
                                                                  WHERE Workbook__c = :originalWorkbookId AND RecordTypeId = :workbookStepRecordTypeId
                                                                  AND Enabled__c = true //Only Copy enabled steps to Sent Workbook
                                                                  ORDER BY SortOrder__c];
         AH_UDC_LogHelper.Debug('CreateWorkbookStepSentRecord => Total Steps to be created: ' + lstOriginalWorkbookSteps.size());
         Map<Id, Decimal> stepIdSortOrderMap = new Map<Id, Decimal> (); //It will hold StepId and it's Sort Order
         for (AH_UDC_WorkbookStep__c objOriginalStep : lstOriginalWorkbookSteps) {
            AH_UDC_WorkbookStep__c objNewStep = objOriginalStep.clone(false, false, false, false);
            objNewStep.RecordTypeId = workbookStepSentRecordTypeId;
            objNewStep.Workbook__c = newWorkbookId;
            objNewStep.StepStatus__c = AH_UDC_Constants.STEP_STATUS_NEW;
            objNewStep.StepCompleted__c = null;
            objNewStep.StepCompletedBy__c = null;
            objNewStep.CreatedById = UserInfo.getUserId();
            objNewStep.CreatedDate = DateTime.now();
            objNewStep.LastModifiedById = UserInfo.getUserId();
            objNewStep.LastModifiedDate = DateTime.now();
            if (String.isNotBlank(objOriginalStep.Prerequisite_Step__c)) {
               objNewStep.Prerequisite_Step__c = null;
               stepSortOrderMapPrereq.put(objOriginalStep.SortOrder__c, stepIdSortOrderMap.get(objOriginalStep.Prerequisite_Step__c));
            }
            stepIdSortOrderMap.put(objOriginalStep.Id, objOriginalStep.SortOrder__c);
            lstNewWorkbookSteps.add(objNewStep);
         }

         if (lstNewWorkbookSteps != null && lstNewWorkbookSteps.size() > 0) {
            AH_UDC_LogHelper.Debug('CreateWorkbookStepSentRecord => lstNewWorkbookSteps.size(): ' + lstNewWorkbookSteps.size());
            AH_UDC_SystemContext.CreateObjects(lstNewWorkbookSteps);

            //Map of SortOrder and StepId for which copy of form responses is pending
            Map<Decimal, Id> mapNewInsertedStepIdAndSortOrder = new Map<Decimal, Id> ();
            Map<Id, Id> mapNewInsertedStepIdAndFormId = new Map<Id, Id> ();
            for (AH_UDC_WorkbookStep__c objInsertedStep : lstNewWorkbookSteps) {
               if(String.isNotBlank(String.valueOf(objInsertedStep.Form__c)))
                  mapNewInsertedStepIdAndFormId.put(objInsertedStep.Form__c, objInsertedStep.Id);
               mapNewInsertedStepIdAndSortOrder.put(objInsertedStep.SortOrder__c, objInsertedStep.Id);
               if (stepSortOrderMapPrereq.containsKey(objInsertedStep.SortOrder__c)) {
                  Decimal sortOrderOfPrereqStep = stepSortOrderMapPrereq.get(objInsertedStep.SortOrder__c);
                  //Get prerequisite stepid based on it's sort order
                  objInsertedStep.Prerequisite_Step__c = mapNewInsertedStepIdAndSortOrder.get(sortOrderOfPrereqStep);
               }
            }

            AH_UDC_LogHelper.Debug('CreateWorkbookStepSentRecord => mapNewInsertedStepIdAndSortOrder: ' + mapNewInsertedStepIdAndSortOrder);
            AH_UDC_LogHelper.Debug('CreateWorkbookStepSentRecord => stepSortOrderMapPrereq: ' + stepSortOrderMapPrereq);
            if (stepSortOrderMapPrereq != null && stepSortOrderMapPrereq.size() > 0) {
               //Update inserted steps to set prerequisite step
               AH_UDC_SystemContext.UpdateObjects(lstNewWorkbookSteps);
            }

            //Copy responses for new inserted steps
            CopyStepResponses(objSavepoint, lstOriginalWorkbookSteps, mapNewInsertedStepIdAndFormId);
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CreateWorkbookStepSentRecord', strErrorMessage, ex, objSavepoint);
      }
   }

   //Insert responses into junction object AH_UDC_WorkbookStepResponse__c
   private void CopyStepResponses(Savepoint objSavepoint, List<AH_UDC_WorkbookStep__c> lstOriginalWorkbookSteps, Map<Id, Id> mapNewInsertedStepIdAndFormId) {
      try {
         //Determine which forms are Shared/Central, or product form, where CopyResponseWhenSendingNew__c checkbox is checked
         Set<Id> formIdsToCopyResponses = new Set<Id> ();
         Set<Id> formIdsWithProductTypeWithoutCopyData = new Set<Id> ();
         for (AH_UDC_WorkbookStep__c wbStep : lstOriginalWorkbookSteps) {
            if(String.isBlank(String.valueOf(wbStep.Form__c)))
               continue;

            if (wbStep.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_CENTRAL
                || wbStep.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_SHARED
                || wbStep.Form__r.CopyResponseWhenSendingNew__c) {
               formIdsToCopyResponses.add(wbStep.Form__c);
            }
            else {
               //Create list of forms with product type to copy responses from workbook sent record
               formIdsWithProductTypeWithoutCopyData.add(wbStep.Form__c);
            }
         }
         AH_UDC_LogHelper.Debug('CopyStepResponses : formIdsToCopyResponses: ' + formIdsToCopyResponses);
         AH_UDC_LogHelper.Debug('CopyStepResponses : propertyAccountId: ' + propertyAccountId);

         List<AH_UDC_WorkbookStepResponse__c> lstStepResponses = new List<AH_UDC_WorkbookStepResponse__c> ();

         // Has the Form IDs of all the Step Responses that are already in lstStepResponses, so that we can filter
         // out the ones that have already been added to the list of responses that are to be copied when
         // performing the query on ProductFormResponses
         List<Id> lstIdOfFormWithStepResponsesBeingCopied = new List<Id> ();

         if (formIdsToCopyResponses.size() > 0) {
            //Get shared & central forms responses as well as product form responses if checkbox CopyResponseWhenSendingNew__c is checked
            AggregateResult[] groupedResults = [SELECT WorkbookStep__r.Form__c FormId, max(Response__c) maxResponseId
                                                FROM AH_UDC_WorkbookStepResponse__c
                                                WHERE WorkbookStep__r.Form__c IN :formIdsToCopyResponses
                                                AND IsMostRecentResponse__c = true
                                                AND WorkbookStep__r.Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c = :propertyAccountId
                                                GROUP BY WorkbookStep__r.Form__c];

            for (AggregateResult result : groupedResults) {
               Id formId = (Id) result.get('FormId');
               Id responseId = (Id) result.get('maxResponseId');
               if (mapNewInsertedStepIdAndFormId.containsKey(formId)) {
                  lstIdOfFormWithStepResponsesBeingCopied.add(formId);
                  lstStepResponses.add(new AH_UDC_WorkbookStepResponse__c(WorkbookStep__c = mapNewInsertedStepIdAndFormId.get(formId),
                                                                          Response__c = responseId));
               }
            }
            AH_UDC_LogHelper.Debug('CopyStepResponses : lstStepResponses.size() - Shared & Central Forms: ' + lstStepResponses.size());
         }

         if (IsCopyWorkbook && formIdsWithProductTypeWithoutCopyData.size() > 0) {
            //For copy workbook option get responses of product forms
            List<AH_UDC_WorkbookStepResponse__c> lstProductFormResponses = [SELECT WorkbookStep__c, WorkbookStep__r.SortOrder__c, Response__c, WorkbookStep__r.Form__c
                                                                            FROM AH_UDC_WorkbookStepResponse__c
                                                                            WHERE WorkbookStep__r.Form__c IN :formIdsWithProductTypeWithoutCopyData
                                                                            AND WorkbookStep__r.Workbook__r.RelatedTo__c = :SelectedNIDocIdCopy
                                                                            AND IsMostRecentResponse__c = true
                                                                            AND WorkbookStep__r.Form__r.FormType__c = :AH_UDC_Constants.FORM_TYPE_PRODUCT];

            AH_UDC_LogHelper.Debug('CopyStepResponses : lstProductFormResponses.size(): ' + lstProductFormResponses.size());
            for (AH_UDC_WorkbookStepResponse__c objStepResp : lstProductFormResponses) {
               if (mapNewInsertedStepIdAndFormId.containsKey(objStepResp.WorkbookStep__r.Form__c)) {
                  lstIdOfFormWithStepResponsesBeingCopied.add(objStepResp.WorkbookStep__r.Form__c);
                  lstStepResponses.add(new AH_UDC_WorkbookStepResponse__c(WorkbookStep__c = mapNewInsertedStepIdAndFormId.get(objStepResp.WorkbookStep__r.Form__c),
                                                                          Response__c = objStepResp.Response__c));
               }
            }
            AH_UDC_LogHelper.Debug('CopyStepResponses : lstStepResponses.size() - After adding product form responses: ' + lstStepResponses.size());
         }

         //This will copy the default responses
         if (lstStepResponses.size() != lstOriginalWorkbookSteps.size())
         {
            List<AH_UDC_WorkbookStepResponse__c> lstDefaultResponses = [SELECT WorkbookStep__c, WorkbookStep__r.SortOrder__c, Response__c, WorkbookStep__r.Form__c
                                                                        FROM AH_UDC_WorkbookStepResponse__c
                                                                        WHERE WorkbookStep__c IN :lstOriginalWorkbookSteps
                                                                        AND WorkbookStep__r.Form__c NOT IN :lstIdOfFormWithStepResponsesBeingCopied
                                                                        AND IsMostRecentResponse__c = true
                                                                        AND(WorkbookStep__r.Form__r.FormType__c = :AH_UDC_Constants.FORM_TYPE_PRODUCT OR
                                                                            WorkbookStep__r.Form__r.FormType__c = :AH_UDC_Constants.FORM_TYPE_SHARED)];

            AH_UDC_LogHelper.Debug('DefaultStepResponses : lstDefaultResponses.size(): ' + lstDefaultResponses.size());
            for (AH_UDC_WorkbookStepResponse__c objStepResp : lstDefaultResponses) {
               if (mapNewInsertedStepIdAndFormId.containsKey(objStepResp.WorkbookStep__r.Form__c)) {
                  lstStepResponses.add(new AH_UDC_WorkbookStepResponse__c(WorkbookStep__c = mapNewInsertedStepIdAndFormId.get(objStepResp.WorkbookStep__r.Form__c),
                                                                          Response__c = objStepResp.Response__c));
               }
            }
            AH_UDC_LogHelper.Debug('CopyStepResponses : lstStepResponses.size() - After adding default responses: ' + lstStepResponses.size());
         }

         if (lstStepResponses.size() > 0) {
            //Insert records into the object AH_UDC_WorkbookStepResponse__c
            AH_UDC_SystemContext.CreateObjects(lstStepResponses);
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CopyStepResponses', strErrorMessage, ex, objSavepoint);
      }
   }

   //Create Property Account record based on values provided
   private Id CreatePropertyAccountRecord(Savepoint objSavepoint, Id accountId) {
      AH_UDC_LogHelper.Debug('CreatePropertyAccountRecord : accountId: ' + accountId);

      List<AH_UDC_PropertyAccount__c> lstPropertyAccounts = null;
      NI_Documentation__c objNIDoc = null;
      List<Account> lstAccounts = null;
      AH_UDC_PropertyAccount__c objPropertyaccount = null;
      propertyAccountId = null;
      try {
         if (String.isNotBlank(String.valueOf(accountId))) {
            lstPropertyAccounts = [SELECT Id
                                   FROM AH_UDC_PropertyAccount__c
                                   WHERE Account__r.Id = :accountId];
            if (lstPropertyAccounts.size() > 0) {
               //Map inserted NI Doc record with existing property account record
               propertyAccountId = lstPropertyAccounts[0].Id;
            }
            else {
               //Get details of selected account from the object and use them to create AH_UDC_PropertyAccount record
               lstAccounts = [SELECT Id, Name,
                              ShippingStreet, ShippingState, ShippingCity, ShippingPostalCode, ShippingCountry,
                              BillingStreet, BillingState, BillingCity, BillingPostalCode, BillingCountry, Phone
                              FROM Account
                              WHERE Id = :accountId];
               if (lstAccounts.size() > 0) {
                  objPropertyaccount = new AH_UDC_PropertyAccount__c(
                                                                     Account__c = lstAccounts[0].Id,
                                                                     PropertyName__c = lstAccounts[0].Name,
                                                                     Address__c = (String.isNotBlank(lstAccounts[0].ShippingStreet) ? lstAccounts[0].ShippingStreet : lstAccounts[0].BillingStreet),
                                                                     City__c = (String.isNotBlank(lstAccounts[0].ShippingCity) ? lstAccounts[0].ShippingCity : lstAccounts[0].BillingCity),
                                                                     StateProvince__c = (String.isNotBlank(lstAccounts[0].ShippingState) ? lstAccounts[0].ShippingState : lstAccounts[0].BillingState),
                                                                     PostalCode__c = (String.isNotBlank(lstAccounts[0].ShippingPostalCode) ? lstAccounts[0].ShippingPostalCode : lstAccounts[0].BillingPostalCode),
                                                                     Country__c = (String.isNotBlank(lstAccounts[0].ShippingCountry) ? lstAccounts[0].ShippingCountry : lstAccounts[0].BillingCountry),
                                                                     Phone__c = lstAccounts[0].Phone,
                                                                     OwnerId = Userinfo.getUserId());
                  AH_UDC_SystemContext.CreateObject(objPropertyaccount);
                  propertyAccountId = objPropertyaccount.Id;
               }
               else {
                  LogException('CreatePropertyAccountRecord', 'Account details not found', null, objSavepoint);
                  return '';
               }
            }
         }
         else { //If account not selected then create property account record with empty field values
            objPropertyAccount = new AH_UDC_PropertyAccount__c(
                                                               Address__c = '',
                                                               City__c = '',
                                                               StateProvince__c = '',
                                                               PostalCode__c = '',
                                                               Country__c = '',
                                                               Phone__c = '');
            AH_UDC_SystemContext.CreateObject(objPropertyAccount);
            propertyAccountId = objPropertyAccount.Id;
         }
         AH_UDC_LogHelper.Debug('CreatePropertyAccountRecord : objPropertyAccount: ' + objPropertyAccount);

         if (String.isBlank(propertyAccountId)) {
            LogException('CreatePropertyAccountRecord', 'Property Account record not inserted', null, objSavepoint);
            return '';
         }

         //Update the already created NIDoc with the AH_UDC_PropertyAccount record id
         objNIDoc = new NI_Documentation__c(
                                            Id = NewNIDocId,
                                            AH_UDC_PropertyAccount__c = propertyAccountId);
         AH_UDC_Security.UpdateObject(objNIDoc);

         AH_UDC_LogHelper.Debug('CreatePropertyAccountRecord : propertyAccountId :' + propertyAccountId);
         return propertyAccountId;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred in  Create Property Account Record - send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CreatePropertyAccountRecord', strErrorMessage, ex, objSavepoint);
         return propertyAccountId;
      }
   }

   //Create a Follow for the current user on the NI Document
   private void CreateFollowForCurrentUser(Savepoint objSavepoint) {
      try {
         //TODO:ROBDEV fix with MOCK
         if (!Test.isRunningTest()) ConnectApi.Subscription subscriptionToRecord = ConnectApi.ChatterUsers.follow(null, Userinfo.getUserId(), NewNIDocId);
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred creating a Follow for user Id (' + Userinfo.getUserId() + ') NIDocument Id (' + NewNIDocId + ') : ' + ex.getMessage();
         if (Test.isRunningTest()) {
            //Can not set IsErrorOccurred = true for test class because of following error, so directly calling LogException method of log helper class
            //System.UnsupportedOperationException: ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true)
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC, LogFunctionalArea, 'CreateFollowForCurrentUser', strErrorMessage, ex, null, null);
         } else {
            LogException('CreateFollowForCurrentUser', strErrorMessage, ex, objSavepoint);
         }
         return;
      }
   }

   //Create AH_UDC_Contact records
   private void CreateUDCContacts(Savepoint objSavepoint) {
      try {
         List<AH_UDC_Contact__c> lstUDCContact = new List<AH_UDC_Contact__c> ();

         //Add the primary UDC Contact
         lstUDCContact.add(new AH_UDC_Contact__c(Contact__c = ContactId, Document__c = NewNIDocId));

         //Add any additional UDC Contacts
         if (ContactLookupList != null && ContactLookupList.size() > 0) {
            AH_UDC_LogHelper.Debug('SendWorkbook : CreateUDCContacts - ContactLookupList.size(): ' + ContactLookupList.size());

            for (ContactLookupWrapper objContact : ContactLookupList) {
               if (String.isNotBlank(String.valueOf(objContact.Id)) && String.isBlank(objContact.ErrorMessage)) {
                  lstUDCContact.add(new AH_UDC_Contact__c(Contact__c = objContact.Id, Document__c = NewNIDocId));
               }
            }
         }

         //Insert the UDC contact records
         if (lstUDCContact.size() > 0) {
            AH_UDC_SystemContext.CreateObjects(lstUDCContact);
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred creating UDC Contacts: ' + ex.getMessage();
         LogException('CreateUDCContacts', strErrorMessage, ex, objSavepoint);
         return;
      }
   }

   //Send email to contact after sending workbook
   @TestVisible private void SendEmailToContacts() {
      try {
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         if (SelectedContact != null && String.isNotBlank(SelectedContact.Email) && String.isNotBlank(String.valueOf(NewNIDocId))) {
            List<Contact> sendContacts = new List<Contact> ();
            sendContacts.add(SelectedContact); //Prepare to email addresses list            

            if (ContactLookupList != null && ContactLookupList.size() > 0) {
               List<Contact> lstContactIds = new List<Contact> ();
               for (ContactLookupWrapper objUDCContact : ContactLookupList) {
                  if (String.isNotBlank(String.valueOf(objUDCContact.Id)) && String.isBlank(objUDCContact.ErrorMessage)) {
                     //Prepare Contact id list to pass in query for getting contact email addresses
                     lstContactIds.add(new Contact(Id = objUDCContact.Id));
                  }
               }
               if (lstContactIds.size() > 0) {
                  for (Contact objContact :[SELECT Email FROM Contact WHERE Id IN :lstContactIds]) {
                     if (String.isNotBlank(objContact.Email)) {
                        sendContacts.add(objContact); //Add additional contact's email in to email addresses list
                     }
                  }
               }
            }

            Boolean IsEmailSent = AH_UDC_SharedWithoutSharing.SendEmailToContacts(LogFunctionalArea, sendContacts, SelectedEmailTemplateId, NewNIDocId, null);
            if (IsEmailSent) {
               AH_UDC_LogHelper.Debug('Email has been sent successfully.');
            }
            else {
               IsErrorOccurred = true;
               SendEmailFailed = true;
            }
         }
      }
      catch(Exception ex) {
         IsErrorOccurred = true;

         String strErrorMessage = 'An exception occurred while sending email to the contact - Logged-In User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, 'SendEmailToContacts', strErrorMessage, Label.AH_UDC_Send_Email_Error_Message, ex);
      }
   }

   //Add new contact lookup on click of Add Contact button
   public void AddContactLookup() {
      if (ContactLookupList.size() >= AddContactLimit) return;

      ContactLookupWrapper objContact = null;
      try {
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         objContact = new ContactLookupWrapper();
         objContact.ErrorMessage = '';
         objContact.Index = ContactLookupList != null && ContactLookupList.size() > 0 ? ContactLookupList.size() : 0;
         ContactLookupList.add(objContact);
         AH_UDC_LogHelper.Debug('ContactLookupList ' + ContactLookupList);
      }
      catch(Exception ex) {
         String strErrorMessage = System.Label.AH_UDC_Send_Email_Error_Message + '- Send Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('AddContactLookup', strErrorMessage, ex, null);
      }
   }

   //Check Contact has external User or not   
   public void ValidateContact() {
      Integer lookupIndex = 0;
      Map<Id, Contact> userContactMap = null;
      Set<Id> contactIDList = null;
      try {
         AH_UDC_LogHelper.Debug('ValidateContact : SelectedContactId: ' + SelectedContactId);
         AH_UDC_LogHelper.Debug('ValidateContact : ContactLookupList: ' + ContactLookupList);
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         contactIDList = new Set<Id> ();
         for (ContactLookupWrapper CLW : ContactLookupList) {
            contactIDList.add(CLW.Id);
         }

         if (contactIDList != null && contactIDList.size() > 0) {
            userContactMap = new Map<ID, Contact> ([SELECT Id, Email
                                                   FROM Contact
                                                   WHERE Id IN :contactIDList]);
         }

         for (Integer index = 0; index<ContactLookupList.size(); index++) {
            ContactLookupWrapper objContact = ContactLookupList[index];
            if (String.isNotBlank(objContact.Id)) {

               if (userContactMap != null && userContactMap.size()> 0) {
                  SelectedUserEmail = userContactMap.get(objContact.Id).Email;
               }

               if (String.isBlank(SelectedUserEmail)) {
                  SetErrorMessageForSelectedContact(index, Label.AH_UDC_Send_Workbook_Additional_Contact_Email_Required_Message);
               } else if (ContactId.equals(objContact.Id) || IsContactAlreadySelected(index, objContact.Id)) {
                  SetErrorMessageForSelectedContact(index, Label.AH_UDC_Duplicate_Contact_Added_For_Send_Workbook_Message);
               } else {
                  //Remove error message if no error found
                  SetErrorMessageForSelectedContact(index, '');
               }
            } else {
               //Remove error message if contact value removed from lookup field or incorrect contact name text entered                        
               SetErrorMessageForSelectedContact(index, '');
            }
         }
         AH_UDC_LogHelper.Debug('ValidateContact : ContactLookupList: ' + ContactLookupList);
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred Validate Contact - send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('ValidateContact', strErrorMessage, ex, null);
      }
   }

   //Check if same contact selected more that once     
   private Boolean IsContactAlreadySelected(Integer lookupIndex, Id ContactId) {
      Integer duplicateCount = 0;
      for (Integer index = 0; index<ContactLookupList.size(); index++) {
         ContactLookupWrapper objContact = ContactLookupList[index];

         if (String.isNotBlank(ContactId) && index != lookupIndex && objContact.Id == ContactId) {
            duplicateCount++;
         }
      }
      return duplicateCount> 0;
   }

   //Set error message for selected contactgg
   private void SetErrorMessageForSelectedContact(Integer lookupIndex, String strMessage) {
      if (ContactLookupList != null && ContactLookupList.size() >= lookupIndex) {
         ContactLookupList[lookupIndex].ErrorMessage = strMessage;
      }
   }

   //Get workbook sent record deatils based on NI Doc Id
   public void GetWorkbookSentDetails() {
      Id NIDocIDForWorkbook = null;
      List<AH_UDC_Workbook__c> lstCopyWorkbookSent = null;
      try {
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;

         if (IsCopyWorkbook) {
            NIDocIDForWorkbook = SelectedNIDocIdCopy;
         }
         else {
            NIDocIDForWorkbook = SelectedNIDocIdNew;
         }

         if (String.isNotBlank(String.valueOf(NIDocIDForWorkbook))) {
            lstCopyWorkbookSent = [SELECT Id, Name, OriginalWorkbook__c, OriginalWorkbook__r.Name, OriginalWorkbook__r.Product__c, RelatedTo__r.Account__c, RelatedTo__r.AH_UDC_WorkbookDueDate__c, ParentWorkbookSent__r.Name,
                                   RelatedTo__r.AH_UDC_ChatterWorkbookAccessed__c, RelatedTo__r.AH_UDC_ChatterWorkbookCompleted__c, RelatedTo__r.AH_UDC_ChatterWorkbookStepCompleted__c
                                   FROM AH_UDC_Workbook__c
                                   WHERE RelatedTo__c = :NIDocIDForWorkbook];
            AH_UDC_LogHelper.Debug('GetWorkbookSentDetails => lstCopyWorkbookSent: ' + lstCopyWorkbookSent);
            if (lstCopyWorkbookSent != null && lstCopyWorkbookSent.size() > 0) {
               ParentWorkbookName = lstCopyWorkbookSent[0].ParentWorkbookSent__r.Name;
               m_niDoc.AH_UDC_WorkbookDueDate__c = lstCopyWorkbookSent[0].RelatedTo__r.AH_UDC_WorkbookDueDate__c;
               SelectedProduct = lstCopyWorkbookSent[0].OriginalWorkbook__r.Product__c;
               SelectedWorkbook = lstCopyWorkbookSent[0].OriginalWorkbook__c;
               IsUDCWorkbookCompleted = true;
               EnabledProductWorkbooks = new List<SelectOption> ();
               EnabledProductWorkbooks.add(new SelectOption(lstCopyWorkbookSent[0].OriginalWorkbook__c, lstCopyWorkbookSent[0].OriginalWorkbook__r.Name));
            }
         }
         else {
            m_niDoc.AH_UDC_WorkbookDueDate__c = null;
            SelectedProduct = null;
            SelectedWorkbook = null;
            SelectedContact.AccountId = null;
            EnabledProductWorkbooks = new List<SelectOption> ();
         }
      }
      catch(Exception ex) {
         AH_UDC_LogHelper.Debug('Error occurred in the method GetWorkbookSentDetails. ' + ex.getMessage() + ' at line number ' + ex.getLineNumber());
         String strErrorMessage = 'An exception occurred Get Workbook Sent Details - send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetWorkbookSentDetails', strErrorMessage, ex, null);
      }
      finally {
         lstCopyWorkbookSent = null;
      }
   }

   //Log exception and display error message to user
   private void LogException(String strMethodName, String strErrorMessage, Exception exc, Savepoint objSavepoint) {
      IsErrorOccurred = true;
      AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, strMethodName, strErrorMessage, System.Label.AH_UDC_Common_Error_Message_Backend, exc, objSavepoint);
   }

   //This method is used by a client side actionfunction to log AH_UDC_Log entries that couldn't be created by the page load due to SOQL DML retrictions
   public void ServerLogMessages() {
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages');
      try {
         if (PageLoadLogMessages != null && PageLoadLogMessages.size() > 0) {
            insert(PageLoadLogMessages);
         }
         PageLoadLogMessages = new List<AH_UDC_Log__c> ();

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
      }
      catch(Exception ex) {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages - Exception: ' + ex);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'ServerLogMessages',
                              'An exception occurred logging Page Load AH_UDC_Log entries',
                              ex, null, null);
      }
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}