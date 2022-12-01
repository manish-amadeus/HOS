/**
 * Name          : AH_UDC_SharedTest
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-Feb-02
 * Description   : Shared Methods for UDC code
 * Dependencies  : AH_UDC_Shared
 **/

@isTest
public class AH_UDC_SharedTest {
   private static final String TEST_USER_NAME = 'test@user.com';

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      Account objAccount = null;
      AH_UDC_PropertyAccount__c objProperty = null;
      NI_Documentation__c objNIDoc = null;
      AH_UDC_Workbook__c objWorkbook = null;
      AH_UDC_Form__c objForm = null;
      AH_UDC_WorkbookStep__c objWorkbookStepOne = null;
      AH_UDC_Response__c objResponse = null;
      User objSysAdminUser = null;
      Contact objContactWithoutExternalUser = null;

      //Insert into Account object
      objAccount = AH_UDC_TestData.GetAccountObject('UDC Test Account 2', 'Hospitality Companies', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave');
      insert objAccount;

      //Insert into Contact object
      objContactWithoutExternalUser = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact 3', 'US', 'Portsmouth', '03801', 'NH',
                                                                       '75 New Hampshire Ave');
      objContactWithoutExternalUser.Email = 'test3@test.com';
      insert objContactWithoutExternalUser;

      //Insert into Account object
      objProperty = AH_UDC_TestData.GetPropertyObject('UDC Test Account 2', 'Portsmouth', 'US',
                                                      '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105', 'St 104', '1 Portsmouth Ave.');
      objProperty.Account__c = objAccount.Id;
      objProperty.Phone__c = '00000000000';
      insert objProperty;

      //Insert a User
      List<Profile> lstSystemProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      system.assert(lstSystemProfile.size() > 0, 'Could not find System Administrator Profile');
      objSysAdminUser = AH_UDC_TestData.GetUserObject(null, lstSystemProfile[0].Id, 'SystemAdmin', 'User', 'TU1.', 'NewmarketTestUser1@amadeus.com', 'NewmarketTestUser1@amadeus.com');
      objSysAdminUser.CommunityNickname = 'TestUser1';
      objSysAdminUser.TimeZoneSidKey = 'America/Indiana/Indianapolis';
      objSysAdminUser.LocaleSidKey = 'en_US';
      objSysAdminUser.EmailEncodingKey = 'ISO-8859-1';
      objSysAdminUser.LanguageLocaleKey = 'en_US';
      objSysAdminUser.No_AD_Account_Standard_User__c = true;
      insert objSysAdminUser;

      //Create Community user with no chatter
      AH_UDC_TestData.CreateUDCCommunityUser('CUserNoChatter', false);

      List<User> lstUser = [Select Id From User Where Email = 'TestCUserNoChatter@amadeus.com'];
      System.assert(lstUser.size() > 0, 'user could not be found.');

      //Insert new record into NI Documentation object for testing
      objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
      objNIDoc.Account__c = objAccount.Id;
      objNIDoc.AH_UDC_PropertyAccount__c = objProperty.Id;
      objNIDoc.OwnerId = objSysAdminUser.id;
      insert objNIDoc;

