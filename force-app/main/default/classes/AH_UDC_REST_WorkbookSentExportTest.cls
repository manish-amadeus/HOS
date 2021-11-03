/**
 * Name          : AH_UDC_REST_WorkbookSentExportTest
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2020-11-23
 * Description   : This is a test class for AH_UDC_REST_WorkbookSentExport
 * Dependencies  : AH_UDC_REST_WorkbookSentExport
 **/

@isTest
private class AH_UDC_REST_WorkbookSentExportTest {

   private static AH_UDC_Workbook__c wb = null;
   private static AH_UDC_WorkbookStep__c wbs = null;
   private static AH_UDC_Response__c response1 = null;
   private static AH_UDC_ResponseQA__c responseQA1 = null;

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
   }

   private static void testData1()
   {
      // Create Account record
      Account oAccount = AH_UDC_TestData.GetAccountObject('UDC Test Account for Test class', 'Hospitality Companies', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave');
      insert oAccount;

      // Create Contact record
      Contact oContact = AH_UDC_TestData.GetContactObject(oAccount.Id, 'Test', 'Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert oContact;

      // Create Contact record
      Contact oContact2 = AH_UDC_TestData.GetContactObject(oAccount.Id, 'Test2', 'Contact2', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert oContact2;

      // Create Property Account object with blank property name to get more code coverage
      AH_UDC_PropertyAccount__c oPropertyAccount = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105', 'St 104', '1 Portsmouth Ave.');
      insert oPropertyAccount;

      // Create NI Doc record
      NI_Documentation__c oNiDoc = AH_UDC_TestData.GetNIDocObject('TestDocName', Date.newInstance(2021, 3, 31));
      oNiDoc.AH_UDC_PropertyAccount__c = oPropertyAccount.Id;
      insert oNiDoc;

      // Create Contact NI Doc mapping record
      AH_UDC_Contact__c oUdcContact = AH_UDC_TestData.GetUDCContactObject(oNiDoc.Id, oContact.Id, UserInfo.getDefaultCurrency());
      insert oUdcContact;
      oUdcContact = AH_UDC_TestData.GetUDCContactObject(oNiDoc.Id, oContact2.Id, UserInfo.getDefaultCurrency());
      insert oUdcContact;

      //Insert Workbook Sent
      Id wbRTId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();

      String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
      wb = AH_UDC_TestData.GetWorkbookObject(oNiDoc.Id, 'Test 1', 'Test Workbook 1 Description', product);
      wb.RecordTypeId = wbRTId;
      insert wb;

      //Insert Workbook Step Sent with Security Code
      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();

      wbs = AH_UDC_TestData.GetWorkbookStepObject(wb.Id, 'Test1');
      wbs.URL__c = 'https://www.lipsum.com/';
      wbs.RecordTypeId = wbsRTId;
      wbs.Workbook__c = wb.id;
      insert wbs;

      //Insert Reponse
      Id responseRTId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();

      response1 = AH_UDC_TestData.GetStepResponseObject(wbs.id);
      response1.RecordTypeId = responseRTId;
      insert response1;

      //Insert ReponseQA
      Id responseQARTId = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();

      responseQA1 = AH_UDC_TestData.GetStepResponseQAObject(response1.id, 'Test Question 1', 'tfa_2', 'Test Answer 1', 'tfa_3');
      responseQA1.RecordTypeId = responseQARTId;
      insert responseQA1;
   }

   @isTest
   private static void TestGet() {
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      reqG.requestURI = '/services/apexrest/AH_UDC_WorkbookSentExport'; //Request URL
      reqG.params.put('wbId', wb.Id);
      reqG.httpMethod = 'GET'; //HTTP Request Type
      RestContext.request = reqG;
      RestContext.response = resG;

      AH_UDC_REST_WorkbookSentExport.get();

      AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse resp = null;
      resp = (AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse.class);

      Test.stopTest();

      System.assertEquals('200', resp.statusCode, 'Expected 200 Response');

      List<AH_UDC_Log__c> logMessages = [select id, Message__c, LogText__c from AH_UDC_Log__c];
      // There will 1 log message from initializing the Config Settings
      System.assertEquals(1, logMessages.size(), 'More Log Messages exist than were expected');
      System.assert(logMessages[0].LogText__c.contains('Initialize AH_UDC_ConfigurationSettings Completed'), 'Did not have the log message that was expected');
   }

   @isTest
   private static void TestGet400Error() {
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      reqG.requestURI = '/services/apexrest/AH_UDC_WorkbookSentExport'; //Request URL
      reqG.params.put('wbBADId', wb.id);
      reqG.httpMethod = 'GET'; //HTTP Request Type
      RestContext.request = reqG;
      RestContext.response = resG;

      AH_UDC_REST_WorkbookSentExport.get();

      AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse resp = null;
      resp = (AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse) JSON.deserialize(RestContext.response.responseBody.toString(),
                                                                                          AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse.class);

      Test.stopTest();

      System.assertEquals('400', resp.statusCode, 'Expected 400 Response');

      List<AH_UDC_Log__c> logMessages = [select id, Message__c, LogText__c from AH_UDC_Log__c];
      // There will 1 log message from initializing the Config Settings
      System.assertEquals(1, logMessages.size(), 'More Log Messages exist than were expected');
      System.assert(logMessages[0].LogText__c.contains('Initialize AH_UDC_ConfigurationSettings Completed'), 'Did not have the log message that was expected');
   }

   @isTest
   private static void TestGet401Error() {
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      reqG.requestURI = '/services/apexrest/AH_UDC_WorkbookSentExport'; //Request URL
      reqG.params.put('wbId', wbs.Id);
      reqG.httpMethod = 'GET'; //HTTP Request Type
      RestContext.request = reqG;
      RestContext.response = resG;

      AH_UDC_REST_WorkbookSentExport.get();

      AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse resp = null;
      resp = (AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse) JSON.deserialize(RestContext.response.responseBody.toString(),
                                                                                          AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse.class);

      Test.stopTest();

      System.assertEquals('401', resp.statusCode, 'Expected 401 Response');

      List<AH_UDC_Log__c> logMessages = [select id, Message__c, LogText__c from AH_UDC_Log__c];
      // There will 1 log message from initializing the Config Settings
      System.assertEquals(1, logMessages.size(), 'More Log Messages exist than were expected');
      System.assert(logMessages[0].LogText__c.contains('Initialize AH_UDC_ConfigurationSettings Completed'), 'Did not have the log message that was expected');
   }

   @isTest
   private static void TestGet500Error() {
      testData1();

      Test.startTest();
      String badId = '123';
      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      reqG.requestURI = '/services/apexrest/AH_UDC_WorkbookSentExport'; //Request URL
      reqG.params.put('wbId', badId);
      reqG.httpMethod = 'GET'; //HTTP Request Type
      RestContext.request = reqG;
      RestContext.response = resG;

      AH_UDC_REST_WorkbookSentExport.get();

      AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse resp = null;
      resp = (AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse) JSON.deserialize(RestContext.response.responseBody.toString(),
                                                                                          AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse.class);

      Test.stopTest();

      System.assertEquals('500', resp.statusCode, 'Expected 500 Response');

      List<AH_UDC_Log__c> logMessages = [SELECT Id, Message__c, LogText__c FROM AH_UDC_Log__c];

      // There will one log message from initializing the Config Settings, and one for Invalid Id
      System.assertEquals(2, logMessages.size(), 'More Log Messages exist than were expected');
      System.assert(logMessages[0].LogText__c.contains('Initialize AH_UDC_ConfigurationSettings Completed'), 'Did not have the log message that was expected for initializing the ConfigSettings');
      System.assert(logMessages[1].LogText__c.contains('Invalid id: ' + badId), 'Did not have the log message that was expected for the badId that was sent');
   }
}