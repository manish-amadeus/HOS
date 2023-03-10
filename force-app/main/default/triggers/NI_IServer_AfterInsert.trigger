/****************************************************************************************
Name            : NI_IServer_AfterInsert Trigger
Author          : Suzanne LeDuc
Created Date    : 09/10/2015
Last Mod Date   : 09/10/2015
Last Mod By     : Sean Harris
NICC Reference  : NICC-014223
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_IServer_AfterInsert on newmarketsvcs__IServer__c (after insert) 
{
    
    NI_IServer_TriggerHandler handler = new NI_IServer_TriggerHandler();
    handler.OnAfterInsert(Trigger.new);
    
}