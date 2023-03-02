<<<<<<< HEAD
<<<<<<< HEAD
/**
 * Name          : AH_UDC_REST_FormDefinition_TEST
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-07-03
 * Description   : This is a test class for AH_UDC_REST_FormDefinition
 * Dependencies  : AH_UDC_REST_FormDefinition
 *
 **/

@isTest
private class AH_UDC_REST_FormDefinition_TEST {

   private static AH_UDC_Form__c m_oForm = null;

   @testSetup 
   static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();
      //Build UDC Admin User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    'WBAdmin1', null, false));
      //Build UDC Admin User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    'WBAdmin2', null, false));
      //Build UDC Admin User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                    'WBUser1', null, false));

      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE,
                                              'FD_ServiceUser1', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         // Community Users
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[2].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE, listUsers[3].Id);
      }
   }

   private static void testData1()
   { 
      try 
      {
         String definition = AH_UDC_TestData.GetFormDefinition();
         m_oForm = AH_UDC_TestData.GetForm(definition,'4853168', 'TestForm1', '58c874ca-f1e4-4504-9878-b4b97af509ec');
         insert m_oForm;
      }
      catch(Exception exc) {
         System.debug(LoggingLevel.ERROR, 'Failed to correctly setup test data');
         throw exc;
      }

   }

   @isTest
   private static void TestPost_Existing() {
      AH_UDC_TestData.ClearLogs();

      RestRequest req = new RestRequest();
      RestResponse res = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         testData1(); //Create form as user

         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(AH_UDC_TestData.GetFormDefinition());
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response');
      
         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPost_ExistingButNotTheirForm() {     
      AH_UDC_TestData.ClearLogs();

      //Create form as WBAdmin1
      User UDCWorkbookAdmin1 = [select id from user where LastName='WBAdmin1'];
      User UDCWorkbookAdmin2 = [select id from user where LastName='WBAdmin2'];
      System.runAs(UDCWorkbookAdmin1)
      {
         String definition = AH_UDC_TestData.GetFormDefinition();
         m_oForm = AH_UDC_TestData.GetForm(definition,'4853168', 'TestForm1', '58c874ca-f1e4-4504-9878-b4b97af509ec');
         insert m_oForm;
      }

      //Even though C# call the endpoint, the call to AH_UDC_REST_FormDefinition is done using a User's impersonation token and not the Service User's token
      System.runAs(UDCWorkbookAdmin2)
      {
         Test.startTest();

         List<AH_UDC_Form__c> forms = [select id from AH_UDC_Form__c where FormAssemblyId__c = '4853168'];
         System.assertEquals(1, forms.size(), 'Expected User to be able to view form');

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(AH_UDC_TestData.GetFormDefinition());
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         AH_UDC_REST_FormDefinition.FormDefinitionResponse resp =
         (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

         Test.stopTest();

         System.assertEquals('500', resp.formDefinitionStatusCode, 'Expected 500 Response');
      
         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPost_New() {
      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(AH_UDC_TestData.GetFormDefinition());
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         AH_UDC_REST_FormDefinition.FormDefinitionResponse resp =
         (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

         Test.stopTest();
         System.debug('###debug:formDefinitionStatusCode:' + resp.formDefinitionStatusCode);
         System.debug('###debug:formDefinitionStatusMessage:' + resp.formDefinitionStatusMessage);
         System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response');

         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPost_NewAsWBUser() {
      //This test should fail since Workbook User's don't have permission to create forms

      AH_UDC_TestData.ClearLogs();
      User UDCWorkbookUser1 = [select id from user where LastName='WBUser1'];
      System.runAs(UDCWorkbookUser1)
      {
         Test.startTest();
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(AH_UDC_TestData.GetFormDefinition());
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         AH_UDC_REST_FormDefinition.FormDefinitionResponse resp =
         (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

         Test.stopTest();

         System.assertEquals('500', resp.formStatusCode, 'Expected 500 Response');

         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPost_Exception() {
      AH_UDC_TestData.ClearLogs();
      Test.startTest();

      RestRequest req = new RestRequest();
      RestResponse res = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof('Exception1');
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         resp =(AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }

      Test.stopTest();

      System.assertEquals('500', resp.formStatusCode, 'Expected 500 Response');

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(1, logMessages.size(), 'Log Messages do not exist and were expected : logMessages.size() : ' + logMessages.size());
   }

   @isTest
   private static void TestPost_ExceptionWriteQLog() {
      AH_UDC_TestData.ClearLogs();
      Test.startTest();

      RestRequest req = new RestRequest();
      RestResponse res = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof('ExceptionWriteQLogs');
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('500', resp.formStatusCode, 'Expected 500 Response');

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected : logMessages.size() : ' + logMessages.size());
   }

   @isTest
   private static void TestGet() {
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         reqG.params.put('FormId', '4853168');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         System.debug('###Call Get');
         AH_UDC_REST_FormDefinition.get();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
   }

   @isTest
   private static void TestGet_BadRequest() {
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         System.debug('###Call Get');
         AH_UDC_REST_FormDefinition.get();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('400', resp.formStatusCode, 'Expected 400 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
   }

   @isTest
   private static void TestGet_FormNotFound() {
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         reqG.params.put('FormId', '123');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         System.debug('###Call Get');
         AH_UDC_REST_FormDefinition.get();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
   }  

   @isTest
   private static void TestGet_Exception() {
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         reqG.params.put('FormId', 'Exception1');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         System.debug('###Call Get');
         AH_UDC_REST_FormDefinition.get();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('500', resp.formStatusCode, 'Expected 500 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(1, logMessages.size(), 'Log Messages do not exist and were expected : logMessages.size() : ' + logMessages.size());
   }

   @isTest
   private static void TestGet_ExceptionWriteQLogs() {
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         reqG.params.put('FormId', 'ExceptionWriteQLogs');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         System.debug('###Call Get');
         AH_UDC_REST_FormDefinition.get();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected : logMessages.size() : ' + logMessages.size());
   }
=======
/**
 * Name          : AH_UDC_REST_FormDefinition_TEST
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-07-03
 * Description   : This is a test class for AH_UDC_REST_FormDefinition
 * Dependencies  : AH_UDC_REST_FormDefinition
 *
 **/

@isTest
private class AH_UDC_REST_FormDefinition_TEST {

   private static AH_UDC_Form__c m_oForm = null;

   @testSetup 
   static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();
      //Build UDC Admin User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    'WBAdmin1', null, false));
      //Build UDC Admin User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    'WBAdmin2', null, false));
      //Build UDC Admin User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                    'WBUser1', null, false));

      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE,
                                              'FD_ServiceUser1', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         // Community Users
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[2].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE, listUsers[3].Id);
      }
   }

   private static void testData1()
   { 
      try 
      {
         String definition = AH_UDC_TestData.GetFormDefinition();
         m_oForm = AH_UDC_TestData.GetForm(definition,'4853168', 'TestForm1', '58c874ca-f1e4-4504-9878-b4b97af509ec');
         insert m_oForm;
      }
      catch(Exception exc) {
         System.debug(LoggingLevel.ERROR, 'Failed to correctly setup test data');
         throw exc;
      }

   }

   @isTest
   private static void TestPost_Existing() {
      AH_UDC_TestData.ClearLogs();

      RestRequest req = new RestRequest();
      RestResponse res = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         testData1(); //Create form as user

         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(AH_UDC_TestData.GetFormDefinition());
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response');
      
         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPost_ExistingButNotTheirForm() {     
      AH_UDC_TestData.ClearLogs();

      //Create form as WBAdmin1
      User UDCWorkbookAdmin1 = [select id from user where LastName='WBAdmin1'];
      User UDCWorkbookAdmin2 = [select id from user where LastName='WBAdmin2'];
      System.runAs(UDCWorkbookAdmin1)
      {
         String definition = AH_UDC_TestData.GetFormDefinition();
         m_oForm = AH_UDC_TestData.GetForm(definition,'4853168', 'TestForm1', '58c874ca-f1e4-4504-9878-b4b97af509ec');
         insert m_oForm;
      }

      //Even though C# call the endpoint, the call to AH_UDC_REST_FormDefinition is done using a User's impersonation token and not the Service User's token
      System.runAs(UDCWorkbookAdmin2)
      {
         Test.startTest();

         List<AH_UDC_Form__c> forms = [select id from AH_UDC_Form__c where FormAssemblyId__c = '4853168'];
         System.assertEquals(1, forms.size(), 'Expected User to be able to view form');

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(AH_UDC_TestData.GetFormDefinition());
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         AH_UDC_REST_FormDefinition.FormDefinitionResponse resp =
         (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

         Test.stopTest();

         System.assertEquals('500', resp.formDefinitionStatusCode, 'Expected 500 Response');
      
         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPost_New() {
      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(AH_UDC_TestData.GetFormDefinition());
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         AH_UDC_REST_FormDefinition.FormDefinitionResponse resp =
         (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

         Test.stopTest();
         System.debug('###debug:formDefinitionStatusCode:' + resp.formDefinitionStatusCode);
         System.debug('###debug:formDefinitionStatusMessage:' + resp.formDefinitionStatusMessage);
         System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response');

         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPost_NewAsWBUser() {
      //This test should fail since Workbook User's don't have permission to create forms

      AH_UDC_TestData.ClearLogs();
      User UDCWorkbookUser1 = [select id from user where LastName='WBUser1'];
      System.runAs(UDCWorkbookUser1)
      {
         Test.startTest();
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(AH_UDC_TestData.GetFormDefinition());
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         AH_UDC_REST_FormDefinition.FormDefinitionResponse resp =
         (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

         Test.stopTest();

         System.assertEquals('500', resp.formStatusCode, 'Expected 500 Response');

         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPost_Exception() {
      AH_UDC_TestData.ClearLogs();
      Test.startTest();

      RestRequest req = new RestRequest();
      RestResponse res = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof('Exception1');
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         resp =(AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }

      Test.stopTest();

      System.assertEquals('500', resp.formStatusCode, 'Expected 500 Response');

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(1, logMessages.size(), 'Log Messages do not exist and were expected : logMessages.size() : ' + logMessages.size());
   }

   @isTest
   private static void TestPost_ExceptionWriteQLog() {
      AH_UDC_TestData.ClearLogs();
      Test.startTest();

      RestRequest req = new RestRequest();
      RestResponse res = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof('ExceptionWriteQLogs');
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('500', resp.formStatusCode, 'Expected 500 Response');

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected : logMessages.size() : ' + logMessages.size());
   }

   @isTest
   private static void TestGet() {
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         reqG.params.put('FormId', '4853168');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         System.debug('###Call Get');
         AH_UDC_REST_FormDefinition.get();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
   }

   @isTest
   private static void TestGet_BadRequest() {
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         System.debug('###Call Get');
         AH_UDC_REST_FormDefinition.get();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('400', resp.formStatusCode, 'Expected 400 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
   }

   @isTest
   private static void TestGet_FormNotFound() {
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         reqG.params.put('FormId', '123');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         System.debug('###Call Get');
         AH_UDC_REST_FormDefinition.get();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
   }  

   @isTest
   private static void TestGet_Exception() {
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         reqG.params.put('FormId', 'Exception1');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         System.debug('###Call Get');
         AH_UDC_REST_FormDefinition.get();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('500', resp.formStatusCode, 'Expected 500 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(1, logMessages.size(), 'Log Messages do not exist and were expected : logMessages.size() : ' + logMessages.size());
   }

   @isTest
   private static void TestGet_ExceptionWriteQLogs() {
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         reqG.params.put('FormId', 'ExceptionWriteQLogs');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         System.debug('###Call Get');
         AH_UDC_REST_FormDefinition.get();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected : logMessages.size() : ' + logMessages.size());
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
/**
 * Name          : AH_UDC_REST_FormDefinition_TEST
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-07-03
 * Description   : This is a test class for AH_UDC_REST_FormDefinition
 * Dependencies  : AH_UDC_REST_FormDefinition
 *
 **/

@isTest
private class AH_UDC_REST_FormDefinition_TEST {

   private static AH_UDC_Form__c m_oForm = null;

   @testSetup 
   static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();
      //Build UDC Admin User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    'WBAdmin1', null, false));
      //Build UDC Admin User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    'WBAdmin2', null, false));
      //Build UDC Admin User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                    'WBUser1', null, false));

      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE,
                                              'FD_ServiceUser1', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         // Community Users
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[2].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE, listUsers[3].Id);
      }
   }

   private static void testData1()
   { 
      try 
      {
         String definition = AH_UDC_TestData.GetFormDefinition();
         m_oForm = AH_UDC_TestData.GetForm(definition,'4853168', 'TestForm1', '58c874ca-f1e4-4504-9878-b4b97af509ec');
         insert m_oForm;
      }
      catch(Exception exc) {
         System.debug(LoggingLevel.ERROR, 'Failed to correctly setup test data');
         throw exc;
      }

   }

   @isTest
   private static void TestPost_Existing() {
      AH_UDC_TestData.ClearLogs();

      RestRequest req = new RestRequest();
      RestResponse res = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         testData1(); //Create form as user

         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(AH_UDC_TestData.GetFormDefinition());
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response');
      
         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPost_ExistingButNotTheirForm() {     
      AH_UDC_TestData.ClearLogs();

      //Create form as WBAdmin1
      User UDCWorkbookAdmin1 = [select id from user where LastName='WBAdmin1'];
      User UDCWorkbookAdmin2 = [select id from user where LastName='WBAdmin2'];
      System.runAs(UDCWorkbookAdmin1)
      {
         String definition = AH_UDC_TestData.GetFormDefinition();
         m_oForm = AH_UDC_TestData.GetForm(definition,'4853168', 'TestForm1', '58c874ca-f1e4-4504-9878-b4b97af509ec');
         insert m_oForm;
      }

      //Even though C# call the endpoint, the call to AH_UDC_REST_FormDefinition is done using a User's impersonation token and not the Service User's token
      System.runAs(UDCWorkbookAdmin2)
      {
         Test.startTest();

         List<AH_UDC_Form__c> forms = [select id from AH_UDC_Form__c where FormAssemblyId__c = '4853168'];
         System.assertEquals(1, forms.size(), 'Expected User to be able to view form');

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(AH_UDC_TestData.GetFormDefinition());
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         AH_UDC_REST_FormDefinition.FormDefinitionResponse resp =
         (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

         Test.stopTest();

         System.assertEquals('500', resp.formDefinitionStatusCode, 'Expected 500 Response');
      
         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPost_New() {
      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(AH_UDC_TestData.GetFormDefinition());
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         AH_UDC_REST_FormDefinition.FormDefinitionResponse resp =
         (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

         Test.stopTest();
         System.debug('###debug:formDefinitionStatusCode:' + resp.formDefinitionStatusCode);
         System.debug('###debug:formDefinitionStatusMessage:' + resp.formDefinitionStatusMessage);
         System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response');

         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPost_NewAsWBUser() {
      //This test should fail since Workbook User's don't have permission to create forms

      AH_UDC_TestData.ClearLogs();
      User UDCWorkbookUser1 = [select id from user where LastName='WBUser1'];
      System.runAs(UDCWorkbookUser1)
      {
         Test.startTest();
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(AH_UDC_TestData.GetFormDefinition());
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         AH_UDC_REST_FormDefinition.FormDefinitionResponse resp =
         (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

         Test.stopTest();

         System.assertEquals('500', resp.formStatusCode, 'Expected 500 Response');

         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPost_Exception() {
      AH_UDC_TestData.ClearLogs();
      Test.startTest();

      RestRequest req = new RestRequest();
      RestResponse res = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof('Exception1');
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         resp =(AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }

      Test.stopTest();

      System.assertEquals('500', resp.formStatusCode, 'Expected 500 Response');

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(1, logMessages.size(), 'Log Messages do not exist and were expected : logMessages.size() : ' + logMessages.size());
   }

   @isTest
   private static void TestPost_ExceptionWriteQLog() {
      AH_UDC_TestData.ClearLogs();
      Test.startTest();

      RestRequest req = new RestRequest();
      RestResponse res = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof('ExceptionWriteQLogs');
         RestContext.request = req;
         RestContext.response = res;

         System.debug('###Call Post');
         AH_UDC_REST_FormDefinition.post();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('500', resp.formStatusCode, 'Expected 500 Response');

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected : logMessages.size() : ' + logMessages.size());
   }

   @isTest
   private static void TestGet() {
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         reqG.params.put('FormId', '4853168');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         System.debug('###Call Get');
         AH_UDC_REST_FormDefinition.get();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
   }

   @isTest
   private static void TestGet_BadRequest() {
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         System.debug('###Call Get');
         AH_UDC_REST_FormDefinition.get();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('400', resp.formStatusCode, 'Expected 400 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
   }

   @isTest
   private static void TestGet_FormNotFound() {
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         reqG.params.put('FormId', '123');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         System.debug('###Call Get');
         AH_UDC_REST_FormDefinition.get();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
   }  

   @isTest
   private static void TestGet_Exception() {
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         reqG.params.put('FormId', 'Exception1');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         System.debug('###Call Get');
         AH_UDC_REST_FormDefinition.get();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('500', resp.formStatusCode, 'Expected 500 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(1, logMessages.size(), 'Log Messages do not exist and were expected : logMessages.size() : ' + logMessages.size());
   }

   @isTest
   private static void TestGet_ExceptionWriteQLogs() {
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp;

      User UDCServiceUser1 = [select id from user where LastName='FD_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
         reqG.params.put('FormId', 'ExceptionWriteQLogs');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         System.debug('###Call Get');
         AH_UDC_REST_FormDefinition.get();

         resp = (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);
      }
      Test.stopTest();

      System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected : logMessages.size() : ' + logMessages.size());
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}