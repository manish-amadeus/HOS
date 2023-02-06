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
         AH_UDC_Shared.Token decryptedToken = new AH_UDC_Shared.Token();

         //Find the token in the request
         for (QuestionAnswer qa : request.QuestionAnswers) {
            if (!qa.Answer.startsWith(AH_UDC_Constants.FORM_TOKEN_PREFIX)) continue;

            string token = qa.Answer.substring(AH_UDC_Constants.FORM_TOKEN_PREFIX.length());

            //Decrypt token
            decryptedToken = AH_UDC_Shared.DecryptToken(token);
            if (!decryptedToken.IsValid) {
               resp.statusCode = '400';
               resp.message = 'Token Not Valid';
               RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
               return;
            }
            break;
         }

         //Find the Workbook Step Sent record for the posted Security Code
         List<AH_UDC_WorkbookStep__c> stepsSent = null; 
         Boolean isWorkbookSent = true;

         if (Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Form__c.isAccessible() &&
             Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Workbook__c.isAccessible()) {
            stepsSent = [SELECT Id, Form__r.Definition__c, Form__r.FormType__c,
                         Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c, Workbook__r.RecordType.DeveloperName
                         FROM AH_UDC_WorkbookStep__c
                         WHERE Workbook__r.SecurityCode__c = :decryptedToken.SecurityCode
                         AND Form__c = :decryptedToken.FormId];
            AH_UDC_LogHelper.Debug('###stepsSent: ' + stepsSent);
            AH_UDC_LogHelper.Debug('###stepsSent Size: ' + stepsSent.size());
         }

         if (stepsSent == null || stepsSent.size() == 0) {
            resp.statusCode = '404';
            resp.message = 'Not Found';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         if (stepsSent[0].Workbook__r.RecordType.DeveloperName == AH_UDC_Constants.RECORD_TYPE_WORKBOOK) isWorkbookSent= false;

         //Central & Shared Form Responses - Find UnLocked Workbook Step Sent records with the same Form for the same Property
         List<AH_UDC_WorkbookStep__c> sharedSentSteps = new List<AH_UDC_WorkbookStep__c> ();
         if (stepsSent[0].Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_SHARED || stepsSent[0].Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_CENTRAL) {
            if (Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Form__c.isAccessible() &&
                Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Workbook__c.isAccessible()) {
               sharedSentSteps = [SELECT Id, Form__r.Definition__c, Form__r.FormType__c
                                  FROM AH_UDC_WorkbookStep__c
                                  WHERE Workbook__r.SentStatus__c in(:AH_UDC_Constants.SENT_STATUS_NEW, :AH_UDC_Constants.SENT_STATUS_IN_PROGRESS)
                                  AND Form__c = :decryptedToken.FormId
                                  AND Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c = :stepsSent[0].Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c
                                  AND Id != :stepsSent[0].id];
               AH_UDC_LogHelper.Debug('###sharedSentSteps: ' + sharedSentSteps.size());
            }
         }

         //Create List of Workbook Step IDs being updated
         List<Id> StepSentIds = new List<Id> ();
         StepSentIds.add(stepsSent[0].id);
         for (AH_UDC_WorkbookStep__c sharedSentStep : sharedSentSteps)
         {
            StepSentIds.add(sharedSentStep.id);
         }
         if (isWorkbookSent)
         {
            //Update steps to inprogress if still in New
            List<AH_UDC_WorkbookStep__c> updateStatusSteps = null;
            if (Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.StepStatus__c.isAccessible()) {
               updateStatusSteps = [SELECT Id, StepStatus__c
                                      FROM AH_UDC_WorkbookStep__c
                                     WHERE StepStatus__c = :AH_UDC_Constants.STEP_STATUS_NEW
                                       AND Id in :StepSentIds];
            }

            if (updateStatusSteps != null && updateStatusSteps.size() > 0) {
               for (AH_UDC_WorkbookStep__c updateStatusStep : updateStatusSteps)
               {
                  updateStatusStep.StepStatus__c = AH_UDC_Constants.STEP_STATUS_IN_PROGRESS;
               }
               AH_UDC_Security.UpdateObjects(updateStatusSteps);
            }
         }
         //Find the Contact sending the response
         List<User> responseUser = null;
         if (Schema.sObjectType.User.fields.Id.isAccessible()) {
            responseUser = [SELECT Id FROM User WHERE Id = :decryptedToken.ResponderUserId];
         }

         if (responseUser == null || responseUser.size() == 0) {
            resp.statusCode = '404';
            resp.message = 'Not Found';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         Id recordTypeIdResponse = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
         Id recordTypeIdQA = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();

         //Ensure all records get the same DateTime
         DateTime dtResponded = Datetime.now();

         //Create a new Respsonse Record
         AH_UDC_Response__c response = new AH_UDC_Response__c();
         response.Responded__c = dtResponded;
         response.RecordTypeId = recordTypeIdResponse;
         response.Responder__c = responseUser[0].Id;
         AH_UDC_Security.CreateObject(response);

         //Create new Workbook Step Respsonse Record(s)
         List<AH_UDC_WorkbookStepResponse__c> wbsResponses = new List<AH_UDC_WorkbookStepResponse__c> ();
         AH_UDC_WorkbookStepResponse__c wbsResponse = new AH_UDC_WorkbookStepResponse__c(WorkbookStep__c = stepsSent[0].id,
                                                                                         Response__c = response.Id,
                                                                                         IsMostRecentResponse__c = true);
         wbsResponses.add(wbsResponse);
         for (AH_UDC_WorkbookStep__c sharedSentStep : sharedSentSteps) {
            wbsResponse = new AH_UDC_WorkbookStepResponse__c(WorkbookStep__c = sharedSentStep.id,
                                                             Response__c = response.Id,
                                                             IsMostRecentResponse__c = true);
            wbsResponses.add(wbsResponse);
         }
         AH_UDC_Security.CreateObjects(wbsResponses);

         //Load Form Definition 
         AH_UDC_Shared.FormDefinition formDefinition = (AH_UDC_Shared.FormDefinition) JSON.deserialize(stepsSent[0].getSObject('Form__r').get('Definition__c').toString(), AH_UDC_Shared.FormDefinition.class);

         //This dictionary is used to renumber tfa fields so there are no gaps
         Map<string, integer> tfaFields = new Map<string, integer>();

         //Need to sort QA by QuestionField since Form Assembly doesn't submit them in the correct order
         request.QuestionAnswers.sort();
         //for (QuestionAnswer qa : request.QuestionAnswers) {
            //System.debug('@@@qa.QuestionField: ' + qa.QuestionField);
         //}

         //Create the Response QA Records - up to 10K can be created
         List<AH_UDC_ResponseQA__c> rQAs = new List<AH_UDC_ResponseQA__c> ();
         QuestionAnswer lastQA = null;
         for (QuestionAnswer qa : request.QuestionAnswers) {
            //System.debug('$$$qa: ' + qa);

            //Use Definition to lookup field names
            if (String.isBlank(qa.Question) || qa.Question == qa.QuestionField) {
               AH_UDC_Shared.FormField questionField = formDefinition.getFieldByAPIName(qa.QuestionField);
               if (questionField != null && String.isNotBlank(questionField.Name)) {
                  qa.Question = questionField.Name;
                  //If QuestionField has array index add it to the looked up field name
                  if (qa.QuestionField.contains('[')) { qa.Question += '[' + qa.QuestionField.substringAfter('['); }
               }
            }
            //Use Definition to lookup answer field name
            AH_UDC_Shared.FormField answerField = formDefinition.getFieldByAPIName(qa.Answer);
            if (answerField != null) {
               qa.AnswerField = answerField.APIName;
               qa.Answer = answerField.Name;
            }

            if (qa.Question != 'Security Code'
                && qa.Question != 'Parent Security Code'
                && qa.Question != 'Product' 
                && !qa.Answer.startsWith(AH_UDC_Constants.FORM_TOKEN_PREFIX)) {
               if (String.isNotBlank(qa.QuestionField))
               {
                  //Fix index of array if indexed field
                  SetFieldArray(qa, tfaFields, lastQA);
                  lastQA = qa;

                  AH_UDC_ResponseQA__c rQA = new AH_UDC_ResponseQA__c(
                                                                      QuestionField__c = qa.QuestionField,
                                                                      Question__c = qa.Question,
                                                                      AnswerField__c = qa.AnswerField,
                                                                      Answer__c = qa.Answer,
                                                                      Response__c = response.id,
                                                                      RecordTypeId = recordTypeIdQA);
                  rQAs.add(rQA);
               }
            }
         }
         if (rQAs.size() > 0) { AH_UDC_Security.CreateObjects(rQAs); }

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
            if (requestBody == 'writeQueuedLogsException') Integer i = 1 / 0;
            AH_UDC_LogHelper.writeQueuedLogs();
         }
         catch(Exception exc) {
            //If logs can't be written at least show an error in debug
            AH_UDC_LogHelper.Debug('AH_UDC_REST_FormResponse.Post - Failed to write QueuedLogs');
         }
      }
   }

   //This function is used to fix gaps in the Form Assembly values posted - we have a FA request in to have them fix this
   public static void SetFieldArray(QuestionAnswer qa, Map<string, integer> tfaField, QuestionAnswer lastQA)
   {
      //System.debug('$$$MAP tfaField: ' + tfaField);
      //System.Debug('$$$ qa.QuestionField - Before: ' + qa.QuestionField);
      //System.Debug('$$$ qa.Question - Before: ' + qa.Question);
      
      //Is Field Indexed
      integer iIndexQuestionFieldBracket = qa.QuestionField.IndexOf('[');
      integer iIndexQuestionBracket = qa.Question.IndexOf('[');
      if (iIndexQuestionFieldBracket > - 1 || iIndexQuestionBracket > - 1)
      {
         string QuestionField = '';
         if (iIndexQuestionFieldBracket > - 1)
         {
            QuestionField = qa.QuestionField;
            //qa.QuestionField = qa.QuestionField.Substring(0, iIndexQuestionFieldBracket);//Remove index
         }
         else
         {
            QuestionField = qa.Question;
            //qa.Question = qa.Question.Substring(0, iIndexQuestionBracket);//Remove index
         }
         if(iIndexQuestionFieldBracket > -1) qa.QuestionField = qa.QuestionField.Substring(0, iIndexQuestionFieldBracket);//Remove index
         if(iIndexQuestionBracket > -1) qa.Question = qa.Question.Substring(0, iIndexQuestionBracket);//Remove index

         integer firstStartBracket = QuestionField.IndexOf('[');
         integer firstEndBracket = QuestionField.IndexOf(']');
         string remainingBrackets = '';
         if (QuestionField.length() > firstEndBracket)
         {
             remainingBrackets = QuestionField.Substring(firstEndBracket+1);
         }
         //System.Debug('$$$FirstEndBracket: ' + firstEndBracket);
         //System.Debug('$$$FirstStartBracket: ' + firstStartBracket);

         integer iFieldIndex = integer.valueOf(QuestionField.Substring(FirstStartBracket+1, FirstEndBracket));
         qa.OriginalFieldIndex = iFieldIndex;

         //System.Debug('$$$iFieldIndex: ' + iFieldIndex);
         //System.Debug('$$$remainingBrackets: ' + remainingBrackets);


         qa.QuestionFieldWithoutIndex = qa.QuestionField;

         //System.Debug('$$$ qa.QuestionField - After: ' + qa.QuestionField);
         //System.Debug('$$$ qa.Question - After: ' + qa.Question);

         //Determine what the index should be
         if (tfaField.ContainsKey(qa.QuestionField))
         {
            integer iFieldIndexOverride = tfaField.get(qa.QuestionField);
            if (!(lastQA.QuestionFieldWithoutIndex == qa.QuestionFieldWithoutIndex
                && lastQA.OriginalFieldIndex == qa.OriginalFieldIndex))
            {
               if (iFieldIndex != iFieldIndexOverride)
               {
                  //Only increment the renumbering if it's not the same as the previous one
                  iFieldIndexOverride++;
                  tfaField.put(qa.QuestionField,iFieldIndexOverride);
               }
            }
            qa.QuestionField += '[' + String.valueOf(iFieldIndexOverride) + ']' + remainingBrackets;
            qa.Question += '[' + String.valueOf(iFieldIndexOverride) + ']' + remainingBrackets;
         }
         else
         {
            tfaField.put(qa.QuestionField, 0);
            qa.QuestionField += '[0]' + remainingBrackets;
            qa.Question += '[0]' + remainingBrackets;
         }
         //System.Debug('$$$ qa.QuestionField - Final: ' + qa.QuestionField);
         //System.Debug('$$$ qa.Question - Final: ' + qa.Question);
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
         AH_UDC_Shared.Token decryptedToken = AH_UDC_Shared.DecryptToken(token);
  
         if (!decryptedToken.IsValid) {
            resp.statusCode = '400';
            resp.message = 'Token Not Valid';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }

         //Check that SecurityCode And FormId are for a valid step
         List<AH_UDC_WorkbookStep__c> stepsSent = null;
         if (Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Form__c.isAccessible() &&
               Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Workbook__c.isAccessible()) {

            stepsSent = [SELECT Id, Workbook__c, Workbook__r.ParentWorkbookSent__c, Form__r.Definition__c, Form__r.FormType__c
                           FROM AH_UDC_WorkbookStep__c
                          WHERE Workbook__r.SecurityCode__c = :decryptedToken.SecurityCode
                            AND Form__c = :decryptedToken.FormId LIMIT 1];
            //AH_UDC_LogHelper.Debug('###stepsSent: ' + stepsSent);
            //AH_UDC_LogHelper.Debug('###stepsSent Size: ' + stepsSent.size());
         }
//TODO:GLT:!!!!!Need isAccessible() on more [Select...]
         if (stepsSent == null || stepsSent.size() == 0) {
            resp.statusCode = '404';
            resp.message = 'Not Found';
            RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
            return;
         }
         Id recordTypeIdResponse = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
         Id recordTypeIdQA = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();
         Id recordTypeIdFormFormAssembly = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();

         //If the form is a central data form don't use saved responses since the Forms use Salesforce Connector to get their data
         if (stepsSent[0].Form__r.FormType__c != AH_UDC_Constants.FORM_TYPE_CENTRAL)
         {
            //Get the newest Response that exists
            List<AH_UDC_WorkbookStepResponse__c> formWbsResponses = [SELECT Response__c
                                                                     FROM AH_UDC_WorkbookStepResponse__c
                                                                     WHERE IsMostRecentResponse__c = true
                                                                     AND WorkbookStep__c = :stepsSent[0].id
                                                                     ORDER BY ID desc
                                                                     LIMIT 1];
            //If there is an existing response, load ResponseQAs
            List<AH_UDC_ResponseQA__c> formQAs = new List<AH_UDC_ResponseQA__c> ();
            if (formWbsResponses.size() > 0) {
               //Get the Questions/Answers
               formQAs = [select Id, QuestionField__c, Answer__c, AnswerField__c
                          from AH_UDC_ResponseQA__c
                          where Response__c = :formWbsResponses[0].Response__c
                          order by ID ASC];

               //Add found Questions/Answers
               if (formQAs != null && formQAs.size() > 0) {
                  for (AH_UDC_ResponseQA__c formQA : formQAs) {
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

            //Get the Step IDs for all Form Assembly Forms in this and the parent workbook
            List<AH_UDC_WorkbookStep__c> allSteps;
            if (stepsSent[0].Workbook__r.ParentWorkbookSent__c == null)
            {
               allSteps = [select Id, Workbook__c, Form__r.FormAssemblyId__c, Workbook__r.ParentWorkbookSent__c
                           from AH_UDC_WorkbookStep__c
                           where Workbook__c = :stepsSent[0].Workbook__c
                           AND Form__c != null
                           AND Form__r.RecordTypeId = :recordTypeIdFormFormAssembly];
            } else {
               allSteps = [select Id, Workbook__c, Form__r.FormAssemblyId__c, Workbook__r.ParentWorkbookSent__c
                           from AH_UDC_WorkbookStep__c
                           where(Workbook__c = :stepsSent[0].Workbook__c or Workbook__c = :stepsSent[0].Workbook__r.ParentWorkbookSent__c)
                           AND Form__c != null
                           AND Form__r.RecordTypeId = :recordTypeIdFormFormAssembly];
            }
            List<Id> allStepsIds = new List<Id> ();
            Map<string, StepDetail> mapStepDetails = new Map<string, StepDetail> ();
            for (AH_UDC_WorkbookStep__c allStep : allSteps)
            {
               allStepsIds.add(allStep.Id);
               Boolean isParentWorkbookStep = allStep.Workbook__c == allStep.Workbook__r.ParentWorkbookSent__c;
               mapStepDetails.put(allStep.Id, new StepDetail(allStep.Id, allStep.Workbook__c, allStep.Form__r.FormAssemblyId__c, null, isParentWorkbookStep));
            }

            //Get Most Recent Workbook Step Responses for all steps that are Form Assembly Forms in the workbook or parent workbook
            List<AH_UDC_WorkbookStepResponse__c> mostRecentWbsResponses = [SELECT Response__c, WorkbookStep__c
                                                                           FROM AH_UDC_WorkbookStepResponse__c
                                                                           WHERE IsMostRecentResponse__c = true
                                                                           AND WorkbookStep__c in :allStepsIds];
            for (AH_UDC_WorkbookStepResponse__c mostRecentWbsResponse : mostRecentWbsResponses)
            {
               //Find Step
               if (mapStepDetails.containsKey(mostRecentWbsResponse.WorkbookStep__c))
               {
                  //Get the StepDetail and update the Response on it
                  mapStepDetails.get(mostRecentWbsResponse.WorkbookStep__c).MostRecentResponseId = mostRecentWbsResponse.Response__c;
               }
            }
            //Find Defaults and Picklists on the form
            //Values for Defaults and Picklists must come from the current workbook or parent workbook
            List<FindResponseQuestion> findResponseQuestions = new List<FindResponseQuestion> ();
            for (AH_UDC_Shared.FormField field : formDefinition.Fields) {
               if (field.DefaultValue != null) {
                  string[] defaultValueParts = field.DefaultValue.split('\\|');
                  AH_UDC_LogHelper.Debug('###field.DefaultValue.toUpperCase()" ' + String.valueOf(field.DefaultValue.toUpperCase()));

                  if (defaultValueParts.size() == 3 && field.DefaultValue.toUpperCase().startsWith('DEFAULT|')) {
                     FindResponseQuestions.add(new FindResponseQuestion(field.APIName, defaultValueParts[1], defaultValueParts[2], 'DEFAULT'));
                  }
                  if (defaultValueParts.size() == 3 && field.DefaultValue.toUpperCase().startsWith('PICKLIST|')) {
                     FindResponseQuestions.add(new FindResponseQuestion(field.APIName, defaultValueParts[1], defaultValueParts[2], 'PICKLIST'));
                  }
               }
            }

            //Find Defaults from other form responses
            if (FindResponseQuestions.size() > 0) {
               //Loop through FindResponseQuestions that need to be found and assign them to responses that exist based on form id
               for(FindResponseQuestion frq : FindResponseQuestions)
               {
                  ID FindParentResponseId = null;
                  ID FindResponseId = null;
                  for(StepDetail findStepDetail : mapStepDetails.values())
                  {
                     if(findStepDetail.FormId == frq.FindFormAssemblyId)
                     {
                        if(findStepDetail.IsParentWorkbook)
                           FindParentResponseId = findStepDetail.MostRecentResponseId;
                        else
                           FindResponseId = findStepDetail.MostRecentResponseId;
                     }
                  }
                  if (FindResponseId != null) frq.ResponseId = FindResponseId;
                  else if (FindParentResponseId != null) frq.ResponseId = FindParentResponseId;
                  //Else there is no response so don't add any id
               }

               //Get Current Workbook Responses for Defaults
               string sQuery = '';
               for(FindResponseQuestion frq : FindResponseQuestions)
               {
                  if (String.isNotBlank(frq.ResponseId) && String.isNotBlank(frq.FindQuestionField)){
                     if(sQuery!='') sQuery += ' OR '; 
                     if (frq.FindType =='PICKLIST')
                        sQuery += '(Response__c = \'' + frq.ResponseId + '\' and QuestionField__c LIKE \'' + frq.FindQuestionField + '[%]\')';
                     else
                        sQuery += '(Response__c = \'' + frq.ResponseId + '\' and QuestionField__c =\'' + frq.FindQuestionField + '\')';
                  }
               }

               if(String.isNotBlank(sQuery))
               {
                  sQuery = 'select Response__c, QuestionField__c, Answer__c, AnswerField__c from AH_UDC_ResponseQA__c where ' + sQuery;

                  AH_UDC_LogHelper.Debug('$$$sQuery: ' + sQuery);

                  AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_TRACE,
                                 'AH_UDC_REST_FormResponse', 'sQuery:',
                                 'sQuery:: ' + sQuery,
                                 null, null, null);

                  List<AH_UDC_ResponseQA__c> defaultQAs = Database.query(sQuery);

                  AH_UDC_LogHelper.Debug('$$$Find Defaults: ' + defaultQAs.size());
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
                     AH_UDC_LogHelper.Debug('$$$defaultQAs.size: ' + defaultQAs.size());
                     for (AH_UDC_ResponseQA__c defaultQA : defaultQAs) {
                        string questionFieldWithoutArray = defaultQA.QuestionField__c;
                        if (questionFieldWithoutArray.contains('[')) questionFieldWithoutArray = questionFieldWithoutArray.substring(0, questionFieldWithoutArray.indexOf('['));
                    
                        if (defaultQA.Response__c == findResponseQuestion.ResponseId 
                           && questionFieldWithoutArray == findResponseQuestion.FindQuestionField) {
                           AH_UDC_LogHelper.Debug('$$$findResponseQuestion.FindType: ' + findResponseQuestion.FindType);

                           if (findResponseQuestion.FindType == 'DEFAULT') {
                              //AH_UDC_LogHelper.Debug('$$$Find Defaults Matched: ' + findResponseQuestion);
                              QuestionAnswer qa = new QuestionAnswer(String.valueOf(findResponseQuestion.FormField), null, String.valueOf(defaultQA.AnswerField__c), String.valueOf(defaultQA.Answer__c));
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
         try {
            AH_UDC_LogHelper.writeQueuedLogs();
         }
         catch(Exception exc) {
            //If logs can't be written at least show an error in debug
            AH_UDC_LogHelper.Debug('AH_UDC_REST_FormDefinition.Get - Failed to write QueuedLogs');
         }
      }
   }

   @TestVisible
   private class StepDetail {
      public ID StepId;
      public ID WorkbookId;
      public String FormId;
      public ID MostRecentResponseId;
      public Boolean IsParentWorkbook = false;
      public StepDetail(ID StepId, ID WorkbookId, String FormId, ID MostRecentResponseId, Boolean IsParentWorkbook)
      {
         this.StepId = StepId;
         this.WorkbookId = WorkbookId;
         this.FormId = FormId;
         this.MostRecentResponseId = MostRecentResponseId;
         this.IsParentWorkbook = IsParentWorkbook;
      }
   }

   @TestVisible
   private class FindResponseQuestion {
      public string FormField;
      public string FindFormAssemblyId;
      public string FindQuestionField;
      public string FindType;
      public string ResponseId;
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

   private class QuestionAnswer implements Comparable {
      public String QuestionField;
      public String Question;
      public String AnswerField;
      public String Answer;
      public String Repeat;
      public Integer OriginalFieldIndex;
      public Integer NewFieldIndex;
      public String QuestionFieldWithoutIndex;
      public QuestionAnswer(string QuestionField, string Question, string AnswerField, string Answer) {
         this.QuestionField = QuestionField;
         this.Question = Question;
         this.AnswerField = AnswerField;
         this.Answer = Answer;
      }

      // Compare opportunities based on the opportunity amount.
      public Integer compareTo(Object compareTo) {
         // Cast argument to OpportunityWrapper
         QuestionAnswer compareToQA = (QuestionAnswer)compareTo;

         // The return value of 0 indicates that both elements are equal.
         integer compare = this.QuestionField.compareTo(compareToQA.QuestionField);
         Integer returnValue = 0;
         if (compare > 0) {
            // Set return value to a positive value.
            returnValue = 1;
         } else if (compare < 0) {
            // Set return value to a negative value.
            returnValue = -1;
         }
         return returnValue;
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