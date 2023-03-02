/*
 * Name:          : AH_UDC_Security_TEST.cls
 * Created By     : George Tasker (george.tasker@amadeus.com)
 * Created Date   : 
 * Description:   : Contains test methods AH_UDC_Security.cls
 * Dependencies   : AH_UDC_AH_UDC_Security.cls, AH_UDC_DescribeCache.cls
 */
@isTest
public class AH_UDC_Security_TEST {
   @TestSetup
   private static void setup() {
      AH_UDC_InitializationHelper.Initialize('All');

      List<User> listUsers = new List<User> ();

      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                    'SecurityUDCSysAdmin', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[0].Id);
      }
   }

   @isTest
   static void isTest_Security() {
<<<<<<< HEAD

=======
      Test.startTest();
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
      List<User> lstUser = [Select Id From User Where Email like '%SecurityUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         NI_Documentation__c niDoc = AH_UDC_TestData.GetNIDocObject('MyNIDoc', Date.today().addMonths(1));
         AH_UDC_SystemContext.CreateObject(niDoc); //To resolve error: Insufficient level of access for NI_Documentation__c.AH_UDC_ChatterWorkbookAccessed__c

         List<AH_UDC_Workbook__c> allWorkbooksA = new List<AH_UDC_Workbook__c> ();
         List<AH_UDC_Workbook__c> allWorkbooksB = new List<AH_UDC_Workbook__c> ();

         Id RecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();

         for (Integer i = 0; i< 4; i++) {
            allWorkbooksA.add(AH_UDC_TestData.GetWorkbookObject(niDoc.Id, 'TestWorkbook-A' + i, 'TestWorkbook-A Description', 'Central Sales', RecordTypeId));
            allWorkbooksB.add(AH_UDC_TestData.GetWorkbookObject(niDoc.Id, 'TestWorkbook-B' + i, 'TestWorkbook-B Description', 'Central Sales', RecordTypeId));
         }

         try {
            Boolean b1 = AH_UDC_Security.getIsStrictDisableSObjectQueryRecordStorage();
            AH_UDC_Security.setIsStrictDisableSObjectQueryRecordStorage(!b1);
            Boolean b2 = AH_UDC_Security.getIsStrictDisableSObjectQueryRecordStorage();
            System.assertNotEquals(b1, b2, 'isStrictDisableSObjectQueryRecordStorage() should have returned ' + !b1);
            AH_UDC_Security.setIsStrictDisableSObjectQueryRecordStorage(b1);
            Boolean b3 = AH_UDC_Security.getIsStrictDisableSObjectQueryRecordStorage();
            System.assertEquals(b1, b3, 'Failed to set isStrictDisableSObjectQueryRecordStorage() back to ' + b1);

            try {
               AH_UDC_Security.CreateObject(allWorkbooksA[0]);
            }
            catch (Exception exc) {
               System.assert(false, 'Failed to create object: ' + exc.getMessage() + '.  ' + AH_UDC_TestData.GetLastLogMessage());
            }
            System.assertEquals(1, [SELECT COUNT() FROM AH_UDC_Workbook__c WHERE Name = :allWorkbooksA[0].Name]);
            AH_UDC_Security.CreateObject(allWorkbooksA[1], false);
            System.assertEquals(1, [SELECT COUNT() FROM AH_UDC_Workbook__c WHERE Name = :allWorkbooksA[1].Name]);

            allWorkbooksA[0].Name += 'UPDATED';
            AH_UDC_Security.UpdateObject(allWorkbooksA[0]);
            System.assertEquals(1, [SELECT COUNT() FROM AH_UDC_Workbook__c WHERE Name = :allWorkbooksA[0].Name]);

            allWorkbooksA[1].Name += 'UPDATED';
            AH_UDC_Security.UpdateObject(allWorkbooksA[1], false);
            System.assertEquals(1, [SELECT COUNT() FROM AH_UDC_Workbook__c WHERE Name = :allWorkbooksA[1].Name]);

            AH_UDC_Security.UpsertObject(allWorkbooksA[2]);
            System.assertEquals(1, [SELECT COUNT() FROM AH_UDC_Workbook__c WHERE Name = :allWorkbooksA[2].Name]);

            allWorkbooksA[1].Name += 'UPDATED';
            AH_UDC_Security.UpsertObject(allWorkbooksA[2], false);
            System.assertEquals(1, [SELECT COUNT() FROM AH_UDC_Workbook__c WHERE Name = :allWorkbooksA[2].Name]);

            AH_UDC_Security.putWithFlsCheck(allWorkbooksA[0], 'name', 'TestWorkbookPUT');
            System.assertEquals('TestWorkbookPUT', allWorkbooksA[0].Name, 'Expected the name to be able to be changed to "testWorkbookPUT"');

            AH_UDC_Security.CreateObjects(allWorkbooksB);
            System.assertEquals(4, [SELECT COUNT() FROM AH_UDC_Workbook__c WHERE Name like 'TestWorkbook-B%']);

            AH_UDC_Security.DeleteObject(allWorkbooksA[0]);
            System.assertEquals(0, [SELECT COUNT() FROM AH_UDC_Workbook__c WHERE Id = :allWorkbooksA[0].Id]);
            AH_UDC_Security.DeleteObject(allWorkbooksA[1], false);
            System.assertEquals(0, [SELECT COUNT() FROM AH_UDC_Workbook__c WHERE Id = :allWorkbooksA[1].Id]);
            AH_UDC_Security.DeleteObjects(allWorkbooksB);
            System.assertEquals(0, [SELECT COUNT() FROM AH_UDC_Workbook__c WHERE Name like 'TestWorkbook-B%']);
         
            // Each of these calls throw an exception if the check fails due to user permissions
            AH_UDC_Security.checkAreFieldsUpdateable('AH_UDC_Workbook__c', new String[] { 'name' });
            AH_UDC_Security.checkAreFieldsCreatable('AH_UDC_Workbook__c', new String[] { 'name' });
            AH_UDC_Security.checkHasFullPrivilege('AH_UDC_Workbook__c');
            AH_UDC_Security.checkIsObjectUpdateable('AH_UDC_Workbook__c');
            AH_UDC_Security.checkIsObjectAccessible('AH_UDC_Workbook__c');
            AH_UDC_Security.checkIsObjectCreateable('AH_UDC_Workbook__c');
            AH_UDC_Security.checkIsFieldCreateable('AH_UDC_Workbook__c', 'Description__c');
            AH_UDC_Security.checkAreFieldsCreatable(allWorkbooksA[0]);
            //AH_UDC_Security.checkAreFieldsUpsertable(allWorkbooksA[0]);
          
            AH_UDC_Security.setIsStrictSecurityCheck(false);
            AH_UDC_Security.setIsTestExecutingTrigger(false);

         } catch(Exception exc) {
            //Asserting issue
            System.assert(false, 'AH_UDC_Security.cls ' + exc.getMessage() + exc.getStackTraceString());
         }

         Boolean retValue = false;
         retValue = AH_UDC_Security.checkAreFieldsAccessible('AH_UDC_Workbook__c', new String[] { 'Enabled__c', 'Description__c' });
         System.assertEquals(retValue, true, 'checkAreFieldsAccessible() did not return the expected value');

         Set<String> retFields = AH_UDC_Security.getAccessibleFields('AH_UDC_Workbook__c', new Set<String> { 'Enabled__c', 'Description__c' });
         System.assertEquals(retFields.size(), 2, 'getAccessibleFields() did not return the expected values');

         retValue = AH_UDC_Security.checkIsFieldAccessible('AH_UDC_Workbook__c', 'Enabled__c');
         System.assertEquals(retValue, true, 'checkIsFieldAccessible() did not return the expected value');

         retValue = AH_UDC_Security.checkisFieldFilterable('AH_UDC_Workbook__c', new String[] { 'Enabled__c' });
         System.assertEquals(retValue, true, 'checkisFieldFilterable(Enabled__c) did not return the expected value');

         retValue = AH_UDC_Security.checkisFieldFilterable('AH_UDC_Workbook__c', new String[] { 'Description__c' });
         System.assertEquals(retValue, false, 'checkisFieldFilterable(Description__c) did not return the expected value');

         retValue = AH_UDC_Security.checkisFieldFilterable('AH_UDC_Workbook__c', new String[] { 'Enabled__c', 'Description__c' });
         System.assertEquals(retValue, false, 'checkisFieldFilterable(Description__c) did not return the expected value');
         // Privilege check on SObject
         try {
            AH_UDC_Security.checkHasFullPrivilege('AH_UDC_Workbook__c');
            // if no exception was thrown, then user has full privileges
         }
         catch (Exception exc) {
            System.assert(false, 'User does not have full privileges on the ' + 'AH_UDC_Workbook__c' + ' SObject');
         }

         // Strict
         retValue = AH_UDC_Security.getIsStrictDisableSObjectQueryRecordStorage();
         System.assertEquals(retValue, false, 'getIsStrictDisableSObjectQueryRecordStorage() did not return the expected value');

         retValue = AH_UDC_Security.getIsStrictSecurityCheck();
         System.assertEquals(retValue, false, 'getIsStrictSecurityCheck() did not return the expected value');
      }
<<<<<<< HEAD
=======
      Test.stopTest();
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
   }

   @isTest
   static void isTest_SecurityException() {
      String objectTypeName = 'Rfp__c';
      String fieldName = 'Status__c';
<<<<<<< HEAD

=======
      Test.startTest();
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
      try {
         AH_UDC_Security.throwInsufficientPrivileges(objectTypeName, fieldName);
         System.assert(false, 'While trying to test an Insufficient Privileges Exception, an exception was not thrown');
      }
      catch(AH_UDC_Security.InsufficientPrivilegesException ipe) {
         // This is what should happen
         System.assert(ipe.getMessage().contains(objectTypeName + '.' + fieldName), 'Did not find the expected ObjectName.FieldName (' + objectTypeName + '.' + fieldName + ') in the exception message: ' + ipe.getMessage());
      }
      catch(Exception exc) {
         System.assert(false, 'An unexpected exception type occurred while trying to test an Insufficient Privileges Exception');
      }
<<<<<<< HEAD
=======
      Test.stopTest();
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
   }
}