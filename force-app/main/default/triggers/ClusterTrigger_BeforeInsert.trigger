/****************************************************************************************
Name            : ClusterTrigger_BeforeInsert Trigger
Author          : Sunita Mittal
Created Date    : 12/07/2015
Last Mod Date   : 04/05/2017
Last Mod By     : Sean Harris
NICC Reference  : NICC-021729
Description     : 
                : 
                : 
******************************************************************************************/
trigger ClusterTrigger_BeforeInsert on Cluster__c (before insert) 
{
    NI_ClusterTriggerHandler handler = new NI_ClusterTriggerHandler();
    handler.OnBeforeInsert(Trigger.New); 
    
system.debug('  ClusterTrigger_BeforeInsert SUMMARY: ');   
system.debug('  Limits.getQueries() = ' + Limits.getQueries()); 
}