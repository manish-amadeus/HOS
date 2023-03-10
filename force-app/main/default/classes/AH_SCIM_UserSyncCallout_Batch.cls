/**************************************************************************************************
Name            : AH_SCIM_UserSyncCallout_Batch Class
Author          : Ganesh Bora
Created Date    : 21/01/2022
Last Mod Date   : 08/24/2022
Last Mod By     : Arul Geetha Amalraj
NICC Reference  : NICC-056411
Description     : Batch job for Valamis user sychronization.	
				: 05/10/2022 Disable Customer User Scenario
				: 06/16/2022 Swap Account ID with Account Number
				: 08/24/2022 Swap Management Company Fields with Parent Hierachy Fields
─────────────────────────────────────────────────────────────────────────────────────────────────────
Dependencies 	: AH_SCIM_UserSyncCallout.cls
TestClass    	: AH_SCIM_UserSyncCallout_Test.cls

Scheduling Commands:
System.schedule('SCIM Scheduler 1',  '0 00 * * * ?', new AH_SCIM_UserSyncCallout_Schedule());
System.schedule('SCIM Scheduler 2',  '0 15 * * * ?', new AH_SCIM_UserSyncCallout_Schedule());
System.schedule('SCIM Scheduler 3',  '0 30 * * * ?', new AH_SCIM_UserSyncCallout_Schedule());
System.schedule('SCIM Scheduler 4',  '0 45 * * * ?', new AH_SCIM_UserSyncCallout_Schedule());

*******************************************************************************************************/
global class AH_SCIM_UserSyncCallout_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts 
{
	
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
		//Get users list SOQL from Static Resource SCIM_UserSync_SR		
		StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'SCIM_UserSync_SR'];
		Blob bodyBlob = sr.Body;
        String query = bodyBlob.toString();
		System.debug('Static Resource: ' + query);

        if (Test.isRunningTest())
		{
			query += ' LIMIT 1';
		}
		return Database.getQueryLocator(query);		
	}	
    
	global void execute(Database.BatchableContext BC, List<User> scope) 
    {
                
        AH_SCIM_UserSyncCallout objAH_SCIM_UserSyncCallout = new AH_SCIM_UserSyncCallout();
		
		if (scope != null)
        {			 
			for (User u : scope) 
            {
                //re-initialized userdata object to avoid any old data catching 
                AH_SCIM_User userData = objAH_SCIM_UserSyncCallout.getDummySCIMUserDataObject();
                
                system.debug('Processing User : '+u.Username);
                //userData.userName = u.Username; 
                //Disable Customer User Scenario
                String u1 = u.Username; 
                if (u1.startsWith('_'))
                {
    				System.debug('Disabled Customer UserName = ' + u1);
    				String u2 = u1.Right(u1.length() - 1);    
    				System.debug('Old UserName' + u2);
                    userData.externalId = u2;
				}
                else
                {
                    userData.externalId = u.Username;  
                }
                
                // EOC :Disable Customer User Scenario                
                
                objAH_SCIM_UserSyncCallout.sfuserIsActive = u.IsActive;             
                
                /*if(u.IsActive == false)                 
                {
                	//Mark User as inactive if its deactivated.        			
                    userdata.active = false; 
                    system.debug('setting status for'+userdata.userName+' as '+userdata.active);
                }*/ 
				
                AH_SCIM_User.Emails e1 = new AH_SCIM_User.Emails();
                e1.value = u.Email;
                e1.primary = true;
                
                userData.emails = new List <AH_SCIM_User.Emails>();
                userData.emails.add(e1);
                
                userData.name.familyName = u.LastName;
                userData.name.givenName = u.FirstName;
                userData.name.formatted = u.FirstName + ' ' + u.LastName;
                userdata.urn_ietf_params_scim_schemas_extension_valamis_2_0_User.custom = new List<AH_SCIM_User.Custom>();
                //Mapping Account Related Data
                //Swap Account ID with Account Number
                /*
                Map<string, string> AccountDataMap = new Map<string, string> {'accountID'=>u.Account.Id, 
                 					'accountName'=>u.Account.Name,
                 					'managementCompanyID' => u.Account.Management_Company_ID__c,
                 					'managementCompanyName' => u.Account.Management_Company_Name__c};
                */
                Map<string, string> AccountDataMap = new Map<string, string> {'accountID'=>u.Account.AccountNumber, 
                 					'accountName'=>u.Account.Name,
                 					'managementCompanyID' => u.Account.Parent.AccountNumber,
                 					'managementCompanyName' => u.Account.Parent.Name};
                
                userData.custom = new List<AH_SCIM_User.Custom>();
                for (string key : AccountDataMap.keyset())
                {
                    AH_SCIM_User.Custom c = new AH_SCIM_User.Custom();
                    c.key = key;
                	c.value = AccountDataMap.get(key);
                	userData.custom.add(c);
                    //New API Structure
                    userdata.urn_ietf_params_scim_schemas_extension_valamis_2_0_User.custom.add(c);
                }
                
                //call callout function for user syncup
                objAH_SCIM_UserSyncCallout.syncUser(userData);
                
            }
		}
	}

	global void finish(Database.BatchableContext BC) 
    {
		system.debug('In the finsh method of AH_SCIM_UserSyncCallout_Batch Apex.......');		
	}
    
}