/**
 * Name          : AH_UDC_REST_Chatter_TEST
 * Created By    : Amadeus Hospitality Services (vaishali.patel@Amadeus.com)
 * Created Date  : 2022-07-26
 * Description   : This class is the test class for AH_UDC_REST_Chatter
 * Dependencies  : AH_UDC_REST_Chatter
 **/
@isTest
public class AH_UDC_REST_Chatter_TEST {

   @TestSetup private static void setup() {

      List<User> listUsers = new List<User> ();
      //Build UDC Service User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE,
                                              'LM_ServiceUser1', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE, listUsers[0].Id);
      }

      NI_Documentation__c oNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
      insert oNIDoc;
   }

   @isTest
   private static void TestChatterPost() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE LastName = 'LM_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         List<NI_Documentation__c> niDocs = [select id from NI_Documentation__c];
         String strReq = '{"NIDocumentId":"' + niDocs[0].id + '","Message":"Test"}';
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_REST_Chatter'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(strReq);
         RestContext.request = req;
         RestContext.response = res;
         AH_UDC_LogHelper.debug('TestPost_LogWarning - Call Post');
         Test.startTest();
         AH_UDC_REST_Chatter.post();
         AH_UDC_REST_Chatter.ChatterResponse resp = (AH_UDC_REST_Chatter.ChatterResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_Chatter.ChatterResponse.class);
         Test.stopTest();
         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');
      }
   }

   @isTest
   private static void TestChatterPostException() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM User WHERE LastName = 'LM_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         List<NI_Documentation__c> niDocs = [select id from NI_Documentation__c];
         String strReq = '{"NIDocumentId":"' + niDocs[0].id + '","Message":"Exception1"}';
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_REST_Chatter'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof(strReq);
         RestContext.request = req;
         RestContext.response = res;
         AH_UDC_LogHelper.debug('TestPost_LogWarning - Call Post');
         Test.startTest();
         AH_UDC_REST_Chatter.post();
         AH_UDC_REST_Chatter.ChatterResponse resp = (AH_UDC_REST_Chatter.ChatterResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_Chatter.ChatterResponse.class);
         Test.stopTest();
         System.assertEquals('500', resp.statusCode, 'Expected 500 Response');
      }
   }
}