/**
 * Name          : AH_UDC_Workbook
 * Created By    : Amadeus Hospitality Services (Sanjay Parmar)
 * Created Date  : 2021-06-10
 * Description   : This class is the single entry point for triggers on the AH_UDC_Workbook__c object
 * Dependencies  : AH_UDC_WorkbookTriggerHelper, AH_UDC_WorkbookTriggerHelper_Test
 **/
trigger AH_UDC_Workbook on AH_UDC_Workbook__c (before insert,before update,after undelete,after update, before delete)  { 
   AH_UDC_WorkbookTriggerHelper.onTrigger();
}