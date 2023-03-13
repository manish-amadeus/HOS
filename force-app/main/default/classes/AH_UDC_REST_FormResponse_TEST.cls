/**
 * Name          : AH_UDC_REST_FormResponse_TEST
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2020-11-23
 * Description   : This is a test class for AH_UDC_REST_FormResponse
 * Dependencies  : AH_UDC_REST_FormResponse
 **/

@isTest
private class AH_UDC_REST_FormResponse_TEST {
   private static AH_UDC_PropertyAccount__c oPA = null;
   private static NI_Documentation__c oNIDoc = null;
   private static NI_Documentation__c oNIDoc2 = null;
   private static AH_UDC_Workbook__c m_oWB = null;
   private static AH_UDC_Workbook__c m_oWB2 = null;
   private static AH_UDC_Workbook__c m_oWB3 = null;
   private static AH_UDC_WorkbookStep__c m_oWBS = null;
   private static AH_UDC_WorkbookStep__c m_oWBS2 = null;
   private static AH_UDC_WorkbookStep__c m_oWBS3 = null;
   private static AH_UDC_WorkbookStep__c m_oWBS4 = null;
   private static AH_UDC_Form__c m_oForm = null;
   private static AH_UDC_Form__c m_oForm2 = null;
   private static AH_UDC_Form__c m_oForm3= null;
   private static AH_UDC_Form__c m_oForm4 = null;
   private static User m_oUser = null;

   private static final string SERVICE_USER = 'FR_ServiceUser1';
   private static final string COMMUNITY_USER_NO_CHATTER = 'FR_CommunityUser1';

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('All');
      String uniqueId = AH_UDC_Shared.generateGUID();
      Account newAccount = AH_UDC_TestData.GetAccountObject(uniqueId);
      insert newAccount;

      Contact newContact = AH_UDC_TestData.GetContactObject(newAccount.id, uniqueId);
      insert newContact;

