/***********************************************************************************************
  Name            : AH_UDC_CreateCommunityUser_TEST
  Author          : Rob Stevens
  Created Date    : 2022-09-18
  Description     : Test class for AH_UDC_CreateCommunityUser
 ************************************************************************************************/
@isTest
private class AH_UDC_REST_CreateCommunityUser_TEST {
   private static final string SERVICE_USER = 'CCU_ServiceUser1';

   @TestSetup 
   private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      
      List<User> listUsers = new List<User> ();
      //Build UDC Service User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE,
                                              SERVICE_USER, null, false));
      insert listUsers;

      String uniqueId = 'CreateCommunityUser1';

      Account newAccount = AH_UDC_TestData.GetAccountObject(uniqueId);
      insert newAccount;

      Contact newContact = AH_UDC_TestData.GetContactObject(newAccount.id, uniqueId);
      insert newContact;
   }

   @isTest
   private static void TestCreateCommunityUser() {
      List<User> SUsers = [SELECT Id,name FROM User WHERE Username = :('Test' + SERVICE_USER + '@amadeus.com')];

      //Get User Profile
      Profile oProfile = [SELECT Id FROM Profile WHERE Name = :AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER,
                                                                                                AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER)];
      Contact oContact = [select id from contact where LastName=:'CreateCommunityUser1'];

      System.runAs(SUsers[0])
      {
         Test.startTest();

         RestRequest reqCCU = new RestRequest();
         RestResponse resCCU = new RestResponse();
         reqCCU.requestURI = '/services/apexrest/AH_UDC_REST_CreateCommunityUser'; //Request URL
         reqCCU.httpMethod = 'POST'; //HTTP Request Type
         AH_UDC_REST_CreateCommunityUser.CreateCommunityUserRequest ccuRequest = new AH_UDC_REST_CreateCommunityUser.CreateCommunityUserRequest();
         ccuRequest.FirstName='NewContactFN';
         ccuRequest.lastName='NewContactLN';
         ccuRequest.ContactId=oContact.id;
         ccuRequest.Username='NewContact@TEST.ahcc';
         ccuRequest.Email='Test@Amadeus.com';
         ccuRequest.CommunityNickname='TEST';
         ccuRequest.Alias='TEST';
         ccuRequest.TimeZoneSidKey='America/New_York';
         ccuRequest.LocaleSidKey='en_US';
         ccuRequest.EmailEncodingKey='ISO-8859-1';
         ccuRequest.LanguageLocaleKey='en_US';
         ccuRequest.ProfileId=oProfile.id;
         reqCCU.requestBody = Blob.valueof(JSON.serialize(ccuRequest));
         RestContext.request = reqCCU;
         RestContext.response = resCCU;

         AH_UDC_REST_CreateCommunityUser.post();
      }
   }
}