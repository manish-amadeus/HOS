/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsLoginCallout_Test Class
Author          : Arul Geetha Amalraj
Created Date    : 12/03/2020
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : NICC-046831
Description     : Cross Orgs Project: Test Class for Login History Callout req,response parsing for DTS_CrossOrgsLoginCallout_Batch class
Code Coverage   : DTS_CrossOrgsLoginCallout_Batch.cls(96%),DTS_CrossOrgsLoginCallout_Schedule.cls(100%),DTS_CrossOrgsUserParsers(100%)              
*********************************************************************************************************************************************/  

@isTest
public class DTS_CrossOrgsLoginCallout_Test {
	
/*──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 //Create Test Org  
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────*/
	
	@testSetup static void setup() {
		DTS_Amadeus_Organizations__c amOrg = new DTS_Amadeus_Organizations__c();
        //Required Fields
        amOrg.Name = 'TravelClick Org';
		amOrg.CalloutMDT__c = 'TC_API';
		amOrg.OrgID__c = '00D0m000000A3M9';
        amOrg.OrgInstance__c = 'CS66';
        Insert amOrg;

		DTS_Amadeus_Users__c amU = new DTS_Amadeus_Users__c();
        amU.Name = 'Test User';
		amU.UserId__c = '0051W000003qE3BQAU';
		amU.amadeusorg__c = amOrg.Id;
        amU.isActive__c = True;
        Insert amU;	
	}
    
/*──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 //Set the Mock and Call the Scheduler
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────*/	
	@isTest static void testCrossOrgsLicenseCallout() {
		
		HttpResponse response = new HttpResponse(); 
		Test.setMock(HttpCalloutMock.class, new DTS_CrossOrgsLoginCallout_Mock());
		JSONParser responseParser = JSON.createParser(response.getBody());
        SchedulableContext sc = null; 
		DTS_CrossOrgsLoginCallout_Schedule b = new DTS_CrossOrgsLoginCallout_Schedule(); 
        //DTS_CrossOrgsLoginCallout_Batch b = new DTS_CrossOrgsLoginCallout_Batch();		
		//Database.executeBatch(b,1);
		b.execute(sc);		
    }	
	
	@isTest static void testCrossOrgsHistoryCallout() {
		
		HttpResponse response = new HttpResponse(); 
		Test.setMock(HttpCalloutMock.class, new DTS_CrossOrgsLoginCallout_Mock());
		JSONParser responseParser = JSON.createParser(response.getBody());
        SchedulableContext sc = null; 
		DTS_CrossOrgsLoginHistory_Schedule b = new DTS_CrossOrgsLoginHistory_Schedule(); 
        //DTS_CrossOrgsLoginHistory_Batch b = new DTS_CrossOrgsLoginHistory_Batch();		
		//Database.executeBatch(b,1);
		b.execute(sc);		
    }	
}