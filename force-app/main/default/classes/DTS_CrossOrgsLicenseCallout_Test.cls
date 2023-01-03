/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsLicenseCallout_Test Class
Author          : Arul Geetha Amalraj
Created Date    : 12/03/2020
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : NICC-046831
Description     : Cross Orgs Project: Test Class for CrossOrg License Callout req, response parsing for DTS_CrossOrgsLicenseCallout_Batch class
Code Coverage   : DTS_CrossOrgsLicenseCallout_Batch.cls(96%),DTS_CrossOrgsLicenseCallout_Schedule.cls(100%),DTS_CrossOrgsLicenseParsers(100%)
*********************************************************************************************************************************************/

@isTest
public class DTS_CrossOrgsLicenseCallout_Test {

/*──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 //Create Test Org  
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────*/		
	@testSetup static void setup() {
		DTS_Amadeus_Organizations__c amOrg = new DTS_Amadeus_Organizations__c();
        //Required Fields
        amOrg.Name = 'TravelClick Org';
		amOrg.CalloutMDT__c = 'TC_API';
		amOrg.OrgID__c = '00D0m000000A3M7';
        amOrg.OrgInstance__c = 'CS67';
        Insert amOrg;		
	}
/*──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 //Set the Mock and Call the Scheduler
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────*/	
 
	@isTest static void testCrossOrgsLicenseCallout() {
		
		HttpResponse response = new HttpResponse(); 
		Test.setMock(HttpCalloutMock.class, new DTS_CrossOrgsLicenseCallout_Mock());
		JSONParser responseParser = JSON.createParser(response.getBody());
        SchedulableContext sc = null; 
		DTS_CrossOrgsLicenseCallout_Schedule b = new DTS_CrossOrgsLicenseCallout_Schedule(); 
        //DTS_CrossOrgsLicenseCallout_Batch b = new DTS_CrossOrgsLicenseCallout_Batch();		
		//Database.executeBatch(b,1);
		b.execute(sc);		
    }	
}