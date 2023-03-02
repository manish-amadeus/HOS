<<<<<<< HEAD
/*
  Name            : AH_UDC_DateFormat_TEST
  Author          : George Tasker (george.tasker@amadeus.com   
  Created Date    : 2021-Sep-23
  Description     : Date formatting based on Current User locale
 */
@isTest
public class AH_UDC_DateFormat_TEST {

   // There are several SF locales that are not standard that have very long names, this test class skips those
   private static Integer MAX_ALLOWED_LOCALE_NAME_LENGTH = 8;

   // Add any additional locales to these lists to test for additional locales.  These are the expected Date Separator/Date Format
   // that we expect Salesforce to return for each defined locales
   //    en_US : US English
   //    fr_FR : France French
   //    km_KH : Cambodia
   //    ko    : Korea
   //    is    : Icelandic
   //    alb   : Albania
   private static List<String> TEST_LOCALES = new List<String> { 'en_US', 'fr_FR', 'km_KH', 'ko', 'is', 'alb' };
   private static List<String> TEST_LOCALE_SEPS = new List<String> { '/', '/', '/', '. ', '.', '-' };
   private static List<String> TEST_LOCALE_FORMATS = new List<String> { 'M/d/yyyy', 'dd/MM/yyyy', 'd/M/yyyy', 'yyyy. M. d', 'd.M.yyyy', 'yyyy-MM-dd' };

   @testSetup
   static void setup()
   {
      // Retrieve the list of valid Locales from the picklist on the User object
      List<Schema.PicklistEntry> listPE = Schema.SObjectType.User.fields.LocaleSidKey.PicklistValues;

      List<User> testUsers = new List<User> ();
      Integer i = 1;
      for (PicklistEntry pe : listPE) {
         if (TEST_LOCALES.contains(pe.getValue()))
         {
            // Skip the extended named locales
            if (pe.getValue().length() > MAX_ALLOWED_LOCALE_NAME_LENGTH) {
               System.debug('Locale skipped due to Locale Name length: ' + pe.getValue());
               continue;
            }            
            User u = AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                               AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                               'UDCSystemAdminDateFormat'+i, null, false);
            
            i++;
            u.localesidkey = pe.getValue();
            testUsers.add(u);
         }
      }

      insert testUsers;
   }

   @isTest
   private static void testLocales() {
      // Build a map of the expected values
      Map<String, SepFormat> mapTestLocales = new Map<String, SepFormat> ();
      for (Integer i = 0; i<TEST_LOCALES.size(); i++) {
         System.debug(TEST_LOCALES[i] + ';' + TEST_LOCALE_SEPS[i] + ';' + TEST_LOCALE_FORMATS[i]);
         SepFormat sdf = new SepFormat();
         sdf.Sep = TEST_LOCALE_SEPS[i];
         sdf.DateFormat = TEST_LOCALE_FORMATS[i];
         mapTestLocales.put(TEST_LOCALES[i], sdf);
      }

      // Retrieve the Users created in setup to use as test users      
      List<User> listUsers = [SELECT Id, LocaleSidKey FROM User WHERE Username like 'TestUDCSystemAdminDateFormat%'];

      // Test for the expected Date Separator and Date Format for each of the test users
      for (User u : listUsers) {
         System.RunAs(u) {
            System.assertEquals(mapTestLocales.get(u.LocaleSidKey).Sep, AH_UDC_DateFormat.DateSeparator(), 'Locale "' + u.LocaleSidKey + '" did not get back the expected date separator');
            System.assertEquals(mapTestLocales.get(u.LocaleSidKey).DateFormat, AH_UDC_DateFormat.DateFormatString(), 'Locale "' + u.LocaleSidKey + '" did not get back the expected date format string');
         }
      }
   }

   // Used to hold the expected Date Separator/Date Format values for specific test locales
   private class SepFormat {
      public String Sep;
      public String DateFormat;
   }
=======
/*
  Name            : AH_UDC_DateFormat_TEST
  Author          : George Tasker (george.tasker@amadeus.com   
  Created Date    : 2021-Sep-23
  Description     : Date formatting based on Current User locale
 */
@isTest
public class AH_UDC_DateFormat_TEST {

   // There are several SF locales that are not standard that have very long names, this test class skips those
   private static Integer MAX_ALLOWED_LOCALE_NAME_LENGTH = 8;

   // Add any additional locales to these lists to test for additional locales.  These are the expected Date Separator/Date Format
   // that we expect Salesforce to return for each defined locales
   //    en_US : US English
   //    fr_FR : France French
   //    km_KH : Cambodia
   //    ko    : Korea
   //    is    : Icelandic
   //    alb   : Albania
   private static List<String> TEST_LOCALES = new List<String> { 'en_US', 'fr_FR', 'km_KH', 'ko', 'is', 'alb' };
   private static List<String> TEST_LOCALE_SEPS = new List<String> { '/', '/', '/', '. ', '.', '-' };
   private static List<String> TEST_LOCALE_FORMATS = new List<String> { 'M/d/yyyy', 'dd/MM/yyyy', 'd/M/yyyy', 'yyyy. M. d', 'd.M.yyyy', 'yyyy-MM-dd' };

   @testSetup
   static void setup()
   {
      // Retrieve the list of valid Locales from the picklist on the User object
      List<Schema.PicklistEntry> listPE = Schema.SObjectType.User.fields.LocaleSidKey.PicklistValues;

      List<User> testUsers = new List<User> ();
      Integer i = 1;
      for (PicklistEntry pe : listPE) {
         if (TEST_LOCALES.contains(pe.getValue()))
         {
            // Skip the extended named locales
            if (pe.getValue().length() > MAX_ALLOWED_LOCALE_NAME_LENGTH) {
               System.debug('Locale skipped due to Locale Name length: ' + pe.getValue());
               continue;
            }            
            User u = AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                               AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                               'UDCSystemAdminDateFormat'+i, null, false);
            
            i++;
            u.localesidkey = pe.getValue();
            testUsers.add(u);
         }
      }

      insert testUsers;
   }

   @isTest
   private static void testLocales() {
      // Build a map of the expected values
      Map<String, SepFormat> mapTestLocales = new Map<String, SepFormat> ();
      for (Integer i = 0; i<TEST_LOCALES.size(); i++) {
         System.debug(TEST_LOCALES[i] + ';' + TEST_LOCALE_SEPS[i] + ';' + TEST_LOCALE_FORMATS[i]);
         SepFormat sdf = new SepFormat();
         sdf.Sep = TEST_LOCALE_SEPS[i];
         sdf.DateFormat = TEST_LOCALE_FORMATS[i];
         mapTestLocales.put(TEST_LOCALES[i], sdf);
      }

      // Retrieve the Users created in setup to use as test users      
      List<User> listUsers = [SELECT Id, LocaleSidKey FROM User WHERE Username like 'TestUDCSystemAdminDateFormat%'];

      // Test for the expected Date Separator and Date Format for each of the test users
      for (User u : listUsers) {
         System.RunAs(u) {
            System.assertEquals(mapTestLocales.get(u.LocaleSidKey).Sep, AH_UDC_DateFormat.DateSeparator(), 'Locale "' + u.LocaleSidKey + '" did not get back the expected date separator');
            System.assertEquals(mapTestLocales.get(u.LocaleSidKey).DateFormat, AH_UDC_DateFormat.DateFormatString(), 'Locale "' + u.LocaleSidKey + '" did not get back the expected date format string');
         }
      }
   }

   // Used to hold the expected Date Separator/Date Format values for specific test locales
   private class SepFormat {
      public String Sep;
      public String DateFormat;
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}