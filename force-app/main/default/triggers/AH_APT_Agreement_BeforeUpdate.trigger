/****************************************************************************************
Name            : AH_APT_Agreement_BeforeUpdate Trigger
Author          : Stuart Emery
Created Date    : 09/18/2013
Last Mod Date   : 05/29/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_APT_Agreement_BeforeUpdate on Apttus__APTS_Agreement__c (before update) 
{
    AH_APT_Agreement_TriggerHandler handler = new AH_APT_Agreement_TriggerHandler(); 
    handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap); 
}