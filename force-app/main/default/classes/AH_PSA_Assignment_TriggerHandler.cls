/************************************************************************************************
Name            : AH_PSA_Assignment_TriggerHandler Class
Author          : Sean Harris
Created Date    : 08/29/2018
Last Mod Date   : 08/11/2020
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class that handles all trigger code for the pse__Assignment__c Object
                : 
                : 
*************************************************************************************************/
public class AH_PSA_Assignment_TriggerHandler 
{
    
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    public Static Boolean bIsTaskUpdate = false;
    
    public AH_PSA_Assignment_TriggerHandler()
    {   
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();    
    }    
    
    public void OnBeforeInsert(List<pse__Assignment__c> newTrigger)
    {   

        if (!bpSwitch.BypassPSAAssignment_ON__c)
        {
            for (pse__Assignment__c asmnt : newTrigger)
            {
                asmnt.isInsertCompleted__c = true;
            }
            
            setAssignmentOwnerAndMgr(newTrigger);
        }
        
    }
    
    
    public void OnAfterInsert(List<pse__Assignment__c> newTrigger)
    {   

        NI_TriggerManager.is1stInsert_Assignment = false;
        
        if (!bpSwitch.BypassPSAAssignment_ON__c)
        {
            
            updateMilestones(newTrigger, null);            
            
            // NICC-044249 (START) ADDED BY CYBAGE ON 05/27/2020 
            Set<Id> asnmtIds = new Set<Id>();
            
            for (pse__Assignment__c asmnt : newTrigger)
            {
                asnmtIds.add(asmnt.Id);
            }
/*             
            // NICC-044531 (BUG FIX START) 
            // GENERATE UNIQUE TIMESTAMP TO TRACK BATCH JOB EXECUTION RESULT
            DateTime myDateTime1 = DateTime.now();
            String s = myDateTime1.format();
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(s));
            String timestamp = EncodingUtil.convertToHex(hash).substring(0,30);
            // NICC-044531 (BUG FIX END)
            
            // MOVED FLOW FUCNTIONALITY TO BATCH .. AS THE TRIGER IS GETTING CALEED MULTIPLE TIMES
            AH_UpdateAssignments_Schedule sch2 = new AH_UpdateAssignments_Schedule(asnmtIds, timestamp); // NICC-044531 (BUG FIX)
            DateTime myDateTime = DateTime.now();
            Integer min = myDateTime.minute() + 4;
            Integer hour = myDateTime.hour(); 
            
            if (min > 60)
            {
                min = min - 60;
                hour = hour + 1;
            }
            
            Integer day = System.now().day();
            Integer month = System.now().month();
            Integer year = System.now().year();            
            String sch = '0 '+ min +' '+ hour + ' ' + day + ' ' + month + ' ? ' + year + '';
            
            system.schedule('UpdateAssignments_' + UserInfo.getUserId() + '_' + timestamp, sch, sch2); 	// NICC-044531 (BUG FIX)
            
            // NICC-044249 (END) 
*/
            
            // NICC-044249 (START) 
            
            // BUILD UNIQUE JOB NAME
            Blob b = Crypto.GenerateAESKey(128);
            String strGUID = EncodingUtil.ConvertTohex(b);
            String strJobName = 'UpdateAssignments_' + UserInfo.getUserId() + '_' + strGUID;
            
            // BUILD CRON TRIGGER EXPRESSION
            DateTime dt = DateTime.now();
            dt = dt.addMinutes(4);
            String strCronTrig = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year() + '';
            
            // INSTANTIATE SCHEDULABLE CLASS
            AH_UpdateAssignments_Schedule objSchedClass = new AH_UpdateAssignments_Schedule(asnmtIds, strJobName);
            
            // SCHEDULE APEX JOB
            system.schedule(strJobName, strCronTrig, objSchedClass); 	
            
            // NICC-044249 (END) 
            
        }

    }
    
    public void OnBeforeUpdate(List<pse__Assignment__c> newTrigger)
    {   

        if (!bpSwitch.BypassPSAAssignment_ON__c && bIsTaskUpdate == false)
        {
            setAssignmentOwnerAndMgr(newTrigger);
        } 

    }
    
    public void OnAfterUpdate(List<pse__Assignment__c> newTrigger, Map<Id, pse__Assignment__c> oldMapTrigger)
    {   

        NI_TriggerManager.is1stUpdate_Assignment = false;
        
        if (!bpSwitch.BypassPSAAssignment_ON__c && bIsTaskUpdate == false)
        {
            updateMilestones(newTrigger, oldMapTrigger);
            
            Set<Id> asnmtIds = new Set<Id>();
            for (pse__Assignment__c asmnt : newTrigger)
            {
                if (asmnt.isInsertCompleted__c == false && oldMapTrigger.get(asmnt.Id).isInsertCompleted__c == false)
                {
                    asnmtIds.add(asmnt.Id);
                }
            }
            
            if (!asnmtIds.isEmpty())
            {
                updateProjectTask(asnmtIds, oldMapTrigger);
            }
            
        }

    }
    
