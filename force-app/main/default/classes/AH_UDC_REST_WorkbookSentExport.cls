/**
 * Name          : AH_UDC_REST_WorkbookSentExport
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-01-12
 * Description   : This class accepts a WorkBookSent Id and returns data for the responses
 * Dependencies  : 
 **/

@RestResource(urlMapping = '/AH_UDC_WorkbookSentExport')
global with sharing class AH_UDC_REST_WorkbookSentExport {

   @HttpGet
   global static void get() {
      AH_UDC_LogHelper.QueueLogs = true;

      AH_UDC_LogHelper.Debug('FormResponseGetResponse');
      WorkbookSentExportResponse resp = new WorkbookSentExportResponse();
      RestRequest req = RestContext.request;
      try {
         ID WorkbookSentId = RestContext.request.params.get('wbId');

         if (String.isBlank(WorkbookSentId)) {
            resp.statusCode = '400';
            resp.message = 'Bad Request';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         //Check that Form Sent ID is valid
         List<AH_UDC_Workbook__c> workbookSent =
         [select Id, name
         from AH_UDC_Workbook__c
         where id = : WorkbookSentId];
         AH_UDC_LogHelper.Debug('workbookSent: ' + workbookSent);
         AH_UDC_LogHelper.Debug('workbookSent: ' + workbookSent.size());

         if (workbookSent == null || workbookSent.size() == 0) {
            resp.statusCode = '401';
            resp.message = 'Not Found';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }
         resp.Name = workbookSent[0].Name;

         //Get Steps
         ID wbId = workbookSent[0].id;
         List<Id> stepIds = new List<Id> ();
         List<AH_UDC_WorkbookStep__c> steps = [select id, name from AH_UDC_WorkbookStep__c where Workbook__c = :wbId order by sortorder__c];
         for (AH_UDC_WorkbookStep__c step : steps) {
            stepIds.Add(step.id);
         }

         //Get Response (most recent)
         List<Id> responseIds = new List<Id> ();
         List<AH_UDC_Response__c> responses = [select id, WorkbookStep__c from AH_UDC_Response__c where WorkbookStep__c in :stepIds];
         Id LastStepId = null;
         List<AH_UDC_Response__c> latestResponses = new List<AH_UDC_Response__c> ();
         for (AH_UDC_Response__c response : responses) {
            if (response != null || LastStepId != response.WorkbookStep__c) {
               responseIds.Add(response.id);
               latestResponses.Add(response);
            }
         }

         //Build Steps
         for (AH_UDC_WorkbookStep__c step : steps) {
            WorkbookStep wbs = new WorkbookStep(step.Name);
            for (AH_UDC_Response__c response : latestResponses) {
               if (response.WorkbookStep__c == step.id) {
                  wbs.QuestionAnswers = new List<QuestionAnswer> ();

                  //Get QAs
                  List<AH_UDC_ResponseQA__c> QAs = [SELECT Id, QuestionField__c, Question__c, AnswerField__c, Answer__c
                                                    FROM AH_UDC_ResponseQA__c
                                                    WHERE Response__c = :response.id];
                  for (AH_UDC_ResponseQA__c QA : QAs) {
                     if (response == null || LastStepId != response.WorkbookStep__c) {
                        QuestionAnswer newQA = new QuestionAnswer(QA.QuestionField__c, QA.Question__c, QA.AnswerField__c, QA.Answer__c);
                        wbs.QuestionAnswers.add(newQA);
                     }
                  }
                  resp.WorkbookSteps.add(wbs);
                  break;
               }
            }
         }
         resp.statusCode = '200';
         resp.message = 'Ok';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e) {
         AH_UDC_LogHelper.Debug('Exception: ' + e);

         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_REST_WorkbookSentExport', 'get',
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
            AH_UDC_LogHelper.Debug('AH_UDC_REST_WorkbookSentExport.Get - Failed to write QueuedLogs');
         }
      }
   }

   @TestVisible
   private class WorkbookSentExportResponse {
      public String statusCode;
      public String message;
      public String Name;
      public List<WorkbookStep> WorkbookSteps = new List<WorkbookStep> ();

      public WorkbookSentExportResponse() {
      }

      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this);
      }
   }

   private class WorkbookStep {
      public String Name;
      public List<QuestionAnswer> QuestionAnswers = new List<QuestionAnswer> ();

      public WorkbookStep(string Name) {
         this.Name = Name;
      }
   }

   private class QuestionAnswer {
      public String QuestionField;
      public String Question;
      public String AnswerField;
      public String Answer;
      public QuestionAnswer(string QuestionField, string Question, string AnswerField, string Answer) {
         this.QuestionField = QuestionField;
         this.Question = Question;
         this.AnswerField = AnswerField;
         this.Answer = Answer;
      }
   }
}