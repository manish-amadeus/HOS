/****************************************************************************************
Name            : ClusterTrigger_AfterInsert Trigger
Author          : Sunita Mittal
Created Date    : 12/07/2015
Last Mod Date   : 04/05/2017
Last Mod By     : Sean Harris
NICC Reference  : NICC-021729
Description     : 
                : 
                : 
******************************************************************************************/
trigger ClusterTrigger_AfterInsert on Cluster__c (after insert) 
{
     NI_ClusterTriggerHandler handler = new NI_ClusterTriggerHandler();
     handler.OnAfterInsert(Trigger.NewMap);
    
system.debug('  ClusterTrigger_AfterInsert SUMMARY: ');   
system.debug('  Limits.getQueries() = ' + Limits.getQueries());     
 }