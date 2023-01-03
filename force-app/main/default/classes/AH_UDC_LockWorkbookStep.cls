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

   public AH_UDC_LockWorkbookStep(ApexPages.StandardController controller) {
      try {
         IsErrorOccurred = false;
         IsStepNotCompleted = false;
         IsStepAlreadyLocked = false;
         IsWorkbookComplete = false;

         if (String.isBlank(apexpages.currentpage().getparameters().get('id'))) {
            IsErrorOccurred = true;
            System.debug('Step Id was not passed in as a parameter on the URL');
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.AH_UDC_Common_Error_Message));
            return;
         }
         StepId = String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('id'));

         List<AH_UDC_WorkbookStep__c> objStepDetails = [SELECT CreatedById, Id, StepCompleted__c, StepStatus__c, StepCompletedBy__c, Workbook__c
                                                        FROM AH_UDC_WorkbookStep__c
                                                        WHERE Id = :StepId];

         List<AH_UDC_Workbook__c> objWorkbook = [SELECT Id, SentStatus__c
                                                 FROM AH_UDC_Workbook__c
                                                 WHERE Id = :objStepDetails[0].Workbook__c];

         if (objWorkbook.size() > 0) {
            if (objWorkbook[0].SentStatus__c == AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED) {
               IsWorkbookComplete = true;
            }
         }

         if (objStepDetails.size() == 0) {
            IsErrorOccurred = true;
            System.debug('Workbook Step Sent record not found');
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.AH_UDC_Common_Error_Message));
            return;
         }

         if (objStepDetails[0].StepStatus__c == AH_UDC_Constants.STEP_STATUS_LOCKED) {
            IsStepAlreadyLocked = true;
         } else if (objStepDetails[0].StepStatus__c != AH_UDC_Constants.STEP_STATUS_COMPLETED) {
            IsStepNotCompleted = true;
         }
      }
      catch(Exception ex) {
         IsErrorOccurred = true;
         System.debug('Error occurred in controller => ' + String.valueOf(ex) + ' at Line Number ' + ex.getLineNumber());
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, Label.AH_UDC_Common_Error_Message));
         LogException('Constructor', 'Error occurred in AH_UDC_LockWorkbookStep() Constructor => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber(), ex);
      }
   }

   // Update the StepStatus to reflect whether it is Locked or In Progress
   public void LockWorkbookStepSent() {
      AH_UDC_WorkbookStep__c objStepDetails = null;
      try {
         if (String.isBlank(StepId)) {
            IsErrorOccurred = true;
            System.debug('Step Id not found');
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.AH_UDC_Common_Error_Message));
            return;
         }         

         if (IsErrorOccurred == false && IsStepNotCompleted == false && IsStepAlreadyLocked == false && IsWorkbookComplete == false) {
            objStepDetails = new AH_UDC_WorkbookStep__c();
            objStepDetails.Id = StepId;
            objStepDetails.StepStatus__c = AH_UDC_Constants.STEP_STATUS_LOCKED;
            update objStepDetails;
         } else if (IsErrorOccurred == false && IsStepNotCompleted == false && IsStepAlreadyLocked == true && IsWorkbookComplete == false) {
            objStepDetails = new AH_UDC_WorkbookStep__c();
            objStepDetails.Id = StepId;
            objStepDetails.StepStatus__c = AH_UDC_Constants.STEP_STATUS_IN_PROGRESS;
            objStepDetails.StepCompletedBy__c = null;
            objStepDetails.StepCompleted__c = null;
            update objStepDetails;
         }
         
      }
      catch(Exception ex) {
         IsErrorOccurred = true;
         System.debug('Error occurred in controller => ' + String.valueOf(ex) + ' at Line Number ' + ex.getLineNumber());
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, Label.AH_UDC_Common_Error_Message));
         LogException('LockWorkbookStepSent', 'Error occurred in LockWorkbookStepSent() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber(), ex);         
      }
   }

   //Log exception and display error message to user
   private void LogException(String strMethodName, String strErrorMessage, Exception exc) {
      IsErrorOccurred = true;
      AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, strMethodName, strErrorMessage, System.Label.AH_UDC_Common_Error_Message, exc);
   }
}