/***********************************************************************************************
  Name            : AH_UDC_LockWorkbookStep
  Author          : Umang Ankleshwaria
  Created Date    : 19-Apr-2021
  Last Mod Date   : 21-Apr-2021
  Last Mod By     : Sanjay Parmar
  NICC Reference  : 
  Description     : Apex class for Workbook Step Sent Lock
 ************************************************************************************************/
public with sharing class AH_UDC_LockWorkbookStep {
   public Id StepId { get; set; }
   public Boolean IsErrorOccurred { get; set; }
   public Boolean IsStepNotCompleted { get; set; }
   public Boolean IsStepAlreadyLocked { get; set; }
   public Boolean IsWorkbookComplete { get; set; }
   @TestVisible private string LogFunctionalArea = 'AH_UDC_LockWorkbookStep'; //This is used for AH_UDC_Log Entries being written on this page
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }
   //This is used client side to determine if AH_UDC_Log Messages need to be written from the Page Load
   public Boolean HasPageLoadLogMessages {
      get {
         AH_UDC_LogHelper.Debug('PageLoadLogMessages: ' + PageLoadLogMessages);
         return PageLoadLogMessages.size() > 0;
      }
   }

   public AH_UDC_LockWorkbookStep(ApexPages.StandardController controller) {
      try {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;
         IsErrorOccurred = false;
         IsStepNotCompleted = false;
         IsStepAlreadyLocked = false;
         IsWorkbookComplete = false;

         if (String.isBlank(ApexPages.currentPage().getParameters().get('id'))) {
            LogException('Constructor', 'StepId parameter not found in the url', null);
            return;
         }
         StepId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'));

         // Retrieve the WorkbookStep's Workbook.Id and NiDoc.Id
         AH_UDC_WorkbookStep__c wbs = [SELECT Workbook__c, Workbook__r.RelatedTo__c
                                       FROM AH_UDC_WorkbookStep__c
                                       WHERE Id = :StepId LIMIT 1];

         if (!AH_UDC_SharedWithoutSharing.CheckRecordEditAccessForUser(wbs.Workbook__c)
             &&
             !AH_UDC_SharedWithoutSharing.CheckRecordEditAccessForUser(wbs.Workbook__r.RelatedTo__c))
         {
            IsErrorOccurred = true;
            //Display error message on the page for no access rights on workbook step for current user 
            if (!ApexPages.hasMessages()) { //If there is already a message added then do not add
               //Display error message to user
               ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.AH_UDC_UserAccessErrorMessageForWorkbookStep));
            }
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_WARN, LogFunctionalArea, 'Constructor', System.Label.AH_UDC_UserAccessErrorMessageForWorkbookStep, null, null, null);
            return;
         }

         List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = [SELECT CreatedById, Id, StepCompleted__c, StepStatus__c, StepCompletedBy__c, Workbook__c
                                                          FROM AH_UDC_WorkbookStep__c
                                                          WHERE Id = :StepId];

         if (lstWorkbookSteps.size() == 0) {
            LogException('Constructor', 'Workbook Step Sent record not found - Step Id: ' + StepId, null);
            return;
         }

         List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id, SentStatus__c
                                                  FROM AH_UDC_Workbook__c
                                                  WHERE Id = :lstWorkbookSteps[0].Workbook__c];

         if (lstWorkbookSteps.size() == 0) {
            LogException('Constructor', 'Workbook Sent record not found associated with the Step Id: ' + StepId, null);
            return;
         }

         if (lstWorkbooks[0].SentStatus__c == AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED) IsWorkbookComplete = true;
         if (lstWorkbookSteps[0].StepStatus__c == AH_UDC_Constants.STEP_STATUS_LOCKED) IsStepAlreadyLocked = true;
         else if (lstWorkbookSteps[0].StepStatus__c != AH_UDC_Constants.STEP_STATUS_COMPLETED) IsStepNotCompleted = true;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('Constructor', strErrorMessage, ex);
      }
      finally {
         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   // Update the StepStatus to reflect whether it is Locked or In Progress
   public void LockWorkbookStepSent() {
      AH_UDC_WorkbookStep__c objStepDetails = null;
      try {
         objStepDetails = new AH_UDC_WorkbookStep__c();

         if (IsErrorOccurred) return;

         if (String.isBlank(StepId)) {
            LogException('LockWorkbookStepSent', 'Step Id not found', null);
            return;
         }

         if (IsStepNotCompleted || IsWorkbookComplete) { return; }
         objStepDetails.Id = StepId;
         if (IsStepAlreadyLocked == false) { objStepDetails.StepStatus__c = AH_UDC_Constants.STEP_STATUS_LOCKED; }
         else if (IsStepAlreadyLocked == true) {
            objStepDetails.StepStatus__c = AH_UDC_Constants.STEP_STATUS_IN_PROGRESS;
            objStepDetails.StepCompletedBy__c = null;
            objStepDetails.StepCompleted__c = null;
         }
         AH_UDC_SystemContext.updateObject(objStepDetails); //WB User and WB Admin don't have access to these fields so update as System context
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred while locking step for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('LockWorkbookStepSent', strErrorMessage, ex);
      }
   }

   //Log exception and display error message to user
   private void LogException(String strMethodName, String strErrorMessage, Exception exc) {
      IsErrorOccurred = true;
      AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, strMethodName, strErrorMessage, System.Label.AH_UDC_Common_Error_Message_Backend, exc);
   }

   //This method is used by a client side actionfunction to log AH_UDC_Log entries that couldn't be created by the page load due to SOQL DML restrictions
   public void ServerLogMessages() {
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages');
      try {
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
         if (PageLoadLogMessages != null && PageLoadLogMessages.size() > 0) {
            insert(PageLoadLogMessages);
         }
         PageLoadLogMessages = new List<AH_UDC_Log__c> ();
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