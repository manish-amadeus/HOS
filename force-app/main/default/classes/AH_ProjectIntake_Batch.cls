/************************************************************************************************
Name            : AH_ProjectIntake_Batch Class
Author          : Sean Harris
Created Date    : 10/12/2020
Last Mod Date   : 10/12/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047197
Description     : Batchable class for the AH_ProjectIntake_Functions class
                : 
*************************************************************************************************/
global class AH_ProjectIntake_Batch implements Database.Batchable<sObject>, Database.stateful
{

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
		system.debug(' **$** in AH_ProjectIntake_Batch()'); 
        String strSOQL = 'SELECT Id FROM NI_Project_Backlog__c LIMIT 1'; 
        return Database.getQueryLocator(strSOQL);        
    }
    
    global void execute(Database.BatchableContext bc, List<NI_Project_Backlog__c> lst)
    {
        system.debug(' **$** in AH_ProjectIntake_Batch()'); 
        AH_ProjectIntake_Functions.recalcPriorityOnDemand();       
    }
    
    global void finish(Database.BatchableContext bc)
    {
        system.debug(' **$** in AH_ProjectIntake_Batch.finish() ');         
        try
        {
            for (CronTrigger cronJob : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE 'RecalcPriorities_%']){                system.abortJob(cronJob.Id);
            }
        }
        catch (Exception ex) { system.debug(' **$** ERROR OCCURRED ABORTING JOB: ' + ex.getMessage()); }            
    }

}