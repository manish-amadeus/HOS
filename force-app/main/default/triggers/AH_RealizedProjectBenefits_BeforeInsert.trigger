/****************************************************************************************
Name            : AH_RealizedProjectBenefits_BeforeInsert Trigger
Author          : Sean Harris
Created Date    : 12/06/2021
Last Mod Date   : 12/06/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                :
                :
******************************************************************************************/
trigger AH_RealizedProjectBenefits_BeforeInsert on AH_Realized_Project_Benefits__c (before insert) 
{
    AH_RealizedProjBnfit_TriggerHandler handler = new AH_RealizedProjBnfit_TriggerHandler();
    handler.OnBeforeInsert(Trigger.new);
}