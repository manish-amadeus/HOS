/**
 * Name          : AH_UDC_SharedWithoutSharing
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-Feb-02
 * Description   : Re-usable common methods for UDC code that do NOT enforce Object/FLS security (WITHOUT SHARING)
 * Dependencies  : 
 **/
public without sharing class AH_UDC_SharedWithoutSharing {
   //NOTE: Move the methods in AH_UDC_Shared.cls that need to run without FLS security to this file

   //This message attaches chatter to the NI_Documentation__c object with a @ Mention to the owner of the record
   public enum CreateChatterMessageType { WorkbookAccessed, WorkbookComplete, WorkbookStepComplete }

<<<<<<< HEAD
=======
   //This method is called by a CommunityUser to create chatter on the NI Documenation object
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
   public static Boolean CreateChatter(String NIDocumentationId, ID WorkbookStepSentId, CreateChatterMessageType messageType) {
      try {
         //AH_UDC_LogHelper.Debug('CreateChatter');
         //AH_UDC_LogHelper.Debug('CreateChatter: NIDocumentationId: ' + String.valueOf(NIDocumentationId));
         //AH_UDC_LogHelper.Debug('CreateChatter: WorkbookStepSentId: ' + String.valueOf(WorkbookStepSentId));
         //AH_UDC_LogHelper.Debug('CreateChatter: messageType: ' + String.valueOf(messageType));

         if (Test.isRunningTest() && NIDocumentationId == 'TestException') { Integer i = 1 / 0; }

         List<NI_Documentation__c> niDoc = [SELECT Id, Name, Document_Name__c, ownerid FROM NI_Documentation__c WHERE Id = :NIDocumentationId];
         if (niDoc == null || niDoc.size() != 1) {
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                                 'AH_UDC_SharedWithoutSharing', 'CreateChatter',
                                 'NI Documentation Record Not Found',
                                 null, NIDocumentationId, 'NI_Documentation__c');
            return false;
         }

         List<AH_UDC_WorkbookStep__c> wbStep = null;
         if (messageType == CreateChatterMessageType.WorkbookStepComplete) {
            wbStep = [SELECT Id, Name FROM AH_UDC_WorkbookStep__c WHERE Id = :WorkbookStepSentId];
            if (wbStep == null || wbStep.size() != 1) {
               AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                                    'AH_UDC_SharedWithoutSharing', 'CreateChatter',
                                    'Workbook Step Record Not Found',
                                    null, WorkbookStepSentId, 'AH_UDC_WorkbookStep__c');
               return false;
            }
         }

         String postText = '';
         if (messageType == CreateChatterMessageType.WorkbookAccessed) {
            postText = String.valueOf(Label.AH_UDC_Chatter_WorkbookAccessed).replace('{!Name}', niDoc[0].Document_Name__c);
         } else if (messageType == CreateChatterMessageType.WorkbookComplete) {
            postText = Label.AH_UDC_Chatter_WorkbookComplete.replace('{!Name}', niDoc[0].Document_Name__c);
         } else if (messageType == CreateChatterMessageType.WorkbookStepComplete) {
            postText = Label.AH_UDC_Chatter_WorkbookStepComplete.replace('{!Name}', niDoc[0].Document_Name__c).replace('{!StepName}', wbStep[0].Name);
         } else {
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                                 'AH_UDC_SharedWithoutSharing', 'CreateChatter',
                                 'Unhandled CreateChatterMessageType',
                                 null, null, null);
            return false;
         }

         //This code performs a callout to a C# API to create the chatter using the UDC Service User
         Http h1 = new Http();
         HttpRequest req1 = new HttpRequest();
         req1.setHeader('Content-Type', 'application/json');
         req1.setHeader('accept', 'application/json');
         req1.setMethod('POST');
         AH_UDC_REST_Chatter.ChatterRequest chatterRequest = new AH_UDC_REST_Chatter.ChatterRequest();
         chatterRequest.NIDocumentId = niDoc[0].id;
         chatterRequest.Message = postText;
         req1.setBody(JSON.serialize(chatterRequest));
         req1.setTimeout((AH_UDC_ConfigHelper.GetInteger('AH_UDC_ChatterTimeout', 120) * 1000));
         string endpointURL = AH_UDC_ConfigHelper.GetString('AH_UDC_ChatterUrl', '');
         req1.setEndpoint(endpointURL);

         HttpResponse httpResp = null;
         AH_UDC_REST_Chatter.ChatterResponse resp;

         AH_UDC_LogHelper.Debug('Chatter: Post Request');
         httpResp = h1.send(req1);
         Integer httpStatus = httpResp.getStatusCode();
<<<<<<< HEAD
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_TRACE,'AH_UDC_SharedWithoutSharing','CreateChatter','Trace Response: ' + httpResp.getbody(),null,null,null);
         string sResp = httpResp.getbody().replace('\\','');
         if(sResp.left(1)=='"') sResp = sResp.substring(1,sResp.length()-1);
         resp = (AH_UDC_REST_Chatter.ChatterResponse) JSON.deserialize(sResp, AH_UDC_REST_Chatter.ChatterResponse.class);
         
