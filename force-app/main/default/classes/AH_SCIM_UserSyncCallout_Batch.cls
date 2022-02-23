/**************************************************************************************************
Name            : AH_SCIM_UserSyncCallout_Batch Class
Author          : Ganesh Bora
Created Date    : 21/01/2022
Last Mod Date   : Ganesh Bora
Last Mod By     : 21/01/2022
NICC Reference  : NICC-056411
Description     : Batch  job for Valamis user sychronization.	
				: 
Comments		: 
─────────────────────────────────────────────────────────────────────────────────────────────────────
MaintainedBy 	: Ganesh Bora
Dependencies 	: AH_SCIM_UserSyncCallout.cls
TestClass    	: AH_SCIM_UserSyncCallout_Test.cls
*******************************************************************************************************/
global class AH_SCIM_UserSyncCallout_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
	
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
		//Get users list SOQL from Static Resource SCIM_UserSync_SR		
		StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'SCIM_UserSync_SR'];
		Blob bodyBlob = sr.Body;
        String query = bodyBlob.toString();
		System.debug('Static Resource :'+ query);
        if(Test.isRunningTest())
		{
			query += ' Limit 1';
		}
		return Database.getQueryLocator(query);		
	}	
    
	global void execute(Database.BatchableContext BC, List<User> scope) 
    {
        AH_SCIM_UserSyncCallout objAH_SCIM_UserSyncCallout = new AH_SCIM_UserSyncCallout();
		AH_SCIM_User userData = objAH_SCIM_UserSyncCallout.getDummySCIMUserDataObject();
		if(scope != null)
        {			 
			for(User u : scope) 
            {
                system.debug('Processing User : '+u.Username);
                userData.userName = u.Username;
                userData.externalId = u.Username;
                userdata.active = false;
                
                AH_SCIM_User.Emails e1 = new AH_SCIM_User.Emails();
                e1.value = u.Email;
                e1.primary = true;
                
                userData.emails = new List <AH_SCIM_User.Emails>();
                userData.emails.add(e1);
                
                userData.name.familyName = u.LastName;
                userData.name.givenName = u.FirstName;
                userData.name.formatted = u.FirstName+' '+u.LastName;
                
                //Mapping Account Related Data
                Map<string, string> AccountDataMap = new Map<string, string> {'accountID'=>u.Account.Id, 
                 					'accountName'=>u.Account.Name,
                 					'managementCompanyID' => u.Account.Management_Company_ID__c,
                 					'managementCompanyName' => u.Account.Management_Company_Name__c};
    
                userData.custom = new List <AH_SCIM_User.Custom>();
                for(string key: AccountDataMap.keyset())
                {
                    AH_SCIM_User.Custom c = new AH_SCIM_User.Custom();
                    c.key = key;
                	c.value = AccountDataMap.get(key);
                	userData.custom.add(c);
                }
                //call callout function for user syncup
                objAH_SCIM_UserSyncCallout.syncUser(userData);
            }
		}//End of Scope
	}

	global void finish(Database.BatchableContext BC) {
		system.debug('In the finsh method of AH_SCIM_UserSyncCallout_Batch Apex.......');		
	}
}