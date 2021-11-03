/***********************************************************************************************
  Name            : AH_UDC_CustomLookupDialog_Test
  Author          : Sanjay Parmar
  Created Date    : 26-Apr-2021
  Last Mod Date   : 26-Apr-2021
  Last Mod By     : Sanjay Parmar
  NICC Reference  : 
  Description     : Test class for AH_UDC_CustomLookupDialog
 ************************************************************************************************/
@isTest
private class AH_UDC_CustomLookupDialog_Test {
   @testSetup
   private static void SetupTestData() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      Boolean isException = false;
      Account objAccount = null;
      String errorMessage = '';
      try {
         //Insert new Account data
         objAccount = AH_UDC_TestData.GetAccountObject('UDC Test Account 2', 'Hospitality Companies', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave');
         insert objAccount;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create Account record for testing : ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      Contact objContact = null;
      try {
         //Insert into Contact object
         objContact = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact', 'US', 'Portsmouth', '03801', 'NH',
                                                       '75 New Hampshire Ave');
         insert objContact;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create Contact record for testing : ' + errorMessage);

      Id profileId = [select id from profile where name = 'AH Customer Community Plus Login User'].Id;
      system.assertEquals(true, profileId != null, 'Could not get profile Id of AH Customer Community Plus Login User');

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      User objUser = null;
      try {
         //Insert into user object
         objUser = AH_UDC_TestData.GetUserObject(objContact.Id, profileId, 'Test', 'User', 'Mr.', 'test@user.com', 'test@user.com' + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX));
         insert objUser;

      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      AH_UDC_PropertyAccount__c objPropertyAccount = null;
      try {
         //Insert into Property Account object with blank property name to get more code coverage
         objPropertyAccount = AH_UDC_TestData.GetPropertyObject('Test Property Account', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105', 'St 104', '1 Portsmouth Ave.');
         insert objPropertyAccount;
      }
      catch(Exception ex) {
         isException = true;
         errorMessage = ex.GetMessage();
      }
      System.assertEquals(false, isException, 'Error occurred in creating property account record : ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      NI_Documentation__c objNIDoc = null;
      List<NI_Documentation__c> lstNIDocs = new List<NI_Documentation__c> ();
      try {
         for (Integer i = 1; i <= 50; i++) { //Create 50 NI Doc records for pagination testing
            objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document ' + i, Date.newInstance(2021, 5, 30));
            objNIDoc.Account__c = objAccount.Id;
            objNIDoc.AH_UDC_PropertyAccount__c = objPropertyAccount.Id;
            lstNIDocs.add(objNIDoc);
         }
         //Insert 50 records into NI Documentation object for testing
         insert lstNIDocs;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create NI_Documentation__c records for testing : ' + errorMessage);

      String WorkbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assertEquals(true, WorkbookRecordTypeId != null && WorkbookRecordTypeId != '', 'RecordType AH_UDC_Workbook not found');

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      AH_UDC_Workbook__c objWorkbook = null;
      try {
         //Insert Workbook Record
         objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
         objWorkbook.RecordTypeId = WorkbookRecordTypeId;
         insert objWorkbook;
      }
      catch(Exception ex) {
         isException = true;
         errorMessage = ex.GetMessage();
      }
      System.assertEquals(false, isException, 'Error occurred in creating workbook record : ' + errorMessage);

      String WorkbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();
      System.assertEquals(true, WorkbookStepRecordTypeId != null && WorkbookStepRecordTypeId != '', 'RecordType AH_UDC_WorkbookStep not found');

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      AH_UDC_WorkbookStep__c objWorkbookStep1 = null;
      try {
         //Insert Workbook Step Record
         objWorkbookStep1 = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 1');
         objWorkbookStep1.URL__c = 'https://www.Amadeus.com/1';
         objWorkbookStep1.RecordTypeId = WorkbookStepRecordTypeId;
         objWorkbookStep1.SortOrder__c = 1;
         insert objWorkbookStep1;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create Step 1 record for testing : ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      AH_UDC_WorkbookStep__c objWorkbookStep2 = null;
      try {
         //Insert Workbook Step Record
         objWorkbookStep2 = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 2');
         objWorkbookStep2.URL__c = 'https://www.Amadeus.com/2';
         objWorkbookStep2.RecordTypeId = WorkbookStepRecordTypeId;
         objWorkbookStep2.SortOrder__c = 2;
         insert objWorkbookStep2;
      }
      catch(Exception exc) {
         System.assert(false, 'Could not create Step 2 record for testing : ' + errorMessage);
      }
   }

   @isTest
   private static void TestNIDocumentationLookup() {
      String strNIDocKeyPrefix = NI_Documentation__c.sObjectType.getDescribe().getKeyPrefix();
      PageReference pageRef = Page.AH_UDC_CustomLookupDialog;
      pageRef.getParameters().put('lktp', strNIDocKeyPrefix); //Pass lookup type as a parameter
      pageRef.getParameters().put('lkfm', 'TestFormId'); //Pass lookup form id as a parameter
      pageRef.getParameters().put('lknm', 'TestFieldId'); //Pass lookup field id as a parameter
      Test.setCurrentPageReference(pageRef);

      Test.startTest();
      ApexPages.StandardController sController = new ApexPages.standardController(new AH_UDC_WorkbookStep__c());
      AH_UDC_CustomLookupDialog objNIDocLookup = new AH_UDC_CustomLookupDialog(sController);
      System.assertEquals(true, objNIDocLookup.IsErrorOccurred != true, 'Error occurred in page execution');
      System.assertEquals(true, objNIDocLookup.IsNIDocLookup, 'Error occurred in page execution - IsNIDocLookup value is not set');
      System.assertEquals(true, objNIDocLookup.NIDocRecordsList != null && objNIDocLookup.NIDocRecordsList.size() > 0, 'Error occurred in page execution - NI Doc list is empty');

      //Pagination Next Click
      objNIDocLookup.Next();
      System.assertEquals(true, objNIDocLookup.PageNumber == 1, 'Error occurred in executing Next method');

      //Pagination Previous Click
      objNIDocLookup.Previous();
      System.assertEquals(true, objNIDocLookup.PageNumber == 0, 'Error occurred in executing Previous method');

      //Pagination Last Click
      objNIDocLookup.End();
      System.assertEquals(true, objNIDocLookup.PageNumber == objNIDocLookup.TotalPages, 'Error occurred in executing End method');

      //Pagination First Click
      objNIDocLookup.Beginning();
      System.assertEquals(true, objNIDocLookup.PageNumber == 0, 'Error occurred in executing Beginning method');

      objNIDocLookup.SearchText = 'Test NI'; //Cover searchtext code
      objNIDocLookup.TotalRecordsAllowed = 40; //Cover if condition of maximum records
      objNIDocLookup.FillDataTableGrid(); //Get records based on search text
      System.assertEquals(true, objNIDocLookup.NIDocRecordsList != null && objNIDocLookup.NIDocRecordsList.size() > 0, 'Error occurred in seacrh - NI Doc list is empty after search');

      Test.stopTest();
   }

   @isTest
   private static void TestContactLookup() {
      String strContactKeyPrefix = Contact.sObjectType.getDescribe().getKeyPrefix();
      PageReference pageRef = Page.AH_UDC_CustomLookupDialog;
      pageRef.getParameters().put('lktp', strContactKeyPrefix); //Pass lookup type as a parameter
      pageRef.getParameters().put('lkfm', 'TestFormId'); //Pass lookup form id as a parameter
      pageRef.getParameters().put('lknm', 'TestFieldId'); //Pass lookup field id as a parameter
      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      ApexPages.StandardController sController = new ApexPages.standardController(new AH_UDC_WorkbookStep__c());
      AH_UDC_CustomLookupDialog objContactLookup = new AH_UDC_CustomLookupDialog(sController);
      System.assertEquals(true, objContactLookup.IsErrorOccurred != true, 'Error occurred in page execution');
      System.assertEquals(true, objContactLookup.IsContactLookup, 'Error occurred in page execution - IsContactLookup value is not set');
      System.assertEquals(true, objContactLookup.ContactRecordsList != null && objContactLookup.ContactRecordsList.size() > 0, 'Error occurred in page execution - Contact list is empty');

      objContactLookup.SearchText = 'Test Contact'; //Cover searchtext code
      objContactLookup.TotalRecordsAllowed = 1; //Cover if condition of maximum records
      objContactLookup.FillDataTableGrid(); //Get records based on search text
      System.assertEquals(true, objContactLookup.ContactRecordsList != null && objContactLookup.ContactRecordsList.size() > 0, 'Error occurred in search - Contact list is empty after search');

      Test.stopTest();
   }

   @isTest
   private static void TestWorkbookStepLookup() {
      String WorkbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();
      System.assertEquals(true, WorkbookStepRecordTypeId != null && WorkbookStepRecordTypeId != '', 'RecordType AH_UDC_WorkbookStep not found');

      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ([SELECT Id FROM AH_UDC_WorkbookStep__c WHERE RecordTypeId = :WorkbookStepRecordTypeId ORDER BY SortOrder__c]);
      System.assertEquals(true, lstWorkbookSteps != null && lstWorkbookSteps.size() > 1, 'Workbook Step Records Not Found');

      PageReference pageRef = Page.AH_UDC_CustomLookupDialog;
      pageRef.getParameters().put('id', lstWorkbookSteps[1].Id); //Pass workbook step id as a parameter
      pageRef.getParameters().put('prerequisiteStepId', lstWorkbookSteps[0].Id); //Pass prerequisite step id as a parameter
      Test.setCurrentPageReference(pageRef);
      Test.startTest();

      ApexPages.StandardController sController = new ApexPages.standardController(new AH_UDC_WorkbookStep__c());
      AH_UDC_CustomLookupDialog objWorkbookStepLookup = new AH_UDC_CustomLookupDialog(sController);
      System.assertEquals(true, objWorkbookStepLookup.IsErrorOccurred != true, 'Error occurred in page execution');
      System.assertEquals(true, objWorkbookStepLookup.IsWorkbookStepLookup, 'Error occurred in page execution - IsWorkbookStepLookup value is not set');
      System.assertEquals(true, objWorkbookStepLookup.WorkbookStepRecordsList != null && objWorkbookStepLookup.WorkbookStepRecordsList.size() > 0, 'Error occurred in page execution - WorkbookStepRecordsList is empty');

      objWorkbookStepLookup.SetPrerequisiteStep();
      System.assertEquals(true, objWorkbookStepLookup.IsErrorOccurred != true, 'Error occurred in SetPrerequisiteStep method execution');

      AH_UDC_WorkbookStep__c objWorkbookStep = [SELECT Id, Prerequisite_Step__c FROM AH_UDC_WorkbookStep__c WHERE Id = :lstWorkbookSteps[1].Id];
      System.assertEquals(true, objWorkbookStep != null && objWorkbookStep.Prerequisite_Step__c == lstWorkbookSteps[0].Id, 'Prerequisite Step Value Not Updated: ' + objWorkbookStep.Prerequisite_Step__c + ' | ' + lstWorkbookSteps[0].Id);

      objWorkbookStepLookup.SearchText = 'Test Step'; //Cover searchtext code
      objWorkbookStepLookup.FillDataTableGrid(); //Get records based on search text
      System.assertEquals(true, objWorkbookStepLookup.WorkbookStepRecordsList != null && objWorkbookStepLookup.WorkbookStepRecordsList.size() > 0, 'Error occurred in page execution - WorkbookStepRecordsList is empty after search');

      Test.stopTest();
   }

   @isTest
   private static void TestExceptionHandling() {
      PageReference pageRef = Page.AH_UDC_CustomLookupDialog;
      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      ApexPages.StandardController sController = new ApexPages.standardController(new AH_UDC_WorkbookStep__c());
      AH_UDC_CustomLookupDialog objLookup = new AH_UDC_CustomLookupDialog(sController);
      System.assertEquals(true, objLookup.IsErrorOccurred, 'Error not occurred in page execution');
      System.assertEquals(true, objLookup.HasPageLoadLogMessages, 'PageLoadLogMessages is empty');

      //Set name to generate error in LogException method
      objLookup.LogFunctionalArea = 'TestException';

      objLookup.ServerLogMessages();
      System.assertEquals(false, objLookup.HasPageLoadLogMessages, 'PageLoadLogMessages is not empty');

      objLookup.SetPrerequisiteStep();
      System.assertEquals(true, objLookup.IsErrorOccurred, 'Error not occurred in the method SetPrerequisiteStep');

      Test.stopTest();
   }
}