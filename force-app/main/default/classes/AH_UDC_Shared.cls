/**
 * Name          : AH_UDC_Shared
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-Feb-02
 * Description   : Re-usable common methods for UDC code that do enforce Object/FLS security (WITH SHARING)
 * Dependencies  : 
 **/

public with sharing class AH_UDC_Shared {
   public class UDCException extends System.Exception {
   }
   private static String kHexChars = '0123456789abcdefABCDEF';

   public static String GetSecurityCode() {
      return generateGUID() + generateGUID();
   }

   //Decrypt token
   public static Token DecryptToken(String token)
   {
      String sEncryptionKey = AH_UDC_ConfigHelper.GetString('AH_UDC_ViewWorkbookTokenEncryptionKey', '');
     
      if (!String.isEmpty(sEncryptionKey) && AH_UDC_ConfigHelper.GetBoolean('AH_UDC_ViewWorkbookTokenEncryption', true)) {
         Blob key = EncodingUtil.base64Decode(sEncryptionKey);
         token = token.replace('_2f_', '/').replace('_2b_', '+'); //Base64 has 2 special characters / + that are not compatible with a URL ID
         Blob data = EncodingUtil.base64Decode(token);
         Blob decryptedData = Crypto.decryptWithManagedIV('AES256', key, data);
         token = decryptedData.toString();
      }
      Token returnToken = new Token();

      String[] tokenParts = token.split('_');
      if (tokenParts.size() != 4) return returnToken; //Invalid Token

      returnToken.SecurityCode = tokenParts[0];
      returnToken.ResponderUserId = tokenParts[1];
      returnToken.FormId = tokenParts[2];
      returnToken.StepId = tokenParts[3];

      //Verify that "Null" was not passed as text
      returnToken.SecurityCode = (returnToken.SecurityCode != null && returnToken.SecurityCode.toUpperCase() == 'NULL' ? null : returnToken.SecurityCode);
      returnToken.ResponderUserId = (returnToken.ResponderUserId != null && returnToken.ResponderUserId.toUpperCase() == 'NULL' ? null : returnToken.ResponderUserId);
      returnToken.FormId = (returnToken.FormId != null && returnToken.FormId.toUpperCase() == 'NULL' ? null : returnToken.FormId);
      returnToken.StepId = (returnToken.StepId != null && returnToken.StepId.toUpperCase() == 'NULL' ? null : returnToken.StepId);

      if (String.isBlank(returnToken.SecurityCode) || String.isBlank(returnToken.ResponderUserId) || String.isBlank(returnToken.FormId) || String.isBlank(returnToken.StepId)) 
         returnToken.IsValid = false;
      else
         returnToken.IsValid = true; //Token is valid
      return returnToken;
   }

   //Creates a token
   public static string CreateStepToken(String SecurityCode, string FormId, string stepId)
   {
      string token = SecurityCode + '_' + UserInfo.getUserId() + '_' + FormId + '_' + stepId;
      //Encrypt token
      string sEncryptionKey = AH_UDC_ConfigHelper.GetString('AH_UDC_ViewWorkbookTokenEncryptionKey', '');
      
      if (!String.isEmpty(sEncryptionKey) && AH_UDC_ConfigHelper.GetBoolean('AH_UDC_ViewWorkbookTokenEncryption', true)) {
         Blob key = EncodingUtil.base64Decode(sEncryptionKey);
         Blob data = Blob.valueOf(token);
         Blob encryptedData = Crypto.encryptWithManagedIV('AES256', key, data);
         token = EncodingUtil.base64Encode(encryptedData).replace('/', '_2f_').replace('+', '_2b_'); //Base64 has 2 special characters / + that are not compatible with a URL ID
      }
      token = AH_UDC_Constants.FORM_TOKEN_PREFIX + token;
      return token;
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

   public class Token {
      public string SecurityCode;
      public string ResponderUserId;
      public string FormId;
      public string StepId;
      public boolean IsValid;
      public Token() {
         IsValid = false;
      }
   }

   public class FormField {
      public string Name;
      public string APIName;
      public string Repeat;
      public string DefaultValue;
      public string Picklist;
      public string InputType;

      public FormField() {
      }
   }
   public class AmadeusFormDefinition
   {
      public string title { get; set; }
      public string product { get; set; }
      public List<Formulas> formulas { get; set; }
      public List<section> sections { get; set; }
      public AmadeusFormDefinition() { }
   }

   // Root myDeserializedClass = JsonConvert.DeserializeObject<Root>(myJsonResponse); 
   public class Validation
   {
      public string required { get; set; }
      public string minlength { get; set; }
      public string maxlength { get; set; }
      public string onlynumber { get; set; }
      public string onlyalpha { get; set; }
      public string alphanumeric { get; set; }
      public string allowpastdate { get; set; }
   }

   public class DynamicSource
   {
      public string formid { get; set; }
      public string formfield { get; set; }
   }
   public class Options
   {
      public string format { get; set; }
   }
   public class Source
   {
      public Source()
      {
      }
      public string id { get; set; }
      public string name { get; set; }
   }

   public class Field
   {
      public Field()
      {
      }

      public string title { get; set; }
      public string name { get; set; }
      public string type { get; set; }
      public string width { get; set; }
      public string tooltip { get; set; }
      public string placeholder { get; set; }
      public string mask { get; set; }
      public Validation validation { get; set; }
      public List<Source> source { get; set; }
      public DynamicSource dynamicsource { get; set; }
      public Options options { get; set; }
      public string readOnly { get; set; }
      public string autocomplete { get; set; }
      public string labelabove { get; set; }
      public string defaultvalue { get; set; }
      public string value { get; set; }
      public string wordwrap { get; set; }
      public string contenttype { get; set; }
      public List<Formulas> formulas { get; set; }
   }
   public class Formulas
   {
      public string type { get; set; }
      public string formula { get; set; }
      public string formulafields { get; set; }
      public string ids { get; set; }
   }

   public class section
   {
      public section()
      {
      }

      public string title { get; set; }
      public string apiname { get; set; }
      public string repeat { get; set; }
      public string gridview { get; set; }
      public string inline { get; set; }
      public string scrollable { get; set; }
      public string maxheight { get; set; }
      public List<section> insidesections { get; set; }
      public List<Field> fields { get; set; }
      public string repeatsectionof { get; set; }
      public List<Field> getDynamicPicklists() {
         try {
            List<Field> returnFields = new List<Field> ();
            if (fields != null && fields.size()> 0)
            {
               for (Field ff : fields) {
                  if (ff.type == 'dropdown' && ff.dynamicSource != null) {
                     returnFields.add(ff);
                  }
               }
            }
            return returnFields;
         }
         catch(Exception exc) {
            AH_UDC_LogHelper.Debug('AmadeusFormField-getDynamicPicklists-returnFields-exception: ' + exc);
            //This is purposely not logged here; logged by the caller
            throw(exc);
         }
      }
      public List<Field> getDynamicRadioGroups() {
         try {
            List<Field> returnFields = new List<Field> ();
            if (fields != null && fields.size() > 0)
            {
               for (Field ff : fields) {
                  if (ff.type == 'radiogroup' && ff.dynamicSource != null) {
                     returnFields.add(ff);
                  }
               }
            }
            return returnFields;
         }
         catch(Exception exc) {
            AH_UDC_LogHelper.Debug('AmadeusFormField-getDynamicPicklists-returnFields-exception: ' + exc);
            //This is purposely not logged here; logged by the caller
            throw(exc);
         }
      }
      public List<Field> getDynamicDefaults() {
         try {
            List<Field> returnFields = new List<Field> ();
            if (fields != null && fields.size() > 0)
            {
               for (Field ff : fields) {
                  if ((ff.type == 'text' || ff.type == 'hidden') && ff.dynamicSource != null) {
                     returnFields.add(ff);
                  }
               }
            }
            return returnFields;
         }
         catch(Exception exc) {
            AH_UDC_LogHelper.Debug('AmadeusFormField-getDynamicDefaults-returnFields-exception: ' + exc);
            //This is purposely not logged here; logged by the caller
            throw(exc);
         }
      }
   }
}