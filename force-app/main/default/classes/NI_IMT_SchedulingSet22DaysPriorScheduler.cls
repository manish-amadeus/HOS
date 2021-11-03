/************************************************************************************************
Name            : NI_IMT_SchedulingSet22DaysPriorBatch Class
Author          : Damodar Raut
Created Date    : 05/19/2016 
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : 
Description     : Class that post to global super user 22 days prior to scheduling set date
                : 
*************************************************************************************************/
global class NI_IMT_SchedulingSet22DaysPriorScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        //find scheduling set meeting the 22 days prior date
    	Date chckdate = system.today().addDays(-22);
		IMT_Migration_Set__c schdlSet = [SELECT Name,Start__c,Status__c FROM IMT_Migration_Set__c WHERE Start__c = :chckdate];
		if(schdlSet != NULL) {
			//If scheduling set has tentaive assignments post chatter to global super user group
			List<pse__Assignment__c> tentativeAssignments = [SELECT Name FROM pse__Assignment__c WHERE pse__Status__c = 'Tentative' AND IMT_Migration_Set__c = :schdlSet.Id];
			if(tentativeAssignments.size() > 0) {
				String communityName = String.valueOf(NI_IMT_Chatter_Settings__c.getValues('Default').get('Community_Name__c'));
				String chatterGroupName = String.valueOf(NI_IMT_Chatter_Settings__c.getValues('Default').get('Chatter_Group_Name__c'));
				if(String.isBlank(communityName) || String.isBlank(chatterGroupName)) {
					system.debug('Community Name and Chatter Group Name can\'t be blank.');
				}
				else {
					Network imtNetwork = [SELECT id, name FROM Network WHERE Name = :communityName];
					CollaborationGroup grp = [SELECT Id,name FROM CollaborationGroup where name = :chatterGroupName];
					if(imtNetwork != NULL && grp!=NULL) {					
						// POST GLOBAL SUPER USER CHATTER
						String postText = '';
						postText = 'There are tentative assignments on the scheduling set '+ schdlSet.Name +'\nDate: ' + schdlSet.Start__c ;
						if(!Test.isRunningTest()){
							ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(imtNetwork.Id, grp.Id, ConnectApi.FeedElementType.FeedItem, postText);
						}		    	
					}
					else {
						system.debug('Community Name or Chatter Group not found.');
					}
				}			
			}
		}
     }
}