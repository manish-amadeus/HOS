/****************************************************************************************
Name            : NI_Location_AfterInsert Trigger
Author          : Suzanne LeDuc
Created Date    : 09/10/2015
Last Mod Date   : 09/10/2015
Last Mod By     : Sean Harris
NICC Reference  : NICC-014223
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Location_AfterInsert on newmarketsvcs__Location__c (after insert) 
{
    NI_Location_TriggerHandler handler = new NI_Location_TriggerHandler();
    handler.OnAfterInsert(Trigger.new);
}