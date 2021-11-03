/****************************************************************************************
Name            : AH_PSA_Project_BeforeInsert Trigger
Author          : CLD Partners
Created Date    : 12/01/2011
Last Mod Date   : 03/15/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_PSA_Project_BeforeInsert on pse__Proj__c (before insert) 
{
    if (NI_TriggerManager.is1stInsert_Project)
    {
        AH_PSA_Project_TriggerHandler handler = new AH_PSA_Project_TriggerHandler();
        handler.OnBeforeInsert(Trigger.new);        
    }
}