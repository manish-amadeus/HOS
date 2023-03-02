<<<<<<< HEAD
<<<<<<< HEAD
/**
 * Name          : AH_UDC_REST_SetCommunityUserProfile
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2020-11-23
 * Description   : This class sets the profile for a community user based on whether they should have Chatter access or not
 * Dependencies  : 
 **/

@RestResource(urlMapping = '/AH_UDC_SetCommunityUserProfile')
global with sharing class AH_UDC_REST_SetCommunityUserProfile {
   @HttpGet
   global static void get() {
      AH_UDC_LogHelper.QueueLogs = true;

      AH_UDC_LogHelper.Debug('AH_UDC_REST_SetCommunityUserProfile');
      SetCommunityUserProfileResponse resp = new SetCommunityUserProfileResponse();

      try {
         String UserId = RestContext.request.params.get('userid');
         AH_UDC_LogHelper.Debug('UserId: ' + UserId);
         if (Test.isRunningTest() && UserId == 'Exception1') integer i=1/0;

         Boolean chatterEnabled = RestContext.request.params.get('chatter').toUpperCase() == 'TRUE';
         AH_UDC_LogHelper.Debug('chatterEnabled: ' + chatterEnabled);

         List<User> targetUsers = [SELECT Id, ProfileId, Profile.Name FROM user WHERE Id = :UserId];
         AH_UDC_LogHelper.Debug('targetUsers.size: ' + targetUsers.size());
         if (targetUsers.size() ==0) {
            //Set the Return code
            resp.statusCode = '400';
            resp.message = 'Bad Request';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         Profile oProfile = null;

         // Retrieve the appropriate Profile based on whether Chatter is enabled or not
         if (chatterEnabled) {
            oProfile = [SELECT Id
                        FROM Profile
                        WHERE name = :AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER,
                                                                    AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER)];

         } else {
            oProfile = [SELECT Id
                        FROM Profile
                        WHERE name = :AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER,
                                                                    AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER)];
         }

         //Update user to profile
         targetUsers[0].ProfileId = oProfile.Id;
         AH_UDC_Security.UpdateObject(targetUsers[0]);
         AH_UDC_LogHelper.Debug('AH_UDC_REST_SetCommunityUserProfile: Updated User');

         //Set the Return code
         resp.statusCode = '200';
         resp.message = 'Updated';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e) {
         AH_UDC_LogHelper.Debug('AH_UDC_REST_SetCommunityUserProfile: Exception: ' + e);
         // Because this method is updating SETUP Sobjects (user's profile) we can't call AH_UDC_LogHelper.Log()
         // or it will result in a mixed DML oprations error.  Calling program will need to log the exception

         resp.statusCode = '500';
         resp.message = 'Exception Occurred: ' + e.getMessage();
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      finally {
         try {
            AH_UDC_LogHelper.writeQueuedLogs();
         }
         catch(Exception exc) {
            //If logs can't be written at least show an error in debug
            AH_UDC_LogHelper.Debug('AH_UDC_REST_SetcommunityUserProfile.Get - Failed to write QueuedLogs');
         }
      }
   }

   @TestVisible
   public class SetCommunityUserProfileResponse {
      public String statusCode;
      public String message;
      public String exceptionMessage;

      public SetCommunityUserProfileResponse() {
      }

      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this);
      }
   }
=======
/**
 * Name          : AH_UDC_REST_SetCommunityUserProfile
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2020-11-23
 * Description   : This class sets the profile for a community user based on whether they should have Chatter access or not
 * Dependencies  : 
 **/

