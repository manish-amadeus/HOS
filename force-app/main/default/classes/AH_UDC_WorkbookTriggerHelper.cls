/**
 * Name          : AH_UDC_WorkbookTriggerHelper
 * Created By    : Amadeus Hospitality Services (Sanjay Parmar)
 * Created Date  : 2021-06-10
 * Description   : This class is the single entry point for processing triggers on object AH_UDC_Workbook__c
 * Dependencies  : 
 **/
public with sharing class AH_UDC_WorkbookTriggerHelper
{
   @TestVisible public static Boolean IsWorkbookSentRecordTypeForException = false;

   public static void onTrigger()
   {
      List<NI_Documentation__c> lstNIDocs = null;
      List<AH_UDC_Workbook__c> lstWorkbook = null;
      try {
        
         if (Trigger.isBefore && Trigger.isUpdate) {
            Set<Id> workbookSentRecordSet = new Set<Id> ();
            Id WorkbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
            if (Test.isRunningTest() && IsWorkbookSentRecordTypeForException == true) WorkbookSentRecordTypeId = null; // Check for record type id is null for testing

            if (String.isNotBlank(String.valueOf(WorkbookSentRecordTypeId))) {
               for (SObject obj : Trigger.new) {
                  AH_UDC_Workbook__c objWorkbookSent = (AH_UDC_Workbook__c) obj;
                  if (objWorkbookSent.RecordTypeId == WorkbookSentRecordTypeId) {
                     workbookSentRecordSet.add(objWorkbookSent.Id);
                  }
               }

               if (workbookSentRecordSet.size() > 0) {
                  List<AH_UDC_Workbook__c> lstWorkbookSents = [SELECT Id, Product__c
                                                               FROM AH_UDC_Workbook__c
                                                               WHERE Id IN :workbookSentRecordSet];
                  for (AH_UDC_Workbook__c objWorkbookSent : lstWorkbookSents) {
                     for (SObject obj : Trigger.new) {
                        AH_UDC_Workbook__c objWorkbookSentNew = (AH_UDC_Workbook__c) obj;
                        if (objWorkbookSent.Id == objWorkbookSentNew.Id) {
                           if (objWorkbookSent.Product__c != objWorkbookSentNew.Product__c) {
                              //If product field value changed for workbook sent record then do not process update
                              obj.addError(Label.AH_UDC_ProductFieldNotEditableMessage);
                           }
                           break;
                        }
                     }
                  }
               }
            }
            else {
               AH_UDC_LogHelper.Debug('Workbook Sent record type not found');
               AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                                    'AH_UDC_WorkbookTriggerHelper',
                                    'onTrigger - Before Update', 'An error occurred during workbook trigger (Before Update) execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + Trigger.new + ' Error : Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT,
                                    null, null, null);

               for (SObject sObj : Trigger.new) {
                  sObj.addError('An error occurred in before update workbook record(s). Please contact UDC System Administrator.');
               }
               return;
            }
         }
	
         if ((Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) || (Trigger.isAfter && Trigger.isUndelete)) {
            Set<Id> setWorkbookId = new Set<Id> ();
            Set<String> setWorkbookName = new Set<String> ();

            // Get the RecordType Id for WORKBOOK
            Id RecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
            if (Test.isRunningTest() && IsWorkbookSentRecordTypeForException == true) RecordTypeId = null; // Check for record type id is null for testing

            if (String.isNotBlank(String.valueOf(RecordTypeId))) {
               for (SObject obj : Trigger.new) {
                  AH_UDC_Workbook__c objWorkbook = (AH_UDC_Workbook__c) obj;
                  if (objWorkbook.RecordTypeId == RecordTypeId) {
                     if (setWorkbookName.contains(objWorkbook.Name)) {
                        obj.addError(Label.AH_UDC_DuplicateWorkbookNameMessage);
                        break;
                     }
                     else {
                        setWorkbookId.add(objWorkbook.Id);
                        setWorkbookName.add(objWorkbook.Name);
                     }
                  }
               }

               // Process only the records where RecordType is WORKBOOK
               if (setWorkbookName.size() > 0) {
                  List<AH_UDC_Workbook__c> lstDuplicateWorkbook = null;
                  if (Trigger.isUpdate || Trigger.isUndelete) {
                     lstDuplicateWorkbook = [SELECT Id, Name
                                             FROM AH_UDC_Workbook__c
                                             WHERE RecordTypeId = :RecordTypeId
                                             AND Name IN :setWorkbookName
                                             AND Id NOT IN :setWorkbookId];
                  } else {
                     lstDuplicateWorkbook = [SELECT Id, Name
                                             FROM AH_UDC_Workbook__c
                                             WHERE RecordTypeId = :RecordTypeId
                                             AND Name IN :setWorkbookName];
                  }

                  if (lstDuplicateWorkbook.size() > 0) {
                     for (AH_UDC_Workbook__c objDuplicateWorkbook : lstDuplicateWorkbook) {
                        for (SObject obj : Trigger.new) {
                           AH_UDC_Workbook__c objWorkbook = (AH_UDC_Workbook__c) obj;
                           if (objWorkbook.Name == objDuplicateWorkbook.Name) {
                              obj.addError(Label.AH_UDC_DuplicateWorkbookNameMessage);
                              break;
                           }
                        }
                     }
                  }
               }
            }
            else {
               AH_UDC_LogHelper.Debug('Workbook record type not found');
               AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                                    'AH_UDC_WorkbookTriggerHelper',
                                    'onTrigger - Before Update/Insert/UnDelete', 'An error occurred during workbook trigger (Before Update/Insert/UnDelete) execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + Trigger.new + ' Error : Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK,
                                    null, null, null);

               for (SObject sObj : Trigger.new) {
                  sObj.addError('An error occurred in before update/insert/undelete workbook record(s). Please contact UDC System Administrator.');
               }
            }
            return;
         }

         if (Trigger.isAfter && Trigger.isUpdate) {
            lstNIDocs = new List<NI_Documentation__c> ();
            Id RecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
            if (Test.isRunningTest() && IsWorkbookSentRecordTypeForException == true) RecordTypeId = null; // Check for record type id is null for testing

            if (String.isNotBlank(String.valueOf(RecordTypeId))) {
               for (SObject obj : Trigger.new) {
                  AH_UDC_Workbook__c objWorkbook = (AH_UDC_Workbook__c) obj;
                  if (Test.isRunningTest() && objWorkbook.Name.indexOfIgnoreCase('Exception Test Workbook') > - 1) {
                     //Throw divide by zero exception for test class
                     Integer a = 1 / 0;
                  } else if (objWorkbook != null && objWorkbook.RecordTypeId == RecordTypeId) {
                     lstNIDocs.add(new NI_Documentation__c(Id = objWorkbook.RelatedTo__c, AH_UDC_WorkbookLocked__c = (objWorkbook.SentStatus__c == AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED)));
                  }
               }

               if (lstNIDocs != null && lstNIDocs.size() > 0) {
                  AH_UDC_SystemContext.UpdateObjects(lstNIDocs);
               }
            }
            else {
               AH_UDC_LogHelper.Debug('Workbook sent record type not found');
               AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                                    'AH_UDC_WorkbookTriggerHelper',
                                    'onTrigger - After Update', 'An error occurred during workbook trigger (After Update) execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + Trigger.new + ' Error : Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT,
                                    null, null, null);

               for (SObject sObj : Trigger.new) {
                  sObj.addError('An error occurred in updating workbook record(s). Please contact UDC System Administrator.');
               }
            }
         } else if (Trigger.isBefore && Trigger.isDelete) {
            //Determine if the current user has the UDC System Admin permission set assigned to them
            String UDCSystemAdminPermissionSetName = AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetUDCSystemAdministrator', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN); AH_UDC_LogHelper.Debug('Config Setting Value (AH_UDC_PermissionSetUDCSystemAdministrator) : ' + UDCSystemAdminPermissionSetName);
            AH_UDC_LogHelper.Debug('Logged In User Name : ' + System.UserInfo.getUserName());
            Integer intCount = (Integer) [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :System.UserInfo.getUserId() AND PermissionSet.Name = :UDCSystemAdminPermissionSetName];
            AH_UDC_LogHelper.Debug('intCount : ' + intCount);

            //Don't allow delete by users other than UDC System Admin users
            if (intCount == 0) {
               AH_UDC_LogHelper.Log('Trace', 'AH_UDC_WorkbookTriggerHelper', 'onTrigger', 'The user (' + System.UserInfo.getUserName() + ') is trying to delete a WORKBOOK_SENT record');
               Id RecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
               if (Test.isRunningTest() && IsWorkbookSentRecordTypeForException == true) RecordTypeId = null; // Check for record type id is null for testing

               if (String.isNotBlank(String.valueOf(RecordTypeId))) {
                  //Prevent users who are not UDC System Admin from deleting WORKBOOK_SENT records
                  for (SObject sObj : Trigger.old) {
                     AH_UDC_Workbook__c objWorkbook = (AH_UDC_Workbook__c) sObj;
                     if (objWorkbook != null && objWorkbook.RecordTypeId == RecordTypeId) {
                        sObj.addError(Label.AH_UDC_NoAccessRightsDelete);
                     }
                  }
               }
               else {
                  AH_UDC_LogHelper.Debug('Workbook sent record type not found');
                  AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                                       'AH_UDC_WorkbookTriggerHelper',
                                       'onTrigger - Before Delete', 'An error occurred during workbook trigger (Before Delete) execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + Trigger.new + ' Error : Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT,
                                       null, null, null);

                  for (SObject sObj : Trigger.old) {
                     sObj.addError('An error occurred in before delete workbook record(s). Please contact UDC System Administrator.');
                  }
               }
            }
         }
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('Error occurred in workbook trigger execution: ' + exc.getMessage() + ' at Line Number : ' + exc.getLineNumber());
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_WorkbookTriggerHelper',
                              'onTrigger', 'An exception occurred during workbook trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + Trigger.new,
                              exc, null, null);

         for (SObject sObj : (Trigger.new != null ? Trigger.new : Trigger.old)) {
            String strAction = Trigger.isDelete ? 'deleting' : (Trigger.isUndelete ? 'restoring' : 'saving');
            sObj.addError('An error occurred while ' + strAction + ' workbook record. Please contact UDC System Administrator.');
         }
      }
   }
}