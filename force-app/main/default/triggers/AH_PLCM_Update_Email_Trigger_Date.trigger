/***********************************************************************************************
Name            : AH_PLCM_Update_Email_Trigger_Date
Author          : Sanjay Parmar
Created Date    : 04-Oct-2020
Last Mod Date   : 14-Sep-2022
Last Mod By     : Hardik Doshi - Modified as per new requirement to consider Reminder date2, Reminder date3
NICC Reference  : 
Description     : Apex Trigger to update migration reminder date
************************************************************************************************/
trigger AH_PLCM_Update_Email_Trigger_Date on NI_Documentation__c (before insert, before update) {
    map<Id, Schema.RecordTypeInfo> recordTypeMap = Schema.getGlobalDescribe().get('NI_Documentation__c').getDescribe().getRecordTypeInfosById();
    try {
        for (NI_Documentation__c objNIDoc: Trigger.new) {
            if (recordTypeMap.get(objNIDoc.recordTypeID).getName().containsIgnoreCase('PLCM Migrations')
                //&& objNIDoc.AH_PLCM_Tech_Transfer__c 
                && objNIDoc.AH_PLCM_Migration_Date__c != null)  {
                objNIDoc.AH_PLCM_Migration_Reminder_2_Date__c = AH_PLCM_Calculate_Email_Trigger_Date.getMigrationRemiderDate(objNIDoc.AH_PLCM_Migration_Date__c, -1, false);
                objNIDoc.AH_PLCM_Migration_Reminder_3_Date__c = AH_PLCM_Calculate_Email_Trigger_Date.getMigrationRemiderDate(objNIDoc.AH_PLCM_Migration_Date__c, 5, true);
            }
            If(recordTypeMap.get(objNIDoc.recordTypeID).getName().containsIgnoreCase('PLCM Migrations')
                && objNIDoc.AH_PLCM_Migration_Date__c == null)  {
                objNIDoc.AH_PLCM_Migration_Reminder_2_Date__c = null;
                objNIDoc.AH_PLCM_Migration_Reminder_3_Date__c = null;
            }
        }
    }
    catch(Exception ex) {
        System.debug('Error Occured in Triggger - ' + String.valueOf(ex));
    }
    finally {
        recordTypeMap = null;
    }
}