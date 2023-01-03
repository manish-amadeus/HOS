/**WorkbookResponses
 * Name          : AH_UDC_WorkbookResponsesExtTest
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2020-01-20
 * Description   : This is a test class for AH_UDC_WorkbookResponsesExt
 * Dependencies  : AH_UDC_WorkbookResponsesExt
 **/

@isTest
private class AH_UDC_WorkbookResponsesExtTest {

   private static AH_UDC_Workbook__c wb = null;
   private static AH_UDC_WorkbookStep__c wbs = null;
   private static AH_UDC_Response__c response1 = null;
   private static AH_UDC_ResponseQA__c responseQA1 = null;

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
   }

   private static void testData1()
   {
      //Insert Workbook Sent
      Id wbRTId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();

      //TODO: May need a NI DOC to pass in to GetWorkbookObject()

      String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
      wb = AH_UDC_TestData.GetWorkbookObject(null, 'Test1', 'Test Workbook 1 Description', product);
      wb.RecordTypeId = wbRTId;
      insert wb;

      //Insert Workbook Step Sent with Security Code
      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();

      wbs = AH_UDC_TestData.GetWorkbookStepObject(wb.Id, 'Test1');
      wbs.URL__c = 'https://www.lipsum.com/';
      wbs.RecordTypeId = wbsRTId;
      insert wbs;

      //Insert Reponse
      Id responseRTId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();

      response1 = AH_UDC_TestData.GetStepResponseObject(wbs.Id);
      response1.RecordTypeId = responseRTId;
      insert response1;

      //Insert ReponseQA
      Id responseQARTId = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();

      responseQA1 = AH_UDC_TestData.GetStepResponseQAObject(response1.Id, 'Test Question 1', 'tfa_2', 'Test Answer 1', 'tfa_3');
      responseQA1.RecordTypeId = responseQARTId;
      insert responseQA1;
   }

   @isTest
   private static void TestPageLoadException() {
      testData1();

      Test.startTest();
      Test.clearApexPageMessages();

      PageReference pageRef = Page.AH_UDC_WorkbookResponses;
      pageRef.getParameters().put('wbid', 'TestException');
      Test.setCurrentPageReference(pageRef);

      ApexPages.StandardController sController = new ApexPages.standardController(wb);
      AH_UDC_WorkbookResponsesExt wbResponseExt = new AH_UDC_WorkbookResponsesExt(sController);

      System.assert(ApexPages.getMessages().size() == 1, 'Expected an error to have occurred while testing an exception in constructor');

      Test.stopTest();
   }

   @isTest
   private static void TestPageLoadWithMissingWbId() {
      testData1();

      Test.startTest();
      Test.clearApexPageMessages();

      PageReference pageRef = Page.AH_UDC_WorkbookResponses;
      Test.setCurrentPageReference(pageRef);

      ApexPages.StandardController sController = new ApexPages.standardController(wb);
      AH_UDC_WorkbookResponsesExt wbResponseExt = new AH_UDC_WorkbookResponsesExt(sController);

      System.assert(ApexPages.getMessages().size() == 1, 'Did not find the expected number of errors (1)');
      System.assert(ApexPages.getMessages()[0].getDetail().contains('No Workbook was specified.'), 'Did not find the expected error message: ' + ApexPages.getMessages());

      Test.stopTest();
   }

   @isTest
   private static void TestPageLoadWithNonExistentWbId() {
      testData1();

      Test.startTest();
      Test.clearApexPageMessages();

      PageReference pageRef = Page.AH_UDC_WorkbookResponses;
      pageRef.getParameters().put('wbid', '000000000000000000');
      Test.setCurrentPageReference(pageRef);

      ApexPages.StandardController sController = new ApexPages.standardController(wb);
      AH_UDC_WorkbookResponsesExt wbResponseExt = new AH_UDC_WorkbookResponsesExt(sController);

      System.assert(ApexPages.getMessages().size() == 1, 'Expected an error to have occurred while testing an exception in constructor');

      Test.stopTest();
   }



   @isTest
   private static void TestPageLoad() {
      testData1();

      Test.startTest();
      Test.clearApexPageMessages();

      PageReference pageRef = Page.AH_UDC_WorkbookResponses;
      pageRef.getParameters().put('wbid', wb.Id);
      Test.setCurrentPageReference(pageRef);

      ApexPages.StandardController sController = new ApexPages.standardController(wb);
      AH_UDC_WorkbookResponsesExt wbResponseExt = new AH_UDC_WorkbookResponsesExt(sController);

      if (ApexPages.getMessages().size() > 0) {
         String s = '';
         for (ApexPages.Message msg : ApexPages.getMessages()) {
            s += msg.getSeverity() + ' | ' + msg.getDetail() + ' | ' + msg.getSummary();
         }
         System.assert(false, s);
      }

      Test.stopTest();
   }

   @isTest
   private static void TestCSV() {
      testData1();

      Test.startTest();
      Test.clearApexPageMessages();

      PageReference pageRef = Page.AH_UDC_WorkbookResponses;
      pageRef.getParameters().put('wbid', wb.Id);
      pageRef.getParameters().put('mode', 'CSV');
      Test.setCurrentPageReference(pageRef);

      ApexPages.StandardController sController = new ApexPages.standardController(wb);
      AH_UDC_WorkbookResponsesExt wbResponseExt = new AH_UDC_WorkbookResponsesExt(sController);

      if (ApexPages.getMessages().size() > 0) {
         String s = '';
         for (ApexPages.Message msg : ApexPages.getMessages()) {
            s += msg.getSeverity() + ' | ' + msg.getDetail() + ' | ' + msg.getSummary();
         }
         System.assert(false, s);
      }

      System.assert(wbResponseExt.mode == 'CSV', 'Mode was expected to be "CSV"');

      Test.stopTest();
   }

   @isTest
   private static void TestMiscellaneous() {
      Test.startTest();
      Test.clearApexPageMessages();

      System.assert(AH_UDC_WorkbookResponsesExt.getNewLine() == '\n', 'Did not get the expected NEWLINE character');
      System.assert(AH_UDC_WorkbookResponsesExt.getNewCell() == ',', 'Did not get the expected NEWCELL character');

      Test.stopTest();
   }
}