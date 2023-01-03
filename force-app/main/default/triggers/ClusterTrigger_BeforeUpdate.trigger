/****************************************************************************************
Name            : ClusterTrigger_BeforeUpdate Trigger
Author          : Sunita Mittal
Created Date    : 12/07/2015
Last Mod Date   : 04/05/2017
Last Mod By     : Sean Harris
NICC Reference  : NICC-021729
Description     : 
                : 
                : 
******************************************************************************************/
trigger ClusterTrigger_BeforeUpdate on Cluster__c (before update) 
{
    NI_ClusterTriggerHandler handler = new  NI_ClusterTriggerHandler();
    handler.OnBeforeUpdate(Trigger.New, Trigger.OldMap);
    
system.debug('  ClusterTrigger_BeforeUpdate SUMMARY: ');   
system.debug('  Limits.getQueries() = ' + Limits.getQueries());     
}