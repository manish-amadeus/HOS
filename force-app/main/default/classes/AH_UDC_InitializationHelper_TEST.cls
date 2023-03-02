/**
 * Name          : AH_UDC_InitializationHelper_TEST
 * Description   : This is a test class for OrgHelper
 * Dependencies  : AH_UDC_InitializationHelper
 **/

@istest
public class AH_UDC_InitializationHelper_TEST {

   @testSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();

      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                              'InitializeHelperUDCSysAdmin', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[0].Id);
      }
   }

   // Do not make this a @testSetup method
   private static void initTest() {
      AH_UDC_ConfigHelper.SetValue('MaximumRoomNightsOrEvents', 10);

      AH_UDC_ConfigHelper.SetValue('LogExceptions', 'true');
      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES, 'true');
      AH_UDC_ConfigHelper.SetValue('EmailLogExceptions', 'false');
   }

   @istest static public void testInvalidCall() {
      initTest();
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%InitializeHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {

         //Call Method
         Map<string, Object> args = new Map<string, Object> ();
         args.put('mode', 'Unknown');
         Callable extension = (Callable) Type.forName('AH_UDC_InitializationHelper').newInstance();
         string excMessage = '';
         try {
            Object result = extension.call('Error', args);
         }
         catch(exception exc) {
            excMessage = exc.getMessage();
         }
         System.assert(excMessage.contains('not implemented'), 'Unexpected result returned by AH_UDC_InitializationHelper callable: ' + excMessage);
      }
      Test.stopTest();
   }

   @istest static public void testInvalid() {
      initTest();
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%InitializeHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         //Call Method
         Map<string, Object> args = new Map<string, Object> ();
         args.put('mode', 'Unknown');
         Callable extension = (Callable) Type.forName('AH_UDC_InitializationHelper').newInstance();
         Object result = extension.call('Initialize', args);
         AH_UDC_LogHelper.Debug('#testInvalid result: ' + result);
         System.assertEquals('There was an issue initializing; please check the log', (string) result, 'Message not expected.');
      }
      Test.stopTest();
   }

   @istest static public void testFalseReturn() {
      AH_UDC_LogHelper.Debug('testFalseReturn');

      initTest();
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%InitializeHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         //Call Method
         Map<string, Object> args = new Map<string, Object> ();
         args.put('mode', (Object) 'TestFalse');
         AH_UDC_LogHelper.Debug('TEST');
         for (string key : args.keySet()) {
            AH_UDC_LogHelper.Debug('arg Test key: ' + key);
            AH_UDC_LogHelper.Debug('arg Test value: ' + args.get(key));
         }

         Callable extension = (Callable) Type.forName('AH_UDC_InitializationHelper').newInstance();
         Object result = extension.call('Initialize', args);
         //Boolean b = AH_UDC_InitializationHelper.Initialize('TestFalse');
         System.assertEquals('There was an issue initializing; please check the log', (string) result, 'Message was not as expected');
      }
      Test.stopTest(); //was commented VP
      //System.assertEquals(false, b, 'Message was not as expected');
   }

   @istest static public void testInit() {
      initTest();
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%InitializeHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         Organization orgInfo = [select Id, name from Organization];

         Boolean b = AH_UDC_InitializationHelper.Initialize(null);
         System.assertEquals(true, b, 'Return Status was not true');

         //insert(new AH_UDC_ConfigurationSetting__c(Name='CS_TEST', SettingType__c='Page',PageGroupName__c='test', PageName__c='test', PageSectionName__c='test', DisplayOrder__c=1, SettingDisplayName__c='General Settings', SettingHelpText__c='General Central Sales Settings', SettingValue__c='/apex/GeneralSettingsViewEdit', SettingValueDefault__c='', SettingValueDomain__c='', UsedBy__c='', OrgName__c=orgInfo.name));
         AH_UDC_ConfigHelper.SetValue('CS_TEST', '/apex/GeneralSettingsViewEdit');

         //Call Method
         Map<string, Object> args = new Map<string, Object> ();
         args.put('mode', 'All');
         Callable extension = (Callable) Type.forName('AH_UDC_InitializationHelper').newInstance();
         Object result = extension.call('Initialize', args);

         System.assertEquals('Initialization Completed', (string) result, 'Expected the initialization to have completed');
         string orgIdPrefix = String.valueOf(orgInfo.id).left(15) + '||%';
         AH_UDC_ConfigurationSetting__c[] cSettings = [SELECT id, name from AH_UDC_ConfigurationSetting__c
                                                       WHERE(OrgName__c = :orgInfo.Name or OrgName__c like :orgIdPrefix)];

         Boolean settingsExist = cSettings.size() > 0;
         System.assertEquals(true, settingsExist, 'No Settings Were Found');
      }
      Test.stopTest();
   }

   @istest static public void testExceptionCS() {
      initTest();
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%InitializeHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         Organization orgInfo = [select name from Organization];

         insert(new AH_UDC_ConfigurationSetting__c(Name = 'EXCEPTION', SettingType__c = 'Page', PageGroupName__c = 'test', PageName__c = 'test', PageSectionName__c = 'test', DisplayOrder__c = 1, SettingDisplayName__c = 'General Settings', SettingHelpText__c = 'General Central Sales Settings', SettingValue__c = '/apex/GeneralSettingsViewEdit', SettingValueDefault__c = '', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgInfo.name));

         Boolean b = AH_UDC_InitializationHelper.Initialize(null);
         System.assertEquals(false, b, 'Return status was not false as expected when an exception occurs');
      }
      Test.stopTest();

   }

   @istest static public void testExceptionWork() {
      initTest();
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%InitializeHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         Organization orgInfo = [select name from Organization];

         insert(new AH_UDC_ConfigurationSetting__c(Name = 'EXCEPTION', SettingType__c = 'Page', PageGroupName__c = 'test', PageName__c = 'test', PageSectionName__c = 'test', DisplayOrder__c = 1, SettingDisplayName__c = 'General Settings', SettingHelpText__c = 'General Central Sales Settings', SettingValue__c = '/apex/GeneralSettingsViewEdit', SettingValueDefault__c = '', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgInfo.name));

         Boolean b = AH_UDC_InitializationHelper.Initialize(null);
         System.assertEquals(false, b, 'Return status was not false as expected when an exception occurs');
      }
      Test.stopTest();
   }

   @istest static public void testSettingWithReplaceableTag() {
      initTest();

      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%InitializeHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         Organization orgInfo = [select name from Organization];

         string tag = '{!TestServer}';
         string server = 'naas-dev.newmarketinc.com';
         string valueWithMergeTag = 'https://' + tag + '/2.0/OAuth2/AccessToken';
         string expectedValue = 'https://' + server + '/2.0/OAuth2/AccessToken';

         string PageName = 'test';
         string PageSectionName = 'test';
         string PageGroupName = 'test';
         insert(new AH_UDC_ConfigurationSetting__c(Name = 'TestServer', SettingType__c = 'String', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 200, SettingDisplayName__c = 'Test Server Name', SettingHelpText__c = 'Server name to connect to for DEV/QA/STAGING/PROD', SettingValue__c = 'naas-dev.newmarketinc.com', SettingValueDefault__c = 'naas-dev.newmarketinc.com', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgInfo.name));
         insert(new AH_UDC_ConfigurationSetting__c(Name = 'TestURL', SettingType__c = 'String', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 200, SettingDisplayName__c = 'Test URL', SettingHelpText__c = 'Test config setting', SettingValue__c = valueWithMergeTag, SettingValueDefault__c = valueWithMergeTag, SettingValueDomain__c = '', UsedBy__c = 'WorkOrchestrator', OrgName__c = orgInfo.name));

         string value = AH_UDC_ConfigHelper.GetString('TestURL', null);

         System.assertEquals(expectedValue, value, 'Replacement of the tag "' + tag + '" did not work correctly. ConfigHelper return a value of: "' + value + '"');
      }
      Test.stopTest();
   }

   @istest static public void testSchedulePurgeJob() {
      initTest();
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%InitializeHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');
      System.runAs(lstUser[0]) {
         //Call Method
         Map<string, Object> args = new Map<string, Object> ();

         args.put('mode', 'add');
         Callable extension = (Callable) Type.forName('AH_UDC_InitializationHelper').newInstance();
         Object result = extension.call('SchedulePurgeJob', args);
         System.assertEquals('Scheduled Purge job was added', (string) result, 'Schedule job is not scheduled');

         args.put('mode', 'verify');
         result = extension.call('SchedulePurgeJob', args);
         System.assert(((string) result).startsWithIgnoreCase('Scheduled Purge job will run at:'), 'Schedule job is not verified');

         args.put('mode', 'remove');
         result = extension.call('SchedulePurgeJob', args);
         System.assertEquals('Scheduled Purge job was removed', (string) result, 'Schedule job is not removed');

         args.put('mode', 'add');
         result = extension.call('SchedulePurgeJob', args);
         System.assertEquals('Scheduled Purge job was added', (string) result, 'Schedule job is not scheduled');

         args.put('mode', 'test');
         result = extension.call('SchedulePurgeJob', args);
         System.assert(((string) result).startsWithIgnoreCase('SchedulePurgeJob, unkown mode: '), 'Schedule job is unknown');
      }
      Test.stopTest();
   }

   @istest static public void testScheduleWorkbookSentEmailJob() {
      initTest();
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%InitializeHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');
      System.runAs(lstUser[0]) {
         //Call Method
         Map<string, Object> args = new Map<string, Object> ();
         Callable extension = (Callable) Type.forName('AH_UDC_InitializationHelper').newInstance();

         args.put('mode', 'add');
         string result = (string) extension.call('ScheduleWorkbookSentEmailJob', args);
         //System.assertEquals('The Workbook Sent Email job is already scheduled', result, 'Schedule Workbook Sent Email job is not schedule');
         System.assertEquals('Scheduled Workbook Sent Email job was added', result, 'Schedule Workbook Sent Email job is not schedule');
         args.put('mode', 'verify');
         result = (string) extension.call('ScheduleWorkbookSentEmailJob', args);
         System.assert(result.startsWithIgnoreCase('Scheduled Workbook Sent Email job will run at:'), 'Schedule Workbook Sent Email job is not verfied');

         args.put('mode', 'remove');
         result = (string) extension.call('ScheduleWorkbookSentEmailJob', args);
         System.assert(result.startsWithIgnoreCase('Scheduled Workbook Sent Email job was removed'), 'Schedule Workbook Sent Email job is not removed');

         args.put('mode', 'test');
         result = (string) extension.call('ScheduleWorkbookSentEmailJob', args);
         System.assert(((string) result).startsWithIgnoreCase('ScheduleWorkbookSentEmailJob, unkown mode: '), 'ScheduleWorkbookSentEmailJob is unknown');
      }
      Test.stopTest();
   }

   /*
     @istest static public void testManagedPackageTagReplacement() {
     initTest();
     Test.startTest();
     Organization orgInfo = [select name from Organization];
    
     //Call Method
     Map<string, Object> args = new Map<string, Object> ();
     args.put('mode', 'All');
     Callable extension = (Callable) Type.forName('AH_UDC_InitializationHelper').newInstance();
     Object result = extension.call('Initialize', args);
    
     System.assertEquals('Initialization Completed', (string) result, 'Expected the initialization to have completed');
    
     string value = ConfigHelper.GetString('AHWSAuthURL', null);
     System.debug('testManagedPackageTagReplacement value == ' + value);
     System.assertEquals(false, value.contains('{!AWHSAuthURL}'), 'Merge tag was not replaced as expected. Value returned was: ' + value);
    
     Test.stopTest();
     }
    */
}