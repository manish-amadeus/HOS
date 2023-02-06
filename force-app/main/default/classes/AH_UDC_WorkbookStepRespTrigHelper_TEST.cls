/*
 * Name            : AH_UDC_WorkbookStepRespTrigHelper_TEST.cls
 * Created Date    : 2022-04-19
 * Created By      : vaishali.patel@Amadeus.com
 * Description     : Test class for AH_UDC_WorkbookStepRespTrigHelper. Because of 40 characters limit for the name, test class name is given as AH_UDC_WorkbookStepRespTrigHelper_TEST
 * Dependencies    : AH_UDC_WorkbookStepRespTrigHelper
 */
@isTest
public class AH_UDC_WorkbookStepRespTrigHelper_TEST {
   private static AH_UDC_Workbook__c wb = null;
   private static AH_UDC_WorkbookStep__c wbs = null;

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      List<User> listUsers = new List<User> ();

      //Insert Workbook user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                              'UDCWorkbookUserWBSRT', null, false));
      //Insert Workbook Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                              'UDCWorkbookAdminWBSRT', null, false));
      //Insert UDC System Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                              'UDCSystemAdminWBSRT', null, false));

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

      //Insert Workbook Step Response
      AH_UDC_WorkbookStepResponse__c wbsResponse1 = AH_UDC_TestData.GetWorkbookStepResponseObject(wbs.id, response1.id);
      insert wbsResponse1;
   }

   @istest
   private static void TestWBStepResponseWithUDCSystemAdmin() {
      List<User> lstUDCSystemAdminUsers = [SELECT Id
                                           FROM User
                                           WHERE Username = 'TestUDCSystemAdminWBSRT@amadeus.com'
                                           AND IsActive = true];
      System.assert(lstUDCSystemAdminUsers.size() > 0, 'UDC System Admin User record not found');

      Id wbRTId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(wbRTId), 'Workbook record type not found');
      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = 'TestWB1'
                                              AND RecordTypeId = :wbRTId];
      System.assertEquals(1, lstWorkbook.size(), 'Expected 1 Workbook record named TestWB1');
      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [SELECT Id, Name
                                                      FROM AH_UDC_WorkbookStep__c
                                                      WHERE Name = 'TestWBStep1'
                                                      AND RecordTypeId = :wbsRTId];
      System.assertEquals(1, lstWorkbookStep.size(), 'Expected 1 Workbook sent step record named TestWBStep1');

      List<AH_UDC_WorkbookStepResponse__c> lstWBSR = [SELECT Id, Response__c, IsMostRecentResponse__c FROM AH_UDC_WorkbookStepResponse__c WHERE WorkbookStep__c = :lstWorkbookStep[0].Id];
      System.assertEquals(1, lstWBSR.size(), 'Expected 1 Workbook step response record');

      Id responseRTId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
      AH_UDC_Response__c response2 = AH_UDC_TestData.GetStepResponseObject();
      response2.RecordTypeId = responseRTId;
      insert response2;
      AH_UDC_WorkbookStepResponse__c wbsResponse2 = AH_UDC_TestData.GetWorkbookStepResponseObject(lstWorkbookStep[0].id, response2.id);

      Test.startTest();
      //delete Response
      System.runAs(lstUDCSystemAdminUsers[0]) {

         insert wbsResponse2;

         List<AH_UDC_WorkbookStepResponse__c> lstWSResponses = [SELECT Id, IsMostRecentResponse__c FROM AH_UDC_WorkbookStepResponse__c WHERE Response__c = :response2.id];
         System.assertEquals(1, lstWSResponses.size(), 'Expected 1 Responses for TestWBStep1');
         System.assertEquals(true, lstWSResponses[0].IsMostRecentResponse__c, 'Expected IsMostRecentResponse = true');

         lstWBSR[0].Name = 'Test WBSR 1';
         update lstWBSR[0];

         List<AH_UDC_WorkbookStepResponse__c> lstWSResponses1 = [SELECT Id, Name FROM AH_UDC_WorkbookStepResponse__c WHERE Id = :lstWBSR[0].id];
         System.assertEquals(1, lstWSResponses1.size(), 'Expected 1 Responses for TestWBStep1');
         System.assertEquals(lstWBSR[0].Name, lstWSResponses1[0].Name, 'Expected WorkbookStepResponse Name = Test WBSR 1');

         try
         {
            delete lstWBSR[0];
         } catch(Exception ex)
         {
            System.assert(false, 'UDC System Admin user should be able to delete the WorkbookStepResponse' + ex.getMessage());
         }
         Integer noOfResponse = [SELECT COUNT() FROM AH_UDC_WorkbookStepResponse__c WHERE Id = :lstWBSR[0].Id];
         System.assertEquals(0, noOfResponse, 'Expected no WorkbookStepResponse');
      }
      Test.stopTest();
   }

      @istest
   private static void NegativeTestWBStepResponseWithWorkbookAdminAndWorkbookUser() {
      List<User> lstUDCWorkbookAdminUsers = [SELECT Id
                                           FROM User
                                           WHERE Username = 'TestUDCWorkbookAdminWBSRT@amadeus.com'
                                           AND IsActive = true];
      System.assert(lstUDCWorkbookAdminUsers.size() > 0, 'UDC Workbook Admin User record not found');

      List<User> lstUDCWorkbookUsers = [SELECT Id
                                        FROM User
                                        WHERE Username = 'TestUDCWorkbookUserWBSRT@amadeus.com'
                                        AND IsActive = true];
      System.assert(lstUDCWorkbookUsers.size() > 0, 'Workbook User record not found');

      Id wbRTId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(wbRTId), 'Workbook record type not found');
      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = 'TestWB1'
                                              AND RecordTypeId = :wbRTId];
      System.assertEquals(1, lstWorkbook.size(), 'Expected 1 Workbook record named TestWB1');
      Id wbsRTId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [SELECT Id, Name
                                                      FROM AH_UDC_WorkbookStep__c
                                                      WHERE Name = 'TestWBStep1'
                                                      AND RecordTypeId = :wbsRTId];
      System.assertEquals(1, lstWorkbookStep.size(), 'Expected 1 Workbook sent step record named TestWBStep1');

      List<AH_UDC_WorkbookStepResponse__c> lstWBSR = [SELECT Id, Response__c, IsMostRecentResponse__c FROM AH_UDC_WorkbookStepResponse__c WHERE WorkbookStep__c = :lstWorkbookStep[0].Id];
      System.assertEquals(1, lstWBSR.size(), 'Expected 1 Workbook step response record');

      Test.startTest();

      //delete Response
      System.runAs(lstUDCWorkbookAdminUsers[0]) {
         try
         {
            delete lstWBSR[0];
            System.assert(true, 'Workbook Admin User should not be able to delete workbook step response');
         }
         catch(DmlException dmlexc) {
            // This is the expected behavior, so no assert here      
         }
         catch(Exception ex) {
            System.assert(false, 'An unexpected exception occurred while executing Delete responses as workbook admin.' + ex.getMessage());
         }

         Integer noOfResponse = [SELECT COUNT() FROM AH_UDC_WorkbookStepResponse__c WHERE Id = :lstWBSR[0].Id];
         System.assertEquals(1, noOfResponse, 'Expected 1 WorkbookStepResponse');
      }

      System.runAs(lstUDCWorkbookUsers[0]) {
         try
         {
            delete lstWBSR[0];
            System.assert(true, 'Workbook User should not be able to delete workbook step response');
         }
         catch(DmlException dmlexc) {
            // This is the expected behavior, so no assert here      
         }
         catch(Exception ex) {
            System.assert(false, 'An unexpected exception occurred while executing Delete responses as workbook admin.' + ex.getMessage());
         }

         Integer noOfResponse = [SELECT COUNT() FROM AH_UDC_WorkbookStepResponse__c WHERE Id = :lstWBSR[0].Id];
         System.assertEquals(1, noOfResponse, 'Expected 1 WorkbookStepResponse');
      }

      Test.stopTest();
   } 

   @isTest
   private static void TestException() {

      Test.startTest();

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

      List<AH_UDC_WorkbookStepResponse__c> lstWSResponses = [SELECT Id, WorkbookStep__c, Response__c FROM AH_UDC_WorkbookStepResponse__c WHERE WorkbookStep__c = :lstWorkbookStep[0].Id];
      System.assertEquals(1, lstWSResponses.size(), 'Expected 1 Responses for TestWBStep1');
      lstWSResponses[0].Name = 'TestException';
      // AH_UDC_WorkbookStepResponse__c wbsResponse2 = AH_UDC_TestData.GetWorkbookStepResponseObject(lstWSResponses[0].WorkbookStep__c, '111111');      
      try
      {
         //update WorkbookStepReponse         
         update lstWSResponses[0];
      }
      catch(Exception ex)
      {
         System.assert(ex.getMessage().contains('Divide by 0'), 'Exception expected while deleting a response' + ex.getMessage());
      }
      Test.stopTest();
   }
}