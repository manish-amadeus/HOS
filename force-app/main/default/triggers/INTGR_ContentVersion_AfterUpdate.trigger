/************************************************************************************************
                           !!! INTEGRATION TRIGGER - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_ContentVersion_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 03/20/2018
Last Mod Date   : 03/01/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
************************************************************************************************/
trigger INTGR_ContentVersion_AfterUpdate on ContentVersion (after update)
{    
    
    if (NI_TriggerManager.bypassTriggersInvokedByCaseDML)
    {
        system.debug(' ***** INTGR_ContentVersion_AfterUpdate WAS BYPASSED VIA NI_TriggerManager.bypassTriggersInvokedByCaseDML');
    }
    else
    {    
        
        INTGR_ContentVersion_TriggerHandler handler = new INTGR_ContentVersion_TriggerHandler();
        handler.OnAfterUpdate(Trigger.newMap);
        
        // Content Pack
        AH_ContentPacks_TriggerHandler cpHandler = new AH_ContentPacks_TriggerHandler();
        cpHandler.createZipFileVersion(Trigger.New);
        
    }
    
    system.debug(' ***** INTGR_ContentVersion_AfterUpdate SUMMARY: Limits.getQueries() = ' + Limits.getQueries()); 
    
}