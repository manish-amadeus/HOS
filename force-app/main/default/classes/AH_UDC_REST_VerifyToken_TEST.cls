/**
 * Name          : AH_UDC_REST_VerifyToken_TEST
 * Created By    : Amadeus Hospitality Services (vaishali.patel@Amadeus.com)
 * Created Date  : 2020-03-17
 * Description   : This class can be used to verify a token is valid and return information about the workbook/step
 * Dependencies  : AH_UDC_REST_VerifyToken
 **/

@isTest
private class AH_UDC_REST_VerifyToken_TEST {

   private static AH_UDC_PropertyAccount__c oPA = null;
   private static NI_Documentation__c oNIDoc1 = null;
   private static AH_UDC_Workbook__c m_oWB1 = null;
   private static AH_UDC_WorkbookStep__c m_oWBS1 = null;
   private static AH_UDC_Form__c m_oForm = null;
   private static User m_oUser = null;

   @TestSetup
   private static void setup() {
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
                                    'VT_ServiceUser1', null, false));
      //Build Community User with chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                    'VT_CommunityUserNoChatter', newContact.Id, true));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

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

         oNIDoc1 = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
         oNIDoc1.AH_UDC_PropertyAccount__c = oPA.Id;
         insert oNIDoc1;

         //Find Amadeusform Record Type
         Id FileUploadRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
         m_oForm = AH_UDC_TestData.GetForm('', '', 'TestForm1', '');
         m_oForm.RecordTypeId = FileUploadRecordTypeId;
         insert m_oForm;

         // Find the "Workbook Sent" record type Id
         Id rtWbSentId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();

         // Create Workbook Sent
         String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
         m_oWB1 = AH_UDC_TestData.GetWorkbookObject(oNIDoc1.Id, 'TestWorkbook001', 'TestWorkbookDescription', product);
         m_oWB1.RecordtypeId = rtWbSentId;
         insert m_oWB1;

         // Find the Workbook Step Sent Record Type
         Id rtWbsSentId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();

         // Create Workbook Sent Step
         m_oWBS1 = AH_UDC_TestData.GetWorkbookStepObject(m_oWB1.Id, 'TEST001');
         m_oWBS1.RecordTypeId = rtWbsSentId;
         m_oWBS1.Workbook__c = m_oWB1.Id;
         m_oWBS1.Form__c = m_oForm.Id;
         insert m_oWBS1;

         // Create Community User
         m_oUser = [SELECT Id FROM User WHERE Username = :('TestVT_CommunityUserNoChatter@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      }
      catch(Exception exc) {
         System.debug(LoggingLevel.ERROR, 'Failed to correctly setup test data');
         throw exc;
      }
   }

   //@isTest
   //private static void TestGet() {
      //testData1();
      //string token = AH_UDC_Shared.CreateStepToken(m_oWB1.SecurityCode__c, m_oForm.id, m_oWBS1.id);
      //AH_UDC_TestData.ClearLogs();
      //User UDCServiceUser1 = [SELECT Id FROM user WHERE Username = :('TestVT_ServiceUser1@amadeus.com') ];
      //System.runAs(UDCServiceUser1)
      //{
         //Test.startTest();

         //RestRequest reqG = new RestRequest();
         //RestResponse resG = new RestResponse();
         //reqG.requestURI = '/services/apexrest/AH_UDC_VerifyToken'; //Request URL
         //reqG.params.put('token', token);
         //reqG.httpMethod = 'GET'; //HTTP Request Type
         //RestContext.request = reqG;
         //RestContext.response = resG;

         //AH_UDC_REST_VerifyToken.get();

         //AH_UDC_REST_VerifyToken.VerifyTokenGetResponse resp =
         //(AH_UDC_REST_VerifyToken.VerifyTokenGetResponse)
         //JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_VerifyToken.VerifyTokenGetResponse.class);

         //Test.stopTest();

         //System.assertEquals('200', resp.statusCode, 'Expected 200 Response');
         //System.assertEquals(AH_UDC_ConfigHelper.GetString('AH_UDC_FileUploadAllowedExtensions',''), resp.allowedFileUploadExtensions, 'Allowed File Extensions should Match');
         //System.assertEquals(AH_UDC_ConfigHelper.GetString('AH_UDC_FileUploadMaximumSizeInMB',AH_UDC_Constants.FILE_UPLOAD_MAXIMUM_SIZE_IN_MB_DEFAULT), resp.maximumFileUploadSizeInMB, 'Maximum File Upload Size should Match');
         //List<AH_UDC_Log__c> logMessages = [SELECT Id, FunctionalArea__c, LogText__c FROM AH_UDC_Log__c];        
         //System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      //}
   //}
   @isTest
   private static void TestGetException() {
      string token = AH_UDC_Constants.FORM_TOKEN_PREFIX + 'TestException';
      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE Username = :('TestVT_ServiceUser1@amadeus.com') ];

      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_VerifyToken'; //Request URL
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_VerifyToken.get();

         AH_UDC_REST_VerifyToken.VerifyTokenGetResponse resp =
         (AH_UDC_REST_VerifyToken.VerifyTokenGetResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_VerifyToken.VerifyTokenGetResponse.class);

         Test.stopTest();

         System.assertEquals('500', resp.statusCode, 'Expected 500 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(1, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }
   @isTest
   private static void TestGetNoToken() {
      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE Username = :('TestVT_ServiceUser1@amadeus.com') ];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_VerifyToken'; //Request URL
         reqG.params.put('token', 'notthetokenprefix');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_VerifyToken.get();

         AH_UDC_REST_VerifyToken.VerifyTokenGetResponse resp =
         (AH_UDC_REST_VerifyToken.VerifyTokenGetResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_VerifyToken.VerifyTokenGetResponse.class);

         Test.stopTest();

         System.assertEquals('400', resp.statusCode, 'Expected 400 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }

   @isTest
   private static void TestGetEmptyToken() {

      string token = AH_UDC_Constants.FORM_TOKEN_PREFIX;

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE Username = :('TestVT_ServiceUser1@amadeus.com') ];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_VerifyToken.get();

         AH_UDC_REST_VerifyToken.VerifyTokenGetResponse resp =
         (AH_UDC_REST_VerifyToken.VerifyTokenGetResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_VerifyToken.VerifyTokenGetResponse.class);

         Test.stopTest();

         System.assertEquals('400', resp.statusCode, 'Expected 400 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }

   @isTest
   private static void TestGetBadToken() {
      testData1();
      string unknownSecurityCode = AH_UDC_Shared.GetSecurityCode();
      string token = AH_UDC_Shared.CreateStepToken(unknownSecurityCode, m_oForm.id, m_oWBS1.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE Username = :('TestVT_ServiceUser1@amadeus.com') ];

      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_VerifyToken.get();

         AH_UDC_REST_VerifyToken.VerifyTokenGetResponse resp =
         (AH_UDC_REST_VerifyToken.VerifyTokenGetResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_VerifyToken.VerifyTokenGetResponse.class);

         Test.stopTest();

         System.assertEquals('404', resp.statusCode, 'Expected 404 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }
   @isTest
   private static void TestGetBadTokenWithoutSecurityCode() {
      testData1();
      string token = AH_UDC_Shared.CreateStepToken('', m_oForm.id, m_oWBS1.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE Username = :('TestVT_ServiceUser1@amadeus.com') ];

      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_VerifyToken.get();

         AH_UDC_REST_VerifyToken.VerifyTokenGetResponse resp =
         (AH_UDC_REST_VerifyToken.VerifyTokenGetResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_VerifyToken.VerifyTokenGetResponse.class);

         Test.stopTest();

         System.assertEquals('400', resp.statusCode, 'Expected 400 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }
}