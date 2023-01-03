/************************************************************************************************
                           !!! INTEGRATION TRIGGER - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_ContentVersion_BeforeInsert Trigger
Author          : Princy Jain
Created Date    : 12/07/2018
Last Mod Date   : 12/11/2018
Last Mod By     : Princy Jain
NICC Reference  : 
Description     : Validates Files before insert from API User
                : 
************************************************************************************************/
trigger INTGR_ContentVersion_BeforeInsert on ContentVersion (before insert)
{    
    INTGR_ContentVersion_TriggerHandler handler = new INTGR_ContentVersion_TriggerHandler();
    handler.OnBeforeInsert(Trigger.new);
}