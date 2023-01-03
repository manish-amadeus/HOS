/****************************************************************************************
Name            : AH_PSA_Project_BeforeUpdate Trigger
Author          : CLD Partners
Created Date    : 10/28/2011
Last Mod Date   : 03/15/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_PSA_Project_BeforeUpdate on pse__Proj__c (before update) 
{
    if (NI_TriggerManager.is1stUpdate_Project)
    {    
        AH_PSA_Project_TriggerHandler handler = new AH_PSA_Project_TriggerHandler();
        handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
}