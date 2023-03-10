/************************************************************************************************
                           !!! INTEGRATION TRIGGER - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_ContentDocLink_BeforeInsert Trigger
Author          : Sean Harris
Created Date    : 02/02/2022
Last Mod Date   : 03/01/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     :
				: 
************************************************************************************************/ 
trigger INTGR_ContentDocLink_BeforeInsert on ContentDocumentLink (before insert) 
{
    
    INTGR_ContentDocLink_TriggerHandler handler = new INTGR_ContentDocLink_TriggerHandler();
    handler.OnBeforeInsert(trigger.New);
    
    system.debug(' ***** INTGR_ContentDocLink_BeforeInsert SUMMARY: Limits.getQueries() = ' + Limits.getQueries()); 
    
}