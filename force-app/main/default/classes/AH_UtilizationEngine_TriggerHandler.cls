/****************************************************************************************
Name            : AH_UtilizationEngine_TriggerHandler Class
Author          : Sean Harris
Created Date    : 10/19/2018
Last Mod Date   : 04/30/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-034366
Description     : Purpose of this class is to parse Utilization Engine records after insert
                : and upsert these records into custom object called AH_Resource_Planner_Overbooking__c
                : 
******************************************************************************************/
public class AH_UtilizationEngine_TriggerHandler 
{
    
    Boolean bIsOverBooked;
	Decimal dHoursBooked; 
	Decimal dWorkCalendarHours; 
    List<AH_Resource_Planner_Overbooking__c> lstNewOBs;
    // VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING 
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    
    public AH_UtilizationEngine_TriggerHandler()
    {   
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();  
    }
    
    public void OnAfterInsert(List<pse__Utilization_Engine__c> newTrigger, Map<Id, pse__Utilization_Engine__c> oldMapTrigger)
    {  
        if (!bpSwitch.BypassResourcePlannerOverbook__c)
        {
            system.debug(' *** AH_UtilizationEngine_TriggerHandler.OnAfterInsert()');   
            processOverbookings(newTrigger);
        }
    }
    
    
    // FUNCTIONS ================================================================    
    private void processOverbookings(List<pse__Utilization_Engine__c> newTrigger)
    {
        
        lstNewOBs = new List<AH_Resource_Planner_Overbooking__c>();

        // GET ALL EXISTING AH_Resource_Planner_Overbooking__c WHERE THE Resource IS IN TRIGGER
        // THIS WILL BE USED LATER TO MATCH UP AGAINST NEW AH_Resource_Planner_Overbooking__c LIST FOR UPSERT
        // WILL BE USED TO GET IDS FOR UPDATES 
        Set<Id> setResourceIds = new Set<Id>();
        for (pse__Utilization_Engine__c ue : newTrigger)
        {
            setResourceIds.add(ue.pse__Resource__c);
        }
        
        List<AH_Resource_Planner_Overbooking__c> lstExistingOBs = new List<AH_Resource_Planner_Overbooking__c>(
            [SELECT Id, Booked_Date__c, Hours_Booked__c, IsOverbooked__c, Contact__c, Work_Calendar_Hours__c, Year__c   
             FROM AH_Resource_Planner_Overbooking__c 
             WHERE Contact__c IN : setResourceIds 
             ORDER BY Contact__c, Year__c]); 
        
        // TRIGGER PARSE START ====================================================================================
        
        // LOOP THROUGH ALL pse__Utilization_Engine__c RECORDS IN TRIGGER 
        for (pse__Utilization_Engine__c ue : newTrigger)
        {
            
            // CREATE A AH_Resource_Planner_Overbooking__c RECORD FOR EVERY FIELD IN pse__Utilization_Engine__c 
            // PASSED IN AND ADD TO THE lstNewOBs LIST COLLECTION
            createOBRecords(ue); 
            
            // A TEMP LIST USED TO STORE A YEARS WORTH OF "EXISTING" AH_Resource_Planner_Overbooking__c BELONGING
            // TO CURRENT RESOURCE/YEAR IN pse__Utilization_Engine__c TRIGGER LOOP
            List<AH_Resource_Planner_Overbooking__c> lstOBs = new List<AH_Resource_Planner_Overbooking__c>(); 
            
            for (AH_Resource_Planner_Overbooking__c ob : lstExistingOBs)
            {
                if ((ue.pse__Resource__c == ob.Contact__c) && (Integer.valueOf(ue.pse__Period__c) == ob.Year__c))
                {
                	lstOBs.add(ob); 
                }
            }
            
            // IF RECORDS FOUND, PASS LIST INTO A PREP METHOD THAT UPDATES WORKING LIST OF AH_Resource_Planner_Overbooking__c CREATED BY PARSE
            // AND ASSIGNING AN Id & RemoveFromUpsert__c CONDITIONALLY 
            if (!lstOBs.isEmpty())
            {
                prepareOBRecords(lstOBs);
            }
			
        }
        
        // TRIGGER PARSE COMPLETE ==============================================================================
        
        // A LIST FOR FINAL UPSERT. CONTAINS A FILTERED RECORDSET TO PREVENT REDUNDANT UPDATES 
        List<AH_Resource_Planner_Overbooking__c> lstOBUpserts = new List<AH_Resource_Planner_Overbooking__c>();
        
        // LOOP THROUGH WORKING LIST OF AH_Resource_Planner_Overbooking__c AND ADD ONLY NEW OR CHANGED RECORDS TO FINAL LIST
        for (AH_Resource_Planner_Overbooking__c nwob : lstNewOBs)
        {
            // SET THE UNIQUE EXTERNAL ID FIELD. USED TO PREVENT LARGE UPSERTS FROM CREATING DUPLICATE AH_Resource_Planner_Overbooking__c RECORDS
            string strExternalId = String.valueOf(nwob.Contact__c) + '_' + String.valueOf(nwob.Booked_Date__c);  
system.debug(' *^* strExternalId = ' + strExternalId); 
            nwob.External_Id__c = strExternalId.remove('-');         
            if (!nwob.RemoveFromUpsert__c)
            {
                lstOBUpserts.add(nwob);
            }
        }  
		
        // TRY THE UPSERT OF FINAL AH_Resource_Planner_Overbooking__c LIST
        try
        {
system.debug(' *^* lstOBUpserts.size() = ' + lstOBUpserts.size()); 
            Schema.SObjectField f = AH_Resource_Planner_Overbooking__c.Fields.External_Id__c;
            database.upsert(lstOBUpserts, f, false);
        }
        catch (exception ex)
        {
            system.debug(' *** ERROR OCCURRED! - Line: ' + ex.getLineNumber() + ', Error:' + ex.getMessage());
        }
        
    }    

