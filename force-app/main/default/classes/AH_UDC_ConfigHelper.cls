/*
 * File            : AH_UDC_ConfigHelper.cls
 * Created Date    : 2019-08-29
 * Created By      : George.Tasker@amadeus.com
 * Description     : Caching routines to use Cache (if enabled) to store previously retrieved configuration
 *                   values so they can be retrieved without needing to make a SOQL call
 * Test classes    : AH_UDC_ConfigHelper_TEST.cls
 */
public with sharing class AH_UDC_ConfigHelper
{
   // Name of the Platform Cache partition that this code will use for storing key/values
   private static final string ORG_CACHE_PARTITION_NAME = 'AH.CentralSales';

   private static cache.OrgPartition m_orgCache = null;

   // A local cache usable by just this instance of this class.  If the Org Cache is not
   // enabled, requests to GetValue, SetValue, RemoveKey, ContainsKey will all use
   // this temporary cache so that SOQL calls only need to be made once for the life of
   // this class instance.
   private static Map<String, object> m_classCache = new Map<String, object> ();

   // Attempts to get a pointer to the Platform Cache partition named ORG_CACHE_PARTITION_NAME.  If
   // successful, m_cache will be non-null
   private static void initOrgCache() {
      try {
         // Not implemented in custom code
      }
      catch(Exception ex) {
         // Cache does not exist
         m_orgCache = null;
         System.debug(ex.getMessage());
      }
   }

   public static void FlushCache() {
      try {
         //clear class cache
         m_classCache.clear();
      }
      catch(Exception ex) {
         ex.setMessage('ConfigHelper.FlushCache::' + ex.getMessage());
         System.debug(ex.getMessage());
         throw(ex);
      }
   }

   // Prefetch Configuration Settings into classCache
   //
   // Should be used when it is known that a code block will need to use multiple
   // config settings.  Use of this function will reduce the number of SOQL calls
   //
   // Returns the number of keys that were found and loaded into the cache
   public static Integer PrefetchValues(List<string> keys) {
      string orgIdPrefix = UserInfo.getOrganizationId().left(15) + '||%';
      //AH_UDC_SystemContext sysContext = new AH_UDC_SystemContext();
      List<String> filteredKeys = new List<String> ();
      for (String key : keys) {
         key = String.escapeSingleQuotes(key);
         filteredKeys.add(key);
      }
      AH_UDC_ConfigurationSetting__c[] settings = AH_UDC_SystemContext.query('SELECT NAME,SettingType__c,SettingValue__c,SettingTextAreaValue__c,SettingValueDefault__c ' +
                                                                   'FROM AH_UDC_ConfigurationSetting__c ' +
                                                                   'WHERE (OrgName__c = \'' + String.valueOf(UserInfo.getOrganizationName()) + '\' or OrgName__c like \'' + String.valueOf(orgIdPrefix) + '\') ' +
                                                                   'AND name in (\'' + String.join(filteredKeys, '\',\'') + '\')');

      for (AH_UDC_ConfigurationSetting__c cs : settings) {
         // TextArea fields store their data in the much larger field,
         // so get the value from that field
         if (cs.SettingType__c == 'TextArea') {
            SetValue(cs.Name, ReplaceParametersInValue(cs.SettingTextAreaValue__c));
         }
         // If there is no value set, use the DEFAULT value
         else if (String.isBlank(cs.SettingValue__c)) {
            SetValue(cs.Name, ReplaceParametersInValue(cs.SettingValueDefault__c));
         } else {
            SetValue(cs.Name, ReplaceParametersInValue(cs.SettingValue__c));
         }
      }

      return settings.size();
   }

   // Looks for a merge tag anywhere in 'value'.  Each one that is found is looked up in the 
   // config settings to get its value, and then that value (if non-null) replaces the tag
   // in value.
   //
   // If there is more than one tag in the value, the function will keep looping
   // until all tags are replaced
   private static string ReplaceParametersInValue(string value) {
      if (String.isBlank(value)) return value;

      Integer startIndex = value.indexOf('{!');
      Integer endIndex;
      String key;
      String replacementValue;

      if (startIndex == - 1) return value;

      Integer startSearchPosition = 0;

      do {
         endIndex = value.substring(startIndex).indexOf('}');
         // There is something wrong in the value, as there is no end to the merge tag
         if (endIndex == - 1) {
            AH_UDC_LogHelper.debug(LoggingLevel.WARN, 'ConfigHelper detected a tag to replace in a Configuration Setting value, but the tag was misformed and could not be replaced');
            return value;
         }

         // Extract the config value key name from the tag, so we know which
         // config setting has the value that will replace the merge tag
         key = value.substring(startIndex + 2, startIndex + endIndex);

         // Configuration Settings may have a merge tag for an object.field that should not be replaced
         if (!key.contains('.')) {

            if (AH_UDC_LabelHelper.HasReplacement(key)) {
               replacementValue = AH_UDC_LabelHelper.GetReplacementString(key);
            } else {
               replacementValue = String.valueOf(GetValue(key, (string) null));
            }

            // If the replacement string is not defined in the ConfigSettings,
            // then no replacements can be done
            if (replacementValue == null) {
               AH_UDC_LogHelper.debug(LoggingLevel.WARN, 'ConfigHelper could not find a Configuration Setting value for the key "' + key + '".');
               return value;
            }

            // Replace the tag in the value
            value = value.replace('{!' + key + '}', replacementValue);
         } else {
            // The tag that was found is not a ConfigSetting merge tag, so skip over it
            startSearchPosition = startIndex + 1;
         }
         startIndex = value.indexOf('{!', startSearchPosition);
      }
      while (startIndex > - 1);

      // All replacements are done
      return value;
   }

   // Returns the value associated with the key 
   public static object GetValue(string key, string defaultValue) {
      return GetValue(key, defaultValue, false);
   }

   // Returns the value associated with the key 
   public static object GetValue(string key, string defaultValue, Boolean silent) {
      Object ret = GetValue(key, silent);
      if (ret == null) {
         ret = (Object) ReplaceParametersInValue(defaultValue);
      }

      return ret;
   }

   // Returns the value associated with the key 
   public static Boolean GetBoolean(string key, Boolean defaultValue) {
      return GetBoolean(key, defaultValue, false);
   }

   // Returns the value associated with the key 
   public static Boolean GetBoolean(string key, Boolean defaultValue, Boolean silent) {
      Object ret = GetValue(key, silent);
      if (ret == null) {
         ret = (Object) defaultValue;
      }
      Boolean retBoolean = false;
      if (ret != null && String.valueOf(ret).toUpperCase() == 'TRUE') {
         retBoolean = true;
      }

      return retBoolean;
   }

   // Returns the value associated with the key 
   public static String GetString(string key, string defaultValue) {
      Object ret = GetValue(key);
      if (ret == null) {
         ret = (Object) ReplaceParametersInValue(defaultValue);
      }

      if (ret == null) { ret = (object)''; }

      return String.valueOf(ret);
   }

   // Returns the value associated with the key 
   public static Integer GetInteger(string key, integer defaultValue) {
      Object ret = GetValue(key);
      if (ret == null) {
         ret = (Object) defaultValue;
      }
      System.debug('Integer.valueOf(ret)=> ' + Integer.valueOf(ret) + ' ret ' + ret);
      return Integer.valueOf(ret);
   }

   public static object GetValue(string key) {
      return GetValue(key, false);
   }

   // Returns the value associated with the key
   // If silent is true, code will not log a warning if a ConfigKey is not found, otherwise
   // a LogEntry is created, warning that a ket value is missing
   public static object GetValue(string key, Boolean silent) {

      key = String.escapeSingleQuotes(key);
      //if the value is in the class cache return it
      if (m_classCache.containsKey(key)) {
         return ReplaceParametersInValue(String.valueOf(m_classCache.get(key)));
      }

      //Init the org cache if it hasn't been already
      if (m_orgCache == null) {
         initOrgCache();
      }

      //if the value is in the org cache return it
      if (m_orgCache != null && m_orgCache.contains(key)) {
         return ReplaceParametersInValue(String.valueOf(m_orgCache.get(key)));
      }

      // Retrieve the Configuration Setting for this Key
      string orgIdPrefix = UserInfo.getOrganizationId().left(15) + '||%';

      AH_UDC_ConfigurationSetting__c[] settings = AH_UDC_SystemContext.query('SELECT NAME,SettingType__c,SettingValue__c,SettingTextAreaValue__c,SettingValueDefault__c ' +
                                                                   'FROM AH_UDC_ConfigurationSetting__c ' +
                                                                   'WHERE (OrgName__c = \'' + String.valueOf(UserInfo.getOrganizationName()) + '\' or OrgName__c like \'' + String.valueOf(orgIdPrefix) + '\') ' +
                                                                   'AND name = \'' + String.valueOf(key) + '\'');

      if (settings.size() == 1) {
         string settingValue = '';
         if (settings[0].SettingType__c == 'TextArea') {
            settingValue = String.valueOf(settings[0].SettingTextAreaValue__c);
         }
         // If there is no value set, use the DEFAULT value
         else if (String.isBlank(settings[0].SettingValue__c)) {
            settingValue = String.valueOf(settings[0].SettingValueDefault__c);
         } else {
            settingValue = String.valueOf(settings[0].SettingValue__c);
         }

         //Unprotect value if needed
         settingValue = decodeProtected(settingValue);

         settingValue = ReplaceParametersInValue(settingValue);

         // Store the setting in the cache for future calls to use
         SetValue(key, settingValue);
         return settingValue;
      }

      if (!silent) {
         AH_UDC_LogHelper.debug(LoggingLevel.WARN, 'ConfigHelper - Key not found: "' + key + '"');
         DmlException exc = new DmlException();
         AH_UDC_LogHelper.Log('Warn', 'Configuration Settings', AH_UDC_LogHelper.getClassAndMethodName(exc),
                              'AH_UDC_ConfigHelper - Key not found: "' + key + '". ' + exc.getStackTraceString());
      }

      //Setting not found return null
      return null;
   }

   public static void SetValues(Map<String, object> keys) {
      try {
         //Init the cache if it hasn't been already
         if (m_orgCache == null) {
            initOrgCache();
         }

         for (string key : keys.keySet()) {
            object keyValue = keys.get(key);

            // Insert/Update the value for this key in the class cache 
            m_classCache.put(key, keyValue);

            //If the org cache is available add/update it
            if (m_orgCache != null) {
               m_orgCache.put(key, keyValue);
            }
         }
      }
      catch(Exception ex) {
         ex.setMessage('AH_UDC_ConfigHelper.SetValues::' + ex.getMessage());
         AH_UDC_LogHelper.debug(LoggingLevel.ERROR, ex.getMessage());
         throw(ex);
      }
   }

   public static void SetValue(string key, object value) {
      Map<String, object> keys = new Map<String, object> ();
      keys.put(key, value);
      SetValues(keys);
   }

   @TestVisible
   // Used by test classes only, will update the value in the SF object, and in the memory cache
   public static void UpdateValue(string key, String value) {

      AH_UDC_ConfigurationSetting__c cs = [SELECT Id, Name, SettingValue__c from AH_UDC_ConfigurationSetting__c where Name = :key limit 1];

      if (cs == null) {
         throw new AH_UDC_ConfigException('Unable to update ConfigSetting "' + key + '" to ' + value + ' as ConfigSetting does not exist');
      }

      cs.SettingValue__c = value;
      update cs;

      Map<String, object> keys = new Map<String, object> ();
      keys.put(key, value);
      SetValues(keys);
   }

   public static void RemoveKey(string key) {
      //Init the cache if it hasn't been already
      if (m_orgCache != null) {
         m_orgCache.remove(key);
      }
      m_classCache.remove(key);
   }

   public static Boolean ContainsKey(string key) {
      return m_classCache.containsKey(key);
   }

   public class AH_UDC_ConfigException extends Exception { }

   public static final string PROTECTED_PREFIX = 'PROTECTED|';

   public static String protect(String dataToEncode) {
      // Not implemented in custom code
      return dataToEncode;
   }

   private static String decodeProtected(String dataToDecode) {
      if (dataToDecode == null || !dataToDecode.startsWith(PROTECTED_PREFIX)) {
         return dataToDecode;
      } else {
         return dataToDecode.substringAfter(PROTECTED_PREFIX);
      }
   }
}