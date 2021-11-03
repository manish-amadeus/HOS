trigger DI_Management_BeforeUpdate on DI_Management__c (before update) {
	DI_Management_TriggerHandler handler = new DI_Management_TriggerHandler();
    handler.OnBeforeUpdate(Trigger.new,Trigger.oldMap);
}