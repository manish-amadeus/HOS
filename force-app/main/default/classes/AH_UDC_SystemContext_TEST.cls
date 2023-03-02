<<<<<<< HEAD
/*
 * Name         : AH_UDC_SystemContext_TEST
 * Created By   : George Tasker (george.tasker@amadeus.com)
 * Created Date : 2021-May-20
 * Description  : Test class for AH_UDC_SystemContext.cls
 * Dependencies : AH_UDC_SystemContext.cls
 */
@isTest
private class AH_UDC_SystemContext_TEST {

   // Setup the data used for the tests in this test class
   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
   }

   @IsTest private static void testSimpleQuery() {
      //AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      List<AH_UDC_ConfigurationSetting__c> listCS = AH_UDC_SystemContext.query('SELECT Name FROM AH_UDC_ConfigurationSetting__c');
      System.assert(listCS != null, 'AH_UDC_SystemContext.query() did not return back a list of AH_UDC_ConfigurationSetting__c instances');
      System.assert(listCS.size() > 0, 'Expected to retrieve at least 1 records from AH_UDC_ConfigurationSetting__c');
   }

   @IsTest private static void testComplexQuery() {
      //AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      List<AH_UDC_ConfigurationSetting__c> listCS;
      listCS = AH_UDC_SystemContext.query('AH_UDC_ConfigurationSetting__c', new List<String>{ 'Name' }, 'Name like \'%debug%\'', 'Name', 1);
      System.assert(listCS != null, 'AH_UDC_SystemContext.query() did not return back a list of AH_UDC_ConfigurationSetting__c instances');
      System.assert(listCS.size() == 1, 'Expected to retrieve 1 record from AH_UDC_ConfigurationSetting__c');
   }

   @IsTest private static void testComplexQueryNoObjectSpecified() {
      //AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      List<AH_UDC_ConfigurationSetting__c> listCS;
      try {
         listCS = AH_UDC_SystemContext.query('AH_UDC_BadSObjName', new List<String>{ 'Name' }, 'Name like \'%debug%\'', 'Name', 1);
         System.assert(false, 'The above call to query() should have failed because the SObject Name specified does not exist');
      }
      catch (AH_UDC_SystemContext.AH_UDC_SystemContextException exc) {
         System.assert(exc.getMessage().endsWith('was not found or is inaccessible'), 'Did not get back the expected exception.  Actual: ' + exc.getMessage());
      }
   }

   @IsTest private static void testComplexQueryNoFieldsSpecified() {
      //AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      List<AH_UDC_ConfigurationSetting__c> listCS;
      try {
         listCS = AH_UDC_SystemContext.query('AH_UDC_ConfigurationSetting__c', new List<String>{ 'AH_UDC_BadFieldName' }, 'Name like \'%debug%\'', 'Name', 1);
         System.assert(false, 'The above call to query() should have failed because there was an invalid field name specified');
      }
      catch (AH_UDC_SystemContext.AH_UDC_SystemContextException exc) {
         System.assert(exc.getMessage().contains('either do not exist, or are inaccessible'), 'Did not get back the expected exception.  Actual: ' + exc.getMessage());
      }
   }


   @IsTest private static void testUpsertSObj() {
      //AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      try {
         AH_UDC_Log__c log = new AH_UDC_Log__c(Message__c='test');
         AH_UDC_SystemContext.upsertSObj(log);
      }
      catch (AH_UDC_SystemContext.AH_UDC_SystemContextException exc) {
         System.assert(false,'Upsert Obj unexpectedly failed with exception: ' + exc.getMessage());
      }
   }

   @IsTest private static void testInsertSobjList() {
      //AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      List<AH_UDC_Log__c> listLog = new List<AH_UDC_Log__c>();
      try {
         AH_UDC_Log__c log = new AH_UDC_Log__c(Message__c='test');
         listLog.add(log);
         AH_UDC_SystemContext.insertSobjList(listLog);
      }
      catch (AH_UDC_SystemContext.AH_UDC_SystemContextException exc) {
         System.assert(false,'Upsert Obj unexpectedly failed with exception: ' + exc.getMessage());
      }
   }

    @IsTest private static void testUpdateSObj() {
      //AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      try {
         AH_UDC_Log__c log = new AH_UDC_Log__c(Message__c='test');
         AH_UDC_SystemContext.upsertSObj(log);
         log.Message__c='TestUpdate';
         AH_UDC_SystemContext.UpdateSObj(log);
      }
      catch (AH_UDC_SystemContext.AH_UDC_SystemContextException exc) {
         System.assert(false,'Upsert Obj unexpectedly failed with exception: ' + exc.getMessage());
      }
   }

   @IsTest private static void testCreateUpdateObject() {
      try {
         AH_UDC_Log__c log = new AH_UDC_Log__c(Message__c='testCreateUpdateObject');
         AH_UDC_SystemContext.CreateObject(log);
         List<AH_UDC_Log__c> verifyLog = [SELECT ID,Message__c FROM AH_UDC_Log__c WHERE Message__c='testCreateUpdateObject'];
         System.assertEquals(1,verifyLog.size(),'Expected to find 1 log record');
         verifyLog[0].Message__c = 'testCreateUpdateObject update';
         AH_UDC_SystemContext.UpdateObject(verifyLog[0]);
         verifyLog = [SELECT ID, Message__c FROM AH_UDC_Log__c  WHERE Message__c='testCreateUpdateObject update'];
         System.assertEquals(1,verifyLog.size(),'Expected to find 1 log record');
         System.assertEquals('testCreateUpdateObject update',verifyLog[0].Message__c,'Expected to find updated Message__c');
      }
      catch (AH_UDC_SystemContext.AH_UDC_SystemContextException exc) {
         System.assert(false,'Create Obj unexpectedly failed with exception: ' + exc.getMessage());
      }
   }

   @IsTest private static void testCreateUpdateObjects() {
      try {
         List<AH_UDC_Log__c> logs = new List<AH_UDC_Log__c>();
         logs.add(new AH_UDC_Log__c(Message__c='testCreateUpdateObjects'));
         AH_UDC_SystemContext.CreateObjects(logs);
         List<AH_UDC_Log__c> verifyLog = [SELECT ID FROM AH_UDC_Log__c where Message__c='testCreateUpdateObjects'];
         System.assertEquals(1,verifyLog.size(),'Expected to find 1 log record');
         verifyLog[0].Message__c = 'testCreateUpdateObjects update';
         AH_UDC_SystemContext.UpdateObjects(verifyLog);
         verifyLog = [SELECT ID, Message__c FROM AH_UDC_Log__c where Message__c='testCreateUpdateObjects update'];
         System.assertEquals(1,verifyLog.size(),'Expected to find 1 log record');
         System.assertEquals('testCreateUpdateObjects update',verifyLog[0].Message__c,'Expected to find updated Message__c');
      }
      catch (AH_UDC_SystemContext.AH_UDC_SystemContextException exc) {
         System.assert(false,'Create Obj unexpectedly failed with exception: ' + exc.getMessage());
      }
   }

