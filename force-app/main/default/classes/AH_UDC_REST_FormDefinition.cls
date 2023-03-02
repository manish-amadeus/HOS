<<<<<<< HEAD
/**
 * Name          : AH_UDC_REST_FormDefinition
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2020-11-23
 * Description   : This class accepts a Form Response POST from the C# API
 * Dependencies  : 
 **/
  
@RestResource(urlMapping = '/AH_UDC_FormDefinition')
global with sharing class AH_UDC_REST_FormDefinition {

   @HttpPost
   global static void post() {
      AH_UDC_LogHelper.QueueLogs = true;

      AH_UDC_LogHelper.Debug('AH_UDC_FormDefinition - POST');
      FormDefinitionResponse resp = new FormDefinitionResponse();
      RestRequest req = RestContext.request;
      String requestBody = '';
      if (req != null && req.requestBody != null) requestBody = req.requestBody.toString();

      Savepoint objSavePoint = Database.setSavepoint();
      try {
         AH_UDC_LogHelper.Debug('requestBody: ' + requestBody);

         if (Test.isRunningTest() && requestBody == 'Exception1') Integer i = 1 / 0;

         FormDefinition formDefinition = (FormDefinition) JSON.deserialize(requestBody, FormDefinition.class);

         //Find the Form Requested
         List<AH_UDC_Form__c> forms = null;

         if (Schema.sObjectType.AH_UDC_Form__c.fields.Definition__c.isAccessible() &&
             Schema.sObjectType.AH_UDC_Form__c.fields.CustomUrlId__c.isAccessible()) {
            forms = [SELECT Id, Name, Definition__c, CustomUrlId__c, CreatedBy.Name
                                          FROM AH_UDC_Form__c
                                          WHERE FormAssemblyId__c = :formDefinition.FormAssemblyId];
            AH_UDC_LogHelper.Debug('AH_UDC_REST_FormDefinition.Post : forms: ' + forms);
         }

         if (forms == null || forms.size() == 0) {
            if (!Schema.sObjectType.AH_UDC_Form__c.isCreateable()) {
               resp.formStatusCode = '500';
               resp.formStatusMessage = 'Not OK : Form does not exist in Salesforce';
               resp.formDefinitionStatusCode = '500';
               resp.formDefinitionStatusMessage = 'The requested form was not found; and you do not have permission to create one.';
               RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
               return;
            }

            Id formAssemblyRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();

            AH_UDC_Form__c newForm = new AH_UDC_Form__c(
                                                        Name = formDefinition.title.left(80),
                                                        Definition__c = requestBody,
                                                        FormAssemblyId__c = formDefinition.FormAssemblyId,
                                                        RecordTypeId = formAssemblyRecordTypeId);
            if (formDefinition.CustomUrlId != null && formDefinition.FormAssemblyId != formDefinition.CustomUrlId) {
               newForm.CustomUrlId__c = formDefinition.CustomUrlId;
            }
            AH_UDC_SystemContext.CreateObject(newForm);

            resp.formStatusCode = '200';
            resp.formStatusMessage = 'OK; Created';
            resp.formUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + newForm.id;
            resp.formDefinition = newForm.Definition__c;
            resp.CustomUrlId = newForm.CustomUrlId__c;
            resp.formDefinitionStatusCode = '200';
            resp.formDefinitionStatusMessage = 'A new form was created; please refresh the page.';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         //Determine if form is in use in workbooks
         AggregateResult[] workbooks = null;
         if (Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Workbook__c.isAccessible() &&
             Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Form__c.isAccessible()) {
            workbooks = [SELECT Workbook__c
                                        FROM AH_UDC_WorkbookStep__c
                                        WHERE Workbook__r.recordtype.DeveloperName = :AH_UDC_Constants.RECORD_TYPE_WORKBOOK
                                        AND Workbook__r.enabled__c = true
                                        AND form__c = :forms[0].id
                                        GROUP BY Workbook__c];
            AH_UDC_LogHelper.Debug('workbooks: ' + workbooks.size());
         }

         //Determine if form is in use in workbooks sent
         AggregateResult[] workbooksSent = null;
         if (Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Workbook__c.isAccessible() &&
             Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Form__c.isAccessible()) {
            workbooksSent = [SELECT Workbook__c
                               FROM AH_UDC_WorkbookStep__c
                              WHERE Workbook__r.recordtype.DeveloperName = :AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT
                                AND Workbook__r.enabled__c = true
                                AND Workbook__r.CompletedDate__c = null
                                AND form__c = :forms[0].id
                              GROUP BY Workbook__c];
            AH_UDC_LogHelper.Debug('workbooksSent: ' + workbooksSent.size());
         }

         List<UserRecordAccess> recordAccess = null;
         if (Schema.sObjectType.UserRecordAccess.fields.RecordId.isAccessible() &&
             Schema.sObjectType.UserRecordAccess.fields.HasEditAccess.isAccessible()) {
            recordAccess = [SELECT RecordId, HasEditAccess
                              FROM UserRecordAccess
                             WHERE UserId = :UserInfo.getUserId()
                               AND RecordId = :forms[0].id];
            AH_UDC_LogHelper.Debug('recordAccess:' + recordAccess);
         }

         if (recordAccess == null || recordAccess.size() != 1 || !recordAccess[0].HasEditAccess) {
            resp.formStatusCode = '200';
            resp.formStatusMessage = 'OK; Workbooks (Enabled) = ' + workbooks.size() + '; Workbooks Sent (Not Completed) = ' + workbooksSent.size();
            resp.formUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + forms[0].id;
            resp.formDefinition = forms[0].Definition__c;
            resp.CustomUrlId = forms[0].CustomUrlId__c;
            resp.formDefinitionStatusCode = '500';
            resp.formDefinitionStatusMessage = 'You do not have access to update the form.';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         forms[0].Definition__c = requestBody;

         if (formDefinition.CustomUrlId != null && formDefinition.FormAssemblyId != formDefinition.CustomUrlId) {
            forms[0].CustomUrlId__c = formDefinition.CustomUrlId;
         }

         AH_UDC_SystemContext.UpdateObject(forms[0]);

         resp.formStatusCode = '200';
         resp.formStatusMessage = 'OK; Workbooks (Enabled) = ' + workbooks.size() + '; Workbooks Sent (Not Completed) = ' + workbooksSent.size();
         resp.formUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + forms[0].id;
         resp.formDefinition = forms[0].Definition__c;
         resp.CustomUrlId = forms[0].CustomUrlId__c;
         resp.formDefinitionStatusCode = '200';
         resp.formDefinitionStatusMessage = 'Definition Updated';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e) {
         AH_UDC_LogHelper.Debug('AH_UDC_REST_FormDefinition.post - Exception: ' + e);

         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_REST_FormDefinition', 'post',
                              'An exception occurred processing a response: Request Body: ' + requestBody,
                              e, null, null);

         //Set the Return code
         resp.formStatusCode = '500';
         resp.formStatusMessage = 'Exception Occurred';
         resp.formDefinitionStatusCode = '500';
         resp.formDefinitionStatusMessage = 'An Error occurred updating the definition';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      finally {
         try {
            if (Test.isRunningTest() && requestBody == 'ExceptionWriteQLogs') integer i = 1/0;
            AH_UDC_LogHelper.writeQueuedLogs();
         }
         catch(Exception exc) {
            //If logs can't be written at least show an error in debug
            AH_UDC_LogHelper.Debug('AH_UDC_REST_FormDefinition.Post - Failed to write QueuedLogs');
         }
      }
   }

   @HttpGet
   global static void get() {
      AH_UDC_LogHelper.QueueLogs = true;

      AH_UDC_LogHelper.Debug('FormDefinitionGetResponse');
      FormDefinitionResponse resp = new FormDefinitionResponse();
      RestRequest req = RestContext.request;
      String FormAssemblyFormId = null;
      Set<String> names = null;
      try {
         FormAssemblyFormId = RestContext.request.params.get('FormId');

         if (Test.isRunningTest() && FormAssemblyFormId == 'Exception1') Integer i = 1 / 0;

         if (String.isBlank(FormAssemblyFormId)) {
            resp.formStatusCode = '400';
            resp.formStatusMessage = 'Bad Request';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         if (Test.isRunningTest() && FormAssemblyFormId == 'TestException') integer i = 1 / 0;

         //Get the Questions/Answers
         List<AH_UDC_Form__c> forms = null;
         if (Schema.sObjectType.AH_UDC_Form__c.fields.Definition__c.isAccessible() &&
             Schema.sObjectType.AH_UDC_Form__c.fields.CustomUrlId__c.isAccessible()) {
            forms = [SELECT Id, Name, Definition__c, CustomUrlId__c
                       FROM AH_UDC_Form__c
                      WHERE FormAssemblyId__c = :FormAssemblyFormId];
            AH_UDC_LogHelper.Debug('forms: ' + forms.size());
         }

         ////No Form with that ID found
         if (forms == null || forms.size() == 0) {
            resp.formStatusCode = '200';
            resp.formStatusMessage = 'Not OK : Form does not exist in Salesforce';
            resp.formUrl = '';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         //Determine if form is in use in workbooks
         AggregateResult[] workbooks = null;
         if (Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Workbook__c.isAccessible() &&
             Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Form__c.isAccessible()) {
            workbooks = [SELECT Workbook__c
                           FROM AH_UDC_WorkbookStep__c
                          WHERE Workbook__r.recordtype.DeveloperName = :AH_UDC_Constants.RECORD_TYPE_WORKBOOK
                            AND Workbook__r.enabled__c = true
                            AND Form__c = :forms[0].id
                          GROUP BY Workbook__c];
            AH_UDC_LogHelper.Debug('workbooks: ' + workbooks.size());
         }

         //Determine if form is in use in workbooks sent
         AggregateResult[] workbooksSent = null;
         if (Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Workbook__c.isAccessible() &&
             Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Form__c.isAccessible()) {
            workbooksSent = [SELECT Workbook__c
                               FROM AH_UDC_WorkbookStep__c
                              WHERE Workbook__r.recordtype.DeveloperName = :AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT
                                AND Workbook__r.enabled__c = true
                                AND Workbook__r.CompletedDate__c = null
                                AND form__c = :forms[0].id
                              GROUP BY Workbook__c];
            AH_UDC_LogHelper.Debug('workbooksSent: ' + workbooksSent.size());
         }

         // Getting form access user name 
         List<AH_UDC_Form__Share> formShare = null;
         if (//Schema.sObjectType.AH_UDC_Form__Share.fields.UserOrGroup.isAccessible() &&
             Schema.sObjectType.AH_UDC_Form__Share.fields.AccessLevel.isAccessible()) {
            formShare = [SELECT UserOrGroup.Name, AccessLevel
                           FROM AH_UDC_Form__Share 
                          WHERE AccessLevel in ('All','Edit') 
                            AND ParentId =: forms[0].id];
         }

         if(formShare != null && formShare.size() > 0) {
            names = new Set<String>();
            for(AH_UDC_Form__Share fs: formShare) {
              if(fs.UserOrGroup != null) { names.add(String.valueOf(fs.UserOrGroup.get('Name'))); }
            }        
         }

         resp.formStatusCode = '200';
         resp.formStatusMessage = 'OK; Workbooks (Enabled) = ' + workbooks.size() + '; Workbooks Sent (Not Completed) = ' + workbooksSent.size();
         resp.formUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + forms[0].id;
         resp.formDefinition = forms[0].Definition__c;
         resp.formDefinitionStatusCode = '200';
         resp.formDefinitionStatusMessage = 'Ok';
         resp.CustomUrlId = forms[0].CustomUrlId__c;
         resp.formEditors = names == null ? '': String.join((Iterable<String>)names, System.Label.AH_UDC_SeparatedString); //Create comma separated string

         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e)
      {
         AH_UDC_LogHelper.Debug('AH_UDC_REST_FormDefinition.get - Exception: ' + e);

         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_REST_FormDefinition', 'get',
                              'An exception occurred processing a response: ' + e.getMessage(),
                              e, null, null);

         //Set the Return code
         resp.formStatusCode = '500';
         resp.formStatusMessage = 'Exception Occurred';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      finally {
         try {
            if (Test.isRunningTest() && FormAssemblyFormId == 'ExceptionWriteQLogs') { integer i = 1/0; }
            AH_UDC_LogHelper.writeQueuedLogs();
         }
         catch(Exception exc) {
            //If logs can't be written, at least show an error in debug
            System.Debug('AH_UDC_REST_FormDefinition.Get - Failed to write QueuedLogs');
         }
      }
   }

   @TestVisible
   private class FormDefinition {
      public String title;
      public String formAssemblyId;
      public String customUrlId;
      public List<field> fields;
   }
   private class field {
      public String name;
      public String apiName;
      public String repeat;
   }

   @TestVisible
   private class FormDefinitionResponse {
      public String formStatusCode;
      public String formStatusMessage;
      public String formUrl;
      public String formDefinitionStatusCode;
      public string formDefinitionStatusMessage;
      public string formDefinition;
      public String customUrlId;
      public String formEditors;
      public FormDefinitionResponse() {
      }

      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this);
      }
   }
=======
/**
 * Name          : AH_UDC_REST_FormDefinition
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2020-11-23
 * Description   : This class accepts a Form Response POST from the C# API
 * Dependencies  : 
 **/
  
@RestResource(urlMapping = '/AH_UDC_FormDefinition')
global with sharing class AH_UDC_REST_FormDefinition {

   @HttpPost
   global static void post() {
      AH_UDC_LogHelper.QueueLogs = true;

      AH_UDC_LogHelper.Debug('AH_UDC_FormDefinition - POST');
      FormDefinitionResponse resp = new FormDefinitionResponse();
      RestRequest req = RestContext.request;
      String requestBody = '';
      if (req != null && req.requestBody != null) requestBody = req.requestBody.toString();

      Savepoint objSavePoint = Database.setSavepoint();
      try {
         AH_UDC_LogHelper.Debug('requestBody: ' + requestBody);

         if (Test.isRunningTest() && requestBody == 'Exception1') Integer i = 1 / 0;

         FormDefinition formDefinition = (FormDefinition) JSON.deserialize(requestBody, FormDefinition.class);

         //Find the Form Requested
         List<AH_UDC_Form__c> forms = null;

         if (Schema.sObjectType.AH_UDC_Form__c.fields.Definition__c.isAccessible() &&
             Schema.sObjectType.AH_UDC_Form__c.fields.CustomUrlId__c.isAccessible()) {
            forms = [SELECT Id, Name, Definition__c, CustomUrlId__c, CreatedBy.Name
                                          FROM AH_UDC_Form__c
                                          WHERE FormAssemblyId__c = :formDefinition.FormAssemblyId];
            AH_UDC_LogHelper.Debug('AH_UDC_REST_FormDefinition.Post : forms: ' + forms);
         }

         if (forms == null || forms.size() == 0) {
            if (!Schema.sObjectType.AH_UDC_Form__c.isCreateable()) {
               resp.formStatusCode = '500';
               resp.formStatusMessage = 'Not OK : Form does not exist in Salesforce';
               resp.formDefinitionStatusCode = '500';
               resp.formDefinitionStatusMessage = 'The requested form was not found; and you do not have permission to create one.';
               RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
               return;
            }

            Id formAssemblyRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();

            AH_UDC_Form__c newForm = new AH_UDC_Form__c(
                                                        Name = formDefinition.title.left(80),
                                                        Definition__c = requestBody,
                                                        FormAssemblyId__c = formDefinition.FormAssemblyId,
                                                        RecordTypeId = formAssemblyRecordTypeId);
            if (formDefinition.CustomUrlId != null && formDefinition.FormAssemblyId != formDefinition.CustomUrlId) {
               newForm.CustomUrlId__c = formDefinition.CustomUrlId;
            }
            AH_UDC_SystemContext.CreateObject(newForm);

            resp.formStatusCode = '200';
            resp.formStatusMessage = 'OK; Created';
            resp.formUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + newForm.id;
            resp.formDefinition = newForm.Definition__c;
            resp.CustomUrlId = newForm.CustomUrlId__c;
            resp.formDefinitionStatusCode = '200';
            resp.formDefinitionStatusMessage = 'A new form was created; please refresh the page.';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         //Determine if form is in use in workbooks
         AggregateResult[] workbooks = null;
         if (Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Workbook__c.isAccessible() &&
             Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Form__c.isAccessible()) {
            workbooks = [SELECT Workbook__c
                                        FROM AH_UDC_WorkbookStep__c
                                        WHERE Workbook__r.recordtype.DeveloperName = :AH_UDC_Constants.RECORD_TYPE_WORKBOOK
                                        AND Workbook__r.enabled__c = true
                                        AND form__c = :forms[0].id
                                        GROUP BY Workbook__c];
            AH_UDC_LogHelper.Debug('workbooks: ' + workbooks.size());
         }

         //Determine if form is in use in workbooks sent
         AggregateResult[] workbooksSent = null;
         if (Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Workbook__c.isAccessible() &&
             Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Form__c.isAccessible()) {
            workbooksSent = [SELECT Workbook__c
                               FROM AH_UDC_WorkbookStep__c
                              WHERE Workbook__r.recordtype.DeveloperName = :AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT
                                AND Workbook__r.enabled__c = true
                                AND Workbook__r.CompletedDate__c = null
                                AND form__c = :forms[0].id
                              GROUP BY Workbook__c];
            AH_UDC_LogHelper.Debug('workbooksSent: ' + workbooksSent.size());
         }

         List<UserRecordAccess> recordAccess = null;
         if (Schema.sObjectType.UserRecordAccess.fields.RecordId.isAccessible() &&
             Schema.sObjectType.UserRecordAccess.fields.HasEditAccess.isAccessible()) {
            recordAccess = [SELECT RecordId, HasEditAccess
                              FROM UserRecordAccess
                             WHERE UserId = :UserInfo.getUserId()
                               AND RecordId = :forms[0].id];
            AH_UDC_LogHelper.Debug('recordAccess:' + recordAccess);
         }

         if (recordAccess == null || recordAccess.size() != 1 || !recordAccess[0].HasEditAccess) {
            resp.formStatusCode = '200';
            resp.formStatusMessage = 'OK; Workbooks (Enabled) = ' + workbooks.size() + '; Workbooks Sent (Not Completed) = ' + workbooksSent.size();
            resp.formUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + forms[0].id;
            resp.formDefinition = forms[0].Definition__c;
            resp.CustomUrlId = forms[0].CustomUrlId__c;
            resp.formDefinitionStatusCode = '500';
            resp.formDefinitionStatusMessage = 'You do not have access to update the form.';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         forms[0].Definition__c = requestBody;

         if (formDefinition.CustomUrlId != null && formDefinition.FormAssemblyId != formDefinition.CustomUrlId) {
            forms[0].CustomUrlId__c = formDefinition.CustomUrlId;
         }

         AH_UDC_SystemContext.UpdateObject(forms[0]);

         resp.formStatusCode = '200';
         resp.formStatusMessage = 'OK; Workbooks (Enabled) = ' + workbooks.size() + '; Workbooks Sent (Not Completed) = ' + workbooksSent.size();
         resp.formUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + forms[0].id;
         resp.formDefinition = forms[0].Definition__c;
         resp.CustomUrlId = forms[0].CustomUrlId__c;
         resp.formDefinitionStatusCode = '200';
         resp.formDefinitionStatusMessage = 'Definition Updated';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e) {
         AH_UDC_LogHelper.Debug('AH_UDC_REST_FormDefinition.post - Exception: ' + e);

         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_REST_FormDefinition', 'post',
                              'An exception occurred processing a response: Request Body: ' + requestBody,
                              e, null, null);

         //Set the Return code
         resp.formStatusCode = '500';
         resp.formStatusMessage = 'Exception Occurred';
         resp.formDefinitionStatusCode = '500';
         resp.formDefinitionStatusMessage = 'An Error occurred updating the definition';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      finally {
         try {
            if (Test.isRunningTest() && requestBody == 'ExceptionWriteQLogs') integer i = 1/0;
            AH_UDC_LogHelper.writeQueuedLogs();
         }
         catch(Exception exc) {
            //If logs can't be written at least show an error in debug
            AH_UDC_LogHelper.Debug('AH_UDC_REST_FormDefinition.Post - Failed to write QueuedLogs');
         }
      }
   }

   @HttpGet
   global static void get() {
      AH_UDC_LogHelper.QueueLogs = true;

      AH_UDC_LogHelper.Debug('FormDefinitionGetResponse');
      FormDefinitionResponse resp = new FormDefinitionResponse();
      RestRequest req = RestContext.request;
      String FormAssemblyFormId = null;
      Set<String> names = null;
      try {
         FormAssemblyFormId = RestContext.request.params.get('FormId');

         if (Test.isRunningTest() && FormAssemblyFormId == 'Exception1') Integer i = 1 / 0;

         if (String.isBlank(FormAssemblyFormId)) {
            resp.formStatusCode = '400';
            resp.formStatusMessage = 'Bad Request';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         if (Test.isRunningTest() && FormAssemblyFormId == 'TestException') integer i = 1 / 0;

         //Get the Questions/Answers
         List<AH_UDC_Form__c> forms = null;
         if (Schema.sObjectType.AH_UDC_Form__c.fields.Definition__c.isAccessible() &&
             Schema.sObjectType.AH_UDC_Form__c.fields.CustomUrlId__c.isAccessible()) {
            forms = [SELECT Id, Name, Definition__c, CustomUrlId__c
                       FROM AH_UDC_Form__c
                      WHERE FormAssemblyId__c = :FormAssemblyFormId];
            AH_UDC_LogHelper.Debug('forms: ' + forms.size());
         }

         ////No Form with that ID found
         if (forms == null || forms.size() == 0) {
            resp.formStatusCode = '200';
            resp.formStatusMessage = 'Not OK : Form does not exist in Salesforce';
            resp.formUrl = '';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         //Determine if form is in use in workbooks
         AggregateResult[] workbooks = null;
         if (Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Workbook__c.isAccessible() &&
             Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Form__c.isAccessible()) {
            workbooks = [SELECT Workbook__c
                           FROM AH_UDC_WorkbookStep__c
                          WHERE Workbook__r.recordtype.DeveloperName = :AH_UDC_Constants.RECORD_TYPE_WORKBOOK
                            AND Workbook__r.enabled__c = true
                            AND Form__c = :forms[0].id
                          GROUP BY Workbook__c];
            AH_UDC_LogHelper.Debug('workbooks: ' + workbooks.size());
         }

         //Determine if form is in use in workbooks sent
         AggregateResult[] workbooksSent = null;
         if (Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Workbook__c.isAccessible() &&
             Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Form__c.isAccessible()) {
            workbooksSent = [SELECT Workbook__c
                               FROM AH_UDC_WorkbookStep__c
                              WHERE Workbook__r.recordtype.DeveloperName = :AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT
                                AND Workbook__r.enabled__c = true
                                AND Workbook__r.CompletedDate__c = null
                                AND form__c = :forms[0].id
                              GROUP BY Workbook__c];
            AH_UDC_LogHelper.Debug('workbooksSent: ' + workbooksSent.size());
         }

         // Getting form access user name 
         List<AH_UDC_Form__Share> formShare = null;
         if (//Schema.sObjectType.AH_UDC_Form__Share.fields.UserOrGroup.isAccessible() &&
             Schema.sObjectType.AH_UDC_Form__Share.fields.AccessLevel.isAccessible()) {
            formShare = [SELECT UserOrGroup.Name, AccessLevel
                           FROM AH_UDC_Form__Share 
                          WHERE AccessLevel in ('All','Edit') 
                            AND ParentId =: forms[0].id];
         }

         if(formShare != null && formShare.size() > 0) {
            names = new Set<String>();
            for(AH_UDC_Form__Share fs: formShare) {
              if(fs.UserOrGroup != null) { names.add(String.valueOf(fs.UserOrGroup.get('Name'))); }
            }        
         }

         resp.formStatusCode = '200';
         resp.formStatusMessage = 'OK; Workbooks (Enabled) = ' + workbooks.size() + '; Workbooks Sent (Not Completed) = ' + workbooksSent.size();
         resp.formUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + forms[0].id;
         resp.formDefinition = forms[0].Definition__c;
         resp.formDefinitionStatusCode = '200';
         resp.formDefinitionStatusMessage = 'Ok';
         resp.CustomUrlId = forms[0].CustomUrlId__c;
         resp.formEditors = names == null ? '': String.join((Iterable<String>)names, System.Label.AH_UDC_SeparatedString); //Create comma separated string

         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e)
      {
         AH_UDC_LogHelper.Debug('AH_UDC_REST_FormDefinition.get - Exception: ' + e);

         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_REST_FormDefinition', 'get',
                              'An exception occurred processing a response: ' + e.getMessage(),
                              e, null, null);

         //Set the Return code
         resp.formStatusCode = '500';
         resp.formStatusMessage = 'Exception Occurred';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      finally {
         try {
            if (Test.isRunningTest() && FormAssemblyFormId == 'ExceptionWriteQLogs') { integer i = 1/0; }
            AH_UDC_LogHelper.writeQueuedLogs();
         }
         catch(Exception exc) {
            //If logs can't be written, at least show an error in debug
            System.Debug('AH_UDC_REST_FormDefinition.Get - Failed to write QueuedLogs');
         }
      }
   }

   @TestVisible
   private class FormDefinition {
      public String title;
      public String formAssemblyId;
      public String customUrlId;
      public List<field> fields;
   }
   private class field {
      public String name;
      public String apiName;
      public String repeat;
   }

   @TestVisible
   private class FormDefinitionResponse {
      public String formStatusCode;
      public String formStatusMessage;
      public String formUrl;
      public String formDefinitionStatusCode;
      public string formDefinitionStatusMessage;
      public string formDefinition;
      public String customUrlId;
      public String formEditors;
      public FormDefinitionResponse() {
      }

      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this);
      }
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}