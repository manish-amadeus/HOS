/**
 * Name          : AH_UDC_REST_WorkbookSentExport_TEST
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2020-11-23
 * Description   : This is a test class for AH_UDC_REST_WorkbookSentExport
 * Dependencies  : AH_UDC_REST_WorkbookSentExport
 * Modified      : 2022-04-24, Vaishali Patel, Added new tests, fixed old tests and added user to run as specific user for tests
 **/

@isTest
private class AH_UDC_REST_WorkbookSentExport_TEST {
   private static AH_UDC_Workbook__c wb = null;
   private static AH_UDC_WorkbookStep__c wbs = null;
   private static AH_UDC_WorkbookStep__c wbswithNoResponse = null;
   private static AH_UDC_WorkbookStep__c wbswithAF = null;
   private static AH_UDC_Form__c m_oForm = null;
   private static AH_UDC_Form__c m_oFormAF = null;
   private static AH_UDC_WorkbookStepResponse__c wbsResponse1 = null;
   private static AH_UDC_WorkbookStepResponse__c wbsResponseAF = null;
   private static AH_UDC_Response__c response1 = null;
   private static AH_UDC_Response__c responseAF = null;
   private static AH_UDC_ResponseQA__c responseQA1 = null;

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      List<User> listUsers = new List<User> ();
      //Build UDC Service User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE,
                                              'WBSE_ServiceUser1', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         //AH_UDC_TestData.InsertWithRetries(listUsers);
         insert listUsers;