	private void prepareOBRecords(List<AH_Resource_Planner_Overbooking__c> lst)
    {

        // THIS METHOD LOOPS THROUGH AH_Resource_Planner_Overbooking__c LIST FOR UPSERT AND DOES THE FOLLOWING:
        // 		1) ASSIGNS AN Id WHEN A CHANGE IS MADE TO IsOverbooked__c, Hours_Booked__c OR Work_Calendar_Hours__c
        // 		2) IF NO CHANGE IS MADE TO IsOverbooked__c, Hours_Booked__c OR Work_Calendar_Hours__c, FLAG FOR REMOVAL FROM FINAL UPSERT
        for (AH_Resource_Planner_Overbooking__c ovr : lst)
        {
            for (AH_Resource_Planner_Overbooking__c nwOvr : lstNewOBs)
            {
                if ((ovr.Contact__c == nwOvr.Contact__c) && (ovr.Booked_Date__c == nwOvr.Booked_Date__c))
                {
                    nwOvr.Id = ovr.Id;
                    // IF NOTHING HAS CHANGED THEN FLAG TO BE REMOVED FROM UPSERT
                    if (ovr.IsOverbooked__c == nwOvr.IsOverbooked__c && 
                        ovr.Hours_Booked__c == nwOvr.Hours_Booked__c && 
                        ovr.Work_Calendar_Hours__c == nwOvr.Work_Calendar_Hours__c)
                    {
                        nwOvr.RemoveFromUpsert__c = true;
                    } 
                }
            }            
        }
        
    }
    
    private void parseUEField(string strData)
    {
        
        bIsOverBooked = false;
        dWorkCalendarHours = 0;
        dHoursBooked = 0;

        string str = strData;
        List<String> s = new List<String>();
        s = str.split(',');
        
        dWorkCalendarHours = decimal.valueOf(s[0]);
        dHoursBooked= (decimal.valueOf(s[1]) + decimal.valueOf(s[2]) + decimal.valueOf(s[3]) + decimal.valueOf(s[4]) + decimal.valueOf(s[5]));
        
        if (dHoursBooked > dWorkCalendarHours)
        {
            bIsOverBooked = true;
        }

    }
    	    
