/****************************************************************************************
Name            : AH_CaseFlagsHistoryTracking_BeforeInsert Trigger
Author          : Cybage Developer - Shashikant Nikam
Created Date    : 01/15/2018
Last Mod Date   : 02/15/2018
Last Mod By     : Cybage Developer - Shashikant Nikam
NICC Reference  : NICC-026092
Description     : 
                :
*****************************************************************************************/
trigger AH_CaseFlagsHistoryTracking_BeforeInsert on AH_Case_Flags_History_Tracking__c (before insert) 
{
    
    AH_CaseHistoryTracking_TriggerHandler handler = new AH_CaseHistoryTracking_TriggerHandler();
    handler.onBeforeInsert(Trigger.new);

}