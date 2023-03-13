/**
 * Name          : AH_UDC_REST_CreateCommunityUser
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2020-11-23
 * Description   : This class creates a community user
 * Dependencies  : 
 **/

@RestResource(urlMapping = '/AH_UDC_CreateCommunityUser')
global without sharing class AH_UDC_REST_CreateCommunityUser {
   @HttpPost
   global static void post() {
      AH_UDC_LogHelper.QueueLogs = true;

      AH_UDC_LogHelper.Debug('AH_UDC_REST_CreateCommunityUser');
      CreateCommunityUserResponse resp = new CreateCommunityUserResponse();
      RestRequest req = RestContext.request;
      String requestBody = '';
      if (req != null && req.requestBody != null) requestBody = req.requestBody.toString();

      try {
         CreateCommunityUserRequest ccuRequest = (CreateCommunityUserRequest) JSON.deserialize(requestBody, CreateCommunityUserRequest.class);
         if (Test.isRunningTest() && ccuRequest.FirstName == 'Exception1') integer i = 1 / 0;
         resp.userId = ccuRequest.ExistingUserId;
         if (String.isEmpty(ccuRequest.ExistingUserId)) {
            //Create User
            User newCommunityUser = new User();
            newCommunityUser.FirstName = ccuRequest.FirstName;
            newCommunityUser.LastName = ccuRequest.LastName;
            newCommunityUser.ContactId = ccuRequest.ContactId;
            newCommunityUser.Username = ccuRequest.UserName; //Max Length 80
            newCommunityUser.Email = ccuRequest.Email;
            newCommunityUser.CommunityNickname = ccuRequest.CommunityNickname; //Max Length 40
            newCommunityUser.Alias = ccuRequest.Alias;
            newCommunityUser.TimeZoneSidKey = ccuRequest.TimeZoneSidKey;
            newCommunityUser.LocaleSidKey = ccuRequest.LocaleSidKey;
            newCommunityUser.EmailEncodingKey = ccuRequest.EmailEncodingKey;
            newCommunityUser.LanguageLocaleKey = ccuRequest.LanguageLocaleKey;
            newCommunityUser.ProfileId = ccuRequest.ProfileId; //This line requires the class be "Without Sharing"

            //AH_UDC_TestData.InsertWithRetries();
            insert new List<User> { newCommunityUser };

            resp.userId = newCommunityUser.Id;
         }
         AH_UDC_SharedWithoutSharing.GrantUserPermissionSet(resp.userId, AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetCommunityUser', ''));

         //Set the Return code
         resp.statusCode = '200';
         resp.message = 'Created';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e) {
         AH_UDC_LogHelper.Debug('AH_UDC_REST_CreateCommunityUser: Exception: ' + e);
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
            AH_UDC_LogHelper.Debug('AH_UDC_REST_CreateCommunityUser.POST - Failed to write QueuedLogs');
         }
      }
   }

   @TestVisible
   public class CreateCommunityUserResponse {
      public String statusCode { get; set; }
      public String message { get; set; }
      public String exceptionMessage { get; set; }
      public String userId { get; set; }

      public CreateCommunityUserResponse() {
      }

      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this);
      }
   }

   @TestVisible
   public class CreateCommunityUserRequest {
      public String ExistingUserId { get; set; }
      public String FirstName { get; set; }
      public String lastName { get; set; }
      public String ContactId { get; set; }
      public String Username { get; set; }
      public String Email { get; set; }
      public String CommunityNickname { get; set; }
      public String Alias { get; set; }
      public String TimeZoneSidKey { get; set; }
      public String LocaleSidKey { get; set; }
      public String EmailEncodingKey { get; set; }
      public String LanguageLocaleKey { get; set; }
      public String ProfileId { get; set; }

      public CreateCommunityUserRequest() {
      }
   }
}