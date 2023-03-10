/****************************************************************************************
Name            : AH_Rally_AccountSync (TC Org Name: BatchSyncRallySFAccount)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : 
				: 
				: 
******************************************************************************************/ 
global class AH_Rally_AccountSync implements Database.Batchable<sObject>, Database.AllowsCallouts
{

    global Set<Id> caseList = new Set<Id>();
    //global List<String> fieldNames = new List<String>{'Rally_Risk_Retention__c'};
    global List<String> fieldNames = new List<String>{'TC_BID__c'};    
    global AH_Rally_AccountSync(Set<Id> accountCaseList)
    {
        caseList = accountCaseList;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        system.debug('in start batch AH_Rally_AccountSync : ');
        return DataBase.getQueryLocator([SELECT Id, Rally_Artifact_Ref__c, Account.Region__c FROM Case WHERE Id IN : caseList]);
    }
    
    global void execute(Database.BatchableContext bc, List<Case> scope)
    {
        system.debug('in execute batch BatchSyncRallySFAccount scope is : ' + scope);
        if (!scope.IsEmpty())
        {
            for (Case c : scope)
            {
                if (c.Rally_Artifact_Ref__c != null)
                {
                    system.debug('make callout');
                    AH_Rally_Library.updateAccountValuesInRally(c.Rally_Artifact_Ref__c, c.Id, fieldNames); 
                } 
            }
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    } 
    
}