/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsUserCallout_Schedule Class
Author          : Arul Geetha Amalraj
Created Date    : 12/03/2020
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-046831
Description     : Cross_Orgs Project -> This class Schedules DTS_CrossOrgsUserCallout_Batch.cls		 
				: Scheduled Daily (Cron Schedule) @8:00PM or Monthly based on the request
TestClass    	: DTS_CrossOrgsUserCallout_Test(100%)
**********************************************************************************************************************************************/

global class DTS_CrossOrgsUserCallout_Schedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        DTS_CrossOrgsUserCallout_Batch b = new DTS_CrossOrgsUserCallout_Batch();
        database.executebatch(b,1);
    }
    /*
    // Cron Schedule-Added here for ref
    DTS_CrossOrgsUserCallout_Schedule b = new DTS_CrossOrgsUserCallout_Schedule();
    String sch = '0 0 20 * * ?';
    system.schedule('CrossOrgsUserCallout Daily @8:00 PM', sch, b); 
    */    
}