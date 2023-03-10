trigger ffaCashEntryTrigger on c2g__codaCashEntry__c (after update) {

    NI_TriggerBypassSwitches__c ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults();
    if(ffaTriggers.Bypass_ffaCashEntryTrigger__c == true)
    {
        System.Debug('************ ffaCashEntryTrigger trigger is disabled');
        return;
    }

    List<c2g__codaCashEntry__c> processList = new List<c2g__codaCashEntry__c>();
    for(c2g__codaCashEntry__c cash : Trigger.new){
        if(cash.c2g__Transaction__c != null && Trigger.oldMap.get(cash.id).c2g__Transaction__c == null){
            processList.add(cash);
        }
    }
    system.debug('\n\n ***** ffaCashEntryTrigger - processList.size() =' +processList.size());
    if(processList.size()>0){
        ffaUtilities.createCancellingARJournal(processList);
    }
    
}