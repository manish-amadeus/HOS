/****************************************************************************************
Name            : NI_Org_Details_AfterInsert Trigger
Author          : Stuart Emery
Created Date    : 7/16/2013
Last Mod Date   : 7/16/2013
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Handles all after insert trigger logic 
                : 
                : 
******************************************************************************************/
trigger NI_Org_Details_AfterInsert on NI_Org_Details__c (after insert) 
{

     NI_Org_Details_TriggerHandler handler = new  NI_Org_Details_TriggerHandler(true);

      handler.OnAfterInsert(Trigger.new);
    
    
}