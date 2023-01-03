/********************************************************************************************************
Name            : AH_ScheduleBatchScrumSnapshot Class
Author          : Shashikant Nikam
Created Date    : 06/26/2018
Last Mod Date   : 06/26/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Schedule Batch Apex job AH_BatchScrumSnapshot 
                : 
/**********************************************************************************************************/
global class AH_ScheduleBatchScrumSnapshot implements Schedulable {

    global void execute (SchedulableContext sc) {
        
        AH_BatchScrumSnapshot batchSurveyRecords = new AH_BatchScrumSnapshot();
        try {
            Database.executeBatch(batchSurveyRecords, 200); 
        }
        catch(Exception e){
            system.debug('Error occured at line no. : '+e.getLineNumber());
            system.debug('e.getMessage()'+e.getMessage());
        }
    }
}