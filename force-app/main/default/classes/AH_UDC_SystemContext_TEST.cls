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
      AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      List<AH_UDC_ConfigurationSetting__c> listCS = sc.query('SELECT Name FROM AH_UDC_ConfigurationSetting__c');
      System.assert(listCS != null, 'AH_UDC_SystemContext.query() did not return back a list of AH_UDC_ConfigurationSetting__c instances');
      System.assert(listCS.size() > 0, 'Expected to retrieve at least 1 records from AH_UDC_ConfigurationSetting__c');
   }

   @IsTest private static void testComplexQuery() {
      AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      List<AH_UDC_ConfigurationSetting__c> listCS;
      listCS = sc.query('AH_UDC_ConfigurationSetting__c', new List<String>{ 'Name' }, 'Name like \'%debug%\'', 'Name', 1);
      System.assert(listCS != null, 'AH_UDC_SystemContext.query() did not return back a list of AH_UDC_ConfigurationSetting__c instances');
      System.assert(listCS.size() == 1, 'Expected to retrieve 1 record from AH_UDC_ConfigurationSetting__c');
   }

   @IsTest private static void testComplexQueryNoObjectSpecified() {
      AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      List<AH_UDC_ConfigurationSetting__c> listCS;
      try {
         listCS = sc.query('AH_UDC_BadSObjName', new List<String>{ 'Name' }, 'Name like \'%debug%\'', 'Name', 1);
         System.assert(false, 'The above call to query() should have failed because the SObject Name specified does not exist');
      }
      catch (AH_UDC_SystemContext.AH_UDC_SystemContextException exc) {
         System.assert(exc.getMessage().endsWith('was not found or is inaccessible'), 'Did not get back the expected exception.  Actual: ' + exc.getMessage());
      }
   }

   @IsTest private static void testComplexQueryNoFieldsSpecified() {
      AH_UDC_SystemContext sc = new AH_UDC_SystemContext();
      List<AH_UDC_ConfigurationSetting__c> listCS;
      try {
         listCS = sc.query('AH_UDC_ConfigurationSetting__c', new List<String>{ 'AH_UDC_BadFieldName' }, 'Name like \'%debug%\'', 'Name', 1);
         System.assert(false, 'The above call to query() should have failed because there was an invalid field name specified');
      }
      catch (AH_UDC_SystemContext.AH_UDC_SystemContextException exc) {
         System.assert(exc.getMessage().contains('either do not exist, or are inaccessible'), 'Did not get back the expected exception.  Actual: ' + exc.getMessage());
      }
   }

}