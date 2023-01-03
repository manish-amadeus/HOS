/************************************************************************************************
Name            : AH_SandboxInit_BatchJobReq
Author          : Bhuleshwar Deshpande
Created Date    : 04/03/2020
Last Mod Date   : 04/03/2020
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : NICC-042469
Description     : Batch Class will be used to perform Delete NI_Job_Requisition__c Object Records.
				: 
************************************************************************************************/
global class AH_SandboxInit_BatchJobReq implements Database.Batchable<sObject>
{
    
    public Database.QueryLocator start(Database.BatchableContext ctx) 
    {
        return Database.getQueryLocator([SELECT Id FROM NI_Job_Requisition__c]);
    }
    
    global void execute(Database.BatchableContext BC, List<NI_Job_Requisition__c> scope)
    {
        Delete scope;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
}