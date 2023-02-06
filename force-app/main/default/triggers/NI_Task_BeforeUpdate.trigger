/****************************************************************************************
Name            : NI_Task_BeforeUpdate Trigger
Author          : Ria Chawla
Created Date    : 08/30/2017
Last Mod Date   : 03/01/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 03/01/2022 - Added if/else block to skip code when new Case created via email-to-case 
                : 
******************************************************************************************/
trigger NI_Task_BeforeUpdate on Task (before update) 
{
    
    if (NI_TriggerManager.bypassTriggersInvokedByCaseDML)
    {
        system.debug(' ***** NI_Task_BeforeUpdate WAS BYPASSED VIA NI_TriggerManager.bypassTriggersInvokedByCaseDML'); 
    }
    else
    {         
        NI_TriggerBypassSwitches__c bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
        if (!bpSwitch.Bypass_Task_ON__c)
        {
            NI_Task_TriggerHandler handler = new NI_Task_TriggerHandler(); 
            handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);
        }        
    }
    
    system.debug(' ***** NI_Task_BeforeUpdate SUMMARY: Limits.getQueries() = ' + Limits.getQueries()); 
    
}