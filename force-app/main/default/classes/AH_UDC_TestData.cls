<<<<<<< HEAD
<<<<<<< HEAD
/***********************************************************************************************
  Name            : AH_UDC_TestData
  Author          : Sanjay Parmar
  Created Date    : 1-Feb-2021
  NICC Reference  : 
  Description     : Common class to prepare test data for test class execution
  Modified        : 2021-07-03, Rob Stevens, Adding Create user methods for users needed for tests
 ************************************************************************************************/
public without sharing class AH_UDC_TestData {

   private static List<String> m_listUserEmails = new List<String> ();

   public static void clearLogs()
   {
      if (test.isRunningTest()) {
         List<AH_UDC_Log__c> logs = [SELECT Id FROM AH_UDC_Log__c LIMIT 2000];
         AH_UDC_SystemContext.deleteSobjList(logs);
      }
   }

   public static string getFormDefinitionTokenTFAFieldAPIName = 'tfa_16';
   public static String getFormDefinition() {
      return '{"title":"UDCSB - SERVICES - RFP Toolkit - Section Names","FormAssemblyId":"4853168","CustomUrlId":"58c874ca-f1e4-4504-9878-b4b97af509ec","fields":[{"Name":"Token","APIName":"tfa_16","Repeat":"","Picklist":"false"},{"Name":"Security Code","APIName":"tfa_1","Repeat":"","Picklist":"false"},{"Name":"Parent Security Code","APIName":"tfa_17","Repeat":"","Picklist":"false"},{"Name":"Custom Section Name","APIName":"tfa_6","Repeat":"tfa_19[0]","Picklist":"false"},{"Name":"Section Title","APIName":"tfa_18","Repeat":"tfa_19[0]","Picklist":"false"},{"Name":"Yes","APIName":"tfa_11","Repeat":""},{"Name":"No, Specify Custom Section Names","APIName":"tfa_12","Repeat":""},{"Name":"Use the Default Section Names","APIName":"tfa_10","Repeat":""}]}';
   }

   public static String getFormDefinition_DefaultStep1() {
      return '{"title":"UDCSB - Unit Test - Default - Step1","FormAssemblyId":"4853372","CustomUrlId":"4853372","fields":[{"Name":"Token","APIName":"tfa_1","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Security Code","APIName":"tfa_2","Repeat":"","DefaultValue":"Please do not change this field.","Picklist":"false","InputType":"Text"},{"Name":"Parent Security Code","APIName":"tfa_3","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Product","APIName":"tfa_5","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Future use","APIName":"tfa_6","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Future Use","APIName":"tfa_7","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Test Default","APIName":"tfa_8","Repeat":"","Picklist":"false","InputType":"Text"}]}';
   }

   public static String GetFormDefinition_DefaultStep2() {
      return '{"title":"UDCSB - Unit Test - Default - Step2","FormAssemblyId":"4853373","CustomUrlId":"4853373","fields":[{"Name":"Token","APIName":"tfa_1","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Security Code","APIName":"tfa_2","Repeat":"","DefaultValue":"Please do not change this field.","Picklist":"false","InputType":"Text"},{"Name":"Parent Security Code","APIName":"tfa_3","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Product","APIName":"tfa_5","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Future use","APIName":"tfa_6","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Future Use","APIName":"tfa_7","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Default value from step1","APIName":"tfa_14","Repeat":"","DefaultValue":"DEFAULT|4853372|tfa_8","Picklist":"false","InputType":"Text"}]}';
   }


   // Returns back a list of picklist values for the PRODUCT field on the Workbook
   public static List<Schema.PicklistEntry> getProductPicklist() {
      List<Schema.PicklistEntry> pickListEntry = null;
      Schema.DescribeFieldResult fieldResult = AH_UDC_Workbook__c.Product__c.getDescribe();
      if (fieldResult == null) { throw new TestDataException('Unable to retrieve the picklist for the Workbook field PRODUCT'); }

      return fieldResult.getPicklistValues();
   }

   //Return Account with values assigned
   public static Account GetAccountObject(string uniqueId) {
      if (uniqueId.toUpperCase().equals('GUID')) {
         uniqueId = AH_UDC_Shared.generateGUID();
      }
      return GetAccountObject(uniqueId, uniqueId + 'Test', uniqueId.left(30), 'US', '03801', 'NH', uniqueId + ' Ave');
   }

   private static Account GetAccountObject(String AccountName, String Industry, String BillingCity, String BillingCountry,
                                           String BillingPostalCode, String BillingState, String BillingStreet) {
      Account objAccount = new Account();
      objAccount.Name = AccountName;
      objAccount.Industry = Industry;
      objAccount.BillingCity = BillingCity;
      objAccount.BillingCountry = BillingCountry;
      objAccount.BillingPostalCode = BillingPostalCode;
      objAccount.BillingState = BillingState;
      objAccount.BillingStreet = BillingStreet;
      return objAccount;
   }

   public static AH_UDC_PropertyAccount__c GetPropertyObject(String AccountName, String BillingCity, String BillingCountry,
                                                             String BillingPostalCode, String BillingState, String BillingStreet, String Address1) {
      AH_UDC_PropertyAccount__c objProperty = new AH_UDC_PropertyAccount__c();
      objProperty.PropertyName__c = AccountName;
      objProperty.City__c = BillingCity;
      objProperty.Country__c = BillingCountry;
      objProperty.PostalCode__c = BillingPostalCode;
      objProperty.StateProvince__c = BillingState;
      objProperty.Address__c = Address1;
      return objProperty;
   }

   public static Contact GetContactObject(ID AccountId, string uniqueId) { //contact firstname and lastname combined should be less than 40 characters
      return GetContactObject(AccountId, 'TestCommunityUser', uniqueId.left(20), 'US', 'Portsmouth', '03801', 'NH', uniqueId);
   }
   //Return Contact with values assigned
   public static Contact GetContactObject(Id AccountId, String FirstName, String LastName, String MailingCountry,
                                          String MailingCity, String MailingPostalCode, String MailingState, String MailingStreet) {
      Contact objContact = new Contact();
      objContact.AccountId = AccountId;
      objContact.FirstName = FirstName;
      objContact.LastName = LastName;
      objContact.MailingCountry = MailingCountry;
      objContact.MailingCity = MailingCity;
      objContact.MailingPostalCode = MailingPostalCode;
      objContact.MailingState = MailingState;
      objContact.MailingStreet = MailingStreet;
      return objContact;
   }

   //Return Contact with values assigned
   public static Contact GetContactObject(Account acct, String FirstName, String LastName, String MailingCountry,
                                          String MailingCity, String MailingPostalCode, String MailingState, String MailingStreet) {
      Contact objContact = new Contact();
      objContact.Account = acct;
      objContact.AccountId = acct.Id;
      objContact.FirstName = FirstName;
      objContact.LastName = LastName;
      objContact.MailingCountry = MailingCountry;
      objContact.MailingCity = MailingCity;
      objContact.MailingPostalCode = MailingPostalCode;
      objContact.MailingState = MailingState;
      objContact.MailingStreet = MailingStreet;
      return objContact;
   }

   public static void delay(Long milliSeconds)
   {
      if (!Test.isRunningTest()) return;

      Long timeDiff = 0;
      DateTime firstTime = System.now();
      do
      {
         timeDiff = System.now().getTime() - firstTime.getTime();
      }
      while (timeDiff <= milliSeconds);
   }

   public static void InsertWithRetries(List<SObject> l)
   {
      Integer retryCount = 0;
      Boolean success = false;
      while (!success) {
         try {
            insert l;
            success = true;
         }
         catch(Exception exc) {
            retryCount++;
            delay(Integer.valueof((Math.random() * 200))); //milliseconds
            if (retryCount > 100) {
               throw new TestDataException('Failed to create Insert record(s): ' + exc.getMessage());
            }
            System.debug('InsertWithRetries: retrying: ' + retryCount);
         }
      }
   }

   // Generates a User Name that will be unique, that can be used when creating a test user
   public static String generateUniqueUserName() {
      String orgId = UserInfo.getOrganizationId();
      String datetimeString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
      Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
      String uniqueName = orgId + datetimeString + randomInt;

      return uniqueName;
   }

   public static void AddPermissionSetToUser(String permissionsetName, Id userId) {
      List<PermissionSet> oPermissionsets = [SELECT Id FROM PermissionSet WHERE Name = :permissionsetName];
      system.assertEquals(1, oPermissionsets.size(), 'Could not find permissionset: ' + permissionsetName);

      insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = oPermissionsets[0].Id);
   }

   public static User BuildUser(string profileName, string permissionsetName, string uniqueId, ID contactId, Boolean isCommunityUser) {
      try
      {
         string externalSalesforceUsername = null;
         if (uniqueId.toUpperCase().equals('GUID')) {
            uniqueId = AH_UDC_Shared.generateGUID();
         }
         if (uniqueId.toUpperCase().startsWith('{GUID}')) {
            externalSalesforceUsername = uniqueId.removeStart('{GUID}');
            uniqueId = AH_UDC_Shared.generateGUID();
         }
         User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
         oCurrentUser.ContactId = null;
         User oNewUser = null;

         System.runAs(oCurrentUser)
         {
            //Get Profile
            List<Profile> oProfiles = [SELECT Id FROM Profile WHERE Name = :profileName];
            system.assertEquals(1, oProfiles.size(), 'Could not find profile: ' + profileName);

            // Create User record
            string userName = 'Test' + uniqueId + '@amadeus.com';
            if (isCommunityUser) { userName += AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX; }
            oNewUser = AH_UDC_TestData.GetUserObject(contactId, oProfiles[0].Id, 'Test' + permissionsetName, uniqueId, uniqueId, 'Test' + uniqueId + '@amadeus.com', userName);
            oNewUser.External_Salesforce_Username__c = externalSalesforceUsername; //This is used to allow Test Methods to retrieve the user
         }
         return oNewUser;
      }
      catch(Exception exc) {
         System.Assert(false, 'CreateUser Exception: ' + exc.getMessage());
         return null;
      }
   }
      
   //Return User with values assigned
   private static User getUserObject(Id ContactId, Id ProfileId, String FirstName, String LastName, String Alias, String strEmail, String UserName) {

      if (m_listUserEmails.Contains(strEmail)) {
         System.assert(false, 'Email address already exists');
      }

      m_listUserEmails.add(strEmail);

      User objUser = new User(
                              ContactId = ContactId,
                              profileid = ProfileId,
                              firstname = FirstName,
                              lastname = LastName,
                              alias = Alias.left(8),
                              email = strEmail,
                              emailencodingkey = 'UTF-8',
                              languagelocalekey = 'en_US',
                              localesidkey = 'en_US',
                              country = 'United States',
                              IsActive = true,
                              timezonesidkey = 'America/Los_Angeles',
                              username = UserName,
                              No_AD_Account_Standard_User__c = true
      );
      return objUser;
   }

   //Return NI_Documentation__c with values assigned
   public static NI_Documentation__c GetNIDocObject(String NIDocName, Date DueDate) {
      if (NIDocName.toUpperCase().equals('GUID')) {
         NIDocName = AH_UDC_Shared.generateGUID();
      }

      Id recordTypeId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      NI_Documentation__c objNIDoc = new NI_Documentation__c();
      objNIDoc.RecordTypeId = recordTypeId;
      objNIDoc.Document_Name__c = NIDocName;
      objNIDoc.AH_UDC_ChatterWorkbookAccessed__c = false;
      objNIDoc.AH_UDC_ChatterWorkbookCompleted__c = false;
      objNIDoc.AH_UDC_WorkbookDueDate__c = DueDate;
      return objNIDoc;
   }

   //Return AH_UDC_Contact__c with values assigned
   public static AH_UDC_Contact__c GetUDCContactObject(Id NIDocId, Id ContactId, String strCurrency) {
      AH_UDC_Contact__c objUDCContact = new AH_UDC_Contact__c();
      objUDCContact.Contact__c = ContactId;
      objUDCContact.CurrencyIsoCode = strCurrency;
      objUDCContact.Document__c = NIDocId;
      return objUDCContact;
   }

   //Return a WORKBOOK_SENT type AH_UDC_Workbook__c record with values assigned
   public static AH_UDC_Workbook__c GetWorkbookObject(Id NIDocId, String WorkbookName, String Description, String Product) {
      Id recordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      return GetWorkbookObject(NIDocId, WorkbookName, Description, Product, recordTypeId);
   }

   //Return a AH_UDC_Workbook__c record of RecordType of Id "RecordTypeId" with values assigned
   public static AH_UDC_Workbook__c GetWorkbookObject(Id NIDocId, String WorkbookName, String Description, String Product, Id RecordTypeId) {
      AH_UDC_Workbook__c objWorkbook = new AH_UDC_Workbook__c();
      objWorkbook.RecordTypeId = RecordTypeId;
      objWorkbook.Name = WorkbookName;
      objWorkbook.RelatedTo__c = NIDocId;
      objWorkbook.Product__c = Product;
      objWorkbook.Description__c = Description;
      objWorkbook.Enabled__c = true;
      objWorkbook.SecurityCode__c = AH_UDC_Shared.GetSecurityCode();
      objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
      return objWorkbook;
   }

   //Return AH_UDC_WorkbookStep__c with values assigned
   public static AH_UDC_WorkbookStep__c GetWorkbookStepObject(Id WorkBookId, String StepName) {
      Id recordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      AH_UDC_WorkbookStep__c objWorkbookStep = new AH_UDC_WorkbookStep__c();
      objWorkbookStep.RecordTypeId = recordTypeId;
      objWorkbookStep.Name = StepName;
      objWorkbookStep.Workbook__c = WorkBookId;
      objWorkbookStep.Enabled__c = true;
      objWorkbookStep.StepStatus__c = AH_UDC_Constants.STEP_STATUS_NEW;
      return objWorkbookStep;
   }

   //Return AH_UDC_Response__c with values assigned
   public static AH_UDC_Response__c GetStepResponseObject() {
      AH_UDC_Response__c objWorkbookStepResponse = new AH_UDC_Response__c();
      objWorkbookStepResponse.Responder__c = UserInfo.getUserId();
      objWorkbookStepResponse.Responded__c = Datetime.now();   
      return objWorkbookStepResponse;
   }

   //Return AH_UDC_Response__c with values assigned
   public static AH_UDC_WorkbookStepResponse__c GetWorkbookStepResponseObject(Id stepId, Id responseId) {
      AH_UDC_WorkbookStepResponse__c objWorkbookStepResponse = new AH_UDC_WorkbookStepResponse__c();
      objWorkbookStepResponse.WorkbookStep__c = stepId;
      objWorkbookStepResponse.Response__c = responseId;
      objWorkbookStepResponse.IsMostRecentResponse__c = true;
      return objWorkbookStepResponse;
   }

   //Return AH_UDC_ResponseQA__c with values assigned
   public static AH_UDC_ResponseQA__c GetStepResponseQAObject(Id responseId, String strQuestion, String strQuestionField, String strAnswer, String strAnswerFeild) {
      AH_UDC_ResponseQA__c objWorkbookStepResponseQA = new AH_UDC_ResponseQA__c();
      objWorkbookStepResponseQA.Response__c = responseId;
      objWorkbookStepResponseQA.Question__c = strQuestion;
      objWorkbookStepResponseQA.QuestionField__c = strQuestionField;
      objWorkbookStepResponseQA.Answer__c = strAnswer;
      objWorkbookStepResponseQA.AnswerField__c = strAnswerFeild;
      return objWorkbookStepResponseQA;
   }
 //Return AH_UDC_ResponseQA__c with values assigned
   public static AH_UDC_ResponseQA__c GetStepResponseQAObject(Id responseId, String strQAJson, Integer iSortOrder) {
      AH_UDC_ResponseQA__c objWorkbookStepResponseQA = new AH_UDC_ResponseQA__c();
      objWorkbookStepResponseQA.Response__c = responseId;
      objWorkbookStepResponseQA.QAJson__c = strQAJson;
      objWorkbookStepResponseQA.SortOrder__c = iSortOrder;     
      return objWorkbookStepResponseQA;
   }
   //Return AH_UDC_Workbook__c with values assigned
   public static AH_UDC_Workbook__c GetWorkbookObjectWithoutDocId(String WorkbookName, String Description, String Product) {
      Id workbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      AH_UDC_Workbook__c objWorkbook = new AH_UDC_Workbook__c();
      objWorkbook.RecordTypeId = workbookRecordTypeId;
      objWorkbook.Name = WorkbookName;
      objWorkbook.Product__c = Product;
      objWorkbook.Description__c = Description;
      return objWorkbook;
   }

   //Return AH_UDC_Form__c with values assigned
   public static AH_UDC_Form__c GetForm(String Definition, string FormAssemblyId, string Name, string CustomUrlId) {
      AH_UDC_Form__c form = new AH_UDC_Form__c();
      form.CustomUrlId__c = CustomUrlId;
      form.Definition__c = Definition;
      form.FormAssemblyId__c = FormAssemblyId;
      form.Name = Name;
      form.FormType__c = AH_UDC_Constants.FORM_TYPE_PRODUCT;
      return form;
   }

   public static AH_UDC_ConfigurationSetting__c GetConfigurationSetting(String Name, String SettingType, String PageGroupName, String PageSectionName, String PageName, String SettingValueDefault, String OrgName) {
      AH_UDC_ConfigurationSetting__c config = new AH_UDC_ConfigurationSetting__c();
      config.Name = Name;
      config.AH_UDC__c = true;
      config.SettingType__c = SettingType;
      config.PageGroupName__c = PageGroupName;
      config.PageSectionName__c = PageSectionName;
      config.PageName__c = PageName;
      config.DisplayOrder__c = 3;
      config.SettingDisplayName__c = 'Permission Set for Workbook Administrator User (API Name)';
      config.SettingHelpText__c = 'This is the API Name of the permission set assigned to Workbook Administrator users that will be using UDC';
      config.SettingValue__c = '';
      config.SettingValueDefault__c = SettingValueDefault;
      config.SettingValueDomain__c = '';
      config.UsedBy__c = '';
      config.OrgName__c = OrgName;
      return config;
   }

   public static string GetLastLogMessage() {
      String lastLogMessage = '';

      // This will dump up to 100 retrieved log messages to the Debug Log, to help track down unexpected messages
      for (AH_UDC_Log__c log : [SELECT LogText__c, CreatedDate FROM AH_UDC_Log__c WITH SECURITY_ENFORCED ORDER BY CreatedDate desc LIMIT 100]) {
         System.debug('Log message (' + log.CreatedDate + '): ' + log.LogText__c);

         // Save the text of the most recent Log message that was retrieved so it can be returned
         if (lastLogMessage == '') { lastLogMessage = log.LogText__c; }
      }

      return lastLogMessage;
   }

   public class TestDataException extends Exception { }