=======
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_TRACE, 'AH_UDC_SharedWithoutSharing', 'CreateChatter', 'Trace Response: ' + httpResp.getbody(), null, null, null);

         string sResp = httpResp.getbody();
         if (sResp.left(1) == '"') sResp = sResp.substring(1, sResp.length() - 1);
         if (sResp.startsWith('{\\"')) sResp = sResp.replace('\\"', '"');
         AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.CreateChatter: Deserializing ChatterResponse: ' + sResp);
         try {
            if (sResp.left(1) == '"') sResp = sResp.substring(1, sResp.length() - 1);
            resp = (AH_UDC_REST_Chatter.ChatterResponse) JSON.deserialize(sResp, AH_UDC_REST_Chatter.ChatterResponse.class);
         }
         catch(exception exc) {
            AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.CreateChatter: Exception: ' + exc);
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                                 'AH_UDC_SharedWithoutSharing', 'CreateChatter',
                                 'ChatterResponse Exception: ' + exc.getMessage() + ' at line number ' + exc.getLineNumber(),
                                 exc, NIDocumentationId, 'NI_Documentation__c');
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_AUDIT,
                                 'AH_UDC_SharedWithoutSharing', 'CreateChatter',
                                 'Invalid ChatterResponse: ' + sResp,
                                 exc, NIDocumentationId, 'NI_Documentation__c');
            return false;
         }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
         if (httpStatus == 200) {
            String msg = + resp.Message + ' Code: ' + resp.StatusCode;
            AH_UDC_LogHelper.Debug('Chatter: ' + msg);
            if (resp.StatusCode != '200') {
               AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR, 'AH_UDC_SharedWithoutSharing', 'CreateChatter', 'An error creating chatter:' + msg, null, niDoc[0].id, 'NIDocument');
               return false;
            }
         } else {
<<<<<<< HEAD
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR, 'AH_UDC_SharedWithoutSharing', 'CreateChatter', 'Unknown HTTP Status when calling endpoint: ' + String.valueOf(resp.StatusCode),null, UserInfo.getUserId(), 'User');
=======
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR, 'AH_UDC_SharedWithoutSharing', 'CreateChatter', 'Unknown HTTP Status when calling endpoint: ' + String.valueOf(resp.StatusCode), null, UserInfo.getUserId(), 'User');
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
            return false;
         }

         AH_UDC_LogHelper.Debug('CreateChatter: CREATED');
         return true;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('CreateChatter: Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_SharedWithoutSharing', 'CreateChatter',
<<<<<<< HEAD
                              'Unhandled Exception: ' + exc.getMessage(),
=======
                              'Unhandled Exception: ' + exc.getMessage() + ' at line number ' + exc.getLineNumber(),
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
                              exc, NIDocumentationId, 'NI_Documentation__c');
         return false;
      }
   }

   //This method is used to get a Workbook Step Sent URL.  Since the URL is based on the most recent response it must be dynamically generated.
   public static Map<Id, String> GetWorkbookStepSentUrls(List<AH_UDC_WorkbookStep__c> workbookStepsSent) {
      //There is purposely no try/catch here

      List<Id> ids = new List<Id> ();
      for (AH_UDC_WorkbookStep__c wss : workbookStepsSent) {
         ids.add(wss.Id);
      }
      return GetWorkbookStepSentUrls(ids);
   }

   //This method is used to get a Workbook Step Sent URL.  Since the URL is based on the most recent response it must be dynamically generated.
   public static string GetWorkbookStepSentUrl(Id stepId) {
      //There is purposely no try/catch here

      List<Id> ids = new List<Id> ();
      ids.add(StepId);
      Map<Id, String> stepUrls = GetWorkbookStepSentUrls(ids);
      if (stepUrls != null && stepUrls.containsKey(stepId)) { return stepUrls.get(stepId); }
      return null;
   }

   //This method is used to get a Workbook Step Sent URL.  Since the URL is based on the most recent response it must be dynamically generated.
   public static Map<Id, String> GetWorkbookStepSentUrls(List<ID> workbookStepSentIds) {
      //NOTE: logging is not allowed due to this method being called by a constructor; as such NULL is passed back

      string workbookStepSentUrl = null;
      Map<Id, String> wbsStepUrls = new Map<Id, String> ();
      try {
         Id recordTypeIdResponse = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
         Id recordTypeIdQA = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();
         Id recordTypeFormAssembly = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();

         List<AH_UDC_WorkbookStep__c> wbSteps = [SELECT Url__c, Workbook__r.SecurityCode__c, Workbook__r.ParentWorkbookSent__r.SecurityCode__c,
                                                 Form__c, Form__r.id, Form__r.RecordTypeId, Form__r.URL__c, Form__r.Definition__c,
                                                 Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c, Workbook__r.Product__c
                                                 FROM AH_UDC_WorkbookStep__c
                                                 WHERE Id in :WorkbookStepSentIds];

         if (wbSteps.size() != workbookStepSentIds.size()) {
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                                 'AH_UDC_SharedWithoutSharing', 'GetWorkbookStepSentUrls',
                                 'One or more Workbook Steps Not Found',
                                 null, null, null);
            return null;
         }

         for (AH_UDC_WorkbookStep__c wbStep : wbSteps) {
            //Determine if this is a form or an external URL
            if (wbStep.Form__c == null && String.isNotBlank(wbStep.URL__c)) {
               //Return the External URL
               wbsStepUrls.put(wbStep.Id, wbStep.URL__c);
               return wbsStepUrls;
            }

            if (wbStep.Form__r.RecordTypeId != recordTypeFormAssembly) { continue; } //these steps are not needed for non Form Assembly forms

            string formDefinition = (string) wbStep.getSobject('Form__r').get('Definition__c');
            AH_UDC_LogHelper.Debug('FormDef: ' + formDefinition);
            if (formDefinition == null) return null;
            AH_UDC_Shared.FormDefinition fd = (AH_UDC_Shared.FormDefinition) JSON.deserialize(formDefinition, AH_UDC_Shared.FormDefinition.class);
            string securityCodeTFA = fd.getFieldByName('Security Code').APIName;
            AH_UDC_LogHelper.Debug('SecurityCodeTFA: ' + securityCodeTFA);
            if (securityCodeTFA == null) return null;
            string tokenTFA = fd.getFieldByName('Token').APIName;
            AH_UDC_LogHelper.Debug('TokenTFA: ' + tokenTFA);
            if (tokenTFA == null) return null;

            AH_UDC_Shared.FormField ffParentSecurityCode = fd.getFieldByName('Parent Security Code');
            string parentSecurityCodeTFA = null;
            if (ffParentSecurityCode != null) { parentSecurityCodeTFA = ffParentSecurityCode.APIName; }
            //This is not an error if the field is not found

            AH_UDC_Shared.FormField ffProduct = fd.getFieldByName('Product');
            string productTFA = null;
            if (ffProduct != null) { productTFA = ffProduct.APIName; }
            //This is not an error if the field is not found

            //Generate Token
            string token = AH_UDC_Shared.CreateStepToken(wbStep.Workbook__r.SecurityCode__c, wbStep.Form__c, wbStep.Id);

            //Build Base URL with required attributes
            workbookStepSentUrl = wbStep.Form__r.URL__c;
            workbookStepSentUrl += '?' + tokenTFA + '=' + token;
            workbookStepSentUrl += '&' + securityCodeTFA + '=' + wbStep.getSobject('Workbook__r').get('SecurityCode__c');

            if (parentSecurityCodeTFA != null
                && wbStep.getSobject('Workbook__r').getSobject('ParentWorkbookSent__r') != null) {
               workbookStepSentUrl += '&' + parentSecurityCodeTFA + '=' + wbStep.getSobject('Workbook__r').getSobject('ParentWorkbookSent__r').get('SecurityCode__c');
            }

            if (productTFA != null && wbStep.getSobject('Workbook__r').get('Product__c') != null) {
               string escapedProductValue = wbStep.Workbook__r.Product__c;
               escapedProductValue = escapedProductValue.replace('&', '%26'); //Escape &
               workbookStepSentUrl += '&' + productTFA + '=' + escapedProductValue;
            }

            //Find the most recent response
<<<<<<< HEAD
            Id propertyAccount = (Id) wbStep.getSobject('Workbook__r').getSobject('RelatedTo__r').get('AH_UDC_PropertyAccount__c');
=======
            //TODO: ROBDEV : Id propertyAccount = (Id) wbStep.getSobject('Workbook__r').getSobject('RelatedTo__r').get('AH_UDC_PropertyAccount__c');
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
            List<AH_UDC_WorkbookStepResponse__c> wbsResponses = [SELECT Response__c
                                                                 FROM AH_UDC_WorkbookStepResponse__c
                                                                 WHERE IsMostRecentResponse__c = true
                                                                 AND WorkbookStep__c = :wbStep.Id
                                                                 ORDER BY createddate desc //this shouldn't be needed since only 1 record should have IsMostRecentResponse=true ... but best to be safe
                                                                 LIMIT 1];
            //It's ok if there are no responses; proceed if there are
            //AH_UDC_LogHelper.Debug('formResponses.size(): ' + formResponses.size());
            //AH_UDC_LogHelper.Debug('formResponses[0].id: ' + formResponses[0].id);
            if (wbsResponses.size() > 0) {
               //Since this is a form check for Responses to add Repeating Field placeholders to the URL
               List<AH_UDC_ResponseQA__c> responseQAs = [SELECT QuestionField__c
                                                         FROM AH_UDC_ResponseQA__c
                                                         WHERE Response__c = :wbsResponses[0].Response__c];

               //group by QuestionField__c having COUNT(id) > 1
               Map<String, Integer> groupFields = new Map<String, Integer> ();
               for (AH_UDC_ResponseQA__c responseQA : responseQAs) {
                  AH_UDC_LogHelper.Debug('$$$responseQA.QuestionField__c: ' + responseQA.QuestionField__c);
                  string questionField = responseQA.QuestionField__c;
                  //If question field has two []'s then only use QAs ending in [0]
                  if (questionField.contains('][') && !questionField.endsWith('[0]'))
                  {
                     //Ignore and do not count as repeat : example "tfa_18[0][1]"
                     AH_UDC_LogHelper.Debug('$$$Ignore: ' + questionField);
                  }
                  else
                  {
                     if (questionField.contains('[')) { questionField = questionField.substringBefore('['); }
                     AH_UDC_LogHelper.Debug('$$$questionField: ' + questionField);

                     if (groupFields.containsKey(questionField)) {
                        groupFields.put(questionField, groupFields.get(questionField) + 1);
                        AH_UDC_LogHelper.Debug('$$$groupFields increment: ' + questionField);
                     } else {
                        groupFields.put(questionField, 1);
                        AH_UDC_LogHelper.Debug('$$$groupFields add: ' + questionField);
                     }
                  }
               }

               System.Debug('$$$groupFields.size: ' + groupFields.size());
               Map<String, Integer> repeatTotals = new Map<String, Integer> ();
               if (groupFields.size() > 0) {
                  for (string key : groupFields.keySet()) {
                     System.Debug('$$$groupFields key: ' + key);

                     Integer repeatCount = groupFields.get(key);

                     System.Debug('$$$groupFields repeatCount: ' + repeatCount);

                     if (repeatCount > 1) {
                        //Get the Repeat ID for the field
                        repeatCount = Integer.valueOf(repeatCount) - 1;
                        AH_UDC_Shared.FormField formField = fd.getFieldByAPIName(key);

                        System.Debug('$$$groupFields formField: ' + formField);

                        if (FormField != null && formField.Repeat != null) {
                           if (repeatTotals.containsKey(formField.Repeat))
                           {
                              if (repeatTotals.get(formField.Repeat) < repeatCount)
                              {
                                 repeatTotals.put(formField.Repeat, repeatCount);
                              }
                           }
                           else
                           {
                              repeatTotals.put(formField.Repeat, repeatCount);
                           }
                        }
                     }
                  }
               }

               for (string key : repeatTotals.keySet()) {
                  System.Debug('$$$repeatTotals key: ' + key);

                  Integer repeatCount = repeatTotals.get(key);

                  workbookStepSentUrl += '&' + key + '=' + String.valueOf(repeatCount);
                  System.Debug('$$$groupFields WorkbookStepSentUrl add: ' + '&' + key + '=' + String.valueOf(repeatCount));
               }
            }
            System.Debug('$$$WorkbookStepSentUrl: ' + workbookStepSentUrl);

            wbsStepUrls.put(wbStep.Id, workbookStepSentUrl);
         }
         return wbsStepUrls;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.GetWorkbookStepSentUrls: Exception: ' + exc.getMessage() + ' at line number ' + exc.getLineNumber());
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_SharedWithoutSharing', 'GetWorkbookStepSentUrls',
<<<<<<< HEAD
                              'Unhandled Exception: ' + exc.getMessage(),
=======
                              'Unhandled Exception: ' + exc.getMessage() + ' at line number ' + exc.getLineNumber(),
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
                              exc, null, null);
         return null;
      }
   }

   public static Boolean SetupCommunityAccess(String ContactId) {
      try {
         AH_UDC_LogHelper.Debug('SetupCommunityAccess : AH_UDC_CreateCommunityUserEnabled : ' + AH_UDC_ConfigHelper.GetBoolean('AH_UDC_CreateCommunityUserEnabled', true));
         if (!AH_UDC_ConfigHelper.GetBoolean('AH_UDC_CreateCommunityUserEnabled', true)) { return true; } //If it's creating community users is not enabled return true;
<<<<<<< HEAD

         if (Test.isRunningTest() && ContactId == 'TestException') { Integer i = 1 / 0; }

         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_ChangeCommunityUserProfile',FALSE)) { throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'SetupCommunityAccess')); }
=======

         if (Test.isRunningTest() && ContactId == 'TestException') { Integer i = 1 / 0; }

         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestChangeCommunityUserProfile', FALSE, true)) { throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'SetupCommunityAccess')); }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a

         //This is the Community User Post Fix that all users of the community get in their username
         string CommunityUserNamePostFix = AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostFix',
                                                                         AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX);

         //Get User Profile
         Profile oProfile = [SELECT Id FROM Profile WHERE Name = :AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER,
                                                                                                AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER)];
         AH_UDC_LogHelper.Debug('SetupCommunityAccess : oProfile : ' + oProfile);
         if (oProfile == null) {
            AH_UDC_LogHelper.Debug('SetupCommunityAccess : Community Profile didn\'t exist');
<<<<<<< HEAD
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,'AH_UDC_SharedWithoutSharing', 'SetupCommunityAccess','Profile not found: ' + AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER, null, null, null);
=======
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR, 'AH_UDC_SharedWithoutSharing', 'SetupCommunityAccess', 'Profile not found: ' + AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER, null, null, null);
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
            return false;
         }

         //Verify Contact is Valid
         List<Contact> contacts = [SELECT Id, Account.Owner.UserRoleid, LastName, FirstName, email FROM contact WHERE Id = :ContactId];
