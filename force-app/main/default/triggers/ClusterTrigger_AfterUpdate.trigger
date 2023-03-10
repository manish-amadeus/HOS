/****************************************************************************************
Name            : ClusterTrigger_AfterUpdate Trigger
Author          : Sunita Mittal
Created Date    : 12/07/2015
Last Mod Date   : 04/05/2017
Last Mod By     : Sean Harris
NICC Reference  : NICC-021729
Description     : 
                : 
                : 
******************************************************************************************/
trigger ClusterTrigger_AfterUpdate on Cluster__c (after update) 
{
    NI_ClusterTriggerHandler handler = new NI_ClusterTriggerHandler();
    handler.OnAfterUpdate(Trigger.NewMap,Trigger.OldMap);
    
system.debug('  ClusterTrigger_AfterUpdate SUMMARY: ');   
system.debug('  Limits.getQueries() = ' + Limits.getQueries());     
}