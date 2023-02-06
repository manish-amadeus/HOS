/**
 * Name          : AH_UDC_WorkbookResponsesExt
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2020-01-20
 * Description   : This is an extension class for the page AH_UDC_WorkbookResponses.
 * Dependencies  : 
 **/
public with sharing class AH_UDC_WorkbookResponsesExt {
   public Boolean IsErrorOccurred { get; set; }
   @TestVisible
   private ID selectedWorkbookId { get; set; }

   public Workbook displayWorkbook { get; set; }
   public string mode { get; set; }
   public string filename { get; set; }

   public static String getNewLine() {
      return '\n';
   }

   public static String getNewCell() {
      return ',';
   }

   @TestVisible private string LogFunctionalArea = 'AH_UDC_WorkbookResponsesExt'; //This is used for AH_UDC_Log Entries being written on this page
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }
   //This is used client side to determine if AH_UDC_Log Messages need to be written from the Page Load
   public Boolean HasPageLoadLogMessages {
      get {
         AH_UDC_LogHelper.Debug('PageLoadLogMessages: ' + PageLoadLogMessages);
         return PageLoadLogMessages.size() > 0;
      }
   }

   public AH_UDC_WorkbookResponsesExt(ApexPages.StandardController controller) {
      try {
         AH_UDC_LogHelper.QueueLogs = true;
         mode = '';

         if (String.isBlank(ApexPages.currentPage().getParameters().get('wbid'))) {
            IsErrorOccurred = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'No Workbook was specified.'));
            return;
         }

         if (Test.isRunningTest() && (ApexPages.currentPage().getParameters().get('wbid') == 'TestException')) {
            Integer a = 1 / 0;
         }

         selectedWorkbookId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('wbid'));

         if (ApexPages.currentPage().getParameters().get('mode') == 'CSV') {
            mode = 'CSV';
            filename = 'Responses.csv';
         }
         getResponses(selectedWorkbookId);
      }
      catch(Exception exc) {
         IsErrorOccurred = true;
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, Label.AH_UDC_Common_Error_Message_Backend));
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_WorkbookResponsesExt', 'Constructor',
                              'An exception occurred in the constructor',
                              exc, null, null);
         return;
      }
      finally {
         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   @TestVisible
   // Returns back whether the responses were successfully retrieved or not
   private Boolean getResponses(String workbookId) {
      try {
         List<AH_UDC_Workbook__c> wbRecords = [select id, name, SentDate__c, SentStatus__c, RelatedToDocName__c, CompletedDate__c,
                                               RelatedTo__r.name
                                               from AH_UDC_Workbook__c
                                               where Id = :workbookId];

         if (wbRecords == null || wbRecords.size() != 1) {
            IsErrorOccurred = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'The requested Workbook ID could not be found.'));
            return false;
         }

         displayWorkbook = new Workbook();
         displayWorkbook.Record = wbRecords[0];

         List<AH_UDC_WorkbookStep__c> stepRecords = [SELECT id, name, StepStatus__c, StepCompleted__c,
                                                     Workbook__r.SecurityCode__c,
                                                     Form__r.id, Form__r.RecordTypeId
                                                     FROM AH_UDC_WorkbookStep__c
                                                     WHERE Workbook__c = :workbookId
                                                     AND Enabled__c = true
                                                     ORDER BY SortOrder__c asc];
         if (stepRecords == null || stepRecords.size() == 0) {
            IsErrorOccurred = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'The requested Workbook does not have any steps.'));
            return false;
         }

         displayWorkbook.WorkbookSteps = new List<WorkbookStep> ();
         string StepToken = AH_UDC_Shared.CreateStepToken(stepRecords[0].Workbook__r.SecurityCode__c, stepRecords[0].Form__r.id, stepRecords[0].id );
         string ExportUrl = AH_UDC_ConfigHelper.GetString('AH_UDC_ExportUrl', '');
         displayWorkbook.ExportCsvUrl = ExportUrl.replace('{TOKEN}', StepToken).replace('{MODE}', 'CSV').replace('{STEP}', '*');
         displayWorkbook.ExportJsonUrl = ExportUrl.replace('{TOKEN}', StepToken).replace('{MODE}', 'JSON').replace('{STEP}', '*');

         List<Id> WorkbookStepIds = new List<Id> ();
         for (AH_UDC_WorkbookStep__c stepRecord : stepRecords)
         {
            WorkbookStepIds.add(stepRecord.id);
         }
         List<AH_UDC_WorkbookStepResponse__c> ResponseRecords = [SELECT WorkbookStep__c, Response__r.CreatedDate
                                                                 FROM AH_UDC_WorkbookStepResponse__c
                                                                 WHERE IsMostRecentResponse__c = true
                                                                 AND WorkbookStep__c in :WorkbookStepIds];

         Id FileUploadFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
         if (String.isBlank(FileUploadFormRecordTypeId)) {
            IsErrorOccurred = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'File upload form record type id not found with developer name ' + AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD));
            return false;
         }

         displayWorkbook.WorkbookHasResponses = ResponseRecords.size() >0;

         for (AH_UDC_WorkbookStep__c stepRecord : stepRecords) {
            WorkbookStep wbs = new WorkbookStep();
            wbs.Record = stepRecord;
            wbs.ExportCsvUrl = ExportUrl.replace('{TOKEN}', StepToken).replace('{MODE}', 'CSV').replace('{STEP}', stepRecord.id);
            wbs.ExportJsonUrl = ExportUrl.replace('{TOKEN}', StepToken).replace('{MODE}', 'JSON').replace('{STEP}', stepRecord.id);
            wbs.IsFileUploadStep = stepRecord.Form__r.RecordTypeId == FileUploadFormRecordTypeId;
            wbs.IsUrl = stepRecord.Form__c ==null;

            for (AH_UDC_WorkbookStepResponse__c ResponseRecord : ResponseRecords) {
               if (ResponseRecord.WorkbookStep__c == stepRecord.Id) {
                  wbs.ResponseRecord = ResponseRecord;
                  break;
               }
            }
            displayWorkbook.WorkbookSteps.add(wbs);
         }

         return true;
      }
      catch(Exception exc) {
         IsErrorOccurred = true;
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR, 'AH_UDC_WorkbookResponsesExt.getResponses', 'Unhandled Exception',
                              exc.getMessage(), exc, workbookId, 'AH_UDC_Workbook__c');
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, Label.AH_UDC_Common_Error_Message_Backend));
         return false;
      }
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

   class Workbook {
      public AH_UDC_Workbook__c Record { get; set; }
      public List<WorkbookStep> WorkbookSteps { get; set; }
      public string ExportCsvUrl { get; set; }
      public string ExportJsonUrl { get; set; }
      public boolean WorkbookHasResponses { get; set; }
   }

   class WorkbookStep {
      public AH_UDC_WorkbookStep__c Record { get; set; }
      public AH_UDC_WorkbookStepResponse__c ResponseRecord { get; set; }
      public boolean IsFileUploadStep { get; set; }
      public boolean IsUrl { get; set; }
      public string ExportCsvUrl { get; set; }
      public string ExportJsonUrl { get; set; }
   }
}