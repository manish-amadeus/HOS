/*************************************************************************************************
Name            : AH_MilestoneSummation_Cntrl
Author          : Shashikant Nikam
Created Date    : 06/18/2018
Last Mod Date   : 07/03/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller for the AH_MilestoneSummation VF page
                : 
*************************************************************************************************/
public class AH_MilestoneSummation_Cntrl 
{
    
    // CLASS VARIABLES
    public boolean showMessage {get; set;}
    public boolean showSchMessage {get; set;} 
    public AH_Milestone_Settings__c milestoneSettings {get; set;}
    public List<AsyncApexJob> asyncJobList {get; set;}
    
    
    // CONSTRUCTOR
    public AH_MilestoneSummation_Cntrl()
    {
        
        // GET ORG DEFAULT MILESTONE SETTINGS TO BE USED IN FILTER CRITERIA OF SOQL
        milestoneSettings = AH_Milestone_Settings__c.getOrgDefaults();
        if (milestoneSettings == null)
        {
            milestoneSettings = new AH_Milestone_Settings__c();
        }
        
        CronTrigger cronjob = new CronTrigger();
        asyncJobList = new List<AsyncApexJob>();
        
        try 
        {
            // IF CLASS IS ALREADY SCHEDULED, SHOW MESSAGE
            cronjob = [SELECT Id, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name = 'Schedule Scrum Snapshot'];
            showSchMessage = true;
            String message = 'Schedule Scrum Snapshot job scheduled for ' + cronjob.NextFireTime.format();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, message));
        }
        catch (Exception e)
        {
            showSchMessage = false;
            system.debug(' **** ERROR OCCURRED: ' + e.getMessage());
        }
        
        // GET THE LIST OF LAST 5 RUNS TO SHOW ON VF PAGE
        try
        {
            asyncJobList = [SELECT ApexClassId, CompletedDate, CreatedBy.Name, Id, Status,
                            ExtendedStatus, TotalJobItems, JobItemsProcessed, NumberOfErrors
                            FROM AsyncApexJob
                            WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE Name = 'AH_MilestoneSummation_Batch')
                            ORDER BY CompletedDate DESC 
                            LIMIT 5];
        }
        catch (Exception e)
        {
            system.debug(' **** ERROR OCCURRED: ' + e.getMessage());
        }
        
    }
    
    // METHOD IS CALLED WHEN 'SCHEDULE APEX' BUTTON ON VF PAGE IS CLICKED
    public void callSchedulableClass()
    {
        // UPDATE/INSERT MILESTONE SETTINGS
        try
        {
            upsert milestoneSettings;  
        }
        catch (Exception e)
        {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Datetime.now().format() + ' - Error encountered while saving records. Please check data enetered.'));
            return;
        }
        
        CronTrigger cronJob = new CronTrigger();
        showMessage = false;
        
        // CHECK IF JOB IS ALREADY SCHEDULED
        try
        {
            cronJob = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Schedule Scrum Snapshot'];
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Job is already scheduled, please abort and reschedule!'));
        }
        catch (Exception e)
        {    
            showSchMessage = true;
            AH_MilestoneSummation_Schedule classObj = new AH_MilestoneSummation_Schedule();
            String sch = '0 0 0 * * ? *';
            String jobID = system.schedule('Schedule Scrum Snapshot', sch, classObj);
            String msg = 'Schedule Scrum Snapshot job scheduled for 12:00 AM daily to create Scrum Snapshots.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, msg));
        }
    }
    
    // ABORT THE SCHEDULED APEX JOB
    public void abortScheduledJob()
    {   
        // QUERY AsyncApexJob TO KNOW THE LAST TIME THE JOB SUCCESSFULLY RAN
        CronTrigger cronJob = new CronTrigger();
        try
        {
            cronJob = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Schedule Scrum Snapshot'];
            system.abortJob(cronJob.Id);
            showSchMessage = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Job aborted successfully!'));
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'No jobs found.')); 
        }
    }
    
}