/*
 * Name           : AH_UDC_DescribeCache_TEST.cls
 * Ported From    : Central Sales
 * Ported By      : George Tasker (george.tasker@amadeus.com)
 * Ported Date    : 2022-Jan-26
 * Description    : Test class - Code coverage for AH_UDC_AH_UDC_DescribeCache.cls
 * Dependencies   : AH_UDC_AH_UDC_DescribeCache.cls
 */
@isTest 
private class AH_UDC_DescribeCache_TEST {

   // This test method will test a successful pass through the code that should finish successfully
   @isTest private static void testSuccessGetObjectDescribe() {

      Schema.DescribeSObjectResult result = AH_UDC_DescribeCache.getObjectDescribe('Opportunity');
      System.assert(result != null, 'Specified Object was not found');
      system.assertEquals('Opportunity', result.getName(), 'getObjectDescribe did not return the expected result');
      logExecute();
   }

   @isTest private static void testFailureGetObjectDescribe() {

      try {
         Schema.DescribeSObjectResult result = AH_UDC_DescribeCache.getObjectDescribe('NoSuchObject');
         System.assertEquals(null, result, 'The specified object should not have been found');
      }
      catch(Exception e) {
         System.assert(e.getMessage().startsWith('Object type not found'), 'Should have failed because object does not exist, instead:' + e.getMessage() );
      }
      logExecute();
   }

   @isTest private static void testSuccessGetFieldDescribe() {

      Schema.DescribeFieldResult result = AH_UDC_DescribeCache.getFieldDescribe('AH_UDC_WorkbookStep__c', 'Workbook__r.CompletedBy__r.Username');
      System.assert(result != null, 'Specified Object or Field was not found');
      system.assertEquals('Username', result.getName(), 'FieldDescribe failed to find the specified Field');
      logExecute();
   }

   @isTest private static void testFailureGetFieldDescribe() {

      try {
         Schema.DescribeFieldResult result = AH_UDC_DescribeCache.getFieldDescribe('AH_UDC_WorkbookStep__c', 'AH_UDC_Workbook_r.NoSuchField');
         System.assertEquals(null, result, 'Field Name should not have been found');
      }
      catch(Exception e) {
         System.assert(e.getMessage().startsWith('Field not found'), 'Expected the Field Name to not be found');
      }
      logExecute();
   }

   @isTest private static void testSuccessGetFieldDescribes() {

      List<Schema.DescribeFieldResult> resultList = AH_UDC_DescribeCache.getFieldDescribes('AH_UDC_WorkbookStep__c', 'Workbook__r.CompletedBy__r.Username');
      system.assert(resultList != null, 'Failed to retrieve the Field Describes for the Object/Field that were specified');
      system.assertEquals('Workbook__c', resultList.get(0).getName(), 'FieldDescribe failed as initial Field was not found');
      system.assertEquals('CompletedBy__c', resultList.get(1).getName(), 'FieldDescribe failed as Related Object was not found');
      system.assertEquals('Username', resultList.get(2).getName(), 'FieldDescribe failed as Related Object Field was not found');
      logExecute();
   }

   // This test method will cause some type of exception to occur, and test that the expected error message(s)
   // and/or log messages do occur.
   @isTest private static void testExceptionGetFieldDescribes() {

      List<Schema.DescribeFieldResult> descFields = new List<schema.DescribeFieldResult> ();
      try {
         descFields = AH_UDC_DescribeCache.getFieldDescribes('AH_UDC_WorkbookStep__c', 'NoSuchField');
      }
      catch(Exception e) {
         system.assertEquals(e.getMessage(), 'Field not found2: ' + 'AH_UDC_WorkbookStep__c.NoSuchField');
      }
      logExecute();
   }

   @isTest private static void testSuccessFieldDescribes() {

      List<Schema.DescribeFieldResult> resultList = AH_UDC_DescribeCache.getFieldDescribes('Account');
      System.assert(resultList != null, 'Failed to retrieve the Field Describes for Account');
      logExecute();
   }

   @isTest private static void testFailureFieldDescribes() {

      try {
         List<Schema.DescribeFieldResult> resultList = AH_UDC_DescribeCache.getFieldDescribes('NoSuchObject');
         System.assertEquals(null, resultList, 'Object name does not exist, so getFieldDescribes() should have failed');
      }
      catch(Exception e) {
         System.assert(e.getMessage().startsWith('Object type not found'), 'Test should have failed due to the specified Object name not existing');
      }
      logExecute();
   }

   @isTest private static void testSuccessGetChildRelationship() {

      Schema.ChildRelationship childRelation = AH_UDC_DescribeCache.getChildRelationship('Account', 'ChildAccounts');
      system.assertEquals('ChildAccounts', childRelation.getRelationshipName(), 'getChildRelationship() should have been successful as the Object and Relationship Name exist');
      logExecute();
   }

   @isTest private static void testFailureGetChildRelationship() {

      Schema.ChildRelationship childRelation;
      try {
         childRelation = AH_UDC_DescribeCache.getChildRelationship('Account123', 'ChildAccounts123');
         system.assert(childRelation != null, 'Child relationship should not have been found as the Object and Relationship Name do not exist');
      }
      catch(Exception e) {
         //TODO:system.assert(childRelation == null, 'Child relationship name should be null for incorrect object type');
         System.assert(e.getMessage().startsWith('Object type not found'), 'Test should have failed due to the specified Object name not existing');
      }
      logExecute();
   }

   @isTest private static void testSuccessGetPicklistLabel() {

      String result = AH_UDC_DescribeCache.getPicklistLabel('AH_UDC_Workbook__c', 'SentStatus__c', 'In Progress');
      system.assertEquals('In Progress', result, 'Expected the specified Value to exist in the picklist');
      logExecute();
   }

   @isTest private static void testFailureGetPicklistLabel() {

      try {
         String result = AH_UDC_DescribeCache.getPicklistLabel('AH_UDC_Workbook__c', 'SentStatus__c', 'NoSuchValue');
      }
      catch(Exception e) {
         System.assert(e.getMessage().startsWith('Picklist entry not'), 'Expected the picklist not to have the specified value, instead a different exception occurred');
      }
      logExecute();
   }

   private static void logExecute() {

      Integer expectedLogCount = 0;
      List<AH_UDC_Log__c> logs = AH_UDC_LogHelper.GetTestMethodLogs(AH_UDC_LogHelper.getClassAndMethodName(new DmlException()));
      for (Integer index = 0; index<logs.size(); index++) {
         switch on index {
            //when 0 { System.assertEquals(TestClassDataHelper.CONFIG_SETTINGS_INITIALIZED, logs[0].LogText__c, 'Did not find the expected Log Message.'); }
            when else { System.assert(false, 'Missing an ASSERT that should check the validity of the Log message at index ' + index); }
         }
      }
      System.assertEquals(expectedLogCount, logs.size(), 'Found ' + (logs.size() > expectedLogCount ? 'more' : 'fewer') + ' Log messages than expected. Search the debug log for "Actual log" to see all Log messages');
   }
}