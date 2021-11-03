/****************************************************************************************
Name            : AH_FetchTrialExpirationBatch Class
Author          : Shashikant Nikam
Created Date    : 10/27/2017
Last Mod Date   : 04/23/2019 
Last Mod By     : Sean Harris
NICC Reference  : NICC-025235
Description     : Batch class to update TrialExpiartion Date and Banquets field on NI_Org_Details__C object.
                : NICC-034313 - Updated API version
******************************************************************************************/
global class AH_FetchTrialExpirationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts 
{

    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        
        system.debug(' ***  ENTERING AH_FetchTrialExpirationBatch.start() - QUERIES ISSUED = ' + Limits.getQueries());
		
        // GET LIST OF ORG DETAILS
        string query = 'SELECT Id, Name, ';
        query += 'Admin_Login_Name_Encrypted__c, Admin_Password_Encrypted__c, '; 
        query += 'Org_Type__c, Security_Token_Encrypted__c, Org_ID__c ';
        query += 'FROM NI_Org_Details__c ';
        query += 'WHERE Org_Type__c LIKE \'Salesforce%\' AND DisablePolling__c = false AND Org_ID__c != null';
        
        system.debug(' **** query = ' + query);
        
        system.debug(' ***  EXITING AH_FetchTrialExpirationBatch.start() - QUERIES ISSUED = ' + Limits.getQueries());
		
        return Database.getQueryLocator(query);
        
    }
        
    global void execute(Database.BatchableContext BC, List<NI_Org_Details__c> scope)
    {
        
        system.debug(' ***  ENTERING AH_FetchTrialExpirationBatch.execute() - QUERIES ISSUED = ' + Limits.getQueries());
		
		system.debug(' **** scope = ' + scope);
        
        List<NI_Org_Details__c> org_detail_ids_tobeUpdated = new List<NI_Org_Details__c>();
        List<NI_Admin_Error_Log__c> ErrorLog_List = new List <NI_Admin_Error_Log__c>();
        
        for (NI_Org_Details__c targetOrgs : scope)
        {
            if (targetOrgs.Admin_Login_Name_Encrypted__c != null && targetOrgs.Admin_Password_Encrypted__c != null && targetOrgs.Security_Token_Encrypted__c != null)
            {
                
                NI_Org_Details__c Org = new NI_Org_Details__c();
                Map<String, String> sessionInfo = AH_FetchTrialExpirationBatchHelper.connect(targetOrgs.Org_Type__c, targetOrgs.Admin_Login_Name_Encrypted__c, targetOrgs.Admin_Password_Encrypted__c, targetOrgs.Security_Token_Encrypted__c, targetOrgs.Id);
                
                if (sessionInfo.get('login_success') == 'false') 
                {
					Org.Id = sessionInfo.get('orgId');
                    if (sessionInfo.get('ExpiredPassword') == 'True') 
                    {
                        Org.Expired_Password__c = true;
                	}
                }
                else 
                {
					Org = AH_FetchTrialExpirationBatchHelper.updateOrgDetails(sessionInfo.get('SERVER_URL'), sessionInfo.get('SESSION_ID'), sessionInfo.get('login_success'), targetOrgs.Id);
                    Org = AH_FetchTrialExpirationBatchHelper.fetchTrialExpDate(sessionInfo.get('SERVER_URL'), sessionInfo.get('SESSION_ID'), sessionInfo.get('login_success'), Org);
                }

				// LIST OF ORGS TO BE UPDATED                
                org_detail_ids_tobeUpdated.add(Org);
                
            }
            
        }
        
        if (!org_detail_ids_tobeUpdated.isEmpty()) 
        {
            update org_detail_ids_tobeUpdated;
        }
        
        system.debug(' ***  EXITING AH_FetchTrialExpirationBatch.execute() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }

    global void finish(Database.BatchableContext BC)
    { 
    }
    
}