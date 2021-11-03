/**
 * Name          : AH_UDC_WorkbookStepTriggerHelper_Test
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-04-20
 * Description   : This class is a test class for AH_UDC_WorkbookStepTriggerHelper
 * Dependencies  : AH_UDC_WorkbookStepTriggerHelper
 **/

@isTest
private class AH_UDC_WorkbookStepTriggerHelper_Test {
   @testSetup
   private static void setupTestData() {
      AH_UDC_InitializationHelper.Initialize('TestClass');
      //Prevent error : System.LimitException: Too many SOQL queries: 101
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      List<Profile> lstProfiles = new List<Profile> ([SELECT Id FROM Profile WHERE Name = :AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING]);
      System.assertEquals(true, lstProfiles != null && lstProfiles.size() > 0, 'Could not get profile Id of \'' + AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING + '\'');

      User objWorkbookAdminUser = null;
      AH_UDC_WorkbookStep__c objWorkbookStep = null;
      User objUDCSystemAdminUser = null;
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

      //Insert Workbook Admin user
      objWorkbookAdminUser = AH_UDC_TestData.GetUserObject(null, lstProfiles[0].Id, 'Workbook', 'Admin', 'Mr.', 'admin@workbook.com', 'admin@workbook.com.ahcc');
      objWorkbookAdminUser.No_AD_Account_Standard_User__c = true;
      insert objWorkbookAdminUser;

      //Insert UDC System Admin user
      objUDCSystemAdminUser = AH_UDC_TestData.GetUserObject(null, lstProfiles[0].Id, 'UDC', 'SystemAdmin', 'Mr.', 'systemadmin@udc.com', 'systemadmin@udc.com.ahcc');
      objUDCSystemAdminUser.No_AD_Account_Standard_User__c = true;
      insert objUDCSystemAdminUser;

      //Insert new Account data 		
      objAccount = AH_UDC_TestData.GetAccountObject('UDC Test Account 2', 'Hospitality Companies', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave');
      insert objAccount;

      objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 8, 30));
      objNIDoc.Account__c = objAccount.Id;
      insert objNIDoc;

      //Insert Workbook Record
      objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      //Set OwnerId to provide Workbook Step delete rights to Workbook Admin User
      objWorkbook.OwnerId = objWorkbookAdminUser.Id;
      insert objWorkbook;

      //Insert Workbook Step Record for Delete
      objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Workbook Step');
      objWorkbookStep.URL__c = 'https://www.google.com/';
      insert objWorkbookStep;

      //Create Form
      AH_UDC_Form__c form = new AH_UDC_Form__c(Name = 'TestForm1', FormAssemblyId__c = '123');
      insert form;

      Id wbRTId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_Workbook').getRecordTypeId();
      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();

      //Test Update Data Setup
      //Insert Workbook 
      AH_UDC_Workbook__c wb1 = new AH_UDC_Workbook__c(Name = 'Test11', RecordtypeId = wbRTId, SecurityCode__c = '4a1d7cd6-e80a-4561-975e-7229655ed41f3758b38b-75f0-416d-872e-1205b8cbaaa7');
      wb1.Product__c = pickListEntry[0].getLabel();
      insert wb1;

      AH_UDC_WorkbookStep__c wbs21 = new AH_UDC_WorkbookStep__c(Name = 'WBS21', RecordtypeId = wbsRTId, Workbook__c = wb1.id, URL__c = 'www.googlese1.com');
      insert wbs21;

      AH_UDC_WorkbookStep__c wbs31 = new AH_UDC_WorkbookStep__c(Name = 'WBS31', RecordtypeId = wbsRTId, Workbook__c = wb1.id, URL__c = 'www.googlese.com');
      insert wbs31;

      AH_UDC_WorkbookStep__c wbs41 = new AH_UDC_WorkbookStep__c(Name = 'WBS41', RecordtypeId = wbsRTId, Workbook__c = wb1.id, form__c = form.id);
      wbs41.Prerequisite_Step__c = wbs21.Id;
      insert wbs41;
      //END Test Update

