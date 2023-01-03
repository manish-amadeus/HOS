/****************************************************************************************
Name            : NI_IMT_SchedulingSetTriggerTest Class
Author          : Damodar Raut
Created Date    : 05/20/2016
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Test Class that handles all trigger code for the Schedulind Set Object
				: 
				: 
******************************************************************************************/
@isTest
private class NI_IMT_SchedulingSetTriggerTest {
	//TEST SCHEDULING DATE TO BE UNIQUE
    public static testmethod void testUniqueDate() {
        Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        NI_IMT_TestDataFactory.createSchedulingSetConfig();
        
        IMT_Migration_Set__c schset1 = new IMT_Migration_Set__c(
        	Name = 'Test1',
        	Start__c = system.today(),
        	RecordTypeId = imtSchdlSetRecordTypeId
        );
        insert schset1;
        
        List<IMT_Migration_Set__c> schdlList = new List<IMT_Migration_Set__c>();
        IMT_Migration_Set__c schset2 = new IMT_Migration_Set__c(
        	Name = 'Test2',
        	Start__c = system.today(),
        	RecordTypeId = imtSchdlSetRecordTypeId
        );
        schdlList.add(schset2);
        IMT_Migration_Set__c schset3 = new IMT_Migration_Set__c(
        	Name = 'Test3',
        	Start__c = system.today(),
        	RecordTypeId = imtSchdlSetRecordTypeId
        );
        schdlList.add(schset3);
        
        try {
        	insert schdlList;
        }
        catch(Exception e) {
        	system.assert(e.getMessage().contains('The date for the scheduling set needs to be unique'));	
        }
    }
    
    //TEST TOTAL PLANNED CANNOT EXCEED THE CUSTOM SETTING VALUE
    public static testmethod void checkSchedulingSetTotalPlanned() {
    	NI_IMT_TestDataFactory.createSchedulingSetConfig();
    	Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
        
    	List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(2);
    	IMT_Migration_Set__c set1 = schedulingSets[0];
    	set1.RecordTypeId = imtSchdlSetRecordTypeId;
    	insert set1;
    	system.assert(set1.Id != NULL);
    	IMT_Migration_Set__c set2 = schedulingSets[1];
    	set2.RecordTypeId = imtSchdlSetRecordTypeId;
    	set2.Budgeted_Complexity_1__c = 101;
    	set2.Start__c = set2.Start__c + 1;
    	try {
    		insert set2;
    	}
    	catch (Exception e) {
    		system.assert(e.getMessage().contains('Total planned value cannot be greater than 100'));	
    	}
    	set1.Budgeted_Complexity_1__c = 101;
    	try {
    		update set1;
    	}
    	catch (Exception e) {
    		system.assert(e.getMessage().contains('Total planned value cannot be greater than 100'));	
    	}
    }
    
    //TEST IsTriggerContext
    public static testmethod void checkIsTriggerContext() {
    	NI_IMT_SchedulingSetTriggerHandler obj = new NI_IMT_SchedulingSetTriggerHandler(true);
    	system.assert(obj.IsTriggerContext);
    }

}