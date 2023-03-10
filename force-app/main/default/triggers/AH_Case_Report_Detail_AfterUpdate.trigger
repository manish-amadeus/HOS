/****************************************************************************************
Name            : AH_Case_Report_Detail_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 02/05/2021 
Last Mod Date   : 02/05/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_Case_Report_Detail_AfterUpdate on AH_Case_Report_Detail__c (after update) 
{
    AH_CaseReportDetail_TriggerHandler handler = new AH_CaseReportDetail_TriggerHandler();
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap); 
}