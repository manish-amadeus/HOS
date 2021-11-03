/*********************************************************************************************************************************************
Name            : DTS_CrossOrgsUserCallout_Test Class
Author          : Arul Geetha Amalraj
Created Date    : 12/03/2020
Last Mod Date   :  
Last Mod By     : 
NICC Reference  : NICC-046831
Description     : Cross Orgs Project : Test Class for Users, UserLogin Callout req, response parsing for DTS_CrossOrgsUserCallout_Batch class
Code Coverage   : DTS_CrossOrgsUserCallout_Batch.cls(91%),DTS_CrossOrgsUserCallout_Schedule.cls(100%),DTS_CrossOrgsUserParsers(100%)                
*********************************************************************************************************************************************/ 

@isTest
public class DTS_CrossOrgsUserCallout_Test {
	
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
        amU.isActive__c = False;
        amU.isFrozen__c = True;
        amU.FreezeDate__c = System.today();
        Insert amU;	
	}
	
/*──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 //Set the Mock and Call the Scheduler
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────*/		
    
	@isTest static void testCrossOrgsUserCallout() {
		
		HttpResponse response = new HttpResponse(); 
		Test.setMock(HttpCalloutMock.class, new DTS_CrossOrgsUserCallout_Mock());
		JSONParser responseParser = JSON.createParser(response.getBody());
        SchedulableContext sc = null; 
		DTS_CrossOrgsUserCallout_Schedule b = new DTS_CrossOrgsUserCallout_Schedule();        
		//Database.executeBatch(b,1);
		b.execute(sc);		
    }	
}