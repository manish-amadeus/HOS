/*
 * File            : PrefixHelper.cls
 * Created By      : Someone long long ago!
 * Modified Date   : 2019-Nov-14
 * Modified By     : George.Tasker@amadeus.com
 * Description     : Determines if the code is running with Managed Package code
 *                   which means there is a AHUDC namespace on the object, classe,
 *                   and field names.  Implements functions that will return the
 *                   object, class, and field names with or without the namespace
 *                   depending on whether packaged Central Sales cod eis installed
 * Test class      : AH_UDC_PrefixHelper_TEST.cls
 *
 * Callable Interface
 *    Actions and their Arguments:
 *       getObjectPrefix:        No parameters
 *       getClassPrefix:         No parameters
 *       getFieldPrefix:         No parameters
 *       getRemoteActionPrefix:  No parameters
 *       getNamespace:           No parameters
 *       getObjectName:          "baseName"
 *       getClassName:           "baseName"
 *       getFieldName            "baseName"
 */
public with sharing class AH_UDC_PrefixHelper implements Callable
{
   @TestVisible
   private static string namespace = null;

   ////////////
   // Provides a callable interface method for invoking functions in this class
   // that we want accessible to unmanaged pacakge code
   //
   // On any error, such as an unrecognized Action, or bad Arguments, this function will return an
   // exception of type ExtensionMalformedCallException
   ////////////
   public Object call(String action, Map<String, Object> args)
   {
      Switch on action {
         when 'getNamespace' {
            return getNamespace();
         }
         when 'getObjectPrefix' {
            return getObjectPrefix();
         }
         when 'getClassPrefix' {
            return getClassPrefix();
         }
         when 'getFieldPrefix' {
            return getClassPrefix();
         }
         when 'getRemoteActionPrefix' {
            return getRemoteActionPrefix();
         }
         when 'getObjectName' {
            string argName = 'baseName';

            // Ensure that ARG_NAME was specified
            if (!args.containsKey(argName) || String.isBlank((String) args.get(argName))) { throw new ExtensionMalformedCallException(action + ': Missing argument/value for \'' + argName + '\'.'); }

            return getObjectName((string) args.get(argName));
         }
         when 'getClassName' {
            string argName = 'baseName';

            // Ensure that ARG_NAME was specified
            if (!args.containsKey(argName) || String.isBlank((String) args.get(argName))) { throw new ExtensionMalformedCallException(action + ': Missing argument /value for \'' + argName + '\'.'); }

            return getClassName((string) args.get(argName));
         }
         when 'getFieldName' {
            string argName = 'baseName';

            // Ensure that ARG_NAME was specified
            if (!args.containsKey(argName) || String.isBlank((String) args.get(argName))) { throw new ExtensionMalformedCallException(action + ': Missing argument/value for \'' + argName + '\'.'); }

            return getFieldName((string) args.get(argName));
         }
         when 'getApexRestUrl'{
            string argName = 'baseApexRestUrl';

            // Ensure that ARG_NAME was specified
            if (!args.containsKey(argName) || String.isBlank((String) args.get(argName))) { throw new ExtensionMalformedCallException(action + ': Missing argument/value for \'' + argName + '\'.'); }

            return getApexRestUrl((string) args.get(argName));
         }
         when 'objectExists'{
            string argName = 'ObjectNameParam';

            // Ensure that ARG_NAME was specified
            if (!args.containsKey(argName) || String.isBlank((String) args.get(argName))) { throw new ExtensionMalformedCallException(action + ': Missing argument/value for \'' + argName + '\'.'); }

            return objectExists((string) args.get(argName));
         }
         when else {
            throw new ExtensionMalformedCallException('Method not implemented (' + action + ')');
         }
      }
   }

   private static boolean objectExists(String objectNameParam) {
      for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values()) {
         String objName = String.valueOf(sObjectType);
         if (objName.contains(objectNameParam)) { return true; }
      }
      return false;
   }

   public static string getNamespace() {
      if (namespace == null) {
         namespace = '';
         // If class with namespace exist
         Type dynamicApexType = Type.forName('AHUDC.Constants');
         if (dynamicApexType != null) {
            namespace = AH_UDC_Constants.APPLICATION_PREFIX;
         }
      }

      return namespace;
   }

   public static string getObjPrefix() {
      string s = getNamespace();
      if (s.length() > 0) { s += '__'; }

      return s;
   }

   public static string getObjectPrefix() {
      string s = getNamespace();
      if (s.length() > 0) { s += '__'; }

      return s;
   }

   public static string getFieldSetPrefix() {
      string s = getNamespace();
      if (s.length() > 0) { s += '__'; }

      return s;
   }

   public static string getClassPrefix() {
      string s = getNamespace();
      if (s.length() > 0) { s += '.'; }

      return s;
   }

   public static string getFieldPrefix() {
      string s = getNamespace();
      if (s.length() > 0) { s += '__'; }

      return s;
   }

   public static String getRemoteActionPrefix() {
      string s = getNamespace();
      if (s.length() > 0) { s += '.'; }

      return s;
   }

   public static String getUrlPrefix() {
      string s = getNamespace();
      if (s.length() > 0) { s += '__'; }

      return s;
   }

   public static string getObjectName(string baseObjectName) {
      string namespacePrefix = getObjectPrefix();
      if (String.isBlank(namespacePrefix)) {
         return baseObjectName;
      }

      // If this is not a custom object, it is a standard Salesforce object, so
      // return the baseObjectName unchanged
      if (!baseObjectName.endsWith('__c')) {
         return baseObjectName;
      }

      // This is a managed package object, might be AHUDC, might not be, 
      // but it already has a namespace prefix, so return it unchanged
      if (baseObjectName.indexOf('__') != baseObjectName.lastIndexOf('__')) {
         return baseObjectName;
      }

      // Whereas this function is CALLABLE, this makes sure we don't add a prefix
      // to the object name if it is one of the Solution Delivery prefixes
      for (String prefix : AH_UDC_Constants.SOLUTION_DELIVERY_PREFIXES) {
         if (baseObjectName.startsWith(prefix)) {
            return baseObjectName;
         }
      }

      return getObjectPrefix() + baseObjectName;
   }

   public static string getFieldSetName(string baseFieldSetName) {
      return getFieldSetPrefix() + baseFieldSetName;
   }

   public static string getClassName(string baseClassName) {
      return getClassPrefix() + baseClassName;
   }

   public static string getFieldName(string baseFieldName) {
      return getFieldPrefix() + baseFieldName;
   }
   public static string getApexRestUrl(string baseApexRestUrl) {
      return baseApexRestUrl.replace('apexrest/', 'apexrest/' + getUrlPrefix());
   }

   // To throw exceptions
   public class ExtensionMalformedCallException extends Exception { }
}