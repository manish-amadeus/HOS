public with sharing class PsaCustomSelfAssignmentController 
{
    public pse__Assignment__c assignment{get;set;}
    public pse__Schedule__c schedule{get;set;}
    public string resourceName{get;set;}
    public string successMessage{get;set;}
    public Date earliestStartDate;
    public Date latestEndDate;

    public PsaCustomSelfAssignmentController()
    {
        assignment = new pse__Assignment__c();
                
        // Get the resource name     
        for(Contact con : [select Id, Name, pse__Salesforce_User__c from contact where pse__Salesforce_User__c = : UserInfo.getUserId() limit 1])
        {
            assignment.pse__Resource__c = con.id;
            resourceName = con.Name;      
        }
        
        // Initialize Schedule
        schedule = new pse__Schedule__c(pse__start_Date__c = Date.Today(),pse__End_Date__c = Date.Today());
        
        // Initialize Assignment
        assignment.pse__Is_Billable__c =  false;
        assignment.pse__Time_Credited__c = true;
        assignment.pse__Exclude_from_Planners__c = true;
        assignment.pse__Bill_Rate__c = 0;
        //assignment.pse__Status__c = 'Scheduled';
        assignment.Name = 'TT Tasks - ' + resourceName;
        
        // Earliest start date is the beginning of the prior week, and latest end date is the end of the next week
        earliestStartDate = Date.Today().toStartOfWeek() -7;
        //latestEndDate = Date.today().toStartOfWeek() + 6;
        latestEndDate = Date.today().toStartOfWeek() + 13; //ADDED PER SALESFORCE.COM CHANGE REQUEST: NICC-006354
    }

  
    public PageReference createAssignment()
    {
        pageReference pageRef = null;
        Savepoint assignmentSavePoint = Database.setSavepoint();
        
        try
        {
            // Check start date <= end date
            if(schedule.pse__End_Date__c < schedule.pse__Start_Date__c)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'The assignment End Date cannot be prior to its Start Date.'));
                return null;
            }
            
            // Check that start date is in this week or last week
            if(schedule.pse__Start_Date__c < earliestStartDate)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'The assignment must start within this week, next week or last week.'));
                return null;
            }
            
            // Check that end date is this week or last week
            if(schedule.pse__End_Date__c > latestEndDate)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'The assignment must end within this week, next week or last week.'));
                return null;
            }
            
            System.debug('*** Assignment.Project is: ' + assignment.pse__Project__c);
            System.debug('*** Assignment.Milestone is: ' + assignment.pse__Milestone__c);
            System.debug('*** Assignment.Resource is: ' + assignment.pse__Resource__c);
            //System.debug('*** Assignment.Start Date is: ' + assignment.pse__Project__c);
            //System.debug('*** Assignment.End Date is: ' + assignment.pse__End_Date__c);
            
            
            /* REMOVED THIS FOR NOW. It should be OK for there to be multiple same-resource assignments to a project/milestone
            * For example, one might be closed already, or for a different set of days.
            // Check whether the resource is already assigned to this project/milestone
            // If so, throw a validaton error.
            // TO DO: Check whether we should find out if the existing assignment is CFTE, and if so open it, and if not, throw the error.
            pse__Assignment__c[] existingAssignments = [select Id, Name from pse__Assignment__c 
                    where pse__Resource__c = : assignment.pse__Resource__c 
                    and pse__Project__c = : assignment.pse__Project__c
                    and pse__Milestone__c = : assignment.pse__Milestone__c ];
            
            if (existingAssignments != null && existingAssignments.size() > 0) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'You already have an assignment for this project/milestone: ' + existingAssignments[0].Name));
                return null;
            }
            */
            

            // Create the Schedule
            schedule.pse__Monday_Hours__c = 0;
            schedule.pse__Tuesday_Hours__c = 0;
            schedule.pse__Wednesday_Hours__c = 0;
            schedule.pse__Thursday_Hours__c = 0;
            schedule.pse__Friday_Hours__c = 0;
            schedule.pse__Saturday_Hours__c = 0;
            schedule.pse__Sunday_Hours__c = 0;
            schedule.pse__Scheduled_Hours__c = 0;
            insert schedule;
            
            System.debug('***schedule.Id is: ' + schedule.Id);
            
            // Set the Assignment Schedule and create the Assignment
            assignment.pse__Schedule__c = schedule.Id;
            insert assignment;
            successMessage = 'Assignment successfully created.';
            
            // Once the assignment has been inserted, update it to set it to non-billable etc
            // This is necessary because a pse before insert trigger on the assignment automatically
            // sets it to billable.
            assignment.pse__Is_Billable__c = false;
            assignment.pse__Time_Credited__c = true;
            assignment.pse__Exclude_from_Planners__c = true;
            assignment.pse__Bill_Rate__c = 0;
            assignment.pse__Status__c = 'Scheduled';
            update assignment;
            
            pageRef = new pageReference('/'+assignment.Id);
        }
        catch(Exception ex)
        {
            System.debug('Error creating assignment: ' + ex.getMessage());
            Database.rollBack(assignmentSavePoint);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
        }
        return pageRef;
    }

    public PageReference cancel()
    {
        return new PageReference('/home/home.jsp');
    }
}