<<<<<<< HEAD
         if (contacts.size() != 1) { return false; } //Contact not found
=======
         if (contacts.size() != 1) {
            AH_UDC_LogHelper.Debug('Contact ID Not Found: ' + ContactId);
            return false;
         } //Contact not found
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a

         AH_UDC_LogHelper.Debug('SetupCommunityAccess : contacts[0].getSObject(\'Account\') :' + contacts[0].getSObject('Account'));
         AH_UDC_LogHelper.Debug('SetupCommunityAccess : contacts[0].getSObject(\'Account\').getSObject(\'Owner\') :' + contacts[0].getSObject('Account').getSObject('Owner'));
         AH_UDC_LogHelper.Debug('SetupCommunityAccess : contacts[0].getSObject(\'Account\').getSObject(\'Owner\').get(\'UserRoleid\') :' + contacts[0].getSObject('Account').getSObject('Owner').get('UserRoleid'));
         //Verify Contact has role
         if (contacts[0].getSObject('Account') == null ||
             contacts[0].getSObject('Account').getSObject('Owner') == null ||
<<<<<<< HEAD
             contacts[0].getSObject('Account').getSObject('Owner').get('UserRoleid') == null) 
             return false; //Contact does not have role cannot add user
=======
             contacts[0].getSObject('Account').getSObject('Owner').get('UserRoleid') == null)
         return false; //Contact does not have role cannot add user
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a

         AH_UDC_LogHelper.Debug('SetupCommunityAccess : contacts[0].Email :' + contacts[0].Email);
         //Verify Contact has email
         if (String.isEmpty(contacts[0].Email)) return false; //Contact does not have an email address

         //Find Contact's User if it exists
         List<User> users = [SELECT Id FROM User WHERE ContactId = :contacts[0].Id AND IsActive = true];
         AH_UDC_LogHelper.Debug('SetupCommunityAccess : users.size() :' + users.size());
         //If Contact Doesn't have user create one
         Id targetUserId = null;
