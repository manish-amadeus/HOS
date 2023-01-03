/************************************************************************************************
                           !!! INTEGRATION TRIGGER - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_ContentVersion_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 03/20/2018
Last Mod Date   : 03/20/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
************************************************************************************************/
trigger INTGR_ContentVersion_AfterUpdate on ContentVersion (after update)
{    
    INTGR_ContentVersion_TriggerHandler handler = new INTGR_ContentVersion_TriggerHandler();
    handler.OnAfterUpdate(Trigger.newMap);
    
    // Content Pack
    AH_ContentPacks_TriggerHandler cpHandler = new AH_ContentPacks_TriggerHandler();
    cpHandler.createZipFileVersion(Trigger.New);
}