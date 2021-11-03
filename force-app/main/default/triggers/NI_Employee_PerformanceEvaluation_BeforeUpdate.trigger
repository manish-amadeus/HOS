/****************************************************************************************
Name            : NI_Employee_Performance_Evaluation__c Before Update Trigger
Author          : Stuart Emery
Created Date    : 11/1/2015
Last Mod Date   : 11/1/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Before Update Trigger for the NI_Employee_Performance_Evaluation__c Object
                : 
                : 
******************************************************************************************/
trigger NI_Employee_PerformanceEvaluation_BeforeUpdate on NI_Employee_Performance_Evaluation__c (before update) {
    
    //ONLY CALL THE TRIGGER IF THE BYPASS SWITCH IS NOT CHECKED 
    if (!NI_FUNCTIONS.bypassTriggerCode('PERFORMANCE EVALUATION'))
    {
        NI_PerformanceReview_TriggerHandler handler = new NI_PerformanceReview_TriggerHandler(true);
        handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
    
}