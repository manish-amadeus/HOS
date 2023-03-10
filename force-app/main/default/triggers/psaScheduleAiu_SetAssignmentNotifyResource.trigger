/****************************************************************************************
Name            : psaScheduleAiu_SetAssignmentNotifyResource
Author          : CLD
Created Date    : October 31, 2011
Description     : The Assignment object has a Notify Resource field which, when checked,
                : triggers a workflow that sends a notification to the assigned Resource
                : and to the Project's PM about any assignment changes.  
                : When a schedule changes, this sets that field if the start date is 
                : within 3 weeks of the current date in order to send the notification.
                : It also gets the PM on the assignment's Project, and sets it in the Assignment
                : Project Manager field so that it can be used for notifying the PM.
******************************************************************************************/
trigger psaScheduleAiu_SetAssignmentNotifyResource on pse__Schedule__c (after insert, after update) 
{
    Date notifyWithinDate = System.Today() + 21;
    List<pse__Assignment__c> assignmentsToUpdate = new List<pse__Assignment__c>();
    
    Map<Id, pse__Assignment__c> assignments = new Map<Id, pse__Assignment__c>(
        [SELECT Notify_Resource__c, Name, pse__Schedule__c, pse__Project__r.pse__Project_Manager__c 
           FROM pse__Assignment__c 
          WHERE pse__Schedule__c in :Trigger.new]);
        
    
    for(pse__Schedule__c schedule: Trigger.New)
    {
        try
        {
            Date startDate = schedule.pse__Start_Date__c;
            Date endDate = schedule.pse__End_Date__c;
            Date oldStartDate = startDate;
            
            if(Trigger.isUpdate) 
            {
                oldStartDate = Trigger.oldMap.get(schedule.Id).pse__Start_Date__c;
            }
            
            // Queue up a notification if:
            // - New assignment or update to assignment where start date changed, and
            // - Start date not in the past, and
            // - New start date is within 21 days or old start date was within 21 days from today
            if((Trigger.isInsert || oldStartDate <> startDate) && (startDate >= System.Today()) && (startDate <= notifyWithinDate) || (startDate <= notifyWithinDate))
            {
                for(Id assignmentId: assignments.keySet())
                {
                    pse__Assignment__c assignment = assignments.get(assignmentId);
                    System.debug('Checking assignment ' + assignment.Name);
                    if(assignment.pse__Schedule__c == schedule.Id)
                    {
                        System.debug('Found match');
                        assignment.Notify_Resource__c=true;
                        Id projectPM = assignment.pse__Project__r.pse__Project_Manager__c;
                        if(projectPM != null)
                        {
                            assignment.Project_Manager__c = projectPM;
                        }
                        assignmentsToUpdate.add(assignment);
                    }
                }
            }
        }
        catch(Exception e)
        {
            System.debug('Error setting resource notification flag: ' + e.getMessage());
            schedule.addError('Error setting resource notification flag: ' + e.getMessage());
        }
    }
    
    // Update assignments that fit the criteria
    if(assignmentsToUpdate.size() > 0)
    {
        Database.SaveResult[] results = Database.update(assignmentsToUpdate);
        for(Database.SaveResult sr: results)
        {
            if(!sr.isSuccess())
            {
                Database.Error err = sr.getErrors()[0];
                System.debug(err.getMessage());
            }
        }
    }
}