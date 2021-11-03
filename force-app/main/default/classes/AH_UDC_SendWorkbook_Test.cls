/***********************************************************************************************
  Name            : AH_UDC_SendWorkbook
  Author          : Umang Ankleshwaria
  Created Date    : 29-Jan-2020
  Last Mod Date   : 08-Feb-2020
  Last Mod By     : Umang Ankleshwaria
  NICC Reference  : 
  Description     : Test class for Send Workbook page of UDC 
  Change History  :
  1. 590043 - Refactoring Code - Changed by Umang Ankleshwaria on 8-Feb-2021
  2. 594855 - Refactoring Code - Changed by Tushar Gupta on 23-Feb-2021
 ************************************************************************************************/
@isTest
public class AH_UDC_SendWorkbook_Test {
   public static final Integer TotalStepRecords = 200;
   public static final Integer TotalFormRecords = 15;
   public static final Integer TotalFormResponseQARecords = 6000; //Create more than s4K records to test with new copy option

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<Account> lstAccounts = new List<Account>();
      lstAccounts.add(AH_UDC_TestData.GetAccountObject('Test Account 1'));
      lstAccounts.add(AH_UDC_TestData.GetAccountObject('Test Account 2'));
      insert lstAccounts;

      List<Contact> lstContacts = new List<Contact>();
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

      List<Profile> lstProfiles = new List<Profile>([SELECT Id FROM Profile WHERE Name = 'AH Customer Community Plus Login User']);
      System.assert(lstProfiles.size() > 0, 'Profile record not found - AH Customer Community Plus Login User');

      AH_UDC_PropertyAccount__c objPropertyAccount = AH_UDC_TestData.GetPropertyObject('Test Property Account', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105', 'St 104', '1 Portsmouth Ave.');
      objPropertyAccount.Account__c = lstAccounts[0].Id;
      insert objPropertyAccount;

      List<AH_UDC_Form__c> lstForms = new List<AH_UDC_Form__c>();
      for(Integer i = 1; i <= TotalFormRecords; i++) {
         //Generate 7 digits form assembly Id
         Integer intFormAssemblyId = (Integer) Math.round(Math.random() * (9000000) + 1000000);
         AH_UDC_Form__c objForm = new AH_UDC_Form__c();
         objForm.Name = 'Test Form' + i;
         objForm.FormAssemblyId__c = String.valueOf(intFormAssemblyId);
         if(i <= 5) objForm.FormType__c = AH_UDC_Constants.FORM_TYPE_PRODUCT; //Create 5 forms of Product type
         else if(i > 5 && i <= 10) objForm.FormType__c = AH_UDC_Constants.FORM_TYPE_SHARED; //Create 5 forms of Shared type
         else objForm.FormType__c = AH_UDC_Constants.FORM_TYPE_CENTRAL; //Create 5 forms of Central type
         lstForms.add(objForm);
      }
      insert lstForms;

      //Create workbook record for new option
      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      objWorkbook.Enabled__c = true;
      insert objWorkbook;

      //Create steps record for the workbook
      CreateStepsAndResponseData(objWorkbook.Id, lstForms, false);

      NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document', Date.today().addMonths(1));
      objNIDoc.AH_UDC_PropertyAccount__c = objPropertyAccount.Id;
      insert objNIDoc;

      Id workbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK);

      //Create workbook sent record for copy option
      AH_UDC_Workbook__c objWorkbookSent = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Sent Workbook 1', 'Test Sent Workbook 1 Description', 'Central Sales');
      insert objWorkbookSent;

      //Create steps record for the workbook
      CreateStepsAndResponseData(objWorkbookSent.Id, lstForms, true);

