@isTest 
private class AH_UDC_ResponseTriggerHelper_TEST {

   private static AH_UDC_Workbook__c wb = null;
   private static AH_UDC_WorkbookStep__c wbs = null;

	@TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
   }

   private static void testData1()
   {
      //Insert Workbook Sent
      Id wbRTId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();

      String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
      wb = AH_UDC_TestData.GetWorkbookObject(null, 'Test1', 'Test Workbook 1 Description', product);
      wb.RecordTypeId = wbRTId;
      insert wb;

      //Insert Workbook Step Sent with Security Code
      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();

      wbs = AH_UDC_TestData.GetWorkbookStepObject(wb.Id, 'Test1');
      wbs.URL__c = 'https://www.amadeus.com/';
      wbs.RecordTypeId = wbsRTId;
      insert wbs;

   }
   //TODO This test class needs asserts... also coverage is not as expected... need to determine why.

   @istest
   private static void TestMostRecentResponse() {
      testData1();

      Test.startTest();

      Id responseRTId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();

      //Insert Reponse
      AH_UDC_Response__c response1 = AH_UDC_TestData.GetStepResponseObject(wbs.Id);
      response1.RecordTypeId = responseRTId;
      insert response1;

      //Insert Reponse
      AH_UDC_Response__c response2 = AH_UDC_TestData.GetStepResponseObject(wbs.Id);
      response2.RecordTypeId = responseRTId;
      insert response2;

      //Update Reponse
      response2.Responded__c = Datetime.now();
      update response2;

      delete response2;

      Test.stopTest();
   }

   @istest
   private static void TestException() {
      testData1();

      Test.startTest();

      Id responseRTId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();

      try
      {
         //Insert Reponse
         AH_UDC_Response__c response1 = AH_UDC_TestData.GetStepResponseObject(wbs.Id);
         response1.RecordTypeId = responseRTId;
         response1.Responded__c =  date.parse('1/1/2000');
         insert response1;
      }
      catch(exception exc)
      {
      }

      Test.stopTest();
   }

}