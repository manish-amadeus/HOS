/********************************************************************************************************
Name            : AH_ScheduleBatchSurveyResData Class
Author          : Ria Chawla
Created Date    : 09/14/2017
Last Mod Date   : 09/27/2017 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-024092
Description     : Schedule Batch Apex job AH_BatchSurveyResponseData 
                : Test class is called AH_UpdateContactScoreControllerTest
/**********************************************************************************************************/
global class AH_ScheduleBatchSurveyResData implements Schedulable
{

    global void execute(SchedulableContext sc)
    {
        
        // QUERY AsyncApexJob TO KNOW THE LAST TIME THE JOB SUCCESSFULLY RAN
        AsyncApexJob asyncJob = new AsyncApexJob();
        asyncJob = [SELECT ApexClassId, CompletedDate, CreatedById, CreatedDate, Id, NumberOfErrors, Status
                    FROM AsyncApexJob
                    WHERE Status = 'Completed'
                    AND ApexClassId IN (SELECT Id FROM ApexClass WHERE Name = 'AH_BatchSurveyResponseData')
                    ORDER BY CompletedDate DESC 
                    LIMIT 1];
        
        if (asyncJob != null)
        {
            system.debug('AH_ScheduleBatchSurveyResData asyncJob = ' + asyncJob);
            Datetime strDt = asyncJob.CompletedDate;
            Datetime endDt = Date.today();
            endDt = endDt.addDays(1);
            AH_BatchSurveyResponseData batchSurveyRecords = new AH_BatchSurveyResponseData(strDt, endDt);
            try
            {
                Database.executeBatch(batchSurveyRecords, 25); 
            }
            catch (Exception e) { system.debug('ERROR OCCURRED ' + e.getMessage());}
        }
        
    }

}