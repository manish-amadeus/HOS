/**
 * Name          : AH_UDC_REST_VerifyToken_TEST
 * Created By    : Amadeus Hospitality Services (vaishali.patel@Amadeus.com)
 * Created Date  : 2020-03-17
 * Description   : This class can be used to verify a token is valid and return information about the workbook/step
 * Dependencies  : AH_UDC_REST_VerifyToken
 **/

@isTest
private class AH_UDC_REST_VerifyToken_TEST {

   @TestSetup
   private static void setup() {
      AH_UDC_InitializationHelper.Initialize('All'); 

      //String uniqueId = AH_UDC_Shared.generateGUID();
      //Account newAccount = AH_UDC_TestData.GetAccountObject(uniqueId);
      //insert newAccount;

      //Contact newContact = AH_UDC_TestData.GetContactObject(newAccount.id, uniqueId);
      //insert newContact;

      AH_UDC_PropertyAccount__c oPA = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
      insert oPA;

      NI_Documentation__c oNIDoc1 = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
      oNIDoc1.AH_UDC_PropertyAccount__c = oPA.Id;
      insert oNIDoc1;

      //Find Amadeusform Record Type
      Id FileUploadRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
      AH_UDC_Form__c oForm = AH_UDC_TestData.GetForm('', '', 'TestForm1', '');
      oForm.RecordTypeId = FileUploadRecordTypeId;
      insert oForm;

      // Find the "Workbook Sent" record type Id
      Id rtWbSentId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();

      // Create Workbook Sent
      String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
      AH_UDC_Workbook__c oWB1 = AH_UDC_TestData.GetWorkbookObject(oNIDoc1.Id, 'TestWorkbook001', 'TestWorkbookDescription', product);
      oWB1.RecordtypeId = rtWbSentId;
      insert oWB1;

      // Find the Workbook Step Sent Record Type
      Id rtWbsSentId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();

      // Create Workbook Sent Step
      AH_UDC_WorkbookStep__c oWBS1 = AH_UDC_TestData.GetWorkbookStepObject(oWB1.Id, 'TEST001');
      oWBS1.RecordTypeId = rtWbsSentId;
      oWBS1.Workbook__c = oWB1.Id;
      oWBS1.Form__c = oForm.Id;
      insert oWBS1;

      List<User> listUsers = new List<User> ();
      //Build UDC Service User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE,
                                    'VT_ServiceUser1', null, false));

      //////Build Community User with chatter
      ////listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER,
                                    ////AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                    ////'VT_CommunityUserNoChatter', newContact.Id, true));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         //AH_UDC_TestData.InsertWithRetries(listUsers);
         insert listUsers;

         // Community Users
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE, listUsers[0].Id);
         //AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[1].Id);
      }

   }

   @isTest
   private static void TestGet() {
      AH_UDC_Workbook__c oWB1 = [select SecurityCode__c from AH_UDC_Workbook__c where Name='TestWorkbook001'];
      AH_UDC_WorkbookStep__c oWBS1 = [select id from AH_UDC_WorkbookStep__c where name ='TEST001'];
      AH_UDC_Form__c oForm = [select id from AH_UDC_Form__c where name ='TestForm1'];

      string token = AH_UDC_Shared.CreateStepToken(oWB1.SecurityCode__c, oForm.id, oWBS1.id);
      AH_UDC_TestData.ClearLogs();
      Test.startTest();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE Username = :('TestVT_ServiceUser1@amadeus.com') ];
      System.runAs(UDCServiceUser1)
      {
      
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

         
         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');
         System.assertEquals(AH_UDC_ConfigHelper.GetString('AH_UDC_FileUploadAllowedExtensions',''), resp.allowedFileUploadExtensions, 'Allowed File Extensions should Match');
         System.assertEquals(AH_UDC_ConfigHelper.GetString('AH_UDC_FileUploadMaximumSizeInMB',AH_UDC_Constants.FILE_UPLOAD_MAXIMUM_SIZE_IN_MB_DEFAULT), resp.maximumFileUploadSizeInMB, 'Maximum File Upload Size should Match');
         List<AH_UDC_Log__c> logMessages = [SELECT Id, FunctionalArea__c, LogText__c FROM AH_UDC_Log__c];        
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
      Test.stopTest();

      System.assertEquals(0, 0, 'ROBDEV');
   }

   @isTest
   private static void TestGetException() {
      string token = AH_UDC_Constants.FORM_TOKEN_PREFIX + 'TestException';
      AH_UDC_TestData.ClearLogs();

      Test.startTest();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE Username = :('TestVT_ServiceUser1@amadeus.com') ];

      System.runAs(UDCServiceUser1)
      {
         

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

         

         System.assertEquals('500', resp.statusCode, 'Expected 500 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(1, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
      Test.stopTest();
   }
   @isTest
   private static void TestGetNoToken() {
      AH_UDC_TestData.ClearLogs();
      Test.startTest();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE Username = :('TestVT_ServiceUser1@amadeus.com') ];
      System.runAs(UDCServiceUser1)
      {
         

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

         

         System.assertEquals('400', resp.statusCode, 'Expected 400 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
      Test.stopTest();
   }

   @isTest
   private static void TestGetEmptyToken() {

      string token = AH_UDC_Constants.FORM_TOKEN_PREFIX;

      AH_UDC_TestData.ClearLogs();
      Test.startTest();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE Username = :('TestVT_ServiceUser1@amadeus.com') ];
      System.runAs(UDCServiceUser1)
      {
         

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

        

         System.assertEquals('400', resp.statusCode, 'Expected 400 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
      Test.stopTest();
   }

   @isTest
   private static void TestGetBadToken() {
      AH_UDC_Workbook__c oWB1 = [select SecurityCode__c from AH_UDC_Workbook__c where Name='TestWorkbook001'];
      AH_UDC_WorkbookStep__c oWBS1 = [select id from AH_UDC_WorkbookStep__c where name ='TEST001'];
      AH_UDC_Form__c oForm = [select id from AH_UDC_Form__c where name ='TestForm1'];

      string unknownSecurityCode = AH_UDC_Shared.GetSecurityCode();
      string token = AH_UDC_Shared.CreateStepToken(unknownSecurityCode, oForm.id, oWBS1.id);

      AH_UDC_TestData.ClearLogs();
      Test.startTest();

      User UDCServiceUser1 = [SELECT Id FROM user WHERE Username = :('TestVT_ServiceUser1@amadeus.com') ];

      System.runAs(UDCServiceUser1)
      {
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

         

         System.assertEquals('404', resp.statusCode, 'Expected 404 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
      Test.stopTest();
   }

   @isTest
   private static void TestGetBadTokenWithoutSecurityCode() {
      AH_UDC_Workbook__c oWB1 = [select SecurityCode__c from AH_UDC_Workbook__c where Name='TestWorkbook001'];
      AH_UDC_WorkbookStep__c oWBS1 = [select id from AH_UDC_WorkbookStep__c where name ='TEST001'];
      AH_UDC_Form__c oForm = [select id from AH_UDC_Form__c where name ='TestForm1'];

      string token = AH_UDC_Shared.CreateStepToken('', oForm.id, oWBS1.id);

      AH_UDC_TestData.ClearLogs();
      Test.startTest();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE Username = :('TestVT_ServiceUser1@amadeus.com') ];

      System.runAs(UDCServiceUser1)
      {
        

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

         

         System.assertEquals('400', resp.statusCode, 'Expected 400 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
      Test.stopTest();
   }
}