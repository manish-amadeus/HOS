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
  3. 702801 - Refactoring Code - Changed by Vaishali Patel on 24-Mar-2022
 ************************************************************************************************/
public without sharing class AH_UDC_Welcome {
   public Boolean IsTermsandConditionAccepted { get; set; } { IsTermsandConditionAccepted = false; }
   public Boolean Opt_Into_Social_Media_Feature { get; set; } { Opt_Into_Social_Media_Feature = false; }
   public String UserDisplayName { get; set; }
   public Boolean IsErrorOccurred { get; set; } { IsErrorOccurred = false; }
   public Boolean IsCommunityEnabled { get { return AH_UDC_ConfigHelper.GetBoolean('AH_UDC_CommunityEnabled', true); } }
   public List<WorkbookWrapper> WorkbookList { get; set; } { WorkbookList = new List<WorkbookWrapper> (); }
   public string LogFunctionalArea { get; set; } { LogFunctionalArea = 'AH_UDC_Welcome'; }
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }
   @TestVisible
   private Boolean isProfileChanged { get; set; } { isProfileChanged = false; }
   public class WorkbookWrapper {
      public String Id { get; set; }
      public String DocumentName { get; set; }
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
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && UserInfo.getFirstName() == 'TestWelcomeException') Integer a = 1 / 0;

         if (!IsCommunityEnabled) {
            //If community portal is disabled then display a message and don't proceed further
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityDisabledMessage', 'The system is currently offline for maintenance; please check back later.')));
            return;
         }

         UserDisplayName = (String.isNotBlank(UserInfo.getFirstName()) ? UserInfo.getFirstName(): UserInfo.getLastName()); //Returns logged-in users first name
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
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC, 'AH_UDC_Welcome', 'AH_UDC_Welcome constructor',
                              'An exception occurred loading workbook for user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ')', ex, null, null);

         //Display error message to user
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, Label.AH_UDC_Common_Error_Message));
      }
      finally
      {
         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   //This method is used by a client side actionfunction to log AH_UDC_Log entries that couldn't be created by the page load due to SOQL DML retrictions
   public void serverLogMessages()
   {
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverLogMessages');
      try
      {
         if (PageLoadLogMessages != null && PageLoadLogMessages.size() > 0)
         {
             AH_UDC_SystemContext.CreateObjects(PageLoadLogMessages);
         }
         PageLoadLogMessages = new List<AH_UDC_Log__c> ();

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverLogMessages - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'serverLogMessages',
                              'An exception occurred logging Page Load AH_UDC_Log entries',
                              exc, null, null);
      }
   }

   //This is used client side to determine if AH_UDC_Log Messages need to be written from the Page Load
   public Boolean HasPageLoadLogMessages {
      get {
         AH_UDC_LogHelper.Debug('###PageLoadLogMessages: ' + PageLoadLogMessages);
         return PageLoadLogMessages.size() > 0;
      }
   }

   //Fill data in Workbook List
   @TestVisible
   private void FillWorkbookList() {
      Id workbookSentRecordTypeId = null;
      List<NI_Documentation__c> lstNIDocs = null;
      List<AH_UDC_Workbook__c> lstWorkbook = null;
      WorkbookWrapper objWorkbookWrapper = null;
      try {
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') integer i = 1 / 0;
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
                  if (Test.isRunningTest() && LogFunctionalArea == 'TestRecordType') workbookSentRecordTypeId = null;
                  if (workbookSentRecordTypeId != null) {
                     //Get all enabled workbooks for logged-in user
                     lstWorkbook = [SELECT Id, Name, SentStatus__c, Product__c, RelatedTo__r.AH_UDC_WorkbookDueDate__c,
                                    RelatedTo__r.Document_Name__c, RelatedTo__r.AH_UDC_PropertyAccount__r.PropertyName__c
                                    FROM AH_UDC_Workbook__c
                                    WHERE Enabled__c = true AND RecordTypeId = :workbookSentRecordTypeId
                                    AND Archive__c = false AND RelatedTo__c IN :lstNIDocs
                                    AND SentStatus__c in (:AH_UDC_Constants.SENT_STATUS_NEW,:AH_UDC_Constants.SENT_STATUS_IN_PROGRESS,:AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED)
                                    AND RelatedTo__r.AH_UDC_WorkbookWithdrawn__c = false
                                    AND Released__c = true
                                    LIMIT 2000];

                     if (lstWorkbook != null && lstWorkbook.size() > 0) {
                        //Initialize list to prevent error
                        WorkbookList = new List<WorkbookWrapper> ();

                        for (AH_UDC_Workbook__c objWorkbook : lstWorkbook) {
                           objWorkbookWrapper = new WorkbookWrapper();
                           objWorkbookWrapper.Id = objWorkbook.Id;
                           objWorkbookWrapper.DocumentName = objWorkbook.RelatedTo__r.Document_Name__c;
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
                     AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                                          'AH_UDC_Welcome',
                                          'FillWorkbookList',
                                          'An exception occurred on FillWorkbookList');
                     ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.AH_UDC_Common_Error_Message));
                  }
               }
            }
         }
      }
      catch(Exception ex) {
         IsErrorOccurred = true;
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
         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
         //Get udc contact - contactId is required for community user so ideally this query never fails
         lstUDCContact = [SELECT Id, TermsandConditionsAcceptedDate__c, TermsandConditionsAccepted__c
                          FROM AH_UDC_Contact__c
                          WHERE Contact__c = :objUser.ContactId
                          ORDER BY CreatedDate DESC
                          LIMIT 1];

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
            isProfileChanged = AH_UDC_SharedWithoutSharing.ChangeUserProfileToChatter(UserInfo.getUserId());
         }
         AH_UDC_SystemContext.UpdateObjects(lstUDCContact);
      }
      catch(Exception ex) {
         IsErrorOccurred = true;
         AH_UDC_LogHelper.debug('Error occurred : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber());
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_Welcome',
                              'TermsAndConditionNext',
                              'An exception occurred on TermsAndConditionNext',
                              ex, null, null);
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.AH_UDC_Common_Error_Message));
      }
   }
}