      //Test Delete Setup Data
      //Insert Workbook
      AH_UDC_Workbook__c wbDelete = new AH_UDC_Workbook__c(Name = 'TestDelete', RecordtypeId = wbRTId, SecurityCode__c = '4a1d7cd6-e80a-4561-975e-7229655ed41f3758b38b-75f0-416d-872e-1205b8cbaaa1');
      wbDelete.Product__c = pickListEntry[0].getLabel();
      insert wbDelete;

      AH_UDC_WorkbookStep__c wbs2 = new AH_UDC_WorkbookStep__c(Name = 'WBS2', RecordtypeId = wbsRTId, Workbook__c = wbDelete.id, URL__c = 'www.test1.com');
      insert wbs2;

      AH_UDC_WorkbookStep__c wbs3 = new AH_UDC_WorkbookStep__c(Name = 'WBS3', RecordtypeId = wbsRTId, Workbook__c = wbDelete.id, form__c = form.id);
      insert wbs3;

      AH_UDC_WorkbookStep__c wbs4 = new AH_UDC_WorkbookStep__c(Name = 'WBS4', RecordtypeId = wbsRTId, Workbook__c = wbDelete.id, URL__c = 'www.test.com');
      wbs4.Prerequisite_Step__c = wbs2.Id;
      insert wbs4;
      //END Test Delete

      //Test UnDelete Setup Data
      AH_UDC_Workbook__c wbUndelete = new AH_UDC_Workbook__c(Name = 'TestUnDelete', RecordtypeId = wbRTId, SecurityCode__c = '4a1d7cd6-e80a-4561-975e-7229655ed41f3758b38b-75f0-416d-872e-1205b8cbaaa5');
      wbUndelete.Product__c = pickListEntry[0].getLabel();
      insert wbUndelete;

      AH_UDC_WorkbookStep__c wbs10 = new AH_UDC_WorkbookStep__c(Name = 'WBS10', RecordtypeId = wbsRTId, Workbook__c = wbUndelete.id, URL__c = 'www.test.com');
      insert wbs10;

      AH_UDC_WorkbookStep__c wbs11 = new AH_UDC_WorkbookStep__c(Name = 'WBS11', RecordtypeId = wbsRTId, Workbook__c = wbUndelete.id, form__c = form.id);
      wbs11.Prerequisite_Step__c = wbs10.Id;
      insert wbs11;
      //END Test UnDelete Setup Data

