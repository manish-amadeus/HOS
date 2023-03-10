/************************************************************************************************
Name            : AH_PSA_Project_TriggerHandler Class
Author          : CLD Partners
Created Date    : 10/28/2011
Last Mod Date   : 09/09/2018 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class that handles all custom trigger code for the pse__Proj__c Object
                : 
                : 
*************************************************************************************************/
public class AH_PSA_Project_TriggerHandler 
{

    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}

        
    public AH_PSA_Project_TriggerHandler()
    {
        
        system.debug(' *** ENTERING AH_PSA_Project_TriggerHandler - CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
        
        system.debug(' *** EXITING AH_PSA_Project_TriggerHandler - CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnBeforeInsert(List<pse__Proj__c> newTrigger)
    {
        
        system.debug(' *** ENTERING AH_PSA_Project_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
		
        if (!bpSwitch.BypassPSAProject_ON__c) 
        {
        	setCustomerProjectContact(newTrigger);
        }
        
        system.debug(' *** EXITING AH_PSA_Project_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }

    public void OnAfterInsert(List<pse__Proj__c> newTrigger)
    {
        
        system.debug(' *** ENTERING AH_PSA_Project_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
		
        NI_TriggerManager.is1stInsert_Project = false;
        
        if (!bpSwitch.BypassPSAProject_ON__c)
        {
        	createPMTTMilestones(newTrigger);
        }
        
        system.debug(' *** EXITING AH_PSA_Project_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }
    
    public void OnBeforeUpdate(List<pse__Proj__c> newTrigger, Map<Id, pse__Proj__c> oldMapTrigger)
    {

    }

    public void OnAfterUpdate(List<pse__Proj__c> newTrigger, Map<Id, pse__Proj__c> oldMapTrigger)
    { 
        
        system.debug(' *** ENTERING AH_PSA_Project_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
		
//        NI_TriggerManager.is1stUpdate_Project = false;
        
        if (!bpSwitch.BypassPSAProject_ON__c)
        {
            
            openMilestones(newTrigger, oldMapTrigger);            
            
            // NICC-043944 (START)
            Set<Id> setProjIds = new Set<Id>();
            for (pse__Proj__c prj : newTrigger)
            {
                
                String oldApprovalStatus = oldMapTrigger.get(prj.Id).Cancellation_Approval_Status__c;  
system.debug('**%** AH_PSA_Project_TriggerHandler:  NEW STATUS = ' + prj.Cancellation_Approval_Status__c + ', PREV STATUS = ' + oldApprovalStatus);                 
                // IF Cancellation_Approval_Status__c IS CHANGED FROM 'Submitted' TO ('Not Submitted' OR 'Rejected')
                if (oldApprovalStatus == 'Submitted')
                {
                    // IF RECALLED OR REJECTED
                    if (prj.Cancellation_Approval_Status__c == 'Not Submitted' || prj.Cancellation_Approval_Status__c == 'Rejected')
                    {
                        setProjIds.add(prj.Id);
                    }
                }
            }
            if (!setProjIds.isEmpty())    
            {
                NI_TriggerManager.is1stUpdate_Milestone = true;
                updateMilestoneTypes(setProjIds);
            }
            // NICC-043944 (END)
        }
        
        system.debug(' *** EXITING AH_PSA_Project_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }
    
    
    // =============================================================================================
    // FUNCTIONS ===================================================================================
    // =============================================================================================
    
    //trigger psaProjectAu_OpenMilestones on pse__Proj__c (after update) 
    private void openMilestones(List<pse__Proj__c> newTrigger, Map<Id, pse__Proj__c> oldMapTrigger)
    {
        // If a billable project is set to a stage of 'In Progress', this trigger
        // iterates through the project's milestones and sets them to a status of 'Open'
        // and also opens them for time and expense entry under the following conditions:
        // - Project is billable
        // - Milestone type = Billable Milestone, Complimentary, Goodwill, Hourly Milestone, or Inclusive Milestone   *PER MARY DUGDALE (all milestones should be included so I think any filtering should be removed)*
        // - Current milestone status = Draft/Tentative
        // - Softrax Order Sequence Number has already been set  *PER MARY DUGDALE (should be removed as Softrax has been closed out)*
        // In addition, if the milestone's approver is not set, it will set it to the PM assigned to the project.
        
        system.debug(' *** ENTERING AH_PSA_Project_TriggerHandler.openMilestones() - QUERIES ISSUED = ' + Limits.getQueries());
		
        List<pse__Proj__c> lstProjects = new List<pse__Proj__c>();
        List<pse__Milestone__c> lstMilestones = new List<pse__Milestone__c>();
        List<pse__Milestone__c> lstMilestonesToUpdate = new List<pse__Milestone__c>();
        
        // Isolate projects to those that are billable and where stage has just been changed
        for (pse__Proj__c project : newTrigger)
        {
            boolean isBillable = project.pse__Is_Billable__c;
            String projectStage = project.pse__Stage__c;
            String oldProjectStage = oldMapTrigger.get(project.Id).pse__Stage__c;
           
            system.debug(' ****% Project Name = ' + project.Name);
            system.debug(' ****% isBillable = ' + isBillable);
            system.debug(' ****% oldProjectStage = ' + oldProjectStage);
            system.debug(' ****% projectStage = ' + projectStage);
            
            if (projectStage != null && (oldProjectStage == null || !oldProjectStage.equals(projectStage)) && isBillable)
            {
                lstProjects.add(project);
            }
        }
        
        system.debug(' ****% lstProjects.size() = ' + lstProjects.size()); 
        
        // For any projects that meet the above criteria, and made it into the list,
        // Iterate through their milestones and open their milestones for t/e if they meet the criteria for doing so
        if (lstProjects.size() > 0)
        {
            // Get the milestones for the projects PER MARY DUGDALE (Removed Softrax_Order_Sequence_Number__c, from the SELECT statement, Added pse__Approved__c)
            lstMilestones = [SELECT Id, name, pse__Status__c, Milestone_Type__c, pse__Approver__c, pse__Project__r.pse__Project_Manager__r.pse__Salesforce_User__c, pse__Audit_Notes__c, 
                             pse__Project__r.pse__Stage__c, pse__Billed__c, pse__Invoiced__c, pse__Actual_Date__c, Activity_Line_Item__c, pse__Approved__c, pse__Project__r.pse__End_Date__c  
                             FROM pse__Milestone__c 
                             WHERE pse__Project__c IN : lstProjects];
            
            if (lstMilestones.size() > 0)
            {
                for (pse__Milestone__c milestone : lstMilestones)
                {
                    String projectStage = milestone.pse__Project__r.pse__Stage__c;
                    String existingMilestoneStatus = milestone.pse__Status__c;
                    String newMilestoneStatus;
                    Date dActual = null; 
                    boolean closedForTE = false;
                    boolean updateMilestone = false;
                    String strAuditNote = 'Added Actual Date';

                    system.debug(' ****% projectStage = ' + projectStage);
                    system.debug(' ****% existingMilestoneStatus = ' + existingMilestoneStatus);
                    system.debug(' ****% milestone.pse__Invoiced__c = ' + milestone.pse__Invoiced__c);
                    system.debug(' ****% milestone.pse__Billed__c = ' + milestone.pse__Billed__c);

                    
                    // Only set statuses for Billable, Complimentary, Goodwill, Inclusive, or Hourly milestones
                    // Also only update the milestone if it has not already been billed or invoiced
                    //		* PER MARY DUGDALE
                    //if ((!milestone.pse__Invoiced__c && !milestone.pse__Billed__c) && 
                    //    (milestone.Milestone_Type__c.equals('Billable Milestone') || 
                    //     milestone.Milestone_Type__c.equals('Complimentary') || 
                    //     milestone.Milestone_Type__c.equals('Goodwill') || 
                    //     milestone.Milestone_Type__c.equals('Inclusive Milestone') || 
                    //     milestone.Milestone_Type__c.equals('Hourly Milestone'))
                    //   )
                    if (!milestone.pse__Invoiced__c && !milestone.pse__Billed__c)
                    {
                        // If new project stage is Draft or Draft at Risk, set milestones to Draft/Tentative and close for t/e
                        if (projectStage.equals('Draft at Risk') || projectStage.equals('Draft'))
                        {
                            if (existingMilestoneStatus != null && 
                                !existingMilestoneStatus.equals('Submitted') && 
                                !existingMilestoneStatus.equals('Approved') && 
                                !existingMilestoneStatus.equals('Canceled'))
                            {
                                newMilestoneStatus = 'Draft/Tentative';
                                closedForTE = true;
                                dActual = null;
                                updateMilestone = true;
                            }
                        }
                        else if (projectStage.equals('In Progress') || projectStage.equals('Project Closing')) 
                        {
                            // Project is now In Progress or Project Closing. Set milestone to Open and open for T/E if milestone 
                            // status isn't currently Submitted, Approved, Escalate to Sales, or Canceled.
                            if (existingMilestoneStatus != null && 
                                !existingMilestoneStatus.equals('Submitted') && 
                                !existingMilestoneStatus.equals('Approved') && 
                                !existingMilestoneStatus.equals('Escalate to Sales') && 
                                !existingMilestoneStatus.equals('Canceled'))
                            {
                                // Only allow opening if Softrax Order Sequence Number has been set on the milestone, unless milestone
                                // type is Inclusive or Goodwill, which don't need Softrax #
                                //		* PER MARY DUGDALE
                                //if (milestone.Softrax_Order_Sequence_Number__c != null || milestone.Activity_Line_Item__c != null || 
                                //    (milestone.Milestone_Type__c.equals('Goodwill') || milestone.Milestone_Type__c.equals('Inclusive Milestone')))
                                    newMilestoneStatus = 'Open';
                                    closedForTE = false;
                                	dActual = null;
                                    updateMilestone = true;
                                //}
                            } 
                        }
                        else if (projectStage.equals('On Hold') || projectStage.equals('Escalation'))
                        {
                            // Project Stage is now On Hold or Escalation. Set milestones to Draft/Tentative and open for T/E if milestone 
                            // status isn't currently Submitted, Approved, Escalate to Sales, or Canceled
                            if (existingMilestoneStatus != null && 
                                !existingMilestoneStatus.equals('Submitted') && 
                                !existingMilestoneStatus.equals('Approved') && 
                                !existingMilestoneStatus.equals('Canceled'))
                            {
                                newMilestoneStatus = 'Draft/Tentative';
                                closedForTE = false;
                                dActual = null;
                                updateMilestone = true;
                            }
                        }
                        else if (projectStage.equals('Canceled'))
                        {
                            // Project Stage is now Canceled. Set milestones to Canceled and close for T/E if milestone 
                            // status isn't currently Submitted, Approved, Escalate to Sales, or Canceled
                            if (existingMilestoneStatus != null && 
                                !existingMilestoneStatus.equals('Submitted') && 
                                !existingMilestoneStatus.equals('Approved') && 
                                !existingMilestoneStatus.equals('Escalate to Sales') && 
                                !existingMilestoneStatus.equals('Canceled'))
                            {
                                newMilestoneStatus = 'Canceled';
                                closedForTE = true;
                                dActual = null;
                                updateMilestone = true;
                            }
                        }
                        else if (projectStage.equals('Completed'))
                        {
                            // Project Stage is now Completed. Set Milestone Approved and close for T/E if milestone 
                            // 		*PER MARY DUGDALE (If Milestone Type = ‘Inclusive Milestone’ update Actual Date with Project End Date)*
                            // status isn't currently Submitted, Escalate to Sales, or Canceled
                            // and actual date is set
                            if (existingMilestoneStatus != null && 
                                !existingMilestoneStatus.equals('Approved') && 
                                !existingMilestoneStatus.equals('Submitted') && 
                                !existingMilestoneStatus.equals('Escalate to Sales') && 
                                !existingMilestoneStatus.equals('Canceled')) 				// && milestone.pse__Actual_Date__c != null)
                            {                           
                                newMilestoneStatus = 'Approved';
                                closedForTE = true;
                                dActual = milestone.pse__Actual_Date__c;
system.debug(' **** %%% milestone.pse__Actual_Date__c = ' + milestone.pse__Actual_Date__c);    
system.debug(' **** %%% milestone.Milestone_Type__c = ' + milestone.Milestone_Type__c);                                 
                                if (milestone.pse__Actual_Date__c == null && milestone.Milestone_Type__c.equals('Inclusive Milestone'))
                                {
                                    dActual = milestone.pse__Project__r.pse__End_Date__c;
                                }
                                updateMilestone = true;
                            }
                        }                   
                    }
                    
                    system.debug(' **** Milestone ' + milestone.Name);
                    system.debug(' **** Milestone Type: ' + milestone.Milestone_Type__c);
                    system.debug(' **** Update milestone? ' + updateMilestone);
                    system.debug(' **** From ' + existingMilestoneStatus + ' to ' + newMilestoneStatus);
                    system.debug(' **** Closed for T/E: ' + closedForTE);
                    system.debug(' **** New Actual Date: ' + dActual + ', from Current Actual Date: ' + milestone.pse__Actual_Date__c);
                    system.debug(' **** pse__Audit_Notes__c: ' + milestone.pse__Audit_Notes__c);
                    
                    if (updateMilestone)
                    {
                        // Set Milestone status and T/E entry setting
                        milestone.pse__Status__c = newMilestoneStatus;
                        milestone.pse__Closed_for_Time_Entry__c = closedForTE;
                        milestone.pse__Closed_for_Expense_Entry__c = closedForTE;
                        milestone.pse__Actual_Date__c = dActual;
                        
                        if (milestone.pse__Audit_Notes__c == null)
                        {
                            milestone.pse__Audit_Notes__c = strAuditNote;
                        }
                        
                        // Check and set the approver to the project PM if necessary
                        if (milestone.pse__Approver__c == null)
                        {
                            milestone.pse__Approver__c = milestone.pse__Project__r.pse__Project_Manager__r.pse__Salesforce_User__c;
                        }
                        
                        lstMilestonesToUpdate.add(milestone);  
                    }
                }
            }
            
            // If there are any milestones that met the opening criteria, update them
            if (lstMilestonesToUpdate.size() > 0)
            {
                Database.SaveResult[] results = Database.update(lstMilestonesToUpdate);
                for (Database.SaveResult sr: results)
                {
                    if (!sr.isSuccess())
                    {
                        Database.Error err = sr.getErrors()[0];
                        System.debug(err.getMessage());
                    }
                }
            }
        }
        
        system.debug(' *** EXITING AH_PSA_Project_TriggerHandler.openMilestones() - QUERIES ISSUED = ' + Limits.getQueries());
		
    } 

    //trigger psaProjectAI on pse__Proj__c (after insert) 
    private void createPMTTMilestones(List<pse__Proj__c> newTrigger)
    {
        
        // logic to create the standard milestone on a project
        
        Set<Id> projIds = new Set<Id>();
        Map<String, pse__Practice__c> practiceMap = new Map<String, pse__Practice__c>();
        List<pse__Milestone__c> msInsertList = new List<pse__Milestone__c>();
        
        for (pse__Proj__c p : newTrigger)
        {
            if (p.pse__Project_Type__c == 'Customer Project')
            {
                projIds.add(p.Id);
            }
        }
        
        for (pse__Practice__c prac : [SELECT Id, Name FROM pse__Practice__c])
        {
            practiceMap.put(prac.name, prac);
        }
        
        for (pse__Proj__c p : [SELECT Id, Name, pse__Opportunity__c, pse__Opportunity__r.Opportunity_Number__c
                               FROM pse__Proj__c 
                               WHERE Id IN : projIds])
        {
            pse__Milestone__c newMS = new pse__Milestone__c();
            newMS.pse__Project__c = p.id;
            newMS.Opportunity__c = p.pse__Opportunity__c != null ? p.pse__Opportunity__c : null;
            newMS.pse__Milestone_Amount__c = 0;
            newMS.Name = 'Project Manager Time - ' + p.pse__Opportunity__r.Opportunity_Number__c;
            newMS.pse__Milestone_Cost__c = 0;
            newMS.pse__Target_Date__c = Date.newInstance(2025, 12, 31);
            newMS.pse__Override_Project_Practice__c = practiceMap.containsKey('Project Management') ? practiceMap.get('Project Management').Id : null;
            newMS.Milestone_Type__c = 'Inclusive Milestone';
            newMS.pse__Closed_for_Time_Entry__c = true;
            newMS.pse__Closed_for_Expense_Entry__c = true;
            newMS.pse__Billing_Hold__c = true;
            newMS.pse__Exclude_from_Billing__c = true;
            newMS.pse__Admin_Global_Edit__c = true;
            newMS.pse__Status__c = 'Draft/Tentative';
            newMS.pse__Audit_Notes__c = 'Override Project Practice ' + Datetime.now().format() + ' by User ' + UserInfo.getUserEmail();
            msInsertList.add(newMS);
        }
        try
        {
            insert msInsertList;
        }
        catch (Exception e)
        {
            system.debug('***** AH_PSA_Project_TriggerHandler.doProjectAI() ' + e.getMessage() + e.getStackTraceString());
        }    
        
    }

    //trigger psaProjectBi_SetCustomerProjectContact on pse__Proj__c (before insert) 
    private void setCustomerProjectContact(List<pse__Proj__c> newTrigger)
    {
        
        // When a project is created, if there is an Opportunity associated with the project, this looks for the Opportunity related contact record
        // designated with the "Customer Project Contact" role, and sets it in the Project's Customer Project Contact field.

        // Get the object Ids of any Opportunities related to the projects being inserted
        Set<Id> opportunityIds = new Set<Id>();
        
        for (pse__Proj__c proj : newTrigger)
        {
            if (proj.pse__Opportunity__c != null)
            {
                opportunityIds.add(proj.pse__Opportunity__c);
            }
        }
        
        if (opportunityIds.size() > 0)
        {
            // Get OpportunityContacts with the Customer Project Contact role
            List<OpportunityContactRole> lstContactRoles = new List<OpportunityContactRole>(
                [SELECT Id, OpportunityId, ContactId 
                 FROM OpportunityContactRole 
                 WHERE OpportunityId IN : opportunityIds 
                 AND Role = 'Customer Project Contact']);
            
            if (!lstContactRoles.isEmpty())
            {
                // Put Opportunity Id and contact role into a map allowing lookup by opp id
                Map<Id, OpportunityContactRole> oppContactMap = new Map<Id, OpportunityContactRole>();
                for (OpportunityContactRole cr : lstContactRoles)
                {
                    oppContactMap.put(cr.OpportunityId, cr);
                }
                
                // Now iterate incoming projects and look for the associated contact role
                for (pse__Proj__c newProject : newTrigger)
                {
                    if (newProject.pse__Opportunity__c != null)
                    {
                        OpportunityContactRole ocr = oppContactMap.get(newProject.pse__Opportunity__c);
                        if (ocr != null)
                        {
                            newProject.Customer_Project_Contact__c = ocr.contactId;
                        }
                    }
                }
            }
        }
    }
    
    // ADDED FUNCTION FOR NICC-043944
    @future
    private static void updateMilestoneTypes(Set<Id> setIds)
    {        
        
        List<pse__Milestone__c> lstMilestoneUpdates = new List<pse__Milestone__c>();
        
        for (pse__Milestone__c ms : [SELECT Id, Milestone_Type__c, Milestone_Type_Previous__c 
                                     FROM pse__Milestone__c
                                     WHERE pse__Project__c IN : setIds  
                                     AND pse__Status__c IN ('Draft/Tentative', 'Open')
                                     AND Milestone_Type__c IN ('Change Order Requested', 'Stale')])
        { 
system.debug(' *X*  previous = ' + ms.Milestone_Type_Previous__c + ', old = ' + ms.Milestone_Type__c);            
            String strPrevType = ms.Milestone_Type_Previous__c;
            ms.Milestone_Type__c = strPrevType;
            ms.Milestone_Type_Previous__c = null;
            lstMilestoneUpdates.add(ms);
        }   
        
        if (!lstMilestoneUpdates.isEmpty())    
        {
            NI_TriggerManager.is1stUpdate_Milestone = true;
            database.update(lstMilestoneUpdates);
        }
            
    }

/*
    // trigger psaProjectBu_ValidateNoBillingEventsToCancel on pse__Proj__c (before update)
    private void validateNoBillingEventsToCancel(List<pse__Proj__c> newTrigger)
    {
        
// OPTIMIZED THIS METHOD. MOVED TO STANDARD VALIDATION RULE NAMED validateNoBillingEventsToCancel       
        
        // When a project is updated to Canceled status, checks whether there are billing events associated with it. If so, throws a validation error.
        
        // Get billing events associated with the project
        Map<Id, pse__Billing_Event__c> billingEvents = new Map<Id, pse__Billing_Event__c>(
            [SELECT Id FROM pse__Billing_Event__c WHERE pse__Project__c IN : newTrigger]);

        // Check whether the project has Canceled stage, and if so look in the list of billing events for the project. If there are any, throw an exception.
        for (pse__Proj__c project : newTrigger) 
        {    
            if (project.pse__Stage__c != null && project.pse__Stage__c.equals('Canceled')) 
            {
                boolean foundBillingEvent = false;
                if (billingEvents != null && billingEvents.size() > 0)
                {
                    for (Id beId : billingEvents.keySet()) 
                    {
                        pse__Billing_Event__c be = billingEvents.get(beId);
                        if (be != null) 
                        {
                            foundBillingEvent = true;
                        }
                    }
                }
                
                if (foundBillingEvent) 
                {
                    project.addError('Billing events already exist for project: ' + project.Name + '. It may not be set to Canceled status.');
                }
            }
        }    
    }    
*/        

}