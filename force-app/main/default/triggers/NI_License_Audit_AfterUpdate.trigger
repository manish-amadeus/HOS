/****************************************************************************************
Name            : NI_License_Audit_BeforeInsert Trigger
Author          : Supriya Galinde
Created Date    : 2/22/2017
Last Mod Date   : 2/22/2017
Last Mod By     : 
NICC Reference  : 
Description     : Handles after Update Trigger Logic for the NI License Audit object
                : 
                : 
******************************************************************************************/
trigger NI_License_Audit_AfterUpdate on NI_License_Audit__c (after update) 
{
  //ONLY RUN THE TRIGGER IF THE BYPASSTRIGGER SWITCH IS NOT CHECKED
    if (!NI_FUNCTIONS.bypassTriggerCode('NI LICENSE AUDIT'))
        {
          NI_License_Audit_TriggerHandler handler = new NI_License_Audit_TriggerHandler();
          handler.OnAfterUpdate(Trigger.new);
        }       
}