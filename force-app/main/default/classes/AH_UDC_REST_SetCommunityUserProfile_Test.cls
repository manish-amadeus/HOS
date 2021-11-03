/**
 * Name          : AH_UDC_REST_WorkbookSentExportTest
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-07-04
 * Description   : This is a test class for AH_UDC_REST_SetCommunityUserProfile
 * Dependencies  : AH_UDC_REST_SetCommunityUserProfile
 **/

@isTest
public class AH_UDC_REST_SetCommunityUserProfile_Test  {
   @testSetup 
   static void setup() {
      AH_UDC_TestData.CreateUDCCommunityUser('CUserNoChatter', false);
      AH_UDC_TestData.CreateUDCCommunityUser('CUserChatter', false);
   }

   @isTest
   private static void TestGet_Chatter() {
      AH_UDC_ConfigHelper.SetValue(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER,AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER);
      AH_UDC_ConfigHelper.SetValue(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER,AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER);

      User SUser1 = [Select id from User where LastName='CUserNoChatter']; //Use the user without chatter
      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      reqG.requestURI = '/services/apexrest/AH_UDC_REST_SetCommunityUserProfile'; //Request URL
      reqG.params.put('userid', SUser1.id);
      reqG.params.put('chatter', 'TRUE');
      reqG.httpMethod = 'GET'; //HTTP Request Type
      RestContext.request = reqG;
      RestContext.response = resG;

      AH_UDC_REST_SetCommunityUserProfile.get();

      AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse resp =
      (AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse)
      JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse.class);

      Test.stopTest();

      System.assertEquals('200', resp.statusCode, 'Expected 200 Response: ' + resp.statusCode);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
   }

   @isTest
   private static void TestGet_NoChatter() {
      AH_UDC_ConfigHelper.SetValue(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER,AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER);
      AH_UDC_ConfigHelper.SetValue(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER,AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER);

      User SUser1 = [Select id from User where LastName='CUserChatter']; //Use the user with Chatter
      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      reqG.requestURI = '/services/apexrest/AH_UDC_REST_SetCommunityUserProfile'; //Request URL
      reqG.params.put('userid', SUser1.id);
      reqG.params.put('chatter', 'FALSE');
      reqG.httpMethod = 'GET'; //HTTP Request Type
      RestContext.request = reqG;
      RestContext.response = resG;

      AH_UDC_REST_SetCommunityUserProfile.get();

      AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse resp =
      (AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse)
      JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse.class);

      Test.stopTest();

      System.assertEquals('200', resp.statusCode, 'Expected 200 Response: ' + resp.statusCode);

      List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
   }

   @isTest
   private static void TestGet_InvalidUserId() {
      AH_UDC_ConfigHelper.SetValue(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER,AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER);
      AH_UDC_ConfigHelper.SetValue(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER,AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER);

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      reqG.requestURI = '/services/apexrest/AH_UDC_REST_SetCommunityUserProfile'; //Request URL
      reqG.params.put('userid', '0053g000000M3uHAAR');
      reqG.params.put('chatter', 'TRUE');
      reqG.httpMethod = 'GET'; //HTTP Request Type
      RestContext.request = reqG;
      RestContext.response = resG;

      AH_UDC_REST_SetCommunityUserProfile.get();

      AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse resp =
      (AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse)
      JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse.class);

      Test.stopTest();

      System.assertEquals('400', resp.statusCode, 'Expected 200 Response: ' + resp.statusCode);

      //List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      //System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
   }

   @isTest
   private static void TestGet_Exception() {
      AH_UDC_ConfigHelper.SetValue(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER,AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER);
      AH_UDC_ConfigHelper.SetValue(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER,AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER);

      Test.startTest();

      RestRequest reqG = new RestRequest();
      RestResponse resG = new RestResponse();
      reqG.requestURI = '/services/apexrest/AH_UDC_REST_SetCommunityUserProfile'; //Request URL
      reqG.params.put('userid', 'Exception1');
      reqG.params.put('chatter', 'TRUE');
      reqG.httpMethod = 'GET'; //HTTP Request Type
      RestContext.request = reqG;
      RestContext.response = resG;

      AH_UDC_REST_SetCommunityUserProfile.get();

      AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse resp =
      (AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse)
      JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse.class);

      Test.stopTest();

      System.assertEquals('500', resp.statusCode, 'Expected 200 Response: ' + resp.statusCode);

      //List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
      //System.assertEquals(1, logMessages.size(), 'Log Messages do not exist and were expected');
   }
}