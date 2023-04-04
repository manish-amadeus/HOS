/****************************************************************************************
Name            : NI_Employee_Performance_Evaluation__c After Update Trigger
Author          : Stuart Emery
Created Date    : 9/17/2014
Last Mod Date   : 9/17/2014
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : After Update Trigger for the NI_Employee_Performance_Evaluation__c Object
                : 
                : 
******************************************************************************************/
trigger NI_Employee_Performance_Evaluation_AfterUpdate on NI_Employee_Performance_Evaluation__c (after update) 
{
    
    //ONLY CALL THE TRIGGER IF THE BYPASS SWITCH IS NOT CHECKED  
    if (!NI_FUNCTIONS.bypassTriggerCode('PERFORMANCE EVALUATION'))
    {
        NI_PerformanceReview_TriggerHandler handler = new NI_PerformanceReview_TriggerHandler(true);
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }    
    
}