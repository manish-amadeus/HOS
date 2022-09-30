/***********************************************************************************************
  Name            : AH_UDC_Welcome
  Author          : Umang Ankleshwaria
  Created Date    : 23-Dec-2020
  Last Mod Date   : 4-Feb-2021
  Last Mod By     : Sanjay Parmar
  NICC Reference  : 
  Description     : Controller class for Welcome page of UDC
  Change History  :
  1. 590045 - Refactoring Code - Changed by Sanjay Parmar on 4-Feb-2021
  2. 594855 - Refactoring Code - Changed by Tushar Gupta on 22-Feb-2021
 ************************************************************************************************/
public without sharing class AH_UDC_Welcome {
   public Boolean IsTermsandConditionAccepted { get; set; } { IsTermsandConditionAccepted = false; }
   public Boolean Opt_Into_Social_Media_Feature { get; set; } { Opt_Into_Social_Media_Feature = false; }
   public String UserFullName { get; set; }
   public Boolean IsErrorOccurred { get; set; } { IsErrorOccurred = false; }
   public List<WorkbookWrapper> WorkbookList { get; set; } { WorkbookList = new List<WorkbookWrapper> (); }
   public class WorkbookWrapper {
      public String Id { get; set; }
      public String WorkbookName { get; set; }
      public Date DueDate { get; set; }
      public String Status { get; set; }
      public Integer StatusNumber { get; set; }
      public String Product { get; set; }
      public String PropertyName { get; set; }
   }

   User objUser = null;
   List<AH_UDC_Contact__c> lstUDCContact = null;

   public AH_UDC_Welcome() {
      AH_UDC_LogHelper.Debug('AH_UDC_Welcome');
      try {
         UserFullName = (String.isEmpty(UserInfo.getFirstName()) ? '' : UserInfo.getFirstName() + ' ') + UserInfo.getLastName(); //Returns logged-in user full name, first name is not a required field
         FillWorkbookList();

         //Determine if user should be shown terms and conditions
         if (lstUDCContact.size() == 0) {
            //There are no record default Terms And Condition to Accepted
            IsTermsandConditionAccepted = true;
         } else {
            for (AH_UDC_Contact__c udcContact : lstUDCContact) {
               if (udcContact.TermsandConditionsAccepted__c) {
                  IsTermsandConditionAccepted = true;
                  break;
               }
            }
         }
      }
      catch(Exception ex) {
         IsErrorOccurred = true;
         //System.debug('Error occurred in AH_UDC_Welcome() Constructor => ' + String.valueOf(ex) + ' at Line Number ' + ex.getLineNumber());
         //Display error message to user
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, Label.AH_UDC_Common_Error_Message));
      }
   }

   //Fill data in Workbook List
   private void FillWorkbookList() {
      Id workbookSentRecordTypeId = null;
      List<NI_Documentation__c> lstNIDocs = null;
      List<AH_UDC_Workbook__c> lstWorkbook = null;
      WorkbookWrapper objWorkbookWrapper = null;
      try {
         //Get logged-in user's contact id
         objUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() AND IsActive = true];

         if (objUser != null) {
            //Get UDC Workbook records for logged-in user
            lstUDCContact = [SELECT Document__c, TermsandConditionsAccepted__c FROM AH_UDC_Contact__c WHERE Contact__c = :objUser.ContactId];

            if (lstUDCContact != null && lstUDCContact.size() > 0) {
               //Initialize list to prevent error
               lstNIDocs = new List<NI_Documentation__c> ();

               for (AH_UDC_Contact__c objUDCContact : lstUDCContact) {
                  if (String.isNotBlank(String.valueOf(objUDCContact.Document__c))) {
                     //Prepare list of NI Docs Id to pass in workbook retrieving query
                     lstNIDocs.add(new NI_Documentation__c(Id = objUDCContact.Document__c));
                  }
               }

               if (lstNIDocs != null && lstNIDocs.size() > 0) {
                  //Get workbook sent record type id
                  workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();

                  if (String.isNotBlank(String.valueOf(workbookSentRecordTypeId))) {
                     //Get all enabled workbooks for logged-in user
                     lstWorkbook = [SELECT Id, Name, SentStatus__c, Product__c, RelatedTo__r.AH_UDC_WorkbookDueDate__c, RelatedTo__r.Document_Name__c, RelatedTo__r.AH_UDC_PropertyAccount__r.PropertyName__c
                                    FROM AH_UDC_Workbook__c
                                    WHERE Enabled__c = true AND RecordTypeId = :workbookSentRecordTypeId AND RelatedTo__c IN :lstNIDocs LIMIT 2000];

                     if (lstWorkbook != null && lstWorkbook.size() > 0) {
                        //Initialize list to prevent error
                        WorkbookList = new List<WorkbookWrapper> ();

                        for (AH_UDC_Workbook__c objWorkbook : lstWorkbook) {
                           objWorkbookWrapper = new WorkbookWrapper();
                           objWorkbookWrapper.Id = objWorkbook.Id;
                           objWorkbookWrapper.WorkbookName = objWorkbook.RelatedTo__r.Document_Name__c;
                           objWorkbookWrapper.DueDate = objWorkbook.RelatedTo__r.AH_UDC_WorkbookDueDate__c;
                           objWorkbookWrapper.Status = objWorkbook.SentStatus__c;
                           objWorkbookWrapper.Product = objWorkbook.Product__c;
                           objWorkbookWrapper.PropertyName = objWorkbook.RelatedTo__r.AH_UDC_PropertyAccount__r.PropertyName__c;

                           if (objWorkbook.SentStatus__c == AH_UDC_Constants.SENT_STATUS_IN_PROGRESS) {
                              objWorkbookWrapper.StatusNumber = 1;
                           } else if (objWorkbook.SentStatus__c == AH_UDC_Constants.SENT_STATUS_NEW) {
                              objWorkbookWrapper.StatusNumber = 2;
                           } else if (objWorkbook.SentStatus__c == AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED) {
                              objWorkbookWrapper.StatusNumber = 3;
                           } else {
                              objWorkbookWrapper.StatusNumber = 4;
                           }

                           WorkbookList.add(objWorkbookWrapper);
                        }
                     }
                  }
                  else {
                     IsErrorOccurred = true;
                     System.debug('Workbook Sent Record Type Not Found');
                     ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.AH_UDC_Common_Error_Message));
                  }
               }
            }
         }
      }
      catch(Exception ex) {
         //System.debug('Error occurred in FillWorkbookList() => ' + String.valueOf(ex) + ' at Line Number ' + ex.getLineNumber());
         throw ex;
      }
   }

   //This method will set/update terms and condition accepted flag and date
   //it will also set if the Social Media was selected
   public void TermsAndConditionNext() {
      AH_UDC_LogHelper.Debug('TermsAndConditionNext');
      IsTermsandConditionAccepted = true;

      List<AH_UDC_Contact__c> lstUDCContact = null;
      try {
         //Get udc contact
         lstUDCContact = [SELECT Id, TermsandConditionsAcceptedDate__c, TermsandConditionsAccepted__c
                          FROM AH_UDC_Contact__c
                          WHERE Contact__c = :objUser.ContactId
                          ORDER BY CreatedDate DESC
                          LIMIT 1];
         if (lstUDCContact != null && lstUDCContact.Size() > 0) {
            lstUDCContact[0].TermsandConditionsAccepted__c = true;
            lstUDCContact[0].TermsandConditionsAcceptedDate__c = DateTime.now();

            if (Opt_Into_Social_Media_Feature == true) {
               lstUDCContact[0].OptIntoSocialMedia__c = true;
               lstUDCContact[0].OptIntoSocialMediaDate__c = DateTime.now();
            }

            //External Call to Set User's Profile must occur before any DML transactions
            AH_UDC_LogHelper.Debug('Opt_Into_Social_Media_Feature: ' + Opt_Into_Social_Media_Feature);
            if (Opt_Into_Social_Media_Feature == true) {
               //Update the user's profile to allow chatter
               AH_UDC_SharedWithoutSharing.ChangeUserProfileToChatter();
            }

            update lstUDCContact;

         } else {
            IsErrorOccurred = true;
            System.debug('User is not found');
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.AH_UDC_Common_Error_Message));
            return;
         }
      }
      catch(Exception ex) {
         IsErrorOccurred = true;
         system.debug('Error occurred : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber());
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.AH_UDC_Common_Error_Message));
      }
   }  
}