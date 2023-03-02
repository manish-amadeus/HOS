/***********************************************************************************************
  Name            : AH_UDC_Users
  Author          : Rob.Stevens@Amadeus.com
  Created Date    : 2022-04-27
  Description     : Controller class for AH_UDC_Users page
 ************************************************************************************************/
public without sharing class AH_UDC_Users {
   @TestVisible private string LogFunctionalArea = 'UDC Users'; //This is used for AH_UDC_Log Entries being written on this page

   //This is used to store AH_UDC_Log records that have been queued
   public List<AH_UDC_log__c> QueuedLogMessages { get; set; } { QueuedLogMessages = new List<AH_UDC_Log__c> (); }

   public List<PermissionSetAssignment> PermissionSetAssignments { get; set; } { PermissionSetAssignments = new List<PermissionSetAssignment> (); }
   public Integer PermissionSetSelected = 0;
   Public String DisplayPermissionSetName { get; set; } { DisplayPermissionSetName = ''; }
   public String SearchUserName { get; set; } { SearchUserName = ''; }
   public String UserId { get; set; } { UserId = null; }
   public String UserName { get; set; } { UserId = null; }
   public List<User> SearchUserResults { get; set; } { SearchUserResults = new List<User> (); }
   public Boolean ShowUserSearchResults { get; set; } { ShowUserSearchResults = false; }
   @TestVisible private Boolean isPermissionSetNameSet = false;
   @TestVisible public Boolean isException { get; set; } {isException= false;}

   public AH_UDC_Users() {
      AH_UDC_LogHelper.QueueLogs = true;
      try
      {
         //Unit Test Force Exception
<<<<<<< HEAD
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestUDCUsersLoadingError', FALSE)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'UDC Users Load'));
=======
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestUDCUsersLoadingError', FALSE, true)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'UDC Users Load'));
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a

         GetPermissionSetAssignments();
      }
      catch(Exception exc) {
         isException = true;
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'An error occurred loading the User page'));
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'AH_UDC_Users',
                              'An error occurred loading the User page',
                              exc, null, null);
      }
      finally {
         //Write any Queued Log Messages to controller property
         QueuedLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   private void GetPermissionSetAssignments()
   {
      string permissionSetName = AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN;
      if (PermissionSetSelected == 1)
      permissionSetName = AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN;
      else if (PermissionSetSelected == 2)
      permissionSetName = AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER;

      DisplayPermissionSetName = permissionSetName;
      PermissionSetAssignments = [SELECT Assignee.Id, Assignee.Name, Assignee.Email, Assignee.Username FROM PermissionSetAssignment WHERE PermissionSet.Name = :String.escapeSingleQuotes(permissionSetName) order by Assignee.Name];
   }

   public List<SelectOption> getPermissionSets() {
      List<SelectOption> permissionSets = new List<SelectOption> ();
      permissionSets.add(new SelectOption('0', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN));
      permissionSets.add(new SelectOption('1', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN));
      permissionSets.add(new SelectOption('2', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER));
      return permissionSets;
   }

   public void setPermissionSet(Integer permissionSet) {
      this.PermissionSetSelected = permissionSet;
      GetPermissionSetAssignments();
   }

   public Integer getPermissionSet() {
      return PermissionSetSelected;
   }

   public void revokePermissionSet() {
      string permissionSetName = AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN;
      if (PermissionSetSelected == 1) {
         permissionSetName = AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN;
      }
      else if (PermissionSetSelected == 2) {
         permissionSetName = AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER;
      }

      AH_UDC_LogHelper.QueueLogs = true;
      try
      {
         System.Debug('$$$RemovePermissionSet UserId: ' + UserId);
         if (Test.isRunningTest() && isException == true) Integer i = 1 / 0;

         //Unit Test Force Exception
<<<<<<< HEAD
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestUDCUsersRevokeError', FALSE)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'UDC Users Revoke'));
=======
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestUDCUsersRevokeError', FALSE, true)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'UDC Users Revoke'));
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a

         //Check if User has the permission that will be revoked
         List<PermissionSetAssignment> existingForUser = [SELECT id
                                                          FROM PermissionSetAssignment
                                                          WHERE Assignee.id = :UserId
                                                          and PermissionSet.Name = :permissionSetName];
         if (existingForUser.size() != 1) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, String.valueOf(UserName) + ' is not currently granted the permission ' + permissionSetName));
            return;
         }
         AH_UDC_SystemContext.DeleteObject(existingForUser[0]);
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, String.valueOf(UserName) + ' has been revoked from the permission set ' + permissionSetName));

         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_AUDIT,
                              LogFunctionalArea,
                              'RevokePermissionSet',
                              String.valueOf(UserName) + ' has been revoked from the permission set ' + permissionSetName,
                              null, UserId, 'User');

         GetPermissionSetAssignments();
      }
      catch(Exception exc)
      {
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Revoking ' + String.valueOf(UserName) + ' from the permission set ' + permissionSetName + ' failed. ' + exc.getMessage()));
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'revokePermissionSet',
                              'Exception occurred revoking ' + String.valueOf(UserName) + ' from permission set ' + permissionSetName,
                              exc, null, null);
      }
      finally {
         QueuedLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
      }
   }

   public void grantPermissionSet() {
      string permissionSetName = AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN;
      if (PermissionSetSelected == 1) {
         permissionSetName = AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN;
      }
      else if (PermissionSetSelected == 2) {
         permissionSetName = AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER;
      }
      AH_UDC_LogHelper.QueueLogs = true;
      try
      {
         System.Debug('$$$GrantPermissionSet UserId: ' + UserId);
         if (Test.isRunningTest() && isException == true) Integer i = 1 / 0;

         //Unit Test Force Exception
<<<<<<< HEAD
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestUDCUsersGrantError', FALSE)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'UDC Users Grant'));
=======
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestUDCUsersGrantError', FALSE, true)) throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'UDC Users Grant'));
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a

         //Check if User is already assigned to any UDC Permission Set; if so show a message that they must be removed first
         List<PermissionSetAssignment> existingForUser = [SELECT Assignee.id
                                                          FROM PermissionSetAssignment
                                                          WHERE Assignee.id = :UserId
                                                          and(PermissionSet.Name = :AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN
                                                              OR PermissionSet.Name = :AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN
                                                              OR PermissionSet.Name = :AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER)];
         if (existingForUser.size() > 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, String.valueOf(UserName) + ' is already assigned to a UDC Permission Set; please remove others first before granting this one.'));
            return;
         }

         if (Test.isRunningTest() && isPermissionSetNameSet == true) permissionSetName = null;
         List<PermissionSet> TargetedPermissionSet = [SELECT id from PermissionSet where Name = :permissionSetName];
         if (TargetedPermissionSet.size() != 1) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Granting ' + String.valueOf(UserName) + ' the permission set ' + permissionSetName + '. Permisssion Set was not found'));
            return;
         }
         PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = TargetedPermissionSet[0].id, AssigneeId = UserId);
         AH_UDC_SystemContext.UpsertObject(psa);
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, String.valueOf(UserName) + ' has been granted the permission set ' + permissionSetName));

         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_AUDIT,
                              LogFunctionalArea,
                              'grantPermissionSet',
                              String.valueOf(UserName) + ' has been granted the permission set ' + permissionSetName,
                              null, UserId, 'User');

         GetPermissionSetAssignments();
         For(Integer iUser=0; iUser < SearchUserResults.size(); iUser++)
         {
            if(SearchUserResults[iUser].Id == UserId){
               SearchUserResults.remove(iUser);
               break;
            }
         }
      }
      catch(Exception exc)
      {
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Granting ' + String.valueOf(UserName) + ' the permission set ' + permissionSetName + ' failed. ' + exc.getMessage()));
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'grantPermissionSet',
                              'Exception occurred granting ' + String.valueOf(UserName) + ' the permission set ' + permissionSetName,
                              exc, null, null);
      }
      finally {
         QueuedLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
      }
   }

   public void searchUsers() {
      System.Debug('$$$searchUsers SearchUserName: ' + SearchUserName);
      string querySerach = '%' + SearchUserName + '%';
      SearchUserResults = [select id, name, email, username from User where IsActive = true and UserType='Standard' and name like :String.escapeSingleQuotes(querySerach) Limit 200];
      ShowUserSearchResults = SearchUserResults.size() > 0;
   }

   public void clearSearchUsers() {
      SearchUserResults = new List<User> ();
      ShowUserSearchResults = false;
      SearchUserName = '';
   }

   //This method is used by a client side actionfunction to log queued AH_UDC_Log entries
   public void serverLogMessages()
   {
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverLogMessages');
      try
      {
         if (QueuedLogMessages != null && QueuedLogMessages.size() > 0)
         {
            AH_UDC_Security.UpsertObjects(QueuedLogMessages);
         }
         QueuedLogMessages = new List<AH_UDC_Log__c> ();

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.serverLogMessages - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'serverLogMessages',
                              'An exception occurred logging AH_UDC_Log entries',
                              exc, null, null);
      }
   }
}