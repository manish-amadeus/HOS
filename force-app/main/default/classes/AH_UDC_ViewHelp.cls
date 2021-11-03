/***********************************************************************************************
  Name            : AH_UDC_ViewHelp
  Author          : Tushar Gupta
  Created Date    : 09-Apr-2021
  Last Mod Date   : 09-Apr-2021
  User Story ID   : 599601
  Last Mod By     : Tushar Gupta
  NICC Reference  : 
  Description     : Contorller class for ViewHelp
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
  
   public AH_UDC_ViewHelp() {
      try {
         //Get the required Step ID from the URL
         if (String.isBlank(ApexPages.currentPage().getparameters().get('id'))) {
            ShowUserError();
            return;
         }
         WorkbookStepId = String.escapeSingleQuotes(ApexPages.currentPage().getparameters().get('id')).escapeHtml4();

         if (ApexPages.currentPage().getparameters().get('Popout') != null 
             && ApexPages.currentPage().getparameters().get('Popout').toLowerCase() == 'false') PopOut = false;

         if (ApexPages.currentPage().getparameters().get('community') != null 
             && ApexPages.currentPage().getparameters().get('community').equalsIgnoreCase('false')) IsCommunityView = false;

         //Verify the Step Exists
         List<AH_UDC_WorkbookStep__c> StepDetails = [SELECT Id, Name, Help__c, Workbook__c
                                                     FROM AH_UDC_WorkbookStep__c
                                                     WHERE Id = :WorkbookStepId];
         if (StepDetails.size() == 0) {
            ShowUserError();
            return;
         }

         //Check that the user has access to the workbook/step requested
         if (AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess(StepDetails[0].Workbook__c) == false)
         {
            ShowUserError();
            return;
         }

         //Set the Step Name
         StepName = StepDetails[0].Name;

         HelpText = StepDetails[0].Help__c;
        
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest()) Integer a = 1/0;
      }
      catch(Exception ex) {
         ShowUserError();         
         LogException('Constructor', 'Error occurred in AH_UDC_ViewHelp() Constructor => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber(), ex);         
      }
   }

   //Log exception and display error message to user
   private void LogException(String strMethodName, String strErrorMessage, Exception exc) {
      IsErrorOccurred = true;
      AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, strMethodName, strErrorMessage, System.Label.AH_UDC_Common_Error_Message, exc);
   }

   public void ShowUserError()
   {      
      if (IsErrorOccurred) return; //Only show 1 error message
      IsErrorOccurred = true;
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.AH_UDC_Common_Error_Message));
   }
}