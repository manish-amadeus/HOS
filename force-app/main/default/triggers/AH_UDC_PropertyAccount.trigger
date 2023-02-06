/**
 * Name          : AH_UDC_PropertyAccount
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-09-22
 * Description   : This class is the single entry point for triggers on the AH_UDC_PropertyAccount__c object
 * Dependencies  : AH_UDC_PropertyAccountTriggerHelper, AH_UDC_PropertyAccountTriggerHelper_Test
 **/

trigger AH_UDC_PropertyAccount on AH_UDC_PropertyAccount__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  { 
   AH_UDC_PropertyAccountTriggerHelper.onTrigger();
}