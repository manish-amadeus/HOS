<<<<<<< HEAD
<<<<<<< HEAD
/***********************************************************************************************
  Name            : AH_UDC_SendWorkbook_TEST
  Author          : Umang Ankleshwaria
  Created Date    : 29-Jan-2020
  Last Mod Date   : 08-Feb-2020
  Last Mod By     : Umang Ankleshwaria
  Description     : Test class for Send Workbook page of UDC 
 ************************************************************************************************/
@isTest
public class AH_UDC_SendWorkbook_TEST {
   private static final String TEST_ACCOUNT_NAME_1 = 'Test Account 1';
   private static final String TEST_ACCOUNT_NAME_2 = 'Test Account 2';
   private static final String TEST_FORM_BASE_NAME = 'Test Form';

   //All following constants will have a value by considering single workbook
   //For ex. single workbook will have total 10 (TOTAL_STEP_RECORDS) number of steps
   private static final Integer TOTAL_STEP_RECORDS = 10;
   private static final Integer TOTAL_FORMS = 8;
   private static final Integer TOTAL_PRODUCT_FORMS = 4;
   private static final Integer TOTAL_PRODUCT_FORMS_WITH_COPY_RESPONSE_TRUE = 1;
   private static final Integer TOTAL_CENTRAL_FORMS = 2;
   private static final Integer TOTAL_SHARED_FORMS = 2;
   private static final Integer TOTAL_RESPONSE_RECORDS = 8;
   private static final Integer TOTAL_RESPONSE_QA_RECORDS_PER_RESPONSE = 5;

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    'swWorkbookAdmin', null, false));
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                    'swWorkbookUser', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[1].Id);
      }

      List<Account> lstAccounts = new List<Account> ();
      lstAccounts.add(AH_UDC_TestData.GetAccountObject(TEST_ACCOUNT_NAME_1));
      lstAccounts.add(AH_UDC_TestData.GetAccountObject(TEST_ACCOUNT_NAME_2));
      insert lstAccounts;

      List<Contact> lstContacts = new List<Contact> ();
      Contact objContactOne = AH_UDC_TestData.GetContactObject(lstAccounts[0].Id, 'Test', 'Contact1', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      objContactOne.Status__c = 'Active';
      objContactOne.Email = 'contact1@test.com';
      lstContacts.add(objContactOne);

      Contact objContactTwo = AH_UDC_TestData.GetContactObject(lstAccounts[1].Id, 'Test', 'Contact2', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      objContactTwo.Status__c = 'Active';
      objContactTwo.Email = 'contact2@test.com';
      lstContacts.add(objContactTwo);

      Contact objContactWithoutEmail = AH_UDC_TestData.GetContactObject(lstAccounts[0].Id, 'Test2', 'Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      objContactWithoutEmail.Status__c = 'Active';
      lstContacts.add(objContactWithoutEmail);
      insert lstContacts;

      pse__Region__c objRegion = new pse__Region__c(
         Name = 'Amadeus Hospitality'
      );
      insert objRegion;

      Id recordTypeStandardProject = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_PROJECT_STANDARD_PROJECT).getRecordTypeId();
      System.assert(String.isNotBlank(recordTypeStandardProject), 'RecordType Id ' + AH_UDC_Constants.RECORD_TYPE_PROJECT_STANDARD_PROJECT + ' not found');

      pse__Proj__c objProject = new pse__Proj__c(
                                    RecordTypeId = recordTypeStandardProject,
                                    Name = 'Test Project',
                                    pse__Region__c = objRegion.Id,
                                    pse__Account__c = lstAccounts[0].Id,
                                    Customer_Project_Contact__c = objContactOne.Id
                                 );
      insert objProject;
   }

   //This method will create steps, responses and responses QA records for provided workbook
   private static void CreateWorkbookStepRecords(Id WorkbookId, Boolean IsWorkbookSentRecord) {
      Id FormAssemblyFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FormAssemblyFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY);

      Id AmadeusFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(AmadeusFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM);

      Id FileUploadFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FileUploadFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD);

      List<AH_UDC_Form__c> lstForms = new List<AH_UDC_Form__c> ();
      for (Integer i = 1; i <= TOTAL_FORMS; i++) {
         AH_UDC_Form__c objForm = new AH_UDC_Form__c();
         objForm.Name = TEST_FORM_BASE_NAME + i;
         if(i <= TOTAL_PRODUCT_FORMS) {
            objForm.FormType__c = AH_UDC_Constants.FORM_TYPE_PRODUCT;
            objForm.CopyResponseWhenSendingNew__c = false;
            if(i == TOTAL_PRODUCT_FORMS) {
               //Create last form of file upload
               objForm.RecordTypeId = FileUploadFormRecordTypeId;
            }
            else {
               objForm.RecordTypeId = FormAssemblyFormRecordTypeId;
               //Generate 7 digits form assembly Id
               Integer intFormAssemblyId = (Integer) Math.round(Math.random() * (9000000) + 1000000);
               objForm.FormAssemblyId__c = String.valueOf(intFormAssemblyId);

               if(i == TOTAL_PRODUCT_FORMS_WITH_COPY_RESPONSE_TRUE) {
                  //Allow copying data of product form
                  objForm.CopyResponseWhenSendingNew__c = true;
               }
            }
         }
         else if(i <= (TOTAL_PRODUCT_FORMS + TOTAL_CENTRAL_FORMS)) {
            objForm.RecordTypeId = AmadeusFormRecordTypeId;
            objForm.FormType__c = AH_UDC_Constants.FORM_TYPE_CENTRAL;
         }
         else if(i <= (TOTAL_PRODUCT_FORMS + TOTAL_CENTRAL_FORMS + TOTAL_SHARED_FORMS)) {
            objForm.RecordTypeId = AmadeusFormRecordTypeId;
            objForm.FormType__c = AH_UDC_Constants.FORM_TYPE_SHARED;
         }
         lstForms.add(objForm);
      }
      //AH_UDC_LogHelper.Debug('CreateWorkbookStepRecords => lstForms: ' + lstForms);
      insert lstForms;

      Id WorkbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(WorkbookStepRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP);

      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ();
      for (Integer i = 1; i <= TOTAL_STEP_RECORDS; i++) {
         AH_UDC_WorkbookStep__c objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(WorkbookId, 'Test Step ' + i);
         objWorkbookStep.SortOrder__c = i;
         if (IsWorkbookSentRecord == false) {
            //If not creating sent record type then change workbook step record type
            objWorkbookStep.RecordTypeId = WorkbookStepRecordTypeId;
         }

         if (i <= TOTAL_FORMS) objWorkbookStep.Form__c = lstForms[i - 1].Id;
         else objWorkbookStep.URL__c = 'https://www.amadeus.com/' + i;
         lstWorkbookSteps.add(objWorkbookStep);
      }
      //AH_UDC_LogHelper.Debug('CreateWorkbookStepRecords => lstWorkbookSteps: ' + lstWorkbookSteps);
      insert lstWorkbookSteps;

      //Set prerequisite steps for one of the step
      lstWorkbookSteps[3].Prerequisite_Step__c = lstWorkbookSteps[1].Id;
      update lstWorkbookSteps;
   }

   private static void CreateResponseAndResponseQARecords(Id WorkbookId) {
      Id WorkbookStepSentRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(WorkbookStepSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT);

      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = [SELECT Id, Form__r.RecordTypeId
                                                      FROM AH_UDC_WorkbookStep__c
                                                      WHERE Workbook__c = :WorkbookId
                                                      AND RecordTypeId = :WorkbookStepSentRecordTypeId];
      //AH_UDC_LogHelper.Debug('CreateResponseAndResponseQARecords => lstWorkbookSteps: ' + lstWorkbookSteps);
      System.assert(lstWorkbookSteps.size() > 0, 'Workbook step sent records not found');

      Id FormAssemblyFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FormAssemblyFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY);

      Id AmadeusFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(AmadeusFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM);

      Id FileUploadFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FileUploadFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD);

      Id FormAssemblyResponseRecordTypeId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FormAssemblyResponseRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY);

      Id AmadeusFormResponseRecordTypeId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_AMADEUS_FORM).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(AmadeusFormResponseRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_AMADEUS_FORM);

      List<AH_UDC_Response__c> lstResponses = new List<AH_UDC_Response__c> ();
      Integer intCount = 0;
      for (AH_UDC_WorkbookStep__c objStep : lstWorkbookSteps) { //Create one response record for each step
         //Don't add response for file upload forms
         if(objStep.Form__r.RecordTypeId == FileUploadFormRecordTypeId) continue;
         AH_UDC_Response__c objResponse = new AH_UDC_Response__c();
         if(objStep.Form__r.RecordTypeId == FormAssemblyFormRecordTypeId)
            objResponse.RecordTypeId = FormAssemblyResponseRecordTypeId;
         else if(objStep.Form__r.RecordTypeId == AmadeusFormRecordTypeId)
            objResponse.RecordTypeId = AmadeusFormResponseRecordTypeId;
         objResponse.Responded__c = Datetime.now();
         objResponse.Responder__c = UserInfo.getUserId();
         objResponse.IsComplete__c = false;
         lstResponses.add(objResponse);
         intCount++;

         //Limit number of response records
         if(intCount >= TOTAL_RESPONSE_RECORDS) break;
      }
      //AH_UDC_LogHelper.Debug('CreateResponseAndResponseQARecords => lstResponses: ' + lstResponses);
      //AH_UDC_LogHelper.Debug('CreateResponseAndResponseQARecords => lstResponses size(): ' + lstResponses.size());
      insert lstResponses;

      Id FormAssemblyResponseQARecordTypeId = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FormAssemblyResponseQARecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY);

      Id AmadeusFormResponseQARecordTypeId = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_AMADEUS_FORM).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(AmadeusFormResponseQARecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_AMADEUS_FORM);

      List<AH_UDC_ResponseQA__c> lstResponseQA = new List<AH_UDC_ResponseQA__c> ();
      List<AH_UDC_WorkbookStepResponse__c> lstWorkbookStepResponses = new List<AH_UDC_WorkbookStepResponse__c> ();
      Integer intIndex = 0;
      for (AH_UDC_Response__c objResponse : lstResponses) {
         for (Integer i = 1; i <= TOTAL_RESPONSE_QA_RECORDS_PER_RESPONSE; i++) {
            AH_UDC_ResponseQA__c objResponseQA = new AH_UDC_ResponseQA__c();
            if(objResponse.RecordTypeId == FormAssemblyResponseRecordTypeId) {
               objResponseQA.RecordTypeId = FormAssemblyResponseQARecordTypeId;
               objResponseQA.QuestionField__c = 'tfa' + i;
               objResponseQA.Question__c = 'Test question ' + i;
               objResponseQA.Answer__c = 'Test answer ' + i;
            }
            else if(objResponse.RecordTypeId == AmadeusFormResponseRecordTypeId) {
               objResponseQA.RecordTypeId = AmadeusFormResponseQARecordTypeId;
               objResponseQA.QAJson__c = '{"SortOrder":"1","QuestionField":"AHUDC_1_3_0","Question":"Textbox","AnswerField":"","Answer":"Test1"},{"SortOrder":"2","QuestionField":"AHUDC_1_4_0","Question":"Use Buildings?","AnswerField":"AHUDC_1_4_Yes","Answer":"Yes"},{"SortOrder":"3","QuestionField":"AHUDC_1_5_0","Question":"Banquet?","AnswerField":"","Answer":"true"},{"SortOrder":"4","QuestionField":"AHUDC_1_6_0","Question":"Will you be interfacing your phone system to APMS?","AnswerField":"AHUDC_1_6_No","Answer":"No"}';
            }
            objResponseQA.Response__c = objResponse.Id;
            objResponseQA.SortOrder__c = i;
            lstResponseQA.add(objResponseQA);
         }

         //Insert record into junction object to map response with the step
         lstWorkbookStepResponses.add(new AH_UDC_WorkbookStepResponse__c(WorkbookStep__c = lstWorkbookSteps[intIndex].Id,
                                                                        Response__c = objResponse.Id));
         objResponse.IsComplete__c = true;
         intIndex++;
      }
      //AH_UDC_LogHelper.Debug('CreateResponseAndResponseQARecords => lstResponseQA: ' + lstResponseQA);
      insert lstResponseQA;

      //AH_UDC_LogHelper.Debug('CreateResponseAndResponseQARecords => lstWorkbookStepResponses: ' + lstWorkbookStepResponses);
      insert lstWorkbookStepResponses;

      //Set IsComplete__c true for all respones
      update lstResponses;
   }

   @IsTest
   private static void TestSendWorkbookWithNewOption() {
      List<User> lstUsers = [Select Id From User Where Email like '%swWorkbookUser%'];
      System.assert(lstUsers.size() > 0, 'Failed retrieving test Workbook User');

      List<pse__Proj__c> lstProjects = [SELECT Id FROM pse__Proj__c
                                       WHERE Name = 'Test Project'];
      System.assert(lstProjects.size() > 0, 'Project record not found with the name \'Test Project\'');

      //Test Send Workbook with New option by using Workbook User
      System.runAs(lstUsers[0]) {
         List<Contact> lstContacts = new List<Contact> ([SELECT Id, Name, AccountId, Email
                                                        FROM Contact WHERE Email = 'contact1@test.com' AND Status__c = 'Active']);
         System.assert(lstContacts.size() > 0, 'Contact records not found with the email contact1@test.com');

         List<Account> lstAccounts = [SELECT Id FROM Account where Name = :TEST_ACCOUNT_NAME_1];
         System.assert(lstAccounts.size() > 0, 'Account records not found with the name ' + TEST_ACCOUNT_NAME_1);

         AH_UDC_PropertyAccount__c objPropertyAccount = AH_UDC_TestData.GetPropertyObject('Test Property Account', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
         objPropertyAccount.Account__c = lstAccounts[0].Id;
         insert objPropertyAccount;

         AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
         objWorkbook.Enabled__c = true;
         insert objWorkbook;

         //Create steps record for the workbook
         CreateWorkbookStepRecords(objWorkbook.Id, false);

         ApexPages.StandardController sc = new ApexPages.standardController(lstContacts[0]);
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         pageRef.getParameters().put('id', lstContacts[0].Id);

         Test.setCurrentPageReference(pageRef);
         Test.startTest();
         AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);
         System.assertEquals(objSendWorkbook.ContactId, String.valueOf(lstContacts[0].Id), 'ContactId did not match with ContactId');
         System.assertEquals(objSendWorkbook.SelectedContact.Id, String.valueOf(lstContacts[0].Id), 'ContactId did not match with Selected Contact Id');
         System.assertEquals(objSendWorkbook.SelectedContact.AccountId, String.valueOf(lstContacts[0].AccountId), 'AccountId did not match with Selected Contact Id');
         System.assert(objSendWorkbook.WorkbookProducts != null && objSendWorkbook.WorkbookProducts.size() > 0, 'Product values not found');
         System.assert(String.isNotBlank(objSendWorkbook.SelectedEmailTemplateId) && String.isNotBlank(objSendWorkbook.SelectedEmailTemplateName), 'Default email template not found');
         System.assert(objSendWorkbook.IsErrorOccurred != true, 'Error occurred in SendWorkbook constructor');

         objSendWorkbook.SelectedProduct = 'Central Sales';
         objSendWorkbook.GetEnabledProductWorkbooks();
         System.assert(objSendWorkbook.EnabledProductWorkbooks != null && objSendWorkbook.EnabledProductWorkbooks.size() > 0, 'Workbook record not found for the product - Central Sales');
         System.assert(objSendWorkbook.EnabledProductWorkbooks.size() > 1, 'There must be at least one EnabledProductWorkbook for the test to run successfully');

         //Set require field's values before executing send workbook method
         objSendWorkbook.NiDocumentName = 'Test NI Doc - New Option';
         objSendWorkbook.ProjectId = lstProjects[0].Id;

         //Select first workbook from the drop down, note that element 0 is "--Please select a WORKBOOK--" and should not be used
         objSendWorkbook.SelectedWorkbook = objSendWorkbook.EnabledProductWorkbooks[1].getValue();
         objSendWorkbook.IsUDCWorkbookAccessed = true;
         objSendWorkbook.IsUDCWorkbookCompleted = true;
         objSendWorkbook.IsUDCWorkbookStepCompleted = true;

         //Test Send Workbook method with New option
         //Sending workbook first time so it will not have any response records
         AH_UDC_Workbook__c objWorkbookSent = TestSendWorkbookMethod(objSendWorkbook, 0, 0, 1);

         //Create response and response QA records for new created workbook sent record
         CreateResponseAndResponseQARecords(objWorkbookSent.Id);

         objSendWorkbook.NewNIDocId = null;
         objSendWorkbook.SelectedNIDocIdNew = objWorkbookSent.RelatedTo__c;
         objSendWorkbook.NiDocumentName = 'Test NI Doc - New Option 2';
         
         Integer intResponseCount = TOTAL_CENTRAL_FORMS + TOTAL_SHARED_FORMS + TOTAL_PRODUCT_FORMS_WITH_COPY_RESPONSE_TRUE;
         if(intResponseCount > TOTAL_RESPONSE_RECORDS) intResponseCount = TOTAL_RESPONSE_RECORDS;
         Integer intResponseQACount = intResponseCount * TOTAL_RESPONSE_QA_RECORDS_PER_RESPONSE;
         //Sending workbook with same property account so it should copy shared and central form responses
         //It should copy product form responses in case when CopyResponseWhenSendingNew__c is true
         objWorkbookSent = TestSendWorkbookMethod(objSendWorkbook, intResponseCount, intResponseQACount, 1);

         //Test Send Workbook method without account id
         objSendWorkbook.SelectedContact.Account.Id = null; // Test UDC PropertyAccount creation code when there is no Account
         objSendWorkbook.NewNIDocId = null;
         objSendWorkbook.SelectedNIDocIdNew = objWorkbookSent.RelatedTo__c;
         objSendWorkbook.NiDocumentName = 'Test NI Doc - Without Account Id';

         //Sending workbook with different property account so it should not copy responses
         TestSendWorkbookMethod(objSendWorkbook, 0, 0, 1);

         Test.stopTest();
      }
   }

   @IsTest
   private static void TestSendWorkbookCopyOption() {
      Account objAccount1 = [SELECT Id FROM Account where Name = :TEST_ACCOUNT_NAME_1 LIMIT 1];
      Account objAccount2 = [SELECT Id FROM Account where Name = :TEST_ACCOUNT_NAME_2 LIMIT 1];

      AH_UDC_PropertyAccount__c objPropertyAccount = AH_UDC_TestData.GetPropertyObject('Test Property Account', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
      objPropertyAccount.Account__c = objAccount1.Id;
      insert objPropertyAccount;

      NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document', Date.today().addMonths(1));
      objNIDoc.AH_UDC_PropertyAccount__c = objPropertyAccount.Id;
      insert objNIDoc;

      Id workbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK);

      //Create workbook sent record for copy option
      AH_UDC_Workbook__c objWorkbookSent = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Sent Workbook 1', 'Test Sent Workbook 1 Description', 'Central Sales');
      insert objWorkbookSent;

      //Instead of creating the entire data from testSetup again, only add the WorkbookSent records to avoid CPU/governor limits
      CreateWorkbookStepRecords(objWorkbookSent.Id, true);

      //Create response and response QA records for workbook sent record
      CreateResponseAndResponseQARecords(objWorkbookSent.Id);

      List<pse__Proj__c> lstProjects = [SELECT Id FROM pse__Proj__c
                                       WHERE Name = 'Test Project'];
      System.assert(lstProjects.size() > 0, 'Project record not found with the name \'Test Project\'');

      Test.startTest();
      List<User> listUser = [Select Id From User Where Email like '%swWorkbookAdmin%'];
      System.assertEquals(1, listUser.size(), 'Failed retrieving test Workbook Admin');

      //Test Send Workbook with Copy option by using Workbook Admin user
      System.runAs(listUser[0]) {
         List<Contact> lstContacts = [SELECT Id, Name, AccountId, Email
                                      FROM Contact
                                      WHERE Status__c = 'Active'];
         System.assert(lstContacts.size() > 0, 'Contact records not found with the email contact2@test.com');

         Contact objContactOne = null;
         Contact objContactTwo = null;
         for (Contact objContact : lstContacts) {
            if (objContact.Email == 'contact1@test.com') {
               objContactOne = objContact;
            }
            else if (objContact.Email == 'contact2@test.com') {
               objContactTwo = objContact;
            }
         }

         Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
         System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);

         List<AH_UDC_Workbook__c> lstWorkbookSents = [SELECT Id, RelatedTo__c, Product__c
                                                      FROM AH_UDC_Workbook__c
                                                      WHERE RecordTypeId = :workbookSentRecordTypeId
                                                      AND Enabled__c = true];
         System.assert(lstWorkbookSents.size() > 0, 'Workbook Sent record not found');

         ApexPages.StandardController sc = new ApexPages.standardController(objContactOne);
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         pageRef.getParameters().put('id', objContactOne.Id);

         Test.setCurrentPageReference(pageRef);

         AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);
         System.assertEquals(objSendWorkbook.ContactId, String.valueOf(objContactOne.Id), 'ContactId did not match with ContactId');
         System.assertEquals(objSendWorkbook.SelectedContact.Id, String.valueOf(objContactOne.Id), 'ContactId did not match with Selected Contact Id');
         System.assertEquals(objSendWorkbook.SelectedContact.Account.Id, String.valueOf(objContactOne.AccountId), 'Account.Id did not match with Selected Contact Id');
         System.assertEquals(objSendWorkbook.SelectedContact.AccountId, String.valueOf(objContactOne.AccountId), 'AccountId did not match with Selected Contact Id');
         System.assert(objSendWorkbook.WorkbookProducts != null && objSendWorkbook.WorkbookProducts.size() > 0, 'Product values not found');
         System.assert(String.isNotBlank(objSendWorkbook.SelectedEmailTemplateId) && String.isNotBlank(objSendWorkbook.SelectedEmailTemplateName), 'Default email template not found');
         System.assert(objSendWorkbook.IsErrorOccurred != true, 'Error occurred in SendWorkbook constructor');

         //Test by adding multiple contacts
         objSendWorkbook.AddContactLookup();
         System.assert(objSendWorkbook.ContactLookupList != null && objSendWorkbook.ContactLookupList.size() == 1, 'Error occurred in AddContactLookup method');

         objSendWorkbook.ContactLookupList[0].Id = objContactTwo.Id;
         objSendWorkbook.ContactLookupList[0].Name = objContactTwo.Name;
         objSendWorkbook.ValidateContact();
         System.assert(String.isBlank(objSendWorkbook.ContactLookupList[0].ErrorMessage), 'Not a valid contact provided');

         objSendWorkbook.IsCopyWorkbook = true;
         objSendWorkbook.SelectedNIDocIdCopy = lstWorkbookSents[0].RelatedTo__c;
         objSendWorkbook.GetWorkbookSentDetails();
         System.assertEquals(objSendWorkbook.SelectedProduct, lstWorkbookSents[0].Product__c, 'Product did not match with the product of new created workbook');
         System.assertEquals(objSendWorkbook.SelectedWorkbook, lstWorkbookSents[0].Id, 'Workbook Id did not match with new created workbook');
         System.assert(objSendWorkbook.EnabledProductWorkbooks != null && objSendWorkbook.EnabledProductWorkbooks.size() > 0
                       && objSendWorkbook.EnabledProductWorkbooks[0].getValue() == lstWorkbookSents[0].Id, 'Workbook drop down did not contain new created workbook');
         
         //Set require field's values before executing send workbook method
         objSendWorkbook.NiDocumentName = 'Test NI Doc - Copy Option';
         objSendWorkbook.SelectedWorkbook = lstWorkbookSents[0].Id; //Use inserted workbook to send as a copy
         objSendWorkbook.IsUDCWorkbookAccessed = false;
         objSendWorkbook.IsUDCWorkbookCompleted = false;
         objSendWorkbook.IsUDCWorkbookStepCompleted = false;

         //Test Sendworkbook method with Copy option
         List<AH_UDC_PropertyAccount__c> lstPropertyAccounts = null;

         Integer intResponseQACount = TOTAL_RESPONSE_RECORDS * TOTAL_RESPONSE_QA_RECORDS_PER_RESPONSE;
         //Additional contacts + one default selected contact
         Integer intUDCContactCount = objSendWorkbook.ContactLookupList.size() + 1;
         TestSendWorkbookMethod(objSendWorkbook, TOTAL_RESPONSE_RECORDS, intResponseQACount, intUDCContactCount);

         lstPropertyAccounts = [SELECT Id FROM AH_UDC_PropertyAccount__c
                                WHERE Account__c = :objAccount1.Id];
         System.assert(lstPropertyAccounts.size() > 0, 'PropertyAccount record not created for Workbook that has an Account');


         // ------------------ Test #2 with Account that has no PropertAccount record yet ----------------

         //Remove additional contacts from the list to perform copy workbook second time
         objSendWorkbook.ContactLookupList.clear();
         //Set NI Doc selection null to cover else section in the method GetWorkbookSentDetails
         objSendWorkbook.SelectedNIDocIdCopy = null;
         objSendWorkbook.GetWorkbookSentDetails();
         System.assert(objSendWorkbook.SelectedProduct == null, 'SelectedProduct should be null');
         System.assert(objSendWorkbook.SelectedWorkbook == null, 'SelectedWorkbook should be null');
         System.assert(objSendWorkbook.EnabledProductWorkbooks.size() == 0, 'EnabledProductWorkbooks should be empty');

         //Perform send work and generate error to test scenario of changing workbook sent status to failed
         objSendWorkbook.LogFunctionalArea = 'TestException';
         objSendWorkbook.ContactId = objContactTwo.Id;
         objSendWorkbook.SelectedContact.Id = objContactTwo.Id;
         //This Account does not have a PropertyAccount created. Sending the Workbook should create it, giving more code coverage
         objSendWorkbook.SelectedContact.Account = objAccount2;
         objSendWorkbook.SelectedContact.AccountId = objContactTwo.AccountId; //This account don't have property account created so it will cover creation of property account record
         objSendWorkbook.SelectedWorkbook = lstWorkbookSents[0].Id;
         objSendWorkbook.ProjectId = lstProjects[0].Id;

         //Test by creating new property account
         TestSendWorkbookMethod(objSendWorkbook, TOTAL_RESPONSE_RECORDS, intResponseQACount, 1);

         lstPropertyAccounts = [SELECT Id FROM AH_UDC_PropertyAccount__c
                                WHERE Account__c = :objContactTwo.AccountId];
         System.assert(lstPropertyAccounts.size() > 0, 'PropertyAccount record should have been created as no record existed for this Account');

      }
      Test.stopTest();
   }

   @IsTest
   private static void TestSendWorkbookWithProject() {
      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      objWorkbook.Enabled__c = true;
      insert objWorkbook;

      //Create steps record for the workbook
      CreateWorkbookStepRecords(objWorkbook.Id, false);

      List<User> lstUsers = [Select Id From User Where Email like '%swWorkbookUser%'];
      System.assert(lstUsers.size() > 0, 'Failed retrieving test Workbook User');

      List<pse__Proj__c> lstProjects = [SELECT Id, Name, Customer_Project_Contact__c, pse__Account__c, pse__Account__r.Name
                                       FROM pse__Proj__c
                                       WHERE Name = 'Test Project'];
      System.assert(lstProjects.size() > 0, 'Project record not found with the name \'Test Project\'');

      //Test Send Workbook with New option by using Workbook User
      System.runAs(lstUsers[0]) {
         ApexPages.StandardController sc = new ApexPages.standardController(new Contact());
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         pageRef.getParameters().put('projectid', lstProjects[0].Id);

         Test.setCurrentPageReference(pageRef);
         Test.startTest();
         AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);
         System.assertEquals(objSendWorkbook.ProjectId, String.valueOf(lstProjects[0].Id), 'ProjectId did not match with the one which is passed in parameters');
         System.assertEquals(objSendWorkbook.ProjectName, String.valueOf(lstProjects[0].Name), 'Project Name did not match with the one which is passed in parameters');
         System.assertEquals(objSendWorkbook.ContactId, String.valueOf(lstProjects[0].Customer_Project_Contact__c), 'ContactId did not match with the one which is associated with the Project');
         System.assertEquals(objSendWorkbook.SelectedContact.Id, String.valueOf(lstProjects[0].Customer_Project_Contact__c), 'SelectedContact.Id did not match with the one which is associated with the Project');
         System.assertEquals(objSendWorkbook.SelectedContact.Account.Id, String.valueOf(lstProjects[0].pse__Account__c), 'SelectedContact.Account.Id did not match with the one which is  associated with the Project');
         System.assertEquals(objSendWorkbook.SelectedContact.Account.Name, String.valueOf(lstProjects[0].pse__Account__r.Name), 'SelectedContact.Account.Name did not match with the one which is  associated with the Project');
         
         objSendWorkbook.SelectedProduct = 'Central Sales';
         objSendWorkbook.GetEnabledProductWorkbooks();
         System.assert(objSendWorkbook.EnabledProductWorkbooks != null && objSendWorkbook.EnabledProductWorkbooks.size() > 0, 'Workbook record not found for the product - Central Sales');
         System.assert(objSendWorkbook.EnabledProductWorkbooks.size() > 1, 'There must be at least one EnabledProductWorkbook for the test to run successfully');

         //Set require field's values before executing send workbook method
         objSendWorkbook.NiDocumentName = 'Test NI Doc - New Option';

         //Select first workbook from the drop down, note that element 0 is "--Please select a WORKBOOK--" and should not be used
         objSendWorkbook.SelectedWorkbook = objSendWorkbook.EnabledProductWorkbooks[1].getValue();
         objSendWorkbook.IsUDCWorkbookAccessed = true;
         objSendWorkbook.IsUDCWorkbookCompleted = true;
         objSendWorkbook.IsUDCWorkbookStepCompleted = true;

         //Test Send Workbook method with project
         AH_UDC_Workbook__c objWorkbookSent = TestSendWorkbookMethod(objSendWorkbook, 0, 0, 1);
         
         Test.stopTest();
      }
   }

   //Send workbook and return workbook sent details
   private static AH_UDC_Workbook__c TestSendWorkbookMethod(AH_UDC_SendWorkbook objSendWorkbook, Integer intResponseRecordsCount, Integer intResponseQARecordsCount, Integer intUDCContactRecordsCount) {
      //AH_UDC_LogHelper.Debug('objSendWorkbook.IsCopyWorkbook => ' + objSendWorkbook.IsCopyWorkbook);

      //Test Send Workbook with New option
      objSendWorkbook.SendWorkbook();

      Integer expectedLogCount = 1;
      List<AH_UDC_Log__c> logs = AH_UDC_LogHelper.GetQueuedLogs();
      for (Integer index = 0; index<logs.size(); index++) {
         switch on index {
            when 0 { System.assert(logs[index].LogText__c.startsWith('An exception occurred creating a Follow for user Id'), 'Did not find the expected Log Message on log index: ' + index); }
            when else { System.assert(false, 'Unexpected log message found (missing an ASSERT that should check the validity of the Log message?) Index: ' + index + '... Exception: ' + logs[index].LogText__c); }
         }
      }

      // This clears the queued logs for any other tests later
      AH_UDC_LogHelper.writeQueuedLogs();

      System.assert(String.isNotBlank(String.valueOf(objSendWorkbook.NewNIDocId)), 'Error occurred in SendWorkbook method - NI Doc record not created');

      Id NIDocRecordTypeId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(NIDocRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK);

      List<NI_Documentation__c> lstNIDocs = [SELECT Id, Document_Name__c, Project__c, AH_UDC_ChatterWorkbookAccessed__c, AH_UDC_ChatterWorkbookCompleted__c, AH_UDC_ChatterWorkbookStepCompleted__c
                                             FROM NI_Documentation__c
                                             WHERE Id = :objSendWorkbook.NewNIDocId
                                             AND RecordTypeId = :NIDocRecordTypeId];
      System.assert(lstNIDocs.size()> 0, 'Error occurred in SendWorkbook method - NI Doc was not able to be retrieved');
      System.assertEquals(lstNIDocs[0].Document_Name__c, objSendWorkbook.NiDocumentName, 'Error occurred in SendWorkbook method - value of Document_Name__c in NI Doc record did not match');
      System.assertEquals(lstNIDocs[0].Project__c, objSendWorkbook.ProjectId, 'Error occurred in SendWorkbook method - value of Project__c in NI Doc record did not match');
      System.assertEquals(lstNIDocs[0].AH_UDC_ChatterWorkbookAccessed__c, objSendWorkbook.IsUDCWorkbookAccessed, 'Error occurred in SendWorkbook method - AH_UDC_ChatterWorkbookAccessed__c value did not match');
      System.assertEquals(lstNIDocs[0].AH_UDC_ChatterWorkbookCompleted__c, objSendWorkbook.IsUDCWorkbookCompleted, 'Error occurred in SendWorkbook method - AH_UDC_ChatterWorkbookCompleted__c value did not match');
      System.assertEquals(lstNIDocs[0].AH_UDC_ChatterWorkbookStepCompleted__c, objSendWorkbook.IsUDCWorkbookStepCompleted, 'Error occurred in SendWorkbook method - AH_UDC_ChatterWorkbookStepCompleted__c value did not match');

      Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);

      List<AH_UDC_Workbook__c> lstWorkbookSents = [SELECT Id, Product__c, RelatedTo__c, OriginalWorkbook__c, ParentWorkbookSent__c, SentStatus__c
                                                   FROM AH_UDC_Workbook__c
                                                   WHERE RelatedTo__c = :objSendWorkbook.NewNIDocId
                                                   AND RecordTypeId = :workbookSentRecordTypeId
                                                   AND Enabled__c = true];
      System.assert(lstWorkbookSents.size() > 0, 'Error occurred in SendWorkbook method - Workbook Sent records not created');
      System.assertEquals(AH_UDC_Constants.SENT_STATUS_NEW, lstWorkbookSents[0].SentStatus__c, 'Error occurred in SendWorkbook method - Workbook sent status should be ' + AH_UDC_Constants.SENT_STATUS_NEW + '. Actual status is ' + lstWorkbookSents[0].SentStatus__c);
      if (objSendWorkbook.IsCopyWorkbook == false) {
         System.assert(lstWorkbookSents[0].OriginalWorkbook__c == objSendWorkbook.SelectedWorkbook, 'Error occurred in SendWorkbook method - OriginalWorkbook__c don\'t have correct value in workbook sent record');

         //If parent Workbook NI Doc is selected then check value ParentWorkbookSent__c field's value
         if (String.isNotBlank(String.valueOf(objSendWorkbook.SelectedNIDocIdNew))) {
            List<AH_UDC_Workbook__c> lstParentWorkbooks = [SELECT Id FROM AH_UDC_Workbook__c
                                                           WHERE RelatedTo__c = :objSendWorkbook.SelectedNIDocIdNew];
            if (lstParentWorkbooks.size() > 0) {
               System.assert(lstWorkbookSents[0].ParentWorkbookSent__c == lstParentWorkbooks[0].Id, 'Error occurred in SendWorkbook method - OriginalWorkbook__c don\'t have correct value in workbook sent record');
            }
         }
      }

      Id workbookStepSentRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookStepSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT);

      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = [SELECT Id FROM AH_UDC_WorkbookStep__c
                                                       WHERE Workbook__c = :lstWorkbookSents[0].Id
                                                       AND RecordTypeId = :workbookStepSentRecordTypeId
                                                       AND Enabled__c = true];
      //AH_UDC_LogHelper.Debug('lstWorkbookSteps.size() => ' + lstWorkbookSteps.size());
      System.assertEquals(TOTAL_STEP_RECORDS, lstWorkbookSteps.size(), 'Error occurred in SendWorkbook method - Step records count not matched');

      if (objSendWorkbook.LogFunctionalArea != 'TestException') { //If generating error then don't check response records
         if (intResponseRecordsCount > 0) {
            List<AH_UDC_WorkbookStepResponse__c> lstWorkbookStepResponses = [SELECT Id, Response__c
                                                                              FROM AH_UDC_WorkbookStepResponse__c
                                                                              WHERE WorkbookStep__r.Workbook__c = :lstWorkbookSents[0].Id];
            System.assertEquals(intResponseRecordsCount, lstWorkbookStepResponses.size(), 'Error occurred in SendWorkbook method - Response count did not match');

            Set<Id> lstResponseIds = new Set<Id>();
            for(AH_UDC_WorkbookStepResponse__c objStepResponse : lstWorkbookStepResponses) {
               lstResponseIds.add(objStepResponse.Response__c);
            }

            Integer intResponseQACount = [SELECT COUNT() FROM AH_UDC_ResponseQA__c
                                          WHERE Response__c IN :lstResponseIds];
            System.assertEquals(intResponseQARecordsCount, intResponseQACount, 'Error occurred in SendWorkbook method - Response QA records count did not matched');
         }

         Integer intUDCContact = [SELECT COUNT() FROM AH_UDC_Contact__c
                                  WHERE Document__c = :objSendWorkbook.NewNIDocId];
         System.assertEquals(intUDCContactRecordsCount, intUDCContact, 'Error occurred in SendWorkbook method - UDC Contact records count did not match');

         System.assert(objSendWorkbook.IsErrorOccurred == false, 'Error occurred in SendWorkbook method');
         System.assert(objSendWorkbook.AllowSend, 'Error occurred in sending email');
      }

      return lstWorkbookSents[0];
   }

   @IsTest
   private static void TestCreateCommunityUser() {
      List<Contact> lstContacts = [SELECT Id, Name, Email FROM Contact WHERE Status__c = 'Active'];
      System.assert(lstContacts.size()> 0, 'Contact records not found');

      Contact objContactOne = null;
      Contact objContactTwo = null;
      Contact objContactWithoutEmail = null;
      for (Contact obj : lstContacts) {
         if (String.isBlank(obj.Email)) objContactWithoutEmail = obj;
         else if (obj.Email == 'contact1@test.com') objContactOne = obj;
         else if (obj.Email == 'contact2@test.com') objContactTwo = obj;
      }
      System.assert(objContactOne != null, 'Contact record is not created - objContactOne');
      System.assert(objContactTwo != null, 'Contact record is not created - objContactTwo');
      System.assert(objContactWithoutEmail != null, 'Contact without email is not created');

      ApexPages.StandardController sc = new ApexPages.standardController(lstContacts[0]);
      PageReference pageRef = Page.AH_UDC_SendWorkbook;
      pageRef.getParameters().put('id', objContactOne.Id);

      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);
      System.assert(String.valueOf(objContactOne.Id) == objSendWorkbook.ContactId, 'TestCreateCommunityUser - Contact Id Not Matched');
      System.assert(objSendWorkbook.WorkbookProducts != null && objSendWorkbook.WorkbookProducts.size() > 0, 'TestCreateCommunityUser - Product values not found');
      System.assert(String.isNotBlank(objSendWorkbook.SelectedEmailTemplateId) && String.isNotBlank(objSendWorkbook.SelectedEmailTemplateName), 'Default email template not found');

      objSendWorkbook.AddContactLookup();
      System.assert(objSendWorkbook.ContactLookupList != null && objSendWorkbook.ContactLookupList.size() == 1, 'Error occurred in AddContactLookup method');

      //Validate duplicate contact with same as selected contact
      objSendWorkbook.ContactLookupList[0].Id = objContactOne.Id;
      objSendWorkbook.ValidateContact();
      System.assert(objSendWorkbook.ContactLookupList[0].ErrorMessage == Label.AH_UDC_Duplicate_Contact_Added_For_Send_Workbook_Message, 'Error occurred in contact validation - Error message not set for duplicate contact with the selected contact');
      System.assert(objSendWorkbook.IsErrorOccurred != true, 'There is an error in contact validation.');

      //Validate contact without email
      objSendWorkbook.ContactLookupList[0].Id = objContactWithoutEmail.Id;
      objSendWorkbook.ValidateContact();
      System.assertEquals(Label.AH_UDC_Send_Workbook_Additional_Contact_Email_Required_Message, objSendWorkbook.ContactLookupList[0].ErrorMessage, 'Error occurred in contact validation - Error message not set for contact email');
      System.assert(String.isBlank(objSendWorkbook.SelectedUserEmail), 'There is an error in contact validation - Contact email is not empty');
      System.assert(objSendWorkbook.IsErrorOccurred != true, 'There is an error in Check External User.');

      //Validate with a valid contact
      objSendWorkbook.ContactLookupList[0].Id = objContactTwo.Id;
      objSendWorkbook.ValidateContact();
      System.assert(String.isBlank(objSendWorkbook.ContactLookupList[0].ErrorMessage), 'Error occurred in contact validation - Error message is not empty for a valid contact');
      System.assert(objSendWorkbook.IsErrorOccurred != true, 'There is an error in contact validation.');

      objSendWorkbook.AddContactLookup();
      System.assert(objSendWorkbook.ContactLookupList != null && objSendWorkbook.ContactLookupList.size() == 2, 'Error occurred in AddContactLookup method - Added 2nd contact in list');

      //Validate duplicate contact with same as previously added contact
      objSendWorkbook.ContactLookupList[1].Id = objContactTwo.Id;
      objSendWorkbook.ValidateContact();
      System.assertEquals(Label.AH_UDC_Duplicate_Contact_Added_For_Send_Workbook_Message, objSendWorkbook.ContactLookupList[0].ErrorMessage, 'Error occurred in contact validation - Error message not set for duplicate contact with previously added contact');
      System.assertEquals(Label.AH_UDC_Duplicate_Contact_Added_For_Send_Workbook_Message, objSendWorkbook.ContactLookupList[1].ErrorMessage, 'Error occurred in contact validation - Error message not set for duplicate contact with previously added contact');
      System.assert(objSendWorkbook.IsErrorOccurred != true, 'There is an error in contact validation.');

      //Remove duplicate contact from the list so it will not create community user multiple time
      objSendWorkbook.ContactLookupList.remove(1);
      objSendWorkbook.ValidateContact(); //Call validate function to remove error message from the valid contact
      System.assert(String.isBlank(objSendWorkbook.ContactLookupList[0].ErrorMessage), 'Error occurred in contact validation - Error message not removed from the valid contact');

      AH_UDC_MockResponseGenerator mock;
      mock = new AH_UDC_MockResponseGenerator(AH_UDC_MockResponseGenerator.ResponseType.CreateCommunityUser, 200);
      Test.setMock(HttpCalloutMock.class, mock);

      objSendWorkbook.CreateCommunityUsers();
      //System.assert(objSendWorkbook.IsCommunityUserCreated == true, 'Community user not created');

      //This Method now uses a MOCK to call c# so creation of the users can't be confirmed
      //Set<Id> lstContactIds = new Set<Id> ();
      //lstContactIds.add(objSendWorkbook.ContactId);
      //if (objSendWorkbook.ContactLookupList != null && objSendWorkbook.ContactLookupList.size() > 0) {
         //for (Integer i = 0; i<objSendWorkbook.ContactLookupList.size(); i++) {
            //if (String.isNotBlank(String.valueOf(objSendWorkbook.ContactLookupList[i].Id)) && String.isBlank(objSendWorkbook.ContactLookupList[i].ErrorMessage)) {
               //lstContactIds.add(objSendWorkbook.ContactLookupList[i].Id);
            //}
         //}
      //}
      //Integer intExternalUserCount = [SELECT COUNT() FROM User WHERE ContactId IN :lstContactIds AND IsActive = true];
      //System.assertEquals(intExternalUserCount, lstContactIds.size(), 'External user not created for all selected contacts');
   }

   @isTest
   private static void TestExceptionHandling() {
      ApexPages.StandardController sc = new ApexPages.standardController(new Contact());
      PageReference pageRef = Page.AH_UDC_SendWorkbook;
      Test.setCurrentPageReference(pageRef); //Call the page without passing id parameter to generate error
      Test.startTest();
      AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);

      //Set LogFunctionalArea value to generate error in LogException method
      objSendWorkbook.LogFunctionalArea = 'TestException';
      System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred while executing page without id parameter');
      System.assert(objSendWorkbook.HasPageLoadLogMessages, 'No log entries found in queue list');

      objSendWorkbook.ServerLogMessages();

      System.assertNotEquals(true, objSendWorkbook.HasPageLoadLogMessages, 'PageLoadLogMessages is not empty');
      Integer intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'AH_UDC_SendWorkbook' AND Source__c = 'Constructor'];
      System.assert(intCount > 0, 'Log message entry not found for the error in constructor');

      intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'ServerLogMessages'];
      System.assert(intCount > 0, 'Log message entry not found for the error in ServerLogMessages method');

      objSendWorkbook.IsErrorOccurred = false;
      objSendWorkbook.SendWorkbook();
      System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method SendWorkbook while executing without ContactId and workbook selection');
      intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'SendWorkbook'];
      System.assert(intCount > 0, 'Log message entry not found for the error in SendWorkbook method');

      objSendWorkbook.IsErrorOccurred = false;
      objSendWorkbook.SendEmailToContacts();
      System.assert(objSendWorkbook.IsErrorOccurred, 'Error should have occurred in the method SendEmailToContacts while executing with LogFunctionalArea TestException');
      intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'SendEmailToContacts'];
      System.assert(intCount > 0, 'Log message entry not found for the error in SendEmailToContacts method');

      objSendWorkbook.IsErrorOccurred = false;
      objSendWorkbook.GetWorkbookSentDetails();
      System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method GetWorkbookSentDetails while executing with LogFunctionalArea TestException');
      intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'GetWorkbookSentDetails'];
      System.assert(intCount > 0, 'Log message entry not found for the error in GetWorkbookSentDetails method');

      objSendWorkbook.IsErrorOccurred = false;
      objSendWorkbook.GetProductList();
      System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method GetProductList while executing with LogFunctionalArea TestException');
      intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'GetProductList'];
      System.assert(intCount > 0, 'Log message entry not found for the error in GetProductList method');

      objSendWorkbook.IsErrorOccurred = false;
      objSendWorkbook.GetDefaultEmailTemplateDetails();
      System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method GetDefaultEmailTemplateDetails while executing with LogFunctionalArea TestException');
      intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'GetDefaultEmailTemplateDetails'];
      System.assert(intCount > 0, 'Log message entry not found for the error in GetDefaultEmailTemplateDetails method');

      objSendWorkbook.IsErrorOccurred = false;
      objSendWorkbook.GetDefaultEmailTemplateDetails();
      System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method GetDefaultEmailTemplateDetails while executing with LogFunctionalArea TestException');
      intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'GetDefaultEmailTemplateDetails'];
      System.assert(intCount > 0, 'Log message entry not found for the error in GetDefaultEmailTemplateDetails method');

      Test.stopTest();
   }
