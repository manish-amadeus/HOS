<<<<<<< HEAD
<<<<<<< HEAD
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
         when 'SchedulePurgeJob' {
            return SchedulePurgeJob((String) args.get('mode'));
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
      System.Debug('mode: ' + mode); //DO NOT change this to LogHelper

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

      //This will schedule the job if it's not already scheduled
      if (!Test.isRunningTest())
      {
         if (String.isEmpty(mode) || mode == 'All' || mode == 'SchedulePurgeJob') {
            modeFound = true;
            SchedulePurgeJob('add');
         }
      }

      if (!modeFound) return false;
      return rStatus;
   }

   private static Boolean isProdOrg() {
      // This is the Amadeus Org's Production Org Id
      return '00D300000006CtnEAE' == Userinfo.getOrganizationId();
   }

   private static AH_UDC_ConfigurationSetting__c newCS(string CSName, string SettingType, string PageGroupName, string PageName, string PageSectionName,
                                                       integer DisplayOrder, string SettingDisplayName, string SettingHelpText, string SettingValue,
                                                       string SettingValueDefault, string SettingValueDomain, string UsedBy, string OrgName) {
      return new AH_UDC_ConfigurationSetting__c(AH_UDC__c = true,
                                                Name = CSName, SettingType__c = SettingType, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName,
                                                DisplayOrder__c = DisplayOrder, SettingDisplayName__c = SettingDisplayName, SettingHelpText__c = SettingHelpText, SettingValue__c = SettingValue,
                                                SettingValueDefault__c = SettingValueDefault, SettingValueDomain__c = SettingValueDomain, UsedBy__c = UsedBy, OrgName__c = OrgName);
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
         defaultSettings.add(newCS('Initialize', 'GroupPage', PageGroupName, PageName, '', 1, 'Initialize Settings', 'Initialize AH_UDC Settings', '', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC Settings', 'GroupPage', PageGroupName, PageName, '', 2, 'UDC Settings', 'UDC Settings', '', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_UsersPage', 'Page', PageGroupName, PageName, '', 3, 'UDC Users', 'Add/Remove UDC Permission Set on Users', '', 'apex/AH_UDC_Users', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_Logging', 'GroupPage', PageGroupName, PageName, '', 4, 'Logging Settings', 'Logging Settings', '', '', '', '', orgName));
         if (!isProdOrg()) defaultSettings.add(newCS('AH_UDC_UnitTest', 'GroupPage', PageGroupName, PageName, '', 5, 'Unit Test Settings', 'Unit Test Settings', '', '', '', '', orgName));
         defaultSettings.add(newCS('AmadeusTechnicalSupportSettings', 'GroupPage', PageGroupName, PageName, PageSectionName, 80, 'Technical Support Settings', AH_UDC_LabelHelper.ReplaceParametersInValue('Contains settings that should only be adjusted by UDC Technical Support. Invalid changes may cause {!ApplicationName} to stop functioning'), '', '', '', '', orgName));

         PageName = 'Initialize Settings';
         PageSectionName = 'Initialize';
         defaultSettings.add(newCS('Init_All', 'Method', PageGroupName, PageName, PageSectionName, 1, 'Initialize All', 'This will initialize all AH_UDC Objects and ConfigurationSettings, creating any ConfigurationSettings that are missing or updating them as required [Non-destructive]', 'AH_UDC_InitializationHelper;Initialize;{"mode":"All"}', 'AH_UDC_InitializationHelper;Initialize;{"mode":"All"}', '', '', orgName));
         defaultSettings.add(newCS('Init_ConfigurationSettings', 'Method', PageGroupName, PageName, PageSectionName, 2, 'Initialize Configuration Settings', 'This will initialize only the ConfigurationSettings, creating any ConfigurationSettings that are missing or updating them as required [Non-destructive]', 'AH_UDC_InitializationHelper;Initialize;{"mode":"ConfigurationSettings"}', 'AH_UDC_InitializationHelper;Initialize;{"mode":"ConfigurationSettings"}', '', '', orgName));

         //Page: General : UDC Settings
         PageName = 'UDC Settings';
         PageSectionName = 'System Status';
         defaultSettings.add(newCS('AH_UDC_SendWorkbookEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Send Workbook Enabled', 'Use this to stop users from sending workbooks.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_SendWorkbookDisabledMessage', 'String', PageGroupName, PageName, PageSectionName, 2, 'Send Workbook Disabled Message', 'When sending is disabled, this is the message users will be shown when they try to send a workbook.', '', 'UDC is undergoing maintenance and sending workbooks is disabled; please check back later.', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_CommunityEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 3, 'Community Enabled', 'Use this to stop community users from viewing workbooks.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_CommunityDisabledMessage', 'String', PageGroupName, PageName, PageSectionName, 4, 'Community Disabled Message', 'When Community is disabled, this is the message users will be shown when they try to view a workbook.', '', 'The system is currently offline for maintenance; please check back later.', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 5, 'View Workbook Enabled', 'Use this to stop Amadeus users from viewing workbooks.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookDisabledMessage', 'String', PageGroupName, PageName, PageSectionName, 6, 'View Workbook Disabled Message', 'When viewing is disabled, this is the message users will be shown when they try to view a workbook.', '', 'The system is currently offline for maintenance; please check back later.', '', '', orgName));

         PageSectionName = 'Email Template Settings';
         defaultSettings.add(newCS('AH_UDC_EmailTemplatePortalUrlPlaceholder', 'String', PageGroupName, PageName, PageSectionName, 1, 'Community Portal URL Placeholder', 'This is the string to search for in email templates; it will be replaced with the real portal url (another configuration setting)', '', 'https://udcsb-amadeus-community.cs19.force.com/customers/s/', '', '', orgName));

         PageSectionName = 'Community Portal';
         defaultSettings.add(newCS('AH_UDC_CommunityPortalUrl', 'String', PageGroupName, PageName, PageSectionName, 1, 'Community Portal Url', 'This is the URL for the Community Portal', '', 'https://udcsb-amadeus-community.cs19.force.com/customers/s/', '', '', orgName));

         PageSectionName = 'Profiles';
         defaultSettings.add(newCS(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER, 'String', PageGroupName, PageName, PageSectionName, 1, 'Community Profile With Chatter', 'This is the profile used when creating community users who agree to chatter', '', 'AH Customer Community Plus Login User', '', '', orgName));
         defaultSettings.add(newCS(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER, 'String', PageGroupName, PageName, PageSectionName, 2, 'Community Profile No Chatter', 'This is the profile used when creating community users who do not agree to chatter', '', 'AH Customer Community Plus Login - No Chatter', '', '', orgName));

         PageSectionName = 'Permission Sets';
         defaultSettings.add(newCS('AH_UDC_PermissionSetCommunityUser', 'String', PageGroupName, PageName, PageSectionName, 1, 'Permission Set for Community User (API Name)', 'This is the API Name of the permission set assigned to community users that will be using UDC', '', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PermissionSetUDCSystemAdministrator', 'String', PageGroupName, PageName, PageSectionName, 2, 'Permission Set for UDC System Administrator User (API Name)', 'This is the API Name of the permission set assigned to UDC System Administrator users that will be using UDC', '', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PermissionSetWorkbookAdministrator', 'String', PageGroupName, PageName, PageSectionName, 3, 'Permission Set for Workbook Administrator User (API Name)', 'This is the API Name of the permission set assigned to Workbook Administrator users that will be using UDC', '', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PermissionSetWorkbookUser', 'String', PageGroupName, PageName, PageSectionName, 4, 'Permission Set for Workbook User (API Name)', 'This is the API Name of the permission set assigned to Workbook SUers that will be using UDC', '', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, '', '', orgName));

         PageSectionName = 'Send Workbook - Create Community User Settings';
         defaultSettings.add(newCS('AH_UDC_CreateCommunityUserEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Create Community User(s) When Sending Workbook', 'This determines if community users will be created when sending workbooks.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_CreateCommunityUserOrgPrefix', 'String', PageGroupName, PageName, PageSectionName, 2, 'Org Name to Append To End Of User Name', 'This is the prefix of the org that should be applied to the end of any user names created (ex. ".UDCSB")', '', '', '', '', orgName)); //DO NOT set a default value on this since the production value needs to be blank
         defaultSettings.add(newCS('AH_UDC_CommunityUserNamePostfix', 'String', PageGroupName, PageName, PageSectionName, 3, 'Community User Name Postfix', 'This is the Comunity postfix applied to the end of any user names created', '', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX, '', '', orgName));

         PageSectionName = 'Update Community User Profile Settings';
         defaultSettings.add(newCS('AH_UDC_CommunityUserProfileUpdateEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Allow updating of commuity user profile to With Chatter profile', 'This determines if the system is allowed to change a community user\'s profile to the profile that allows chatter.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_SetCommunityUserProfileUrl', 'String', PageGroupName, PageName, PageSectionName, 2, 'Set Community User Profile Url', 'This is the URL of the .net Core API for CommunityUserProfile Controller', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/CommunityUserProfile', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_SetCommunityUserProfileTimeout', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Timeout for the URL in Seconds', 'This determines how long the call to the API will wait.', '', '120', '1\r\n120', '', orgName));

         PageSectionName = 'Chatter';
         defaultSettings.add(newCS('AH_UDC_ChatterUrl', 'String', PageGroupName, PageName, PageSectionName, 2, 'Chatter Url', 'This is the URL of the .net Core API for Chatter Controller', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/Chatter', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ChatterTimeout', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Timeout for the Chatter URL in Seconds', 'This determines how long the call to the API will wait.', '', '120', '1\r\n120', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ChatterPostMaxLength', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Max Post Length', 'This determines how many characters are allowed in the chatter post.', '', '2000', '1\r\n5000', '', orgName));

         PageSectionName = 'CreateCommunityUser';
         defaultSettings.add(newCS('AH_UDC_CreateCommunityUserUrl', 'String', PageGroupName, PageName, PageSectionName, 2, 'Chatter Url', 'This is the URL of the .net Core API for Community User Controller', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/CommunityUser', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_CreateCommunityUserTimeout', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Timeout for the Community User URL in Seconds', 'This determines how long the call to the API will wait.', '', '120', '1\r\n120', '', orgName));
         
         PageSectionName = 'Send Workbook - Chatter Notification Settings';
         defaultSettings.add(newCS('AH_UDC_WorkbookAccessedDefaultValue', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'When Workbook Accessed', 'This will determine if chatter notification need to be send when workbook is accessed by the user on community portal.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookCompletedDefaultValue', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'When Workbook Completed', 'This will determine if chatter notification need to be send when workbook is completed by the user on community portal.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookStepCompletedDefaultValue', 'Checkbox', PageGroupName, PageName, PageSectionName, 3, 'When Workbook Step Completed', 'This will determine if chatter notification need to be send when workbook step is completed by the user on community portal.', '', 'false', '', '', orgName));

         PageSectionName = 'Send Workbook Settings';
         defaultSettings.add(newCS('AH_UDC_AddContactLimit', 'Integer', PageGroupName, PageName, PageSectionName, 1, 'Max Contact Limit', 'This determines how many Contact users can add to document using the Send workbook page.', '', '5', '0\r\n10', '', orgName)); //max-min value updated as per discussion with Hardik

         PageSectionName = 'Custom Lookup settings';
         defaultSettings.add(newCS('AH_UDC_CustomLookupMaxRecordsAllowed', 'Integer', PageGroupName, PageName, PageSectionName, 1, 'Update Custom Lookup Maximum Records Allowed', 'This determines maximum records allow in custom lookup dialog.', '', '200', '0\r\n500', '', orgName)); //max-min value updated as per discussion with Hardik
         defaultSettings.add(newCS('AH_UDC_CustomLookupRecordsPerPage', 'Integer', PageGroupName, PageName, PageSectionName, 2, 'Update Custom Lookup Records Per Page', 'This determines Total records to display per page in custom lookup dialog.', '', '25', '25\r\n100', '', orgName));

         PageSectionName = 'ViewWorkbook Settings';
         defaultSettings.add(newCS('AH_UDC_ReturnToWelcomePageURL', 'String', PageGroupName, PageName, PageSectionName, 1, 'Return To Welcome Page URL', 'This is the URL to which the user is sent when clicking Return To Welcome Page.', '', '/customers/s/services?tabset-8bc76=1cb08', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_CollapsedMenuCirclesPerPage', 'Integer', PageGroupName, PageName, PageSectionName, 2, 'Collapsed Menu Number of Steps Shown', 'This determines the number of steps shown in the collapsed menu.', '', '10', '1\r\n100', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookNotificationDisplayInSeconds', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Notification Display Time in Seconds', 'This determines how long all notifications will be show.', '', '5', '1\r\n60', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookUpdateTimerIntervalInSeconds', 'Integer', PageGroupName, PageName, PageSectionName, 4, 'Update Timer Interval in Seconds', 'This determines how often the view workbook page will look for updates and chatter.', '', '60', '10\r\n600', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookTokenEncryptionKey', 'String', PageGroupName, PageName, PageSectionName, 5, 'Token Encryption Key', 'This is the key for encrypting the token sent to Forms; this should not be set manually.\r\nTo issue a new key set the value to empty and run the Initialize Settings.', '', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookTokenEncryption', 'Checkbox', PageGroupName, PageName, PageSectionName, 6, 'Encrypt Token', 'When checked the Token sent to the Form will be encrypted', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookDisplayConsoleLogMessages', 'Checkbox', PageGroupName, PageName, PageSectionName, 7, 'Display Console Log Messages', 'When checked console.log messages will be written to the browser', '', 'false', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookStartVideo', 'String', PageGroupName, PageName, PageSectionName, 8, 'Start Page Video', 'This is the HTML to the video that is shown on the View Workbook Start page.', '', '&nbsp;', '', '', orgName));
         
         PageSectionName = 'File Upload Settings';
         defaultSettings.add(newCS('AH_UDC_FileUploadMaximumFileCount', 'Integer', PageGroupName, PageName, PageSectionName, 1, 'Maximum number of files allowed for upload at one time', 'This determines how many files a user is allowed to select for upload.', '', '5', '1\r\n24', '', orgName));
         defaultSettings.add(newCS('AH_UDC_FileUploadAllowedExtensions', 'String', PageGroupName, PageName, PageSectionName, 2, 'Allowed extensions for file upload', 'This is a comma separatead list of the allowed file extensions.', '', 'TXT, BMP, JPEG, PNG,PDF, XLS, DOC, DOCX, XLSX, JPG, MSG, PPT, PPTX, GIF, SVG, EPS, CDR, ZIP', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_FileUploadMaximumSizeInMB', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Maximum individual file size in MB', 'This determines maximum file upload size in MB.', '', '21', '1\r\n21', '', orgName));
         defaultSettings.add(newCS('AH_UDC_FileUploadUrl', 'String', PageGroupName, PageName, PageSectionName, 4, 'File Upload URL', 'This is the URL to the REST API used for file upload.', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/FormUploadFile', '', '', orgName));

         PageSectionName = 'Data Management Settings';
         defaultSettings.add(newCS('AH_UDC_PurgeEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Purge Enabled', 'This determines if the purge will happen when the scheduled job runs; this relies on the job being sceduled.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeAllExceptMostRecentResponseForCompletedWorkbooks', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Purge all except most recent response for Completed/Locked Workbooks', 'When checked, purge all except most recent response for Completed/Locked workbooks. Setting will be used in scheduler job.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeResponseAfterNumberOfDaysForCompletedLockedWorkbooks', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Number of days after Workbook is locked until purged', 'This determines number of days after Workbook is locked until purged. Setting will be used in scheduler job.', '', '3', '1\r\n100', '', orgName)); //max 100 days
         defaultSettings.add(newCS('AH_UDC_NumberOfPriorWorkbookStepSentResponsesToKeep', 'Integer', PageGroupName, PageName, PageSectionName, 4, 'Number of prior Workbook Step Sent Responses to keep', 'This determines number of Prior Workbook Step Sent Responses to keep. Setting will be used in scheduler job.', '', '3', '2\r\n10', '', orgName)); //default value = 3, max 10 
         defaultSettings.add(newCS('AH_UDC_PurgeBatchSize', 'Integer', PageGroupName, PageName, PageSectionName, 5, 'Number Records in each Purge Batch', 'This determines number of decords that will be sent to each Batch execution; this needs to be set appropriately to avoid governor issues.', '', '10', '1\r\n200', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeResponseBatchSize', 'Integer', PageGroupName, PageName, PageSectionName, 6, 'Number Records in each Purge Response Batch', 'This determines number of decords that will be sent to each Batch execution; this needs to be set appropriately to avoid governor issues.', '', '10', '1\r\n200', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeRemoveScheduledJob', 'Method', PageGroupName, PageName, PageSectionName, 7, 'Remove Scheduled Job', 'This will remove the scheduled data maintenance job.', 'AH_UDC_InitializationHelper;SchedulePurgeJob;{"mode":"Remove"}', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeCron', 'String', PageGroupName, PageName, PageSectionName, 8, 'Purge Job CRON setting', 'This controls when the Purge job will run. NOTE: You must remove the job and reinitialize in order for this setting to take effect.', '', '0 0 2 * * ?', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeVerify', 'Method', PageGroupName, PageName, PageSectionName, 9, 'Verify Scheduled Job', 'This will verify the scheduled data maintenance job is scheduled and when it will run.', 'AH_UDC_InitializationHelper;SchedulePurgeJob;{"mode":"Verify"}', '', '', '', orgName));

         PageSectionName = 'Amadeus Custom Form Settings';
         defaultSettings.add(newCS('AH_UDC_APIUrl', 'String', PageGroupName, PageName, PageSectionName, 1, 'API URL to get/save form response data', 'This is the URL which will be used to get/save form response data.', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/AmadeusForm/', '', '', orgName));

         PageSectionName = 'Export Response URL';
         defaultSettings.add(newCS('AH_UDC_ExportUrl', 'String', PageGroupName, PageName, PageSectionName, 1, 'URL for response export', 'This is the URL which will be used to export response(s).', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/Export/{TOKEN}/{MODE}/{STEP}', '', '', orgName));

         //Page: Settings : Amadeus Technical Support
         PageGroupName = 'For Technical Support Use Only';
         PageName = 'Technical Support Settings';

         PageSectionName = 'Troubleshooting';
         string TroubleshootingDefaultValue = 'FALSE';
         if (Test.isRunningTest()) TroubleshootingDefaultValue = 'TRUE';
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES, 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Enable System.Debug logging', 'Turns on advanced troubleshooting logging, when DEBUG LOGGING in Salesforce is enabled for one or more users. This will generate large log files and should be used sparingly', '', TroubleshootingDefaultValue, '', '', orgName));

         //Page: Settings : Logging Settings
         PageGroupName = 'Logging Settings';
         PageName = 'Logging Settings';
         PageSectionName = 'Log Entries to Create';

         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_TRACES, 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Write TRACES to the Log', 'When a TRACE message is generated by the application, write the message the Log__c object', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_WARNINGS, 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Write WARNINGS to the Log', 'When a WARNING message is generated by the application, write the message the Log__c object', '', 'TRUE', 'TRUE\r\nFALSE', '', orgName));
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_ERRORS, 'Checkbox', PageGroupName, PageName, PageSectionName, 3, 'Write ERRORS to the Log', 'When an ERROR message is generated by the application, write the message the Log__c object', '', 'TRUE', 'TRUE\r\nFALSE', '', orgName));
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_EXCEPTIONS, 'Checkbox', PageGroupName, PageName, PageSectionName, 4, 'Write EXCEPTIONS to the Log', 'When an EXCEPTION message is generated by the application, write the message the Log__c object', '', 'TRUE', 'TRUE\r\nFALSE', '', orgName));
         PageSectionName = 'Log Entries to Email';
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_WARNINGS, 'Checkbox', PageGroupName, PageName, PageSectionName, 10, 'Email logged WARNINGS', 'When a WARNING message is logged, should an email be sent to the Email Log Recipient(s)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_ERRORS, 'Checkbox', PageGroupName, PageName, PageSectionName, 11, 'Email logged ERRORS', 'When an ERROR message is logged, should an email be sent to the Email Log Recipient(s)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_EXCEPTIONS, 'Checkbox', PageGroupName, PageName, PageSectionName, 12, 'Email logged EXCEPTIONS', 'When an EXCEPTION message is logged, should an email be sent to the Email Log Recipient(s)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
         PageSectionName = 'Recipient(s) for Log Emails';
         string emails = '';
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_RECIPIENTS, 'String', PageGroupName, PageName, PageSectionName, 8, 'Email Log Recipient(s)', 'Comma-separated list of email addresses to which logs that are emailed will be sent', '', emails, '', '', orgName));

         //Page: Settings : Debug Settings
         if (!isProdOrg()) {
            PageGroupName = 'Unit Test Settings';
            PageName = 'Unit Test Settings';

            PageSectionName = 'UDC User';
            defaultSettings.add(newCS('AH_UDC_UnitTestUDCUsersLoadingError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force UDC Users Load Error', 'Forces an error on the Loading of the UDC Users page.', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestUDCUsersGrantError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force UDC Users Grant Error', 'Forces an error on the UDC Users page when Granting a permission set.', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestUDCUsersRevokeError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force UDC Users Revoke Error', 'Forces an error on the UDC Users page when Revoking a permission set.', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'Community User';
            defaultSettings.add(newCS('AH_UDC_ChangeCommunityUserProfile', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Community User Profile Change Error', 'Forces an error anywhere in the code that a Community User\'s Profile is being changed (e.g. When a new Community User confirms opt into Chatter)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'ChangeUserProfileToChatter';
            defaultSettings.add(newCS('AH_UDC_UnitTestSetCommunityUserProfileHttpNon200Error', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Community User Profile Change HTTP Error', 'Forces an error anywhere in the code that a Community User\'s Profile is being changed (e.g. When a new Community User confirms opt into Chatter)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestSetCommunityUserProfileRespNon200Error', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Community User Profile Change Response Error', 'Forces an error anywhere in the code that a Community User\'s Profile is being changed (e.g. When a new Community User confirms opt into Chatter)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'Send Workbook';
            defaultSettings.add(newCS('AH_UDC_UnitTestSendWorkbookError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Send Workbook Error', 'Forces an error on the sending of a Workbook', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceSendWorkbookCreateCommunityUserException', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Send Workbook Create Community User Exception', 'Forces an exception on the creating of the community user', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'View Help';
            defaultSettings.add(newCS('AH_UDC_UnitTestForceViewHelpError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force View Help Load Error', 'Forces an error on the load of the View Help page', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'View Workbook';
            defaultSettings.add(newCS('AH_UDC_UnitTestForceViewWorkbookLoadError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force View Workbook Load Error', 'Forces an error on the load of the View Workbook page', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceViewWorkbookRefreshError', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Force View Workbook Refresh Error', 'Forces an error on the refresh of the View Workbook page', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceViewWorkbookFileUploadStepInProgressError', 'Checkbox', PageGroupName, PageName, PageSectionName, 3, 'Force View Workbook File Upload Set Step In Progress Error', 'Forces an error when the File Upload tries to set the step status to In Progress', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'File Upload';
            defaultSettings.add(newCS('AH_UDC_UnitTestForceFileUploadError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force File Upload Error', 'Forces an error during file upload', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceFileDeleteError', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Force File Delete Error', 'Forces an error during file delete', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'Workbook Archive';
            defaultSettings.add(newCS('AH_UDC_UnitTestForceArchivePageLoadError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Archive Page Load Error', 'Forces an error during Archive page load', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceArchiveError', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Force Archive Error', 'Forces an error during archive', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
         }

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

   Private static string SchedulePurgeJob(string mode) {
      List<CronTrigger> jobs = AH_UDC_SystemContext.query('SELECT Id,NextFireTime FROM CronTrigger where cronjobdetail.name = \'' + AH_UDC_Constants.Purge_Scheduled_Job_Name + '\'');
      if (mode.toLowerCase() == 'remove') {
         if (jobs.size() == 0) return 'The Purge job is currently not scheduled';
         System.abortJob(jobs[0].id);
         return 'Scheduled Purge job was removed';
      }
      if (mode.toLowerCase() == 'add') {
         if (jobs.size() > 0) return 'The Purge job is already scheduled';
         String cronStr = AH_UDC_ConfigHelper.GetString('AH_UDC_PurgeCron', '0 0 2 * * ?'); //Default is class runs every day at 2 AM
         String jobID = System.schedule(AH_UDC_Constants.Purge_Scheduled_Job_Name, cronStr, new AH_UDC_DataMaintenance_Schedule());
         return 'Scheduled Purge job was removed';
      }
      if (mode.toLowerCase() == 'verify') {
         if (jobs.size() == 0) return 'The Purge job is currently not scheduled';
         return 'Scheduled Purge job will run at: ' + jobs[0].NextFireTime.format();
      }
      return 'SchedulePurgeJob, unkown mode: ' + mode;
   }
=======
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
         when 'SchedulePurgeJob' {
            return SchedulePurgeJob((String) args.get('mode'));
         }
         when 'ScheduleWorkbookSentEmailJob' {
            return ScheduleWorkbookSentEmailJob((String) args.get('mode'));
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
      System.Debug('mode: ' + mode); //DO NOT change this to LogHelper

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
         List<AH_UDC_ConfigurationSetting__c> csSettings = [select id from AH_UDC_ConfigurationSetting__c where Name = :AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES];
         if (csSettings.size() ==0) insert new AH_UDC_ConfigurationSetting__c(Name = AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES, SettingType__c = 'Checkbox', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 1, SettingDisplayName__c = 'Enable System.Debug logging', SettingHelpText__c = 'Turns on advanced troubleshooting logging, when DEBUG LOGGING in Salesforce is enabled for one or more users. This will generate large log files and should be used sparingly', SettingValue__c = '', SettingValueDefault__c = 'FALSE', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName);
         AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES,FALSE);
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

   private static Boolean isProdOrg() {
      // This is the Amadeus Org's Production Org Id
      return '00D300000006CtnEAE' == Userinfo.getOrganizationId();
   }

   private static AH_UDC_ConfigurationSetting__c newCS(string CSName, string SettingType, string PageGroupName, string PageName, string PageSectionName,
                                                       integer DisplayOrder, string SettingDisplayName, string SettingHelpText, string SettingValue,
                                                       string SettingValueDefault, string SettingValueDomain, string UsedBy, string OrgName) {
      return new AH_UDC_ConfigurationSetting__c(AH_UDC__c = true,
                                                Name = CSName, SettingType__c = SettingType, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName,
                                                DisplayOrder__c = DisplayOrder, SettingDisplayName__c = SettingDisplayName, SettingHelpText__c = SettingHelpText, SettingValue__c = SettingValue,
                                                SettingValueDefault__c = SettingValueDefault, SettingValueDomain__c = SettingValueDomain, UsedBy__c = UsedBy, OrgName__c = OrgName);
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
         defaultSettings.add(newCS('Initialize', 'GroupPage', PageGroupName, PageName, '', 1, 'Initialize Settings', 'Initialize AH_UDC Settings', '', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC Settings', 'GroupPage', PageGroupName, PageName, '', 2, 'UDC Settings', 'UDC Settings', '', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_UsersPage', 'Page', PageGroupName, PageName, '', 3, 'UDC Users', 'Add/Remove UDC Permission Set on Users', '', 'apex/AH_UDC_Users', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_Logging', 'GroupPage', PageGroupName, PageName, '', 4, 'Logging Settings', 'Logging Settings', '', '', '', '', orgName));
         if (!isProdOrg()) defaultSettings.add(newCS('AH_UDC_UnitTest', 'GroupPage', PageGroupName, PageName, '', 5, 'Unit Test Settings', 'Unit Test Settings', '', '', '', '', orgName));
         defaultSettings.add(newCS('AmadeusTechnicalSupportSettings', 'GroupPage', PageGroupName, PageName, PageSectionName, 80, 'Technical Support Settings', AH_UDC_LabelHelper.ReplaceParametersInValue('Contains settings that should only be adjusted by UDC Technical Support. Invalid changes may cause {!ApplicationName} to stop functioning'), '', '', '', '', orgName));

         PageName = 'Initialize Settings';
         PageSectionName = 'Initialize';
         defaultSettings.add(newCS('Init_All', 'Method', PageGroupName, PageName, PageSectionName, 1, 'Initialize All', 'This will initialize all AH_UDC Objects and ConfigurationSettings, creating any ConfigurationSettings that are missing or updating them as required [Non-destructive]', 'AH_UDC_InitializationHelper;Initialize;{"mode":"All"}', 'AH_UDC_InitializationHelper;Initialize;{"mode":"All"}', '', '', orgName));
         defaultSettings.add(newCS('Init_ConfigurationSettings', 'Method', PageGroupName, PageName, PageSectionName, 2, 'Initialize Configuration Settings', 'This will initialize only the ConfigurationSettings, creating any ConfigurationSettings that are missing or updating them as required [Non-destructive]', 'AH_UDC_InitializationHelper;Initialize;{"mode":"ConfigurationSettings"}', 'AH_UDC_InitializationHelper;Initialize;{"mode":"ConfigurationSettings"}', '', '', orgName));

         //Page: General : UDC Settings
         PageName = 'UDC Settings';
         PageSectionName = 'System Status';
         defaultSettings.add(newCS('AH_UDC_SendWorkbookEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Send Workbook Enabled', 'Use this to stop users from sending workbooks.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_SendWorkbookDisabledMessage', 'String', PageGroupName, PageName, PageSectionName, 2, 'Send Workbook Disabled Message', 'When sending is disabled, this is the message users will be shown when they try to send a workbook.', '', 'UDC is undergoing maintenance and sending workbooks is disabled; please check back later.', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_CommunityEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 3, 'Community Enabled', 'Use this to stop community users from viewing workbooks.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_CommunityDisabledMessage', 'String', PageGroupName, PageName, PageSectionName, 4, 'Community Disabled Message', 'When Community is disabled, this is the message users will be shown when they try to view a workbook.', '', 'The system is currently offline for maintenance; please check back later.', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 5, 'View Workbook Enabled', 'Use this to stop Amadeus users from viewing workbooks.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookDisabledMessage', 'String', PageGroupName, PageName, PageSectionName, 6, 'View Workbook Disabled Message', 'When viewing is disabled, this is the message users will be shown when they try to view a workbook.', '', 'The system is currently offline for maintenance; please check back later.', '', '', orgName));

         PageSectionName = 'Email Template Settings';
         defaultSettings.add(newCS('AH_UDC_EmailTemplatePortalUrlPlaceholder', 'String', PageGroupName, PageName, PageSectionName, 1, 'Community Portal URL Placeholder', 'This is the string to search for in email templates; it will be replaced with the real portal url (another configuration setting)', '', 'https://udcsb-amadeus-community.cs19.force.com/customers/s/', '', '', orgName));

         PageSectionName = 'Community Portal';
         defaultSettings.add(newCS('AH_UDC_CommunityPortalUrl', 'String', PageGroupName, PageName, PageSectionName, 1, 'Community Portal Url', 'This is the URL for the Community Portal', '', 'https://udcsb-amadeus-community.cs19.force.com/customers/s/', '', '', orgName));

         PageSectionName = 'Profiles';
         defaultSettings.add(newCS(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER, 'String', PageGroupName, PageName, PageSectionName, 1, 'Community Profile With Chatter', 'This is the profile used when creating community users who agree to chatter', '', 'AH Customer Community Plus Login User', '', '', orgName));
         defaultSettings.add(newCS(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER, 'String', PageGroupName, PageName, PageSectionName, 2, 'Community Profile No Chatter', 'This is the profile used when creating community users who do not agree to chatter', '', 'AH Customer Community Plus Login - No Chatter', '', '', orgName));

         PageSectionName = 'Permission Sets';
         defaultSettings.add(newCS('AH_UDC_PermissionSetCommunityUser', 'String', PageGroupName, PageName, PageSectionName, 1, 'Permission Set for Community User (API Name)', 'This is the API Name of the permission set assigned to community users that will be using UDC', '', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PermissionSetUDCSystemAdministrator', 'String', PageGroupName, PageName, PageSectionName, 2, 'Permission Set for UDC System Administrator User (API Name)', 'This is the API Name of the permission set assigned to UDC System Administrator users that will be using UDC', '', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PermissionSetWorkbookAdministrator', 'String', PageGroupName, PageName, PageSectionName, 3, 'Permission Set for Workbook Administrator User (API Name)', 'This is the API Name of the permission set assigned to Workbook Administrator users that will be using UDC', '', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PermissionSetWorkbookUser', 'String', PageGroupName, PageName, PageSectionName, 4, 'Permission Set for Workbook User (API Name)', 'This is the API Name of the permission set assigned to Workbook SUers that will be using UDC', '', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, '', '', orgName));

         PageSectionName = 'Send Workbook - Create Community User Settings';
         defaultSettings.add(newCS('AH_UDC_CreateCommunityUserEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Create Community User(s) When Sending Workbook', 'This determines if community users will be created when sending workbooks.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_CreateCommunityUserOrgPrefix', 'String', PageGroupName, PageName, PageSectionName, 2, 'Org Name to Append To End Of User Name', 'This is the prefix of the org that should be applied to the end of any user names created (ex. ".UDCSB")', '', '', '', '', orgName)); //DO NOT set a default value on this since the production value needs to be blank
         defaultSettings.add(newCS('AH_UDC_CommunityUserNamePostfix', 'String', PageGroupName, PageName, PageSectionName, 3, 'Community User Name Postfix', 'This is the Comunity postfix applied to the end of any user names created', '', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX, '', '', orgName));

         PageSectionName = 'Update Community User Profile Settings';
         defaultSettings.add(newCS('AH_UDC_CommunityUserProfileUpdateEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Allow updating of commuity user profile to With Chatter profile', 'This determines if the system is allowed to change a community user\'s profile to the profile that allows chatter.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_SetCommunityUserProfileUrl', 'String', PageGroupName, PageName, PageSectionName, 2, 'Set Community User Profile Url', 'This is the URL of the .net Core API for CommunityUserProfile Controller', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/CommunityUserProfile', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_SetCommunityUserProfileTimeout', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Timeout for the URL in Seconds', 'This determines how long the call to the API will wait.', '', '120', '1\r\n120', '', orgName));

         PageSectionName = 'Chatter';
         defaultSettings.add(newCS('AH_UDC_ChatterUrl', 'String', PageGroupName, PageName, PageSectionName, 2, 'Chatter Url', 'This is the URL of the .net Core API for Chatter Controller', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/Chatter', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ChatterTimeout', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Timeout for the Chatter URL in Seconds', 'This determines how long the call to the API will wait.', '', '120', '1\r\n120', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ChatterPostMaxLength', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Max Post Length', 'This determines how many characters are allowed in the chatter post.', '', '2000', '1\r\n5000', '', orgName));

         PageSectionName = 'CreateCommunityUser';
         defaultSettings.add(newCS('AH_UDC_CreateCommunityUserUrl', 'String', PageGroupName, PageName, PageSectionName, 2, 'Chatter Url', 'This is the URL of the .net Core API for Community User Controller', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/CommunityUser', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_CreateCommunityUserTimeout', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Timeout for the Community User URL in Seconds', 'This determines how long the call to the API will wait.', '', '120', '1\r\n120', '', orgName));

         PageSectionName = 'Send Workbook - Chatter Notification Settings';
         defaultSettings.add(newCS('AH_UDC_WorkbookAccessedDefaultValue', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'When Workbook Accessed', 'This will determine if chatter notification need to be send when workbook is accessed by the user on community portal.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookCompletedDefaultValue', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'When Workbook Completed', 'This will determine if chatter notification need to be send when workbook is completed by the user on community portal.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookStepCompletedDefaultValue', 'Checkbox', PageGroupName, PageName, PageSectionName, 3, 'When Workbook Step Completed', 'This will determine if chatter notification need to be send when workbook step is completed by the user on community portal.', '', 'false', '', '', orgName));

         PageSectionName = 'Send Workbook Settings';
         defaultSettings.add(newCS('AH_UDC_AddContactLimit', 'Integer', PageGroupName, PageName, PageSectionName, 1, 'Max Contact Limit', 'This determines how many Contact users can add to document using the Send workbook page.', '', '5', '0\r\n10', '', orgName)); //max-min value updated as per discussion with Hardik

         PageSectionName = 'Custom Lookup settings';
         defaultSettings.add(newCS('AH_UDC_CustomLookupMaxRecordsAllowed', 'Integer', PageGroupName, PageName, PageSectionName, 1, 'Update Custom Lookup Maximum Records Allowed', 'This determines maximum records allow in custom lookup dialog.', '', '200', '0\r\n500', '', orgName)); //max-min value updated as per discussion with Hardik
         defaultSettings.add(newCS('AH_UDC_CustomLookupRecordsPerPage', 'Integer', PageGroupName, PageName, PageSectionName, 2, 'Update Custom Lookup Records Per Page', 'This determines Total records to display per page in custom lookup dialog.', '', '25', '25\r\n100', '', orgName));

         PageSectionName = 'ViewWorkbook Settings';
         defaultSettings.add(newCS('AH_UDC_ReturnToWelcomePageURL', 'String', PageGroupName, PageName, PageSectionName, 1, 'Return To Welcome Page URL', 'This is the URL to which the user is sent when clicking Return To Welcome Page.', '', '/customers/s/services?tabset-8bc76=1cb08', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_CollapsedMenuCirclesPerPage', 'Integer', PageGroupName, PageName, PageSectionName, 2, 'Collapsed Menu Number of Steps Shown', 'This determines the number of steps shown in the collapsed menu.', '', '10', '1\r\n100', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookNotificationDisplayInSeconds', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Notification Display Time in Seconds', 'This determines how long all notifications will be show.', '', '5', '1\r\n60', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookUpdateTimerIntervalInSeconds', 'Integer', PageGroupName, PageName, PageSectionName, 4, 'Update Timer Interval in Seconds', 'This determines how often the view workbook page will look for updates and chatter.', '', '60', '10\r\n600', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookTokenEncryptionKey', 'String', PageGroupName, PageName, PageSectionName, 5, 'Token Encryption Key', 'This is the key for encrypting the token sent to Forms; this should not be set manually.\r\nTo issue a new key set the value to empty and run the Initialize Settings.', '', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookTokenEncryption', 'Checkbox', PageGroupName, PageName, PageSectionName, 6, 'Encrypt Token', 'When checked the Token sent to the Form will be encrypted', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookDisplayConsoleLogMessages', 'Checkbox', PageGroupName, PageName, PageSectionName, 7, 'Display Console Log Messages', 'When checked console.log messages will be written to the browser', '', 'false', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookStartVideo', 'String', PageGroupName, PageName, PageSectionName, 8, 'Start Page Video', 'This is the HTML to the video that is shown on the View Workbook Start page.', '', '&nbsp;', '', '', orgName));

         PageSectionName = 'File Upload Settings';
         defaultSettings.add(newCS('AH_UDC_FileUploadMaximumFileCount', 'Integer', PageGroupName, PageName, PageSectionName, 1, 'Maximum number of files allowed for upload at one time', 'This determines how many files a user is allowed to select for upload.', '', '5', '1\r\n24', '', orgName));
         defaultSettings.add(newCS('AH_UDC_FileUploadAllowedExtensions', 'String', PageGroupName, PageName, PageSectionName, 2, 'Allowed extensions for file upload', 'This is a comma separatead list of the allowed file extensions.', '', 'TXT, BMP, JPEG, PNG,PDF, XLS, DOC, DOCX, XLSX, JPG, MSG, PPT, PPTX, GIF, SVG, EPS, CDR, ZIP', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_FileUploadMaximumSizeInMB', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Maximum individual file size in MB', 'This determines maximum file upload size in MB.', '', '21', '1\r\n21', '', orgName));
         defaultSettings.add(newCS('AH_UDC_FileUploadUrl', 'String', PageGroupName, PageName, PageSectionName, 4, 'File Upload URL', 'This is the URL to the REST API used for file upload.', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/FormUploadFile', '', '', orgName));

         PageSectionName = 'Data Management Settings';
         defaultSettings.add(newCS('AH_UDC_PurgeEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Purge Enabled', 'This determines if the purge will happen when the scheduled job runs; this relies on the job being sceduled.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeAllExceptMostRecentResponseForCompletedWorkbooks', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Purge all except most recent response for Completed/Locked Workbooks', 'When checked, purge all except most recent response for Completed/Locked workbooks. Setting will be used in scheduler job.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeResponseAfterNumberOfDaysForCompletedLockedWorkbooks', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Number of days after Workbook is locked until purged', 'This determines number of days after Workbook is locked until purged. Setting will be used in scheduler job.', '', '3', '1\r\n100', '', orgName)); //max 100 days
         defaultSettings.add(newCS('AH_UDC_NumberOfPriorWorkbookStepSentResponsesToKeep', 'Integer', PageGroupName, PageName, PageSectionName, 4, 'Number of prior Workbook Step Sent Responses to keep', 'This determines number of Prior Workbook Step Sent Responses to keep. Setting will be used in scheduler job.', '', '3', '2\r\n10', '', orgName)); //default value = 3, max 10 
         defaultSettings.add(newCS('AH_UDC_PurgeBatchSize', 'Integer', PageGroupName, PageName, PageSectionName, 5, 'Number Records in each Purge Batch', 'This determines number of records that will be sent to each Batch execution; this needs to be set appropriately to avoid governor issues.', '', '10', '1\r\n200', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeResponseBatchSize', 'Integer', PageGroupName, PageName, PageSectionName, 6, 'Number Records in each Purge Response Batch', 'This determines number of records that will be sent to each Batch execution; this needs to be set appropriately to avoid governor issues.', '', '10', '1\r\n200', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeRemoveScheduledJob', 'Method', PageGroupName, PageName, PageSectionName, 7, 'Remove Scheduled Job', 'This will remove the scheduled data maintenance job.', 'AH_UDC_InitializationHelper;SchedulePurgeJob;{"mode":"Remove"}', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeCron', 'String', PageGroupName, PageName, PageSectionName, 8, 'Purge Job CRON setting', 'This controls when the Purge job will run. NOTE: You must remove the job and reinitialize in order for this setting to take effect.', '', '0 0 2 * * ?', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeVerify', 'Method', PageGroupName, PageName, PageSectionName, 9, 'Verify Scheduled Job', 'This will verify the scheduled data maintenance job is scheduled and when it will run.', 'AH_UDC_InitializationHelper;SchedulePurgeJob;{"mode":"Verify"}', '', '', '', orgName));

         PageSectionName = 'Workbook Sent Email';
         defaultSettings.add(newCS('AH_UDC_WorkbookSentEmailEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Workbook Sent Email Enabled', 'This determines if the Workbook Sent Email job will send emails when the scheduled job runs; this relies on the job being sceduled.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookSentEmailOrgWideEmail', 'String', PageGroupName, PageName, PageSectionName, 2, 'Org Wide Email', 'This is the email address setup in Organization-Wide Addresses.', '', 'udcservice@amadeus.com', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookSentEmailBatchSize', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Number Records in each Workbook Sent Email Batch', 'This determines number of records that will be sent to each Batch execution; this needs to be set appropriately to avoid governor issues.', '', '10', '1\r\n200', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookSentEmailRemoveScheduledJob', 'Method', PageGroupName, PageName, PageSectionName, 4, 'Remove Scheduled Job', 'This will remove the scheduled job.', 'AH_UDC_InitializationHelper;ScheduleWorkbookSentEmailJob;{"mode":"Remove"}', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookSentEmailCron', 'String', PageGroupName, PageName, PageSectionName, 5, 'Purge Job CRON setting', 'This controls when the job will run. NOTE: You must remove the job and reinitialize in order for this setting to take effect.', '', '0 0 2 * * ?', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookSentEmailAdd', 'Method', PageGroupName, PageName, PageSectionName, 6, 'Add Scheduled Job', 'This will add the job if it is not already scheduled.', 'AH_UDC_InitializationHelper;ScheduleWorkbookSentEmailJob;{"mode":"Add"}', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookSentEmailVerify', 'Method', PageGroupName, PageName, PageSectionName, 7, 'Verify Scheduled Job', 'This will verify the job is scheduled and when it will run.', 'AH_UDC_InitializationHelper;ScheduleWorkbookSentEmailJob;{"mode":"Verify"}', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookSentEmailForceRun', 'Method', PageGroupName, PageName, PageSectionName, 8, 'Run Job', 'This will force the Workbook Sent Email job to run.', 'AH_UDC_InitializationHelper;ScheduleWorkbookSentEmailJob;{"mode":"Run"}', '', '', '', orgName));

         PageSectionName = 'Amadeus Custom Form Settings';
         defaultSettings.add(newCS('AH_UDC_APIUrl', 'String', PageGroupName, PageName, PageSectionName, 1, 'API URL to get/save form response data', 'This is the URL which will be used to get/save form response data.', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/AmadeusForm/', '', '', orgName));

         PageSectionName = 'Export Response URL';
         defaultSettings.add(newCS('AH_UDC_ExportUrl', 'String', PageGroupName, PageName, PageSectionName, 1, 'URL for response export', 'This is the URL which will be used to export response(s).', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/Export/{TOKEN}/{MODE}/{STEP}', '', '', orgName));

         //Page: Settings : Amadeus Technical Support
         PageGroupName = 'For Technical Support Use Only';
         PageName = 'Technical Support Settings';

         PageSectionName = 'Troubleshooting';
         string TroubleshootingDefaultValue = 'FALSE';
         if (Test.isRunningTest()) TroubleshootingDefaultValue = 'TRUE';
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES, 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Enable System.Debug logging', 'Turns on advanced troubleshooting logging, when DEBUG LOGGING in Salesforce is enabled for one or more users. This will generate large log files and should be used sparingly', '', TroubleshootingDefaultValue, '', '', orgName));

         //Page: Settings : Logging Settings
         PageGroupName = 'Logging Settings';
         PageName = 'Logging Settings';
         PageSectionName = 'Log Entries to Create';

         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_TRACES, 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Write TRACES to the Log', 'When a TRACE message is generated by the application, write the message the Log__c object', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_WARNINGS, 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Write WARNINGS to the Log', 'When a WARNING message is generated by the application, write the message the Log__c object', '', 'TRUE', 'TRUE\r\nFALSE', '', orgName));
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_ERRORS, 'Checkbox', PageGroupName, PageName, PageSectionName, 3, 'Write ERRORS to the Log', 'When an ERROR message is generated by the application, write the message the Log__c object', '', 'TRUE', 'TRUE\r\nFALSE', '', orgName));
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_EXCEPTIONS, 'Checkbox', PageGroupName, PageName, PageSectionName, 4, 'Write EXCEPTIONS to the Log', 'When an EXCEPTION message is generated by the application, write the message the Log__c object', '', 'TRUE', 'TRUE\r\nFALSE', '', orgName));
         PageSectionName = 'Log Entries to Email';
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_WARNINGS, 'Checkbox', PageGroupName, PageName, PageSectionName, 10, 'Email logged WARNINGS', 'When a WARNING message is logged, should an email be sent to the Email Log Recipient(s)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_ERRORS, 'Checkbox', PageGroupName, PageName, PageSectionName, 11, 'Email logged ERRORS', 'When an ERROR message is logged, should an email be sent to the Email Log Recipient(s)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_EXCEPTIONS, 'Checkbox', PageGroupName, PageName, PageSectionName, 12, 'Email logged EXCEPTIONS', 'When an EXCEPTION message is logged, should an email be sent to the Email Log Recipient(s)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
         PageSectionName = 'Recipient(s) for Log Emails';
         string emails = '';
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_RECIPIENTS, 'String', PageGroupName, PageName, PageSectionName, 8, 'Email Log Recipient(s)', 'Comma-separated list of email addresses to which logs that are emailed will be sent', '', emails, '', '', orgName));

         //Page: Settings : Debug Settings
         if (!isProdOrg()) {
            PageGroupName = 'Unit Test Settings';
            PageName = 'Unit Test Settings';

            PageSectionName = 'UDC User';
            defaultSettings.add(newCS('AH_UDC_UnitTestUDCUsersLoadingError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force UDC Users Load Error', 'Forces an error on the Loading of the UDC Users page.', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestUDCUsersGrantError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force UDC Users Grant Error', 'Forces an error on the UDC Users page when Granting a permission set.', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestUDCUsersRevokeError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force UDC Users Revoke Error', 'Forces an error on the UDC Users page when Revoking a permission set.', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'Community User';
            defaultSettings.add(newCS('AH_UDC_UnitTestChangeCommunityUserProfile', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Community User Profile Change Error', 'Forces an error anywhere in the code that a Community User\'s Profile is being changed (e.g. When a new Community User confirms opt into Chatter)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'ChangeUserProfileToChatter';
            defaultSettings.add(newCS('AH_UDC_UnitTestSetCommunityUserProfileHttpNon200Error', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Community User Profile Change HTTP Error', 'Forces an error anywhere in the code that a Community User\'s Profile is being changed (e.g. When a new Community User confirms opt into Chatter)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestSetCommunityUserProfileRespNon200Error', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Community User Profile Change Response Error', 'Forces an error anywhere in the code that a Community User\'s Profile is being changed (e.g. When a new Community User confirms opt into Chatter)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'Send Workbook';
            defaultSettings.add(newCS('AH_UDC_UnitTestSendWorkbookError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Send Workbook Error', 'Forces an error on the sending of a Workbook', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceSendWorkbookCreateCommunityUserException', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Send Workbook Create Community User Exception', 'Forces an exception on the creating of the community user', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'Release Workbook';
            defaultSettings.add(newCS('AH_UDC_UnitTestForceReleaseWorkbookSendToContactsException', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Release Workbook Send to Contacts Exception', 'Forces an exception on the creating of the community user and sending of emails', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'View Help';
            defaultSettings.add(newCS('AH_UDC_UnitTestForceViewHelpError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force View Help Load Error', 'Forces an error on the load of the View Help page', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'View Workbook';
            defaultSettings.add(newCS('AH_UDC_UnitTestForceViewWorkbookLoadError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force View Workbook Load Error', 'Forces an error on the load of the View Workbook page', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceViewWorkbookRefreshError', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Force View Workbook Refresh Error', 'Forces an error on the refresh of the View Workbook page', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceViewWorkbookFileUploadStepInProgressError', 'Checkbox', PageGroupName, PageName, PageSectionName, 3, 'Force View Workbook File Upload Set Step In Progress Error', 'Forces an error when the File Upload tries to set the step status to In Progress', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'File Upload';
            defaultSettings.add(newCS('AH_UDC_UnitTestForceFileUploadError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force File Upload Error', 'Forces an error during file upload', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceFileDeleteError', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Force File Delete Error', 'Forces an error during file delete', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'Workbook Archive';
            defaultSettings.add(newCS('AH_UDC_UnitTestForceArchivePageLoadError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Archive Page Load Error', 'Forces an error during Archive page load', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceArchiveError', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Force Archive Error', 'Forces an error during archive', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'Custom Lookup Dialog';
            defaultSettings.add(newCS('AH_UDC_UnitTestForceCustomLookupDialogPageLoadError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Custom Lookup Dialog Page Load Error', 'Forces an error during Custom Lookup Dialog page load', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceProjectLookupDialogeError', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Force Project Lookup Dialog Error', 'Forces an error during Project Lookup  Dialog', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
         }

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

   Private static string SchedulePurgeJob(string mode) {
      List<CronTrigger> jobs = AH_UDC_SystemContext.query('SELECT Id,NextFireTime FROM CronTrigger where cronjobdetail.name = \'' + AH_UDC_Constants.PURGE_SCHEDULED_JOB_NAME + '\'');
      if (mode.toLowerCase() == 'remove') {
         if (jobs.size() == 0) return 'The Purge job is currently not scheduled';
         System.abortJob(jobs[0].id);
         return 'Scheduled Purge job was removed';
      }
      if (mode.toLowerCase() == 'add') {
         if (jobs.size() > 0) return 'The Purge job is already scheduled';
         String cronStr = AH_UDC_ConfigHelper.GetString('AH_UDC_PurgeCron', '0 0 2 * * ?'); //Default is class runs every day at 2 AM
         String jobID = System.schedule(AH_UDC_Constants.PURGE_SCHEDULED_JOB_NAME, cronStr, new AH_UDC_DataMaintenance_Schedule());
         return 'Scheduled Purge job was added';
      }
      if (mode.toLowerCase() == 'verify') {
         if (jobs.size() == 0) return 'The Purge job is currently not scheduled';
         return 'Scheduled Purge job will run at: ' + jobs[0].NextFireTime.format();
      }
      return 'SchedulePurgeJob, unkown mode: ' + mode;
   }

   Private static string ScheduleWorkbookSentEmailJob(string mode) {
      List<CronTrigger> jobs = AH_UDC_SystemContext.query('SELECT Id,NextFireTime FROM CronTrigger where cronjobdetail.name = \'' + AH_UDC_Constants.WORKBOOK_SENT_EMAIL_SCHEDULED_JOB_NAME + '\'');
      if (mode.toLowerCase() == 'remove') {
         if (jobs.size() == 0) return 'The Workbook Sent Email job is currently not scheduled';
         System.abortJob(jobs[0].id);
         return 'Scheduled Workbook Sent Email job was removed';
      }
      if (mode.toLowerCase() == 'add') {
         if (jobs.size() > 0) return 'The Workbook Sent Email job is already scheduled';
         String cronStr = AH_UDC_ConfigHelper.GetString('AH_UDC_WorkbookSentEmailCron', '0 0 2 * * ?'); //Default is class runs every day at 2 AM
         String jobID = System.schedule(AH_UDC_Constants.WORKBOOK_SENT_EMAIL_SCHEDULED_JOB_NAME, cronStr, new AH_UDC_WorkbookSentEmail_Schedule());
         return 'Scheduled Workbook Sent Email job was added';
      }
      if (mode.toLowerCase() == 'verify') {
         if (jobs.size() == 0) return 'The Workbook Sent Email job is currently not scheduled';
         return 'Scheduled Workbook Sent Email job will run at: ' + jobs[0].NextFireTime.format();
      }
      if (mode.toLowerCase() == 'run') {
         //Get the size of the batch to run
         Integer MAX_BATCH_SIZE = AH_UDC_ConfigHelper.GetInteger('AH_UDC_WorkbookSentEmailBatchSize',10);
         //Start the Batch
         AH_UDC_WorkbookSentEmail_Batch wbSentEmailBatch = new AH_UDC_WorkbookSentEmail_Batch();
         database.executebatch(wbSentEmailBatch, MAX_BATCH_SIZE);
         return 'Workbook Sent Email job will run now. Please use the log to verify when the job is finished.';
      }
      return 'ScheduleWorkbookSentEmailJob, unkown mode: ' + mode;
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
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
         when 'SchedulePurgeJob' {
            return SchedulePurgeJob((String) args.get('mode'));
         }
         when 'ScheduleWorkbookSentEmailJob' {
            return ScheduleWorkbookSentEmailJob((String) args.get('mode'));
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
      System.Debug('mode: ' + mode); //DO NOT change this to LogHelper

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
         List<AH_UDC_ConfigurationSetting__c> csSettings = [select id from AH_UDC_ConfigurationSetting__c where Name = :AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES];
         if (csSettings.size() ==0) insert new AH_UDC_ConfigurationSetting__c(Name = AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES, SettingType__c = 'Checkbox', AH_UDC__c = true, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName, DisplayOrder__c = 1, SettingDisplayName__c = 'Enable System.Debug logging', SettingHelpText__c = 'Turns on advanced troubleshooting logging, when DEBUG LOGGING in Salesforce is enabled for one or more users. This will generate large log files and should be used sparingly', SettingValue__c = '', SettingValueDefault__c = 'FALSE', SettingValueDomain__c = '', UsedBy__c = '', OrgName__c = orgName);
         AH_UDC_ConfigHelper.SetValue(AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES,FALSE);
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

   private static Boolean isProdOrg() {
      // This is the Amadeus Org's Production Org Id
      return '00D300000006CtnEAE' == Userinfo.getOrganizationId();
   }

   private static AH_UDC_ConfigurationSetting__c newCS(string CSName, string SettingType, string PageGroupName, string PageName, string PageSectionName,
                                                       integer DisplayOrder, string SettingDisplayName, string SettingHelpText, string SettingValue,
                                                       string SettingValueDefault, string SettingValueDomain, string UsedBy, string OrgName) {
      return new AH_UDC_ConfigurationSetting__c(AH_UDC__c = true,
                                                Name = CSName, SettingType__c = SettingType, PageGroupName__c = PageGroupName, PageName__c = PageName, PageSectionName__c = PageSectionName,
                                                DisplayOrder__c = DisplayOrder, SettingDisplayName__c = SettingDisplayName, SettingHelpText__c = SettingHelpText, SettingValue__c = SettingValue,
                                                SettingValueDefault__c = SettingValueDefault, SettingValueDomain__c = SettingValueDomain, UsedBy__c = UsedBy, OrgName__c = OrgName);
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
         defaultSettings.add(newCS('Initialize', 'GroupPage', PageGroupName, PageName, '', 1, 'Initialize Settings', 'Initialize AH_UDC Settings', '', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC Settings', 'GroupPage', PageGroupName, PageName, '', 2, 'UDC Settings', 'UDC Settings', '', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_UsersPage', 'Page', PageGroupName, PageName, '', 3, 'UDC Users', 'Add/Remove UDC Permission Set on Users', '', 'apex/AH_UDC_Users', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_Logging', 'GroupPage', PageGroupName, PageName, '', 4, 'Logging Settings', 'Logging Settings', '', '', '', '', orgName));
         if (!isProdOrg()) defaultSettings.add(newCS('AH_UDC_UnitTest', 'GroupPage', PageGroupName, PageName, '', 5, 'Unit Test Settings', 'Unit Test Settings', '', '', '', '', orgName));
         defaultSettings.add(newCS('AmadeusTechnicalSupportSettings', 'GroupPage', PageGroupName, PageName, PageSectionName, 80, 'Technical Support Settings', AH_UDC_LabelHelper.ReplaceParametersInValue('Contains settings that should only be adjusted by UDC Technical Support. Invalid changes may cause {!ApplicationName} to stop functioning'), '', '', '', '', orgName));

         PageName = 'Initialize Settings';
         PageSectionName = 'Initialize';
         defaultSettings.add(newCS('Init_All', 'Method', PageGroupName, PageName, PageSectionName, 1, 'Initialize All', 'This will initialize all AH_UDC Objects and ConfigurationSettings, creating any ConfigurationSettings that are missing or updating them as required [Non-destructive]', 'AH_UDC_InitializationHelper;Initialize;{"mode":"All"}', 'AH_UDC_InitializationHelper;Initialize;{"mode":"All"}', '', '', orgName));
         defaultSettings.add(newCS('Init_ConfigurationSettings', 'Method', PageGroupName, PageName, PageSectionName, 2, 'Initialize Configuration Settings', 'This will initialize only the ConfigurationSettings, creating any ConfigurationSettings that are missing or updating them as required [Non-destructive]', 'AH_UDC_InitializationHelper;Initialize;{"mode":"ConfigurationSettings"}', 'AH_UDC_InitializationHelper;Initialize;{"mode":"ConfigurationSettings"}', '', '', orgName));

         //Page: General : UDC Settings
         PageName = 'UDC Settings';
         PageSectionName = 'System Status';
         defaultSettings.add(newCS('AH_UDC_SendWorkbookEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Send Workbook Enabled', 'Use this to stop users from sending workbooks.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_SendWorkbookDisabledMessage', 'String', PageGroupName, PageName, PageSectionName, 2, 'Send Workbook Disabled Message', 'When sending is disabled, this is the message users will be shown when they try to send a workbook.', '', 'UDC is undergoing maintenance and sending workbooks is disabled; please check back later.', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_CommunityEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 3, 'Community Enabled', 'Use this to stop community users from viewing workbooks.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_CommunityDisabledMessage', 'String', PageGroupName, PageName, PageSectionName, 4, 'Community Disabled Message', 'When Community is disabled, this is the message users will be shown when they try to view a workbook.', '', 'The system is currently offline for maintenance; please check back later.', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 5, 'View Workbook Enabled', 'Use this to stop Amadeus users from viewing workbooks.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookDisabledMessage', 'String', PageGroupName, PageName, PageSectionName, 6, 'View Workbook Disabled Message', 'When viewing is disabled, this is the message users will be shown when they try to view a workbook.', '', 'The system is currently offline for maintenance; please check back later.', '', '', orgName));

         PageSectionName = 'Email Template Settings';
         defaultSettings.add(newCS('AH_UDC_EmailTemplatePortalUrlPlaceholder', 'String', PageGroupName, PageName, PageSectionName, 1, 'Community Portal URL Placeholder', 'This is the string to search for in email templates; it will be replaced with the real portal url (another configuration setting)', '', 'https://udcsb-amadeus-community.cs19.force.com/customers/s/', '', '', orgName));

         PageSectionName = 'Community Portal';
         defaultSettings.add(newCS('AH_UDC_CommunityPortalUrl', 'String', PageGroupName, PageName, PageSectionName, 1, 'Community Portal Url', 'This is the URL for the Community Portal', '', 'https://udcsb-amadeus-community.cs19.force.com/customers/s/', '', '', orgName));

         PageSectionName = 'Profiles';
         defaultSettings.add(newCS(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER, 'String', PageGroupName, PageName, PageSectionName, 1, 'Community Profile With Chatter', 'This is the profile used when creating community users who agree to chatter', '', 'AH Customer Community Plus Login User', '', '', orgName));
         defaultSettings.add(newCS(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITHOUT_CHATTER, 'String', PageGroupName, PageName, PageSectionName, 2, 'Community Profile No Chatter', 'This is the profile used when creating community users who do not agree to chatter', '', 'AH Customer Community Plus Login - No Chatter', '', '', orgName));

         PageSectionName = 'Permission Sets';
         defaultSettings.add(newCS('AH_UDC_PermissionSetCommunityUser', 'String', PageGroupName, PageName, PageSectionName, 1, 'Permission Set for Community User (API Name)', 'This is the API Name of the permission set assigned to community users that will be using UDC', '', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PermissionSetUDCSystemAdministrator', 'String', PageGroupName, PageName, PageSectionName, 2, 'Permission Set for UDC System Administrator User (API Name)', 'This is the API Name of the permission set assigned to UDC System Administrator users that will be using UDC', '', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PermissionSetWorkbookAdministrator', 'String', PageGroupName, PageName, PageSectionName, 3, 'Permission Set for Workbook Administrator User (API Name)', 'This is the API Name of the permission set assigned to Workbook Administrator users that will be using UDC', '', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PermissionSetWorkbookUser', 'String', PageGroupName, PageName, PageSectionName, 4, 'Permission Set for Workbook User (API Name)', 'This is the API Name of the permission set assigned to Workbook SUers that will be using UDC', '', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, '', '', orgName));

         PageSectionName = 'Send Workbook - Create Community User Settings';
         defaultSettings.add(newCS('AH_UDC_CreateCommunityUserEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Create Community User(s) When Sending Workbook', 'This determines if community users will be created when sending workbooks.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_CreateCommunityUserOrgPrefix', 'String', PageGroupName, PageName, PageSectionName, 2, 'Org Name to Append To End Of User Name', 'This is the prefix of the org that should be applied to the end of any user names created (ex. ".UDCSB")', '', '', '', '', orgName)); //DO NOT set a default value on this since the production value needs to be blank
         defaultSettings.add(newCS('AH_UDC_CommunityUserNamePostfix', 'String', PageGroupName, PageName, PageSectionName, 3, 'Community User Name Postfix', 'This is the Comunity postfix applied to the end of any user names created', '', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX, '', '', orgName));

         PageSectionName = 'Update Community User Profile Settings';
         defaultSettings.add(newCS('AH_UDC_CommunityUserProfileUpdateEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Allow updating of commuity user profile to With Chatter profile', 'This determines if the system is allowed to change a community user\'s profile to the profile that allows chatter.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_SetCommunityUserProfileUrl', 'String', PageGroupName, PageName, PageSectionName, 2, 'Set Community User Profile Url', 'This is the URL of the .net Core API for CommunityUserProfile Controller', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/CommunityUserProfile', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_SetCommunityUserProfileTimeout', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Timeout for the URL in Seconds', 'This determines how long the call to the API will wait.', '', '120', '1\r\n120', '', orgName));

         PageSectionName = 'Chatter';
         defaultSettings.add(newCS('AH_UDC_ChatterUrl', 'String', PageGroupName, PageName, PageSectionName, 2, 'Chatter Url', 'This is the URL of the .net Core API for Chatter Controller', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/Chatter', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ChatterTimeout', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Timeout for the Chatter URL in Seconds', 'This determines how long the call to the API will wait.', '', '120', '1\r\n120', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ChatterPostMaxLength', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Max Post Length', 'This determines how many characters are allowed in the chatter post.', '', '2000', '1\r\n5000', '', orgName));

         PageSectionName = 'CreateCommunityUser';
         defaultSettings.add(newCS('AH_UDC_CreateCommunityUserUrl', 'String', PageGroupName, PageName, PageSectionName, 2, 'Chatter Url', 'This is the URL of the .net Core API for Community User Controller', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/CommunityUser', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_CreateCommunityUserTimeout', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Timeout for the Community User URL in Seconds', 'This determines how long the call to the API will wait.', '', '120', '1\r\n120', '', orgName));

         PageSectionName = 'Send Workbook - Chatter Notification Settings';
         defaultSettings.add(newCS('AH_UDC_WorkbookAccessedDefaultValue', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'When Workbook Accessed', 'This will determine if chatter notification need to be send when workbook is accessed by the user on community portal.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookCompletedDefaultValue', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'When Workbook Completed', 'This will determine if chatter notification need to be send when workbook is completed by the user on community portal.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookStepCompletedDefaultValue', 'Checkbox', PageGroupName, PageName, PageSectionName, 3, 'When Workbook Step Completed', 'This will determine if chatter notification need to be send when workbook step is completed by the user on community portal.', '', 'false', '', '', orgName));

         PageSectionName = 'Send Workbook Settings';
         defaultSettings.add(newCS('AH_UDC_AddContactLimit', 'Integer', PageGroupName, PageName, PageSectionName, 1, 'Max Contact Limit', 'This determines how many Contact users can add to document using the Send workbook page.', '', '5', '0\r\n10', '', orgName)); //max-min value updated as per discussion with Hardik

         PageSectionName = 'Custom Lookup settings';
         defaultSettings.add(newCS('AH_UDC_CustomLookupMaxRecordsAllowed', 'Integer', PageGroupName, PageName, PageSectionName, 1, 'Update Custom Lookup Maximum Records Allowed', 'This determines maximum records allow in custom lookup dialog.', '', '200', '0\r\n500', '', orgName)); //max-min value updated as per discussion with Hardik
         defaultSettings.add(newCS('AH_UDC_CustomLookupRecordsPerPage', 'Integer', PageGroupName, PageName, PageSectionName, 2, 'Update Custom Lookup Records Per Page', 'This determines Total records to display per page in custom lookup dialog.', '', '25', '25\r\n100', '', orgName));

         PageSectionName = 'ViewWorkbook Settings';
         defaultSettings.add(newCS('AH_UDC_ReturnToWelcomePageURL', 'String', PageGroupName, PageName, PageSectionName, 1, 'Return To Welcome Page URL', 'This is the URL to which the user is sent when clicking Return To Welcome Page.', '', '/customers/s/services?tabset-8bc76=1cb08', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_CollapsedMenuCirclesPerPage', 'Integer', PageGroupName, PageName, PageSectionName, 2, 'Collapsed Menu Number of Steps Shown', 'This determines the number of steps shown in the collapsed menu.', '', '10', '1\r\n100', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookNotificationDisplayInSeconds', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Notification Display Time in Seconds', 'This determines how long all notifications will be show.', '', '5', '1\r\n60', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookUpdateTimerIntervalInSeconds', 'Integer', PageGroupName, PageName, PageSectionName, 4, 'Update Timer Interval in Seconds', 'This determines how often the view workbook page will look for updates and chatter.', '', '60', '10\r\n600', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookTokenEncryptionKey', 'String', PageGroupName, PageName, PageSectionName, 5, 'Token Encryption Key', 'This is the key for encrypting the token sent to Forms; this should not be set manually.\r\nTo issue a new key set the value to empty and run the Initialize Settings.', '', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookTokenEncryption', 'Checkbox', PageGroupName, PageName, PageSectionName, 6, 'Encrypt Token', 'When checked the Token sent to the Form will be encrypted', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookDisplayConsoleLogMessages', 'Checkbox', PageGroupName, PageName, PageSectionName, 7, 'Display Console Log Messages', 'When checked console.log messages will be written to the browser', '', 'false', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_ViewWorkbookStartVideo', 'String', PageGroupName, PageName, PageSectionName, 8, 'Start Page Video', 'This is the HTML to the video that is shown on the View Workbook Start page.', '', '&nbsp;', '', '', orgName));

         PageSectionName = 'File Upload Settings';
         defaultSettings.add(newCS('AH_UDC_FileUploadMaximumFileCount', 'Integer', PageGroupName, PageName, PageSectionName, 1, 'Maximum number of files allowed for upload at one time', 'This determines how many files a user is allowed to select for upload.', '', '5', '1\r\n24', '', orgName));
         defaultSettings.add(newCS('AH_UDC_FileUploadAllowedExtensions', 'String', PageGroupName, PageName, PageSectionName, 2, 'Allowed extensions for file upload', 'This is a comma separatead list of the allowed file extensions.', '', 'TXT, BMP, JPEG, PNG,PDF, XLS, DOC, DOCX, XLSX, JPG, MSG, PPT, PPTX, GIF, SVG, EPS, CDR, ZIP', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_FileUploadMaximumSizeInMB', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Maximum individual file size in MB', 'This determines maximum file upload size in MB.', '', '21', '1\r\n21', '', orgName));
         defaultSettings.add(newCS('AH_UDC_FileUploadUrl', 'String', PageGroupName, PageName, PageSectionName, 4, 'File Upload URL', 'This is the URL to the REST API used for file upload.', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/FormUploadFile', '', '', orgName));

         PageSectionName = 'Data Management Settings';
         defaultSettings.add(newCS('AH_UDC_PurgeEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Purge Enabled', 'This determines if the purge will happen when the scheduled job runs; this relies on the job being sceduled.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeAllExceptMostRecentResponseForCompletedWorkbooks', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Purge all except most recent response for Completed/Locked Workbooks', 'When checked, purge all except most recent response for Completed/Locked workbooks. Setting will be used in scheduler job.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeResponseAfterNumberOfDaysForCompletedLockedWorkbooks', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Number of days after Workbook is locked until purged', 'This determines number of days after Workbook is locked until purged. Setting will be used in scheduler job.', '', '3', '1\r\n100', '', orgName)); //max 100 days
         defaultSettings.add(newCS('AH_UDC_NumberOfPriorWorkbookStepSentResponsesToKeep', 'Integer', PageGroupName, PageName, PageSectionName, 4, 'Number of prior Workbook Step Sent Responses to keep', 'This determines number of Prior Workbook Step Sent Responses to keep. Setting will be used in scheduler job.', '', '3', '2\r\n10', '', orgName)); //default value = 3, max 10 
         defaultSettings.add(newCS('AH_UDC_PurgeBatchSize', 'Integer', PageGroupName, PageName, PageSectionName, 5, 'Number Records in each Purge Batch', 'This determines number of records that will be sent to each Batch execution; this needs to be set appropriately to avoid governor issues.', '', '10', '1\r\n200', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeResponseBatchSize', 'Integer', PageGroupName, PageName, PageSectionName, 6, 'Number Records in each Purge Response Batch', 'This determines number of records that will be sent to each Batch execution; this needs to be set appropriately to avoid governor issues.', '', '10', '1\r\n200', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeRemoveScheduledJob', 'Method', PageGroupName, PageName, PageSectionName, 7, 'Remove Scheduled Job', 'This will remove the scheduled data maintenance job.', 'AH_UDC_InitializationHelper;SchedulePurgeJob;{"mode":"Remove"}', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeCron', 'String', PageGroupName, PageName, PageSectionName, 8, 'Purge Job CRON setting', 'This controls when the Purge job will run. NOTE: You must remove the job and reinitialize in order for this setting to take effect.', '', '0 0 2 * * ?', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_PurgeVerify', 'Method', PageGroupName, PageName, PageSectionName, 9, 'Verify Scheduled Job', 'This will verify the scheduled data maintenance job is scheduled and when it will run.', 'AH_UDC_InitializationHelper;SchedulePurgeJob;{"mode":"Verify"}', '', '', '', orgName));

         PageSectionName = 'Workbook Sent Email';
         defaultSettings.add(newCS('AH_UDC_WorkbookSentEmailEnabled', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Workbook Sent Email Enabled', 'This determines if the Workbook Sent Email job will send emails when the scheduled job runs; this relies on the job being sceduled.', '', 'true', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookSentEmailOrgWideEmail', 'String', PageGroupName, PageName, PageSectionName, 2, 'Org Wide Email', 'This is the email address setup in Organization-Wide Addresses.', '', 'udcservice@amadeus.com', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookSentEmailBatchSize', 'Integer', PageGroupName, PageName, PageSectionName, 3, 'Number Records in each Workbook Sent Email Batch', 'This determines number of records that will be sent to each Batch execution; this needs to be set appropriately to avoid governor issues.', '', '10', '1\r\n200', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookSentEmailRemoveScheduledJob', 'Method', PageGroupName, PageName, PageSectionName, 4, 'Remove Scheduled Job', 'This will remove the scheduled job.', 'AH_UDC_InitializationHelper;ScheduleWorkbookSentEmailJob;{"mode":"Remove"}', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookSentEmailCron', 'String', PageGroupName, PageName, PageSectionName, 5, 'Purge Job CRON setting', 'This controls when the job will run. NOTE: You must remove the job and reinitialize in order for this setting to take effect.', '', '0 0 2 * * ?', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookSentEmailAdd', 'Method', PageGroupName, PageName, PageSectionName, 6, 'Add Scheduled Job', 'This will add the job if it is not already scheduled.', 'AH_UDC_InitializationHelper;ScheduleWorkbookSentEmailJob;{"mode":"Add"}', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookSentEmailVerify', 'Method', PageGroupName, PageName, PageSectionName, 7, 'Verify Scheduled Job', 'This will verify the job is scheduled and when it will run.', 'AH_UDC_InitializationHelper;ScheduleWorkbookSentEmailJob;{"mode":"Verify"}', '', '', '', orgName));
         defaultSettings.add(newCS('AH_UDC_WorkbookSentEmailForceRun', 'Method', PageGroupName, PageName, PageSectionName, 8, 'Run Job', 'This will force the Workbook Sent Email job to run.', 'AH_UDC_InitializationHelper;ScheduleWorkbookSentEmailJob;{"mode":"Run"}', '', '', '', orgName));

         PageSectionName = 'Amadeus Custom Form Settings';
         defaultSettings.add(newCS('AH_UDC_APIUrl', 'String', PageGroupName, PageName, PageSectionName, 1, 'API URL to get/save form response data', 'This is the URL which will be used to get/save form response data.', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/AmadeusForm/', '', '', orgName));

         PageSectionName = 'Export Response URL';
         defaultSettings.add(newCS('AH_UDC_ExportUrl', 'String', PageGroupName, PageName, PageSectionName, 1, 'URL for response export', 'This is the URL which will be used to export response(s).', '', 'https://staging-mbrfp.meetingbroker.com/AmadeusHospitality/UnifiedDataCollection/FormToSalesforceUDCSB/Export/{TOKEN}/{MODE}/{STEP}', '', '', orgName));

         //Page: Settings : Amadeus Technical Support
         PageGroupName = 'For Technical Support Use Only';
         PageName = 'Technical Support Settings';

         PageSectionName = 'Troubleshooting';
         string TroubleshootingDefaultValue = 'FALSE';
         if (Test.isRunningTest()) TroubleshootingDefaultValue = 'TRUE';
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_DEBUG_MESSAGES, 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Enable System.Debug logging', 'Turns on advanced troubleshooting logging, when DEBUG LOGGING in Salesforce is enabled for one or more users. This will generate large log files and should be used sparingly', '', TroubleshootingDefaultValue, '', '', orgName));

         //Page: Settings : Logging Settings
         PageGroupName = 'Logging Settings';
         PageName = 'Logging Settings';
         PageSectionName = 'Log Entries to Create';

         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_TRACES, 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Write TRACES to the Log', 'When a TRACE message is generated by the application, write the message the Log__c object', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_WARNINGS, 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Write WARNINGS to the Log', 'When a WARNING message is generated by the application, write the message the Log__c object', '', 'TRUE', 'TRUE\r\nFALSE', '', orgName));
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_ERRORS, 'Checkbox', PageGroupName, PageName, PageSectionName, 3, 'Write ERRORS to the Log', 'When an ERROR message is generated by the application, write the message the Log__c object', '', 'TRUE', 'TRUE\r\nFALSE', '', orgName));
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_LOG_EXCEPTIONS, 'Checkbox', PageGroupName, PageName, PageSectionName, 4, 'Write EXCEPTIONS to the Log', 'When an EXCEPTION message is generated by the application, write the message the Log__c object', '', 'TRUE', 'TRUE\r\nFALSE', '', orgName));
         PageSectionName = 'Log Entries to Email';
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_WARNINGS, 'Checkbox', PageGroupName, PageName, PageSectionName, 10, 'Email logged WARNINGS', 'When a WARNING message is logged, should an email be sent to the Email Log Recipient(s)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_ERRORS, 'Checkbox', PageGroupName, PageName, PageSectionName, 11, 'Email logged ERRORS', 'When an ERROR message is logged, should an email be sent to the Email Log Recipient(s)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_EXCEPTIONS, 'Checkbox', PageGroupName, PageName, PageSectionName, 12, 'Email logged EXCEPTIONS', 'When an EXCEPTION message is logged, should an email be sent to the Email Log Recipient(s)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
         PageSectionName = 'Recipient(s) for Log Emails';
         string emails = '';
         defaultSettings.add(newCS(AH_UDC_LogHelper.CONFIG_KEY_LOG_SETTINGS_EMAIL_RECIPIENTS, 'String', PageGroupName, PageName, PageSectionName, 8, 'Email Log Recipient(s)', 'Comma-separated list of email addresses to which logs that are emailed will be sent', '', emails, '', '', orgName));

         //Page: Settings : Debug Settings
         if (!isProdOrg()) {
            PageGroupName = 'Unit Test Settings';
            PageName = 'Unit Test Settings';

            PageSectionName = 'UDC User';
            defaultSettings.add(newCS('AH_UDC_UnitTestUDCUsersLoadingError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force UDC Users Load Error', 'Forces an error on the Loading of the UDC Users page.', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestUDCUsersGrantError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force UDC Users Grant Error', 'Forces an error on the UDC Users page when Granting a permission set.', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestUDCUsersRevokeError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force UDC Users Revoke Error', 'Forces an error on the UDC Users page when Revoking a permission set.', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'Community User';
            defaultSettings.add(newCS('AH_UDC_UnitTestChangeCommunityUserProfile', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Community User Profile Change Error', 'Forces an error anywhere in the code that a Community User\'s Profile is being changed (e.g. When a new Community User confirms opt into Chatter)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'ChangeUserProfileToChatter';
            defaultSettings.add(newCS('AH_UDC_UnitTestSetCommunityUserProfileHttpNon200Error', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Community User Profile Change HTTP Error', 'Forces an error anywhere in the code that a Community User\'s Profile is being changed (e.g. When a new Community User confirms opt into Chatter)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestSetCommunityUserProfileRespNon200Error', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Community User Profile Change Response Error', 'Forces an error anywhere in the code that a Community User\'s Profile is being changed (e.g. When a new Community User confirms opt into Chatter)', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'Send Workbook';
            defaultSettings.add(newCS('AH_UDC_UnitTestSendWorkbookError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Send Workbook Error', 'Forces an error on the sending of a Workbook', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceSendWorkbookCreateCommunityUserException', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Send Workbook Create Community User Exception', 'Forces an exception on the creating of the community user', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'Release Workbook';
            defaultSettings.add(newCS('AH_UDC_UnitTestForceReleaseWorkbookSendToContactsException', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Release Workbook Send to Contacts Exception', 'Forces an exception on the creating of the community user and sending of emails', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'View Help';
            defaultSettings.add(newCS('AH_UDC_UnitTestForceViewHelpError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force View Help Load Error', 'Forces an error on the load of the View Help page', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'View Workbook';
            defaultSettings.add(newCS('AH_UDC_UnitTestForceViewWorkbookLoadError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force View Workbook Load Error', 'Forces an error on the load of the View Workbook page', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceViewWorkbookRefreshError', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Force View Workbook Refresh Error', 'Forces an error on the refresh of the View Workbook page', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceViewWorkbookFileUploadStepInProgressError', 'Checkbox', PageGroupName, PageName, PageSectionName, 3, 'Force View Workbook File Upload Set Step In Progress Error', 'Forces an error when the File Upload tries to set the step status to In Progress', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'File Upload';
            defaultSettings.add(newCS('AH_UDC_UnitTestForceFileUploadError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force File Upload Error', 'Forces an error during file upload', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceFileDeleteError', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Force File Delete Error', 'Forces an error during file delete', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'Workbook Archive';
            defaultSettings.add(newCS('AH_UDC_UnitTestForceArchivePageLoadError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Archive Page Load Error', 'Forces an error during Archive page load', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceArchiveError', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Force Archive Error', 'Forces an error during archive', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));

            PageSectionName = 'Custom Lookup Dialog';
            defaultSettings.add(newCS('AH_UDC_UnitTestForceCustomLookupDialogPageLoadError', 'Checkbox', PageGroupName, PageName, PageSectionName, 1, 'Force Custom Lookup Dialog Page Load Error', 'Forces an error during Custom Lookup Dialog page load', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
            defaultSettings.add(newCS('AH_UDC_UnitTestForceProjectLookupDialogeError', 'Checkbox', PageGroupName, PageName, PageSectionName, 2, 'Force Project Lookup Dialog Error', 'Forces an error during Project Lookup  Dialog', '', 'FALSE', 'TRUE\r\nFALSE', '', orgName));
         }

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

   Private static string SchedulePurgeJob(string mode) {
      List<CronTrigger> jobs = AH_UDC_SystemContext.query('SELECT Id,NextFireTime FROM CronTrigger where cronjobdetail.name = \'' + AH_UDC_Constants.PURGE_SCHEDULED_JOB_NAME + '\'');
      if (mode.toLowerCase() == 'remove') {
         if (jobs.size() == 0) return 'The Purge job is currently not scheduled';
         System.abortJob(jobs[0].id);
         return 'Scheduled Purge job was removed';
      }
      if (mode.toLowerCase() == 'add') {
         if (jobs.size() > 0) return 'The Purge job is already scheduled';
         String cronStr = AH_UDC_ConfigHelper.GetString('AH_UDC_PurgeCron', '0 0 2 * * ?'); //Default is class runs every day at 2 AM
         String jobID = System.schedule(AH_UDC_Constants.PURGE_SCHEDULED_JOB_NAME, cronStr, new AH_UDC_DataMaintenance_Schedule());
         return 'Scheduled Purge job was added';
      }
      if (mode.toLowerCase() == 'verify') {
         if (jobs.size() == 0) return 'The Purge job is currently not scheduled';
         return 'Scheduled Purge job will run at: ' + jobs[0].NextFireTime.format();
      }
      return 'SchedulePurgeJob, unkown mode: ' + mode;
   }

   Private static string ScheduleWorkbookSentEmailJob(string mode) {
      List<CronTrigger> jobs = AH_UDC_SystemContext.query('SELECT Id,NextFireTime FROM CronTrigger where cronjobdetail.name = \'' + AH_UDC_Constants.WORKBOOK_SENT_EMAIL_SCHEDULED_JOB_NAME + '\'');
      if (mode.toLowerCase() == 'remove') {
         if (jobs.size() == 0) return 'The Workbook Sent Email job is currently not scheduled';
         System.abortJob(jobs[0].id);
         return 'Scheduled Workbook Sent Email job was removed';
      }
      if (mode.toLowerCase() == 'add') {
         if (jobs.size() > 0) return 'The Workbook Sent Email job is already scheduled';
         String cronStr = AH_UDC_ConfigHelper.GetString('AH_UDC_WorkbookSentEmailCron', '0 0 2 * * ?'); //Default is class runs every day at 2 AM
         String jobID = System.schedule(AH_UDC_Constants.WORKBOOK_SENT_EMAIL_SCHEDULED_JOB_NAME, cronStr, new AH_UDC_WorkbookSentEmail_Schedule());
         return 'Scheduled Workbook Sent Email job was added';
      }
      if (mode.toLowerCase() == 'verify') {
         if (jobs.size() == 0) return 'The Workbook Sent Email job is currently not scheduled';
         return 'Scheduled Workbook Sent Email job will run at: ' + jobs[0].NextFireTime.format();
      }
      if (mode.toLowerCase() == 'run') {
         //Get the size of the batch to run
         Integer MAX_BATCH_SIZE = AH_UDC_ConfigHelper.GetInteger('AH_UDC_WorkbookSentEmailBatchSize',10);
         //Start the Batch
         AH_UDC_WorkbookSentEmail_Batch wbSentEmailBatch = new AH_UDC_WorkbookSentEmail_Batch();
         database.executebatch(wbSentEmailBatch, MAX_BATCH_SIZE);
         return 'Workbook Sent Email job will run now. Please use the log to verify when the job is finished.';
      }
      return 'ScheduleWorkbookSentEmailJob, unkown mode: ' + mode;
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}