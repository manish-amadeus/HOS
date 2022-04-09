/**************************************************************************************************
Name            : AH_SCIM_UserSyncCallout_Batch Class
Author          : Ganesh Bora
Created Date    : 21/01/2022
Last Mod Date   : 03/25/2022
Last Mod By     : 
NICC Reference  : NICC-056411
Description     : Batch  job for Valamis user sychronization.	
				: 
Comments		: 
─────────────────────────────────────────────────────────────────────────────────────────────────────
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
		
		if(scope != null)
        {			 
			for(User u : scope) 
            {
                //re-initialized userdata object to avoid any old data catching 
                AH_SCIM_User userData = objAH_SCIM_UserSyncCallout.getDummySCIMUserDataObject();
                
                system.debug('Processing User : '+u.Username);
                //userData.userName = u.Username;               
                userData.externalId = u.Username;
                
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
                userData.name.formatted = u.FirstName+' '+u.LastName;
                userdata.urn_ietf_params_scim_schemas_extension_valamis_2_0_User.custom = new List<AH_SCIM_User.Custom>();
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
                    //New API Structure
                    userdata.urn_ietf_params_scim_schemas_extension_valamis_2_0_User.custom.add(c);
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