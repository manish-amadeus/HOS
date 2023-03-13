/*
 * Name         : AH_UDC_WorkbookSentEmail_Batch
 * Created By   : Rob Stevens (Rob.Stevens@amadeus.com)
 * Created Date : 2022-10-17
 * Description  : Used to send Workbook Sent emails
 * Dependencies : 
 * Test Class   : AH_UDC_WorkbookSentEmail_Batch.cls
 */
global class AH_UDC_WorkbookSentEmail_Batch implements Database.Batchable<SObject> {

   @TestVisible private static Boolean IsTestException = false;
   global AH_UDC_WorkbookSentEmail_Batch() {

   }

   /**
    * @description gets invoked when the batch job starts
    * @param context contains the job ID
    * @returns the record set as a QueryLocator object that will be batched for execution
    */
   global Database.QueryLocator start(Database.BatchableContext context) {
      AH_UDC_LogHelper.Debug('AH_UDC_WorkbookSentEmail_Batch: start: STARTED');
      AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_MESSAGE, 'AH_UDC_WorkbookSentEmail_Batch', 'Started', 'Workbook Sent Email Job Status : Started', null, null, null);
      return Database.getQueryLocator('select id, Name, DueDate__c, RelatedTo__c, ' +
                                      'Reminder1Enabled__c, Reminder1Days__c, Reminder1EmailTemplate__c, Reminder1Sent__c, ' +
                                      'Reminder2Enabled__c, Reminder2Days__c, Reminder2EmailTemplate__c, Reminder2Sent__c, ' +
                                      'Reminder3Enabled__c, Reminder3Days__c, Reminder3EmailTemplate__c, Reminder3Sent__c, ' +
                                      'Reminder4Enabled__c, Reminder4Days__c, Reminder4EmailTemplate__c, Reminder4Sent__c ' +
                                      'from AH_UDC_Workbook__c ' +
                                      'where DueDate__c !=null ' +
                                      'and SentStatus__c in (\'New\', \'In Progress\') ' +
                                      'and Archive__c=false and InternalUseOnly__c=false and Withdrawn__c=false ' +
                                      'and ((Reminder1Enabled__c =true and Reminder1Sent__c = null) or ' +
                                      '(Reminder2Enabled__c =true and Reminder2Sent__c = null) or ' +
                                      '(Reminder3Enabled__c =true and Reminder3Sent__c = null) or ' +
                                      '(Reminder4Enabled__c =true and Reminder4Sent__c = null)) ');
   }

   /**
    * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
    * @param context contains the job ID
    * @param scope contains the batch of records to process.
    * NOTE: each batch is executed in serial not parallel
    */
   global void execute(Database.BatchableContext context, List<AH_UDC_Workbook__c> lstWorkbooks) {
      AH_UDC_LogHelper.Debug('AH_UDC_WorkbookSentEmail_Batch: execute: STARTED');
      AH_UDC_LogHelper.Debug('lstWorkbooks.size(): ' + lstWorkbooks.size());
      // process each batch of records default size is 10

      //Check if Workbook Sent Emails is enabled
      Boolean wbSentEmailEnabled = AH_UDC_ConfigHelper.GetBoolean('AH_UDC_WorkbookSentEmailEnabled', false);
      //Stop Purge right away if it becomes disabled
      AH_UDC_LogHelper.Debug('lstWorkbooks.wbSentEmailEnabled: ' + wbSentEmailEnabled);
      if (!wbSentEmailEnabled) return;

      try {
         if (Test.isRunningTest() && IsTestException) Integer a = 1 / 0;

         AH_UDC_LogHelper.Debug('lstWorkbooks.size: ' + lstWorkbooks.size());

         //Build List of Related IDs and Templates
         Set<Id> RelatedIds = new Set<Id> ();
         Set<String> TemplateNames = new Set<String> ();
         for (AH_UDC_Workbook__c wb : lstWorkbooks)
         {
            if (!RelatedIds.contains(wb.RelatedTo__c)) RelatedIds.add(wb.RelatedTo__c);
            if (String.isNotBlank(wb.Reminder1EmailTemplate__c)) if (!TemplateNames.contains(wb.Reminder1EmailTemplate__c)) TemplateNames.add(wb.Reminder1EmailTemplate__c);
            if (String.isNotBlank(wb.Reminder2EmailTemplate__c)) if (!TemplateNames.contains(wb.Reminder2EmailTemplate__c)) TemplateNames.add(wb.Reminder2EmailTemplate__c);
            if (String.isNotBlank(wb.Reminder3EmailTemplate__c)) if (!TemplateNames.contains(wb.Reminder3EmailTemplate__c)) TemplateNames.add(wb.Reminder3EmailTemplate__c);
            if (String.isNotBlank(wb.Reminder4EmailTemplate__c)) if (!TemplateNames.contains(wb.Reminder4EmailTemplate__c)) TemplateNames.add(wb.Reminder4EmailTemplate__c);
         }
         AH_UDC_LogHelper.Debug('TemplateNames.size(): ' + TemplateNames.size());
         AH_UDC_LogHelper.Debug('TemplateNames: ' + TemplateNames);

         List<EmailTemplate> templates = new List<EmailTemplate> ();
         If (TemplateNames.size() > 0) templates = [select id, DeveloperName from EmailTemplate where DeveloperName in :TemplateNames];

         //Get AH Contacts for the Related IDs and build Lookup list that includes contact user's email address
         List<AH_UDC_Contact__c> relatedContacts = [select id, Document__c, Contact__c, Contact__r.Email from AH_UDC_Contact__c where Document__c in :RelatedIds];
         AH_UDC_LogHelper.Debug('relatedContacts.size(): ' + relatedContacts.size());
         AH_UDC_LogHelper.Debug('relatedContacts: ' + relatedContacts);

         //Evaluate if Emails need to be sent for each workbook
         List<AH_UDC_Workbook__c> wbUpdates = new List<AH_UDC_Workbook__c> ();
         for (AH_UDC_Workbook__c wb : lstWorkbooks)
         {
            AH_UDC_Workbook__c wbUpdate = new AH_UDC_Workbook__c(Id = wb.id);
            Boolean wbUpdated = false;
            AH_UDC_LogHelper.Debug('wb.id: ' + wb.id);
            AH_UDC_LogHelper.Debug('wb.name: ' + wb.name);

            //Find Related Contacts
            List<Contact> SendContacts = new List<Contact> ();
            for (AH_UDC_Contact__c relatedContact : relatedContacts)
            {
               if (relatedContact.Document__c == wb.RelatedTo__c) SendContacts.add(new Contact(Id = relatedContact.Contact__c, Email = relatedContact.Contact__r.Email));
            }

            //Find Org Wide Id
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :AH_UDC_ConfigHelper.GetString('AH_UDC_WorkbookSentEmailOrgWideEmail', 'udcservice@amadeus.com')];
            if (owea.size() != 1) {
               AH_UDC_LogHelper.Debug('AH_UDC_WorkbookSentEmail_Batch: Missing Org Wide Email: ' + AH_UDC_ConfigHelper.GetString('AH_UDC_WorkbookSentEmailOrgWideEmail', 'udcservice@amadeus.com'));
               AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR, 'AH_UDC_WorkbookSentEmail_Batch', 'execute', 'Missing Org Wide Email: ' + AH_UDC_ConfigHelper.GetString('AH_UDC_WorkbookSentEmailOrgWideEmail', 'udcservice@amadeus.com'), null, null, null);
               return;
            }
            ID OrgWideEmail = owea[0].Id;

            AH_UDC_LogHelper.Debug('SendContacts.size(): ' + SendContacts.size());
            if (SendContacts.size() > 0)
            {
               //Determine which Reminders need to be sent
               if (ShouldSendReminder(wb.Reminder1Sent__c, wb.Reminder1Enabled__c, wb.Reminder1Days__c, wb.Reminder1EmailTemplate__c, wb.DueDate__c, templates))
               {
                  If (SendEmailToContacts('AH_UDC_WorkbookSentEmail_Batch', SendContacts, wb.Reminder1EmailTemplate__c, templates, wb.RelatedTo__c, OrgWideEmail)) {
                     wbUpdated = true;
                     wbUpdate.Reminder1Sent__c = System.now();
                  }
               }
               if (ShouldSendReminder(wb.Reminder2Sent__c, wb.Reminder2Enabled__c, wb.Reminder2Days__c, wb.Reminder2EmailTemplate__c, wb.DueDate__c, templates))
               {
                  If (SendEmailToContacts('AH_UDC_WorkbookSentEmail_Batch', SendContacts, wb.Reminder2EmailTemplate__c, templates, wb.RelatedTo__c, OrgWideEmail)) {
                     wbUpdated = true;
                     wbUpdate.Reminder2Sent__c = System.now();
                  }
               }
               if (ShouldSendReminder(wb.Reminder3Sent__c, wb.Reminder3Enabled__c, wb.Reminder3Days__c, wb.Reminder3EmailTemplate__c, wb.DueDate__c, templates))
               {
                  If (SendEmailToContacts('AH_UDC_WorkbookSentEmail_Batch', SendContacts, wb.Reminder3EmailTemplate__c, templates, wb.RelatedTo__c, OrgWideEmail)) {
                     wbUpdated = true;
                     wbUpdate.Reminder3Sent__c = System.now();
                  }
               }
               if (ShouldSendReminder(wb.Reminder4Sent__c, wb.Reminder4Enabled__c, wb.Reminder4Days__c, wb.Reminder4EmailTemplate__c, wb.DueDate__c, templates))
               {
                  If (SendEmailToContacts('AH_UDC_WorkbookSentEmail_Batch', SendContacts, wb.Reminder4EmailTemplate__c, templates, wb.RelatedTo__c, OrgWideEmail)) {
                     wbUpdated = true;
                     wbUpdate.Reminder4Sent__c = System.now();
                  }
               }
            }
            if (wbUpdated) wbUpdates.add(wbUpdate);
         }
         AH_UDC_LogHelper.Debug('AH_UDC_WorkbookSentEmail_Batch: execute: STARTED');

         //Send Emails
         if (wbUpdates.size() > 0) {
            //Set WBReminder Sent Dates
            Update wbUpdates;
         }
      } catch(Exception e) {
         AH_UDC_LogHelper.Debug('AH_UDC_WorkbookSentEmail_Batch: Exception: ' + e);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                              'AH_UDC_WorkbookSentEmail_Batch', 'execute',
                              'Error while processing Workbook Sent Email',
                              e, null, null);
      }
   }

   //Determine if Reminder on Sent Workbook should be enabled
   private Boolean ShouldSendReminder(DateTime Sent, Boolean ReminderEnabled, Decimal ReminderDays, string ReminderEmailTemplate, Date wbDueDate, List<EmailTemplate> templates)
   {
      AH_UDC_LogHelper.Debug('ShouldSendReminder: Start');
      AH_UDC_LogHelper.Debug('ShouldSendReminder: ReminderEnabled: ' + ReminderEnabled);
      AH_UDC_LogHelper.Debug('ShouldSendReminder: ReminderDays: ' + ReminderDays);
      AH_UDC_LogHelper.Debug('ShouldSendReminder: wbDueDate: ' + wbDueDate);
      AH_UDC_LogHelper.Debug('ShouldSendReminder: Sent: ' + Sent);
      AH_UDC_LogHelper.Debug('ShouldSendReminder: ReminderEmailTemplate: ' + ReminderEmailTemplate);
      if (!ReminderEnabled || ReminderDays == null || wbDueDate == null || Sent != null) return false;
      //Determine if template is specified and valid
      if (String.isEmpty(ReminderEmailTemplate)) return false;
      Boolean isValidTemplate = false;
      for (EmailTemplate template : templates)
      {
         if (template.DeveloperName == ReminderEmailTemplate) {
            isValidTemplate = true;
            break;
         }
      }
      AH_UDC_LogHelper.Debug('ShouldSendReminder: isValidTemplate: ' + isValidTemplate);
      if (!isValidTemplate) return false;
      Integer DaysBetween = (system.today()).daysBetween(wbDueDate);
      if (ReminderDays >= 0 && system.today() <= wbDueDate)
      {
         AH_UDC_LogHelper.Debug('ShouldSendReminder: daysBetween: ' + (system.today()).daysBetween(wbDueDate));
         If (DaysBetween <= ReminderDays) {
            AH_UDC_LogHelper.Debug('ShouldSendReminder: return: TRUE ');
            return true;
         }
      }
      if (ReminderDays< 0 && system.today()> wbDueDate)
      {
         If (DaysBetween <= ReminderDays) {
            AH_UDC_LogHelper.Debug('ShouldSendReminder: return: TRUE ');
            return true;
         }
      }
      AH_UDC_LogHelper.Debug('ShouldSendReminder: return: FALSE ');
      return false;
   }

   //Send email to contact after sending workbook
   public static Boolean SendEmailToContacts(
                                             String LogFunctionalArea, List<Contact> sendContacts, String ReminderEmailTemplate, List<EmailTemplate> templates, Id NIDocId, string ReplyTo)
   {
      ID EmailTemplateId = null;
      for (EmailTemplate template : templates)
      {
         AH_UDC_LogHelper.Debug('AH_UDC_WorkbookSentEmail_Batch.SendEmailToContacts : template.DeveloperName: ' + template.DeveloperName);
         if (template.DeveloperName == ReminderEmailTemplate)
         {
            EmailTemplateId = template.id;
            AH_UDC_LogHelper.Debug('AH_UDC_WorkbookSentEmail_Batch.SendEmailToContacts : Found EmailTemplateId: ' + EmailTemplateId);
            break;
         }
      }
      return AH_UDC_SharedWithoutSharing.SendEmailToContacts(LogFunctionalArea, sendContacts, EmailTemplateId, NIDocId, ReplyTo);
   }

   /**
    * @description gets invoked when the batch job finishes. Place any clean up code in this method.
    * @param context contains the job ID
    */
   global void finish(Database.BatchableContext context) {
      // Query the AsyncApexJob object to retrieve the current job's information.
      AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                        FROM AsyncApexJob
                        WHERE Id = :context.getJobId()];
      String strStatusMessage = 'Workbook Sent Email Job Status : ' + a.Status + '. The batch Apex job processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.';
      AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_MESSAGE, 'AH_UDC_WorkbookSentEmail_Batch', 'Finished', strStatusMessage, null, null, null);
   }
}