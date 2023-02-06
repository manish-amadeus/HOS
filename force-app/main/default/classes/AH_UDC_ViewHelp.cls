/***********************************************************************************************
  Name            : AH_UDC_ViewHelp
  Author          : Tushar Gupta
  Created Date    : 09-Apr-2021
  Last Mod Date   : 09-Apr-2021
  User Story ID   : 599601
  Last Mod By     : Tushar Gupta
  NICC Reference  : 
  Description     : Controller class for ViewHelp
  Dependencies    : AH_UDC_Shared
  Change History  : 2021-05-10 : Rob.Stevens : Refactor for new UI
 ************************************************************************************************/
public without sharing class AH_UDC_ViewHelp {
   public String StepName { get; set; } { StepName = ''; }
   public String HelpText { get; set; } { HelpText = ''; }
   public Boolean IsErrorOccurred { get; set; } { IsErrorOccurred = false; }
   public Boolean PopOut { get; set; } { PopOut = true; }
   public Boolean IsCommunityView { get; set; } { IsCommunityView = true; }
   public String WorkbookStepId { get; set; } { WorkbookStepId = ''; }
   @TestVisible private string LogFunctionalArea = 'AH_UDC_ViewHelp'; //This is used for AH_UDC_Log Entries being written on this page
   
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }
   //This is used client side to determine if AH_UDC_Log Messages need to be written from the Page Load
   public Boolean HasPageLoadLogMessages {
      get {
         AH_UDC_LogHelper.Debug('PageLoadLogMessages: ' + PageLoadLogMessages);
         return PageLoadLogMessages.size() > 0;
      }
   }

   public AH_UDC_ViewHelp() {
      try {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;

         //Unit Test Force Exception
         if(AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceViewHelpError',FALSE, true)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'View Help Load'));

         //Get the required Step ID from the URL
         if (String.isBlank(ApexPages.currentPage().getparameters().get('id'))) {
            ShowUserError('AH_UDC_ViewHelp constructor failed. Id parameter was not provided');
            return;
         }
         WorkbookStepId = String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('id')).escapeHtml4();

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && WorkbookStepId == 'TestException') Integer a = 1/0;

         if (ApexPages.currentPage().getparameters().get('Popout') != null 
             && ApexPages.currentPage().getparameters().get('Popout').toLowerCase() == 'false') PopOut = false;

         if (ApexPages.currentPage().getparameters().get('community') != null 
             && ApexPages.currentPage().getparameters().get('community').equalsIgnoreCase('false')) IsCommunityView = false;

         //Verify the Step Exists
         List<AH_UDC_WorkbookStep__c> StepDetails = [SELECT Id, Name, Help__c, Workbook__c
                                                     FROM AH_UDC_WorkbookStep__c
                                                     WHERE Id = :WorkbookStepId];
         if (StepDetails.size() == 0) {
            ShowUserError('AH_UDC_ViewHelp constructor failed. StepDetails size is 0');
            return;
         }

         //Check that the user has access to the workbook/step requested
         if (AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess(StepDetails[0].Workbook__c) == false)
         {
            ShowUserError('AH_UDC_ViewHelp constructor failed. CheckViewWorkbookUserAccess() is false');
            return;
         }

         //Set the Step Name
         StepName = StepDetails[0].Name;

         HelpText = StepDetails[0].Help__c;
      }
      catch(Exception ex) {
         ShowUserError('AH_UDC_ViewHelp constructor failed. Exception occurred: ' + ex.getMessage() + ' | ' + ex.getLineNumber() + ' | ' + ex.getStackTraceString());         
         LogException('Constructor', 'Error occurred in AH_UDC_ViewHelp() Constructor => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber(), ex);         
      }
      finally
      {
         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   //Log exception and display error message to user
   private void LogException(String strMethodName, String strErrorMessage, Exception exc) {
      IsErrorOccurred = true;
      AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, strMethodName, strErrorMessage, System.Label.AH_UDC_Common_Error_Message, exc);
   }

   public void ShowUserError(String logText) {
      AH_UDC_LogHelper.Debug(LoggingLevel.ERROR, logText);

      if (IsErrorOccurred) return; //Only show 1 error message
      IsErrorOccurred = true;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.AH_UDC_Common_Error_Message));
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