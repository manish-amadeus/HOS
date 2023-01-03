/***********************************************************************************************
  Name            : AH_UDC_SendWorkbookAddContact
  Author          : Tushar Gupta
  Created Date    : 05-Mar-2021
  Last Mod Date   : 05-Mar-2021
  Last Mod By     : Tushar Gupta
  NICC Reference  : 
  User Story ID   : 587450
  Description     : Controller class for Send Workbook New Conact of UDC
  Change History  :
 ************************************************************************************************/
public with sharing class AH_UDC_SendWorkbookAddContact {
   public Id SelectedEmailTemplateId { get; set; }
   public String SelectedEmailTemplateName { get; set; }
   public Boolean IsErrorOccurred { get; set; } //To display error on page 
   public Id InsertedUDCContactId { get; set; }
   public Id SelectedContactId { get; set; }
   public String SelectedContactName { get; set; }
   public string ValidationMessage { get; set; }
   public String NiDocId { get; set; }
   public boolean IsUserCreated { get; set; }
   @TestVisible private string LogFunctionalArea = 'AH_UDC_SendWorkbookAddContact'; //This is used for AH_UDC_Log Entries being written on this page
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }
   //This is used client side to determine if AH_UDC_Log Messages need to be written from the Page Load
   public Boolean HasPageLoadLogMessages {
      get {
         AH_UDC_LogHelper.Debug('PageLoadLogMessages: ' + PageLoadLogMessages);
         return PageLoadLogMessages.size() > 0;
      }
   }

   //Initialize constructor
   public AH_UDC_SendWorkbookAddContact(ApexPages.StandardController controller) {
      try {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;

         if (String.isBlank(apexpages.currentpage().getparameters().get('nidocid'))) {
            LogException('Constructor', 'NI Document Id Not Found', null);
            return;
         }
         NiDocId = String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('nidocid'));

         GetDefaultEmailTemplateDetails(); //Set default email template
      }
      catch(Exception ex) {
         String strMessage = 'Error occurred in AH_UDC_SendWorkbookAdditionalContact() Constructor => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('Constructor', strMessage, ex);
      }
      finally {
         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
      }
   }

   //Get default email template details based on developer name
   public void GetDefaultEmailTemplateDetails() {
      List<EmailTemplate> lstEmailTemplates = null;
      try {
         //Get default email template details from the object based on developer name
         lstEmailTemplates = [SELECT Id, Name
                              FROM EmailTemplate
                              WHERE DeveloperName = :Label.AH_UDC_Send_Workbook_Default_Email_Template];

         if (lstEmailTemplates != null && lstEmailTemplates.size() > 0) {
            SelectedEmailTemplateId = lstEmailTemplates[0].Id;
            SelectedEmailTemplateName = lstEmailTemplates[0].Name;
         }
      }
      catch(Exception ex) {
         String strMessage = 'Error occurred in GetDefaultEmailTemplateDetails() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetDefaultEmailTemplateDetails', strMessage, ex);
      }
      finally { //Dispose unused variables/objects
         lstEmailTemplates = null;
      }
   }

   //Check Contact has external User or not
   public void CheckExternalUser() {
      Integer intUserCount = 0;
      Contact objContact = null;
      try {
         ValidationMessage = '';
         if (String.isNotBlank(SelectedContactId) && String.isNotBlank(NiDocId)) {
            objContact = [SELECT Id, Email
                          FROM Contact
                          WHERE Id = :SelectedContactId];
            if (objContact != null && String.isBlank(objContact.Email)) {
               ValidationMessage = Label.AH_UDC_Send_Workbook_Additional_Contact_Email_Required_Message;
            } else if (IsWorkbookAlreadyAssigned(SelectedContactId, NiDocId)) {
               ValidationMessage = Label.AH_UDC_Additional_Contact_Duplicate_Contact_Error_Message;
            }
         } else {
            LogException('CheckExternalUser', 'SelectedContactId or NiDocId is blank', null);
         }
      }
      catch(Exception ex) {
         String strMessage = 'Error occurred in CheckExternalUser() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetDefaultEmailTemplateDetails', strMessage, ex);
      }
      finally {
         objContact = null;
      }
   }

   //Check if workbook is already assigned to the contact
   private Boolean IsWorkbookAlreadyAssigned(Id ContactId, Id NIDocId) {
      List<AH_UDC_Contact__c> lstUDCContact = null;
      try {
         lstUDCContact = new List<AH_UDC_Contact__c> ([SELECT Id
                                                      FROM AH_UDC_Contact__c
                                                      WHERE Contact__c = :ContactId AND Document__c = :NIDocId]);
         return lstUDCContact != null && lstUDCContact.size() > 0;
      }
      catch(Exception ex) {
         throw ex;
      }
      finally { //Dispose unused variables/objects
         lstUDCContact = null;
      }
   }

   //Create new UDC Contact and send email to external user
   public void SendWorkbookAdditionalContact() {
      AH_UDC_Contact__c UDCAdditionalContact = null;
      try {
         if (String.isNotBlank(NiDocId) && String.isNotBlank(SelectedContactId)) {
            UDCAdditionalContact = new AH_UDC_Contact__c();
            UDCAdditionalContact.Document__c = NiDocId;
            UDCAdditionalContact.Contact__c = SelectedContactId;
            insert UDCAdditionalContact;
            InsertedUDCContactId = UDCAdditionalContact.Id;
            if (String.isNotBlank(InsertedUDCContactId)) {
               //Send email to selected external user
               SendEmailToContact();
            } else {
               LogException('SendWorkbookAdditionalContact', 'Error occurred in inserting UDCContact', null);
            }
         } else {
            LogException('SendWorkbookAdditionalContact', 'NiDocId or SelectedContactId is not found', null);
         }
      }
      catch(Exception ex) {
         String strMessage = 'Error occurred in SendWorkbookAdditionalContact() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('SendWorkbookAdditionalContact', strMessage, ex);
      }
   }

   //Send email to contcat after sending workbook
   private void SendEmailToContact() {
      List<string> lstToAddresses = null;
      Messaging.SingleEmailMessage objEmail = null;
      List<Messaging.SingleEmailMessage> lstEmails = null;
      Messaging.SendEmailResult[] results = null;
      List<User> lstUser = null;
      try {
         lstUser = [SELECT Id, Email
                    FROM User
                    WHERE ContactId = :SelectedContactId AND IsActive = true];

         if (lstUser != null && String.isNotBlank(lstUser.get(0).Email) && String.isNotBlank(NiDocId)) {
            AH_UDC_LogHelper.Debug('SelectedEmailTemplateId : ' + SelectedEmailTemplateId);
            AH_UDC_LogHelper.Debug('lstUser.Email : ' + lstUser.get(0).Email);
            AH_UDC_LogHelper.Debug('lstUser.get(0).Id : ' + lstUser.get(0).Id);

            lstToAddresses = new List<string> ();
            lstToAddresses.add(lstUser.get(0).Email); //Prepare to email addresses list

            //Prerender email so that we can do replacement of URL
            objEmail = Messaging.renderStoredEmailTemplate(SelectedEmailTemplateId, SelectedContactId, NiDocId);

            //Replace Community Portal URL
            objEmail.setHtmlBody(objEmail.getHtmlBody().replace(
                                                                AH_UDC_ConfigHelper.GetString('AH_UDC_EmailTemplatePortalUrlPlaceholder', ''),
                                                                AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityPortalUrl', '')));

            //Set to whom the email will be sent
            objEmail.setToAddresses(lstToAddresses);

            lstEmails = new List<Messaging.SingleEmailMessage> ();
            lstEmails.add(objEmail);
            results = Messaging.sendEmail(lstEmails, false);

            if (results != null && results.size() > 0 && results[0].success) {
               AH_UDC_LogHelper.Debug('The email has been sent successfully.');
            } else {
               IsErrorOccurred = true;
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, Label.AH_UDC_Send_Email_Error_Message));
               AH_UDC_LogHelper.Debug('Error in Sending Email : ' + results[0].getErrors());
            }
         }
      }
      catch(Exception ex) {
         String strMessage = 'Error occurred in SendEmailToContact() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('SendEmailToContact', strMessage, ex);
      }
   }

   //Create community users before sending workbooks
   public void CreateCommunityUsers() {
      try {
         //NOTE: This method calls DML executed against SETUP objects ... thus no other objects can be inserted (like Log Messages)
         if (String.isNotBlank(SelectedContactId)) {
            //Create the primary contact's Community User
            IsUserCreated = AH_UDC_SharedWithoutSharing.SetupCommunityAccess(SelectedContactId);
         } else {
            LogException('CreateCommunityUsers', 'SelectedContactId is blank', null);
         }
      }
      catch(Exception ex) {
         String strMessage = 'Error occurred in CreateCommunityUsers() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('CreateCommunityUsers', strMessage, ex);
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