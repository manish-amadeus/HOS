/**
 * Name          : AH_UDC_WorkbookStepResponseTrigger
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-02-12
 * Description   : This class is the single entry point for triggers on the AH_UDC_WorkbookStepResponse object
<<<<<<< HEAD
<<<<<<< HEAD
 * Dependencies  : AH_UDC_WorkbookStepResponseTriggerHelper, AH_UDC_WorkbookStepResponseTriggerHelperTest
 **/
trigger AH_UDC_WorkbookStepResponseTrigger on AH_UDC_WorkbookStepResponse__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  { 
   AH_UDC_WorkbookStepResponseTriggerHelper.onTrigger();
=======
=======
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
 * Dependencies  : AH_UDC_WorkbookStepRespTrigHelper, AH_UDC_WorkbookStepRespTrigHelper_TEST
 **/
trigger AH_UDC_WorkbookStepResponseTrigger on AH_UDC_WorkbookStepResponse__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  { 
   AH_UDC_WorkbookStepRespTrigHelper.onTrigger();
<<<<<<< HEAD
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}