    public void OnAfterDelete(List<pse__Assignment__c> oldTrigger)
    {

        NI_TriggerManager.is1stUpdate_Assignment = false;
        
        if (!bpSwitch.BypassPSAAssignment_ON__c)
        {         
            updateMilestones(oldTrigger, null); 
        }

    }    
    
    // =============================================================================================
    // FUNCTIONS ===================================================================================
    // =============================================================================================
    private void setAssignmentOwnerAndMgr(List<pse__Assignment__c> newTrigger) 
    {
        
        system.debug(' *** ENTERING AH_PSA_Assignment_TriggerHandler.setAssignmentOwnerAndMgr() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // FILL A SET OF ALL RELATED pse__Proj__c IDS
        Set<Id> setIds = new Set<Id>();
        for (pse__Assignment__c asgn : newTrigger)
        {
            setIds.add(asgn.pse__Project__c);
        }
        
        // FILL LIST OF ALL RELATED pse__Proj__c RECORDS
        List<pse__Proj__c> lstPrj = new List<pse__Proj__c>([SELECT Id, Name, pse__Project_Manager__c, pse__Project_Manager__r.pse__Salesforce_User__c 
                                                            FROM pse__Proj__c 
                                                            WHERE Id IN : setIds]);

        // LOOP THOUGH THE pse__Assignment__c TRIGGER
        for (pse__Assignment__c a : newTrigger)
        {

            // THEN LOOP THOUGH ALL THE RELATED pse__Proj__c RECORDS
            for (pse__Proj__c p : lstPrj)
            { 				
                // IF THE pse__Proj__c RECORD MATCHES 
                if (a.pse__Project__c == p.Id)
                {                       
                    // IF Project_Manager__c DOES NOT MATCH THE pse__Project_Manager__c ON THE RELATED PROJECT
                    // (REPLACEMENT FOR "FF PSA - Update PM Name on Assignments" PROCESS BUILDER)
                    if ((a.Project_Manager__c != p.pse__Project_Manager__c) && (p.pse__Project_Manager__c != null))
                    {                     
                        a.Project_Manager__c = p.pse__Project_Manager__c; 
                    }                      
                    // IF OWNER DOES NOT MATCH THE MANAGER ON THE RELATED PROJECT
                    if ((a.OwnerId != p.pse__Project_Manager__r.pse__Salesforce_User__c) && (p.pse__Project_Manager__r.pse__Salesforce_User__c != null))
                    {
                        // SET THE OWNER ON THE pse__Assignment__c TO THE MANAGER ON RELATED pse__Proj__c RECORD                     
                        a.OwnerId = p.pse__Project_Manager__r.pse__Salesforce_User__c; 
                    }
                    
                } 
                
            } 

        } 

        system.debug(' *** EXITING AH_PSA_Assignment_TriggerHandler.setAssignmentOwnerAndMgr() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    private void updateMilestones(List<pse__Assignment__c> newTrigger, Map<Id, pse__Assignment__c> oldMapTrigger) 
    {
        
        system.debug(' *** ENTERING AH_PSA_Assignment_TriggerHandler.updateMilestones() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // FULL SET OF TARGETED PSA MILESTONE IDS 
        Set<Id> milestoneIds = new Set<Id>();
        
        for (pse__Assignment__c asmnt : newTrigger)
        {
            if (asmnt.pse__Milestone__c != null)
            {
                milestoneIds.add(asmnt.pse__Milestone__c);
            }
            
            if (oldMapTrigger != null)
            {
                // IF THE MILESTONE CHANGES ON AN ASSIGNMENT - ADD OLD MILESTONE ID TO SET
                pse__Assignment__c oldAssmnt = oldMapTrigger.get(asmnt.Id);
                if ((asmnt.pse__Milestone__c != oldAssmnt.pse__Milestone__c) && (oldAssmnt.pse__Milestone__c != null))
                {
                    milestoneIds.add(oldAssmnt.pse__Milestone__c);
                }
            }
        }

        if (milestoneIds.size() > 0)
        {
            
            // FILL LIST OF PSA MILESTONE UPDATE CANDIDATE RECORDS
            List<pse__Milestone__c> lstMilestoneUpdates = new List<pse__Milestone__c>(
                [SELECT Id, pse__Target_Date__c, Billable_Assignment_Count__c  
                 FROM pse__Milestone__c 
                 WHERE Id IN : milestoneIds]);
            
            // QUERY FOR RELATED ASSIGNMENTS PULLING BACK MAX END DATE & COUNTS THAT ARE BILLABLE
            List<AggregateResult> ag = new List<AggregateResult>(
                [SELECT pse__Milestone__c, MAX(pse__End_Date__c) TargetDate, COUNT(Id) BillableCount
                 FROM pse__Assignment__c
                 WHERE pse__Is_Billable__c = true 
                 AND pse__Milestone__c IN : milestoneIds
                 GROUP BY pse__Milestone__c]);
            
            // FUTURE FEATURE (10 YEARS OUT) 
            // Date dt = system.today();
            // Date dtDefault = Date.newInstance(dt.addYears(10).Year(), 12, 31);
            Date dtDefault = Date.newInstance(2025, 12, 31); 
            
            for (pse__Milestone__c ms : lstMilestoneUpdates)
            {   
                // SET DEFAULTS
                ms.pse__Target_Date__c = dtDefault;
                ms.Billable_Assignment_Count__c = 0;
                for (AggregateResult x : ag)
                {
                    if (x.get('pse__Milestone__c') == ms.Id)
                    {   
                        ms.pse__Target_Date__c = (Date) x.get('TargetDate');
                        ms.Billable_Assignment_Count__c = (Decimal) x.get('BillableCount'); 
                        break;
                    }                
                }
            }
            
            if (!lstMilestoneUpdates.isEmpty())
            {
                database.update(lstMilestoneUpdates);
            }
            
        }
        
        system.debug(' *** EXITING AH_PSA_Assignment_TriggerHandler.updateMilestones() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    
    // ADDED BY CYBAGE ON 05/27/2020 TO UPDATE "PROJECT TASK" OBJECT AS PER "PROJECT TASK ASSIGNMENT" OBJECT
    private static void updateProjectTask(Set<Id> asnmtIds, Map<Id, pse__Assignment__c> oldMapTrigger)
    {
        
        system.debug(' *** ENTERING AH_PSA_Assignment_TriggerHandler.updateProjecttask() - QUERIES ISSUED = ' + Limits.getQueries());
        
        bIsTaskUpdate = true;
        
        if (!asnmtIds.isEmpty())
        {
            // QUERY ON JUNCTION OBJECT
            List<pse__Project_Task_Assignment__c> projectTaskassignmentLst = [SELECT id, 
                                                                              pse__Project_Task__c,
                                                                              pse__Project_Task__r.Name,
                                                                              pse__Assignment__r.Name, 
                                                                              pse__Assignment__r.pse__Location__c,
                                                                              pse__Assignment__r.pse__Milestone__c,
                                                                              pse__Assignment__r.pse__Status__c,
                                                                              pse__Assignment__r.pse__Is_Billable__c,
                                                                              pse__Assignment__r.pse__Time_Credited__c,
                                                                              pse__Assignment__r.pse__Start_Date__c,
                                                                              pse__Assignment__r.pse__Scheduled_Hours__c,
                                                                              pse__Assignment__r.pse__End_Date__c 
                                                                              FROM pse__Project_Task_Assignment__c 
                                                                              WHERE pse__Assignment__c IN : asnmtIds];

            // LIST HOLDS PROJECT TASK OBJECTS TO BE UPDATED
            List<pse__Project_Task__c> prjTaskList = new List<pse__Project_Task__c>();
            
            // LOOP ON RETRIEVED QUERY RESULT TO COLLECT PROJECT TASK FILED VALUES
            for (pse__Project_Task_Assignment__c taskAssignmentObj : projectTaskassignmentLst)
            {
                if (taskAssignmentObj.pse__Project_Task__c != NULL)	
                {
                    pse__Project_Task__c prjTask = new pse__Project_Task__c(Id = taskAssignmentObj.pse__Project_Task__c);
                    
                    Time startTime = Time.newInstance(8, 0, 0, 0);
                    Time endTime = Time.newInstance(17, 0, 0, 0);
                    Datetime startDate = DateTime.newInstance(taskAssignmentObj.pse__Assignment__r.pse__Start_Date__c, startTime);
                    Datetime endDate = DateTime.newInstance(taskAssignmentObj.pse__Assignment__r.pse__End_Date__c, endTime);
                    
                    prjTask.Name = taskAssignmentObj.pse__Assignment__r.Name;
                    prjTask.Location__c = taskAssignmentObj.pse__Assignment__r.pse__Location__c; 
                    prjTask.pse__Milestone__c = taskAssignmentObj.pse__Assignment__r.pse__Milestone__c;
                    prjTask.pse__Status__c = taskAssignmentObj.pse__Assignment__r.pse__Status__c; 
                    prjTask.Billable__c = taskAssignmentObj.pse__Assignment__r.pse__Is_Billable__c; 
                    prjTask.Time_Credited__c = taskAssignmentObj.pse__Assignment__r.pse__Time_Credited__c;
                    prjTask.pse__Start_Date_Time__c	= startDate;
                    prjTask.pse__End_Date_Time__c = endDate;
                    prjTask.pse__Estimated_Hours__c	= taskAssignmentObj.pse__Assignment__r.pse__Scheduled_Hours__c;
                    prjTaskList.add(prjTask);
                }
                
            }
            
            // UPDATE RELATED PROJECT TASKS
            if (!prjTaskList.isEmpty())
            {
                Database.update(prjTaskList);
            }
            
        }
        
    }
    
}