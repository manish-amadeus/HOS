<<<<<<< HEAD
<<<<<<< HEAD
/*
 * File            : AH_UDC_ConfigHelper_TEST.cls
 * Created Date    : 2019-08-29
 * Created By      : George.Tasker@amadeus.com
 * Description     : Caching routines to use Cache (if enabled) to store previously retrieved configuration
 *                   values so they can be retrieved without needing to make a SOQL call
 */
@isTest
public class AH_UDC_ConfigHelper_TEST
{
   private static string TEST_KEY = 'TestCache';
   private static string TEST_CONFIG_VALUE_A = 'TestCacheValue_A';
   private static string TEST_CONFIG_VALUE_B = 'TestCacheValue_B';

   private static string TEST_CONFIG_KEY_INTEGER = 'FirstThreeIntegers';
   private static Integer TEST_CONFIG_VALUE_INTEGER = 123;

   private static string TEST_CONFIG_KEY_BOOLEAN = 'Vacancy';
   private static Boolean TEST_CONFIG_VALUE_BOOLEAN = true;

   private static string TEST_CONFIG_KEY_1 = 'Test1';
   private static string TEST_CONFIG_VALUE_1 = 'Test1OriginalValue';

   private static string TEST_CONFIG_KEY_2 = 'Test2';
   private static string TEST_CONFIG_VALUE_2 = 'Test2OriginalValue';

   private static string TEST_CONFIG_KEY_3 = 'Test3';
   private static string TEST_CONFIG_VALUE_3 = 'Test3OriginalValue';

   private static string TEST_CONFIG_KEY_4 = 'Test4';
   private static string TEST_CONFIG_VALUE_4 = 'Test4OriginalValue';

   private static string TEST_CONFIG_KEY_5 = 'Test5';
   private static string TEST_CONFIG_VALUE_5 = 'Test5OriginalValue';

   private static string TEST_CONFIG_KEY_1_1 = 'Test1_1';
   private static string TEST_CONFIG_VALUE_1_1 = 'Test1_1OriginalValue';

   private static string TEST_CONFIG_KEY_2_1 = 'Test2_1';
   private static string TEST_CONFIG_VALUE_2_1 = 'Test2_1OriginalValue';

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('TestClass');
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs1 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_1,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'String',
                                                                              SettingValue__c = TEST_CONFIG_VALUE_1,
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs1;

      //Add a another setting
      AH_UDC_ConfigurationSetting__c cs2 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 2,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_2,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'String',
                                                                              SettingValue__c = TEST_CONFIG_VALUE_2,
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs2;

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs3 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_3,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'Integer',
                                                                              SettingValue__c = '100',
                                                                              SettingValueDefault__c = '1',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs3;

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs4 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_4,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'Checkbox',
                                                                              SettingValue__c = 'TRUE',
                                                                              SettingValueDefault__c = 'FALSE',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs4;

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs5 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_5,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'String',
                                                                              SettingValue__c = TEST_CONFIG_VALUE_1,
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs5;

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs = new AH_UDC_ConfigurationSetting__c(
                                                                             DisplayOrder__c = 1,
                                                                             AH_UDC__c = true,
                                                                             Name = 'AHServerURL',
                                                                             OrgName__c = UserInfo.getOrganizationName(),
                                                                             PageGroupName__c = 'TestPageGroupName',
                                                                             PageName__c = 'TestPageName',
                                                                             PageSectionName__c = 'TestPageSectionName',
                                                                             SettingDisplayName__c = 'TestDisplayName',
                                                                             SettingHelpText__c = 'TestHelpText',
                                                                             SettingType__c = 'String',
                                                                             SettingValue__c = 'https://www.amadeus-hospitality.com/',
                                                                             SettingValueDefault__c = 'https://www.amadeus-hospitality.com/',
                                                                             SettingValueDomain__c = '',
                                                                             UsedBy__c = 'Test'
      );
      insert cs;