=======
/***********************************************************************************************
  Name            : AH_UDC_TestData
  Author          : Sanjay Parmar
  Created Date    : 1-Feb-2021
  NICC Reference  : 
  Description     : Common class to prepare test data for test class execution
  Modified        : 2021-07-03, Rob Stevens, Adding Create user methods for users needed for tests
 ************************************************************************************************/
public without sharing class AH_UDC_TestData {

   private static List<String> m_listUserEmails = new List<String> ();

   public static void clearLogs()
   {
      if (test.isRunningTest()) {
         List<AH_UDC_Log__c> logs = [SELECT Id FROM AH_UDC_Log__c LIMIT 2000];
         AH_UDC_SystemContext.deleteSobjList(logs);
      }
   }

   public static string getFormDefinitionTokenTFAFieldAPIName = 'tfa_16';
   public static String getFormDefinition() {
      return '{"title":"UDCSB - SERVICES - RFP Toolkit - Section Names","FormAssemblyId":"4853168","CustomUrlId":"58c874ca-f1e4-4504-9878-b4b97af509ec","fields":[{"Name":"Token","APIName":"tfa_16","Repeat":"","Picklist":"false"},{"Name":"Security Code","APIName":"tfa_1","Repeat":"","Picklist":"false"},{"Name":"Parent Security Code","APIName":"tfa_17","Repeat":"","Picklist":"false"},{"Name":"Custom Section Name","APIName":"tfa_6","Repeat":"tfa_19[0]","Picklist":"false"},{"Name":"Section Title","APIName":"tfa_18","Repeat":"tfa_19[0]","Picklist":"false"},{"Name":"Yes","APIName":"tfa_11","Repeat":""},{"Name":"No, Specify Custom Section Names","APIName":"tfa_12","Repeat":""},{"Name":"Use the Default Section Names","APIName":"tfa_10","Repeat":""}]}';
   }

   public static String getFormDefinition_DefaultStep1() {
      return '{"title":"UDCSB - Unit Test - Default - Step1","FormAssemblyId":"4853372","CustomUrlId":"4853372","fields":[{"Name":"Token","APIName":"tfa_1","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Security Code","APIName":"tfa_2","Repeat":"","DefaultValue":"Please do not change this field.","Picklist":"false","InputType":"Text"},{"Name":"Parent Security Code","APIName":"tfa_3","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Product","APIName":"tfa_5","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Future use","APIName":"tfa_6","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Future Use","APIName":"tfa_7","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Test Default","APIName":"tfa_8","Repeat":"","Picklist":"false","InputType":"Text"}]}';
   }

   public static String getFormDefinition_DefaultStep2() {
      return '{"title":"UDCSB - Unit Test - Default - Step2","FormAssemblyId":"4853373","CustomUrlId":"4853373","fields":[{"Name":"Token","APIName":"tfa_1","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Security Code","APIName":"tfa_2","Repeat":"","DefaultValue":"Please do not change this field.","Picklist":"false","InputType":"Text"},{"Name":"Parent Security Code","APIName":"tfa_3","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Product","APIName":"tfa_5","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Future use","APIName":"tfa_6","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Future Use","APIName":"tfa_7","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Default value from step1","APIName":"tfa_14","Repeat":"","DefaultValue":"DEFAULT|4853372|tfa_8","Picklist":"false","InputType":"Text"}]}';
   }

   public static String getFormDefinition_DefaultAndPicklistStep1() {
      return '{"title":"UDCSB - Unit Test - Default, Picklist - Step1","FormAssemblyId":"4853374","CustomUrlId":"4853374","fields":[{"Name":"Token","APIName":"tfa_1","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Security Code","APIName":"tfa_2","Repeat":"","DefaultValue":"Please do not change this field.","Picklist":"false","InputType":"Text"},{"Name":"Parent Security Code","APIName":"tfa_3","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Product","APIName":"tfa_5","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Default Test","APIName":"tfa_33","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Picklist Test","APIName":"tfa_31","Repeat":"tfa_30[0]","Picklist":"false","InputType":"Text"},{"Name":"Test Default","APIName":"tfa_8","Repeat":"","Picklist":"false","InputType":"Text"}]}'; 
   }

   public static String getFormDefinition_DefaultAndPicklistStep2() {
      return '{"title":"UDCSB - Unit Test - Default, Picklist - Step2","FormAssemblyId":"4853375","CustomUrlId":"4853375","fields":[{"Name":"Token","APIName":"tfa_1","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Security Code","APIName":"tfa_2","Repeat":"","DefaultValue":"Please do not change this field.","Picklist":"false","InputType":"Text"},{"Name":"Parent Security Code","APIName":"tfa_3","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Product","APIName":"tfa_5","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Picklist","APIName":"tfa_24","Repeat":"tfa_14[0]","DefaultValue":"Picklist|4853374|tfa_31","Picklist":"true","InputType":"Picklist"},{"Name":"Default","APIName":"tfa_54","Repeat":"tfa_14[0]","DefaultValue":"DEFAULT|4853374|tfa_33","Picklist":"false","InputType":"Text"},{"Name":"Default value from step1","APIName":"tfa_15","Repeat":"","DefaultValue":"DEFAULT|4853374|tfa_8","Picklist":"false","InputType":"Text"}]}';
   }
   // Returns back a list of picklist values for the PRODUCT field on the Workbook
   public static List<Schema.PicklistEntry> getProductPicklist() {
      List<Schema.PicklistEntry> pickListEntry = null;
      Schema.DescribeFieldResult fieldResult = AH_UDC_Workbook__c.Product__c.getDescribe();
      if (fieldResult == null) { throw new TestDataException('Unable to retrieve the picklist for the Workbook field PRODUCT'); }

      return fieldResult.getPicklistValues();
   }

   //Return Account with values assigned
   public static Account GetAccountObject(string uniqueId) {
      if (uniqueId.toUpperCase().equals('GUID')) {
         uniqueId = AH_UDC_Shared.generateGUID();
      }
      return GetAccountObject(uniqueId, uniqueId + 'Test', uniqueId.left(30), 'US', '03801', 'NH', uniqueId + ' Ave');
   }

   private static Account GetAccountObject(String AccountName, String Industry, String BillingCity, String BillingCountry,
                                           String BillingPostalCode, String BillingState, String BillingStreet) {
      Account objAccount = new Account();
      objAccount.Name = AccountName;
      objAccount.Industry = Industry;
      objAccount.BillingCity = BillingCity;
      objAccount.BillingCountry = BillingCountry;
      objAccount.BillingPostalCode = BillingPostalCode;
      objAccount.BillingState = BillingState;
      objAccount.BillingStreet = BillingStreet;
      return objAccount;
   }

   public static AH_UDC_PropertyAccount__c GetPropertyObject(String AccountName, String BillingCity, String BillingCountry,
                                                             String BillingPostalCode, String BillingState, String BillingStreet, String Address1) {
      AH_UDC_PropertyAccount__c objProperty = new AH_UDC_PropertyAccount__c();
      objProperty.PropertyName__c = AccountName;
      objProperty.City__c = BillingCity;
      objProperty.Country__c = BillingCountry;
      objProperty.PostalCode__c = BillingPostalCode;
      objProperty.StateProvince__c = BillingState;
      objProperty.Address__c = Address1;
      return objProperty;
   }

   public static Contact GetContactObject(ID AccountId, string uniqueId) { //contact firstname and lastname combined should be less than 40 characters
      return GetContactObject(AccountId, 'TestCommunityUser', uniqueId.left(20), 'US', 'Portsmouth', '03801', 'NH', uniqueId);
   }
   //Return Contact with values assigned
   public static Contact GetContactObject(Id AccountId, String FirstName, String LastName, String MailingCountry,
                                          String MailingCity, String MailingPostalCode, String MailingState, String MailingStreet) {
      Contact objContact = new Contact();
      objContact.AccountId = AccountId;
      objContact.FirstName = FirstName;
      objContact.LastName = LastName;
      objContact.MailingCountry = MailingCountry;
      objContact.MailingCity = MailingCity;
      objContact.MailingPostalCode = MailingPostalCode;
      objContact.MailingState = MailingState;
      objContact.MailingStreet = MailingStreet;
      return objContact;
   }

   //Return Contact with values assigned
   public static Contact GetContactObject(Account acct, String FirstName, String LastName, String MailingCountry,
                                          String MailingCity, String MailingPostalCode, String MailingState, String MailingStreet) {
      Contact objContact = new Contact();
      objContact.Account = acct;
      objContact.AccountId = acct.Id;
      objContact.FirstName = FirstName;
      objContact.LastName = LastName;
      objContact.MailingCountry = MailingCountry;
      objContact.MailingCity = MailingCity;
      objContact.MailingPostalCode = MailingPostalCode;
      objContact.MailingState = MailingState;
      objContact.MailingStreet = MailingStreet;
      return objContact;
   }

   public static void delay(Long milliSeconds)
   {
      if (!Test.isRunningTest()) return;

      Long timeDiff = 0;
      DateTime firstTime = System.now();
      do
      {
         timeDiff = System.now().getTime() - firstTime.getTime();
      }
      while (timeDiff <= milliSeconds);
   }

   public static void InsertWithRetries(List<SObject> l)
   {
      Integer retryCount = 0;
      Boolean success = false;
      while (!success) {
         try {
            insert l;
            success = true;
         }
         catch(Exception exc) {
            retryCount++;
            delay(Integer.valueof((Math.random() * 200))); //milliseconds
            if (retryCount > 100) {
               throw new TestDataException('Failed to create Insert record(s): ' + exc.getMessage());
            }
            System.debug('InsertWithRetries: retrying: ' + retryCount);
         }
      }
   }

   // Generates a User Name that will be unique, that can be used when creating a test user
   public static String generateUniqueUserName() {
      String orgId = UserInfo.getOrganizationId();
      String datetimeString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
      Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
      String uniqueName = orgId + datetimeString + randomInt;

      return uniqueName;
   }

   public static void AddPermissionSetToUser(String permissionsetName, Id userId) {
      List<PermissionSet> oPermissionsets = [SELECT Id FROM PermissionSet WHERE Name = :permissionsetName];
      system.assertEquals(1, oPermissionsets.size(), 'Could not find permissionset: ' + permissionsetName);

      insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = oPermissionsets[0].Id);
   }

   public static User BuildUser(string profileName, string permissionsetName, string uniqueId, ID contactId, Boolean isCommunityUser) {
      try
      {
         string externalSalesforceUsername = null;
         if (uniqueId.toUpperCase().equals('GUID')) {
            uniqueId = AH_UDC_Shared.generateGUID();
         }
         if (uniqueId.toUpperCase().startsWith('{GUID}')) {
            externalSalesforceUsername = uniqueId.removeStart('{GUID}');
            uniqueId = AH_UDC_Shared.generateGUID();
         }
         User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
         oCurrentUser.ContactId = null;
         User oNewUser = null;

         System.runAs(oCurrentUser)
         {
            //Get Profile
            List<Profile> oProfiles = [SELECT Id FROM Profile WHERE Name = :profileName];
            system.assertEquals(1, oProfiles.size(), 'Could not find profile: ' + profileName);

            // Create User record
            string userName = 'Test' + uniqueId + '@amadeus.com';
            if (isCommunityUser) { userName += AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX; }
            oNewUser = AH_UDC_TestData.GetUserObject(contactId, oProfiles[0].Id, 'Test' + permissionsetName, uniqueId, uniqueId, 'Test' + uniqueId + '@amadeus.com', userName);
            oNewUser.External_Salesforce_Username__c = externalSalesforceUsername; //This is used to allow Test Methods to retrieve the user
         }
         return oNewUser;
      }
      catch(Exception exc) {
         System.Assert(false, 'CreateUser Exception: ' + exc.getMessage());
         return null;
      }
   }
      
   //Return User with values assigned
   private static User getUserObject(Id ContactId, Id ProfileId, String FirstName, String LastName, String Alias, String strEmail, String UserName) {

      if (m_listUserEmails.Contains(strEmail)) {
         System.assert(false, 'Email address already exists');
      }

      m_listUserEmails.add(strEmail);

      User objUser = new User(
                              ContactId = ContactId,
                              profileid = ProfileId,
                              firstname = FirstName,
                              lastname = LastName,
                              alias = Alias.left(8),
                              email = strEmail,
                              emailencodingkey = 'UTF-8',
                              languagelocalekey = 'en_US',
                              localesidkey = 'en_US',
                              country = 'United States',
                              IsActive = true,
                              timezonesidkey = 'America/Los_Angeles',
                              username = UserName,
                              No_AD_Account_Standard_User__c = true
      );
      return objUser;
   }

   //Return NI_Documentation__c with values assigned
   public static NI_Documentation__c GetNIDocObject(String NIDocName, Date DueDate) {
      if (NIDocName.toUpperCase().equals('GUID')) {
         NIDocName = AH_UDC_Shared.generateGUID();
      }

      Id recordTypeId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      NI_Documentation__c objNIDoc = new NI_Documentation__c();
      objNIDoc.RecordTypeId = recordTypeId;
      objNIDoc.Document_Name__c = NIDocName;
      objNIDoc.AH_UDC_ChatterWorkbookAccessed__c = false;
      objNIDoc.AH_UDC_ChatterWorkbookCompleted__c = false;
      objNIDoc.AH_UDC_WorkbookDueDate__c = DueDate;
      return objNIDoc;
   }

   //Return AH_UDC_Contact__c with values assigned
   public static AH_UDC_Contact__c GetUDCContactObject(Id NIDocId, Id ContactId, String strCurrency) {
      AH_UDC_Contact__c objUDCContact = new AH_UDC_Contact__c();
      objUDCContact.Contact__c = ContactId;
      objUDCContact.CurrencyIsoCode = strCurrency;
      objUDCContact.Document__c = NIDocId;
      return objUDCContact;
   }

   //Return a WORKBOOK_SENT type AH_UDC_Workbook__c record with values assigned
   public static AH_UDC_Workbook__c GetWorkbookObject(Id NIDocId, String WorkbookName, String Description, String Product) {
      Id recordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      return GetWorkbookObject(NIDocId, WorkbookName, Description, Product, recordTypeId);
   }

   //Return a AH_UDC_Workbook__c record of RecordType of Id "RecordTypeId" with values assigned
   public static AH_UDC_Workbook__c GetWorkbookObject(Id NIDocId, String WorkbookName, String Description, String Product, Id RecordTypeId) {
      AH_UDC_Workbook__c objWorkbook = new AH_UDC_Workbook__c();
      objWorkbook.RecordTypeId = RecordTypeId;
      objWorkbook.Name = WorkbookName;
      objWorkbook.RelatedTo__c = NIDocId;
      objWorkbook.Product__c = Product;
      objWorkbook.Description__c = Description;
      objWorkbook.Enabled__c = true;
      objWorkbook.SecurityCode__c = AH_UDC_Shared.GetSecurityCode();
      objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
      return objWorkbook;
   }

   //Return AH_UDC_WorkbookStep__c with values assigned
   public static AH_UDC_WorkbookStep__c GetWorkbookStepObject(Id WorkBookId, String StepName) {
      Id recordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      AH_UDC_WorkbookStep__c objWorkbookStep = new AH_UDC_WorkbookStep__c();
      objWorkbookStep.RecordTypeId = recordTypeId;
      objWorkbookStep.Name = StepName;
      objWorkbookStep.Workbook__c = WorkBookId;
      objWorkbookStep.Enabled__c = true;
      objWorkbookStep.StepStatus__c = AH_UDC_Constants.STEP_STATUS_NEW;
      return objWorkbookStep;
   }

   //Return AH_UDC_Response__c with values assigned
   public static AH_UDC_Response__c GetStepResponseObject() {
      AH_UDC_Response__c objWorkbookStepResponse = new AH_UDC_Response__c();
      objWorkbookStepResponse.Responder__c = UserInfo.getUserId();
      objWorkbookStepResponse.Responded__c = Datetime.now();   
      return objWorkbookStepResponse;
   }

   //Return AH_UDC_Response__c with values assigned
   public static AH_UDC_WorkbookStepResponse__c GetWorkbookStepResponseObject(Id stepId, Id responseId) {
      AH_UDC_WorkbookStepResponse__c objWorkbookStepResponse = new AH_UDC_WorkbookStepResponse__c();
      objWorkbookStepResponse.WorkbookStep__c = stepId;
      objWorkbookStepResponse.Response__c = responseId;
      objWorkbookStepResponse.IsMostRecentResponse__c = true;
      return objWorkbookStepResponse;
   }

   //Return AH_UDC_ResponseQA__c with values assigned
   public static AH_UDC_ResponseQA__c GetStepResponseQAObject(Id responseId, String strQuestion, String strQuestionField, String strAnswer, String strAnswerFeild) {
      AH_UDC_ResponseQA__c objWorkbookStepResponseQA = new AH_UDC_ResponseQA__c();
      objWorkbookStepResponseQA.Response__c = responseId;
      objWorkbookStepResponseQA.Question__c = strQuestion;
      objWorkbookStepResponseQA.QuestionField__c = strQuestionField;
      objWorkbookStepResponseQA.Answer__c = strAnswer;
      objWorkbookStepResponseQA.AnswerField__c = strAnswerFeild;
      return objWorkbookStepResponseQA;
   }
 //Return AH_UDC_ResponseQA__c with values assigned
   public static AH_UDC_ResponseQA__c GetStepResponseQAObject(Id responseId, String strQAJson, Integer iSortOrder) {
      AH_UDC_ResponseQA__c objWorkbookStepResponseQA = new AH_UDC_ResponseQA__c();
      objWorkbookStepResponseQA.Response__c = responseId;
      objWorkbookStepResponseQA.QAJson__c = strQAJson;
      objWorkbookStepResponseQA.SortOrder__c = iSortOrder;     
      return objWorkbookStepResponseQA;
   }
   //Return AH_UDC_Workbook__c with values assigned
   public static AH_UDC_Workbook__c GetWorkbookObjectWithoutDocId(String WorkbookName, String Description, String Product) {
      Id workbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      AH_UDC_Workbook__c objWorkbook = new AH_UDC_Workbook__c();
      objWorkbook.RecordTypeId = workbookRecordTypeId;
      objWorkbook.Name = WorkbookName;
      objWorkbook.Product__c = Product;
      objWorkbook.Description__c = Description;
      return objWorkbook;
   }

   //Return AH_UDC_Form__c with values assigned
   public static AH_UDC_Form__c GetForm(String Definition, string FormAssemblyId, string Name, string CustomUrlId) {
      AH_UDC_Form__c form = new AH_UDC_Form__c();
      form.CustomUrlId__c = CustomUrlId;
      form.Definition__c = Definition;
      form.FormAssemblyId__c = FormAssemblyId;
      form.Name = Name;
      form.FormType__c = AH_UDC_Constants.FORM_TYPE_PRODUCT;
      return form;
   }

   public static AH_UDC_ConfigurationSetting__c GetConfigurationSetting(String Name, String SettingType, String PageGroupName, String PageSectionName, String PageName, String SettingValueDefault, String OrgName) {
      AH_UDC_ConfigurationSetting__c config = new AH_UDC_ConfigurationSetting__c();
      config.Name = Name;
      config.AH_UDC__c = true;
      config.SettingType__c = SettingType;
      config.PageGroupName__c = PageGroupName;
      config.PageSectionName__c = PageSectionName;
      config.PageName__c = PageName;
      config.DisplayOrder__c = 3;
      config.SettingDisplayName__c = 'Permission Set for Workbook Administrator User (API Name)';
      config.SettingHelpText__c = 'This is the API Name of the permission set assigned to Workbook Administrator users that will be using UDC';
      config.SettingValue__c = '';
      config.SettingValueDefault__c = SettingValueDefault;
      config.SettingValueDomain__c = '';
      config.UsedBy__c = '';
      config.OrgName__c = OrgName;
      return config;
   }

   public static string GetLastLogMessage() {
      String lastLogMessage = '';

      // This will dump up to 100 retrieved log messages to the Debug Log, to help track down unexpected messages
      for (AH_UDC_Log__c log : [SELECT LogText__c, CreatedDate FROM AH_UDC_Log__c WITH SECURITY_ENFORCED ORDER BY CreatedDate desc LIMIT 100]) {
         System.debug('Log message (' + log.CreatedDate + '): ' + log.LogText__c);

         // Save the text of the most recent Log message that was retrieved so it can be returned
         if (lastLogMessage == '') { lastLogMessage = log.LogText__c; }
      }

      return lastLogMessage;
   }

   public class TestDataException extends Exception { }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