<<<<<<< HEAD
=======
         AH_UDC_REST_CreateCommunityUser.CreateCommunityUserRequest ccuRequest = new AH_UDC_REST_CreateCommunityUser.CreateCommunityUserRequest();
         Boolean hasCommunityUserPermissionSet = false;
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
         if (users.size() == 0) {
            //Determine User Id
            string random = '';
            string orgPrefix = '';
            orgPrefix = AH_UDC_ConfigHelper.GetString('AH_UDC_CreateCommunityUserOrgPrefix', '');
            string usernameAppend = orgPrefix + CommunityUserNamePostFix;
            string userName = contacts[0].email.left(78 - usernameAppend.length()) + usernameAppend;
            string nickname = contacts[0].FirstName.left(15) + '_' + contacts[0].LastName.left(20);

            //Check if user name / nickname exists
            Boolean validUserName = false;
            //Max 5 attempts to find unique names
            for (integer iAttempts = 0; iAttempts< 5; iAttempts++) {
               AH_UDC_LogHelper.Debug('SetupCommunityAccess : username :' + username);
               AH_UDC_LogHelper.Debug('SetupCommunityAccess : nickname :' + nickname);
               List<AggregateResult> existingUsers = [SELECT COUNT(Id) usercount FROM User WHERE Username = :username OR CommunityNickname = :nickname];
               AH_UDC_LogHelper.Debug('SetupCommunityAccess : existingUsers[0].get(\'usercount\') : ' + existingUsers[0].get('usercount'));
               if (existingUsers[0].get('usercount') == 0) {
                  validUserName = true;
                  break;
               }

               //Generate Random 3 digit and add to username/nickname and try again
               Integer randomNumber = Integer.valueof((Math.random() * 100));
               random = string.valueOf(randomNumber).leftPad(3, '0');

               usernameAppend = '.' + random + orgPrefix + CommunityUserNamePostFix;
               userName = contacts[0].email.left(78 - usernameAppend.length()) + usernameAppend;

               nickname = contacts[0].FirstName.left(15) + '_' + contacts[0].LastName.left(20) + '_' + random;
            }

            AH_UDC_LogHelper.Debug('SetupCommunityAccess : ValidUserName :' + validUserName);
            if (!validUserName) { return false; } //Could not find a valid user name

<<<<<<< HEAD
            AH_UDC_REST_CreateCommunityUser.CreateCommunityUserRequest ccuRequest = new AH_UDC_REST_CreateCommunityUser.CreateCommunityUserRequest();
=======
            ccuRequest = new AH_UDC_REST_CreateCommunityUser.CreateCommunityUserRequest();
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
            ccuRequest.FirstName = contacts[0].FirstName;
            ccuRequest.lastName = contacts[0].LastName;
            ccuRequest.ContactId = contacts[0].Id;
            ccuRequest.Username = userName; //Max Length 80
            ccuRequest.Email = contacts[0].Email;
            ccuRequest.CommunityNickname = nickname; //Max Length 40
            ccuRequest.Alias = contacts[0].FirstName.left(3) + contacts[0].LastName.left(5);
            ccuRequest.TimeZoneSidKey = 'America/New_York';
            ccuRequest.LocaleSidKey = 'en_US';
            ccuRequest.EmailEncodingKey = 'ISO-8859-1';
            ccuRequest.LanguageLocaleKey = 'en_US';
            ccuRequest.ProfileId = oProfile.Id;
<<<<<<< HEAD

=======
         }
         else {
            ccuRequest.ExistingUserId = users[0].Id;
            List<PermissionSet> cuPermissionSets = [SELECT Id FROM PermissionSet Where Name = :AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetCommunityUser', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER)];
            if (cuPermissionSets.size() != 0) {
               List<PermissionSetAssignment> psAssignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :users[0].Id and PermissionSetId = :cuPermissionSets[0].id];
               if (psAssignments.size() >  0) hasCommunityUserPermissionSet = true;
            }
         }
         if(!hasCommunityUserPermissionSet){
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
            //This code performs a callout to a C# API to create the community user
            Http httpCCU = new Http();
            HttpRequest wrCCU = new HttpRequest();
            wrCCU.setHeader('Content-Type', 'application/json');
            wrCCU.setHeader('accept', 'application/json');
            wrCCU.setMethod('POST');
            wrCCU.setBody(JSON.serialize(ccuRequest));
            wrCCU.setTimeout((AH_UDC_ConfigHelper.GetInteger('AH_UDC_CreateCommunityUserTimeout', 120) * 1000));
            wrCCU.setEndpoint(AH_UDC_ConfigHelper.GetString('AH_UDC_CreateCommunityUserUrl', ''));
            AH_UDC_LogHelper.Debug('CommunityUser: Post Request');
            HttpResponse httpRespCCU = httpCCU.send(wrCCU);
            Integer httpStatus = httpRespCCU.getStatusCode();

            if (httpStatus == 200) {
<<<<<<< HEAD
               AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_TRACE,'AH_UDC_SharedWithoutSharing','SetupCommunityAccess','Trace Response: ' + httpRespCCU.getbody(),null,null,null);
               string sResp = httpRespCCU.getbody().replace('\\','');
               if(sResp.left(1)=='"') sResp = sResp.substring(1,sResp.length()-1);
               AH_UDC_REST_CreateCommunityUser.CreateCommunityUserResponse respCCU = (AH_UDC_REST_CreateCommunityUser.CreateCommunityUserResponse) JSON.deserialize(sResp, AH_UDC_REST_CreateCommunityUser.CreateCommunityUserResponse.class);
         
               String msg = + respCCU.Message + ' Code: ' + respCCU.StatusCode;
               AH_UDC_LogHelper.Debug('CreateCommunityUser: ' + msg);
               if (respCCU.StatusCode != '200') {
                  AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,'AH_UDC_SharedWithoutSharing', 'SetupCommunityAccess','An error creating Community User:' + msg, null, ccuRequest.ContactId , 'ContactId');
                  return false;
               }
               targetUserId = respCCU.contactId;
            } else {
               AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,'AH_UDC_SharedWithoutSharing', 'SetupCommunityAccess','Unknown HTTP Status when calling endpoint: ' + String.valueOf(httpStatus), null, UserInfo.getUserId(), 'User');
               return false;
            }
         } else {
            targetUserId = users[0].Id;
         }

         // Grant User Permission Set for Community User
         if (!Test.isRunningTest()) //TODO: ROBDEV: Maybe figure out how to avoid this
         {
            Boolean gupsResult = GrantUserPermissionSet(targetUserId, AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetCommunityUser', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER));
            AH_UDC_LogHelper.Debug('SetupCommunityAccess : gupsResult :' + gupsResult);
            if (!gupsResult) { return false; } //Adding permisions set failed - do not rollback user if one was created
         }
=======
               AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_TRACE, 'AH_UDC_SharedWithoutSharing', 'SetupCommunityAccess', 'Trace Response: ' + httpRespCCU.getbody(), null, null, null);
               string sResp = httpRespCCU.getbody();
               AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.SetupCommunityAccess: Deserializing CreateCommunityUserResponse: ' + sResp);
               if (sResp.left(1) == '"') sResp = sResp.substring(1, sResp.length() - 1);
               if (sResp.startsWith('{\\"')) sResp = sResp.replace('\\"', '"');
               AH_UDC_REST_CreateCommunityUser.CreateCommunityUserResponse respCCU;
               try {
                  respCCU = (AH_UDC_REST_CreateCommunityUser.CreateCommunityUserResponse) JSON.deserialize(sResp, AH_UDC_REST_CreateCommunityUser.CreateCommunityUserResponse.class);
               }
               catch(Exception exc) {
                  AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.SetupCommunityAccess: Exception: ' + exc);
                  AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                                       'AH_UDC_SharedWithoutSharing', 'SetupCommunityAccess',
                                       'Unhandled Exception: ' + exc.getMessage() + ' at line number ' + exc.getLineNumber(),
                                       exc, ContactId, 'Contact');
                  AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_AUDIT,
                                       'AH_UDC_SharedWithoutSharing', 'SetupCommunityAccess',
                                       'Invalid CreateCommunityUserResponse: ' + sResp,
                                       exc, ContactId, 'Contact');
                  return false;
               }
               String msg = + respCCU.Message + ' Code: ' + respCCU.StatusCode;
               AH_UDC_LogHelper.Debug('CreateCommunityUser: ' + msg);
               if (respCCU.StatusCode != '200') {
                  AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR, 'AH_UDC_SharedWithoutSharing', 'SetupCommunityAccess', 'An error creating Community User:' + msg, null, ccuRequest.ContactId, 'ContactId');
                  return false;
               }
               targetUserId = respCCU.userId;
            } else {
               AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR, 'AH_UDC_SharedWithoutSharing', 'SetupCommunityAccess', 'Unknown HTTP Status when calling endpoint: ' + String.valueOf(httpStatus), null, UserInfo.getUserId(), 'User');
               return false;
            }
         }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
         return true;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.SetupCommunityAccess: Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_SharedWithoutSharing', 'SetupCommunityAccess',