      cs = new AH_UDC_ConfigurationSetting__c(
                                              DisplayOrder__c = 1,
                                              AH_UDC__c = true,
                                              Name = 'PoweredBy',
                                              OrgName__c = UserInfo.getOrganizationName(),
                                              PageGroupName__c = 'TestPageGroupName',
                                              PageName__c = 'TestPageName',
                                              PageSectionName__c = 'TestPageSectionName',
                                              SettingDisplayName__c = 'TestDisplayName',
                                              SettingHelpText__c = 'TestHelpText',
                                              SettingType__c = 'String',
                                              SettingValue__c = 'Powered by: {!AHServerURL}',
                                              SettingValueDefault__c = '',
                                              SettingValueDomain__c = 'Test',
                                              UsedBy__c = 'Test'
      );
      insert cs;

      //Add a setting with text area
      AH_UDC_ConfigurationSetting__c cs6 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_1_1,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'TextArea',
                                                                              SettingValue__c = TEST_CONFIG_VALUE_1,
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs6;

      //Add a another setting
      AH_UDC_ConfigurationSetting__c cs7 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 2,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_2_1,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'TextArea',
                                                                              SettingValue__c = TEST_CONFIG_VALUE_2,
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs7;

   }

   @isTest private static void TestPrefetchValues() {
      Test.startTest();
      List<String> keys = new List<String> { TEST_CONFIG_KEY_1, TEST_CONFIG_KEY_2 };
      Integer prefetched = AH_UDC_ConfigHelper.PrefetchValues(keys);
      System.assertEquals(2, prefetched, 'Did not prefetch the expected number of values');

      keys.add('Does not exist');
      prefetched = AH_UDC_ConfigHelper.PrefetchValues(keys);
      System.assertEquals(2, prefetched, 'Should still have only found two of the keys');
      Test.stopTest();
   }

   @isTest private static void TestPrefetchValuesWithSettingTypeTextArea() {
      Test.startTest();
      List<String> keys = new List<String> { TEST_CONFIG_KEY_1_1, TEST_CONFIG_KEY_2_1 };
      Integer prefetched = AH_UDC_ConfigHelper.PrefetchValues(keys);
      System.assertEquals(2, prefetched, 'Did not prefetch the expected number of values');

      keys.add('Does not exist');
      prefetched = AH_UDC_ConfigHelper.PrefetchValues(keys);
      System.assertEquals(2, prefetched, 'Should still have only found two of the keys');
      Test.stopTest();
   }

   @isTest private static void TestGetInteger() {
      Test.startTest();
      Integer val = AH_UDC_ConfigHelper.GetInteger(TEST_CONFIG_KEY_3, - 1);
      System.assertEquals(100, val, 'Did not get the expected value back from GetInteger()');
      Test.stopTest();
   }

   @isTest private static void TestGetBoolean() {
      Test.startTest();
      Boolean val = AH_UDC_ConfigHelper.GetBoolean(TEST_CONFIG_KEY_4, false);
      System.assertEquals(true, val, 'Did not get the expected value back from GetBoolean()');
      Test.stopTest();
   }

   @isTest private static void TestUpdateValue() {
      Test.startTest();
      AH_UDC_ConfigHelper.UpdateValue(TEST_CONFIG_KEY_3, '150');
      System.assertEquals('150',(String) AH_UDC_ConfigHelper.GetValue(TEST_CONFIG_KEY_3), 'Get the expected updated value back from UpdateValue()');
      Test.stopTest();
   }

   @isTest private static void TestCache() {
      Test.startTest();

      //Add a value and verify it can be retrieved
      AH_UDC_ConfigHelper.SetValue(TEST_KEY, (Object) TEST_CONFIG_VALUE_A);
      System.assertEquals(true, AH_UDC_ConfigHelper.ContainsKey(TEST_KEY), 'Expected the cache to have a value for "' + TEST_KEY + '"');
      string sGetValue = (string) AH_UDC_ConfigHelper.GetValue(TEST_KEY);
      System.assertEquals(TEST_CONFIG_VALUE_A, (string) AH_UDC_ConfigHelper.GetValue(TEST_KEY), 'Retrieval of Value for "' + TEST_KEY + '" failed.');

      // Change the value assigned to the key and verify
      AH_UDC_ConfigHelper.SetValue(TEST_KEY, (Object) TEST_CONFIG_VALUE_B);
      System.assertEquals(TEST_CONFIG_VALUE_B, (string) AH_UDC_ConfigHelper.GetValue(TEST_KEY), 'Retrieval of Value_2 for "' + TEST_KEY + '" failed.');

      // Remove the value if it was previously cached, and verify
      AH_UDC_ConfigHelper.RemoveKey(TEST_KEY);
      System.assertEquals(null, (Boolean) AH_UDC_ConfigHelper.GetValue(TEST_KEY), 'Expected the cache to not have a value for "' + TEST_KEY + '"');

      System.assertEquals('DefVal', (string) AH_UDC_ConfigHelper.GetValue('NoSuchKey', 'DefVal'), 'Retrieval of default value when key was not found, failed.');

      AH_UDC_ConfigHelper.FlushCache();

      Test.stopTest();
   }

   @isTest private static void TestReplaceParametersInValue() {
      Test.startTest();

      string url = AH_UDC_ConfigHelper.GetString('PoweredBy', 'MissingParameter');
      System.assertEquals('Powered by: https://www.amadeus-hospitality.com/', url, 'Value that was returned did not contain the merged data');

      Test.stopTest();
   }
