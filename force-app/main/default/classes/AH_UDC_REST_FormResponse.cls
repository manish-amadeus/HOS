/**
 * Name          : AH_UDC_REST_FormResponse
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2020-11-23
 * Description   : This class accepts a Form Response POST from the C# API
 * Dependencies  : 
 **/

@RestResource(urlMapping = '/AH_UDC_FormResponse')
global with sharing class AH_UDC_REST_FormResponse {
   @HttpPost
   //This is used to write a single AH_UDC_Response record
   //This is used to write potentially thousands of AH_UDC_ResponseQA records
   //Shared Responses are handled by sending back to the API caller the list of forms
   global static void post() {
      AH_UDC_LogHelper.QueueLogs = true;

      FormResponseResponse resp = new FormResponseResponse();
      RestRequest req = RestContext.request;
      Savepoint objSavePoint = Database.setSavepoint();

      String requestBody = '';

      try {
         if (req != null && req.requestBody != null) requestBody = req.requestBody.toString();
         AH_UDC_LogHelper.Debug('requestBody: ' + requestBody);

         FormResponseRequest request = (FormResponseRequest) JSON.deserialize(requestBody, FormResponseRequest.class);
         string SecurityCode = '';
         string ResponderUserId = '';
         string FormId = '';

         //Find the token in the request
         for (QuestionAnswer qa : request.QuestionAnswers) {
            if (!qa.Answer.startsWith(AH_UDC_Constants.FORM_TOKEN_PREFIX)) continue;

            string token = qa.Answer.substring(AH_UDC_Constants.FORM_TOKEN_PREFIX.length());

            //Decrypt token
            string sEncryptionKey = AH_UDC_ConfigHelper.GetString('AH_UDC_ViewWorkbookTokenEncryptionKey', '');
            if (!String.isEmpty(sEncryptionKey) && AH_UDC_ConfigHelper.GetBoolean('AH_UDC_ViewWorkbookTokenEncryption', true)) {
               Blob key = EncodingUtil.base64Decode(sEncryptionKey);
               token = token.replace('_2f_', '/').replace('_2b_', '+'); //Base64 has 2 special characters / + that are not compatible with a URL ID
               Blob data = EncodingUtil.base64Decode(token);
               Blob decryptedData = Crypto.decryptWithManagedIV('AES256', key, data);
               token = decryptedData.toString();
            }

            string[] tokenParts = token.split('_');
            SecurityCode = tokenParts[0];
            ResponderUserId = tokenParts[1];
            FormId = tokenParts[2];
            break;
         }

         //Find the Workbook Step Sent record for the posted Security Code
         List<AH_UDC_WorkbookStep__c> stepsSent = [SELECT Id, Form__r.Definition__c, Form__r.FormType__c,
                                                   Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c
                                                   FROM AH_UDC_WorkbookStep__c
                                                   WHERE Workbook__r.SecurityCode__c = :SecurityCode
                                                   AND Form__c = :FormId];
         AH_UDC_LogHelper.Debug('###stepsSent: ' + stepsSent);
         AH_UDC_LogHelper.Debug('###stepsSent Size: ' + stepsSent.size());

         if (stepsSent == null || stepsSent.size() == 0) {
            resp.statusCode = '401';
            resp.message = 'Not Found';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         //Central & Shared Form Responses - Find UnLocked Workbook Step Sent records with the same Form for the same Property
         List<AH_UDC_WorkbookStep__c> sharedSentSteps = new List<AH_UDC_WorkbookStep__c> ();
         Boolean WriteAllSharedResponses = false;
         if (stepsSent[0].Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_SHARED || stepsSent[0].Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_CENTRAL) {
            sharedSentSteps = [SELECT Id, Form__r.Definition__c, Form__r.FormType__c
                               FROM AH_UDC_WorkbookStep__c
                               WHERE Workbook__r.SentStatus__c in(:AH_UDC_Constants.SENT_STATUS_NEW, :AH_UDC_Constants.SENT_STATUS_IN_PROGRESS)
                               AND Form__c = :FormId
                               AND Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c = :stepsSent[0].Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c
                               AND Id != :stepsSent[0].id];
            AH_UDC_LogHelper.Debug('###sharedSentSteps: ' + sharedSentSteps.size());

            Integer totalResponses = sharedSentSteps.size() + 1;
            Integer totalResponseQAs = totalResponses * request.QuestionAnswers.size();

            if (totalResponses + totalResponseQAs< 10000) {
               WriteAllSharedResponses = true;
            }
         }

         //Create List of Workbook Step IDs being updated
         List<Id> StepSentIds = new List<Id> ();
         StepSentIds.add(stepsSent[0].id);
         for (AH_UDC_WorkbookStep__c sharedSentStep : sharedSentSteps)
         {
            StepSentIds.add(sharedSentStep.id);
         }
         //Update steps to inprogress if still in New
         List<AH_UDC_WorkbookStep__c> updateStatusSteps = [SELECT Id, StepStatus__c
                                                           FROM AH_UDC_WorkbookStep__c
                                                           WHERE StepStatus__c = :AH_UDC_Constants.STEP_STATUS_NEW
                                                           and ID in :StepSentIds];
         for(AH_UDC_WorkbookStep__c updateStatusStep : updateStatusSteps)
         {
            updateStatusStep.StepStatus__c = AH_UDC_Constants.STEP_STATUS_IN_PROGRESS;
         }
         if(updateStatusSteps.size() >0) update updateStatusSteps;

         //Find the Contact sending the response
         List<User> responseUser = [SELECT Id FROM user where Id = :ResponderUserId];

         if (responseUser == null || responseUser.size() == 0) {
            resp.statusCode = '401';
            resp.message = 'Not Found';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         Id recordTypeIdResponse = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
         Id recordTypeIdQA = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();

         //Ensure all records get the same DateTime
         DateTime dtResponded = Datetime.now();

         //Create a new Respsonse Record(s)
         List<AH_UDC_Response__c> responses = new List<AH_UDC_Response__c> ();
         AH_UDC_Response__c response = new AH_UDC_Response__c();
         response.WorkbookStep__c = stepsSent[0].id;
         response.Responded__c = dtResponded;
         response.RecordTypeId = recordTypeIdResponse;
         response.Responder__c = responseUser[0].Id;
         responses.add(response);
         if (WriteAllSharedResponses) {
            for (AH_UDC_WorkbookStep__c sharedSentStep : sharedSentSteps) {
               AH_UDC_Response__c sharedResponse = new AH_UDC_Response__c();
               sharedResponse.WorkbookStep__c = sharedSentStep.id;
               sharedResponse.Responded__c = dtResponded;
               sharedResponse.RecordTypeId = recordTypeIdResponse;
               sharedResponse.Responder__c = responseUser[0].Id;
               responses.add(sharedResponse);
            }
         }
         insert responses;

         //Load Form Definition
         AH_UDC_Shared.FormDefinition formDefinition = (AH_UDC_Shared.FormDefinition) JSON.deserialize(stepsSent[0].getSObject('Form__r').get('Definition__c').toString(), AH_UDC_Shared.FormDefinition.class);

         //Create the Response QA Records
         List<AH_UDC_ResponseQA__c> rQAs = new List<AH_UDC_ResponseQA__c> ();
         for (QuestionAnswer qa : request.QuestionAnswers) {
            //Use Definition to lookup field names
            if (String.isBlank(qa.Question) || qa.Question == qa.QuestionField) {
               AH_UDC_Shared.FormField questionField = formDefinition.getFieldByAPIName(qa.QuestionField);
               if (questionField != null) {
                  qa.Question = questionField.Name;
                  //If QuestionField has array index add it to the looked up field name
                  if (qa.QuestionField.contains('[')) { qa.Question += '[' + qa.QuestionField.substringAfter('[');}
               }
            }
            //Use Definition to lookup field names
            AH_UDC_Shared.FormField answerField = formDefinition.getFieldByAPIName(qa.Answer);
            if (answerField != null) {
               qa.AnswerField = answerField.APIName;
               qa.Answer = answerField.Name;
            }

            if (qa.Question != 'Security Code'
                && qa.Question != 'Parent Security Code'
                && qa.Question != 'Product' && !qa.Answer.startsWith(AH_UDC_Constants.FORM_TOKEN_PREFIX)) {
               for (AH_UDC_Response__c newResponse : responses) {
                  AH_UDC_ResponseQA__c rQA = new AH_UDC_ResponseQA__c();
                  rQA.QuestionField__c = qa.QuestionField;
                  rQA.Question__c = qa.Question;
                  rQA.AnswerField__c = qa.AnswerField;
                  rQA.Answer__c = qa.Answer;
                  rQA.Response__c = newResponse.id;
                  rQA.RecordTypeId = recordTypeIdQA;
                  rQAs.add(rQA);
               }
            }
         }
         if (rQAs.size()> 0) insert(rQAs);

         //TODO: If Shared Responses could not be written due to governors, return that to c# so it can make additional calls.

         resp.statusCode = '200';
         resp.message = 'Ok';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e) {
         AH_UDC_LogHelper.Debug('AH_UDC_REST_FormResponse.Post - Exception: ' + e);

         if (objSavePoint != null) {
            Database.rollback(objSavepoint);
         }

         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_REST_FormResponse',
                              'post()',
                              'An exception occurred processing a response; Request Body: ' + requestBody,
                              e, null, null);

         //Set the Return code
         resp.statusCode = '500';
         resp.message = 'Exception Occurred';
         resp.exceptionMessage = e.getMessage();
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      finally {
         try {
            if (requestBody=='writeQueuedLogsException') Integer i=1/0;
            AH_UDC_LogHelper.writeQueuedLogs();
         }
         catch(Exception exc) {
            //If logs can't be written at least show an error in debug
            AH_UDC_LogHelper.Debug('AH_UDC_REST_FormResponse.Post - Failed to write QueuedLogs');
         }
      }
   }

   @HttpGet
   global static void get() {
      AH_UDC_LogHelper.QueueLogs = true;

      //AH_UDC_LogHelper.Debug('###FormResponseGetResponse');
      FormResponseGetResponse resp = new FormResponseGetResponse();
      RestRequest req = RestContext.request;
      try {
         String token = RestContext.request.params.get('token');

         if (!token.startsWith(AH_UDC_Constants.FORM_TOKEN_PREFIX)) {
            resp.statusCode = '400';
            resp.message = 'Bad Request';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }
         token = token.substring(AH_UDC_Constants.FORM_TOKEN_PREFIX.length());
         //AH_UDC_LogHelper.Debug('###Token: ' + token);

         if (Test.isRunningTest() && token == 'TestException') integer i = 1 / 0;
         if (String.isBlank(token)) {
            resp.statusCode = '400';
            resp.message = 'Bad Request';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         //Decrypt token
         string sEncryptionKey = AH_UDC_ConfigHelper.GetString('AH_UDC_ViewWorkbookTokenEncryptionKey', '');
         if (!String.isEmpty(sEncryptionKey) && AH_UDC_ConfigHelper.GetBoolean('AH_UDC_ViewWorkbookTokenEncryption', true)) {
            Blob key = EncodingUtil.base64Decode(sEncryptionKey);
            token = token.replace('_2f_', '/').replace('_2b_', '+'); //Base64 has 2 special characters / + that are not compatible with a URL ID
            Blob data = EncodingUtil.base64Decode(token);
            Blob decryptedData = Crypto.decryptWithManagedIV('AES256', key, data);
            token = decryptedData.toString();
         }

         //Split token
         string[] tokenParts = token.split('_');

         //Get Form Id
         if (tokenParts.size() != 3 || String.isBlank(tokenParts[0]) || String.isBlank(tokenParts[1]) || String.isBlank(tokenParts[2])) {
            resp.statusCode = '400';
            resp.message = 'Bad Request';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }
         string SecurityCode = tokenParts[0];
         String FormId = tokenParts[2];
         //AH_UDC_LogHelper.Debug('###FormId: ' + FormId);

         //Check that SecurityCode And FormId are for a valid step
         List<AH_UDC_WorkbookStep__c> stepsSent = [select Id, Workbook__c, Workbook__r.ParentWorkbookSent__c, Form__r.Definition__c
                                                   from AH_UDC_WorkbookStep__c
                                                   where Workbook__r.SecurityCode__c = :SecurityCode
                                                   AND Form__c = :FormId
                                                   LIMIT 1];
         //AH_UDC_LogHelper.Debug('###stepsSent: ' + stepsSent);
         //AH_UDC_LogHelper.Debug('###stepsSent Size: ' + stepsSent.size());

         if (stepsSent == null || stepsSent.size() == 0) {
            resp.statusCode = '401';
            resp.message = 'Not Found';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }
         Id recordTypeIdResponse = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
         Id recordTypeIdQA = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();

         //Get the newest Response that exists
         List<AH_UDC_Response__c> formResponses = [SELECT Id
                                                   FROM AH_UDC_Response__c
                                                   WHERE IsMostRecentResponse__c = true
                                                   AND WorkbookStep__c = :stepsSent[0].id
                                                   ORDER BY ID desc
                                                   LIMIT 1];
         AH_UDC_LogHelper.Debug('###formResponses: ' + formResponses);
         AH_UDC_LogHelper.Debug('###formResponses: ' + formResponses.size());

         //If there is an existing response, load ResponseQAs
         List<AH_UDC_ResponseQA__c> formQAs = new List<AH_UDC_ResponseQA__c> ();
         if (formResponses.size() > 0) {
            //Get the Questions/Answers
            AH_UDC_LogHelper.Debug('###formResponses[0].id: ' + formResponses[0].id);
            formQAs = [select Id, QuestionField__c, Answer__c, AnswerField__c
                       from AH_UDC_ResponseQA__c
                       where Response__c = :formResponses[0].id
                       and recordtypeid = :recordTypeIdQA
                       order by ID ASC];
            AH_UDC_LogHelper.Debug('###formQAs: ' + formQAs);
            AH_UDC_LogHelper.Debug('###formQAs: ' + formQAs.size());

            //No Questions/Answers yet
            if (formQAs != null && formQAs.size() > 0) {
               for (AH_UDC_ResponseQA__c formQA : formQAs) {
                  AH_UDC_LogHelper.Debug('###formQA.QuestionField__c: ' + String.valueOf(formQA.QuestionField__c));
                  AH_UDC_LogHelper.Debug('###formQA.AnswerField__c: ' + String.valueOf(formQA.AnswerField__c));
                  AH_UDC_LogHelper.Debug('###formQA.Answer__c: ' + String.valueOf(formQA.Answer__c));
                  QuestionAnswer qa = new QuestionAnswer(
                                                         String.valueOf(formQA.QuestionField__c),
                                                         null, //Left Null since the Human Readable Question is not needed
                                                         String.valueOf(formQA.AnswerField__c),
                                                         String.valueOf(formQA.Answer__c));
                  resp.QuestionAnswers.add(qa);
               }
            }
         }

         //Load Form Definition
         AH_UDC_Shared.FormDefinition formDefinition = (AH_UDC_Shared.FormDefinition) JSON.deserialize(stepsSent[0].getSObject('Form__r').get('Definition__c').toString(), AH_UDC_Shared.FormDefinition.class);

         //Find Defaults and Picklists on the form
         List<FindResponseQuestion> findResponseQuestions = new List<FindResponseQuestion> ();
         string whereDefaults = '';
         for (AH_UDC_Shared.FormField field : formDefinition.Fields) {
            if (field.DefaultValue != null) {
               string[] defaultValueParts = field.DefaultValue.split('\\|');
               if (defaultValueParts.size() == 3 && field.DefaultValue.toUpperCase().startsWith('DEFAULT|')) {
                  
                  ////TODO ROBDEV Restor Default Functionality
                  //boolean foundAnswer = false;
                  ////Determine if an Answer was provided - which will override default
                  //for (AH_UDC_ResponseQA__c formQA : formQAs) {
                     ////AH_UDC_LogHelper.Debug('###Get Default Values: Eval QA: ' + formQA.QuestionField__c);
                     //if (formQA.QuestionField__c == field.APIName) {
                        ////AH_UDC_LogHelper.Debug('###Get Default Values: Existing QA: Dont use default');
                        //foundAnswer = true;
                        //break;
                     //}
                  //}
                  //if (!foundAnswer) {
                     ////AH_UDC_LogHelper.Debug('###Get Default Values: No QA: Use default');

                     //FindResponseQuestion frq = new FindResponseQuestion(field.APIName, defaultValueParts[1], defaultValueParts[2], 'DEFAULT');
                     //FindResponseQuestions.add(frq);
                     //whereDefaults += (String.isEmpty(whereDefaults) ? '' : ' or ') + '(Response__r.WorkbookStep__r.Form__r.FormAssemblyId__c = \'' + defaultValueParts[1] + '\' and QuestionField__c=\'' + defaultValueParts[2] + '\')';
                  //}
               }
               //AH_UDC_LogHelper.Debug('###field.DefaultValue.toUpperCase()" ' + field.DefaultValue.toUpperCase());
               //AH_UDC_LogHelper.Debug('###startswith picklist: ' + field.DefaultValue.toUpperCase().startsWith('PICKLIST|'));
               if (defaultValueParts.size() == 3 && field.DefaultValue.toUpperCase().startsWith('PICKLIST|')) {
                  //AH_UDC_LogHelper.Debug('###isPicklist');
                  FindResponseQuestion frq = new FindResponseQuestion(field.APIName, defaultValueParts[1], defaultValueParts[2], 'PICKLIST');
                  FindResponseQuestions.add(frq);
                  whereDefaults += (String.isEmpty(whereDefaults) ? '' : ' or ') + '(Response__r.WorkbookStep__r.Form__r.FormAssemblyId__c = \'' + defaultValueParts[1] + '\' and (QuestionField__c=\'' + defaultValueParts[2] + '\' or QuestionField__c LIKE \'' + defaultValueParts[2] + '[%]\'))';
               }
            }
         }

         //Find Defaults from other form responses
         if (FindResponseQuestions.size() > 0) {
            //Get Current Workbook Responses for Defaults
            string sQuery = 'select QuestionField__c, Answer__c, AnswerField__c, Response__r.WorkbookStep__r.Form__r.FormAssemblyId__c' + ' from AH_UDC_ResponseQA__c' + ' where Response__r.IsMostRecentResponse__c = true' + ' and Response__r.recordtypeid = \'' + recordTypeIdResponse + '\'';

            //AH_UDC_LogHelper.Debug('###sQuery: ' + sQuery);
            //AH_UDC_LogHelper.Debug('###whereDefaults: ' + whereDefaults);

            List<AH_UDC_ResponseQA__c> defaultQAs = Database.query(sQuery + ' and Response__r.WorkbookStep__r.Workbook__c = \'' + stepsSent[0].Workbook__c + '\'' + ' and (' + whereDefaults + ')');

            List<AH_UDC_ResponseQA__c> defaultParentQAs = new List<AH_UDC_ResponseQA__c> ();
            if (stepsSent[0].Workbook__r.ParentWorkbookSent__c != null) {
               defaultQAs = Database.query(sQuery + ' and (Response__r.WorkbookStep__r.Workbook__c = \'' + stepsSent[0].Workbook__c + '\'' + '      OR Response__r.WorkbookStep__r.Workbook__c = \'' + stepsSent[0].Workbook__r.ParentWorkbookSent__c + '\')' + ' and (' + whereDefaults + ')');
            }

            //AH_UDC_LogHelper.Debug('###Find Defaults: ' + defaultQAs.size());
            Map<String, Picklist> mapPicklists = new Map<String, Picklist> ();

            //Use Definition to seed mapPicklists
            //AH_UDC_LogHelper.Debug('#Find Picklists');
            List<AH_UDC_Shared.FormField> foundPicklists = formDefinition.getPicklists();
            //AH_UDC_LogHelper.Debug('#foundPicklists: ' + foundPicklists);
            for (AH_UDC_Shared.FormField foundPicklist : foundPicklists) {
               Picklist picklist = new Picklist();
               picklist.FieldName = foundPicklist.APIName;
               mapPicklists.put(String.valueOf(foundPicklist.APIName), picklist);
            }

            for (FindResponseQuestion findResponseQuestion : FindResponseQuestions) {
               //AH_UDC_LogHelper.Debug('###defaultQAs.size: ' + defaultQAs.size());
               for (AH_UDC_ResponseQA__c defaultQA : defaultQAs) {
                  //AH_UDC_LogHelper.Debug('###' + defaultQA.getSobject('Response__r').getSobject('WorkbookStep__r').getSobject('Form__r').get('FormAssemblyId__c'));
                  //AH_UDC_LogHelper.Debug('###' + findDefault.FormAssemblyId);
                  AH_UDC_LogHelper.Debug('###' + defaultQA.QuestionField__c);
                  //AH_UDC_LogHelper.Debug('###' + findDefault.QuestionField);
                  string questionFieldWithoutArray = defaultQA.QuestionField__c;
                  if (questionFieldWithoutArray.contains('[')) questionFieldWithoutArray = questionFieldWithoutArray.substring(0, questionFieldWithoutArray.indexOf('['));
                  //AH_UDC_LogHelper.Debug('###questionFieldWithoutArray: ' + questionFieldWithoutArray);
                  //AH_UDC_LogHelper.Debug('###findResponseQuestion.FindQuestionField: ' + findResponseQuestion.FindQuestionField);

                  if (defaultQA.getSobject('Response__r').getSobject('WorkbookStep__r').getSobject('Form__r').get('FormAssemblyId__c') == findResponseQuestion.FindFormAssemblyId && questionFieldWithoutArray == findResponseQuestion.FindQuestionField) {
                     //AH_UDC_LogHelper.Debug('###findResponseQuestion.FindType: ' + findResponseQuestion.FindType);

                     if (findResponseQuestion.FindType == 'DEFAULT') {
                        //AH_UDC_LogHelper.Debug('###Find Defaults Matched: ' + findDefault.QuestionField);
                        QuestionAnswer qa = new QuestionAnswer(String.valueOf(findResponseQuestion.FindQuestionField), null, String.valueOf(defaultQA.AnswerField__c), String.valueOf(defaultQA.Answer__c));
                        resp.QuestionAnswers.add(qa);
                        break;
                     }

                     if (findResponseQuestion.FindType == 'PICKLIST') {
                        //AH_UDC_LogHelper.Debug('###PICKLIST');
                        PicklistOption option = new PicklistOption(defaultQA.Answer__c);
                        Picklist picklist = null;
                        if (mapPicklists.containsKey(findResponseQuestion.FormField)) {
                           //AH_UDC_LogHelper.Debug('PICKLIST: Add to existing');
                           picklist = mapPicklists.get(findResponseQuestion.FormField);
                           picklist.Options.add(option);
                        } else {
                           //AH_UDC_LogHelper.Debug('###PICKLIST: Add new');
                           picklist = new Picklist();
                           picklist.FieldName = findResponseQuestion.FormField;
                           picklist.Options.add(option);
                           mapPicklists.put(String.valueOf(findResponseQuestion.FormField), picklist);
                        }
                     }
                  }
               }
            }
            //AH_UDC_LogHelper.Debug('###PICKLIST: Check MAP');
            for (string picklistName : mapPicklists.keySet()) {
               //AH_UDC_LogHelper.Debug('###PICKLIST: Add map to response');
               Picklist picklistForResponse = mapPicklists.get(picklistName);
               if (picklistForResponse.Options.size() == 0) {
                  //Add Default Option
                  PicklistOption optionDefault = new PicklistOption('{No Values}');
                  picklistForResponse.Options.add(optionDefault);
               }
               resp.Picklists.add(picklistForResponse);
            }
         }

         //Get Picklist values from prior form

         resp.statusCode = '200';
         resp.message = 'Ok';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e) {
         AH_UDC_LogHelper.Debug('###Exception: ' + e);

         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_REST_FormResponse', 'get',
                              'An exception occurred processing a response: ' + e.getMessage() + ' | ' + e.getStackTraceString(),
                              e, null, null);

         //Set the Return code
         resp.statusCode = '500';
         resp.message = 'Exception Occurred';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      finally {
         //TODO ROBDEV Restore Try/Catch
         //try {
            AH_UDC_LogHelper.writeQueuedLogs();
         //}
         //catch(Exception exc) {
            //If logs can't be written at least show an error in debug
         //   AH_UDC_LogHelper.Debug('AH_UDC_REST_FormDefinition.Get - Failed to write QueuedLogs');
         //}
      }
   }
   
   @TestVisible
   private class FindResponseQuestion {
      public string FormField;
      public string FindFormAssemblyId;
      public string FindQuestionField;
      public string FindType;
      public FindResponseQuestion(string FormField, string FindFormAssemblyId, string FindQuestionField, string FindType) {
         this.FormField = FormField;
         this.FindFormAssemblyId = FindFormAssemblyId;
         this.FindQuestionField = FindQuestionField;
         this.FindType = FindType;
      }
   }

   @TestVisible
   private class FormResponseRequest {
      public List<QuestionAnswer> QuestionAnswers;
   }

   private class Picklist {
      public String FieldName;
      public List<PicklistOption> Options = new List<PicklistOption> ();
   }

   private class PicklistOption {
      public String Display;
      public PicklistOption(string Display) {
         this.Display = Display;
      }
   }

   private class QuestionAnswer {
      public String QuestionField;
      public String Question;
      public String AnswerField;
      public String Answer;
      public QuestionAnswer(string QuestionField, string Question, string AnswerField, string Answer) {
         this.QuestionField = QuestionField;
         this.Question = Question;
         this.AnswerField = AnswerField;
         this.Answer = Answer;
      }
   }

   @TestVisible
   private class FormResponseResponse {
      public String statusCode;
      public String message;
      public String exceptionMessage;

      public FormResponseResponse() {
      }

      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this);
      }
   }

   @TestVisible
   private class FormResponseGetResponse {
      public String statusCode;
      public String message;
      public List<QuestionAnswer> QuestionAnswers = new List<QuestionAnswer> ();
      public List<Picklist> Picklists = new List<Picklist> ();

      public FormResponseGetResponse() {
      }

      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this);
      }
   }

}