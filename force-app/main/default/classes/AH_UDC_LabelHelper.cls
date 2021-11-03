/*
 * File            : AH_UDC_LabelHelper.cls
 * Created Date    : 2020-08-17
 * Created By      : George.Tasker@amadeus.com
 * Description     : Functions that will will process the text in a label to manipulate the text
 *                   and return the result
 * Test classes    : AH_UDC_LabelHelper_TEST.cls
 */
global with sharing class AH_UDC_LabelHelper //implements Callable
{
   public static String TEST_TAG = 'TestTag';
   public static String TEST_TAG_VALUE = 'TestValue';

   public static Map<String, String> Replacements = new Map<String, String>();

   public static string GetFieldLabel(string objectName, string fieldName) {
      string retValue = fieldName;

      try {
         Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
         Schema.SObjectType objSchema = schemaMap.get(objectName);
         Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();

         retValue = fieldMap.get(fieldName).getDescribe().getLabel();
      }
      catch (Exception exc) {
          AH_UDC_LogHelper.Log('Exception', 'AH_UDC_LabelHelper',  AH_UDC_LogHelper.getClassAndMethodName(new DmlException()),
                        'Exception occurred while retrieving a field\'s label', exc, objectName, fieldName);
      }

      return retValue;
   }

   private static void BuildReplacementsMap() {
      // TODO: add any replacements here
      // Replacements.put('ApplicationName', Label.ApplicationName);
      
      if (Test.isRunningTest()) {  // Needed for test class methods
         Replacements.put(TEST_TAG, TEST_TAG_VALUE);
      }
   }

   public static Boolean HasReplacement(string labelName) {
      if (Replacements.size() == 0) {
         BuildReplacementsMap();
      }

      return Replacements.containsKey(labelName);
   }

   public static string GetReplacementString(string labelName) {
      if (Replacements.size() == 0) {
         BuildReplacementsMap();
      }

      if (Replacements.containsKey(labelName)) {
         return Replacements.get(labelName);
      } else {
         return null;
      }
   }

   // Looks for a merge tag anywhere in 'value'.  Each one that is found is looked up in the 
   // config settings to get its value, and then that value (if non-null) replaces the tag
   // in value.
   //
   // If there is more than one tag in the value, the function will keep looping
   // until all tags are replaced
   public static string ReplaceParametersInValue(string value) {
      try {
         if (String.isBlank(value)) return value;

         Integer startIndex = value.indexOf('{!');
         Integer endIndex;
         String key;
         String replacementValue;
      
         if (startIndex == -1) return value;

         Integer startSearchPosition = 0;

         do {
            endIndex = value.substring(startIndex).indexOf('}');
            // There is something wrong in the value, as there is no end to the merge tag
            if (endIndex == -1) {
               System.debug('Warning: LabelHelper detected a tag to replace in a Label value, but the tag was misformed and could not be replaced');
               return value;
            }

            // Extract the config value key name from the tag, so we know which
            // config setting has the value that will replace the merge tag
            key = value.substring(startIndex+2, startIndex+endIndex);

            // Configuration Settings may have a merge tag for an object.field that should not be replaced
            if (!key.contains('.')) {
               replacementValue = GetReplacementString(key);

               // If the replacement string is not defined in the ConfigSettings,
               // then no replacements can be done
               if (replacementValue == null)
               {
                  System.debug('Warning: LabelHelper could not find the replacement value for the label named "' + key + '".');
                  return value;
               }

               // Replace the tag in the value
               value = value.replace('{!' + key + '}', replacementValue);
            } else {
               // The tag that was found is not a merge tag, so skip over it
               startSearchPosition = startIndex + 1;
            }
            startIndex = value.indexOf('{!', startSearchPosition);
         } 
         while (startIndex > -1);

      }
      catch (Exception exc) {
          AH_UDC_LogHelper.Log('Exception', 'LabelHelper',  AH_UDC_LogHelper.getClassAndMethodName(new DmlException()),
                        'Exception occurred while trying to replace parameters in a value (' + value + ')', exc, null, null);
      }

      return value;
   }
}