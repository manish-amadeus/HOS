/**********************************************************
*************************************
Name 			: SLTC_OpportunitySplit_BeforeDelete
Author 			: Lamu Sreeharsha
Created Date 	: 4/19/2022
Last Mod Date 	:  4/19/2022 
Last Mod By 	: Lamu Sreeharsha
NICC Reference  : 
Description 	: Trigger used to call beforeDelete events.
***********************************************************
*************************************/

trigger SLTC_OpportunitySplit_BeforeDelete on OpportunitySplit (before delete) {
     if(trigger.isBefore){
        SLTC_OppSplit_TriggerHandler handler = new SLTC_OppSplit_TriggerHandler();
        handler.onBeforeDelete(Trigger.Old);
    }
}