/****************************************************************************************
Name            : NI_Org_Details_AfterInsert Trigger
Author          : Supriya Galinde
Created Date    : 7/16/2013
Last Mod Date   : 7/16/2013
Last Mod By     : Supriya Galinde
NICC Reference  : 
Description     : Handles all after insert trigger logic 
                : 
                : 
******************************************************************************************/
trigger NI_Org_Details_AfterUpdate on NI_Org_Details__c (after update) 
{
	NI_Org_Details_TriggerHandler handler = new  NI_Org_Details_TriggerHandler(true);

    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
      
}