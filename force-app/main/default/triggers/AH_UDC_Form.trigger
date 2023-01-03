/**
 * Name          : AH_UDC_Form
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-04-20
 * Description   : This class is the single entry point for triggers on the AH_UDC_Form__c object
 * Dependencies  : AH_UDC_FormTriggerHelper, AH_UDC_FormTriggerHelper_Test
 **/
trigger AH_UDC_Form on AH_UDC_Form__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  { 
   AH_UDC_FormTriggerHelper.onTrigger();
}