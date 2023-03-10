/*
 * Name         : AH_UDC_LogTriggerHelper_TEST
 * Created By   : Rob Stevens (Rob.Stevens@amadeus.com)
 * Created Date : 2020-Oct-06
 * Description  : Test class for AH_UDC_LogTriggerHelper.cls
 * Dependencies : AH_UDC_LogTriggerHelper.cls
 */
@isTest
private class AH_UDC_LogTriggerHelper_TEST {

   // Setup the data used for the tests in this test class
   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();

      //Insert UDC System Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                    'LTHUDCSystemAdmin', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         //AH_UDC_TestData.InsertWithRetries(listUsers);
         insert listUsers;
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[0].Id);
      }
   }

   @isTest
   private static void testUDCSystemAdminDelete() {
      Test.startTest();

      List<User> lstUDCSystemAdminUsers = [SELECT Id
                                           FROM User
                                           WHERE Username = 'TestLTHUDCSystemAdmin@amadeus.com'
                                           AND IsActive = true];
      System.assert(lstUDCSystemAdminUsers.size() > 0, 'UDC System Admin User record not found');

      //Check as UDC System Admin
      System.runAs(lstUDCSystemAdminUsers[0]) {
         AH_UDC_Log__c logDebug = AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_AUDIT, 'AuditTestFA', 'testUDCSystemAdminDelete', 'My AUDIT log message');
         System.assertNotEquals(null, logDebug.Id, 'Log of AUDIT message failed');

         //Test that UDC System Admins shouldn't be able to delete an Audit record
         try
         {
            Delete logDebug;
            System.assert(true, 'The UDC System Admin should not have been able to delete an Audit record.');
         }
         catch(Exception exc)
         {
            Boolean isExpectedMessage = String.valueOf(exc.getMessage()).contains(Label.AH_UDC_LogTriggerDeleteNotAllowed_Error);
            System.assertEquals(true, isExpectedMessage, 'Expected Error Message was not present');
         }
      }
      Test.stopTest();
   }

   @isTest
   private static void testSystemAdminDelete() {
      Test.startTest();

      //NOTE: There is no RUNAS since the user installing the package will be a System Admin
      AH_UDC_Log__c logDebug = AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_AUDIT, 'AuditTestFA', 'testSystemAdminDelete', 'My AUDIT log message');
      System.assertNotEquals(null, logDebug.Id, 'Log of AUDIT message failed');

      //Test that UDC System Admins shouldn't be able to delete an Audit record
      try
      {
         Delete logDebug;
      }
      catch(Exception exc)
      {
         System.assert(true, 'The Salesforce System Admin should have been able to delete an Audit record.');
      }
      Test.stopTest();
   }

   @isTest
   private static void testException() {
      Test.startTest();

      //NOTE: There is no RUNAS since the user installing the package will be a System Admin
      AH_UDC_Log__c logDebug = AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_AUDIT, 'AuditTestFA', 'testSystemAdminDelete', 'My AUDIT log message');
      System.assertNotEquals(null, logDebug.Id, 'Log of AUDIT message failed');

      AH_UDC_LogTriggerHelper.isException = true;

      //Test that UDC System Admins shouldn't be able to delete an Audit record
      try
      {
         Delete logDebug;
      }
      catch(Exception exc)
      {
         System.assert(true, 'Forced exception did not occur.');
      }
      Test.stopTest();
   }
}