/***********************************************************************************************
  Name            : AH_UDC_TestData
  Author          : Sanjay Parmar
  Created Date    : 1-Feb-2021
  NICC Reference  : 
  Description     : Common class to prepare test data for test class execution
  Modified        : 2021-07-03, Rob Stevens, Adding Create user methods for users needed for tests
 ************************************************************************************************/
public without sharing class AH_UDC_TestData {

   private static List<String> m_listUserEmails = new List<String> ();

   public static void clearLogs()
   {
      if (test.isRunningTest()) {
         List<AH_UDC_Log__c> logs = [SELECT Id FROM AH_UDC_Log__c LIMIT 2000];
         AH_UDC_SystemContext.deleteSobjList(logs);
      }
   }

   public static string getFormDefinitionTokenTFAFieldAPIName = 'tfa_16';
   public static String getFormDefinition() {
      return '{"title":"UDCSB - SERVICES - RFP Toolkit - Section Names","FormAssemblyId":"4853168","CustomUrlId":"58c874ca-f1e4-4504-9878-b4b97af509ec","fields":[{"Name":"Token","APIName":"tfa_16","Repeat":"","Picklist":"false"},{"Name":"Security Code","APIName":"tfa_1","Repeat":"","Picklist":"false"},{"Name":"Parent Security Code","APIName":"tfa_17","Repeat":"","Picklist":"false"},{"Name":"Custom Section Name","APIName":"tfa_6","Repeat":"tfa_19[0]","Picklist":"false"},{"Name":"Section Title","APIName":"tfa_18","Repeat":"tfa_19[0]","Picklist":"false"},{"Name":"Yes","APIName":"tfa_11","Repeat":""},{"Name":"No, Specify Custom Section Names","APIName":"tfa_12","Repeat":""},{"Name":"Use the Default Section Names","APIName":"tfa_10","Repeat":""}]}';
   }

   public static String getFormDefinition_DefaultStep1() {
      return '{"title":"UDCSB - Unit Test - Default - Step1","FormAssemblyId":"4853372","CustomUrlId":"4853372","fields":[{"Name":"Token","APIName":"tfa_1","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Security Code","APIName":"tfa_2","Repeat":"","DefaultValue":"Please do not change this field.","Picklist":"false","InputType":"Text"},{"Name":"Parent Security Code","APIName":"tfa_3","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Product","APIName":"tfa_5","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Future use","APIName":"tfa_6","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Future Use","APIName":"tfa_7","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Test Default","APIName":"tfa_8","Repeat":"","Picklist":"false","InputType":"Text"}]}';
   }

   public static String getFormDefinition_DefaultStep2() {
      return '{"title":"UDCSB - Unit Test - Default - Step2","FormAssemblyId":"4853373","CustomUrlId":"4853373","fields":[{"Name":"Token","APIName":"tfa_1","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Security Code","APIName":"tfa_2","Repeat":"","DefaultValue":"Please do not change this field.","Picklist":"false","InputType":"Text"},{"Name":"Parent Security Code","APIName":"tfa_3","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Product","APIName":"tfa_5","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Future use","APIName":"tfa_6","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Future Use","APIName":"tfa_7","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Default value from step1","APIName":"tfa_14","Repeat":"","DefaultValue":"DEFAULT|4853372|tfa_8","Picklist":"false","InputType":"Text"}]}';
   }

   public static String getFormDefinition_DefaultAndPicklistStep1() {
      return '{"title":"UDCSB - Unit Test - Default, Picklist - Step1","FormAssemblyId":"4853374","CustomUrlId":"4853374","fields":[{"Name":"Token","APIName":"tfa_1","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Security Code","APIName":"tfa_2","Repeat":"","DefaultValue":"Please do not change this field.","Picklist":"false","InputType":"Text"},{"Name":"Parent Security Code","APIName":"tfa_3","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Product","APIName":"tfa_5","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Default Test","APIName":"tfa_33","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Picklist Test","APIName":"tfa_31","Repeat":"tfa_30[0]","Picklist":"false","InputType":"Text"},{"Name":"Test Default","APIName":"tfa_8","Repeat":"","Picklist":"false","InputType":"Text"}]}'; 
   }

   public static String getFormDefinition_DefaultAndPicklistStep2() {
      return '{"title":"UDCSB - Unit Test - Default, Picklist - Step2","FormAssemblyId":"4853375","CustomUrlId":"4853375","fields":[{"Name":"Token","APIName":"tfa_1","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Security Code","APIName":"tfa_2","Repeat":"","DefaultValue":"Please do not change this field.","Picklist":"false","InputType":"Text"},{"Name":"Parent Security Code","APIName":"tfa_3","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Product","APIName":"tfa_5","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Picklist","APIName":"tfa_24","Repeat":"tfa_14[0]","DefaultValue":"Picklist|4853374|tfa_31","Picklist":"true","InputType":"Picklist"},{"Name":"Default","APIName":"tfa_54","Repeat":"tfa_14[0]","DefaultValue":"DEFAULT|4853374|tfa_33","Picklist":"false","InputType":"Text"},{"Name":"Default value from step1","APIName":"tfa_15","Repeat":"","DefaultValue":"DEFAULT|4853374|tfa_8","Picklist":"false","InputType":"Text"}]}';
   }
   // Returns back a list of picklist values for the PRODUCT field on the Workbook
   public static List<Schema.PicklistEntry> getProductPicklist() {
      List<Schema.PicklistEntry> pickListEntry = null;
      Schema.DescribeFieldResult fieldResult = AH_UDC_Workbook__c.Product__c.getDescribe();
      if (fieldResult == null) { throw new TestDataException('Unable to retrieve the picklist for the Workbook field PRODUCT'); }

      return fieldResult.getPicklistValues();
   }

   //Return Account with values assigned
   public static Account GetAccountObject(string uniqueId) {
      if (uniqueId.toUpperCase().equals('GUID')) {
         uniqueId = AH_UDC_Shared.generateGUID();
      }
      return GetAccountObject(uniqueId, uniqueId + 'Test', uniqueId.left(30), 'US', '03801', 'NH', uniqueId + ' Ave');
   }

   private static Account GetAccountObject(String AccountName, String Industry, String BillingCity, String BillingCountry,
                                           String BillingPostalCode, String BillingState, String BillingStreet) {
      Account objAccount = new Account();
      objAccount.Name = AccountName;
      objAccount.Industry = Industry;
      objAccount.BillingCity = BillingCity;
      objAccount.BillingCountry = BillingCountry;
      objAccount.BillingPostalCode = BillingPostalCode;
      objAccount.BillingState = BillingState;
      objAccount.BillingStreet = BillingStreet;
      return objAccount;
   }

   public static AH_UDC_PropertyAccount__c GetPropertyObject(String AccountName, String BillingCity, String BillingCountry,
                                                             String BillingPostalCode, String BillingState, String BillingStreet, String Address1) {
      AH_UDC_PropertyAccount__c objProperty = new AH_UDC_PropertyAccount__c();
      objProperty.PropertyName__c = AccountName;
      objProperty.City__c = BillingCity;
      objProperty.Country__c = BillingCountry;
      objProperty.PostalCode__c = BillingPostalCode;
      objProperty.StateProvince__c = BillingState;
      objProperty.Address__c = Address1;
      return objProperty;
   }

   public static Contact GetContactObject(ID AccountId, string uniqueId) { //contact firstname and lastname combined should be less than 40 characters
      return GetContactObject(AccountId, 'TestCommunityUser', uniqueId.left(20), 'US', 'Portsmouth', '03801', 'NH', uniqueId);
   }
   //Return Contact with values assigned
   public static Contact GetContactObject(Id AccountId, String FirstName, String LastName, String MailingCountry,
                                          String MailingCity, String MailingPostalCode, String MailingState, String MailingStreet) {
      Contact objContact = new Contact();
      objContact.AccountId = AccountId;
      objContact.FirstName = FirstName;
      objContact.LastName = LastName;
      objContact.MailingCountry = MailingCountry;
      objContact.MailingCity = MailingCity;
      objContact.MailingPostalCode = MailingPostalCode;
      objContact.MailingState = MailingState;
      objContact.MailingStreet = MailingStreet;
      return objContact;
   }

   //Return Contact with values assigned
   public static Contact GetContactObject(Account acct, String FirstName, String LastName, String MailingCountry,
                                          String MailingCity, String MailingPostalCode, String MailingState, String MailingStreet) {
      Contact objContact = new Contact();
      objContact.Account = acct;
      objContact.AccountId = acct.Id;
      objContact.FirstName = FirstName;
      objContact.LastName = LastName;
      objContact.MailingCountry = MailingCountry;
      objContact.MailingCity = MailingCity;
      objContact.MailingPostalCode = MailingPostalCode;
      objContact.MailingState = MailingState;
      objContact.MailingStreet = MailingStreet;
      return objContact;
   }

   public static void delay(Long milliSeconds)
   {
      if (!Test.isRunningTest()) return;

      Long timeDiff = 0;
      DateTime firstTime = System.now();
      do
      {
         timeDiff = System.now().getTime() - firstTime.getTime();
      }
      while (timeDiff <= milliSeconds);
   }

   public static void InsertWithRetries(List<SObject> l)
   {
      Integer retryCount = 0;
      Boolean success = false;
      while (!success) {
         try {
            insert l;
            success = true;
         }
         catch(Exception exc) {
            retryCount++;
            delay(Integer.valueof((Math.random() * 200))); //milliseconds
            if (retryCount > 100) {
               throw new TestDataException('Failed to create Insert record(s): ' + exc.getMessage());
            }
            System.debug('InsertWithRetries: retrying: ' + retryCount);
         }
      }
   }

   // Generates a User Name that will be unique, that can be used when creating a test user
   public static String generateUniqueUserName() {
      String orgId = UserInfo.getOrganizationId();
      String datetimeString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
      Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
      String uniqueName = orgId + datetimeString + randomInt;

      return uniqueName;
   }

   public static void AddPermissionSetToUser(String permissionsetName, Id userId) {
      List<PermissionSet> oPermissionsets = [SELECT Id FROM PermissionSet WHERE Name = :permissionsetName];
      system.assertEquals(1, oPermissionsets.size(), 'Could not find permissionset: ' + permissionsetName);

      insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = oPermissionsets[0].Id);
   }

   public static User BuildUser(string profileName, string permissionsetName, string uniqueId, ID contactId, Boolean isCommunityUser) {
      try
      {
         string externalSalesforceUsername = null;
         if (uniqueId.toUpperCase().equals('GUID')) {
            uniqueId = AH_UDC_Shared.generateGUID();
         }
         if (uniqueId.toUpperCase().startsWith('{GUID}')) {
            externalSalesforceUsername = uniqueId.removeStart('{GUID}');
            uniqueId = AH_UDC_Shared.generateGUID();
         }
         User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
         oCurrentUser.ContactId = null;
         User oNewUser = null;

         System.runAs(oCurrentUser)
         {
            //Get Profile
            List<Profile> oProfiles = [SELECT Id FROM Profile WHERE Name = :profileName];
            system.assertEquals(1, oProfiles.size(), 'Could not find profile: ' + profileName);

            // Create User record
            string userName = 'Test' + uniqueId + '@amadeus.com';
            if (isCommunityUser) { userName += AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX; }
            oNewUser = AH_UDC_TestData.GetUserObject(contactId, oProfiles[0].Id, 'Test' + permissionsetName, uniqueId, uniqueId, 'Test' + uniqueId + '@amadeus.com', userName);
            oNewUser.External_Salesforce_Username__c = externalSalesforceUsername; //This is used to allow Test Methods to retrieve the user
         }
         return oNewUser;
      }
      catch(Exception exc) {
         System.Assert(false, 'CreateUser Exception: ' + exc.getMessage());
         return null;
      }
   }
      
   //Return User with values assigned
   private static User getUserObject(Id ContactId, Id ProfileId, String FirstName, String LastName, String Alias, String strEmail, String UserName) {

      if (m_listUserEmails.Contains(strEmail)) {
         System.assert(false, 'Email address already exists');
      }

      m_listUserEmails.add(strEmail);

      User objUser = new User(
                              ContactId = ContactId,
                              profileid = ProfileId,
                              firstname = FirstName,
                              lastname = LastName,
                              alias = Alias.left(8),
                              email = strEmail,
                              emailencodingkey = 'UTF-8',
                              languagelocalekey = 'en_US',
                              localesidkey = 'en_US',
                              country = 'United States',
                              IsActive = true,
                              timezonesidkey = 'America/Los_Angeles',
                              username = UserName,
                              No_AD_Account_Standard_User__c = true
      );
      return objUser;
   }

   //Return NI_Documentation__c with values assigned
   public static NI_Documentation__c GetNIDocObject(String NIDocName, Date DueDate) {
      if (NIDocName.toUpperCase().equals('GUID')) {
         NIDocName = AH_UDC_Shared.generateGUID();
      }

      Id recordTypeId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      NI_Documentation__c objNIDoc = new NI_Documentation__c();
      objNIDoc.RecordTypeId = recordTypeId;
      objNIDoc.Document_Name__c = NIDocName;
      objNIDoc.AH_UDC_ChatterWorkbookAccessed__c = false;
      objNIDoc.AH_UDC_ChatterWorkbookCompleted__c = false;
      objNIDoc.AH_UDC_WorkbookDueDate__c = DueDate;
      return objNIDoc;
   }

   //Return AH_UDC_Contact__c with values assigned
   public static AH_UDC_Contact__c GetUDCContactObject(Id NIDocId, Id ContactId, String strCurrency) {
      AH_UDC_Contact__c objUDCContact = new AH_UDC_Contact__c();
      objUDCContact.Contact__c = ContactId;
      objUDCContact.CurrencyIsoCode = strCurrency;
      objUDCContact.Document__c = NIDocId;
      return objUDCContact;
   }

   //Return a WORKBOOK_SENT type AH_UDC_Workbook__c record with values assigned
   public static AH_UDC_Workbook__c GetWorkbookObject(Id NIDocId, String WorkbookName, String Description, String Product) {
      Id recordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      return GetWorkbookObject(NIDocId, WorkbookName, Description, Product, recordTypeId);
   }

   //Return a AH_UDC_Workbook__c record of RecordType of Id "RecordTypeId" with values assigned
   public static AH_UDC_Workbook__c GetWorkbookObject(Id NIDocId, String WorkbookName, String Description, String Product, Id RecordTypeId) {
      AH_UDC_Workbook__c objWorkbook = new AH_UDC_Workbook__c();
      objWorkbook.RecordTypeId = RecordTypeId;
      objWorkbook.Name = WorkbookName;
      objWorkbook.RelatedTo__c = NIDocId;
      objWorkbook.Product__c = Product;
      objWorkbook.Description__c = Description;
      objWorkbook.Enabled__c = true;
      objWorkbook.SecurityCode__c = AH_UDC_Shared.GetSecurityCode();
      objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
      return objWorkbook;
   }

   //Return AH_UDC_WorkbookStep__c with values assigned
   public static AH_UDC_WorkbookStep__c GetWorkbookStepObject(Id WorkBookId, String StepName) {
      Id recordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
      AH_UDC_WorkbookStep__c objWorkbookStep = new AH_UDC_WorkbookStep__c();
      objWorkbookStep.RecordTypeId = recordTypeId;
      objWorkbookStep.Name = StepName;
      objWorkbookStep.Workbook__c = WorkBookId;
      objWorkbookStep.Enabled__c = true;
      objWorkbookStep.StepStatus__c = AH_UDC_Constants.STEP_STATUS_NEW;
      return objWorkbookStep;
   }

   //Return AH_UDC_Response__c with values assigned
   public static AH_UDC_Response__c GetStepResponseObject() {
      AH_UDC_Response__c objWorkbookStepResponse = new AH_UDC_Response__c();
      objWorkbookStepResponse.Responder__c = UserInfo.getUserId();
      objWorkbookStepResponse.Responded__c = Datetime.now();   
      return objWorkbookStepResponse;
   }

   //Return AH_UDC_Response__c with values assigned
   public static AH_UDC_WorkbookStepResponse__c GetWorkbookStepResponseObject(Id stepId, Id responseId) {
      AH_UDC_WorkbookStepResponse__c objWorkbookStepResponse = new AH_UDC_WorkbookStepResponse__c();
      objWorkbookStepResponse.WorkbookStep__c = stepId;
      objWorkbookStepResponse.Response__c = responseId;
      objWorkbookStepResponse.IsMostRecentResponse__c = true;
      return objWorkbookStepResponse;
   }

   //Return AH_UDC_ResponseQA__c with values assigned
   public static AH_UDC_ResponseQA__c GetStepResponseQAObject(Id responseId, String strQuestion, String strQuestionField, String strAnswer, String strAnswerFeild) {
      AH_UDC_ResponseQA__c objWorkbookStepResponseQA = new AH_UDC_ResponseQA__c();
      objWorkbookStepResponseQA.Response__c = responseId;
      objWorkbookStepResponseQA.Question__c = strQuestion;
      objWorkbookStepResponseQA.QuestionField__c = strQuestionField;
      objWorkbookStepResponseQA.Answer__c = strAnswer;
      objWorkbookStepResponseQA.AnswerField__c = strAnswerFeild;
      return objWorkbookStepResponseQA;
   }
 //Return AH_UDC_ResponseQA__c with values assigned
   public static AH_UDC_ResponseQA__c GetStepResponseQAObject(Id responseId, String strQAJson, Integer iSortOrder) {
      AH_UDC_ResponseQA__c objWorkbookStepResponseQA = new AH_UDC_ResponseQA__c();
      objWorkbookStepResponseQA.Response__c = responseId;
      objWorkbookStepResponseQA.QAJson__c = strQAJson;
      objWorkbookStepResponseQA.SortOrder__c = iSortOrder;     
      return objWorkbookStepResponseQA;
   }
   //Return AH_UDC_Workbook__c with values assigned
   public static AH_UDC_Workbook__c GetWorkbookObjectWithoutDocId(String WorkbookName, String Description, String Product) {
      Id workbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      AH_UDC_Workbook__c objWorkbook = new AH_UDC_Workbook__c();
      objWorkbook.RecordTypeId = workbookRecordTypeId;
      objWorkbook.Name = WorkbookName;
      objWorkbook.Product__c = Product;
      objWorkbook.Description__c = Description;
      return objWorkbook;
   }

   //Return AH_UDC_Form__c with values assigned
   public static AH_UDC_Form__c GetForm(String Definition, string FormAssemblyId, string Name, string CustomUrlId) {
      AH_UDC_Form__c form = new AH_UDC_Form__c();
      form.CustomUrlId__c = CustomUrlId;
      form.Definition__c = Definition;
      form.FormAssemblyId__c = FormAssemblyId;
      form.Name = Name;
      form.FormType__c = AH_UDC_Constants.FORM_TYPE_PRODUCT;
      return form;
   }

   public static AH_UDC_ConfigurationSetting__c GetConfigurationSetting(String Name, String SettingType, String PageGroupName, String PageSectionName, String PageName, String SettingValueDefault, String OrgName) {
      AH_UDC_ConfigurationSetting__c config = new AH_UDC_ConfigurationSetting__c();
      config.Name = Name;
      config.AH_UDC__c = true;
      config.SettingType__c = SettingType;
      config.PageGroupName__c = PageGroupName;
      config.PageSectionName__c = PageSectionName;
      config.PageName__c = PageName;
      config.DisplayOrder__c = 3;
      config.SettingDisplayName__c = 'Permission Set for Workbook Administrator User (API Name)';
      config.SettingHelpText__c = 'This is the API Name of the permission set assigned to Workbook Administrator users that will be using UDC';
      config.SettingValue__c = '';
      config.SettingValueDefault__c = SettingValueDefault;
      config.SettingValueDomain__c = '';
      config.UsedBy__c = '';
      config.OrgName__c = OrgName;
      return config;
   }

   public static string GetLastLogMessage() {
      String lastLogMessage = '';

      // This will dump up to 100 retrieved log messages to the Debug Log, to help track down unexpected messages
      for (AH_UDC_Log__c log : [SELECT LogText__c, CreatedDate FROM AH_UDC_Log__c WITH SECURITY_ENFORCED ORDER BY CreatedDate desc LIMIT 100]) {
         System.debug('Log message (' + log.CreatedDate + '): ' + log.LogText__c);

         // Save the text of the most recent Log message that was retrieved so it can be returned
         if (lastLogMessage == '') { lastLogMessage = log.LogText__c; }
      }

      return lastLogMessage;
   }

   public class TestDataException extends Exception { }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}