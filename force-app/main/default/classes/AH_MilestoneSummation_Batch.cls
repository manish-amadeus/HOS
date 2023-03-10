/****************************************************************************************
Name            : AH_MilestoneSummation_Batch
Author          : Ria Chawla
Created Date    : 06/20/2018
Last Mod Date   : 07/03/2019
Last Mod By     : Sean Harris 
NICC Reference  : 
Description     : Batch class to create Scrum Snapshot using queried data
				:
******************************************************************************************/
global class AH_MilestoneSummation_Batch implements Database.Batchable<sObject> 
{
    
    //CLASS VARIABLES
    public Map<String, AH_MilestoneSummation_Schedule.MilestoneWrapper> mapOfMilestone;
    public String queryVar = '';
    
    //CONSTRUCTOR
    public AH_MilestoneSummation_Batch(Map<String, AH_MilestoneSummation_Schedule.MilestoneWrapper> mapOfMilestoneJ)
    {
        mapOfMilestone = new Map<String, AH_MilestoneSummation_Schedule.MilestoneWrapper>();
        mapOfMilestone = mapOfMilestoneJ;
    }
    
    global Iterable<sObject> start(Database.BatchableContext BC)
    {
        // LIST TO STORE SERVICES SCRUM SNAPSHOT RECORDS TO BE INSERTED
        List<Services_Scrum_Snapshot__c> scrumSnapshotToInsert = new List<Services_Scrum_Snapshot__c>();
        
        if (!mapOfMilestone.isEmpty())
        {
            
            // FOR EACH VALUE IN MAP, CREATE A RECORD
            for (String l : mapOfMilestone.keySet())
            {
                AH_MilestoneSummation_Schedule.MilestoneWrapper wrapperObj = mapOfMilestone.get(l);
                Services_Scrum_Snapshot__c scrumObj = new Services_Scrum_Snapshot__c();
                scrumObj.Date_of_Pull__c = Date.today();
                scrumObj.Region_Name__c = wrapperObj.projectRegion;
                scrumObj.Group__c = wrapperObj.projectGroup;
                
                // ADDED BY SHASHIKANT ON 6/18/2019
                Integer month = wrapperObj.targetDate.month();
                Integer year = wrapperObj.targetDate.year();
                String targetPeriod = year + '-0' + month;
                if (month > 9)
                {
                    targetPeriod = year + '-' + month;
                }

                scrumObj.Target_Period__c = targetPeriod; 
                scrumObj.Scheduled_Amount__c = wrapperObj.milestoneAmount;
                scrumSnapshotToInsert.add(scrumObj);
            }  
        }
        
        return scrumSnapshotToInsert;
        
    }
    
    global void execute(Database.BatchableContext BC, List<Services_Scrum_Snapshot__c> scope)
    { 
        // IF LIST IS NOT EMPTY, INSERT IT
        if (!scope.isEmpty())
        {
            try
            {
                Database.insert(scope);
            }
            catch (Exception e) 
            {  
            }
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //DO NOTHING
    }
    
}