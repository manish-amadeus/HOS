/****************************************************************************************
Name            : AH_PSA_Assignment_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 08/29/2018
Last Mod Date   : 03/15/2019
Last Mod By     : Sean Harris
NICC Reference  :
Description     : Written by CLS Partners. Updated to meet AH Standards
                :
                :
******************************************************************************************/
trigger AH_PSA_Assignment_AfterUpdate on pse__Assignment__c (after update) 
{
    if (NI_TriggerManager.is1stUpdate_Assignment)
    {    
        AH_PSA_Assignment_TriggerHandler handler = new AH_PSA_Assignment_TriggerHandler();
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}