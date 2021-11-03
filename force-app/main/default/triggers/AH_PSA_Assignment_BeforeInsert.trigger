/****************************************************************************************
Name            : AH_PSA_Assignment_BeforeInsert Trigger
Author          : Sean Harris
Created Date    : 11/02/2018
Last Mod Date   : 03/15/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-031010
Description     : 
                :
                :
******************************************************************************************/
trigger AH_PSA_Assignment_BeforeInsert on pse__Assignment__c (before insert) 
{
    if (NI_TriggerManager.is1stInsert_Assignment)
    {   
        AH_PSA_Assignment_TriggerHandler handler = new AH_PSA_Assignment_TriggerHandler();
        handler.OnBeforeInsert(Trigger.new);
    }
}