/************************************************************************************************
Name            : NI_IMT_SchedulingSetCloseSchedulerTest Class
Author          : Damodar Raut
Created Date    : 06/29/2016 
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Test Class that handles all test code for the NI_IMT_SchedulingSetCloseScheduler class
                : 
*************************************************************************************************/
@isTest
public with sharing class NI_IMT_SchedulingSetCloseSchedulerTest {
	public static String CRON_EXP = '0 0 0 15 10 ? 2022';
	
	public static testmethod void testCloseAndCompleteDays() {
		Test.startTest();
		String jobId = System.schedule('NI_IMT_SchedulingSetCloseSchedulerTest', CRON_EXP, new NI_IMT_SchedulingSetCloseScheduler());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2022-10-15 00:00:00', String.valueOf(ct.NextFireTime));
		
		NI_IMT_TestDataFactory.createSchedulingSetConfig();
    	Id imtSchdlSetRecordTypeId = Schema.getGlobalDescribe().get('IMT_Migration_Set__c').getDescribe().getRecordTypeInfosByName().get('IMT - InterContinental Hotels Group').getRecordTypeId();
    	List<IMT_Migration_Set__c> schedulingSets = NI_IMT_TestDataFactory.createSchedulingSet(2);
    	//Test Closed status
    	IMT_Migration_Set__c set1 = schedulingSets[0];
    	set1.RecordTypeId = imtSchdlSetRecordTypeId;
    	set1.Start__c = system.today() + 21;
    	insert set1;
    	system.assert(set1.Id != NULL);
    	//Test complete status
    	IMT_Migration_Set__c set2 = schedulingSets[1];
    	set2.RecordTypeId = imtSchdlSetRecordTypeId;
    	set2.Start__c = system.today() - 2;
    	insert set2;
    	system.assert(set2.Id != NULL);
    	
    	Test.stopTest();
    	
    	IMT_Migration_Set__c newMig1 = [SELECT Status__c FROM IMT_Migration_Set__c WHERE Id = :set1.Id];
    	system.assertEquals('Closed' , newMig1.Status__c);
    	
    	IMT_Migration_Set__c newMig2 = [SELECT Status__c FROM IMT_Migration_Set__c WHERE Id = :set2.Id];
    	system.assertEquals('Complete' , newMig2.Status__c);
	}
}