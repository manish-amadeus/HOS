/***********************************************************************************************
Name            : AH_Trust_Outage_Before_Update
Author          : Shashikant Nikam
Created Date    : 05/18/2018
Last Mod Date   : 05/18/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Call the before update Methods in the AH_Trust_Outage_Trigger_Handler Class
                :
                :
************************************************************************************************/

trigger AH_Trust_Outage_Before_Update on NI_Trust_Outage__c (before update) {

    system.debug('in BeforeUpdate..');
    AH_Trust_Outage_Trigger_Handler trustOutageHandler = new AH_Trust_Outage_Trigger_Handler();
	trustOutageHandler.OnBeforeUpdate(Trigger.New, Trigger.oldMap);
    system.debug('Before Update completed. Limits.getQueries() : ' + Limits.getQueries());
}