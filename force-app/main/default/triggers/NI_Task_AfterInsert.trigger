/****************************************************************************************
Name            : NI_Task_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 11/30/2016
Last Mod Date   : 03/01/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 03/01/2022 - Added if/else block to skip code when new Case created via email-to-case 
                : 
******************************************************************************************/
trigger NI_Task_AfterInsert on Task (after insert) 
{
    
    if (NI_TriggerManager.bypassTriggersInvokedByCaseDML)
    {
        system.debug(' ***** NI_Task_AfterInsert WAS BYPASSED VIA NI_TriggerManager.bypassTriggersInvokedByCaseDML'); 
    }
    else
    {         
        
        NI_TriggerBypassSwitches__c bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
        
        if (!bpSwitch.Bypass_Winaproach_ON__c)
        { 
            INTGR_WinSN_Task_Handler WinSN = new INTGR_WinSN_Task_Handler();
            WinSN.OnAfterInsert(Trigger.new); 
        }
        
        if (!bpSwitch.Bypass_Task_ON__c)
        {
            NI_Task_TriggerHandler handler = new NI_Task_TriggerHandler(); 
            handler.OnAfterInsert(Trigger.new);
        }

    }
    
    system.debug(' ***** NI_Task_AfterInsert SUMMARY: Limits.getQueries() = ' + Limits.getQueries()); 
    
}