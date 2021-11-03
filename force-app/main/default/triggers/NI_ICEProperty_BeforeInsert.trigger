/****************************************************************************************
Name            : NI_ICEProperty_BeforeInsert Trigger
Author          : Sean Harris
Created Date    : 02/26/2014
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_ICEProperty_BeforeInsert on ICEProperty__c(Before insert) 
{

    NI_ICEProperty_TriggerHandler handler = new NI_ICEProperty_TriggerHandler(true);
    handler.OnBeforeInsert(Trigger.new);
    
}