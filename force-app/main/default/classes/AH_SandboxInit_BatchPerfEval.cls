/************************************************************************************************
Name            : AH_SandboxInit_BatchPerfEval
Author          : Bhuleshwar Deshpande
Created Date    : 04/06/2020
Last Mod Date   : 04/06/2020
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : NICC-042469
Description     : Batch Class will be used to perform Delete NI_Employee_Performance_Evaluation__c Object Records.
				: 
************************************************************************************************/
global class AH_SandboxInit_BatchPerfEval implements Database.Batchable<sObject>
{
    
    public Database.QueryLocator start(Database.BatchableContext ctx) 
    {
        return Database.getQueryLocator([SELECT Id FROM NI_Employee_Performance_Evaluation__c]);
    }
    
    global void execute(Database.BatchableContext BC, List<NI_Employee_Performance_Evaluation__c> scope)
    {
        Delete scope;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
}