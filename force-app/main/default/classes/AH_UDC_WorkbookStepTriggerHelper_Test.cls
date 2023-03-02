<<<<<<< HEAD
/**
 * Name          : AH_UDC_WorkbookStepTriggerHelper_TEST
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-04-20
 * Description   : This class is a test class for AH_UDC_WorkbookStepTriggerHelper
 * Dependencies  : AH_UDC_WorkbookStepTriggerHelper
 **/

@isTest
private class AH_UDC_WorkbookStepTriggerHelper_TEST {
   public static final Integer TotalSteps = 200;
   @testSetup
   private static void setupTestData() {
      List<User> listUsers = new List<User> ();

      //Insert Workbook user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                              'UDCWorkbookUser', null, false));
      //Insert Workbook Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                              'UDCWorkbookAdmin', null, false));
      //Insert UDC System Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                              'UDCSystemAdmin', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[2].Id);
      }
      User objWorkbookUser = listUsers[0];
      User objWorkbookAdminUser = listUsers[1];
      User objUdcSystemAdmin = listUsers[2];


      //Prevent error : System.LimitException: Too many SOQL queries: 101
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      AH_UDC_WorkbookStep__c objWorkbookStep = null;
      Account objAccount = null;
      NI_Documentation__c objNIDoc = null;
      AH_UDC_Workbook__c objWorkbook = null;
      Schema.DescribeFieldResult fieldResult = null;
      List<Schema.PicklistEntry> pickListEntry = null;

      //Get Product Picklist
      fieldResult = AH_UDC_Workbook__c.Product__c.getDescribe();
      if (fieldResult != null) {
         pickListEntry = fieldResult.getPicklistValues();
      }

      //Insert new Account data         
      objAccount = AH_UDC_TestData.GetAccountObject('GUID');
      insert objAccount;

      objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 8, 30));
      objNIDoc.Account__c = objAccount.Id;
      insert objNIDoc;

      //Insert Workbook Record
      objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      //Set OwnerId to provide Workbook Step delete rights to Workbook Admin user
      objWorkbook.OwnerId = objWorkbookAdminUser.Id;
      insert objWorkbook;

      //Insert Workbook Step Record for Delete
      objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Workbook Step');
      objWorkbookStep.URL__c = 'https://www.google.com/';
      insert objWorkbookStep;

      //Create Form
      AH_UDC_Form__c form = new AH_UDC_Form__c(Name = 'TestForm1', FormAssemblyId__c = '515151');
      insert form;

      Id wbRTId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_Workbook').getRecordTypeId();
      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();

      //Test Insert Data Setup
      AH_UDC_Workbook__c objWB = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('TestWB', 'TestWB 1 Description', 'Central Sales');
      objWB.Enabled__c = true;
      insert objWB;
      System.runAs(objWorkbookUser) {
         AH_UDC_Workbook__c wbInsert = new AH_UDC_Workbook__c(Name = 'TestInsert', RecordtypeId = wbRTId, SecurityCode__c = '4a1d7cd6-e80a-4561-975e-7229655ed41f3758b38b-75f0-416d-872e-1205b8cbaaa0');
         wbInsert.Product__c = pickListEntry[0].getLabel();
         insert wbInsert;
      }
      //End Test Insert

      //Test Update Data Setup
      //Insert Workbook 
      AH_UDC_Workbook__c wb1 = new AH_UDC_Workbook__c(Name = 'Test11', RecordtypeId = wbRTId, SecurityCode__c = '4a1d7cd6-e80a-4561-975e-7229655ed41f3758b38b-75f0-416d-872e-1205b8cbaaa7');
      wb1.Product__c = pickListEntry[0].getLabel();
      insert wb1;

      AH_UDC_WorkbookStep__c wbs21 = new AH_UDC_WorkbookStep__c(Name = 'WBS21', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.googlese1.com');
      insert wbs21;

      AH_UDC_WorkbookStep__c wbs31 = new AH_UDC_WorkbookStep__c(Name = 'WBS31', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.googlese.com');
      insert wbs31;

      AH_UDC_WorkbookStep__c wbs41 = new AH_UDC_WorkbookStep__c(Name = 'WBS41', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, form__c = form.Id);
      wbs41.Prerequisite_Step__c = wbs21.Id;
      insert wbs41;

      try {
         List<sObject> records = new List<sObject> ();
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS101', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.test.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS102', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.Test123.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS103', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.goog123ese.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS104', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.Amadeus.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS105', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.Google.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS106', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.Gmail.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS107', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.Gdrive.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS108', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.Yahoo.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS109', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.amax.com'));
         insert records;
      }
      catch(exception ex)
      {
         AH_UDC_LogHelper.Debug('insert error ' + ex.getMessage());
         System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage) > - 1, 'Duplicate URL or Form - Error message did not match');
      }

      //END Test Update

      //Test Delete Setup Data
      //Insert Workbook
      AH_UDC_Workbook__c wbDelete = new AH_UDC_Workbook__c(Name = 'TestDelete', RecordtypeId = wbRTId, SecurityCode__c = '4a1d7cd6-e80a-4561-975e-7229655ed41f3758b38b-75f0-416d-872e-1205b8cbaaa1');
      wbDelete.Product__c = pickListEntry[0].getLabel();
      insert wbDelete;

      AH_UDC_WorkbookStep__c wbs2 = new AH_UDC_WorkbookStep__c(Name = 'WBS2', RecordtypeId = wbsRTId, Workbook__c = wbDelete.Id, URL__c = 'www.test1.com');
      insert wbs2;

      AH_UDC_WorkbookStep__c wbs3 = new AH_UDC_WorkbookStep__c(Name = 'WBS3', RecordtypeId = wbsRTId, Workbook__c = wbDelete.Id, form__c = form.Id);
      insert wbs3;

      AH_UDC_WorkbookStep__c wbs4 = new AH_UDC_WorkbookStep__c(Name = 'WBS4', RecordtypeId = wbsRTId, Workbook__c = wbDelete.Id, URL__c = 'www.test.com');
      wbs4.Prerequisite_Step__c = wbs2.Id;
      insert wbs4;

      try {
         List<sObject> records = new List<sObject> ();
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS5', RecordtypeId = wbsRTId, Workbook__c = wbDelete.Id, URL__c = 'www.Amadeus.com/test1'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS6', RecordtypeId = wbsRTId, Workbook__c = wbDelete.Id, URL__c = 'www.Amadeus.com/test2'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS7', RecordtypeId = wbsRTId, Workbook__c = wbDelete.Id, URL__c = 'www.Amadeus.com/test3'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS8', RecordtypeId = wbsRTId, Workbook__c = wbDelete.Id, URL__c = 'www.Amadeus.com/test4'));
         insert records;
      }
      catch(exception ex)
      {
         AH_UDC_LogHelper.Debug('insert error ' + ex.getMessage());
         System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage) > - 1, 'Duplicate URL or Form - Error message did not match');
      }
      //END Test Delete

      //Test UnDelete Setup Data
      AH_UDC_Workbook__c wbUndelete = new AH_UDC_Workbook__c(Name = 'TestUnDelete', RecordtypeId = wbRTId, SecurityCode__c = '4a1d7cd6-e80a-4561-975e-7229655ed41f3758b38b-75f0-416d-872e-1205b8cbaaa5');
      wbUndelete.Product__c = pickListEntry[0].getLabel();
      insert wbUndelete;

      AH_UDC_WorkbookStep__c wbs10 = new AH_UDC_WorkbookStep__c(Name = 'WBS10', RecordtypeId = wbsRTId, Workbook__c = wbUndelete.Id, URL__c = 'www.test.com');
      insert wbs10;

      AH_UDC_WorkbookStep__c wbs11 = new AH_UDC_WorkbookStep__c(Name = 'WBS11', RecordtypeId = wbsRTId, Workbook__c = wbUndelete.Id, form__c = form.Id);
      wbs11.Prerequisite_Step__c = wbs10.Id;
      insert wbs11;
      //END Test UnDelete Setup Data

      //Test Exception Setup Data
      AH_UDC_Workbook__c wbException = new AH_UDC_Workbook__c(Name = 'TestExc', RecordtypeId = wbRTId, SecurityCode__c = '4a1d7cd6-e80a-4561-975e-7229655ed41f3758b38b-75f0-416d-872e-1205b8cbaaa2');
      wbException.Product__c = pickListEntry[0].getLabel();
      insert wbException;
      //END Test Exception Setup Data

      Id RecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      AH_UDC_Workbook__c objWorkbook1 = AH_UDC_TestData.GetWorkbookObject(null, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      objWorkbook1.RecordTypeId = RecordTypeId;
      insert objWorkbook1;
      try {
         List<sObject> records = new List<sObject> ();
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS1', RecordtypeId = wbsRTId, Workbook__c = objWorkbook1.Id, URL__c = 'www.Amadeus.com/test1'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS2', RecordtypeId = wbsRTId, Workbook__c = objWorkbook1.Id, URL__c = 'www.Amadeus.com/test2'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS3', RecordtypeId = wbsRTId, Workbook__c = objWorkbook1.Id, URL__c = 'www.Amadeus.com/test3'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS4', RecordtypeId = wbsRTId, Workbook__c = objWorkbook1.Id, URL__c = 'www.Amadeus.com/test4'));
         insert records;
      }
      catch(exception ex)
      {
         AH_UDC_LogHelper.Debug('insert error ' + ex.getMessage());
         System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage) > - 1, 'Duplicate URL or Form - Error message did not match');
      }

      //Set Owner to provide Workbook delete rights to Workbook Admin user   
      System.runAs(objWorkbookAdminUser) {
         AH_UDC_Workbook__c objWorkbook3 = AH_UDC_TestData.GetWorkbookObject(null, 'Test Workbook 3', 'Test Workbook 3 Description', 'Central Sales');
         objWorkbook3.RecordTypeId = RecordTypeId;
         insert objWorkbook3;

         try {
            List<sObject> records = new List<sObject> ();
            records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS1', RecordtypeId = wbsRTId, Workbook__c = objWorkbook3.Id, URL__c = 'www.Amadeus.com/test1'));
            records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS2', RecordtypeId = wbsRTId, Workbook__c = objWorkbook3.Id, URL__c = 'www.Amadeus.com/test2'));
            records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS3', RecordtypeId = wbsRTId, Workbook__c = objWorkbook3.Id, URL__c = 'www.Amadeus.com/test3'));
            records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS4', RecordtypeId = wbsRTId, Workbook__c = objWorkbook3.Id, URL__c = 'www.Amadeus.com/test4'));
            insert records;
         }
         catch(exception ex)
         {
            AH_UDC_LogHelper.Debug('insert error ' + ex.getMessage());
            System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage) > - 1, 'Duplicate URL or Form - Error message did not match');
         }
      }

      //Prepare test Data for File Upload testing : Start
      Id formAssemblyRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
      AH_UDC_Form__c objFormAssemblyForm1 = new AH_UDC_Form__c(Name = 'Form Assembly Form 1', RecordTypeId = formAssemblyRecordTypeId, FormAssemblyId__c = '1717171', FormType__c = AH_UDC_Constants.FORM_TYPE_PRODUCT);
      insert objFormAssemblyForm1;

      Id fileUploadFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
      //Create file upload form
      AH_UDC_Form__c objFileUploadForm1 = new AH_UDC_Form__c(Name = 'File Upload Form 1', RecordTypeId = fileUploadFormRecordTypeId, FormType__c = AH_UDC_Constants.FORM_TYPE_PRODUCT);
      insert objFileUploadForm1;

      AH_UDC_Workbook__c objFileUploadWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('File Upload Workbook', 'File Upload Workbook', 'Central Sales');
      objFileUploadWorkbook.Enabled__c = true;
      insert objFileUploadWorkbook;

      AH_UDC_WorkbookStep__c objFormAssemblyStep1 = new AH_UDC_WorkbookStep__c(Name = 'Form Assembly Step 1', RecordtypeId = wbsRTId, Workbook__c = objFileUploadWorkbook.Id, form__c = objFormAssemblyForm1.Id);
      insert objFormAssemblyStep1;

      AH_UDC_WorkbookStep__c objFileUploadStep1 = new AH_UDC_WorkbookStep__c(Name = 'File Upload Step 1', RecordtypeId = wbsRTId, Workbook__c = objFileUploadWorkbook.Id, form__c = objFileUploadForm1.Id);
      insert objFileUploadStep1;
      //Prepare test Data for File Upload testing : End
   }

   @isTest
   private static void testInsertWithWorkbookAdmin() {
      //SELECT workbook admin user 
      List<User> lstWorkbookAdminUsers = [SELECT Id FROM User
                                          WHERE Username = 'TestUDCWorkbookAdmin@amadeus.com'];
      System.assertEquals(true, lstWorkbookAdminUsers[0] != null, 'Workbook Admin user record not found');

      List<AH_UDC_Workbook__c> lstWorkbookDetail = [SELECT Id FROM AH_UDC_Workbook__c WHERE Name = 'TestWB'];
      System.assertEquals(1, lstWorkbookDetail.size(), 'Expected 1 Workbook.');

      //insert lstWorkbookDetail;
      Id workbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookStepRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP);
      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ();
      for (Integer i = 1; i <= TotalSteps; i++) {
         AH_UDC_WorkbookStep__c objWorkbookStep = new AH_UDC_WorkbookStep__c();
         objWorkbookStep.Workbook__c = lstWorkbookDetail[0].Id;
         objWorkbookStep.Name = 'Test Step ' + i;
         objWorkbookStep.RecordTypeId = workbookStepRecordTypeId;
         objWorkbookStep.URL__c = 'https://www.amadeus.com/' + i;
         objWorkbookStep.SortOrder__c = i;
         lstWorkbookSteps.add(objWorkbookStep);
      }
      //Share workbook with UDC Workbook Admin
      AH_UDC_Workbook__Share objWorkbookShareSent = new AH_UDC_Workbook__Share();
      objWorkbookShareSent.ParentId = lstWorkbookDetail[0].Id;
      objWorkbookShareSent.UserOrGroupId = lstWorkbookAdminUsers[0].Id;
      objWorkbookShareSent.AccessLevel = 'Edit';
      insert objWorkbookShareSent;
      Test.startTest();
      System.runAs(lstWorkbookAdminUsers[0]) {
         try
         {
            insert lstWorkbookSteps;
         } catch(Exception ex)
         {
            System.assert(false, 'UDC System Admin user should be able to insert the Workbook Steps' + ex.getMessage());
         }
      }
      Test.stopTest();
   }

   private static void testInsertWithWorkbookUser() {
      List<AH_UDC_Workbook__c> workbookDetail = [SELECT Id, name FROM AH_UDC_Workbook__c WHERE Name = 'TestInsert'];
      System.assertEquals(1, workbookDetail.size(), 'Expected 1 Workbook.');

      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();
      Boolean InsertException = false;
      try {
         AH_UDC_WorkbookStep__c wbStep = new AH_UDC_WorkbookStep__c(Name = 'WBS1', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.test.com');
         AH_UDC_Security.CreateObject(wbStep);
         AH_UDC_LogHelper.Debug('Workbook User should not be insert Workbook Step');
         System.assert(true, 'Workbook User should not be insert Workbook Step');
      }
      catch(exception ex)
      {
         AH_UDC_LogHelper.Debug('Error while inserting workbook steps ' + ex.getMessage());
         InsertException = true;
      }
      System.assertEquals(true, InsertException, 'Workbook User should not be able to insert Step');
   }

   private static void testInsert() {
      List<AH_UDC_Workbook__c> workbookDetail = [SELECT Id, name FROM AH_UDC_Workbook__c WHERE Name = 'TestInsert'];
      System.assertEquals(1, workbookDetail.size(), 'Expected 1 Workbook.');

      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();

      try {
         List<sObject> records = new List<sObject> ();
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS1', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.test.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS2', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.TestG.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS3', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.goog123ese.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS4', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.Amadeus.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS5', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.Google.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS6', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.Gmail.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS7', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.Gdrive.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS8', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.Yahoo.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS9', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.amax.com'));
         insert records;
      }
      catch(exception ex)
      {
         AH_UDC_LogHelper.Debug('Error while inserting workbook steps ' + ex.getMessage());
         System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage) > - 1, 'Duplicate URL or Form - Error message did not match');
      }
   }

   private static void testUpdateWithWorkbookUser() {
      List<AH_UDC_Workbook__c> workbookDetail = [SELECT Id, name FROM AH_UDC_Workbook__c WHERE Name = 'Test11'];
      System.assertEquals(1, workbookDetail.size(), 'Expected 1 Workbook.');

      List<AH_UDC_WorkbookStep__c> workbookStep = [SELECT Id, name, sortorder__c, Prerequisite_Step__c, URL__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id AND Name = 'WBS21'];
      System.assertEquals(1, workbookStep.size(), 'Expected 1 Workbook Steps');

      Boolean InsertException = false;
      try {
         workbookStep[0].Name = 'update by workbookadmin';
         AH_UDC_Security.UpdateObjects(workbookStep);
         AH_UDC_LogHelper.Debug('Workbook User should not be update Workbook Step');
         System.assert(true, 'Workbook User should not be update Workbook Step');
      }
      catch(exception ex)
      {
         AH_UDC_LogHelper.Debug('Error while updating workbook steps ' + ex.getMessage());
         InsertException = true;
      }
      System.assertEquals(true, InsertException, 'Workbook User should not be able to insert Step');
   }

   private static void testUpdate() {
      List<AH_UDC_Workbook__c> workbookDetail = [SELECT Id FROM AH_UDC_Workbook__c WHERE Name = 'Test11'];
      System.assert(workbookDetail.size() > 0, 'Workbook record not found with name Test11.');

      List<AH_UDC_WorkbookStep__c> workbookSteps = [SELECT Id, Name, SortOrder__c, Prerequisite_Step__c, URL__c, Form__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id ORDER BY SortOrder__c];
      System.assertEquals(12, workbookSteps.size(), 'Expected 12 workbook step records but found only ' + workbookSteps.size() + ' records');
      AH_UDC_LogHelper.Debug('workbookSteps: ' + workbookSteps);

      List<AH_UDC_Form__c> lstForms = [SELECT Id FROM AH_UDC_Form__c WHERE Name = 'TestForm1'];
      System.assert(lstForms.size() > 0, 'Form record not found with name TestForm1.');

      for(AH_UDC_WorkbookStep__c objStep : workbookSteps) {
         if(objStep.SortOrder__c == 1) {
            String strUrl = objStep.URL__c;
            //Try to update step with the url which is already exists for another step
            objStep.URL__c = 'www.test.com';
            try {
               update objStep;
            }
            catch(Exception ex) {
               System.assert(ex.getMessage().indexOf(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage) > -1, 'Error message did not match while updating step with the url which is already exists for another step. Actual error message: ' + ex.getMessage());
               objStep.URL__c = strUrl; //Set url value back to original
            }
         }
         else if(objStep.SortOrder__c == 2) {
            String strUrl = objStep.URL__c;
            //Try to update step with the form id which is already exists for another step
            objStep.Form__c = lstForms[0].Id;
            objStep.URL__c = null;
            try {
               update objStep;
            }
            catch(Exception ex) {
               System.assert(ex.getMessage().indexOf(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage) > -1, 'Error message did not match while updating step with the form id which is already exists for another step. Actual error message: ' + ex.getMessage());
               objStep.URL__c = strUrl; //Set url value back to original
               objStep.Form__c = null; //Revert form field to null
            }
         }
         else if(objStep.SortOrder__c == 6) {
            //Set 4th step as a prerequisite of 6th step
            objStep.Prerequisite_Step__c = workbookSteps[3].Id;  
            update objStep;

            List<AH_UDC_WorkbookStep__c> lstSteps = [SELECT Id, Prerequisite_Step__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id AND SortOrder__c = 6];
            System.assert(lstSteps.size() > 0, 'No step found with sort order 7');
            System.assertEquals(workbookSteps[3].Id, lstSteps[0].Prerequisite_Step__c, 'Prerequisite step is not updated');
         }
      }

      //Trying to move a step after the step for which it is set as prerequisite step
      workbookSteps[3].SortOrder__c = 8;
      try {
         update workbookSteps[3];
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOf(Label.AH_UDC_Workbook_Step_Trigger_Sort_order_changes_Validation_Message) > -1, 'Error message did not match while moving step after the step for which it is set as prerequisite step. Actual error message: ' + ex.getMessage());
         workbookSteps[3].SortOrder__c = 4; //Set sort order back to original
      }

      //Trying to move a step earlier than it's prerequisite step
      workbookSteps[5].SortOrder__c = 2;
      try {
         update workbookSteps[5];
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOf(Label.AH_UDC_Workbook_Step_Trigger_Sort_order_changes_Validation_Message) > -1, 'Error message did not match while moving step earlier than it\' prerequisite step. Actual error message: ' + ex.getMessage());
         workbookSteps[5].SortOrder__c = 6; //Set sort order back to original
      }
      
      //Trying to disable step which is prerequisite of another step
      workbookSteps[3].Enabled__c = false;
      try {
         update workbookSteps[3];
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOf(Label.AH_UDC_Workbook_Step_Trigger_Disable_Delete_Validation_Message) > -1, 'Error message did not match while disabling step which is prerequisite of another step. Actual error message: ' + ex.getMessage());
      }

      AH_UDC_WorkbookStepTriggerHelper.IsWorkbookRecordTypeException = true;
      try {
         //This update action is only for executing the trigger
         update workbookSteps[0];
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOf(Label.AH_UDC_WorkbookStepTriggerExceptionMessage) > - 1, 'Error not generated after making IsWorkbookRecordTypeException = true. Actual error message : ' + ex.getMessage());
      }

      //Allow other actions to perform without any error
      AH_UDC_WorkbookStepTriggerHelper.IsWorkbookRecordTypeException = false;
   }

   private static void testDelete() {

      List<AH_UDC_Workbook__c> workbookDetail = [SELECT Id, name FROM AH_UDC_Workbook__c WHERE Name = 'TestDelete'];
      System.assertEquals(1, workbookDetail.size(), 'Expected 1 Workbook.');

      //bulk delete
      List<AH_UDC_WorkbookStep__c> deleteWorkbookStepList = [SELECT Id, name, sortorder__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id AND Name IN('WBS5', 'WBS6', 'WBS7', 'WBS8')];
      System.assertEquals(4, deleteWorkbookStepList.size(), 'Expected 4 Workbook Steps');
      delete deleteWorkbookStepList;

      List<AH_UDC_WorkbookStep__c> workbookSteps = [SELECT Id, name, sortorder__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id order by SortOrder__c];
      System.assertEquals(3, workbookSteps.size(), 'Expected 3 Workbook Steps');

      List<AH_UDC_WorkbookStep__c> workbookStep3 = [SELECT Id, name, sortorder__c, Prerequisite_Step__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id AND Name = 'WBS3'];
      System.assertEquals(1, workbookStep3.size(), 'Expected 1 Workbook Steps');

      List<AH_UDC_WorkbookStep__c> workbookSteps3 = [SELECT Id, name, sortorder__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id AND Id = :workbookStep3[0].Id];
      delete workbookSteps3;

      List<AH_UDC_WorkbookStep__c> workbookSteps1 = [SELECT Id, name, sortorder__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id order by SortOrder__c];
      System.assertEquals(2, workbookSteps1.size(), 'Expected 2 Workbook Steps after deleting 1');
   }

   private static void testUndelete() {
      List<AH_UDC_Workbook__c> workbookDetail = [SELECT Id, name FROM AH_UDC_Workbook__c WHERE Name = 'TestUnDelete'];
      System.assertEquals(1, workbookDetail.size(), 'Expected 1 Workbook.');

      List<AH_UDC_WorkbookStep__c> workbookStep11 = [SELECT Id, name, sortorder__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id AND Name = 'WBS11'];
      System.assertEquals(1, workbookStep11.size(), 'Expected 1 Workbook Steps');

      Id workbookStep11iD = workbookStep11[0].Id;
      delete workbookStep11;

      List<AH_UDC_WorkbookStep__c> workbookSteps12 = [SELECT Id, name, sortorder__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id order by SortOrder__c];
      System.assertEquals(1, workbookSteps12.size(), 'Expected 1 Workbook Steps after deleting 1');

      AH_UDC_WorkbookStep__c[] workstep = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id AND Id = :workbookStep11iD ALL ROWS];

      undelete workbookStep11;

      List<AH_UDC_WorkbookStep__c> workbookSteps2 = [SELECT Id, name, sortorder__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id order by SortOrder__c];
      System.assertEquals(2, workbookSteps2.size(), 'Expected 2 Workbook Steps after undelete 1');
   }

   @isTest
   private static void testException() {

      List<AH_UDC_Workbook__c> workbookDetail = [SELECT Id, name FROM AH_UDC_Workbook__c WHERE Name = 'TestExc'];
      System.assertEquals(1, workbookDetail.size(), 'Expected 1 Workbook.');

      List<AH_UDC_Form__c> formDetail = [SELECT Id, name FROM AH_UDC_Form__c WHERE Name = 'TestForm1' AND FormAssemblyId__c = '515151'];
      System.assertEquals(1, formDetail.size(), 'Expected 1 form.');

      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();

      Test.startTest();

      Boolean InsertException = false;
      try
      {
         AH_UDC_WorkbookStep__c wbs1 = new AH_UDC_WorkbookStep__c(Name = 'TestException',
                                                                  RecordtypeId = wbsRTId,
                                                                  Workbook__c = workbookDetail[0].Id,
                                                                  form__c = formDetail[0].Id);
         insert wbs1;
      }
      catch(exception exc)
      {
         InsertException = true;
      }
      Test.stopTest();
      System.assertEquals(true, InsertException, 'Expected Exception');
   }

   @isTest
   private static void RunAsUDCWorkbookUser() {
      //create workbook  user with profiles and permission set
      List<User> objWorkbookUser = [SELECT Id FROM User
                                    WHERE Username = 'TestUDCWorkbookUser@amadeus.com'];
      System.assertEquals(true, objWorkbookUser[0] != null, 'Workbook User record not found');
      Boolean InsertException = false;
      Test.startTest();
      System.runAs(objWorkbookUser[0]) {

         testInsertWithWorkbookUser();
         testUpdateWithWorkbookUser();
      }
      Test.stopTest();
   }

   @isTest
   private static void RunAsUDCWorkbookAdminUser() {
      //create workbook admin user with profiles and permission set
      List<User> objWorkbookAdminUser = [SELECT Id FROM User
                                         WHERE Username = 'TestUDCWorkbookAdmin@amadeus.com'];
      System.assertEquals(true, objWorkbookAdminUser[0] != null, 'Workbook Admin user record not found');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name, OwnerId
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = 'Test11'];
      System.assert(lstWorkbook.size() > 0, 'Workbook records could not be found.');

      List<AH_UDC_Workbook__c> lstWorkbookDelete = [SELECT Id, Name, OwnerId
                                                    FROM AH_UDC_Workbook__c
                                                    WHERE Name = 'TestDelete'];
      System.assert(lstWorkbookDelete.size() > 0, 'Workbook records could not be found.');

      List<AH_UDC_Workbook__c> lstWorkbookUndelete = [SELECT Id, Name, OwnerId
                                                      FROM AH_UDC_Workbook__c
                                                      WHERE Name = 'TestUnDelete'];
      System.assert(lstWorkbookUndelete.size() > 0, 'Workbook records could not be found.');

      List<sObject> records = new List<sObject> ();
      records.add(new AH_UDC_Workbook__Share(ParentId = lstWorkbook[0].Id, UserOrGroupId = objWorkbookAdminUser[0].Id, AccessLevel = 'Edit')); //update workbook
      records.add(new AH_UDC_Workbook__Share(ParentId = lstWorkbookDelete[0].Id, UserOrGroupId = objWorkbookAdminUser[0].Id, AccessLevel = 'Edit')); //delete workbook
      records.add(new AH_UDC_Workbook__Share(ParentId = lstWorkbookUndelete[0].Id, UserOrGroupId = objWorkbookAdminUser[0].Id, AccessLevel = 'Edit')); //undelte workbook
      insert records;

      Test.startTest();
      System.runAs(objWorkbookAdminUser[0]) {
         testUpdate();
         try {
            // Delete wont work here as this workbooks are shared with Workbook Admin user not own by Workbook admin User
            testDelete();
         }
         catch(DmlException dmlexc) {
            // This is the expected behavior, so no assert here      
         }
         catch(Exception ex) {
            System.assert(false, 'An unexpected exception occurred while executing Delete workbook steps as workbook admin.' + ex.getMessage());
         }

         try {
            // Undelete wont work here as this workbooks are shared with Workbook Admin user not own by Workbook admin user            

            testUndelete();
         }
         catch(DmlException dmlexc) {
            // This is the expected behavior, so no assert here      
         }
         catch(Exception ex) {
            System.assert(false, 'An unexpected exception occurred while executing Un-delete workbook steps as workbook admin.' + ex.getMessage());
         }
      }
      Test.stopTest();
   }

   @isTest
   private static void RunAsUDCSystemAdminUser() {
      //create System admin user with profiles and permission set
      List<User> objSystemAdminUser = [SELECT Id FROM User
                                       WHERE Username = 'TestUDCSystemAdmin@amadeus.com'];
      System.assertEquals(true, objSystemAdminUser[0] != null, 'System Admin user record not found');

      Test.startTest();
      System.runAs(objSystemAdminUser[0]) {

         testInsert();

         testUpdate();

         testDelete();

         testUndelete();
      }
      Test.stopTest();
   }

   @isTest
   private static void TestDeleteAndUnDeleteTriggerForWorkbookSteps() {
      Test.startTest();

      Id WorkbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(WorkbookRecordTypeId), 'Workbook record type not found');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name FROM AH_UDC_Workbook__c WHERE Name = 'Test Workbook 1' AND RecordTypeId = :WorkbookRecordTypeId];
      System.assertEquals(true, lstWorkbook.size() > 0, 'Workbook  Record Not Found');

      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [SELECT Id, Name FROM AH_UDC_WorkbookStep__c WHERE Name = 'WBS1' AND Workbook__c = :lstWorkbook[0].Id];
      System.assertEquals(true, lstWorkbookStep.size() > 0, 'Workbook step Record Not Found');


      //workbook has been created and its owner is workbook admin
      List<AH_UDC_Workbook__c> lstWorkbookAdmin = [SELECT Id, Name FROM AH_UDC_Workbook__c WHERE Name = 'Test Workbook 3' AND RecordTypeId = :WorkbookRecordTypeId];
      System.assertEquals(true, lstWorkbookAdmin.size() > 0, 'Workbook Admin Record Not Found');

      //workbook step has been created and its owner is workbook admin so it allow to delete and undelete 
      List<AH_UDC_WorkbookStep__c> lstWorkbookAdminStep = [SELECT Id, Name FROM AH_UDC_WorkbookStep__c WHERE Name = 'WBS1' AND Workbook__c = :lstWorkbookAdmin[0].Id];
      System.assertEquals(true, lstWorkbookAdminStep.size() > 0, 'Workbook step record not found');

      List<User> lstWorkbookUsers = [SELECT Id, Username
                                     FROM User
                                     WHERE Username = 'TestUDCWorkbookUser@amadeus.com'
                                     AND IsActive = true];
      System.assert(lstWorkbookUsers.size() > 0, 'Workbook User record not found');

      //Check as workbook User
      System.runAs(lstWorkbookUsers[0]) {
         Id deletedId = null;
         try {
            deletedId = lstWorkbookStep[0].Id;
            delete lstWorkbookStep[0];
            System.assert(false, 'UDC Workbook User should not be able to delete the Workbook step');
         }
         catch(DmlException dmlexc) {
            // This is the expected behavior, so no assert here      
         }
         catch(Exception ex) {
            System.assert(false, 'An unexpected exception occurred while deleting workbook step with workbook user.' + ex.getMessage());
         }
      }

      List<User> lstWorkbookAdminUsers = [SELECT Id, Username
                                          FROM User
                                          WHERE Username = 'TestUDCWorkbookAdmin@amadeus.com'
                                          AND IsActive = true];
      System.assert(lstWorkbookAdminUsers.size() > 0, 'Workbook Admin user record not found');

      System.runAs(lstWorkbookAdminUsers[0]) {
         Id deletedId = lstWorkbookAdminStep[0].Id;
         delete lstWorkbookAdminStep[0];

         //Check if workbook step record is deleted or not
         List<AH_UDC_Workbookstep__c> lstDeletedWorkbookStep = [SELECT Id FROM AH_UDC_Workbookstep__c WHERE Id = :deletedId];
         System.assert(lstDeletedWorkbookStep == null || lstDeletedWorkbookStep.size() == 0, 'Owned Workbook step should be deleted by WorkbookAdmin');

         List<AH_UDC_WorkbookStep__c> lstUndeleteWorkbookStep = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Id = :deletedId ALL ROWS];
         undelete lstWorkbookAdminStep[0];

         //Check if workbook step record is unDeleted or not
         List<AH_UDC_WorkbookStep__c> lstUnDeletedWorkbooksStep = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Id = :deletedId];
         System.assertEquals(false, lstUnDeletedWorkbooksStep == null || lstUnDeletedWorkbooksStep.size() == 0, 'Owned Workbook step should be undeleted by Workbook Admin');
      }

      List<User> lstUDCSystemAdminUsers = [SELECT Id, Username
                                           FROM User
                                           WHERE Username = 'TestUDCSystemAdmin@amadeus.com'
                                           AND IsActive = true];
      System.assert(lstUDCSystemAdminUsers.size() > 0, 'UDC System Admin user record is not found');

      System.runAs(lstUDCSystemAdminUsers[0]) {
         Id deletedId = lstWorkbookStep[0].Id;
         delete lstWorkbookStep[0];

         //Check if workbook step record is deleted or not
         List<AH_UDC_WorkbookStep__c> lstDeletedWorkbookSteps = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Id = :deletedId];
         System.assert(lstDeletedWorkbookSteps == null || lstDeletedWorkbookSteps.size() == 0, 'Workbook step should be deleted by UDC System Admin user');

         List<AH_UDC_WorkbookStep__c> lstUndeleteWorkbook = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Id = :deletedId ALL ROWS];
         undelete lstWorkbookStep[0];

         //Check if workbook step record is unDeleted or not
         List<AH_UDC_WorkbookStep__c> lstUnDeletedWorkbooks = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Id = :deletedId];
         System.assertEquals(false, lstUnDeletedWorkbooks == null || lstUnDeletedWorkbooks.size() == 0, 'Workbook should be undeleted by UDC System Admin user');
      }

      Test.stopTest();
   }

   @isTest
   private static void testStepWithFileUploadForm() {
      Test.startTest();
      Id formAssemblyRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(formAssemblyRecordTypeId), 'Form assembly form record type id not found');

      Id fileUploadFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
      System.assert(String.isNotBlank(fileUploadFormRecordTypeId), 'File upload form record type id not found');

      Id workbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(workbookRecordTypeId), 'Workbook record type id not found');

      Id workbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();
      System.assert(String.isNotBlank(workbookStepRecordTypeId), 'Workbook step record type id not found');

      List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id
                                               FROM AH_UDC_Workbook__c
                                               WHERE Name = 'File Upload Workbook'
                                               AND RecordTypeId = :workbookRecordTypeId];
      System.assert(lstWorkbooks.size() > 0, 'Workbook record not found with name File Upload Workbook');

      List<AH_UDC_Form__c> lstFormsToInsert = new List<AH_UDC_Form__c> ();
      lstFormsToInsert.add(new AH_UDC_Form__c(Name = 'Form Assembly Form 2',
                                              FormAssemblyId__c = '1818181',
                                              RecordTypeId = formAssemblyRecordTypeId,
                                              FormType__c = AH_UDC_Constants.FORM_TYPE_PRODUCT));
      for (Integer i = 2; i <= 5; i++) {
         //Add 4 file upload forms in the list for bulk insert
         lstFormsToInsert.add(new AH_UDC_Form__c(Name = 'File Upload Form ' + i,
                                                 RecordTypeId = fileUploadFormRecordTypeId,
                                                 FormType__c = AH_UDC_Constants.FORM_TYPE_PRODUCT));
      }
      insert lstFormsToInsert; //Bulk insert forms

      List<AH_UDC_WorkbookStep__c> lstWorkbookStepsToInsert = new List<AH_UDC_WorkbookStep__c> ();
      lstWorkbookStepsToInsert.add(new AH_UDC_WorkbookStep__c(Name = 'Form Assembly 2',
                                                              RecordTypeId = workbookStepRecordTypeId,
                                                              Workbook__c = lstWorkbooks[0].Id,
                                                              form__c = lstFormsToInsert[0].Id));
      for (Integer i = 1; i <= 4; i++) {
         //Add 4 file upload steps in the list for bulk insert
         lstWorkbookStepsToInsert.add(new AH_UDC_WorkbookStep__c(Name = 'File Upload Step ' + (i + 1),
                                                                 RecordTypeId = workbookStepRecordTypeId,
                                                                 Workbook__c = lstWorkbooks[0].Id,
                                                                 form__c = lstFormsToInsert[i].Id));
      }

      try {
         insert lstWorkbookStepsToInsert; //Try to insert multiple file upload steps in a bulk
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOf(Label.AH_UDC_FileUploadTriggerError) > - 1, 'Error not generated when trying to insert multiple file upload steps in a bulk.');
      }

      List<AH_UDC_WorkbookStep__c> lstFileUploadSteps = [SELECT Id
                                                         FROM AH_UDC_WorkbookStep__c
                                                         WHERE Name = 'File Upload Step 1'
                                                         AND Workbook__c = :lstWorkbooks[0].Id
                                                         AND RecordTypeId = :workbookStepRecordTypeId
                                                         And Form__c != null
                                                         AND Form__r.RecordTypeId = :fileUploadFormRecordTypeId];
      System.assert(lstFileUploadSteps.size() > 0, 'Workbook step record not found with name File Upload Step 1');

      AH_UDC_WorkbookStep__c objFileUploadStep2 = new AH_UDC_WorkbookStep__c(Name = 'File Upload Step 2',
                                                                             RecordtypeId = workbookStepRecordTypeId,
                                                                             Workbook__c = lstWorkbooks[0].Id,
                                                                             form__c = lstFormsToInsert[1].Id);
      try {
         insert objFileUploadStep2; //Try to insert another file upload step when one file upload step is already there
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOf(Label.AH_UDC_FileUploadTriggerError) > - 1, 'Error not generated when trying to insert step with file upload form and one file upload form is already there.');
      }

      //Fetch other step than file upload step
      List<AH_UDC_WorkbookStep__c> lstSteps = [SELECT Id, Form__c
                                               FROM AH_UDC_WorkbookStep__c
                                               WHERE Name = 'Form Assembly Step 1'
                                               AND Workbook__c = :lstWorkbooks[0].Id
                                               AND Form__r.RecordTypeId != :fileUploadFormRecordTypeId
                                               AND RecordTypeId = :workbookStepRecordTypeId];
      System.assert(lstSteps.size() > 0, 'Workbook step record not found with name Form Assembly Step 1');

      lstSteps[0].Form__c = lstFormsToInsert[1].Id;
      try {
         //Try to update step with file upload form when one file upload form is already there
         update lstSteps[0];
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOf(Label.AH_UDC_FileUploadTriggerError) > - 1, 'Error not generated when trying to update step with file upload form and one file upload form is already there.');
      }

      //Delete file upload step to test undelete case
      delete lstFileUploadSteps[0];

      //Insert another file upload step after deleting previous file upload step
      insert objFileUploadStep2;

      lstFileUploadSteps = [SELECT Id
                            FROM AH_UDC_WorkbookStep__c
                            WHERE Name = 'File Upload Step 1'
                            AND RecordTypeId = :workbookStepRecordTypeId ALL ROWS];
      System.assert(lstFileUploadSteps.size() > 0, 'Deleted step not found with name File Upload Step 1');

      try {
         //Try to undelete step with file upload form when one file upload form is already there
         undelete lstFileUploadSteps[0];
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOf(Label.AH_UDC_FileUploadTriggerError) > - 1, 'Error not generated when trying to undelete step with file upload form and one file upload form is already there.');
      }

      AH_UDC_WorkbookStep__c objFileUploadStep = new AH_UDC_WorkbookStep__c(Name = 'File Upload Step 2',
                                                                            Workbook__c = lstWorkbooks[0].Id,
                                                                            RecordtypeId = workbookStepRecordTypeId,
                                                                            URL__c = 'https://www.test.com/');
      AH_UDC_WorkbookStepTriggerHelper.IsWorkbookRecordTypeException = true;
      try {
         //This insert action is only for executing the trigger
         insert objFileUploadStep;
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOf(Label.AH_UDC_WorkbookStepTriggerExceptionMessage) > - 1, 'Error not generated after making IsWorkbookRecordTypeException = true. Actual error message : ' + ex.getMessage());
      }

      AH_UDC_WorkbookStepTriggerHelper.IsWorkbookRecordTypeException = false;
      AH_UDC_WorkbookStepTriggerHelper.IsFormRecordTypeException = true;
      try {
         //This insert action is only for executing the trigger
         insert objFileUploadStep;
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOf(Label.AH_UDC_WorkbookStepTriggerExceptionMessage) > - 1, 'Error not generated after making IsFormRecordTypeException = true. Actual error message : ' + ex.getMessage());
      }

      AH_UDC_WorkbookStepTriggerHelper.IsWorkbookRecordTypeException = false;
      AH_UDC_WorkbookStepTriggerHelper.IsFormRecordTypeException = false;
      AH_UDC_WorkbookStepTriggerHelper.IsExceptionToCoverCatchBlock = true;
      try {
         //This insert action is only for executing the trigger
         insert objFileUploadStep;
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOf(Label.AH_UDC_WorkbookStepTriggerExceptionMessage) > - 1, 'Error not generated after making IsExceptionToCoverCatchBlock = true. Actual error message : ' + ex.getMessage());
      }
      Test.stopTest();
   }
