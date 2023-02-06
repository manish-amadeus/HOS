/**
 * Name          : AH_UDC_Log
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2022-05-05
 * Description   : This class is the single entry point for triggers on the AH_UDC_Log__c object
 * Dependencies  : AH_UDC_LogTriggerHelper, AH_UDC_LogTriggerHelper_Test
 **/
trigger AH_UDC_Log on AH_UDC_Log__c (before delete)  { 
   AH_UDC_LogTriggerHelper.onTrigger();
}