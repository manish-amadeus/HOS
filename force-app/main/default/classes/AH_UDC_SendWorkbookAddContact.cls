<<<<<<< HEAD
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
   public Boolean IsErrorOccurredInEmail { get; set; } //It will be true only if error occurred while sending an email
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

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
      }
      catch(Exception ex) {
         String strMessage = 'Error occurred in AH_UDC_SendWorkbookAdditionalContact() Constructor => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('Constructor', strMessage, ex);
      }
      finally {
         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
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

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
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
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0; //Throw an exception from the test class
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
      try {
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0; //Throw an exception from the test class
         List<AH_UDC_Contact__c> lstUDCContact = [SELECT Id
                                                  FROM AH_UDC_Contact__c
                                                  WHERE Contact__c = :ContactId AND Document__c = :NIDocId];
         return lstUDCContact != null && lstUDCContact.size() > 0;
      }
      catch(Exception ex) {
         String strMessage = 'Error occurred : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('IsWorkbookAlreadyAssigned', strMessage, ex);
         throw ex;
      }
   }

   //Create new UDC Contact and send email to external user
   public void SendWorkbookAdditionalContact() {
      AH_UDC_Contact__c UDCAdditionalContact = null;
      try {
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0; //Throw an exception from the test class  
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

   //Send email to contact after sending workbook
   private void SendEmailToContact() {
      try {
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0; //Throw an exception from the test class
         if (String.isNotBlank(NiDocId)) {
            List<User> lstUser = [SELECT Id, Email
                                  FROM User
                                  WHERE ContactId = :SelectedContactId
                                  AND IsActive = true];

            if (lstUser.size() > 0 && String.isNotBlank(lstUser.get(0).Email)) {
               List<string> lstToAddresses = new List<string> ();
               lstToAddresses.add(lstUser.get(0).Email); //Prepare to email addresses list

               Boolean IsEmailSent = AH_UDC_SharedWithoutSharing.SendEmailToContacts(LogFunctionalArea, lstToAddresses, SelectedEmailTemplateId, SelectedContactId, NiDocId);
               if (IsEmailSent) {
                  AH_UDC_LogHelper.Debug('Email has been sent successfully.');
               }
               else {
                  IsErrorOccurred = true;
                  IsErrorOccurredInEmail = true;
               }
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
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0; //Throw an exception from the test class
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
=======
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
   public Boolean IsErrorOccurredInEmail { get; set; } //It will be true only if error occurred while sending an email
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

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
      }
      catch(Exception ex) {
         String strMessage = 'Error occurred in AH_UDC_SendWorkbookAdditionalContact() Constructor => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('Constructor', strMessage, ex);
      }
      finally {
         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
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

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
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
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0; //Throw an exception from the test class
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
      try {
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0; //Throw an exception from the test class
         List<AH_UDC_Contact__c> lstUDCContact = [SELECT Id
                                                  FROM AH_UDC_Contact__c
                                                  WHERE Contact__c = :ContactId AND Document__c = :NIDocId];
         return lstUDCContact != null && lstUDCContact.size() > 0;
      }
      catch(Exception ex) {
         String strMessage = 'Error occurred : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('IsWorkbookAlreadyAssigned', strMessage, ex);
         throw ex;
      }
   }

   //Create new UDC Contact and send email to external user
   public void SendWorkbookAdditionalContact() {
      AH_UDC_Contact__c UDCAdditionalContact = null;
      try {
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0; //Throw an exception from the test class  
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

   //Send email to contact after sending workbook
   private void SendEmailToContact() {
      try {
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0; //Throw an exception from the test class
         if (String.isNotBlank(NiDocId)) {
            List<Contact> sendContacts = [SELECT Id, Email
                                          FROM Contact
                                          WHERE ID = :SelectedContactId];

            if (sendContacts.size() > 0 && String.isNotBlank(sendContacts[0].Email)) {
               Boolean IsEmailSent = AH_UDC_SharedWithoutSharing.SendEmailToContacts(LogFunctionalArea, sendContacts, SelectedEmailTemplateId, NiDocId, null);
               if (IsEmailSent) {
                  AH_UDC_LogHelper.Debug('Email has been sent successfully.');
               }
               else {
                  IsErrorOccurred = true;
                  IsErrorOccurredInEmail = true;
               }
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
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0; //Throw an exception from the test class
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
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}