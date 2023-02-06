/**
 * Name          : AH_UDC_REST_Chatter
 * Created By    : Amadeus Hospitality Services (vaishali.patel@Amadeus.com)
 * Created Date  : 2022-07-26
 * Description   : This class accepts an NI Doc ID and Message for creating a chatter post
 * Dependencies  : 
 **/

 @RestResource(urlMapping = '/AH_UDC_Chatter')
global with sharing class AH_UDC_REST_Chatter {

   public class ChatterRequest{
      public string NIDocumentId {get;set;}
      public string Message{get;Set;}
   }

   public class ChatterResponse {
      public String statusCode {get;set;}
      public String Message {get;set;}
      public ChatterResponse() {
      }
      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this);
      }
   }

   @HttpPost
   global static void post() {
      ChatterResponse resp = new ChatterResponse();
      RestRequest req = RestContext.request;
      String requestBody = '';
      try {
         if (req != null && req.requestBody != null) { requestBody = req.requestBody.toString(); }
         ChatterRequest chatterRequest = (ChatterRequest) JSON.deserialize(requestBody, ChatterRequest.class);

         if(Test.isRunningTest() && chatterRequest.Message == 'Exception1') Integer i = 1/0;

         //Adding a Text post
         FeedItem post = new FeedItem();
         post.ParentId = chatterRequest.NIDocumentId;
         post.Body = chatterRequest.Message;
         AH_UDC_SystemContext.CreateObject(post);
         resp.statusCode = '200';
         resp.Message = 'Posted';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(exception exc)
      {
         resp.statusCode = '500';
         resp.Message = 'Error';
         AH_UDC_LogHelper.Debug('AH_UDC_REST_Chatter: Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                           'AH_UDC_REST_Chatter', 'CreateChatter',
                           'Unhandled Exception: ' + exc.getMessage() + '; Raw Request: ' + requestBody,
                           exc, null, null);
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
   }
}