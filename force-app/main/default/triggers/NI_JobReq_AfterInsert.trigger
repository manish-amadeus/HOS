/****************************************************************************************
Name            : NI_Job_Requisition__c After Insert Trigger
Author          : Stuart Emery
Created Date    : 3/2/2015
Last Mod Date   : 3/2/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : After Insert Trigger for the NI_Job_Requisition__c Object
                : 
                : 
******************************************************************************************/
trigger NI_JobReq_AfterInsert on NI_Job_Requisition__c (after insert) 
{
    
    //ONLY RUN THE TRIGGER IF THE BYPASSTRIGGER SWITCH IS NOT CHECKED
    if (!NI_FUNCTIONS.bypassTriggerCode('NI JOB REQUISITION'))
    {
        NI_JobReq_TriggerHandler handler = new NI_JobReq_TriggerHandler(true);
        handler.OnAfterInsert(Trigger.new);
     }   
    
}