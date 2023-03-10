/**
 * Name          : AH_UDC_REST_LogMessage_TEST
 * Created By    : Amadeus Hospitality Services (Vaishali.Patel@Amadeus.com)
 * Created Date  : 2021-07-29
 * Description   : This is a test class for AH_UDC_REST_LogMessage
 * Dependencies  : AH_UDC_REST_LogMessage
 *
 **/

@isTest
private class AH_UDC_REST_LogMessage_TEST {

   @TestSetup private static void setup() {

      List<User> listUsers = new List<User> ();
      //Build UDC Service User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE,
                                    'LM_ServiceUser1', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         //AH_UDC_TestData.InsertWithRetries(listUsers);
         insert listUsers;

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE, listUsers[0].Id);
      }
   }

   @isTest
   private static void TestPost_LogWarning() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE LastName = 'LM_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         String strReq = '{"logLevel":"AH_UDC_LogHelper.LogLevel_EXC", "functionalArea":"AH_UDC_REST_LogMessage", "sourceMethod":"post","details" : "An exception occurred processing a response","e":null, "relatedRecordId" :null, "relatedRecordType":null}';
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_REST_LogMesssage'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(strReq);
         RestContext.request = req;
         RestContext.response = res;
         AH_UDC_LogHelper.debug('TestPost_LogWarning - Call Post');
         Test.startTest();
         AH_UDC_REST_LogMessage.post();
         AH_UDC_REST_LogMessage.LogMessageResponse resp =
         (AH_UDC_REST_LogMessage.LogMessageResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_LogMessage.LogMessageResponse.class);
         Test.stopTest();
         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');
      }
   }
   @isTest
   private static void TestPost_LogException() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE LastName = 'LM_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         String strReq = '{"logLevel": null, "functionalArea":"AH_UDC_REST_LogMessage", "sourceMethod":"post","details" : "An exception occurred processing a response","e":null, "relatedRecordId" :null, "relatedRecordType":null}';
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_REST_LogMesssage'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(strReq);
         RestContext.request = req;
         RestContext.response = res;
         AH_UDC_LogHelper.debug('TestPost_LogException - Call Post');
         Test.startTest();
         AH_UDC_REST_LogMessage.post();
         AH_UDC_REST_LogMessage.LogMessageResponse resp =
         (AH_UDC_REST_LogMessage.LogMessageResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_LogMessage.LogMessageResponse.class);
         Test.stopTest();
         System.assertEquals('500', resp.statusCode, 'Expected 500 Response');
      }

   }

   @isTest
   private static void TestPost_LogFailure() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE LastName = 'LM_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         String strReq = '';
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_REST_LogMesssage'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(strReq);
         RestContext.request = req;
         RestContext.response = res;
         AH_UDC_LogHelper.debug('TestPost_LogFailure - Call Post');
         Test.startTest();
         AH_UDC_REST_LogMessage.post();
         AH_UDC_REST_LogMessage.LogMessageResponse resp =
         (AH_UDC_REST_LogMessage.LogMessageResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_LogMessage.LogMessageResponse.class);
         Test.stopTest();
         System.assertEquals('500', resp.statusCode, 'Expected 500 Response');
         List<AH_UDC_Log__c> logMessages = [SELECT Id, Message__c FROM AH_UDC_Log__c];
         System.assert(logMessages.size() > 0, 'Log Messages exist and were not expected');
      }
   }
}