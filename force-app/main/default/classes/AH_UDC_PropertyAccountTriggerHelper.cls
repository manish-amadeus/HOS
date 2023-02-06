/**
 * Name          : AH_UDC_PropertyAccountTriggerHelper
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-09-23
 * Description   : This class is the single entry point for processing triggers on object AH_UDC_PropertyAccount__c
 * Dependencies  : 
 **/

public class AH_UDC_PropertyAccountTriggerHelper {
   public static void onTrigger() {
      System.debug('$$$AH_UDC_PropertyAccountTriggerHelper');
      try
      {
         if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
         {
            if(Test.isRunningTest() && Trigger.new.size() >0 && ((AH_UDC_PropertyAccount__c)Trigger.new[0]).PropertyName__c == 'Test Property Account Exception') Integer i = 1/0;
            for (SObject sObj : Trigger.new)
            {
               AH_UDC_PropertyAccount__c pa = (AH_UDC_PropertyAccount__c) sObj;
               if (String.isBlank(pa.securitycode__c)) {
                  pa.securitycode__c = AH_UDC_Shared.GetSecurityCode();
               }
            }
         }
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_PropertyAccountTriggerHelper', 'onTrigger',
                              'An exception occurred: ' + exc.getMessage(),
                              exc, null, null);
         for (SObject sObj : (Trigger.new != null ? Trigger.new : Trigger.old))
         {
            sObj.addError(System.Label.AH_UDC_PropertyAccountTriggerHelper_ExceptionOccurred); // prevent upsert
         }
      }
   }
}