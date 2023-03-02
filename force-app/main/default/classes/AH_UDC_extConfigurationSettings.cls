<<<<<<< HEAD
/*
 * File            : AH_UDC_extConfigurationSettings.cls
 * Created Date    : 2019-08-29
 * Created By      : Rob.Stevens@Amadeus.com
 * Description     : Extension class for Configuration Settings Page
 *
 * Test classes    : AH_UDC_extConfigurationSettings_TEST.cls
 */
public with sharing class AH_UDC_extConfigurationSettings {
   public Map<String, SettingGroup> settingGroups { get; set; }

   public string actionParameter1 { get; set; }

   public List<AH_UDC_ConfigurationSetting__History> configurationSettingsHistory { get; Set; }
   public string csHistoryID { get; set; }
   public string csHistoryParentId { get; set; }
   public string csHistoryIDNext { get; set; }

   public Boolean SettingsExist{ get; set; } {SettingsExist=true;}

   // Protect against injection
   public String pageName;
   public String getpageName() { return pageName; }
   public void setpageName(String pageName) {
      this.pageName = String.escapeSingleQuotes(pageName);
   }

   // Protect against injection
   public String pageGroupName;
   public String getpageGroupName() { return pageGroupName; }
   public void setpageGroupName(String pageGroupName) {
      this.pageGroupName = String.escapeSingleQuotes(pageGroupName);
   }

   // Protect against injection
   public String updateSettingName;
   public String getupdateSettingName() { return updateSettingName; }
   public void setupdateSettingName(String updateSettingName) {
      this.updateSettingName = String.escapeSingleQuotes(updateSettingName);
   }

   // Protect against injection
   public String updateSettingValue;
   public String getupdateSettingValue() { return updateSettingValue; }
   public void setupdateSettingValue(String updateSettingValue) {
      this.updateSettingValue = String.escapeSingleQuotes(updateSettingValue);
   }

   // Protect against injection
   public String updateSettingStatus;
   public String getupdateSettingStatus() { return updateSettingStatus; }
   public void setupdateSettingStatus(String updateSettingStatus) {
      this.updateSettingStatus = String.escapeSingleQuotes(updateSettingStatus);
   }

   // Protect against injection
   public String updateSettingIsMethod;
   public String getupdateSettingIsMethod() { return updateSettingIsMethod; }
   public void setupdateSettingIsMethod(String updateSettingIsMethod) {
      this.updateSettingIsMethod = String.escapeSingleQuotes(updateSettingIsMethod);
   }

   public AH_UDC_extConfigurationSettings() {
      pageName = ''; //(ApexPages.currentPage().getParameters().get('pn') == null) ? null : String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('pn'));
      GetSettings();
   }

   public void GetSettings()
   {
      // Determine if specific History
      csHistoryID = String.valueOf(apexpages.currentpage().getparameters().get('csHistoryID'));
      csHistoryParentId = String.valueOf(apexpages.currentpage().getparameters().get('csHistoryParentId'));

      // Get Org Info
      Organization orgInfo = [SELECT Id, name FROM Organization LIMIT 1];

      // Get Configuration Settings
      AH_UDC_ConfigurationSetting__c[] configurationSettings;

      settingGroups = new Map<String, SettingGroup> ();
      string orgIdPrefix = String.valueOf(orgInfo.id).left(15) + '||%';
      SettingsExist = true;

      if (String.isBlank(pageName)) {

         configurationSettings =
            [SELECT Name, PageGroupName__c, PageName__c, SettingDisplayName__c, SettingType__c, 
                    SettingValue__c, SettingTextAreaValue__c, SettingValueDefault__c, 
                    SettingHelpText__c, SettingValueDomain__c
               FROM AH_UDC_ConfigurationSetting__c
              WHERE (OrgName__c = :orgInfo.name or OrgName__c like :orgIdPrefix)
                AND PageName__c = null
              ORDER BY PageGroupName__c, DisplayOrder__c, SettingDisplayName__c];
         if(configurationSettings.size() ==0) SettingsExist = false;
         for (AH_UDC_ConfigurationSetting__c setting : configurationSettings) {
            if (!settingGroups.containsKey(setting.PageGroupName__c)) {
               settingGroups.put(setting.PageGroupName__c, new SettingGroup(setting.PageGroupName__c));
            }

            // If setting is an Object replace the value with the full Url
            if (setting.SettingType__c == 'Object') {
               String settingValue = (String.isNotBlank(setting.SettingValue__c) ? setting.SettingValue__c : setting.SettingValueDefault__c);
               setting.SettingValue__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + settingValue;
            }

            settingGroups.get(setting.PageGroupName__c).settings.add(new AH_UDC_extConfigurationSetting(setting));
         }
      } else if (pageName == 'History') {
         string sQueryWhere = '';
         if (String.isEmpty(csHistoryID)) {
            if (String.isNotEmpty(csHistoryParentId)) {
               sQueryWhere = 'WHERE parent.id=:csHistoryParentId';
            }
         } else {
            sQueryWhere = 'WHERE id < :csHistoryID';
            if (String.isNotEmpty(csHistoryParentId)) {
               sQueryWhere += 'AND parent.id=:csHistoryParentId';
            }
         }

         string sQueryCS = 'select id,' +
                           'Parent.Id,' +
                           'parent.PageGroupName__c,' +
                           'parent.PageName__c, ' +
                           'parent.name,' +
                           'CreatedDate,' +
                           'CreatedBy.name,' +
                           'Field,' +
                           'OldValue,' +
                           'NewValue' +
                           ' from AH_UDC_ConfigurationSetting__History' +
                           ' ' + sQueryWhere +
                           ' order by CreatedDate desc' +
                           ' limit 1000';

         configurationSettingsHistory = Database.query(sQueryCS);

         csHistoryIDNext = null;
         if (configurationSettingsHistory.size() == 1000) {
            csHistoryIDNext = configurationSettingsHistory[999].Id;
         }
      } else {
         configurationSettings = [SELECT Id, Name, PageGroupName__c, PageName__c,
                                         SettingDisplayName__c, SettingType__c, SettingValue__c,
                                         SettingTextAreaValue__c, SettingValueDefault__c, PageSectionName__c,
                                         SettingHelpText__c, SettingValueDomain__c
                                    FROM AH_UDC_ConfigurationSetting__c
                                   WHERE (OrgName__c = :orgInfo.name OR OrgName__c like :orgIdPrefix)
                                     AND PageName__c = :pageName
                                   ORDER BY PageSectionName__c, DisplayOrder__c, SettingDisplayName__c];

         for (AH_UDC_ConfigurationSetting__c setting : configurationSettings) {
            if (!settingGroups.containsKey(setting.PageSectionName__c)) {
               settingGroups.put(setting.PageSectionName__c, new SettingGroup(setting.PageSectionName__c));
            }

            if (pageGroupName == null) {
               pageGroupName = setting.PageGroupName__c;
            }

            //If setting is an Object replace the value with the full Url
            if (setting.SettingType__c == 'Object') {
               String settingValue = (String.isNotBlank(setting.SettingValue__c) ? setting.SettingValue__c : setting.SettingValueDefault__c);
               setting.SettingValue__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + settingValue;
            }

            settingGroups.get(setting.PageSectionName__c).settings.add(new AH_UDC_extConfigurationSetting(setting));
         }
      }
   }

   public PageReference launchPage() {
      PageReference pr = new PageReference(actionParameter1);
      pr.setRedirect(true);
      return pr;
   }

   public void showSettingPage() {
      pageName = actionParameter1;
      GetSettings();
   }

   public void refreshPage() {
      GetSettings();
   }

   public void showNextHistoryPage() {
      pageName = 'History';
      csHistoryID = actionParameter1;
      csHistoryParentId = (String.isEmpty(csHistoryParentId) ? '' : csHistoryParentId);
      GetSettings();
   }

   public void showSettingHistory() {
      pageName = 'History';
      csHistoryParentId = csHistoryParentId;
      GetSettings();
   }

   public void initSettings() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      GetSettings();
   }

   class SettingGroup {
      public string groupName { get; set; }
      public List<AH_UDC_extConfigurationSetting> settings { get; set; }
      public SettingGroup(string groupName) {
         this.groupName = groupName;
         this.settings = new List<AH_UDC_extConfigurationSetting> ();
      }
   }

   @TestVisible
   class AH_UDC_extConfigurationSetting {
      public string Id { get; set; }
      public string Name { get; set; }
      public string PageGroupName { get; set; }
      public string PageName { get; set; }
      public string SettingDisplayName { get; set; }
      public string SettingType { get; set; }
      public string SettingValue { get; set; }
      public string SettingValueDomain { get; set; }
      public string SettingValueDefault { get; set; }
      public string SettingHelpText { get; set; }
      public Boolean isChecked { get; set; }
      public List<String> picklistValues { get; set; }
      public integer minValue { get; set; }
      public integer maxValue { get; set; }
      public AH_UDC_extConfigurationSetting(AH_UDC_ConfigurationSetting__c cs) {
         Id = cs.Id;
         Name = cs.Name;

         //Use Default Value if Value isn't set
         if (String.isBlank(cs.SettingValue__c)) {
            cs.SettingValue__c = cs.SettingValueDefault__c;
         }

         PageGroupName = cs.PageGroupName__c;
         PageName = cs.PageName__c;
         SettingDisplayName = cs.SettingDisplayName__c;
         SettingType = cs.SettingType__c;
         SettingValueDefault = cs.SettingValueDefault__c;

         // For certain controls, if there are SettingValueDomain values specified,
         // the valid values/ranges will be automatically appended to the end
         // of this help text later in the code
         SettingHelpText = cs.SettingHelpText__c;
         if (SettingHelpText == null) {
            SettingHelpText = '';
         }

         List<String> rangeValues;
         if (!String.isBlank(cs.SettingValueDomain__c)) {
            // Check if the SettingValueDomain is a {!ObjectName.FieldName}
            if (cs.SettingType__c == 'Picklist' && cs.SettingValueDomain__c.startsWith('{!')) {

               try {
                  if (cs.SettingValueDomain__c.contains('.')) {
                     // The domain is specifying a picklist field on an object
                     rangeValues = RetrievePicklistValuesFromObject(cs.SettingValueDomain__c);
                  } else {
                     // The domain is specifying a GlobalValueSet
                     rangeValues = RetrievePicklistValuesFromGlobalValueSet(cs.SettingValueDomain__c);
                  }
               }
               catch(Exception exc) {
                  // Can't write to the database in a controller constructor, best we can do is show a message on the page
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                                             'Failed to retrieve the picklist values for "' + SettingDisplayName
                                                             + '" from "' + cs.SettingValueDomain__c + '". '
                                                             + exc.getMessage()));
                  rangeValues.clear();
               }
            } else {
               // SettingValueDomain has a CR/LF separated list of valid values
               rangeValues = cs.SettingValueDomain__c.split('\r\n');
            }
         } else {
            rangeValues = new List<String> ();
         }

         BuildHelpText(cs, rangeValues);

         if (cs.SettingType__c == 'TextArea') {
            SettingValue = cs.SettingTextAreaValue__c;
         } else {
            SettingValue = cs.SettingValue__c;
         }
      }

      private void BuildHelpText(AH_UDC_ConfigurationSetting__c cs, List<String> rangeValues) {
         if (cs.SettingType__c == 'Checkbox') {
            this.isChecked = (cs.SettingValue__c.toUpperCase() == 'TRUE');

            if (!String.isBlank(cs.SettingValueDefault__c)) {
               SettingHelpText += '\r\n\r\nDefault: ' + (cs.SettingValueDefault__c.toUpperCase() == 'TRUE' ? 'Checked' : 'Unchecked');
            }
         } else if (cs.SettingType__c == 'Picklist') {
            this.picklistValues = rangeValues;
            // Add the valid choices
            if (rangeValues.size() > 0) {
               SettingHelpText += '\r\n\r\nValid values:';
               for (string s : rangeValues) {
                  SettingHelpText += '\r\n   ' + s;
               }
            }

            if (!String.isBlank(cs.SettingValueDefault__c)) {
               SettingHelpText += '\r\n\r\nDefault: ' + cs.SettingValueDefault__c;
            }
         } else if (cs.SettingType__c == 'String') {
            if (rangeValues.size() > 0) {
               SettingHelpText += '\r\n\r\nValid values:';
               for (string s : rangeValues) {
                  SettingHelpText += '\r\n   ' + s;
               }
            }

            if (!String.isBlank(cs.SettingValueDefault__c)) {
               SettingHelpText += '\r\n\r\nDefault: ' + cs.SettingValueDefault__c;
            }
         } else if (cs.SettingType__c == 'Integer' && cs.SettingValueDomain__c != null) {
            if (rangeValues.size() >= 1) this.minValue = Integer.valueOf(rangeValues[0]);
            if (rangeValues.size() >= 2) this.maxValue = Integer.valueOf(rangeValues[1]);

            if (rangeValues.size() > 1) {
               SettingHelpText += '\r\n\r\nValid range: ' + this.minValue + '-' + this.maxValue;
            } else if (rangeValues.size() == 1) {
               SettingHelpText += '\r\n\r\nMinimum value: ' + this.minValue;
            }

            if (!String.isBlank(cs.SettingValueDefault__c)) {
               SettingHelpText += '\r\n\r\nDefault: ' + cs.SettingValueDefault__c;
            }
         }
      }

      @TestVisible
      private List<String> RetrievePicklistValuesFromObject(string domain) {
         List<String> rangeValues = new List<String> ();
         // Split the value specified in the domain into ObjectName and FieldName, removing the surrounding curley brace tags
         // Example: "{!RFP__c.BookingStatus__c}" becomes two strings: "RFP__c" and "BookingStatus__c"
         String[] parts = domain.remove('{!').remove('}').split('\\.');

         // Store the list of picklist values into the rangeValues list
         // Retrieve the picklist field's definition from metadata
         List<String> pickListValuesList = new List<String> ();
         Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(parts[0]);
         Schema.DescribeSObjectResult res = convertToObj.getDescribe();
         Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(parts[1]).getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

         // Store the values of the picklist to the rangeValues list used in populating the help text
         for (Schema.PicklistEntry f : ple) {
            rangeValues.add(f.getLabel());
         }

         return rangeValues;
      }

      private List<String> RetrievePicklistValuesFromGlobalValueSet(string s) {
         //This is not used at this time
         List<String> rangeValues = new List<String> ();
         return rangeValues;
      }
   }

   // Updates the record in the database with the new value for the current Config Setting being edited
   public void updateSetting() {
      try {
         if (updateSettingIsMethod != null && updateSettingIsMethod.toUpperCase() == 'TRUE') {
            requestMethod();
            return;
         }

         if (Test.isRunningTest() && updateSettingName == 'Exception') {
            Integer i = 1 / 0;
         }

         AH_UDC_LogHelper.Debug('###updateSettingName: ' + updateSettingName);
         AH_UDC_LogHelper.Debug('###updateSettingValue: ' + updateSettingValue);

         //Get Org Info
         Organization orgInfo = [select Id, name from Organization LIMIT 1];

         //Get Setting
         string orgIdPrefix = String.valueOf(orgInfo.id).left(15) + '||%';
         AH_UDC_ConfigurationSetting__c[] settings = [SELECT Name, SettingValue__c, SettingTextAreaValue__c, SettingType__c, SettingValueDomain__c
                                                        FROM AH_UDC_ConfigurationSetting__c
                                                       WHERE Name = :updateSettingName
                                                         AND (OrgName__c = :orgInfo.name OR OrgName__c like :orgIdPrefix)];

         if (settings.size() == 1) {
            // If this is an integer field, and there is a min/max set, make sure the user-specified
            // value is within the valid range (inclusive of min and max value)
            if (settings[0].SettingType__c == 'Integer' && settings[0].SettingValueDomain__c != null) {
               Integer newValue = Integer.valueOf(updateSettingValue);
               Integer minValue = -2147483647; // Default if no range
               Integer maxValue = 2147483647; // Default if no range

               List<String> rangeValues = settings[0].SettingValueDomain__c.split('\r\n');
               if (rangeValues.size() >= 1) minValue = Integer.valueOf(rangeValues[0]);
               if (rangeValues.size() >= 2) maxValue = Integer.valueOf(rangeValues[1]);

               if (minValue > newValue || maxValue<newValue) {
                  updateSettingStatus = 'Update failed.  Value is not within the allowed range of ' + minValue + ' to ' + maxValue;
                  return;
               }
            }

            if (settings[0].SettingType__c == 'Time_24h') {
               Integer h = -1;
               Integer m = -1;
               string UNRECOGNIZED_TIME_FORMAT = 'Unrecognized time format.  Time must be specified in 24 hour format, ranging from 00:00 to 23:59';

               try {
                  string[] parts = updateSettingValue.split(':');
                  if (parts.size() == 2) {
                     h = Integer.valueOf(parts[0]);
                     m = Integer.valueOf(parts[1]);

                     if (h< 0 || h> 23 || m< 0 || m> 59) {
                        updateSettingStatus = UNRECOGNIZED_TIME_FORMAT;
                        return;
                     }

                     updateSettingValue = String.valueOf(h).leftPad(2, '0') + ':' + String.valueOf(m).leftPad(2, '0');
                  } else {
                     updateSettingStatus = UNRECOGNIZED_TIME_FORMAT;
                     return;
                  }
               }
               catch(Exception exc) {
                  updateSettingStatus = UNRECOGNIZED_TIME_FORMAT;
                  return;
               }
            }

            // Update the field appropriate for saving this setting value
            if (settings[0].SettingType__c == 'TextArea') {
               settings[0].SettingTextAreaValue__c = updateSettingValue;
            } else if (settings[0].SettingType__c == 'ProtectedString') {
               settings[0].SettingValue__c = AH_UDC_ConfigHelper.protect(updateSettingValue);
            } else {
               settings[0].SettingValue__c = updateSettingValue;
            }

            AH_UDC_Security.UpdateObjects(settings);
            updateSettingStatus = 'Setting updated';
         } else {
            updateSettingStatus = 'Update failed: Setting Not Found';
         }
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.debug('###updateSetting exc: ' + exc.getMessage());
         updateSettingStatus = 'Update failed: Please check the log for details';
         AH_UDC_LogHelper.Log('Exception', 'Configuration Settings', AH_UDC_LogHelper.getClassAndMethodName(new DmlException()),
                              'Exception: ', exc, null, null);
      }
   }

   //Request Code Method
   public void requestMethod() {
      try {
         if (Test.isRunningTest() && updateSettingValue == 'Exception') {
            throw new AH_UDC_ConfigHelper.AH_UDC_ConfigException(AH_UDC_extConfigurationSettings_TEST.TEST_CLASS_FORCED_EXCEPTION);
         }

         AH_UDC_LogHelper.debug('###requestMethod: ' + updateSettingValue);

         string[] methodDetails = updateSettingValue.split(';');

         //Setup Arguments for Method
         Map<string, Object> args = new Map<string, Object> ();
         Map<string, string> argsString = (Map<string, string>) JSON.deserialize(methodDetails[methodDetails.size() - 1], Map<string, string>.class);
         for (string key : argsString.keySet()) {
            args.put(key, argsString.get(key));
         }

         //Call Method
         Callable extension;
         if (methodDetails.size() == 4) {
            extension = (Callable) Type.forName(methodDetails[0], methodDetails[1]).newInstance();
         } else {
            extension = (Callable) Type.forName(methodDetails[0]).newInstance();
         }
         Object result = extension.call(methodDetails[methodDetails.size() - 2], args);
         string resultMessage = String.valueOf(result);

         updateSettingStatus = 'Request Completed';
         if (String.isNotEmpty(resultMessage)) {
            updateSettingStatus += ', Status: ' + resultMessage;
         }
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.debug('###requestMethod exc: ' + exc.getMessage());
         updateSettingStatus = 'Request failed; please check the log for details.';
         AH_UDC_LogHelper.Log('Exception', 'Configuration Settings', AH_UDC_LogHelper.getClassAndMethodName(new DmlException()),
                       'Exception: ', exc, null, null);
      }
   }
