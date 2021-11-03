/************************************************************************************************
Name            : AH_CreateRemoteSites_Batch Class
Author          : Shashikant Nikam
Created Date    : 4/20/2019
Last Mod Date   : 5/7/2019
Last Mod By     : Stuart Emery
NICC Reference  : NICC-034473
Description     : Batch class for AH_Schedule_CreateRemoteSites schedulable class.
				: Query Polling Result records for 'Unauthorized endpoint' error type & create remote sites.
				: 
				:
*************************************************************************************************/

global class AH_CreateRemoteSites_Batch implements Database.Batchable <sObject>,Database.AllowsCallouts, Database.Stateful
{
						
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String retQuery = 'SELECT ID, '+
            				' Name, '+
            				' Endpoint_URL__c, '+
            				' AccountId__c, '+
            				' AccountId__r.Org_Type__c, '+
                            ' AccountId__r.Admin_Login_Name_Encrypted__c, '+
                            ' AccountId__r.Admin_Password_Encrypted__c, '+
                            ' AccountId__r.Security_Token_Encrypted__c '+
            				' FROM PollingResult__c '+
            				' WHERE CreatedDate = Last_N_Days:4 '+
                            ' AND ErrorType__c = \'Unauthorized endpoint\'';
        
        system.debug('retQuery : '+retQuery);
        
        return Database.getQueryLocator(retQuery);
    }
    
    global void execute(Database.BatchableContext bc , List<PollingResult__c> pollingResults)
    {
        system.debug('pollingResults size : '+pollingResults.size());
        for (PollingResult__c poll : pollingResults)
        {
            try 
            {
                AH_CreateRemoteSites createRemSitesObj = new AH_CreateRemoteSites(poll, poll.Endpoint_URL__c);
                createRemSitesObj.login();
            }
            catch(Exception e)
            {
                AH_CreateRemoteSites a = new AH_CreateRemoteSites();
                a.WriteToLog(poll.AccountId__c, 'Exception occured at line no. :'+e.getlinenumber()+'. '+e.getMessage(), 'PollingResult__c', 'AH_CreateRemoteSites_Batch', 'Metadata API callout');
            }
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
    }
}