      System.runAs(lstUser[0]) {
         //Insert Workbook Record
         objWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 1', 'Test Workbook 1 Descriptions', 'Central Sales');
         objWorkbook.RelatedTo__c = objNIDoc.Id;
         objWorkbook.Enabled__c = true;
         objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
         insert objWorkbook;

         string definition = '{"title":"UDCSB - SERVICES - RFP Toolkit - Section Names","FormAssemblyId":"4853168","CustomUrlId":"58c874ca-f1e4-4504-9878-b4b97af509ec","fields":[{"Name":"Token","APIName":"tfa_16","Repeat":"","Picklist":"false"},{"Name":"Security Code","APIName":"tfa_1","Repeat":"","Picklist":"false"},{"Name":"Parent Security Code","APIName":"tfa_17","Repeat":"","Picklist":"false"},{"Name":"Custom Section Name","APIName":"tfa_6","Repeat":"tfa_19[0]","Picklist":"false"},{"Name":"Section Title","APIName":"tfa_18","Repeat":"tfa_19[0]","Picklist":"false"},{"Name":"Yes","APIName":"tfa_11","Repeat":""},{"Name":"No, Specify Custom Section Names","APIName":"tfa_12","Repeat":""},{"Name":"Use the Default Section Names","APIName":"tfa_10","Repeat":""}]}';

         objForm = AH_UDC_TestData.GetForm(definition, '4853168', 'Test Form', '58c874ca-f1e4-4504-9878-b4b97af509ec');
         insert objForm;

         //Insert First Workbook Record 
         objWorkbookStepOne = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 1');
         objWorkbookStepOne.Form__c = objForm.Id;
         insert objWorkbookStepOne;

         Id responseRecordTypeId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
         System.assert(String.isNotBlank(String.valueOf(responseRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY);

         objResponse = AH_UDC_TestData.GetStepResponseObject(objWorkbookStepOne.Id);
         objResponse.RecordTypeId = responseRecordTypeId;
         insert objResponse;

         Id responseQARecordTypeId = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();
         System.assert(String.isNotBlank(String.valueOf(responseQARecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY);

         List<AH_UDC_ResponseQA__c> lstResponseQA = new List<AH_UDC_ResponseQA__c> ();
         AH_UDC_ResponseQA__c responseQA1 = AH_UDC_TestData.GetStepResponseQAObject(objResponse.Id, 'Ques 1', 'Ques1', 'Ans 1', 'Ans1');
         responseQA1.RecordTypeId = responseQARecordTypeId;
         lstResponseQA.add(responseQA1);
         AH_UDC_ResponseQA__c responseQA2 = AH_UDC_TestData.GetStepResponseQAObject(objResponse.Id, 'Ques 1', 'Ques1', 'Ans 1', 'Ans1');
         responseQA2.RecordTypeId = responseQARecordTypeId;
         lstResponseQA.add(responseQA2);
         insert lstResponseQA;
      }
   }

   @IsTest
   public static void TestGetSecurityCode()
   {
      Test.startTest();
      String s = AH_UDC_Shared.GetSecurityCode();
      //TODO: ROBDEV - Code has changed for the size of this SecurityCode - verify this still works
      System.assertEquals(false, String.isEmpty(s), 'A security code was expected but was instead null or empty');
      System.assertEquals(72, s.length(), 'A security code of length 72 was expected');
      Test.stopTest();
   }

   @IsTest
   public static void TestCharAt()
   {
      Test.startTest();
      String s = AH_UDC_Shared.charAt(null, 1);
      System.assertEquals(null, s, 'Expected CharAt to return null string');
      s = AH_UDC_Shared.charAt('', 1);
      System.assertEquals('', s, 'Expected CharAt to return empty string');
      s = AH_UDC_Shared.charAt(null, - 1);
      System.assertEquals(null, s, 'Expected CharAt to return null string');
      s = AH_UDC_Shared.charAt('123', 7);
      System.assertEquals(null, s, 'Expected CharAt to return null string');
      Test.stopTest();
   }

   @isTest
   public static void CreateChatter()
   {
      Test.startTest();
      List<NI_Documentation__c> lstNIDoc = [Select Id From NI_Documentation__c Where Document_Name__c = 'Test NI Document 1'];
      System.assert(lstNIDoc.size() > 0, 'Ni documentation records could not be found.');

      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [Select Id From AH_UDC_WorkbookStep__c Where Name = 'Test Step 1'];
      System.assert(lstWorkbookStep.size() > 0, 'Workbook step records could not be found.');
      List<User> lstUser = [Select Id From User Where Email = 'TestCUserNoChatter@amadeus.com'];
      System.assert(lstUser.size() > 0, 'user could not be found.');

      System.runAs(lstUser[0]) {
         //Test Each Chat Type
         Boolean isChatterCreated = AH_UDC_SharedWithoutSharing.CreateChatter(lstNIDoc[0].Id, null, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookAccessed);
         System.assertEquals(true, isChatterCreated, 'Chatter Workbook Accessed Message was not created.');
         isChatterCreated = AH_UDC_SharedWithoutSharing.CreateChatter(lstNIDoc[0].Id, null, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookComplete);
         System.assertEquals(true, isChatterCreated, 'Chatter Workbook Complete Message was not created.');
         isChatterCreated = AH_UDC_SharedWithoutSharing.CreateChatter(lstNIDoc[0].Id, lstWorkbookStep[0].id, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookStepComplete);
         System.assertEquals(true, isChatterCreated, 'Chatter Workbook Step Complete Message was not created.');

         //Missing message type 
         isChatterCreated = AH_UDC_SharedWithoutSharing.CreateChatter(lstNIDoc[0].Id, lstWorkbookStep[0].id, null);
         System.assert(!isChatterCreated, 'Could not generate Unhandled CreateChatterMessageType error.');
      }
      Test.stopTest();
   }

   @isTest
   public static void CreateChatterErrors()
   {
      Test.startTest();
      List<User> lstSystemAdminUser = [Select Id From User Where Username = 'NewmarketTestUser1@amadeus.com'];
      System.assert(lstSystemAdminUser.size() > 0, 'System Admin users could not be found.');

      List<NI_Documentation__c> lstNIDoc = [Select Id From NI_Documentation__c Where Document_Name__c = 'Test NI Document 1'];
      System.assert(lstNIDoc.size() > 0, 'Ni documentation records could not be found.');
      List<User> lstUser = [Select Id From User Where Email = 'TestCUserNoChatter@amadeus.com'];
      System.assert(lstUser.size() > 0, 'user could not be found.');

      System.runAs(lstUser[0]) {
         //Test Try Catch
         Boolean isChatterCreated = AH_UDC_SharedWithoutSharing.CreateChatter('TestException', null, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookStepComplete);
         System.assertEquals(false, isChatterCreated, 'Chatter failure expected for forced exception');

         //Test Missing NI Doc
         isChatterCreated = AH_UDC_SharedWithoutSharing.CreateChatter(lstSystemAdminUser[0].id, null, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookStepComplete);
         System.assertEquals(false, isChatterCreated, 'Chatter failure expected for NIDocumentationId that does not exist');

         //Workbook step not passed when required
         isChatterCreated = AH_UDC_SharedWithoutSharing.CreateChatter(lstNIDoc[0].Id, null, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookStepComplete);
         System.assertEquals(false, isChatterCreated, 'Chatter failure expected for Workbook Step Complete Message when Step ID is null.');
      }
      Test.stopTest();
   }

   @isTest
   public static void TestGetWorkbookAndItsSteps() {
      List<AH_UDC_Workbook__c> lstWorkbook = [Select Id From AH_UDC_Workbook__c Where Name = 'Test Workbook 1'];
      System.assert(lstWorkbook.size() > 0, 'Workbooks could not be found.');
      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [Select Id, Workbook__c, Workbook__r.ParentWorkbookSent__c, Form__r.Definition__c From AH_UDC_WorkbookStep__c Where Name LIKE 'Test Step%'];
      System.assert(lstWorkbookStep.size() > 0, 'Workbook steps could not be found.');
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email = 'TestCUserNoChatter@amadeus.com'];
      System.assert(lstUser.size() > 0, 'User could not be found.');

      System.runAs(lstUser[0]) {
         AH_UDC_SharedWithoutSharing.GetWorkbookStepSentUrl(lstWorkbookStep[0].Id);
         Map<Id, String> mapStepIds = AH_UDC_SharedWithoutSharing.GetWorkbookStepSentUrls(lstWorkbookStep);
         System.assertEquals(1, mapStepIds.size(), 'Could not match the GetWorkbookStepSentUrls size');

         //Check workbook user access
         Boolean isAccess = AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess(lstWorkbook[0].Id);
         System.assert(isAccess, 'External user does not have access');

         //Test the catch block
         isAccess = AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess('TestException');
         System.assert(!isAccess, 'External user does not have access');

         try {
            Integer a = 0, b = 1, c = b / a;
         }
         catch(Exception ex) {
            AH_UDC_SharedWithoutSharing.LogException('AH_UDC_SharedTest', 'TestGetWorkbookAndItsSteps', 'An exception occurred for the user', null, ex);
         }

         Boolean token = AH_UDC_Shared.InitializeFormTokenEncryptionKey();
         System.assertEquals(false, token, 'Form token encryption key could not valid');

         AH_UDC_Shared.FormField ff = new AH_UDC_Shared.FormField();
         AH_UDC_Shared.FormDefinition formDefinition = (AH_UDC_Shared.FormDefinition) JSON.deserialize(lstWorkbookStep[0].getSObject('Form__r').get('Definition__c').toString(), AH_UDC_Shared.FormDefinition.class);

         List<AH_UDC_Shared.FormField> foundPicklists = formDefinition.getPicklists();
         System.assertEquals(0, foundPicklists.size(), 'foundPicklists value could be size zero');
      }
      Test.stopTest();
   }

   @isTest
   private static void TestCommunityUser() {
      List<Contact> lstContactWithoutExternalUser = [Select Id, Name From Contact Where FirstName = 'Test' And LastName = 'Contact 3'];
      System.assert(lstContactWithoutExternalUser.size() > 0, 'Contact without external user could not be found.');
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email = 'TestCUserNoChatter@amadeus.com'];
      System.assert(lstUser.size() > 0, 'User could not be found.');
      //Create external user if contact does not have
      System.runAs(lstUser[0]) {
         Boolean hasAccess = AH_UDC_SharedWithoutSharing.SetupCommunityAccess(lstContactWithoutExternalUser[0].Id);
         System.assert(!hasAccess, 'Could not able to setup community access');
         try {
            Integer a = 0, b = 1, c = b / a;
         }
         catch(Exception ex) {
            AH_UDC_SharedWithoutSharing.LogException('AH_UDC_SharedTest', 'TestGetWorkbookAndItsSteps', 'An exception occurred for the user', null, ex, null);
         }
      }
      Test.stopTest();
   }

   @isTest
   private static void TestChangeUserProfileToChatter() {
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email = 'TestCUserNoChatter@amadeus.com'];
      System.assert(lstUser.size() > 0, 'User could not be found.');
      //Create external user if contact does not have
      System.runAs(lstUser[0]) {
         //Change the external user profile
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         Boolean isChanged = AH_UDC_SharedWithoutSharing.ChangeUserProfileToChatter();
         System.assertEquals(true, isChanged, 'External User profile has not been changed');
      }
      Test.stopTest();
   }

