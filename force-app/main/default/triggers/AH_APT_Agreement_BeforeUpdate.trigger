/****************************************************************************************
Name            : AH_APT_Agreement_BeforeUpdate Trigger
Author          : Stuart Emery
Created Date    : 09/18/2013
Last Mod Date   : 12/06/2022
Last Mod By     : Japtej Lamba
NICC Reference  : 
Description     : Trigger for Before Update logic. Added Handler call for updating Status on
                : Parent and Child Agreement records and cloning attachment from Parent to Child
                : 
******************************************************************************************/
trigger AH_APT_Agreement_BeforeUpdate on Apttus__APTS_Agreement__c (before update) 
{
    List<Apttus__APTS_Agreement__c> trigger_new_filter = new List<Apttus__APTS_Agreement__c>();
    for(Apttus__APTS_Agreement__c record : Trigger.New){
        if(record.SLTC_Is_SLTC_Record__c){
            trigger_new_filter.add(record);
        } 
    }

    if(!trigger_new_filter.isEmpty()){
        SLTC_AgreementTriggerHandler handler = new SLTC_AgreementTriggerHandler();
        handler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    }else{
        AH_APT_Agreement_TriggerHandler handler = new AH_APT_Agreement_TriggerHandler(); 
        handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap); 
    }
    
}