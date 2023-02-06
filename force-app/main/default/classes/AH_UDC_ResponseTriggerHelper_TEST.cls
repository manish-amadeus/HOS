/*
 * Name            : AH_UDC_ResponseTriggerHelper_TEST.cls
 * Created Date    : 2022-04-18
 * Created By      : vaishali.patel@Amadeus.com
 * Description     : Test class for AH_UDC_ResponseTriggerHelper
 * Dependencies    : AH_UDC_ResponseTriggerHelper
 */
@isTest
private class AH_UDC_ResponseTriggerHelper_TEST {

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      List<User> listUsers = new List<User> ();

      //Insert Workbook user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                              'UDCWorkbookUserRT', null, false));
      //Insert Workbook Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                              'UDCWorkbookAdminRT', null, false));
      //Insert UDC System Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                              'UDCSystemAdminRT', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[2].Id);
      }

      // Create Property Account object with blank property name to get more code coverage
      AH_UDC_PropertyAccount__c oPropertyAccount = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
      insert oPropertyAccount;

      // Create NI Doc record
      NI_Documentation__c oNiDoc = AH_UDC_TestData.GetNIDocObject('GUID', Date.newInstance(2021, 3, 31));
      oNiDoc.AH_UDC_PropertyAccount__c = oPropertyAccount.Id;
      insert oNiDoc;

      //Insert Workbook Sent
      Id wbRTId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();

      String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
      AH_UDC_Workbook__c wb = AH_UDC_TestData.GetWorkbookObject(null, 'TestWB1', 'Test Workbook 1 Description', product);
      wb.RecordTypeId = wbRTId;
      wb.RelatedTo__c = oNiDoc.Id;
      insert wb;

      //Insert Workbook Step Sent with Security Code
      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();

      Id rtFormAssemblyForm = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
      String definitionFA = '{"title":"UDCSB - Unit Test - Picklist - Source","FormAssemblyId":"4853245","CustomUrlId":"58c874ca-f1e4-4504-9878-b4b97af509ec","fields":[{"Name":"Security Code","APIName":"tfa_6","Repeat":"","Picklist":"false"},{"Name":"Token","APIName":"tfa_7","Repeat":"","Picklist":"false"},{"Name":"Parent Security Code","APIName":"tfa_9","Repeat":"","Picklist":"false"},{"Name":"Room Types","APIName":"tfa_1","Repeat":"tfa_1-D[0]","Picklist":"false"},{"Name":"Yes","APIName":"tfa_13","Repeat":""},{"Name":"No","APIName":"tfa_11","Repeat":""},{"Name":"Do you have Rooms","APIName":"tfa_10","Repeat":""}]}';
      AH_UDC_Form__c m_oForm = AH_UDC_TestData.GetForm(definitionFA, '4853111', 'TestFormFA', '58c874ca-f1e4-4504-9878-b4b97af509ec');
      m_oForm.RecordTypeId = rtFormAssemblyForm;
      insert m_oForm;

      AH_UDC_WorkbookStep__c wbs = AH_UDC_TestData.GetWorkbookStepObject(wb.Id, 'TestWBStep1');
      wbs.Form__c = m_oForm.Id;
      wbs.RecordTypeId = wbsRTId;
      wbs.Workbook__c = wb.id;
      insert wbs;
   
      //Insert Response
      Id responseRTId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
      AH_UDC_Response__c response1 = AH_UDC_TestData.GetStepResponseObject();
      response1.RecordTypeId = responseRTId;
      insert response1;

       //Insert Response - Do not assign to a WorkbookStepResponse
      AH_UDC_Response__c response2 = AH_UDC_TestData.GetStepResponseObject();
      response2.RecordTypeId = responseRTId;
      insert response2;

      //Insert Workbook Step Response
      AH_UDC_WorkbookStepResponse__c wbsResponse1 = AH_UDC_TestData.GetWorkbookStepResponseObject(wbs.id, response1.id);
      insert wbsResponse1;
   }

   @istest
   private static void TestDeleteResponseWithUDCSystemAdminPositive() {
      List<User> lstUDCSystemAdminUsers = [SELECT Id
                                           FROM User
                                           WHERE Username = 'TestUDCSystemAdminRT@amadeus.com'
                                           AND IsActive = true];
      System.assert(lstUDCSystemAdminUsers.size() > 0, 'UDC System Admin User record not found');

      Id wbRTId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(wbRTId), 'Workbook record type not found');
      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = 'TestWB1'
                                              AND RecordTypeId = :wbRTId];
      System.assertEquals(1, lstWorkbook.size(), 'Expected 1 Workbook Record named TestWB1');
      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [SELECT Id, Name
                                                      FROM AH_UDC_WorkbookStep__c
                                                      WHERE Name = 'TestWBStep1'
                                                      AND RecordTypeId = :wbsRTId];
      System.assertEquals(1, lstWorkbookStep.size(), 'Expected 1 Workbook sent step Record named TestWBStep1');

      List<AH_UDC_WorkbookStepResponse__c> lstWBStepResponses = [SELECT Response__c, IsMostRecentResponse__c FROM AH_UDC_WorkbookStepResponse__c WHERE WorkbookStep__c = :lstWorkbookStep[0].Id];
      System.assertEquals(1, lstWBStepResponses.size(), 'Expected 1 WB Step Response for TestWBStep1');

      List<AH_UDC_Response__c> lstResponses = [SELECT Id FROM AH_UDC_Response__c];
      System.assertEquals(2, lstResponses.size(), 'Expected 2 Responses for TestWBStep1');

      Test.startTest();
      //delete Response
      System.runAs(lstUDCSystemAdminUsers[0]) {
         try
         {
            //This delete should be allowed since the record is not assigned to a Workbook Step Response
            delete lstResponses[1];
         } catch(Exception ex)
         {
            System.assert(false, 'UDC System Admin user should be able to delete the Response since it is not assigned to a WorkbookStepResponse' + ex.getMessage());
         }
         Integer noOfResponse = [SELECT COUNT() FROM AH_UDC_Response__c];
         System.assertEquals(1, noOfResponse, 'Expected 1 Response remaining since the unattached one should have been allowed to be deleted');

         try {
            //This delete should throw an exception since the response in assigned to a Workbook Step Response
            delete lstResponses[0];
         }
         catch(Exception ex) {
            System.assert(ex.getMessage().indexOf(Label.AH_UDC_ResponseTriggerDeleteError) > - 1, 'Error occurred in response trigger while deleting response. Error : ' + ex.getMessage() + ' at Line number ' + ex.getLineNumber());
         }

      }
      Test.stopTest();
   }

   @istest
   private static void TestDeleteResponseWithWorkbookAdmin() {
      List<User> lstUDCWorkbookAdminUsers = [SELECT Id
                                             FROM User
                                             WHERE Username = 'TestUDCWorkbookAdminRT@amadeus.com'
                                             AND IsActive = true];
      System.assert(lstUDCWorkbookAdminUsers.size() > 0, 'workbook Admin User record not found');

      Id wbRTId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(wbRTId), 'Workbook record type not found');
      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = 'TestWB1'
                                              AND RecordTypeId = :wbRTId];
      System.assertEquals(1, lstWorkbook.size(), 'Expected 1 Workbook Record named TestWB1');
      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [SELECT Id, Name
                                                      FROM AH_UDC_WorkbookStep__c
                                                      WHERE Name = 'TestWBStep1'
                                                      AND RecordTypeId = :wbsRTId];
      System.assertEquals(1, lstWorkbookStep.size(), 'Expected 1 Workbook sent step Record named TestWBStep1');

      List<AH_UDC_WorkbookStepResponse__c> lstWSResponses = [SELECT Id, Response__c FROM AH_UDC_WorkbookStepResponse__c WHERE WorkbookStep__c = :lstWorkbookStep[0].Id];
      System.assertEquals(1, lstWSResponses.size(), 'Expected 1 Workbook Step Response for TestWBStep1');

      Set<Id> setResponses = new Set<Id> ();
      for (AH_UDC_WorkbookStepResponse__c wsr :[SELECT Response__c, IsMostRecentResponse__c FROM AH_UDC_WorkbookStepResponse__c WHERE WorkbookStep__c = :lstWorkbookStep[0].Id])
      {
         setResponses.add(wsr.Response__c);
      }
      List<AH_UDC_Response__c> lstResponse = [SELECT Id FROM AH_UDC_Response__c];
      System.assertEquals(2, lstResponse.size(), 'Expected 2 Responses for TestWBStep1');

      Test.startTest();
      //delete Response
      System.runAs(lstUDCWorkbookAdminUsers[0]) {
         try
         {
            delete lstResponse[1];
            System.assert(true, 'Workbook Admin should not be able to delete response');
         }
         catch(DmlException dmlexc) {
            // This is the expected behavior, so no assert here      
         }
         catch(Exception ex) {
            System.assert(false, 'An unexpected exception occurred while executing Delete responses as workbook admin.' + ex.getMessage());
         }

         Integer noOfResponse = [SELECT COUNT() FROM AH_UDC_Response__c];
         System.assertEquals(2, noOfResponse, 'Expected 2 Responses');
      }
      Test.stopTest();
   }


   @istest
   private static void TestDeleteResponseWithWorkbookUser() {
      List<User> lstUDCWorkbookUsers = [SELECT Id
                                        FROM User
                                        WHERE Username = 'TestUDCWorkbookUserRT@amadeus.com'
                                        AND IsActive = true];
      System.assert(lstUDCWorkbookUsers.size() > 0, 'Workbook User record not found');

      Id wbRTId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(wbRTId), 'Workbook record type not found');
      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = 'TestWB1'
                                              AND RecordTypeId = :wbRTId];
      System.assertEquals(1, lstWorkbook.size(), 'Expected 1 Workbook Record named TestWB1');
      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [SELECT Id, Name
                                                      FROM AH_UDC_WorkbookStep__c
                                                      WHERE Name = 'TestWBStep1'
                                                      AND RecordTypeId = :wbsRTId];
      System.assertEquals(1, lstWorkbookStep.size(), 'Expected 1 Workbook sent step Record named TestWBStep1');

      List<AH_UDC_WorkbookStepResponse__c> lstWSResponses = [SELECT Id, Response__c FROM AH_UDC_WorkbookStepResponse__c WHERE WorkbookStep__c = :lstWorkbookStep[0].Id];
      System.assertEquals(1, lstWSResponses.size(), 'Expected 1 Responses for TestWBStep1');

      Set<Id> setResponses = new Set<Id> ();
      for (AH_UDC_WorkbookStepResponse__c wsr :[SELECT Response__c, IsMostRecentResponse__c FROM AH_UDC_WorkbookStepResponse__c WHERE WorkbookStep__c = :lstWorkbookStep[0].Id])
      {
         setResponses.add(wsr.Response__c);
      }
      List<AH_UDC_Response__c> lstResponse = [SELECT Id FROM AH_UDC_Response__c];
      System.assertEquals(2, lstResponse.size(), 'Expected 2 Responses for TestWBStep1'); Test.startTest();

      //delete Response
      System.runAs(lstUDCWorkbookUsers[0]) {
         try
         {
            delete lstResponse[0];
            System.assert(true, 'Workbook User should not be able to delete response');
         }
         catch(DmlException dmlexc) {
            // This is the expected behavior, so no assert here      
         }
         catch(Exception ex) {
            System.assert(false, 'An unexpected exception occurred while executing Delete responses as workbook admin.' + ex.getMessage());
         }

         Integer noOfResponse = [SELECT COUNT() FROM AH_UDC_Response__c];
         System.assertEquals(2, noOfResponse, 'Expected 2 Responses');
      }
      Test.stopTest();
   }

   @istest
   private static void TestException() {

      AH_UDC_ResponseTriggerHelper.hasException = true;

      Id wbRTId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(wbRTId), 'Workbook record type not found');
      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = 'TestWB1'
                                              AND RecordTypeId = :wbRTId];
      System.assertEquals(1, lstWorkbook.size(), 'Expected 1 Workbook Record named TestWB1');
      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [SELECT Id, Name
                                                      FROM AH_UDC_WorkbookStep__c
                                                      WHERE Name = 'TestWBStep1'
                                                      AND RecordTypeId = :wbsRTId];
      System.assertEquals(1, lstWorkbookStep.size(), 'Expected 1 Workbook sent step Record named TestWBStep1');

      List<AH_UDC_WorkbookStepResponse__c> lstWSResponses = [SELECT Id, Response__c FROM AH_UDC_WorkbookStepResponse__c WHERE WorkbookStep__c = :lstWorkbookStep[0].Id];
      System.assertEquals(1, lstWSResponses.size(), 'Expected 1 Responses for TestWBStep1');
      Set<Id> setResponses = new Set<Id> ();
      for (AH_UDC_WorkbookStepResponse__c wsr :[SELECT Response__c, IsMostRecentResponse__c FROM AH_UDC_WorkbookStepResponse__c WHERE WorkbookStep__c = :lstWorkbookStep[0].Id])
      {
         setResponses.add(wsr.Response__c);
      }
      List<AH_UDC_Response__c> lstResponse = [SELECT Id FROM AH_UDC_Response__c WHERE Id = :setResponses];
      System.debug('lstResponse:' + lstResponse);
      System.assertEquals(1, lstResponse.size(), 'Expected 1 Responses for TestWBStep1');
      Test.startTest();
      //delete Response

      try
      {
         delete lstResponse[0];
      }
      catch(Exception ex)
      {
         System.assert(ex.getMessage().contains('Divide by 0'), 'Exception expected while deleting a response' + ex.getMessage());
      }

      Test.stopTest();
   }
}