/***********************************************************************************************
  Name            : AH_UDC_ReleaseWorkbook
  Author          : Amadeus (Rob.Stevens@Amadeus.com)
  Created Date    : 2022-10-24
  Description     : Controller class for AH_UDC_ReleaseWorkbook page
 ************************************************************************************************/
public with sharing class AH_UDC_ReleaseWorkbook {
   public Id WorkbookId { get; set; }
   public Boolean IsErrorOccurred { get; set; } { IsErrorOccurred = false; }
   public String ReleaseNotAllowedMessage { get; set; }
   List<AH_UDC_Workbook__c> lstWorkbooks = new List<AH_UDC_Workbook__c> ();

   @TestVisible private string LogFunctionalArea = 'AH_UDC_ReleaseWorkbook'; //This is used for AH_UDC_Log Entries being written on this page
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }
   //This is used client side to determine if AH_UDC_Log Messages need to be written from the Page Load
   public Boolean HasPageLoadLogMessages {
      get {
         return PageLoadLogMessages != null && PageLoadLogMessages.size() > 0;
      }
   }

   public AH_UDC_ReleaseWorkbook(ApexPages.StandardController controller) {
      try {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;

         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceReleasePageLoadError', FALSE, true))
         {
            throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'Workbook Release Page Load'));
         }

         VerifyUserRequest();
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred loading Release Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + '). Workbook Id ' + WorkbookId + ' : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('Constructor', strErrorMessage, ex, null);
      }
      finally {
         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   private boolean VerifyUserRequest() {
      try {
         if (String.isBlank(String.valueOf(WorkbookId)))
         WorkbookId = apexpages.currentpage().getparameters().get('Id');

         if (String.isBlank(String.valueOf(WorkbookId))) {
            LogException('IsValidUserRequest', 'WorkbookId not found in the parameters', null, null);
            return false;
         }

         Id WorkbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
         if (String.isBlank(String.valueOf(WorkbookSentRecordTypeId))) {
            LogException('IsValidUserRequest', 'Workbook Sent Record Type Id not found', null, null);
            return false;
         }

         lstWorkbooks = [SELECT Id, RelatedTo__c, Released__c, EmailTemplate__c
                         FROM AH_UDC_Workbook__c
                         WHERE Id = :WorkbookId
                         AND RecordTypeId = :WorkbookSentRecordTypeId];
         if (lstWorkbooks.size() == 0) {
            LogException('IsValidUserRequest', 'Workbook sent record not found with the Id ' + WorkbookId, null, null);
            return false;
         }
         else if (!AH_UDC_SharedWithoutSharing.CheckRecordEditAccessForUser(WorkbookId)
                  && !AH_UDC_SharedWithoutSharing.CheckRecordEditAccessForUser(lstWorkbooks[0].RelatedTo__c)) {
            //Don't allow user to release if they don't have edit rights on workbook or NI Doc record
            ReleaseNotAllowedMessage = Label.AH_UDC_ReleaseWorkbook_UserNotAllowedMessage;
            return false;
         }
         else if (lstWorkbooks[0].Released__c) {
            ReleaseNotAllowedMessage = Label.AH_UDC_ReleaseWorkbook_AlreadyReleasedMessage;
            return false;
         }
         return true;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred while verifying user request for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + '). Workbook Id ' + WorkbookId + ' : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('IsValidUserRequest', strErrorMessage, ex, null);
         return false;
      }
   }

   public void ReleaseWorkbook() {
      try {
         AH_UDC_LogHelper.QueueLogs = true;

         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceReleaseError', FALSE, true))
         {
            throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'Workbook Release'));
         }

         if (VerifyUserRequest() == false) return; //If there is an error then don't proceed further

         //Create Community Users and Send Emails
         if (!SendToContacts()) {
            AH_UDC_LogHelper.writeQueuedLogs();
            LogException('ReleaseWorkbook', 'Failed to Send To UDC Contacts', null, null);
            return;
         }

         //Prepare database save point for rollback transaction BEFORE any records are inserted
         Savepoint objSavePoint = Database.setSavepoint();

         //Reset Workbook, Steps, and NI Doc
         List<AH_UDC_Workbook__c> workbooks = [select id, SentStatus__c, RelatedTo__c, CompletedBy__c, CompletedDate__c from AH_UDC_Workbook__c where id = :WorkbookId];
         workbooks[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
         workbooks[0].CompletedBy__c = null;
         workbooks[0].CompletedDate__c = null;
         AH_UDC_SystemContext.updateSObj(workbooks[0]);

         List<AH_UDC_WorkbookStep__c> workbookSteps = [select id, StepCompleted__c, StepCompletedBy__c, StepStatus__c from AH_UDC_WorkbookStep__c where Workbook__c = :WorkbookId];
         for (AH_UDC_WorkbookStep__c workbookStep : workbookSteps) {
            workbookStep.StepCompleted__c = null;
            workbookStep.StepCompletedBy__c = null;
            workbookStep.StepStatus__c = AH_UDC_Constants.STEP_STATUS_NEW;
         }
         AH_UDC_SystemContext.UpdateObjects(workbookSteps);

         List<NI_Documentation__c> niDocs = [select id, AH_UDC_PropertyConfirmation__c, AH_UDC_PropertyConfirmationAccepted_Date__c from NI_Documentation__c where id = :workbooks[0].RelatedTo__c];
         niDocs[0].AH_UDC_PropertyConfirmation__c = false;
         niDocs[0].AH_UDC_PropertyConfirmationAccepted_Date__c = null;
         AH_UDC_SystemContext.updateSObj(niDocs[0]);
         
         //Update Workbook to Released
         AH_UDC_LogHelper.Debug('ReleaseWorkbook => WorkbookId: ' + WorkbookId);
         AH_UDC_Workbook__c objWorkbook = new AH_UDC_Workbook__c(
                                                                 Id = WorkbookId,
                                                                 Released__c = true
         );
         AH_UDC_SystemContext.UpdateObject(objWorkbook);
      }
      catch(Exception ex) {
         AH_UDC_LogHelper.Debug('Error occurred in the method ReleaseWorkbook: ' + ex.getMessage() + ' at line number ' + ex.getLineNumber());
         String strErrorMessage = 'An exception occurred while archiving workbook by the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + '). Workbook Id ' + WorkbookId + ' : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('ReleaseWorkbook', strErrorMessage, ex, null);
      }
      finally {
         AH_UDC_LogHelper.writeQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   //Log exception and display error message to user
   private void LogException(String strMethodName, String strErrorMessage, Exception exc, SavePoint objSavePoint) {
      AH_UDC_LogHelper.Debug('strErrorMessage: ' + strErrorMessage);
      AH_UDC_LogHelper.Debug('exc: ' + exc);
      IsErrorOccurred = true;
      if (objSavePoint != null) Database.rollback(objSavePoint);
      if (AH_UDC_LogHelper.QueueLogs)
      {
         AH_UDC_LogHelper.writeQueuedLogs();
      }

      AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, strMethodName, strErrorMessage, System.Label.AH_UDC_Common_Error_Message_Backend, exc);
   }

   //This method is used by a client side actionfunction to log AH_UDC_Log entries that couldn't be created by the page load due to SOQL DML retrictions
   public void ServerLogMessages() {
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages');
      try {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages => PageLoadLogMessages: ' + PageLoadLogMessages);
         if (PageLoadLogMessages != null && PageLoadLogMessages.size() > 0) {
            insert(PageLoadLogMessages);
         }
         PageLoadLogMessages = new List<AH_UDC_Log__c> ();

         //Generate exception for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') throw(new AH_UDC_Shared.UDCException('Exception for test class execution'));
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

   List<AH_UDC_Contact__c> udcContacts = new List<AH_UDC_Contact__c> ();

   //Create community users before sending workbooks
   public Boolean SendToContacts() {
      try {
         AH_UDC_LogHelper.Debug('SendToContacts Start');
         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceReleaseWorkbookSendToContactsException', FALSE, true)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'Release Workbook Send To Contacts'));
         //Get list of contacts to create
         udcContacts = [select id, Contact__c, Contact__r.Email from AH_UDC_Contact__c where Document__c = :lstWorkbooks[0].RelatedTo__c];
         //Create the primary contact's Community User
         if (udcContacts.size() == 0) return true; //No UDC Contacts
         Boolean AllUsersCreated = false;
         List<Contact> SendContacts = new List<Contact> ();
         for (AH_UDC_Contact__c udcContact : udcContacts) {
            If (!AH_UDC_SharedWithoutSharing.SetupCommunityAccess(udcContact.Contact__c)) return false;
            SendContacts.add(new Contact(id = udcContact.Contact__c, Email = udcContact.Contact__r.Email));
         }
         List<EmailTemplate> lstEmailTemplates = [SELECT Id, Name
                                                  FROM EmailTemplate
                                                  WHERE DeveloperName = :lstWorkbooks[0].EmailTemplate__c];
         if (lstEmailTemplates.size() != 1) return false; //Invalid Template
         //Send Emails
         return AH_UDC_SharedWithoutSharing.SendEmailToContacts(LogFunctionalArea, sendContacts, lstEmailTemplates[0].id, lstWorkbooks[0].RelatedTo__c, null);
      }
      catch(Exception ex) {
         AH_UDC_LogHelper.Debug('SendToContacts Exception: ' + ex.getMessage() + ' at line number ' + ex.getLineNumber());
         String strErrorMessage = 'An exception occurred in SendToContacts method - Release Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'SendToContacts', strErrorMessage,
                              ex, null, null);
         return false;
      }
   }
}