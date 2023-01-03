/***********************************************************************************************
  Name            : AH_UDC_UnlockWorkbook_Test
  Author          : Ravi Shah
  Created Date    : 05-Mar-2021
  Last Mod Date   : 
  Last Mod By     : 
  NICC Reference  : 
  User Story ID   : 590658
  Description     : 
 
 ************************************************************************************************/
@isTest
public class AH_UDC_UnlockWorkbook_Test {

   private static final String TEST_NI_DOC_NAME = 'Test NI Document 1';
   private static final String TEST_WORKBOOK_NAME = 'Test Workbook 1';

   @TestSetup
   private static void setup() {
      //Prevent error : System.LimitException: Too many SOQL queries: 101
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      // Create NI Doc record
      NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject(TEST_NI_DOC_NAME, Date.newInstance(2021, 3, 31));      
      insert objNIDoc;

      // Create Workbook Record
      String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, TEST_WORKBOOK_NAME, 'Test Workbook 1 Description', product);
      objWorkbook.RelatedTo__c = objNIDoc.Id;
      objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
      objWorkbook.Enabled__c = true;
      objWorkbook.RecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      insert objWorkbook;

   }

   @isTest
   private static void AH_UDC_UnlockWorkbook_Test() {      
      List<NI_Documentation__c> lstNIDocument = [SELECT Id, Name
                                                FROM NI_Documentation__c
                                                WHERE Document_Name__c = :TEST_NI_DOC_NAME];
      System.assert(lstNIDocument.size() > 0, 'Ni Document records could not be found.');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                             FROM AH_UDC_Workbook__c
                                             WHERE Name = :TEST_WORKBOOK_NAME];
      System.assert(lstWorkbook.size() > 0, 'Workbook records could not be found.');
      
      ApexPages.StandardController sc = new ApexPages.standardController(lstNIDocument[0]);
      PageReference pageRef = Page.AH_UDC_SendWorkbook;
      pageRef.getParameters().put('id', lstNIDocument[0].Id);
      Test.setCurrentPageReference(pageRef);
      Test.startTest();

      AH_UDC_UnlockWorkbook objUnlockWorkbook = new AH_UDC_UnlockWorkbook(sc);
      system.assertEquals(true, String.valueOf(lstNIDocument[0].Id) == objUnlockWorkbook.NiDocId, 'NIDocId could not Matched');

      objUnlockWorkbook.UnlockWorkbook();
      system.assertEquals(true, objUnlockWorkbook.IsAnyError != true, 'There is an error in Unlock Workbook method.');

      //Workbook Record
      lstWorkbook[0] = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 2', 'Test Workbook 2 Description', 'Central Sales');
      lstWorkbook[0].RelatedTo__c = lstNIDocument[0].Id;
      lstWorkbook[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_IN_PROGRESS;
      lstWorkbook[0].Enabled__c = true;
      insert lstWorkbook[0];
      
      objUnlockWorkbook = new AH_UDC_UnlockWorkbook(sc);
      objUnlockWorkbook.IsAnyError = true;
      objUnlockWorkbook.UnlockWorkbook();
      System.assert(objUnlockWorkbook.IsAnyError, 'UnlockWorkbook - Error in Unlockworkbook function');

      Test.stopTest();
   }

   @isTest
   private static void AH_UDC_UnlockWorkbook_Negative_Test() {      
      List<NI_Documentation__c> lstNIDocument = [SELECT Id, Name
                                                FROM NI_Documentation__c
                                                WHERE Document_Name__c = :TEST_NI_DOC_NAME];
      System.assert(lstNIDocument.size() > 0, 'Ni Document records could not be found.');
      ApexPages.StandardController sc = new ApexPages.standardController(lstNIDocument[0]);

      PageReference pageRef = Page.AH_UDC_UnlockWorkbook;
      Test.setCurrentPageReference(pageRef);
      Test.startTest();

      AH_UDC_UnlockWorkbook objUnlockWorkbook = new AH_UDC_UnlockWorkbook(sc);
      objUnlockWorkbook.NiDocId = null;
      objUnlockWorkbook.UnlockWorkbook();
      System.assertEquals(true, objUnlockWorkbook.IsAnyError, 'UnlockWorkbook - Error NI Doc Id is null');

      AH_UDC_UnlockWorkbook objUnlockWorkbookError = new AH_UDC_UnlockWorkbook(sc);
      objUnlockWorkbookError.NiDocId = 'aAp290000004NS';
      objUnlockWorkbookError.UnlockWorkbook();
      System.assertEquals(true, objUnlockWorkbookError.IsAnyError, 'UnlockWorkbook - Error NI Doc Id is invalid');

      //Set name to generate error in LogException method
      objUnlockWorkbook.LogFunctionalArea = 'TestException';
      System.assert(objUnlockWorkbook.IsAnyError, 'Error not occurred while executing page without id parameter');
      System.assert(objUnlockWorkbook.HasPageLoadLogMessages, 'No log entries found in queue list');

      objUnlockWorkbook.ServerLogMessages();
      System.assertEquals(false, objUnlockWorkbook.HasPageLoadLogMessages, 'PageLoadLogMessages is not empty');

      Test.stopTest();
   }
}