      //Create Workbook Admin and Workbook User records
      CreateWBAdminAndWBUserRecords();
   }

   //This method will create steps, responses and responses QA records for provided workbook
   private static void CreateStepsAndResponseData(Id WorkbookId, List<AH_UDC_Form__c> lstForms, Boolean FlagCreateSentRecord) {
      Id workbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookStepRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP);

      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = new List<AH_UDC_WorkbookStep__c>();
      for(Integer i = 1; i <= TotalStepRecords; i++) {
         AH_UDC_WorkbookStep__c objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(WorkbookId, 'Test Step ' + i);
         if(FlagCreateSentRecord == false) {
            //If not creating sent record type then change workbook step record type
            objWorkbookStep.RecordTypeId = workbookStepRecordTypeId;
         }

         if(i <= TotalFormRecords) {
            objWorkbookStep.Form__c = lstForms[i - 1].Id;
         }
         else {
            objWorkbookStep.URL__c = 'https://www.amadeus.com/' + i;
         }

         objWorkbookStep.SortOrder__c = i;
         lstWorkbookSteps.add(objWorkbookStep);
      }
      insert lstWorkbookSteps;

      //Set prerequisite steps for some of the steps
      lstWorkbookSteps[50].Prerequisite_Step__c = lstWorkbookSteps[5].Id;
      lstWorkbookSteps[60].Prerequisite_Step__c = lstWorkbookSteps[6].Id;
      lstWorkbookSteps[70].Prerequisite_Step__c = lstWorkbookSteps[7].Id;
      lstWorkbookSteps[80].Prerequisite_Step__c = lstWorkbookSteps[8].Id;
      lstWorkbookSteps[90].Prerequisite_Step__c = lstWorkbookSteps[9].Id;
      update lstWorkbookSteps;

      if(FlagCreateSentRecord) { //If creating workbook step sent records then create responses and response QA record for them
         Id responseRecordTypeId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
         System.assert(String.isNotBlank(String.valueOf(responseRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY);

         List<AH_UDC_Response__c> lstWorkbookStepResponses = new List<AH_UDC_Response__c>();
         for(Integer i = 0; i < TotalFormRecords; i++) { //Create responses only for 30 steps so it will not hit 101 while copying responses
            AH_UDC_Response__c objWorkbookStepResponse = AH_UDC_TestData.GetStepResponseObject(lstWorkbookSteps[i].Id);
            objWorkbookStepResponse.RecordTypeId = responseRecordTypeId;
            lstWorkbookStepResponses.add(objWorkbookStepResponse);
         }
         AH_UDC_LogHelper.Debug('CreateFormResponseForAllSteps : lstWorkbookStepResponses.size(): ' + lstWorkbookStepResponses.size());
         insert lstWorkbookStepResponses;

         Id responseQARecordTypeId = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();
         System.assert(String.isNotBlank(String.valueOf(responseQARecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY);

         List<AH_UDC_ResponseQA__c> lstWorkbookStepResponseQA = new List<AH_UDC_ResponseQA__c>();
         Integer index = 1;
         for(AH_UDC_Response__c objResponse : lstWorkbookStepResponses) { 
            if(index > TotalFormResponseQARecords) break;  
            for(Integer i = 1; i <= 400; i++) { //Create 400 RepsonseQA records per step to create 6K records
               AH_UDC_ResponseQA__c objWorkbookStepResponseQA = AH_UDC_TestData.GetStepResponseQAObject(objResponse.Id, 'Test Question ' + index, 'Test Question Field ' + index, 'Test Answer ' + index, 'Test Answer Field ' + index);
               objWorkbookStepResponseQA.RecordTypeId = responseQARecordTypeId;
               lstWorkbookStepResponseQA.add(objWorkbookStepResponseQA);
               index++;
               if(index > TotalFormResponseQARecords) break;
            }
         }
         AH_UDC_LogHelper.Debug('CreateFormResponseForAllSteps : lstWorkbookStepResponseQA.size(): ' + lstWorkbookStepResponseQA.size());
         insert lstWorkbookStepResponseQA;
      }
   }

   //This method will create user records and will assign permission set to them
   //Created future method to prevent the error - Mixed DML Operations
   @Future
   private static void CreateWBAdminAndWBUserRecords() {
      //Get ProfileId for Workbook Admin and Workbook User
      List<Profile> lstProfiles = new List<Profile>([SELECT Id FROM Profile WHERE Name = :AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING]);
      System.assert(lstProfiles.size() > 0, 'Could not get profile record of \'' + AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING + '\'');

      //Insert Workbook Admin user
      User objWorkbookAdmin = AH_UDC_TestData.GetUserObject(null, lstProfiles[0].Id, 'Workbook', 'Admin', 'Mr.', 'admin@workbook.com', 'admin@workbook.com.ahcc');
      objWorkbookAdmin.No_AD_Account_Standard_User__c = true;
      insert objWorkbookAdmin;

      List<PermissionSet> lstPermissionSets = new List<PermissionSet> ([SELECT Id FROM PermissionSet
                                                                        WHERE Name = :AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN]);
      System.assert(lstPermissionSets.size() > 0, 'Could not get Permission Set Id of ' + AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN);

      //Assign Workbook Admin permission set to the user
      PermissionSetAssignment objPermissionSetAssignment = new PermissionSetAssignment (PermissionSetId = lstPermissionSets[0].Id, AssigneeId = objWorkbookAdmin.Id);
      insert objPermissionSetAssignment;

      //Insert Workbook User
      User objWorkbookUser = AH_UDC_TestData.GetUserObject(null, lstProfiles[0].Id, 'Workbook', 'User', 'Mr.', 'user@workbook.com', 'user@workbook.com.ahcc');
      objWorkbookUser.No_AD_Account_Standard_User__c = true;
      insert objWorkbookUser;

      lstPermissionSets = new List<PermissionSet> ([SELECT Id FROM PermissionSet
                                                   WHERE Name = :AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER]);
      System.assert(lstPermissionSets.size() > 0, 'Could not get Permission Set Id of ' + AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER);

      //Assign Workbook User permission set to the user
      objPermissionSetAssignment = new PermissionSetAssignment (PermissionSetId = lstPermissionSets[0].Id, AssigneeId = objWorkbookUser.Id);
      insert objPermissionSetAssignment;
   }

   @IsTest
   private static void TestSendWorkbookNewOption() {
      List<User> lstWorkbookUsers = new List<User> ([SELECT Id, Username FROM User
                                                   WHERE Username = 'user@workbook.com.ahcc' AND IsActive = true]);
      System.assert(lstWorkbookUsers.size() > 0, 'Workbook User record not found');

      //Test Send Workbook with New option by using Workbook User
      System.runAs(lstWorkbookUsers[0]) {
         List<Contact> lstContacts = new List<Contact>([SELECT Id, Name, AccountId, Email
                                                      FROM Contact WHERE Email = 'contact1@test.com' AND Status__c = 'Active']);
         System.assert(lstContacts.size() > 0, 'Contact records not found with the email contact1@test.com');

         Id NIDocRecordTypeId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
         System.assert(String.isNotBlank(String.valueOf(NIDocRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK);

         List<NI_Documentation__c> lstNIDocs = new List<NI_Documentation__c>([SELECT Id FROM NI_Documentation__c
                                                                           WHERE RecordTypeId = :NIDocRecordTypeId]);
         System.assert(lstNIDocs.size() > 0, 'NI Doc Record not found');

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
         System.assert(objSendWorkbook.IsErrorOccurred != true, 'Error occured in SendWorkbook constructor');

         objSendWorkbook.SelectedProduct = 'Central Sales';
         objSendWorkbook.GetEnabledProductWorkbooks();
         System.assert(objSendWorkbook.EnabledProductWorkbooks != null && objSendWorkbook.EnabledProductWorkbooks.size() > 0, 'Workbook record not found for the product - Central Sales');
         
         //Set require field's values before executing send workbook method
         objSendWorkbook.NiDocumentName = 'Test NI Doc - New Option';
         objSendWorkbook.SelectedWorkbook = objSendWorkbook.EnabledProductWorkbooks[0].getValue(); //Select first workbook from the drop down
         objSendWorkbook.IsUDCWorkbookAccessed = true;
         objSendWorkbook.IsUDCWorkbookCompleted = true;
         objSendWorkbook.IsUDCWorkbookStepCompleted = true;

         //Test Send Workbook method with New option
         TestSendWorkbookMethod(objSendWorkbook);

         //Test Send Workbook method without account id
         objSendWorkbook.SelectedContact.AccountId = null; //Set account to null to cover UDC Property Account creation code
         objSendWorkbook.SelectedNIDocIdNew = lstNIDocs[0].Id;
         objSendWorkbook.NiDocumentName = 'Test NI Doc - Without Account Id';
         TestSendWorkbookMethod(objSendWorkbook);

         Test.stopTest();
      }
   }

   @IsTest
   private static void TestSendWorkbookCopyOption() {
      List<User> lstWorkbookAdminUsers = new List<User> ([SELECT Id, Username
                                                         FROM User
                                                         WHERE Username = 'admin@workbook.com.ahcc' AND IsActive = true]);
      System.assert(lstWorkbookAdminUsers.size() > 0, 'Workbook User record not found');

      //Test Send Workbook with Copy option by using Workbook Admin user
      System.runAs(lstWorkbookAdminUsers[0]) {
         List<Contact> lstContacts = new List<Contact>([SELECT Id, Name, AccountId, Email
                                                      FROM Contact
                                                      WHERE Status__c = 'Active']);
         System.assert(lstContacts.size() > 0, 'Contact records not found with the email contact2@test.com');

         Contact objContactOne = null;
         Contact objContactTwo = null;
         for(Contact objContact : lstContacts) {
            if(objContact.Email == 'contact1@test.com')  objContactOne = objContact;
            else if(objContact.Email == 'contact2@test.com')  objContactTwo = objContact;
         }

         Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
         System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);

         List<AH_UDC_Workbook__c> lstWorkbookSents = new List<AH_UDC_Workbook__c> ([SELECT Id, RelatedTo__c, Product__c
                                                                                    FROM AH_UDC_Workbook__c
                                                                                    WHERE RecordTypeId = :workbookSentRecordTypeId
                                                                                    AND Enabled__c = true]);
         System.assert(lstWorkbookSents.size() > 0, 'Workbook Sent record not found');

         ApexPages.StandardController sc = new ApexPages.standardController(objContactOne);
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         pageRef.getParameters().put('id', objContactOne.Id);

         Test.setCurrentPageReference(pageRef);
         Test.startTest();
         AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);
         System.assertEquals(objSendWorkbook.ContactId, String.valueOf(objContactOne.Id), 'ContactId did not match with ContactId');
         System.assertEquals(objSendWorkbook.SelectedContact.Id, String.valueOf(objContactOne.Id), 'ContactId did not match with Selected Contact Id');
         System.assertEquals(objSendWorkbook.SelectedContact.AccountId, String.valueOf(objContactOne.AccountId), 'AccountId did not match with Selected Contact Id');
         System.assert(objSendWorkbook.WorkbookProducts != null && objSendWorkbook.WorkbookProducts.size() > 0, 'Product values not found');
         System.assert(String.isNotBlank(objSendWorkbook.SelectedEmailTemplateId) && String.isNotBlank(objSendWorkbook.SelectedEmailTemplateName), 'Default email template not found');
         System.assert(objSendWorkbook.IsErrorOccurred != true, 'Error occured in SendWorkbook constructor');
         
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

         //After calling GetWorkbookSentDetails, it will change account id
         //Set same account of contact to copy responses of shared and central form
         objSendWorkbook.SelectedContact.AccountId = objContactOne.AccountId;

         //Set require field's values before executing send workbook method
         objSendWorkbook.NiDocumentName = 'Test NI Doc - Copy Option';
         objSendWorkbook.SelectedWorkbook = lstWorkbookSents[0].Id; //Use inserted workbook to send as a copy
         objSendWorkbook.IsUDCWorkbookAccessed = false;
         objSendWorkbook.IsUDCWorkbookCompleted = false;
         objSendWorkbook.IsUDCWorkbookStepCompleted = false;

         //Test Sendworkbook method with Copy option
         TestSendWorkbookMethod(objSendWorkbook);

         //Remova additional contacts from the list to perform copy workbook second time
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
         objSendWorkbook.SelectedContact.AccountId = objContactTwo.AccountId; //This account don't have property account created so it will cover creation of property account record
         objSendWorkbook.SelectedWorkbook = lstWorkbookSents[0].Id;

         //Test Sendworkbook method with Copy option
         TestSendWorkbookMethod(objSendWorkbook);

         List<AH_UDC_PropertyAccount__c> lstPropertyAccounts = new List<AH_UDC_PropertyAccount__c>([SELECT Id FROM AH_UDC_PropertyAccount__c
                                                                  WHERE Account__c = :objContactTwo.AccountId]);
         System.assert(lstPropertyAccounts.size() > 0, 'Property account record not created');

         Test.stopTest();
      }
   }

   private static void TestSendWorkbookMethod(AH_UDC_SendWorkbook objSendWorkbook) {
      AH_UDC_LogHelper.Debug('objSendWorkbook.IsCopyWorkbook => ' + objSendWorkbook.IsCopyWorkbook);

      //Test Send Workbook with New option
      objSendWorkbook.SendWorkbook();
      System.assert(String.isNotBlank(String.valueOf(objSendWorkbook.NewNIDocId)), 'Error occured in SendWorkbook method - NI Doc record not created');
      
      Id NIDocRecordTypeId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(NIDocRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK);

      List<NI_Documentation__c> lstNIDocs = new List<NI_Documentation__c> ([SELECT Id, Document_Name__c, AH_UDC_ChatterWorkbookAccessed__c, AH_UDC_ChatterWorkbookCompleted__c, AH_UDC_ChatterWorkbookStepCompleted__c
                                                                           FROM NI_Documentation__c
                                                                           WHERE Id = :objSendWorkbook.NewNIDocId
                                                                           AND RecordTypeId = :NIDocRecordTypeId]);
      System.assert(lstNIDocs.size() > 0, 'Error occured in SendWorkbook method - NI Doc record not created');
      System.assertEquals(lstNIDocs[0].Document_Name__c, objSendWorkbook.NiDocumentName, 'Error occured in SendWorkbook method - AH_UDC_ChatterWorkbookAccessed__c in not to true in NI Doc record');
      System.assertEquals(lstNIDocs[0].AH_UDC_ChatterWorkbookAccessed__c, objSendWorkbook.IsUDCWorkbookAccessed, 'Error occured in SendWorkbook method - AH_UDC_ChatterWorkbookAccessed__c value did not match');
      System.assertEquals(lstNIDocs[0].AH_UDC_ChatterWorkbookCompleted__c, objSendWorkbook.IsUDCWorkbookCompleted, 'Error occured in SendWorkbook method - AH_UDC_ChatterWorkbookCompleted__c value did not match');
      System.assertEquals(lstNIDocs[0].AH_UDC_ChatterWorkbookStepCompleted__c, objSendWorkbook.IsUDCWorkbookStepCompleted, 'Error occured in SendWorkbook method - AH_UDC_ChatterWorkbookStepCompleted__c value did not match');

      Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);

      List<AH_UDC_Workbook__c> lstWorkbookSents = new List<AH_UDC_Workbook__c> ([SELECT Id, Product__c, RelatedTo__c, OriginalWorkbook__c, ParentWorkbookSent__c, SentStatus__c
                                                                                 FROM AH_UDC_Workbook__c
                                                                                 WHERE RelatedTo__c = :objSendWorkbook.NewNIDocId
                                                                                 AND RecordTypeId = :workbookSentRecordTypeId
                                                                                 AND Enabled__c = true]);
      System.assert(lstWorkbookSents.size() > 0, 'Error occured in SendWorkbook method - Workbook Sent records not created');
      if(objSendWorkbook.IsCopyWorkbook == false) {
         System.assert(lstWorkbookSents[0].OriginalWorkbook__c == objSendWorkbook.SelectedWorkbook, 'Error occured in SendWorkbook method - OriginalWorkbook__c don\'t have correct value in workbook sent record');
         if (String.isNotBlank(String.valueOf(objSendWorkbook.SelectedNIDocIdNew))) { //If parent Workbook NI Doc is selected then check value ParentWorkbookSent__c field's value
            List<AH_UDC_Workbook__c> lstParentWorkbooks = new List<AH_UDC_Workbook__c>([SELECT Id FROM AH_UDC_Workbook__c
                                                                                       WHERE RelatedTo__c = :objSendWorkbook.SelectedNIDocIdNew]);
            if (lstParentWorkbooks.size() > 0) {
               System.assert(lstWorkbookSents[0].ParentWorkbookSent__c == lstParentWorkbooks[0].Id, 'Error occured in SendWorkbook method - OriginalWorkbook__c don\'t have correct value in workbook sent record');
            }
         }
      }

      Id workbookStepSentRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookStepSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT);

      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = new List<AH_UDC_WorkbookStep__c>([SELECT Id FROM AH_UDC_WorkbookStep__c
                                                                                       WHERE Workbook__c = :lstWorkbookSents[0].Id
                                                                                       AND RecordTypeId = :workbookStepSentRecordTypeId
                                                                                       AND Enabled__c = true]);
      AH_UDC_LogHelper.Debug('lstWorkbookSteps.size() => ' + lstWorkbookSteps.size());
      System.assertEquals(TotalStepRecords, lstWorkbookSteps.size(), 'Error occured in SendWorkbook method - Step records count not matched');

      AH_UDC_LogHelper.Debug('objSendWorkbook.HasPendingStepsToCopy => ' + objSendWorkbook.HasPendingStepsToCopy);
      if(objSendWorkbook.HasPendingStepsToCopy) { //If there large number of response QA recordss then copy data step by step
         Integer intIndex = 0;
         while(objSendWorkbook.HasPendingStepsToCopy == true) {
            if(objSendWorkbook.LogFunctionalArea == 'TestException') {
               //Generate error to test scenario of changing workbook sent status to failed
               objSendWorkbook.MapSharedOrCentralFormIdResponseId = null;
            }

            //Copy form responses and response QA records step by step
            objSendWorkbook.CopyResponsesStepByStep();

            if(objSendWorkbook.LogFunctionalArea == 'TestException') {
               System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occured in the method CopyResponsesStepByStep');
               List<AH_UDC_Workbook__c> lstFailedWorkbooks = new List<AH_UDC_Workbook__c> ([SELECT Id, SentStatus__c
                                                                                 FROM AH_UDC_Workbook__c
                                                                                 WHERE Id = :lstWorkbookSents[0].Id]);
               System.assert(lstFailedWorkbooks.size() > 0, 'Workbook Sent records not found');
               System.assertEquals(lstFailedWorkbooks[0].SentStatus__c, AH_UDC_Constants.SENT_STATUS_FAILED_TO_SEND, 'Workbook sent status not changed to ' + AH_UDC_Constants.SENT_STATUS_FAILED_TO_SEND);
               break;
            }
            else {
               System.assert(objSendWorkbook.IsErrorOccurred != true, 'Error occured in CopyResponsesStepByStep method');
            }
            intIndex++;
         }
      }

      if(objSendWorkbook.LogFunctionalArea != 'TestException') { //If generating error then don't check response records
         if(objSendWorkbook.IsCopyWorkbook || objSendWorkbook.MapSharedOrCentralFormIdResponseId.size() > 0) {
            List<AH_UDC_Response__c> lstFormResponses = new List<AH_UDC_Response__c> ([SELECT Id FROM AH_UDC_Response__c
                                                                                       WHERE WorkbookStep__r.Workbook__c = :lstWorkbookSents[0].Id
                                                                                       AND IsMostRecentResponse__c = true]);
            AH_UDC_LogHelper.Debug('lstFormResponses.size() => ' + lstFormResponses.size());
            if(objSendWorkbook.IsCopyWorkbook) {
               //For copy option, all responses should be copied
               System.assertEquals(TotalFormRecords, lstFormResponses.size(), 'Error occured in SendWorkbook method - Form Response records count not matched');
            }
            else {
               //For new option, only Shared and Central form responses should be copied
               System.assertEquals(objSendWorkbook.MapSharedOrCentralFormIdResponseId.size(), lstFormResponses.size(), 'Error occured in SendWorkbook method - Form Response records count not matched');
            }

            Integer intFormResponseQACount = [SELECT COUNT() FROM AH_UDC_ResponseQA__c
                                             WHERE Response__c IN :lstFormResponses];
            if(objSendWorkbook.IsCopyWorkbook) {
               //For copy option, all response QA records should be copied
               System.assertEquals(TotalFormResponseQARecords, intFormResponseQACount, 'Error occured in SendWorkbook method - Form Response QA records count not matched');
            }
            else {
               //For new option, only Shared and Central form response QA records should be copied
               System.assertEquals(4000, intFormResponseQACount, 'Error occured in SendWorkbook method - Form Response QA records count not matched');
            }
         }

         Set<Id> lstContactIds = new Set<Id>();
         lstContactIds.add(objSendWorkbook.ContactId);
         if (objSendWorkbook.ContactLookupList != null && objSendWorkbook.ContactLookupList.size() > 0) {
            for (Integer i = 0; i < objSendWorkbook.ContactLookupList.size(); i++) {
               if (String.isNotBlank(String.valueOf(objSendWorkbook.ContactLookupList[i].Id)) && String.isBlank(objSendWorkbook.ContactLookupList[i].ErrorMessage)) {
                  lstContactIds.add(objSendWorkbook.ContactLookupList[i].Id);
               }
            }
         }

         Integer intUDCContact = [SELECT COUNT() FROM AH_UDC_Contact__c
                                 WHERE Document__c = :objSendWorkbook.NewNIDocId
                                 AND Contact__c IN :lstContactIds];
         System.assertEquals(lstContactIds.size(), intUDCContact, 'Error occured in SendWorkbook method - UDC Contact records not created for all selected contacts');

         System.assert(objSendWorkbook.IsErrorOccurred != true, 'Error occured in SendWorkbook method');
         System.assert(objSendWorkbook.IsErrorOccurredInEmail != true, 'Error occured in sending email');
      }
   }

   @IsTest
   private static void TestCreateCommunityUser() {
      List<Contact> lstContacts = new List<Contact>([SELECT Id, Name, Email FROM Contact WHERE Status__c = 'Active']);
      System.assert(lstContacts.size() > 0, 'Contact records not found');

      Contact objContactOne = null;
      Contact objContactTwo = null;
      Contact objContactWithoutEmail = null;
      for (Contact obj : lstContacts) {
         if(String.isBlank(obj.Email)) objContactWithoutEmail = obj;
         else if(obj.Email == 'contact1@test.com') objContactOne = obj;
         else if(obj.Email == 'contact2@test.com') objContactTwo = obj;
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
      System.assert(objSendWorkbook.ContactLookupList[0].ErrorMessage == Label.AH_UDC_Duplicate_Contact_Added_For_Send_Workbook_Message, 'Error occured in contact validation - Error message not set for duplicate contact with the selected contact');
      System.assert(objSendWorkbook.IsErrorOccurred != true, 'There is an error in contact validation.');

      //Validate contact without email
      objSendWorkbook.ContactLookupList[0].Id = objContactWithoutEmail.Id;
      objSendWorkbook.ValidateContact();
      System.assertEquals(Label.AH_UDC_Send_Workbook_Additional_Contact_Email_Required_Message, objSendWorkbook.ContactLookupList[0].ErrorMessage, 'Error occured in contact validation - Error message not set for contact email');
      System.assert(String.isBlank(objSendWorkbook.SelectedUserEmail), 'There is an error in contact validation - Contact email is not empty');
      System.assert(objSendWorkbook.IsErrorOccurred != true, 'There is an error in Check External User.');

      //Validate with a valid contact
      objSendWorkbook.ContactLookupList[0].Id = objContactTwo.Id;
      objSendWorkbook.ValidateContact();
      System.assert(String.isBlank(objSendWorkbook.ContactLookupList[0].ErrorMessage), 'Error occured in contact validation - Error message is not empty for a valid contact');
      System.assert(objSendWorkbook.IsErrorOccurred != true, 'There is an error in contact validation.');

      objSendWorkbook.AddContactLookup();
      System.assert(objSendWorkbook.ContactLookupList != null && objSendWorkbook.ContactLookupList.size() == 2, 'Error occurred in AddContactLookup method - Added 2nd contact in list');

      //Validate duplicate contact with same as previously added contact
      objSendWorkbook.ContactLookupList[1].Id = objContactTwo.Id;
      objSendWorkbook.ValidateContact();
      System.assertEquals(Label.AH_UDC_Duplicate_Contact_Added_For_Send_Workbook_Message, objSendWorkbook.ContactLookupList[0].ErrorMessage, 'Error occured in contact validation - Error message not set for duplicate contact with previously added contact');
      System.assertEquals(Label.AH_UDC_Duplicate_Contact_Added_For_Send_Workbook_Message, objSendWorkbook.ContactLookupList[1].ErrorMessage, 'Error occured in contact validation - Error message not set for duplicate contact with previously added contact');
      System.assert(objSendWorkbook.IsErrorOccurred != true, 'There is an error in contact validation.');

      //Remove duplicate contact from the list so it will not create community user multiple time
      objSendWorkbook.ContactLookupList.remove(1);
      objSendWorkbook.ValidateContact(); //Call validate function to remove error message from the valid contact
      System.assert(String.isBlank(objSendWorkbook.ContactLookupList[0].ErrorMessage), 'Error occured in contact validation - Error message not removed from the valid contact');

      objSendWorkbook.CreateCommunityUsers();
      System.assert(objSendWorkbook.IsCommunityUserCreated == true, 'Community user not created');

      Set<Id> lstContactIds = new Set<Id>();
      lstContactIds.add(objSendWorkbook.ContactId);
      if (objSendWorkbook.ContactLookupList != null && objSendWorkbook.ContactLookupList.size() > 0) {
         for (Integer i = 0; i < objSendWorkbook.ContactLookupList.size(); i++) {
            if (String.isNotBlank(String.valueOf(objSendWorkbook.ContactLookupList[i].Id)) && String.isBlank(objSendWorkbook.ContactLookupList[i].ErrorMessage)) {
               lstContactIds.add(objSendWorkbook.ContactLookupList[i].Id);
            }
         }
      }

      Integer intExternalUserCount = [SELECT COUNT() FROM User WHERE ContactId IN :lstContactIds AND IsActive = true];
      System.assertEquals(intExternalUserCount, lstContactIds.size(), 'External user not created for all selected contacts');
   }

   @isTest
   private static void TestExceptionHandling() {
      ApexPages.StandardController sc = new ApexPages.standardController(new Contact());
      PageReference pageRef = Page.AH_UDC_SendWorkbook;
      Test.setCurrentPageReference(pageRef); //Call the page without passing id parameter to generate error
      Test.startTest();
      AH_UDC_SendWorkbook objSendWorkbook = new AH_UDC_SendWorkbook(sc);

      //Set name to generate error in LogException method
      objSendWorkbook.LogFunctionalArea = 'TestException';
      System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred while executing page without id parameter');
      System.assert(objSendWorkbook.HasPageLoadLogMessages, 'No log entries found in queue list');

      objSendWorkbook.ServerLogMessages();
      System.assertNotEquals(true, objSendWorkbook.HasPageLoadLogMessages, 'PageLoadLogMessages is not empty');

      objSendWorkbook.IsErrorOccurred = false;
      objSendWorkbook.SendWorkbook();
      System.assert(objSendWorkbook.IsErrorOccurred, 'Error not occurred in the method SendWorkbook while executing without ContactId and workbook selection');

      Test.stopTest();
   }
}