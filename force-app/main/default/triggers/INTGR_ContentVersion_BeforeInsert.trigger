/************************************************************************************************
                           !!! INTEGRATION TRIGGER - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_ContentVersion_BeforeInsert Trigger
Author          : Princy Jain
Created Date    : 12/07/2018
Last Mod Date   : 03/01/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
************************************************************************************************/
trigger INTGR_ContentVersion_BeforeInsert on ContentVersion (before insert)
{    
    
    if (NI_TriggerManager.bypassTriggersInvokedByCaseDML)
    {
        system.debug(' ***** INTGR_ContentVersion_BeforeInsert WAS BYPASSED VIA NI_TriggerManager.bypassTriggersInvokedByCaseDML');
    }
    else
    {            
        INTGR_ContentVersion_TriggerHandler handler = new INTGR_ContentVersion_TriggerHandler();
        handler.OnBeforeInsert(Trigger.new);        
    }
    
    system.debug(' ***** INTGR_ContentVersion_BeforeInsert SUMMARY: Limits.getQueries() = ' + Limits.getQueries()); 
    
}