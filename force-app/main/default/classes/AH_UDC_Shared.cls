/**
 * Name          : AH_UDC_Shared
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-Feb-02
 * Description   : Re-usable common methods for UDC code that do enforce Object/FLS security (WITH SHARING)
 * Dependencies  : 
 **/

public with sharing class AH_UDC_Shared {
   //TODO:ROBDEV:Move the methods in this class that need to run without FLS security to AH_UDC_SharedWithoutSharing.cls 

   

   private static String kHexChars = '0123456789abcdefABCDEF';

   public static String GetSecurityCode() {
      return generateGUID() + generateGUID();
   }

   //This method generates a sudo GUID, it will return any exception to the sender
   public static String generateGUID() {
      //There is purposely no try/catch here

      String returnValue = '';
      Integer nextByte = 0;
      for (Integer i = 0; i< 16; i++) {
         if (i == 4 || i == 6 || i == 8 || i == 10) {
            returnValue += '-';
         }
         //generate a "byte"; i.e., number in range [-2^7,2^7-1]
         nextByte = (Math.round(Math.random() * 255) - 128) & 255;

         if (i == 6) {
            nextByte = nextByte & 15;
            nextByte = nextByte | (4 << 4);
         }
         if (i == 8) {
            nextByte = nextByte & 63;
            nextByte = nextByte | 128;
         }

         returnValue += charAt(kHexChars, nextByte> > 4);
         returnValue += charAt(kHexChars, nextByte & 15);
      }
      return returnValue;
   }

   @TestVisible
   //This is a helper method for generateGUID
   private static String charAt(String str, Integer index) {
      if (str == null) {
         return null;
      }
      if (str.length() <= 0) {
         return str;
      }
      if (index< 0 || index >= str.length()) {
         return null;
      }
      return str.substring(index, index + 1);
   }

   public static boolean InitializeFormTokenEncryptionKey() {
      //Check the configuration setting for Form Token Encryption Certificate; if not populated update it.
      try {
         string certificate = AH_UDC_ConfigHelper.GetString('AH_UDC_ViewWorkbookTokenEncryptionKey', '');
         if (string.isEmpty(certificate)) {
            //Generate token to be used
            Blob key = Crypto.generateAesKey(256);
            string sKey = EncodingUtil.base64Encode(key);
            AH_UDC_ConfigHelper.UpdateValue('AH_UDC_ViewWorkbookTokenEncryptionKey', sKey);
         }
         return true;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_Shared.InitializeFormTokenEncryptionKey - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_Shared', 'InitializeFormTokenEncryptionKey',
                              'An exception occurred: ' + exc.getMessage(),
                              exc, null, null);
         return false;
      }
   }
   
   public class FormDefinition {
      public string Title;
      public List<FormField> Fields;

      public FormDefinition() {
      }

      public FormField getFieldByName(string name) {
         FormField returnField = null;
         for (FormField ff : fields) {
            if (ff.Name == name) {
               returnField = ff;
               break;
            }
         }
         return returnField;
      }

      public FormField getFieldByAPIName(string name) {
         if (name.contains('[')) {
            name = name.substringBefore('[');
         }
         FormField returnField = null;
         for (FormField ff : fields) {
            if (ff.APIName == name) {
               returnField = ff;
               break;
            }
         }
         return returnField;
      }

      public List<FormField> getPicklists() {
         try {
            List<FormField> returnFields = new List<FormField> ();
            for (FormField ff : fields) {
               if (ff.Picklist != null && ff.Picklist.toUpperCase() == 'TRUE') {
                  returnFields.add(ff);
               }
            }
            return returnFields;
         }
         catch(Exception exc) {
            AH_UDC_LogHelper.Debug('FormField-getPicklists-returnFields-exception: ' + exc);
            //This is purposely not logged here; logged by the caller
            throw(exc);
         }
      }
   }

   public class FormField {
      public string Name;
      public string APIName;
      public string Repeat;
      public string DefaultValue;
      public string Picklist;

      public FormField() {
      }
   }

}