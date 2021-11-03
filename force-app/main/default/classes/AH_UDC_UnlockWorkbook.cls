/***********************************************************************************************
  Name            : AH_UDC_UnlockWorkbook
  Author          : Ravi Shah
  Created Date    : 3-March-2021
  Last Mod Date   : 3-March-2021
  Last Mod By     : 
  NICC Reference  : 
  User Story ID   : 590658
  Description     : Controller class for Unlock Workbook of UDC
  Change History  :
 
 ************************************************************************************************/

public with sharing class AH_UDC_UnlockWorkbook {
   //Declare properties
   public String NiDocId { get; set; }
   public Boolean IsWorkbookCompleted { get; set; }
   public Boolean IsAnyError { get; set; }
   public string WorkbookName { get; set; }
   public string SentStatus { get; set; }
   @TestVisible private string LogFunctionalArea = 'AH_UDC_UnlockWorkbook'; //This is used for AH_UDC_Log Entries being written on this page
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }
   //This is used client side to determine if AH_UDC_Log Messages need to be written from the Page Load
   public Boolean HasPageLoadLogMessages {
      get {
         AH_UDC_LogHelper.Debug('PageLoadLogMessages: ' + PageLoadLogMessages);
         return PageLoadLogMessages.size() > 0;
      }
   }

   private Id WorkbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();

   //Initialize constructor
   public AH_UDC_UnlockWorkbook(ApexPages.StandardController controller) {
      AH_UDC_Workbook__c Workbook = null;
      try {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;

         IsWorkbookCompleted = false;
         IsAnyError = false;

         if (String.isBlank(apexpages.currentpage().getparameters().get('id'))) {
            LogException('Constructor', 'NI Document Id Not Found', null);
            return;
         }
         NiDocId = String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('id'));

         Workbook = [SELECT Id, Name, SentStatus__c, RecordTypeId
                     FROM AH_UDC_Workbook__c
                     WHERE RelatedTo__c = :NiDocId AND RecordTypeId = :WorkbookSentRecordTypeId];

         if (Workbook == null) {
            LogException('Constructor', 'Ah_UDC_Workbook__c was not found', null);
            return;
         }

         WorkbookName = Workbook.Name;
         SentStatus = Workbook.SentStatus__c;
         if (Workbook.SentStatus__c == AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED) {
            IsWorkbookCompleted = true;
         }
         else {
            IsWorkbookCompleted = false;
         }
      } catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('Constructor', strErrorMessage, ex);
      }
      finally {
         Workbook = null;
         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
      }
   }

   //Unlock workbook if status is 'Completed/Unlock'
   public void UnlockWorkbook() {
      AH_UDC_Workbook__c Workbook = null;
      try {
         if (String.isNotBlank(NiDocId)) {
            Workbook = [SELECT Id, Name, SentStatus__c, RecordTypeId
                        FROM AH_UDC_Workbook__c
                        WHERE RelatedTo__c = :NiDocId AND RecordTypeId = :WorkbookSentRecordTypeId];
            if (Workbook != null) {
               Workbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_IN_PROGRESS;
               UPDATE Workbook;
            } else {
               LogException('UnlockWorkbook', 'Ah_UDC_Workbook__c is Not Found', null);
               return;
            }
         } else {
            LogException('UnlockWorkbook', 'NiDocId is null/blank', null);
            return;
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('UnlockWorkbook', strErrorMessage, ex);
      }
      finally {
         Workbook = null;
      }
   }

   //Log exception and display error message to user
   private void LogException(String strMethodName, String strErrorMessage, Exception exc) {
      IsAnyError = true;
      AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, strMethodName, strErrorMessage, System.Label.AH_UDC_Common_Error_Message, exc);
   }

   //This method is used by a client side actionfunction to log AH_UDC_Log entries that couldn't be created by the page load due to SOQL DML retrictions
   public void ServerLogMessages() {
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages');
      try {
         if (PageLoadLogMessages != null && PageLoadLogMessages.size() > 0) {
            insert(PageLoadLogMessages);
         }
         PageLoadLogMessages = new List<AH_UDC_Log__c> ();
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1/0;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'ServerLogMessages',
                              'An exception occurred logging Page Load AH_UDC_Log entries',
                              exc, null, null);
      }
   }
}