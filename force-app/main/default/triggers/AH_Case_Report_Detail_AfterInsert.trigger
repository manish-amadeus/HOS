/****************************************************************************************
Name            : AH_Case_Report_Detail_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 02/05/2021 
Last Mod Date   : 02/05/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_Case_Report_Detail_AfterInsert on AH_Case_Report_Detail__c (after insert) 
{
    AH_CaseReportDetail_TriggerHandler handler = new AH_CaseReportDetail_TriggerHandler();
    handler.OnAfterInsert(Trigger.new); 
}