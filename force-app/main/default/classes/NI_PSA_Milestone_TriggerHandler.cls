/************************************************************************************************
Name            : NI_PSA_Milestone_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 7/25/2014
Last Mod Date   : 03/15/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-010968
Description     : Class that handles all trigger code for the pse__Milestone__c Object
                :
                : 
*************************************************************************************************/ 
public class NI_PSA_Milestone_TriggerHandler
{
    
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
	  
    
    public NI_PSA_Milestone_TriggerHandler()
    {
        
        system.debug(' *** ENTERING NI_PSA_Milestone_TriggerHandler - CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUES
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();   
        
        system.debug(' *** EXITING NI_PSA_Milestone_TriggerHandler - CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnBeforeInsert(List<pse__Milestone__c> newTrigger)
    {
        
        system.debug(' *** ENTERING NI_PSA_Milestone_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());

        if (!bpSwitch.Bypass_PSA_Milestone__c)
        {
            setMilestoneFields(newTrigger, false);
            setTargetPeriod(newTrigger, null);
        }

        system.debug(' *** EXITING NI_PSA_Milestone_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterInsert(List<pse__Milestone__c> newTrigger)
    { 
        
        system.debug(' *** ENTERING NI_PSA_Milestone_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());

        NI_TriggerManager.is1stInsert_Milestone = false;

        if (!bpSwitch.Bypass_PSA_Milestone__c)
        {      
            //CLD ADDITION // CALL THE MILESTONE ROLLUP METHOD FOR ACTVITIY LINE ITEMS: 
            calculateActivityLineRollup(newTrigger, null);
            syncALIEndDate(newTrigger); 
            if (!bpSwitch.Bypass_Assignment_Flows__c)
            {
                runFlows(newTrigger, null);
            } 
        }
        
        system.debug(' *** EXITING NI_PSA_Milestone_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());

    }
    
    public void OnBeforeUpdate(List<pse__Milestone__c> newTrigger, Map<Id, pse__Milestone__c> oldMapTrigger)
    { 
        
        system.debug(' *** ENTERING NI_PSA_Milestone_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());

        if (!bpSwitch.Bypass_PSA_Milestone__c)
        {   
            setMilestoneFields(newTrigger, false);
            setTargetPeriod(newTrigger, oldMapTrigger);
        }
        
        system.debug(' *** EXITING NI_PSA_Milestone_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());

    }
    
    public void OnAfterUpdate(List<pse__Milestone__c> newTrigger, Map<Id, pse__Milestone__c> oldMapTrigger)
    { 
        
        system.debug(' *** ENTERING NI_PSA_Milestone_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());

        NI_TriggerManager.is1stUpdate_Milestone = false;

        if (!bpSwitch.Bypass_PSA_Milestone__c)
        {      
            //CLD ADDITION // CALL THE MILESTONE ROLLUP METHOD FOR ACTVITIY LINE ITEMS: 
            calculateActivityLineRollup(newTrigger, oldMapTrigger);
            syncALIEndDate(newTrigger); 
            if (!bpSwitch.Bypass_Assignment_Flows__c)
            {
                runFlows(newTrigger, oldMapTrigger);
            }
        }
        
        system.debug(' *** EXITING NI_PSA_Milestone_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());

    }   
    
    public void OnAfterDelete(List<pse__Milestone__c> oldTrigger)
    {     
        
        system.debug(' *** ENTERING NI_PSA_Milestone_TriggerHandler.OnAfterDelete() - QUERIES ISSUED = ' + Limits.getQueries());

        NI_TriggerManager.is1stUpdate_Milestone = false;
        
        if (!bpSwitch.Bypass_PSA_Milestone__c)
        {      
            //CLD ADDITION // CALL THE MILESTONE ROLLUP METHOD FOR ACTVITIY LINE ITEMS: 
            calculateActivityLineRollup(oldTrigger, null);
        }
        
        system.debug(' *** EXITING NI_PSA_Milestone_TriggerHandler.OnAfterDelete() - QUERIES ISSUED = ' + Limits.getQueries());

    }
    
    public void OnAfterUnDelete(List<pse__Milestone__c> newTrigger)
    {
        
        system.debug(' *** ENTERING NI_PSA_Milestone_TriggerHandler.OnAfterUnDelete() - QUERIES ISSUED = ' + Limits.getQueries());

        NI_TriggerManager.is1stUpdate_Milestone = false;
        
        if (!bpSwitch.Bypass_PSA_Milestone__c)
        {        
            setMilestoneFields(newTrigger, true);
        } 
        
        system.debug(' *** EXITING NI_PSA_Milestone_TriggerHandler.OnAfterUnDelete() - QUERIES ISSUED = ' + Limits.getQueries());

    }    
    
    //========================================================================================================================    
    // FUNCTIONS 
    //========================================================================================================================  
    private void setMilestoneFields(List<pse__Milestone__c> newTrigger, boolean bIsUnDelete) 
    {
        
        system.debug(' *** ENTERING NI_PSA_Milestone_TriggerHandler.setMilestoneFields() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Set<Id> setMilestoneIds = new Set<Id>();
        for (pse__Milestone__c mst : newTrigger)
        {
            if (mst.Id != null)
            {
                setMilestoneIds.add(mst.Id);
            }
        }
        
        if (setMilestoneIds.isEmpty()) { return; }
        
        // QUERY FOR RELATED ASSIGNMENTS PULLING BACK MAX END DATE & COUNTS THAT ARE BILLABLE
        List<AggregateResult> ag = new List<AggregateResult>(
            [SELECT pse__Milestone__c, MAX(pse__End_Date__c) TargetDate, COUNT(Id) BillableCount 
             FROM pse__Assignment__c 
             WHERE pse__Is_Billable__c = true 
             AND pse__Milestone__c IN : newTrigger 
             GROUP BY pse__Milestone__c]); 
        
        // FUTURE FEATURE (10 YEARS OUT) 
        // Date dt = system.today();
        // Date dtDefault = Date.newInstance(dt.addYears(10).Year(), 12, 31);
        Date dtDefault = Date.newInstance(2025, 12, 31); 
        Set<Id> setMSIds = new Set<Id>();
        
        for (pse__Milestone__c ms : newTrigger)
        { 
            if (!bIsUnDelete)
            {
                // SET DEFAULTS
                // DEFAULT Admin Global Edit CHECKBOX TO True BECAUSE Admin Global Edit IS A MANAGED FIELD THAT WE CANNOT CHANGE THE DEFAULT TO True ON 
                ms.pse__Admin_Global_Edit__c = true;              
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
            else
            {
                setMSIds.add(ms.Id);
            }
        }
        
        if (bIsUnDelete)
        {
            
            List<pse__Milestone__c> lstMSUpdates = new List<pse__Milestone__c>();
            
            for (pse__Milestone__c ms : [SELECT Id, pse__Admin_Global_Edit__c, pse__Target_Date__c, Billable_Assignment_Count__c 
                                         FROM pse__Milestone__c 
                                         WHERE Id IN : setMSIds])
            { 
                // SET DEFAULTS
                // DEFAULT Admin Global Edit CHECKBOX TO True BECAUSE Admin Global Edit IS A MANAGED FIELD THAT WE CANNOT CHANGE THE DEFAULT TO True ON 
                ms.pse__Admin_Global_Edit__c = true;              
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
                lstMSUpdates.add(ms);
            }    
            
            database.update(lstMSUpdates);
            
        }
        
        system.debug(' *** EXITING NI_PSA_Milestone_TriggerHandler.setMilestoneFields() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    private void calculateActivityLineRollup(List<pse__Milestone__c> newTrigger, Map<Id, pse__Milestone__c> oldMapTrigger)
    {
        
        system.debug(' *** ENTERING NI_PSA_Milestone_TriggerHandler.calculateActivityLineRollup() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Set<Id> aliIDset = new Set<Id>();

        // LOOP THOUGH ALL MILESTINES AND CONDITIONALLY FILL A SET OF ALI IDs
        for (pse__Milestone__c ms : newTrigger) 
        {  
            // IF IS UPDATE
            if (oldMapTrigger != null)
            {
                pse__Milestone__c oldMS = oldMapTrigger.get(ms.Id);
                // IF pse__Approved__c OR pse__Milestone_Amount__c CHANGES
                if (ms.pse__Approved__c || (ms.pse__Milestone_Amount__c != oldMS.pse__Milestone_Amount__c))
                {
                    aliIDset.add(ms.Activity_Line_Item__c);                
                }                
            }
            else
            {
                // IF IS INSERT
                aliIDset.add(ms.Activity_Line_Item__c);  
            } 
        }

        if (aliIDset.isEmpty())
        {
            return;
        }
        
        //METHOD FOR CALCULATING THE ROLLUP OF MILESTONE AMOUNTS TO AN ACTIVITY LINE ITEM
        Map<Id, Decimal> aliMap = new Map<Id, Decimal>();
        Map<Id, Decimal> aliRevenueMap = new Map<Id, Decimal>();
        
        for (pse__Milestone__c ms : [SELECT Id, Activity_Line_Item__c, pse__Milestone_Amount__c, Milestone_Type__c, pse__Target_Date__c, pse__Status__c 
                                     FROM pse__Milestone__c
                                     WHERE Activity_Line_Item__c != null
                                     AND Activity_Line_Item__c IN : aliIDset])
        {
            if (ms.Milestone_Type__c != 'Cancellation Fee')
            {
                if (aliMap.containsKey(ms.Activity_Line_Item__c))
                {
                    Decimal tmp = aliMap.get(ms.Activity_Line_Item__c) + ms.pse__Milestone_Amount__c;
                    aliMap.put(ms.Activity_Line_Item__c, tmp);
                }
                else
                {
                    aliMap.put(ms.Activity_Line_Item__c, ms.pse__Milestone_Amount__c);
                }
            }
            
            if ((ms.pse__Target_Date__c <= Date.today()) && (ms.pse__Status__c == 'Approved'))
            { 
                if (aliRevenueMap.containsKey(ms.Activity_Line_Item__c))
                {
                    Decimal tmp = aliRevenueMap.get(ms.Activity_Line_Item__c) + ms.pse__Milestone_Amount__c;
                    aliRevenueMap.put(ms.Activity_Line_Item__c, tmp);
                }
                else
                {
                    aliRevenueMap.put(ms.Activity_Line_Item__c, ms.pse__Milestone_Amount__c);
                }
            }       
        }
        
        system.debug(' **** NI_PSA_Milestone_TriggerHandler - calculateActivityLineRollup - aliMap' + aliMap);
        system.debug(' **** NI_PSA_Milestone_TriggerHandler - calculateActivityLineRollup - aliRevenueMap' + aliRevenueMap);
        
        List<Activity_Line_Item__c> aliUpdateList = new List<Activity_Line_Item__c>();
        for (Activity_Line_Item__c ali : [SELECT Id, Milestone_Rollup_Amount__c FROM Activity_Line_Item__c WHERE Id IN : aliIDset])
        {
            ali.Milestone_Rollup_Amount__c = 0;
            if (aliMap.containsKey(ali.id))
            {
                ali.Milestone_Rollup_Amount__c = aliMap.get(ali.id);
            }
            ali.Milestone_Revenue_Rollup__c = 0;
            if (aliRevenueMap.containsKey(ali.id))
            {
                ali.Milestone_Revenue_Rollup__c = aliRevenueMap.get(ali.id);
            }
            aliUpdateList.add(ali);
        }
        
        if (!aliUpdateList.isEmpty())
        {
            database.update(aliUpdateList);
        } 
        
        system.debug(' *** EXITING NI_PSA_Milestone_TriggerHandler.calculateActivityLineRollup() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }    
    
    private void syncALIEndDate(List<pse__Milestone__c> newTrigger)
    {

        system.debug(' *** ENTERING NI_PSA_Milestone_TriggerHandler.syncALIEndDate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Map<Id, Date> aliEndDateMap = new Map<Id, Date>(); 
        
        for (pse__Milestone__c ms : newTrigger) 
        {  
            // Instead of looking for when the actual date is not null, the conditions for recognizing revenue should be based on 
            // the milestone status equaling approved and the target date being less than or equal today.  
            if ((ms.Activity_Line_Item__c != null) && (ms.pse__Status__c == 'Approved') && (ms.pse__Target_Date__c <= Date.today()))
            {
                aliEndDateMap.put(ms.Activity_Line_Item__c, ms.pse__Target_Date__c);
            }
            
        }
            
        if (!aliEndDateMap.isEmpty())
        {
            // Method for syncing the end date / deliverable date of the 
            List<Activity_Line_Item__c> aliList = [SELECT Id, Name, Contract_End_Date__c FROM Activity_Line_Item__c WHERE Id IN : aliEndDateMap.keyset()];
            for (Activity_Line_Item__c ali : aliList)
            {              
                ali.Contract_End_Date__c = aliEndDateMap.get(ali.id);
            }
            if (!aliList.isEmpty())
            {
                database.update(aliList);
            }
        }

        system.debug(' *** EXITING NI_PSA_Milestone_TriggerHandler.syncALIEndDate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    } 
    
    private void setTargetPeriod(List<pse__Milestone__c> newTrigger, Map<Id, pse__Milestone__c> oldMapTrigger)
    {
        
        // Find out if any milestones need target period set
        // This will save a query if none have target dates
        // This adds a milestone to an update list if:
        // 		a) it has just been created and has a target date specified
        // 		b) it was just been updated and either it is now null or it is different from the target date that was there before 
        
        List<pse__Milestone__c> milestonesToUpdate = new List<pse__Milestone__c>();
        
        for (pse__Milestone__c m : newTrigger)
        {
            // IF IS INSERT AND HAS TARGET DATE VALUE
            if (oldMapTrigger == null)
            {
                if (m.pse__Target_Date__c != null)
                {
                    milestonesToUpdate.add(m);
                }
            }
            else // IF IS UPDATE AND TARGET DATE VALUE HAS CHANGED
            {
                if (m.pse__Target_Date__c != oldMapTrigger.get(m.Id).pse__Target_Date__c)
                {
                    milestonesToUpdate.add(m);
                }
            }
        }
        
        if (milestonesToUpdate.size() > 0)
        {
            
            // GET A LIST OF ALL THE MONTH TIME PERIODS
            List<pse__Time_Period__c> timePeriods = new List<pse__Time_Period__c>([SELECT Name, pse__Start_Date__c, pse__End_Date__c
                                                                                   FROM pse__Time_Period__c 
                                                                                   WHERE pse__Type__c = 'Month']);
            
            for (pse__Milestone__c milestone : milestonesToUpdate)
            {
                
                Date targetDate = milestone.pse__Target_Date__c;
                
                if (targetDate == null)
                {
                    // Milestone has no target date. Make sure it has no target period either
                    milestone.Target_Period__c = null;
                }
                else
                {
                    boolean foundMatchingPeriod = false;
                    for (pse__Time_Period__c tp : timePeriods)
                    {
                        // Iterate through the month periods to find the one matching the target date and set the time period name as the milestone's target period
                        if (targetDate >= tp.pse__Start_Date__c && targetDate <= tp.pse__End_Date__c)
                        {
                            milestone.Target_Period__c = tp.Name;
                            foundMatchingPeriod = true;
                        }
                    }
                    
                    // If there was no matching time period, make sure the milestone's target period is empty. (e.g., Milestone target date was set to sometime in year 2025)
                    if (!foundMatchingPeriod)
                    {
                        milestone.Target_Period__c = null;
                    }
                }
            }
        }
               
    }
    
    private void runFlows(List<pse__Milestone__c> newTrigger, Map<Id, pse__Milestone__c> oldMapTrigger)
    {

        Map<String, Id> mapProjIds = new Map<String, Id>(); 
       
        for (pse__Milestone__c ms : newTrigger)
        {
system.debug(' *^* Milestone_Type__c = ' + ms.Milestone_Type__c);             
            if (ms.Milestone_Type__c == 'Billable Milestone' || ms.Milestone_Type__c == 'Complimentary')
            {
                if (oldMapTrigger == null) // IS INSERT
                {
                    mapProjIds.put('varProjectId', ms.pse__Project__c);
                }
                else
                {
                    pse__Milestone__c old = oldMapTrigger.get(ms.Id);
system.debug(' *^* Contracted_Milestone__c = ' + ms.Contracted_Milestone__c + ', old Contracted_Milestone__c = ' + old.Contracted_Milestone__c + ', IsActive__c = ' + ms.IsActive__c + ', old IsActive__c = ' + old.IsActive__c);                    
                    if (ms.Contracted_Milestone__c != old.Contracted_Milestone__c || ms.IsActive__c != old.IsActive__c)
                    {
                        mapProjIds.put('varProjectId', ms.pse__Project__c);
                    }
                }                 
            }
        }
        
system.debug(' *^* mapProjIds = ' + mapProjIds); 
        
        if (!mapProjIds.isEmpty())
        {
            
            Flow.Interview.MilestoneBacklogProjectTotal f1; 
            f1 = new Flow.Interview.MilestoneBacklogProjectTotal(mapProjIds);     
            f1.start();
            
            Flow.Interview.MilestoneTotal f2; 
            f2 = new Flow.Interview.MilestoneTotal(mapProjIds);     
            f2.start(); 
            
        }

    }
    
}