/************************************************************************************************
Name            : AH_BatchScrumSnapshot Class
Author          : Shashikant Nikam
Created Date    : 06/26/2018
Last Mod Date   : 06/26/2018 
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Query Services_Scrum_Snapshot__c records that have been created in between date range 
				: specified to insert in Scrum_Snapshot_History__b BIG OBJECT
*************************************************************************************************/
global class AH_BatchScrumSnapshot implements Database.Batchable<sObject> {
    
    public static Integer totalAmtOfRecords = 0;
    
    global Database.QueryLocator start (Database.BatchableContext bc) {
        
        String query = 'select ID, Name, Actual_Amount__c, Backlog_Amount__c, Budget_Amount__c, Comp_Amount__c, '+
            'Date_of_Pull__c, Downside_Amount__c, Forecast_Amount__c, Group__c, Service_Group__c, Region_Name__c, '+
            'Reimbursable_Expenses__c, Scheduled_Amount__c, Scheduled_Hours__c, '+
            'Target_Period__c, Tentative_Value__c, Upside_Amount__c '+
            'from Services_Scrum_Snapshot__c';
        // ADD DATE CONDITION IN WHERE CLAUSE 

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Services_Scrum_Snapshot__c> scope){
        
        system.debug('scope : '+scope);
        
        try {
            totalAmtOfRecords = scope.size();
            List<Scrum_Snapshot_History__b> historyList  = new List<Scrum_Snapshot_History__b>();
            for (Services_Scrum_Snapshot__c sc: scope){
                
                Scrum_Snapshot_History__b history = new Scrum_Snapshot_History__b();
                history.Services_Scrum_Snapshot_SF_ID__c = sc.id;
                history.Services_Scrum_Snapshot_Name__c = sc.Name;
                history.Actual_Amount__c 	= String.valueOf(sc.Actual_Amount__c);
                history.Backlog_Amount__c 	= String.valueOf(sc.Backlog_Amount__c);
                history.Budget_Amount__c 	= String.valueOf(sc.Budget_Amount__c);
                history.Comp_Amount__c 		= String.valueOf(sc.Comp_Amount__c);
                history.Date_of_Pull__c	 	= String.valueOf(sc.Date_of_Pull__c);
                history.Downside_Amount__c 	= String.valueOf(sc.Downside_Amount__c);
                history.Forecast_Amount__c	= String.valueOf(sc.Forecast_Amount__c);
                history.Group__c 			= sc.Group__c;
                history.Service_Group__c 	= sc.Service_Group__c;
                history.Region_Name__c 		= sc.Region_Name__c;
                history.Reimbursable_Expenses__c = String.valueOf(sc.Reimbursable_Expenses__c);
                history.Scheduled_Amount__c = String.valueOf(sc.Scheduled_Amount__c);
                history.Scheduled_Hours__c 	= String.valueOf(sc.Scheduled_Hours__c);
                history.Target_Period__c 	= sc.Target_Period__c;
                history.Tentative_Value__c 	= String.valueOf(sc.Tentative_Value__c);
                history.Upside_Amount__c 	= String.valueOf(sc.Upside_Amount__c);
                
                historyList.add(history);
            }
            
            if (!historyList.isEmpty()){
                
                Boolean isSuccess = true;
                if (!Test.isRunningTest()){
                    // INSERT DATA INTO Scrum_Snapshot_History__b BIG OBJECT
                    List<Database.SaveResult> saveResult = Database.insertImmediate(historyList);
                    
                    // ITERATE THROUGH EACH RETURNED RESULT
                    for (Database.SaveResult sr : saveResult) {
                        if (!sr.isSuccess()) {
                            isSuccess = false;
                            // OPERATION FAILED, SO GET ALL ERRORS
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
                }
                if (isSuccess){
                    
                    // DELETE THE RECORDS FROM Services_Scrum_Snapshot__c OBJECT 
                    // AS THESE ARE STORED IN Scrum_Snapshot_History__b BIG OBJECT
                    Database.delete(scope);
                    system.debug('Deleted '+ scope.size() +' Service - Scrum Snapshot records.');
                }
                //}
            }
        }
        catch (Exception e){
            system.debug('Error occured at line no. : '+e.getLineNumber());
            system.debug('e.getMessage() : '+e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext bc){
        system.debug('Batch Finished');
        system.debug('Total no of records processed : '+totalAmtOfRecords);
    }
}