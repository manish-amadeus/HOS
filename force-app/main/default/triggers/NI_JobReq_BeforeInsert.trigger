/****************************************************************************************
Name            : NI_JobReq_BeforeInsert Trigger
Author          : Stuart Emery
Created Date    : 2/24/2015
Last Mod Date   : 2/24/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Before Insert Trigger that calls the OnBeforeUpdate methods in the 
                : I_JobReq_TriggerHandler Class
                : 
******************************************************************************************/
trigger NI_JobReq_BeforeInsert on NI_Job_Requisition__c (before insert) {
    
    NI_JobReq_TriggerHandler handler = new NI_JobReq_TriggerHandler(true);
    
    //ONLY RUN THE TRIGGER IF THE BYPASSTRIGGER SWITCH IS NOT CHECKED
    if (!NI_FUNCTIONS.bypassTriggerCode('NI JOB REQUISITION'))
    {
        handler.OnBeforeInsert(Trigger.new);   
    }  
}