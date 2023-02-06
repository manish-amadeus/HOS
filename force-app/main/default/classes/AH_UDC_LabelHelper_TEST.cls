/*
 * Name          : AH_UDC_LabelHelper_TEST
 * Created By    : George Tasker
 * Created Date  : 2020 Sep 21
 * Description   : Unit tests for the label helper class
 * Dependencies  :  AH_UDC_LabelHelper.cls
 */
@isTest
public class AH_UDC_LabelHelper_TEST
{
   public class ExtensionMalformedCallException extends Exception { }

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
   }

   @istest static public void testGetFieldLabel(){
      string s =  AH_UDC_LabelHelper.getFieldLabel('AH_UDC_ConfigurationSetting__c', 'UsedBy__c');
      System.assertEquals('Used By', s, ' AH_UDC_LabelHelper.GetFieldLabel() did not return the expected value'); 
   }
 
   @istest static public void testReplacementStringWithNoReplacements(){
      String msg = 'This is a string with no replacements needed';
      string s =  AH_UDC_LabelHelper.replaceParametersInValue(msg);
      System.assertEquals(msg, s, 'Test of a string with no replacements needed failed');
      
      Boolean  hasReplacement =  AH_UDC_LabelHelper.hasReplacement(msg);
      System.assert(hasReplacement != true, 'Test of a string with no replacements needed failed');
   }

   @istest static public void testReplacementStringWithUnknownReplacement() {
      String baseMsg = 'This is a string replacing one value ';
      String tag = 'ThisIsNotAValidMergeTag-FAIL';
      String msg = baseMsg + '{!' + tag + '}';
      string s =  AH_UDC_LabelHelper.replaceParametersInValue(msg);
      System.assertEquals(msg, s, 'Attempt to replace an unknown tag failed with an error');
   }

   @istest static public void testReplacementStringWithOneReplacement() {
      String baseMsg = 'This is a string replacing one value ';
      String msg = baseMsg + '{!' + AH_UDC_LabelHelper.TEST_TAG + '}';
      string s =  AH_UDC_LabelHelper.replaceParametersInValue(msg);
      System.assertEquals(baseMsg + AH_UDC_LabelHelper.TEST_TAG_VALUE, s, 'Failed to replace the one merge tag in the string');
   }

   @istest static public void testReplacementStringSkipThisReplacement() {
      String baseMsg = 'This is a string replacing one value ';
      String msg = baseMsg + '{!NICC__Location__c.Name}';
      string s = AH_UDC_LabelHelper.replaceParametersInValue(msg);
      System.assertEquals(msg, s, 'Replacement should do nothing with this tag that has a "." in it');
   }

   @istest static public void testReplacementStringWithMultipleReplacements() {
      String msg = '{!' + AH_UDC_LabelHelper.TEST_TAG + '}' +' + ' + '{!' + AH_UDC_LabelHelper.TEST_TAG + '}' + ' = 2*' + '{!' + AH_UDC_LabelHelper.TEST_TAG + '}';
      string s =  AH_UDC_LabelHelper.replaceParametersInValue(msg);
      System.assertEquals(AH_UDC_LabelHelper.TEST_TAG_VALUE + ' + ' + AH_UDC_LabelHelper.TEST_TAG_VALUE + ' = 2*' + AH_UDC_LabelHelper.TEST_TAG_VALUE, s, 'Failed to replace multiple merge tags in the string');
   }
}