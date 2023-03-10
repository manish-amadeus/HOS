/****************************************************************************************
Name            : IT_Hardware_Asset__c After Update Trigger
Author          : Stuart Emery
Created Date    : 3/27/2015
Last Mod Date   : 3/27/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : After Update Trigger for the IT_Hardware_Asset__c Object
                : 
                : 
******************************************************************************************/
trigger IT_Hardware_Asset_AfterUpdate on IT_Hardware_Asset__c (after update) {
    
    if (!NI_FUNCTIONS.bypassTriggerCode('IT HARDWARE ASSET'))
    {
        IT_Hardware_Asset_TriggerHandler handler = new IT_Hardware_Asset_TriggerHandler();
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}