/****************************************************************************************
Name            : AH_RsrcPlan_Overbook_TriggerHandler Class
Author          : Sean Harris
Created Date    : 10/19/2018
Last Mod Date   : 10/19/2018
Last Mod By     : Sean Harris
NICC Reference  : NICC-034366
Description     : Purpose of this class is to create links to corresponding assignments 
                : that make up the overbooking
                :
******************************************************************************************/
public class AH_RsrcPlan_Overbook_TriggerHandler 
{    

    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    
    public AH_RsrcPlan_Overbook_TriggerHandler()
    {   
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults(); 
    }
    
    // ======================================================================================================================================= 
    // = TRIGGER ENTRY METHODS
    // =======================================================================================================================================     
    public void OnAfterInsert(List<AH_Resource_Planner_Overbooking__c> newTrigger, Map<Id, AH_Resource_Planner_Overbooking__c> oldMapTrigger)
    {  
        
        system.debug(' *** ENTERING AH_RsrcPlan_Overbook_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.BypassResourcePlannerOverbook__c)
        {
			processOverbookings(newTrigger);
        }
        
        system.debug(' *** EXITING AH_RsrcPlan_Overbook_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterUpdate(List<AH_Resource_Planner_Overbooking__c> newTrigger, Map<Id, AH_Resource_Planner_Overbooking__c> oldMapTrigger)
    { 
        
        system.debug(' *** ENTERING AH_RsrcPlan_Overbook_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.BypassResourcePlannerOverbook__c)
        {            
			processOverbookings(newTrigger);
        }
        
        system.debug(' *** EXITING AH_RsrcPlan_Overbook_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    // ======================================================================================================================================= 
    // = TRIGGER FUNCTIONS
    // ======================================================================================================================================= 	 

    private void purgeNonOverbookedJunctionRecords(Set<Id> setContactIds)
    {
        
        // PURGES ALL Resource_Overbooking_to_Assignment__c RECORDS THAT HAVE A REFERENCE TO NON-OVERBOOKED AH_Resource_Planner_Overbooking__c RECORD
        
        try
        {
            
            List<Resource_Overbooking_to_Assignment__c> lstJuncs = new List<Resource_Overbooking_to_Assignment__c>(
                [SELECT Id, Assignment__c, Overbooked_Date__c, Resource_Planner_Overbooking__c 
                 FROM Resource_Overbooking_to_Assignment__c 
                 WHERE Contact__c IN : setContactIds 
                 AND IsOverbooked__c = false]);

system.debug(' *^* PURGING ' + lstJuncs.size() + ' Resource_Overbooking_to_Assignment__c RECORDS...');
            
            database.delete(lstJuncs, false); 

system.debug(' *^* PURGE SUCCESSFUL! ');
            
        }
        catch (Exception e)
        {
system.debug(' *^* ERROR OCCURRED PURGING RECORDS: ' + e.getMessage());            
        }

    }
    
    private void processOverbookings(List<AH_Resource_Planner_Overbooking__c> newTrigger)
    {

        system.debug(' *** ENTERING AH_RsrcPlan_Overbook_TriggerHandler.processOverbookings() - QUERIES ISSUED = ' + Limits.getQueries());
                
system.debug(' *^* newTrigger.size() = ' + newTrigger.size());	        
        
        // SETS A DATE VARIABLE IN THE PAST. USED FOR pse__Start_Date__c GREATER THAN SOQL FILTERS
        Date dtNow = system.today();
        //Date dtMinStart = Date.newInstance(dtNow.Year(), 1, 1);
        Date dtMinStart = dtNow.addDays(-366);

system.debug(' *^* dtMinStart = ' + dtMinStart);
        
        // FILL A SET OF RESOURCE IDS (Contact IDs)
        Set<Id> setResourceIds = new Set<Id>();
        for (AH_Resource_Planner_Overbooking__c o : newTrigger)
        {
            setResourceIds.add(o.Contact__c);
        }        

system.debug(' *^* setResourceIds = ' + setResourceIds);
        
		// PURGE ALL Resource_Overbooking_to_Assignment__c RECORDS THAT HAVE REFERENCE TO A NON-OVERBOOKED AH_Resource_Planner_Overbooking__c RECORD
        purgeNonOverbookedJunctionRecords(setResourceIds);
        

        // QUERY ALL 'Scheduled' OR 'Tentative' ASSIGNMENT RECORDS FOR RELATED RESOURCE(S) WITH START DATE GREATED THAN VARIABLE SPECIFIED ABOVE
        List<pse__Assignment__c> lstAssignments = new List<pse__Assignment__c>([SELECT Id, Name, pse__Schedule__c, pse__Resource__c 
                                                                                FROM pse__Assignment__c 
                                                                                WHERE pse__Schedule__c != null 
                                                                                AND pse__Status__c IN ('Scheduled', 'Tentative')
                                                                                AND pse__Start_Date__c >= : dtMinStart 
                                                                                AND pse__Resource__c IN : setResourceIds]);
															 
system.debug(' *^* lstAssignments.size() = ' + lstAssignments.size());	
        
        // BUILD A MAP OF pse__Assignment__c RECORDS WITH THE RECORD'S pse__Schedule__c ID AS THE KEY
        Map<Id, pse__Assignment__c> mapSchedule2Assignment = new Map<Id, pse__Assignment__c>();                               
		for (pse__Assignment__c a1 : lstAssignments)
        {
            mapSchedule2Assignment.put(a1.pse__Schedule__c, a1);
        }

system.debug(' *^* mapSchedule2Assignment.size() = ' + mapSchedule2Assignment.size());        
        
        // CREATE A LIST OF SCHEDULES WITH CHILD EXCEPTIONS RELATED TO THE ASSIGNMENTS QUERIED ABOVE
        List<pse__Schedule__c> lstSchedules = new List<pse__Schedule__c>(
            [SELECT p.Id, p.Name, p.pse__Start_Date__c, p.pse__End_Date__c, CreatedById, 
             p.pse__Sunday_Hours__c, p.pse__Monday_Hours__c, p.pse__Tuesday_Hours__c, p.pse__Wednesday_Hours__c, p.pse__Thursday_Hours__c, p.pse__Friday_Hours__c, p.pse__Saturday_Hours__c, 
             	(SELECT Id, Name, pse__Date__c, pse__End_Date__c, CreatedById, pse__Schedule__c,  
              	pse__Sunday_Hours__c, pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c, pse__Thursday_Hours__c, pse__Friday_Hours__c, pse__Saturday_Hours__c 
              	FROM pse__Schedule_Exceptions__r)
             FROM pse__Schedule__c p
             WHERE Id IN : mapSchedule2Assignment.keySet()]);  

system.debug(' *^* lstSchedules.size() = ' + lstSchedules.size());
               
        // CREATE A LIST OF SCHEDULES BY RESOURCE
        List<plannerDay> lstSchedDays = new List<plannerDay>();		

        for (pse__Schedule__c sch : lstSchedules)
        {
            
            // GET START & END DATES OF CURRENT pse__Schedule__c RECORD
            Date dtSchedStart = sch.pse__Start_Date__c;
            Date dtSchedEnd = sch.pse__End_Date__c;
            // GET NUMBER OF DAYS BETWEEN START & END. (ADDED 1 TO VARIABLE TO PREVENT 0 VALUE WHEN START & END DATE ARE SAME DAY)
            Integer iSchedDays = (dtSchedStart.daysBetween(dtSchedEnd) + 1);

            // FILL A LIST OF ALL THE RELATED pse__Schedule_Exception__c RECORDS
            List<pse__Schedule_Exception__c> lstSchedExs = new List<pse__Schedule_Exception__c>();
            lstSchedExs = sch.pse__Schedule_Exceptions__r;

            // IF THERE ARE NO RELATED pse__Schedule_Exception__c RECORDS THEN PROCESS BASED ON pse__Schedule__c RECORD
//            if (lstSchedExs.size() == 0)
//            {
                
                for (Integer i = 0; i < iSchedDays; i++)
                {                    
                    
                    Date dtSchedDay = dtSchedStart.addDays(i);
                    Datetime dtSchedTmp = DateTime.newInstance(dtSchedDay, Time.newInstance(0, 0, 0, 0));
                    String strDayName = dtSchedTmp.format('EEEE');

                    if (strDayName == 'Sunday')
                    {
                        lstSchedDays.add(new plannerDay(dtSchedDay, strDayName, sch.Name, sch.Name, mapSchedule2Assignment.get(sch.Id).pse__Resource__c, mapSchedule2Assignment.get(sch.Id).Id, sch.pse__Sunday_Hours__c, false, sch.CreatedById));
                    }
                    if (strDayName == 'Monday')
                    {
                        lstSchedDays.add(new plannerDay(dtSchedDay, strDayName, sch.Name, sch.Name, mapSchedule2Assignment.get(sch.Id).pse__Resource__c, mapSchedule2Assignment.get(sch.Id).Id, sch.pse__Monday_Hours__c, false, sch.CreatedById));
                    }
                    if (strDayName == 'Tuesday')
                    {
                        lstSchedDays.add(new plannerDay(dtSchedDay, strDayName, sch.Name, sch.Name, mapSchedule2Assignment.get(sch.Id).pse__Resource__c, mapSchedule2Assignment.get(sch.Id).Id, sch.pse__Tuesday_Hours__c, false, sch.CreatedById));
                    }
                    if (strDayName == 'Wednesday')
                    {
                        lstSchedDays.add(new plannerDay(dtSchedDay, strDayName, sch.Name, sch.Name, mapSchedule2Assignment.get(sch.Id).pse__Resource__c, mapSchedule2Assignment.get(sch.Id).Id, sch.pse__Wednesday_Hours__c, false, sch.CreatedById));
                    }
                    if (strDayName == 'Thursday')
                    {
                        lstSchedDays.add(new plannerDay(dtSchedDay, strDayName, sch.Name, sch.Name, mapSchedule2Assignment.get(sch.Id).pse__Resource__c, mapSchedule2Assignment.get(sch.Id).Id, sch.pse__Thursday_Hours__c, false, sch.CreatedById));
                    }
                    if (strDayName == 'Friday')
                    {
                        lstSchedDays.add(new plannerDay(dtSchedDay, strDayName, sch.Name, sch.Name, mapSchedule2Assignment.get(sch.Id).pse__Resource__c, mapSchedule2Assignment.get(sch.Id).Id, sch.pse__Friday_Hours__c, false, sch.CreatedById));
                    }
                    if (strDayName == 'Saturday')
                    {
                        lstSchedDays.add(new plannerDay(dtSchedDay, strDayName, sch.Name, sch.Name, mapSchedule2Assignment.get(sch.Id).pse__Resource__c, mapSchedule2Assignment.get(sch.Id).Id, sch.pse__Saturday_Hours__c, false, sch.CreatedById));
                    }
                    
                } 
                
//            }
//            else
//            {
                
                for (pse__Schedule_Exception__c schEx : sch.pse__Schedule_Exceptions__r)
                {
                    
                    // GET START & END DATES OF CURRENT pse__Schedule_Exception__c RECORD
                    Date dtSchedExStart = schEx.pse__Date__c;
                    Date dtSchedExEnd = schEx.pse__End_Date__c;
                    // GET NUMBER OF DAYS BETWEEN START & END. (ADDED 1 TO VARIABLE TO PREVENT 0 VALUE WHEN START & END DATE ARE SAME DAY)
                    Integer iSchedExDays = (dtSchedExStart.daysBetween(dtSchedExEnd) + 1);
                    
                    for (Integer i = 0; i < iSchedExDays; i++)
                    {
                        
                        Date dtSchedExDay = dtSchedExStart.addDays(i);
                        Datetime dtSchedExTmp = DateTime.newInstance(dtSchedExDay, Time.newInstance(0, 0, 0, 0));
                        String strDayNameEx = dtSchedExTmp.format('EEEE');
                        
                        if (strDayNameEx == 'Sunday' && schEx.pse__Sunday_Hours__c > 0)
                        {
                            lstSchedDays.add(new plannerDay(dtSchedExDay, strDayNameEx, sch.Name, schEx.Name, mapSchedule2Assignment.get(schEx.pse__Schedule__c).pse__Resource__c, mapSchedule2Assignment.get(schEx.pse__Schedule__c).Id, schEx.pse__Sunday_Hours__c, true, schEx.CreatedById));
                        }
                        if (strDayNameEx == 'Monday' && schEx.pse__Monday_Hours__c > 0)
                        {
                            lstSchedDays.add(new plannerDay(dtSchedExDay, strDayNameEx, sch.Name, schEx.Name, mapSchedule2Assignment.get(schEx.pse__Schedule__c).pse__Resource__c, mapSchedule2Assignment.get(schEx.pse__Schedule__c).Id, schEx.pse__Monday_Hours__c, true, schEx.CreatedById));
                        }
                        if (strDayNameEx == 'Tuesday' && schEx.pse__Tuesday_Hours__c > 0)
                        {
                            lstSchedDays.add(new plannerDay(dtSchedExDay, strDayNameEx, sch.Name, schEx.Name, mapSchedule2Assignment.get(schEx.pse__Schedule__c).pse__Resource__c, mapSchedule2Assignment.get(schEx.pse__Schedule__c).Id, schEx.pse__Tuesday_Hours__c, true, schEx.CreatedById));
                        }
                        if (strDayNameEx == 'Wednesday' && schEx.pse__Wednesday_Hours__c > 0)
                        {
                            lstSchedDays.add(new plannerDay(dtSchedExDay, strDayNameEx, sch.Name, schEx.Name, mapSchedule2Assignment.get(schEx.pse__Schedule__c).pse__Resource__c, mapSchedule2Assignment.get(schEx.pse__Schedule__c).Id, schEx.pse__Wednesday_Hours__c, true, schEx.CreatedById));
                        }
                        if (strDayNameEx == 'Thursday' && schEx.pse__Thursday_Hours__c > 0)
                        {
                            lstSchedDays.add(new plannerDay(dtSchedExDay, strDayNameEx, sch.Name, schEx.Name, mapSchedule2Assignment.get(schEx.pse__Schedule__c).pse__Resource__c, mapSchedule2Assignment.get(schEx.pse__Schedule__c).Id, schEx.pse__Thursday_Hours__c, true, schEx.CreatedById));
                        }
                        if (strDayNameEx == 'Friday' && schEx.pse__Friday_Hours__c > 0)
                        {
                            lstSchedDays.add(new plannerDay(dtSchedExDay, strDayNameEx, sch.Name, schEx.Name, mapSchedule2Assignment.get(schEx.pse__Schedule__c).pse__Resource__c, mapSchedule2Assignment.get(schEx.pse__Schedule__c).Id, schEx.pse__Friday_Hours__c, true, schEx.CreatedById));
                        }
                        if (strDayNameEx == 'Saturday' && schEx.pse__Saturday_Hours__c > 0)
                        {
                            lstSchedDays.add(new plannerDay(dtSchedExDay, strDayNameEx, sch.Name, schEx.Name, mapSchedule2Assignment.get(schEx.pse__Schedule__c).pse__Resource__c, mapSchedule2Assignment.get(schEx.pse__Schedule__c).Id, schEx.pse__Saturday_Hours__c, true, schEx.CreatedById));
                        }
                        
                    }                
                    
                }  
                
//            }
  
        }
            
system.debug(' *^* lstSchedDays.size() = ' + lstSchedDays.size()); 
        
        // CREATE A LIST OF Resource_Overbooking_to_Assignment__c JUNCTION RECORDS TO BE INSERTED
        List<Resource_Overbooking_to_Assignment__c> lstJuncInserts = new List<Resource_Overbooking_to_Assignment__c>();
        // CREATE A SET OF AH_Resource_Planner_Overbooking__c IDS TO BE PURGED PRIOR TO INSERT
		Set<Id> setRPOIds = new Set<Id>();

		// LOOP THROUGH ALL RECORDS IN TRIGGER AND FILL LIST OF JUNCTION RECORDS TO BE INSERTED
        for (AH_Resource_Planner_Overbooking__c rpo : newTrigger)
        {   
            
            if (rpo.IsOverbooked__c)
            {
                
                setRPOIds.add(rpo.Id);
                
                // LOOP THROUGH AND FIND ALL RELATED SCHEDULES
                for (plannerDay schDay : lstSchedDays)
                {
//system.debug(rpo.Contact__c + ' == ' + schDay.resourceId + ' && ' + rpo.Booked_Date__c + ' == ' + schDay.dt);  
                    if (rpo.Contact__c == schDay.resourceId && rpo.Booked_Date__c == schDay.dt)
                    {  
system.debug(' *^* FOUND MATCH');                   
                        Resource_Overbooking_to_Assignment__c ro2a = new Resource_Overbooking_to_Assignment__c();   
                        ro2a.Resource_Planner_Overbooking__c = rpo.Id; 
system.debug(' *^* schDay.dHours = ' + schDay.dHours);                    
                        if (schDay.dHours > 0)
                        {  
                            ro2a.Assignment__c = schDay.AssignmentId;
                            ro2a.Blocked_By__c = schDay.blockedById;
                            ro2a.Hours_Blocked__c = schDay.dHours;
                            ro2a.Schedule_Exception__c = schDay.isSchedException;
                            lstJuncInserts.add(ro2a);
                        }
                        
                    }
                    
                }                
                
            }            
            
        }

        // IN ORDER TO PREVENT DUPLICATE JUNCTION OBJECTS DELETE ALL EXISTING BEFORE INSERT
        List<Resource_Overbooking_to_Assignment__c> lstJuncDeletes = new List<Resource_Overbooking_to_Assignment__c>(
            [SELECT Id 
             FROM Resource_Overbooking_to_Assignment__c 
             WHERE Resource_Planner_Overbooking__c IN : setRPOIds]);

system.debug(' *^* lstJuncDeletes.size() = ' + lstJuncDeletes.size());
        
        if (!lstJuncDeletes.isEmpty())
        {
            database.delete(lstJuncDeletes);
        }         
        
system.debug(' *^* lstJuncInserts.size() = ' + lstJuncInserts.size());
        
        if (!lstJuncInserts.isEmpty())
        {
            database.insert(lstJuncInserts);
        }
        
    }

    // =======================================================================================================================================
    // = WRAPPER CLASSES
    // =======================================================================================================================================
    public class plannerDay
    {
        
        public Date dt {get; set;} 
        public String dayName {get; set;}
        public String parentScheduleName {get; set;}
        public String ScheduleName {get; set;}        
        public Id resourceId {get; set;}
        public Id AssignmentId {get; set;}
        public Decimal dHours {get; set;}
        public Boolean isSchedException {get; set;}
        public Id blockedById {get; set;}
        
        public plannerDay (Date p1, String p2, String p3, String p4, Id p5, Id p6, Decimal p7, Boolean p8, Id p9)
        {
            this.dt = p1;
            this.dayName = p2;
            this.parentScheduleName = p3;
            this.ScheduleName = p4;
            this.resourceId = p5;
            this.AssignmentId = p6;
            this.dHours = 0;
            if (p7 != null)
            {
                this.dHours = p7;
            }
            this.isSchedException = p8;
            this.blockedById = p9;
        }
        
    }
    
}