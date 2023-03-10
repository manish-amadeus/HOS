/***********************************************************************************************
  Name            : AH_UDC_StepOrder
  Author          : Ravi Shah
  Created Date    : 25-Jan-2021
  Last Mod Date   : 9-Feb-2021
  Last Mod By     : Sanjay Parmar
  NICC Reference  : 
  Description     : Controller class for Step Order page
  Change History  :
                    1. 590045 - Refactoring Code - Changed by Sanjay Parmar on 9-Feb-2021
 ************************************************************************************************/
public with sharing class AH_UDC_StepOrder {
   public List<AH_UDC_WorkbookStep__c> StepList { get; set; }
   public String StepIds { get; set; } //Being used in hidden field to get comma separated step ids in specified order
   public Boolean IsErrorOccurred { get; set; } { IsErrorOccurred = false; }
   public Boolean HasWorkbookStep { get; set; } { HasWorkbookStep = false; }
   //being used to check user has access right on current workbook or not
   public Boolean UserHasAccess { get; set; } { UserHasAccess = false; }

   @TestVisible private string LogFunctionalArea = 'AH_UDC_StepOrder'; //This is used for AH_UDC_Log Entries being written on this page
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }
   //This is used client side to determine if AH_UDC_Log Messages need to be written from the Page Load
   public Boolean HasPageLoadLogMessages {
      get {
         AH_UDC_LogHelper.Debug('PageLoadLogMessages: ' + PageLoadLogMessages);
         return PageLoadLogMessages.size() > 0;
      }
   }
   public AH_UDC_StepOrder(ApexPages.StandardController controller) {
      String workbookId = null;
      try {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;

         if (String.isBlank(apexpages.currentpage().getparameters().get('id'))) {
            LogException('Constructor', 'Workbook Id Not Found', null);
            return;
         }
         workBookId = String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('id'));
         //Check current user has access rights on Workbook
         UserHasAccess = AH_UDC_SharedWithoutSharing.CheckRecordEditAccessForUser(workBookId);
         if (UserHasAccess != true)
         {
            IsErrorOccurred = true;
            //Display error message on the page for no access rights on workbook for current user 
            if (!ApexPages.hasMessages()) { //If there is already a message added then do not add
               //Display error message to user
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.AH_UDC_UserDoesNotHaveWorkbookEditAccessErrorMessage)); ///Only the generic error should ever be show to the users.
            }
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_WARN,
                                 LogFunctionalArea,
                                 'Constructor', 'The user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') tried to access the workbook on which the user do not have edit rights.',
                                 null, null, null);
         }
         else {
            //Get all steps from the AH_UDC_WorkbookStep__c object
            StepList = [SELECT Id, Name, SortOrder__c
                        FROM AH_UDC_WorkbookStep__c
                        WHERE Workbook__c = :workBookId
                        ORDER BY SortOrder__c];
            if (StepList.size() > 0) HasWorkbookStep = true;
         }
      }
      catch(Exception ex) {
         String strMessage = 'Error occurred in AH_UDC_StepOrder() Constructor => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         //Display error message on the page         
         LogException('Constructor', strMessage, ex);
      }
      finally { //Dispose unused variables/objects
         workbookId = null;

         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   //Save sort order in workbook step object
   public void SaveStepOrders() {
      String[] arrayOfStep = null;
      Set<Id> workbookAvailableStep = null;
      try {
         workbookAvailableStep = new Set<id> ();
         for (AH_UDC_WorkbookStep__c workbookStepObj : StepList) {
            workbookAvailableStep.add(workbookStepObj.Id);
         }
         if (String.isNotBlank(StepIds)) {
            //Split step ids into array
            arrayOfStep = StepIds.split(',');
            AH_UDC_LogHelper.Debug('arrayOfStep => ' + arrayOfStep);

            if (arrayOfStep != null && arrayOfStep.size() > 0) {
               Integer stepOrder = 1;
               StepList = new List<AH_UDC_WorkbookStep__c> ();
               for (String strStepId : arrayOfStep) {
                  //Verify that the step IDs are still valid for the requested workbook id
                  if (String.isNotBlank(strStepId) && workbookAvailableStep.contains(strStepId)) {
                     //Prepare list of steps to update sort order
                     StepList.add(new AH_UDC_WorkbookStep__c(Id = strStepId, SortOrder__c = stepOrder));
                     stepOrder++;
                  }
               }
               AH_UDC_LogHelper.Debug('StepList => ' + StepList);
               update StepList;
            }
            else {
               //Display error message on the page               
               LogException('SaveStepOrders', 'Invalid Step Ids Found', null);
            }
         }
         else {
            //Display error message on the page            
            LogException('SaveStepOrders', 'Step Ids Not Found', null);
         }
      }
      catch(Exception ex) {
         String strMessage = 'Error occurred in SaveStepOrders() => ' + String.valueOf(ex) + ' at Line Number ' + ex.getLineNumber();
         //Display error message on the page         
         LogException('SaveStepOrders', strMessage, ex);

      }
      finally { //Dispose unused variables/objects
         arrayOfStep = null;
         workbookAvailableStep = null;
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
         if (PageLoadLogMessages != null && PageLoadLogMessages.size() > 0) {
            insert(PageLoadLogMessages);
         }
         PageLoadLogMessages = new List<AH_UDC_Log__c> ();

         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
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