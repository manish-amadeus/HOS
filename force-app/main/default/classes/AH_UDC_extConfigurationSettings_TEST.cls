/*
 * File            : AH_UDC_extConfigurationSettings_TEST.cls
 * Created Date    : 2019-08-29
 * Created By      : Rob.Stevens@Amadeus.com
 * Description     : Test Extension class for Configuration Settings Page
 */
@isTest
public with sharing class AH_UDC_extConfigurationSettings_TEST {

   public static final String TEST_CLASS_FORCED_EXCEPTION = 'TEST CLASS: Throwing an intentional exception for testing/code coverage from Test Class';

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();

      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                    'ConfigSetUDCSysAdmin', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[0].Id);
      }
   }

   @isTest static void testLaunchPage() {
      //Get Org Info
      Organization orgInfo = [SELECT name FROM Organization];

      Test.startTest();

      AH_UDC_extConfigurationSettings ecs = new AH_UDC_extConfigurationSettings();
      String launchUrl = '/apex/GeneralSettingsViewEdit';
      ecs.actionParameter1 = launchUrl;
      PageReference pr = ecs.launchPage();
      System.assertEquals(launchUrl, pr.getUrl(), 'Page is not redirecting to expected Url');

      Test.stopTest();
   }

   @isTest static void testShowSettingPage() {
      //Get Org Info
      Organization orgInfo = [SELECT name FROM Organization];

      Test.startTest();

      AH_UDC_extConfigurationSettings ecs = new AH_UDC_extConfigurationSettings();
      ecs.actionParameter1 = 'Test';
      ecs.showSettingPage();
      System.assertEquals(ecs.actionParameter1, ecs.getpageName(), 'Did not find the expected PageName');
      
      Test.stopTest();
   }
   
   @isTest static void testUpdateSetting() {
      //Get Org Info
      Organization orgInfo = [select name from Organization];

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs1 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = 'Test1',
                                                                              OrgName__c = orgInfo.Name,
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'String',
                                                                              SettingValue__c = 'TestOriginalValue',
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      insert cs1;

      AH_UDC_ConfigurationSetting__c cs2 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 6,
                                                                              AH_UDC__c = true,
                                                                              Name = 'Test6',
                                                                              OrgName__c = orgInfo.Name,
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = null,
                                                                              SettingType__c = 'Time_24h',
                                                                              SettingValue__c = '',
                                                                              SettingValueDefault__c = '09:42',
                                                                              SettingValueDomain__c = '',
                                                                              UsedBy__c = 'Test'
      );
      insert cs2;

      List<User> lstUser = [Select Id From User Where Email like '%ConfigSetUDCSysAdmin%'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user was not created');

      System.runAs(lstUser[0]) {
         Test.startTest();

         AH_UDC_extConfigurationSettings ecs = new AH_UDC_extConfigurationSettings();
         ecs.setupdateSettingName('Test1');
         System.assertEquals('Test1', ecs.getupdateSettingName(), 'Failed to set updateSettingName');

         ecs.setupdateSettingValue('TestValueUpdated');
         ecs.updateSetting();
         System.assertEquals('Setting updated', ecs.getupdateSettingStatus(), 'Failed to save STRING Setting Value');

         AH_UDC_ConfigurationSetting__c[] csUpdated = [SELECT name, SettingValue__c from AH_UDC_ConfigurationSetting__c where Name = 'Test1'];

         System.assertEquals('TestValueUpdated', ecs.getupdateSettingValue(), 'Setting Value Not Updated');
         System.assertEquals('TestValueUpdated', csUpdated[0].SettingValue__c, 'Saved Setting Value Not Updated');

         // Good value
         ecs.setupdateSettingName('Test6');
         ecs.setupdateSettingValue('12:34');
         ecs.updateSetting();
         System.assertEquals('Setting updated', ecs.getupdateSettingStatus(), 'Failed to save 24H Setting Value');

         // Bad value
         ecs.setupdateSettingName('Test6');
         ecs.setupdateSettingValue('12:60');
         ecs.updateSetting();
         System.assert(ecs.getupdateSettingStatus().startsWith('Unrecognized time format'), 'Should have failed to save 24H Setting Value with invalid number');

         // Bad value
         ecs.setupdateSettingName('Test6');
         ecs.setupdateSettingValue('ab:de');
         ecs.updateSetting();
         System.assert(ecs.getupdateSettingStatus().startsWith('Unrecognized time format'), 'Should have failed to save 24H Setting Value with letters and a colon entered');

         // Bad value
         ecs.setupdateSettingName('Test6');
         ecs.setupdateSettingValue('abcde');
         ecs.updateSetting();
         System.assert(ecs.getupdateSettingStatus().startsWith('Unrecognized time format'), 'Should have failed to save 24H Setting Value with letters entered');

         Test.stopTest();
      }
   }

   @isTest static void testUpdateSettingOutOfRange() {
      //Get Org Info
      Organization orgInfo = [SELECT name FROM Organization];

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs1 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = 'Test1',
                                                                              OrgName__c = orgInfo.Name,
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'Integer',
                                                                              SettingValue__c = '100',
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = '0\r\n120',
                                                                              UsedBy__c = 'Test'
      );
      insert cs1;
      Test.startTest();

      AH_UDC_extConfigurationSettings ecs = new AH_UDC_extConfigurationSettings();
      ecs.setupdateSettingName('Test1');
      ecs.setupdateSettingValue('200');
      ecs.updateSetting();

      System.assert(ecs.getupdateSettingStatus().startsWith('Update failed'), 'Update should have failed as the new integer value was outside the valid range');

      Test.stopTest();
   }

   @isTest static void testUpdateMissingSetting() {
      //Get Org Info
      Organization orgInfo = [SELECT name FROM Organization];

      Test.startTest();

      AH_UDC_extConfigurationSettings ecs = new AH_UDC_extConfigurationSettings();
      ecs.setupdateSettingName('Test');
      ecs.setupdateSettingValue('TestValueUpdated');
      ecs.updateSetting();

      System.assert(ecs.getupdateSettingStatus().startsWith('Update failed:'), 'Missing Setting error not correct');

      Test.stopTest();
   }

   @isTest static void testRequestMethod() {
      //Get Org Info
      Organization orgInfo = [SELECT name FROM Organization];

      Test.startTest();

      AH_UDC_extConfigurationSettings ecs = new AH_UDC_extConfigurationSettings();
      ecs.setupdateSettingValue('Exception');
      ecs.requestMethod();

      System.assert(ecs.getupdateSettingStatus().startsWith('Request failed;'), 'Testing an exception while calling requestMethod should have failed');

      Test.stopTest();
   }

   @isTest static void testUpdateException() {
      //Get Org Info
      Organization orgInfo = [SELECT name FROM Organization];

      Test.startTest();

      AH_UDC_extConfigurationSettings ecs = new AH_UDC_extConfigurationSettings();
      ecs.setupdateSettingName('Exception');
      ecs.setupdateSettingValue('TestException');
      boolean isException = false;
      ecs.updateSetting();

      System.assert(ecs.getupdateSettingStatus().startsWith('Update failed:'), 'Exception Setting error not correct');

      Test.stopTest();
   }

   @isTest static void testPage() {
      //Get Org Info
      Organization orgInfo = [SELECT name FROM Organization];

      List<AH_UDC_ConfigurationSetting__c> cs = new List<AH_UDC_ConfigurationSetting__c> ();

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs1 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 1,
                                                                              AH_UDC__c = true,
                                                                              Name = 'Test1',
                                                                              OrgName__c = orgInfo.Name,
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'String',
                                                                              SettingValue__c = 'TestOriginalValue',
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      cs.add(cs1);

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs2 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 2,
                                                                              AH_UDC__c = true,
                                                                              Name = 'Test2',
                                                                              OrgName__c = orgInfo.Name,
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'Integer',
                                                                              SettingValue__c = '1',
                                                                              SettingValueDefault__c = '1',
                                                                              SettingValueDomain__c = '1\r\n2',
                                                                              UsedBy__c = 'Test'
      );
      cs.add(cs2);

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs3 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 3,
                                                                              AH_UDC__c = true,
                                                                              Name = 'Test3',
                                                                              OrgName__c = orgInfo.Name,
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'Picklist',
                                                                              SettingValue__c = 'Test',
                                                                              SettingValueDefault__c = 'Test',
                                                                              SettingValueDomain__c = 'Test',
                                                                              UsedBy__c = 'Test'
      );
      cs.add(cs3);

      //Add a setting
      AH_UDC_ConfigurationSetting__c cs4 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 4,
                                                                              AH_UDC__c = true,
                                                                              Name = 'Test4',
                                                                              OrgName__c = orgInfo.Name,
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = 'TestHelpText',
                                                                              SettingType__c = 'Checkbox',
                                                                              SettingValue__c = 'True',
                                                                              SettingValueDefault__c = 'True',
                                                                              SettingValueDomain__c = '',
                                                                              UsedBy__c = 'Test'
      );
      cs.add(cs4);

      //Add a Dynamic Picklist setting
      AH_UDC_ConfigurationSetting__c cs5 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 5,
                                                                              AH_UDC__c = true,
                                                                              Name = 'Test5',
                                                                              OrgName__c = orgInfo.Name,
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = null,
                                                                              SettingType__c = 'Picklist',
                                                                              SettingValue__c = '',
                                                                              SettingValueDefault__c = '',
                                                                              SettingValueDomain__c = '{!Opportunity.LeadSource}',
                                                                              UsedBy__c = 'Test'
      );
      cs.add(cs5);

      //Add a Time_24H setting
      AH_UDC_ConfigurationSetting__c cs6 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 6,
                                                                              AH_UDC__c = true,
                                                                              Name = 'Test6',
                                                                              OrgName__c = orgInfo.Name,
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = 'TestPageName',
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = null,
                                                                              SettingType__c = 'Time_24h',
                                                                              SettingValue__c = '',
                                                                              SettingValueDefault__c = '09:42',
                                                                              SettingValueDomain__c = '',
                                                                              UsedBy__c = 'Test'
      );
      cs.add(cs6);

      //Add a object setting
      AH_UDC_ConfigurationSetting__c cs7 = new AH_UDC_ConfigurationSetting__c(
                                                                              DisplayOrder__c = 7,
                                                                              AH_UDC__c = true,
                                                                              Name = 'Test7',
                                                                              OrgName__c = orgInfo.Name,
                                                                              PageGroupName__c = 'TestPageGroupName',
                                                                              PageName__c = null,
                                                                              PageSectionName__c = 'TestPageSectionName',
                                                                              SettingDisplayName__c = 'TestDisplayName',
                                                                              SettingHelpText__c = null,
                                                                              SettingType__c = 'Object',
                                                                              SettingValue__c = '',
                                                                              SettingValueDefault__c = 'TestDefaultValue',
                                                                              SettingValueDomain__c = '',
                                                                              UsedBy__c = 'Test'
      );
      cs.add(cs7);
      insert cs;

      Test.startTest();

      String tpn = 'TestPageName';
      String tpgn = 'TestPageGroupName';
      PageReference pageRef = new PageReference('/apex/AH_UDC_ConfigurationSettings?pn=' + tpn);
      System.assertNotEquals(null, pageRef, 'Failed to render the extConfigurationSettings page reference');
      pageRef.getParameters().put('pn', tpn);
      Test.setCurrentPage(pageRef);

      AH_UDC_extConfigurationSettings extCS = new AH_UDC_extConfigurationSettings();

      System.assertEquals('/apex/AH_UDC_ConfigurationSettings?pn=' + tpn, ApexPages.currentPage().GetUrl(), 'PageReference is not pointing at the expected page');

      extCS.setpageName(tpn);
      System.assertEquals(tpn, extCS.getpageName(), 'Did not find the expected PageName');

      extCS.GetSettings(); //added to cover else condition where it sets pagegroupname, if it is null 
      System.assertEquals(tpgn, extCS.getPageGroupName(), 'Did not find the expected PageGroupName');

      extCS.setpageGroupName('TestPageGroupName1');
      System.assertEquals('TestPageGroupName1', extCS.getPageGroupName(), 'Did not find the expected PageGroupName');

      extCS.actionParameter1 = 'History';
      extCS.showSettingPage();
      extCS.showNextHistoryPage();
      System.assertEquals(extCS.actionParameter1, extCS.getpageName(), 'Did not find the expected PageName');
      
      extCS.setpageGroupName(tpgn);
      System.assertEquals(tpgn, extCS.getPageGroupName(), 'Did not find the expected PageGroupName');


      Test.stopTest();
   }
}