/**
 * Name          : AH_UDC_InitializationHelper
 * Description   : The class initializes the org, checking for the existance of all config settings,
 *               : and creating them if they do not exist
 * Dependencies  :
 **/

public with sharing class AH_UDC_InitializationHelper implements Callable {

   //Implement Callable
   ////////////
   // Provides a callable interface method for invoking functions in this class
   // that we want accessible to unmanaged package code
   //
   // Actions and their Arguments:
   //
   //    Initialize - Returns a string containing the human readable message with the results of the call
   //          mode         : [string] 'All', 'ConfigurationSettings', or blank will all do the same and initialize config settings
   //                                  'TestFalse'  can be used for test classes and code coverage
   //
   // On any error, such as an unrecognized Action, or bad Arguments, this function will return a
   // exception of type ExtensionMalformedCallException
   //
   ////////////
   public static Object call(String action, Map<String, Object> args) {
      for (string key : args.keySet()) {
         AH_UDC_LogHelper.Debug('arg Key: ' + key);
         AH_UDC_LogHelper.Debug('arg value: ' + args.get(key));
      }

      switch on action {
         when 'Initialize' {
            return AH_UDC_InitializationHelper.InitializeReturnMessage((String) args.get('mode'));
         }
         when else {
            throw new ExtensionMalformedCallException('Method not implemented');
         }
      }
   }
   public class ExtensionMalformedCallException extends Exception { }

   //Pass null to initialize all
   public static string InitializeReturnMessage(string mode) {
      Boolean success = Initialize(mode);
      if (success) {
         return 'Initialization Completed';
      } else {
         return 'There was an issue initializing; please check the log';
      }
   }

   //Pass null to initialize all
   public static Boolean Initialize(string mode) {
      AH_UDC_LogHelper.Debug('mode: ' + mode);
      Boolean rStatus = true; //Set to false if any settings fail
      Boolean modeFound = false; //Set to false if any settings fail
      if (mode == null) mode = '';

      //This will create (if they don't exist) or update (only managed) settings
      if (Test.isRunningTest() && mode == 'TestFalse') {
         return false;
      }

      // Necessary for the first time settings are initialized to avoid too many SOQL errors looking for this setting
      if (!AH_UDC_ConfigHelper.ContainsKey(AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES)) {
         //Get Org Info
         Organization orgInfo = [select Id, name from Organization LIMIT 1];
         string orgName = String.valueOf(orgInfo.Id).left(15) + '||' + orgInfo.Name;

         string PageGroupName = 'For Amadeus Technical Support Use Only';
         string PageName = 'Amadeus Technical Support Settings';

         string PageSectionName = 'Troubleshooting';
         insert new AH_UDC_ConfigurationSetting__c(Name = AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES, SettingType__c = 'Checkbox', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 1, SettingDisplayName__c = 'Enable System.Debug logging', SettingHelpText__c = 'Turns on advanced troubleshooting logging, when DEBUG LOGGING in Salesforce is enabled for one or more users. This will generate large log files and should be used sparingly', SettingValue__c = '', SettingValueDefault__c = 'FALSE', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName);
      }

      if (mode == 'TestClass') {
         AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES, true);
         AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_ERRORS, false);
         AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_EXCEPTIONS, false);
         AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_TRACES, false);
         AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_WARNINGS, true);
         AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_ERRORS, false);
         AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_ERRORS, false);
         AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_ERRORS, false);
         AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_ERRORS, false);
         AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_EXCEPTIONS, false);
         AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_WARNINGS, false);
         AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_RECIPIENTS, '');
         return true;
      }

      //This will create (if they don't exist) or update (only managed) settings
      if (String.isEmpty(mode) || mode == 'All' || mode == 'ConfigurationSettings') {
         modeFound = true;
         if (!initConfigurationSettings()) rStatus = false;
      }

      //This will create (if they don't exist) or update (only managed) settings
      if (String.isEmpty(mode) || mode == 'All' || mode == 'InitFormTokenCert') {
         modeFound = true;
         if (!AH_UDC_Shared.InitializeFormTokenEncryptionKey()) rStatus = false;
      }

      if (!modeFound) return false;
      return rStatus;
   }


   //This will create (if they don't exist) or update (only AH_UDC) settings
   @TestVisible
   private static Boolean initConfigurationSettings() {
      List<AH_UDC_ConfigurationSetting__c> insertCS = new List<AH_UDC_ConfigurationSetting__c> ();
      List<AH_UDC_ConfigurationSetting__c> updateCS = new List<AH_UDC_ConfigurationSetting__c> ();
      List<AH_UDC_ConfigurationSetting__c> deleteCS = new List<AH_UDC_ConfigurationSetting__c> ();

      try {
         if (Test.isRunningTest()) {
            List<AH_UDC_ConfigurationSetting__c> checkTest = [SELECT Name from AH_UDC_ConfigurationSetting__c where Name = 'EXCEPTION'];
            if (checkTest.size() > 0) integer i = 1 / 0;
         }

         //Get Org Info
         Organization orgInfo = [select Id, name from Organization LIMIT 1];
         string orgName = String.valueOf(orgInfo.Id).left(15) + '||' + orgInfo.Name;

         string PageGroupName = '';
         string PageName = '';
         string PageSectionName = '';
         List<AH_UDC_ConfigurationSetting__c> defaultSettings = new List<AH_UDC_ConfigurationSetting__c> ();

         //Page: Main Configuration
         PageGroupName = 'General';
         PageName = '';
         PageSectionName = '';
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'Initialize', SettingType__c = 'GroupPage', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = '', PageSectionName__c = '', DisplayOrder__c = 1, SettingDisplayName__c = 'Initialize Settings', SettingHelpText__c = 'Initialize AH_UDC Settings', SettingValue__c = '', SettingValueDefault__c = '', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC Settings', SettingType__c = 'GroupPage', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = '', PageSectionName__c = '', DisplayOrder__c = 2, SettingDisplayName__c = 'UDC Settings', SettingHelpText__c = 'UDC Settings', SettingValue__c = '', SettingValueDefault__c = '', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_Logging', SettingType__c = 'GroupPage', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = '', PageSectionName__c = '', DisplayOrder__c = 3, SettingDisplayName__c = 'Logging Settings', SettingHelpText__c = 'Logging Settings', SettingValue__c = '', SettingValueDefault__c = '', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AmadeusTechnicalSupportSettings', SettingType__c = 'GroupPage', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 80, SettingDisplayName__c = 'Amadeus Technical Support Settings', SettingHelpText__c = AH_UDC_LabelHelper.ReplaceParametersInValue('Contains settings that should only be adjusted by Amadeus Technical Support. Invalid changes may cause {!ApplicationName} to stop functioning'), SettingValue__c = '', SettingValueDefault__c = '', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));

         PageName = 'Initialize Settings';
         PageSectionName = 'Initialize';
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'Init_All', SettingType__c = 'Method', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 1, SettingDisplayName__c = 'Initialize All', SettingHelpText__c = 'This will initialize all AH_UDC Objects and ConfigurationSettings, creating any ConfigurationSettings that are missing or updating them as required [Non-destructive]', SettingValue__c = 'AH_UDC_InitializationHelper;Initialize;{"mode":"All"}', SettingValueDefault__c = 'AH_UDC_InitializationHelper;Initialize;{"mode":"All"}', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'Init_ConfigurationSettings', AH_UDC__c = true, SettingType__c = 'Method', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 2, SettingDisplayName__c = 'Initialize Configuration Settings', SettingHelpText__c = 'This will initialize only the ConfigurationSettings, creating any ConfigurationSettings that are missing or updating them as required [Non-destructive]', SettingValue__c = 'AH_UDC_InitializationHelper;Initialize;{"mode":"ConfigurationSettings"}', SettingValueDefault__c = 'AH_UDC_InitializationHelper;Initialize;{"mode":"ConfigurationSettings"}', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));

         //Page: General : UDC Settings
         PageName = 'UDC Settings';
         PageSectionName = 'Email Template Settings';
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_EmailTemplatePortalUrlPlaceholder', AH_UDC__c = true, SettingType__c = 'String', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 1, SettingDisplayName__c = 'Community Portal URL Placeholder', SettingHelpText__c = 'This is the string to search for in email templates; it will be replaced with the real portal url (another configuration setting)', SettingValue__c = '', SettingValueDefault__c = 'https://udcsb-amadeus-community.cs19.force.com/customers/s/', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));

         PageSectionName = 'Community Portal';
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_CommunityPortalUrl', AH_UDC__c = true, SettingType__c = 'String', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 1, SettingDisplayName__c = 'Community Portal Url', SettingHelpText__c = 'This is the URL for the Community Portal', SettingValue__c = '', SettingValueDefault__c = 'https://udcsb-amadeus-community.cs19.force.com/customers/s/', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));

         PageSectionName = 'Profiles';
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER, AH_UDC__c = true, SettingType__c = 'String', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 1, SettingDisplayName__c = 'Community Profile With Chatter', SettingHelpText__c = 'This is the profile used when creating community users who agree to chatter', SettingValue__c = '', SettingValueDefault__c = 'AH Customer Community Plus Login User', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER, AH_UDC__c = true, SettingType__c = 'String', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 2, SettingDisplayName__c = 'Community Profile No Chatter', SettingHelpText__c = 'This is the profile used when creating community users who do not agree to chatter', SettingValue__c = '', SettingValueDefault__c = 'AH Customer Community Plus Login - No Chatter', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));

         PageSectionName = 'Permission Sets';
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_PermissionSetCommunityUser', AH_UDC__c = true, SettingType__c = 'String', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 1, SettingDisplayName__c = 'Permission Set for Community User (API Name)', SettingHelpText__c = 'This is the API Name of the permission set assigned to community users that will be using UDC', SettingValue__c = '', SettingValueDefault__c = AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_PermissionSetUDCSystemAdministrator', AH_UDC__c = true, SettingType__c = 'String', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 2, SettingDisplayName__c = 'Permission Set for UDC System Administrator User (API Name)', SettingHelpText__c = 'This is the API Name of the permission set assigned to UDC System Administrator users that will be using UDC', SettingValue__c = '', SettingValueDefault__c = AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_PermissionSetWorkbookAdministrator', AH_UDC__c = true, SettingType__c = 'String', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 3, SettingDisplayName__c = 'Permission Set for Workbook Administrator User (API Name)', SettingHelpText__c = 'This is the API Name of the permission set assigned to Workbook Administrator users that will be using UDC', SettingValue__c = '', SettingValueDefault__c = AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_PermissionSetWorkbookUser', AH_UDC__c = true, SettingType__c = 'String', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 3, SettingDisplayName__c = 'Permission Set for Workbook User (API Name)', SettingHelpText__c = 'This is the API Name of the permission set assigned to Workbook SUers that will be using UDC', SettingValue__c = '', SettingValueDefault__c = AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));

         PageSectionName = 'Send Workbook - Create Community User Settings';
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_CreateCommunityUserEnabled', AH_UDC__c = true, SettingType__c = 'Checkbox', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 1, SettingDisplayName__c = 'Create Community User(s) When Sending Workbook', SettingHelpText__c = 'This determines if community users will be created when sending workbooks.', SettingValue__c = '', SettingValueDefault__c = 'true', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_CreateCommunityUserOrgPrefix', AH_UDC__c = true, SettingType__c = 'String', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 2, SettingDisplayName__c = 'Org Name to Append To End Of User Name', SettingHelpText__c = 'This is the prefix of the org that should be applied to the end of any user names created', SettingValue__c = '', SettingValueDefault__c = '.UDCSB', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_CommunityUserNamePostfix', AH_UDC__c = true, SettingType__c = 'String', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 2, SettingDisplayName__c = 'Community User Name Postfix', SettingHelpText__c = 'This is the Comunity postfix applied to the end of any user names created', SettingValue__c = '', SettingValueDefault__c = AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX, SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
         
         PageSectionName = 'Update Community User Profile Settings';
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_CommunityUserProfileUpdateEnabled', AH_UDC__c = true, SettingType__c = 'Checkbox', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 1, SettingDisplayName__c = 'Allow updating of commuity user profile to With Chatter profile', SettingHelpText__c = 'This determines if the system is allowed to change a community user\'s profile to the profile that allows chatter.', SettingValue__c = '', SettingValueDefault__c = 'true', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_SetCommunityUserProfileUrl', AH_UDC__c = true, SettingType__c = 'String', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 2, SettingDisplayName__c = 'Set Community User Profile Url', SettingHelpText__c = 'This is the URL of the .net Core API for CommunityUserProfile Controller', SettingValue__c = '', SettingValueDefault__c = 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/CommunityUserProfile', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
        
         PageSectionName = 'Send Workbook settings';
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_AddContactLimit', AH_UDC__c = true, SettingType__c = 'Integer', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 1, SettingDisplayName__c = 'Max Contact Limit', SettingHelpText__c = 'This determines how many Contact users can add to document using the Send workbook page.', SettingValue__c = '', SettingValueDefault__c = '5', SettingValueDomain__c = '0\r\n10', UsedBy__c = '', OrgName__c = orgName));//max-min value updated as per discussion with Hardik

         PageSectionName = 'Custom Lookup settings';
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_CustomLookupMaxRecordsAllowed', AH_UDC__c = true, SettingType__c = 'Integer', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 3, SettingDisplayName__c = 'Update Custom Lookup Maximum Records Allowed', SettingHelpText__c = 'This determines maximum records allow in custom lookup dialog.', SettingValue__c = '', SettingValueDefault__c = '200', SettingValueDomain__c = '0\r\n500', UsedBy__c = '', OrgName__c = orgName));//max-min value updated as per discussion with Hardik
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_CustomLookupRecordsPerPage', AH_UDC__c = true, SettingType__c = 'Integer', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 4, SettingDisplayName__c = 'Update Custom Lookup Records Per Page', SettingHelpText__c = 'This determines Total records to display per page in custom lookup dialog.', SettingValue__c = '', SettingValueDefault__c = '25', SettingValueDomain__c = '25\r\n100', UsedBy__c = '', OrgName__c = orgName));

         PageSectionName = 'ViewWorkbook Settings';
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_ReturnToWelcomePageURL', AH_UDC__c = true, SettingType__c = 'String', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 1, SettingDisplayName__c = 'Return To Welcome Page URL', SettingHelpText__c = 'This is the URL to which the user is sent when clicking Return To Welcome Page.', SettingValue__c = '', SettingValueDefault__c = '/customers/s/services?tabset-8bc76=1cb08', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_CollapsedMenuCirclesPerPage', AH_UDC__c = true, SettingType__c = 'Integer', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 2, SettingDisplayName__c = 'Collapsed Menu Number of Steps Shown', SettingHelpText__c = 'This determines the number of steps shown in the collapsed menu.', SettingValue__c = '', SettingValueDefault__c = '10', SettingValueDomain__c = '1\r\n100', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_ViewWorkbookNotificationDisplayInSeconds', AH_UDC__c = true, SettingType__c = 'Integer', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 3, SettingDisplayName__c = 'Notification Display Time in Seconds', SettingHelpText__c = 'This determines how long all notifications will be show.', SettingValue__c = '', SettingValueDefault__c = '5', SettingValueDomain__c = '1\r\n60', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_ViewWorkbookUpdateTimerIntervalInSeconds', AH_UDC__c = true, SettingType__c = 'Integer', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 4, SettingDisplayName__c = 'Update Timer Interval in Seconds', SettingHelpText__c = 'This determines how often the view workbook page will look for updates and chatter.', SettingValue__c = '', SettingValueDefault__c = '60', SettingValueDomain__c = '10\r\n600', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_ViewWorkbookTokenEncryptionKey', AH_UDC__c = true, SettingType__c = 'String', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 5, SettingDisplayName__c = 'Token Encryption Key', SettingHelpText__c = 'This is the key for encrypting the token sent to Forms; this should not be set manually.\r\nTo issue a new key set the value to empty and run the Initialize Settings.', SettingValue__c = '', SettingValueDefault__c = '', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_ViewWorkbookTokenEncryption', AH_UDC__c = true, SettingType__c = 'Checkbox', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 6, SettingDisplayName__c = 'Encrypt Token', SettingHelpText__c = 'When checked the Token sent to the Form will be encrypted', SettingValue__c = '', SettingValueDefault__c = 'true', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = 'AH_UDC_ViewWorkbookDisplayConsoleLogMessages', AH_UDC__c = true, SettingType__c = 'Checkbox', PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 6, SettingDisplayName__c = 'Display Console Log Messages', SettingHelpText__c = 'When checked console.log messages will be written to the browser', SettingValue__c = '', SettingValueDefault__c = 'false', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));
         
         //Page: Settings : Amadeus Technical Support
         PageGroupName = 'For Amadeus Technical Support Use Only';
         PageName = 'Amadeus Technical Support Settings';

         PageSectionName = 'Troubleshooting';
         string TroubleshootingDefaultValue = 'FALSE';
         if (Test.isRunningTest()) TroubleshootingDefaultValue = 'TRUE';
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES, SettingType__c = 'Checkbox', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 1, SettingDisplayName__c = 'Enable System.Debug logging', SettingHelpText__c = 'Turns on advanced troubleshooting logging, when DEBUG LOGGING in Salesforce is enabled for one or more users. This will generate large log files and should be used sparingly', SettingValue__c = '', SettingValueDefault__c = TroubleshootingDefaultValue, SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));

         //Page: Settings : Logging Settings
         PageGroupName = 'Logging Settings';
         PageName = 'Logging Settings';
         PageSectionName = 'Log Entries to Create';

         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_TRACES, SettingType__c = 'Checkbox', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 1, SettingDisplayName__c = 'Write TRACES to the Log', SettingHelpText__c = 'When a TRACE message is generated by the application, write the message the Log__c object', SettingValue__c = '', SettingValueDefault__c = 'FALSE', SettingValueDomain__c = 'TRUE\r\nFALSE', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_WARNINGS, SettingType__c = 'Checkbox', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 2, SettingDisplayName__c = 'Write WARNINGS to the Log', SettingHelpText__c = 'When a WARNING message is generated by the application, write the message the Log__c object', SettingValue__c = '', SettingValueDefault__c = 'TRUE', SettingValueDomain__c = 'TRUE\r\nFALSE', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_ERRORS, SettingType__c = 'Checkbox', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 3, SettingDisplayName__c = 'Write ERRORS to the Log', SettingHelpText__c = 'When an ERROR message is generated by the application, write the message the Log__c object', SettingValue__c = '', SettingValueDefault__c = 'TRUE', SettingValueDomain__c = 'TRUE\r\nFALSE', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_EXCEPTIONS, SettingType__c = 'Checkbox', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 4, SettingDisplayName__c = 'Write EXCEPTIONS to the Log', SettingHelpText__c = 'When an EXCEPTION message is generated by the application, write the message the Log__c object', SettingValue__c = '', SettingValueDefault__c = 'TRUE', SettingValueDomain__c = 'TRUE\r\nFALSE', UsedBy__c = '', OrgName__c = orgName));
         PageSectionName = 'Log Entries to Email';
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_WARNINGS, SettingType__c = 'Checkbox', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 10, SettingDisplayName__c = 'Email logged WARNINGS', SettingHelpText__c = 'When a WARNING message is logged, should an email be sent to the Email Log Recipient(s)', SettingValue__c = '', SettingValueDefault__c = 'TRUE', SettingValueDomain__c = 'TRUE\r\nFALSE', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_ERRORS, SettingType__c = 'Checkbox', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 11, SettingDisplayName__c = 'Email logged ERRORS', SettingHelpText__c = 'When an ERROR message is logged, should an email be sent to the Email Log Recipient(s)', SettingValue__c = '', SettingValueDefault__c = 'TRUE', SettingValueDomain__c = 'TRUE\r\nFALSE', UsedBy__c = '', OrgName__c = orgName));
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_EXCEPTIONS, SettingType__c = 'Checkbox', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 12, SettingDisplayName__c = 'Email logged EXCEPTIONS', SettingHelpText__c = 'When an EXCEPTION message is logged, should an email be sent to the Email Log Recipient(s)', SettingValue__c = '', SettingValueDefault__c = 'FALSE', SettingValueDomain__c = 'TRUE\r\nFALSE', UsedBy__c = '', OrgName__c = orgName));
         PageSectionName = 'Recipient(s) for Log Emails';
         string emails = '';
         defaultSettings.add(new AH_UDC_ConfigurationSetting__c(Name = AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_RECIPIENTS, SettingType__c = 'String', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 8, SettingDisplayName__c = 'Email Log Recipient(s)', SettingHelpText__c = 'Comma-separated list of email addresses to which logs that are emailed will be sent', SettingValue__c = '', SettingValueDefault__c = emails, SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName));

         //Create map from default settings list
         Map<String, AH_UDC_ConfigurationSetting__c> mapDefaultSettings = new Map<String, AH_UDC_ConfigurationSetting__c> ();
         for (AH_UDC_ConfigurationSetting__c cs : defaultSettings) {
            mapDefaultSettings.put(cs.name, cs);
         }

         //Get Existing Settings - AH_UDC only
         string orgIdPrefix = String.valueOf(orgInfo.Id).left(15) + '||%';
         List<AH_UDC_ConfigurationSetting__c> existingSettings = [SELECT Name, SettingType__c, PageGroupName__c, PageName__c, PageSectionName__c, DisplayOrder__c, SettingDisplayName__c, SettingHelpText__c, SettingValue__c, SettingTextAreaValue__c, SettingValueDefault__c, SettingValueDomain__c, UsedBy__c, OrgName__c FROM AH_UDC_ConfigurationSetting__c WHERE AH_UDC__c = true and(OrgName__c = :orgInfo.name or OrgName__c like :orgIdPrefix)];

         //Create map from existing settings list
         Map<String, AH_UDC_ConfigurationSetting__c> mapExistingSettings = new Map<String, AH_UDC_ConfigurationSetting__c> ();
         for (AH_UDC_ConfigurationSetting__c cs : existingSettings) {
            mapExistingSettings.put(cs.name, cs);
         }

         //Add Missing Settings
         for (AH_UDC_ConfigurationSetting__c defaultSetting : defaultSettings) {
            if (mapExistingSettings.containsKey(defaultSetting.name)) {
               //Update Setting  ... everything except the value
               AH_UDC_ConfigurationSetting__c eCS = mapExistingSettings.get(String.escapeSingleQuotes(defaultSetting.name));
               eCS.SettingType__c = String.escapeSingleQuotes(defaultSetting.SettingType__c);
               eCS.PageGroupName__c = String.escapeSingleQuotes(defaultSetting.PageGroupName__c);
               eCS.PageName__c = String.escapeSingleQuotes(defaultSetting.PageName__c);
               eCS.PageSectionName__c = String.escapeSingleQuotes(defaultSetting.PageSectionName__c);
               //For checkmarx
               eCS.DisplayOrder__c = Decimal.valueof(String.valueOf(defaultSetting.DisplayOrder__c));
               eCS.SettingDisplayName__c = String.escapeSingleQuotes(defaultSetting.SettingDisplayName__c);
               eCS.SettingHelpText__c = String.escapeSingleQuotes(defaultSetting.SettingHelpText__c);
               eCS.SettingValueDefault__c = String.escapeSingleQuotes(defaultSetting.SettingValueDefault__c);
               eCS.SettingValueDomain__c = String.escapeSingleQuotes(defaultSetting.SettingValueDomain__c);
               eCS.UsedBy__c = String.escapeSingleQuotes(defaultSetting.UsedBy__c);

               //Remove the Value if it's the same as the default
               if (eCS.SettingValue__c != null && eCS.SettingValueDefault__c != null
                   && eCS.SettingValue__c.toUpperCase() == eCS.SettingValueDefault__c.toUpperCase()) {
                  eCS.SettingValue__c = '';
               }

               if (eCS.SettingType__c == 'TextArea' && string.isBlank(eCS.SettingTextAreaValue__c)) {
                  eCS.SettingTextAreaValue__c = String.escapeSingleQuotes(defaultSetting.SettingTextAreaValue__c);
               }

               //Update the Org Name field to have an ID as well
               string updateOrgIdPrefix = String.valueOf(orgInfo.Id).left(15) + '||';
               if (!eCS.OrgName__c.contains('||')) {
                  eCS.OrgName__c = updateOrgIdPrefix + eCS.OrgName__c;
               }

               //Protect any ProtectedString settings
               if (eCS.SettingType__c == 'ProtectedString' && eCS.SettingValue__c != null && !eCS.SettingValue__c.startsWith(AH_UDC_ConfigHelper.PROTECTED_PREFIX)) {
                  eCS.SettingValue__c = AH_UDC_ConfigHelper.protect(eCS.SettingValue__c);
               }

               updateCS.add(eCS);
            } else {
               //Create Setting
               AH_UDC_LogHelper.Debug('defaultSetting: ' + defaultSetting);
               insertCS.add(defaultSetting);
            }
         }

         //Delete old sunset managed settings
         for (AH_UDC_ConfigurationSetting__c existingSetting : existingSettings) {
            if (!mapDefaultSettings.containsKey(existingSetting.name)) {
               deleteCS.add(existingSetting);
            }
         }

         AH_UDC_LogHelper.Debug('updateCS:' + String.valueOf(updateCS.size()));
         AH_UDC_LogHelper.Debug('insertCS:' + String.valueOf(insertCS.size()));
         AH_UDC_LogHelper.Debug('deleteCS:' + String.valueOf(deleteCS.size()));

         if (updateCS.size() > 0) upsert(updateCS);
         if (insertCS.size() > 0) upsert(insertCS);
         if (deleteCS.size() > 0) delete(deleteCS);

         AH_UDC_LogHelper.Log('Message', 'Initializing AH_UDC Configuration Settings', AH_UDC_LogHelper.getClassAndMethodName(new DmlException()),
                              'Initialize AH_UDC_ConfigurationSettings Completed');

         return true;
      }
      catch(Exception exc) {

         // START DEBUGGING - For troubleshooting when there is a duplicate Name for two ConfigSettings
         List<String> listNames = new List<String> ();
         for (AH_UDC_ConfigurationSetting__c cs : updateCS) {
            system.Debug(LoggingLevel.INFO, '???' + cs.Name);
            if (listNames.Contains(cs.Name)) {
               system.Debug(LoggingLevel.ERROR, 'Duplicate AH_UDC_ConfigSetting named "' + cs.Name + '" found in updateCS');
            } else {
               listNames.add(cs.Name);
            }
         }
         for (AH_UDC_ConfigurationSetting__c cs : insertCS) {
            if (listNames.Contains(cs.Name)) {
               system.Debug(LoggingLevel.ERROR, 'Duplicate AH_UDC_ConfigSetting named "' + cs.Name + '" found in insertCS');
            } else {
               listNames.add(cs.Name);
            }
         }
         listNames.clear();
         // END DEBUGGING
         AH_UDC_LogHelper.Log('Exception', 'AH_UDC Configuration Settings', AH_UDC_LogHelper.getClassAndMethodName(new DmlException()),
                              'Exception occurred while initializing AH_UDC Configuration Settings', exc, null, null);
         return false;
      }
   }
}