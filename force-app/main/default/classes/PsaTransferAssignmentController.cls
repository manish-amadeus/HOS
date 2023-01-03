/************************************************************************************************
Name            : PsaTransferAssignmentController 
Author          : CLD Partners
Created Date    : 12/08/2011
Last Mod Date   : 03/14/2019
Last Mod By     : Sean Harris
NICC Reference  :
Description     : Written by CLD Partners. Updated to meet AH Standards
                : Controller for PsaTransferAssignment VF Page
                :
                :
*************************************************************************************************/
public with sharing class PsaTransferAssignmentController 
{

    private pse__Assignment__c origAssignment;
    private pse__Schedule__c origSchedule;
    private pse__Assignment__c newAssignment;
    private pse__Schedule__c newSchedule;
    private String origAssignmentName;
    private String origProjectName;
    private String origResourceName;
    private String transferType;
    private List<SelectOption> transferTypeOptions;
    private boolean isCopySchedule;
    private boolean isCloseOriginal = false;
    private boolean isNewResourceRendered = false;
    private boolean isNewProjectRendered = true;
    private List<SelectOption> milestoneOptions;
    private Id newAssignmentId;
    private boolean transferComplete = false;
  
    
    public PsaTransferAssignmentController(ApexPages.StandardController controller) 
    {
        
        pse__Assignment__c assignmentIn = (pse__Assignment__c)controller.getRecord();
        
        system.debug(' **** Current assignment Id = ' + assignmentIn.Id);
        
        this.origAssignment = [SELECT Id, Name, pse__Project__c, pse__Project__r.Name, pse__Resource__c, pse__Resource__r.Name, pse__Role__c,
                               pse__Start_Date__c, pse__End_Date__c, pse__Milestone__c, pse__Milestone__r.Name, pse__Billable_Hours_Submitted__c, 
                               pse__Billable_Expenses_Submitted__c, pse__Non_Billable_Hours_Submitted__c, pse__Non_Billable_Expenses_Submitted__c, 
                               pse__Project__r.pse__Start_Date__c, pse__Schedule__c, pse__Cost_Rate_Amount__c, pse__Location__c, OwnerId, 
                               pse__Description__c, pse__Assignment_Daily_Notes__c, pse__Status__c, pse__Is_Billable__c, pse__Bill_Rate__c, 
                               pse__Closed_for_Expense_Entry__c, pse__Closed_for_Time_Entry__c, NI_411_Description__c, pse__Time_Credited__c, 
                               pse__Time_Excluded__c, Contact_Name__c
                               FROM pse__Assignment__c 
                               WHERE Id =: assignmentIn.Id];
        
        this.origSchedule = [SELECT Id, Name, pse__Start_Date__c, pse__End_Date__c, pse__Sunday_Hours__c, 
                             pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c, pse__Thursday_Hours__c, 
                             pse__Friday_Hours__c, pse__Saturday_Hours__c, pse__Scheduled_Hours__c, pse__Scheduled_Days__c 
                             FROM pse__Schedule__c 
                             WHERE Id =: origAssignment.pse__Schedule__c];   
        
        if (origAssignment != null)
        {
            origAssignmentName = origAssignment.Name;
            origProjectName = origAssignment.pse__Project__r.Name;
            origResourceName = origAssignment.pse__Resource__r.Name;
            system.debug(' **** Current assignment Name = ' + origAssignmentName);
            system.debug(' **** Current assignment Project = ' + origProjectName);
            system.debug(' **** Current assignment Resource = ' + origResourceName);
        }
        
        newSchedule = new pse__Schedule__c();
        newSchedule.pse__Start_Date__c = origAssignment.pse__Start_Date__c; 
        newSchedule.pse__End_Date__c = origAssignment.pse__End_Date__c;
        
        // Initialize the new assignment with info from the original
        newAssignment = new pse__Assignment__c();
        newAssignment.pse__Project__c = origAssignment.pse__Project__c; 
        newAssignment.pse__Resource__c = origAssignment.pse__Resource__c; 
        newAssignment.pse__Milestone__c = origAssignment.pse__Milestone__c;
        newAssignment.pse__Status__c = origAssignment.pse__Status__c;
        newAssignment.pse__Description__c = origAssignment.pse__Description__c;
        newAssignment.pse__Assignment_Daily_Notes__c = origAssignment.pse__Assignment_Daily_Notes__c; 
        newAssignment.pse__Is_Billable__c = origAssignment.pse__Is_Billable__c;
        newAssignment.pse__Bill_Rate__c = origAssignment.pse__Bill_Rate__c; 
        newAssignment.pse__Closed_for_Expense_Entry__c = origAssignment.pse__Closed_for_Expense_Entry__c;
        newAssignment.pse__Closed_for_Time_Entry__c = origAssignment.pse__Closed_for_Time_Entry__c; 
        newAssignment.NI_411_Description__c = origAssignment.NI_411_Description__c;
        newAssignment.pse__Time_Credited__c = origAssignment.pse__Time_Credited__c; 
        newAssignment.pse__Time_Excluded__c = origAssignment.pse__Time_Excluded__c;
        
        // Initialize the dropdown list of transfer type options and initialize default transfer type
        transferTypeOptions = new List<SelectOption>();
        transferTypeOptions.add(new SelectOption('RTP', 'Assign Resource to Another Project'));
        transferTypeOptions.add(new SelectOption('RRP', 'Replace Resource on Original Project'));
        transferType = 'RTP';
        
    }

    public pse__Assignment__c getOrigAssignment()
    {
        return origAssignment;
    }
    
    public pse__Assignment__c getNewAssignment()
    {
        return newAssignment;
    }
    
    public pse__Schedule__c getNewSchedule()
    {
        return newSchedule;
    }
        
    public String getOrigProjectName()
    {
        return origProjectName;
    }
    
    public String getTransferType()
    {
        return transferType;
    }
    
    public void setTransferType(String tt)
    {
        this.transferType = tt;
    }
    
    public List<SelectOption> getTransferTypeOptions()
    {
        return transferTypeOptions;
    }
    
    public boolean getIsCopySchedule()
    {
        return isCopySchedule;
    }
    
    public void setIsCopySchedule(boolean copySchedule)
    {
        isCopySchedule = copySchedule;
    }
    
    public boolean getIsCloseOriginal()
    {
        return isCloseOriginal;
    }
    
    public void setIsCloseOriginal(boolean closeOrig)
    {
        isCloseOriginal = closeOrig;
    }
    
    public boolean getIsNewResourceRendered()
    {
        return isNewResourceRendered;
    }
    
    public boolean getIsNewProjectRendered()
    {
        return isNewProjectRendered;
    }
    
    public Id getNewAssignmentId()
    {
        return newAssignmentId;
    }
    
    public boolean getTransferComplete()
    {
        return transferComplete;
    }

    public List<SelectOption> getMilestoneOptions()
    {
        loadMilestoneOptions(newAssignment.pse__Project__c);
        return milestoneOptions;
    }
    
    public PageReference refreshMilestoneOptions()
    {
        getMilestoneOptions();
        return null;
    }
    
    
    private void loadMilestoneOptions(Id projectId)
    {
        
        milestoneOptions = new List<SelectOption>();
        milestoneOptions.add(new SelectOption('', '--None--'));
        
        try
        {
            pse__Milestone__c[] milestones = [SELECT Name FROM pse__Milestone__c 
                                              WHERE pse__Project__c =: projectId 
                                              AND pse__Billed__c = false 
                                              ORDER BY Name];
            if (milestones != null)
            {
                for (pse__Milestone__c m : milestones)
                {
                    milestoneOptions.add(new SelectOption(m.Id, m.Name));
                }
            }
        }
        catch (Exception e) 
        {
            system.debug(e.getMessage());
        }
        
    }    
    
    public PageReference changeTransferType() 
    {

        if (this.transferType.equals('RTP'))
        {
            this.isNewResourceRendered = false;
            this.isNewProjectRendered = true;   
        }
        else
        {
            this.isNewResourceRendered = true;
            this.isNewProjectRendered = false;
        }
        
        return null;
        
    }

    public PageReference cancel() 
    {
        String pageRef = '/' + ApexPages.currentPage().getParameters().get('id');
        return new PageReference(pageRef);
    }
    
    public PageReference transferAssignment() 
    {
        system.debug(' ### Transfer Type: ' + transferType);
        system.debug(' ### From Project: ' + origAssignment.pse__Project__r.Name);
        system.debug(' ### From Resource: ' + origAssignment.pse__Resource__r.Name);
        system.debug(' ### From Milestone: ' + origAssignment.pse__Milestone__c);
        system.debug(' ### From Start Date: ' + origAssignment.pse__Start_Date__c);
        system.debug(' ### From End Date: ' + origAssignment.pse__End_Date__c);
        system.debug(' ### To Project: ' + newAssignment.pse__Project__c);
        system.debug(' ### To Resource: ' + newAssignment.pse__Resource__c);
        system.debug(' ### To Milestone: ' + newAssignment.pse__Milestone__c);
        system.debug(' ### To Start Date: ' + newSchedule.pse__Start_Date__c);
        system.debug(' ### To End Date: ' + newSchedule.pse__End_Date__c);
        system.debug(' ### Close Original: ' + isCloseOriginal);
        
        // Perform validations
        String validationMsg = validate();
        
        if (validationMsg != null)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Validation Failed: ' + validationMsg));
            return null;
        }
        
        // Validations passed. Set back any interim changes that may have been made by toggling between transfer types
        if (transferType.equals('RTP'))
        {
            // Same resource is being assigned to a new project
            // Set the resource, role and cost rate from original resource
            // Let the assignment name get set automatically
            newAssignment.pse__Resource__c = origAssignment.pse__Resource__c;
            newAssignment.pse__Role__c = origAssignment.pse__Role__c;
            newAssignment.pse__Cost_Rate_Amount__c = origAssignment.pse__Cost_Rate_Amount__c;
        }
        else
        {
            // Different resource is being assigned to the same project
            // Add project, milestone, location, and role information from original assignment
            // Use the original assignment name
            newAssignment.pse__Project__c = origAssignment.pse__Project__c;
            newAssignment.pse__Milestone__c = origAssignment.pse__Milestone__c;
            newAssignment.pse__Location__c = origAssignment.pse__Location__c;
            newAssignment.pse__Role__c = origAssignment.pse__Role__c;
            newAssignment.Name = origAssignment.Name;

            // Set the 'Reassigned to Resource' field for email notification if the original assignment is being canceled.
            // Set the cost rate on the assignment to that of the new resource
            Contact newResource = [SELECT Id, Name, pse__Default_Cost_Rate__c FROM Contact WHERE Id =: newAssignment.pse__Resource__c];
            newAssignment.pse__Cost_Rate_Amount__c = newResource.pse__Default_Cost_Rate__c;
            
            /*
            // COMMENTED BY CYBAGE ON 07/24/2020 for Project - "Modify Transfer Assignment Functionality in PSA"
            if (isCloseOriginal)
            {
                origAssignment.Reassigned_To_Resource__c = newResource.Name;
            }
            */
        }
        
        // Get assignment daily notes
        pse__Assignment_Daily_Note__c [] dailyNotes = [SELECT pse__Date__c, pse__Note__c 
                                                       FROM pse__Assignment_Daily_Note__c 
                                                       WHERE pse__Assignment__c =: origAssignment.Id];
        
        system.debug(' **** Assignment has ' + dailyNotes.size() + ' daily notes');            
   
        Decimal numDays = origSchedule.pse__Scheduled_Days__c;
        
        system.debug(' **** Number of days scheduled: ' + numDays);
        
        // If the assignment is scheduled for more than 5 days, simply copy the schedule pattern to the new schedule. Do the same if the start/end date have not changed.
        if (numDays > 5 || (newAssignment.pse__Start_Date__c == origSchedule.pse__Start_Date__c && newAssignment.pse__End_Date__c == origSchedule.pse__End_Date__c))
        {
            newSchedule.pse__Monday_Hours__c = origSchedule.pse__Monday_Hours__c;
            newSchedule.pse__Tuesday_Hours__c = origSchedule.pse__Tuesday_Hours__c;
            newSchedule.pse__Wednesday_Hours__c = origSchedule.pse__Wednesday_Hours__c;
            newSchedule.pse__Thursday_Hours__c = origSchedule.pse__Thursday_Hours__c;
            newSchedule.pse__Friday_Hours__c = origSchedule.pse__Friday_Hours__c;
            newSchedule.pse__Saturday_Hours__c = origSchedule.pse__Saturday_Hours__c;
            newSchedule.pse__Sunday_Hours__c = origSchedule.pse__Sunday_Hours__c;
            newSchedule.pse__Scheduled_Days__c = origSchedule.pse__Scheduled_Days__c;
            newSchedule.pse__Scheduled_Hours__c = origSchedule.pse__Scheduled_Hours__c;
        }
        else
        {
            // Initialize the new schedule. Instead of copying the schedule pattern such that hours are copied based on day of week,
            // the new schedule pattern must follow the original pattern based simply on day 1 hours = day 1 hours and so on.  So if the 
            // original schedule has hours for Mon-Wed and the new one has hours for Wed-Fri the Wed,Thu,and Fri hours on the new schedule
            // will match the Mon,Tue,Wed hours on the original respectively.
            Integer origFirstDaysFromStart = origAssignment.pse__Start_Date__c.toStartOfWeek().daysBetween(origAssignment.pse__Start_Date__c);
            Integer newFirstDaysFromStart = newSchedule.pse__Start_Date__c.toStartOfWeek().daysBetween(newSchedule.pse__Start_Date__c);
            Integer shift = newFirstDaysFromStart-origFirstDaysFromStart;
            
            system.debug(' **** Orig First Day Start Index ' + origFirstDaysFromStart);
            system.debug(' **** New First Day Start Index ' + newFirstDaysFromStart);
            system.debug(' **** Day shift between assignments is ' + shift);
            
            if (shift < 0) 
            {
                shift = shift + 5;
			}
            
            system.debug(' **** Adjusted shift between assignments is ' + shift);
            
            newSchedule.pse__Saturday_Hours__c = origSchedule.pse__Saturday_Hours__c;
            newSchedule.pse__Sunday_Hours__c = origSchedule.pse__Sunday_Hours__c;
            newSchedule.pse__Scheduled_Hours__c = origSchedule.pse__Scheduled_Hours__c;
            newSchedule.pse__Scheduled_Days__c = origSchedule.pse__Scheduled_Days__c;
            
            if (shift == 0)
            {
                newSchedule.pse__Monday_Hours__c = origSchedule.pse__Monday_Hours__c;
                newSchedule.pse__Tuesday_Hours__c =  origSchedule.pse__Tuesday_Hours__c;
                newSchedule.pse__Wednesday_Hours__c = origSchedule.pse__Wednesday_Hours__c;
                newSchedule.pse__Thursday_Hours__c = origSchedule.pse__Thursday_Hours__c;
                newSchedule.pse__Friday_Hours__c = origSchedule.pse__Friday_Hours__c;
            }
            else if (shift == 1)
            {
                newSchedule.pse__Monday_Hours__c = origSchedule.pse__Friday_Hours__c;
                newSchedule.pse__Tuesday_Hours__c = origSchedule.pse__Monday_Hours__c;
                newSchedule.pse__Wednesday_Hours__c = origSchedule.pse__Tuesday_Hours__c;
                newSchedule.pse__Thursday_Hours__c = origSchedule.pse__Wednesday_Hours__c;
                newSchedule.pse__Friday_Hours__c = origSchedule.pse__Thursday_Hours__c;                
            }
            else if (shift == 2)
            {
                newSchedule.pse__Monday_Hours__c = origSchedule.pse__Thursday_Hours__c;
                newSchedule.pse__Tuesday_Hours__c =  origSchedule.pse__Friday_Hours__c;
                newSchedule.pse__Wednesday_Hours__c = origSchedule.pse__Monday_Hours__c;
                newSchedule.pse__Thursday_Hours__c = origSchedule.pse__Tuesday_Hours__c;
                newSchedule.pse__Friday_Hours__c = origSchedule.pse__Wednesday_Hours__c;
            }
            else if (shift == 3)
            {
                newSchedule.pse__Monday_Hours__c = origSchedule.pse__Wednesday_Hours__c;
                newSchedule.pse__Tuesday_Hours__c =  origSchedule.pse__Thursday_Hours__c;
                newSchedule.pse__Wednesday_Hours__c = origSchedule.pse__Friday_Hours__c;
                newSchedule.pse__Thursday_Hours__c = origSchedule.pse__Monday_Hours__c;
                newSchedule.pse__Friday_Hours__c = origSchedule.pse__Tuesday_Hours__c;
            }
            else if (shift == 4)
            {
                newSchedule.pse__Monday_Hours__c = origSchedule.pse__Tuesday_Hours__c;
                newSchedule.pse__Tuesday_Hours__c = origSchedule.pse__Wednesday_Hours__c;
                newSchedule.pse__Wednesday_Hours__c = origSchedule.pse__Thursday_Hours__c;
                newSchedule.pse__Thursday_Hours__c = origSchedule.pse__Friday_Hours__c;
                newSchedule.pse__Friday_Hours__c = origSchedule.pse__Monday_Hours__c;
            }
        }
                
        system.debug(' **** New Monday Hours: ' + newSchedule.pse__Monday_Hours__c);
        system.debug(' **** New Tuesday Hours: ' + newSchedule.pse__Tuesday_Hours__c);
        system.debug(' **** New Wednesday Hours: ' + newSchedule.pse__Wednesday_Hours__c);
        system.debug(' **** New Thursday Hours: ' + newSchedule.pse__Thursday_Hours__c);
        system.debug(' **** New Friday Hours: ' + newSchedule.pse__Friday_Hours__c);
        
        Savepoint sp = Database.setSavepoint();
        
        try
        {
            // Insert the new schedule. Its start and end dates have already been set.
            insert newSchedule;
            
            // Set the new schedule in the new assignment and create it
            newAssignment.pse__Schedule__c = newSchedule.Id;
            insert newAssignment;
            system.debug('newAssignment.Id : '+newAssignment.Id);
            this.newAssignmentId = newAssignment.Id;
            
            // ADDED BY STUART EMERY ON 3/22/2013 PER SALESFORCE.COM CHANGE REQUEST: NICC-006355
            // Per FinancialForce - PSA Support, there is a trigger on the Assignment object that
            // sets the pse__Is_Billable__c field on the Assignment record to 'true' if the
            // pse__Is_Billable__c field on the Project is set to 'true'.  To get around this, 
            // we need to update the pse__Is_Billable__c, pse__Time_Credited__c and pse__Time_Excluded__c
            // fields to the values of the original Assignment after the new Assignment is inserted  
            newAssignment.pse__Is_Billable__c = origAssignment.pse__Is_Billable__c;
            newAssignment.pse__Time_Credited__c = origAssignment.pse__Time_Credited__c;
            newAssignment.pse__Time_Excluded__c = origAssignment.pse__Time_Excluded__c;
            newAssignment.Contact_Name__c = origAssignment.Contact_Name__c;
            newAssignment.pse__Location__c = origAssignment.pse__Location__c;  	// ADDED TO SET THE LOCATION WHEN AN ASSIGNMENT IS MOVED TO ANOTHER PROJECT
            newAssignment.Name = origAssignment.Name; 							// ADDED TO SET THE ASSIGNMENT NAME WHEN AN ASSIGNMENT IS MOVED TO ANOTHER PROJECT
            
            // ADDED BY CYBAGE ON  07/30/2020
            newAssignment.isInsertCompleted__c = false;
            
            update newAssignment; 
            
            // Copy assignment daily notes if they fall within dates of new assignment.
            if (dailyNotes != null && dailyNotes.size() > 0)
            {
                List<pse__Assignment_Daily_Note__c> newDailyNotes = new List<pse__Assignment_Daily_Note__c>();
                for (pse__Assignment_Daily_Note__c note : dailyNotes)
                {
                    if (note.pse__Date__c >= newSchedule.pse__Start_Date__c && note.pse__Date__c <= newSchedule.pse__End_Date__c)
                    {
                        pse__Assignment_Daily_Note__c newNote = new pse__Assignment_Daily_Note__c();
                        newNote.pse__Assignment__c = this.newAssignmentId; 
                        newNote.pse__Date__c = note.pse__Date__c; 
                        newNote.pse__Note__c = note.pse__Note__c;
                        newDailyNotes.add(newNote);
                    }
                }
                
                if (newDailyNotes.size() > 0)
                {
                    insert newDailyNotes;
                }
            }
            
            
            /*
            // COMMENTED BY CYBAGE ON 07/24/2020 for Project - "Modify Transfer Assignment Functionality in PSA"
            // If so specified, DELETE the old assignment
            if (isCloseOriginal)
            {
                // First set the assignment to "Canceled" so that the old assignee gets a 
                // notification.  Also change the owner of the original assignment to the 
                // current user so that it can be deleted. 
                origAssignment.pse__Status__c = 'Canceled';
                origAssignment.pse__Closed_For_Time_Entry__c = true;
                origAssignment.pse__Closed_For_Expense_Entry__c = true;
                origAssignment.Notify_Resource__c = true;
                origAssignment.OwnerId = UserInfo.getUserId();
                origAssignment.Cancellation_Reason__c = 'Significant Staff Change';
                update origAssignment;
                
        		Date dtDefault = Date.newInstance(2025, 12, 31); 
                
                List<pse__Milestone__c> oldMS = new List<pse__Milestone__c>();
                for (pse__Milestone__c ms : [SELECT Id FROM pse__Milestone__c WHERE Id =: origAssignment.pse__Milestone__c])
                {
                    ms.pse__Admin_Global_Edit__c = true;              
                    ms.pse__Target_Date__c = dtDefault;
                    ms.Billable_Assignment_Count__c = 0;                    
                    oldMS.add(ms);    
                }
                
                database.update(oldMS);
                
                // Next delete the assignment (its schedule should get deleted automatically by trigger)
                delete origAssignment;
            }
			*/
        }
        catch (Exception e)
        {
            system.Debug('Error: ' + e.getMessage() + '... Error Line Number : ' +e.getLineNumber());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'Error saving assignment: ' + e.getMessage()));
            Database.rollback(sp);
            return null;
        }
        
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Assignment Successfully Created'));
        transferComplete = true;
        
        return null;
        
    }

    private String validate()
    {
        // If this method returns a non-null value then validation failed
        system.debug(' *** ENTERING PsaTransferAssignmentController.validate() ');
        
        // Assignment start and end dates are required
        if (newSchedule.pse__Start_Date__c == null || newSchedule.pse__End_Date__c == null)
        {
            return 'A start and end date are required.';
        }
        
        // Assignment end date must be >= start date
        if (newSchedule.pse__Start_Date__c > newSchedule.pse__End_Date__c)
        {
            return 'The start cannot be before the end date.';
        }
        
        // Assignment start date >= Today
        if (newSchedule.pse__Start_Date__c < system.Today())
        {
            return 'The assignment start date cannot be in the past.';
        }
        
        // If moving the resource to another project, the assignment must fall on or after the project's start date
        if (transferType.equals('RTP'))
        {
            pse__Proj__c newProject = [SELECT Id, Name, pse__Start_Date__c FROM pse__Proj__c WHERE Id =: newAssignment.pse__Project__c];
            
            system.debug(' **** New project: ' + newAssignment.pse__Project__c + ' Start Date: ' + newProject.pse__Start_Date__c);
            
            if (newProject.pse__Start_Date__c > newSchedule.pse__Start_Date__c)
            {
                return 'The specified Assignment start date is before the chosen Project start date.';
            }
        }
        
        /*
        // COMMENTED BY CYBAGE ON 07/24/2020 for Project - "Modify Transfer Assignment Functionality in PSA"
        // Assignment can have no expenses, timecards, or transactions associated with it
        if (isCloseOriginal)
        {
            if (origAssignment.pse__Billable_Expenses_Submitted__c > 0 || 
                origAssignment.pse__Billable_Hours_Submitted__c > 0 || 
                origAssignment.pse__Non_Billable_Hours_Submitted__c > 0 || 
                origAssignment.pse__Non_Billable_Expenses_Submitted__c > 0)
            {
                return 'The original assignment cannot be deleted because it already has time and/or expenses submitted against it.';
            }
        }
        */
               
        return null;
        
    }
    
}