=======
/**
 * Name          : AH_UDC_WorkbookStepTriggerHelper_TEST
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-04-20
 * Description   : This class is a test class for AH_UDC_WorkbookStepTriggerHelper
 * Dependencies  : AH_UDC_WorkbookStepTriggerHelper
 **/

@isTest
private class AH_UDC_WorkbookStepTriggerHelper_TEST {
   public static final Integer TotalSteps = 200;
   @testSetup
   private static void setupTestData() {
      List<User> listUsers = new List<User> ();

      //Insert Workbook user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                              'UDCWorkbookUser', null, false));
      //Insert Workbook Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                              'UDCWorkbookAdmin', null, false));
      //Insert UDC System Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                              'UDCSystemAdmin', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[2].Id);
      }
      User objWorkbookUser = listUsers[0];
      User objWorkbookAdminUser = listUsers[1];
      User objUdcSystemAdmin = listUsers[2];


      //Prevent error : System.LimitException: Too many SOQL queries: 101
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      AH_UDC_WorkbookStep__c objWorkbookStep = null;
      Account objAccount = null;
      NI_Documentation__c objNIDoc = null;
      AH_UDC_Workbook__c objWorkbook = null;
      Schema.DescribeFieldResult fieldResult = null;
      List<Schema.PicklistEntry> pickListEntry = null;

