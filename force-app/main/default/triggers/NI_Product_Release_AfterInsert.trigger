/****************************************************************************************
Name            : NI_Product_Release_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 01/22/2016
Last Mod Date   : 01/22/2016
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Product_Release_AfterInsert on NI_Product_Release__c (after insert) 
{

    NI_Product_Release_TriggerHandler handler = new NI_Product_Release_TriggerHandler();
    handler.OnAfterInsert(Trigger.new);
    
}