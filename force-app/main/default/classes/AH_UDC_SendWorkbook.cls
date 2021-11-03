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
   public String SelectedProduct { get; set; }
   public Boolean IsCommunityUserCreated { get; set; }
   public Boolean IsContactHasEmail { get; set; }
   public Boolean IsCopyWorkbook { get; set; } // This is for New UDC Copy Exisiting Workbook  
   public Boolean IsUDCWorkbookAccessed { get; set; } //This is for Workbook Accessed  status flags
   public Boolean IsUDCWorkbookCompleted { get; set; } //This is for Workbook Completed status flags
   public Boolean IsUDCWorkbookStepCompleted { get; set; } //This is for Workbook Step Completed status flags
   public String SelectedWorkbook { get; set; }
   public String NiDocumentName { get; set; }
   public Date DueDate { get; set; }
   public Id SelectedEmailTemplateId { get; set; }
   public String SelectedEmailTemplateName { get; set; }
   public List<SelectOption> WorkbookProducts { get; set; }
   public List<SelectOption> EnabledProductWorkbooks { get; set; }
   public Contact SelectedContact { get; set; }
   public Id SelectedNIDocIdCopy { get; set; }
   public Id SelectedNIDocIdNew { get; set; }
   public String ParentWorkbookName { get; set; }
   public Id ContactId { get; set; }
   public Id NewNIDocId { get; set; } //New inserted NI Doc Id
   public Boolean IsErrorOccurred { get; set; } //To display error on page 
   public Boolean IsErrorOccurredInEmail { get; set; } //It will be true only if error occurred while sending an email
   public String UserLocal { get; set; }
   public String DateFormat { get; set; }
   public Id SelectedContactId { get; set; }
   public List<ContactLookupWrapper> ContactLookupList { get; set; }
   public String SelectedUserEmail { get; set; }
   public Integer AddContactLimit { get; set; } //Maximum number of contacts allowed
   //List of steps for which copy of form responses is pending
   List<AH_UDC_WorkbookStep__c> CopyPendingStepList { get; set; } { CopyPendingStepList = new List<AH_UDC_WorkbookStep__c> (); }
   //Map of SortOrder and StepId for which copy of form responses is pending
   Map<Decimal, Id> MapNewInsertedStepIdAndSortOrder { get; set; } { MapNewInsertedStepIdAndSortOrder = new Map<Decimal, Id> (); }
   //Map of Shared or Central FormId and ResponseId for which copy of form responses is pending
   @TestVisible Map<Id, Id> MapSharedOrCentralFormIdResponseId { get; set; } { MapSharedOrCentralFormIdResponseId = new Map<Id, Id> (); }
   public Id propertyAccountId { get; set; }

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

   //This is used client side to determine if there are some pending steps to copy form responses
   public Boolean HasPendingStepsToCopy {
      get {
         return CopyPendingStepList != null && CopyPendingStepList.size() > 0
         && MapNewInsertedStepIdAndSortOrder != null && MapNewInsertedStepIdAndSortOrder.size() > 0;
      }
   }

   public AH_UDC_SendWorkbook(ApexPages.StandardController controller) {
      List<User> externalUser = null;
      IsCommunityUserCreated = false;
      IsErrorOccurred = false;
      IsErrorOccurredInEmail = false;
      try {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;
         ContactLookupList = new List<ContactLookupWrapper> ();
         IsUDCWorkbookAccessed = false;
         IsUDCWorkbookCompleted = true;
         IsUDCWorkbookStepCompleted = false;
         IsCopyWorkbook = false;
         SelectedContact = new Contact();
         ContactId = apexpages.currentpage().getparameters().get('id');
         UserLocal = UserInfo.getLocale();
         DateFormat = AH_UDC_DateFormat.GetDateFormat();
         ParentWorkbookName = '';
         AddContactLimit = AH_UDC_ConfigHelper.GetInteger('AH_UDC_AddContactLimit', 5); // Integer.valueOf(Label.AH_UDC_AddContactLimit);                     

         if (String.isNotBlank(String.valueOf(ContactId))) {
            //Get current contact's details
            List<Contact> lstContacts = new List<Contact> ([SELECT Name, Id, AccountId, Email
                                                           FROM Contact
                                                           WHERE Id = :ContactId AND Status__c = 'Active']);
            if (lstContacts.size() == 0) {
               LogException('Constructor', 'Contact record not found', null, null);
               return;
            }

            SelectedContact = lstContacts[0];
            if (String.isNotBlank(SelectedContact.Email)) { //Check Contact has email address or not
               IsContactHasEmail = true;
               GetProductList(); //Get available product list
               if (IsErrorOccurred == false) { //If error occurred in GetEnabledProductWorkbooks() then do not call other methods
                  GetDefaultEmailTemplateDetails(); //Get default email template details to fill in the lookup field
               }
            }
            else {
               IsContactHasEmail = false;
            }
         }
         else {
            LogException('Constructor', 'Contact Id not found', null, null);
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred loading send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('Constructor', strErrorMessage, ex, null);
      }
      finally {
         externalUser = null;
         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
      }
   }

   //Get available product list
   public void GetProductList() {
      Schema.DescribeFieldResult fieldResult = null;
      List<Schema.PicklistEntry> pickListEntry = null;
      try {
         WorkbookProducts = new List<SelectOption> ();
         fieldResult = AH_UDC_Workbook__c.Product__c.getDescribe();

         if (fieldResult == null) {
            LogException('GetProductList', 'Metadata details not found for the field - Product__c', null, null);
            return;
         }

         pickListEntry = fieldResult.getPicklistValues();
         if (pickListEntry != null && pickListEntry.size() > 0) {
            WorkbookProducts.add(new SelectOption('Please select', 'Please select'));
            for (Schema.PicklistEntry option : pickListEntry) {
               WorkbookProducts.add(new SelectOption(option.getValue(), option.getLabel()));
            }
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred getting product list - send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetProductList', strErrorMessage, ex, null);
      }
   }

   //Get enabled workbook list for selected product
   public void GetEnabledProductWorkbooks() {
      Id workbookRecordTypeId = null;
      List<AH_UDC_Workbook__c> lstWorkbook = null;
      try {
         EnabledProductWorkbooks = new List<SelectOption> ();
         workbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
         if (String.isNotBlank(String.valueOf(workbookRecordTypeId))) {
            for (AH_UDC_Workbook__c option :[SELECT Name, Product__c, Id
                 FROM AH_UDC_Workbook__c
                 WHERE RecordTypeId = :workbookRecordTypeId AND Product__c = :SelectedProduct AND Enabled__c = :true]) {
               EnabledProductWorkbooks.add(new SelectOption(option.Id, option.Name));
            }
         }
         else {
            LogException('GetEnabledProductWorkbooks', 'AH_UDC_Workbook Record Type No Found', null, null);
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred getting enable product workbook - send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetEnabledProductWorkbooks', strErrorMessage, ex, null);
      }
   }

   //Get default email template details based on developer name
   public void GetDefaultEmailTemplateDetails() {
      List<EmailTemplate> lstEmailTemplates = null;
      try {
         //Get default email template details from the object based on developer name
         lstEmailTemplates = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = :Label.AH_UDC_Send_Workbook_Default_Email_Template];

         if (lstEmailTemplates != null && lstEmailTemplates.size() > 0) {
            SelectedEmailTemplateId = lstEmailTemplates[0].Id;
            SelectedEmailTemplateName = lstEmailTemplates[0].Name;
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred getting Default Email Template Details - send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetDefaultEmailTemplateDetails', strErrorMessage, ex, null);
      }
   }

   //Create community users before sending workbooks
   public void CreateCommunityUsers() {
      try
      {
         //NOTE: This method calls DML executed against SETUP objects ... thus no other objects can be inserted (like Log Messages)

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
                  if (!IsAddUserCreated)
                  {
                     IsAllUsersCreated = false;
                  }
               }
            }
         }
         IsCommunityUserCreated = IsAllUsersCreated;
      }
      catch(Exception ex)
      {
         String strErrorMessage = 'An exception occurred creating community user - send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CreateCommunityUsers', strErrorMessage, ex, null);
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
         if (String.isBlank(SelectedWorkbook)) {
            LogException('SendWorkbook', 'Workbook not selected', null, null);
            return;
         }

         //The the account ID for the active contact
         accountId = SelectedContact.AccountId;

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
         //Do not proceed further if error occured or if ResponseQA records exceed governor limit
         if (IsErrorOccurred || HasPendingStepsToCopy) return; //CreateWorkbookStepSentRecord() will show the Error to the user and the rollback will occur if it can't insert a record

         CreateFollowForCurrentUser(objSavePoint);
         AH_UDC_LogHelper.Debug('SendWorkbook : CreateFollowForCurrentUser - IsErrorOccurred: ' + IsErrorOccurred);
         if (IsErrorOccurred) return; //CreateFollowForCurrentUser() will show the Error to the user and the rollback will occur if it can't insert a record

         //Create primary AH_UDC_Contact record
         CreateUDCContacts(objSavePoint);
         AH_UDC_LogHelper.Debug('SendWorkbook : CreateUDCContacts - IsErrorOccurred: ' + IsErrorOccurred);
         if (IsErrorOccurred) return; //CreateUDCContacts() will show the Error to the user and the rollback will occur if it can't insert a record

         SendEmailToContacts();
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
         insert objNIDoc;
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
               if (objWorkbookClone != null)
               {
                  insert objWorkbookClone;
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
            List<AH_UDC_WorkbookStep__c> lstOriginalWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ([SELECT Id, Name, CurrencyIsoCode, Description__c, Enabled__c, Form__c, Help__c, Prerequisite_Step__c,
                                                                                                      RecordTypeId, SortOrder__c, StepCompleted__c, StepStatus__c, URL__c, StepCompletedBy__c, Workbook__c,
                                                                                                      Form__r.FormType__c
                                                                                                      FROM AH_UDC_WorkbookStep__c
                                                                                                      WHERE Workbook__c = :originalWorkbookId AND RecordTypeId = :workbookRecordTypeId
                                                                                                      AND Enabled__c = true //Only Copy enabled steps to Sent Workbook
                                                                                                      ORDER BY SortOrder__c]);
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
               insert lstNewWorkbookSteps;

               for (AH_UDC_WorkbookStep__c objInsertedStep : lstNewWorkbookSteps) {
                  MapNewInsertedStepIdAndSortOrder.put(objInsertedStep.SortOrder__c, objInsertedStep.Id);
                  if (stepSortOrderMapPrereq.containsKey(objInsertedStep.SortOrder__c)) {
                     Decimal sortOrderOfPrereqStep = stepSortOrderMapPrereq.get(objInsertedStep.SortOrder__c);
                     //Get prerequisite stepid based on it's sort order
                     objInsertedStep.Prerequisite_Step__c = MapNewInsertedStepIdAndSortOrder.get(sortOrderOfPrereqStep);
                  }
               }

               AH_UDC_LogHelper.Debug('CreateWorkbookStepSentRecord => MapNewInsertedStepIdAndSortOrder: ' + MapNewInsertedStepIdAndSortOrder);
               AH_UDC_LogHelper.Debug('CreateWorkbookStepSentRecord => stepSortOrderMapPrereq: ' + stepSortOrderMapPrereq);
               if (stepSortOrderMapPrereq != null && stepSortOrderMapPrereq.size() > 0) {
                  //Update inserted steps to set prerequisite step
                  update lstNewWorkbookSteps;
               }

               //Copy Responses and ResponseQA records for inserted steps
               CopyResponseAndResponseQARecords(objSavepoint, lstOriginalWorkbookSteps);
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

   //Copy Response and ResponseQA records for new inserted steps
   private void CopyResponseAndResponseQARecords(Savepoint objSavepoint, List<AH_UDC_WorkbookStep__c> lstOriginalWorkbookSteps) {
      try {
         //Get Central and Shared Response/ResponseQA Records that need to be inserted
         {
            //Determine which forms are Shared/Central
            Set<Id> sharedOrCentralFormIds = new Set<Id> ();
            for (AH_UDC_WorkbookStep__c wbStep : lstOriginalWorkbookSteps)
            {
               if (wbStep.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_CENTRAL || wbStep.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_SHARED)
               {
                  sharedOrCentralFormIds.add(wbStep.Form__c);
               }
            }

            AH_UDC_LogHelper.Debug('CopyResponseAndResponseQARecords : sharedOrCentralFormIds.size(): ' + sharedOrCentralFormIds.size());
            if (sharedOrCentralFormIds.size() > 0)
            {
               //Find Most Recent Response for each form ... with the same Property Account
               //Get the highest response ID ... flagged as Is Most Recent ... for each Form
               AH_UDC_LogHelper.Debug('CopyResponseAndResponseQARecords : propertyAccountId: ' + propertyAccountId);
               AggregateResult[] groupedResults = [SELECT WorkbookStep__r.Form__c FormId, max(Id) maxResponseId
                                                   FROM AH_UDC_Response__c
                                                   WHERE WorkbookStep__r.Form__c IN :sharedOrCentralFormIds
                                                   AND IsMostRecentResponse__c = true
                                                   AND WorkbookStep__r.Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c = :propertyAccountId
                                                   GROUP BY WorkbookStep__r.Form__c];
               //Add the Responses to the list of those needing to be copied
               AH_UDC_LogHelper.Debug('CopyResponseAndResponseQARecords : groupedResults.size(): ' + groupedResults.size());
               for (AggregateResult ar : groupedResults) {
                  MapSharedOrCentralFormIdResponseId.put((Id) ar.get('FormId'), (Id) ar.get('maxResponseId'));
               }
            }
         }

         AH_UDC_LogHelper.Debug('CopyResponseAndResponseQARecords => IsCopyWorkbook: ' + IsCopyWorkbook);
         AH_UDC_LogHelper.Debug('CopyResponseAndResponseQARecords => MapSharedOrCentralFormIdResponseId: ' + MapSharedOrCentralFormIdResponseId);
         if (IsCopyWorkbook || MapSharedOrCentralFormIdResponseId.size() > 0) {
            Integer intTotalResponseQARecords;
            if (IsCopyWorkbook) ///Get Product,Shared and Central Responses
            {
               intTotalResponseQARecords = [SELECT COUNT()
                                            FROM AH_UDC_ResponseQA__c
                                            //Copy data only of the steps that are associated to forms with type "Product"
                                            WHERE(Response__r.WorkbookStep__r.Form__r.FormType__c = :AH_UDC_Constants.FORM_TYPE_PRODUCT
                                                  AND Response__r.WorkbookStep__c IN :lstOriginalWorkbookSteps
                                                  AND Response__r.IsMostRecentResponse__c = true)
                                            //This includes responses for Central or Shared forms
                                            OR Response__r.Id IN :MapSharedOrCentralFormIdResponseId.values()];
            }
            else
            {
               //Get Only Shared and Central Responses
               intTotalResponseQARecords = [SELECT COUNT()
                                            FROM AH_UDC_ResponseQA__c
                                            WHERE
                                            //This includes responses for Central or Shared forms
                                            Response__r.Id IN :MapSharedOrCentralFormIdResponseId.values()];
            }
            AH_UDC_LogHelper.Debug('CopyResponseAndResponseQARecords => Total Response QA Records Need To Insert: ' + intTotalResponseQARecords);

            Integer intTotalRecordsAllowedToInsert = Limits.getLimitDmlRows() - 1000;
            //Can not create 9K records in test class so decrease limit
            if(Test.isRunningTest()) intTotalRecordsAllowedToInsert = 4000;
            AH_UDC_LogHelper.Debug('CopyResponseAndResponseQARecords => Maximum Records Allowed To Insert in a Single DML Statement: ' + intTotalRecordsAllowedToInsert);

            //Check for total records allowed in a single DML statement and minus a buffer of 1000 records to allow for other records being written (ex. AH_UDC_Response)
            if (intTotalResponseQARecords > intTotalRecordsAllowedToInsert) {
               //Delayed writing of responses via client side calls
               if (IsCopyWorkbook) ///Get Product,Shared and Central Responses
               {
                  //Include steps which has responses available for 'Product' forms
                  for (AH_UDC_Response__c objResponse :
                       [SELECT WorkbookStep__c, WorkbookStep__r.SortOrder__c, WorkbookStep__r.Form__c
                       FROM AH_UDC_Response__c
                       WHERE WorkbookStep__r.Form__r.FormType__c = : AH_UDC_Constants.FORM_TYPE_PRODUCT
                       AND WorkbookStep__c IN : lstOriginalWorkbookSteps
                       AND IsMostRecentResponse__c = true])
                  {
                     //Prepare list of only those steps which has responses available
                     CopyPendingStepList.add(new AH_UDC_WorkbookStep__c(Id = objResponse.WorkbookStep__c, SortOrder__c = objResponse.WorkbookStep__r.SortOrder__c, Form__c = objResponse.WorkbookStep__r.Form__c));
                  }
               }

               //Include steps which has forms Shared or Central
               for (AH_UDC_WorkbookStep__c objStep : lstOriginalWorkbookSteps) {
                  if (MapSharedOrCentralFormIdResponseId.get(objStep.Form__c) != null) {
                     //Add step only if response exist for Shared or Central forms
                     CopyPendingStepList.add(new AH_UDC_WorkbookStep__c(Id = objStep.Id, SortOrder__c = objStep.SortOrder__c, Form__c = objStep.Form__c));
                  }
               }
               AH_UDC_LogHelper.Debug('CopyResponseAndResponseQARecords => CopyPendingStepList: ' + CopyPendingStepList);
            }
            else {
               Set<Id> sharedOrCentralResponseIds = new Set<Id> ();
               sharedOrCentralResponseIds.addAll(MapSharedOrCentralFormIdResponseId.values());
               //Write Responses immediately in this transaction
               CreateStepResponseRecords(objSavepoint, lstOriginalWorkbookSteps, sharedOrCentralResponseIds);
            }
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CopyResponseAndResponseQARecords', strErrorMessage, ex, objSavepoint);
      }
   }

   //Create responses record based on step ids provided
   private void CreateStepResponseRecords(Savepoint objSavepoint, List<AH_UDC_WorkbookStep__c> lstOriginalWorkbookSteps, Set<Id> sharedOrCentralResponseIds) {
      List<AH_UDC_Response__c> lstOriginalResponses = null;
      List<AH_UDC_Response__c> lstNewResponses = null;
      AH_UDC_Response__c objResponseNew = null;
      try {
         AH_UDC_LogHelper.Debug('CreateStepResponseRecords => lstOriginalWorkbookSteps: ' + lstOriginalWorkbookSteps);
         AH_UDC_LogHelper.Debug('CreateStepResponseRecords => MapNewInsertedStepIdAndSortOrder: ' + MapNewInsertedStepIdAndSortOrder);
         AH_UDC_LogHelper.Debug('CreateStepResponseRecords => sharedOrCentralResponseIds: ' + sharedOrCentralResponseIds);
         if (lstOriginalWorkbookSteps != null && lstOriginalWorkbookSteps.size() > 0
             && MapNewInsertedStepIdAndSortOrder != null && MapNewInsertedStepIdAndSortOrder.size() > 0) {
            //Get most recent responses bsed on step ids
            lstOriginalResponses = new List<AH_UDC_Response__c> ([SELECT Id, RecordTypeId, WorkbookStep__r.SortOrder__c, Name, IsMostRecentResponse__c, Responded__c, Responder__c,
                                                                 WorkbookStep__r.Form__c, WorkbookStep__r.Form__r.FormType__c
                                                                 FROM AH_UDC_Response__c
                                                                 WHERE(WorkbookStep__c = :lstOriginalWorkbookSteps
                                                                       AND IsMostRecentResponse__c = true
                                                                       //Copy data only of the steps that are associated to forms with type "Product"
                                                                       AND WorkbookStep__r.Form__r.FormType__c = :AH_UDC_Constants.FORM_TYPE_PRODUCT)
                                                                 //This includes responses for Central or Shared forms
                                                                 OR Id IN :sharedOrCentralResponseIds
                                                                 ]);
            AH_UDC_LogHelper.Debug('CreateStepResponseRecords => lstOriginalResponses: ' + lstOriginalResponses);

            //Build a map for Shared/Central Form Id to Workbook Sort Order
            Map<ID, Decimal> mapFormIdToSortOrder = new Map<ID, Decimal> ();
            for (AH_UDC_Response__c objOriginalResponse : lstOriginalResponses)
            {
               if (objOriginalResponse.WorkbookStep__r.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_SHARED ||
                   objOriginalResponse.WorkbookStep__r.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_CENTRAL)
               {
                  for (AH_UDC_WorkbookStep__c findSharedOrCentralWBStep : lstOriginalWorkbookSteps)
                  {
                     if (findSharedOrCentralWBStep.Form__c == objOriginalResponse.WorkbookStep__r.Form__c)
                     {
                        mapFormIdToSortOrder.put(findSharedOrCentralWBStep.Form__c, findSharedOrCentralWBStep.SortOrder__c);
                        break; //A workbook cannot have the same form for multiple steps
                     }
                  }
               }
            }

            //Use original responses to build new responses
            if (lstOriginalResponses != null && lstOriginalResponses.size() > 0) {
               lstNewResponses = new List<AH_UDC_Response__c> ();
               AH_UDC_LogHelper.Debug('CreateStepResponseRecords => mapFormIdToSortOrder :: ' + mapFormIdToSortOrder);
               for (AH_UDC_Response__c objOriginalResponse : lstOriginalResponses) {
                  objResponseNew = new AH_UDC_Response__c();
                  objResponseNew.RecordTypeId = objOriginalResponse.RecordTypeId;
                  if (objOriginalResponse.WorkbookStep__r.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_PRODUCT)
                  {
                     objResponseNew.WorkbookStep__c = MapNewInsertedStepIdAndSortOrder.get(objOriginalResponse.WorkbookStep__r.SortOrder__c); //Set new inserted step id
                  }
                  else //Shared or Central
                  {
                     objResponseNew.WorkbookStep__c = MapNewInsertedStepIdAndSortOrder.get(mapFormIdToSortOrder.get(objOriginalResponse.WorkbookStep__r.Form__c));
                  }
                  //This field should be deafult to true since the workbook is new (the trigger will make sure this is set correct anyway) 
                  objResponseNew.IsMostRecentResponse__c = true;
                  lstNewResponses.add(objResponseNew);
               }

               //Create ResponseQA records for the new Response records
               if (lstNewResponses != null && lstNewResponses.size() > 0) {
                  AH_UDC_LogHelper.Debug('CreateStepResponseRecords : lstNewResponses.size(): ' + lstNewResponses.size());
                  insert lstNewResponses;

                  //Copy ResponseQA records for new added response records
                  CreateStepResponseQARecords(objSavepoint, lstOriginalResponses, lstNewResponses, mapFormIdToSortOrder);
               }
            }
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CreateStepResponseRecords', strErrorMessage, ex, objSavepoint);
      }
   }

   //Copy ResponseQA records based on the response records
   private void CreateStepResponseQARecords(Savepoint objSavepoint, List<AH_UDC_Response__c> lstOriginalResponses, List<AH_UDC_Response__c> lstNewResponses, Map<ID, Decimal> mapFormIdToSortOrder) {
      try {
         AH_UDC_LogHelper.Debug('CreateResponseQARecords => lstOriginalResponses.size(): ' + (lstOriginalResponses != null ? lstOriginalResponses.size() : 0));
         if (lstOriginalResponses != null && lstOriginalResponses.size() > 0
             && lstNewResponses != null && lstNewResponses.size() > 0) {
            Map<Id, Id> stepIdResponseIdMap = new Map<Id, Id> ();
            for (AH_UDC_Response__c objNewResponse : lstNewResponses) {
               //Create map of new StepId and new ResponseId
               stepIdResponseIdMap.put(objNewResponse.WorkbookStep__c, objNewResponse.Id);
            }
            AH_UDC_LogHelper.Debug('CreateResponseQARecords => stepIdResponseIdMap: ' + stepIdResponseIdMap);

            List<AH_UDC_ResponseQA__c> lstNewResponsesQA = new List<AH_UDC_ResponseQA__c> ();
            for (AH_UDC_ResponseQA__c objOriginalResponseQA :
                 [SELECT Id, RecordTypeId, Response__c, Response__r.WorkbookStep__r.SortOrder__c, Name, AnswerField__c, Answer__c, QuestionField__c, Question__c,
                 Response__r.WorkbookStep__r.Form__c, Response__r.WorkbookStep__r.Form__r.FormType__c
                 FROM AH_UDC_ResponseQA__c
                 WHERE Response__c IN : lstOriginalResponses])
            {

               //Get new StepId based on sort order
               Id newStepId;
               if (objOriginalResponseQA.Response__r.WorkbookStep__r.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_PRODUCT)
               {
                  newStepId = MapNewInsertedStepIdAndSortOrder.get(objOriginalResponseQA.Response__r.WorkbookStep__r.SortOrder__c);
               }
               else //Shared or Central
               {
                  newStepId = MapNewInsertedStepIdAndSortOrder.get(mapFormIdToSortOrder.get(objOriginalResponseQA.Response__r.WorkbookStep__r.Form__c));
               }

               Id NewResponseId = stepIdResponseIdMap.get(newStepId); //Get new ResponseId based on StepId
               AH_UDC_ResponseQA__c objNewResponseQA = new AH_UDC_ResponseQA__c();
               objNewResponseQA.RecordTypeId = objOriginalResponseQA.RecordTypeId;
               objNewResponseQA.Response__c = NewResponseId;
               objNewResponseQA.AnswerField__c = objOriginalResponseQA.AnswerField__c;
               objNewResponseQA.Answer__c = objOriginalResponseQA.Answer__c;
               objNewResponseQA.QuestionField__c = objOriginalResponseQA.QuestionField__c;
               objNewResponseQA.Question__c = objOriginalResponseQA.Question__c;
               lstNewResponsesQA.add(objNewResponseQA);
            }
            if (lstNewResponsesQA != null && lstNewResponsesQA.size() > 0) {
               System.debug('CreateResponseQARecords => lstNewResponsesQA.size(): ' + lstNewResponsesQA.size());
               insert lstNewResponsesQA;
            }
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CreateResponseQARecords', strErrorMessage, ex, objSavepoint);
      }
   }

   //Copy step form responses one by one
   public void CopyResponsesStepByStep() {
      List<AH_UDC_WorkbookStep__c> lstOriginalWorkbookSteps = null;
      Set<Id> sharedOrCentralResponseIds = null;
      SavePoint objSavePoint = null;
      Id FormId = null;
      try {
         if (HasPendingStepsToCopy) {
            lstOriginalWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ();
            sharedOrCentralResponseIds = new Set<Id> ();
            objSavePoint = Database.setSavepoint();

            lstOriginalWorkbookSteps.add(CopyPendingStepList.get(0)); //Prepare list of only one step
            FormId = CopyPendingStepList.get(0).Form__c;
            AH_UDC_LogHelper.Debug('CopyResponsesStepByStep => FormId: ' + FormId);
            AH_UDC_LogHelper.Debug('MapSharedOrCentralFormIdResponseId.get(FormId) => ' + MapSharedOrCentralFormIdResponseId.get(FormId));
            if (String.isNotBlank(String.valueOf(FormId)) && MapSharedOrCentralFormIdResponseId.get(FormId) != null) {
               //If step has form associated of type Shared or Central then prepare set of ResponseId to pass as a paramater
               sharedOrCentralResponseIds.add(MapSharedOrCentralFormIdResponseId.get(FormId));
            }

            //Copy form responses of first step from the list of pending steps
            CreateStepResponseRecords(objSavePoint, lstOriginalWorkbookSteps, sharedOrCentralResponseIds);
         }
         else {
            LogException('CopyResponsesStepByStep', 'No pending steps found - CopyResponsesStepByStep Or MapNewInsertedStepIdAndSortOrder is empty', null, objSavePoint);
         }

         if (IsErrorOccurred != true) { //Proceed further only if error not occurred in the execution of method CreateStepResponseRecords
            CopyPendingStepList.remove(0); //Remove copied step from pending steps list

            if (CopyPendingStepList.size() == 0) {
               //If copy of responses for all steps is done then create follow record, create UDC Contact record and send email to the contact
               CreateFollowForCurrentUser(objSavePoint);
               AH_UDC_LogHelper.Debug('CopyResponsesStepByStep : CreateFollowForCurrentUser - IsErrorOccurred: ' + IsErrorOccurred);
               if (IsErrorOccurred) return; //CreateFollowForCurrentUser() will show the Error to the user and the rollback will occur if it can't insert a record

               //Create primary AH_UDC_Contact record
               CreateUDCContacts(objSavePoint);
               AH_UDC_LogHelper.Debug('CopyResponsesStepByStep : CreateUDCContacts - IsErrorOccurred: ' + IsErrorOccurred);
               if (IsErrorOccurred) return;

               SendEmailToContacts();

               AH_UDC_LogHelper.Debug('CopyResponsesStepByStep : SendEmailToContacts - IsErrorOccurred: ' + IsErrorOccurred);
               AH_UDC_LogHelper.Debug('CopyResponsesStepByStep : SendEmailToContacts - IsErrorOccurredInEmail: ' + IsErrorOccurredInEmail);
            }
         }
         else {
            UpdateWorkbookSentStatusToFailed(objSavePoint);
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CopyResponsesStepByStep', strErrorMessage, ex, objSavepoint);
         UpdateWorkbookSentStatusToFailed(null);
      }
   }

   //Change workbook sent status to failed in case when it is failed to copy step responses
   private void UpdateWorkbookSentStatusToFailed(SavePoint objSavePoint) {
      List<AH_UDC_Workbook__c> lstWorkbooks = null;
      try {
         CopyPendingStepList.clear();
         if (String.isNotBlank(NewNIDocId)) {
            AH_UDC_LogHelper.Debug('UpdateWorkbookSentStatusToFailed() => Getting details based on New NI Doc Id to update workbook sent status failed');
            lstWorkbooks = [SELECT Id, SentStatus__c FROM AH_UDC_Workbook__c WHERE RelatedTo__c = :NewNIDocId];
            AH_UDC_LogHelper.Debug('UpdateWorkbookSentStatusToFailed() => lstWorkbooks: ' + lstWorkbooks);
            if (lstWorkbooks.size() == 0) {
               LogException('UpdateWorkbookSentStatusToFailed', 'Workbook details not found - objWorkbook is null', null, objSavePoint);
               return;
            }

            //Change Workbook Sent Status to Failed
            lstWorkbooks[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_FAILED_TO_SEND;
            AH_UDC_LogHelper.Debug('Workbook Sent Status is Updated to \'Failed To Send\'');

            update lstWorkbooks[0];
         }
         else {
            LogException('UpdateWorkbookSentStatusToFailed', 'NewNIDocId is empty', null, objSavePoint);
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('UpdateWorkbookSentStatusToFailed', strErrorMessage, ex, objSavePoint);
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
            lstPropertyAccounts = new List<AH_UDC_PropertyAccount__c> ([SELECT Id
                                                                       FROM AH_UDC_PropertyAccount__c
                                                                       WHERE Account__r.Id = :accountId]);
            if (lstPropertyAccounts.size() > 0) {
               //Map inserted NI Doc record with existing property account record
               propertyAccountId = lstPropertyAccounts[0].Id;
            }
            else {
               //Get details of selected account from the object and use them to create AH_UDC_PropertyAccount record
               lstAccounts = new List<Account> ([SELECT Id, Name, BillingAddress, BillingStreet, BillingState, BillingCity, BillingPostalCode, BillingCountry, Phone
                                                FROM Account
                                                WHERE Id = :accountId]);
               if (lstAccounts.size() > 0) {
                  objPropertyaccount = new AH_UDC_PropertyAccount__c(Account__c = lstAccounts[0].Id, PropertyName__c = lstAccounts[0].Name, AddressLine1__c = lstAccounts[0].BillingStreet, City__c = lstAccounts[0].BillingCity, StateProvince__c = lstAccounts[0].BillingState, PostalCode__c = lstAccounts[0].BillingPostalCode, Country__c = lstAccounts[0].BillingCountry, Phone__c = lstAccounts[0].Phone, OwnerId = Userinfo.getUserId());
                  insert objPropertyaccount;
                  propertyAccountId = objPropertyaccount.Id;
               }
               else {
                  LogException('CreatePropertyAccountRecord', 'Account details not found', null, objSavepoint);
                  return '';
               }
            }
         }
         else { //If account not selected then create property account record with empty field values
            objPropertyaccount = new AH_UDC_PropertyAccount__c(
                                                               AddressLine1__c = '',
                                                               City__c = '',
                                                               StateProvince__c = '',
                                                               PostalCode__c = '',
                                                               Country__c = '',
                                                               Phone__c = '');
            insert objPropertyaccount;
            propertyAccountId = objPropertyaccount.Id;
         }
         AH_UDC_LogHelper.Debug('CreatePropertyAccountRecord : objPropertyaccount: ' + objPropertyaccount);

         if (String.isBlank(propertyAccountId)) {
            LogException('CreatePropertyAccountRecord', 'Property Account record not inserted', null, objSavepoint);
            return '';
         }

         //Update the already craeted NIDoc with the AH_UDC_PropertyAccount record id
         objNIDoc = new NI_Documentation__c(
                                            Id = NewNIDocId,
                                            AH_UDC_PropertyAccount__c = propertyAccountId);
         update objNIDoc;

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
      try
      {
         ConnectApi.Subscription subscriptionToRecord = ConnectApi.ChatterUsers.follow(null, Userinfo.getUserId(), NewNIDocId);
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred creating a Follow for user Id (' + Userinfo.getUserId() + ') NIDocument Id (' + NewNIDocId + ') : ' + ex.getMessage();
         if(Test.isRunningTest()) {
            //Can not set IsErrorOccured = true for test class because of following error, so directly calling LogException method of log helpre class
            //System.UnsupportedOperationException: ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true)
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC, LogFunctionalArea, 'CreateFollowForCurrentUser', strErrorMessage, ex, null, null);
         }
         else {
            LogException('CreateFollowForCurrentUser', strErrorMessage, ex, objSavepoint);
         }
         return;
      }
   }

   //Create a Follow for the current user on the NI Document
   private void CreateUDCContacts(Savepoint objSavepoint) {
      try
      {
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
            insert lstUDCContact;
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred creating UDC Contacts: ' + ex.getMessage();
         LogException('CreateUDCContacts', strErrorMessage, ex, objSavepoint);
         return;
      }
   }

   //Send email to contact after sending workbook
   private void SendEmailToContacts() {
      List<string> lstToAddresses = null;
      Messaging.SingleEmailMessage objEmail = null;
      List<Messaging.SingleEmailMessage> lstEmails = null;
      Messaging.SendEmailResult[] results = null;
      List<Contact> lstContacts = null;
      try {
         if (SelectedContact != null && String.isNotBlank(SelectedContact.Email) && String.isNotBlank(NewNIDocId)) {
            lstToAddresses = new List<string> ();
            lstToAddresses.add(SelectedContact.Email); //Prepare to email addresses list            

            if (ContactLookupList != null && ContactLookupList.size() > 0) {
               lstContacts = new List<Contact> ();
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

            //Prerender email so that we can do replacement of URL
            objEmail = Messaging.renderStoredEmailTemplate(SelectedEmailTemplateId, SelectedContact.Id, NewNIDocId);
            //Replace Community Portal URL
            objEmail.setHtmlBody(objEmail.getHtmlBody().replace(
                                                                AH_UDC_ConfigHelper.GetString('AH_UDC_EmailTemplatePortalUrlPlaceholder', ''),
                                                                AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityPortalUrl', '')));

            //Set to whom the email will be sent
            objEmail.setToAddresses(lstToAddresses);
            lstEmails = new List<Messaging.SingleEmailMessage> ();
            lstEmails.add(objEmail);
            results = Messaging.sendEmail(lstEmails, false);
            if (results != null && results.size() > 0 && results[0].success) {
               AH_UDC_LogHelper.Debug('The email has been sent successfully.');
            }
            else {
               IsErrorOccurred = true;
               IsErrorOccurredInEmail = true;
               AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, 'SendEmailToContacts', 'Error in Sending Email : ' + results[0].getErrors(), Label.AH_UDC_Send_Email_Error_Message, null);
            }
         }
      }
      catch(Exception ex) {
         IsErrorOccurred = true;
         IsErrorOccurredInEmail = true;
         String strErrorMessage = 'An exception occured while sending email to the contact - Logged-In User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, 'SendEmailToContacts', strErrorMessage, Label.AH_UDC_Send_Email_Error_Message, ex);
      }
   }

   //Add new contact lookup oon click of Add Contact button
   public void AddContactLookup() {
      ContactLookupWrapper objContact = null;
      try {
         objContact = new ContactLookupWrapper();
         objContact.ErrorMessage = '';
         objContact.Index = ContactLookupList != null && ContactLookupList.size() > 0 ? ContactLookupList.size() : 0;
         ContactLookupList.add(objContact);
         AH_UDC_LogHelper.Debug('ContactLookupList ' + ContactLookupList);
      }
      catch(Exception ex) {
         String strErrorMessage = System.Label.AH_UDC_Send_Email_Error_Message + '- send workbook page for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('SendEmailToContacts', strErrorMessage, ex, null);
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
         for (ContactLookupWrapper CLW : ContactLookupList)
         {
            contactIDList.add(CLW.Id);
         }

         if (contactIDList != null && contactIDList.size() > 0)
         {
            userContactMap = new Map<ID, Contact> ([SELECT Id, Email
                                                   FROM Contact
                                                   WHERE Id IN :contactIDList]);
         }

         for (Integer index = 0; index<ContactLookupList.size(); index++) {
            ContactLookupWrapper objContact = ContactLookupList[index];
            if (String.isNotBlank(objContact.Id)) {

               if (userContactMap != null && userContactMap.size()> 0)
               {
                  SelectedUserEmail = userContactMap.get(objContact.Id).Email;
               }

               if (String.isBlank(SelectedUserEmail)) {
                  SetErrorMessageForSelectedContact(index, Label.AH_UDC_Send_Workbook_Additional_Contact_Email_Required_Message);
               } else if (ContactId.equals(objContact.Id) || IsContactAlreadySelected(index, objContact.Id)) {
                  SetErrorMessageForSelectedContact(index, Label.AH_UDC_Duplicate_Contact_Added_For_Send_Workbook_Message);
               }
               else {
                  //Remove error message if no error found
                  SetErrorMessageForSelectedContact(index, '');
               }
            }
            else {
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
      return duplicateCount > 0;
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
         if (IsCopyWorkbook) {
            NIDocIDForWorkbook = SelectedNIDocIdCopy;
         }
         else {
            NIDocIDForWorkbook = SelectedNIDocIdNew;
         }

         if (String.isNotBlank(String.valueOf(NIDocIDForWorkbook))) {
            lstCopyWorkbookSent = new List<AH_UDC_Workbook__c> ([SELECT Id, Name, Product__c, RelatedTo__r.Account__c, RelatedTo__r.AH_UDC_WorkbookDueDate__c, ParentWorkbookSent__r.Name,
                                                                RelatedTo__r.AH_UDC_ChatterWorkbookAccessed__c, RelatedTo__r.AH_UDC_ChatterWorkbookCompleted__c, RelatedTo__r.AH_UDC_ChatterWorkbookStepCompleted__c
                                                                FROM AH_UDC_Workbook__c
                                                                WHERE RelatedTo__c = :NIDocIDForWorkbook]);

            if (lstCopyWorkbookSent != null && lstCopyWorkbookSent.size() > 0) {
               ParentWorkbookName = lstCopyWorkbookSent[0].ParentWorkbookSent__r.Name;
               DueDate = lstCopyWorkbookSent[0].RelatedTo__r.AH_UDC_WorkbookDueDate__c;
               SelectedProduct = lstCopyWorkbookSent[0].Product__c;
               SelectedWorkbook = lstCopyWorkbookSent[0].Id;
               SelectedContact.AccountId = lstCopyWorkbookSent[0].RelatedTo__r.Account__c;
               IsUDCWorkbookCompleted = true;
               EnabledProductWorkbooks = new List<SelectOption> ();
               EnabledProductWorkbooks.add(new SelectOption(lstCopyWorkbookSent[0].Id, lstCopyWorkbookSent[0].Name));
            }
         }
         else {
            DueDate = null;
            SelectedProduct = null;
            SelectedWorkbook = null;
            SelectedContact.AccountId = null;
            IsUDCWorkbookAccessed = false;
            IsUDCWorkbookCompleted = true;
            IsUDCWorkbookStepCompleted = false;
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
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1/0;
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
}