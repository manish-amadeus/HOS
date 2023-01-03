/****************************************************************************************
Name            : NICC_Artifact_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 2/15/2013
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NICC_Artifact_AfterUpdate on NICC_Artifact__c (after update) 
{

    NICC_Artifact_TriggerHandler handler = new NICC_Artifact_TriggerHandler(true);
    handler.OnAfterUpdate(Trigger.new);

}