/****************************************************************************************
Name            : psaTimecardHeaderAiu_SendMilestoneToApprovalWhenComplete
Author          : CLD
Created Date    : October 28, 2011
Last Modified   : May 20, 2012 by Stu Emery per SFDC Change Request NICC-004997
Description     : When a timecard has just been updated with a Project Phase of 'Milestone Complete',
                : and the project is not an internal project, this submits the milestone into the 
                : milestone approval process.  The milestone is sent for approval under the following 
                : circumstances:
                : - Timecard was just approved (prior version of timecard record was not approved)
                : - Project Phase specified on timecard is 'Milestone Complete'
                : - Project type is 'Customer Project'
                : - Project's 'Timecard Requires Milestone' is set to true
                : - Milestone status is 'Open'
                :
                : Before sending the milestone for approval, this will also set the milestone
                : actual date to the last date on the timecard for which time is entered.
******************************************************************************************/
trigger psaTimecardHeaderAiu_SendMilestoneToApprovalWhenComplete on pse__Timecard_Header__c (after insert, after update) 
{
    public static final String TIMECARD_PROJ_PHASE_MILESTONE_COMPLETE = 'Milestone Complete';
    public static final String PROJECT_PROJ_TYPE_CUSTOMER = 'Customer Project';
    public static final String MILESTONE_STATUS_OPEN = 'Open';
        
    // Get associated project and miletone info
    Set<Id> milestoneIds = new Set<Id>();
    Set<Id> projectIds = new Set<Id>();
    Set<Id> assignmentIds = new Set<Id>();    

    for (pse__Timecard_Header__c tc : Trigger.new) 
    {
        milestoneIds.add(tc.pse__Milestone__c);
        projectIds.add(tc.pse__Project__c);
        assignmentIds.add(tc.pse__Assignment__c);        
    }
    
    // Look up associated project and milestones info to determine whether the project requires milestone approval
    // and to get the milestones themselves for submission to approval process if necessary
    // Original Code by CLD
    //Map<Id, pse__Milestone__c> milestones = new Map<Id, pse__Milestone__c>(
        //[SELECT Name, pse__Status__c 
           //FROM pse__Milestone__c 
         // WHERE id IN :milestoneIds]);
          
      //New Code Updated on 5/20/2012 per SFDC Change Request NICC-004997 to only select Milestones 
      //with Assignments where 'Billable' is set to true
      //************UPDATED ON 12/3/2015 PER NICC-016119*************************
      //ADDED THE "Id IN :assignmentIds" TO MAKE THE QUERY MORE SELECTIVE
     Map<Id, pse__Milestone__c> milestones = new Map<Id, pse__Milestone__c>(
        [SELECT Name, pse__Status__c 
           FROM pse__Milestone__c 
          WHERE id IN (SELECT pse__Milestone__c FROM pse__Assignment__c WHERE Id IN :assignmentIds AND pse__Is_Billable__c = true) 
           AND id IN :milestoneIds]);      
        
    Map<Id, pse__Proj__c> projects = new Map<Id, pse__Proj__c>(
        [SELECT Name, Timecards_Require_Milestone__c, pse__Project_Type__c, pse__Project_Manager__r.pse__Salesforce_User__c 
           FROM pse__Proj__c 
          WHERE id IN :projectIds]);
          
    Map<Id, pse__Assignment__c> assignments = new Map<Id, pse__Assignment__c> (
       [SELECT Name, pse__Is_Billable__c 
          FROM pse__Assignment__c 
        WHERE id IN :assignmentIds]);         
    
 
    for (pse__Timecard_Header__c tc: Trigger.new) 
    {
        try
        {
            // Only submit milestone for approval if timecard was just approved
            if(tc.pse__Approved__c && !Trigger.OldMap.get(tc.Id).pse__Approved__c)
            {
            System.debug('In here1 xxxxx' + tc);
                // Only submit milestone for approval if a project phase was specified as Miletone Complete
                if(tc.pse__Project_Phase__c != null && tc.pse__Project_Phase__c.equals(TIMECARD_PROJ_PHASE_MILESTONE_COMPLETE)) 
                {
                System.debug('In here2 xxxxx' + tc);
                    // Only submit milestone for approval if time for project requires milestone
                    // and the project is a customer project
                    String projectType = projects.get(tc.pse__Project__c).pse__Project_Type__c;
                    Id pmId = projects.get(tc.pse__Project__c).pse__Project_Manager__r.pse__Salesforce_User__c;
                    
                    boolean tcRequiresMilestone = projects.get(tc.pse__Project__c).Timecards_Require_Milestone__c;
                    if(projectType!= null && projectType.equals(PROJECT_PROJ_TYPE_CUSTOMER) && tcRequiresMilestone)
                     {
                     System.debug('In here3 xxxxx' + tc);
                      boolean assignmentIsBillable = false;
                      assignmentIsBillable = assignments.get(tc.pse__Assignment__c).pse__Is_Billable__c;
                       if(assignmentIsBillable)
                       {                    
                       System.debug('In here4 xxxxx' + tc);
                        // Send in the milestone for approval if it has an 'Open' status.
                        pse__Milestone__c milestone = milestones.get(tc.pse__Milestone__c);
                        if(milestone != null && milestone.pse__Status__c != null && milestone.pse__Status__c.equals(MILESTONE_STATUS_OPEN))
                        {
                         System.debug('In here5 xxxxx' + tc);
                            // Set the actual date on the milestone to the last date with time entered on the timecard
                            milestone.pse__Actual_Date__c = getTimecardLastDate(tc);
                            
                            // Set the approver on the Milestone to be the PM on the Project
                            if(pmId!=null)
                            {
                                milestone.pse__Approver__c = pmId;
                            }
                            
                            update milestone;
                            
                            // Send the milestone to approval
                            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                            req1.setComments('Submitting milestone for approval.');
                            req1.setObjectId(milestone.Id);
                            Approval.ProcessResult result1 = Approval.process(req1);
                        }
                    }
                }
            }
        }
    }        
        catch(Exception e)
        {
            System.debug('Error checking for / initiating milestone approval process: ' + e.getMessage());
            tc.addError('Error checking for / initiating milestone approval process: ' + e.getMessage());
        }
    }
  
    // Returns the last date on the timecard for which hours entered > 0
    // If it is a 0-hour timecard, it will return the first date on the timecard.
    private Date getTimecardLastDate(pse__Timecard_Header__c timecard)
    {   
        Date endDate = timecard.pse__End_Date__c;
        Date lastDate = timecard.pse__Start_Date__c;
        if(timecard.pse__Saturday_Hours__c > 0)
        {
            lastDate = endDate;
        }
        else if(timecard.pse__Friday_Hours__c > 0)
        {
            lastDate = endDate - 1;
        }
        else if(timecard.pse__Thursday_Hours__c > 0)
        {
            lastDate = endDate - 2;
        }
        else if(timecard.pse__Wednesday_Hours__c > 0)
        {
            lastDate = endDate - 3;
        }
        else if(timecard.pse__Tuesday_Hours__c > 0)
        {
            lastDate = endDate - 4;
        }
        else if(timecard.pse__Monday_Hours__c > 0)
        {
            lastDate = endDate - 5;
        }
        else if(timecard.pse__Sunday_Hours__c > 0)
        {
            lastDate = endDate - 6;
        }
        
        return lastDate;
    }
}