=======
/***********************************************************************************************
  Name            : AH_UDC_SendWorkbook_TEST
  Author          : Umang Ankleshwaria
  Created Date    : 29-Jan-2020
  Last Mod Date   : 08-Feb-2020
  Last Mod By     : Umang Ankleshwaria
  Description     : Test class for Send Workbook page of UDC 
 ************************************************************************************************/
@isTest
public class AH_UDC_SendWorkbook_TEST {
   private static final String TEST_ACCOUNT_NAME_1 = 'Test Account 1';
   private static final String TEST_ACCOUNT_NAME_2 = 'Test Account 2';
   private static final String TEST_FORM_BASE_NAME = 'Test Form';

   //All following constants will have a value by considering single workbook
   //For ex. single workbook will have total 10 (TOTAL_STEP_RECORDS) number of steps
   private static final Integer TOTAL_STEP_RECORDS = 10;
   private static final Integer TOTAL_FORMS = 8;
   private static final Integer TOTAL_PRODUCT_FORMS = 4;
   private static final Integer TOTAL_PRODUCT_FORMS_WITH_COPY_RESPONSE_TRUE = 1;
   private static final Integer TOTAL_CENTRAL_FORMS = 2;
   private static final Integer TOTAL_SHARED_FORMS = 2;
   private static final Integer TOTAL_RESPONSE_RECORDS = 8;
   private static final Integer TOTAL_RESPONSE_QA_RECORDS_PER_RESPONSE = 5;

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    'swWorkbookAdmin', null, false));
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                    'swWorkbookUser', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[1].Id);
      }

      List<Account> lstAccounts = new List<Account> ();
      lstAccounts.add(AH_UDC_TestData.GetAccountObject(TEST_ACCOUNT_NAME_1));
      lstAccounts.add(AH_UDC_TestData.GetAccountObject(TEST_ACCOUNT_NAME_2));
      insert lstAccounts;

      List<Contact> lstContacts = new List<Contact> ();
      Contact objContactOne = AH_UDC_TestData.GetContactObject(lstAccounts[0].Id, 'Test', 'Contact1', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      objContactOne.Status__c = 'Active';
      objContactOne.Email = 'contact1@test.com';
      lstContacts.add(objContactOne);

      Contact objContactTwo = AH_UDC_TestData.GetContactObject(lstAccounts[1].Id, 'Test', 'Contact2', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      objContactTwo.Status__c = 'Active';
      objContactTwo.Email = 'contact2@test.com';
      lstContacts.add(objContactTwo);

      Contact objContactWithoutEmail = AH_UDC_TestData.GetContactObject(lstAccounts[0].Id, 'Test2', 'Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      objContactWithoutEmail.Status__c = 'Active';
      lstContacts.add(objContactWithoutEmail);
      insert lstContacts;

      User objUser = AH_UDC_TestData.BuildUser(AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER, AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER),
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                              'CommunityUser', objContactOne.Id, true);
      insert objUser;

      pse__Region__c objRegion = new pse__Region__c(
         Name = 'Amadeus Hospitality'
      );
      insert objRegion;

      Id recordTypeStandardProject = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_PROJECT_STANDARD_PROJECT).getRecordTypeId();
      System.assert(String.isNotBlank(recordTypeStandardProject), 'RecordType Id ' + AH_UDC_Constants.RECORD_TYPE_PROJECT_STANDARD_PROJECT + ' not found');

      pse__Proj__c objProject = new pse__Proj__c(
                                    RecordTypeId = recordTypeStandardProject,
                                    Name = 'Test Project',
                                    pse__Region__c = objRegion.Id,
                                    pse__Account__c = lstAccounts[0].Id,
                                    Customer_Project_Contact__c = objContactOne.Id
                                 );
      insert objProject;
   }

   //This method will create steps, responses and responses QA records for provided workbook
   private static void CreateWorkbookStepRecords(Id WorkbookId, Boolean CreatePreRequisiteSteps) {
      Id FormAssemblyFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FormAssemblyFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY);

      Id AmadeusFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(AmadeusFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM);

      Id FileUploadFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FileUploadFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD);

      List<AH_UDC_Form__c> lstForms = new List<AH_UDC_Form__c> ();
      for (Integer i = 1; i <= TOTAL_FORMS; i++) {
         AH_UDC_Form__c objForm = new AH_UDC_Form__c();
         objForm.Name = TEST_FORM_BASE_NAME + i;
         if(i <= TOTAL_PRODUCT_FORMS) {
            objForm.FormType__c = AH_UDC_Constants.FORM_TYPE_PRODUCT;
            objForm.CopyResponseWhenSendingNew__c = false;
            if(i == TOTAL_PRODUCT_FORMS) {
               //Create last form of file upload
               objForm.RecordTypeId = FileUploadFormRecordTypeId;
            }
            else {
               objForm.RecordTypeId = FormAssemblyFormRecordTypeId;
               //Generate 7 digits form assembly Id
               Integer intFormAssemblyId = (Integer) Math.round(Math.random() * (9000000) + 1000000);
               objForm.FormAssemblyId__c = String.valueOf(intFormAssemblyId);

               if(i <= TOTAL_PRODUCT_FORMS_WITH_COPY_RESPONSE_TRUE) {
                  //Allow copying data of product form
                  objForm.CopyResponseWhenSendingNew__c = true;
               }
            }
         }
         else if(i <= (TOTAL_PRODUCT_FORMS + TOTAL_CENTRAL_FORMS)) {
            objForm.RecordTypeId = AmadeusFormRecordTypeId;
            objForm.FormType__c = AH_UDC_Constants.FORM_TYPE_CENTRAL;
         }
         else if(i <= (TOTAL_PRODUCT_FORMS + TOTAL_CENTRAL_FORMS + TOTAL_SHARED_FORMS)) {
            objForm.RecordTypeId = AmadeusFormRecordTypeId;
            objForm.FormType__c = AH_UDC_Constants.FORM_TYPE_SHARED;
         }
         lstForms.add(objForm);
      }
      AH_UDC_LogHelper.Debug('CreateWorkbookStepRecords => lstForms: ' + lstForms);
      insert lstForms;

      Id WorkbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(WorkbookStepRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP);

      AH_UDC_LogHelper.Debug('CreateWorkbookStepRecords => CreatePreRequisiteSteps: ' + CreatePreRequisiteSteps);
      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ();
      for (Integer i = 1; i <= TOTAL_STEP_RECORDS; i++) {
         AH_UDC_WorkbookStep__c objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(WorkbookId, 'Test Step ' + i);
         objWorkbookStep.SortOrder__c = i;
         objWorkbookStep.RecordTypeId = WorkbookStepRecordTypeId;

         if (i <= TOTAL_FORMS) objWorkbookStep.Form__c = lstForms[i - 1].Id;
         else objWorkbookStep.URL__c = 'https://www.amadeus.com/' + i;
         lstWorkbookSteps.add(objWorkbookStep);
      }
      AH_UDC_LogHelper.Debug('CreateWorkbookStepRecords => lstWorkbookSteps: ' + lstWorkbookSteps);
      insert lstWorkbookSteps;

      if(CreatePreRequisiteSteps) {
         //Set prerequisite steps for one of the step
         lstWorkbookSteps[3].Prerequisite_Step__c = lstWorkbookSteps[1].Id;
         update lstWorkbookSteps;
      }
   }

   private static List<AH_UDC_WorkbookStepResponse__c> CreateResponseAndResponseQARecords(Id WorkbookId) {
      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = [SELECT Id, Form__r.RecordTypeId
                                                      FROM AH_UDC_WorkbookStep__c
                                                      WHERE Workbook__c = :WorkbookId];
      System.assert(lstWorkbookSteps.size() > 0, 'Workbook step sent records not found');

      Id FormAssemblyFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FormAssemblyFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY);

      Id AmadeusFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(AmadeusFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM);

      Id FileUploadFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FileUploadFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD);

      Id FormAssemblyResponseRecordTypeId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FormAssemblyResponseRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY);

      Id AmadeusFormResponseRecordTypeId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_AMADEUS_FORM).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(AmadeusFormResponseRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_AMADEUS_FORM);

      List<AH_UDC_Response__c> lstResponses = new List<AH_UDC_Response__c> ();
      Integer intCount = 0;
      for (AH_UDC_WorkbookStep__c objStep : lstWorkbookSteps) { //Create one response record for each step
         //Don't add response for file upload forms
         if(objStep.Form__r.RecordTypeId == FileUploadFormRecordTypeId) continue;
         AH_UDC_Response__c objResponse = new AH_UDC_Response__c();
         if(objStep.Form__r.RecordTypeId == FormAssemblyFormRecordTypeId)
            objResponse.RecordTypeId = FormAssemblyResponseRecordTypeId;
         else if(objStep.Form__r.RecordTypeId == AmadeusFormRecordTypeId)
            objResponse.RecordTypeId = AmadeusFormResponseRecordTypeId;
         objResponse.Responded__c = Datetime.now();
         objResponse.Responder__c = UserInfo.getUserId();
         objResponse.IsComplete__c = false;
         lstResponses.add(objResponse);
         intCount++;

         //Limit number of response records
         if(intCount >= TOTAL_RESPONSE_RECORDS) break;
      }
      insert lstResponses;

      Id FormAssemblyResponseQARecordTypeId = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FormAssemblyResponseQARecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY);

      Id AmadeusFormResponseQARecordTypeId = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_AMADEUS_FORM).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(AmadeusFormResponseQARecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_AMADEUS_FORM);

      List<AH_UDC_ResponseQA__c> lstResponseQA = new List<AH_UDC_ResponseQA__c> ();
      List<AH_UDC_WorkbookStepResponse__c> lstWorkbookStepResponses = new List<AH_UDC_WorkbookStepResponse__c> ();
      Integer intIndex = 0;
      for (AH_UDC_Response__c objResponse : lstResponses) {
         for (Integer i = 1; i <= TOTAL_RESPONSE_QA_RECORDS_PER_RESPONSE; i++) {
            AH_UDC_ResponseQA__c objResponseQA = new AH_UDC_ResponseQA__c();
            if(objResponse.RecordTypeId == FormAssemblyResponseRecordTypeId) {
               objResponseQA.RecordTypeId = FormAssemblyResponseQARecordTypeId;
               objResponseQA.QuestionField__c = 'tfa' + i;
               objResponseQA.Question__c = 'Test question ' + i;
               objResponseQA.Answer__c = 'Test answer ' + i;
            }
            else if(objResponse.RecordTypeId == AmadeusFormResponseRecordTypeId) {
               objResponseQA.RecordTypeId = AmadeusFormResponseQARecordTypeId;
               objResponseQA.QAJson__c = '{"SortOrder":"1","QuestionField":"AHUDC_1_3_0","Question":"Textbox","AnswerField":"","Answer":"Test1"},{"SortOrder":"2","QuestionField":"AHUDC_1_4_0","Question":"Use Buildings?","AnswerField":"AHUDC_1_4_Yes","Answer":"Yes"},{"SortOrder":"3","QuestionField":"AHUDC_1_5_0","Question":"Banquet?","AnswerField":"","Answer":"true"},{"SortOrder":"4","QuestionField":"AHUDC_1_6_0","Question":"Will you be interfacing your phone system to APMS?","AnswerField":"AHUDC_1_6_No","Answer":"No"}';
            }
            objResponseQA.Response__c = objResponse.Id;
            objResponseQA.SortOrder__c = i;
            lstResponseQA.add(objResponseQA);
         }

         //Insert record into junction object to map response with the step
         lstWorkbookStepResponses.add(new AH_UDC_WorkbookStepResponse__c(WorkbookStep__c = lstWorkbookSteps[intIndex].Id,
                                                                        Response__c = objResponse.Id,
                                                                        IsMostRecentResponse__c = true));
         objResponse.IsComplete__c = true;
         intIndex++;
      }
      insert lstResponseQA;

      insert lstWorkbookStepResponses;

      //Set IsComplete__c true for all respones
      update lstResponses;

      return lstWorkbookStepResponses;
   }

   @IsTest
   private static void TestSendWorkbookWithNewOption() {
      List<User> lstUsers = [Select Id From User Where Email like '%swWorkbookUser%'];
      System.assert(lstUsers.size() > 0, 'Failed retrieving test Workbook User');

      List<pse__Proj__c> lstProjects = [SELECT Id FROM pse__Proj__c
                                       WHERE Name = 'Test Project'];
      System.assert(lstProjects.size() > 0, 'Project record not found with the name \'Test Project\'');

      //Test Send Workbook with New option by using Workbook User
      System.runAs(lstUsers[0]) {
         List<Contact> lstContacts = new List<Contact> ([SELECT Id, Name, AccountId, Email
                                                        FROM Contact WHERE Email = 'contact1@test.com' AND Status__c = 'Active']);
         System.assert(lstContacts.size() > 0, 'Contact records not found with the email contact1@test.com');

         List<Account> lstAccounts = [SELECT Id FROM Account where Name = :TEST_ACCOUNT_NAME_1];
         System.assert(lstAccounts.size() > 0, 'Account records not found with the name ' + TEST_ACCOUNT_NAME_1);

         AH_UDC_PropertyAccount__c objPropertyAccount = AH_UDC_TestData.GetPropertyObject('Test Property Account', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
         objPropertyAccount.Account__c = lstAccounts[0].Id;
         insert objPropertyAccount;

         EmailTemplate objEmailTemplate = new EmailTemplate(Name = 'Test Email Template',
                                                         DeveloperName = 'AH_UDC_Test_Email_Template',
                                                         FolderId = UserInfo.getUserId(),
                                                         TemplateType = 'Text',
                                                         Subject = 'Test Subject',
                                                         Encoding = 'UTF-8');
         insert objEmailTemplate;

         AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
         objWorkbook.EmailTemplate__c = objEmailTemplate.DeveloperName;
         objWorkbook.Enabled__c = true;
         insert objWorkbook;

         //Create steps record for the workbook
         CreateWorkbookStepRecords(objWorkbook.Id, false);

         //Create default responses
         List<AH_UDC_WorkbookStepResponse__c> lstDefaultResponses = CreateResponseAndResponseQARecords(objWorkbook.Id);

         List<AH_UDC_WorkbookStepResponse__c> lstWorkbookStepDefaultResponses = [SELECT Id, WorkbookStep__r.Form__c, WorkbookStep__r.Form__r.FormType__c, WorkbookStep__r.Form__r.CopyResponseWhenSendingNew__c
                                                                                 FROM AH_UDC_WorkbookStepResponse__c
                                                                                 WHERE Id IN :lstDefaultResponses];
         System.assert(lstWorkbookStepDefaultResponses.size() > 0, 'Default responses not found');

         List<AH_UDC_WorkbookStepResponse__c> lstCopiedDefaultResponses = new List<AH_UDC_WorkbookStepResponse__c>();
         for(AH_UDC_WorkbookStepResponse__c objResponse : lstWorkbookStepDefaultResponses) {
            //Central form default responses are not being copied so ignore them
            if(objResponse.WorkbookStep__r.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_SHARED
               || objResponse.WorkbookStep__r.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_PRODUCT)
               lstCopiedDefaultResponses.add(objResponse);
         }

         ApexPages.StandardController sc = new ApexPages.standardController(lstContacts[0]);
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         pageRef.getParameters().put('id', lstContacts[0].Id);

         Test.setCurrentPageReference(pageRef);
         Test.startTest();
         AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);
         System.assertEquals(objSendWorkbook.ContactId, String.valueOf(lstContacts[0].Id), 'ContactId did not match with ContactId');
         System.assertEquals(objSendWorkbook.SelectedContact.Id, String.valueOf(lstContacts[0].Id), 'ContactId did not match with Selected Contact Id');
         System.assertEquals(objSendWorkbook.SelectedContact.AccountId, String.valueOf(lstContacts[0].AccountId), 'AccountId did not match with Selected Contact Id');
         System.assert(objSendWorkbook.WorkbookProducts != null && objSendWorkbook.WorkbookProducts.size() > 0, 'Product values not found');
         System.assert(String.isNotBlank(objSendWorkbook.SelectedEmailTemplateId) && String.isNotBlank(objSendWorkbook.SelectedEmailTemplateName), 'Default email template not found');
         System.assert(objSendWorkbook.IsErrorOccurred != true, 'Error occurred in SendWorkbook constructor');

         objSendWorkbook.SelectedProduct = 'Central Sales';
         objSendWorkbook.GetEnabledProductWorkbooks();
         System.assert(objSendWorkbook.EnabledProductWorkbooks != null && objSendWorkbook.EnabledProductWorkbooks.size() > 0, 'Workbook record not found for the product - Central Sales');
         System.assert(objSendWorkbook.EnabledProductWorkbooks.size() > 1, 'There must be at least one EnabledProductWorkbook for the test to run successfully');

         //Set require field's values before executing send workbook method
         objSendWorkbook.NiDocumentName = 'Test NI Doc - New Option';
         objSendWorkbook.ProjectId = lstProjects[0].Id;

         //Select first workbook from the drop down, note that element 0 is "--Please select a WORKBOOK--" and should not be used
         objSendWorkbook.SelectedWorkbook = objSendWorkbook.EnabledProductWorkbooks[1].getValue();
         objSendWorkbook.IsUDCWorkbookAccessed = true;
         objSendWorkbook.IsUDCWorkbookCompleted = true;
         objSendWorkbook.IsUDCWorkbookStepCompleted = true;

         objSendWorkbook.SetEmailTemplate();
         System.assertEquals(objEmailTemplate.Id, objSendWorkbook.SelectedEmailTemplateId, 'Email template id did not match with the one which is mentioned in the workbook');
         System.assertEquals(objEmailTemplate.Name, objSendWorkbook.SelectedEmailTemplateName, 'Email template name did not match with the one which is mentioned in the workbook');

         Integer intDefaultResponseQACount = lstCopiedDefaultResponses.size() * TOTAL_RESPONSE_QA_RECORDS_PER_RESPONSE;

         //Test Send Workbook method with New option
         //Sending workbook first time so it will not have any response records
         AH_UDC_Workbook__c objWorkbookSent1 = TestSendWorkbookMethod(objSendWorkbook, lstCopiedDefaultResponses, intDefaultResponseQACount, 1);

         //Create response and response QA records for new created workbook sent record
         List<AH_UDC_WorkbookStepResponse__c> lstStepResponses = CreateResponseAndResponseQARecords(objWorkbookSent1.Id);

         objSendWorkbook.NewNIDocId = null;
         objSendWorkbook.SelectedNIDocIdNew = objWorkbookSent1.RelatedTo__c;
         objSendWorkbook.NiDocumentName = 'Test NI Doc - New Option 2';
         
         List<AH_UDC_WorkbookStepResponse__c> lstOriginalWorkbookStepResponses = [SELECT Id, WorkbookStep__r.Form__c, WorkbookStep__r.Form__r.FormType__c, WorkbookStep__r.Form__r.CopyResponseWhenSendingNew__c
                                                                                 FROM AH_UDC_WorkbookStepResponse__c
                                                                                 WHERE Id IN :lstStepResponses
                                                                                 AND IsMostRecentResponse__c = true];
         System.assert(lstOriginalWorkbookStepResponses.size() > 0, 'Original workbook step responses not found');

         List<AH_UDC_WorkbookStepResponse__c> lstCopiedResponses = new List<AH_UDC_WorkbookStepResponse__c>();
         Set<Id> lstFormIdsWithoutResponse = new Set<Id>();
         for(AH_UDC_WorkbookStepResponse__c objResponse : lstOriginalWorkbookStepResponses) {
            if(String.isBlank(String.valueOf(objResponse.WorkbookStep__r.Form__c))) continue;

            if(objResponse.WorkbookStep__r.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_CENTRAL
               || objResponse.WorkbookStep__r.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_SHARED
               || (objResponse.WorkbookStep__r.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_PRODUCT && objResponse.WorkbookStep__r.Form__r.CopyResponseWhenSendingNew__c == true))
               lstCopiedResponses.add(objResponse);
            else {
               lstFormIdsWithoutResponse.add(objResponse.WorkbookStep__r.Form__c);
            }
         }

         for(Id formId : lstFormIdsWithoutResponse) {
            for(AH_UDC_WorkbookStepResponse__c objResponse : lstCopiedDefaultResponses) {
               if(formId == objResponse.WorkbookStep__r.Form__c) {
                  //Add default responses for the setps which has form with copy responses false
                  lstCopiedResponses.add(objResponse);
                  break;
               }
            }
         }

         Integer intResponseCount = TOTAL_CENTRAL_FORMS + TOTAL_SHARED_FORMS + TOTAL_PRODUCT_FORMS_WITH_COPY_RESPONSE_TRUE;
         Integer intResponseQACount = lstCopiedResponses.size() * TOTAL_RESPONSE_QA_RECORDS_PER_RESPONSE;
         //Sending workbook with same property account so it should copy shared and central form responses
         //It should copy product form responses in case when CopyResponseWhenSendingNew__c is true
         AH_UDC_Workbook__c objWorkbookSent2 = TestSendWorkbookMethod(objSendWorkbook, lstCopiedResponses, intResponseQACount, 1);

         //Test Send Workbook method without account id
         objSendWorkbook.SelectedContact.Account.Id = null; // Test UDC PropertyAccount creation code when there is no Account
         objSendWorkbook.NewNIDocId = null;
         objSendWorkbook.SelectedNIDocIdNew = objWorkbookSent2.RelatedTo__c;
         objSendWorkbook.NiDocumentName = 'Test NI Doc - Without Account Id';

         //Sending workbook with different property account so it should copy default responses
         TestSendWorkbookMethod(objSendWorkbook, lstCopiedDefaultResponses, intDefaultResponseQACount, 1);
         Test.stopTest();
      }
   }

   @IsTest
   private static void TestSendWorkbookCopyOption() {
      Account objAccount1 = [SELECT Id FROM Account where Name = :TEST_ACCOUNT_NAME_1 LIMIT 1];
      Account objAccount2 = [SELECT Id FROM Account where Name = :TEST_ACCOUNT_NAME_2 LIMIT 1];

      AH_UDC_PropertyAccount__c objPropertyAccount = AH_UDC_TestData.GetPropertyObject('Test Property Account', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
      objPropertyAccount.Account__c = objAccount1.Id;
      insert objPropertyAccount;

      NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document', Date.today().addMonths(1));
      objNIDoc.AH_UDC_PropertyAccount__c = objPropertyAccount.Id;
      insert objNIDoc;

      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      objWorkbook.Enabled__c = true;
      insert objWorkbook;

      //Create workbook steps in original workbook before sending workbook
      CreateWorkbookStepRecords(objWorkbook.Id, false);

      //Create workbook sent record for copy option
      AH_UDC_Workbook__c objWorkbookSent = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Sent Workbook 1', 'Test Sent Workbook 1 Description', 'Central Sales');
      objWorkbookSent.OriginalWorkbook__c = objWorkbook.Id;
      insert objWorkbookSent;

      Id WorkbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(WorkbookStepRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP);

      //Copy workbook steps from original workbook record
      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = [SELECT Id, RecordTypeId, Workbook__c, Name, Form__c, URL__c
                                                      FROM AH_UDC_WorkbookStep__c
                                                      WHERE Workbook__c = :objWorkbook.Id
                                                      AND RecordTypeId = :WorkbookStepRecordTypeId
                                                      AND Enabled__c = true];
      System.assert(lstWorkbookSteps.size() > 0, 'Workbook step records not found in original workbook');

      Id WorkbookStepSentRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(WorkbookStepSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT);

      List<AH_UDC_WorkbookStep__c> lstWorkbookStepSent = lstWorkbookSteps.deepClone();
      for(AH_UDC_WorkbookStep__c objStep : lstWorkbookStepSent) {
         objStep.Id = null;
         objStep.RecordTypeId = WorkbookStepSentRecordTypeId;
         objStep.Workbook__c = objWorkbookSent.Id;
      }
      //Insert workbook steps for the workbook sent record
      insert lstWorkbookStepSent;
      AH_UDC_LogHelper.Debug('TestSendWorkbookCopyOption => lstWorkbookStepSent: ' + lstWorkbookStepSent);

      delete lstWorkbookSteps[0]; //Delete first step of original workbook  
      lstWorkbookSteps.remove(0);       
      for(integer i = 0; i < lstWorkbookSteps.size(); i++) {
         //Reverse sort order of all steps
         lstWorkbookSteps[i].SortOrder__c = lstWorkbookSteps.size() - i;
      }
      update lstWorkbookSteps;

      AH_UDC_WorkbookStep__c objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 0');
      objWorkbookStep.RecordTypeId = WorkbookStepRecordTypeId;
      objWorkbookStep.URL__c = 'https://www.amadeus.com/0';
      insert objWorkbookStep; //Insert one more step in workbook record

      //Create response and response QA records for workbook sent record
      List<AH_UDC_WorkbookStepResponse__c> lstStepResponses = CreateResponseAndResponseQARecords(objWorkbookSent.Id);
      lstStepResponses.remove(0); //Remove first step's response from the list because that step has been deleted from the original workbook
      
      List<pse__Proj__c> lstProjects = [SELECT Id FROM pse__Proj__c
                                       WHERE Name = 'Test Project'];
      System.assert(lstProjects.size() > 0, 'Project record not found with the name \'Test Project\'');

      Test.startTest();
      List<User> listUser = [Select Id From User Where Email like '%swWorkbookAdmin%'];
      System.assertEquals(1, listUser.size(), 'Failed retrieving test Workbook Admin');

      //Test Send Workbook with Copy option by using Workbook Admin user
      System.runAs(listUser[0]) {
         List<Contact> lstContacts = [SELECT Id, Name, AccountId, Email
                                      FROM Contact
                                      WHERE Status__c = 'Active'];
         System.assert(lstContacts.size() > 0, 'Contact records not found with the email contact2@test.com');

         Contact objContactOne = null;
         Contact objContactTwo = null;
         for (Contact objContact : lstContacts) {
            if (objContact.Email == 'contact1@test.com') {
               objContactOne = objContact;
            }
            else if (objContact.Email == 'contact2@test.com') {
               objContactTwo = objContact;
            }
         }

         Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
         System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);

         List<AH_UDC_Workbook__c> lstWorkbookSents = [SELECT Id, RelatedTo__c, OriginalWorkbook__r.Product__c, OriginalWorkbook__c
                                                      FROM AH_UDC_Workbook__c
                                                      WHERE RecordTypeId = :workbookSentRecordTypeId
                                                      AND Name = 'Test Sent Workbook 1'
                                                      AND Enabled__c = true];
         System.assert(lstWorkbookSents.size() > 0, 'Workbook Sent record not found');

         ApexPages.StandardController sc = new ApexPages.standardController(objContactOne);
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         pageRef.getParameters().put('id', objContactOne.Id);

         Test.setCurrentPageReference(pageRef);

         AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);
         System.assertEquals(objSendWorkbook.ContactId, String.valueOf(objContactOne.Id), 'ContactId did not match with ContactId');
         System.assertEquals(objSendWorkbook.SelectedContact.Id, String.valueOf(objContactOne.Id), 'ContactId did not match with Selected Contact Id');
         System.assertEquals(objSendWorkbook.SelectedContact.Account.Id, String.valueOf(objContactOne.AccountId), 'Account.Id did not match with Selected Contact Id');
         System.assertEquals(objSendWorkbook.SelectedContact.AccountId, String.valueOf(objContactOne.AccountId), 'AccountId did not match with Selected Contact Id');
         System.assert(objSendWorkbook.WorkbookProducts != null && objSendWorkbook.WorkbookProducts.size() > 0, 'Product values not found');
         System.assert(String.isNotBlank(objSendWorkbook.SelectedEmailTemplateId) && String.isNotBlank(objSendWorkbook.SelectedEmailTemplateName), 'Default email template not found');
         System.assert(objSendWorkbook.IsErrorOccurred != true, 'Error occurred in SendWorkbook constructor');

         //Test by adding multiple contacts
         objSendWorkbook.AddContactLookup();
         System.assert(objSendWorkbook.ContactLookupList != null && objSendWorkbook.ContactLookupList.size() == 1, 'Error occurred in AddContactLookup method');

         objSendWorkbook.ContactLookupList[0].Id = objContactTwo.Id;
         objSendWorkbook.ContactLookupList[0].Name = objContactTwo.Name;
         objSendWorkbook.ValidateContact();
         System.assert(String.isBlank(objSendWorkbook.ContactLookupList[0].ErrorMessage), 'Not a valid contact provided');

         objSendWorkbook.IsCopyWorkbook = true;
         objSendWorkbook.SelectedNIDocIdCopy = lstWorkbookSents[0].RelatedTo__c;
         objSendWorkbook.GetWorkbookSentDetails();
         System.assertEquals(lstWorkbookSents[0].OriginalWorkbook__r.Product__c, objSendWorkbook.SelectedProduct, 'Product did not match with the product of new created workbook');
         System.assertEquals(lstWorkbookSents[0].OriginalWorkbook__c, objSendWorkbook.SelectedWorkbook, 'Workbook Id did not match with new created workbook');
         System.assert(objSendWorkbook.EnabledProductWorkbooks != null && objSendWorkbook.EnabledProductWorkbooks.size() > 0, 'EnabledProductWorkbooks should not be empty');
         System.assertEquals(lstWorkbookSents[0].OriginalWorkbook__c, objSendWorkbook.EnabledProductWorkbooks[0].getValue(), 'Workbook drop down does not contain original workbook');
         
         //Set require field's values before executing send workbook method
         objSendWorkbook.NiDocumentName = 'Test NI Doc - Copy Option';
         objSendWorkbook.IsUDCWorkbookAccessed = false;
         objSendWorkbook.IsUDCWorkbookCompleted = false;
         objSendWorkbook.IsUDCWorkbookStepCompleted = false;

         //Test Sendworkbook method with Copy option
         List<AH_UDC_PropertyAccount__c> lstPropertyAccounts = null;

         Integer intResponseQACount = lstStepResponses.size() * TOTAL_RESPONSE_QA_RECORDS_PER_RESPONSE;
         //Additional contacts + one default selected contact
         Integer intUDCContactCount = objSendWorkbook.ContactLookupList.size() + 1;
         TestSendWorkbookMethod(objSendWorkbook, lstStepResponses, intResponseQACount, intUDCContactCount);

         lstPropertyAccounts = [SELECT Id FROM AH_UDC_PropertyAccount__c
                                WHERE Account__c = :objAccount1.Id];
         System.assert(lstPropertyAccounts.size() > 0, 'PropertyAccount record not created for Workbook that has an Account');


         // ------------------ Test #2 with Account that has no PropertAccount record yet ----------------

         //Remove additional contacts from the list to perform copy workbook second time
         objSendWorkbook.ContactLookupList.clear();
         //Set NI Doc selection null to cover else section in the method GetWorkbookSentDetails
         objSendWorkbook.SelectedNIDocIdCopy = null;
         objSendWorkbook.GetWorkbookSentDetails();
         System.assertEquals(null, objSendWorkbook.SelectedProduct, 'SelectedProduct should be null');
         System.assertEquals(null, objSendWorkbook.SelectedWorkbook, 'SelectedWorkbook should be null');
         System.assertEquals(0, objSendWorkbook.EnabledProductWorkbooks.size(), 'EnabledProductWorkbooks should be empty');

         objSendWorkbook.SelectedNIDocIdCopy = lstWorkbookSents[0].RelatedTo__c;
         objSendWorkbook.GetWorkbookSentDetails();
         System.assertEquals(lstWorkbookSents[0].OriginalWorkbook__r.Product__c, objSendWorkbook.SelectedProduct, 'Product did not match with the product of new created workbook');
         System.assertEquals(lstWorkbookSents[0].OriginalWorkbook__c, objSendWorkbook.SelectedWorkbook, 'Workbook Id did not match with new created workbook');
         System.assert(objSendWorkbook.EnabledProductWorkbooks != null && objSendWorkbook.EnabledProductWorkbooks.size() > 0, 'EnabledProductWorkbooks should not be empty');
         System.assertEquals(lstWorkbookSents[0].OriginalWorkbook__c, objSendWorkbook.EnabledProductWorkbooks[0].getValue(), 'Workbook drop down does not contain original workbook');

         //Perform send work and generate error to test scenario of changing workbook sent status to failed
         objSendWorkbook.LogFunctionalArea = 'TestException';
         objSendWorkbook.ContactId = objContactTwo.Id;
         objSendWorkbook.SelectedContact.Id = objContactTwo.Id;
         //This Account does not have a PropertyAccount created. Sending the Workbook should create it, giving more code coverage
         objSendWorkbook.SelectedContact.Account = objAccount2;
         objSendWorkbook.SelectedContact.AccountId = objContactTwo.AccountId; //This account don't have property account created so it will cover creation of property account record
         objSendWorkbook.ProjectId = lstProjects[0].Id;
         objSendWorkbook.NiDocumentName = 'Test NI Doc 2 - Copy Option';

         //Test by creating new property account
         TestSendWorkbookMethod(objSendWorkbook, lstStepResponses, intResponseQACount, 1);

         lstPropertyAccounts = [SELECT Id FROM AH_UDC_PropertyAccount__c
                                WHERE Account__c = :objContactTwo.AccountId];
         System.assert(lstPropertyAccounts.size() > 0, 'PropertyAccount record should have been created as no record existed for this Account');

      }
      Test.stopTest();
   }

   @IsTest
   private static void TestSendWorkbookWithProject() {
      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      objWorkbook.Enabled__c = true;
      insert objWorkbook;

      //Create steps record for the workbook
      CreateWorkbookStepRecords(objWorkbook.Id, true);

      List<User> lstUsers = [Select Id From User Where Email like '%swWorkbookUser%'];
      System.assert(lstUsers.size() > 0, 'Failed retrieving test Workbook User');

      List<pse__Proj__c> lstProjects = [SELECT Id, Name, Customer_Project_Contact__c, pse__Account__c, pse__Account__r.Name
                                       FROM pse__Proj__c
                                       WHERE Name = 'Test Project'];
      System.assert(lstProjects.size() > 0, 'Project record not found with the name \'Test Project\'');

      //Test Send Workbook with New option by using Workbook User
      System.runAs(lstUsers[0]) {
         ApexPages.StandardController sc = new ApexPages.standardController(new Contact());
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         pageRef.getParameters().put('projectid', lstProjects[0].Id);

         Test.setCurrentPageReference(pageRef);
         Test.startTest();
         AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);
         System.assertEquals(objSendWorkbook.ProjectId, String.valueOf(lstProjects[0].Id), 'ProjectId did not match with the one which is passed in parameters');
         System.assertEquals(objSendWorkbook.ProjectName, String.valueOf(lstProjects[0].Name), 'Project Name did not match with the one which is passed in parameters');
         System.assertEquals(objSendWorkbook.ContactId, String.valueOf(lstProjects[0].Customer_Project_Contact__c), 'ContactId did not match with the one which is associated with the Project');
         System.assertEquals(objSendWorkbook.SelectedContact.Id, String.valueOf(lstProjects[0].Customer_Project_Contact__c), 'SelectedContact.Id did not match with the one which is associated with the Project');
         System.assertEquals(objSendWorkbook.SelectedContact.Account.Id, String.valueOf(lstProjects[0].pse__Account__c), 'SelectedContact.Account.Id did not match with the one which is  associated with the Project');
         System.assertEquals(objSendWorkbook.SelectedContact.Account.Name, String.valueOf(lstProjects[0].pse__Account__r.Name), 'SelectedContact.Account.Name did not match with the one which is  associated with the Project');
         
         objSendWorkbook.SelectedProduct = 'Central Sales';
         objSendWorkbook.GetEnabledProductWorkbooks();
         System.assert(objSendWorkbook.EnabledProductWorkbooks != null && objSendWorkbook.EnabledProductWorkbooks.size() > 0, 'Workbook record not found for the product - Central Sales');
         System.assert(objSendWorkbook.EnabledProductWorkbooks.size() > 1, 'There must be at least one EnabledProductWorkbook for the test to run successfully');

         //Set require field's values before executing send workbook method
         objSendWorkbook.NiDocumentName = 'Test NI Doc - New Option';

         //Select first workbook from the drop down, note that element 0 is "--Please select a WORKBOOK--" and should not be used
         objSendWorkbook.SelectedWorkbook = objSendWorkbook.EnabledProductWorkbooks[1].getValue();
         objSendWorkbook.IsUDCWorkbookAccessed = true;
         objSendWorkbook.IsUDCWorkbookCompleted = true;
         objSendWorkbook.IsUDCWorkbookStepCompleted = true;

         //Test Send Workbook method with project
         AH_UDC_Workbook__c objWorkbookSent = TestSendWorkbookMethod(objSendWorkbook, null, 0, 1);
         
         Test.stopTest();
      }
   }

   //Send workbook and return workbook sent details
   private static AH_UDC_Workbook__c TestSendWorkbookMethod(AH_UDC_SendWorkbook objSendWorkbook, List<AH_UDC_WorkbookStepResponse__c> lstOriginalStepResponse, Integer intOriginalResponseQACount, Integer intUDCContactRecordsCount) {
      //Test Send Workbook with New option
      objSendWorkbook.SendWorkbook();

      Integer expectedLogCount = 1;
      List<AH_UDC_Log__c> logs = AH_UDC_LogHelper.GetQueuedLogs();
      for (Integer index = 0; index<logs.size(); index++) {
         switch on index {
            when 0 { System.assert(logs[index].LogText__c.startsWith('An exception occurred creating a Follow for user Id'), 'Did not find the expected Log Message on log index: ' + index); }
            when else { System.assert(false, 'Unexpected log message found (missing an ASSERT that should check the validity of the Log message?) Index: ' + index + '... Exception: ' + logs[index].LogText__c); }
         }
      }

      // This clears the queued logs for any other tests later
      AH_UDC_LogHelper.writeQueuedLogs();

      System.assert(String.isNotBlank(String.valueOf(objSendWorkbook.NewNIDocId)), 'Error occurred in SendWorkbook method - NI Doc record not created');

      Id NIDocRecordTypeId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(NIDocRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK);

      List<NI_Documentation__c> lstNIDocs = [SELECT Id, Document_Name__c, Project__c, AH_UDC_ChatterWorkbookAccessed__c, AH_UDC_ChatterWorkbookCompleted__c, AH_UDC_ChatterWorkbookStepCompleted__c
                                             FROM NI_Documentation__c
                                             WHERE Id = :objSendWorkbook.NewNIDocId
                                             AND RecordTypeId = :NIDocRecordTypeId];
      System.assert(lstNIDocs.size()> 0, 'Error occurred in SendWorkbook method - NI Doc was not able to be retrieved');
      System.assertEquals(lstNIDocs[0].Document_Name__c, objSendWorkbook.NiDocumentName, 'Error occurred in SendWorkbook method - value of Document_Name__c in NI Doc record did not match');
      System.assertEquals(lstNIDocs[0].Project__c, objSendWorkbook.ProjectId, 'Error occurred in SendWorkbook method - value of Project__c in NI Doc record did not match');
      System.assertEquals(lstNIDocs[0].AH_UDC_ChatterWorkbookAccessed__c, objSendWorkbook.IsUDCWorkbookAccessed, 'Error occurred in SendWorkbook method - AH_UDC_ChatterWorkbookAccessed__c value did not match');
      System.assertEquals(lstNIDocs[0].AH_UDC_ChatterWorkbookCompleted__c, objSendWorkbook.IsUDCWorkbookCompleted, 'Error occurred in SendWorkbook method - AH_UDC_ChatterWorkbookCompleted__c value did not match');
      System.assertEquals(lstNIDocs[0].AH_UDC_ChatterWorkbookStepCompleted__c, objSendWorkbook.IsUDCWorkbookStepCompleted, 'Error occurred in SendWorkbook method - AH_UDC_ChatterWorkbookStepCompleted__c value did not match');

      Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);

      List<AH_UDC_Workbook__c> lstWorkbookSents = [SELECT Id, Product__c, RelatedTo__c, OriginalWorkbook__c, ParentWorkbookSent__c, SentStatus__c
                                                   FROM AH_UDC_Workbook__c
                                                   WHERE RelatedTo__c = :objSendWorkbook.NewNIDocId
                                                   AND RecordTypeId = :workbookSentRecordTypeId
                                                   AND Enabled__c = true];
      System.assert(lstWorkbookSents.size() > 0, 'Error occurred in SendWorkbook method - Workbook Sent records not created');
      System.assertEquals(AH_UDC_Constants.SENT_STATUS_NEW, lstWorkbookSents[0].SentStatus__c, 'Error occurred in SendWorkbook method - Workbook sent status should be ' + AH_UDC_Constants.SENT_STATUS_NEW + '. Actual status is ' + lstWorkbookSents[0].SentStatus__c);
      System.assert(lstWorkbookSents[0].OriginalWorkbook__c == objSendWorkbook.SelectedWorkbook, 'Error occurred in SendWorkbook method - OriginalWorkbook__c don\'t have correct value in workbook sent record');
      if (objSendWorkbook.IsCopyWorkbook == false) {
         //If parent Workbook NI Doc is selected then check value ParentWorkbookSent__c field's value
         if (String.isNotBlank(String.valueOf(objSendWorkbook.SelectedNIDocIdNew))) {
            List<AH_UDC_Workbook__c> lstParentWorkbooks = [SELECT Id FROM AH_UDC_Workbook__c
                                                           WHERE RelatedTo__c = :objSendWorkbook.SelectedNIDocIdNew];
            if (lstParentWorkbooks.size() > 0) {
               System.assert(lstWorkbookSents[0].ParentWorkbookSent__c == lstParentWorkbooks[0].Id, 'Error occurred in SendWorkbook method - OriginalWorkbook__c don\'t have correct value in workbook sent record');
            }
         }
      }

      Id workbookStepSentRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookStepSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT);

      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = [SELECT Id FROM AH_UDC_WorkbookStep__c
                                                       WHERE Workbook__c = :lstWorkbookSents[0].Id
                                                       AND RecordTypeId = :workbookStepSentRecordTypeId
                                                       AND Enabled__c = true];
      System.assertEquals(TOTAL_STEP_RECORDS, lstWorkbookSteps.size(), 'Error occurred in SendWorkbook method - Step records count not matched');

      if (objSendWorkbook.LogFunctionalArea != 'TestException') { //If generating error then don't check response records
         System.assert(objSendWorkbook.IsErrorOccurred == false, 'Error occurred in SendWorkbook method');
         System.assert(objSendWorkbook.AllowSend, 'Error occurred in sending email');

         if (lstOriginalStepResponse != null && lstOriginalStepResponse.size() > 0) {
            List<AH_UDC_WorkbookStepResponse__c> lstOriginalWorkbookStepResponses = [SELECT WorkbookStep__r.Form__c, Response__c
                                                                                    FROM AH_UDC_WorkbookStepResponse__c
                                                                                    WHERE Id IN :lstOriginalStepResponse
                                                                                    AND IsMostRecentResponse__c = true];
            System.assert(lstOriginalWorkbookStepResponses.size() > 0, 'Original step responses not found');

            Map<Id, Id> mapOriginalFormIdAndResponseId = new Map<Id, Id>();
            for(AH_UDC_WorkbookStepResponse__c objOriginalStepResponse : lstOriginalWorkbookStepResponses)
               mapOriginalFormIdAndResponseId.put(objOriginalStepResponse.WorkbookStep__r.Form__c, objOriginalStepResponse.Response__c);

            List<AH_UDC_WorkbookStepResponse__c> lstWorkbookStepResponses = [SELECT Id, WorkbookStep__r.Form__c, Response__c
                                                                              FROM AH_UDC_WorkbookStepResponse__c
                                                                              WHERE WorkbookStep__r.Workbook__c = :lstWorkbookSents[0].Id];
            System.assertEquals(lstOriginalWorkbookStepResponses.size(), lstWorkbookStepResponses.size(), 'Error occurred in SendWorkbook method - Response count did not match');

            Integer intResponseCount = 0;
            Set<Id> lstResponseIds = new Set<Id>();
            for(AH_UDC_WorkbookStepResponse__c objStepResponse : lstWorkbookStepResponses) {
               if (mapOriginalFormIdAndResponseId.containsKey(objStepResponse.WorkbookStep__r.Form__c)
                  && mapOriginalFormIdAndResponseId.get(objStepResponse.WorkbookStep__r.Form__c) == objStepResponse.Response__c) {
                  lstResponseIds.add(objStepResponse.Response__c);
                  intResponseCount++;
               }
               else
                  break;
            }
            System.assertEquals(lstWorkbookStepResponses.size(), intResponseCount, 'Step responses count did not match');

            Integer intResponseQACount = [SELECT COUNT() FROM AH_UDC_ResponseQA__c
                                          WHERE Response__c IN :lstResponseIds];
            System.assertEquals(intOriginalResponseQACount, intResponseQACount, 'Error occurred in SendWorkbook method - Response QA records count did not matched');
         }

         Integer intUDCContact = [SELECT COUNT() FROM AH_UDC_Contact__c
                                  WHERE Document__c = :objSendWorkbook.NewNIDocId];
         System.assertEquals(intUDCContactRecordsCount, intUDCContact, 'Error occurred in SendWorkbook method - UDC Contact records count did not match');
      }

      return lstWorkbookSents[0];
   }

   @IsTest
   private static void TestCreateCommunityUser() {
      List<Contact> lstContacts = [SELECT Id, Name, Email FROM Contact WHERE Status__c = 'Active'];
      System.assert(lstContacts.size()> 0, 'Contact records not found');

      Contact objContactOne = null;
      Contact objContactTwo = null;
      Contact objContactWithoutEmail = null;
      for (Contact obj : lstContacts) {
         if (String.isBlank(obj.Email)) objContactWithoutEmail = obj;
         else if (obj.Email == 'contact1@test.com') objContactOne = obj;
         else if (obj.Email == 'contact2@test.com') objContactTwo = obj;
      }
      System.assert(objContactOne != null, 'Contact record is not created - objContactOne');
      System.assert(objContactTwo != null, 'Contact record is not created - objContactTwo');
      System.assert(objContactWithoutEmail != null, 'Contact without email is not created');

      ApexPages.StandardController sc = new ApexPages.standardController(lstContacts[0]);
      PageReference pageRef = Page.AH_UDC_SendWorkbook;
      pageRef.getParameters().put('id', objContactOne.Id);

      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);
      System.assert(String.valueOf(objContactOne.Id) == objSendWorkbook.ContactId, 'TestCreateCommunityUser - Contact Id Not Matched');
      System.assert(objSendWorkbook.WorkbookProducts != null && objSendWorkbook.WorkbookProducts.size() > 0, 'TestCreateCommunityUser - Product values not found');
      System.assert(String.isNotBlank(objSendWorkbook.SelectedEmailTemplateId) && String.isNotBlank(objSendWorkbook.SelectedEmailTemplateName), 'Default email template not found');

      objSendWorkbook.AddContactLookup();
      System.assert(objSendWorkbook.ContactLookupList != null && objSendWorkbook.ContactLookupList.size() == 1, 'Error occurred in AddContactLookup method');

      //Validate duplicate contact with same as selected contact
      objSendWorkbook.ContactLookupList[0].Id = objContactOne.Id;
      objSendWorkbook.ValidateContact();
      System.assert(objSendWorkbook.ContactLookupList[0].ErrorMessage == Label.AH_UDC_Duplicate_Contact_Added_For_Send_Workbook_Message, 'Error occurred in contact validation - Error message not set for duplicate contact with the selected contact');
      System.assert(objSendWorkbook.IsErrorOccurred != true, 'There is an error in contact validation.');

      //Validate contact without email
      objSendWorkbook.ContactLookupList[0].Id = objContactWithoutEmail.Id;
      objSendWorkbook.ValidateContact();
      System.assertEquals(Label.AH_UDC_Send_Workbook_Additional_Contact_Email_Required_Message, objSendWorkbook.ContactLookupList[0].ErrorMessage, 'Error occurred in contact validation - Error message not set for contact email');
      System.assert(String.isBlank(objSendWorkbook.SelectedUserEmail), 'There is an error in contact validation - Contact email is not empty');
      System.assert(objSendWorkbook.IsErrorOccurred != true, 'There is an error in Check External User.');

      //Validate with a valid contact
      objSendWorkbook.ContactLookupList[0].Id = objContactTwo.Id;
      objSendWorkbook.ValidateContact();
      System.assert(String.isBlank(objSendWorkbook.ContactLookupList[0].ErrorMessage), 'Error occurred in contact validation - Error message is not empty for a valid contact');
      System.assert(objSendWorkbook.IsErrorOccurred != true, 'There is an error in contact validation.');

      objSendWorkbook.AddContactLookup();
      System.assert(objSendWorkbook.ContactLookupList != null && objSendWorkbook.ContactLookupList.size() == 2, 'Error occurred in AddContactLookup method - Added 2nd contact in list');

      //Validate duplicate contact with same as previously added contact
      objSendWorkbook.ContactLookupList[1].Id = objContactTwo.Id;
      objSendWorkbook.ValidateContact();
      System.assertEquals(Label.AH_UDC_Duplicate_Contact_Added_For_Send_Workbook_Message, objSendWorkbook.ContactLookupList[0].ErrorMessage, 'Error occurred in contact validation - Error message not set for duplicate contact with previously added contact');
      System.assertEquals(Label.AH_UDC_Duplicate_Contact_Added_For_Send_Workbook_Message, objSendWorkbook.ContactLookupList[1].ErrorMessage, 'Error occurred in contact validation - Error message not set for duplicate contact with previously added contact');
      System.assert(objSendWorkbook.IsErrorOccurred != true, 'There is an error in contact validation.');

      //Remove duplicate contact from the list so it will not create community user multiple time
      objSendWorkbook.ContactLookupList.remove(1);
      objSendWorkbook.ValidateContact(); //Call validate function to remove error message from the valid contact
      System.assert(String.isBlank(objSendWorkbook.ContactLookupList[0].ErrorMessage), 'Error occurred in contact validation - Error message not removed from the valid contact');

      AH_UDC_MockResponseGenerator mock;
      mock = new AH_UDC_MockResponseGenerator(AH_UDC_MockResponseGenerator.ResponseType.CreateCommunityUser, 200);
      Test.setMock(HttpCalloutMock.class, mock);

      objSendWorkbook.CreateCommunityUsers();
      System.assert(objSendWorkbook.IsCommunityUserCreated == true, 'Community user not created');

      //This Method now uses a MOCK to call c# so creation of the users can't be confirmed
      //Set<Id> lstContactIds = new Set<Id> ();
      //lstContactIds.add(objSendWorkbook.ContactId);
      //if (objSendWorkbook.ContactLookupList != null && objSendWorkbook.ContactLookupList.size() > 0) {
         //for (Integer i = 0; i<objSendWorkbook.ContactLookupList.size(); i++) {
            //if (String.isNotBlank(String.valueOf(objSendWorkbook.ContactLookupList[i].Id)) && String.isBlank(objSendWorkbook.ContactLookupList[i].ErrorMessage)) {
               //lstContactIds.add(objSendWorkbook.ContactLookupList[i].Id);
            //}
         //}
      //}
      //Integer intExternalUserCount = [SELECT COUNT() FROM User WHERE ContactId IN :lstContactIds AND IsActive = true];
      //System.assertEquals(intExternalUserCount, lstContactIds.size(), 'External user not created for all selected contacts');
   }

   @isTest
   private static void TestExceptionHandling() {
      AH_UDC_ConfigHelper.SetValue('AH_UDC_SendWorkbookEnabled', false);
      
      List<User> lstUsers = [Select Id From User Where Email like '%swWorkbookUser%'];
      System.assert(lstUsers.size() > 0, 'Failed retrieving test Workbook User');

      System.runAs(lstUsers[0]) {
         ApexPages.StandardController sc = new ApexPages.standardController(new Contact());
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         Test.setCurrentPageReference(pageRef); //Call the page without passing id parameter to generate error
         Test.startTest();
         AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);
         String strSendNotAllowedMsg = AH_UDC_ConfigHelper.GetString('AH_UDC_SendWorkbookDisabledMessage', 'Send Workbook is currently disabled.');
         System.assertEquals(false, objSendWorkbook.AllowSend, 'AllowSend should be false because isSendWorkbookEnabled is set to false');
         System.assertEquals(strSendNotAllowedMsg, objSendWorkbook.SendNotAllowedMessage, 'SendNotAllowedMessage did not match');

         objSendWorkbook.SendWorkbook();
         System.assert(ApexPages.hasMessages(), 'SendWorkbook - Warning message is not added for SendNotAllowedMessage');
         System.assert(ApexPages.getMessages()[0].getDetail().contains(strSendNotAllowedMsg), 'SendWorkbook - SendNotAllowedMessage did not match');

         AH_UDC_ConfigHelper.SetValue('AH_UDC_SendWorkbookEnabled', true);
         objSendWorkbook = new AH_UDC_SendWorkbook(sc);

         //Set LogFunctionalArea value to generate error in LogException method
         objSendWorkbook.LogFunctionalArea = 'TestException';
         System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred while executing page without id parameter');
         System.assert(objSendWorkbook.HasPageLoadLogMessages, 'No log entries found in queue list');

         objSendWorkbook.ServerLogMessages();
         System.assertNotEquals(true, objSendWorkbook.HasPageLoadLogMessages, 'PageLoadLogMessages is not empty');
         Integer intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'AH_UDC_SendWorkbook' AND Source__c = 'Constructor'];
         System.assert(intCount > 0, 'Log message entry not found for the error in constructor');

         intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'ServerLogMessages'];
         System.assert(intCount > 0, 'Log message entry not found for the error in ServerLogMessages method');

         objSendWorkbook.IsErrorOccurred = false;
         objSendWorkbook.SendWorkbook();
         System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method SendWorkbook while executing without ContactId and workbook selection');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'SendWorkbook'];
         System.assert(intCount > 0, 'Log message entry not found for the error in SendWorkbook method');

         objSendWorkbook.IsErrorOccurred = false;
         objSendWorkbook.SendEmailToContacts();
         System.assert(objSendWorkbook.IsErrorOccurred, 'Error should have occurred in the method SendEmailToContacts while executing with LogFunctionalArea TestException');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'SendEmailToContacts'];
         System.assert(intCount > 0, 'Log message entry not found for the error in SendEmailToContacts method');

         objSendWorkbook.IsErrorOccurred = false;
         objSendWorkbook.GetWorkbookSentDetails();
         System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method GetWorkbookSentDetails while executing with LogFunctionalArea TestException');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'GetWorkbookSentDetails'];
         System.assert(intCount > 0, 'Log message entry not found for the error in GetWorkbookSentDetails method');

         objSendWorkbook.IsErrorOccurred = false;
         objSendWorkbook.GetProductList();
         System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method GetProductList while executing with LogFunctionalArea TestException');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'GetProductList'];
         System.assert(intCount > 0, 'Log message entry not found for the error in GetProductList method');

         objSendWorkbook.IsErrorOccurred = false;
         objSendWorkbook.GetDefaultEmailTemplateDetails();
         System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method GetDefaultEmailTemplateDetails while executing with LogFunctionalArea TestException');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'GetDefaultEmailTemplateDetails'];
         System.assert(intCount > 0, 'Log message entry not found for the error in GetDefaultEmailTemplateDetails method');

         objSendWorkbook.IsErrorOccurred = false;
         objSendWorkbook.ValidateContact();
         System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method ValidateContact while executing with LogFunctionalArea TestException');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'ValidateContact'];
         System.assert(intCount > 0, 'Log message entry not found for the error in ValidateContact method');

         objSendWorkbook.IsErrorOccurred = false;
         objSendWorkbook.AddContactLookup();
         System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method AddContactLookup while executing with LogFunctionalArea TestException');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'AddContactLookup'];
         System.assert(intCount > 0, 'Log message entry not found for the error in AddContactLookup method');

         Test.stopTest();
      }
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
/***********************************************************************************************
  Name            : AH_UDC_SendWorkbook_TEST
  Author          : Umang Ankleshwaria
  Created Date    : 29-Jan-2020
  Last Mod Date   : 08-Feb-2020
  Last Mod By     : Umang Ankleshwaria
  Description     : Test class for Send Workbook page of UDC 
 ************************************************************************************************/
