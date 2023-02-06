/**
 * Name          : AH_UDC_REST_WorkbookSentInfo_TEST
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-07-25
 * Description   : This is a test class for AH_UDC_REST_WorkbookSentInfo
 * Dependencies  : AH_UDC_REST_WorkbookSentInfo
 **/

@isTest
private class AH_UDC_REST_WorkbookSentInfo_TEST {
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
      //Build UDC Workbook User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                              'WBSI_WBUser1', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);
         //WB User
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[0].Id);
      }
   }

   private static void testData1(boolean withSteps)
   { 
      // Create Account record
      Account oAccount = AH_UDC_TestData.GetAccountObject('GUID');
      insert oAccount;

      // Create Contact record
      Contact oContact = AH_UDC_TestData.GetContactObject(oAccount.Id, 'Test', 'Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert oContact;

      // Create Property Account object with blank property name to get more code coverage
      AH_UDC_PropertyAccount__c oPropertyAccount = AH_UDC_TestData.GetPropertyObject('WBSITest1', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
      insert oPropertyAccount;

      // Create NI Doc record
      NI_Documentation__c oNiDoc = AH_UDC_TestData.GetNIDocObject('WBSITest1', Date.newInstance(2021, 3, 31));
      oNiDoc.AH_UDC_PropertyAccount__c = oPropertyAccount.Id;
      insert oNiDoc;

      // Create Contact NI Doc mapping record
      AH_UDC_Contact__c oUdcContact = AH_UDC_TestData.GetUDCContactObject(oNiDoc.Id, oContact.Id, UserInfo.getDefaultCurrency());
      insert oUdcContact;

      //Insert Workbook Sent
      Id wbRTId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();

      String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
      wb = AH_UDC_TestData.GetWorkbookObject(oNiDoc.Id, 'WBSITest1', 'Test Workbook 1 Description', product);
      wb.RecordTypeId = wbRTId;
      wb.RelatedTo__c = oNiDoc.Id;
      insert wb;

      if (withSteps)
         {
         //Insert Workbook Step Sent with Security Code
         Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
         Id rtFormAssemblyForm = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
         String definitionFA = '{"title":"UDCSB - Unit Test - Picklist - Source","FormAssemblyId":"4853245","CustomUrlId":"58c874ca-f1e4-4504-9878-b4b97af509ec","fields":[{"Name":"Security Code","APIName":"tfa_6","Repeat":"","Picklist":"false"},{"Name":"Token","APIName":"tfa_7","Repeat":"","Picklist":"false"},{"Name":"Parent Security Code","APIName":"tfa_9","Repeat":"","Picklist":"false"},{"Name":"Room Types","APIName":"tfa_1","Repeat":"tfa_1-D[0]","Picklist":"false"},{"Name":"Yes","APIName":"tfa_13","Repeat":""},{"Name":"No","APIName":"tfa_11","Repeat":""},{"Name":"Do you have Rooms","APIName":"tfa_10","Repeat":""}]}';
         m_oForm = AH_UDC_TestData.GetForm(definitionFA, '4853111', 'TestFormFA', '58c874ca-f1e4-4504-9878-b4b97af509ec');
         m_oForm.RecordTypeId = rtFormAssemblyForm;
         insert m_oForm;

         wbs = AH_UDC_TestData.GetWorkbookStepObject(wb.Id, 'WBSITest1');
         wbs.Form__c = m_oForm.Id;
         wbs.RecordTypeId = wbsRTId;
         wbs.Workbook__c = wb.id;
         insert wbs;

         //Insert Response
         Id responseRTId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
         Id responseRTIdAF = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_AMADEUS_FORM).getRecordTypeId();
         response1 = AH_UDC_TestData.GetStepResponseObject();
         response1.RecordTypeId = responseRTId;
         insert response1;

         //Insert Workbook Step Response
         wbsResponse1 = AH_UDC_TestData.GetWorkbookStepResponseObject(wbs.id, response1.id);
         insert wbsResponse1;

         //Insert ReponseQA
         Id responseQARTId = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();
         responseQA1 = AH_UDC_TestData.GetStepResponseQAObject(response1.id, 'Test Question 1', 'tfa_10', 'Test Answer 1', 'tfa_13');
         responseQA1.RecordTypeId = responseQARTId;
         insert responseQA1;
      }
   }

   @isTest
   private static void TestGet() {
      testData1(true);
      User UDCWBUser1 = [SELECT Id FROM user WHERE LastName = 'WBSI_WBUser1'];
      System.runAs(UDCWBUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_WorkbookSentInfo'; //Request URL
         reqG.params.put('workbookSentId', wb.Id);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_WorkbookSentInfo.get();

         AH_UDC_REST_WorkbookSentInfo.WorkbookSentInfoResponse resp = null;
         resp = (AH_UDC_REST_WorkbookSentInfo.WorkbookSentInfoResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_WorkbookSentInfo.WorkbookSentInfoResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');
         System.assertEquals(1, resp.WorkbookSteps.size(), 'Workbook Step count different than expected');
         
         //There will be 1 log message from initializing the Config Settings
         List<AH_UDC_Log__c> logMessages = [select id, Message__c, LogText__c from AH_UDC_Log__c];
         System.assertEquals(1, logMessages.size(), 'More Log Messages exist than were expected');
         System.assert(logMessages[0].LogText__c.contains('Initialize AH_UDC_ConfigurationSettings Completed'), 'Did not have the log message that was expected');
      }
   }

   @isTest
   private static void TestException() {
      testData1(false);
      User UDCWBUser1 = [SELECT Id FROM user WHERE LastName = 'WBSI_WBUser1'];
      System.runAs(UDCWBUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_WorkbookSentInfo'; //Request URL
         reqG.params.put('workbookSentId', 'exception1');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_WorkbookSentInfo.get();

         AH_UDC_REST_WorkbookSentInfo.WorkbookSentInfoResponse resp = null;
         resp = (AH_UDC_REST_WorkbookSentInfo.WorkbookSentInfoResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_WorkbookSentInfo.WorkbookSentInfoResponse.class);

         Test.stopTest();

         System.assertEquals('500', resp.statusCode, 'Expected 200 Response');
      }
   }

   @isTest
   private static void Test400() {
      testData1(false);
      User UDCWBUser1 = [SELECT Id FROM user WHERE LastName = 'WBSI_WBUser1'];
      System.runAs(UDCWBUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_WorkbookSentInfo'; //Request URL
         reqG.params.put('workbookSentId', '');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_WorkbookSentInfo.get();

         AH_UDC_REST_WorkbookSentInfo.WorkbookSentInfoResponse resp = null;
         resp = (AH_UDC_REST_WorkbookSentInfo.WorkbookSentInfoResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_WorkbookSentInfo.WorkbookSentInfoResponse.class);

         Test.stopTest();

         System.assertEquals('400', resp.statusCode, 'Expected 200 Response');
      }
   }

   @isTest
   private static void Test404() {
      testData1(false);
      User UDCWBUser1 = [SELECT Id FROM user WHERE LastName = 'WBSI_WBUser1'];
      System.runAs(UDCWBUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_WorkbookSentInfo'; //Request URL
         reqG.params.put('workbookSentId',  wb.Id);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_WorkbookSentInfo.get();

         AH_UDC_REST_WorkbookSentInfo.WorkbookSentInfoResponse resp = null;
         resp = (AH_UDC_REST_WorkbookSentInfo.WorkbookSentInfoResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_WorkbookSentInfo.WorkbookSentInfoResponse.class);

         Test.stopTest();

         System.assertEquals('404', resp.statusCode, 'Expected 200 Response');
      }
   }
}