      List<User> listUsers = new List<User> ();
      //Build UDC Service User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE,
                                              SERVICE_USER, null, false));
      //Build Community User with chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                              COMMUNITY_USER_NO_CHATTER, newContact.Id, true));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         //AH_UDC_TestData.InsertWithRetries(listUsers);
         insert listUsers;

         // Community Users
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[1].Id);
      }
   }

   private static void testData1()
   {
      try {
         oPA = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
         insert oPA;

         oNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
         oNIDoc.AH_UDC_PropertyAccount__c = oPA.Id;
         insert oNIDoc;

         String definition = AH_UDC_TestData.GetFormDefinition();
         m_oForm = AH_UDC_TestData.GetForm(definition, '123', 'TestForm1', '58c874ca-f1e4-4504-9878-b4b97af509ec');
         insert m_oForm;

         // Find the "Workbook Sent" record type Id
         Id rtWbSentId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();

         // Create Workbook Sent
         String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
         m_oWB = AH_UDC_TestData.GetWorkbookObject(oNIDoc.Id, 'TestWorkbook001', 'TestWorkbookDescription', product);
         m_oWB.RecordtypeId = rtWbSentId;
         insert m_oWB;

         // Find the Workbook Step Sent Record Type
         Id rtWbsSentId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();

         // Create Workbook Sent Step
         m_oWBS = AH_UDC_TestData.GetWorkbookStepObject(m_oWB.Id, 'TEST001');
         m_oWBS.RecordTypeId = rtWbsSentId;
         m_oWBS.Workbook__c = m_oWB.Id;
         m_oWBS.Form__c = m_oForm.Id;
         insert m_oWBS;

         // Query the Community User
         m_oUser = [SELECT Id FROM User WHERE Username = :('Test' + COMMUNITY_USER_NO_CHATTER + '@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      }
      catch(Exception exc) {
         System.debug(LoggingLevel.ERROR, 'Failed to correctly setup test data');
         throw exc;
      }
   }

   private static void testData2() //This is a setup for Shared Data
   {
      try {
         testData1();

         oNIDoc2 = AH_UDC_TestData.GetNIDocObject('Test NI Document 2', Date.newInstance(2021, 3, 31));
         oNIDoc2.AH_UDC_PropertyAccount__c = oPA.Id;
         insert oNIDoc2;

         m_oForm.FormType__c = AH_UDC_Constants.FORM_TYPE_SHARED;
         update m_oForm;

         // Find the "Workbook Sent" record type Id
         Id rtWbSentId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();

         // Create Another Workbook Sent
         String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
         m_oWB2 = AH_UDC_TestData.GetWorkbookObject(oNIDoc2.Id, 'TestWorkbook002', 'TestWorkbookDescription', product);
         m_oWB2.RecordtypeId = rtWbSentId;
         insert m_oWB2;

         // Find the Workbook Step Sent Record Type
         Id rtWbsSentId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();

         // Create Workbook Sent Step
         m_oWBS2 = AH_UDC_TestData.GetWorkbookStepObject(m_oWB2.Id, 'TEST002');
         m_oWBS2.RecordTypeId = rtWbsSentId;
         m_oWBS2.Workbook__c = m_oWB2.Id;
         m_oWBS2.Form__c = m_oForm.Id;
         insert m_oWBS2;
      }
      catch(Exception exc) {
         System.debug(LoggingLevel.ERROR, 'Failed to correctly setup test data');
         throw exc;
      }
   }

   private static void testData_DefaultAndPicklistField()
   {
      try {
         oPA = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
         insert oPA;

         oNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document-picklist', Date.newInstance(2021, 3, 31));
         oNIDoc.AH_UDC_PropertyAccount__c = oPA.Id;
         insert oNIDoc;

         String definitionStep1 = AH_UDC_TestData.getFormDefinition_DefaultAndPicklistStep1();
         m_oForm3 = AH_UDC_TestData.GetForm(definitionStep1, '4853374', 'UDCSB - Unit Test - Default and Picklist- Step1', '4853374');
         insert m_oForm3;

         String definitionStep2 = AH_UDC_TestData.getFormDefinition_DefaultAndPicklistStep2();
         m_oForm4 = AH_UDC_TestData.GetForm(definitionStep2, '4853375', 'UDCSB - Unit Test - Default and Picklist - Step2', '4853375');
         insert m_oForm4;

         // Find the "Workbook Sent" record type Id
         Id rtWbSentId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();

         // Create Workbook Sent
         String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
         m_oWB = AH_UDC_TestData.GetWorkbookObject(oNIDoc.Id, 'TestWorkbook001', 'TestWorkbookDescription', product);
         m_oWB.RecordtypeId = rtWbSentId;
         insert m_oWB;

         // Find the Workbook Step Sent Record Type
         Id rtWbsSentId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();

         // Create Workbook Sent Step
         m_oWBS3 = AH_UDC_TestData.GetWorkbookStepObject(m_oWB.Id, 'Step3');
         m_oWBS3.RecordTypeId = rtWbsSentId;
         m_oWBS3.Workbook__c = m_oWB.Id;
         m_oWBS3.Form__c = m_oForm3.Id;
         insert m_oWBS3;

         // Create Workbook Sent Step
         m_oWBS4 = AH_UDC_TestData.GetWorkbookStepObject(m_oWB.Id, 'Step4');
         m_oWBS4.RecordTypeId = rtWbsSentId;
         m_oWBS4.Workbook__c = m_oWB.Id;
         m_oWBS4.Form__c = m_oForm4.Id;
         insert m_oWBS4;

         //Create Response record for Step1
         AH_UDC_Response__c response = new AH_UDC_Response__c(
                                                              Responded__c = Datetime.now()
         );
         insert response;

         //Create  Response record for Step1
         AH_UDC_WorkbookStepResponse__c wbsResponse = new AH_UDC_WorkbookStepResponse__c(
                                                                                         Response__c = response.Id,
                                                                                         WorkbookStep__c = m_oWBS3.id,
                                                                                         IsMostRecentResponse__c = true
         );
         insert wbsResponse;

         //Create ResponsQA records for Step1
         AH_UDC_ResponseQA__c responseQA  = null;
         List<AH_UDC_ResponseQA__c> lstResponseQA = new List<AH_UDC_ResponseQA__c>();
         responseQA = new AH_UDC_ResponseQA__c(QuestionField__c = 'tfa_8', Question__c = 'Test Default', Answer__c = 'test1', Response__c = response.id);
         lstResponseQA.add(responseQA);
         responseQA = new AH_UDC_ResponseQA__c(QuestionField__c = 'tfa_31[0]', Question__c = 'Picklist Test[0]', Answer__c = 'Test Alpha', Response__c = response.id);
         lstResponseQA.add(responseQA);
         responseQA = new AH_UDC_ResponseQA__c(QuestionField__c = 'tfa_31[1]', Question__c = 'Picklist Test[1]', Answer__c = 'Test Beta', Response__c = response.id);
         lstResponseQA.add(responseQA);
         responseQA = new AH_UDC_ResponseQA__c(QuestionField__c = 'tfa_33', Question__c = 'Default Test', Answer__c = 'Test Default', Response__c = response.id);
         lstResponseQA.add(responseQA);
         insert lstResponseQA;

         // Query the Community User
         m_oUser = [SELECT Id FROM User WHERE Username = :('Test' + COMMUNITY_USER_NO_CHATTER + '@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      }
      catch(Exception exc) {
         System.debug(LoggingLevel.ERROR, 'Failed to correctly setup test data');
         throw exc;
      }
   }
   @isTest
   private static void TestGet_DefaultAndPicklistField() {
      testData_DefaultAndPicklistField();

      string token = AH_UDC_Shared.CreateStepToken(m_oWB.SecurityCode__c, m_oForm4.id, m_oWBS4.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE Username = :('Test' + SERVICE_USER + '@amadeus.com')];
      System.runAs(UDCServiceUser1)
      {         
         RestRequest reqPost = new RestRequest();
         RestResponse resPost = new RestResponse();
         reqPost.requestURI = '/services/apexrest/AH_UDC_FormResponse'; //Request URL
         reqPost.httpMethod = 'POST'; //HTTP Request Type
         reqPost.requestBody = Blob.valueof('{"QuestionAnswers":[' +
                                            '{"QuestionField":"' + AH_UDC_TestData.GetFormDefinitionTokenTFAFieldAPIName + '","Question":"Token","AnswerField":"","Answer":"' + token + '"}]}"'); RestContext.request = reqPost;                                            
         RestContext.response = resPost;

         AH_UDC_REST_FormResponse.post();

         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_FormResponse'; //Request URL
         //reqG.params.put('SecurityCode', m_securityCode);
         //reqG.params.put('FormId', m_oForm.Id);
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_FormResponse.get();

         AH_UDC_REST_FormResponse.FormResponseResponse resp = null;
         resp = (AH_UDC_REST_FormResponse.FormResponseResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormResponse.FormResponseResponse.class);

         Test.stopTest();

         List<AH_UDC_Log__c> logMessages = [select Id, LogText__c from AH_UDC_Log__c];
         System.assertEquals('200', resp.statusCode, 'Expected 200 Response: ' + resp.message);
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }

   @isTest
   private static void TestPostSharedResponse() {
      testData2(); //This sets up 2 Workbooks with steps for a shared form

      string token = AH_UDC_Shared.CreateStepToken(m_oWB2.SecurityCode__c, m_oForm.id, m_oWBS2.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE Username = :('Test' + SERVICE_USER + '@amadeus.com')];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_FormResponse'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof('{"QuestionAnswers":[' +
                                        '{"QuestionField":"' + AH_UDC_TestData.GetFormDefinitionTokenTFAFieldAPIName + '","Question":"Token","AnswerField":"","Answer":"' + token + '"},' +
                                        '{"QuestionField":"tfa_1","Question":"","AnswerField":"tfa_2","Answer":""}]}"');
         RestContext.request = req;
         RestContext.response = res;

         AH_UDC_REST_FormResponse.post();

         AH_UDC_REST_FormResponse.FormResponseResponse resp =
         (AH_UDC_REST_FormResponse.FormResponseResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormResponse.FormResponseResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');

         List<AH_UDC_Response__c> responses = [select id, Name from AH_UDC_Response__c];
         System.Debug('$$$responses.size(): ' + responses.size());
         System.Debug('$$$responses: ' + responses);

         List<AH_UDC_Log__c> logMessages = [select id from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPost() {
      testData1();

      string token = AH_UDC_Shared.CreateStepToken(m_oWB.SecurityCode__c, m_oForm.id, m_oWBS.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE Username = :('Test' + SERVICE_USER + '@amadeus.com')];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_FormResponse'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof('{"QuestionAnswers":[' +
                                        '{"QuestionField":"' + AH_UDC_TestData.GetFormDefinitionTokenTFAFieldAPIName + '","Question":"Token","AnswerField":"","Answer":"' + token + '"},' +
                                        '{"QuestionField":"tfa_1","Question":"","AnswerField":"tfa_2","Answer":""},' +
                                        '{"QuestionField":"tfa_18[0][0]","Question":"Question[0][0]","AnswerField":"tfa_2","Answer":""},' +
                                        '{"QuestionField":"tfa_18[0][1]","Question":"Question[0][1]","AnswerField":"tfa_2","Answer":""},' +
                                        '{"QuestionField":"tfa_18[2][0]","Question":"Question[0][0]","AnswerField":"tfa_2","Answer":""},' +
                                        '{"QuestionField":"tfa_18[2][1]","Question":"Question[0][1]","AnswerField":"tfa_2","Answer":""}' +
                                        ']}"');
         RestContext.request = req;
         RestContext.response = res;

         AH_UDC_REST_FormResponse.post();

         AH_UDC_REST_FormResponse.FormResponseResponse resp =
         (AH_UDC_REST_FormResponse.FormResponseResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormResponse.FormResponseResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');

         List<AH_UDC_Log__c> logMessages = [select id from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPostFailedWriteLogQ() {
      testData1();

      string token = AH_UDC_Shared.CreateStepToken(m_oWB.SecurityCode__c, m_oForm.id, m_oWBS.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE Username = :('Test' + SERVICE_USER + '@amadeus.com')];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_FormResponse'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof('writeQueuedLogsException');
         RestContext.request = req;
         RestContext.response = res;

         AH_UDC_REST_FormResponse.post();

         AH_UDC_REST_FormResponse.FormResponseResponse resp =
         (AH_UDC_REST_FormResponse.FormResponseResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormResponse.FormResponseResponse.class);

         Test.stopTest();

         System.assertEquals('500', resp.statusCode, 'Expected 500 Response');

         List<AH_UDC_Log__c> logMessages = [select id from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPost201QAa() {
      testData1();

      string token = AH_UDC_Shared.CreateStepToken(m_oWB.SecurityCode__c, m_oForm.id, m_oWBS.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE Username = :('Test' + SERVICE_USER + '@amadeus.com')];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_FormResponse'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type

         string QAs = '';
         for (integer tfa = 1; tfa< 201; tfa++)
         {
            if (QAs != '') QAs += ',';
            QAs += '{"QuestionField":"tfa_' + String.valueOf(tfa) + '","Question":"My Test Question","AnswerField":"tfa_AF' + String.valueOf(tfa) + '","Answer":"My Test Answer"}';
         }

         req.requestBody = Blob.valueof('{"QuestionAnswers":[' +
                                        '{"QuestionField":"' + AH_UDC_TestData.GetFormDefinitionTokenTFAFieldAPIName + '","Question":"Token","AnswerField":"","Answer":"' + token + '"},' +
                                        QAs + ']}"');
         RestContext.request = req;
         RestContext.response = res;

         AH_UDC_REST_FormResponse.post();

         AH_UDC_REST_FormResponse.FormResponseResponse resp =
         (AH_UDC_REST_FormResponse.FormResponseResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormResponse.FormResponseResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');

         List<AH_UDC_Log__c> logMessages = [select id from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPostBadToken() {
      testData1();

      string unknownSecurityCode = AH_UDC_Shared.GetSecurityCode();
      string token = AH_UDC_Shared.CreateStepToken(unknownSecurityCode, m_oForm.id, m_oWBS.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE Username = :('Test' + SERVICE_USER + '@amadeus.com')];
      System.runAs(UDCServiceUser1)
      {

         Test.startTest();

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_FormResponse'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof('{"QuestionAnswers":[' +
                                        '{"QuestionField":"' + AH_UDC_TestData.GetFormDefinitionTokenTFAFieldAPIName + '","Question":"Token","AnswerField":"","Answer":"' + token + '"},' +
                                        '{"QuestionField":"tfa_1","Question":"My Test Question","AnswerField":"tfa_2","Answer":"My Test Answer"}]}"');

         RestContext.request = req;
         RestContext.response = res;

         AH_UDC_REST_FormResponse.post();

         AH_UDC_REST_FormResponse.FormResponseResponse resp =
         (AH_UDC_REST_FormResponse.FormResponseResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormResponse.FormResponseResponse.class);

         Test.stopTest();

         System.assertEquals('404', resp.statusCode, 'Expected 404 Response');

         List<AH_UDC_Log__c> logMessages = [select id from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Message for Exception not found but expected');
      }
   }

   @isTest
   private static void TestPostException() {
      testData1();

      string token = AH_UDC_Shared.CreateStepToken(m_oWB.SecurityCode__c, m_oForm.id, m_oWBS.id);
      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE Username = :('Test' + SERVICE_USER + '@amadeus.com')];
      System.runAs(UDCServiceUser1)
      {

         Test.startTest();

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_FormResponse'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         RestContext.request = req;
         RestContext.response = res;

         AH_UDC_REST_FormResponse.post();

         AH_UDC_REST_FormResponse.FormResponseResponse resp =
         (AH_UDC_REST_FormResponse.FormResponseResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormResponse.FormResponseResponse.class);

         Test.stopTest();

         System.assertEquals('500', resp.statusCode, 'Expected 500 Response');

         List<AH_UDC_Log__c> logMessages = [select id from AH_UDC_Log__c];
         System.assertEquals(1, logMessages.size(), 'Log Message for Exception not found but expected');
      }
   }

   @isTest
   private static void TestGet() {
      testData1();

      string token = AH_UDC_Shared.CreateStepToken(m_oWB.SecurityCode__c, m_oForm.id, m_oWBS.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE Username = :('Test' + SERVICE_USER + '@amadeus.com')];
      System.runAs(UDCServiceUser1)
      {
         RestRequest reqPost = new RestRequest();
         RestResponse resPost = new RestResponse();
         reqPost.requestURI = '/services/apexrest/AH_UDC_FormResponse'; //Request URL
         reqPost.httpMethod = 'POST'; //HTTP Request Type
         reqPost.requestBody = Blob.valueof('{"QuestionAnswers":[' +
                                            '{"QuestionField":"' + AH_UDC_TestData.GetFormDefinitionTokenTFAFieldAPIName + '","Question":"Token","AnswerField":"","Answer":"' + token + '"},' +
                                            '{"QuestionField":"tfa_1","Question":"My Test Question","AnswerField":"tfa_2","Answer":"My Test Answer"}]}"'); RestContext.request = reqPost;
         RestContext.response = resPost;

         AH_UDC_REST_FormResponse.post();

         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_FormResponse'; //Request URL
         //reqG.params.put('SecurityCode', m_securityCode);
         //reqG.params.put('FormId', m_oForm.Id);
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_FormResponse.get();

         AH_UDC_REST_FormResponse.FormResponseResponse resp = null;
         resp = (AH_UDC_REST_FormResponse.FormResponseResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormResponse.FormResponseResponse.class);

         Test.stopTest();

         List<AH_UDC_Log__c> logMessages = [select Id, LogText__c from AH_UDC_Log__c];
         System.assertEquals('200', resp.statusCode, 'Expected 200 Response: ' + resp.message);
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }

   @isTest
   private static void TestGetException() {
      testData1();

      string token = AH_UDC_Constants.FORM_TOKEN_PREFIX + 'TestException';

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE Username = :('Test' + SERVICE_USER + '@amadeus.com')];
      System.runAs(UDCServiceUser1)
      {

         Test.startTest();
         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_FormResponse'; //Request URL
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_FormResponse.get();

         AH_UDC_REST_FormResponse.FormResponseResponse resp = null;
         resp = (AH_UDC_REST_FormResponse.FormResponseResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormResponse.FormResponseResponse.class);

         Test.stopTest();

         System.assertEquals('500', resp.statusCode, 'Expected 500 Response');

         List<AH_UDC_Log__c> logMessages = [select Id, LogText__c from AH_UDC_Log__c];
         System.assertEquals(1, logMessages.size(), 'More Log Messages exist than were expected');
      }
   }

   @isTest
   private static void TestGetNoPrior() {
      testData1();

      string token = AH_UDC_Shared.CreateStepToken(m_oWB.SecurityCode__c, m_oForm.id, m_oWBS.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE Username = :('Test' + SERVICE_USER + '@amadeus.com')];
      System.runAs(UDCServiceUser1)
      {

         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_FormResponse'; //Request URL
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_FormResponse.get();

         AH_UDC_REST_FormResponse.FormResponseResponse resp =
         (AH_UDC_REST_FormResponse.FormResponseResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormResponse.FormResponseResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');

         List<AH_UDC_Log__c> logMessages = [select id from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }

   @isTest
   private static void TestGetNoPriorButNoQA() {
      testData1();

      string token = AH_UDC_Shared.CreateStepToken(m_oWB.SecurityCode__c, m_oForm.id, m_oWBS.id);

      AH_UDC_TestData.ClearLogs();

      //Create response without QAs
      Id wbRTResponseId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();

      //Create Response record for Step1
      AH_UDC_Response__c response = new AH_UDC_Response__c(
                                                           Responded__c = Datetime.now()
      );
      insert response;

      //Create  Response record for Step1
      AH_UDC_WorkbookStepResponse__c wbsResponse = new AH_UDC_WorkbookStepResponse__c(
                                                                                      Response__c = response.Id,
                                                                                      WorkbookStep__c = m_oWBS.id,
                                                                                      IsMostRecentResponse__c = true
      );
      insert wbsResponse;

      User UDCServiceUser1 = [SELECT Id FROM User WHERE Username = :('Test' + SERVICE_USER + '@amadeus.com')];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_FormResponse'; //Request URL
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_FormResponse.get();

         AH_UDC_REST_FormResponse.FormResponseResponse resp =
         (AH_UDC_REST_FormResponse.FormResponseResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormResponse.FormResponseResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');

         List<AH_UDC_Log__c> logMessages = [select id from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }

   @isTest
   private static void TestGetNoToken() {
      testData1();

      string token = AH_UDC_Constants.FORM_TOKEN_PREFIX;

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE Username = :('Test' + SERVICE_USER + '@amadeus.com')];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_FormResponse'; //Request URL
         reqG.params.put('token', 'notthetokenprefix');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_FormResponse.get();

         AH_UDC_REST_FormResponse.FormResponseResponse resp =
         (AH_UDC_REST_FormResponse.FormResponseResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormResponse.FormResponseResponse.class);

         Test.stopTest();

         System.assertEquals('400', resp.statusCode, 'Expected 400 Response');

         List<AH_UDC_Log__c> logMessages = [select id from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }

   @isTest
   private static void TestGetEmptyToken() {
      testData1();

      string token = AH_UDC_Constants.FORM_TOKEN_PREFIX;

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE Username = :('Test' + SERVICE_USER + '@amadeus.com')];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_FormResponse'; //Request URL
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_FormResponse.get();

         AH_UDC_REST_FormResponse.FormResponseResponse resp =
         (AH_UDC_REST_FormResponse.FormResponseResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormResponse.FormResponseResponse.class);

         Test.stopTest();

         System.assertEquals('400', resp.statusCode, 'Expected 400 Response');

         List<AH_UDC_Log__c> logMessages = [select id from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }

   @isTest
   private static void TestGetBadToken() {
      testData1();
      string unknownSecurityCode = AH_UDC_Shared.GetSecurityCode();
      string token = AH_UDC_Shared.CreateStepToken(unknownSecurityCode, m_oForm.id, m_oWBS.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE Username = :('Test' + SERVICE_USER + '@amadeus.com')];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_FormResponse'; //Request URL
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_FormResponse.get();

         AH_UDC_REST_FormResponse.FormResponseResponse resp =
         (AH_UDC_REST_FormResponse.FormResponseResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormResponse.FormResponseResponse.class);

         Test.stopTest();

         System.assertEquals('404', resp.statusCode, 'Expected 404 Response');

         List<AH_UDC_Log__c> logMessages = [select id from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }
   public class TestingException extends Exception { }
}