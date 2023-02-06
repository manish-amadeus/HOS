/**
 * Name          : AH_UDC_REST_AmadeusFormResponse
 * Created By    : Amadeus Hospitality Services (vaishali.patel@Amadeus.com)
 * Created Date  : 2021-11-8
 * Description   : This class accepts a Amadeus Form Response POST from the C# API
 * Dependencies  : 
 **/

@RestResource(urlMapping = '/AH_UDC_AmadeusFormResponse')
global with sharing class AH_UDC_REST_AmadeusFormResponse {
   public static final Integer QA_JSON_MAX_PER_REQUEST = 20;
   @HttpPost
   //This is used to write a single AH_UDC_Response record
   //This is used to write potentially thousands of AH_UDC_ResponseQA records
   //Shared Responses are handled by sending back to the API caller the list of forms
   global static void post() {

      AH_UDC_LogHelper.QueueLogs = true;

      String requestBody = '';
      AmadeusFormResponsePostResponse resp = new AmadeusFormResponsePostResponse();
      RestRequest req = RestContext.request;
      Savepoint objSavePoint = Database.setSavepoint();
      try {
         if (req != null && req.requestBody != null) { requestBody = req.requestBody.toString(); }
         AH_UDC_LogHelper.Debug('requestBody: ' + requestBody);

         AmadeusFormPostRequest request = (AmadeusFormPostRequest) JSON.deserialize(requestBody, AmadeusFormPostRequest.class);

         Id recordTypeIdResponse = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_AMADEUS_FORM).getRecordTypeId();
         Id recordTypeIdQA = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_AMADEUS_FORM).getRecordTypeId();

         //Bypass Token check and Response creation if a specific Response ID is included in the request         
         if (String.isNotEmpty(request.responseId))
         {
            AH_UDC_LogHelper.Debug('request.responseId: ' + request.responseId);
            resp.responseId = request.responseId;
         }
         else
         {
            //Find the token in the request
            String token = request.token.substring(AH_UDC_Constants.FORM_TOKEN_PREFIX.length());

            //Decrypt token
            AH_UDC_Shared.Token decryptedToken = AH_UDC_Shared.DecryptToken(token);
            if (!decryptedToken.IsValid) {
               resp.statusCode = '400';
               resp.message = 'Token Not Valid';
               RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
               return;
            }

            //Find the Contact sending the response
            List<User> responseUser = [SELECT Id FROM User where Id = :decryptedToken.ResponderUserId WITH SECURITY_ENFORCED];

            if (responseUser == null || responseUser.size() == 0) {
               resp.statusCode = '404';
               resp.message = 'Responder Not Found';
               RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
               return;
            }

            Id amadeusFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM).getRecordTypeId();
            AH_UDC_LogHelper.debug('$$$:SecurityCode' + decryptedToken.SecurityCode);
            AH_UDC_LogHelper.debug('$$$:AmadeusFormRecordTypeId' + amadeusFormRecordTypeId);
            AH_UDC_LogHelper.debug('$$$:FormId' + decryptedToken.FormId);
            //Find the Workbook Step Sent record for the posted Security Code
            List<AH_UDC_WorkbookStep__c> stepsSent = null;
            if (Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Form__c.isAccessible() &&
                Schema.sObjectType.AH_UDC_WorkbookStep__c.fields.Workbook__c.isAccessible()) {
               stepsSent = [SELECT Id, Form__r.Definition__c, Form__r.FormType__c,
                            Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c
                            FROM AH_UDC_WorkbookStep__c
                            WHERE Workbook__r.SecurityCode__c = :decryptedToken.SecurityCode
                            AND Form__r.RecordTypeId = :AmadeusFormRecordTypeId
                            AND Form__c = :decryptedToken.FormId WITH SECURITY_ENFORCED];
               AH_UDC_LogHelper.Debug('###stepsSent: ' + stepsSent);
               AH_UDC_LogHelper.Debug('###$AmadeusFormRecordTypeId: ' + amadeusFormRecordTypeId);
               AH_UDC_LogHelper.Debug('###stepsSent Size: ' + stepsSent.size());
            }

            if (stepsSent == null || stepsSent.size() == 0) {
               resp.statusCode = '404';
               resp.message = 'Not Found';
               RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
               return;
            }
            //Create List of Workbook Step IDs being updated
            Set<Id> stepSentIds = new Set<Id> ();
            stepSentIds.add(stepsSent[0].id);

            //Central & Shared Form Responses - Find UnLocked Workbook Step Sent records with the same Form for the same Property
            List<AH_UDC_WorkbookStep__c> sharedSentSteps = null;
            if (stepsSent[0].Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_SHARED || stepsSent[0].Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_CENTRAL) {
               sharedSentSteps = [SELECT Id, Form__r.Definition__c, Form__r.FormType__c
                                  FROM AH_UDC_WorkbookStep__c
                                  WHERE Workbook__r.SentStatus__c in(:AH_UDC_Constants.SENT_STATUS_NEW, :AH_UDC_Constants.SENT_STATUS_IN_PROGRESS)
                                  AND Form__c = :decryptedToken.FormId
                                  AND Form__r.RecordTypeId = :amadeusFormRecordTypeId
                                  AND Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c = :stepsSent[0].Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c
                                  AND Id != :stepsSent[0].id WITH SECURITY_ENFORCED];
               AH_UDC_LogHelper.Debug('###sharedSentSteps: ' + sharedSentSteps.size());

               //if shared step exist than add id to set
               if (sharedSentSteps != null || sharedSentSteps.size() > 0)
               {
                  for (AH_UDC_WorkbookStep__c sharedSentStep : sharedSentSteps)
                  {
                     stepSentIds.add(sharedSentStep.id);
                  }
               }
            }

            //Update steps to inprogress if still in New
            List<AH_UDC_WorkbookStep__c> updateStatusSteps = [SELECT Id, StepStatus__c
                                                              FROM AH_UDC_WorkbookStep__c
                                                              WHERE StepStatus__c = :AH_UDC_Constants.STEP_STATUS_NEW
                                                              and ID in :StepSentIds WITH SECURITY_ENFORCED];
            if (updateStatusSteps.size() > 0)
            {
               for (AH_UDC_WorkbookStep__c updateStatusStep : updateStatusSteps)
               {
                  updateStatusStep.StepStatus__c = AH_UDC_Constants.STEP_STATUS_IN_PROGRESS;
               }

               AH_UDC_Security.UpdateObjects(updateStatusSteps);
            }
            //Ensure all records get the same DateTime
            DateTime dtResponded = Datetime.now();

            //Create new Response Record
            AH_UDC_Response__c response = new AH_UDC_Response__c(
                                                                 Responded__c = dtResponded,
                                                                 RecordTypeId = recordTypeIdResponse,
                                                                 Responder__c = responseUser[0].Id,
                                                                 IsComplete__c = false);

            AH_UDC_Security.CreateObject(response);
            resp.responseId = response.Id;

            AH_UDC_LogHelper.Debug('###resp.responseId: ' + resp.responseId);
            // resp.isComplete = 'false';
            //Create new Workbook Step Response Record(s)
            List<AH_UDC_WorkbookStepResponse__c> wbsResponses = new List<AH_UDC_WorkbookStepResponse__c> ();
            AH_UDC_WorkbookStepResponse__c wbsResponse = new AH_UDC_WorkbookStepResponse__c(WorkbookStep__c = stepsSent[0].id,
                                                                                            Response__c = response.Id);
            wbsResponses.add(wbsResponse);

            if (sharedSentSteps != null && sharedSentSteps.size() > 0)
            {
               for (AH_UDC_WorkbookStep__c sharedSentStep : sharedSentSteps) {
                  wbsResponse = new AH_UDC_WorkbookStepResponse__c(WorkbookStep__c = sharedSentStep.id,
                                                                   Response__c = response.Id);
                  wbsResponses.add(wbsResponse);
               }
            }
            AH_UDC_LogHelper.Debug('###wbsResponses: ' + wbsResponses);
            if (wbsResponses != null && wbsResponses.size() > 0) { AH_UDC_Security.CreateObjects(wbsResponses); }
         }

         //The C# API should never send more than 9,000 ResponseQA Records in a request
         //Create the Response QA Records - for product form type only
         List<AH_UDC_ResponseQA__c> rQAs = new List<AH_UDC_ResponseQA__c> ();
         if (request.responseQAs != null)
         {
            for (QuestionAnswer qa : request.responseQAs) {
               if (String.isNotBlank(qa.QAJson))
               {
                  AH_UDC_ResponseQA__c rQA = new AH_UDC_ResponseQA__c(Response__c = resp.responseId,
                                                                      RecordTypeId = recordTypeIdQA,
                                                                      SortOrder__c = String.isNotBlank(qa.SO) ? integer.valueof(qa.SO) : null,
                                                                      QAJson__c = qa.QAJson);
                  rQAs.add(rQA);
               }
            }
            if (rQAs.size() > 0) {
               AH_UDC_Security.CreateObjects(rQAs);
            }
         }

         if (request.isComplete != null && request.isComplete.equalsIgnoreCase('true'))
         {
            //Update IsComplete to true at the end of inserting responseQA for the response         
            List<AH_UDC_Response__c> response = [SELECT Id, IsComplete__c FROM AH_UDC_Response__c WHERE Id = :request.responseId WITH SECURITY_ENFORCED];
            if (response.size() > 0)
            {
               response[0].IsComplete__c = true;
               AH_UDC_Security.updateObject(response[0]);
            }
            resp.isComplete = 'true';
         }

         resp.statusCode = '200';
         resp.message = 'Ok';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e) {
         AH_UDC_LogHelper.Debug('AH_UDC_REST_AmadeusFormResponse.Post - Exception: ' + e);

         if (objSavePoint != null) {
            Database.rollback(objSavepoint);
         }

         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_REST_AmadeusFormResponse',
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
            if (requestBody == 'writeQueuedLogsException') { Integer i = 1 / 0; }
            AH_UDC_LogHelper.writeQueuedLogs();
         }
         catch(Exception exc) {
            //If logs can't be written at least show an error in debug
            AH_UDC_LogHelper.Debug('AH_UDC_REST_AmadeusFormResponse.Post - Failed to write QueuedLogs');
         }
      }
   }

   @HttpGet
   global static void get() {
      AH_UDC_LogHelper.QueueLogs = true;

      //AH_UDC_LogHelper.Debug('###AmadeusFormResponseGetResponse');
      AmadeusFormResponseGetResponse resp = new AmadeusFormResponseGetResponse();
      try {
         RestRequest req = RestContext.request;

         String requestBody = '';
         if (req != null && req.requestBody != null) { requestBody = req.requestBody.toString(); }
         AH_UDC_LogHelper.Debug('requestBody: ' + requestBody);

         // AmadeusFormGetRequest request = (AmadeusFormGetRequest) JSON.deserialize(requestBody, AmadeusFormGetRequest.class);

         Id recordTypeIdResponse = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_AMADEUS_FORM).getRecordTypeId();
         Id recordTypeIdQA = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_AMADEUS_FORM).getRecordTypeId();

         //Bypass Token check and Response creation if a specific Response ID is included in the request
         String reqId = RestContext.request.params.get('responseId');
         integer iStartingSO = String.isBlank(RestContext.request.params.get('startSortOrder')) ? 0 : Integer.valueOf(RestContext.request.params.get('startSortOrder'));
         if (String.isNotBlank(reqId)) //RestContext.request.params.get('responseId')))        
         {
            resp.responseId = reqId; //request.responseId;
         }
         else
         {
            String token = RestContext.request.params.get('token');
            if (!token.startsWith(AH_UDC_Constants.FORM_TOKEN_PREFIX)) {
               resp.statusCode = '400';
               resp.message = 'Bad Request';
               RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
               return;
            }
            token = token.substring(AH_UDC_Constants.FORM_TOKEN_PREFIX.length());
            //AH_UDC_LogHelper.Debug('###Token: ' + token);

            if (Test.isRunningTest() && token == 'TestException') { integer i = 1 / 0; }
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

            AH_UDC_LogHelper.Debug('###FormId: ' + decryptedToken.FormId);

            Id amadeusFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM).getRecordTypeId();
            Id recordTypeIdFormFormAssembly = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();

            //Check that SecurityCode And FormId are for a valid step
            List<AH_UDC_WorkbookStep__c> stepsSent = [SELECT Id, Workbook__c, Workbook__r.ParentWorkbookSent__c, Form__r.Definition__c, Form__r.FormType__c, Workbook__r.Product__c
                                                      FROM AH_UDC_WorkbookStep__c
                                                      where Workbook__r.SecurityCode__c = :decryptedToken.SecurityCode
                                                      AND Form__c = :decryptedToken.FormId
                                                      AND Form__r.RecordTypeId = :AmadeusFormRecordTypeId
                                                      WITH SECURITY_ENFORCED LIMIT 1];
            AH_UDC_LogHelper.Debug('###stepsSent: ' + stepsSent);
            AH_UDC_LogHelper.Debug('###stepsSent Size: ' + stepsSent.size());

            if (stepsSent == null || stepsSent.size() == 0) {
               resp.statusCode = '404';
               resp.message = 'Not Found';
               RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
               return;
            }

            resp.formDefinition = stepsSent[0].Form__r.Definition__c;

            //Check for Dynamic picklist, if exist than get aprropriate value
            AH_UDC_Shared.AmadeusFormDefinition objFormDefinition =
            (AH_UDC_Shared.AmadeusFormDefinition) JSON.deserialize(resp.formDefinition, AH_UDC_Shared.AmadeusFormDefinition.class);
            objFormDefinition.product = stepsSent[0].Workbook__r.Product__c; //assign product in the definition

            //Use Definition to find dynamic controls(picklist/radio)
            Id formRecordTypeIdResponse = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
            AH_UDC_LogHelper.Debug('#Find Dynamic Picklists, Radio group & Text Defaults');
            List<AH_UDC_Shared.Field> lstDynamicPicklist = new List<AH_UDC_Shared.Field> ();
            List<AH_UDC_Shared.Field> lstDynamicRadioGroup = new List<AH_UDC_Shared.Field> ();
            List<AH_UDC_Shared.Field> lstDynamicDefault = new List<AH_UDC_Shared.Field> ();
            for (AH_UDC_Shared.section sec : objFormDefinition.sections) {
               lstDynamicRadioGroup.addAll(sec.getDynamicRadioGroups()); //add all the dynamic radiogroups in the list
               lstDynamicPicklist.addAll(sec.getDynamicPicklists()); //add all the dynamic picklists in the list
               lstDynamicDefault.addAll(sec.getDynamicDefaults()); //add all the dynamic defaults in the list

               if (sec.insidesections != null && sec.insidesections.size() > 0)
               {
                  for (AH_UDC_Shared.section insideSection : sec.insidesections)
                  {
                     lstDynamicRadioGroup.addAll(insideSection.getDynamicRadioGroups()); //add all the dynamic radiogroups in the list
                     lstDynamicPicklist.addAll(insideSection.getDynamicPicklists()); //add all the dynamic picklists in the list
                     lstDynamicDefault.addAll(sec.getDynamicDefaults()); //add all the dynamic defaults in the list
                  }
               }
            }

            //If there are dynamic sources them responses from other steps in this workbook or the parent workbook are needed
            if (lstDynamicPicklist.size() > 0 || lstDynamicRadioGroup.size() > 0 || lstDynamicDefault.size() > 0)
            {
               //Get the Step IDs for all Form Assembly Forms and Amadeus Forms in this and the parent workbook
               List<AH_UDC_WorkbookStep__c> allSteps;
               if (stepsSent[0].Workbook__r.ParentWorkbookSent__c == null)
               {
                  allSteps = [select Id, Workbook__c, Form__c, Workbook__r.ParentWorkbookSent__c, Form__r.RecordTypeId
                              from AH_UDC_WorkbookStep__c
                              where Workbook__c = :stepsSent[0].Workbook__c
                              AND Form__c != null
                              AND(Form__r.RecordTypeId = :recordTypeIdFormFormAssembly
                                  OR Form__r.RecordTypeId = :amadeusFormRecordTypeId)
                              WITH SECURITY_ENFORCED];
               } else {
                  allSteps = [SELECT Id, Workbook__c, Form__c, Workbook__r.ParentWorkbookSent__c, Form__r.RecordTypeId
                              FROM AH_UDC_WorkbookStep__c
                              WHERE(Workbook__c = :stepsSent[0].Workbook__c or Workbook__c = :stepsSent[0].Workbook__r.ParentWorkbookSent__c)
                              AND Form__c != null
                              AND(Form__r.RecordTypeId = :recordTypeIdFormFormAssembly
                                  OR Form__r.RecordTypeId = :amadeusFormRecordTypeId)
                              WITH SECURITY_ENFORCED];
               }
               List<Id> allStepsIds = new List<Id> ();
               Map<string, StepDetail> mapStepDetails = new Map<string, StepDetail> ();
               for (AH_UDC_WorkbookStep__c allStep : allSteps)
               {
                  allStepsIds.add(allStep.Id);
                  Boolean isParentWorkbookStep = allStep.Workbook__c == allStep.Workbook__r.ParentWorkbookSent__c;
                  Boolean isAamdeusForm = allStep.Form__r.RecordTypeId == amadeusFormRecordTypeId;
                  Boolean isFormAssemblyForm = allStep.Form__r.RecordTypeId == recordTypeIdFormFormAssembly;
                  mapStepDetails.put(allStep.Id, new StepDetail(allStep.Id, allStep.Workbook__c, allStep.Form__c, null, isParentWorkbookStep, isAamdeusForm, isFormAssemblyForm));
               }

               //Get Most Recent Workbook Step Responses for all steps that are Form Assembly Forms in the workbook or parent workbook
               List<AH_UDC_WorkbookStepResponse__c> mostRecentWbsResponses = [SELECT Response__c, WorkbookStep__c
                                                                              FROM AH_UDC_WorkbookStepResponse__c
                                                                              WHERE IsMostRecentResponse__c = true
                                                                              AND WorkbookStep__c in :allStepsIds WITH SECURITY_ENFORCED];

               for (AH_UDC_WorkbookStepResponse__c mostRecentWbsResponse : mostRecentWbsResponses)
               {
                  //Find Step
                  if (mapStepDetails.containsKey(mostRecentWbsResponse.WorkbookStep__c))
                  {
                     //Get the StepDetail and update the Response on it                    
                     mapStepDetails.get(mostRecentWbsResponse.WorkbookStep__c).MostRecentResponseId = mostRecentWbsResponse.Response__c;
                  }
               }

               //Values for Options and Picklists must come from the current workbook or parent workbook
               List<FindResponseQuestion> findResponseQuestions = new List<FindResponseQuestion> ();

               //Dynamic Radio button
               AH_UDC_LogHelper.Debug('###lstDynamicRadioGroup: ' + lstDynamicRadioGroup);
               for (AH_UDC_Shared.Field fs : lstDynamicRadioGroup)
               {
                  FindResponseQuestions.add(new FindResponseQuestion(fs.name, fs.dynamicsource.formid, fs.dynamicsource.formfield, 'OPTION'));
               }

               //Dynamic picklist
               AH_UDC_LogHelper.Debug('###lstDynamicPicklist: ' + lstDynamicPicklist);
               for (AH_UDC_Shared.Field fs : lstDynamicPicklist)
               {
                  FindResponseQuestions.add(new FindResponseQuestion(fs.name, fs.dynamicsource.formid, fs.dynamicsource.formfield, 'PICKLIST'));
               }

               //Dynamic default
               AH_UDC_LogHelper.Debug('###lstDynamicDefault: ' + lstDynamicDefault);
               for (AH_UDC_Shared.Field fs : lstDynamicDefault)
               {
                  FindResponseQuestions.add(new FindResponseQuestion(fs.name, fs.dynamicsource.formid, fs.dynamicsource.formfield, 'DEFAULT'));
               }

               //Loop through FindResponseQuestions that need to be found and assign them to responses that exist based on form id
               for (FindResponseQuestion frq : FindResponseQuestions)
               {
                  Id findParentResponseId = null;
                  Id findResponseId = null;
                  for (StepDetail findStepDetail : mapStepDetails.values())
                  {
                     if (findStepDetail.formId != frq.FindFormId) { continue; }

                     frq.IsAmadeusForm = findStepDetail.IsAmadeusForm;
                     frq.IsFormAssemblyForm = findStepDetail.IsFormAssemblyForm;
                     if (findStepDetail.isParentWorkbook)
                     {
                        findParentResponseId = findStepDetail.mostRecentResponseId;
                     } else {
                        findResponseId = findStepDetail.mostRecentResponseId;
                     }
                  }

                  if (findResponseId != null) { frq.ResponseId = findResponseId; }
                  else if (findParentResponseId != null) { frq.ResponseId = findParentResponseId; }
                  //Else there is no response so don't add any id
               }
               //Return the list to the calling c# so it can retreive the Amadeus Form Responses
               resp.findResponseQuestions = FindResponseQuestions;

               //NOTE: This SOQL will only get Form Assembly Responses as Amadeus Form JSON is too large

               //Get Current Workbook Responses for Picklists/Options/Defaults
               string sQuery = '';
               for (FindResponseQuestion frq : FindResponseQuestions)
               {
                  if (frq.IsFormAssemblyForm)
                  {
                     if (frq.ResponseId == null) { continue; }

                     if (sQuery != '') { sQuery += ' OR '; }
                     if (frq.FindType == 'PICKLIST')
                     {
                        sQuery += '(Response__c = \'' + frq.ResponseId + '\' and QuestionField__c LIKE \'' + frq.FindQuestionField + '[%]\') ';
                     } else {
                        sQuery += '(Response__c = \'' + frq.ResponseId + '\' and QuestionField__c =\'' + frq.FindQuestionField + '\') ';
                     }
                  }
               }
               if (sQuery != '')
               {
                  sQuery = 'select Response__c, QuestionField__c, Answer__c, AnswerField__c from AH_UDC_ResponseQA__c where ' + sQuery;

                  AH_UDC_LogHelper.Debug('$$$sQuery: ' + sQuery);

                  List<AH_UDC_ResponseQA__c> dQAs = Database.query(sQuery);

                  if (dQAs.size() > 0)
                  {
                     //Create frq map to speed loops below
                     Map<String, FindResponseQuestion> mapFindResponseQuestions = new Map<String, FindResponseQuestion> ();
                     for (FindResponseQuestion frq : FindResponseQuestions)
                     {
                        mapFindResponseQuestions.put(frq.ResponseId + '_' + frq.FindQuestionField, frq);
                     }

                     //Dynamic Radio Group
                     for (AH_UDC_Shared.Field dr : lstDynamicRadioGroup)
                     {
                        for (AH_UDC_ResponseQA__c dQA : dQAs) {
                           if (!mapFindResponseQuestions.containsKey(dQA.Response__c + '_' + dQA.QuestionField__c)) { continue; }

                           FindResponseQuestion frq = mapFindResponseQuestions.get(dQA.Response__c + '_' + dQA.QuestionField__c);
                           if (dr.dynamicsource.formid == frq.FindFormId
                               && dr.dynamicsource.formfield == frq.FindQuestionField)
                           {
                              List<AH_UDC_Shared.Source> src = dr.source;
                              for (integer i = 0; i<src.size(); i++)
                              {
                                 if (src[i].name.equalsIgnoreCase(dQA.Answer__c))
                                 {
                                    dr.defaultvalue = src[i].id; //assign dynamic value as default value to radiogroup
                                    break; //out of finding the default value in the posible values
                                 }
                              }
                              break; //out of drQA loop since only 1 value is needed
                           }
                        }
                     }

                     //Dynamic picklist
                     for (AH_UDC_Shared.Field dp : lstDynamicPicklist)
                     {
                        Integer i = 0;
                        List<AH_UDC_Shared.Source> lstSource = new List<AH_UDC_Shared.Source> ();
                        for (AH_UDC_ResponseQA__c dQA : dQAs)
                        {
                           //Multiple dQA records may match the Question Field since picklists have multiple values
                           string questionField = dQA.QuestionField__c;
                           if (questionField.contains('[')) { questionField = questionField.substring(0, questionField.indexOf('[')); }
                           AH_UDC_LogHelper.Debug('###questionField: ' + questionField + ' dp.dynamicsource.formfield: ' + dp.dynamicsource.formfield);

                           if (mapFindResponseQuestions.containsKey(dQA.Response__c + '_' + questionField))
                           {
                              FindResponseQuestion frq = mapFindResponseQuestions.get(dQA.Response__c + '_' + questionField);
                              if (dp.dynamicsource.formid == frq.FindFormId
                                  && dp.dynamicsource.formfield == frq.FindQuestionField && dQA.Answer__c != null)
                              {
                                 string id = dp.name + '-' + i;
                                 i++;
                                 AH_UDC_Shared.Source src = new AH_UDC_Shared.Source();
                                 src.id = dQA.Answer__c;
                                 src.name = dQA.Answer__c;
                                 lstSource.add(src); //Add all the dynamic options in the list
                              }
                           }
                        }
                        dp.source = lstSource; //Add options list to picklist source   
                        AH_UDC_LogHelper.Debug('###lstSource: ' + lstSource);
                     }

                     //Dynamic Default
                     for (AH_UDC_Shared.Field dr : lstDynamicDefault)
                     {
                        for (AH_UDC_ResponseQA__c dQA : dQAs) {
                           if (!mapFindResponseQuestions.containsKey(dQA.Response__c + '_' + dQA.QuestionField__c)) { continue; }

                           FindResponseQuestion frq = mapFindResponseQuestions.get(dQA.Response__c + '_' + dQA.QuestionField__c);
                           if (dr.dynamicsource.formid == frq.FindFormId && dr.dynamicsource.formfield == frq.FindQuestionField)
                           {
                               dr.defaultvalue = dQA.Answer__c; //assign dynamic value as default value to radiogroup                               
                           }
                           break; //out of drQA loop since only 1 value is needed
                        }
                     }
                  }
               }
            }

            //update form Definition after assigning product and dyamic default value
            resp.formDefinition = JSON.serialize(objFormDefinition);

            if (stepsSent[0].Form__r.FormType__c != AH_UDC_Constants.FORM_TYPE_CENTRAL)
            {
               //Get the newest Response that exists
               List<AH_UDC_WorkbookStepResponse__c> formWbsResponses = [SELECT Response__c
                                                                        FROM AH_UDC_WorkbookStepResponse__c
                                                                        WHERE IsMostRecentResponse__c = true
                                                                        AND WorkbookStep__c = :stepsSent[0].id
                                                                        WITH SECURITY_ENFORCED
                                                                        ORDER BY ID desc
                                                                        LIMIT 1];
               AH_UDC_LogHelper.Debug('###formResponses: ' + formWbsResponses.size());
               //If there is an existing response, load ResponseQAs
               if (formWbsResponses.size()> 0) {
                  resp.responseId = (String) formWbsResponses[0].Response__c;

                  //Get the Questions/Answers
                  // List<AH_UDC_ResponseQA__c> amadeusformQAs = new List<AH_UDC_ResponseQA__c> ();
                  // resp.QuestionAnswers = new List<QuestionAnswer> ();

                  integer rQACount = [SELECT COUNT()
                                      FROM AH_UDC_ResponseQA__c
                                      WHERE Response__c = :formWbsResponses[0].Response__c
                                      AND recordtypeid = :recordTypeIdQA WITH SECURITY_ENFORCED];

                  double rQABatch = rQACount / QA_JSON_MAX_PER_REQUEST;
                  resp.responseQABatches = String.valueOf(rQABatch).indexOf('.') == 0 ? String.valueOf(rQABatch) : String.valueOf(rQABatch + 1).substringBefore('.');
               }
               else {
                  resp.statusCode = '200';
                  resp.message = 'Ok';
                  RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
                  return;
               }
            }
         }

         resp.QuestionAnswers = new List<QuestionAnswer> ();
         for (AH_UDC_ResponseQA__c amadeusFormQA :[SELECT QAJson__c, SortOrder__c
              FROM AH_UDC_ResponseQA__c
              WHERE Response__c = :resp.responseId
              AND recordtypeid = :recordTypeIdQA
              AND SortOrder__c >= :iStartingSO
              WITH SECURITY_ENFORCED
              ORDER BY SortOrder__c ASC LIMIT :QA_JSON_MAX_PER_REQUEST]) {

            resp.QuestionAnswers.add(new QuestionAnswer(String.valueOf(amadeusFormQA.QAJson__c), String.valueOf(amadeusFormQA.SortOrder__c)));
         }

         AH_UDC_LogHelper.Debug('###resp.QuestionAnswers size: ' + resp.QuestionAnswers.size());

         resp.statusCode = '200';
         resp.message = 'Ok';
         RestContext.response.responseBody = Blob.valueOf(resp.compileResponse());
      }
      catch(Exception e) {
         AH_UDC_LogHelper.Debug('###Exception: ' + e);

         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_REST_AmadeusFormResponse', 'get',
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
            AH_UDC_LogHelper.Debug('AH_UDC_REST_AmadeusFormResponse.Get - Failed to write QueuedLogs');
         }
      }
   }

   @TestVisible
   private class StepDetail {
      public Id StepId;
      public Id WorkbookId;
      public String FormId;
      public Id MostRecentResponseId;
      public Boolean IsParentWorkbook = false;
      public Boolean IsAmadeusForm = false;
      public Boolean IsFormAssemblyForm = false;

      public StepDetail(Id stepId, Id workbookId, String formId, Id mostRecentResponseId, Boolean isParentWorkbook, Boolean IsAmadeusForm, Boolean IsFormAssemblyForm)
      {
         this.StepId = stepId;
         this.WorkbookId = workbookId;
         this.FormId = formId;
         this.MostRecentResponseId = mostRecentResponseId;
         this.IsParentWorkbook = isParentWorkbook;
         this.IsAmadeusForm = IsAmadeusForm;
         this.IsFormAssemblyForm = IsFormAssemblyForm;
      }
   }

   @TestVisible
   private class FindResponseQuestion {
      public String FormField;
      public String FindFormId;
      public String FindQuestionField;
      public String FindType;
      public String ResponseId;
      public Boolean IsAmadeusForm = false;
      public Boolean IsFormAssemblyForm = false;

      public FindResponseQuestion(string formField, string findFormId, string findQuestionField, string findType) {
         this.FormField = formField;
         this.FindFormId = findFormId;
         this.FindQuestionField = findQuestionField;
         this.FindType = findType;
      }
   }

   @TestVisible
   private class AmadeusFormPostRequest {
      public String token;
      public String responseId;
      public String isComplete;
      public List<QuestionAnswer> ResponseQAs;
   }

   @TestVisible
   private class AmadeusFormGetRequest {
      public String token;
      public String responseId;
      public String startSortOrder;
      public String isComplete;
   }

   @TestVisible
   private class QuestionAnswer {
      public String QAJson;
      public String SO; //SortOrder
      public QuestionAnswer() { }
      public QuestionAnswer(string QAJson, string SortOrder)
      {
         this.QAJson = QAJson;
         this.SO = SortOrder;
      }
   }

   @TestVisible
   private class AmadeusFormResponsePostResponse {
      public String statusCode;
      public String message;
      public String exceptionMessage;
      public String responseId;
      public String isComplete;
      public AmadeusFormResponsePostResponse() { statusCode = ''; }

      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this);
      }
   }

   @TestVisible
   private class AmadeusFormResponseGetResponse {
      public String statusCode;
      public String message;
      public String responseId;
      public String formDefinition;
      public String responseQABatches;
      public List<QuestionAnswer> QuestionAnswers;
      public List<FindResponseQuestion> FindResponseQuestions;
      public AmadeusFormResponseGetResponse() 
      { 
         QuestionAnswers = new List<QuestionAnswer> (); 
         FindResponseQuestions = new List<FindResponseQuestion> ();
      }

      //Convert response to the JSON format
      public String compileResponse() {
         return JSON.serialize(this);
      }
   }
}