/*************************************************************************************************
Name            : SLTC_ContentDocumentLink_AfterInsert Trigger
Author          : Japtej Lamba
Created Date    : 10/28/2022
Last Mod Date   : 10/28/2022
Last Mod By     : Japtej Lamba
NICC Reference  : 
Description 
************************************************************************************************/ 
trigger SLTC_ContentDocumentLink_AfterInsert on ContentDocumentLink (after insert)  {
    SLTC_ContentDocumentLink_TriggerHandler handler = new SLTC_ContentDocumentLink_TriggerHandler();
    handler.OnAfterInsert(trigger.New);
}