/**********************************************************
*************************************
Name            : SLTC_Account_AfterDelete
Author          : Lamu Sreeharsha
Created Date    : 4/18/2022
Last Mod Date   :  4/25/2022
Last Mod By     : Lamu Sreeharsha
NICC Reference  : 
Description     : Trigger used to call AfterDelete events.
***********************************************************
*************************************/

trigger SLTC_Account_AfterDelete on Account (after delete) {
    if(Trigger.isAfter){
        SLTC_Account_TriggerHandler accountHandler = new SLTC_Account_TriggerHandler();
        accountHandler.OnAfterDelete(trigger.old);
    }
}