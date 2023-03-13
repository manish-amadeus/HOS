/**
 * Name          : AH_UDC_REST_AmadeusFormResponse_TEST
 * Created By    : Amadeus Hospitality Services (vaishali.patel@Amadeus.com)
 * Created Date  : 2022-28-2
 * Description   : This is a test class for AH_UDC_REST_AmadeusFormResponse
 * Dependencies  : AH_UDC_REST_AmadeusFormResponse
 **/
@isTest
private class AH_UDC_REST_AmadeusFormResponse_TEST {
   private static AH_UDC_PropertyAccount__c oPA = null;
   private static NI_Documentation__c oNIDoc1 = null;
   private static NI_Documentation__c oNIDoc2 = null;
   private static NI_Documentation__c oNIDoc3 = null;
   private static AH_UDC_Workbook__c m_oWB1 = null;
   private static AH_UDC_Workbook__c m_oWB2 = null;
   private static AH_UDC_Workbook__c m_oWB3 = null;
   private static AH_UDC_WorkbookStep__c m_oWBS1 = null;
   private static AH_UDC_WorkbookStep__c m_oWBS2 = null;
   private static AH_UDC_WorkbookStep__c m_oWBS3 = null;
   private static AH_UDC_Form__c m_oForm = null;
   private static AH_UDC_Form__c m_oForm3 = null;
   private static User m_oUser = null;
   private static final Integer TotalRows = 50; //TotalQARecords = TotalRows * 15 

