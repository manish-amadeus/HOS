/****************************************************************************************
Name            : NICC_Artifact_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 2/15/2013
Last Mod Date   : 
Last Mod By     :
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NICC_Artifact_AfterInsert on NICC_Artifact__c (after Insert) 
{
    NICC_Artifact_TriggerHandler handler = new NICC_Artifact_TriggerHandler(true);
    handler.OnAfterInsert(Trigger.new);
}