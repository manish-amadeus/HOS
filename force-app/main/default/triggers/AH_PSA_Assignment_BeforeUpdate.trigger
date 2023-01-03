/****************************************************************************************
Name            : AH_PSA_Assignment_BeforeUpdate Trigger
Author          : Sean Harris
Created Date    : 11/02/2018
Last Mod Date   : 03/15/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-031010
Description     : 
                :
                :
******************************************************************************************/
trigger AH_PSA_Assignment_BeforeUpdate on pse__Assignment__c (before update) 
{
    if (NI_TriggerManager.is1stUpdate_Assignment)
    {    
        AH_PSA_Assignment_TriggerHandler handler = new AH_PSA_Assignment_TriggerHandler();
        handler.OnBeforeUpdate(Trigger.new);
    }
}