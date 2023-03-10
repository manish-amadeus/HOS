/****************************************************************************************
Name            : AH_PSA_Project_AfterUpdate Trigger
Author          : CLD Partners
Created Date    : 11/09/2011
Last Mod Date   : 07/23/2019
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_PSA_Project_AfterUpdate on pse__Proj__c (after update) 
{
    if (NI_TriggerManager.is1stUpdate_Project)
    { 
        try 
        {
            AH_PSA_Project_TriggerHandler handler = new AH_PSA_Project_TriggerHandler();
        	handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        catch(Exception e)
        {
            system.debug('Exception found : '+e);
        }
    }
}