    private void createOBRecords(pse__Utilization_Engine__c ue)
    {

        AH_Resource_Planner_Overbooking__c ob;
        Integer yr = Integer.valueOf(ue.pse__Period__c);
        
        // JANUARY 
        parseUEField(ue.pse__data_1_1__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 1), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_2__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 2), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_3__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 3), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_4__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 4), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_5__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 5), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_6__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 6), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_7__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 7), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_8__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 8), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_9__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 9), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_10__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 10), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_11__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 11), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_12__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 12), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_13__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 13), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_14__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 14), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_15__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 15), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_16__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 16), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_17__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 17), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_18__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 18), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_19__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 19), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_20__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 20), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_21__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 21), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_22__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 22), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_23__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 23), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_24__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 24), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_25__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 25), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_26__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 26), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_27__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 27), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_28__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 28), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_29__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 29), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_30__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 30), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_1_31__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 1, 31), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        
        // FEBRUARY
        parseUEField(ue.pse__data_2_1__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 1), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_2__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 2), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_3__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 3), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_4__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 4), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_5__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 5), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_6__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 6), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_7__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 7), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_8__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 8), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_9__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 9), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_10__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 10), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_11__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 11), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_12__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 12), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_13__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 13), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_14__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 14), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_15__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 15), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_16__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 16), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_17__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 17), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_18__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 18), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_19__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 19), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_20__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 20), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_21__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 21), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_22__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 22), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_23__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 23), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_24__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 24), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_25__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 25), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_26__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 26), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_27__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 27), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_2_28__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 28), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        
        if (date.isLeapYear(yr))
        {
            parseUEField(ue.pse__data_2_29__c); 
            ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 2, 29), 
                                                        Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
            lstNewOBs.add(ob);             
        }
        
        // MARCH
        parseUEField(ue.pse__data_3_1__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 1), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_2__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 2), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_3__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 3), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_4__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 4), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_5__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 5), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_6__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 6), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_7__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 7), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_8__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 8), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_9__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 9), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_10__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 10), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_11__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 11), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_12__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 12), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_13__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 13), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_14__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 14), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_15__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 15), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_16__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 16), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_17__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 17), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_18__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 18), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_19__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 19), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_20__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 20), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_21__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 21), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_22__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 22), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_23__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 23), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_24__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 24), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_25__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 25), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_26__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 26), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_27__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 27), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_28__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 28), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_29__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 29), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_30__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 30), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_3_31__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 3, 31), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        
        // APRIL 
        parseUEField(ue.pse__data_4_1__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 1), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_2__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 2), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_3__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 3), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_4__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 4), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_5__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 5), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_6__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 6), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_7__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 7), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_8__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 8), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_9__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 9), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_10__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 10), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_11__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 11), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_12__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 12), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_13__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 13), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_14__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 14), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_15__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 15), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_16__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 16), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_17__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 17), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_18__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 18), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_19__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 19), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_20__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 20), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_21__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 21), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_22__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 22), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_23__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 23), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_24__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 24), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_25__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 25), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_26__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 26), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_27__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 27), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_28__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 28), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_29__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 29), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_4_30__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 4, 30), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        
        // MAY
        parseUEField(ue.pse__data_5_1__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 1), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_2__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 2), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_3__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 3), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_4__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 4), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_5__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 5), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_6__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 6), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_7__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 7), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_8__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 8), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_9__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 9), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_10__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 10), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_11__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 11), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_12__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 12), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_13__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 13), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_14__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 14), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_15__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 15), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_16__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 16), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_17__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 17), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_18__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 18), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_19__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 19), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_20__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 20), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_21__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 21), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_22__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 22), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_23__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 23), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_24__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 24), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_25__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 25), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_26__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 26), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_27__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 27), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_28__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 28), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_29__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 29), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_30__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 30), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_5_31__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 5, 31), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        
        // JUNE
        parseUEField(ue.pse__data_6_1__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 1), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_2__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 2), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_3__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 3), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_4__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 4), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_5__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 5), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_6__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 6), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_7__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 7), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_8__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 8), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_9__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 9), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_10__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 10), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_11__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 11), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_12__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 12), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_13__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 13), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_14__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 14), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_15__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 15), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_16__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 16), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_17__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 17), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_18__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 18), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_19__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 19), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_20__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 20), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_21__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 21), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_22__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 22), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_23__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 23), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_24__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 24), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_25__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 25), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_26__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 26), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_27__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 27), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_28__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 28), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_29__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 29), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_6_30__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 6, 30), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        
        // JUNE
        parseUEField(ue.pse__data_7_1__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 1), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_2__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 2), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_3__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 3), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_4__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 4), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_5__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 5), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_6__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 6), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_7__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 7), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_8__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 8), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_9__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 9), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_10__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 10), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_11__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 11), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_12__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 12), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_13__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 13), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_14__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 14), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_15__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 15), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_16__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 16), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_17__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 17), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_18__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 18), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_19__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 19), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_20__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 20), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_21__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 21), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_22__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 22), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_23__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 23), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_24__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 24), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_25__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 25), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_26__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 26), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_27__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 27), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_28__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 28), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_29__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 29), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_30__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 30), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_7_31__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 7, 31), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob);         
        
        // AUGUST 
        parseUEField(ue.pse__data_8_1__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 1), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_2__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 2), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_3__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 3), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_4__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 4), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_5__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 5), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_6__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 6), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_7__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 7), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_8__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 8), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_9__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 9), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_10__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 10), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_11__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 11), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_12__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 12), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_13__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 13), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_14__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 14), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_15__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 15), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_16__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 16), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_17__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 17), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_18__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 18), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_19__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 19), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_20__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 20), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_21__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 21), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_22__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 22), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_23__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 23), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_24__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 24), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_25__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 25), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_26__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 26), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_27__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 27), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_28__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 28), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_29__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 29), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_30__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 30), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_8_31__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 8, 31), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        
        // SEPTEMBER 
        parseUEField(ue.pse__data_9_1__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 1), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_2__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 2), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_3__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 3), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_4__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 4), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_5__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 5), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_6__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 6), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_7__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 7), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_8__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 8), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_9__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 9), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_10__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 10), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_11__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 11), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_12__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 12), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_13__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 13), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_14__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 14), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_15__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 15), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_16__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 16), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_17__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 17), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_18__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 18), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_19__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 19), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_20__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 20), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_21__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 21), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_22__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 22), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_23__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 23), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_24__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 24), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_25__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 25), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_26__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 26), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_27__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 27), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_28__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 28), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_29__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 29), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_9_30__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 9, 30), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        
        // OCTOBER
        parseUEField(ue.pse__data_10_1__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 1), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_2__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 2), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_3__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 3), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_4__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 4), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_5__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 5), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_6__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 6), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_7__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 7), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_8__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 8), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_9__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 9), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_10__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 10), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_11__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 11), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_12__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 12), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_13__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 13), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_14__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 14), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_15__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 15), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_16__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 16), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_17__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 17), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_18__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 18), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_19__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 19), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_20__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 20), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_21__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 21), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_22__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 22), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_23__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 23), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_24__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 24), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_25__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 25), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_26__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 26), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_27__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 27), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_28__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 28), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_29__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 29), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_30__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 30), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_10_31__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 10, 31), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        
        // NOVEMBER
        parseUEField(ue.pse__data_11_1__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 1), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_2__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 2), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_3__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 3), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_4__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 4), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_5__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 5), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_6__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 6), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_7__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 7), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_8__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 8), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_9__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 9), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_10__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 10), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_11__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 11), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_12__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 12), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_13__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 13), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_14__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 14), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_15__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 15), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_16__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 16), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_17__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 17), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_18__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 18), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_19__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 19), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_20__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 20), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_21__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 21), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_22__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 22), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_23__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 23), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_24__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 24), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_25__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 25), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_26__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 26), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_27__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 27), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_28__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 28), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_29__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 29), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_11_30__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 11, 30), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        
        // DECEMBER
        parseUEField(ue.pse__data_12_1__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 1), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_2__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 2), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_3__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 3), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_4__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 4), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_5__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 5), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_6__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 6), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_7__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 7), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_8__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 8), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_9__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 9), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_10__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 10), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_11__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 11), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_12__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 12), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_13__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 13), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_14__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 14), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_15__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 15), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_16__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 16), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_17__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 17), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_18__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 18), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_19__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 19), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_20__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 20), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_21__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 21), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_22__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 22), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_23__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 23), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_24__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 24), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_25__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 25), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_26__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 26), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_27__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 27), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_28__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 28), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_29__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 29), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_30__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 30), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob); 
        parseUEField(ue.pse__data_12_31__c); 
        ob = new AH_Resource_Planner_Overbooking__c(Contact__c = ue.pse__Resource__c, Booked_Date__c = date.newInstance(yr, 12, 31), 
                                                    Year__c = yr, IsOverbooked__c = bIsOverBooked, Work_Calendar_Hours__c = dWorkCalendarHours, Hours_Booked__c = dHoursBooked); 
        lstNewOBs.add(ob);         
        
    }
  
}