=======
/*
 * File            : AH_UDC_extConfigurationSettings.cls
 * Created Date    : 2019-08-29
 * Created By      : Rob.Stevens@Amadeus.com
 * Description     : Extension class for Configuration Settings Page
 *
 * Test classes    : AH_UDC_extConfigurationSettings_TEST.cls
 */
public with sharing class AH_UDC_extConfigurationSettings {
   public Map<String, SettingGroup> settingGroups { get; set; }

   public string actionParameter1 { get; set; }

   public List<AH_UDC_ConfigurationSetting__History> configurationSettingsHistory { get; Set; }
   public string csHistoryID { get; set; }
   public string csHistoryParentId { get; set; }
   public string csHistoryIDNext { get; set; }

   public Boolean SettingsExist{ get; set; } {SettingsExist=true;}

   // Protect against injection
   public String pageName;
   public String getpageName() { return pageName; }
   public void setpageName(String pageName) {
      this.pageName = String.escapeSingleQuotes(pageName);
   }

   // Protect against injection
   public String pageGroupName;
   public String getpageGroupName() { return pageGroupName; }
   public void setpageGroupName(String pageGroupName) {
      this.pageGroupName = String.escapeSingleQuotes(pageGroupName);
   }

   // Protect against injection
   public String updateSettingName;
   public String getupdateSettingName() { return updateSettingName; }
   public void setupdateSettingName(String updateSettingName) {
      this.updateSettingName = String.escapeSingleQuotes(updateSettingName);
   }

   // Protect against injection
   public String updateSettingValue;
   public String getupdateSettingValue() { return updateSettingValue; }
   public void setupdateSettingValue(String updateSettingValue) {
      this.updateSettingValue = String.escapeSingleQuotes(updateSettingValue);
   }

   // Protect against injection
   public String updateSettingStatus;
   public String getupdateSettingStatus() { return updateSettingStatus; }
   public void setupdateSettingStatus(String updateSettingStatus) {
      this.updateSettingStatus = String.escapeSingleQuotes(updateSettingStatus);
   }

   // Protect against injection
   public String updateSettingIsMethod;
   public String getupdateSettingIsMethod() { return updateSettingIsMethod; }
   public void setupdateSettingIsMethod(String updateSettingIsMethod) {
      this.updateSettingIsMethod = String.escapeSingleQuotes(updateSettingIsMethod);
   }

   public AH_UDC_extConfigurationSettings() {
      pageName = ''; //(ApexPages.currentPage().getParameters().get('pn') == null) ? null : String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('pn'));
      GetSettings();
   }

   public void GetSettings()
   {
      // Determine if specific History
      csHistoryID = String.valueOf(apexpages.currentpage().getparameters().get('csHistoryID'));
      csHistoryParentId = String.valueOf(apexpages.currentpage().getparameters().get('csHistoryParentId'));

      // Get Org Info
      Organization orgInfo = [SELECT Id, name FROM Organization LIMIT 1];

      // Get Configuration Settings
      AH_UDC_ConfigurationSetting__c[] configurationSettings;

      settingGroups = new Map<String, SettingGroup> ();
      string orgIdPrefix = String.valueOf(orgInfo.id).left(15) + '||%';
      SettingsExist = true;

      if (String.isBlank(pageName)) {

         configurationSettings =
            [SELECT Name, PageGroupName__c, PageName__c, SettingDisplayName__c, SettingType__c, 
                    SettingValue__c, SettingTextAreaValue__c, SettingValueDefault__c, 
                    SettingHelpText__c, SettingValueDomain__c
               FROM AH_UDC_ConfigurationSetting__c
              WHERE (OrgName__c = :orgInfo.name or OrgName__c like :orgIdPrefix)
                AND PageName__c = null
              ORDER BY PageGroupName__c, DisplayOrder__c, SettingDisplayName__c];
         if(configurationSettings.size() ==0) SettingsExist = false;
         for (AH_UDC_ConfigurationSetting__c setting : configurationSettings) {
            if (!settingGroups.containsKey(setting.PageGroupName__c)) {
               settingGroups.put(setting.PageGroupName__c, new SettingGroup(setting.PageGroupName__c));
            }

            // If setting is an Object replace the value with the full Url
            if (setting.SettingType__c == 'Object') {
               String settingValue = (String.isNotBlank(setting.SettingValue__c) ? setting.SettingValue__c : setting.SettingValueDefault__c);
               setting.SettingValue__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + settingValue;
            }

            settingGroups.get(setting.PageGroupName__c).settings.add(new AH_UDC_extConfigurationSetting(setting));
         }
      } else if (pageName == 'History') {
         string sQueryWhere = '';
         if (String.isEmpty(csHistoryID)) {
            if (String.isNotEmpty(csHistoryParentId)) {
               sQueryWhere = 'WHERE parent.id=:csHistoryParentId';
            }
         } else {
            sQueryWhere = 'WHERE id < :csHistoryID';
            if (String.isNotEmpty(csHistoryParentId)) {
               sQueryWhere += 'AND parent.id=:csHistoryParentId';
            }
         }

         string sQueryCS = 'select id,' +
                           'Parent.Id,' +
                           'parent.PageGroupName__c,' +
                           'parent.PageName__c, ' +
                           'parent.name,' +
                           'CreatedDate,' +
                           'CreatedBy.name,' +
                           'Field,' +
                           'OldValue,' +
                           'NewValue' +
                           ' from AH_UDC_ConfigurationSetting__History' +
                           ' ' + sQueryWhere +
                           ' order by CreatedDate desc' +
                           ' limit 1000';

         configurationSettingsHistory = Database.query(sQueryCS);

         csHistoryIDNext = null;
         if (configurationSettingsHistory.size() == 1000) {
            csHistoryIDNext = configurationSettingsHistory[999].Id;
         }
      } else {
         configurationSettings = [SELECT Id, Name, PageGroupName__c, PageName__c,
                                         SettingDisplayName__c, SettingType__c, SettingValue__c,
                                         SettingTextAreaValue__c, SettingValueDefault__c, PageSectionName__c,
                                         SettingHelpText__c, SettingValueDomain__c
                                    FROM AH_UDC_ConfigurationSetting__c
                                   WHERE (OrgName__c = :orgInfo.name OR OrgName__c like :orgIdPrefix)
                                     AND PageName__c = :pageName
                                   ORDER BY PageSectionName__c, DisplayOrder__c, SettingDisplayName__c];

         for (AH_UDC_ConfigurationSetting__c setting : configurationSettings) {
            if (!settingGroups.containsKey(setting.PageSectionName__c)) {
               settingGroups.put(setting.PageSectionName__c, new SettingGroup(setting.PageSectionName__c));
            }

            if (pageGroupName == null) {
               pageGroupName = setting.PageGroupName__c;
            }

            //If setting is an Object replace the value with the full Url
            if (setting.SettingType__c == 'Object') {
               String settingValue = (String.isNotBlank(setting.SettingValue__c) ? setting.SettingValue__c : setting.SettingValueDefault__c);
               setting.SettingValue__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + settingValue;
            }

            settingGroups.get(setting.PageSectionName__c).settings.add(new AH_UDC_extConfigurationSetting(setting));
         }
      }
   }

   public PageReference launchPage() {
      PageReference pr = new PageReference(actionParameter1);
      pr.setRedirect(true);
      return pr;
   }

   public void showSettingPage() {
      pageName = actionParameter1;
      GetSettings();
   }

   public void refreshPage() {
      GetSettings();
   }

   public void showNextHistoryPage() {
      pageName = 'History';
      csHistoryID = actionParameter1;
      csHistoryParentId = (String.isEmpty(csHistoryParentId) ? '' : csHistoryParentId);
      GetSettings();
   }

   public void showSettingHistory() {
      pageName = 'History';
      csHistoryParentId = csHistoryParentId;
      GetSettings();
   }

   public void initSettings() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      GetSettings();
   }

   class SettingGroup {
      public string groupName { get; set; }
      public List<AH_UDC_extConfigurationSetting> settings { get; set; }
      public SettingGroup(string groupName) {
         this.groupName = groupName;
         this.settings = new List<AH_UDC_extConfigurationSetting> ();
      }
   }

   @TestVisible
   class AH_UDC_extConfigurationSetting {
      public string Id { get; set; }
      public string Name { get; set; }
      public string PageGroupName { get; set; }
      public string PageName { get; set; }
      public string SettingDisplayName { get; set; }
      public string SettingType { get; set; }
      public string SettingValue { get; set; }
      public string SettingValueDomain { get; set; }
      public string SettingValueDefault { get; set; }
      public string SettingHelpText { get; set; }
      public Boolean isChecked { get; set; }
      public List<String> picklistValues { get; set; }
      public integer minValue { get; set; }
      public integer maxValue { get; set; }
      public AH_UDC_extConfigurationSetting(AH_UDC_ConfigurationSetting__c cs) {
         Id = cs.Id;
         Name = cs.Name;

         //Use Default Value if Value isn't set
         if (String.isBlank(cs.SettingValue__c)) {
            cs.SettingValue__c = cs.SettingValueDefault__c;
         }

         PageGroupName = cs.PageGroupName__c;
         PageName = cs.PageName__c;
         SettingDisplayName = cs.SettingDisplayName__c;
         SettingType = cs.SettingType__c;
         SettingValueDefault = cs.SettingValueDefault__c;

         // For certain controls, if there are SettingValueDomain values specified,
         // the valid values/ranges will be automatically appended to the end
         // of this help text later in the code
         SettingHelpText = cs.SettingHelpText__c;
         if (SettingHelpText == null) {
            SettingHelpText = '';
         }

         List<String> rangeValues;
         if (!String.isBlank(cs.SettingValueDomain__c)) {
            // Check if the SettingValueDomain is a {!ObjectName.FieldName}
            if (cs.SettingType__c == 'Picklist' && cs.SettingValueDomain__c.startsWith('{!')) {

               try {
                  if (cs.SettingValueDomain__c.contains('.')) {
                     // The domain is specifying a picklist field on an object
                     rangeValues = RetrievePicklistValuesFromObject(cs.SettingValueDomain__c);
                  } else {
                     // The domain is specifying a GlobalValueSet
                     rangeValues = RetrievePicklistValuesFromGlobalValueSet(cs.SettingValueDomain__c);
                  }
               }
               catch(Exception exc) {
                  // Can't write to the database in a controller constructor, best we can do is show a message on the page
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                                             'Failed to retrieve the picklist values for "' + SettingDisplayName
                                                             + '" from "' + cs.SettingValueDomain__c + '". '
                                                             + exc.getMessage()));
                  rangeValues.clear();
               }
            } else {
               // SettingValueDomain has a CR/LF separated list of valid values
               rangeValues = cs.SettingValueDomain__c.split('\r\n');
            }
         } else {
            rangeValues = new List<String> ();
         }

         BuildHelpText(cs, rangeValues);

         if (cs.SettingType__c == 'TextArea') {
            SettingValue = cs.SettingTextAreaValue__c;
         } else {
            SettingValue = cs.SettingValue__c;
         }
      }

      private void BuildHelpText(AH_UDC_ConfigurationSetting__c cs, List<String> rangeValues) {
         if (cs.SettingType__c == 'Checkbox') {
            this.isChecked = (cs.SettingValue__c.toUpperCase() == 'TRUE');

            if (!String.isBlank(cs.SettingValueDefault__c)) {
               SettingHelpText += '\r\n\r\nDefault: ' + (cs.SettingValueDefault__c.toUpperCase() == 'TRUE' ? 'Checked' : 'Unchecked');
            }
         } else if (cs.SettingType__c == 'Picklist') {
            this.picklistValues = rangeValues;
            // Add the valid choices
            if (rangeValues.size() > 0) {
               SettingHelpText += '\r\n\r\nValid values:';
               for (string s : rangeValues) {
                  SettingHelpText += '\r\n   ' + s;
               }
            }

            if (!String.isBlank(cs.SettingValueDefault__c)) {
               SettingHelpText += '\r\n\r\nDefault: ' + cs.SettingValueDefault__c;
            }
         } else if (cs.SettingType__c == 'String') {
            if (rangeValues.size() > 0) {
               SettingHelpText += '\r\n\r\nValid values:';
               for (string s : rangeValues) {
                  SettingHelpText += '\r\n   ' + s;
               }
            }

            if (!String.isBlank(cs.SettingValueDefault__c)) {
               SettingHelpText += '\r\n\r\nDefault: ' + cs.SettingValueDefault__c;
            }
         } else if (cs.SettingType__c == 'Integer' && cs.SettingValueDomain__c != null) {
            if (rangeValues.size() >= 1) this.minValue = Integer.valueOf(rangeValues[0]);
            if (rangeValues.size() >= 2) this.maxValue = Integer.valueOf(rangeValues[1]);

            if (rangeValues.size() > 1) {
               SettingHelpText += '\r\n\r\nValid range: ' + this.minValue + '-' + this.maxValue;
            } else if (rangeValues.size() == 1) {
               SettingHelpText += '\r\n\r\nMinimum value: ' + this.minValue;
            }

            if (!String.isBlank(cs.SettingValueDefault__c)) {
               SettingHelpText += '\r\n\r\nDefault: ' + cs.SettingValueDefault__c;
            }
         }
      }

      @TestVisible
      private List<String> RetrievePicklistValuesFromObject(string domain) {
         List<String> rangeValues = new List<String> ();
         // Split the value specified in the domain into ObjectName and FieldName, removing the surrounding curley brace tags
         // Example: "{!RFP__c.BookingStatus__c}" becomes two strings: "RFP__c" and "BookingStatus__c"
         String[] parts = domain.remove('{!').remove('}').split('\\.');

         // Store the list of picklist values into the rangeValues list
         // Retrieve the picklist field's definition from metadata
         List<String> pickListValuesList = new List<String> ();
         Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(parts[0]);
         Schema.DescribeSObjectResult res = convertToObj.getDescribe();
         Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(parts[1]).getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

         // Store the values of the picklist to the rangeValues list used in populating the help text
         for (Schema.PicklistEntry f : ple) {
            rangeValues.add(f.getLabel());
         }

         return rangeValues;
      }

      private List<String> RetrievePicklistValuesFromGlobalValueSet(string s) {
         //This is not used at this time
         List<String> rangeValues = new List<String> ();
         return rangeValues;
      }
   }

   // Updates the record in the database with the new value for the current Config Setting being edited
   public void updateSetting() {
      try {
         if (updateSettingIsMethod != null && updateSettingIsMethod.toUpperCase() == 'TRUE') {
            requestMethod();
            return;
         }

         if (Test.isRunningTest() && updateSettingName == 'Exception') {
            Integer i = 1 / 0;
         }

         AH_UDC_LogHelper.Debug('###updateSettingName: ' + updateSettingName);
         AH_UDC_LogHelper.Debug('###updateSettingValue: ' + updateSettingValue);

         //Get Org Info
         Organization orgInfo = [select Id, name from Organization LIMIT 1];

         //Get Setting
         string orgIdPrefix = String.valueOf(orgInfo.id).left(15) + '||%';
         AH_UDC_ConfigurationSetting__c[] settings = [SELECT Name, SettingValue__c, SettingTextAreaValue__c, SettingType__c, SettingValueDomain__c
                                                        FROM AH_UDC_ConfigurationSetting__c
                                                       WHERE Name = :updateSettingName
                                                         AND (OrgName__c = :orgInfo.name OR OrgName__c like :orgIdPrefix)];

         if (settings.size() == 1) {
            // If this is an integer field, and there is a min/max set, make sure the user-specified
            // value is within the valid range (inclusive of min and max value)
            if (settings[0].SettingType__c == 'Integer' && settings[0].SettingValueDomain__c != null) {
               Integer newValue = Integer.valueOf(updateSettingValue);
               Integer minValue = -2147483647; // Default if no range
               Integer maxValue = 2147483647; // Default if no range

               List<String> rangeValues = settings[0].SettingValueDomain__c.split('\r\n');
               if (rangeValues.size() >= 1) minValue = Integer.valueOf(rangeValues[0]);
               if (rangeValues.size() >= 2) maxValue = Integer.valueOf(rangeValues[1]);

               if (minValue > newValue || maxValue<newValue) {
                  updateSettingStatus = 'Update failed.  Value is not within the allowed range of ' + minValue + ' to ' + maxValue;
                  return;
               }
            }

            if (settings[0].SettingType__c == 'Time_24h') {
               Integer h = -1;
               Integer m = -1;
               string UNRECOGNIZED_TIME_FORMAT = 'Unrecognized time format.  Time must be specified in 24 hour format, ranging from 00:00 to 23:59';

               try {
                  string[] parts = updateSettingValue.split(':');
                  if (parts.size() == 2) {
                     h = Integer.valueOf(parts[0]);
                     m = Integer.valueOf(parts[1]);

                     if (h< 0 || h> 23 || m< 0 || m> 59) {
                        updateSettingStatus = UNRECOGNIZED_TIME_FORMAT;
                        return;
                     }

                     updateSettingValue = String.valueOf(h).leftPad(2, '0') + ':' + String.valueOf(m).leftPad(2, '0');
                  } else {
                     updateSettingStatus = UNRECOGNIZED_TIME_FORMAT;
                     return;
                  }
               }
               catch(Exception exc) {
                  updateSettingStatus = UNRECOGNIZED_TIME_FORMAT;
                  return;
               }
            }

            // Update the field appropriate for saving this setting value
            if (settings[0].SettingType__c == 'TextArea') {
               settings[0].SettingTextAreaValue__c = updateSettingValue;
            } else if (settings[0].SettingType__c == 'ProtectedString') {
               settings[0].SettingValue__c = AH_UDC_ConfigHelper.protect(updateSettingValue);
            } else {
               settings[0].SettingValue__c = updateSettingValue;
            }

            AH_UDC_Security.UpdateObjects(settings);
            updateSettingStatus = 'Setting updated';
         } else {
            updateSettingStatus = 'Update failed: Setting Not Found';
         }
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.debug('###updateSetting exc: ' + exc.getMessage());
         updateSettingStatus = 'Update failed: Please check the log for details';
         AH_UDC_LogHelper.Log('Exception', 'Configuration Settings', AH_UDC_LogHelper.getClassAndMethodName(new DmlException()),
                              'Exception: ', exc, null, null);
      }
   }

   //Request Code Method
   public void requestMethod() {
      try {
         if (Test.isRunningTest() && updateSettingValue == 'Exception') {
            throw new AH_UDC_ConfigHelper.AH_UDC_ConfigException(AH_UDC_extConfigurationSettings_TEST.TEST_CLASS_FORCED_EXCEPTION);
         }

         AH_UDC_LogHelper.debug('###requestMethod: ' + updateSettingValue);

         string[] methodDetails = updateSettingValue.split(';');

         //Setup Arguments for Method
         Map<string, Object> args = new Map<string, Object> ();
         Map<string, string> argsString = (Map<string, string>) JSON.deserialize(methodDetails[methodDetails.size() - 1], Map<string, string>.class);
         for (string key : argsString.keySet()) {
            args.put(key, argsString.get(key));
         }

         //Call Method
         Callable extension;
         if (methodDetails.size() == 4) {
            extension = (Callable) Type.forName(methodDetails[0], methodDetails[1]).newInstance();
         } else {
            extension = (Callable) Type.forName(methodDetails[0]).newInstance();
         }
         Object result = extension.call(methodDetails[methodDetails.size() - 2], args);
         string resultMessage = String.valueOf(result);

         updateSettingStatus = 'Request Completed';
         if (String.isNotEmpty(resultMessage)) {
            updateSettingStatus += ', Status: ' + resultMessage;
         }
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.debug('###requestMethod exc: ' + exc.getMessage());
         updateSettingStatus = 'Request failed; please check the log for details.';
         AH_UDC_LogHelper.Log('Exception', 'Configuration Settings', AH_UDC_LogHelper.getClassAndMethodName(new DmlException()),
                       'Exception: ', exc, null, null);
      }
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}