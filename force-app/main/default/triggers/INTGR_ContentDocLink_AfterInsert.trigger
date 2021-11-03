/************************************************************************************************
                           !!! INTEGRATION TRIGGER - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_ContentDocLink_AfterInsert Trigger
Author          : Princy Jain
Created Date    : 03/29/2018
Last Mod Date   : 03/29/2018
Last Mod By     : Princy Jain
NICC Reference  : 
Description 
************************************************************************************************/ 
trigger INTGR_ContentDocLink_AfterInsert on ContentDocumentLink (after insert) 
{
    INTGR_ContentDocLink_TriggerHandler handler = new INTGR_ContentDocLink_TriggerHandler();
    handler.OnAfterInsert(trigger.New);
}