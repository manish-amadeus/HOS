/***********************************************************************************************
Name            : AH_PLCM_Update_Email_Trigger_Date
Author          : Sanjay Parmar
Created Date    : 04-Oct-2020
Last Mod Date   : 06-Oct-2020
Last Mod By     : Sanjay Parmar
NICC Reference  : 
Description     : Apex Trigger to update migration reminder date
************************************************************************************************/
trigger AH_PLCM_Update_Email_Trigger_Date on NI_Documentation__c (before insert, before update) {
    map<Id, Schema.RecordTypeInfo> recordTypeMap = Schema.getGlobalDescribe().get('NI_Documentation__c').getDescribe().getRecordTypeInfosById();
    List<Date> lstHolidays = null;
    try {
        for (NI_Documentation__c objNIDoc: Trigger.new) {
            if (recordTypeMap.get(objNIDoc.recordTypeID).getName().containsIgnoreCase('PLCM Migrations')
                && objNIDoc.AH_PLCM_Tech_Transfer__c && objNIDoc.AH_PLCM_Migration_Date__c != null)  {
                //Get amadeus holidays list
                lstHolidays = AH_PLCM_Calculate_Email_Trigger_Date.getHolidaysList();

                objNIDoc.AH_PLCM_Migration_Reminder_2_Date__c = AH_PLCM_Calculate_Email_Trigger_Date.getMigrationRemiderDate(lstHolidays, objNIDoc.AH_PLCM_Migration_Date__c, -3, false);
                objNIDoc.AH_PLCM_Migration_Reminder_3_Date__c = AH_PLCM_Calculate_Email_Trigger_Date.getMigrationRemiderDate(lstHolidays, objNIDoc.AH_PLCM_Migration_Date__c, -1, false);
                objNIDoc.AH_PLCM_End_of_Migration_Validation_Date__c = AH_PLCM_Calculate_Email_Trigger_Date.getMigrationRemiderDate(lstHolidays, objNIDoc.AH_PLCM_Migration_Date__c, 2, true);
            }
        }
    }
    catch(Exception ex) {
        System.debug('Error Occured in Triggger - ' + String.valueOf(ex));
    }
    finally {
        recordTypeMap = null;
        lstHolidays = null;
    }
}