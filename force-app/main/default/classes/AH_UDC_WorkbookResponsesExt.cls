/**WorkbookResponses
 * Name          : AH_UDC_WorkbookResponsesExtTest
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2020-01-20
 * Description   : This is an extension class for the page AH_UDC_WorkbookResponses
 * Dependencies  : AH_UDC_WorkbookResponsesExt
 **/
public with sharing class AH_UDC_WorkbookResponsesExt {

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

   //public AH_UDC_WorkbookResponsesExt() {
   //}

   public AH_UDC_WorkbookResponsesExt(ApexPages.StandardController controller) {
      try {
         AH_UDC_LogHelper.QueueLogs = true;
         mode = '';

         if (String.isBlank(ApexPages.currentPage().getParameters().get('wbid'))) {
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
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'An error occurred rendering this page; please contact the UDC support team. ' + (Test.isRunningTest() ? exc.getMessage() : '')));
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_WorkbookResponsesExt', 'Constructor',
                              'An exception occurred in the constructor',
                              exc, null, null);
         return;
      }
      finally {
         AH_UDC_LogHelper.writeQueuedLogs();
      }
   }

   @TestVisible
   // Returns back whether the responses were successfully retrieved or not
   private Boolean getResponses(String workbookId) {
      try {
         //Boolean OnlyShowLatestResponse = true;

         List<AH_UDC_Workbook__c> wbRecords = [select id, name, SentDate__c, SentStatus__c, RelatedToDocName__c, Description__c, CompletedDate__c
                                               from AH_UDC_Workbook__c
                                               where Id = :workbookId];

         if (wbRecords == null || wbRecords.size() != 1) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'The requested Workbook ID could not be found.'));
            return false;
         }

         displayWorkbook = new Workbook();
         displayWorkbook.Record = wbRecords[0];

         List<AH_UDC_WorkbookStep__c> stepRecords = [SELECT id, name, StepStatus__c, Description__c, StepCompleted__c
                                                     FROM AH_UDC_WorkbookStep__c
                                                     WHERE Workbook__c = :workbookId
                                                     AND Enabled__c = true
                                                     ORDER BY SortOrder__c asc];
         displayWorkbook.WorkbookSteps = new List<WorkbookStep> ();

         List<AH_UDC_Response__c> ResponseRecords = null;
         //if (OnlyShowLatestResponse) {
            ResponseRecords = [SELECT WorkbookStep__c, Id, Name, Responded__c
                               FROM AH_UDC_Response__c
                               WHERE WorkbookStep__r.Workbook__c = :workbookId
                               AND IsMostRecentResponse__c = true
                               ORDER BY Id desc];
         //} else {
            //ResponseRecords = [SELECT WorkbookStep__c, Id, Name, Responded__c
                               //FROM AH_UDC_Response__c
                               //WHERE WorkbookStep__r.Workbook__c = :workbookId
                               //ORDER BY id desc];
         //}

         List<AH_UDC_ResponseQA__c> ResponseQARecords = [SELECT Id, Response__c, Question__c, QuestionField__c, Answer__c, AnswerField__c
                                                         FROM AH_UDC_ResponseQA__c
                                                         WHERE Response__r.WorkbookStep__r.Workbook__c = :workbookId
                                                         ORDER BY Id asc];

         for (AH_UDC_WorkbookStep__c stepRecord : stepRecords) {
            WorkbookStep wbs = new WorkbookStep();
            wbs.Record = stepRecord;

            wbs.StepResponses = new List<StepResponse> ();
            for (AH_UDC_Response__c ResponseRecord : ResponseRecords) {
               if (ResponseRecord.WorkbookStep__c == stepRecord.Id) {
                  StepResponse r = new StepResponse();
                  r.Record = ResponseRecord;

                  //Get Response QA records
                  r.StepResponseQAs = new List<StepResponseQA> ();
                  for (AH_UDC_ResponseQA__c ResponseQARecord : ResponseQARecords) {
                     if (ResponseQARecord.Response__c == ResponseRecord.Id) {
                        StepResponseQA rQA = new StepResponseQA();
                        rQA.Record = ResponseQARecord;
                        r.StepResponseQAs.add(rQA);
                     }
                  }
                  wbs.StepResponses.add(r);
               }
            }
            displayWorkbook.WorkbookSteps.add(wbs);
         }

         return true;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR, 'AH_UDC_WorkbookResponsesExt.getResponses', 'Unhandled Exception',
                              exc.getMessage(), exc, workbookId, 'AH_UDC_Workbook__c');
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'An error occurred rendering this page; please contact the UDC support team.'));
         return false;
      }
   }

   class Workbook {
      public AH_UDC_Workbook__c Record { get; set; }
      public List<WorkbookStep> WorkbookSteps { get; set; }
   }

   class WorkbookStep {
      public AH_UDC_WorkbookStep__c Record { get; set; }
      public List<StepResponse> StepResponses { get; set; }
   }

   class StepResponse {
      public AH_UDC_Response__c Record { get; set; }
      public List<StepResponseQA> StepResponseQAs { get; set; }
   }

   class StepResponseQA {
      public AH_UDC_ResponseQA__c Record { get; set; }
   }
}