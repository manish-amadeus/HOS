/*
 * Name         : AH_UDC_WorkbookSentEmail_TEST
 * Created By   : Vaishali Patel (vaishali.patel@amadeus.com)
 * Created Date : 11/30/2022
 * Description  : Unit test for AH_UDC_WorkbookSentEmail_Batch class and AH_UDC_WorkbookSentEmail_Schedule class
 * Dependencies : AH_UDC_WorkbookSentEmail_Batch, AH_UDC_WorkbookSentEmail_Schedule
 */

@isTest
public class AH_UDC_WorkbookSentEmail_TEST {

   @testSetup
   private static void setupTestData() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      //Insert new Account data
      Account objAccount = AH_UDC_TestData.GetAccountObject('GUID');
      insert objAccount;

      Contact objContact = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'WorkbookSentEmailContact', 'USA', 'Portsmouth', '03801', 'NH', 'WorkbookSentEmail');
      objContact.Status__c = 'Active';
      objContact.Email = 'WorkbookSentEmailContact@test.com';
      insert objContact;

      List<NI_Documentation__c> lstNIDoc = new List<NI_Documentation__c> ();
      NI_Documentation__c objNIDoc1 = AH_UDC_TestData.GetNIDocObject('UDC Test NI Document WSE1', System.today().addDays(7));
      objNIDoc1.Account__c = objAccount.Id;
      lstNIDoc.add(objNIDoc1);
      NI_Documentation__c objNIDoc2 = AH_UDC_TestData.GetNIDocObject('UDC Test NI Document WSE2', System.today().addDays(5));
      objNIDoc2.Account__c = objAccount.Id;
      lstNIDoc.add(objNIDoc2);
      NI_Documentation__c objNIDoc3 = AH_UDC_TestData.GetNIDocObject('UDC Test NI Document WSE3', System.today().addDays(1));
      objNIDoc3.Account__c = objAccount.Id;
      lstNIDoc.add(objNIDoc3);
      NI_Documentation__c objNIDoc4 = AH_UDC_TestData.GetNIDocObject('UDC Test NI Document WSE4', System.today().addDays(1));
      objNIDoc4.Account__c = objAccount.Id;
      lstNIDoc.add(objNIDoc4);
      insert lstNIDoc;

      List<AH_UDC_Contact__c> lstContact = new List<AH_UDC_Contact__c> ();
      AH_UDC_Contact__c objUDCContact1 = AH_UDC_TestData.GetUDCContactObject(objNIDoc1.Id, objContact.Id, 'USD');
      lstContact.add(objUDCContact1);
      AH_UDC_Contact__c objUDCContact2 = AH_UDC_TestData.GetUDCContactObject(objNIDoc2.Id, objContact.Id, 'USD');
      lstContact.add(objUDCContact2);
      AH_UDC_Contact__c objUDCContact3 = AH_UDC_TestData.GetUDCContactObject(objNIDoc3.Id, objContact.Id, 'USD');
      lstContact.add(objUDCContact3);
      AH_UDC_Contact__c objUDCContact4 = AH_UDC_TestData.GetUDCContactObject(objNIDoc4.Id, objContact.Id, 'USD');
      lstContact.add(objUDCContact4);
      insert lstContact;

      //Insert Workbooksent Record
      List<AH_UDC_Workbook__c> lstWBS = new List<AH_UDC_Workbook__c> ();
      AH_UDC_Workbook__c objWorkbookSent1 = AH_UDC_TestData.GetWorkbookObject(objNIDoc1.Id, 'TestWorkbookSentEmail1', 'TestWorkbookSentEmail Description', 'Central Sales');
      objWorkbookSent1.Reminder1Enabled__c = true;
      objWorkbookSent1.SentDate__c = System.today();
      lstWBS.add(objWorkbookSent1);

      AH_UDC_Workbook__c objWorkbookSent2 = AH_UDC_TestData.GetWorkbookObject(objNIDoc2.Id, 'TestWorkbookSentEmail2', 'TestWorkbookSentEmail Description', 'Central Sales');
      objWorkbookSent2.Reminder2Enabled__c = true;
      objWorkbookSent2.SentDate__c = System.today();
      lstWBS.add(objWorkbookSent2);

      AH_UDC_Workbook__c objWorkbookSent3 = AH_UDC_TestData.GetWorkbookObject(objNIDoc3.Id, 'TestWorkbookSentEmail3', 'TestWorkbookSentEmail Description', 'Central Sales');
      objWorkbookSent3.Reminder3Enabled__c = true;
      objWorkbookSent3.SentDate__c = System.today();
      lstWBS.add(objWorkbookSent3);

      AH_UDC_Workbook__c objWorkbookSent4 = AH_UDC_TestData.GetWorkbookObject(objNIDoc4.Id, 'TestWorkbookSentEmail4', 'TestWorkbookSentEmail Description', 'Central Sales');
      objWorkbookSent4.Reminder4Enabled__c = true;
      objWorkbookSent4.SentDate__c = System.today();
      lstWBS.add(objWorkbookSent4);
      insert lstWBS;

      lstNIDoc[3].AH_UDC_WorkbookDueDate__c = System.today().addDays(- 2);
      update lstNIDoc[3];
   }

   @isTest
   private static void testSend7DaysReminder()
   {
      Test.startTest();
      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, SentStatus__c, DueDate__c, SentDate__c, Reminder1Sent__c, Reminder1Enabled__c FROM AH_UDC_Workbook__c WHERE Name = 'TestWorkbookSentEmail1'];
      System.assertEquals(1, lstWorkbook.size(), 'Expected 1 Workbook with name TestWorkbookSentEmail1.');
      System.assert(lstWorkbook[0].Reminder1Sent__c == null, 'Expected Reminder1Sent__c to be null.');

      AH_UDC_WorkbookSentEmail_Batch obj = new AH_UDC_WorkbookSentEmail_Batch();
      Database.executeBatch(obj);
      Test.stopTest();
      lstWorkbook = [SELECT Id, Reminder1Sent__c, Reminder1Days__c, SentDate__c, Reminder1Enabled__c FROM AH_UDC_Workbook__c WHERE Name = 'TestWorkbookSentEmail1'];
      System.assert(lstWorkbook[0].Reminder1Sent__c != null, 'Expected Reminder1Sent__c to be not null.');

   }

   @isTest
   private static void testSend5DaysReminder()
   {
      Test.startTest();
      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, SentStatus__c, DueDate__c, SentDate__c, Reminder2Sent__c, Reminder2Enabled__c FROM AH_UDC_Workbook__c WHERE Name = 'TestWorkbookSentEmail2'];
      System.assertEquals(1, lstWorkbook.size(), 'Expected 1 Workbook with name TestWorkbookSentEmail2.');
      System.assert(lstWorkbook[0].Reminder2Sent__c == null, 'Expected Reminder2Sent__c to be null.');
      AH_UDC_WorkbookSentEmail_Batch obj = new AH_UDC_WorkbookSentEmail_Batch();
      Database.executeBatch(obj);
      Test.stopTest();
      lstWorkbook = [SELECT Id, Reminder2Sent__c, Reminder2Days__c, SentDate__c, Reminder2Enabled__c FROM AH_UDC_Workbook__c WHERE Name = 'TestWorkbookSentEmail2'];
      System.assert(lstWorkbook[0].Reminder2Sent__c != null, 'Expected Reminder2Sent__c to be not null.');
   }

   @isTest
   private static void testSend1DaysReminder()
   {
      Test.startTest();
      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, SentStatus__c, DueDate__c, SentDate__c, Reminder3Sent__c, Reminder3Enabled__c FROM AH_UDC_Workbook__c WHERE Name = 'TestWorkbookSentEmail3'];
      System.assertEquals(1, lstWorkbook.size(), 'Expected 1 Workbook with name TestWorkbookSentEmail3.');
      System.assert(lstWorkbook[0].Reminder3Sent__c == null, 'Expected Reminder3Sent__c to be null.');
      AH_UDC_WorkbookSentEmail_Batch obj = new AH_UDC_WorkbookSentEmail_Batch();
      Database.executeBatch(obj);
      Test.stopTest();
      lstWorkbook = [SELECT Id, Reminder3Sent__c, Reminder3Days__c, SentDate__c, Reminder3Enabled__c FROM AH_UDC_Workbook__c WHERE Name = 'TestWorkbookSentEmail3'];
      System.assert(lstWorkbook[0].Reminder3Sent__c != null, 'Expected Reminder3Sent__c to be not null.');
   }

   @isTest
   private static void testSendPast1DaysReminder()
   {
      Test.startTest();

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, SentStatus__c, DueDate__c, SentDate__c, Reminder4Sent__c, Reminder4Enabled__c FROM AH_UDC_Workbook__c WHERE Name = 'TestWorkbookSentEmail4'];
      System.assertEquals(1, lstWorkbook.size(), 'Expected 1 Workbook with name TestWorkbookSentEmail4.');
      System.assert(lstWorkbook[0].Reminder4Sent__c == null, 'Expected Reminder4Sent__c to be null.');
      AH_UDC_WorkbookSentEmail_Batch obj = new AH_UDC_WorkbookSentEmail_Batch();
      Database.executeBatch(obj);
      Test.stopTest();
      lstWorkbook = [SELECT Id, Reminder4Sent__c, Reminder4Days__c, SentDate__c, Reminder4Enabled__c FROM AH_UDC_Workbook__c WHERE Name = 'TestWorkbookSentEmail4'];
      System.assert(lstWorkbook[0].Reminder4Sent__c != null, 'Expected Reminder4Sent__c to be not null.');
   }


   @isTest
   private static void ExceptionTestForWorkbookSentEmail() {
      Test.startTest();
      try {
         AH_UDC_WorkbookSentEmail_Batch.IsTestException = true;
         AH_UDC_WorkbookSentEmail_Batch obj = new AH_UDC_WorkbookSentEmail_Batch();
         Database.executeBatch(obj);
      }
      catch(Exception ex)
      {
         System.assert(ex.getMessage().indexOf('Divide by 0') > - 1, 'Different error occurred in the method GetAddress. Error: ' + ex.getMessage() + ' at line number ' + ex.getLineNumber());
      }
      Test.stopTest();
   }

   //Test for AH_UDC_WorkbookSentEmail_Schedule 
   @isTest
   private static void WorkbookSentEmailScheduleTest() {
      Test.StartTest();
      AH_UDC_WorkbookSentEmail_Schedule testBatchSchedule = new AH_UDC_WorkbookSentEmail_Schedule();
      String sch = '0 0 0 1 1 ? ';
      sch += System.Today().year() + 1;

      // Schedule the test job
      String jobId = System.schedule('AH UDC WorkbookSentEmail Test Job', sch, testBatchSchedule);
      Test.stopTest();
      // Get the information from the CronTrigger API object 
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

      // Verify the job has not run 
      System.assertEquals(0, ct.TimesTriggered);
      // Verify the next time the job will run 
      String expResult = System.Today().year() + 1 + '-01-01 00:00:00';
      System.assertEquals(expResult, String.valueOf(ct.NextFireTime));
   }
}