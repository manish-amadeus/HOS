/***********************************************************************************************
  Name            : AH_UDC_StepOrder_TEST
  Author          : Ravi Shah
  Created Date    : 30-Jan-2021
  Last Mod Date   : 8-Feb-2021
  Last Mod By     : Sanjay Parmar
  Description     : Test class for Step Order class
  Change History  :
  1. 590045 - Refactoring Code - Changed by Sanjay Parmar on 8-Feb-2021
  2. 594855 - Refactoring Code - Changed by Tushar Gupta on 23-Feb-2021
 ************************************************************************************************/
@isTest
private class AH_UDC_StepOrder_TEST {
   private static final string ClassName = 'AH_UDC_StepOrder_TEST';

   private static final String TEST_NI_DOC_NAME = 'Test NI Document 1';
   private static final String TEST_WORKBOOK_NAME = 'Test Workbook 1';
   private static final String TEST2_NI_DOC_NAME = 'Test NI Document 2';
   private static final String TEST2_WORKBOOK_NAME = 'Test Workbook 2';

   private static string UDCWorkbookUser = ClassName + '_UDCWorkbookUser';
   private static string UDCWorkbookAdminUser = ClassName + '_UDCWorkbookAdminUser';
   private static string UDCWorkbookAdmin2User = ClassName + '_UDCWorkbookAdmin2User';
   private static string UDCSystemAdminUser = ClassName + '_UDCSystemAdminUser';

