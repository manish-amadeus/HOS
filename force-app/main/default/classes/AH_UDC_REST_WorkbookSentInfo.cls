/**
 * Name          : AH_UDC_REST_WorkbookSentInfo
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-01-12
 * Description   : This class accepts a WorkBookSent Id and returns data about the workbook.  This is used by integrating applications.
 * Dependencies  : 
 **/

@RestResource(urlMapping = '/AH_UDC_WorkbookSentInfo')
global with sharing class AH_UDC_REST_WorkbookSentInfo {
   public static final Integer QAJsonMaxPerRequest = 20;

   @HttpGet
   global static void get() {
      AH_UDC_LogHelper.QueueLogs = true;

      AH_UDC_LogHelper.Debug('AH_UDC_REST_WorkbookSentInfo');
      WorkbookSentInfoResponse resp = new WorkbookSentInfoResponse();
      RestRequest req = RestContext.request;
      try {
         String workbookSentId = RestContext.request.params.get('workbookSentId');
         if (Test.isRunningTest() && workbookSentId=='exception1') integer e = 1/0;

         if (String.isBlank(workbookSentId)) {
            resp.statusCode = '400';
            resp.message = 'Bad Request';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         //Check that Workbook Sent ID is valid and that the user has access to it
         List<AH_UDC_WorkbookStep__c> workbooksteps = [SELECT id, name, StepStatus__c, StepCompleted__c,
                                                       Workbook__r.SecurityCode__c, Workbook__r.RelatedToDocName__c, Workbook__r.SentDate__c, Workbook__r.SentStatus__c,
                                                       Workbook__r.RelatedTo__r.Name, Workbook__r.RelatedTo__r.Document_Name__c,
                                                       Form__r.id
                                                       FROM AH_UDC_WorkbookStep__c
                                                       WHERE Workbook__c = :workbookSentId
                                                       AND Enabled__c = true
                                                       ORDER BY SortOrder__c asc];

         if (workbooksteps == null || workbooksteps.size() == 0) {
            resp.statusCode = '404';
            resp.message = 'Not Found';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         resp.workbookSentId = workbookSentId;
         resp.documentName = workbooksteps[0].Workbook__r.RelatedTo__r.Document_Name__c;
         resp.documentId = workbooksteps[0].Workbook__r.RelatedTo__r.Name;
         resp.sentDate = workbooksteps[0].Workbook__r.SentDate__c;
         resp.sentStatus = workbooksteps[0].Workbook__r.SentStatus__c;

         string StepToken = AH_UDC_Shared.CreateStepToken(workbooksteps[0].Workbook__r.SecurityCode__c, workbooksteps[0].Form__r.id);
         string ExportUrl = AH_UDC_ConfigHelper.GetString('AH_UDC_ExportUrl', '');
         resp.ExportCsvUrl = ExportUrl.replace('{TOKEN}', StepToken).replace('{MODE}', 'CSV').replace('{STEP}', '*');
         resp.ExportJsonUrl = ExportUrl.replace('{TOKEN}', StepToken).replace('{MODE}', 'JSON').replace('{STEP}', '*');

         for (AH_UDC_WorkbookStep__c WorkbookStep : WorkbookSteps) {
            WorkbookStep wbs = new WorkbookStep();
            wbs.id = WorkbookStep.Id;
            wbs.name = WorkbookStep.name;
            wbs.stepStatus = WorkbookStep.StepStatus__c;
            wbs.ExportCsvUrl = ExportUrl.replace('{TOKEN}', StepToken).replace('{MODE}', 'CSV').replace('{STEP}', WorkbookStep.id);
            wbs.ExportJsonUrl = ExportUrl.replace('{TOKEN}', StepToken).replace('{MODE}', 'JSON').replace('{STEP}', WorkbookStep.id);
            resp.WorkbookSteps.add(wbs);
         }

         resp.statusCode = '200';
         resp.message = 'Ok';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e) {
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_REST_WorkbookSentInfo', 'get',
                              'An exception occurred processing a response: ' + e.getMessage(),
                              e, null, null);

         //Set the Return code
         resp.statusCode = '500';
         resp.message = 'Exception Occurred';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      finally {
         try {
            AH_UDC_LogHelper.writeQueuedLogs();
         }
         catch(Exception exc) {
            //If logs can't be written at least show an error in debug
            AH_UDC_LogHelper.Debug('AH_UDC_REST_WorkbookSentInfo.Get - Failed to write QueuedLogs');
         }
      }
   }

   @TestVisible
   private class WorkbookSentInfoResponse {
      public String statusCode { get; set; }
      public String message { get; set; }
      public String workbookSentId { get; set; }
      public string documentName { get; set; }
      public string documentId { get; set; }
      public DateTime sentDate { get; set; }
      public string sentStatus { get; set; }

      public string exportCsvUrl { get; set; }
      public string exportJsonUrl { get; set; }

      public List<WorkbookStep> WorkbookSteps { get; set; }

      public WorkbookSentInfoResponse() {
         this.WorkbookSteps = new List<WorkbookStep> ();
      }

      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this, true);
      }
   }

   class WorkbookStep {
      public string id { get; set; }
      public string name { get; set; }
      public string stepStatus { get; set; }

      public string exportCsvUrl { get; set; }
      public string exportJsonUrl { get; set; }
   }


}