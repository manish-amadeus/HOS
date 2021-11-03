/****************************************************************************************
Name            : NI_Product2_BeforeUpdate Trigger
Author          : Sean Harris
Created Date    : 03/10/2015
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Product2_BeforeUpdate on Product2 (before update) 
{

    NI_Product2_TriggerHandler handler = new NI_Product2_TriggerHandler();
    handler.OnBeforeUpdate(Trigger.new, Trigger.OldMap);
    
}