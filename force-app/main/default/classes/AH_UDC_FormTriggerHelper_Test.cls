/**
 * Name          : AH_UDC_FormTriggerHelper_TEST
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-04-20
 * Description   : This class is a tet class for AH_UDC_FormTriggerHelper
 * Dependencies  : AH_UDC_FormTriggerHelper
 **/

@isTest
private class AH_UDC_FormTriggerHelper_TEST {
   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();

      //Insert Workbook user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                              'FTHUDCWorkbookUser', null, false));
      //Insert Workbook Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                              'FTHUDCWorkbookAdmin', null, false));
      //Insert UDC System Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                              'FTHUDCSystemAdmin', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         //AH_UDC_TestData.InsertWithRetries(listUsers);
         insert listUsers;
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[2].Id);
      }

      User objWorkbookUser = listUsers[0];
      User objWorkbookAdmin = listUsers[1];
      User objUdcSystemAdmin = listUsers[2];
   }

   @isTest
   private static void TestTriggerForUDCSystemAdmin() {
      Test.startTest();

      List<User> lstUDCSystemAdminUsers = [SELECT Id
                                           FROM User
                                           WHERE Username = 'TestFTHUDCSystemAdmin@amadeus.com'
                                           AND IsActive = true];
      System.assert(lstUDCSystemAdminUsers.size() > 0, 'UDC System Admin User record not found');

      //Check as UDC System Admin
      System.runAs(lstUDCSystemAdminUsers[0]) {
         string testPrefix = 'SysA,';

         Id RecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
         AH_UDC_Workbook__c objWorkbook1 = AH_UDC_TestData.GetWorkbookObject(null, testPrefix + 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
         objWorkbook1.RecordTypeId = RecordTypeId;
         insert objWorkbook1;

         AH_UDC_Workbook__c objWorkbook2 = AH_UDC_TestData.GetWorkbookObject(null, testPrefix + 'Test Workbook 2', 'Test Workbook 2 Description', 'Central Sales');
         objWorkbook2.RecordTypeId = RecordTypeId;
         objWorkbook2.OwnerId = lstUDCSystemAdminUsers[0].Id;
         insert objWorkbook2;

         AH_UDC_Form__c objForm = new AH_UDC_Form__c(Name = testPrefix + 'Test Form For Workbook Step', FormAssemblyId__c = '1245123');
         insert objForm;

         AH_UDC_WorkbookStep__c objWorkbookStep = new AH_UDC_WorkbookStep__c(Name = testPrefix + 'WBS21', Form__c = objForm.Id, Workbook__c = objWorkbook1.id);
         insert objWorkbookStep;

         testInsertForms(testPrefix);
         testInsertMultipleForms(testPrefix);
         testUpdateForm(testPrefix);
         testDuplicateException(testPrefix);
         testDuplicateFAIdsException(testPrefix);
         testDuplicateFAIdsExceptionForUndelete(testPrefix);
         testDeleteForm(testPrefix);
         testDeleteFormUsesdbyWBStep(testPrefix);
         testUndeleteForm(testPrefix);
      }

      Test.stopTest();
   }

   //TODO: ROBDEV : Commenting due to SBFull issue
   //@isTest
   //private static void TestTriggerForWorkbookAdmin() {
      //Test.startTest();

      //List<User> lstWorkbookAdminUsers = [SELECT Id
                                          //FROM User
                                          //WHERE Username = 'TestFTHUDCWorkbookAdmin@amadeus.com'
                                          //AND IsActive = true];
      //System.assert(lstWorkbookAdminUsers.size() > 0, 'UDC Workbook Admin record not found');

      ////Check as workbook Admin
      //System.runAs(lstWorkbookAdminUsers[0]) {
         //string testPrefix = 'WBA,';

         //Id RecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
         //AH_UDC_Workbook__c objWorkbook1 = AH_UDC_TestData.GetWorkbookObject(null, testPrefix + 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
         //objWorkbook1.RecordTypeId = RecordTypeId;
         //insert objWorkbook1;

         //AH_UDC_Workbook__c objWorkbook2 = AH_UDC_TestData.GetWorkbookObject(null, testPrefix + 'Test Workbook 2', 'Test Workbook 2 Description', 'Central Sales');
         //objWorkbook2.RecordTypeId = RecordTypeId;
         //objWorkbook2.OwnerId = lstWorkbookAdminUsers[0].Id;
         //insert objWorkbook2;

         //AH_UDC_Form__c objForm = new AH_UDC_Form__c(Name = testPrefix + 'Test Form For Workbook Step', FormAssemblyId__c = '1245123');
         //insert objForm;

         //AH_UDC_WorkbookStep__c objWorkbookStep = new AH_UDC_WorkbookStep__c(Name = testPrefix + 'WBS21', Form__c = objForm.Id, Workbook__c = objWorkbook1.id);
         //insert objWorkbookStep;

         //testInsertForms(testPrefix);
         //testInsertMultipleForms(testPrefix);
         //testUpdateForm(testPrefix);
         //testDuplicateException(testPrefix);
         //testDuplicateFAIdsException(testPrefix);
         //testDuplicateFAIdsExceptionForUndelete(testPrefix);
         //testDeleteStepsForWorkbookAdmin(testPrefix);
      //}

      //Test.stopTest();
   //}

   //@isTest
   //private static void TestTriggerForWorkbookUser() {
      //Test.startTest();

      //List<User> lstWorkbookUsers = [SELECT Id
                                     //FROM User
                                     //WHERE Username = 'TestFTHUDCWorkbookUser@amadeus.com'
                                     //AND IsActive = true];
      //System.assert(lstWorkbookUsers.size() > 0, 'UDC Workbook User record not found');

      ////Check as UDC Workbook User
      //System.runAs(lstWorkbookUsers[0]) {
         //string testPrefix = 'WBA,';

         //Id RecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
         //AH_UDC_Workbook__c objWorkbook1 = AH_UDC_TestData.GetWorkbookObject(null, testPrefix + 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
         //objWorkbook1.RecordTypeId = RecordTypeId;
         //insert objWorkbook1;

         //AH_UDC_Workbook__c objWorkbook2 = AH_UDC_TestData.GetWorkbookObject(null, testPrefix + 'Test Workbook 2', 'Test Workbook 2 Description', 'Central Sales');
         //objWorkbook2.RecordTypeId = RecordTypeId;
         //objWorkbook2.OwnerId = lstWorkbookUsers[0].Id;
         //insert objWorkbook2;

         //AH_UDC_Form__c objForm = new AH_UDC_Form__c(Name = testPrefix + 'Test Form For Workbook Step', FormAssemblyId__c = '1245123');
         //insert objForm;

         //AH_UDC_WorkbookStep__c objWorkbookStep = new AH_UDC_WorkbookStep__c(Name = testPrefix + 'WBS21', Form__c = objForm.Id, Workbook__c = objWorkbook1.id);
         //insert objWorkbookStep;

         //testInsertFormForWorkbookUser(testPrefix);
         //testUpdateFormForWorkbookUser(testPrefix);
      //}

      //Test.stopTest();
   //}

   @isTest
   private static void TestNagativeScenario() {
      Test.startTest();

      AH_UDC_FormTriggerHelper.IsException = true;

      //Execute Insert to fire trigger and log exception
      try {
         AH_UDC_Form__c objForm1 = new AH_UDC_Form__c(Name = 'TestNagativeScenario TestException', FormAssemblyId__c = 'Neg123456');
         insert objForm1;
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_FormTriggerHelper_ExceptionOccurred) > - 1, 'Error occurred in the method TestNagativeScenario. Error: ' + ex.getMessage() + ' at line number ' + ex.getLineNumber());
      }

      Test.stopTest();
   }

   private static void testInsertFormForWorkbookUser(string prefix) {
      Boolean InsertException = false;

      try {
         //Create Form with dupe name
         AH_UDC_Form__c objForm2 = new AH_UDC_Form__c(Name = prefix + 'TestForm1', FormAssemblyId__c = prefix + '456');
         AH_UDC_Security.CreateObject(objForm2);
         System.assert(true, 'Workbook User should not be able to insert Form');
      }
      catch(Exception ex) {
         //Excepted Error
         InsertException = true;
      }
      System.assertEquals(true, InsertException, 'WorkbookUser should not be able to insert form');

   }

   private static void testUpdateFormForWorkbookUser(string prefix) {
      Boolean UpdateException = false;

      try {
         AH_UDC_Form__c objForm = [SELECT Id, Name FROM AH_UDC_Form__c WHERE Name = 'Test Form For Workbook Step' LIMIT 1];
         objForm.name = 'Update Form testUpdateFormForWorkbookUser';
         AH_UDC_Security.UpdateObject(objForm);
      }
      catch(exception exc) {
         UpdateException = true;
      }

      System.assertEquals(true, UpdateException, 'Expected Update Dupe Name Exception');

   }


   private static void testDeleteStepsForWorkbookAdmin(string prefix) {
      string WBName = prefix + 'Test Workbook 2';
      List<AH_UDC_Workbook__c> lstWorkbookForAdmin = [SELECT Id, Name FROM AH_UDC_Workbook__c WHERE Name = :WBName ];
      System.assert(lstWorkbookForAdmin.size() > 0, 'Workbook record not found');

      //Check As Workbook Admin
      AH_UDC_Form__c objFormStepForWorkbookAdmin = new AH_UDC_Form__c(Name = prefix + 'Test Form Workbook Admin For Workbook Step', FormAssemblyId__c = prefix + '12845123');
      insert objFormStepForWorkbookAdmin;

      AH_UDC_WorkbookStep__c workbStepForAdmin = new AH_UDC_WorkbookStep__c(Name = prefix + 'WBS22', Form__c = objFormStepForWorkbookAdmin.Id, Workbook__c = lstWorkbookForAdmin[0].Id);
      insert workbStepForAdmin;

      try {
         delete objFormStepForWorkbookAdmin;
         System.assert(false, 'Workbook Admin should not be able to delete form if form is used in step');
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_FormTriggerDelete_Error) > - 1, 'Form already in use - Error message did not match');
      }
   }

   private static void testInsertForms(string prefix) {

      //Create Form
      AH_UDC_Form__c objForm1 = new AH_UDC_Form__c(Name = prefix + 'TestForm1', FormAssemblyId__c = prefix + '123');
      insert objForm1;

      Boolean InsertException = false;
      try {
         //Create Form with dupe name
         AH_UDC_Form__c objForm2 = new AH_UDC_Form__c(Name = prefix + 'TestForm1', FormAssemblyId__c = prefix + '456');
         insert objForm2;
      }
      catch(exception exc) {
         InsertException = true;
      }
      List<AH_UDC_Form__c> objForms = [SELECT id, name FROM AH_UDC_Form__c where name like :prefix + '%' or name='Test Form For Workbook Step'] ;
      System.assertEquals(true, InsertException, 'Expected Insert Dupe Name Exception');

      AH_UDC_LogHelper.debug('Total Forms inserted in testInsertForms method: ' + objForms.size());
      System.assertEquals(2, objForms.size(), 'Expected 2 Form only'); //one form is created and one is created in TestSetup method
   }

   private static void testDeleteForm(string prefix) {

      AH_UDC_Form__c objForm1 = new AH_UDC_Form__c(Name = prefix + 'TestFormDelete', FormAssemblyId__c = prefix + '123');
      insert objForm1;
      System.assertEquals(1, [SELECT COUNT() FROM AH_UDC_Form__c WHERE Name = :prefix + 'TestFormDelete'], 'Expected 1 Form, name: ' + prefix + 'TestFormDelete ');
      
      delete objForm1;
      System.assertEquals(0, [SELECT COUNT() FROM AH_UDC_Form__c WHERE Name = :prefix + 'TestFormDelete'], 'Expected 0 Form');         
     
   }

   private static void testDeleteFormUsesdbyWBStep(string prefix) {
      string formName= prefix + 'Test Form For Workbook Step';
      List<AH_UDC_Form__c> lstForm = [SELECT Id, Name FROM AH_UDC_Form__c WHERE Name = :formName];
      System.assert(lstForm.size() > 0, 'Expected 1 Form, name: Test Form For Workbook Step ');

      try {
         delete lstForm[0];
         System.assert(false, 'Form already in use - exception should have occurred');         
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_FormTriggerDelete_Error) > - 1, 'Form already in use - Error message did not match');
      }
   }

   private static void testUndeleteForm(string prefix) {

      //Create Form
      AH_UDC_Form__c objForm1 = new AH_UDC_Form__c(Name = prefix + 'TestFormUndelete', FormAssemblyId__c = prefix + '123');
      insert objForm1;
      System.assertEquals(1, [SELECT COUNT() FROM AH_UDC_Form__c WHERE Name = :prefix + 'TestFormUndelete'], 'Expected 1 Form, name: ' + prefix + 'TestFormUndelete ');
      
      delete objForm1;
      System.assertEquals(0, [SELECT COUNT() FROM AH_UDC_Form__c WHERE Name = :prefix + 'TestFormUndelete'], 'Expected 0 Form');

      try {
         undelete objForm1;
         System.assertEquals(1, [SELECT COUNT() FROM AH_UDC_Form__c WHERE Name = :prefix + 'TestFormUndelete'], 'Expected 1 Form, name: TestFormUndeletep ');
      }
      catch(Exception exc) {
         System.assert(exc.getMessage().indexOfIgnoreCase(Label.AH_UDC_DuplicateFormNameError) > - 1, 'Expected duplicate form exception, but a different exception occurred: ' + exc.getMessage());
      }
   }

   private static void testInsertMultipleForms(string prefix) {

      Boolean InsertException = false;
      try {
         List<AH_UDC_Form__c> newForms = new List<AH_UDC_Form__c> ();
         //Create Form
         AH_UDC_Form__c objForm1 = new AH_UDC_Form__c(Name = prefix + 'testInsertMultipleForms Form1', FormAssemblyId__c = prefix + '12300');
         newForms.add(objForm1);

         //Create Form 
         AH_UDC_Form__c objForm2 = new AH_UDC_Form__c(Name = prefix + 'testInsertMultipleForms Form2', FormAssemblyId__c = prefix + '45600');
         newForms.add(objForm2);

         insert newForms;
      }
      catch(exception exc) {
         InsertException = true;
      }

      List<AH_UDC_Form__c> lstForms = [SELECT Id, name FROM AH_UDC_Form__c];
      AH_UDC_LogHelper.debug('Method name: testInsertMultipleSteps, Total Forms after insert opration: ' + lstForms.size());

      System.assertEquals(4, lstForms.size(), 'Expected 4 Forms'); //one is created in TestSetup method, one in insert method and 2 more here
      System.assertEquals(false, InsertException, 'Dupe Name Exception is not generated for Insert');

   }

   private static void testUpdateForm(string prefix) {

      //Create Form
      AH_UDC_Form__c objForm1 = new AH_UDC_Form__c(Name = prefix + 'Test Form For Update operation', FormAssemblyId__c = '1234');
      insert objForm1;

      Boolean UpdateException = false;
      try {
         objForm1.name = prefix + 'Test Form For Workbook Step';
         update objForm1;
      }
      catch(exception exc) {
         UpdateException = true;
      }
      List<AH_UDC_Form__c> forms = [select id, name from AH_UDC_Form__c];
      System.assertEquals(true, UpdateException, 'Expected Update Dupe Name Exception');

   }

   private static void testDuplicateException(string prefix) {
      try {
         //Create Form         
         AH_UDC_Form__c objForm221 = new AH_UDC_Form__c(Name = prefix + 'TestDupeException1', FormAssemblyId__c = prefix + '12399');
         insert objForm221;

         AH_UDC_Form__c objForm232 = new AH_UDC_Form__c(Name = prefix + 'TestDupeException1', FormAssemblyId__c = prefix + '123991');
         insert objForm232;
         System.assert(false, 'A duplicate exception should have occurred');
      }
      catch(exception exc) {
         System.assert(exc.getMessage().indexOfIgnoreCase(Label.AH_UDC_DuplicateFormNameError) > - 1, 'Expected duplicate form exception,, but a different exception occurred: ' + exc.getMessage());
      }
   }

   private static void testDuplicateFAIdsException(string prefix) {
      try {
         //Create Forms   
         Id formAssemblyRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
         List<AH_UDC_Form__c> lstForms = new List<AH_UDC_Form__c> ();
         AH_UDC_Form__c objForm21 = new AH_UDC_Form__c(Name = prefix + 'TestDupeException11', FormAssemblyId__c = prefix + '12398', RecordTypeId = formAssemblyRecordTypeId);
         AH_UDC_Form__c objForm22 = new AH_UDC_Form__c(Name = prefix + 'TestDupeException22', FormAssemblyId__c = prefix + '12398', RecordTypeId = formAssemblyRecordTypeId);

         lstForms.add(objForm21);
         lstForms.add(objForm22);

         insert lstForms;
         System.assert(false, 'Invalid FormAssemblyId exception should have occurred');
      }
      catch(exception exc) {
         System.assert(exc.getMessage().indexOfIgnoreCase(Label.AH_UDC_FormAssemblyIdError) > - 1, 'Expected Invalid FormAssemblyId exception, but a different exception occurred: ' + exc.getMessage());
      }
   }

   private static void testDuplicateFAIdsExceptionForUndelete(string prefix) {
      try {
         //Create Forms   
         Id formAssemblyRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
         List<AH_UDC_Form__c> lstForms = new List<AH_UDC_Form__c> ();
         AH_UDC_Form__c objForm21 = new AH_UDC_Form__c(Name = prefix + 'TestDupeException11', FormAssemblyId__c = prefix + '12398', RecordTypeId = formAssemblyRecordTypeId);
         AH_UDC_Form__c objForm22 = new AH_UDC_Form__c(Name = prefix + 'TestDupeException22', FormAssemblyId__c = prefix + '12399', RecordTypeId = formAssemblyRecordTypeId);

         lstForms.add(objForm21);
         lstForms.add(objForm22);
         insert lstForms;
         System.assertEquals(2, [SELECT COUNT() FROM AH_UDC_Form__c WHERE Name = :prefix + 'TestDupeException11' OR Name = :prefix + 'TestDupeException22' ], 'Expected 2 Form, name: ' + prefix + 'TestDupeException11, ' + prefix + 'TestDupeException22');
         
         delete objForm21;
         System.assertEquals(0, [SELECT COUNT() FROM AH_UDC_Form__c WHERE Name = :prefix + 'TestDupeException11'], 'Expected 0 Form');

         objForm22.FormAssemblyId__c = prefix + '12398';
         update objForm22;
         System.assertEquals(1, [SELECT COUNT() FROM AH_UDC_Form__c WHERE FormAssemblyId__c = :prefix + '12398'], 'Expected 1 Form with FormAssemblyId__c = ' + prefix + '12398');

         undelete objForm21;
         System.assert(false, 'Duplicate FormAssemblyId exception should have occurred');
      }
      catch(exception exc) {
         System.assert(exc.getMessage().indexOfIgnoreCase(Label.AH_UDC_FormAssemblyIdError) > - 1, 'Expected Duplicate FormAssemblyId exception, but a different exception occurred: ' + exc.getMessage());
      }
   }
}