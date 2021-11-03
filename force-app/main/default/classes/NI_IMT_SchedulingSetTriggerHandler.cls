/************************************************************************************************
Name            : NI_IMT_SchedulingSetTriggerHandler Class
Author          : Damodar Raut
Created Date    : 05/11/2016 
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Class that handles all trigger code for the Schedulind Set Object
                : 
*************************************************************************************************/
public class NI_IMT_SchedulingSetTriggerHandler {

    private boolean m_isExecuting = false;
    
    public NI_IMT_SchedulingSetTriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }

    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }
    
    public void OnBeforeInsert(List<IMT_Migration_Set__c> newTrigger) {
    	if (!NI_FUNCTIONS.bypassTriggerCode('IMT_Migration_Set__c')) {
    		Map<Date, IMT_Migration_Set__c> migMap = new Map<Date, IMT_Migration_Set__c>();
    		RecordType recType = [SELECT Name FROM RecordType WHERE Id = :newTrigger[0].RecordTypeId LIMIT 1];
        	String schedulingSetRecordTypeName = recType.Name;
        	Integer totalPlanned = Integer.valueOf(IMT_Scheduling_Set_Config__c.getValues(schedulingSetRecordTypeName).get('Total_Planned__c'));
        	Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        	for (IMT_Migration_Set__c mig : newTrigger) {
            	// Make sure another migration set isn't also a duplicate  
    			if (migMap.containsKey(mig.Start__c) && mig.RecordTypeId == imtSchdlSetRecordTypeId) {
                	mig.addError('The date for the scheduling set needs to be unique.');
	            } else {
	                migMap.put(mig.Start__c, mig);
	            }
	            
	            if (mig.Total_Budget__c > totalPlanned) {
                	mig.addError('Total planned value cannot be greater than ' + totalPlanned);
	            }
   			 }
    		// Find all the migration in the database that have the same date as any of the migration being inserted.  
    		for (IMT_Migration_Set__c mig1 : [SELECT Start__c FROM IMT_Migration_Set__c WHERE Start__c IN :migMap.KeySet()]) {
		        IMT_Migration_Set__c newMig = migMap.get(mig1.Start__c);
		        newMig.addError('The date for the scheduling set needs to be unique.');
		    }
    	}    	
    }
    
    public void OnBeforeUpdate(List<IMT_Migration_Set__c> newTrigger, Map<Id, IMT_Migration_Set__c> oldMapTrigger) {
		if (!NI_FUNCTIONS.bypassTriggerCode('IMT_Migration_Set__c')) {
			//RecordType recType = [SELECT Name FROM RecordType WHERE Id = :newTrigger[0].RecordTypeId LIMIT 1];
        	String schedulingSetRecordTypeName = newTrigger[0].RecordType.Name;
        	Integer totalPlanned = Integer.valueOf(IMT_Scheduling_Set_Config__c.getValues(schedulingSetRecordTypeName).get('Total_Planned__c'));
			for (IMT_Migration_Set__c mig : newTrigger) {
                if (mig.Total_Budget__c > totalPlanned) {
                	mig.addError('Total planned value cannot be greater than ' + totalPlanned);
	            }
            }       
        }                 
    }
}