<<<<<<< HEAD
                              'Unhandled Exception: ' + exc.getMessage(),
=======
                              'Unhandled Exception: ' + exc.getMessage() + ' at line number ' + exc.getLineNumber(),
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
                              exc, ContactId, 'Contact');
         return false;
      }
   }

   public static Boolean GrantUserPermissionSet(ID UserId, String PermissionSetName) {
      try {
         Map<String, String> retrunMap = new Map<String, String> ();
         //Verify Permission Set Exists and get id
         List<PermissionSet> permissionSets = [SELECT Id FROM PermissionSet Where Name = :PermissionSetName];
         if (permissionSets.size() == 0) {
            AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.GrantUserPermissionSet - ' + 'PermissionSet not found: ' + PermissionSetName);
<<<<<<< HEAD
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,'AH_UDC_SharedWithoutSharing', 'GrantUserPermissionSet','PermissionSet not found: ' + PermissionSetName,null, null, null);
=======
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR, 'AH_UDC_SharedWithoutSharing', 'GrantUserPermissionSet', 'PermissionSet not found: ' + PermissionSetName, null, null, null);
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
            return false;
         }

         //Verify if user already has the specified permissionset
         List<PermissionSetAssignment> psAssignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserId and PermissionSetId = :permissionSets[0].id];
         if (psAssignments.size() == 1) return true; //User already has permission set

         PermissionSetAssignment psAssignment = new PermissionSetAssignment();
         psAssignment.PermissionSetId = permissionSets[0].id;
         psAssignment.AssigneeId = UserId;
         AH_UDC_SystemContext.CreateObject(psAssignment);

         //PermissionSet added to user
         return true;
      }
      catch(exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.GrantUserPermissionSet: Exception: ' + exc);
<<<<<<< HEAD
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,'AH_UDC_SharedWithoutSharing', 'GrantUserPermissionSet','Unhandled Exception: ' + exc.getMessage(),exc, UserId, 'UserId');
=======
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC, 'AH_UDC_SharedWithoutSharing', 'GrantUserPermissionSet', 'Unhandled Exception: ' + exc.getMessage() + ' at line number ' + exc.getLineNumber(), exc, UserId, 'UserId');
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
         return false; //Return false since the permission set was not applied
      }
   }

   //Check login user has  workbook rights or not
   public static boolean CheckViewWorkbookUserAccess(string WorkbookId) {
      AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess - WorkbookId: ' + WorkbookId);
      List<AH_UDC_Workbook__c> listWorkbook;
      List<AH_UDC_Contact__c> listUDCContact;
      try {
         if (Test.isRunningTest() && WorkbookId == 'TestException') { Integer i = 1 / 0; }
         //Get logged-in user's contact id
         List<User> objUsers = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() AND IsActive = true];
         if (objUsers.size() == 0) { return false; }

         //Determine if workbook id is valid
<<<<<<< HEAD
         listWorkbook = [SELECT Id, RelatedTo__c, Withdrawn__c, SentStatus__c
                         FROM AH_UDC_Workbook__c
                         WHERE Enabled__c = true
                         AND Id = :WorkbookId];
         if (listWorkbook.size() == 0) { return false; }
=======
         listWorkbook = [SELECT Id, RelatedTo__c, Withdrawn__c, SentStatus__c, Enabled__c, RecordType.DeveloperName
                         FROM AH_UDC_Workbook__c
                         WHERE Id = :WorkbookId];
         if (listWorkbook.size() == 0) { return false; }

         if (listWorkbook[0].RecordType.DeveloperName == AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT && listWorkbook[0].Enabled__c == false) return false;
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a

         //Determine if user has Read Access to the record
         List<UserRecordAccess> lstUserRecordAccess = null;
         lstUserRecordAccess = [SELECT RecordId
                                FROM UserRecordAccess
                                WHERE RecordId = :WorkbookId AND UserId = :UserInfo.getUserId() AND HasReadAccess = true];
         AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess - lstUserRecordAccess: ' + lstUserRecordAccess);
         if (lstUserRecordAccess.size() == 1) { return true; }

         //For Community User, look for a UDC Contact record with the NI Document ID
         if (String.isEmpty(listWorkbook[0].RelatedTo__c)) { return false; } //Protect against bad data (Missing RelatedTo__c aka NI Document record)
         listUDCContact = [SELECT ID
                           FROM AH_UDC_Contact__c
                           WHERE Contact__c = :objUsers[0].ContactId
                           AND Document__c = :listWorkbook[0].RelatedTo__c];
<<<<<<< HEAD
         if (listUDCContact.size()> 0) { 
            AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess - listWorkbook[0].Withdrawn__c: ' + listWorkbook[0].Withdrawn__c);
            AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess - listWorkbook[0].SentStatus__c: ' + listWorkbook[0].SentStatus__c);
            return true; //Community User has access
         } 
=======
         if (listUDCContact.size()> 0) {
            AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess - listWorkbook[0].Withdrawn__c: ' + listWorkbook[0].Withdrawn__c);
            AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess - listWorkbook[0].SentStatus__c: ' + listWorkbook[0].SentStatus__c);
            return true; //Community User has access
         }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a

         //Default access is false
         return false;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_SharedWithoutSharing', 'CheckViewWorkbookUserAccess',
<<<<<<< HEAD
                              'Unhandled Exception: ' + exc.getMessage(),
=======
                              'Unhandled Exception: ' + exc.getMessage() + ' at line number ' + exc.getLineNumber(),
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
                              exc, WorkbookId, 'AH_UDC_Workbook__c');
         return false;
      }
      finally {
         listWorkbook = null;
         listUDCContact = null;
      }
   }

   // Check if user has access to the specified NiDocumentation record
   public static Boolean UserHasAccessToNIDoc(Id NiDocId, String LogFunctionalArea) {
      User objUser = null;
      List<AH_UDC_Contact__c> lstUDCContacts = null;

      try {
         //Get logged-in user's contact id
         objUser = [SELECT Id, Username, ContactId FROM User WHERE Id = :UserInfo.getUserId() AND IsActive = true];
         AH_UDC_LogHelper.Debug('###:UserInfo.getUserName: ' + UserInfo.getUserName());
         AH_UDC_LogHelper.Debug('###objUser.ContactId: ' + objUser.ContactId);
         AH_UDC_LogHelper.Debug('###NIDocId: ' + NIDocId);

         if (objUser == null) {
            LogException(LogFunctionalArea, 'UserHasAccessToNIDoc', 'User record not found', System.Label.AH_UDC_Common_Error_Message, null);
            return false;
         }

         //Get UDC Workbook records for logged-in user
         lstUDCContacts = [SELECT Id
                           FROM AH_UDC_Contact__c
                           WHERE Document__c = :NIDocId
                           AND Contact__c = :objUser.ContactId];
         AH_UDC_LogHelper.Debug('###lstUDCContacts: ' + lstUDCContacts);

         //Return true if user has NI Doc record Access otherwise return false
         return lstUDCContacts != null && lstUDCContacts.size() > 0;
      }
      catch(Exception ex) {
<<<<<<< HEAD
         LogException(LogFunctionalArea, 'UserHasAccessToNIDoc', 'Error occurred in UserHasAccessToNIDoc() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber(), System.Label.AH_UDC_Common_Error_Message, ex);
=======
         LogException(LogFunctionalArea, 'UserHasAccessToNIDoc', 'Error occurred in UserHasAccessToNIDoc() => ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber() + ' at line number ' + ex.getLineNumber(), System.Label.AH_UDC_Common_Error_Message, ex);
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
         throw ex;
      }
   }


   //Check if user has workbook edit rights or not
   public static boolean CheckRecordEditAccessForUser(string recId) {
      List<UserRecordAccess> lstUserRecordAccess = null;
      try {
         lstUserRecordAccess = [SELECT RecordId FROM UserRecordAccess
                                WHERE RecordId = :recId AND UserId = :UserInfo.getUserId() AND HasEditAccess = true];
         AH_UDC_LogHelper.Debug('lstUserRecordAccess size : ' + lstUserRecordAccess.size());
         return(lstUserRecordAccess.size() != 0);
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.CheckRecordEditAccessForUser: Exception: ' + exc);
<<<<<<< HEAD
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,'AH_UDC_SharedWithoutSharing', 'CheckRecordEditAccessForUser','Exception: ' + exc.getMessage(),exc, UserInfo.getUserId(), 'User');
=======
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC, 'AH_UDC_SharedWithoutSharing', 'CheckRecordEditAccessForUser', 'Exception: ' + exc.getMessage() + ' at line number ' + exc.getLineNumber(), exc, UserInfo.getUserId(), 'User');
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
         return false;
      }
   }

   //Check if user has  workbook read rights or not
   public static boolean CheckWorkbookReadUserAccess(string WorkbookId) {
      List<UserRecordAccess> lstUserRecordAccess = null;
      try {
         lstUserRecordAccess = [SELECT RecordId FROM UserRecordAccess
                                WHERE RecordId = :WorkbookId AND UserId = :UserInfo.getUserId() AND HasReadAccess = true];
         AH_UDC_LogHelper.Debug('lstUserRecordAccess size : ' + lstUserRecordAccess.size());
         if (lstUserRecordAccess.size() == 0) { return false; }
         return true;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.CheckWorkbookReadUserAccess: Exception: ' + exc);
<<<<<<< HEAD
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,'AH_UDC_SharedWithoutSharing', 'CheckWorkbookReadUserAccess','Exception: ' + exc.getMessage(),exc, UserInfo.getUserId(), 'User');
=======
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC, 'AH_UDC_SharedWithoutSharing', 'CheckWorkbookReadUserAccess', 'Exception: ' + exc.getMessage() + ' at line number ' + exc.getLineNumber(), exc, UserInfo.getUserId(), 'User');
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
         return false;
      }
   }

   public static Boolean ChangeUserProfileToChatter(Id userId) {
      AH_UDC_LogHelper.Debug('ChangeUserProfileToChatter');
      Boolean profileChanged = false;
      Boolean isQueueLogEnabled = true;
<<<<<<< HEAD
      try {      
         if (AH_UDC_LogHelper.QueueLogs == false){
            AH_UDC_LogHelper.QueueLogs = true;
            isQueueLogEnabled = false;
         }
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_TRACE,'SharedWithoutSharing','ChangeUserProfileToChatter','Request for User',null,userId,'UserID');
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_ChangeCommunityUserProfile', false)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'Change Community User Profile'));
=======
      try {
         if (AH_UDC_LogHelper.QueueLogs == false) {
            AH_UDC_LogHelper.QueueLogs = true;
            isQueueLogEnabled = false;
         }
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_TRACE, 'SharedWithoutSharing', 'ChangeUserProfileToChatter', 'Request for User', null, userId, 'UserID');
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestChangeCommunityUserProfile', false, true)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'Change Community User Profile'));
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a

         //This code performs a callout to a C# API to set the user's profile
         Http h1 = new Http();
         HttpRequest req1 = new HttpRequest();
         req1.setHeader('Content-Type', 'application/json');
         req1.setHeader('accept', 'application/json');
         req1.setMethod('GET');
         req1.setTimeout((AH_UDC_ConfigHelper.GetInteger('AH_UDC_SetCommunityUserProfileTimeout', 120) * 1000));

         string endpointURL = AH_UDC_ConfigHelper.GetString('AH_UDC_SetCommunityUserProfileUrl', '') + '/' + userId + '/TRUE';

         AH_UDC_LogHelper.Debug('ChangeUserProfileToChatter: endpointURL: ' + endpointURL);
         req1.setEndpoint(endpointURL);
<<<<<<< HEAD

         HttpResponse res1 = null;
         AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse resp;

         AH_UDC_LogHelper.Debug('ChangeUserProfileToChatter: Send Request');
         res1 = h1.send(req1);
         Integer httpStatus = res1.getStatusCode();
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_TRACE,'SharedWithoutSharing','ChangeUserProfileToChatter','Trace Response: ' + res1.getbody(),null,userId,'UserID');
         string sResp = res1.getbody().replace('\\','');
         if(sResp.left(1)=='"') sResp = sResp.substring(1,sResp.length()-1);
         resp = (AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse) JSON.deserialize(sResp, AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse.class);
         
         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestSetCommunityUserProfileHttpNon200Error', FALSE)) { httpStatus = 500; }
         
         if (httpStatus == 200) {
            //Unit Test Force Exception
            if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestSetCommunityUserProfileRespNon200Error', FALSE)) {
               resp.Message='Unit Test Forced Error';
               resp.StatusCode = '501';
            }

