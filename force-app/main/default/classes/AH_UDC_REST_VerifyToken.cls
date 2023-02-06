/**
 * Name          : AH_UDC_REST_VerifyToken
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2020-11-23
 * Description   : This class can be used to verify a token is valid and return information about the workbook/step
 * Dependencies  : 
 **/

@RestResource(urlMapping = '/AH_UDC_VerifyToken')
global with sharing class AH_UDC_REST_VerifyToken {
   
   @HttpGet
   global static void get() {
      AH_UDC_LogHelper.QueueLogs = true;
      VerifyTokenGetResponse resp = new VerifyTokenGetResponse();
      RestRequest req = RestContext.request;
      try {
         String token = RestContext.request.params.get('token');
         if (!token.startsWith(AH_UDC_Constants.FORM_TOKEN_PREFIX)) {
            resp.statusCode = '400';
            resp.statusMessage = 'Bad Request';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }
         token = token.substring(AH_UDC_Constants.FORM_TOKEN_PREFIX.length());
         AH_UDC_LogHelper.Debug('###Token: ' + token);
         if (Test.isRunningTest() && token == 'TestException') integer i = 1 / 0;
      
         if (String.isBlank(token)) {
            resp.statusCode = '400';
            resp.statusMessage = 'Bad Request';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }
         //Decrypt token
         AH_UDC_Shared.Token decryptedToken = AH_UDC_Shared.DecryptToken(token);
  
         if (!decryptedToken.IsValid) {
            resp.statusCode = '400';
            resp.statusMessage = 'Token Not Valid';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         //Check that SecurityCode And FormId are for a valid step
         List<AH_UDC_WorkbookStep__c> stepsSent = [select Id, Name,
                                                   Workbook__c, 
                                                   Workbook__r.SentStatus__c,
                                                   Workbook__r.RelatedTo__r.id,
                                                   Workbook__r.RelatedTo__r.Document_Name__c,
                                                   Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c,
                                                   Form__c, Form__r.RecordType.DeveloperName 
                                                   from AH_UDC_WorkbookStep__c
                                                   where Workbook__r.SecurityCode__c = :decryptedToken.SecurityCode
                                                   and Enabled__c = true
                                                   order by SortOrder__c];
         boolean FoundTokenForm = decryptedToken.FormId == null || String.isEmpty(decryptedToken.FormId);
         //Add step ids to response
         for(AH_UDC_WorkbookStep__c step : stepsSent)
         {
            Step addStep = new Step(step.id, step.name, null);
            if (step.Form__c != null) addStep.FormType = step.Form__r.RecordType.DeveloperName;
            resp.steps.add(addStep);
            if (String.isNotEmpty(decryptedToken.FormId) && step.Form__c!=null && step.Form__c == decryptedToken.FormId) FoundTokenForm = true;
         }
         
         if (stepsSent == null || stepsSent.size() == 0 || !FoundTokenForm) {
            resp.statusCode = '404';
            resp.statusMessage = 'Not Found';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }
         
         //Get configuration settings for File Upload
         resp.allowedFileUploadExtensions = AH_UDC_ConfigHelper.GetString('AH_UDC_FileUploadAllowedExtensions','');
         resp.maximumFileUploadSizeInMB = AH_UDC_ConfigHelper.GetString('AH_UDC_FileUploadMaximumSizeInMB',AH_UDC_Constants.FILE_UPLOAD_MAXIMUM_SIZE_IN_MB_DEFAULT);

         resp.statusCode = '200';
         resp.statusMessage = 'Ok';

         resp.WorkbookId = stepsSent[0].Workbook__c;
         resp.workbookStatus = stepsSent[0].Workbook__r.SentStatus__c;
         resp.DocumentId = stepsSent[0].Workbook__r.RelatedTo__r.Id;
         resp.documentName = stepsSent[0].Workbook__r.RelatedTo__r.Document_Name__c;
         resp.StepId = decryptedToken.StepId;
         resp.PropertyAccountId = stepsSent[0].Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c;

         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e) {
         AH_UDC_LogHelper.Debug('###Exception: ' + e);

         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_REST_VerifyToken', 'get',
                              'An exception occurred verifying a token: ' + e.getMessage() + ' | ' + e.getStackTraceString(),
                              e, null, null);

         //Set the Return code
         resp.statusCode = '500';
         resp.statusMessage = 'Exception Occurred';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      finally {
         try {
            AH_UDC_LogHelper.writeQueuedLogs();
         }
         catch(Exception exc) {
            //If logs can't be written at least show an error in debug
            AH_UDC_LogHelper.Debug('AH_UDC_REST_VerifyToken.Get - Failed to write QueuedLogs');
         }
      }
   }
   
   @TestVisible
   private class VerifyTokenGetResponse {
      public String statusCode;
      public String statusMessage;
      public String workbookId;
      public String documentId;
      public String stepId;
      public String documentName;
      public String workbookStatus;
      public String propertyAccountId;

      public String allowedFileUploadExtensions;
      public String maximumFileUploadSizeInMB;

      public List<Step> steps;

      public VerifyTokenGetResponse() {
         steps = new List<Step>();
      }

      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this);
      }
   }

   private class Step {
      public String Id;
      public String Name;
      public String FormType;

      public Step(string stepId, string stepName, string formType) {
         this.Id = stepId;
         this.name = stepName;
         this.FormType = formType;
      }
   }

}