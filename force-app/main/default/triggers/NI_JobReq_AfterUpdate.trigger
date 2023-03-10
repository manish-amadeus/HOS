/****************************************************************************************
Name            : NI_Job_Requisition__c After Update Trigger
Author          : Stuart Emery
Created Date    : 3/2/2015
Last Mod Date   : 3/2/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : After Update Trigger for the NI_Job_Requisition__c Object
                : 
                : 
******************************************************************************************/
trigger NI_JobReq_AfterUpdate on NI_Job_Requisition__c (after update) 
{

     if (!NI_FUNCTIONS.bypassTriggerCode('NI JOB REQUISITION'))
    {
       NI_JobReq_TriggerHandler handler = new NI_JobReq_TriggerHandler(true);
       handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }    
    
}