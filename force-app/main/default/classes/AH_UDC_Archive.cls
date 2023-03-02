/***********************************************************************************************
  Name            : AH_UDC_Archive_Test
  Author          : Sanjay Parmar
  Created Date    : 31-Aug-2022
  Last Mod Date   : 31-Aug-2022
  Last Mod By     : Sanjay Parmar
  Description     : Controller class for AH_UDC_Archive page
 ************************************************************************************************/
public with sharing class AH_UDC_Archive  {
   public Id WorkbookId { get; set; }
   @TestVisible private Id NIDocId { get; set; }
   public Boolean IsErrorOccurred { get; set; } { IsErrorOccurred = false; }
   public String ArchiveNotAllowedMessage { get; set; }
   @TestVisible private string LogFunctionalArea = 'AH_UDC_Archive'; //This is used for AH_UDC_Log Entries being written on this page
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }
   //This is used client side to determine if AH_UDC_Log Messages need to be written from the Page Load
   public Boolean HasPageLoadLogMessages {
      get {
         return PageLoadLogMessages != null && PageLoadLogMessages.size() > 0;
      }
   }

   public AH_UDC_Archive(ApexPages.StandardController controller) {
      try {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;

         //Unit Test Force Exception
<<<<<<< HEAD
<<<<<<< HEAD
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceArchivePageLoadError', FALSE))
=======
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceArchivePageLoadError', FALSE, true))
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceArchivePageLoadError', FALSE, true))
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
         {
            throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'Workbook Archive Page Load'));
         }

         VerifyUserRequest();
         AH_UDC_LogHelper.Debug('LogFunctionalArea: ' + LogFunctionalArea);
         //Generate exception for test class execution to cover catch block
         if(Test.isRunningTest() && LogFunctionalArea == 'TestException') throw(new AH_UDC_Shared.UDCException('Exception for test class execution'));
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred loading Archive Workbook page for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + '). Workbook Id ' + WorkbookId + ' : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('Constructor', strErrorMessage, ex);
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
         if(String.isBlank(String.valueOf(WorkbookId)))
            WorkbookId = apexpages.currentpage().getparameters().get('Id');

         if (String.isBlank(String.valueOf(WorkbookId))) {
            LogException('IsValidUserRequest', 'WorkbookId not found in the parameters', null);
            return false;
         }

         Id WorkbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
         if (String.isBlank(String.valueOf(WorkbookSentRecordTypeId))) {
            LogException('IsValidUserRequest', 'Workbook Sent Record Type Id not found', null);
            return false;
         }

         List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id, RelatedTo__c, Archive__c
                                                   FROM AH_UDC_Workbook__c
                                                   WHERE Id = :WorkbookId
                                                   AND RecordTypeId = :WorkbookSentRecordTypeId];
         if(lstWorkbooks.size() == 0) {
            LogException('IsValidUserRequest', 'Workbook sent record not found with the Id ' + WorkbookId, null);
            return false;
         }
         else if (!AH_UDC_SharedWithoutSharing.CheckRecordEditAccessForUser(WorkbookId)
                  && !AH_UDC_SharedWithoutSharing.CheckRecordEditAccessForUser(lstWorkbooks[0].RelatedTo__c)) {
            //Don't allow user to archive if he don't have edit rights on workbook or NI Doc record
            ArchiveNotAllowedMessage = Label.AH_UDC_Archive_UserNotAllowedMessage;
            return false;
         }
         else if(lstWorkbooks[0].Archive__c) {
            ArchiveNotAllowedMessage = Label.AH_UDC_Archive_WorkbookAlreadyArchivedMessage;
            return false;
         }
         NIDocId = lstWorkbooks[0].RelatedTo__c;
         return true;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred while verifying user request for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + '). Workbook Id ' + WorkbookId + ' : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('IsValidUserRequest', strErrorMessage, ex);
         return false;
      }
   }

   public void ArchiveWorkbook() {
      try {
         //Generate exception for test class execution to cover catch block
         if(Test.isRunningTest() && LogFunctionalArea == 'TestException') throw(new AH_UDC_Shared.UDCException('Exception for test class execution'));

         //Unit Test Force Exception
<<<<<<< HEAD
<<<<<<< HEAD
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceArchiveError', FALSE))
=======
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceArchiveError', FALSE, true))
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceArchiveError', FALSE, true))
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
         {
            throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'Workbook Archive'));
         }

         if(VerifyUserRequest() == false)
            return; //If there is an error then don't proceed further

         AH_UDC_LogHelper.Debug('ArchiveWorkbook => WorkbookId: ' + WorkbookId);
         AH_UDC_Workbook__c objWorkbook = new AH_UDC_Workbook__c(
                                             Id = WorkbookId,
                                             Archive__c = true
                                          );
         AH_UDC_SystemContext.UpdateObject(objWorkbook);

         List<EntitySubscription> lstSubscriptions = [SELECT Id FROM EntitySubscription
                                                      WHERE ParentId = :WorkbookId
                                                      OR ParentId = :NIDocId
                                                      LIMIT 500];
         AH_UDC_LogHelper.Debug('ArchiveWorkbook => lstSubscriptions: ' + lstSubscriptions);
         if(lstSubscriptions.size() > 0) AH_UDC_SystemContext.DeleteObjects(lstSubscriptions);
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred while archiving workbook by the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + '). Workbook Id ' + WorkbookId + ' : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('ArchiveWorkbook', strErrorMessage, ex);
      }
   }

   //Log exception and display error message to user
   private void LogException(String strMethodName, String strErrorMessage, Exception exc) {
      IsErrorOccurred = true;
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
         if(Test.isRunningTest() && LogFunctionalArea == 'TestException') throw(new AH_UDC_Shared.UDCException('Exception for test class execution'));
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