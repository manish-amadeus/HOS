/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsLicenseCallout_Schedule Class
Author          : Arul Geetha Amalraj
Created Date    : 12/03/2020
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-046831
Description     : Cross_Orgs Project -> This class Schedules DTS_CrossOrgsLicenseCallout_Batch.cls		 
				: Scheduled Daily (Cron Schedule) @7:00PM or Monthly based on the request
TestClass    	: DTS_CrossOrgsLicenseCallout_Test(100%)
**********************************************************************************************************************************************/
 
global class DTS_CrossOrgsLicenseCallout_Schedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        DTS_CrossOrgsLicenseCallout_Batch b = new DTS_CrossOrgsLicenseCallout_Batch();
        database.executebatch(b,1);
    }
    /*
    // Cron Schedule-Added here for ref
    DTS_CrossOrgsLicenseCallout_Schedule b = new DTS_CrossOrgsLicenseCallout_Schedule();
    String sch = '0 0 19 * * ?';
    system.schedule('CrossOrgsLicenseCallout Daily @7:00 PM', sch, b); 
    */    
}