         // Service User
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE, listUsers[0].Id);
      }
   }

   private static void testData1()
   { 
      // Create Account record
      Account oAccount = AH_UDC_TestData.GetAccountObject('GUID');
      insert oAccount;

      // Create Contact record
      Contact oContact = AH_UDC_TestData.GetContactObject(oAccount.Id, 'Test', 'Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert oContact;

      // Create Contact record
      Contact oContact2 = AH_UDC_TestData.GetContactObject(oAccount.Id, 'Test2', 'Contact2', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert oContact2;

      // Create Property Account object with blank property name to get more code coverage
      AH_UDC_PropertyAccount__c oPropertyAccount = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
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
      wb.RelatedTo__c = oNiDoc.Id;
      insert wb;

      //Insert Workbook Step Sent with Security Code
      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      Id rtFormAssemblyForm = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
      String definitionFA = '{"title":"UDCSB - Unit Test - Picklist - Source","FormAssemblyId":"4853245","CustomUrlId":"58c874ca-f1e4-4504-9878-b4b97af509ec","fields":[{"Name":"Security Code","APIName":"tfa_6","Repeat":"","Picklist":"false"},{"Name":"Token","APIName":"tfa_7","Repeat":"","Picklist":"false"},{"Name":"Parent Security Code","APIName":"tfa_9","Repeat":"","Picklist":"false"},{"Name":"Room Types","APIName":"tfa_1","Repeat":"tfa_1-D[0]","Picklist":"false"},{"Name":"Yes","APIName":"tfa_13","Repeat":""},{"Name":"No","APIName":"tfa_11","Repeat":""},{"Name":"Do you have Rooms","APIName":"tfa_10","Repeat":""}]}';
      m_oForm = AH_UDC_TestData.GetForm(definitionFA, '4853111', 'TestFormFA', '58c874ca-f1e4-4504-9878-b4b97af509ec');
      m_oForm.RecordTypeId = rtFormAssemblyForm;
      insert m_oForm;

      wbs = AH_UDC_TestData.GetWorkbookStepObject(wb.Id, 'Test1');
      wbs.Form__c = m_oForm.Id;
      wbs.RecordTypeId = wbsRTId;
      wbs.Workbook__c = wb.id;
      insert wbs;

      wbswithNoResponse = AH_UDC_TestData.GetWorkbookStepObject(wb.Id, 'TestWithNoResponse');
      wbswithNoResponse.URL__c = 'https://www.lipsum.com/';
     // wbswithNoResponse.RecordTypeId = wbsRTId;
    //  wbswithNoResponse.Workbook__c = wb.id;
      insert wbswithNoResponse;

      Id AmadeusFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM).getRecordTypeId();
      m_oFormAF = AH_UDC_TestData.GetForm('', '', 'TestFormAF', '');
      m_oFormAF.RecordTypeId = AmadeusFormRecordTypeId;
      insert m_oFormAF;

      wbsWithAF = AH_UDC_TestData.GetWorkbookStepObject(wb.Id, 'TestWithAFResponse');
      //wbsWithAF.RecordTypeId = wbsRTId;
      wbsWithAF.Form__c = m_oFormAF.Id;
      //wbsWithAF.Workbook__c = wb.id;
      insert wbsWithAF;


      //Insert Response
      Id responseRTId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
      Id responseRTIdAF = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_AMADEUS_FORM).getRecordTypeId();
      response1 = AH_UDC_TestData.GetStepResponseObject();
      response1.RecordTypeId = responseRTId;
      insert response1;

      responseAF = AH_UDC_TestData.GetStepResponseObject();
      responseAF.RecordTypeId = responseRTIdAF;
      insert responseAF;

      //Insert Workbook Step Response
      wbsResponse1 = AH_UDC_TestData.GetWorkbookStepResponseObject(wbs.id, response1.id);
      insert wbsResponse1;

      wbsResponseAF = AH_UDC_TestData.GetWorkbookStepResponseObject(wbsWithAF.id, responseAf.id);
      insert wbsResponseAF;

      //Insert ReponseQA
      Id responseQARTId = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();

      responseQA1 = AH_UDC_TestData.GetStepResponseQAObject(response1.id, 'Test Question 1', 'tfa_10', 'Test Answer 1', 'tfa_13');
      responseQA1.RecordTypeId = responseQARTId;
      insert responseQA1;

      Id responseQARTIdAF = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_AMADEUS_FORM).getRecordTypeId();
      String strJson1 = '{"SortOrder":"1","QuestionField":"AHUDC_1_0_0","Question":"Floor #","AnswerField":"","Answer":"111"},{"SortOrder":"2","QuestionField":"AHUDC_1_1_0","Question":"Description","AnswerField":"","Answer":"Test v"},{"SortOrder":"3","QuestionField":"AHUDC_1_2_0","Question":"Total Rooms","AnswerField":"AH_UDC_3","Answer":"3"},{"SortOrder":"4","QuestionField":"AHUDC_1_3_0","Question":"Square Feet","AnswerField":"","Answer":"10000"},{"SortOrder":"5","QuestionField":"AHUDC_1_4_0","Question":"Banquet?","AnswerField":"AH_UDC_No","Answer":"No"},{"SortOrder":"6","QuestionField":"AHUDC_1_5_0_0","Question":"Room # 0","AnswerField":"","Answer":"1"},{"SortOrder":"7","QuestionField":"AHUDC_1_6_0_0","Question":"Room Code 0","AnswerField":"","Answer":"qqq"},{"SortOrder":"8","QuestionField":"AHUDC_1_5_0_1","Question":"Room # 1","AnswerField":"","Answer":"2"},{"SortOrder":"9","QuestionField":"AHUDC_1_6_0_1","Question":"Room Code 1","AnswerField":"","Answer":"qqq"},{"SortOrder":"10","QuestionField":"AHUDC_1_5_0_2","Question":"Room # 2","AnswerField":"","Answer":"3"},{"SortOrder":"11","QuestionField":"AHUDC_1_6_0_2","Question":"Room Code 2","AnswerField":"","Answer":"qqq"},{"SortOrder":"12","QuestionField":"AHUDC_1_5_0_3","Question":"Room # 3","AnswerField":"","Answer":"4"},{"SortOrder":"13","QuestionField":"AHUDC_1_6_0_3","Question":"Room Code 3","AnswerField":"","Answer":"qqq"},{"SortOrder":"14","QuestionField":"AHUDC_1_5_0_4","Question":"Room # 4","AnswerField":"","Answer":"5"},{"SortOrder":"15","QuestionField":"AHUDC_1_6_0_4","Question":"Room Code 4","AnswerField":"","Answer":"qqq"}';
      String strJson2 = '{"SortOrder":"16","QuestionField":"AHUDC_1_5_0_5","Question":"Room # 5","AnswerField":"","Answer":"6"},{"SortOrder":"17","QuestionField":"AHUDC_1_6_0_5","Question":"Room Code 5","AnswerField":"","Answer":"qqq"},{"SortOrder":"18","QuestionField":"AHUDC_1_5_0_6","Question":"Room # 6","AnswerField":"","Answer":"7"},{"SortOrder":"19","QuestionField":"AHUDC_1_6_0_6","Question":"Room Code 6","AnswerField":"","Answer":"qqq"},{"SortOrder":"20","QuestionField":"AHUDC_1_5_0_7","Question":"Room # 7","AnswerField":"","Answer":"8"},{"SortOrder":"21","QuestionField":"AHUDC_1_6_0_7","Question":"Room Code 7","AnswerField":"","Answer":"qqq"},{"SortOrder":"22","QuestionField":"AHUDC_1_5_0_8","Question":"Room # 8","AnswerField":"","Answer":"9"},{"SortOrder":"23","QuestionField":"AHUDC_1_6_0_8","Question":"Room Code 8","AnswerField":"","Answer":"qqq"},{"SortOrder":"24","QuestionField":"AHUDC_1_5_0_9","Question":"Room # 9","AnswerField":"","Answer":"10"},{"SortOrder":"25","QuestionField":"AHUDC_1_6_0_9","Question":"Room Code 9","AnswerField":"","Answer":"qqq"},{"SortOrder":"26","QuestionField":"AHUDC_1_5_0_10","Question":"Room # 10","AnswerField":"","Answer":"11"},{"SortOrder":"27","QuestionField":"AHUDC_1_6_0_10","Question":"Room Code 10","AnswerField":"","Answer":"rrr"},{"SortOrder":"28","QuestionField":"AHUDC_1_5_0_11","Question":"Room # 11","AnswerField":"","Answer":"12"},{"SortOrder":"29","QuestionField":"AHUDC_1_6_0_11","Question":"Room Code 11","AnswerField":"","Answer":"aaa"},{"SortOrder":"30","QuestionField":"AHUDC_1_5_0_12","Question":"Room # 12","AnswerField":"","Answer":"13"}';
      String strJson3 = '{"SortOrder":"31","QuestionField":"AHUDC_1_6_0_12","Question":"Room Code 12","AnswerField":"","Answer":"aaa"},{"SortOrder":"32","QuestionField":"AHUDC_1_5_0_13","Question":"Room # 13","AnswerField":"","Answer":"14"},{"SortOrder":"33","QuestionField":"AHUDC_1_6_0_13","Question":"Room Code 13","AnswerField":"","Answer":"aaa"},{"SortOrder":"34","QuestionField":"AHUDC_1_5_0_14","Question":"Room # 14","AnswerField":"","Answer":"15"},{"SortOrder":"35","QuestionField":"AHUDC_1_6_0_14","Question":"Room Code 14","AnswerField":"","Answer":"zzz"},{"SortOrder":"36","QuestionField":"AHUDC_1_5_0_15","Question":"Room # 15","AnswerField":"","Answer":"16"},{"SortOrder":"37","QuestionField":"AHUDC_1_6_0_15","Question":"Room Code 15","AnswerField":"","Answer":"ooo"},{"SortOrder":"38","QuestionField":"AHUDC_1_5_0_16","Question":"Room # 16","AnswerField":"","Answer":"17"},{"SortOrder":"39","QuestionField":"AHUDC_1_6_0_16","Question":"Room Code 16","AnswerField":"","Answer":"ooo"},{"SortOrder":"40","QuestionField":"AHUDC_1_5_0_17","Question":"Room # 17","AnswerField":"","Answer":"18"},{"SortOrder":"41","QuestionField":"AHUDC_1_6_0_17","Question":"Room Code 17","AnswerField":"","Answer":"ooo"},{"SortOrder":"42","QuestionField":"AHUDC_1_5_0_18","Question":"Room # 18","AnswerField":"","Answer":"19"},{"SortOrder":"43","QuestionField":"AHUDC_1_6_0_18","Question":"Room Code 18","AnswerField":"","Answer":"ooo"},{"SortOrder":"44","QuestionField":"AHUDC_1_5_0_19","Question":"Room # 19","AnswerField":"","Answer":"20"},{"SortOrder":"45","QuestionField":"AHUDC_1_6_0_19","Question":"Room Code 19","AnswerField":"","Answer":"ooo"}';
      AH_UDC_ResponseQA__c rqAF1 = AH_UDC_TestData.GetStepResponseQAObject(responseAF.id, strJson1, 1);
      rqAF1.RecordTypeId = responseQARTIdAF;
      insert rqAF1;
      AH_UDC_ResponseQA__c rqAF2 = AH_UDC_TestData.GetStepResponseQAObject(responseAF.id, strJson2, 2);
      rqAF2.RecordTypeId = responseQARTIdAF;
      insert rqAF2;
      AH_UDC_ResponseQA__c rqAF3 = AH_UDC_TestData.GetStepResponseQAObject(responseAF.id, strJson3, 3);
      rqAF3.RecordTypeId = responseQARTIdAF;
      insert rqAF3;
   }
   private static void testData2()
   {
      testData1();
      Id AmadeusFileUploadRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
      m_oForm.RecordTypeId = AmadeusFileUploadRecordTypeId;
      m_oForm.FormAssemblyId__c = '';
      update m_oForm;
   }
   @isTest
   private static void TestGet() {
      testData1();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'WBSE_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_WorkbookSentExport'; //Request URL
         reqG.params.put('workbookSentStepId', wbs.Id);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_WorkbookSentExport.get();

         AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse resp = null;
         resp = (AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');
         System.assertEquals(1, resp.QuestionAnswers.size(), 'Expected Response size to be matched');
         List<AH_UDC_Log__c> logMessages = [select id, Message__c, LogText__c from AH_UDC_Log__c];
         // There will be 1 log message from initializing the Config Settings
         System.assertEquals(1, logMessages.size(), 'More Log Messages exist than were expected');
         System.assert(logMessages[0].LogText__c.contains('Initialize AH_UDC_ConfigurationSettings Completed'), 'Did not have the log message that was expected');
      }
   }

   @isTest
   private static void TestGetWithAmadeusForm() {
      testData1();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'WBSE_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_WorkbookSentExport'; //Request URL
         reqG.params.put('workbookSentStepId', wbswithAF.Id);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_WorkbookSentExport.get();

         AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse resp = null;
         resp = (AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');
         System.assertEquals(3, resp.QuestionAnswers.size(), 'Expected Response size to be matched');
         List<AH_UDC_Log__c> logMessages = [select id, Message__c, LogText__c from AH_UDC_Log__c];
         // There will be 1 log message from initializing the Config Settings
         System.assertEquals(1, logMessages.size(), 'More Log Messages exist than were expected');
         System.assert(logMessages[0].LogText__c.contains('Initialize AH_UDC_ConfigurationSettings Completed'), 'Did not have the log message that was expected');
      }
   }

   @isTest
   private static void TestGetWithNoResponse() {
      testData1();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'WBSE_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_WorkbookSentExport'; //Request URL
         reqG.params.put('workbookSentStepId', wbswithNoResponse.Id);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_WorkbookSentExport.get();

         AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse resp = null;
         resp = (AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');

         List<AH_UDC_Log__c> logMessages = [select id, Message__c, LogText__c from AH_UDC_Log__c];
         // There will be 1 log message from initializing the Config Settings
         System.assertEquals(1, logMessages.size(), 'More Log Messages exist than were expected');
         System.assert(logMessages[0].LogText__c.contains('Initialize AH_UDC_ConfigurationSettings Completed'), 'Did not have the log message that was expected');
      }
   }
   @isTest
   private static void TestGet400Error() {
      testData1();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'WBSE_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
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
   }

   @isTest
   private static void TestGet404Error() {
      testData1();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'WBSE_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();
         String badId = '123';
         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_WorkbookSentExport'; //Request URL
         reqG.params.put('workbookSentStepId', badId); //Added wrong Id to test 404 error
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_WorkbookSentExport.get();

         AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse resp = null;
         resp = (AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse) JSON.deserialize(RestContext.response.responseBody.toString(),
                                                                                             AH_UDC_REST_WorkbookSentExport.WorkbookSentExportResponse.class);

         Test.stopTest();

         System.assertEquals('404', resp.statusCode, 'Expected 404 Response');

         List<AH_UDC_Log__c> logMessages = [select id, Message__c, LogText__c from AH_UDC_Log__c];
         // There will 1 log message from initializing the Config Settings
         System.assertEquals(1, logMessages.size(), 'More Log Messages exist than were expected');
         System.assert(logMessages[0].LogText__c.contains('Initialize AH_UDC_ConfigurationSettings Completed'), 'Did not have the log message that was expected');
      }
   }

   @isTest
   private static void TestGet500Error() {
      testData1();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'WBSE_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();
         String badId = 'TestException';
         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_WorkbookSentExport'; //Request URL
         reqG.params.put('workbookSentStepId', badId);
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
         System.assert(logMessages[1].LogText__c.contains('Divide by 0'), 'Did not have the log message that was expected for the badId that was sent');
      }
   }

   @isTest
   private static void TestGet500ErrorWithWrongRecordtype() {
      testData2();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'WBSE_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();
         String badId = '123';
         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_WorkbookSentExport'; //Request URL
         reqG.params.put('workbookSentStepId', wbs.Id);
         reqG.params.put('reqestId', badId);
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
         System.assert(logMessages[1].LogText__c.contains('Invalid'), 'Did not have the log message that was expected for the badId that was sent');
      }
   }
}