=======

         HttpResponse res1 = null;
         AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse resp;

         AH_UDC_LogHelper.Debug('ChangeUserProfileToChatter: Send Request');
         res1 = h1.send(req1);
         Integer httpStatus = res1.getStatusCode();
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_TRACE, 'SharedWithoutSharing', 'ChangeUserProfileToChatter', 'Trace Response: ' + res1.getbody(), null, userId, 'UserID');
         string sResp = res1.getbody(); //TODO: ROBDEV .replace('\\','
         if (sResp.left(1) == '"') sResp = sResp.substring(1, sResp.length() - 1);
         resp = (AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse) JSON.deserialize(sResp, AH_UDC_REST_SetCommunityUserProfile.SetCommunityUserProfileResponse.class);

         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestSetCommunityUserProfileHttpNon200Error', FALSE, true)) { httpStatus = 500; }

         if (httpStatus == 200) {
            //Unit Test Force Exception
            if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestSetCommunityUserProfileRespNon200Error', FALSE, true)) {
               resp.Message = 'Unit Test Forced Error';
               resp.StatusCode = '501';
            }

>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
            String msg = + resp.Message + ' Code: ' + resp.StatusCode;
            AH_UDC_LogHelper.Debug('ChangeUserProfileToChatter: ' + msg);
            if (resp.StatusCode == '200') {
               profileChanged = true;
            } else {
               AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                                    'AH_UDC_SharedWithoutSharing', 'ChangeUserProfileToChatter',
                                    'An error occurred while changing the User profile to "'
                                    + AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER, AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER)
                                    + '. ' + msg, null, UserInfo.getUserId(), 'User');
            }
         } else {
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
<<<<<<< HEAD
                                    'AH_UDC_SharedWithoutSharing', 'ChangeUserProfileToChatter',
                                    'Unknown HTTP Status when calling endpoint: ' + String.valueOf(resp.StatusCode)
                                    , null, UserInfo.getUserId(), 'User');
