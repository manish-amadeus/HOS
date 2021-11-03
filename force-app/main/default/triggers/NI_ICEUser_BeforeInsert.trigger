/****************************************************************************************
Name            : NI_ICEUser_BeforeInsert Trigger
Author          : Sean Harris
Created Date    : 02/26/2014
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_ICEUser_BeforeInsert on ICEUser__c(Before insert) 
{

    NI_ICEUser_TriggerHandler handler = new NI_ICEUser_TriggerHandler(true);
    handler.OnBeforeInsert(Trigger.new);
    
}