/****************************************************************************************
Name            : AH_PSA_Project_AfterInsert Trigger
Author          : CLD Partners
Created Date    : 05/09/2016
Last Mod Date   : 03/15/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_PSA_Project_AfterInsert on pse__Proj__c (after insert) 
{
    if (NI_TriggerManager.is1stInsert_Project)
    {
        AH_PSA_Project_TriggerHandler handler = new AH_PSA_Project_TriggerHandler();
        handler.OnAfterInsert(Trigger.new);
    }
}