=======
                                 'AH_UDC_SharedWithoutSharing', 'ChangeUserProfileToChatter',
                                 'Unknown HTTP Status when calling endpoint: ' + String.valueOf(resp.StatusCode)
                                 , null, UserInfo.getUserId(), 'User');
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
         }
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.ChangeUserProfileToChatter: Exception: ' + exc);
<<<<<<< HEAD
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,'AH_UDC_SharedWithoutSharing', 'ChangeUserProfileToChatter','Exception: ' + exc.getMessage(),exc, UserInfo.getUserId(), 'User');
      }
      finally{
         if(isQueueLogEnabled == false)
=======
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC, 'AH_UDC_SharedWithoutSharing', 'ChangeUserProfileToChatter', 'Exception: ' + exc.getMessage() + ' at line number ' + exc.getLineNumber(), exc, UserInfo.getUserId(), 'User');
      }
      finally {
         if (isQueueLogEnabled == false)
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
         {
            //Write any Queued Log Messages
            AH_UDC_LogHelper.GetQueuedLogs();
            AH_UDC_LogHelper.clearQueuedLogs();
            AH_UDC_LogHelper.QueueLogs = false;
         }
      }
      return profileChanged;
   }

   //Log exception and display error message to user
   public static void LogException(String strLogFunctionalArea, String strMethodName, String strErrorMessageToLog, String strErrorMessageToDisplay, Exception exc) {
      try {
         AH_UDC_LogHelper.Debug('Exception Occurred in the method ' + strMethodName);
         AH_UDC_LogHelper.Debug('Exception : ' + (exc != null ? (exc.getMessage() + ' at Line Number ' + exc.getLineNumber()) : strErrorMessageToLog));
         if (!ApexPages.hasMessages()) { //If there is already a message added then do not add
            //Display error message to user
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, strErrorMessageToDisplay)); ///Only the generic error should ever be show to the users.
         }
         AH_UDC_LogHelper.Log(exc != null ? AH_UDC_LogHelper.LogLevel_EXC : AH_UDC_LogHelper.LogLevel_ERROR,
                              strLogFunctionalArea,
                              strMethodName, strErrorMessageToLog,
                              exc, null, null);

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && strLogFunctionalArea == 'TestException') { Integer a = 1 / 0; }
      }
      catch(Exception ex) {
         AH_UDC_LogHelper.Debug(strLogFunctionalArea + '.LogException - Exception: ' + exc.getMessage() + ' at line number ' + exc.getLineNumber());
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              strLogFunctionalArea,
                              'LogException',
                              'Unhandled Exception: ' + ex.getMessage() + ' at line number ' + ex.getLineNumber(),
                              ex, null, null);
      }
   }

   //Log exception and display error message to user also rollback database changes
   public static void LogException(String strLogFunctionalArea, String strMethodName, String strErrorMessageToLog, String strErrorMessageToDisplay, Exception exc, Savepoint objSavePoint) {
      try {
         AH_UDC_LogHelper.Debug('Exception Occurred in the method ' + strMethodName);
         AH_UDC_LogHelper.Debug('Exception : ' + (exc != null ? (exc.getMessage() + ' at Line Number ' + exc.getLineNumber()) : strErrorMessageToLog));
         if (!ApexPages.hasMessages()) { //If there is already a message added then do not add
            //Display error message to user
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, strErrorMessageToDisplay)); ///Only the generic error should ever be show to the users.
         }

         if (objSavepoint != null) {
            //Rollback other inserted data
            Database.rollback(objSavepoint);
         }
         AH_UDC_LogHelper.Log(exc != null ? AH_UDC_LogHelper.LogLevel_EXC : AH_UDC_LogHelper.LogLevel_ERROR,
                              strLogFunctionalArea,
                              strMethodName, strErrorMessageToLog,
                              exc, null, null);

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && strLogFunctionalArea == 'TestException') { Integer a = 1 / 0; }
      }
      catch(Exception ex) {
         AH_UDC_LogHelper.Debug(strLogFunctionalArea + '.LogException - Exception: ' + ex);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              strLogFunctionalArea,
                              'LogException',
                              'Unhandled Exception: ' + ex.getMessage() + ' at line number ' + ex.getLineNumber(),
                              ex, null, null);
      }
   }

   //Send email to contact after sending workbook