=======
/*
 * File            : AH_UDC_ConfigHelper_TEST.cls
 * Created Date    : 2019-08-29
 * Created By      : George.Tasker@amadeus.com
 * Description     : Caching routines to use Cache (if enabled) to store previously retrieved configuration
 *                   values so they can be retrieved without needing to make a SOQL call
 */
@isTest
public class AH_UDC_ConfigHelper_TEST
{
   private static string TEST_KEY = 'TestCache';
   private static string TEST_CONFIG_VALUE_A = 'TestCacheValue_A';
   private static string TEST_CONFIG_VALUE_B = 'TestCacheValue_B';

   private static string TEST_CONFIG_KEY_INTEGER = 'FirstThreeIntegers';
   private static Integer TEST_CONFIG_VALUE_INTEGER = 123;

   private static string TEST_CONFIG_KEY_BOOLEAN = 'Vacancy';
   private static Boolean TEST_CONFIG_VALUE_BOOLEAN = true;

   private static string TEST_CONFIG_KEY_1 = 'Test1';
   private static string TEST_CONFIG_VALUE_1 = 'Test1OriginalValue';

   private static string TEST_CONFIG_KEY_2 = 'Test2';
   private static string TEST_CONFIG_VALUE_2 = 'Test2OriginalValue';

   private static string TEST_CONFIG_KEY_3 = 'Test3';
   private static string TEST_CONFIG_VALUE_3 = 'Test3OriginalValue';

   private static string TEST_CONFIG_KEY_4 = 'Test4';
   private static string TEST_CONFIG_VALUE_4 = 'Test4OriginalValue';

   private static string TEST_CONFIG_KEY_5 = 'Test5';
   private static string TEST_CONFIG_VALUE_5 = 'Test5OriginalValue';

   private static string TEST_CONFIG_KEY_1_1 = 'Test1_1';
   private static string TEST_CONFIG_VALUE_1_1 = 'Test1_1OriginalValue';

