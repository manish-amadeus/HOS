/**
 * Name          : AH_UDC_REST_LogMessage
 * Created By    : Amadeus Hospitality Services (vaishali.patel@Amadeus.com)
 * Created Date  : 2021-07-29
 * Description   : This class accepts a Log Response POST from the C# application
 * Dependencies  : 
 **/

@RestResource(urlMapping = '/AH_UDC_LogMessage')
global with sharing class AH_UDC_REST_LogMessage {

   public class AH_UDC_REST_LogMessageException extends Exception { }

   @HttpPost
   global static void post() {
      LogMessageResponse resp = new LogMessageResponse();
      RestRequest req = RestContext.request;
      String requestBody = '';
      try {
         if (req != null && req.requestBody != null) { requestBody = req.requestBody.toString(); }
         LogMessage LogMessage = (LogMessage) JSON.deserialize(requestBody, LogMessage.class);
         AH_UDC_REST_LogMessageException exc = null;
         if (String.isNotBlank(LogMessage.e)) exc = new AH_UDC_REST_LogMessageException(LogMessage.e);
         AH_UDC_log__c log = AH_UDC_LogHelper.Log(LogMessage.logLevel, LogMessage.functionalArea, LogMessage.sourceMethod, LogMessage.details, exc, LogMessage.relatedRecordId, LogMessage.relatedRecordType);
         resp.statusCode = '200';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(exception e)
      {
         resp.statusCode = '500';
         try {
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                                 'AH_UDC_REST_LogMessage', 'post',
                                 'An exception occurred processing a request: Request Body: ' + requestBody,
                                 e, null, null);
         }
         catch(Exception exc) {
            //If logs can't be written at least show an error in debug
            System.Debug('###AH_UDC_REST_LogMessage.Post - Failed to write Logs' + exc.getMessage());
         }
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
   }


   @TestVisible
   private class LogMessage {
      public String logLevel;
      public String functionalArea;
      public String sourceMethod;
      public String details;
      public String e;
      public String relatedRecordId;
      public String relatedRecordType;
   }

   @TestVisible
   private class LogMessageResponse {
      public String statusCode;
      //public String logStatusMessage;
      public LogMessageResponse() {
      }

      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this);
      }
   }
}