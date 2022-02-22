/**************************************************************************************************
Name            : AH_SCIM_UserSyncCallout_Batch Class
Author          : Ganesh Bora
Created Date    : 21/01/2022
Last Mod Date   : Ganesh Bora
Last Mod By     : 21/01/2022
NICC Reference  : 
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
                userData.custom = new List <AH_SCIM_User.Custom>();
                
                AH_SCIM_User.Custom c1 = new AH_SCIM_User.Custom();
                c1.key = 'accountID';
                c1.value = u.Account.Id;
                userData.custom.add(c1);
                
                AH_SCIM_User.Custom c2 = new AH_SCIM_User.Custom();
                c2.key = 'accountName';
                c2.value = u.Account.Name;
                userData.custom.add(c2);
                
                AH_SCIM_User.Custom c3 = new AH_SCIM_User.Custom();
                c3.key = 'managementCompanyID';
                c3.value = u.Account.Management_Company_ID__c;
                userData.custom.add(c3);
                
                AH_SCIM_User.Custom c4 = new AH_SCIM_User.Custom();
                c4.key = 'managementCompanyName';
                c4.value = u.Account.Management_Company_Name__c;
                userData.custom.add(c4);
                
                //call callout function for user syncup
                objAH_SCIM_UserSyncCallout.syncUser(userData);
            }
		}//End of Scope
	}

	global void finish(Database.BatchableContext BC) {
		system.debug('In the finsh method of AH_SCIM_UserSyncCallout_Batch Apex.......');		
	}
}