   @TestSetup
   private static void setup() {

      //Prevent error : System.LimitException: Too many SOQL queries: 101      
      AH_UDC_InitializationHelper.Initialize('All');

      List<User> listUsers = new List<User> ();
      //Create Workbook user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                    '{GUID}' + UDCWorkbookUser, null, false));
      //Create Workbook Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    '{GUID}' + UDCWorkbookAdminUser, null, false));
      //Create Workbook Admin User 2
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    '{GUID}' + UDCWorkbookAdmin2User, null, false));
      //Create UDC System Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                    '{GUID}' + UDCSystemAdminUser, null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         // Community Users
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[2].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[3].Id);
      }


      // Create NI Doc record
      NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject(TEST_NI_DOC_NAME, Date.newInstance(2021, 3, 31));
      insert objNIDoc;

      // Create NI Doc record
      NI_Documentation__c objNIDoc2 = AH_UDC_TestData.GetNIDocObject(TEST2_NI_DOC_NAME, Date.newInstance(2021, 3, 31));
      insert objNIDoc2;

      //Get workbook record type Id
      Id workbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      system.assertEquals(true, workbookRecordTypeId != null, 'Workbook record type(AH_UDC_Workbook) id did not find.');

      System.runAs(listUsers[1]) {
         // Create Workbook Record
         String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
         AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, TEST_WORKBOOK_NAME, 'Test Workbook 1 Description', product);
         objWorkbook.RecordTypeId = workbookRecordTypeId; //Above function return object with Workbook Sent record type so need to change it
         insert objWorkbook;
      }

      //Create Workbook Record with current login user 
      String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
      AH_UDC_Workbook__c objWorkbook2 = AH_UDC_TestData.GetWorkbookObject(objNIDoc2.Id, TEST2_WORKBOOK_NAME, 'Test Workbook 2 Description', product);
      objWorkbook2.RecordTypeId = workbookRecordTypeId;
      insert objWorkbook2;
   }

   private static void TestStepOrder() {
      //this is already run as system admin and workbook admin
      //Get workbook step record type Id
      Id workbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();
      system.assertEquals(true, workbookStepRecordTypeId != null, 'Workbook record type(AH_UDC_WorkbookStep) id did not find.');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = :TEST_WORKBOOK_NAME];
      System.assert(lstWorkbook.size() > 0, 'Workbook record did not find.');

      List<AH_UDC_WorkbookStep__c> wbsteps = new List<AH_UDC_WorkbookStep__c> ();
      for (Integer i = 0; i <= 40; i++)
      {
         wbsteps.add(new AH_UDC_WorkbookStep__c(Name = 'WBStep' + i,
                                                RecordtypeId = workbookStepRecordTypeId,
                                                Workbook__c = lstWorkbook[0].Id,
                                                URL__c = 'https://www.Amadeus.com/' + i));
      }
      insert wbsteps;
      System.assert(wbsteps.size() > 0, 'WorkbookStep record is not Inserted Sucessfully.');

      PageReference pageRef = Page.AH_UDC_StepOrder;
      pageRef.getParameters().put('id', lstWorkbook[0].Id);
      Test.setCurrentPageReference(pageRef);
      ApexPages.StandardController sController = new ApexPages.standardController(lstWorkbook[0]);
      AH_UDC_StepOrder objStepOrder = new AH_UDC_StepOrder(sController);
      system.assertEquals(true, (objStepOrder.IsErrorOccurred != true && objStepOrder.StepList != null && objStepOrder.StepList.size() > 0), 'Error occurred in Step Order page execution');
      system.assertEquals(true, objStepOrder.UserHasAccess, 'User does not have edit access on workbook.');

      if (objStepOrder.StepList.size() > 0) {
         String strStpeIds = '';
         for (Integer i = objStepOrder.StepList.size() - 1; i > 0; i--) { //Change step order in reverse
            if (String.isNotBlank(strStpeIds)) {
               strStpeIds += ',' + objStepOrder.StepList[i].Id;
            }
            else {
               strStpeIds = objStepOrder.StepList[i].Id;
            }
         }

         //Change order of workbook steps
         objStepOrder.StepIds = strStpeIds;
         objStepOrder.SaveStepOrders();
         system.assert(objStepOrder.IsErrorOccurred != true, 'Error occurred in updating Step Orders');

         //Make StepIds blank to generate error and get more code coverage
         objStepOrder.StepIds = '';
         objStepOrder.SaveStepOrders();
         system.assert(objStepOrder.IsErrorOccurred, 'Error is not generated after passing blank StepIds');
      }
   }

   @isTest
   private static void StepOrderNegativeErrorTest() {
      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = :TEST_WORKBOOK_NAME];
      System.assert(lstWorkbook.size() > 0, 'Workbook records could not be found.');

      PageReference pageRef = Page.AH_UDC_StepOrder;
      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      ApexPages.StandardController sController = new ApexPages.standardController(lstWorkbook[0]);
      AH_UDC_StepOrder objStepOrder = new AH_UDC_StepOrder(sController);

      //Set name to generate error in LogException method
      objStepOrder.LogFunctionalArea = 'TestException';
      System.assert(objStepOrder.IsErrorOccurred, 'Error not occurred while executing page without id parameter');
      System.assert(objStepOrder.HasPageLoadLogMessages, 'No log entries found in queue list');

      objStepOrder.ServerLogMessages();
      System.assertEquals(false, objStepOrder.HasPageLoadLogMessages, 'PageLoadLogMessages is not empty');

      Test.stopTest();
   }

   @isTest
   private static void RunAsWorkbookUser() {
      //create System admin user with profiles and permission set
      List<User> objWorkbookUser = [SELECT Id FROM User
                                    WHERE External_Salesforce_Username__c = :UDCWorkbookUser];
      System.assertEquals(true, objWorkbookUser[0] != null, 'Workbook User Record Not Found');

      //Get workbook step record type Id
      Id workbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();
      system.assertEquals(true, workbookStepRecordTypeId != null, 'Workbook record type(AH_UDC_WorkbookStep) id did not find.');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name, OwnerId
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = :TEST_WORKBOOK_NAME];
      System.assert(lstWorkbook.size() > 0, 'Workbook records could not be found.');

      Test.startTest();
      System.runAs(objWorkbookUser[0]) {
         PageReference pageRef = Page.AH_UDC_StepOrder;
         pageRef.getParameters().put('id', lstWorkbook[0].Id);
         Test.setCurrentPageReference(pageRef);
         ApexPages.StandardController sController = new ApexPages.standardController(lstWorkbook[0]);
         AH_UDC_StepOrder objStepOrder = new AH_UDC_StepOrder(sController);
         system.assertEquals(false, objStepOrder.UserHasAccess, 'User does not have Edit access on workbook.');
      }
      Test.stopTest();
   }

   @isTest
   private static void RunAsWorkbookAdminUser() {
      //create workbook admin user with profiles and permission set
      List<User> objWorkbookAdminUser = [SELECT Id FROM User
                                         WHERE External_Salesforce_Username__c = :UDCWorkbookAdminUser];
      System.assertEquals(true, objWorkbookAdminUser[0] != null, 'Workbook Admin User Record Not Found');

      Test.startTest();
      System.runAs(objWorkbookAdminUser[0]) {
         TestStepOrder();
      }
      Test.stopTest();
   }

   @isTest
   private static void TestStepOrderwithDifferentUser() {
      //Here we are testing with another workbookk admin who does not have acees right on given workbook.
      List<User> objWorkbookAdminUser = [SELECT Id FROM User
                                         WHERE External_Salesforce_Username__c = :UDCWorkbookAdmin2User];
      System.assertEquals(true, objWorkbookAdminUser[0] != null, 'Workbook Admin User 2 Record Not Found');

      //Get workbook step record type Id
      Id workbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();
      system.assertEquals(true, workbookStepRecordTypeId != null, 'Workbook record type(AH_UDC_WorkbookStep) id did not find.');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name, OwnerId
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = :TEST_WORKBOOK_NAME];
      System.assert(lstWorkbook.size() > 0, 'Workbook records could not be found.');

      Test.startTest();
      System.runAs(objWorkbookAdminUser[0]) {
         PageReference pageRef = Page.AH_UDC_StepOrder;
         pageRef.getParameters().put('id', lstWorkbook[0].Id);
         Test.setCurrentPageReference(pageRef);
         ApexPages.StandardController sController = new ApexPages.standardController(lstWorkbook[0]);
         AH_UDC_StepOrder objStepOrder = new AH_UDC_StepOrder(sController);
         system.assertEquals(false, objStepOrder.UserHasAccess, 'User does not have Edit access on workbook.');
      }
      Test.stopTest();
   }

   @isTest
   private static void RunAsSystemAdminUser() {
      //create System admin user with profiles and permission set
      List<User> objSystemAdminUser = [SELECT Id FROM User
                                       WHERE External_Salesforce_Username__c = :UDCSystemAdminUser];
      System.assertEquals(true, objSystemAdminUser[0] != null, 'System Admin User Record Not Found');

      Test.startTest();
      System.runAs(objSystemAdminUser[0]) {
         TestStepOrder();
      }
      Test.stopTest();
   }

   @isTest
   private static void TestOnRunTimeshareWorkbookWithUser() {
      Id workbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK);

      List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id
                                               FROM AH_UDC_Workbook__c
                                               WHERE RecordTypeId = :workbookRecordTypeId
                                               AND Enabled__c = true AND Name = :TEST2_WORKBOOK_NAME];
      System.assert(lstWorkbooks.size() > 0, 'Workbook record is not created');

      List<User> lstUsers = [SELECT Id FROM User
                             WHERE External_Salesforce_Username__c = :UDCWorkbookAdminUser];
      System.assert(lstUsers.size() > 0, 'Workbook Admin user is not created');

      // Share workbook with Workbook Admin for workbook step lookup
      AH_UDC_Workbook__Share objWorkbookShare = new AH_UDC_Workbook__Share();
      objWorkbookShare.ParentId = lstWorkbooks[0].Id;
      objWorkbookShare.UserOrGroupId = lstUsers[0].Id;
      objWorkbookShare.AccessLevel = 'Edit';
      insert objWorkbookShare;

      Test.startTest();
      System.runAs(lstUsers[0]) {
         PageReference pageRef = Page.AH_UDC_StepOrder;
         pageRef.getParameters().put('id', lstWorkbooks[0].Id);
         Test.setCurrentPageReference(pageRef);
         ApexPages.StandardController sController = new ApexPages.standardController(lstWorkbooks[0]);
         AH_UDC_StepOrder objStepOrder = new AH_UDC_StepOrder(sController);
         system.assertEquals(true, objStepOrder.UserHasAccess, 'User does not have Edit access on workbook.');
      }
      Test.stopTest();
   }
}