   @isTest
   private static void NegativeTest() {
      List<AH_UDC_Workbook__c> lstWorkbook = [Select Id From AH_UDC_Workbook__c Where Name = 'Test Workbook 1'];
      System.assert(lstWorkbook.size() > 0, 'workbooks could not be found.');
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email = 'NewmarketTestUser1@amadeus.com'];
      System.runAs(lstUser[0]) {
         //Negative Test for getting a Workbook Step Sent URL
         String stepsUrl = AH_UDC_SharedWithoutSharing.GetWorkbookStepSentUrl(lstWorkbook[0].Id);
         System.assert(String.isBlank(stepsUrl), 'Step Urls should be blank');

         List<AH_UDC_ConfigurationSetting__c> tokenEncryptionKey = [Select Id, Name From AH_UDC_ConfigurationSetting__c Where Name = 'AH_UDC_ViewWorkbookTokenEncryptionKey'];
         System.assert(tokenEncryptionKey.size() > 0, 'Configuration Setting - "AH_UDC_ViewWorkbookTokenEncryptionKey" could not be found');
         Delete tokenEncryptionKey;
         Boolean token = AH_UDC_Shared.InitializeFormTokenEncryptionKey();
         System.assert(!token, 'An exception occurred while calling the InitializeFormTokenEncryptionKey');

         List<AH_UDC_ConfigurationSetting__c> communityUserProfileUrl = [Select Id, Name From AH_UDC_ConfigurationSetting__c Where Name = 'AH_UDC_SetCommunityUserProfileUrl'];
         System.assert(communityUserProfileUrl.size() > 0, 'Configuration Setting - "AH_UDC_SetCommunityUserProfileUrl" could not be found');
         Delete communityUserProfileUrl;
         Boolean isChanged = AH_UDC_SharedWithoutSharing.ChangeUserProfileToChatter();

         List<AH_UDC_ConfigurationSetting__c> communityUserNamePostFix = [Select Id, Name From AH_UDC_ConfigurationSetting__c Where Name = 'AH_UDC_CommunityUserNamePostFix'];
         System.assert(communityUserNamePostFix.size() > 0, 'Configuration Setting - "AH_UDC_CommunityUserNamePostFix" could not be found');
         Delete communityUserNamePostFix;
         List<Contact> objContact = [Select Id From Contact Where Email = 'test3@test.com'];
         System.assert(objContact.size() > 0, 'Contact should not be found');

         Boolean hasAccess = AH_UDC_SharedWithoutSharing.SetupCommunityAccess(objContact[0].Id);
         System.assert(hasAccess, 'Could not have setup community access');

         hasAccess = AH_UDC_SharedWithoutSharing.SetupCommunityAccess('TestException');
         System.assert(!hasAccess, 'Contact have setup community access');

         List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [Select Id, Workbook__c, Workbook__r.ParentWorkbookSent__c, Form__r.Definition__c From AH_UDC_WorkbookStep__c Where Name LIKE 'Test Step%'];
         Map<Id, String> mapStepIds = AH_UDC_SharedWithoutSharing.GetWorkbookStepSentUrls(lstWorkbookStep);
         System.assertEquals(1, mapStepIds.size(), 'Could not match the GetWorkbookStepSentUrls size');
      }

      Test.stopTest();
   }
}