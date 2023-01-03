/**
 * Name          : AH_UDC_WorkbookTriggerHelper_Test
 * Created By    : Amadeus Hospitality Services (Sanjay Parmar)
 * Created Date  : 2021-06-14
 * Description   : This is the test class for AH_UDC_WorkbookTriggerHelper
 * Dependencies  : 
 **/
@isTest
private class AH_UDC_WorkbookTriggerHelper_Test {

   @testSetup
   private static void SetupTestData() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<Profile> lstProfiles = new List<Profile> ([SELECT Id FROM Profile WHERE Name = :AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING]);
      System.assertEquals(true, lstProfiles != null && lstProfiles.size() > 0, 'Unable to retrieve the Profile named: ' + AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING);

      Boolean isException = false;
      String errorMessage = '';
      User objWorkbookAdminUser = null;
      try {
         //Insert Workbook Admin user
         objWorkbookAdminUser = AH_UDC_TestData.GetUserObject(null, lstProfiles[0].Id, 'Workbook', 'Admin', 'Mr.', 'admin@workbook.com', 'admin@workbook.com' + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX));
         objWorkbookAdminUser.No_AD_Account_Standard_User__c = true;
         insert objWorkbookAdminUser;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create user - objWorkbookAdminUser : ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      User objUDCSystemAdminUser = null;
      try {
         //Insert UDC System Admin user
         objUDCSystemAdminUser = AH_UDC_TestData.GetUserObject(null, lstProfiles[0].Id, 'UDC', 'SystemAdmin', 'Mr.', 'systemadmin@udc.com', 'systemadmin@udc.com' + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX));
         objUDCSystemAdminUser.No_AD_Account_Standard_User__c = true;
         insert objUDCSystemAdminUser;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create user - objUDCSystemAdminUser : ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      Account objAccount = null;
      try {
         //Insert new Account data
         objAccount = AH_UDC_TestData.GetAccountObject('UDC Test Account 2', 'Hospitality Companies', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave');
         insert objAccount;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Error occurred in creating Account record : ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      NI_Documentation__c objNIDoc = null;
      try {
         objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 8, 30));
         objNIDoc.Account__c = objAccount.Id;
         insert objNIDoc;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Error occurred in creating NI Doc record - objNIDoc : ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      AH_UDC_Workbook__c objWorkbook = null;
      try {
         //Insert Workbook Record
         objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
         //Set OwnerId to provide Workbook delete rights to Workbook Admin User
         objWorkbook.OwnerId = objWorkbookAdminUser.Id;
         insert objWorkbook;
      }
      catch(Exception ex) {
         isException = true;
         errorMessage = ex.GetMessage();
      }
      System.assertEquals(false, isException, 'Error occurred in creating Workbook record  - objWorkbook : ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      NI_Documentation__c objNIDoc2 = null;
      try {
         objNIDoc2 = AH_UDC_TestData.GetNIDocObject('Test NI Document 2', Date.newInstance(2021, 8, 30));
         objNIDoc2.Account__c = objAccount.Id;
         insert objNIDoc2;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Error occurred in creating NI Doc record - objNIDoc2 : ' + errorMessage);

      if (isException) {
         isException = false;
         errorMessage = '';
      }
      AH_UDC_Workbook__c objWorkbook2 = null;
      try {
         //Insert Workbook Record
         objWorkbook2 = AH_UDC_TestData.GetWorkbookObject(objNIDoc2.Id, 'Exception Test Workbook', 'Exception Test Workbook Description', 'Central Sales');
         //Set OwnerId to provide Workbook delete rights to Workbook Admin User
         objWorkbook2.OwnerId = objWorkbookAdminUser.Id;
         insert objWorkbook2;
      }
      catch(Exception ex) {
         isException = true;
         errorMessage = ex.GetMessage();
      }
      System.assertEquals(false, isException, 'Error occurred in creating Workbook record - objWorkbook2 : ' + errorMessage);
   }

   @isTest
   private static void TestUpdateTrigger() {
      Test.startTest();
      String WorkbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assertEquals(true, WorkbookSentRecordTypeId != null && WorkbookSentRecordTypeId != '', 'Record type AH_UDC_WorkbookSent not found');

      List<AH_UDC_Workbook__c> lstWorkbooks = new List<AH_UDC_Workbook__c> ([SELECT Id, Name, RelatedTo__c FROM AH_UDC_Workbook__c WHERE RecordTypeId = :WorkbookSentRecordTypeId]);
      System.assertEquals(true, lstWorkbooks != null && lstWorkbooks.size() > 0, 'Workbook Sent Record Not Found');

      //Update workbook sent status to execute trigger
      lstWorkbooks[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
      update lstWorkbooks[0];

      //Check if the field AH_UDC_WorkbookLocked__c is updated to true or not
      NI_Documentation__c objNIDoc = [SELECT Id, AH_UDC_WorkbookLocked__c FROM NI_Documentation__c WHERE Id = :lstWorkbooks[0].RelatedTo__c];
      System.assertEquals(true, objNIDoc != null, 'NI Doc Record of the Workbook Sent Record (' + lstWorkbooks[0].Name + ') Not Found');
      System.assertEquals(true, objNIDoc.AH_UDC_WorkbookLocked__c, 'AH_UDC_WorkbookLocked__c is not set to true');

      //Update workbook sent status to execute trigger
      lstWorkbooks[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_IN_PROGRESS;
      update lstWorkbooks[0];

      //Check if the field AH_UDC_WorkbookLocked__c is updated to false or not
      objNIDoc = [SELECT Id, Name, AH_UDC_WorkbookLocked__c FROM NI_Documentation__c WHERE Id = :lstWorkbooks[0].RelatedTo__c];
      System.assertEquals(true, objNIDoc != null, 'NI Doc Record of the Workbook Sent Record (' + lstWorkbooks[0].Name + ') Not Found');
      System.assertEquals(true, objNIDoc.AH_UDC_WorkbookLocked__c == false, 'AH_UDC_WorkbookLocked__c is not set to false');

      AH_UDC_Workbook__c objWorkbook = [SELECT Id, Name, RelatedTo__c FROM AH_UDC_Workbook__c WHERE RecordTypeId = :WorkbookSentRecordTypeId AND Name = 'Exception Test Workbook'];
      System.assertEquals(true, objWorkbook != null, 'Workbook Sent Record (Exception Test Workbook) Not Found');
      try {
         //Genarete error to get code coverage of catch block
         objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
         update objWorkbook;
      }
      catch(Exception ex) {
         //Ignore forcefully generated error
      }

      //Check if the field AH_UDC_WorkbookLocked__c is updated or not
      objNIDoc = [SELECT Id, AH_UDC_WorkbookLocked__c FROM NI_Documentation__c WHERE Id = :objWorkbook.RelatedTo__c];
      System.assertEquals(true, objNIDoc != null, 'NI Doc of the Workbook Sent Record (Exception Test Workbook) Not Found');
      System.assertEquals(true, objNIDoc.AH_UDC_WorkbookLocked__c == false || objNIDoc.AH_UDC_WorkbookLocked__c == null, 'Error not generated for getting code coverage of catch block');

      Test.stopTest();
   }

   @isTest
   private static void TestDeleteTrigger() {
      Test.startTest();
      TestDeleteFuture();
      Test.stopTest();
   }

   //Created future method to prevent erro: MIXED_DML_OPERATION
   //Error Description: DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa): PermissionSetAssignment, original object: AH_UDC_ConfigurationSetting__c:
   @Future
   private static void TestDeleteFuture() {
      String WorkbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assertEquals(true, WorkbookSentRecordTypeId != null && WorkbookSentRecordTypeId != '', 'Record type AH_UDC_WorkbookSent not found');

      AH_UDC_Workbook__c objWorkbook = [SELECT Id, Name, RelatedTo__c FROM AH_UDC_Workbook__c WHERE RecordTypeId = :WorkbookSentRecordTypeId LIMIT 1];
      System.assertEquals(true, objWorkbook != null, 'Workbook Sent Record Not Found');

      String username = 'admin@workbook.com' + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX);
      User objWorkbookAdminUser = [SELECT Id FROM User WHERE Username = :username];
      System.assertEquals(true, objWorkbookAdminUser != null, 'Workbook Admin User "' + username + '" not found');

      List<PermissionSet> lstPermissionSets = new List<PermissionSet> ([SELECT Id FROM PermissionSet WHERE Name = :AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN]);
      System.assertEquals(true, lstPermissionSets != null && lstPermissionSets.size() > 0, 'Could not get Permission Set Id of AH_UDC_WorkbookAdministrator');

      Boolean isException = false;
      String errorMessage = '';
      PermissionSetAssignment objPermissionSetAssignment = null;
      try {
         //Assign Workbook Admin permission set to the user
         objPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = lstPermissionSets[0].Id, AssigneeId = objWorkbookAdminUser.Id);
         insert objPermissionSetAssignment;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not assign AH_UDC_WorkbookAdministrator permission set to the user : ' + errorMessage);

      System.runAs(objWorkbookAdminUser) {
         Id deletedId = null;
         try {
            deletedId = objWorkbook.Id;
            delete objWorkbook;
         }
         catch(Exception ex) {
            System.assertEquals(true, ex.getMessage().indexOf(Label.AH_UDC_NoAccessRightsDelete) > - 1, 'Error occurred in deleting workbook : ' + ex.getMessage());
         }

         //Check if workbook record is deleted or not
         List<AH_UDC_Workbook__c> lstWorkbooks = new List<AH_UDC_Workbook__c> ([SELECT Id FROM AH_UDC_Workbook__c WHERE Id = :deletedId]);
         System.assertEquals(true, lstWorkbooks != null && lstWorkbooks.size() > 0, 'Workbook has been deleted by a user who does not have a permissionset assigned');
      }

      username = 'systemadmin@udc.com' + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX);
      User objUDCSystemAdminUser = [SELECT Id FROM User WHERE Username = :username];
      System.assertEquals(true, objUDCSystemAdminUser != null, 'System Admin User "' + username + '" not found');

      lstPermissionSets = new List<PermissionSet> ([SELECT Id FROM PermissionSet WHERE Name = :AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN]);
      System.assertEquals(true, lstPermissionSets != null && lstPermissionSets.size() > 0, 'Could not get PermissionSet Id of ' + AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN);
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      objPermissionSetAssignment = null;
      try {
         //Assign UDC System Admin permission set to the user
         objPermissionSetAssignment = new PermissionSetAssignment(PermissionSetId = lstPermissionSets[0].Id, AssigneeId = objUDCSystemAdminUser.Id);
         insert objPermissionSetAssignment;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not assign ' + AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN + ' permissionset to the user : ' + errorMessage);

      System.runAs(objUDCSystemAdminUser) {
         Id deletedId = objWorkbook.Id;
         delete objWorkbook;

         //Check if workbook record is deleted or not
         List<AH_UDC_Workbook__c> lstDeletedWorkbooks = new List<AH_UDC_Workbook__c> ([SELECT Id FROM AH_UDC_Workbook__c WHERE Id = :deletedId]);
         System.assertEquals(true, lstDeletedWorkbooks == null || lstDeletedWorkbooks.size() == 0, 'Workbook not deleted by using UDC System Admin User');
      }
   }
}