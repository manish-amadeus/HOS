/****************************************************************************************
Name            : NI_Product2_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 03/10/2015
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Product2_AfterUpdate on Product2 (after update) 
{

    NI_Product2_TriggerHandler handler = new NI_Product2_TriggerHandler();
    handler.OnAfterUpdate(Trigger.new, Trigger.OldMap);
    
}