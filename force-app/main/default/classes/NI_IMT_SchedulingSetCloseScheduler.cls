/************************************************************************************************
Name            : NI_IMT_SchedulingSetCloseScheduler Class
Author          : Damodar Raut
Created Date    : 06/29/2016 
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Class that closes and completes scheduling set according the no. of days specified in custom setting
                : 
*************************************************************************************************/
global class NI_IMT_SchedulingSetCloseScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<IMT_Scheduling_Set_Config__c> configs = [SELECT Id,Name,Close_Date__c,Complete_Date__c FROM IMT_Scheduling_Set_Config__c];
		List<Date> closeDays = new List<Date>();
		List<Date> completeDays = new List<Date>();
		//Fetch close and complete days
		for(IMT_Scheduling_Set_Config__c config :configs) {
			Integer day1 = Integer.valueOf(config.Close_Date__c);
			Date chckdate1 = system.today().addDays(day1);
			closeDays.add(chckdate1);
			
			Integer day2 = Integer.valueOf(config.Complete_Date__c * -1);
			Date chckdate2 = system.today().addDays(day2);
			completeDays.add(chckdate2);
		}
		updateSchedulingSetStatus(closeDays, 'Closed');
		updateSchedulingSetStatus(completeDays, 'Complete');
     }
     
     //Update the status of the scheduling matching the date criteria 
     public void updateSchedulingSetStatus(List<Date> schdlSetDateList, String status) {
     	List<IMT_Migration_Set__c> schdlSets = [SELECT Name,Start__c,Status__c FROM IMT_Migration_Set__c WHERE Start__c IN :schdlSetDateList];
		for(IMT_Migration_Set__c schdlSet :schdlSets) {
			schdlSet.Status__c = status;
		}
		update schdlSets;
     }
}