   @TestSetup
   private static void setup() {
      String uniqueId = AH_UDC_Shared.generateGUID();
      Account newAccount = AH_UDC_TestData.GetAccountObject(uniqueId);
      insert newAccount;

      Contact newContact = AH_UDC_TestData.GetContactObject(newAccount.id, uniqueId);
      insert newContact;

      List<User> listUsers = new List<User> ();
      //Build UDC Service User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE,
                                              'AFR_ServiceUser1', null, false));
      //Build Community User with chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                              'CommunityUser', newContact.Id, true));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         //AH_UDC_TestData.InsertWithRetries(listUsers);
         insert listUsers;

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SERVICE, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[1].Id);
      }
   }

   private static void testData1()
   {
      try {
         AH_UDC_InitializationHelper.Initialize('All');

         oPA = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
         insert oPA;

         oNIDoc1 = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
         oNIDoc1.AH_UDC_PropertyAccount__c = oPA.Id;
         insert oNIDoc1;

         String definition = '{"product":"","formulas":[],"sections":[{"title":"Instructions","apiname":"UDC0","repeat":"false","inline":"false","scrollable":"true","fields":' +
         '[{"title":"Add all inventory rooms (Guest Sleeping Rooms) in the list below.","name":"UDC1","type":"paragraph","tooltip":""},{"title":"Non Inventory rooms (Virtual Rooms) will be added in a different section.","name":"AHUDC_1_1","type":"paragraph","tooltip":""},' +
         '{"title":"Use Buildings?","name":"UDC2","type":"radiogroup","source":[{"id":"UDC2-0","name":"Yes"},{"id":"UDC2-1","name":"No"}],"defaultvalue":"Yes"},' +
         '{"title":"Will you be interfacing your phone system to APMS?","name":"UDC3","type":"radiogroup","tooltip":"Will you be interfacing your phone system to APMS?","source":[{"id":"UDC3-0","name":"Yes"},{"id":"UDC3-1","name":"No"}],"defaultvalue":""}]}]}';

         //pass recordtype id
         //Find Amadeusform Record Type
         Id AmadeusFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM).getRecordTypeId();
         m_oForm = AH_UDC_TestData.GetForm(definition, '', 'TestForm1', '');
         m_oForm.RecordTypeId = AmadeusFormRecordTypeId;
         insert m_oForm;

         // Find the "Workbook Sent" record type Id
         Id rtWbSentId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();

         // Create Workbook Sent
         String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
         m_oWB1 = AH_UDC_TestData.GetWorkbookObject(oNIDoc1.Id, 'TestWorkbook001', 'TestWorkbookDescription', product);
         m_oWB1.RecordtypeId = rtWbSentId;
         insert m_oWB1;

         // Find the Workbook Step Sent Record Type
         Id rtWbsSentId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();

         // Create Workbook Sent Step
         m_oWBS1 = AH_UDC_TestData.GetWorkbookStepObject(m_oWB1.Id, 'TEST001');
         m_oWBS1.RecordTypeId = rtWbsSentId;
         m_oWBS1.Workbook__c = m_oWB1.Id;
         m_oWBS1.Form__c = m_oForm.Id;
         insert m_oWBS1;

         m_oUser = [SELECT Id FROM User WHERE Username = :('TestCommunityUser@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      }
      catch(Exception exc) {
         System.debug(LoggingLevel.ERROR, 'Failed to correctly setup test data in testdata1(): ' + exc.getMessage());
         throw exc;
      }
   }

   private static void testData2() //This is a setup for Shared Data
   {
      try {
         testData1();

         oNIDoc2 = AH_UDC_TestData.GetNIDocObject('Test NI Document 2', Date.newInstance(2021, 3, 31));
         oNIDoc2.AH_UDC_PropertyAccount__c = oPA.Id;
         insert oNIDoc2;

         m_oForm.FormType__c = AH_UDC_Constants.FORM_TYPE_SHARED;
         update m_oForm;

         // Find the "Workbook Sent" record type Id
         Id rtWbSentId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();

         // Create Another Workbook Sent
         String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
         m_oWB2 = AH_UDC_TestData.GetWorkbookObject(oNIDoc2.Id, 'TestWorkbook002', 'TestWorkbookDescription', product);
         m_oWB2.RecordtypeId = rtWbSentId;
         insert m_oWB2;

         // Find the Workbook Step Sent Record Type
         Id rtWbsSentId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();


         // Create Workbook Sent Step
         m_oWBS2 = AH_UDC_TestData.GetWorkbookStepObject(m_oWB2.Id, 'TEST002');
         m_oWBS2.RecordTypeId = rtWbsSentId;
         m_oWBS2.Workbook__c = m_oWB2.Id;
         m_oWBS2.Form__c = m_oForm.Id;
         insert m_oWBS2;
      }
      catch(Exception exc) {
         System.debug(LoggingLevel.ERROR, 'Failed to correctly setup test data in testdata2(): ' + exc.getMessage());
         throw exc;
      }
   }

   private static void testData3() //This is a setup for Bulk Data for Grid
   {
      try {
         testData1();

         oNIDoc3 = AH_UDC_TestData.GetNIDocObject('Test NI Document 3', Date.newInstance(2021, 3, 31));
         oNIDoc3.AH_UDC_PropertyAccount__c = oPA.Id;
         insert oNIDoc3;

         //create form
         String definition = '{"product":"","formulas":[],"sections":[{"title":"Specify Rooms","apiname":"UDC9","repeat":"false","inline":"false","scrollable":"true","fields":[],"insidesections":[{"title":"Rooms","apiname":"UDC10","repeat":"true","scrollable":"true","gridview":"true","maxheight":"400","fields":[{"title":"Room No.","name":"UDC11","type":"number","width":"100","tooltip":"Room Number","validation":{"required":"true","maxlength":"5","number":"true"}},{"title":"Room Type","name":"UDC12","type":"dropdown","width":"100","tooltip":"Room Type","source":[],"dynamicsource":{"formid":"aWk740000004CBSCA2","formfield":"tfa_157"},"autocomplete":"true","validation":{"required":"true"}},{"title":"Building/Tower","name":"UDC14","width":"150","type":"dropdown","tooltip":"Building/Tower","source":[{"id":"UDC14-0","name":"Main"},{"id":"UDC14-1","name":"Tower"}],"autocomplete":"true"},{"title":"Floor","name":"UDC13","width":"100","type":"dropdown","tooltip":"Floor","source":[{"id":"UDC13-0","name":"1"},{"id":"UDC13-1","name":"2"},{"id":"UDC13-2","name":"3"}],"autocomplete":"true"},{"title":"Phone Extension","name":"UDC23","width":"150","type":"text","tooltip":"Phone Extension"},{"title":"Section","name":"UDC15","width":"100","type":"dropdown","tooltip":"Section","source":[{"id":"UDC15-0","name":"A"},{"id":"UDC15-1","name":"B"}],"autocomplete":"true"},{"title":"Attribute 1","width":"130","name":"UDC16","type":"dropdown","tooltip":"Attribute 1","source":[{"id":"UDC16-0","name":"Value 1"},{"id":"UDC16-1","name":"Value 2"}],"autocomplete":"true"},{"title":"Attribute 2","width":"130","name":"UDC17","type":"dropdown","tooltip":"Attribute 2","source":[{"id":"UDC17-0","name":"Value 1"},{"id":"UDC17-1","name":"Value 2"}],"autocomplete":"true"},{"title":"Attribute 3","name":"UDC18","width":"130","type":"dropdown","tooltip":"Attribute 3","source":[{"id":"UDC18-0","name":"Value 1"},{"id":"UDC18-1","name":"Value 2"}],"autocomplete":"true"},{"title":"Attribute 4","width":"130","name":"UDC19","type":"dropdown","tooltip":"Attribute 4","source":[{"id":"UDC19-0","name":"Value 1"},{"id":"UDC19-1","name":"Value 2"},{"id":"UDC19-2","name":"Value 3"}],"autocomplete":"true"},{"title":"PMS Room Code","width":"150","name":"UDC20","type":"text","tooltip":"PMS Room Code"},{"title":"Service Sequence","name":"UDC21","width":"150","type":"text","tooltip":"Service Sequence"}]}]}]}';
         Id AmadeusFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM).getRecordTypeId();
         m_oForm3 = AH_UDC_TestData.GetForm(definition, '', 'TestForm3', '');
         m_oForm3.RecordTypeId = AmadeusFormRecordTypeId;
         insert m_oForm3;

         // Find the "Workbook Sent" record type Id
         Id rtWbSentId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();

         // Create Another Workbook Sent
         String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
         m_oWB3 = AH_UDC_TestData.GetWorkbookObject(oNIDoc3.Id, 'TestWorkbook003', 'TestWorkbookDescription', product);
         m_oWB3.RecordtypeId = rtWbSentId;
         insert m_oWB3;

         // Find the Workbook Step Sent Record Type
         Id rtWbsSentId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();


         // Create Workbook Sent Step
         m_oWBS3 = AH_UDC_TestData.GetWorkbookStepObject(m_oWB3.Id, 'TEST003');
         m_oWBS3.RecordTypeId = rtWbsSentId;
         m_oWBS3.Workbook__c = m_oWB3.Id;
         m_oWBS3.Form__c = m_oForm3.Id;
         insert m_oWBS3;
      }
      catch(Exception exc) {
         System.debug(LoggingLevel.ERROR, 'Failed to correctly setup test data in testdata3(): ' + exc.getMessage());
         throw exc;
      }
   }
   private static void testData4() //This is a setup for dynamic radio/picklist check
   {
      try {
         testData1();
         //create form
         String definitionFA = '{"title":"UDCSB - Unit Test - Picklist - Source","FormAssemblyId":"4853245","CustomUrlId":"58c874ca-f1e4-4504-9878-b4b97af509ec","fields":[{"Name":"Security Code","APIName":"tfa_6","Repeat":"","Picklist":"false"},{"Name":"Token","APIName":"tfa_7","Repeat":"","Picklist":"false"},{"Name":"Parent Security Code","APIName":"tfa_9","Repeat":"","Picklist":"false"},{"Name":"Room Types","APIName":"tfa_1","Repeat":"tfa_1-D[0]","Picklist":"false"},{"Name":"Yes","APIName":"tfa_13","Repeat":""},{"Name":"No","APIName":"tfa_11","Repeat":""},{"Name":"Do you have Rooms","APIName":"tfa_10","Repeat":""}]}';
         m_oForm3 = AH_UDC_TestData.GetForm(definitionFA, '4853245', 'TestForm0', '58c874ca-f1e4-4504-9878-b4b97af509ec');
         insert m_oForm3;
         // Find the "Workbook Sent" record type Id
         Id rtWbsSentId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();

         //Update First Workbook Sent Step with FormAssembly Form
         m_oWBS1.Form__c = m_oForm3.Id;
         update m_oWBS1;

         Id recordTypeIdResponse = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_AMADEUS_FORM).getRecordTypeId();

         //Create response and responseQA for form assembly form (step1) and consumed by step2 - amadeusform
         AH_UDC_Response__c m_oR = new AH_UDC_Response__c(
                                                          Responded__c = Datetime.now(),
                                                          RecordTypeId = recordTypeIdResponse,
                                                          Responder__c = UserInfo.getUserId(),
                                                          IsComplete__c = true);
         insert m_oR;

         AH_UDC_WorkbookStepResponse__c m_oWSR = AH_UDC_TestData.GetWorkbookStepResponseObject(m_oWBS1.Id, m_oR.Id);
         insert m_oWSR;

         List<AH_UDC_ResponseQA__c> lstRQA = new List<AH_UDC_ResponseQA__c> ();
         lstRQA.add(AH_UDC_TestData.GetStepResponseQAObject(m_oR.Id, 'Do you have Rooms', 'tfa_10', 'Yes', 'tfa_13'));
         lstRQA.add(AH_UDC_TestData.GetStepResponseQAObject(m_oR.Id, 'Room Types[0]', 'tfa_1[0]', 'Room Type 1', ''));
         lstRQA.add(AH_UDC_TestData.GetStepResponseQAObject(m_oR.Id, 'Room Types[1]', 'tfa_1[1]', 'Room Type 2', ''));
         insert lstRQA;

         //create amadeus form with dynamic source
         String definitionAF = '{"product":"","formulas":[],"sections":[{"title":"Floors","apiname":"UDC0","gridview":"false","inline":"true","scrollable":"true","insidesections":[{"title":"Rooms","apiname":"UDC1","gridview":"true","scrollable":"true","fields":[{"title":"Room #","name":"UDC2","type":"number","width":"200","labelabove":"true","tooltip":"Room Number","defaultvalue":"","placeholder":"Room Number","validation":{"required":"true","maxlength":"6","minlength":"3","onlynumber":"true"}},{"type":"dropdown","name":"UDC3","title":"Room Type","width":120,"source":[],"autocomplete":true,"dynamicsource":{"formid":"' + m_oForm3.Id + '","formField":"tfa_1"}},{"type":"dropdown","name":"UDC4","title":"Floor no.","width":120,"source":[{"name":"Floor1","id":"UDC4-0"},{"name":"Floor2","id":"UDC4-1"}],"autocomplete":true},{"title":"Room Code","name":"UDC5","type":"text","width":"200","labelabove":"true","tooltip":"Room Code","defaultvalue":""},{"title":"Extension","name":"UDC6","type":"text","width":"200","labelabove":"true","tooltip":"Extension","defaultvalue":"","placeholder":"Extension"}]}],"fields":[{"title":"Floor #","name":"UDC7","type":"text","width":"200","labelabove":"true","tooltip":"Floor Number","defaultvalue":"","placeholder":"Floor Number"},{"width":"200","validation":null,"type":"dropdown","tooltip":"Floor No?","title":"Floor No?","source":[{"name":"Yes","id":"UDC8-0"},{"name":"No","id":"UDC8-1"}],"placeholder":"","name":"UDC8","labelabove":"true","defaultvalue":"","autocomplete":null},{"title":"Dynamic RoomType?","name":"UDC11","type":"radiogroup","width":"200","labelabove":"true","tooltip":"Do you have Rooms?","defaultvalue":"no","placeholder":"","source":[{"id":"UDC11-0","name":"Yes"},{"id":"UDC11-1","name":"No"}]}]}]}';
         Id AmadeusFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM).getRecordTypeId();
         m_oForm.Definition__c = definitionAF;
         update m_oForm;

         // Create Workbook Sent Step
         m_oWBS2 = AH_UDC_TestData.GetWorkbookStepObject(m_oWB1.Id, 'TEST002');
         m_oWBS2.RecordTypeId = rtWbsSentId;
         m_oWBS2.Workbook__c = m_oWB1.Id;
         m_oWBS2.Form__c = m_oForm.Id;
         insert m_oWBS2;
      }
      catch(Exception exc) {
         System.debug(LoggingLevel.ERROR, 'Failed to correctly setup test data in testdata4(): ' + exc.getMessage());
         throw exc;
      }
   }

   @isTest
   private static void TestGetForDymnamicFields() { //Test for dynamic radio/picklist
      testData4();
      string token = AH_UDC_Shared.CreateStepToken(m_oWB1.SecurityCode__c, m_oForm.id, m_oWBS1.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL         
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_AmadeusFormResponse.get();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse resp = null;
         resp = (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse.class);

         Test.stopTest();

         List<AH_UDC_Log__c> logMessages = [SELECT Id, LogText__c FROM AH_UDC_Log__c];
         System.assertEquals('200', resp.statusCode, 'Expected 200 Response: ' + resp.message);
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }

   @isTest
   private static void TestPostBulkData() {
      testData3();
      String strJSON = '';
      string token = AH_UDC_Shared.CreateStepToken(m_oWB3.SecurityCode__c, m_oForm3.id, m_oWBS3.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      for (integer row = 0; row<TotalRows; row++)
      {
         strJSON += '{\\"QF\\":\\"UDC11_0_' + row + '\\",\\"Q\\":\\"Room No. 0\\",\\"AF\\":\\"\\",\\"A\\":\\"' + (row + 1) + '\\"},' +
         '{\\"QF\\":\\"UDC12_0_' + row + '\\",\\"Q\\":\\"Room Type 0\\",\\"AF\\":\\"UDC12-0\\",\\"A\\":\\"Single Room\\"},' +
         '{\\"QF\\":\\"UDC13_0_' + row + '\\",\\"Q\\":\\"Building/Tower 0\\",\\"AF\\":\\"UDC13-0\\",\\"A\\":\\"1\\"},' +
         '{\\"QF\\":\\"UDC14_0_' + row + '\\",\\"Q\\":\\"Floor 0\\",\\"AF\\":\\"UDC14-0\\",\\"A\\":\\"1\\"},' +
         '{\\"QF\\":\\"UDC15_0_' + row + '\\",\\"Q\\":\\"Phone Extension 0\\",\\"AF\\":\\"\\",\\"A\\":\\"1112\\"},' +
         '{\\"QF\\":\\"UDC16_0_' + row + '\\",\\"Q\\":\\"Section 0\\",\\"AF\\":\\"UDC16-0\\",\\"A\\":\\"A\\"},' +
         '{\\"QF\\":\\"UDC17_0_' + row + '\\",\\"Q\\":\\"Attribute 1 0\\",\\"AF\\":\\"UDC17-1\\",\\"A\\":\\"Value 2\\"},' +
         '{\\"QF\\":\\"UDC18_0_' + row + '\\",\\"Q\\":\\"Attribute 2 0\\",\\"AF\\":\\"UDC18-0\\",\\"A\\":\\"Value 1\\"},' +
         '{\\"QF\\":\\"UDC19_0_' + row + '\\",\\"Q\\":\\"Attribute 3 0\\",\\"AF\\":\\"UDC19-0\\",\\"A\\":\\"Value 1\\"},' +
         '{\\"QF\\":\\"UDC20_0_' + row + '\\",\\"Q\\":\\"Attribute 4 0\\",\\"AF\\":\\"UDC20-0\\",\\"A\\":\\"Value 1\\"},' +
         '{\\"QF\\":\\"UDC21_0_' + row + '\\",\\"Q\\":\\"PMS Room Code 0\\",\\"AF\\":\\"\\",\\"A\\":\\"111112\\"},' +
         '{\\"QF\\":\\"UDC22_0_' + row + '\\",\\"Q\\":\\"Service Sequence 0\\",\\"AF\\":\\"\\",\\"A\\":\\"112\\"},' +
         '{\\"QF\\":\\"UDC23_0_' + row + '\\",\\"Q\\":\\"Guestroom Category 0\\",\\"AF\\":\\"UDC20-0\\",\\"A\\":\\"Category 1\\"},' +
         '{\\"QF\\":\\"UDC24_0_' + row + '\\",\\"Q\\":\\"Maintenance 0\\",\\"AF\\":\\"\\",\\"A\\":\\"true\\"},' +
         '{\\"QF\\":\\"UDC25_0_' + row + '\\",\\"Q\\":\\"Description 0\\",\\"AF\\":\\"\\",\\"A\\":\\"asdasadf\\"},';
      }

      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof('{"token" : "' + token + '", "ResponseQAs":[{"QAJson":"' + strJSON.left(strJSON.length() - 1) + '"}]}'); //,"isComplete":"false"
         RestContext.request = req;
         RestContext.response = res;

         AH_UDC_REST_AmadeusFormResponse.post();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse resp =
         (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }

   }

   @isTest
   private static void TestPost() {
      testData1();

      string token = AH_UDC_Shared.CreateStepToken(m_oWB1.SecurityCode__c, m_oForm.id, m_oWBS1.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type

         string reqJson = '{"token" : "' + token + '","ResponseQAs":[{' +
         '"QAJson":"{\\"SO\\":\\"1\\",\\"QF\\":\\"UDC2\\",\\"Q\\":\\"Use Buildings?\\",\\"A\\":\\"No\\",\\"AF\\":\\"UDC2-0\\"},' +
         '{\\"SO\\":\\"2\\",\\"QF\\":\\"UDC3\\",\\"Q\\":\\"Will you be interfacing your phone system to APMS?\\",\\"A\\":\\"Yes\\",\\"AF\\":\\"UDC3-0\\"}"}]}';

         req.requestBody = Blob.valueof(reqJson);

         RestContext.request = req;
         RestContext.response = res;

         AH_UDC_REST_AmadeusFormResponse.post();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse resp =
         (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPostComplete() {
      testData1();

      string token = AH_UDC_Shared.CreateStepToken(m_oWB1.SecurityCode__c, m_oForm.id, m_oWBS1.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type

         string reqJson = '{"token" : "' + token + '","ResponseQAs":[{' +
         '"QAJson":"{\\"SO\\":\\"1\\",\\"QF\\":\\"UDC2\\",\\"Q\\":\\"Use Buildings?\\",\\"A\\":\\"No\\",\\"AF\\":\\"UDC2-0\\"},' +
         '{\\"SO\\":\\"2\\",\\"QF\\":\\"UDC3\\",\\"Q\\":\\"Will you be interfacing your phone system to APMS?\\",\\"A\\":\\"Yes\\",\\"AF\\":\\"UDC3-0\\"}"}]}';
         req.requestBody = Blob.valueof(reqJson);

         RestContext.request = req;
         RestContext.response = res;

         AH_UDC_REST_AmadeusFormResponse.post();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse resp =
         (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse.class);
         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');

         //2nd call
         AH_UDC_TestData.ClearLogs();
         req = new RestRequest();
         req.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         string responseId = resp.responseId;

         reqJson = '{"token" : "' + token + '","ResponseQAs":[{' +
         '"QAJson":"{\\"SO\\":\\"1\\",\\"QF\\":\\"UDC2\\",\\"Q\\":\\"Use Buildings?\\",\\"A\\":\\"No\\",\\"AF\\":\\"UDC2-0\\"},' +
         '{\\"SO\\":\\"2\\",\\"QF\\":\\"UDC3\\",\\"Q\\":\\"Will you be interfacing your phone system to APMS?\\",\\"A\\":\\"Yes\\",\\"AF\\":\\"UDC3-0\\"}"}],' +
         '"isComplete":"true","responseId":"' + resp.responseId + '"}';
         req.requestBody = Blob.valueof(reqJson);
         RestContext.request = req;
         RestContext.response = res;
         AH_UDC_REST_AmadeusFormResponse.post();

         resp = (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');
         System.assertEquals(responseId, resp.responseId, 'Expected same Response Id');
         System.assertEquals('true', resp.isComplete, 'Expected isComplete equals to true');
         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPostSharedResponse() {
      testData2(); //This sets up 2 Workbooks with steps for a shared form

      string token = AH_UDC_Shared.CreateStepToken(m_oWB2.SecurityCode__c, m_oForm.id, m_oWBS2.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         string reqJson = '{"token" : "' + token + '","ResponseQAs":[{' +
         '"QAJson":"{\\"SO\\":\\"1\\",\\"QF\\":\\"UDC2\\",\\"Q\\":\\"Use Buildings?\\",\\"A\\":\\"No\\",\\"AF\\":\\"UDC2-0\\"},' +
         '{\\"SO\\":\\"2\\",\\"QF\\":\\"UDC3\\",\\"Q\\":\\"Will you be interfacing your phone system to APMS?\\",\\"A\\":\\"Yes\\",\\"AF\\":\\"UDC3-0\\"}"}],"isComplete":"false"}';
         req.requestBody = Blob.valueof(reqJson);
         RestContext.request = req;
         RestContext.response = res;

         AH_UDC_REST_AmadeusFormResponse.post();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse resp =
         (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');

         // List<AH_UDC_Response__c> responses = [SELECT Id, Name FROM AH_UDC_Response__c];

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }


   @isTest
   private static void TestPostFailedWriteLog() {
      testData1();

      string token = AH_UDC_Shared.CreateStepToken(m_oWB1.SecurityCode__c, m_oForm.id, m_oWBS1.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         req.requestBody = Blob.valueof('writeQueuedLogsException');
         RestContext.request = req;
         RestContext.response = res;

         AH_UDC_REST_AmadeusFormResponse.post();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse resp =
         (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse.class);

         Test.stopTest();

         System.assertEquals('500', resp.statusCode, 'Expected 500 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages exist and were not expected');
      }
   }

   @isTest
   private static void TestPostBadToken() {
      testData1();

      string unknownSecurityCode = AH_UDC_Shared.GetSecurityCode();
      string token = AH_UDC_Shared.CreateStepToken(unknownSecurityCode, m_oForm.id, m_oWBS1.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         string reqJson = '{"token" : "' + token + '","ResponseQAs":[{' +
         '"QAJson":"{\\"SO\\":\\"1\\",\\"QF\\":\\"UDC2\\",\\"Q\\":\\"Use Buildings?\\",\\"A\\":\\"No\\",\\"AF\\":\\"UDC2-0\\"},' +
         '{\\"SO\\":\\"2\\",\\"QF\\":\\"UDC3\\",\\"Q\\":\\"Will you be interfacing your phone system to APMS?\\",\\"A\\":\\"Yes\\",\\"AF\\":\\"UDC3-0\\"}"}],"isComplete":"false"}';
         req.requestBody = Blob.valueof(reqJson);
         RestContext.request = req;
         RestContext.response = res;

         AH_UDC_REST_AmadeusFormResponse.post();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse resp =
         (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse.class);

         Test.stopTest();

         System.assertEquals('404', resp.statusCode, 'Expected 404 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Message for Exception not found but expected');
      }
   }

   @isTest
   private static void TestPostException() {
      testData1();

      string token = AH_UDC_Shared.CreateStepToken(m_oWB1.SecurityCode__c, m_oForm.id, m_oWBS1.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         req.httpMethod = 'POST'; //HTTP Request Type
         RestContext.request = req;
         RestContext.response = res;

         AH_UDC_REST_AmadeusFormResponse.post();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse resp =
         (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse.class);

         Test.stopTest();

         System.assertEquals('500', resp.statusCode, 'Expected 500 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(1, logMessages.size(), 'Log Message for Exception not found but expected');
      }
   }

   @isTest
   private static void TestGet() {
      testData1();

      string token = AH_UDC_Shared.CreateStepToken(m_oWB1.SecurityCode__c, m_oForm.id, m_oWBS1.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {

         RestRequest reqPost = new RestRequest();
         RestResponse resPost = new RestResponse();
         reqPost.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         reqPost.httpMethod = 'POST'; //HTTP Request Type
         string reqJson = '{"token" : "' + token + '","ResponseQAs":[{' +
         '"QAJson":"{\\"SO\\":\\"1\\",\\"QF\\":\\"UDC2\\",\\"Q\\":\\"Use Buildings?\\",\\"A\\":\\"No\\",\\"AF\\":\\"UDC2-1\\"},' +
         '{\\"SO\\":\\"2\\",\\"QF\\":\\"UDC3\\",\\"Q\\":\\"Will you be interfacing your phone system to APMS?\\",\\"A\\":\\"Yes\\",\\"AF\\":\\"UDC3-0\\"}"}],"isComplete":"false"}';
         reqPost.requestBody = Blob.valueof(reqJson);
         RestContext.request = reqPost;
         RestContext.response = resPost;

         AH_UDC_REST_AmadeusFormResponse.post();

         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL         
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_AmadeusFormResponse.get();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse resp = null;
         resp = (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse.class);

         Test.stopTest();

         List<AH_UDC_Log__c> logMessages = [SELECT Id, LogText__c FROM AH_UDC_Log__c];
         System.assertEquals('200', resp.statusCode, 'Expected 200 Response: ' + resp.message);
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }

   @isTest
   private static void TestGetWithRequestId() {
      testData3();
      String strJSON = '';
      string token = AH_UDC_Shared.CreateStepToken(m_oWB3.SecurityCode__c, m_oForm3.id, m_oWBS3.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      for (integer row = 0; row<TotalRows; row++)
      {
         strJSON += '{\\"QF\\":\\"UDC11_0_' + row + '\\",\\"Q\\":\\"Room No. 0\\",\\"AF\\":\\"\\",\\"A\\":\\"' + (row + 1) + '\\"},' +
         '{\\"QF\\":\\"UDC12_0_' + row + '\\",\\"Q\\":\\"Room Type 0\\",\\"AF\\":\\"UDC12-0\\",\\"A\\":\\"Single Room\\"},' +
         '{\\"QF\\":\\"UDC13_0_' + row + '\\",\\"Q\\":\\"Building/Tower 0\\",\\"AF\\":\\"UDC13-0\\",\\"A\\":\\"1\\"},' +
         '{\\"QF\\":\\"UDC14_0_' + row + '\\",\\"Q\\":\\"Floor 0\\",\\"AF\\":\\"UDC14-0\\",\\"A\\":\\"1\\"},' +
         '{\\"QF\\":\\"UDC15_0_' + row + '\\",\\"Q\\":\\"Phone Extension 0\\",\\"AF\\":\\"\\",\\"A\\":\\"1112\\"},' +
         '{\\"QF\\":\\"UDC16_0_' + row + '\\",\\"Q\\":\\"Section 0\\",\\"AF\\":\\"UDC16-0\\",\\"A\\":\\"A\\"},' +
         '{\\"QF\\":\\"UDC17_0_' + row + '\\",\\"Q\\":\\"Attribute 1 0\\",\\"AF\\":\\"UDC17-1\\",\\"A\\":\\"Value 2\\"},' +
         '{\\"QF\\":\\"UDC18_0_' + row + '\\",\\"Q\\":\\"Attribute 2 0\\",\\"AF\\":\\"UDC18-0\\",\\"A\\":\\"Value 1\\"},' +
         '{\\"QF\\":\\"UDC19_0_' + row + '\\",\\"Q\\":\\"Attribute 3 0\\",\\"AF\\":\\"UDC19-0\\",\\"A\\":\\"Value 1\\"},' +
         '{\\"QF\\":\\"UDC20_0_' + row + '\\",\\"Q\\":\\"Attribute 4 0\\",\\"AF\\":\\"UDC20-0\\",\\"A\\":\\"Value 1\\"},' +
         '{\\"QF\\":\\"UDC21_0_' + row + '\\",\\"Q\\":\\"PMS Room Code 0\\",\\"AF\\":\\"\\",\\"A\\":\\"111112\\"},' +
         '{\\"QF\\":\\"UDC22_0_' + row + '\\",\\"Q\\":\\"Service Sequence 0\\",\\"AF\\":\\"\\",\\"A\\":\\"112\\"},' +
         '{\\"QF\\":\\"UDC23_0_' + row + '\\",\\"Q\\":\\"Guestroom Category 0\\",\\"AF\\":\\"UDC20-0\\",\\"A\\":\\"Category 1\\"},' +
         '{\\"QF\\":\\"UDC24_0_' + row + '\\",\\"Q\\":\\"Maintenance 0\\",\\"AF\\":\\"\\",\\"A\\":\\"true\\"},' +
         '{\\"QF\\":\\"UDC25_0_' + row + '\\",\\"Q\\":\\"Description 0\\",\\"AF\\":\\"\\",\\"A\\":\\"asdasadf\\"},';
      }
      System.runAs(UDCServiceUser1)
      {

         //Create data and save
         RestRequest reqPost = new RestRequest();
         RestResponse resPost = new RestResponse();
         reqPost.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         reqPost.httpMethod = 'POST'; //HTTP Request Type
         reqPost.requestBody = Blob.valueof('{"token" : "' + token + '", "ResponseQAs":[{"SortOrder":"1","QAJson":"' + strJSON.left(strJSON.length() - 1) + '"}]}');
         RestContext.request = reqPost;
         RestContext.response = resPost;

         AH_UDC_REST_AmadeusFormResponse.post();
         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse respPost =
         (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponsePostResponse.class);
         System.assertEquals('200', respPost.statusCode, 'Expected 200 Response');

         Test.startTest();
         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL         
         reqG.params.put('token', token);
         reqG.params.put('responseId', respPost.responseId); //get responseId from post
         reqG.params.put('startSortOrder', '1'); //set starting SortOrder
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_AmadeusFormResponse.get();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse resp = null;
         resp = (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse.class);

         Test.stopTest();

         List<AH_UDC_Log__c> logMessages = [SELECT Id, LogText__c FROM AH_UDC_Log__c];
         System.assertEquals('200', resp.statusCode, 'Expected 200 Response: ' + resp.message);
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }

   @isTest
   private static void TestGetException() {
      testData1();

      string token = AH_UDC_Constants.FORM_TOKEN_PREFIX + 'TestException';

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {

         Test.startTest();
         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_AmadeusFormResponse.get();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse resp = null;
         resp = (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse) JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse.class);

         Test.stopTest();

         System.assertEquals('500', resp.statusCode, 'Expected 500 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id, LogText__c FROM AH_UDC_Log__c];
         System.assertEquals(1, logMessages.size(), 'More Log Messages exist than were expected');
      }
   }

   @isTest
   private static void TestGetNoPrior() {
      testData1();

      string token = AH_UDC_Shared.CreateStepToken(m_oWB1.SecurityCode__c, m_oForm.id, m_oWBS1.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_AmadeusFormResponse.get();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse resp =
         (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }

   @isTest
   private static void TestGetNoPriorButNoQA() {
      testData1();

      string token = AH_UDC_Shared.CreateStepToken(m_oWB1.SecurityCode__c, m_oForm.id, m_oWBS1.id);

      AH_UDC_TestData.ClearLogs();

      //Create response without QAs
      Id wbRTResponseId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_AMADEUS_FORM).getRecordTypeId();

      //Create Response record for Step1
      AH_UDC_Response__c response = new AH_UDC_Response__c(Responded__c = Datetime.now());
      insert response;

      //Create  Response record for Step1
      AH_UDC_WorkbookStepResponse__c wbsResponse = new AH_UDC_WorkbookStepResponse__c(
                                                                                      Response__c = response.Id,
                                                                                      WorkbookStep__c = m_oWBS1.id,
                                                                                      IsMostRecentResponse__c = true
      );
      insert wbsResponse;

      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_AmadeusFormResponse.get();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse resp =
         (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse.class);

         Test.stopTest();

         System.assertEquals('200', resp.statusCode, 'Expected 200 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }

   @isTest
   private static void TestGetNoToken() {
      testData1();

      string token = AH_UDC_Constants.FORM_TOKEN_PREFIX;

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         reqG.params.put('token', 'notthetokenprefix');
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_AmadeusFormResponse.get();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse resp =
         (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse.class);

         Test.stopTest();

         System.assertEquals('400', resp.statusCode, 'Expected 400 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }

   @isTest
   private static void TestGetEmptyToken() {
      testData1();

      string token = AH_UDC_Constants.FORM_TOKEN_PREFIX;

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_AmadeusFormResponse.get();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse resp =
         (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse.class);

         Test.stopTest();

         System.assertEquals('400', resp.statusCode, 'Expected 400 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }

   @isTest
   private static void TestGetBadToken() {
      testData1();
      string unknownSecurityCode = AH_UDC_Shared.GetSecurityCode();
      string token = AH_UDC_Shared.CreateStepToken(unknownSecurityCode, m_oForm.id, m_oWBS1.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_AmadeusFormResponse.get();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse resp =
         (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse.class);

         Test.stopTest();

         System.assertEquals('404', resp.statusCode, 'Expected 404 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }
   @isTest
   private static void TestGetBadTokenWithoutSecurityCode() {
      testData1();
      string token = AH_UDC_Shared.CreateStepToken('', m_oForm.id, m_oWBS1.id);

      AH_UDC_TestData.ClearLogs();
      User UDCServiceUser1 = [SELECT Id FROM user WHERE LastName = 'AFR_ServiceUser1'];
      System.runAs(UDCServiceUser1)
      {
         Test.startTest();

         RestRequest reqG = new RestRequest();
         RestResponse resG = new RestResponse();
         reqG.requestURI = '/services/apexrest/AH_UDC_AmadeusFormResponse'; //Request URL
         reqG.params.put('token', token);
         reqG.httpMethod = 'GET'; //HTTP Request Type
         RestContext.request = reqG;
         RestContext.response = resG;

         AH_UDC_REST_AmadeusFormResponse.get();

         AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse resp =
         (AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse)
         JSON.deserialize(RestContext.response.responseBody.toString(), AH_UDC_REST_AmadeusFormResponse.AmadeusFormResponseGetResponse.class);

         Test.stopTest();

         System.assertEquals('400', resp.statusCode, 'Expected 400 Response');

         List<AH_UDC_Log__c> logMessages = [SELECT Id FROM AH_UDC_Log__c];
         System.assertEquals(0, logMessages.size(), 'Log Messages found and not expected: ' + logMessages);
      }
   }
}