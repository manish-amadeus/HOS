/**
 * Name          : AH_UDC_WorkbookTriggerHelper
 * Created By    : Amadeus Hospitality Services (Sanjay Parmar)
 * Created Date  : 2021-06-10
 * Description   : This class is the single entry point for processing triggers on object AH_UDC_Workbook__c
 * Dependencies  : 
 **/
public without sharing class AH_UDC_WorkbookTriggerHelper
{
   public static void onTrigger()
   {
      List<NI_Documentation__c> lstNIDocs = null;
      try
      {
         if (Trigger.isAfter && Trigger.isUpdate)
         {
            lstNIDocs = new List<NI_Documentation__c>();
            Id RecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
            for (SObject obj : Trigger.new)
            {
               AH_UDC_Workbook__c objWorkbook = (AH_UDC_Workbook__c) obj;
               if (Test.isRunningTest() && objWorkbook.Name.indexOfIgnoreCase('Exception Test Workbook') > -1) {
                  //Throw divide by zero exception for test class
                  Integer a = 1/0;
               }
               else if(objWorkbook != null && objWorkbook.RecordTypeId == RecordTypeId)
               {
                  lstNIDocs.add(new NI_Documentation__c(Id = objWorkbook.RelatedTo__c, AH_UDC_WorkbookLocked__c = (objWorkbook.SentStatus__c == AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED)));
               }
            }

            if(lstNIDocs != null && lstNIDocs.size() > 0)
            {
               update lstNIDocs;
            }
         }
         else if (Trigger.isBefore && Trigger.isDelete)
         {
            String UDCSystemAdminPermissionSetName = AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetUDCSystemAdministrator', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN);
            AH_UDC_LogHelper.Debug('Config Setting Value (AH_UDC_PermissionSetUDCSystemAdministrator) : ' + UDCSystemAdminPermissionSetName);
            AH_UDC_LogHelper.Debug('Logged In User Name : ' + System.UserInfo.getUserName());
            Integer intCount = (Integer) [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId =: System.UserInfo.getUserId() AND PermissionSet.Name =: UDCSystemAdminPermissionSetName];
            AH_UDC_LogHelper.Debug('intCount : ' + intCount);
            if(intCount == 0)
            { //Don't allow delete for other users than UDC System Admin User
               AH_UDC_LogHelper.Log('Trace', 'AH_UDC_WorkbookTriggerHelper', 'onTrigger', 'The user (' + System.UserInfo.getUserName() + ') is trying to delete workbook sent record');
               Id RecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
               for (SObject sObj : Trigger.old)
               {
                  AH_UDC_Workbook__c objWorkbook = (AH_UDC_Workbook__c) sObj;
                  if (objWorkbook != null && objWorkbook.RecordTypeId == RecordTypeId)
                  {
                     //Prevent other users than UDC System Admin from deleting Workbook sent Record
                     sObj.addError(Label.AH_UDC_NoAccessRightsDelete);
                  }
               }
            }
         }
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC, 
                              'AH_UDC_WorkbookTriggerHelper',
                              'onTrigger', 'An exception occurred during workbook trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + Trigger.new,
                              exc, null, null);
         for (SObject sObj : (Trigger.new != null ? Trigger.new : Trigger.old))
         {
            sObj.addError('An Exception Occurred'); // prevent upsert
         }
      }
      finally
      {
         lstNIDocs = null;
      }
   }
}