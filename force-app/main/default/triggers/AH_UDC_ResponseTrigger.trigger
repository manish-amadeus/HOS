/**
 * Name          : AH_UDC_ResponseTrigger
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-02-12
 * Description   : This class is the single entry point for triggers on the AH_UDC_Response object
 * Dependencies  : AH_UDC_ResponseTriggerHelper, AH_UDC_ResponseTriggerHelperTest
 **/
trigger AH_UDC_ResponseTrigger on AH_UDC_Response__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  { 
   AH_UDC_ResponseTriggerHelper.onTrigger();
}