   private static string TEST_CONFIG_KEY_2_1 = 'Test2_1';
   private static string TEST_CONFIG_VALUE_2_1 = 'Test2_1OriginalValue';

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('TestClass');
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();

      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                              'ConfigHelperUDCSysAdmin', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[0].Id);
      }

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs1 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_1,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'String',
                                                                              SettingValue__c = TEST_CONFIG_VALUE_1,
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs1;

      //Add a another setting
      AH_UDC_ConfigurationSetting__c cs2 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 2,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_2,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'String',
                                                                              SettingValue__c = TEST_CONFIG_VALUE_2,
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs2;

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs3 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_3,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'Integer',
                                                                              SettingValue__c = '100',
                                                                              SettingValueDefault__c = '1',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs3;

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs4 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_4,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'Checkbox',
                                                                              SettingValue__c = 'TRUE',
                                                                              SettingValueDefault__c = 'FALSE',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs4;

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs5 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_5,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'String',
                                                                              SettingValue__c = TEST_CONFIG_VALUE_1,
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs5;

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs = new AH_UDC_ConfigurationSetting__c(
                                                                             DisplayOrder__c = 1,
                                                                             AH_UDC__c = true,
                                                                             Name = 'AHServerURL',
                                                                             OrgName__c = UserInfo.getOrganizationName(),
                                                                             PageGroupName__c = 'TestPageGroupName',
                                                                             PageName__c = 'TestPageName',
                                                                             PageSectionName__c = 'TestPageSectionName',
                                                                             SettingDisplayName__c = 'TestDisplayName',
                                                                             SettingHelpText__c = 'TestHelpText',
                                                                             SettingType__c = 'String',
                                                                             SettingValue__c = 'https://www.amadeus-hospitality.com/',
                                                                             SettingValueDefault__c = 'https://www.amadeus-hospitality.com/',
                                                                             SettingValueDomain__c = '',
                                                                             UsedBy__c = 'Test'
      );
      insert cs;

      cs = new AH_UDC_ConfigurationSetting__c(
                                              DisplayOrder__c = 1,
                                              AH_UDC__c = true,
                                              Name = 'PoweredBy',
                                              OrgName__c = UserInfo.getOrganizationName(),
                                              PageGroupName__c = 'TestPageGroupName',
                                              PageName__c = 'TestPageName',
                                              PageSectionName__c = 'TestPageSectionName',
                                              SettingDisplayName__c = 'TestDisplayName',
                                              SettingHelpText__c = 'TestHelpText',
                                              SettingType__c = 'String',
                                              SettingValue__c = 'Powered by: {!AHServerURL}',
                                              SettingValueDefault__c = '',
                                              SettingValueDomain__c = 'Test',
                                              UsedBy__c = 'Test'
      );
      insert cs;

      //Add a setting with text area
      AH_UDC_ConfigurationSetting__c cs6 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_1_1,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'TextArea',
                                                                              SettingValue__c = TEST_CONFIG_VALUE_1,
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs6;

      //Add a another setting
      AH_UDC_ConfigurationSetting__c cs7 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 2,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_2_1,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'TextArea',
                                                                              SettingValue__c = TEST_CONFIG_VALUE_2,
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs7;

   }

   @isTest private static void TestPrefetchValues() {
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%ConfigHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         List<String> keys = new List<String> { TEST_CONFIG_KEY_1, TEST_CONFIG_KEY_2 };
         Integer prefetched = AH_UDC_ConfigHelper.PrefetchValues(keys);
         System.assertEquals(2, prefetched, 'Did not prefetch the expected number of values');

         keys.add('Does not exist');
         prefetched = AH_UDC_ConfigHelper.PrefetchValues(keys);
         System.assertEquals(2, prefetched, 'Should still have only found two of the keys');
      }
      Test.stopTest();
   }

   @isTest private static void TestPrefetchValuesWithSettingTypeTextArea() {
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%ConfigHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         List<String> keys = new List<String> { TEST_CONFIG_KEY_1_1, TEST_CONFIG_KEY_2_1 };
         Integer prefetched = AH_UDC_ConfigHelper.PrefetchValues(keys);
         System.assertEquals(2, prefetched, 'Did not prefetch the expected number of values');

         keys.add('Does not exist');
         prefetched = AH_UDC_ConfigHelper.PrefetchValues(keys);
         System.assertEquals(2, prefetched, 'Should still have only found two of the keys');
      }
      Test.stopTest();
   }

   @isTest private static void TestGetInteger() {
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%ConfigHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         Integer val = AH_UDC_ConfigHelper.GetInteger(TEST_CONFIG_KEY_3, - 1);
         System.assertEquals(100, val, 'Did not get the expected value back from GetInteger()');
      }
      Test.stopTest();
   }

   @isTest private static void TestGetBoolean() {
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%ConfigHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         Boolean val = AH_UDC_ConfigHelper.GetBoolean(TEST_CONFIG_KEY_4, false);
         System.assertEquals(true, val, 'Did not get the expected value back from GetBoolean()');
      }
      Test.stopTest();
   }

   @isTest private static void TestUpdateValue() {
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%ConfigHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         AH_UDC_ConfigHelper.UpdateValue(TEST_CONFIG_KEY_3, '150');
         System.assertEquals('150', (String) AH_UDC_ConfigHelper.GetValue(TEST_CONFIG_KEY_3), 'Get the expected updated value back from UpdateValue()');
      }
      Test.stopTest();
   }

   @isTest private static void TestCache() {
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%ConfigHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         //Add a value and verify it can be retrieved
         AH_UDC_ConfigHelper.SetValue(TEST_KEY, (Object) TEST_CONFIG_VALUE_A);
         System.assertEquals(true, AH_UDC_ConfigHelper.ContainsKey(TEST_KEY), 'Expected the cache to have a value for "' + TEST_KEY + '"');
         string sGetValue = (string) AH_UDC_ConfigHelper.GetValue(TEST_KEY);
         System.assertEquals(TEST_CONFIG_VALUE_A, (string) AH_UDC_ConfigHelper.GetValue(TEST_KEY), 'Retrieval of Value for "' + TEST_KEY + '" failed.');

         // Change the value assigned to the key and verify
         AH_UDC_ConfigHelper.SetValue(TEST_KEY, (Object) TEST_CONFIG_VALUE_B);
         System.assertEquals(TEST_CONFIG_VALUE_B, (string) AH_UDC_ConfigHelper.GetValue(TEST_KEY), 'Retrieval of Value_2 for "' + TEST_KEY + '" failed.');

         // Remove the value if it was previously cached, and verify
         AH_UDC_ConfigHelper.RemoveKey(TEST_KEY);
         System.assertEquals(null, (Boolean) AH_UDC_ConfigHelper.GetValue(TEST_KEY), 'Expected the cache to not have a value for "' + TEST_KEY + '"');

         System.assertEquals('DefVal', (string) AH_UDC_ConfigHelper.GetValue('NoSuchKey', 'DefVal'), 'Retrieval of default value when key was not found, failed.');

         AH_UDC_ConfigHelper.FlushCache();
      }

      Test.stopTest();
   }

   @isTest private static void TestReplaceParametersInValue() {
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%ConfigHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         string url = AH_UDC_ConfigHelper.GetString('PoweredBy', 'MissingParameter');
         System.assertEquals('Powered by: https://www.amadeus-hospitality.com/', url, 'Value that was returned did not contain the merged data');
      }
      Test.stopTest();
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
/*
 * File            : AH_UDC_ConfigHelper_TEST.cls
 * Created Date    : 2019-08-29
 * Created By      : George.Tasker@amadeus.com
 * Description     : Caching routines to use Cache (if enabled) to store previously retrieved configuration
 *                   values so they can be retrieved without needing to make a SOQL call
 */
