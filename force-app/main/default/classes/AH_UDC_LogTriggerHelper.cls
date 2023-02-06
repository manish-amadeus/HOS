/**
 * Name          : AH_UDC_LogTriggerHelper
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-04-20
 * Description   : This class is the single entry point for processing triggers on object AH_UDC_Log
 * Dependencies  :
 **/
public with sharing class AH_UDC_LogTriggerHelper {
   @TestVisible
   private static Boolean isException = false;

   public static void onTrigger() {
      try {
         if (Test.isRunningTest() && isException == true) {
            AH_UDC_LogHelper.Debug('AH_UDC_LogTriggerHelper - Exception');
            integer i = 1 / 0;
         }

         if (Trigger.isBefore && (Trigger.isDelete))
         {
            onDeleteStep();
            return;
         }
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_LogTriggerHelper',
                              'onTrigger', 'An exception occurred during Log trigger execution for the User (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ')',
                              exc, null, null);

         // Mark all records as failed due to the unexpected exception that occurred
         for (SObject sObj : (Trigger.new != null ? Trigger.new : Trigger.old))
         {
            sObj.addError(Label.AH_UDC_TriggerException.replace('{0}', 'AH_UDC_LogTriggerHelper')); // prevent deletion
         }
      }
   }

   public static void onDeleteStep() {
      try {
         //Determine if user is System Admin profile
         List<user> adminUsers = [SELECT Id
                              FROM User
                              WHERE Profile.Name = :AH_UDC_Constants.PROFILE_DEFAULT_NAME_SYSTEM_ADMINISTRATOR 
                              AND IsActive = true AND Id = :UserInfo.getUserId()];
         Boolean isSystemAdmin = adminUsers != null && adminUsers.size() == 1;

         //If user is not system admin and Log records of type Audit are being deleted, flag them as an error
         for (AH_UDC_Log__c log : (List<AH_UDC_Log__c>)Trigger.old) {
            if (log.Level__c == AH_UDC_LogHelper.LogLevel_AUDIT && !isSystemAdmin) {
               log.addError(Label.AH_UDC_LogTriggerDeleteNotAllowed_Error);
            }
         }
      } catch (exception exc) {
         System.Debug(AH_UDC_LogHelper.getClassAndMethodName(new DmlException()) + ': Exception occurred: ' + exc.getMessage() + ' | ' + exc.getStackTraceString());
         throw exc;
      }
   }
}