=======
/*
 * Name         : AH_UDC_SystemContext_TEST
 * Created By   : George Tasker (george.tasker@amadeus.com)
 * Created Date : 2021-May-20
 * Description  : Test class for AH_UDC_SystemContext.cls
 * Dependencies : AH_UDC_SystemContext.cls
 */
@isTest
private class AH_UDC_SystemContext_TEST {

   // Setup the data used for the tests in this test class
   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
   }

   @IsTest private static void testSimpleQuery() {
      //AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      List<AH_UDC_ConfigurationSetting__c> listCS = AH_UDC_SystemContext.query('SELECT Name FROM AH_UDC_ConfigurationSetting__c');
      System.assert(listCS != null, 'AH_UDC_SystemContext.query() did not return back a list of AH_UDC_ConfigurationSetting__c instances');
      System.assert(listCS.size() > 0, 'Expected to retrieve at least 1 records from AH_UDC_ConfigurationSetting__c');
   }

   @IsTest private static void testComplexQuery() {
      //AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      List<AH_UDC_ConfigurationSetting__c> listCS;
      listCS = AH_UDC_SystemContext.query('AH_UDC_ConfigurationSetting__c', new List<String>{ 'Name' }, 'Name like \'%debug%\'', 'Name', 1);
      System.assert(listCS != null, 'AH_UDC_SystemContext.query() did not return back a list of AH_UDC_ConfigurationSetting__c instances');
      System.assert(listCS.size() == 1, 'Expected to retrieve 1 record from AH_UDC_ConfigurationSetting__c');
   }

   @IsTest private static void testComplexQueryNoObjectSpecified() {
      //AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      List<AH_UDC_ConfigurationSetting__c> listCS;
      try {
         listCS = AH_UDC_SystemContext.query('AH_UDC_BadSObjName', new List<String>{ 'Name' }, 'Name like \'%debug%\'', 'Name', 1);
         System.assert(false, 'The above call to query() should have failed because the SObject Name specified does not exist');
      }
      catch (AH_UDC_SystemContext.AH_UDC_SystemContextException exc) {
         System.assert(exc.getMessage().endsWith('was not found or is inaccessible'), 'Did not get back the expected exception.  Actual: ' + exc.getMessage());
      }
   }

   @IsTest private static void testComplexQueryNoFieldsSpecified() {
      //AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      List<AH_UDC_ConfigurationSetting__c> listCS;
      try {
         listCS = AH_UDC_SystemContext.query('AH_UDC_ConfigurationSetting__c', new List<String>{ 'AH_UDC_BadFieldName' }, 'Name like \'%debug%\'', 'Name', 1);
         System.assert(false, 'The above call to query() should have failed because there was an invalid field name specified');
      }
      catch (AH_UDC_SystemContext.AH_UDC_SystemContextException exc) {
         System.assert(exc.getMessage().contains('either do not exist, or are inaccessible'), 'Did not get back the expected exception.  Actual: ' + exc.getMessage());
      }
   }


   @IsTest private static void testUpsertSObj() {
      //AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      try {
         AH_UDC_Log__c log = new AH_UDC_Log__c(Message__c='test');
         AH_UDC_SystemContext.upsertSObj(log);
      }
      catch (AH_UDC_SystemContext.AH_UDC_SystemContextException exc) {
         System.assert(false,'Upsert Obj unexpectedly failed with exception: ' + exc.getMessage());
      }
   }

   @IsTest private static void testInsertSobjList() {
      //AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      List<AH_UDC_Log__c> listLog = new List<AH_UDC_Log__c>();
      try {
         AH_UDC_Log__c log = new AH_UDC_Log__c(Message__c='test');
         listLog.add(log);
         AH_UDC_SystemContext.insertSobjList(listLog);
      }
      catch (AH_UDC_SystemContext.AH_UDC_SystemContextException exc) {
         System.assert(false,'Upsert Obj unexpectedly failed with exception: ' + exc.getMessage());
      }
   }

    @IsTest private static void testUpdateSObj() {
      //AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      try {
         AH_UDC_Log__c log = new AH_UDC_Log__c(Message__c='test');
         AH_UDC_SystemContext.upsertSObj(log);
         log.Message__c='TestUpdate';
         AH_UDC_SystemContext.UpdateSObj(log);
      }
      catch (AH_UDC_SystemContext.AH_UDC_SystemContextException exc) {
         System.assert(false,'Upsert Obj unexpectedly failed with exception: ' + exc.getMessage());
      }
   }

   @IsTest private static void testCreateUpdateObject() {
      try {
         AH_UDC_Log__c log = new AH_UDC_Log__c(Message__c='testCreateUpdateObject');
         AH_UDC_SystemContext.CreateObject(log);
         List<AH_UDC_Log__c> verifyLog = [SELECT ID,Message__c FROM AH_UDC_Log__c WHERE Message__c='testCreateUpdateObject'];
         System.assertEquals(1,verifyLog.size(),'Expected to find 1 log record');
         verifyLog[0].Message__c = 'testCreateUpdateObject update';
         AH_UDC_SystemContext.UpdateObject(verifyLog[0]);
         verifyLog = [SELECT ID, Message__c FROM AH_UDC_Log__c  WHERE Message__c='testCreateUpdateObject update'];
         System.assertEquals(1,verifyLog.size(),'Expected to find 1 log record');
         System.assertEquals('testCreateUpdateObject update',verifyLog[0].Message__c,'Expected to find updated Message__c');
      }
      catch (AH_UDC_SystemContext.AH_UDC_SystemContextException exc) {
         System.assert(false,'Create Obj unexpectedly failed with exception: ' + exc.getMessage());
      }
   }

   @IsTest private static void testCreateUpdateObjects() {
      try {
         List<AH_UDC_Log__c> logs = new List<AH_UDC_Log__c>();
         logs.add(new AH_UDC_Log__c(Message__c='testCreateUpdateObjects'));
         AH_UDC_SystemContext.CreateObjects(logs);
         List<AH_UDC_Log__c> verifyLog = [SELECT ID FROM AH_UDC_Log__c where Message__c='testCreateUpdateObjects'];
         System.assertEquals(1,verifyLog.size(),'Expected to find 1 log record');
         verifyLog[0].Message__c = 'testCreateUpdateObjects update';
         AH_UDC_SystemContext.UpdateObjects(verifyLog);
         verifyLog = [SELECT ID, Message__c FROM AH_UDC_Log__c where Message__c='testCreateUpdateObjects update'];
         System.assertEquals(1,verifyLog.size(),'Expected to find 1 log record');
         System.assertEquals('testCreateUpdateObjects update',verifyLog[0].Message__c,'Expected to find updated Message__c');
      }
      catch (AH_UDC_SystemContext.AH_UDC_SystemContextException exc) {
         System.assert(false,'Create Obj unexpectedly failed with exception: ' + exc.getMessage());
      }
   }

>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}