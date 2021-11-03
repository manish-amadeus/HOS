/****************************************************************************************
Name            : NI_Job_Requisition__c Before Update Trigger
Author          : Stuart Emery
Created Date    : 3/6/2015
Last Mod Date   : 3/6/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Before Update Trigger for the NI_Job_Requisition__c Object
                : 
                : 
******************************************************************************************/
trigger NI_JobReq_BeforeUpdate on NI_Job_Requisition__c (before update) 
{

     if (!NI_FUNCTIONS.bypassTriggerCode('NI JOB REQUISITION'))
    {
       NI_JobReq_TriggerHandler handler = new NI_JobReq_TriggerHandler(true);
       handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);
    }    
    
}