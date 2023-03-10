/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsLoginCallout_Schedule Class
Author          : Arul Geetha Amalraj
Created Date    : 12/03/2020
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-046831
Description     : Cross_Orgs Project -> This class Schedules DTS_CrossOrgsLoginCallout_Batch.cls		 
				: Scheduled Daily (Cron Schedule) @9:00PM or Monthly based on the request
TestClass    	: DTS_CrossOrgsLoginCallout_Test(100%)
**********************************************************************************************************************************************/

global class DTS_CrossOrgsLoginCallout_Schedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        DTS_CrossOrgsLoginCallout_Batch b = new DTS_CrossOrgsLoginCallout_Batch();
        database.executebatch(b,1);
    }
    
    /*
    // Cron Schedule-Added here for ref:-
    DTS_CrossOrgsLoginCallout_Schedule b = new DTS_CrossOrgsLoginCallout_Schedule();
    String sch = '0 0 21 * * ?';
    system.schedule('CrossOrgsLoginCallout Daily @9:00 PM', sch, b); 
    */    
}