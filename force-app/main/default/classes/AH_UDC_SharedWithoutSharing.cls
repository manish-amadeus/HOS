/**
 * Name          : AH_UDC_SharedWithoutSharing
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-Feb-02
 * Description   : Re-usable common methods for UDC code that do NOT enforce Object/FLS security (WITHOUT SHARING)
 * Dependencies  : 
 **/
public without sharing class AH_UDC_SharedWithoutSharing {
   //TODO:ROBDEV:Move the methods in AH_UDC_Shared.cls that need to run without FLS security to this file

   //This message attaches chatter to the NI_Documentation__c object with a @ Mention to the owner of the record
   public enum CreateChatterMessageType { WorkbookAccessed, WorkbookComplete, WorkbookStepComplete }
   public static Boolean CreateChatter(String NIDocumentationId, ID WorkbookStepSentId, CreateChatterMessageType messageType) {
      try {
         //AH_UDC_LogHelper.Debug('CreateChatter');
         //AH_UDC_LogHelper.Debug('CreateChatter: NIDocumentationId: ' + String.valueOf(NIDocumentationId));
         //AH_UDC_LogHelper.Debug('CreateChatter: WorkbookStepSentId: ' + String.valueOf(WorkbookStepSentId));
         //AH_UDC_LogHelper.Debug('CreateChatter: messageType: ' + String.valueOf(messageType));

         if (Test.isRunningTest() && NIDocumentationId == 'TestException') Integer i = 1 / 0;

         List<NI_Documentation__c> niDoc = [select Id, Name, Document_Name__c, ownerid from NI_Documentation__c where Id = :NIDocumentationId];
         if (niDoc == null || niDoc.size() != 1) {
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                                 'AH_UDC_Shared', 'CreateChatterMessageType',
                                 'NI Documentation Record Not Found',
                                 null, NIDocumentationId, 'NI_Documentation__c');
            return false;
         }

         List<AH_UDC_WorkbookStep__c> wbStep = null;
         if (messageType == CreateChatterMessageType.WorkbookStepComplete) {
            wbStep = [select Id, Name from AH_UDC_WorkbookStep__c where Id = :WorkbookStepSentId];
            if (wbStep == null || wbStep.size() != 1) {
               AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                                    'AH_UDC_Shared', 'CreateChatterMessageType',
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
                                 'AH_UDC_Shared', 'CreateChatterMessageType',
                                 'Unhandled CreateChatterMessageType',
                                 null, null, null);
            return false;
         }

         //Adding a Text post
         FeedItem post = new FeedItem();
         post.ParentId = niDoc[0].id;
         post.Body = postText;
         insert post;

         //AH_UDC_LogHelper.Debug('CreateChatter: CREATED');
         return true;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('CreateChatter: Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_Shared', 'CreateChatterMessageType',
                              'Unhandled Exception: ' + exc.getMessage(),
                              exc, NIDocumentationId, 'NI_Documentation__c');
         return false;
      }
   }

   //This method is used to get a Workbook Step Sent URL.  Since the URL is based on the most recent response it must be dynamically generated.
   public static Map<Id, String> GetWorkbookStepSentUrls(List<AH_UDC_WorkbookStep__c> WorkbookStepsSent) {
      //There is purposely no try/catch here

      List<Id> ids = new List<Id> ();
      for (AH_UDC_WorkbookStep__c WorkbookStepSent : WorkbookStepsSent) {
         ids.add(WorkbookStepSent.id);
      }
      return GetWorkbookStepSentUrls(ids);
   }

   //This method is used to get a Workbook Step Sent URL.  Since the URL is based on the most recent response it must be dynamically generated.
   public static string GetWorkbookStepSentUrl(ID StepId) {
      //There is purposely no try/catch here

      List<Id> ids = new List<Id> ();
      ids.add(StepId);
      Map<Id, String> stepUrls = GetWorkbookStepSentUrls(ids);
      if (stepUrls != null && stepUrls.containsKey(StepId)) return stepUrls.get(StepId);
      return null;
   }

   //This method is used to get a Workbook Step Sent URL.  Since the URL is based on the most recent response it must be dynamically generated.
   public static Map<Id, String> GetWorkbookStepSentUrls(List<ID> WorkbookStepSentIds) {
      //NOTE: logging is not allowed due to this method being called by a constructor; as such NULL is passed back

      string WorkbookStepSentUrl = null;
      Map<Id, String> wbsStepUrls = new Map<Id, String> ();
      try {
         Id recordTypeIdResponse = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
         Id recordTypeIdQA = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();

         List<AH_UDC_WorkbookStep__c> wbSteps = [SELECT Url__c, Workbook__r.SecurityCode__c, Workbook__r.ParentWorkbookSent__r.SecurityCode__c,
                                                 Form__c, Form__r.id, Form__r.URL__c, Form__r.Definition__c,
                                                 Workbook__r.RelatedTo__r.AH_UDC_PropertyAccount__c, Workbook__r.Product__c
                                                 FROM AH_UDC_WorkbookStep__c
                                                 where id in :WorkbookStepSentIds];

         if (wbSteps.size() != WorkbookStepSentIds.size()) {
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                                 'AH_UDC_Shared', 'GetWorkbookStepSentUrls',
                                 'One or more Workbook Steps Not Found',
                                 null, null, null);
            return null;
         }

         for (AH_UDC_WorkbookStep__c wbStep : wbSteps) {
            //Determine if this is a form or an external URL
            if (wbStep.Form__c == null) {
               //Return the External URL
               wbsStepUrls.put(wbStep.Id, wbStep.URL__c);
               return wbsStepUrls;
            }
            string formDefinition = (string) wbStep.getSobject('Form__r').get('Definition__c');
            AH_UDC_LogHelper.Debug('FormDef: ' + formDefinition);
            if (formDefinition == null) {
               return null;
            }
            AH_UDC_Shared.FormDefinition fd = (AH_UDC_Shared.FormDefinition) JSON.deserialize(formDefinition, AH_UDC_Shared.FormDefinition.class);
            string SecurityCodeTFA = fd.getFieldByName('Security Code').APIName;
            AH_UDC_LogHelper.Debug('SecurityCodeTFA: ' + SecurityCodeTFA);
            if (SecurityCodeTFA == null) {
               return null;
            }
            string TokenTFA = fd.getFieldByName('Token').APIName;
            AH_UDC_LogHelper.Debug('TokenTFA: ' + TokenTFA);
            if (TokenTFA == null) {
               return null;
            }

            AH_UDC_Shared.FormField ffParentSecurityCode = fd.getFieldByName('Parent Security Code');
            string ParentSecurityCodeTFA = null;
            if (ffParentSecurityCode != null) ParentSecurityCodeTFA = ffParentSecurityCode.APIName;
            //This is not an error if the field is not found

            AH_UDC_Shared.FormField ffProduct = fd.getFieldByName('Product');
            string ProductTFA = null;
            if (ffProduct != null) ProductTFA = ffProduct.APIName;
            //This is not an error if the field is not found

            //Generate Token
            string token = wbStep.getSobject('Workbook__r').get('SecurityCode__c') + '_' + UserInfo.getUserId() + '_' + wbStep.getSobject('Form__r').get('Id');
            //Encrypt token
            string sEncryptionKey = AH_UDC_ConfigHelper.GetString('AH_UDC_ViewWorkbookTokenEncryptionKey', '');
            if (!String.isEmpty(sEncryptionKey) && AH_UDC_ConfigHelper.GetBoolean('AH_UDC_ViewWorkbookTokenEncryption', true)) {
               Blob key = EncodingUtil.base64Decode(sEncryptionKey);
               Blob data = Blob.valueOf(token);
               Blob encryptedData = Crypto.encryptWithManagedIV('AES256', key, data);
               token = EncodingUtil.base64Encode(encryptedData).replace('/', '_2f_').replace('+', '_2b_'); //Base64 has 2 special characters / + that are not compatible with a URL ID
            }
            token = AH_UDC_Constants.FORM_TOKEN_PREFIX + token;

            //Build Base URL with required attributes
            WorkbookStepSentUrl = wbStep.Form__r.URL__c;
            WorkbookStepSentUrl += '?' + TokenTFA + '=' + token;
            WorkbookStepSentUrl += '&' + SecurityCodeTFA + '=' + wbStep.getSobject('Workbook__r').get('SecurityCode__c');

            if (ParentSecurityCodeTFA != null
                && wbStep.getSobject('Workbook__r').getSobject('ParentWorkbookSent__r') != null) {
               WorkbookStepSentUrl += '&' + ParentSecurityCodeTFA + '=' + wbStep.getSobject('Workbook__r').getSobject('ParentWorkbookSent__r').get('SecurityCode__c');
            }

            if (ProductTFA != null && wbStep.getSobject('Workbook__r').get('Product__c') != null) {
               string escapedProductValue = wbStep.Workbook__r.Product__c;
               escapedProductValue = escapedProductValue.replace('&', '%26'); //Escape &
               WorkbookStepSentUrl += '&' + ProductTFA + '=' + escapedProductValue;
            }

            //Find the most recent response
            ID PropertyAccount = (Id) wbStep.getSobject('Workbook__r').getSobject('RelatedTo__r').get('AH_UDC_PropertyAccount__c');
            List<AH_UDC_Response__c> formResponses = [select Id
                                                      from AH_UDC_Response__c
                                                      where IsMostRecentResponse__c = true
                                                      and WorkbookStep__c = :wbStep.Id
                                                      and recordtypeid = :recordTypeIdResponse
                                                      order by createddate desc
                                                      limit 1];
            //It's ok if there are no responses; proceed if there are
            //AH_UDC_LogHelper.Debug('formResponses.size(): ' + formResponses.size());
            //AH_UDC_LogHelper.Debug('formResponses[0].id: ' + formResponses[0].id);
            if (formResponses.size() > 0) {
               //Since this is a form check for Responses to add Repeating Field placeholders to the URL
               List<AH_UDC_ResponseQA__c> responseQAs = [SELECT QuestionField__c
                                                         FROM AH_UDC_ResponseQA__c
                                                         WHERE Response__c = :formResponses[0].id];

               //group by QuestionField__c having COUNT(id) > 1
               Map<String, Integer> groupFields = new Map<String, Integer> ();
               for (AH_UDC_ResponseQA__c responseQA : responseQAs) {
                  //AH_UDC_LogHelper.Debug('responseQA.QuestionField__c: ' + responseQA.QuestionField__c);
                  string questionField = responseQA.QuestionField__c;
                  if (questionField.contains('[')) questionField = questionField.substringBefore('[');
                  //AH_UDC_LogHelper.Debug('questionField: ' + questionField);

                  if (groupFields.containsKey(questionField)) {
                     groupFields.put(questionField, groupFields.get(questionField) + 1);
                  } else {
                     groupFields.put(questionField, 1);
                  }
               }

               //AH_UDC_LogHelper.Debug('groupFields.size: ' + groupFields.size());
               if (groupFields.size() > 0) {
                  for (string key : groupFields.keySet()) {

                     Integer repeatCount = groupFields.get(key);

                     if (repeatCount > 1) {
                        //Get the Repeat ID for the field
                        repeatCount = Integer.valueOf(repeatCount) - 1;
                        AH_UDC_Shared.FormField formField = fd.getFieldByAPIName(key);

                        if (FormField != null && formField.Repeat != null) {
                           WorkbookStepSentUrl += '&' + formField.Repeat + '=' + String.valueOf(repeatCount);
                        }
                     }
                  }
               }
            }
            //AH_UDC_LogHelper.Debug('WorkbookStepSentUrl: ' + WorkbookStepSentUrl);

            wbsStepUrls.put(wbStep.Id, WorkbookStepSentUrl);
         }
         return wbsStepUrls;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.GetWorkbookStepSentUrls: Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_Shared', 'GetWorkbookStepSentUrls',
                              'Unhandled Exception: ' + exc.getMessage(),
                              exc, null, null);
         return null;
      }
   }


   public static Boolean SetupCommunityAccess(String ContactId) {
      try {
         AH_UDC_LogHelper.Debug('SetupCommunityAccess : AH_UDC_CreateCommunityUserEnabled : ' + AH_UDC_ConfigHelper.GetBoolean('AH_UDC_CreateCommunityUserEnabled', true));
         if (!AH_UDC_ConfigHelper.GetBoolean('AH_UDC_CreateCommunityUserEnabled', true)) return true; //If it's creating community users is not enabled return true;

         if (Test.isRunningTest() && ContactId == 'TestException') Integer i = 1 / 0;

         //This is the Community User Post Fix that all users of the community get in their username
         string CommunityUserNamePostFix = AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostFix',
                                                                         AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX);

         //Get User Profile
         Profile oProfile = [SELECT Id FROM Profile WHERE Name = :AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER,
                                                                                                AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER)];
         AH_UDC_LogHelper.Debug('SetupCommunityAccess : oProfile : ' + oProfile);
         if (oProfile == null) {
            //TODO: Should something more be returned to the calling program, or logged?  They have no idea why it failed
            return false;
         }

         //Verify Contact is Valid
         List<Contact> contacts = [select id, Account.Owner.UserRoleid, LastName, FirstName, email from contact where Id = :ContactId];
         if (contacts.size() != 1) return false; //Contact not found

         AH_UDC_LogHelper.Debug('SetupCommunityAccess : contacts[0].getSObject(\'Account\') :' + contacts[0].getSObject('Account'));
         AH_UDC_LogHelper.Debug('SetupCommunityAccess : contacts[0].getSObject(\'Account\').getSObject(\'Owner\') :' + contacts[0].getSObject('Account').getSObject('Owner'));
         AH_UDC_LogHelper.Debug('SetupCommunityAccess : contacts[0].getSObject(\'Account\').getSObject(\'Owner\').get(\'UserRoleid\') :' + contacts[0].getSObject('Account').getSObject('Owner').get('UserRoleid'));
         //Verify Contact has role
         if (contacts[0].getSObject('Account') == null ||
             contacts[0].getSObject('Account').getSObject('Owner') == null ||
             contacts[0].getSObject('Account').getSObject('Owner').get('UserRoleid') == null) {
            return false; //Contact does not have role cannot add user
         }

         AH_UDC_LogHelper.Debug('SetupCommunityAccess : contacts[0].Email :' + contacts[0].Email);
         //Verify Contact has email
         if (String.isEmpty(contacts[0].Email)) {
            return false; //Contact does not have an email address
         }

         //Find Contact's User if it exists
         List<User> users = [select id from user where ContactId = :contacts[0].id and IsActive = true];
         AH_UDC_LogHelper.Debug('SetupCommunityAccess : users.size() :' + users.size());
         //If Contact Doesn't have user create one
         Id TargetUserId = null;
         if (users.size() == 0) {
            //Determine User Id
            string random = '';
            string orgPrefix = '';
            orgPrefix = AH_UDC_ConfigHelper.GetString('AH_UDC_CreateCommunityUserOrgPrefix', '');
            string usernameAppend = orgPrefix + CommunityUserNamePostFix;
            string userName = contacts[0].email.left(78 - usernameAppend.length()) + usernameAppend;
            string nickname = contacts[0].FirstName.left(15) + '_' + contacts[0].LastName.left(20);

            //Check if user name / nickname exists
            Boolean ValidUserName = false;
            //Max 5 attempts to find unique names
            for (integer iAttempts = 0; iAttempts< 5; iAttempts++) {
               AH_UDC_LogHelper.Debug('SetupCommunityAccess : username :' + username);
               AH_UDC_LogHelper.Debug('SetupCommunityAccess : nickname :' + nickname);
               List<AggregateResult> existingUsers = [select COUNT(id) usercount from user where Username = :username or CommunityNickname = :nickname];
               AH_UDC_LogHelper.Debug('SetupCommunityAccess : existingUsers[0].get(\'usercount\') : ' + existingUsers[0].get('usercount'));
               if (existingUsers[0].get('usercount') == 0) {
                  ValidUserName = true;
                  break;
               }

               //Generate Random 3 digit and add to username/nickname and try again
               Integer randomNumber = Integer.valueof((Math.random() * 100));
               random = string.valueOf(randomNumber).leftPad(3, '0');

               usernameAppend = '.' + random + orgPrefix + CommunityUserNamePostFix;
               userName = contacts[0].email.left(78 - usernameAppend.length()) + usernameAppend;

               nickname = contacts[0].FirstName.left(15) + '_' + contacts[0].LastName.left(20) + '_' + random;
            }

            AH_UDC_LogHelper.Debug('SetupCommunityAccess : ValidUserName :' + ValidUserName);
            if (!ValidUserName) return false; //Could not find a valid user name

            //Create User
            User newCommunityUser = new User();
            newCommunityUser.FirstName = contacts[0].FirstName;
            newCommunityUser.lastName = contacts[0].LastName;
            newCommunityUser.ContactId = contacts[0].Id;
            newCommunityUser.Username = userName; //Max Length 80
            newCommunityUser.Email = contacts[0].Email;
            newCommunityUser.CommunityNickname = nickname; //Max Length 40
            newCommunityUser.Alias = contacts[0].FirstName.left(3) + contacts[0].LastName.left(5);
            newCommunityUser.TimeZoneSidKey = 'America/New_York';
            newCommunityUser.LocaleSidKey = 'en_US';
            newCommunityUser.EmailEncodingKey = 'ISO-8859-1';
            newCommunityUser.LanguageLocaleKey = 'en_US';
            newCommunityUser.ProfileId = oProfile.Id;
            insert newCommunityUser;
            TargetUserId = newCommunityUser.id;
         } else {
            TargetUserId = users[0].Id;
         }

         // Grant User Permission Set for Community User
         Boolean gupsResult = GrantUserPermissionSet(TargetUserId,
                                                     AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetCommunityUser',
                                                                                   AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER));
         AH_UDC_LogHelper.Debug('SetupCommunityAccess : gupsResult :' + gupsResult);
         if (!gupsResult) return false; //Adding permisions set failed - do not rollback user if one was created

         return true;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.SetupCommunityAccess: Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_Shared', 'SetupCommunityAccess',
                              'Unhandled Exception: ' + exc.getMessage(),
                              exc, ContactId, 'Contact');
         return false;
      }
   }

   public static Boolean GrantUserPermissionSet(ID UserId, String PermissionSetName) {
      try {
         Map<String, String> retrunMap = new Map<String, String> ();
         //Verify Permission Set Exists and get id
         List<PermissionSet> permissionSets = [select id from PermissionSet where name = :PermissionSetName];
         if (permissionSets.size() == 0) {
            AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.GrantUserPermissionSet - ' + 'PermissionSet not found: ' + PermissionSetName);
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                                 'AH_UDC_Shared', 'GrantUserPermissionSet',
                                 'PermissionSet not found: ' + PermissionSetName,
                                 null, null, null);
            return false;
         }

         //Verify if user already has the specified permissionset
         List<PermissionSetAssignment> psAssignments = [select id from PermissionSetAssignment where AssigneeId = :UserId and PermissionSetId = :permissionSets[0].id];
         if (psAssignments.size() == 1) {
            return true; //User already has permission set
         }

         PermissionSetAssignment psAssignment = new PermissionSetAssignment();
         psAssignment.PermissionSetId = permissionSets[0].id;
         psAssignment.AssigneeId = UserId;
         insert psAssignment;

         //PermissionSet added to user
         return true;
      }
      catch(exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.GrantUserPermissionSet: Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_Shared', 'GrantUserPermissionSet',
                              'Unhandled Exception: ' + exc.getMessage(),
                              exc, UserId, 'UserId');
         return false; //Return false since the permission set was not applied
      }
   }

   //Check login user has  workbook rights or not
   public static boolean CheckViewWorkbookUserAccess(string WorkbookId) {
      AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess-WorkbookId: ' + WorkbookId);
      List<AH_UDC_Workbook__c> listWorkbook;
      List<AH_UDC_Contact__c> listUDCContact;
      try {
         if (Test.isRunningTest() && WorkbookId == 'TestException') Integer i = 1 / 0;
         //Get logged-in user's contact id
         List<User> objUsers = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() AND IsActive = true];
         if (objUsers.size() == 0) return false;

         //Determine if workbook id is valid
         listWorkbook = [SELECT Id, RelatedTo__c
                         FROM AH_UDC_Workbook__c
                         WHERE Enabled__c = true
                         AND Id = :WorkbookId];
         if (listWorkbook.size() == 0) return false;

         //Determine if user has Read Access to the record
         List<UserRecordAccess> lstUserRecordAccess = null;
         lstUserRecordAccess = [SELECT RecordId
                                FROM UserRecordAccess
                                WHERE RecordId = :WorkbookId AND UserId = :UserInfo.getUserId() AND HasReadAccess = true];
         AH_UDC_LogHelper.Debug('lstUserRecordAccess size : ' + lstUserRecordAccess.size());
         if (lstUserRecordAccess.size() == 1) return true;

         //For Community User, look for a the UDC Contact record with the NI Document ID
         if (String.isEmpty(listWorkbook[0].RelatedTo__c)) return false; //Protect against bad data (Missing RelatedTo__c aka NI Document record)
         listUDCContact = [SELECT ID
                           FROM AH_UDC_Contact__c
                           WHERE Contact__c = :objUsers[0].ContactId
                           AND Document__c = :listWorkbook[0].RelatedTo__c];
         if (listUDCContact.size()> 0) return true; //Community User has access

         //Default access is false
         return false;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess: Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_Shared', 'CheckViewWorkbookUserAccess',
                              'Unhandled Exception: ' + exc.getMessage(),
                              exc, WorkbookId, 'AH_UDC_Workbook__c');
         return false;
      }
      finally {
         listWorkbook = null;
         listUDCContact = null;
      }
   }

   //Check if user has  workbook edit rights or not
   public static boolean CheckWorkbookEditUserAccess(string WorkbookId) {
      List<UserRecordAccess> lstUserRecordAccess = null;
      try {
         lstUserRecordAccess = [SELECT RecordId FROM UserRecordAccess
                                WHERE RecordId = :WorkbookId AND UserId = :UserInfo.getUserId() AND HasEditAccess = true];
         AH_UDC_LogHelper.Debug('lstUserRecordAccess size : ' + lstUserRecordAccess.size());
         if (lstUserRecordAccess.size() == 0) return false;
         return true;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.CheckWorkbookEditUserAccess: Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_Shared', 'CheckWorkbookEditUserAccess',
                              'Exception: ' + exc.getMessage(),
                              exc, UserInfo.getUserId(), 'User');
         return false;
      }
   }

   //Check if user has  workbook edit rights or not
   public static boolean CheckWorkbookReadUserAccess(string WorkbookId) {
      List<UserRecordAccess> lstUserRecordAccess = null;
      try {
         lstUserRecordAccess = [SELECT RecordId FROM UserRecordAccess
                                WHERE RecordId = :WorkbookId AND UserId = :UserInfo.getUserId() AND HasReadAccess = true];
         AH_UDC_LogHelper.Debug('lstUserRecordAccess size : ' + lstUserRecordAccess.size());
         if (lstUserRecordAccess.size() == 0) return false;
         return true;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.CheckWorkbookEditUserAccess: Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_Shared', 'CheckWorkbookEditUserAccess',
                              'Exception: ' + exc.getMessage(),
                              exc, UserInfo.getUserId(), 'User');
         return false;
      }
   }

   public static Boolean ChangeUserProfileToChatter() {
      AH_UDC_LogHelper.Debug('AgreeToUseChatter');
      Boolean ProfileChanged = false;
      try {
         //This code performs a callout to a C# API to set the user's profile
         Http h1 = new Http();
         HttpRequest req1 = new HttpRequest();
         req1.setHeader('Content-Type', 'application/json');
         req1.setHeader('accept', 'application/json');
         req1.setMethod('GET');
         req1.setTimeout(120000);

         string profileUrl = AH_UDC_ConfigHelper.GetString('AH_UDC_SetCommunityUserProfileUrl', '') + '/' + UserInfo.getUserId() + '/TRUE';

         AH_UDC_LogHelper.Debug('AgreeToUseChatter: profileEndpoint: ' + profileUrl);
         req1.setEndpoint(profileUrl);
         AH_UDC_LogHelper.Debug('AgreeToUseChatter: Send Request');
         HttpResponse res1 = h1.send(req1);
         AH_UDC_LogHelper.Debug('AgreeToUseChatter: Request returned');
         String IsChatterEnableErrorDetails = res1.getbody();
         AH_UDC_LogHelper.Debug('AgreeToUseChatter: IsChatterEnableErrorDetails: ' + IsChatterEnableErrorDetails);

         ProfileChanged = true;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_SharedWithoutSharing.ChangeUserProfileToChatter: Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_Shared', 'ChangeUserProfileToChatter',
                              'Exception: ' + exc.getMessage(),
                              exc, UserInfo.getUserId(), 'User');
      }
      return ProfileChanged;
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
         if (Test.isRunningTest() && strLogFunctionalArea == 'TestException') Integer a = 1 / 0;
      }
      catch(Exception ex) {
         AH_UDC_LogHelper.Debug(strLogFunctionalArea + '.LogException - Exception: ' + ex);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              strLogFunctionalArea,
                              'LogException',
                              'An exception occurred in LogException method',
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
         if (Test.isRunningTest() && strLogFunctionalArea == 'TestException') Integer a = 1 / 0;
      }
      catch(Exception ex) {
         AH_UDC_LogHelper.Debug(strLogFunctionalArea + '.LogException - Exception: ' + ex);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              strLogFunctionalArea,
                              'LogException',
                              'An exception occurred in LogException method',
                              ex, null, null);
      }
   }
}