      //Test Exception Setup Data
      AH_UDC_Workbook__c wbException = new AH_UDC_Workbook__c(Name = 'TestExc', RecordtypeId = wbRTId, SecurityCode__c = '4a1d7cd6-e80a-4561-975e-7229655ed41f3758b38b-75f0-416d-872e-1205b8cbaaa2');
      wbException.Product__c = pickListEntry[0].getLabel();
      insert wbException;
      //END Test Exception Setup Data
   }

   @isTest
   private static void testUpdate() {
      Test.startTest();

      List<AH_UDC_Workbook__c> workbookDetail = [select id, name from AH_UDC_Workbook__c WHERE Name = 'Test11'];
      System.assertEquals(1, workbookDetail.size(), 'Expected 1 Workbook.');

      List<AH_UDC_WorkbookStep__c> workbookSteps = [select id, name, sortorder__c from AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].id order by SortOrder__c];
      System.assertEquals(3, workbookSteps.size(), 'Expected 3 Workbook Steps');

      List<AH_UDC_WorkbookStep__c> workbookStep21 = [select id, name, sortorder__c, Prerequisite_Step__c from AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].id AND Name = 'WBS21'];
      System.assertEquals(1, workbookStep21.size(), 'Expected 1 Workbook Steps');

      List<AH_UDC_WorkbookStep__c> workbookStep31 = [select id, name, sortorder__c, Prerequisite_Step__c from AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].id AND Name = 'WBS31'];
      System.assertEquals(1, workbookStep31.size(), 'Expected 1 Workbook Steps');

      List<AH_UDC_WorkbookStep__c> workbookStep41 = [select id, name, sortorder__c, Prerequisite_Step__c from AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].id AND Name = 'WBS41'];
      System.assertEquals(1, workbookStep41.size(), 'Expected 1 Workbook Steps');

      AH_UDC_WorkbookStep__c[] workstep1 = [select id, Enabled__c, SortOrder__c, Prerequisite_Step__c from AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].id AND Id = :workbookStep31[0].id];
      workstep1[0].Enabled__c = false;
      workstep1[0].SortOrder__c = 1;
      workstep1[0].Prerequisite_Step__c = workbookStep21[0].Id;
      update workstep1;
      System.assertEquals(true, workstep1[0].Prerequisite_Step__c != null, 'updated Sucessfully');
      System.assertEquals(false, workstep1[0].Enabled__c, 'updated Sucessfully');

      AH_UDC_WorkbookStep__c[] workstep2 = [select id, Enabled__c, SortOrder__c, Prerequisite_Step__c from AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].id AND Id = :workbookStep41[0].id];
      workstep2[0].Enabled__c = true;
      workstep2[0].SortOrder__c = 1;
      update workstep2;

      AH_UDC_WorkbookStep__c[] workstep = [select id from AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].id AND Id = :workbookStep31[0].id];
      Test.stopTest();

   }

   @isTest
   private static void testDelete() {
      Test.startTest();
      List<AH_UDC_Workbook__c> workbookDetail = [select id, name from AH_UDC_Workbook__c WHERE Name = 'TestDelete'];
      System.assertEquals(1, workbookDetail.size(), 'Expected 1 Workbook.');

      List<AH_UDC_WorkbookStep__c> workbookSteps = [select id, name, sortorder__c from AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].id order by SortOrder__c];
      System.assertEquals(3, workbookSteps.size(), 'Expected 3 Workbook Steps');

      List<AH_UDC_WorkbookStep__c> workbookStep3 = [select id, name, sortorder__c, Prerequisite_Step__c from AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].id AND Name = 'WBS3'];
      System.assertEquals(1, workbookStep3.size(), 'Expected 1 Workbook Steps');

      List<AH_UDC_WorkbookStep__c> workbookSteps3 = [select id, name, sortorder__c from AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].id AND Id = :workbookStep3[0].Id];
      delete workbookSteps3;

      List<AH_UDC_WorkbookStep__c> workbookSteps1 = [select id, name, sortorder__c from AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].id order by SortOrder__c];
      System.assertEquals(2, workbookSteps1.size(), 'Expected 2 Workbook Steps after deleting 1');

      Test.stopTest();
   }

   @isTest
   private static void testUndelete() {
      Test.startTest();

      List<AH_UDC_Workbook__c> workbookDetail = [select id, name from AH_UDC_Workbook__c WHERE Name = 'TestUnDelete'];
      System.assertEquals(1, workbookDetail.size(), 'Expected 1 Workbook.');

      List<AH_UDC_WorkbookStep__c> workbookStep11 = [select id, name, sortorder__c from AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].id AND Name = 'WBS11'];
      System.assertEquals(1, workbookStep11.size(), 'Expected 1 Workbook Steps');

      id workbookStep11iD = workbookStep11[0].Id;
      delete workbookStep11;

      List<AH_UDC_WorkbookStep__c> workbookSteps12 = [select id, name, sortorder__c from AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].id order by SortOrder__c];
      System.assertEquals(1, workbookSteps12.size(), 'Expected 1 Workbook Steps after deleting 1');

      AH_UDC_WorkbookStep__c[] workstep = [select id from AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].id AND Id = :workbookStep11iD ALL ROWS];

      undelete workbookStep11;

      List<AH_UDC_WorkbookStep__c> workbookSteps2 = [select id, name, sortorder__c from AH_UDC_WorkbookStep__c WHERE Workbook__c = :workbookDetail[0].id order by SortOrder__c];
      System.assertEquals(2, workbookSteps2.size(), 'Expected 2 Workbook Steps after undelete 1');

      Test.stopTest();
   }

   @isTest
   private static void testException() {

      List<AH_UDC_Workbook__c> workbookDetail = [select id, name from AH_UDC_Workbook__c WHERE Name = 'TestExc'];
      System.assertEquals(1, workbookDetail.size(), 'Expected 1 Workbook.');

      List<AH_UDC_Form__c> formDetail = [select id, name from AH_UDC_Form__c WHERE Name = 'TestForm1' AND FormAssemblyId__c = '123'];
      System.assertEquals(1, formDetail.size(), 'Expected 1 form.');

      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();

      Test.startTest();

      Boolean InsertException = false;
      try
      {
         AH_UDC_WorkbookStep__c wbs1 = new AH_UDC_WorkbookStep__c(Name = 'TestException',
                                                                  RecordtypeId = wbsRTId,
                                                                  Workbook__c = workbookDetail[0].id,
                                                                  form__c = formDetail[0].id);
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
   private static void testDeleteWithWorkbookAdminUser() {

      Test.startTest();
      testDeleteFuture();
      Test.stopTest();
   }

   //Created future method to prevent erro: MIXED_DML_OPERATION
   //Error Description: DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa): PermissionSetAssignment, original object: AH_UDC_ConfigurationSetting__c:
   @Future
   private static void testDeleteFuture() {
      User objWorkbookAdminUser = [SELECT Id FROM User WHERE Username = 'admin@workbook.com.ahcc'];
      System.assertEquals(true, objWorkbookAdminUser != null, 'Workbook Admin User Record Not Found');

      List<PermissionSet> lstPermissionSets = new List<PermissionSet> ([SELECT Id FROM PermissionSet WHERE Name = 'AH_UDC_WorkbookAdministrator']);
      System.assertEquals(true, lstPermissionSets != null && lstPermissionSets.size() > 0, 'Could not get Permission Set Id of AH_UDC_WorkbookAdministrator');

      PermissionSetAssignment objPermissionSetAssignment = null;
      //Assign Workbook Admin permission set to the user
      objPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = lstPermissionSets[0].Id, AssigneeId = objWorkbookAdminUser.Id);
      insert objPermissionSetAssignment;

      String WorkbookStepSentRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStepSent').getRecordTypeId();
      System.assertEquals(true, WorkbookStepSentRecordTypeId != null && WorkbookStepSentRecordTypeId != '', 'Record type AH_UDC_WorkbookStepSent not found');

      AH_UDC_WorkbookStep__c objWorkbookStep = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE RecordTypeId = :WorkbookStepSentRecordTypeId LIMIT 1];
      System.assertEquals(true, objWorkbookStep != null, 'Workbook Step Sent Record Not Found');

      System.runAs(objWorkbookAdminUser) {
         Id deletedId = null;
         try {
            deletedId = objWorkbookStep.Id;
            delete objWorkbookStep;
         }
         catch(Exception ex) {
            System.assertEquals(true, ex.getMessage().indexOf(Label.AH_UDC_NoAccessRightsDelete) > - 1, 'Error occured in deleting workbook step : ' + ex.getMessage());
         }

         //Check if workbook step record is deleted or not
         List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ([SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Id = :deletedId]);
         System.assertEquals(true, lstWorkbookSteps != null && lstWorkbookSteps.size() > 0, 'Workbook Step has been deleted by using the user who don\'t have any permission set assigned');
      }

      User objUDCSystemAdminUser = [SELECT Id FROM User WHERE Username = 'systemadmin@udc.com.ahcc'];
      System.assertEquals(true, objUDCSystemAdminUser != null, 'UDC System Admin User Record Not Found');

      lstPermissionSets = new List<PermissionSet> ([SELECT Id FROM PermissionSet WHERE Name = 'AH_UDC_SystemAdministrator']);
      System.assertEquals(true, lstPermissionSets != null && lstPermissionSets.size() > 0, 'Could not get Permission Set Id of AH_UDC_SystemAdministrator');

      objPermissionSetAssignment = null;

      //Assign UDC System Admin permission set to the user
      objPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = lstPermissionSets[0].Id, AssigneeId = objUDCSystemAdminUser.Id);
      insert objPermissionSetAssignment;

      System.runAs(objUDCSystemAdminUser) {
         Id deletedId = objWorkbookStep.Id;
         delete objWorkbookStep;

         //Check if workbook step record is deleted or not
         List<AH_UDC_WorkbookStep__c> lstDeletedWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ([SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Id = :deletedId]);
         System.assertEquals(true, lstDeletedWorkbookSteps == null || lstDeletedWorkbookSteps.size() == 0, 'Workbook Step not deleted by using UDC System Admin User');
      }
   }
}