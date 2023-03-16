/***************************************************************************************************************************************
Name            : DTS_CrossOrgsHubData_Test Class
Author          : Arul Geetha Amalraj
Created Date    : 12/02/2020
Last Mod Date   : 16/03/2023 
Last Mod By     : 
NICC Reference  : 
Description     : Test Class for DTS_CrossOrgsHubData, DTS_CrossOrgsHubLogins Class  
Code Coverage   : DTS_CrossOrgsHubData (92%), DTS_CrossOrgsHubLogins (94%), DTS_CrossOrgsHubLoginHistory (95%) 
                : 
***************************************************************************************************************************************/

@isTest
public class DTS_CrossOrgsHubData_Test {
    
/*──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 //Create Test Data 
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────*/	
	@testSetup static void setup() {
		DTS_Amadeus_Organizations__c amOrg = new DTS_Amadeus_Organizations__c();
        //Required Fields
        amOrg.Name = 'Hub Org';		
		amOrg.OrgID__c = '00D0m000000A3M7';
        amOrg.OrgInstance__c = 'CS67';
		amOrg.CalloutMDT__c = 'HUB_ORG';
        Insert amOrg;
		
		List<DTS_Amadeus_Licenses__c> amslList = new List<DTS_Amadeus_Licenses__c>();
         For (Integer i=0; i<10; i++){
			DTS_Amadeus_Licenses__c amsl = new DTS_Amadeus_Licenses__c();
			amsl.Name = 'Salesforce'+ i;
			amsl.LicenseType__c = 'User License';
			amsl.Status__c = 'Active';
			amsl.TotalLicenses__c = 100;
			amsl.UsedLicenses__c = 50;
			amsl.AmadeusOrg__c = amOrg.Id;
            amslList.add(amsl);
         }	 
				
		Insert amslList; 
		
		Datetime dToday = System.today();
		Datetime dYestday = System.today().addDays(-1);		
		List<LoginHistory> hQuery = [SELECT Id,UserID,LoginTime,SourceIp,LoginType,Status,LoginUrl,Application,CountryISO From LoginHistory where LoginTime >= :dYestday and LoginTime <:dToday LIMIT 12000];		
		
		List<DTS_Amadeus_Users__c> amuList = new List<DTS_Amadeus_Users__c>();
         For (Integer i=0; i<10; i++){
			DTS_Amadeus_Users__c amu = new DTS_Amadeus_Users__c();
			amu.Name = 'Test User:'+ i;
			amu.UserId__c = hQuery[i].UserId;
			amU.FirstName__c = 'Test';
			amU.LastName__c = 'User:'+i;				
			amU.Email__c = 'TestUser@gmail.com';            			
			amU.FederationID__c = '1233456'; 
			amU.IsActive__c = True; 			
			amU.Profile__c = 'System Administrator'; 
			amU.UserLicense__c = 'Salesforc';		
            amU.AmadeusOrg__c = amOrg.Id;
            amuList.add(amu);
         }	 
				
		Insert amuList; 	
		
	}
/*──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 //Tests current hub org`s Data
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────*/	
	@isTest static void testHubData(){
		test.startTest();
        SchedulableContext sc = null; 		
    	DTS_CrossOrgsHubData b = new DTS_CrossOrgsHubData ();		
		b.execute(sc);
			
    }
	
	@isTest static void testLoginData(){
		test.startTest();
        SchedulableContext sc = null; 		
    	DTS_CrossOrgsHubLogins d = new DTS_CrossOrgsHubLogins ();		
		d.execute(sc);
			
    }
	
	@isTest static void testHistoryData(){
		test.startTest();
        SchedulableContext sc = null; 		
    	DTS_CrossOrgsHubLoginHistory d = new DTS_CrossOrgsHubLoginHistory ();		
		d.execute(sc);
			
    }
	
}