@isTest
public class AH_UDC_SendWorkbook_TEST {
   private static final String TEST_ACCOUNT_NAME_1 = 'Test Account 1';
   private static final String TEST_ACCOUNT_NAME_2 = 'Test Account 2';
   private static final String TEST_FORM_BASE_NAME = 'Test Form';

   //All following constants will have a value by considering single workbook
   //For ex. single workbook will have total 10 (TOTAL_STEP_RECORDS) number of steps
   private static final Integer TOTAL_STEP_RECORDS = 10;
   private static final Integer TOTAL_FORMS = 8;
   private static final Integer TOTAL_PRODUCT_FORMS = 4;
   private static final Integer TOTAL_PRODUCT_FORMS_WITH_COPY_RESPONSE_TRUE = 1;
   private static final Integer TOTAL_CENTRAL_FORMS = 2;
   private static final Integer TOTAL_SHARED_FORMS = 2;
   private static final Integer TOTAL_RESPONSE_RECORDS = 8;
   private static final Integer TOTAL_RESPONSE_QA_RECORDS_PER_RESPONSE = 5;

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    'swWorkbookAdmin', null, false));
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                    'swWorkbookUser', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[1].Id);
      }

      List<Account> lstAccounts = new List<Account> ();
      lstAccounts.add(AH_UDC_TestData.GetAccountObject(TEST_ACCOUNT_NAME_1));
      lstAccounts.add(AH_UDC_TestData.GetAccountObject(TEST_ACCOUNT_NAME_2));
      insert lstAccounts;

      List<Contact> lstContacts = new List<Contact> ();
      Contact objContactOne = AH_UDC_TestData.GetContactObject(lstAccounts[0].Id, 'Test', 'Contact1', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      objContactOne.Status__c = 'Active';
      objContactOne.Email = 'contact1@test.com';
      lstContacts.add(objContactOne);

      Contact objContactTwo = AH_UDC_TestData.GetContactObject(lstAccounts[1].Id, 'Test', 'Contact2', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      objContactTwo.Status__c = 'Active';
      objContactTwo.Email = 'contact2@test.com';
      lstContacts.add(objContactTwo);

      Contact objContactWithoutEmail = AH_UDC_TestData.GetContactObject(lstAccounts[0].Id, 'Test2', 'Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      objContactWithoutEmail.Status__c = 'Active';
      lstContacts.add(objContactWithoutEmail);
      insert lstContacts;

      User objUser = AH_UDC_TestData.BuildUser(AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER, AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER),
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                              'CommunityUser', objContactOne.Id, true);
      insert objUser;

      pse__Region__c objRegion = new pse__Region__c(
         Name = 'Amadeus Hospitality'
      );
      insert objRegion;

      Id recordTypeStandardProject = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_PROJECT_STANDARD_PROJECT).getRecordTypeId();
      System.assert(String.isNotBlank(recordTypeStandardProject), 'RecordType Id ' + AH_UDC_Constants.RECORD_TYPE_PROJECT_STANDARD_PROJECT + ' not found');

      pse__Proj__c objProject = new pse__Proj__c(
                                    RecordTypeId = recordTypeStandardProject,
                                    Name = 'Test Project',
                                    pse__Region__c = objRegion.Id,
                                    pse__Account__c = lstAccounts[0].Id,
                                    Customer_Project_Contact__c = objContactOne.Id
                                 );
      insert objProject;
   }

   //This method will create steps, responses and responses QA records for provided workbook
   private static void CreateWorkbookStepRecords(Id WorkbookId, Boolean CreatePreRequisiteSteps) {
      Id FormAssemblyFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FormAssemblyFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY);

      Id AmadeusFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(AmadeusFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM);

      Id FileUploadFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FileUploadFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD);

      List<AH_UDC_Form__c> lstForms = new List<AH_UDC_Form__c> ();
      for (Integer i = 1; i <= TOTAL_FORMS; i++) {
         AH_UDC_Form__c objForm = new AH_UDC_Form__c();
         objForm.Name = TEST_FORM_BASE_NAME + i;
         if(i <= TOTAL_PRODUCT_FORMS) {
            objForm.FormType__c = AH_UDC_Constants.FORM_TYPE_PRODUCT;
            objForm.CopyResponseWhenSendingNew__c = false;
            if(i == TOTAL_PRODUCT_FORMS) {
               //Create last form of file upload
               objForm.RecordTypeId = FileUploadFormRecordTypeId;
            }
            else {
               objForm.RecordTypeId = FormAssemblyFormRecordTypeId;
               //Generate 7 digits form assembly Id
               Integer intFormAssemblyId = (Integer) Math.round(Math.random() * (9000000) + 1000000);
               objForm.FormAssemblyId__c = String.valueOf(intFormAssemblyId);

               if(i <= TOTAL_PRODUCT_FORMS_WITH_COPY_RESPONSE_TRUE) {
                  //Allow copying data of product form
                  objForm.CopyResponseWhenSendingNew__c = true;
               }
            }
         }
         else if(i <= (TOTAL_PRODUCT_FORMS + TOTAL_CENTRAL_FORMS)) {
            objForm.RecordTypeId = AmadeusFormRecordTypeId;
            objForm.FormType__c = AH_UDC_Constants.FORM_TYPE_CENTRAL;
         }
         else if(i <= (TOTAL_PRODUCT_FORMS + TOTAL_CENTRAL_FORMS + TOTAL_SHARED_FORMS)) {
            objForm.RecordTypeId = AmadeusFormRecordTypeId;
            objForm.FormType__c = AH_UDC_Constants.FORM_TYPE_SHARED;
         }
         lstForms.add(objForm);
      }
      AH_UDC_LogHelper.Debug('CreateWorkbookStepRecords => lstForms: ' + lstForms);
      insert lstForms;

      Id WorkbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(WorkbookStepRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP);

      AH_UDC_LogHelper.Debug('CreateWorkbookStepRecords => CreatePreRequisiteSteps: ' + CreatePreRequisiteSteps);
      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ();
      for (Integer i = 1; i <= TOTAL_STEP_RECORDS; i++) {
         AH_UDC_WorkbookStep__c objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(WorkbookId, 'Test Step ' + i);
         objWorkbookStep.SortOrder__c = i;
         objWorkbookStep.RecordTypeId = WorkbookStepRecordTypeId;

         if (i <= TOTAL_FORMS) objWorkbookStep.Form__c = lstForms[i - 1].Id;
         else objWorkbookStep.URL__c = 'https://www.amadeus.com/' + i;
         lstWorkbookSteps.add(objWorkbookStep);
      }
      AH_UDC_LogHelper.Debug('CreateWorkbookStepRecords => lstWorkbookSteps: ' + lstWorkbookSteps);
      insert lstWorkbookSteps;

      if(CreatePreRequisiteSteps) {
         //Set prerequisite steps for one of the step
         lstWorkbookSteps[3].Prerequisite_Step__c = lstWorkbookSteps[1].Id;
         update lstWorkbookSteps;
      }
   }

   private static List<AH_UDC_WorkbookStepResponse__c> CreateResponseAndResponseQARecords(Id WorkbookId) {
      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = [SELECT Id, Form__r.RecordTypeId
                                                      FROM AH_UDC_WorkbookStep__c
                                                      WHERE Workbook__c = :WorkbookId];
      System.assert(lstWorkbookSteps.size() > 0, 'Workbook step sent records not found');

      Id FormAssemblyFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FormAssemblyFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY);

      Id AmadeusFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(AmadeusFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM);

      Id FileUploadFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FileUploadFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD);

      Id FormAssemblyResponseRecordTypeId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FormAssemblyResponseRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY);

      Id AmadeusFormResponseRecordTypeId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_AMADEUS_FORM).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(AmadeusFormResponseRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_AMADEUS_FORM);

      List<AH_UDC_Response__c> lstResponses = new List<AH_UDC_Response__c> ();
      Integer intCount = 0;
      for (AH_UDC_WorkbookStep__c objStep : lstWorkbookSteps) { //Create one response record for each step
         //Don't add response for file upload forms
         if(objStep.Form__r.RecordTypeId == FileUploadFormRecordTypeId) continue;
         AH_UDC_Response__c objResponse = new AH_UDC_Response__c();
         if(objStep.Form__r.RecordTypeId == FormAssemblyFormRecordTypeId)
            objResponse.RecordTypeId = FormAssemblyResponseRecordTypeId;
         else if(objStep.Form__r.RecordTypeId == AmadeusFormRecordTypeId)
            objResponse.RecordTypeId = AmadeusFormResponseRecordTypeId;
         objResponse.Responded__c = Datetime.now();
         objResponse.Responder__c = UserInfo.getUserId();
         objResponse.IsComplete__c = false;
         lstResponses.add(objResponse);
         intCount++;

         //Limit number of response records
         if(intCount >= TOTAL_RESPONSE_RECORDS) break;
      }
      insert lstResponses;

      Id FormAssemblyResponseQARecordTypeId = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FormAssemblyResponseQARecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY);

      Id AmadeusFormResponseQARecordTypeId = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_AMADEUS_FORM).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(AmadeusFormResponseQARecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_AMADEUS_FORM);

      List<AH_UDC_ResponseQA__c> lstResponseQA = new List<AH_UDC_ResponseQA__c> ();
      List<AH_UDC_WorkbookStepResponse__c> lstWorkbookStepResponses = new List<AH_UDC_WorkbookStepResponse__c> ();
      Integer intIndex = 0;
      for (AH_UDC_Response__c objResponse : lstResponses) {
         for (Integer i = 1; i <= TOTAL_RESPONSE_QA_RECORDS_PER_RESPONSE; i++) {
            AH_UDC_ResponseQA__c objResponseQA = new AH_UDC_ResponseQA__c();
            if(objResponse.RecordTypeId == FormAssemblyResponseRecordTypeId) {
               objResponseQA.RecordTypeId = FormAssemblyResponseQARecordTypeId;
               objResponseQA.QuestionField__c = 'tfa' + i;
               objResponseQA.Question__c = 'Test question ' + i;
               objResponseQA.Answer__c = 'Test answer ' + i;
            }
            else if(objResponse.RecordTypeId == AmadeusFormResponseRecordTypeId) {
               objResponseQA.RecordTypeId = AmadeusFormResponseQARecordTypeId;
               objResponseQA.QAJson__c = '{"SortOrder":"1","QuestionField":"AHUDC_1_3_0","Question":"Textbox","AnswerField":"","Answer":"Test1"},{"SortOrder":"2","QuestionField":"AHUDC_1_4_0","Question":"Use Buildings?","AnswerField":"AHUDC_1_4_Yes","Answer":"Yes"},{"SortOrder":"3","QuestionField":"AHUDC_1_5_0","Question":"Banquet?","AnswerField":"","Answer":"true"},{"SortOrder":"4","QuestionField":"AHUDC_1_6_0","Question":"Will you be interfacing your phone system to APMS?","AnswerField":"AHUDC_1_6_No","Answer":"No"}';
            }
            objResponseQA.Response__c = objResponse.Id;
            objResponseQA.SortOrder__c = i;
            lstResponseQA.add(objResponseQA);
         }

         //Insert record into junction object to map response with the step
         lstWorkbookStepResponses.add(new AH_UDC_WorkbookStepResponse__c(WorkbookStep__c = lstWorkbookSteps[intIndex].Id,
                                                                        Response__c = objResponse.Id,
                                                                        IsMostRecentResponse__c = true));
         objResponse.IsComplete__c = true;
         intIndex++;
      }
      insert lstResponseQA;

      insert lstWorkbookStepResponses;

      //Set IsComplete__c true for all respones
      update lstResponses;

      return lstWorkbookStepResponses;
   }

   @IsTest
   private static void TestSendWorkbookWithNewOption() {
      List<User> lstUsers = [Select Id From User Where Email like '%swWorkbookUser%'];
      System.assert(lstUsers.size() > 0, 'Failed retrieving test Workbook User');

      List<pse__Proj__c> lstProjects = [SELECT Id FROM pse__Proj__c
                                       WHERE Name = 'Test Project'];
      System.assert(lstProjects.size() > 0, 'Project record not found with the name \'Test Project\'');

      //Test Send Workbook with New option by using Workbook User
      System.runAs(lstUsers[0]) {
         List<Contact> lstContacts = new List<Contact> ([SELECT Id, Name, AccountId, Email
                                                        FROM Contact WHERE Email = 'contact1@test.com' AND Status__c = 'Active']);
         System.assert(lstContacts.size() > 0, 'Contact records not found with the email contact1@test.com');

         List<Account> lstAccounts = [SELECT Id FROM Account where Name = :TEST_ACCOUNT_NAME_1];
         System.assert(lstAccounts.size() > 0, 'Account records not found with the name ' + TEST_ACCOUNT_NAME_1);

         AH_UDC_PropertyAccount__c objPropertyAccount = AH_UDC_TestData.GetPropertyObject('Test Property Account', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
         objPropertyAccount.Account__c = lstAccounts[0].Id;
         insert objPropertyAccount;

         EmailTemplate objEmailTemplate = new EmailTemplate(Name = 'Test Email Template',
                                                         DeveloperName = 'AH_UDC_Test_Email_Template',
                                                         FolderId = UserInfo.getUserId(),
                                                         TemplateType = 'Text',
                                                         Subject = 'Test Subject',
                                                         Encoding = 'UTF-8');
         insert objEmailTemplate;

         AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
         objWorkbook.EmailTemplate__c = objEmailTemplate.DeveloperName;
         objWorkbook.Enabled__c = true;
         insert objWorkbook;

         //Create steps record for the workbook
         CreateWorkbookStepRecords(objWorkbook.Id, false);

         //Create default responses
         List<AH_UDC_WorkbookStepResponse__c> lstDefaultResponses = CreateResponseAndResponseQARecords(objWorkbook.Id);

         List<AH_UDC_WorkbookStepResponse__c> lstWorkbookStepDefaultResponses = [SELECT Id, WorkbookStep__r.Form__c, WorkbookStep__r.Form__r.FormType__c, WorkbookStep__r.Form__r.CopyResponseWhenSendingNew__c
                                                                                 FROM AH_UDC_WorkbookStepResponse__c
                                                                                 WHERE Id IN :lstDefaultResponses];
         System.assert(lstWorkbookStepDefaultResponses.size() > 0, 'Default responses not found');

         List<AH_UDC_WorkbookStepResponse__c> lstCopiedDefaultResponses = new List<AH_UDC_WorkbookStepResponse__c>();
         for(AH_UDC_WorkbookStepResponse__c objResponse : lstWorkbookStepDefaultResponses) {
            //Central form default responses are not being copied so ignore them
            if(objResponse.WorkbookStep__r.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_SHARED
               || objResponse.WorkbookStep__r.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_PRODUCT)
               lstCopiedDefaultResponses.add(objResponse);
         }

         ApexPages.StandardController sc = new ApexPages.standardController(lstContacts[0]);
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         pageRef.getParameters().put('id', lstContacts[0].Id);

         Test.setCurrentPageReference(pageRef);
         Test.startTest();
         AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);
         System.assertEquals(objSendWorkbook.ContactId, String.valueOf(lstContacts[0].Id), 'ContactId did not match with ContactId');
         System.assertEquals(objSendWorkbook.SelectedContact.Id, String.valueOf(lstContacts[0].Id), 'ContactId did not match with Selected Contact Id');
         System.assertEquals(objSendWorkbook.SelectedContact.AccountId, String.valueOf(lstContacts[0].AccountId), 'AccountId did not match with Selected Contact Id');
         System.assert(objSendWorkbook.WorkbookProducts != null && objSendWorkbook.WorkbookProducts.size() > 0, 'Product values not found');
         System.assert(String.isNotBlank(objSendWorkbook.SelectedEmailTemplateId) && String.isNotBlank(objSendWorkbook.SelectedEmailTemplateName), 'Default email template not found');
         System.assert(objSendWorkbook.IsErrorOccurred != true, 'Error occurred in SendWorkbook constructor');

         objSendWorkbook.SelectedProduct = 'Central Sales';
         objSendWorkbook.GetEnabledProductWorkbooks();
         System.assert(objSendWorkbook.EnabledProductWorkbooks != null && objSendWorkbook.EnabledProductWorkbooks.size() > 0, 'Workbook record not found for the product - Central Sales');
         System.assert(objSendWorkbook.EnabledProductWorkbooks.size() > 1, 'There must be at least one EnabledProductWorkbook for the test to run successfully');

         //Set require field's values before executing send workbook method
         objSendWorkbook.NiDocumentName = 'Test NI Doc - New Option';
         objSendWorkbook.ProjectId = lstProjects[0].Id;

         //Select first workbook from the drop down, note that element 0 is "--Please select a WORKBOOK--" and should not be used
         objSendWorkbook.SelectedWorkbook = objSendWorkbook.EnabledProductWorkbooks[1].getValue();
         objSendWorkbook.IsUDCWorkbookAccessed = true;
         objSendWorkbook.IsUDCWorkbookCompleted = true;
         objSendWorkbook.IsUDCWorkbookStepCompleted = true;

         objSendWorkbook.SetEmailTemplate();
         System.assertEquals(objEmailTemplate.Id, objSendWorkbook.SelectedEmailTemplateId, 'Email template id did not match with the one which is mentioned in the workbook');
         System.assertEquals(objEmailTemplate.Name, objSendWorkbook.SelectedEmailTemplateName, 'Email template name did not match with the one which is mentioned in the workbook');

         Integer intDefaultResponseQACount = lstCopiedDefaultResponses.size() * TOTAL_RESPONSE_QA_RECORDS_PER_RESPONSE;

         //Test Send Workbook method with New option
         //Sending workbook first time so it will not have any response records
         AH_UDC_Workbook__c objWorkbookSent1 = TestSendWorkbookMethod(objSendWorkbook, lstCopiedDefaultResponses, intDefaultResponseQACount, 1);

         //Create response and response QA records for new created workbook sent record
         List<AH_UDC_WorkbookStepResponse__c> lstStepResponses = CreateResponseAndResponseQARecords(objWorkbookSent1.Id);

         objSendWorkbook.NewNIDocId = null;
         objSendWorkbook.SelectedNIDocIdNew = objWorkbookSent1.RelatedTo__c;
         objSendWorkbook.NiDocumentName = 'Test NI Doc - New Option 2';
         
         List<AH_UDC_WorkbookStepResponse__c> lstOriginalWorkbookStepResponses = [SELECT Id, WorkbookStep__r.Form__c, WorkbookStep__r.Form__r.FormType__c, WorkbookStep__r.Form__r.CopyResponseWhenSendingNew__c
                                                                                 FROM AH_UDC_WorkbookStepResponse__c
                                                                                 WHERE Id IN :lstStepResponses
                                                                                 AND IsMostRecentResponse__c = true];
         System.assert(lstOriginalWorkbookStepResponses.size() > 0, 'Original workbook step responses not found');

         List<AH_UDC_WorkbookStepResponse__c> lstCopiedResponses = new List<AH_UDC_WorkbookStepResponse__c>();
         Set<Id> lstFormIdsWithoutResponse = new Set<Id>();
         for(AH_UDC_WorkbookStepResponse__c objResponse : lstOriginalWorkbookStepResponses) {
            if(String.isBlank(String.valueOf(objResponse.WorkbookStep__r.Form__c))) continue;

            if(objResponse.WorkbookStep__r.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_CENTRAL
               || objResponse.WorkbookStep__r.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_SHARED
               || (objResponse.WorkbookStep__r.Form__r.FormType__c == AH_UDC_Constants.FORM_TYPE_PRODUCT && objResponse.WorkbookStep__r.Form__r.CopyResponseWhenSendingNew__c == true))
               lstCopiedResponses.add(objResponse);
            else {
               lstFormIdsWithoutResponse.add(objResponse.WorkbookStep__r.Form__c);
            }
         }

         for(Id formId : lstFormIdsWithoutResponse) {
            for(AH_UDC_WorkbookStepResponse__c objResponse : lstCopiedDefaultResponses) {
               if(formId == objResponse.WorkbookStep__r.Form__c) {
                  //Add default responses for the setps which has form with copy responses false
                  lstCopiedResponses.add(objResponse);
                  break;
               }
            }
         }

         Integer intResponseCount = TOTAL_CENTRAL_FORMS + TOTAL_SHARED_FORMS + TOTAL_PRODUCT_FORMS_WITH_COPY_RESPONSE_TRUE;
         Integer intResponseQACount = lstCopiedResponses.size() * TOTAL_RESPONSE_QA_RECORDS_PER_RESPONSE;
         //Sending workbook with same property account so it should copy shared and central form responses
         //It should copy product form responses in case when CopyResponseWhenSendingNew__c is true
         AH_UDC_Workbook__c objWorkbookSent2 = TestSendWorkbookMethod(objSendWorkbook, lstCopiedResponses, intResponseQACount, 1);

         //Test Send Workbook method without account id
         objSendWorkbook.SelectedContact.Account.Id = null; // Test UDC PropertyAccount creation code when there is no Account
         objSendWorkbook.NewNIDocId = null;
         objSendWorkbook.SelectedNIDocIdNew = objWorkbookSent2.RelatedTo__c;
         objSendWorkbook.NiDocumentName = 'Test NI Doc - Without Account Id';

         //Sending workbook with different property account so it should copy default responses
         TestSendWorkbookMethod(objSendWorkbook, lstCopiedDefaultResponses, intDefaultResponseQACount, 1);
         Test.stopTest();
      }
   }

   @IsTest
   private static void TestSendWorkbookCopyOption() {
      Account objAccount1 = [SELECT Id FROM Account where Name = :TEST_ACCOUNT_NAME_1 LIMIT 1];
      Account objAccount2 = [SELECT Id FROM Account where Name = :TEST_ACCOUNT_NAME_2 LIMIT 1];

      AH_UDC_PropertyAccount__c objPropertyAccount = AH_UDC_TestData.GetPropertyObject('Test Property Account', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
      objPropertyAccount.Account__c = objAccount1.Id;
      insert objPropertyAccount;

      NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document', Date.today().addMonths(1));
      objNIDoc.AH_UDC_PropertyAccount__c = objPropertyAccount.Id;
      insert objNIDoc;

      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      objWorkbook.Enabled__c = true;
      insert objWorkbook;

      //Create workbook steps in original workbook before sending workbook
      CreateWorkbookStepRecords(objWorkbook.Id, false);

      //Create workbook sent record for copy option
      AH_UDC_Workbook__c objWorkbookSent = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Sent Workbook 1', 'Test Sent Workbook 1 Description', 'Central Sales');
      objWorkbookSent.OriginalWorkbook__c = objWorkbook.Id;
      insert objWorkbookSent;

      Id WorkbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(WorkbookStepRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP);

      //Copy workbook steps from original workbook record
      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = [SELECT Id, RecordTypeId, Workbook__c, Name, Form__c, URL__c
                                                      FROM AH_UDC_WorkbookStep__c
                                                      WHERE Workbook__c = :objWorkbook.Id
                                                      AND RecordTypeId = :WorkbookStepRecordTypeId
                                                      AND Enabled__c = true];
      System.assert(lstWorkbookSteps.size() > 0, 'Workbook step records not found in original workbook');

      Id WorkbookStepSentRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(WorkbookStepSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT);

      List<AH_UDC_WorkbookStep__c> lstWorkbookStepSent = lstWorkbookSteps.deepClone();
      for(AH_UDC_WorkbookStep__c objStep : lstWorkbookStepSent) {
         objStep.Id = null;
         objStep.RecordTypeId = WorkbookStepSentRecordTypeId;
         objStep.Workbook__c = objWorkbookSent.Id;
      }
      //Insert workbook steps for the workbook sent record
      insert lstWorkbookStepSent;
      AH_UDC_LogHelper.Debug('TestSendWorkbookCopyOption => lstWorkbookStepSent: ' + lstWorkbookStepSent);

      delete lstWorkbookSteps[0]; //Delete first step of original workbook  
      lstWorkbookSteps.remove(0);       
      for(integer i = 0; i < lstWorkbookSteps.size(); i++) {
         //Reverse sort order of all steps
         lstWorkbookSteps[i].SortOrder__c = lstWorkbookSteps.size() - i;
      }
      update lstWorkbookSteps;

      AH_UDC_WorkbookStep__c objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 0');
      objWorkbookStep.RecordTypeId = WorkbookStepRecordTypeId;
      objWorkbookStep.URL__c = 'https://www.amadeus.com/0';
      insert objWorkbookStep; //Insert one more step in workbook record

      //Create response and response QA records for workbook sent record
      List<AH_UDC_WorkbookStepResponse__c> lstStepResponses = CreateResponseAndResponseQARecords(objWorkbookSent.Id);
      lstStepResponses.remove(0); //Remove first step's response from the list because that step has been deleted from the original workbook
      
      List<pse__Proj__c> lstProjects = [SELECT Id FROM pse__Proj__c
                                       WHERE Name = 'Test Project'];
      System.assert(lstProjects.size() > 0, 'Project record not found with the name \'Test Project\'');

      Test.startTest();
      List<User> listUser = [Select Id From User Where Email like '%swWorkbookAdmin%'];
      System.assertEquals(1, listUser.size(), 'Failed retrieving test Workbook Admin');

      //Test Send Workbook with Copy option by using Workbook Admin user
      System.runAs(listUser[0]) {
         List<Contact> lstContacts = [SELECT Id, Name, AccountId, Email
                                      FROM Contact
                                      WHERE Status__c = 'Active'];
         System.assert(lstContacts.size() > 0, 'Contact records not found with the email contact2@test.com');

         Contact objContactOne = null;
         Contact objContactTwo = null;
         for (Contact objContact : lstContacts) {
            if (objContact.Email == 'contact1@test.com') {
               objContactOne = objContact;
            }
            else if (objContact.Email == 'contact2@test.com') {
               objContactTwo = objContact;
            }
         }

         Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
         System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);

         List<AH_UDC_Workbook__c> lstWorkbookSents = [SELECT Id, RelatedTo__c, OriginalWorkbook__r.Product__c, OriginalWorkbook__c
                                                      FROM AH_UDC_Workbook__c
                                                      WHERE RecordTypeId = :workbookSentRecordTypeId
                                                      AND Name = 'Test Sent Workbook 1'
                                                      AND Enabled__c = true];
         System.assert(lstWorkbookSents.size() > 0, 'Workbook Sent record not found');

         ApexPages.StandardController sc = new ApexPages.standardController(objContactOne);
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         pageRef.getParameters().put('id', objContactOne.Id);

         Test.setCurrentPageReference(pageRef);

         AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);
         System.assertEquals(objSendWorkbook.ContactId, String.valueOf(objContactOne.Id), 'ContactId did not match with ContactId');
         System.assertEquals(objSendWorkbook.SelectedContact.Id, String.valueOf(objContactOne.Id), 'ContactId did not match with Selected Contact Id');
         System.assertEquals(objSendWorkbook.SelectedContact.Account.Id, String.valueOf(objContactOne.AccountId), 'Account.Id did not match with Selected Contact Id');
         System.assertEquals(objSendWorkbook.SelectedContact.AccountId, String.valueOf(objContactOne.AccountId), 'AccountId did not match with Selected Contact Id');
         System.assert(objSendWorkbook.WorkbookProducts != null && objSendWorkbook.WorkbookProducts.size() > 0, 'Product values not found');
         System.assert(String.isNotBlank(objSendWorkbook.SelectedEmailTemplateId) && String.isNotBlank(objSendWorkbook.SelectedEmailTemplateName), 'Default email template not found');
         System.assert(objSendWorkbook.IsErrorOccurred != true, 'Error occurred in SendWorkbook constructor');

         //Test by adding multiple contacts
         objSendWorkbook.AddContactLookup();
         System.assert(objSendWorkbook.ContactLookupList != null && objSendWorkbook.ContactLookupList.size() == 1, 'Error occurred in AddContactLookup method');

         objSendWorkbook.ContactLookupList[0].Id = objContactTwo.Id;
         objSendWorkbook.ContactLookupList[0].Name = objContactTwo.Name;
         objSendWorkbook.ValidateContact();
         System.assert(String.isBlank(objSendWorkbook.ContactLookupList[0].ErrorMessage), 'Not a valid contact provided');

         objSendWorkbook.IsCopyWorkbook = true;
         objSendWorkbook.SelectedNIDocIdCopy = lstWorkbookSents[0].RelatedTo__c;
         objSendWorkbook.GetWorkbookSentDetails();
         System.assertEquals(lstWorkbookSents[0].OriginalWorkbook__r.Product__c, objSendWorkbook.SelectedProduct, 'Product did not match with the product of new created workbook');
         System.assertEquals(lstWorkbookSents[0].OriginalWorkbook__c, objSendWorkbook.SelectedWorkbook, 'Workbook Id did not match with new created workbook');
         System.assert(objSendWorkbook.EnabledProductWorkbooks != null && objSendWorkbook.EnabledProductWorkbooks.size() > 0, 'EnabledProductWorkbooks should not be empty');
         System.assertEquals(lstWorkbookSents[0].OriginalWorkbook__c, objSendWorkbook.EnabledProductWorkbooks[0].getValue(), 'Workbook drop down does not contain original workbook');
         
         //Set require field's values before executing send workbook method
         objSendWorkbook.NiDocumentName = 'Test NI Doc - Copy Option';
         objSendWorkbook.IsUDCWorkbookAccessed = false;
         objSendWorkbook.IsUDCWorkbookCompleted = false;
         objSendWorkbook.IsUDCWorkbookStepCompleted = false;

         //Test Sendworkbook method with Copy option
         List<AH_UDC_PropertyAccount__c> lstPropertyAccounts = null;

         Integer intResponseQACount = lstStepResponses.size() * TOTAL_RESPONSE_QA_RECORDS_PER_RESPONSE;
         //Additional contacts + one default selected contact
         Integer intUDCContactCount = objSendWorkbook.ContactLookupList.size() + 1;
         TestSendWorkbookMethod(objSendWorkbook, lstStepResponses, intResponseQACount, intUDCContactCount);

         lstPropertyAccounts = [SELECT Id FROM AH_UDC_PropertyAccount__c
                                WHERE Account__c = :objAccount1.Id];
         System.assert(lstPropertyAccounts.size() > 0, 'PropertyAccount record not created for Workbook that has an Account');


         // ------------------ Test #2 with Account that has no PropertAccount record yet ----------------

         //Remove additional contacts from the list to perform copy workbook second time
         objSendWorkbook.ContactLookupList.clear();
         //Set NI Doc selection null to cover else section in the method GetWorkbookSentDetails
         objSendWorkbook.SelectedNIDocIdCopy = null;
         objSendWorkbook.GetWorkbookSentDetails();
         System.assertEquals(null, objSendWorkbook.SelectedProduct, 'SelectedProduct should be null');
         System.assertEquals(null, objSendWorkbook.SelectedWorkbook, 'SelectedWorkbook should be null');
         System.assertEquals(0, objSendWorkbook.EnabledProductWorkbooks.size(), 'EnabledProductWorkbooks should be empty');

         objSendWorkbook.SelectedNIDocIdCopy = lstWorkbookSents[0].RelatedTo__c;
         objSendWorkbook.GetWorkbookSentDetails();
         System.assertEquals(lstWorkbookSents[0].OriginalWorkbook__r.Product__c, objSendWorkbook.SelectedProduct, 'Product did not match with the product of new created workbook');
         System.assertEquals(lstWorkbookSents[0].OriginalWorkbook__c, objSendWorkbook.SelectedWorkbook, 'Workbook Id did not match with new created workbook');
         System.assert(objSendWorkbook.EnabledProductWorkbooks != null && objSendWorkbook.EnabledProductWorkbooks.size() > 0, 'EnabledProductWorkbooks should not be empty');
         System.assertEquals(lstWorkbookSents[0].OriginalWorkbook__c, objSendWorkbook.EnabledProductWorkbooks[0].getValue(), 'Workbook drop down does not contain original workbook');

         //Perform send work and generate error to test scenario of changing workbook sent status to failed
         objSendWorkbook.LogFunctionalArea = 'TestException';
         objSendWorkbook.ContactId = objContactTwo.Id;
         objSendWorkbook.SelectedContact.Id = objContactTwo.Id;
         //This Account does not have a PropertyAccount created. Sending the Workbook should create it, giving more code coverage
         objSendWorkbook.SelectedContact.Account = objAccount2;
         objSendWorkbook.SelectedContact.AccountId = objContactTwo.AccountId; //This account don't have property account created so it will cover creation of property account record
         objSendWorkbook.ProjectId = lstProjects[0].Id;
         objSendWorkbook.NiDocumentName = 'Test NI Doc 2 - Copy Option';

         //Test by creating new property account
         TestSendWorkbookMethod(objSendWorkbook, lstStepResponses, intResponseQACount, 1);

         lstPropertyAccounts = [SELECT Id FROM AH_UDC_PropertyAccount__c
                                WHERE Account__c = :objContactTwo.AccountId];
         System.assert(lstPropertyAccounts.size() > 0, 'PropertyAccount record should have been created as no record existed for this Account');

      }
      Test.stopTest();
   }

   @IsTest
   private static void TestSendWorkbookWithProject() {
      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      objWorkbook.Enabled__c = true;
      insert objWorkbook;

      //Create steps record for the workbook
      CreateWorkbookStepRecords(objWorkbook.Id, true);

      List<User> lstUsers = [Select Id From User Where Email like '%swWorkbookUser%'];
      System.assert(lstUsers.size() > 0, 'Failed retrieving test Workbook User');

      List<pse__Proj__c> lstProjects = [SELECT Id, Name, Customer_Project_Contact__c, pse__Account__c, pse__Account__r.Name
                                       FROM pse__Proj__c
                                       WHERE Name = 'Test Project'];
      System.assert(lstProjects.size() > 0, 'Project record not found with the name \'Test Project\'');

      //Test Send Workbook with New option by using Workbook User
      System.runAs(lstUsers[0]) {
         ApexPages.StandardController sc = new ApexPages.standardController(new Contact());
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         pageRef.getParameters().put('projectid', lstProjects[0].Id);

         Test.setCurrentPageReference(pageRef);
         Test.startTest();
         AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);
         System.assertEquals(objSendWorkbook.ProjectId, String.valueOf(lstProjects[0].Id), 'ProjectId did not match with the one which is passed in parameters');
         System.assertEquals(objSendWorkbook.ProjectName, String.valueOf(lstProjects[0].Name), 'Project Name did not match with the one which is passed in parameters');
         System.assertEquals(objSendWorkbook.ContactId, String.valueOf(lstProjects[0].Customer_Project_Contact__c), 'ContactId did not match with the one which is associated with the Project');
         System.assertEquals(objSendWorkbook.SelectedContact.Id, String.valueOf(lstProjects[0].Customer_Project_Contact__c), 'SelectedContact.Id did not match with the one which is associated with the Project');
         System.assertEquals(objSendWorkbook.SelectedContact.Account.Id, String.valueOf(lstProjects[0].pse__Account__c), 'SelectedContact.Account.Id did not match with the one which is  associated with the Project');
         System.assertEquals(objSendWorkbook.SelectedContact.Account.Name, String.valueOf(lstProjects[0].pse__Account__r.Name), 'SelectedContact.Account.Name did not match with the one which is  associated with the Project');
         
         objSendWorkbook.SelectedProduct = 'Central Sales';
         objSendWorkbook.GetEnabledProductWorkbooks();
         System.assert(objSendWorkbook.EnabledProductWorkbooks != null && objSendWorkbook.EnabledProductWorkbooks.size() > 0, 'Workbook record not found for the product - Central Sales');
         System.assert(objSendWorkbook.EnabledProductWorkbooks.size() > 1, 'There must be at least one EnabledProductWorkbook for the test to run successfully');

         //Set require field's values before executing send workbook method
         objSendWorkbook.NiDocumentName = 'Test NI Doc - New Option';

         //Select first workbook from the drop down, note that element 0 is "--Please select a WORKBOOK--" and should not be used
         objSendWorkbook.SelectedWorkbook = objSendWorkbook.EnabledProductWorkbooks[1].getValue();
         objSendWorkbook.IsUDCWorkbookAccessed = true;
         objSendWorkbook.IsUDCWorkbookCompleted = true;
         objSendWorkbook.IsUDCWorkbookStepCompleted = true;

         //Test Send Workbook method with project
         AH_UDC_Workbook__c objWorkbookSent = TestSendWorkbookMethod(objSendWorkbook, null, 0, 1);
         
         Test.stopTest();
      }
   }

   //Send workbook and return workbook sent details
   private static AH_UDC_Workbook__c TestSendWorkbookMethod(AH_UDC_SendWorkbook objSendWorkbook, List<AH_UDC_WorkbookStepResponse__c> lstOriginalStepResponse, Integer intOriginalResponseQACount, Integer intUDCContactRecordsCount) {
      //Test Send Workbook with New option
      objSendWorkbook.SendWorkbook();

      Integer expectedLogCount = 1;
      List<AH_UDC_Log__c> logs = AH_UDC_LogHelper.GetQueuedLogs();
      for (Integer index = 0; index<logs.size(); index++) {
         switch on index {
            when 0 { System.assert(logs[index].LogText__c.startsWith('An exception occurred creating a Follow for user Id'), 'Did not find the expected Log Message on log index: ' + index); }
            when else { System.assert(false, 'Unexpected log message found (missing an ASSERT that should check the validity of the Log message?) Index: ' + index + '... Exception: ' + logs[index].LogText__c); }
         }
      }

      // This clears the queued logs for any other tests later
      AH_UDC_LogHelper.writeQueuedLogs();

      System.assert(String.isNotBlank(String.valueOf(objSendWorkbook.NewNIDocId)), 'Error occurred in SendWorkbook method - NI Doc record not created');

      Id NIDocRecordTypeId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(NIDocRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK);

      List<NI_Documentation__c> lstNIDocs = [SELECT Id, Document_Name__c, Project__c, AH_UDC_ChatterWorkbookAccessed__c, AH_UDC_ChatterWorkbookCompleted__c, AH_UDC_ChatterWorkbookStepCompleted__c
                                             FROM NI_Documentation__c
                                             WHERE Id = :objSendWorkbook.NewNIDocId
                                             AND RecordTypeId = :NIDocRecordTypeId];
      System.assert(lstNIDocs.size()> 0, 'Error occurred in SendWorkbook method - NI Doc was not able to be retrieved');
      System.assertEquals(lstNIDocs[0].Document_Name__c, objSendWorkbook.NiDocumentName, 'Error occurred in SendWorkbook method - value of Document_Name__c in NI Doc record did not match');
      System.assertEquals(lstNIDocs[0].Project__c, objSendWorkbook.ProjectId, 'Error occurred in SendWorkbook method - value of Project__c in NI Doc record did not match');
      System.assertEquals(lstNIDocs[0].AH_UDC_ChatterWorkbookAccessed__c, objSendWorkbook.IsUDCWorkbookAccessed, 'Error occurred in SendWorkbook method - AH_UDC_ChatterWorkbookAccessed__c value did not match');
      System.assertEquals(lstNIDocs[0].AH_UDC_ChatterWorkbookCompleted__c, objSendWorkbook.IsUDCWorkbookCompleted, 'Error occurred in SendWorkbook method - AH_UDC_ChatterWorkbookCompleted__c value did not match');
      System.assertEquals(lstNIDocs[0].AH_UDC_ChatterWorkbookStepCompleted__c, objSendWorkbook.IsUDCWorkbookStepCompleted, 'Error occurred in SendWorkbook method - AH_UDC_ChatterWorkbookStepCompleted__c value did not match');

      Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);

      List<AH_UDC_Workbook__c> lstWorkbookSents = [SELECT Id, Product__c, RelatedTo__c, OriginalWorkbook__c, ParentWorkbookSent__c, SentStatus__c
                                                   FROM AH_UDC_Workbook__c
                                                   WHERE RelatedTo__c = :objSendWorkbook.NewNIDocId
                                                   AND RecordTypeId = :workbookSentRecordTypeId
                                                   AND Enabled__c = true];
      System.assert(lstWorkbookSents.size() > 0, 'Error occurred in SendWorkbook method - Workbook Sent records not created');
      System.assertEquals(AH_UDC_Constants.SENT_STATUS_NEW, lstWorkbookSents[0].SentStatus__c, 'Error occurred in SendWorkbook method - Workbook sent status should be ' + AH_UDC_Constants.SENT_STATUS_NEW + '. Actual status is ' + lstWorkbookSents[0].SentStatus__c);
      System.assert(lstWorkbookSents[0].OriginalWorkbook__c == objSendWorkbook.SelectedWorkbook, 'Error occurred in SendWorkbook method - OriginalWorkbook__c don\'t have correct value in workbook sent record');
      if (objSendWorkbook.IsCopyWorkbook == false) {
         //If parent Workbook NI Doc is selected then check value ParentWorkbookSent__c field's value
         if (String.isNotBlank(String.valueOf(objSendWorkbook.SelectedNIDocIdNew))) {
            List<AH_UDC_Workbook__c> lstParentWorkbooks = [SELECT Id FROM AH_UDC_Workbook__c
                                                           WHERE RelatedTo__c = :objSendWorkbook.SelectedNIDocIdNew];
            if (lstParentWorkbooks.size() > 0) {
               System.assert(lstWorkbookSents[0].ParentWorkbookSent__c == lstParentWorkbooks[0].Id, 'Error occurred in SendWorkbook method - OriginalWorkbook__c don\'t have correct value in workbook sent record');
            }
         }
      }

      Id workbookStepSentRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookStepSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT);

      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = [SELECT Id FROM AH_UDC_WorkbookStep__c
                                                       WHERE Workbook__c = :lstWorkbookSents[0].Id
                                                       AND RecordTypeId = :workbookStepSentRecordTypeId
                                                       AND Enabled__c = true];
      System.assertEquals(TOTAL_STEP_RECORDS, lstWorkbookSteps.size(), 'Error occurred in SendWorkbook method - Step records count not matched');

      if (objSendWorkbook.LogFunctionalArea != 'TestException') { //If generating error then don't check response records
         System.assert(objSendWorkbook.IsErrorOccurred == false, 'Error occurred in SendWorkbook method');
         System.assert(objSendWorkbook.AllowSend, 'Error occurred in sending email');

         if (lstOriginalStepResponse != null && lstOriginalStepResponse.size() > 0) {
            List<AH_UDC_WorkbookStepResponse__c> lstOriginalWorkbookStepResponses = [SELECT WorkbookStep__r.Form__c, Response__c
                                                                                    FROM AH_UDC_WorkbookStepResponse__c
                                                                                    WHERE Id IN :lstOriginalStepResponse
                                                                                    AND IsMostRecentResponse__c = true];
            System.assert(lstOriginalWorkbookStepResponses.size() > 0, 'Original step responses not found');

            Map<Id, Id> mapOriginalFormIdAndResponseId = new Map<Id, Id>();
            for(AH_UDC_WorkbookStepResponse__c objOriginalStepResponse : lstOriginalWorkbookStepResponses)
               mapOriginalFormIdAndResponseId.put(objOriginalStepResponse.WorkbookStep__r.Form__c, objOriginalStepResponse.Response__c);

            List<AH_UDC_WorkbookStepResponse__c> lstWorkbookStepResponses = [SELECT Id, WorkbookStep__r.Form__c, Response__c
                                                                              FROM AH_UDC_WorkbookStepResponse__c
                                                                              WHERE WorkbookStep__r.Workbook__c = :lstWorkbookSents[0].Id];
            System.assertEquals(lstOriginalWorkbookStepResponses.size(), lstWorkbookStepResponses.size(), 'Error occurred in SendWorkbook method - Response count did not match');

            Integer intResponseCount = 0;
            Set<Id> lstResponseIds = new Set<Id>();
            for(AH_UDC_WorkbookStepResponse__c objStepResponse : lstWorkbookStepResponses) {
               if (mapOriginalFormIdAndResponseId.containsKey(objStepResponse.WorkbookStep__r.Form__c)
                  && mapOriginalFormIdAndResponseId.get(objStepResponse.WorkbookStep__r.Form__c) == objStepResponse.Response__c) {
                  lstResponseIds.add(objStepResponse.Response__c);
                  intResponseCount++;
               }
               else
                  break;
            }
            System.assertEquals(lstWorkbookStepResponses.size(), intResponseCount, 'Step responses count did not match');

            Integer intResponseQACount = [SELECT COUNT() FROM AH_UDC_ResponseQA__c
                                          WHERE Response__c IN :lstResponseIds];
            System.assertEquals(intOriginalResponseQACount, intResponseQACount, 'Error occurred in SendWorkbook method - Response QA records count did not matched');
         }

         Integer intUDCContact = [SELECT COUNT() FROM AH_UDC_Contact__c
                                  WHERE Document__c = :objSendWorkbook.NewNIDocId];
         System.assertEquals(intUDCContactRecordsCount, intUDCContact, 'Error occurred in SendWorkbook method - UDC Contact records count did not match');
      }

      return lstWorkbookSents[0];
   }

   @IsTest
   private static void TestCreateCommunityUser() {
      List<Contact> lstContacts = [SELECT Id, Name, Email FROM Contact WHERE Status__c = 'Active'];
      System.assert(lstContacts.size()> 0, 'Contact records not found');

      Contact objContactOne = null;
      Contact objContactTwo = null;
      Contact objContactWithoutEmail = null;
      for (Contact obj : lstContacts) {
         if (String.isBlank(obj.Email)) objContactWithoutEmail = obj;
         else if (obj.Email == 'contact1@test.com') objContactOne = obj;
         else if (obj.Email == 'contact2@test.com') objContactTwo = obj;
      }
      System.assert(objContactOne != null, 'Contact record is not created - objContactOne');
      System.assert(objContactTwo != null, 'Contact record is not created - objContactTwo');
      System.assert(objContactWithoutEmail != null, 'Contact without email is not created');

      ApexPages.StandardController sc = new ApexPages.standardController(lstContacts[0]);
      PageReference pageRef = Page.AH_UDC_SendWorkbook;
      pageRef.getParameters().put('id', objContactOne.Id);

      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);
      System.assert(String.valueOf(objContactOne.Id) == objSendWorkbook.ContactId, 'TestCreateCommunityUser - Contact Id Not Matched');
      System.assert(objSendWorkbook.WorkbookProducts != null && objSendWorkbook.WorkbookProducts.size() > 0, 'TestCreateCommunityUser - Product values not found');
      System.assert(String.isNotBlank(objSendWorkbook.SelectedEmailTemplateId) && String.isNotBlank(objSendWorkbook.SelectedEmailTemplateName), 'Default email template not found');

      objSendWorkbook.AddContactLookup();
      System.assert(objSendWorkbook.ContactLookupList != null && objSendWorkbook.ContactLookupList.size() == 1, 'Error occurred in AddContactLookup method');

      //Validate duplicate contact with same as selected contact
      objSendWorkbook.ContactLookupList[0].Id = objContactOne.Id;
      objSendWorkbook.ValidateContact();
      System.assert(objSendWorkbook.ContactLookupList[0].ErrorMessage == Label.AH_UDC_Duplicate_Contact_Added_For_Send_Workbook_Message, 'Error occurred in contact validation - Error message not set for duplicate contact with the selected contact');
      System.assert(objSendWorkbook.IsErrorOccurred != true, 'There is an error in contact validation.');

      //Validate contact without email
      objSendWorkbook.ContactLookupList[0].Id = objContactWithoutEmail.Id;
      objSendWorkbook.ValidateContact();
      System.assertEquals(Label.AH_UDC_Send_Workbook_Additional_Contact_Email_Required_Message, objSendWorkbook.ContactLookupList[0].ErrorMessage, 'Error occurred in contact validation - Error message not set for contact email');
      System.assert(String.isBlank(objSendWorkbook.SelectedUserEmail), 'There is an error in contact validation - Contact email is not empty');
      System.assert(objSendWorkbook.IsErrorOccurred != true, 'There is an error in Check External User.');

      //Validate with a valid contact
      objSendWorkbook.ContactLookupList[0].Id = objContactTwo.Id;
      objSendWorkbook.ValidateContact();
      System.assert(String.isBlank(objSendWorkbook.ContactLookupList[0].ErrorMessage), 'Error occurred in contact validation - Error message is not empty for a valid contact');
      System.assert(objSendWorkbook.IsErrorOccurred != true, 'There is an error in contact validation.');

      objSendWorkbook.AddContactLookup();
      System.assert(objSendWorkbook.ContactLookupList != null && objSendWorkbook.ContactLookupList.size() == 2, 'Error occurred in AddContactLookup method - Added 2nd contact in list');

      //Validate duplicate contact with same as previously added contact
      objSendWorkbook.ContactLookupList[1].Id = objContactTwo.Id;
      objSendWorkbook.ValidateContact();
      System.assertEquals(Label.AH_UDC_Duplicate_Contact_Added_For_Send_Workbook_Message, objSendWorkbook.ContactLookupList[0].ErrorMessage, 'Error occurred in contact validation - Error message not set for duplicate contact with previously added contact');
      System.assertEquals(Label.AH_UDC_Duplicate_Contact_Added_For_Send_Workbook_Message, objSendWorkbook.ContactLookupList[1].ErrorMessage, 'Error occurred in contact validation - Error message not set for duplicate contact with previously added contact');
      System.assert(objSendWorkbook.IsErrorOccurred != true, 'There is an error in contact validation.');

      //Remove duplicate contact from the list so it will not create community user multiple time
      objSendWorkbook.ContactLookupList.remove(1);
      objSendWorkbook.ValidateContact(); //Call validate function to remove error message from the valid contact
      System.assert(String.isBlank(objSendWorkbook.ContactLookupList[0].ErrorMessage), 'Error occurred in contact validation - Error message not removed from the valid contact');

      AH_UDC_MockResponseGenerator mock;
      mock = new AH_UDC_MockResponseGenerator(AH_UDC_MockResponseGenerator.ResponseType.CreateCommunityUser, 200);
      Test.setMock(HttpCalloutMock.class, mock);

      objSendWorkbook.CreateCommunityUsers();
      System.assert(objSendWorkbook.IsCommunityUserCreated == true, 'Community user not created');

      //This Method now uses a MOCK to call c# so creation of the users can't be confirmed
      //Set<Id> lstContactIds = new Set<Id> ();
      //lstContactIds.add(objSendWorkbook.ContactId);
      //if (objSendWorkbook.ContactLookupList != null && objSendWorkbook.ContactLookupList.size() > 0) {
         //for (Integer i = 0; i<objSendWorkbook.ContactLookupList.size(); i++) {
            //if (String.isNotBlank(String.valueOf(objSendWorkbook.ContactLookupList[i].Id)) && String.isBlank(objSendWorkbook.ContactLookupList[i].ErrorMessage)) {
               //lstContactIds.add(objSendWorkbook.ContactLookupList[i].Id);
            //}
         //}
      //}
      //Integer intExternalUserCount = [SELECT COUNT() FROM User WHERE ContactId IN :lstContactIds AND IsActive = true];
      //System.assertEquals(intExternalUserCount, lstContactIds.size(), 'External user not created for all selected contacts');
   }

   @isTest
   private static void TestExceptionHandling() {
      AH_UDC_ConfigHelper.SetValue('AH_UDC_SendWorkbookEnabled', false);
      
      List<User> lstUsers = [Select Id From User Where Email like '%swWorkbookUser%'];
      System.assert(lstUsers.size() > 0, 'Failed retrieving test Workbook User');

      System.runAs(lstUsers[0]) {
         ApexPages.StandardController sc = new ApexPages.standardController(new Contact());
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         Test.setCurrentPageReference(pageRef); //Call the page without passing id parameter to generate error
         Test.startTest();
         AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);
         String strSendNotAllowedMsg = AH_UDC_ConfigHelper.GetString('AH_UDC_SendWorkbookDisabledMessage', 'Send Workbook is currently disabled.');
         System.assertEquals(false, objSendWorkbook.AllowSend, 'AllowSend should be false because isSendWorkbookEnabled is set to false');
         System.assertEquals(strSendNotAllowedMsg, objSendWorkbook.SendNotAllowedMessage, 'SendNotAllowedMessage did not match');

         objSendWorkbook.SendWorkbook();
         System.assert(ApexPages.hasMessages(), 'SendWorkbook - Warning message is not added for SendNotAllowedMessage');
         System.assert(ApexPages.getMessages()[0].getDetail().contains(strSendNotAllowedMsg), 'SendWorkbook - SendNotAllowedMessage did not match');

         AH_UDC_ConfigHelper.SetValue('AH_UDC_SendWorkbookEnabled', true);
         objSendWorkbook = new AH_UDC_SendWorkbook(sc);

         //Set LogFunctionalArea value to generate error in LogException method
         objSendWorkbook.LogFunctionalArea = 'TestException';
         System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred while executing page without id parameter');
         System.assert(objSendWorkbook.HasPageLoadLogMessages, 'No log entries found in queue list');

         objSendWorkbook.ServerLogMessages();
         System.assertNotEquals(true, objSendWorkbook.HasPageLoadLogMessages, 'PageLoadLogMessages is not empty');
         Integer intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'AH_UDC_SendWorkbook' AND Source__c = 'Constructor'];
         System.assert(intCount > 0, 'Log message entry not found for the error in constructor');

         intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'ServerLogMessages'];
         System.assert(intCount > 0, 'Log message entry not found for the error in ServerLogMessages method');

         objSendWorkbook.IsErrorOccurred = false;
         objSendWorkbook.SendWorkbook();
         System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method SendWorkbook while executing without ContactId and workbook selection');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'SendWorkbook'];
         System.assert(intCount > 0, 'Log message entry not found for the error in SendWorkbook method');

         objSendWorkbook.IsErrorOccurred = false;
         objSendWorkbook.SendEmailToContacts();
         System.assert(objSendWorkbook.IsErrorOccurred, 'Error should have occurred in the method SendEmailToContacts while executing with LogFunctionalArea TestException');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'SendEmailToContacts'];
         System.assert(intCount > 0, 'Log message entry not found for the error in SendEmailToContacts method');

         objSendWorkbook.IsErrorOccurred = false;
         objSendWorkbook.GetWorkbookSentDetails();
         System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method GetWorkbookSentDetails while executing with LogFunctionalArea TestException');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'GetWorkbookSentDetails'];
         System.assert(intCount > 0, 'Log message entry not found for the error in GetWorkbookSentDetails method');

         objSendWorkbook.IsErrorOccurred = false;
         objSendWorkbook.GetProductList();
         System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method GetProductList while executing with LogFunctionalArea TestException');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'GetProductList'];
         System.assert(intCount > 0, 'Log message entry not found for the error in GetProductList method');

         objSendWorkbook.IsErrorOccurred = false;
         objSendWorkbook.GetDefaultEmailTemplateDetails();
         System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method GetDefaultEmailTemplateDetails while executing with LogFunctionalArea TestException');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'GetDefaultEmailTemplateDetails'];
         System.assert(intCount > 0, 'Log message entry not found for the error in GetDefaultEmailTemplateDetails method');

         objSendWorkbook.IsErrorOccurred = false;
         objSendWorkbook.ValidateContact();
         System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method ValidateContact while executing with LogFunctionalArea TestException');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'ValidateContact'];
         System.assert(intCount > 0, 'Log message entry not found for the error in ValidateContact method');

         objSendWorkbook.IsErrorOccurred = false;
         objSendWorkbook.AddContactLookup();
         System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method AddContactLookup while executing with LogFunctionalArea TestException');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'AddContactLookup'];
         System.assert(intCount > 0, 'Log message entry not found for the error in AddContactLookup method');

         Test.stopTest();
      }
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}