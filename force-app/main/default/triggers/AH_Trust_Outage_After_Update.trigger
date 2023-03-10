/***********************************************************************************************
Name            : AH_Trust_Outage_After_Update
Author          : Shashikant Nikam
Created Date    : 05/15/2018
Last Mod Date   : 05/15/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Call the After update Methods in the AH_Trust_Outage_Trigger_Handler Class
                :
                :
************************************************************************************************/

trigger AH_Trust_Outage_After_Update on NI_Trust_Outage__c (after update) {

    system.debug('in AfterUpdate..');
    AH_Trust_Outage_Trigger_Handler trustOutageHandler = new AH_Trust_Outage_Trigger_Handler();
	trustOutageHandler.OnAfterUpdate(Trigger.New, Trigger.oldMap);
    system.debug('After Update completed. Limits.getQueries() : ' + Limits.getQueries());
}