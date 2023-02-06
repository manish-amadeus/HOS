/*
 * Name:          : MockResponseGenerator
 * Created By     : George Tasker (george.tasker@amadeus.com)
 * Created Date   : 2021-May-10
 * Description:   : Used to create a mock HTTPResponse or a mock Web Service response to be used by 
 *                  test methods to simulate callouts
 * Dependencies   : 
 * Test Class     : Each mock response is specific to other test classes, so all of them will be tested
 *                  via those test classes
 */
@isTest
public class AH_UDC_MockResponseGenerator implements HttpCalloutMock /*, WebServiceMock */ {

   public class AH_UDC_MockResponseGeneratorException extends Exception { }

   public enum ResponseType {
      Unknown,
      SetCommunityUserProfile,
      CreateCommunityUser,
      Chatter
   }

   private Integer StatusCode { get; set; }
   private ResponseType ResponseType { get; set; }

   // Constructor
   public AH_UDC_MockResponseGenerator(ResponseType rt, Integer desiredStatus) {
      StatusCode = desiredStatus;
      ResponseType = rt;
   }

   // Implement HttpCalloutMock interface method
   public HTTPResponse respond(HTTPRequest req) {
      AH_UDC_LogHelper.Debug('Mock Endpoint: ' + req.getEndpoint());
      AH_UDC_LogHelper.Debug('Mock GetMethod: ' + req.getMethod());
      AH_UDC_LogHelper.Debug('Mock ResponseType: ' + ResponseType);

      // Create a fake response
      switch on ResponseType {
         when SetCommunityUserProfile { return SetCommunityUserProfile(StatusCode); }
         when CreateCommunityUser { return CreateCommunityUser(StatusCode); }
         when Chatter { return Chatter(StatusCode); }
         when else {
            throw new AH_UDC_MockResponseGeneratorException('AH_UDC_MockResponseGenerator is missing code to generate a mock HTTP Response for ResponseType: ' + ResponseType);
         }
      }
   }
/* Not used in UDC currectly, but code is kept here so it matches Central Sales, in case this is ever needed
   // Implement WebServiceMock interface method
   public void doInvoke(Object stub,
                        Object request,
                        Map<String, Object> response,
                        String endpoint,
                        String soapAction,
                        String requestName,
                        String responseNS,
                        String responseName,
                        String responseTypeString) {

      AH_UDC_LogHelper.Debug('Mock Endpoint: ' + endpoint);
      AH_UDC_LogHelper.Debug('Mock SoapAction: ' + soapAction);
      AH_UDC_LogHelper.Debug('Mock ResponseTypeString: ' + responseTypeString);

      // Create a fake response
      switch on ResponseType {
         //when MBService_SUCCESS { example_SUCCESS(stub, request, response, endpoint, soapAction, requestName, responseNS, responseName, responseTypeString); }
         //when MBService_FAIL { example_FAIL(stub, request, response, endpoint, soapAction, requestName, responseNS, responseName, responseTypeString); }
         when else {
            throw new MockResponseException('MockResponseGenerator is missing code to generate a mock Web Response for ResponseType: ' + ResponseType);
         }
      }
   }
*/
   // ---------------- HTTP CALLOUT RESPONSES --------------------------------------------------------------------

    // Create a simulated response for a callout that returns a XXX
   private HTTPResponse CreateCommunityUser(Integer desiredStatus) {
      // Build a RESPONSE instance in the form the web service would have returned
      AH_UDC_REST_CreateCommunityUser.CreateCommunityUserResponse response = new AH_UDC_REST_CreateCommunityUser.CreateCommunityUserResponse();
      response.statusCode = String.valueOf(desiredStatus);
      switch on desiredStatus {
         when 200 { response.message = 'Updated'; }
         when 400 { response.message = 'Bad Request'; }
         when 500 { response.message = 'Exception Occurred: Mock Response forced an exception'; }
         when else { response.message = ''; }
      }

      // Encode the response into an HttpResponse that looks exactly like it would coming back from a real callout
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(JSON.serialize(response));
      res.setStatusCode(desiredStatus);
      return res;
   }

   // Create a simulated response for a callout that returns a XXX
   private HTTPResponse SetCommunityUserProfile(Integer desiredStatus) {
      // Build a RESPONSE instance in the form the web service would have returned
      AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse response;
      response = new AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse();
      response.statusCode = String.valueOf(desiredStatus);
      switch on desiredStatus {
         when 200 { response.message = 'Updated'; }
         when 400 { response.message = 'Bad Request'; }
         when 500 { response.message = 'Exception Occurred: Mock Response forced an exception'; }
         when else { response.message = ''; }
      }

      // Encode the response into an HttpResponse that looks exactly like it would coming back from a real callout
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(JSON.serialize(response));
      res.setStatusCode(desiredStatus);
      return res;
   }

   // Create a simulated response for a callout that returns a XXX
   private HTTPResponse Chatter(Integer desiredStatus) {
      // Build a RESPONSE instance in the form the web service would have returned
      AH_UDC_REST_Chatter.ChatterResponse response = new AH_UDC_REST_Chatter.ChatterResponse();
      response.statusCode = String.valueOf(desiredStatus);
      switch on desiredStatus {
         when 200 { response.message = 'Posted'; }
         when 500 { response.message = 'Error'; }
         when else { response.message = ''; }
      }

      // Encode the response into an HttpResponse that looks exactly like it would coming back from a real callout
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(JSON.serialize(response));
      res.setStatusCode(desiredStatus);
      return res;
   }

   // ---------------- Helper Functions  --------------------------------------------------------------------

}