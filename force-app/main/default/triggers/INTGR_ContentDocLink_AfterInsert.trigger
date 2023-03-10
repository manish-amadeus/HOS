/************************************************************************************************
                           !!! INTEGRATION TRIGGER - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_ContentDocLink_AfterInsert Trigger
Author          : Princy Jain
Created Date    : 03/29/2018
Last Mod Date   : 03/01/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
				: 
************************************************************************************************/ 
trigger INTGR_ContentDocLink_AfterInsert on ContentDocumentLink (after insert) 
{
    
    if (NI_TriggerManager.bypassTriggersInvokedByCaseDML)
    {
        system.debug(' ***** INTGR_ContentDocLink_AfterInsert WAS BYPASSED VIA NI_TriggerManager.bypassTriggersInvokedByCaseDML');
    }
    else
    {
        INTGR_ContentDocLink_TriggerHandler handler = new INTGR_ContentDocLink_TriggerHandler();
        handler.OnAfterInsert(trigger.New);
    }
 
    system.debug(' ***** INTGR_ContentDocLink_AfterInsert SUMMARY: Limits.getQueries() = ' + Limits.getQueries()); 
    
}