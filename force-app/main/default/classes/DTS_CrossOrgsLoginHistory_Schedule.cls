/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsLoginHistory_Schedule Class
Author          : Arul Geetha Amalraj
Created Date    : 12/09/2020
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-046831
Description     : Cross_Orgs Project -> This class Schedules DTS_CrossOrgsLoginHistory_Batch.cls		 
				: Scheduled Daily (Cron Schedule) @9:00PM or Monthly based on the request
TestClass    	: DTS_CrossOrgsLoginCallout_Test(100%)
**********************************************************************************************************************************************/

global class DTS_CrossOrgsLoginHistory_Schedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        DTS_CrossOrgsLoginHistory_Batch b = new DTS_CrossOrgsLoginHistory_Batch();
        database.executebatch(b,1);
    }
    
    /*
    // Cron Schedule-Added here for ref:-
    DTS_CrossOrgsLoginHistoryCallout_Schedule b = new DTS_CrossOrgsLoginHistoryCallout_Schedule();
    String sch = '0 0 21 * * ?';
    system.schedule('CrossOrgsLoginHistoryCallout Daily @9:00 PM', sch, b); 
    */    
}