<<<<<<< HEAD
   public static Boolean SendEmailToContacts(String LogFunctionalArea, List<string> lstToAddresses, Id EmailTemplateId, Id ContactId, Id NIDocId) {
      try {
         if (lstToAddresses != null && lstToAddresses.size() > 0 && String.isNotBlank(String.valueOf(EmailTemplateId))
             && String.isNotBlank(String.valueOf(ContactId)) && String.isNotBlank(String.valueOf(NIDocId))) {
            //Prerender email so that we can do replacement of URL
            Messaging.SingleEmailMessage objEmail = Messaging.renderStoredEmailTemplate(EmailTemplateId, ContactId, NIDocId);
            //Replace Community Portal URL
            objEmail.setHtmlBody(objEmail.getHtmlBody().replace(AH_UDC_ConfigHelper.GetString('AH_UDC_EmailTemplatePortalUrlPlaceholder', ''),
                                                                AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityPortalUrl', '')));
            //Set to whom the email will be sent
            objEmail.setToAddresses(lstToAddresses);

            List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage> ();
            lstEmails.add(objEmail);

=======
   public static Boolean SendEmailToContacts(String LogFunctionalArea, List<Contact> sendContacts, Id EmailTemplateId, Id NIDocId, ID OrgWideEmail) {
      try {
         if (Test.isRunningTest()) return true;
         AH_UDC_LogHelper.Debug('SendEmailToContacts - Start:');
         AH_UDC_LogHelper.Debug('sendContacts:' + sendContacts);
         AH_UDC_LogHelper.Debug('EmailTemplateId:' + EmailTemplateId);
         AH_UDC_LogHelper.Debug('NIDocId:' + NIDocId);

         if (sendContacts != null && sendContacts.size() > 0 && EmailTemplateId != null && NIDocId != null)
         {
            AH_UDC_LogHelper.Debug('SendEmailToContacts - L1');
            List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage> ();
            // Email Template tag replacement
            List<NI_Documentation__c> lstNIDoc = [SELECT AH_UDC_WorkbookDueDate__c FROM NI_Documentation__c WHERE Id = :NIDocId];
            string dueDate = '';
            Set<Id> setContactIds = new Set<Id> ();
            Map<Id, User> userMap = new Map<Id, User> ();
            Set<string> setName = new Set<String> ();
            string allUserName;

            if (lstNIDoc.size() > 0)
            {
               Date tempDate = lstNIDoc[0].AH_UDC_WorkbookDueDate__c;
               if (tempDate != null)
               {
                  DateTime dt = DateTime.newInstance(tempDate.year(), tempDate.month(), tempDate.day(), 11, 59, 59); // keep the 11:59:59 for the local time zone
                  dueDate = dt.format('MMMM') + ' ' + tempDate.day();
               }
               else {
                  dueDate = Label.AH_UDC_EmailTagNoneValue;
               }
            }

            //get contactId for find the user info
            for (Contact sendContact : sendContacts)
            {
               setContactIds.add(sendContact.Id);
            }

            List<User> lstUser = [SELECT id, firstname, lastname, email, username, ContactId, Name FROM user WHERE IsActive = true and ContactId In :setContactIds];
            if (lstUser.size() > 0)
            {
               for (User oUser : lstUser)
               {
                  userMap.put(oUser.ContactId, oUser);
                  setName.add(oUser.Name);
               }
            }

            for (Contact sendContact : sendContacts)
            {
               AH_UDC_LogHelper.Debug('SendEmailToContacts - L2 : ' + sendContact);
               if (sendContact.id != null && String.isNotEmpty(sendContact.email))
               {
                  //Prerender email so that we can do replacement of URL
                  Messaging.SingleEmailMessage objEmail = Messaging.renderStoredEmailTemplate(EmailTemplateId, sendContact.id, NIDocId);
                  Set<String> cloneName = setName.clone();
                  cloneName.remove(userMap.get(sendContact.Id).Name); //remove self name from the list of users tag while sending email                                  
                  allUserName = String.join((Iterable<String>) cloneName, ', ');
                  if (String.isBlank(allUserName))
                  allUserName = Label.AH_UDC_EmailTagNoneValue;
                  //Replace Community Portal URL
                  string HtmlBody = objEmail.getHtmlBody()
                  .replace(AH_UDC_ConfigHelper.GetString('AH_UDC_EmailTemplatePortalUrlPlaceholder', ''), AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityPortalUrl', ''))
                  .replaceAll('(?i)\\{UDCPortalURL\\}', AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityPortalUrl', ''))
                  .replaceAll('(?i)\\{UDCduedate\\}', dueDate)
                  .replaceAll('(?i)\\{CUser.FirstName\\}', userMap.get(sendContact.Id).FirstName.trim())
                  .replaceAll('(?i)\\{CUser.LastName\\}', userMap.get(sendContact.Id).LastName.trim())
                  .replaceAll('(?i)\\{CUser.Email\\}', userMap.get(sendContact.Id).Email.trim())
                  .replaceAll('(?i)\\{CUser.UserName\\}', userMap.get(sendContact.Id).Username.trim())
                  .replaceAll('(?i)\\{UDCListCUsers\\}', allUserName);

                  HtmlBody = ReplaceStartEndTag(HtmlBody, '{UDCDueDate-START}', '{UDCDueDate-END}', lstNIDoc[0].AH_UDC_WorkbookDueDate__c == null);
                  HtmlBody = ReplaceStartEndTag(HtmlBody, '{UDCListCUsers-START}', '{UDCListCUsers-END}', allUserName.equalsIgnoreCase(Label.AH_UDC_EmailTagNoneValue));

                  objEmail.setHtmlBody(HtmlBody);
                  //Set to whom the email will be sent
                  List<String> addresses = new List<String> ();
                  addresses.add(sendContact.Email);
                  objEmail.setToAddresses(addresses);
                  if (OrgWideEmail != null) objEmail.setOrgWideEmailAddressId(OrgWideEmail);
                  lstEmails.add(objEmail);
               }
            }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
            Messaging.SendEmailResult[] results = Messaging.sendEmail(lstEmails, false);
            if (results != null && results.size() > 0 && results[0].success) {
               return true;
            }
            LogException(LogFunctionalArea, 'SendEmailToContacts', 'Error occurred in Sending Email  - Logged-In User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ' : ' + results[0].getErrors(), Label.AH_UDC_Send_Email_Error_Message, null);
         }
         return false;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred while sending email to the contact - Logged-In User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, 'SendEmailToContacts', strErrorMessage, Label.AH_UDC_Send_Email_Error_Message, ex);
         return false;
      }
   }
<<<<<<< HEAD
=======

   public static string ReplaceStartEndTag(string toSearch, string startTag, string endTag, boolean removeBetween) {
      string toSearchReturn = toSearch;
      string toSearchUpper = toSearch.toUpperCase();
      string startTagUpper = startTag.toUpperCase();
      string endTagUpper = endTag.toUpperCase();
      integer startTagIndex = toSearchUpper.indexOf(startTagUpper);
      integer endTagIndex = toSearchUpper.indexOf(endTagUpper);
      if (removeBetween)
      {
         if (startTagIndex > - 1) {
            toSearchReturn = toSearchReturn.substring(0, startTagIndex) + (endTagIndex == - 1 ? '' : toSearchReturn.substring(endTagIndex + endTag.length()));
         }
         else {
            if (endTagIndex > - 1) toSearchReturn = toSearchReturn.substring(0, endTagIndex) + toSearchReturn.substring(endTagIndex + endTag.length());
         }
      }
      else
      {
         if (endTagIndex > - 1 && endTagIndex > startTagIndex) toSearchReturn = toSearchReturn.substring(0, endTagIndex) + toSearchReturn.substring(endTagIndex + endTag.length());
         if (startTagIndex > - 1) toSearchReturn = toSearchReturn.substring(0, startTagIndex) + toSearchReturn.substring(startTagIndex + startTag.length());
      }
      return toSearchReturn;
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}