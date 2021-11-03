/**
* Name          : AH_UDC_InitializationHelper_TEST
* Description   : This is a test class for OrgHelper
* Dependencies  : AH_UDC_InitializationHelper
**/

@istest
public class AH_UDC_InitializationHelper_TEST {

   @testSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
   }

   // Do not make this a @testSetup method
   private static void initTest(){
      AH_UDC_ConfigHelper.SetValue('MaximumRoomNightsOrEvents', 10);

      AH_UDC_ConfigHelper.SetValue('LogExceptions', 'true');
      AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES, 'true');
      AH_UDC_ConfigHelper.SetValue('EmailLogExceptions', 'false');
   }

   @istest static public void testInvalidCall() {
      initTest();
      Test.startTest();

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

      Test.stopTest();

      System.assert(excMessage.contains('not implemented'), 'Unexpected result returned by AH_UDC_InitializationHelper callable: ' + excMessage);
   }

   @istest static public void testInvalid() {
      initTest();
      Test.startTest();

      //Call Method
      Map<string, Object> args = new Map<string, Object> ();
      args.put('mode', 'Unknown');
      Callable extension = (Callable) Type.forName('AH_UDC_InitializationHelper').newInstance();
      Object result = extension.call('Initialize', args);
      AH_UDC_LogHelper.Debug('#testInvalid result: ' + result);
      Test.stopTest();

      System.assertEquals('There was an issue initializing; please check the log', (string) result, 'Message not expected.');
   }

   @istest static public void testFalseReturn() {
      AH_UDC_LogHelper.Debug('testFalseReturn');

      initTest();
      Test.startTest();

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
      //Test.stopTest();

      System.assertEquals('There was an issue initializing; please check the log', (string) result, 'Message was not as expected');
      //System.assertEquals(false, b, 'Message was not as expected');
   }

   @istest static public void testInit() {
      initTest();
      Test.startTest();
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

      Test.stopTest();
      string orgIdPrefix = String.valueOf(orgInfo.id).left(15) + '||%';
      AH_UDC_ConfigurationSetting__c[] cSettings = [SELECT id, name from AH_UDC_ConfigurationSetting__c 
                                                    WHERE (OrgName__c = :orgInfo.Name or OrgName__c like :orgIdPrefix)];

      Boolean settingsExist = cSettings.size() > 0;
      System.assertEquals(true, settingsExist, 'No Settings Were Found');
   }

   @istest static public void testExceptionCS() {
      initTest();
      Test.startTest();
      Organization orgInfo = [select name from Organization];

      insert(new AH_UDC_ConfigurationSetting__c(Name='EXCEPTION', SettingType__c='Page',PageGroupName__c='test', PageName__c='test', PageSectionName__c='test', DisplayOrder__c=1, SettingDisplayName__c='General Settings', SettingHelpText__c='General Central Sales Settings', SettingValue__c='/apex/GeneralSettingsViewEdit', SettingValueDefault__c='', SettingValueDomain__c='', UsedBy__c='', OrgName__c=orgInfo.name));

      Boolean b = AH_UDC_InitializationHelper.Initialize(null);
      Test.stopTest();

      System.assertEquals(false, b, 'Return status was not false as expected when an exception occurs');

   }

   @istest static public void testExceptionWork() {
      initTest();
      Test.startTest();
      Organization orgInfo = [select name from Organization];

      insert(new AH_UDC_ConfigurationSetting__c(Name='EXCEPTION', SettingType__c='Page',PageGroupName__c='test', PageName__c='test', PageSectionName__c='test', DisplayOrder__c=1, SettingDisplayName__c='General Settings', SettingHelpText__c='General Central Sales Settings', SettingValue__c='/apex/GeneralSettingsViewEdit', SettingValueDefault__c='', SettingValueDomain__c='', UsedBy__c='', OrgName__c=orgInfo.name));

      Boolean b = AH_UDC_InitializationHelper.Initialize(null);
      Test.stopTest();

      System.assertEquals(false, b, 'Return status was not false as expected when an exception occurs');

   }

   @istest static public void testSettingWithReplaceableTag() {
      initTest();

      Test.startTest();
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