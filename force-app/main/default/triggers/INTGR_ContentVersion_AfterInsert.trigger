/************************************************************************************************
                           !!! INTEGRATION TRIGGER - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_ContentVersion_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 03/20/2018
Last Mod Date   : 03/01/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
************************************************************************************************/
trigger INTGR_ContentVersion_AfterInsert on ContentVersion (after insert)
{    
    
    if (NI_TriggerManager.bypassTriggersInvokedByCaseDML)
    {
        system.debug(' ***** INTGR_ContentVersion_AfterInsert WAS BYPASSED VIA NI_TriggerManager.bypassTriggersInvokedByCaseDML');
    }
    else
    {    
        
        INTGR_ContentVersion_TriggerHandler handler = new INTGR_ContentVersion_TriggerHandler();
        handler.OnAfterInsert(Trigger.new);        
        
        // Content Pack
        AH_ContentPacks_TriggerHandler cpHandler = new AH_ContentPacks_TriggerHandler();
        
        if (AH_ContentPacks_TriggerHandler.runOnce)
        {
            AH_ContentPacks_TriggerHandler.runOnce = false;
            cpHandler.createZipFileVersion(Trigger.New);
        }
        
    }
    
    system.debug(' ***** INTGR_ContentVersion_AfterInsert SUMMARY: Limits.getQueries() = ' + Limits.getQueries()); 
       
}