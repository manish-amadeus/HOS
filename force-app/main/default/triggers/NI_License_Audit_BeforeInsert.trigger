/****************************************************************************************
Name            : NI_License_Audit_BeforeInsert Trigger
Author          : Stuart Emery
Created Date    : 8/25/2015
Last Mod Date   : 8/25/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Handles Before Insert Trigger Logic for the NI License Audit object
                : 
                : 
******************************************************************************************/
trigger NI_License_Audit_BeforeInsert on NI_License_Audit__c (before insert) 
{
  //ONLY RUN THE TRIGGER IF THE BYPASSTRIGGER SWITCH IS NOT CHECKED
    if (!NI_FUNCTIONS.bypassTriggerCode('NI LICENSE AUDIT'))
        {
          NI_License_Audit_TriggerHandler handler = new NI_License_Audit_TriggerHandler();
          handler.OnBeforeInsert(Trigger.new);
        }       
}