@isTest
public class AH_UDC_ConfigHelper_TEST
{
   private static string TEST_KEY = 'TestCache';
   private static string TEST_CONFIG_VALUE_A = 'TestCacheValue_A';
   private static string TEST_CONFIG_VALUE_B = 'TestCacheValue_B';

   private static string TEST_CONFIG_KEY_INTEGER = 'FirstThreeIntegers';
   private static Integer TEST_CONFIG_VALUE_INTEGER = 123;

   private static string TEST_CONFIG_KEY_BOOLEAN = 'Vacancy';
   private static Boolean TEST_CONFIG_VALUE_BOOLEAN = true;

   private static string TEST_CONFIG_KEY_1 = 'Test1';
   private static string TEST_CONFIG_VALUE_1 = 'Test1OriginalValue';

   private static string TEST_CONFIG_KEY_2 = 'Test2';
   private static string TEST_CONFIG_VALUE_2 = 'Test2OriginalValue';

   private static string TEST_CONFIG_KEY_3 = 'Test3';
   private static string TEST_CONFIG_VALUE_3 = 'Test3OriginalValue';

   private static string TEST_CONFIG_KEY_4 = 'Test4';
   private static string TEST_CONFIG_VALUE_4 = 'Test4OriginalValue';

   private static string TEST_CONFIG_KEY_5 = 'Test5';
   private static string TEST_CONFIG_VALUE_5 = 'Test5OriginalValue';

