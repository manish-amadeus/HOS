/****************************************************************************************
Name            : NI_Location_AfterUpdate Trigger
Author          : Suzanne LeDuc
Created Date    : 09/10/2015
Last Mod Date   : 09/10/2015
Last Mod By     : Sean Harris
NICC Reference  : NICC-014223
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Location_AfterUpdate on newmarketsvcs__Location__c (after update) 
{
    NI_Location_TriggerHandler handler = new NI_Location_TriggerHandler();
    handler.OnAfterUpdate(Trigger.new);   
}