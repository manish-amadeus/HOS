/**
 * Name          : AH_UDC_Shared_TEST
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-Feb-02
 * Description   : Shared Methods for UDC code
 * Dependencies  : AH_UDC_Shared
 **/

@isTest
public class AH_UDC_Shared_TEST  {
   private static final string CLASS_NAME = 'AH_UDC_Shared_TEST';
   private static final string UDC_COMMUNITY_USER_NO_CHATTER = 'Shared_CUserNoChatter';
   private static final string UDC_SYSTEM_ADMIN = 'NewmarketTestUser1';

   //private static final String TEST_USER_NAME = 'testShared@user.com';

   //private static final string SystemAdminUser1 = 'SystemAdminUser1';

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      AH_UDC_Shared.InitializeFormTokenEncryptionKey();
      //Insert into Account object
      Account objAccount = AH_UDC_TestData.GetAccountObject('GUID');
      insert objAccount;

      //Insert into Contact object
      Contact objContactWithoutExternalUser = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact 3', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      objContactWithoutExternalUser.Email = 'test3@test.com';
      insert objContactWithoutExternalUser;

      //Insert into Account object
      AH_UDC_PropertyAccount__c objProperty = AH_UDC_TestData.GetPropertyObject('UDC Test Account 2', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
      objProperty.Account__c = objAccount.Id;
      objProperty.Phone__c = '00000000000';
      insert objProperty;

      String uniqueId = AH_UDC_Shared.generateGUID();
      Account newAccount = AH_UDC_TestData.GetAccountObject(uniqueId);
      insert newAccount;

      Contact newContact = AH_UDC_TestData.GetContactObject(newAccount.id, uniqueId);
      newContact.Email = 'test@NewContact.com';
      insert newContact;

      List<User> listUsers = new List<User> ();
      //Build UDC Service User
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                              UDC_SYSTEM_ADMIN, null, false));
      //Build Community User with no chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITHOUT_CHATTER,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                              UDC_COMMUNITY_USER_NO_CHATTER, newContact.Id, true));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         //AH_UDC_TestData.InsertWithRetries(listUsers);
         insert listUsers;

         // Community Users
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[1].Id);
      }

      //Insert new record into NI Documentation object for testing
      NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
      objNIDoc.Account__c = objAccount.Id;
      objNIDoc.AH_UDC_PropertyAccount__c = objProperty.Id;
      objNIDoc.OwnerId = listUsers[0].Id;
      insert objNIDoc;

      //Create UDC Contact
      AH_UDC_Contact__c udcContact = AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, newContact.Id, 'USD');
      //AH_UDC_Contact__c  udcContact = new AH_UDC_Contact__c(contact__c = newContact.Id, Document__c = objNIDoc.Id);
      insert udcContact;

      Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.runAs(listUsers[0]) {
         //Insert Workbook Record
         AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 1', 'Test Workbook 1 Descriptions', 'Central Sales');
         objWorkbook.RelatedTo__c = objNIDoc.Id;
         objWorkbook.Enabled__c = true;
         objWorkbook.RecordTypeId = workbookSentRecordTypeId;
         objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
         insert objWorkbook;

         string definition = '{"title":"UDCSB - SERVICES - RFP Toolkit - Section Names","FormAssemblyId":"4853168","CustomUrlId":"58c874ca-f1e4-4504-9878-b4b97af509ec","fields":[{"Name":"Token","APIName":"tfa_16","Repeat":"","Picklist":"false"},{"Name":"Security Code","APIName":"tfa_1","Repeat":"","Picklist":"false"},{"Name":"Parent Security Code","APIName":"tfa_17","Repeat":"","Picklist":"false"},{"Name":"Custom Section Name","APIName":"tfa_6","Repeat":"tfa_19[0]","Picklist":"false"},{"Name":"Section Title","APIName":"tfa_18","Repeat":"tfa_19[0]","Picklist":"false"},{"Name":"Yes","APIName":"tfa_11","Repeat":""},{"Name":"No, Specify Custom Section Names","APIName":"tfa_12","Repeat":""},{"Name":"Use the Default Section Names","APIName":"tfa_10","Repeat":""}]}';
         Id formAssemblyRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
         AH_UDC_Form__c objForm = AH_UDC_TestData.GetForm(definition, '4853168', 'Test Form', '58c874ca-f1e4-4504-9878-b4b97af509ec');
         objForm.RecordTypeId = formAssemblyRecordTypeId;
         insert objForm;

         //Insert First Workbook Record 
         AH_UDC_WorkbookStep__c objWorkbookStepOne = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 1');
         objWorkbookStepOne.Form__c = objForm.Id;
         insert objWorkbookStepOne;

         Id responseRecordTypeId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
         System.assert(String.isNotBlank(String.valueOf(responseRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY);

         AH_UDC_Response__c objResponse = AH_UDC_TestData.GetStepResponseObject();
         objResponse.RecordTypeId = responseRecordTypeId;
         insert objResponse;

         Id responseQARecordTypeId = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();
         System.assert(String.isNotBlank(String.valueOf(responseQARecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY);

         List<AH_UDC_ResponseQA__c> lstResponseQA = new List<AH_UDC_ResponseQA__c> ();
         AH_UDC_ResponseQA__c responseQA1 = AH_UDC_TestData.GetStepResponseQAObject(objResponse.Id, 'tfa_1', 'tfa_1', 'Ans 1', 'Ans1');
         responseQA1.RecordTypeId = responseQARecordTypeId;
         lstResponseQA.add(responseQA1);
         AH_UDC_ResponseQA__c responseQA2 = AH_UDC_TestData.GetStepResponseQAObject(objResponse.Id, 'tfa_6', 'tfa_6', 'Ans 6', 'Ans6');
         responseQA2.RecordTypeId = responseQARecordTypeId;
         AH_UDC_ResponseQA__c responseQA3 = AH_UDC_TestData.GetStepResponseQAObject(objResponse.Id, 'tfa_16', 'tfa_16', 'Ans 16', 'Ans16');
         responseQA2.RecordTypeId = responseQARecordTypeId;
         AH_UDC_ResponseQA__c responseQA4 = AH_UDC_TestData.GetStepResponseQAObject(objResponse.Id, 'tfa_17', 'tfa_17', 'Ans 17', 'Ans17');
         responseQA2.RecordTypeId = responseQARecordTypeId;
         AH_UDC_ResponseQA__c responseQA5 = AH_UDC_TestData.GetStepResponseQAObject(objResponse.Id, 'tfa_18', 'tfa_18', 'Ans 18', 'Ans18');
         responseQA2.RecordTypeId = responseQARecordTypeId;
         lstResponseQA.add(responseQA2);
         insert lstResponseQA;

         AH_UDC_WorkbookStepResponse__c objWBSResponse = AH_UDC_TestData.GetWorkbookStepResponseObject(objWorkbookStepOne.Id, objResponse.Id);
         insert objWBSResponse;
      }
   }

   @IsTest
   public static void testGetSecurityCode()
   {
      List<User> lstSystemAdminUser = [SELECT Id FROM User WHERE Username = :('test' + UDC_SYSTEM_ADMIN + '@amadeus.com')];
      System.assert(lstSystemAdminUser.size() > 0, 'System Admin users could not be found.');
      Test.startTest();
      System.runAs(lstSystemAdminUser[0]) {
         String s = AH_UDC_Shared.GetSecurityCode();
         System.assertEquals(false, String.isEmpty(s), 'A security code was expected but was instead null or empty');
         System.assertEquals(72, s.length(), 'A security code of length 72 was expected');

      }
      Test.stopTest();
   }

   @IsTest
   public static void testToken()
   {
      List<User> lstSystemAdminUser = [SELECT Id FROM User WHERE Username = :('test' + UDC_SYSTEM_ADMIN + '@amadeus.com')];
      System.assert(lstSystemAdminUser.size() > 0, 'System Admin users could not be found.');
      Test.startTest();
      System.runAs(lstSystemAdminUser[0]) {
         String s = AH_UDC_Shared.GetSecurityCode();         
         string sToken = AH_UDC_Shared.CreateStepToken(s, 'a0w290000022Yu5AAE', 'a1029000002cpToAAI');

         AH_UDC_Shared.Token token = AH_UDC_Shared.DecryptToken(sToken.substring(AH_UDC_Constants.FORM_TOKEN_PREFIX.length()));
         System.assertEquals(true, token.IsValid, 'Invalid token');
         System.assertEquals('a0w290000022Yu5AAE', token.FormId, 'FormId did not match');
         System.assertEquals('a1029000002cpToAAI', token.StepId, 'StepId did not match');
      }
      Test.stopTest();
   }

   @IsTest
   public static void testCharAt()
   {
      List<User> lstSystemAdminUser = [SELECT Id FROM User WHERE Username = :('test' + UDC_SYSTEM_ADMIN + '@amadeus.com')];
      System.assert(lstSystemAdminUser.size() > 0, 'System Admin users could not be found.');
      Test.startTest();
      System.runAs(lstSystemAdminUser[0]) {
         String s = AH_UDC_Shared.charAt(null, 1);
         System.assertEquals(null, s, 'Expected CharAt to return null string');
         s = AH_UDC_Shared.charAt('', 1);
         System.assertEquals('', s, 'Expected CharAt to return empty string');
         s = AH_UDC_Shared.charAt(null, - 1);
         System.assertEquals(null, s, 'Expected CharAt to return null string');
         s = AH_UDC_Shared.charAt('123', 7);
         System.assertEquals(null, s, 'Expected CharAt to return null string');
      }
      Test.stopTest();
   }

   @isTest
   public static void createChatter()
   {
      Test.startTest();
      List<NI_Documentation__c> lstNIDoc = [Select Id From NI_Documentation__c Where Document_Name__c = 'Test NI Document 1'];
      System.assert(lstNIDoc.size() > 0, 'Ni documentation records could not be found.');

      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [Select Id From AH_UDC_WorkbookStep__c Where Name = 'Test Step 1'];
      System.assert(lstWorkbookStep.size() > 0, 'Workbook step records could not be found.');
      List<User> lstUser = [SELECT Id FROM User WHERE Username = :('Test' + UDC_COMMUNITY_USER_NO_CHATTER + '@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      System.assert(lstUser.size() > 0, 'user could not be found.');

      System.runAs(lstUser[0]) {

         AH_UDC_MockResponseGenerator mock = new AH_UDC_MockResponseGenerator(AH_UDC_MockResponseGenerator.ResponseType.Chatter, 200);
         Test.setMock(HttpCalloutMock.class, mock);

         //Test Each Chat Type
         Boolean isChatterCreated = AH_UDC_SharedWithoutSharing.CreateChatter(lstNIDoc[0].Id, null, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookAccessed);
         System.assertEquals(true, isChatterCreated, 'Chatter Workbook Accessed Message was not created.');
         isChatterCreated = AH_UDC_SharedWithoutSharing.CreateChatter(lstNIDoc[0].Id, null, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookComplete);
         System.assertEquals(true, isChatterCreated, 'Chatter Workbook Complete Message was not created.');
         isChatterCreated = AH_UDC_SharedWithoutSharing.CreateChatter(lstNIDoc[0].Id, lstWorkbookStep[0].id, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookStepComplete);
         System.assertEquals(true, isChatterCreated, 'Chatter Workbook Step Complete Message was not created.');

         //Missing message type
         isChatterCreated = AH_UDC_SharedWithoutSharing.CreateChatter(lstNIDoc[0].Id, lstWorkbookStep[0].id, null);
         System.assert(!isChatterCreated, 'Could not generate Unhandled CreateChatterMessageType error.');
      }
      Test.stopTest();
   }

   @isTest
   public static void createChatterErrors()
   {
      Test.startTest();

      List<User> lstSystemAdminUser = [SELECT Id FROM User WHERE Username = :('test' + UDC_SYSTEM_ADMIN + '@amadeus.com')];
      System.assert(lstSystemAdminUser.size() > 0, 'System Admin users could not be found.');

      List<NI_Documentation__c> lstNIDoc = [Select Id From NI_Documentation__c Where Document_Name__c = 'Test NI Document 1'];
      System.assert(lstNIDoc.size() > 0, 'Ni documentation records could not be found.');
      List<User> lstUser = [SELECT Id FROM User WHERE Username = :('Test' + UDC_COMMUNITY_USER_NO_CHATTER + '@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      System.assert(lstUser.size() > 0, 'user could not be found.');

      System.runAs(lstUser[0]) {
         //Test Try Catch
         Boolean isChatterCreated = AH_UDC_SharedWithoutSharing.CreateChatter('TestException', null, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookStepComplete);
         System.assertEquals(false, isChatterCreated, 'Chatter failure expected for forced exception');

         //Test Missing NI Doc
         isChatterCreated = AH_UDC_SharedWithoutSharing.CreateChatter(lstSystemAdminUser[0].id, null, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookStepComplete);
         System.assertEquals(false, isChatterCreated, 'Chatter failure expected for NIDocumentationId that does not exist');

         //Workbook step not passed when required
         isChatterCreated = AH_UDC_SharedWithoutSharing.CreateChatter(lstNIDoc[0].Id, null, AH_UDC_SharedWithoutSharing.CreateChatterMessageType.WorkbookStepComplete);
         System.assertEquals(false, isChatterCreated, 'Chatter failure expected for Workbook Step Complete Message when Step ID is null.');
      }
      Test.stopTest();
   }

   @IsTest
   public static void testAmadeusFormDefinition()
   {
      Test.startTest();
      List<User> lstUser = [SELECT Id FROM User WHERE Username = :('Test' + UDC_COMMUNITY_USER_NO_CHATTER + '@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      System.assert(lstUser.size() > 0, 'User could not be found.');

      System.runAs(lstUser[0]) {
         String definitionAF = '{"product":"","formulas":[{"type":"hide","formula":"{product} == \'SO\'","formulafields":"product","ids":"UDC10"}],"sections":[{"title":"Floors","apiname":"UDC0","gridview":"false","inline":"true","scrollable":"true","insidesections":[{"title":"Rooms","apiname":"UDC1","gridview":"true","scrollable":"true","fields":[{"title":"Room #","name":"UDC2","type":"number","readOnly":"true","width":"200","labelabove":"true","tooltip":"Room Number","defaultvalue":"","placeholder":"Room Number","validation":{"required":"true","maxlength":"6","minlength":"3","onlynumber":"true"}},{"type":"dropdown","name":"UDC3","title":"Room Type","width":120,"source":[],"autocomplete":true,"dynamicsource":{"formid":"a0w290000022FyNAAU","formfield":"tfa_1"}},{"type":"dropdown","name":"UDC4","title":"Floor no.","width":120,"source":[],"autocomplete":true,"dynamicsource":{"formid":"a0w290000022HTrAAM","formfield":"tfa_11"}},{"title":"Room Code","name":"UDC5","type":"text","width":"200","labelabove":"true","tooltip":"Room Code","defaultvalue":""},{"title":"Extension","name":"UDC6","type":"text","width":"200","labelabove":"true","tooltip":"Extension","defaultvalue":"","placeholder":"Extension"},{"title":"Date","name":"UDC12","type":"calendar","width":"200", "labelabove": "true", "validation": {"allowpastdate": "false"}}]}],"fields":[{"title":"Floor #","name":"UDC7","type":"text","width":"200","labelabove":"true","tooltip":"Floor Number","defaultvalue":"","placeholder":"Floor Number"},{"width":"200","validation":null,"type":"dropdown","tooltip":"Floor No?","title":"Floor No?","source":[{"name":"Yes","id":"UDC8-0"},{"name":"No","id":"UDC8-1"}],"placeholder":"","name":"UDC8","labelabove":"true","formulas":[{"type":"hide","formula":"{UDC8} == \'UDC8-1\'","formulafields":"UDC8","ids":"UDC4"}]},{"title":"Total Rooms","name":"UDC9","type":"dropdown","width":"200","labelabove":"true","tooltip":"Total Rooms","source":[],"dynamicsource":{"formid":"a0w290000022FyNAAU","formfield":"tfa_1"}},{"title":"Show multiple columns?","name":"UDC10","type":"radiogroup","width":"200","labelabove":"true","tooltip":"Show multiple columns?","defaultvalue":"UDC10-0","placeholder":"","source":[{"id":"UDC10-0","name":"Yes"},{"id":"UDC10-1","name":"No"}]},{"title":"Dynamic RoomType?","name":"UDC11","type":"radiogroup","width":"200","labelabove":"true","tooltip":"Do you have Rooms?","defaultvalue":"no","placeholder":"","source":[{"id":"UDC11-0","name":"Yes"},{"id":"UDC11-1","name":"No"}],"dynamicsource":{"formid":"a0w290000022FyNAAU","formfield":"tfa_10"}}]}]}';
         AH_UDC_Shared.AmadeusFormDefinition amadeusFormDefinition = (AH_UDC_Shared.AmadeusFormDefinition) JSON.deserialize(definitionAF, AH_UDC_Shared.AmadeusFormDefinition.class);

         List<AH_UDC_Shared.Field> lstDynamicPicklist = new List<AH_UDC_Shared.Field> ();
         List<AH_UDC_Shared.Field> lstDynamicRadioGroup = new List<AH_UDC_Shared.Field> ();
         List<AH_UDC_Shared.Field> lstDynamicDefault = new List<AH_UDC_Shared.Field> ();
         List<AH_UDC_Shared.Field> fields;
         List<AH_UDC_Shared.Field> insidesectionFields;
         AH_UDC_Shared.section section;
         for (AH_UDC_Shared.section sec : amadeusFormDefinition.sections) {
            section = sec;
            System.assert(section.gridview == 'false', 'gridView is not expected for Section');
            System.assert(section.repeat == null, 'repeat is not expected to set for non repetable Section');
            System.assert(section.scrollable == 'true', 'scrollable = true expected for Section');
            System.assertEquals('Floors', section.title, 'Title should be \'Floors\'');
            System.assertEquals('UDC0', section.apiname, 'APIName is unexpected');
            System.assert(section.inline == 'true', 'inline attribute should be set true for Section');
            System.assert(section.maxheight == null, 'maxheight attribute is not exptcted to be set true for Section');
            System.assert(section.repeatsectionof == null, 'repeatsectionof attribute is not exptcted to be set for Section when section is not repeated');
            System.assert(section.fields.size() > 0, 'fields attribute is exptcted to be set for Section');
            lstDynamicRadioGroup.addAll(sec.getDynamicRadioGroups()); //add all the dynamic radiogroups in the list
            lstDynamicPicklist.addAll(sec.getDynamicPicklists()); //add all the dynamic picklists in the list
            lstDynamicDefault.addAll(sec.getDynamicDefaults()); //add all the dynamic picklists in the list
            if (sec.insidesections != null && sec.insidesections.size() > 0)
            {
               for (AH_UDC_Shared.section insideSection : sec.insidesections)
               {
                  insidesectionFields = insideSection.fields;
                  System.assertEquals('Rooms', insideSection.title, 'Title should be \'Rooms\'');

                  lstDynamicRadioGroup.addAll(insideSection.getDynamicRadioGroups()); //add all the dynamic radiogroups in the list
                  lstDynamicPicklist.addAll(insideSection.getDynamicPicklists()); //add all the dynamic picklists in the list
                  lstDynamicDefault.addAll(insideSection.getDynamicDefaults()); //add all the dynamic picklists in the list
               }
            }
         }

         for (AH_UDC_Shared.Field sf : section.fields)
         {
            System.assert(sf.labelabove == 'true', 'labelabove attribute is exptcted to be set true');

            if (sf.type == 'text')
            {
               sf.wordwrap = 'true';
               sf.width = '200';
               System.assert(sf.placeholder.length() > 0, 'Expected placeholder to be set');
               System.assert(sf.tooltip.length() > 0, 'Expected tooltip to be set');
            }
            if (sf.formulas != null && sf.formulas.size() > 0)
            {
               AH_UDC_Shared.Formulas formula = sf.formulas[0];
               System.assertEquals('hide', formula.type, 'Formula type should be hide');
               System.assert(formula.ids.length() > 0, 'Expected Ids to be set to hide');
               System.assert(formula.formula.length() > 0, 'Expected formula to be set');
               System.assert(formula.formulafields.length() > 0, 'Expected formulafields to be set');
            }
            if (sf.dynamicsource != null)
            {
               System.assert(sf.dynamicsource.formfield.length() > 0, 'Expected formfield to be set');
               System.assert(sf.dynamicsource.formid.length() > 0, 'Expected formid to be set');
            }
         }
         for (AH_UDC_Shared.Field isf : insidesectionFields)
         {
            System.assert(isf.value == null, 'Expected value not to be set in definition');

            if (isf.type == 'number' && isf.validation != null)
            {
               System.assert(isf.mask == null, 'Expected mask not to be set');
               System.assert(isf.validation.onlynumber == 'true', 'Validation for Number type is expected to be set OnlyNumber  = true');
               System.assert(isf.validation.maxlength == '6', 'Expected maxlength to be set 6');
               System.assert(isf.validation.minlength == '3', 'Expected minlength to be set 3');
               System.assert(isf.validation.required == 'true', 'Expected required true');
               System.assert(isf.validation.alphanumeric == null, 'Expected alphanumeric validation not to be set for number');
               System.assert(isf.validation.onlyalpha == null, 'Expected onlyalpha validation not to be set for number');
            }

            if ((isf.type == 'dropdown' || isf.type == 'radio') && isf.dynamicsource == null)
            {
               System.assert(isf.source.size() > 0, 'Expected source to be set');
               System.assert(isf.autocomplete == 'true', 'Expected autocomplete to be set to true');
            }

            if (isf.name == 'UDC12' && isf.type == 'calendar' && isf.validation != null)
            {
               System.assertEquals('false', isf.validation.allowpastdate, 'Expected allowpastdate to be set to false');
            }
         }
         AH_UDC_Shared.Field f1 = new AH_UDC_Shared.Field();
         f1.title = 'Date';
         f1.name = 'UDC12';
         f1.wordwrap = 'true';
         f1.type = 'calendar';
         f1.options = new AH_UDC_Shared.Options();
         f1.options.format = 'YYYY-mmm-DD';

         AH_UDC_Shared.Field f2 = new AH_UDC_Shared.Field();
         f2.title = 'Room Type 1';
         f2.name = 'UDC13';
         f2.type = 'dropdown';
         f2.autocomplete = 'true';
         List<AH_UDC_Shared.Source> sources = new List<AH_UDC_Shared.Source> ();
         AH_UDC_Shared.Source s1 = new AH_UDC_Shared.Source();
         s1.id = 'RoomType1';
         s1.name = 'Single Room';
         AH_UDC_Shared.Source s2 = new AH_UDC_Shared.Source();
         s2.id = 'RoomType2';
         s2.name = 'Single Room';
         sources.add(s1);
         sources.add(s2);
         f2.source = sources;
         f2.defaultvalue = s2.name;

         AH_UDC_Shared.Field f3 = new AH_UDC_Shared.Field();
         f3.title = 'Long Text';
         f3.name = 'UDC14';
         f3.wordwrap = 'true';
         f3.contenttype = 'longtext';
         f3.type = 'text';

         amadeusFormDefinition.title = 'AmadeusForm Test';
         System.assertEquals(true, String.isEmpty(amadeusFormDefinition.product), 'Product name should be empty');
         System.assertEquals(1, amadeusFormDefinition.formulas.size(), 'AmadeusFormDefinition for step2 should have 1 formula');

         AH_UDC_Shared.Formulas formula = amadeusFormDefinition.formulas[0];
         System.assertEquals('hide', formula.type, 'Formula type should be hide');
         System.assert(formula.ids.length() > 0, 'Expected Ids to be set to hide');
         System.assert(formula.formula.length() > 0, 'Expected formula to be set');
         System.assert(formula.formulafields.length() > 0, 'Expected formulafields to be set');

         System.assertEquals(3, lstDynamicPicklist.size(), 'AmadeusFormDefinition for step2 should have 3 dynamic piclist');
         System.assertEquals(1, lstDynamicRadioGroup.size(), 'AmadeusFormDefinition for step2 should have 1 dynamic radiogroup');
      }
      Test.stopTest();
   }

   @IsTest
   public static void testFormAssemblyFormDefinition()
   {
      Test.startTest();
      List<User> lstUser = [SELECT Id FROM User WHERE Username = :('Test' + UDC_COMMUNITY_USER_NO_CHATTER + '@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      System.assert(lstUser.size() > 0, 'User could not be found.');

      String definition = AH_UDC_TestData.getFormDefinition_DefaultAndPicklistStep2();
      System.runAs(lstUser[0]) {
         AH_UDC_Shared.FormDefinition formDefinition = (AH_UDC_Shared.FormDefinition) JSON.deserialize(definition, AH_UDC_Shared.FormDefinition.class);
         List<AH_UDC_Shared.FormField> lstFormFields = formDefinition.getPicklists();
         AH_UDC_Shared.FormField field = formDefinition.getFieldByAPIName('tfa_24');
         System.assertEquals('Picklist', field.Name, 'Field name should match');
         field = formDefinition.getFieldByName('Default');
         System.assertEquals('tfa_54', field.APIName, 'APIName should match');
      }
      Test.stopTest();
   }

   @isTest
   public static void testGetWorkbookAndItsSteps() {
      List<AH_UDC_Workbook__c> lstWorkbook = [Select Id From AH_UDC_Workbook__c Where Name = 'Test Workbook 1'];
      System.assert(lstWorkbook.size() > 0, 'Workbooks could not be found.');
      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [Select Id, Workbook__c, Workbook__r.ParentWorkbookSent__c, Form__r.Definition__c From AH_UDC_WorkbookStep__c Where Name LIKE 'Test Step%'];
      System.assert(lstWorkbookStep.size() > 0, 'Workbook steps could not be found.');
      Test.startTest();
      List<User> lstUser = [SELECT Id FROM User WHERE Username = :('Test' + UDC_COMMUNITY_USER_NO_CHATTER + '@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      System.assert(lstUser.size() > 0, 'User could not be found.');

      System.runAs(lstUser[0]) {
         AH_UDC_SharedWithoutSharing.GetWorkbookStepSentUrl(lstWorkbookStep[0].Id);
         Map<Id, String> mapStepIds = AH_UDC_SharedWithoutSharing.GetWorkbookStepSentUrls(lstWorkbookStep);
         System.assert(mapStepIds != null && mapStepIds.size() == lstWorkbookStep.size(), 'Could not match the GetWorkbookStepSentUrls size');

         //Check workbook user access
         Boolean isAccess = AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess(lstWorkbook[0].Id);
         System.assert(isAccess, 'External user does not have access');

         //Test the catch block
         isAccess = AH_UDC_SharedWithoutSharing.CheckViewWorkbookUserAccess('TestException');
         System.assert(!isAccess, 'External user does not have access');

         Boolean token = AH_UDC_Shared.InitializeFormTokenEncryptionKey();
         System.assertEquals(true, token, 'Form token encryption key could not valid');

         AH_UDC_Shared.FormField ff = new AH_UDC_Shared.FormField();
         AH_UDC_Shared.FormDefinition formDefinition = (AH_UDC_Shared.FormDefinition) JSON.deserialize(lstWorkbookStep[0].getSObject('Form__r').get('Definition__c').toString(), AH_UDC_Shared.FormDefinition.class);

         List<AH_UDC_Shared.FormField> foundPicklists = formDefinition.getPicklists();
         System.assertEquals(0, foundPicklists.size(), 'foundPicklists value could be size zero');
      }
      Test.stopTest();
   }

   @isTest
   private static void testCommunityUser() {
      List<Contact> lstContactWithoutExternalUser = [Select Id, Name From Contact Where FirstName = 'Test' And LastName = 'Contact 3'];
      System.assert(lstContactWithoutExternalUser.size() > 0, 'Contact without external user could not be found.');
      Test.startTest();
      List<User> lstUser = [SELECT Id FROM User WHERE Username = :('Test' + UDC_SYSTEM_ADMIN + '@amadeus.com')];
      System.assert(lstUser.size() > 0, 'System Admin user not found.');

      AH_UDC_MockResponseGenerator mock;
      mock = new AH_UDC_MockResponseGenerator(AH_UDC_MockResponseGenerator.ResponseType.CreateCommunityUser, 200);
      Test.setMock(HttpCalloutMock.class, mock);

      //Create external user if contact does not have
      System.runAs(lstUser[0]) {
         Boolean hasAccess = AH_UDC_SharedWithoutSharing.SetupCommunityAccess(lstContactWithoutExternalUser[0].Id);
         System.assert(hasAccess, 'Unable to setup community access');
      }
      Test.stopTest();
   }

   @isTest
   private static void testChangeUserProfileToChatter() {
      Test.startTest();
      List<User> lstUser = [SELECT Id FROM User WHERE Username = :('Test' + UDC_COMMUNITY_USER_NO_CHATTER + '@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      System.assert(lstUser.size() > 0, 'User could not be found.');
      //Create external user if contact does not have
      System.runAs(lstUser[0]) {
         AH_UDC_MockResponseGenerator mock;
         mock = new AH_UDC_MockResponseGenerator(AH_UDC_MockResponseGenerator.ResponseType.SetCommunityUserProfile, 200);
         Test.setMock(HttpCalloutMock.class, mock);

         //Change the external user profile
         Boolean isChanged = AH_UDC_SharedWithoutSharing.ChangeUserProfileToChatter(UserInfo.getUserId());
         System.assertEquals(true, isChanged, 'External User profile was not changed');
      }
      Test.stopTest();
   }

   @isTest
   private static void testCreateStepToken() {
      Test.startTest();
      List<User> lstUser = [SELECT Id FROM User WHERE Username = :('Test' + UDC_COMMUNITY_USER_NO_CHATTER + '@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      System.assert(lstUser.size() > 0, 'User could not be found.');

      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      objWorkbook.Enabled__c = true;
      insert objWorkbook;

      Id formAssemblyFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(formAssemblyFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY);

      AH_UDC_Form__c objForm = new AH_UDC_Form__c();
      objForm.RecordTypeId = formAssemblyFormRecordTypeId;
      objForm.Name = 'Test Form 1';
      objForm.FormType__c = AH_UDC_Constants.FORM_TYPE_PRODUCT;

      //Generate 7 digits form assembly Id
      Integer intFormAssemblyId = (Integer) Math.round(Math.random() * (9000000) + 1000000);
      objForm.FormAssemblyId__c = String.valueOf(intFormAssemblyId);
      insert objForm;

      Id workbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookStepRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP);

      AH_UDC_WorkbookStep__c objWorkbookStep = new AH_UDC_WorkbookStep__c();
      objWorkbookStep.RecordTypeId = workbookStepRecordTypeId;
      objWorkbookStep.Name = 'Test Step 1';
      objWorkbookStep.Workbook__c = objWorkBook.Id;
      objWorkbookStep.Enabled__c = true;
      objWorkbookStep.Form__c = objForm.Id;
      insert objWorkbookStep;

      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = [SELECT Id, Workbook__r.SecurityCode__c, Form__c
                                                       FROM AH_UDC_WorkbookStep__c
                                                       WHERE Id = :objWorkbookStep.Id];
      System.assert(lstWorkbookSteps.size() > 0, 'Step record not found with Id ' + objWorkbookStep.Id);
      System.runAs(lstUser[0]) {
         String strToken = AH_UDC_Shared.CreateStepToken(lstWorkbookSteps[0].Workbook__r.SecurityCode__c, lstWorkbookSteps[0].Form__c, lstWorkbookSteps[0].id);
         System.assert(String.isNotBlank(strToken), 'Step token not generated');

         AH_UDC_Shared.Token newToken = AH_UDC_Shared.DecryptToken(strToken.substring(AH_UDC_Constants.FORM_TOKEN_PREFIX.length()));
         System.assertEquals(true, newToken.IsValid, 'Token is not valid');
      }
      Test.stopTest();
   }

   @isTest
   private static void testForNegativeToken() {
      Test.startTest();
      List<User> lstUser = [SELECT Id FROM User WHERE Username = :('Test' + UDC_COMMUNITY_USER_NO_CHATTER + '@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      System.assert(lstUser.size() > 0, 'User could not be found.');
      System.runAs(lstUser[0]) {
         String strToken = AH_UDC_Shared.CreateStepToken('Bad Security Code', null, null);
         System.assert(String.isNotBlank(strToken), 'Step token not generated');
         AH_UDC_Shared.Token newToken = AH_UDC_Shared.DecryptToken(strToken.substring(AH_UDC_Constants.FORM_TOKEN_PREFIX.length()));
         System.assertEquals(false, newToken.IsValid, 'Token is valid');
         System.assertEquals(true, String.isBlank(newToken.FormId), 'FormId should be blank');
         System.assertEquals(true, String.isBlank(newToken.StepId), 'StepId should be blank');
      }
      Test.stopTest();
   }

   @isTest
   private static void testGetFieldByName() {
      Test.startTest();
      List<User> lstUser = [SELECT Id FROM User WHERE Username = :('Test' + UDC_COMMUNITY_USER_NO_CHATTER + '@amadeus.com' + AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX)];
      System.assert(lstUser.size() > 0, 'User could not be found.');
      System.runAs(lstUser[0]) {
         String strJSON = '{"title":"Test Form","FormAssemblyId":"4853750","CustomUrlId":"4853750","fields":[{"Name":"Security Code","APIName":"tfa_1","Repeat":"","Picklist":"false","InputType":"Text"},{"Name":"Token","APIName":"tfa_2","Repeat":"","Picklist":"false","InputType":"Text"}]}';
         AH_UDC_Shared.FormDefinition objFormDefinition = (AH_UDC_Shared.FormDefinition) JSON.deserialize(strJSON, AH_UDC_Shared.FormDefinition.class);
         String strAPIName = objFormDefinition.getFieldByName('Security Code').APIName;
         System.assertEquals('tfa_1', strAPIName, 'Step token not generated');
      }
      Test.stopTest();
   }

   @isTest
   private static void negativeTest() {
      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id FROM AH_UDC_Workbook__c WHERE Name = 'Test Workbook 1'];
      System.assert(lstWorkbook.size() > 0, 'workbooks could not be found.');
      Test.startTest();
      List<User> lstUser = [SELECT Id FROM User WHERE Email = :('test' + UDC_SYSTEM_ADMIN + '@amadeus.com')];
      List<AH_UDC_Log__c> logMessages = null;

      AH_UDC_TestData.clearLogs();

      System.runAs(lstUser[0])
      {
         //Negative Test for getting a Workbook Step Sent URL
         String stepsUrl = AH_UDC_SharedWithoutSharing.GetWorkbookStepSentUrl(lstWorkbook[0].Id);
         System.assert(String.isBlank(stepsUrl), 'Step Urls should be blank');
         logMessages = [SELECT Id, LogText__c FROM AH_UDC_Log__c];
         System.assert(logMessages.size() > 0, 'Expected log messages');
         System.assert(logMessages[0].LogText__c.contains('One or more Workbook Steps Not Found'), 'Did not have the expected log message.');

         List<AH_UDC_ConfigurationSetting__c> tokenEncryptionKey = [SELECT Id, Name FROM AH_UDC_ConfigurationSetting__c WHERE Name = 'AH_UDC_ViewWorkbookTokenEncryptionKey'];
         System.assert(tokenEncryptionKey.size() > 0, 'Configuration Setting - "AH_UDC_ViewWorkbookTokenEncryptionKey" could not be found');
         Delete tokenEncryptionKey;
         Boolean token = AH_UDC_Shared.InitializeFormTokenEncryptionKey();
         System.assert(!token, 'An exception occurred while calling the InitializeFormTokenEncryptionKey');

         AH_UDC_TestData.clearLogs();
         Boolean hasAccess = AH_UDC_SharedWithoutSharing.SetupCommunityAccess('TestException');
         System.assert(!hasAccess, 'Community Access should not have been setup correctly. Expect this to fail');
         logMessages = [SELECT Id, LogText__c FROM AH_UDC_Log__c];
         System.assert(logMessages.size() > 0, 'Expected log messages');
         System.assert(logMessages[0].LogText__c.contains('Divide by 0'), 'Did not have the expected log message.');
      }
      Test.stopTest();
   }

   @isTest
   private static void TestEmailReplacement() {
      //RunAs is not needed since method only uses values passed in
      Test.startTest();

      string HtmlBody ='A{CUser.FirstName}B';
      string dueDate =''; 
      string sendToFirstName ='TESTFN';
      string sendTolastName ='';
      string SendToemail ='';
      string sendToUsername ='';
      string allUserName ='';

      HtmlBody = AH_UDC_SharedWithoutSharing.PerformReplacementsOnHtml(HtmlBody, dueDate, 
      sendToFirstName, sendTolastName, SendToemail, sendToUsername,
      allUserName);
      System.assertEquals('ATESTFNB', HtmlBody, 'Replace did not occur as expected.');
      Test.stopTest();
   }
}