      //Get Product Picklist
      fieldResult = AH_UDC_Workbook__c.Product__c.getDescribe();
      if (fieldResult != null) {
         pickListEntry = fieldResult.getPicklistValues();
      }

      //Insert new Account data         
      objAccount = AH_UDC_TestData.GetAccountObject('GUID');
      insert objAccount;

      objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 8, 30));
      objNIDoc.Account__c = objAccount.Id;
      insert objNIDoc;

      //Insert Workbook Record
      objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      //Set OwnerId to provide Workbook Step delete rights to Workbook Admin user
      objWorkbook.OwnerId = objWorkbookAdminUser.Id;
      insert objWorkbook;

      //Insert Workbook Step Record for Delete
      objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Workbook Step');
      objWorkbookStep.URL__c = 'https://www.google.com/';
      insert objWorkbookStep;

      //Create Form
      AH_UDC_Form__c form = new AH_UDC_Form__c(Name = 'TestForm1', FormAssemblyId__c = '515151');
      insert form;

      Id wbRTId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_Workbook').getRecordTypeId();
      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();

      //Test Insert Data Setup
      AH_UDC_Workbook__c objWB = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('TestWB', 'TestWB 1 Description', 'Central Sales');
      objWB.Enabled__c = true;
      insert objWB;
      System.runAs(objWorkbookUser) {
         AH_UDC_Workbook__c wbInsert = new AH_UDC_Workbook__c(Name = 'TestInsert', RecordtypeId = wbRTId, SecurityCode__c = '4a1d7cd6-e80a-4561-975e-7229655ed41f3758b38b-75f0-416d-872e-1205b8cbaaa0');
         wbInsert.Product__c = pickListEntry[0].getLabel();
         insert wbInsert;
      }
      //End Test Insert

      //Test Update Data Setup
      //Insert Workbook 
      AH_UDC_Workbook__c wb1 = new AH_UDC_Workbook__c(Name = 'Test11', RecordtypeId = wbRTId, SecurityCode__c = '4a1d7cd6-e80a-4561-975e-7229655ed41f3758b38b-75f0-416d-872e-1205b8cbaaa7');
      wb1.Product__c = pickListEntry[0].getLabel();
      insert wb1;

      AH_UDC_WorkbookStep__c wbs21 = new AH_UDC_WorkbookStep__c(Name = 'WBS21', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.googlese1.com');
      insert wbs21;

      AH_UDC_WorkbookStep__c wbs31 = new AH_UDC_WorkbookStep__c(Name = 'WBS31', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.googlese.com');
      insert wbs31;

      AH_UDC_WorkbookStep__c wbs41 = new AH_UDC_WorkbookStep__c(Name = 'WBS41', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, form__c = form.Id);
      wbs41.Prerequisite_Step__c = wbs21.Id;
      insert wbs41;

      try {
         List<sObject> records = new List<sObject> ();
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS101', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.test.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS102', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.Test123.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS103', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.goog123ese.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS104', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.Amadeus.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS105', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.Google.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS106', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.Gmail.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS107', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.Gdrive.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS108', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.Yahoo.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS109', RecordtypeId = wbsRTId, Workbook__c = wb1.Id, URL__c = 'www.amax.com'));
         insert records;
      }
      catch(exception ex)
      {
         AH_UDC_LogHelper.Debug('insert error ' + ex.getMessage());
         System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage) > - 1, 'Duplicate URL or Form - Error message did not match');
      }

      //END Test Update

      //Test Delete Setup Data
      //Insert Workbook
      AH_UDC_Workbook__c wbDelete = new AH_UDC_Workbook__c(Name = 'TestDelete', RecordtypeId = wbRTId, SecurityCode__c = '4a1d7cd6-e80a-4561-975e-7229655ed41f3758b38b-75f0-416d-872e-1205b8cbaaa1');
      wbDelete.Product__c = pickListEntry[0].getLabel();
      insert wbDelete;

      AH_UDC_WorkbookStep__c wbs2 = new AH_UDC_WorkbookStep__c(Name = 'WBS2', RecordtypeId = wbsRTId, Workbook__c = wbDelete.Id, URL__c = 'www.test1.com');
      insert wbs2;

      AH_UDC_WorkbookStep__c wbs3 = new AH_UDC_WorkbookStep__c(Name = 'WBS3', RecordtypeId = wbsRTId, Workbook__c = wbDelete.Id, form__c = form.Id);
      insert wbs3;

      AH_UDC_WorkbookStep__c wbs4 = new AH_UDC_WorkbookStep__c(Name = 'WBS4', RecordtypeId = wbsRTId, Workbook__c = wbDelete.Id, URL__c = 'www.test.com');
      wbs4.Prerequisite_Step__c = wbs2.Id;
      insert wbs4;

      try {
         List<sObject> records = new List<sObject> ();
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS5', RecordtypeId = wbsRTId, Workbook__c = wbDelete.Id, URL__c = 'www.Amadeus.com/test1'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS6', RecordtypeId = wbsRTId, Workbook__c = wbDelete.Id, URL__c = 'www.Amadeus.com/test2'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS7', RecordtypeId = wbsRTId, Workbook__c = wbDelete.Id, URL__c = 'www.Amadeus.com/test3'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS8', RecordtypeId = wbsRTId, Workbook__c = wbDelete.Id, URL__c = 'www.Amadeus.com/test4'));
         insert records;
      }
      catch(exception ex)
      {
         AH_UDC_LogHelper.Debug('insert error ' + ex.getMessage());
         System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage) > - 1, 'Duplicate URL or Form - Error message did not match');
      }
      //END Test Delete

      //Test UnDelete Setup Data
      AH_UDC_Workbook__c wbUndelete = new AH_UDC_Workbook__c(Name = 'TestUnDelete', RecordtypeId = wbRTId, SecurityCode__c = '4a1d7cd6-e80a-4561-975e-7229655ed41f3758b38b-75f0-416d-872e-1205b8cbaaa5');
      wbUndelete.Product__c = pickListEntry[0].getLabel();
      insert wbUndelete;

      AH_UDC_WorkbookStep__c wbs10 = new AH_UDC_WorkbookStep__c(Name = 'WBS10', RecordtypeId = wbsRTId, Workbook__c = wbUndelete.Id, URL__c = 'www.test.com');
      insert wbs10;

      AH_UDC_WorkbookStep__c wbs11 = new AH_UDC_WorkbookStep__c(Name = 'WBS11', RecordtypeId = wbsRTId, Workbook__c = wbUndelete.Id, form__c = form.Id);
      wbs11.Prerequisite_Step__c = wbs10.Id;
      insert wbs11;
      //END Test UnDelete Setup Data

      //Test Exception Setup Data
      AH_UDC_Workbook__c wbException = new AH_UDC_Workbook__c(Name = 'TestExc', RecordtypeId = wbRTId, SecurityCode__c = '4a1d7cd6-e80a-4561-975e-7229655ed41f3758b38b-75f0-416d-872e-1205b8cbaaa2');
      wbException.Product__c = pickListEntry[0].getLabel();
      insert wbException;
      //END Test Exception Setup Data

      Id RecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      AH_UDC_Workbook__c objWorkbook1 = AH_UDC_TestData.GetWorkbookObject(null, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      objWorkbook1.RecordTypeId = RecordTypeId;
      insert objWorkbook1;
      try {
         List<sObject> records = new List<sObject> ();
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS1', RecordtypeId = wbsRTId, Workbook__c = objWorkbook1.Id, URL__c = 'www.Amadeus.com/test1'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS2', RecordtypeId = wbsRTId, Workbook__c = objWorkbook1.Id, URL__c = 'www.Amadeus.com/test2'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS3', RecordtypeId = wbsRTId, Workbook__c = objWorkbook1.Id, URL__c = 'www.Amadeus.com/test3'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS4', RecordtypeId = wbsRTId, Workbook__c = objWorkbook1.Id, URL__c = 'www.Amadeus.com/test4'));
         insert records;
      }
      catch(exception ex)
      {
         AH_UDC_LogHelper.Debug('insert error ' + ex.getMessage());
         System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage) > - 1, 'Duplicate URL or Form - Error message did not match');
      }

      //Set Owner to provide Workbook delete rights to Workbook Admin user   
      System.runAs(objWorkbookAdminUser) {
         AH_UDC_Workbook__c objWorkbook3 = AH_UDC_TestData.GetWorkbookObject(null, 'Test Workbook 3', 'Test Workbook 3 Description', 'Central Sales');
         objWorkbook3.RecordTypeId = RecordTypeId;
         insert objWorkbook3;

         try {
            List<sObject> records = new List<sObject> ();
            records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS1', RecordtypeId = wbsRTId, Workbook__c = objWorkbook3.Id, URL__c = 'www.Amadeus.com/test1'));
            records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS2', RecordtypeId = wbsRTId, Workbook__c = objWorkbook3.Id, URL__c = 'www.Amadeus.com/test2'));
            records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS3', RecordtypeId = wbsRTId, Workbook__c = objWorkbook3.Id, URL__c = 'www.Amadeus.com/test3'));
            records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS4', RecordtypeId = wbsRTId, Workbook__c = objWorkbook3.Id, URL__c = 'www.Amadeus.com/test4'));
            insert records;
         }
         catch(exception ex)
         {
            AH_UDC_LogHelper.Debug('insert error ' + ex.getMessage());
            System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage) > - 1, 'Duplicate URL or Form - Error message did not match');
         }
      }

      //Prepare test Data for File Upload testing : Start
      Id formAssemblyRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
      AH_UDC_Form__c objFormAssemblyForm1 = new AH_UDC_Form__c(Name = 'Form Assembly Form 1', RecordTypeId = formAssemblyRecordTypeId, FormAssemblyId__c = '1717171', FormType__c = AH_UDC_Constants.FORM_TYPE_PRODUCT);
      insert objFormAssemblyForm1;

      Id fileUploadFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
      //Create file upload form
      List<AH_UDC_Form__c> lstFileUploadForms = new List<AH_UDC_Form__c>();
      lstFileUploadForms.add(new AH_UDC_Form__c(Name = 'File Upload Form 1', RecordTypeId = fileUploadFormRecordTypeId, FormType__c = AH_UDC_Constants.FORM_TYPE_PRODUCT));
      lstFileUploadForms.add(new AH_UDC_Form__c(Name = 'File Upload Form 2', RecordTypeId = fileUploadFormRecordTypeId, FormType__c = AH_UDC_Constants.FORM_TYPE_PRODUCT));
      insert lstFileUploadForms;

      AH_UDC_Workbook__c objFileUploadWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('File Upload Workbook', 'File Upload Workbook', 'Central Sales');
      objFileUploadWorkbook.Enabled__c = true;
      insert objFileUploadWorkbook;

      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = new List<AH_UDC_WorkbookStep__c>();
      lstWorkbookSteps.add(new AH_UDC_WorkbookStep__c(Name = 'Form Assembly Step 1', RecordtypeId = wbsRTId, Workbook__c = objFileUploadWorkbook.Id, form__c = objFormAssemblyForm1.Id));
      lstWorkbookSteps.add(new AH_UDC_WorkbookStep__c(Name = 'File Upload Step 1', RecordtypeId = wbsRTId, Workbook__c = objFileUploadWorkbook.Id, form__c = lstFileUploadForms[0].Id));
      lstWorkbookSteps.add(new AH_UDC_WorkbookStep__c(Name = 'File Upload Step 2', RecordtypeId = wbsRTId, Workbook__c = objFileUploadWorkbook.Id, form__c = lstFileUploadForms[1].Id));
      insert lstWorkbookSteps;
      //Prepare test Data for File Upload testing : End
   }

   @isTest
   private static void testInsertWithWorkbookAdmin() {
      //SELECT workbook admin user 
      List<User> lstWorkbookAdminUsers = [SELECT Id FROM User
                                          WHERE Username = 'TestUDCWorkbookAdmin@amadeus.com'];
      System.assertEquals(true, lstWorkbookAdminUsers[0] != null, 'Workbook Admin user record not found');

      List<AH_UDC_Workbook__c> lstWorkbookDetail = [SELECT Id FROM AH_UDC_Workbook__c WHERE Name = 'TestWB'];
      System.assertEquals(1, lstWorkbookDetail.size(), 'Expected 1 Workbook.');

      //insert lstWorkbookDetail;
      Id workbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookStepRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP);
      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ();
      for (Integer i = 1; i <= TotalSteps; i++) {
         AH_UDC_WorkbookStep__c objWorkbookStep = new AH_UDC_WorkbookStep__c();
         objWorkbookStep.Workbook__c = lstWorkbookDetail[0].Id;
         objWorkbookStep.Name = 'Test Step ' + i;
         objWorkbookStep.RecordTypeId = workbookStepRecordTypeId;
         objWorkbookStep.URL__c = 'https://www.amadeus.com/' + i;
         objWorkbookStep.SortOrder__c = i;
         lstWorkbookSteps.add(objWorkbookStep);
      }
      //Share workbook with UDC Workbook Admin
      AH_UDC_Workbook__Share objWorkbookShareSent = new AH_UDC_Workbook__Share();
      objWorkbookShareSent.ParentId = lstWorkbookDetail[0].Id;
      objWorkbookShareSent.UserOrGroupId = lstWorkbookAdminUsers[0].Id;
      objWorkbookShareSent.AccessLevel = 'Edit';
      insert objWorkbookShareSent;
      Test.startTest();
      System.runAs(lstWorkbookAdminUsers[0]) {
         try
         {
            insert lstWorkbookSteps;
         } catch(Exception ex)
         {
            System.assert(false, 'UDC System Admin user should be able to insert the Workbook Steps' + ex.getMessage());
         }
      }
      Test.stopTest();
   }

   private static void testInsertWithWorkbookUser() {
      List<AH_UDC_Workbook__c> workbookDetail = [SELECT Id, name FROM AH_UDC_Workbook__c WHERE Name = 'TestInsert'];
      System.assertEquals(1, workbookDetail.size(), 'Expected 1 Workbook.');

      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();
      Boolean InsertException = false;
      try {
         AH_UDC_WorkbookStep__c wbStep = new AH_UDC_WorkbookStep__c(Name = 'WBS1', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.test.com');
         AH_UDC_Security.CreateObject(wbStep);
         AH_UDC_LogHelper.Debug('Workbook User should not be insert Workbook Step');
         System.assert(true, 'Workbook User should not be insert Workbook Step');
      }
      catch(exception ex)
      {
         AH_UDC_LogHelper.Debug('Error while inserting workbook steps ' + ex.getMessage());
         InsertException = true;
      }
      System.assertEquals(true, InsertException, 'Workbook User should not be able to insert Step');
   }

   private static void testInsert() {
      List<AH_UDC_Workbook__c> workbookDetail = [SELECT Id, name FROM AH_UDC_Workbook__c WHERE Name = 'TestInsert'];
      System.assertEquals(1, workbookDetail.size(), 'Expected 1 Workbook.');

      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();

      try {
         List<sObject> records = new List<sObject> ();
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS1', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.test.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS2', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.TestG.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS3', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.goog123ese.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS4', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.Amadeus.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS5', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.Google.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS6', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.Gmail.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS7', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.Gdrive.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS8', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.Yahoo.com'));
         records.add(new AH_UDC_WorkbookStep__c(Name = 'WBS9', RecordtypeId = wbsRTId, Workbook__c = workbookDetail[0].Id, URL__c = 'www.amax.com'));
         insert records;
      }
      catch(exception ex)
      {
         AH_UDC_LogHelper.Debug('Error while inserting workbook steps ' + ex.getMessage());
         System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage) > - 1, 'Duplicate URL or Form - Error message did not match');
      }
   }

   private static void testUpdateWithWorkbookUser() {
      List<AH_UDC_Workbook__c> workbookDetail = [SELECT Id, name FROM AH_UDC_Workbook__c WHERE Name = 'Test11'];
      System.assertEquals(1, workbookDetail.size(), 'Expected 1 Workbook.');

      List<AH_UDC_WorkbookStep__c> workbookStep = [SELECT Id, name, sortorder__c, Prerequisite_Step__c, URL__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id AND Name = 'WBS21'];
      System.assertEquals(1, workbookStep.size(), 'Expected 1 Workbook Steps');

      Boolean InsertException = false;
      try {
         workbookStep[0].Name = 'update by workbookadmin';
         AH_UDC_Security.UpdateObjects(workbookStep);
         AH_UDC_LogHelper.Debug('Workbook User should not be update Workbook Step');
         System.assert(true, 'Workbook User should not be update Workbook Step');
      }
      catch(exception ex)
      {
         AH_UDC_LogHelper.Debug('Error while updating workbook steps ' + ex.getMessage());
         InsertException = true;
      }
      System.assertEquals(true, InsertException, 'Workbook User should not be able to insert Step');
   }

   private static void testUpdate() {
      List<AH_UDC_Workbook__c> workbookDetail = [SELECT Id FROM AH_UDC_Workbook__c WHERE Name = 'Test11'];
      System.assert(workbookDetail.size() > 0, 'Workbook record not found with name Test11.');

      List<AH_UDC_WorkbookStep__c> workbookSteps = [SELECT Id, Name, SortOrder__c, Prerequisite_Step__c, URL__c, Form__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id ORDER BY SortOrder__c];
      System.assertEquals(12, workbookSteps.size(), 'Expected 12 workbook step records but found only ' + workbookSteps.size() + ' records');
      AH_UDC_LogHelper.Debug('workbookSteps: ' + workbookSteps);

      List<AH_UDC_Form__c> lstForms = [SELECT Id FROM AH_UDC_Form__c WHERE Name = 'TestForm1'];
      System.assert(lstForms.size() > 0, 'Form record not found with name TestForm1.');

      for(AH_UDC_WorkbookStep__c objStep : workbookSteps) {
         if(objStep.SortOrder__c == 1) {
            String strUrl = objStep.URL__c;
            //Try to update step with the url which is already exists for another step
            objStep.URL__c = 'www.test.com';
            try {
               update objStep;
            }
            catch(Exception ex) {
               System.assert(ex.getMessage().indexOf(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage) > -1, 'Error message did not match while updating step with the url which is already exists for another step. Actual error message: ' + ex.getMessage());
               objStep.URL__c = strUrl; //Set url value back to original
            }
         }
         else if(objStep.SortOrder__c == 2) {
            String strUrl = objStep.URL__c;
            //Try to update step with the form id which is already exists for another step
            objStep.Form__c = lstForms[0].Id;
            objStep.URL__c = null;
            try {
               update objStep;
            }
            catch(Exception ex) {
               System.assert(ex.getMessage().indexOf(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage) > -1, 'Error message did not match while updating step with the form id which is already exists for another step. Actual error message: ' + ex.getMessage());
               objStep.URL__c = strUrl; //Set url value back to original
               objStep.Form__c = null; //Revert form field to null
            }
         }
         else if(objStep.SortOrder__c == 6) {
            //Set 4th step as a prerequisite of 6th step
            objStep.Prerequisite_Step__c = workbookSteps[3].Id;  
            update objStep;

            List<AH_UDC_WorkbookStep__c> lstSteps = [SELECT Id, Prerequisite_Step__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id AND SortOrder__c = 6];
            System.assert(lstSteps.size() > 0, 'No step found with sort order 7');
            System.assertEquals(workbookSteps[3].Id, lstSteps[0].Prerequisite_Step__c, 'Prerequisite step is not updated');
         }
      }

      //Trying to move a step after the step for which it is set as prerequisite step
      workbookSteps[3].SortOrder__c = 8;
      try {
         update workbookSteps[3];
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOf(Label.AH_UDC_Workbook_Step_Trigger_Sort_order_changes_Validation_Message) > -1, 'Error message did not match while moving step after the step for which it is set as prerequisite step. Actual error message: ' + ex.getMessage());
         workbookSteps[3].SortOrder__c = 4; //Set sort order back to original
      }

      //Trying to move a step earlier than it's prerequisite step
      workbookSteps[5].SortOrder__c = 2;
      try {
         update workbookSteps[5];
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOf(Label.AH_UDC_Workbook_Step_Trigger_Sort_order_changes_Validation_Message) > -1, 'Error message did not match while moving step earlier than it\' prerequisite step. Actual error message: ' + ex.getMessage());
         workbookSteps[5].SortOrder__c = 6; //Set sort order back to original
      }
      
      //Trying to disable step which is prerequisite of another step
      workbookSteps[3].Enabled__c = false;
      try {
         update workbookSteps[3];
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOf(Label.AH_UDC_Workbook_Step_Trigger_Disable_Delete_Validation_Message) > -1, 'Error message did not match while disabling step which is prerequisite of another step. Actual error message: ' + ex.getMessage());
      }

      AH_UDC_WorkbookStepTriggerHelper.IsWorkbookRecordTypeException = true;
      try {
         //This update action is only for executing the trigger
         update workbookSteps[0];
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOf(Label.AH_UDC_WorkbookStepTriggerExceptionMessage) > - 1, 'Error not generated after making IsWorkbookRecordTypeException = true. Actual error message : ' + ex.getMessage());
      }

      //Allow other actions to perform without any error
      AH_UDC_WorkbookStepTriggerHelper.IsWorkbookRecordTypeException = false;
   }

   private static void testDelete() {

      List<AH_UDC_Workbook__c> workbookDetail = [SELECT Id, name FROM AH_UDC_Workbook__c WHERE Name = 'TestDelete'];
      System.assertEquals(1, workbookDetail.size(), 'Expected 1 Workbook.');

      //bulk delete
      List<AH_UDC_WorkbookStep__c> deleteWorkbookStepList = [SELECT Id, name, sortorder__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id AND Name IN('WBS5', 'WBS6', 'WBS7', 'WBS8')];
      System.assertEquals(4, deleteWorkbookStepList.size(), 'Expected 4 Workbook Steps');
      delete deleteWorkbookStepList;

      List<AH_UDC_WorkbookStep__c> workbookSteps = [SELECT Id, name, sortorder__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id order by SortOrder__c];
      System.assertEquals(3, workbookSteps.size(), 'Expected 3 Workbook Steps');

      List<AH_UDC_WorkbookStep__c> workbookStep3 = [SELECT Id, name, sortorder__c, Prerequisite_Step__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id AND Name = 'WBS3'];
      System.assertEquals(1, workbookStep3.size(), 'Expected 1 Workbook Steps');

      List<AH_UDC_WorkbookStep__c> workbookSteps3 = [SELECT Id, name, sortorder__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id AND Id = :workbookStep3[0].Id];
      delete workbookSteps3;

      List<AH_UDC_WorkbookStep__c> workbookSteps1 = [SELECT Id, name, sortorder__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id order by SortOrder__c];
      System.assertEquals(2, workbookSteps1.size(), 'Expected 2 Workbook Steps after deleting 1');
   }

   private static void testUndelete() {
      List<AH_UDC_Workbook__c> workbookDetail = [SELECT Id, name FROM AH_UDC_Workbook__c WHERE Name = 'TestUnDelete'];
      System.assertEquals(1, workbookDetail.size(), 'Expected 1 Workbook.');

      List<AH_UDC_WorkbookStep__c> workbookStep11 = [SELECT Id, name, sortorder__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id AND Name = 'WBS11'];
      System.assertEquals(1, workbookStep11.size(), 'Expected 1 Workbook Steps');

      Id workbookStep11iD = workbookStep11[0].Id;
      delete workbookStep11;

      List<AH_UDC_WorkbookStep__c> workbookSteps12 = [SELECT Id, name, sortorder__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id order by SortOrder__c];
      System.assertEquals(1, workbookSteps12.size(), 'Expected 1 Workbook Steps after deleting 1');

      AH_UDC_WorkbookStep__c[] workstep = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id AND Id = :workbookStep11iD ALL ROWS];

      undelete workbookStep11;

      List<AH_UDC_WorkbookStep__c> workbookSteps2 = [SELECT Id, name, sortorder__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].Id order by SortOrder__c];
      System.assertEquals(2, workbookSteps2.size(), 'Expected 2 Workbook Steps after undelete 1');
   }

   @isTest
   private static void testException() {

      List<AH_UDC_Workbook__c> workbookDetail = [SELECT Id, name FROM AH_UDC_Workbook__c WHERE Name = 'TestExc'];
      System.assertEquals(1, workbookDetail.size(), 'Expected 1 Workbook.');

      List<AH_UDC_Form__c> formDetail = [SELECT Id, name FROM AH_UDC_Form__c WHERE Name = 'TestForm1' AND FormAssemblyId__c = '515151'];
      System.assertEquals(1, formDetail.size(), 'Expected 1 form.');

      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();

      Test.startTest();

      Boolean InsertException = false;
      try
      {
         AH_UDC_WorkbookStep__c wbs1 = new AH_UDC_WorkbookStep__c(Name = 'TestException',
                                                                  RecordtypeId = wbsRTId,
                                                                  Workbook__c = workbookDetail[0].Id,
                                                                  form__c = formDetail[0].Id);
         insert wbs1;
      }
      catch(exception exc)
      {
         InsertException = true;
      }
      Test.stopTest();
      System.assertEquals(true, InsertException, 'Expected Exception');
   }

   @isTest
   private static void RunAsUDCWorkbookUser() {
      //create workbook  user with profiles and permission set
      List<User> objWorkbookUser = [SELECT Id FROM User
                                    WHERE Username = 'TestUDCWorkbookUser@amadeus.com'];
      System.assertEquals(true, objWorkbookUser[0] != null, 'Workbook User record not found');
      Boolean InsertException = false;
      Test.startTest();
      System.runAs(objWorkbookUser[0]) {

         testInsertWithWorkbookUser();
         testUpdateWithWorkbookUser();
      }
      Test.stopTest();
   }

   @isTest
   private static void RunAsUDCWorkbookAdminUser() {
      //create workbook admin user with profiles and permission set
      List<User> objWorkbookAdminUser = [SELECT Id FROM User
                                         WHERE Username = 'TestUDCWorkbookAdmin@amadeus.com'];
      System.assertEquals(true, objWorkbookAdminUser[0] != null, 'Workbook Admin user record not found');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name, OwnerId
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = 'Test11'];
      System.assert(lstWorkbook.size() > 0, 'Workbook records could not be found.');

      List<AH_UDC_Workbook__c> lstWorkbookDelete = [SELECT Id, Name, OwnerId
                                                    FROM AH_UDC_Workbook__c
                                                    WHERE Name = 'TestDelete'];
      System.assert(lstWorkbookDelete.size() > 0, 'Workbook records could not be found.');

      List<AH_UDC_Workbook__c> lstWorkbookUndelete = [SELECT Id, Name, OwnerId
                                                      FROM AH_UDC_Workbook__c
                                                      WHERE Name = 'TestUnDelete'];
      System.assert(lstWorkbookUndelete.size() > 0, 'Workbook records could not be found.');

      List<sObject> records = new List<sObject> ();
      records.add(new AH_UDC_Workbook__Share(ParentId = lstWorkbook[0].Id, UserOrGroupId = objWorkbookAdminUser[0].Id, AccessLevel = 'Edit')); //update workbook
      records.add(new AH_UDC_Workbook__Share(ParentId = lstWorkbookDelete[0].Id, UserOrGroupId = objWorkbookAdminUser[0].Id, AccessLevel = 'Edit')); //delete workbook
      records.add(new AH_UDC_Workbook__Share(ParentId = lstWorkbookUndelete[0].Id, UserOrGroupId = objWorkbookAdminUser[0].Id, AccessLevel = 'Edit')); //undelte workbook
      insert records;

      Test.startTest();
      System.runAs(objWorkbookAdminUser[0]) {
         testUpdate();
         try {
            // Delete wont work here as this workbooks are shared with Workbook Admin user not own by Workbook admin User
            testDelete();
         }
         catch(DmlException dmlexc) {
            // This is the expected behavior, so no assert here      
         }
         catch(Exception ex) {
            System.assert(false, 'An unexpected exception occurred while executing Delete workbook steps as workbook admin.' + ex.getMessage());
         }

         try {
            // Undelete wont work here as this workbooks are shared with Workbook Admin user not own by Workbook admin user            

            testUndelete();
         }
         catch(DmlException dmlexc) {
            // This is the expected behavior, so no assert here      
         }
         catch(Exception ex) {
            System.assert(false, 'An unexpected exception occurred while executing Un-delete workbook steps as workbook admin.' + ex.getMessage());
         }
      }
      Test.stopTest();
   }

   @isTest
   private static void RunAsUDCSystemAdminUser() {
      //create System admin user with profiles and permission set
      List<User> objSystemAdminUser = [SELECT Id FROM User
                                       WHERE Username = 'TestUDCSystemAdmin@amadeus.com'];
      System.assertEquals(true, objSystemAdminUser[0] != null, 'System Admin user record not found');

      Test.startTest();
      System.runAs(objSystemAdminUser[0]) {

         testInsert();

         testUpdate();

         testDelete();

         testUndelete();
      }
      Test.stopTest();
   }

   @isTest
   private static void TestDeleteAndUnDeleteTriggerForWorkbookSteps() {
      Test.startTest();

      Id WorkbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(WorkbookRecordTypeId), 'Workbook record type not found');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name FROM AH_UDC_Workbook__c WHERE Name = 'Test Workbook 1' AND RecordTypeId = :WorkbookRecordTypeId];
      System.assertEquals(true, lstWorkbook.size() > 0, 'Workbook  Record Not Found');

      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [SELECT Id, Name FROM AH_UDC_WorkbookStep__c WHERE Name = 'WBS1' AND Workbook__c = :lstWorkbook[0].Id];
      System.assertEquals(true, lstWorkbookStep.size() > 0, 'Workbook step Record Not Found');


      //workbook has been created and its owner is workbook admin
      List<AH_UDC_Workbook__c> lstWorkbookAdmin = [SELECT Id, Name FROM AH_UDC_Workbook__c WHERE Name = 'Test Workbook 3' AND RecordTypeId = :WorkbookRecordTypeId];
      System.assertEquals(true, lstWorkbookAdmin.size() > 0, 'Workbook Admin Record Not Found');

      //workbook step has been created and its owner is workbook admin so it allow to delete and undelete 
      List<AH_UDC_WorkbookStep__c> lstWorkbookAdminStep = [SELECT Id, Name FROM AH_UDC_WorkbookStep__c WHERE Name = 'WBS1' AND Workbook__c = :lstWorkbookAdmin[0].Id];
      System.assertEquals(true, lstWorkbookAdminStep.size() > 0, 'Workbook step record not found');

      List<User> lstWorkbookUsers = [SELECT Id, Username
                                     FROM User
                                     WHERE Username = 'TestUDCWorkbookUser@amadeus.com'
                                     AND IsActive = true];
      System.assert(lstWorkbookUsers.size() > 0, 'Workbook User record not found');

      //Check as workbook User
      System.runAs(lstWorkbookUsers[0]) {
         Id deletedId = null;
         try {
            deletedId = lstWorkbookStep[0].Id;
            delete lstWorkbookStep[0];
            System.assert(false, 'UDC Workbook User should not be able to delete the Workbook step');
         }
         catch(DmlException dmlexc) {
            // This is the expected behavior, so no assert here      
         }
         catch(Exception ex) {
            System.assert(false, 'An unexpected exception occurred while deleting workbook step with workbook user.' + ex.getMessage());
         }
      }

      List<User> lstWorkbookAdminUsers = [SELECT Id, Username
                                          FROM User
                                          WHERE Username = 'TestUDCWorkbookAdmin@amadeus.com'
                                          AND IsActive = true];
      System.assert(lstWorkbookAdminUsers.size() > 0, 'Workbook Admin user record not found');

      System.runAs(lstWorkbookAdminUsers[0]) {
         Id deletedId = lstWorkbookAdminStep[0].Id;
         delete lstWorkbookAdminStep[0];

         //Check if workbook step record is deleted or not
         List<AH_UDC_Workbookstep__c> lstDeletedWorkbookStep = [SELECT Id FROM AH_UDC_Workbookstep__c WHERE Id = :deletedId];
         System.assert(lstDeletedWorkbookStep == null || lstDeletedWorkbookStep.size() == 0, 'Owned Workbook step should be deleted by WorkbookAdmin');

         List<AH_UDC_WorkbookStep__c> lstUndeleteWorkbookStep = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Id = :deletedId ALL ROWS];
         undelete lstWorkbookAdminStep[0];

         //Check if workbook step record is unDeleted or not
         List<AH_UDC_WorkbookStep__c> lstUnDeletedWorkbooksStep = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Id = :deletedId];
         System.assertEquals(false, lstUnDeletedWorkbooksStep == null || lstUnDeletedWorkbooksStep.size() == 0, 'Owned Workbook step should be undeleted by Workbook Admin');
      }

      List<User> lstUDCSystemAdminUsers = [SELECT Id, Username
                                           FROM User
                                           WHERE Username = 'TestUDCSystemAdmin@amadeus.com'
                                           AND IsActive = true];
      System.assert(lstUDCSystemAdminUsers.size() > 0, 'UDC System Admin user record is not found');

      System.runAs(lstUDCSystemAdminUsers[0]) {
         Id deletedId = lstWorkbookStep[0].Id;
         delete lstWorkbookStep[0];

         //Check if workbook step record is deleted or not
         List<AH_UDC_WorkbookStep__c> lstDeletedWorkbookSteps = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Id = :deletedId];
         System.assert(lstDeletedWorkbookSteps == null || lstDeletedWorkbookSteps.size() == 0, 'Workbook step should be deleted by UDC System Admin user');

         List<AH_UDC_WorkbookStep__c> lstUndeleteWorkbook = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Id = :deletedId ALL ROWS];
         undelete lstWorkbookStep[0];

         //Check if workbook step record is unDeleted or not
         List<AH_UDC_WorkbookStep__c> lstUnDeletedWorkbooks = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Id = :deletedId];
         System.assertEquals(false, lstUnDeletedWorkbooks == null || lstUnDeletedWorkbooks.size() == 0, 'Workbook should be undeleted by UDC System Admin user');
      }

      Test.stopTest();
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}