@RestResource(urlMapping = '/AH_UDC_SetCommunityUserProfile')
global with sharing class AH_UDC_REST_SetCommunityUserProfile {
   @HttpGet
   global static void get() {
      AH_UDC_LogHelper.QueueLogs = true;

      AH_UDC_LogHelper.Debug('AH_UDC_REST_SetCommunityUserProfile');
      SetCommunityUserProfileResponse resp = new SetCommunityUserProfileResponse();

      try {
         String UserId = RestContext.request.params.get('userid');
         AH_UDC_LogHelper.Debug('UserId: ' + UserId);
         if (Test.isRunningTest() && UserId == 'Exception1') integer i=1/0;

         Boolean chatterEnabled = RestContext.request.params.get('chatter').toUpperCase() == 'TRUE';
         AH_UDC_LogHelper.Debug('chatterEnabled: ' + chatterEnabled);

         List<User> targetUsers = [SELECT Id, ProfileId, Profile.Name FROM user WHERE Id = :UserId];
         AH_UDC_LogHelper.Debug('targetUsers.size: ' + targetUsers.size());
         if (targetUsers.size() ==0) {
            //Set the Return code
            resp.statusCode = '400';
            resp.message = 'Bad Request';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         Profile oProfile = null;

         // Retrieve the appropriate Profile based on whether Chatter is enabled or not
         if (chatterEnabled) {
            oProfile = [SELECT Id
                        FROM Profile
                        WHERE name = :AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER,
                                                                    AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER)];

         } else {
            oProfile = [SELECT Id
                        FROM Profile
                        WHERE name = :AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER,
                                                                    AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER)];
         }

         //Update user to profile
         targetUsers[0].ProfileId = oProfile.Id;
         AH_UDC_Security.UpdateObject(targetUsers[0]);
         AH_UDC_LogHelper.Debug('AH_UDC_REST_SetCommunityUserProfile: Updated User');

         //Set the Return code
         resp.statusCode = '200';
         resp.message = 'Updated';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e) {
         AH_UDC_LogHelper.Debug('AH_UDC_REST_SetCommunityUserProfile: Exception: ' + e);
         // Because this method is updating SETUP Sobjects (user's profile) we can't call AH_UDC_LogHelper.Log()
         // or it will result in a mixed DML oprations error.  Calling program will need to log the exception

         resp.statusCode = '500';
         resp.message = 'Exception Occurred: ' + e.getMessage();
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      finally {
         try {
            AH_UDC_LogHelper.writeQueuedLogs();
         }
         catch(Exception exc) {
            //If logs can't be written at least show an error in debug
            AH_UDC_LogHelper.Debug('AH_UDC_REST_SetcommunityUserProfile.Get - Failed to write QueuedLogs');
         }
      }
   }

   @TestVisible
   public class SetCommunityUserProfileResponse {
      public String statusCode;
      public String message;
      public String exceptionMessage;

      public SetCommunityUserProfileResponse() {
      }

      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this);
      }
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
/**
 * Name          : AH_UDC_REST_SetCommunityUserProfile
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2020-11-23
 * Description   : This class sets the profile for a community user based on whether they should have Chatter access or not
 * Dependencies  : 
 **/

@RestResource(urlMapping = '/AH_UDC_SetCommunityUserProfile')
global with sharing class AH_UDC_REST_SetCommunityUserProfile {
   @HttpGet
   global static void get() {
      AH_UDC_LogHelper.QueueLogs = true;

      AH_UDC_LogHelper.Debug('AH_UDC_REST_SetCommunityUserProfile');
      SetCommunityUserProfileResponse resp = new SetCommunityUserProfileResponse();

      try {
         String UserId = RestContext.request.params.get('userid');
         AH_UDC_LogHelper.Debug('UserId: ' + UserId);
         if (Test.isRunningTest() && UserId == 'Exception1') integer i=1/0;

         Boolean chatterEnabled = RestContext.request.params.get('chatter').toUpperCase() == 'TRUE';
         AH_UDC_LogHelper.Debug('chatterEnabled: ' + chatterEnabled);

         List<User> targetUsers = [SELECT Id, ProfileId, Profile.Name FROM user WHERE Id = :UserId];
         AH_UDC_LogHelper.Debug('targetUsers.size: ' + targetUsers.size());
         if (targetUsers.size() ==0) {
            //Set the Return code
            resp.statusCode = '400';
            resp.message = 'Bad Request';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         Profile oProfile = null;

         // Retrieve the appropriate Profile based on whether Chatter is enabled or not
         if (chatterEnabled) {
            oProfile = [SELECT Id
                        FROM Profile
                        WHERE name = :AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER,
                                                                    AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER)];

         } else {
            oProfile = [SELECT Id
                        FROM Profile
                        WHERE name = :AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER,
                                                                    AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER)];
         }

         //Update user to profile
         targetUsers[0].ProfileId = oProfile.Id;
         AH_UDC_Security.UpdateObject(targetUsers[0]);
         AH_UDC_LogHelper.Debug('AH_UDC_REST_SetCommunityUserProfile: Updated User');

         //Set the Return code
         resp.statusCode = '200';
         resp.message = 'Updated';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e) {
         AH_UDC_LogHelper.Debug('AH_UDC_REST_SetCommunityUserProfile: Exception: ' + e);
         // Because this method is updating SETUP Sobjects (user's profile) we can't call AH_UDC_LogHelper.Log()
         // or it will result in a mixed DML oprations error.  Calling program will need to log the exception

         resp.statusCode = '500';
         resp.message = 'Exception Occurred: ' + e.getMessage();
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      finally {
         try {
            AH_UDC_LogHelper.writeQueuedLogs();
         }
         catch(Exception exc) {
            //If logs can't be written at least show an error in debug
            AH_UDC_LogHelper.Debug('AH_UDC_REST_SetcommunityUserProfile.Get - Failed to write QueuedLogs');
         }
      }
   }

   @TestVisible
   public class SetCommunityUserProfileResponse {
      public String statusCode;
      public String message;
      public String exceptionMessage;

      public SetCommunityUserProfileResponse() {
      }

      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this);
      }
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}