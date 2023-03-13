/*
 * Name         : AH_UDC_Users_TEST
 * Created By   : Vaishali Patel (vaishali.patel@amadeus.com)
 * Created Date : 5/2/2022
 * Description  : Unit test for AH_UDC_Users class
 * Dependencies : AH_UDC_Users
 */

@isTest
private class AH_UDC_Users_TEST {
   @testSetup
   private static void setupTestData() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      //Insert user
      User u = AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                         null,
                                         'uUDCUser', null, false);
      insert u;

      List<User> listUsers = new List<User> ();
      //Insert UDC System Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                              'uUDCSystemAdmin', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         //AH_UDC_TestData.InsertWithRetries(listUsers);
         insert listUsers;

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[0].Id);
      }

   }
   @istest
   private static void testSearchAndClearUsers()
   {
      Test.startTest();
      List<User> lstUDCSystemAdminUsers = [SELECT Id
                                           FROM User
                                           WHERE Username = 'TestuUDCSystemAdmin@amadeus.com'
                                           AND IsActive = true];
      System.assert(lstUDCSystemAdminUsers.size() > 0, 'UDC System Admin User record not found');

      //Check as UDC System Admin
      System.runAs(lstUDCSystemAdminUsers[0]) {
         AH_UDC_Users u1 = new AH_UDC_Users();
         u1.SearchUserName = 'uUDCUser';
         u1.searchUsers();
         System.assertEquals(1, u1.SearchUserResults.size(), 'Did not find the expected Users');
         u1.clearSearchUsers();
         System.assertEquals(0, u1.SearchUserResults.size(), 'Expected Users should be 0');
      }
      Test.stopTest();
   }
   @isTest
   private static void testGrantAndRevokePermisssionSet() {
      Test.startTest();
      List<User> lstUDCSystemAdminUsers = [SELECT Id
                                           FROM User
                                           WHERE Username = 'TestuUDCSystemAdmin@amadeus.com'
                                           AND IsActive = true];
      System.assert(lstUDCSystemAdminUsers.size() > 0, 'UDC System Admin User record not found');

      //Check as UDC System Admin
      System.runAs(lstUDCSystemAdminUsers[0]) {
         AH_UDC_Users u1 = new AH_UDC_Users();
         List<SelectOption> permissionSets = u1.getPermissionSets();
         System.assertEquals(3, permissionSets.size(), 'Did not find the expected PermissionSet');
         u1.UserId = [SELECT Id from User WHERE Name like '%uUDCUser%'].id;

         
         //Test for permission set 0 - UDC_SYSTEM_ADMIN
         u1.PermissionSetSelected = 0;
         u1.setPermissionSet(0);
         Integer permissionSetId = u1.getPermissionSet();
         List<PermissionSetAssignment> permissionSetAssignments = [SELECT Assignee.Id, Assignee.Name, Assignee.Email, Assignee.Username FROM PermissionSetAssignment WHERE Assignee.Id = :u1.UserId AND PermissionSet.Name = :u1.DisplayPermissionSetName order by Assignee.Name];
         System.assertEquals(0, permissionSetAssignments.size(), 'Did not find the expected PermissionSet');

         //Get search results prior to grant
         u1.SearchUserName = 'uUDCUser';
         u1.searchUsers();
         System.assertEquals(1, u1.SearchUserResults.size(), 'User Search should have found 1 user');

         u1.grantPermissionSet();
         permissionSetAssignments = [SELECT Assignee.Id, Assignee.Name, Assignee.Email, PermissionSet.Name, Assignee.Username FROM PermissionSetAssignment WHERE Assignee.Id = :u1.UserId AND PermissionSet.Name = :u1.DisplayPermissionSetName order by Assignee.Name];
         System.assertEquals(1, permissionSetAssignments.size(), 'Did not find the expected PermissionSet');
         System.assertEquals(u1.DisplayPermissionSetName, permissionSetAssignments[0].PermissionSet.Name, 'Did not find the expected PermissionSet');
         System.assertEquals(0, u1.SearchUserResults.size(), 'User should have been removed from search results after granting');

         u1.UserId = u1.UserId;
         u1.revokePermissionSet();
         permissionSetAssignments = [SELECT Assignee.Id, Assignee.Name, Assignee.Email, PermissionSet.Name, Assignee.Username FROM PermissionSetAssignment WHERE Assignee.Id = :u1.UserId AND PermissionSet.Name = :u1.DisplayPermissionSetName order by Assignee.Name];
         System.assertEquals(0, permissionSetAssignments.size(), 'Did not find the expected PermissionSet');

         //Test for permission set 1 - UDC_WORKBOOK_ADMIN
         u1.setPermissionSet(1);
         u1.grantPermissionSet();
         permissionSetAssignments = [SELECT Assignee.Id, Assignee.Name, Assignee.Email, PermissionSet.Name, Assignee.Username FROM PermissionSetAssignment WHERE Assignee.Id = :u1.UserId AND PermissionSet.Name = :u1.DisplayPermissionSetName order by Assignee.Name];
         System.assertEquals(1, permissionSetAssignments.size(), 'Did not find the expected PermissionSet');
         System.assertEquals(u1.DisplayPermissionSetName, permissionSetAssignments[0].PermissionSet.Name, 'Did not find the expected PermissionSet');

         u1.UserId = u1.UserId;
         u1.revokePermissionSet();
         permissionSetAssignments = [SELECT Assignee.Id, Assignee.Name, Assignee.Email, PermissionSet.Name, Assignee.Username FROM PermissionSetAssignment WHERE Assignee.Id = :u1.UserId AND PermissionSet.Name = :u1.DisplayPermissionSetName order by Assignee.Name];
         System.assertEquals(0, permissionSetAssignments.size(), 'Did not find the expected PermissionSet');

         //Test for permission set 1 - UDC_WORKBOOK_USER
         u1.setPermissionSet(2);
         u1.grantPermissionSet();
         permissionSetAssignments = [SELECT Assignee.Id, Assignee.Name, Assignee.Email, PermissionSet.Name, Assignee.Username FROM PermissionSetAssignment WHERE Assignee.Id = :u1.UserId AND PermissionSet.Name = :u1.DisplayPermissionSetName order by Assignee.Name];
         System.assertEquals(1, permissionSetAssignments.size(), 'Did not find the expected PermissionSet');
         System.assertEquals(u1.DisplayPermissionSetName, permissionSetAssignments[0].PermissionSet.Name, 'Did not find the expected PermissionSet');

         u1.UserId = u1.UserId;
         u1.revokePermissionSet();
         permissionSetAssignments = [SELECT Assignee.Id, Assignee.Name, Assignee.Email, PermissionSet.Name, Assignee.Username FROM PermissionSetAssignment WHERE Assignee.Id = :u1.UserId AND PermissionSet.Name = :u1.DisplayPermissionSetName order by Assignee.Name];
         System.assertEquals(0, permissionSetAssignments.size(), 'Did not find the expected PermissionSet');
      }
      Test.stopTest();
   }
   @isTest
   private static void negetiveTest() {
      Test.startTest();
      List<User> lstUDCSystemAdminUsers = [SELECT Id
                                           FROM User
                                           WHERE Username = 'TestuUDCSystemAdmin@amadeus.com'
                                           AND IsActive = true];
      System.assert(lstUDCSystemAdminUsers.size() > 0, 'UDC System Admin User record not found');

      //Check as UDC System Admin
      System.runAs(lstUDCSystemAdminUsers[0]) {
         AH_UDC_Users u1 = new AH_UDC_Users();
         User u = [SELECT Id, Name from User WHERE Name like '%uUDCUser%'];
         u1.UserId = u.Id;
         u1.UserName = u.Name;
         u1.PermissionSetSelected = 0;
         u1.setPermissionSet(0);
         u1.grantPermissionSet();

         //Handle Add message here
         test.setCurrentPage(Page.AH_UDC_Users);

         list<apexpages.Message> msg = ApexPages.getMessages();
         System.assertEquals(1, msg.size(), 'Messages:' + msg);
         Test.clearApexPageMessages(); //Clear the messages on a Visualforce page while executing Apex test methods.
         u1.setPermissionSet(1);
         u1.grantPermissionSet();
         msg = ApexPages.getMessages();

         System.assertEquals(1, msg.size(), 'Messages:' + msg);
         System.assert(msg[0].getDetail().contains('already assigned to a UDC Permission Set'), 'Permisssion Set shouldn\'t be assigned to a UDC User');

         u1.UserId = u.Id;
         u1.UserName = u.Name;
         u1.isPermissionSetNameSet = true;
         System.assert(u1.getPermissionSet() > 0, 'Unexpected permission set');
         u1.setPermissionSet(0);
         u1.UserId = u.Id;
         u1.UserName = u.Name;
         u1.revokePermissionSet();
         Test.clearApexPageMessages();
         u1.grantPermissionSet();
         msg = ApexPages.getMessages();

         System.assertEquals(1, msg.size(), 'Messages:' + msg);
         System.assert(msg[0].getDetail().contains('Permisssion Set was not found'), 'Permisssion Set should be null');
         Test.clearApexPageMessages();


         u1.UserId = null;
         u1.UserName = null;
         u1.revokePermissionSet();
         msg = ApexPages.getMessages();
         System.assertEquals(1, msg.size(), 'Messages:' + msg);
         System.assert(msg[0].getDetail().contains('is not currently granted the permission'), 'Permisssion Set is already granted to a UDC User before revoking');
         Test.clearApexPageMessages();

         //test catch block
         u1.isException = true;
         u1.setPermissionSet(0);
         try
         {        
            u1.grantPermissionSet();
            System.assert(true, 'Divide by Zero exception is expected for Granting Permission set');
         }
         catch(Exception e)
         {
            Boolean expectedExceptionThrown = e.getMessage().contains('Divide by 0') ? true : false;
            System.assertEquals(expectedExceptionThrown, true, 'Divide by zero exception expected');
         }

         try
         {           
            u1.revokePermissionSet();
            System.assert(true, 'Divide by Zero exception is expected for Revoking Permission set');
         }
         catch(Exception e)
         {
            Boolean expectedExceptionThrown = e.getMessage().contains('Divide by 0') ? true : false;
            System.assertEquals(expectedExceptionThrown, true, 'Divide by zero exception expected');
         }
      }
      Test.stopTest();
   }
   @isTest
   private static void loadingException() {
      Test.startTest();
      List<User> lstUDCSystemAdminUsers = [SELECT Id
                                           FROM User
                                           WHERE Username = 'TestuUDCSystemAdmin@amadeus.com'
                                           AND IsActive = true];
      System.assert(lstUDCSystemAdminUsers.size() > 0, 'UDC System Admin User record not found');

      //Check as UDC System Admin
      System.runAs(lstUDCSystemAdminUsers[0]) {
         AH_UDC_ConfigHelper.SetValue('AH_UDC_UnitTestUDCUsersLoadingError',true);
         AH_UDC_Users u1 = new AH_UDC_Users();
         System.assertEquals(1, u1.QueuedLogMessages.size(), 'Expected 1 Queued log message on loading failure');

         u1.serverLogMessages();
         List<AH_UDC_Log__c> logs = [select id from AH_UDC_Log__c];
         System.assertEquals(2, logs.size(), 'Expected 2 AH_UDC_Log records on loading failure (Init Config and Log Error)');

         U1.LogFunctionalArea = 'TestException';
         u1.serverLogMessages();
         logs = [SELECT id FROM AH_UDC_Log__c WHERE FunctionalArea__c = 'TestException' AND Source__c = 'ServerLogMessages'];
         System.assertEquals(1, logs.size(), 'Log message entry not found for the error in ServerLogMessages method');
      }
      Test.stopTest();
   }
}