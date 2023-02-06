/**
 * Name          : AH_UDC_REST_SetCommunityUserProfile_TEST
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-07-04
 * Description   : This is a test class for AH_UDC_REST_SetCommunityUserProfile
 * Dependencies  : AH_UDC_REST_SetCommunityUserProfile
 **/

@isTest
public class AH_UDC_REST_SetCommunityUserProfile_TEST {

   private static final string SCUP_USER_NO_CHATTER = 'SCUPCUserNoChatter';
   private static final string SCUP_USER_WITH_CHATTER = 'SCUPCUserChatter';

   @testSetup
   static void setup() {
      String uniqueId = AH_UDC_Shared.generateGUID();
      Account newAccount = AH_UDC_TestData.GetAccountObject(uniqueId);
      insert newAccount;

      List<Contact> listContacts = new List<Contact> ();
      listContacts.add(AH_UDC_TestData.GetContactObject(newAccount.id, AH_UDC_Shared.generateGUID()));
      listContacts.add(AH_UDC_TestData.GetContactObject(newAccount.id, AH_UDC_Shared.generateGUID()));
      insert listContacts;

      List<User> listUsers = new List<User> ();
      //Build Community User with chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                              SCUP_USER_NO_CHATTER, listContacts[0].Id, true));
      //Build Community User with chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                              SCUP_USER_WITH_CHATTER, listContacts[1].Id, true));
      //Build UDC Service User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_AH_UDC_SERVICE,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE,
                                              'SetCommUserProfileServiceUser', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         // Community Users
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE, listUsers[2].Id);
      }
   }

   @isTest
   private static void TestGet_Chatter() {
      AH_UDC_ConfigHelper.SetValue(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER, AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER);
      AH_UDC_ConfigHelper.SetValue(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER, AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER);
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'SetCommUserProfileServiceUser'];
      System.runAs(UDCServiceUser1)
      {
         User SUser1 = [SELECT Id FROM User WHERE Username = :('Test' + SCUP_USER_NO_CHATTER + '@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
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
   }

   @isTest
   private static void TestGet_NoChatter() {
      AH_UDC_ConfigHelper.SetValue(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER, AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER);
      AH_UDC_ConfigHelper.SetValue(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER, AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER);
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'SetCommUserProfileServiceUser'];
      System.runAs(UDCServiceUser1)
      {
         User SUser1 = [SELECT Id FROM User WHERE Username = :('Test' + SCUP_USER_WITH_CHATTER + '@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
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

         System.assertEquals('200', resp.statusCode, 'Did not receive the expected response code');

         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestGet_InvalidUserId() {
      AH_UDC_ConfigHelper.SetValue(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER, AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER);
      AH_UDC_ConfigHelper.SetValue(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER, AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER);
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'SetCommUserProfileServiceUser'];
      System.runAs(UDCServiceUser1)
      {
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

         System.assertEquals('400', resp.statusCode, 'Did not receive the expected response code');
         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestGet_Exception() {
      AH_UDC_ConfigHelper.SetValue(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER, AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER);
      AH_UDC_ConfigHelper.SetValue(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER, AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER);
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'SetCommUserProfileServiceUser'];
      AH_UDC_TestData.ClearLogs();
      System.runAs(UDCServiceUser1)
      {
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

         System.assertEquals('500', resp.statusCode, 'Did not receive the expected response code');
         List<AH_UDC_Log__c> logMessages = [select id, Message__c from AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }
}