   private static string TEST_CONFIG_KEY_1_1 = 'Test1_1';
   private static string TEST_CONFIG_VALUE_1_1 = 'Test1_1OriginalValue';

   private static string TEST_CONFIG_KEY_2_1 = 'Test2_1';
   private static string TEST_CONFIG_VALUE_2_1 = 'Test2_1OriginalValue';

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('TestClass');
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();

      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                              'ConfigHelperUDCSysAdmin', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[0].Id);
      }

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs1 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_1,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'String',
                                                                              SettingValue__c = TEST_CONFIG_VALUE_1,
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs1;

      //Add a another setting
      AH_UDC_ConfigurationSetting__c cs2 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 2,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_2,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'String',
                                                                              SettingValue__c = TEST_CONFIG_VALUE_2,
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs2;

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs3 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_3,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'Integer',
                                                                              SettingValue__c = '100',
                                                                              SettingValueDefault__c = '1',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs3;

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs4 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_4,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'Checkbox',
                                                                              SettingValue__c = 'TRUE',
                                                                              SettingValueDefault__c = 'FALSE',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs4;

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs5 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_5,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'String',
                                                                              SettingValue__c = TEST_CONFIG_VALUE_1,
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs5;

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs = new AH_UDC_ConfigurationSetting__c(
                                                                             DisplayOrder__c = 1,
                                                                             AH_UDC__c = true,
                                                                             Name = 'AHServerURL',
                                                                             OrgName__c = UserInfo.getOrganizationName(),
                                                                             PageGroupName__c = 'TestPageGroupName',
                                                                             PageName__c = 'TestPageName',
                                                                             PageSectionName__c = 'TestPageSectionName',
                                                                             SettingDisplayName__c = 'TestDisplayName',
                                                                             SettingHelpText__c = 'TestHelpText',
                                                                             SettingType__c = 'String',
                                                                             SettingValue__c = 'https://www.amadeus-hospitality.com/',
                                                                             SettingValueDefault__c = 'https://www.amadeus-hospitality.com/',
                                                                             SettingValueDomain__c = '',
                                                                             UsedBy__c = 'Test'
      );
      insert cs;

      cs = new AH_UDC_ConfigurationSetting__c(
                                              DisplayOrder__c = 1,
                                              AH_UDC__c = true,
                                              Name = 'PoweredBy',
                                              OrgName__c = UserInfo.getOrganizationName(),
                                              PageGroupName__c = 'TestPageGroupName',
                                              PageName__c = 'TestPageName',
                                              PageSectionName__c = 'TestPageSectionName',
                                              SettingDisplayName__c = 'TestDisplayName',
                                              SettingHelpText__c = 'TestHelpText',
                                              SettingType__c = 'String',
                                              SettingValue__c = 'Powered by: {!AHServerURL}',
                                              SettingValueDefault__c = '',
                                              SettingValueDomain__c = 'Test',
                                              UsedBy__c = 'Test'
      );
      insert cs;

      //Add a setting with text area
      AH_UDC_ConfigurationSetting__c cs6 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_1_1,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'TextArea',
                                                                              SettingValue__c = TEST_CONFIG_VALUE_1,
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs6;

      //Add a another setting
      AH_UDC_ConfigurationSetting__c cs7 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 2,
                                                                              AH_UDC__c = true,
                                                                              Name = TEST_CONFIG_KEY_2_1,
                                                                              OrgName__c = UserInfo.getOrganizationName(),
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'TextArea',
                                                                              SettingValue__c = TEST_CONFIG_VALUE_2,
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs7;

   }

   @isTest private static void TestPrefetchValues() {
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%ConfigHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         List<String> keys = new List<String> { TEST_CONFIG_KEY_1, TEST_CONFIG_KEY_2 };
         Integer prefetched = AH_UDC_ConfigHelper.PrefetchValues(keys);
         System.assertEquals(2, prefetched, 'Did not prefetch the expected number of values');

         keys.add('Does not exist');
         prefetched = AH_UDC_ConfigHelper.PrefetchValues(keys);
         System.assertEquals(2, prefetched, 'Should still have only found two of the keys');
      }
      Test.stopTest();
   }

   @isTest private static void TestPrefetchValuesWithSettingTypeTextArea() {
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%ConfigHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         List<String> keys = new List<String> { TEST_CONFIG_KEY_1_1, TEST_CONFIG_KEY_2_1 };
         Integer prefetched = AH_UDC_ConfigHelper.PrefetchValues(keys);
         System.assertEquals(2, prefetched, 'Did not prefetch the expected number of values');

         keys.add('Does not exist');
         prefetched = AH_UDC_ConfigHelper.PrefetchValues(keys);
         System.assertEquals(2, prefetched, 'Should still have only found two of the keys');
      }
      Test.stopTest();
   }

   @isTest private static void TestGetInteger() {
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%ConfigHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         Integer val = AH_UDC_ConfigHelper.GetInteger(TEST_CONFIG_KEY_3, - 1);
         System.assertEquals(100, val, 'Did not get the expected value back from GetInteger()');
      }
      Test.stopTest();
   }

   @isTest private static void TestGetBoolean() {
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%ConfigHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         Boolean val = AH_UDC_ConfigHelper.GetBoolean(TEST_CONFIG_KEY_4, false);
         System.assertEquals(true, val, 'Did not get the expected value back from GetBoolean()');
      }
      Test.stopTest();
   }

   @isTest private static void TestUpdateValue() {
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%ConfigHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         AH_UDC_ConfigHelper.UpdateValue(TEST_CONFIG_KEY_3, '150');
         System.assertEquals('150', (String) AH_UDC_ConfigHelper.GetValue(TEST_CONFIG_KEY_3), 'Get the expected updated value back from UpdateValue()');
      }
      Test.stopTest();
   }

   @isTest private static void TestCache() {
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%ConfigHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         //Add a value and verify it can be retrieved
         AH_UDC_ConfigHelper.SetValue(TEST_KEY, (Object) TEST_CONFIG_VALUE_A);
         System.assertEquals(true, AH_UDC_ConfigHelper.ContainsKey(TEST_KEY), 'Expected the cache to have a value for "' + TEST_KEY + '"');
         string sGetValue = (string) AH_UDC_ConfigHelper.GetValue(TEST_KEY);
         System.assertEquals(TEST_CONFIG_VALUE_A, (string) AH_UDC_ConfigHelper.GetValue(TEST_KEY), 'Retrieval of Value for "' + TEST_KEY + '" failed.');

         // Change the value assigned to the key and verify
         AH_UDC_ConfigHelper.SetValue(TEST_KEY, (Object) TEST_CONFIG_VALUE_B);
         System.assertEquals(TEST_CONFIG_VALUE_B, (string) AH_UDC_ConfigHelper.GetValue(TEST_KEY), 'Retrieval of Value_2 for "' + TEST_KEY + '" failed.');

         // Remove the value if it was previously cached, and verify
         AH_UDC_ConfigHelper.RemoveKey(TEST_KEY);
         System.assertEquals(null, (Boolean) AH_UDC_ConfigHelper.GetValue(TEST_KEY), 'Expected the cache to not have a value for "' + TEST_KEY + '"');

         System.assertEquals('DefVal', (string) AH_UDC_ConfigHelper.GetValue('NoSuchKey', 'DefVal'), 'Retrieval of default value when key was not found, failed.');

         AH_UDC_ConfigHelper.FlushCache();
      }

      Test.stopTest();
   }

   @isTest private static void TestReplaceParametersInValue() {
      Test.startTest();
      List<User> lstUser = [Select Id From User Where Email like '%ConfigHelperUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         string url = AH_UDC_ConfigHelper.GetString('PoweredBy', 'MissingParameter');
         System.assertEquals('Powered by: https://www.amadeus-hospitality.com/', url, 'Value that was returned did not contain the merged data');
      }
      Test.stopTest();
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}