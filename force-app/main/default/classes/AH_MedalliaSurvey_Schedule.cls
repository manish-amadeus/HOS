/***********************************************************************************************
Name            : AH_MedalliaSurvey_Schedule
Author          : Bhagwat Garkal
Created Date    : 04/28/2022
Last Mod Date   : 04/28/2022
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : Schedulable class for AH_MedalliaSurvey_Batch Class.   
                :
                :
************************************************************************************************/
global class AH_MedalliaSurvey_Schedule implements Schedulable 
{
    global void execute(SchedulableContext sc) 
    {
        try
        {
            List<Medallia_Selection_Criteria__c> updateCriteria = new List<Medallia_Selection_Criteria__c>();
            for (Medallia_Selection_Criteria__c serviceCriteria : [SELECT Id, Days_between_Surveys__c, Active__c, Last_Execution_time__c, Next_Execution_time__c, SurveySubType__c,
                                                                   RecordType.Name, RecordType.DeveloperName, SurveyType__c 
                                                                   FROM Medallia_Selection_Criteria__c 
                                                                   WHERE Active__c = true])
            {
                if (serviceCriteria.Next_Execution_time__c != null)
                {
                    Date executionDate = serviceCriteria.Next_Execution_time__c.date();
                    if (executionDate.isSameDay(System.today()))
                    {
                        serviceCriteria.Last_Execution_time__c = System.now();
                        AH_MedalliaSurvey_Batch batch = new AH_MedalliaSurvey_Batch(serviceCriteria.RecordType.DeveloperName, serviceCriteria.SurveyType__c, serviceCriteria.SurveySubType__c);
                        Id batchId = Database.executeBatch(batch);
                        
                        //Update Last_Execution_time
                        updateCriteria.add(serviceCriteria);
                    }    
                } 
            }
            
            //Updating Last_Execution_time, So Next_Execution_time will get setup
            if (!updateCriteria.isEmpty())
            {
                update updateCriteria;
            }
            
        }
        catch (Exception e)
        {
            AH_DTS_Integration_Logger.writeToDTSLog(system.now(), 'Medallia', 'Active', 'Error', 'Error Scheduling Apex Job', e.getMessage(), '4 - Minor', UserInfo.getUserName(), 'AH_MedalliaSurvey_Schedule', 'Apex Job Scheduler', 'Salesforce', true, false); 
        }
    }
    
}