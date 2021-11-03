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
      AH_UDC_TestData.CreateUDCWorkbookAdmin('WBAdmin1');
      AH_UDC_TestData.CreateUDCWorkbookAdmin('WBAdmin2');
      AH_UDC_TestData.CreateUDCWorkbookUser('WBUser1');
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
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      AH_UDC_TestData.ClearLogs();
      User UDCWorkbookAdmin1 = [select id from user where LastName='WBAdmin1'];
      System.runAs(UDCWorkbookAdmin1)
      {
         Test.startTest();

         testData1(); //Create form as user

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

         System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response');
      
         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPost_ExistingButNotTheirForm() {
      //TODO ROBDEV This test should get a 500 since the user doesn't have access to update other user's forms
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      AH_UDC_TestData.ClearLogs();

      //Create form as WBAdmin1
      User UDCWorkbookAdmin1 = [select id from user where LastName='WBAdmin1'];
      System.runAs(UDCWorkbookAdmin1)
      {
         String definition = AH_UDC_TestData.GetFormDefinition();
         m_oForm = AH_UDC_TestData.GetForm(definition,'4853168', 'TestForm1', '58c874ca-f1e4-4504-9878-b4b97af509ec');
         insert m_oForm;
      }

      User UDCWorkbookAdmin2 = [select id from user where LastName='WBAdmin2'];
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
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      AH_UDC_TestData.ClearLogs();
      User UDCWorkbookAdmin1 = [select id from user where LastName='WBAdmin1'];
      System.runAs(UDCWorkbookAdmin1)
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

         System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response');

         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPost_NewAsWBUser() {
      //This test should fail since Workbook User's don't have permission to create forms

      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
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
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      AH_UDC_TestData.ClearLogs();
      Test.startTest();

      RestRequest req = new RestRequest();
      RestResponse res = new RestResponse();
      req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
      req.httpMethod = 'POST'; //HTTP Request Type
      req.requestBody = Blob.valueof('Exception1');
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
      System.assertEquals(1, logMessages.size(), 'Log Messages do not exist and were expected : logMessages.size() : ' + logMessages.size());
   }

   @isTest
   private static void TestPost_ExceptionWriteQLog() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      AH_UDC_TestData.ClearLogs();
      Test.startTest();

      RestRequest req = new RestRequest();
      RestResponse res = new RestResponse();
      req.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
      req.httpMethod = 'POST'; //HTTP Request Type
      req.requestBody = Blob.valueof('ExceptionWriteQLogs');
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
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected : logMessages.size() : ' + logMessages.size());
   }

   @isTest
   private static void TestGet() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
      reqG.params.put('FormId', '4853168');
      reqG.httpMethod = 'GET'; //HTTP Request Type
      RestContext.request = reqG;
      RestContext.response = resG;

      System.debug('###Call Get');
      AH_UDC_REST_FormDefinition.get();

      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp =
      (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
      JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

      Test.stopTest();

      System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
   }

   @isTest
   private static void TestGet_BadRequest() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
      reqG.httpMethod = 'GET'; //HTTP Request Type
      RestContext.request = reqG;
      RestContext.response = resG;

      System.debug('###Call Get');
      AH_UDC_REST_FormDefinition.get();

      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp =
      (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
      JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

      Test.stopTest();

      System.assertEquals('400', resp.formStatusCode, 'Expected 400 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
   }

   @isTest
   private static void TestGet_FormNotFound() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
      reqG.params.put('FormId', '123');
      reqG.httpMethod = 'GET'; //HTTP Request Type
      RestContext.request = reqG;
      RestContext.response = resG;

      System.debug('###Call Get');
      AH_UDC_REST_FormDefinition.get();

      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp =
      (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
      JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

      Test.stopTest();

      System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
   }  

   @isTest
   private static void TestGet_Exception() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
      reqG.params.put('FormId', 'Exception1');
      reqG.httpMethod = 'GET'; //HTTP Request Type
      RestContext.request = reqG;
      RestContext.response = resG;

      System.debug('###Call Get');
      AH_UDC_REST_FormDefinition.get();

      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp =
      (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
      JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

      Test.stopTest();

      System.assertEquals('500', resp.formStatusCode, 'Expected 500 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(1, logMessages.size(), 'Log Messages do not exist and were expected : logMessages.size() : ' + logMessages.size());
   }

   @isTest
   private static void TestGet_ExceptionWriteQLogs() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      AH_UDC_TestData.ClearLogs();
      testData1();

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      reqG.requestURI = '/services/apexrest/AH_UDC_REST_FormDefinition'; //Request URL
      reqG.params.put('FormId', 'ExceptionWriteQLogs');
      reqG.httpMethod = 'GET'; //HTTP Request Type
      RestContext.request = reqG;
      RestContext.response = resG;

      System.debug('###Call Get');
      AH_UDC_REST_FormDefinition.get();

      AH_UDC_REST_FormDefinition.FormDefinitionResponse resp =
      (AH_UDC_REST_FormDefinition.FormDefinitionResponse)
      JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_FormDefinition.FormDefinitionResponse.class);

      Test.stopTest();

      System.assertEquals('200', resp.formStatusCode, 'Expected 200 Response: ' + resp.formStatusMessage);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected : logMessages.size() : ' + logMessages.size());
   }
}