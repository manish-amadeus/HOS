/**
 * Name          : AH_UDC_REST_WorkbookSentExport
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-01-12
 * Description   : This class accepts a WorkBookSent Id and returns data for the responses
 * Dependencies  : 
 **/

@RestResource(urlMapping = '/AH_UDC_WorkbookSentExport')
global with sharing class AH_UDC_REST_WorkbookSentExport {
   public static final Integer QAJsonMaxPerRequest = 20;

   @HttpGet
   global static void get() {
      AH_UDC_LogHelper.QueueLogs = true;

      AH_UDC_LogHelper.Debug('AH_UDC_REST_WorkbookSentExport');
      WorkbookSentExportResponse resp = new WorkbookSentExportResponse();
      RestRequest req = RestContext.request;
      try {
         String WorkbookSentStepId = RestContext.request.params.get('workbookSentStepId');

         resp.responseId = String.valueOf(RestContext.request.params.get('responseId'));
         integer iStartingSO = String.isBlank(RestContext.request.params.get('startSortOrder')) ? 0 : Integer.valueOf(RestContext.request.params.get('startSortOrder'));

         if (Test.isRunningTest() && WorkbookSentStepId == 'TestException') integer i = 1 / 0;
         if (String.isBlank(WorkbookSentStepId)) {
            resp.statusCode = '400';
            resp.message = 'Bad Request';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         //Check that Workbook Sent Step ID is valid
         List<AH_UDC_WorkbookStep__c> workbooksteps = [select Id, Form__r.RecordTypeId
                                                       from AH_UDC_WorkbookStep__c
                                                       where id = :WorkbookSentStepId];

         if (workbooksteps == null || workbooksteps.size() == 0) {
            resp.statusCode = '404';
            resp.message = 'Not Found';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         //Get Most Recent AH_UDC_WorkbookStepResponse__c
         if (string.isBlank(resp.responseId))
         {
            List<AH_UDC_WorkbookStepResponse__c> wbsResponses = [select Response__c
                                                                 from AH_UDC_WorkbookStepResponse__c
                                                                 where WorkbookStep__c = :WorkbookSentStepId
                                                                 and IsMostRecentResponse__c = true];
            if (wbsResponses.size() == 0)
            {
               resp.statusCode = '200';
               resp.message = 'No Response';
               RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
               return;
            }
            resp.responseId = wbsResponses[0].Response__c;
         }
         else
         {
         }

         //Build QA results
         Id rtFormAmadeusForm = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM).getRecordTypeId();
         Id rtFormAssemblyForm = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
         if (workbooksteps[0].form__r!=null)
         {
            if (workbooksteps[0].form__r.RecordTypeId == rtFormAmadeusForm)
            {
               if (iStartingSO == 0)
               {
                  integer rQACount = [SELECT COUNT()
                                      FROM AH_UDC_ResponseQA__c
                                      WHERE Response__c = :resp.responseId];
                  //resp.totalResponseQARecord = String.valueOf(rQACount); //set the total response count which helps to decide multiple get request
                  double rQABatch = rQACount / QAJsonMaxPerRequest;
                  resp.responseQABatches = String.valueOf(rQABatch).indexOf('.') == 0 ? String.valueOf(rQABatch) : String.valueOf(rQABatch + 1).substringBefore('.');
               }

               for (AH_UDC_ResponseQA__c amadeusFormQA :
                    [SELECT QAJson__c, SortOrder__c
                    FROM AH_UDC_ResponseQA__c
                    WHERE Response__c = : resp.responseId
                    AND SortOrder__c >= : iStartingSO
                    ORDER BY SortOrder__c ASC
                    LIMIT : QAJsonMaxPerRequest]) {

                  resp.QuestionAnswers.add(new QuestionAnswer(String.valueOf(amadeusFormQA.QAJson__c), String.valueOf(amadeusFormQA.SortOrder__c)));
               }
            }
            else if (workbooksteps[0].form__r.RecordTypeId == rtFormAssemblyForm)
            {
               //Get QAs - There will never be 10,000 (the SOQL max)
               List<AH_UDC_ResponseQA__c> QAs = [SELECT QAJson__c, QuestionField__c, Question__c, AnswerField__c, Answer__c, SortOrder__c
                                                 FROM AH_UDC_ResponseQA__c
                                                 WHERE Response__c = :resp.responseId];
               for (AH_UDC_ResponseQA__c QA : QAs) {
                  resp.QuestionAnswers.add(new QuestionAnswer(QA.QuestionField__c, QA.Question__c, QA.AnswerField__c, QA.Answer__c, String.valueOf(QA.SortOrder__c)));
               }
            }
            else {
               AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                                    'AH_UDC_REST_WorkbookSentExport', 'get',
                                    'An exception occurred processing a response: Invalid Record type',
                                    null, null, null);
               //Set the Return code
               resp.statusCode = '500';
               resp.message = 'Exception Occurred';
               RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
               return;
            }
         }
         resp.statusCode = '200';
         resp.message = 'Ok';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e) {
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
      public String responseQABatches;
      public String responseId;
      public List<QuestionAnswer> QuestionAnswers = new List<QuestionAnswer> ();

      public WorkbookSentExportResponse() {
      }

      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this, true);
      }
   }

   @TestVisible
   private class QuestionAnswer {
      public String QAJson;
      public String QuestionField;
      public String Question;
      public String AnswerField;
      public String Answer;
      public String SortOrder;
      public QuestionAnswer(String QuestionField, String Question, String AnswerField, String Answer, string SortOrder) {
         this.QuestionField = QuestionField;
         this.Question = Question;
         this.AnswerField = AnswerField;
         this.Answer = Answer;
         this.SortOrder = SortOrder;
      }
      public QuestionAnswer(String QAJson) {
         this.QAJson = QAJson;
      }
      public QuestionAnswer(string QAJson, string SortOrder)
      {
         this.QAJson = QAJson;
         this.SortOrder = SortOrder;
      }
   }
}