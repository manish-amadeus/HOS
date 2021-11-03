/************************************************************************************************
Name            : NI_Task_TriggerHandler Class
Author          : Sean Harris
Created Date    : 11/30/2016
Last Mod Date   : 04/30/2018
Last Mod By     : Shashikant Nikam
NICC Reference  :
Description     : Class that handles all trigger code for the Task Object
                : Ria added Trigger Switch to bypass 'CASE FLAGS' code.
                : New method 'clearCaseFlag' added to clear flag when a new Completed task of 
				: record type mentioned in custom setting is inserted.
				: 
*************************************************************************************************/
public class NI_Task_TriggerHandler
{
    
    
    public NI_Task_TriggerHandler()
    {
        
    }
     
    public void OnBeforeInsert(List<Task> newTrigger)
    {
        
        if (bypassTrigger(newTrigger))
        {
            return;
        }        
        
        // VARIABLES TO HOLD VALUES
        List<Task> tasksToProcess = new List<Task>();
        Set<String> businessHrsSet = new Set<String>();
        Map<String, String> recTypeBusHrsMap = new Map<String, String>();
        Map<String, Id> bsHrsMap = new Map<String, Id>();
       
        // UPDATED BY SHASHIKANT FOR OPTIMIZATION on 04/26/2018
        // FETCH RECORDTYPE OF TASK AND BUSINESS HOURS FROM CUSTOM SETTING
        List<AH_Task_Business_Hours__c> list_AH_Task_Business_Hours = new List<AH_Task_Business_Hours__c>();
        list_AH_Task_Business_Hours = AH_Task_Business_Hours__c.getAll().values();
        if (!list_AH_Task_Business_Hours.isEmpty()) 
        {
            for (AH_Task_Business_Hours__c t : list_AH_Task_Business_Hours)
            {
                businessHrsSet.add(t.Business_Hours__c);
                recTypeBusHrsMap.put(t.Name, t.Business_Hours__c);
            }
        }
        
        // CREATE A MAP TO HOLD BUSINESS HOURS NAME WITH ITS ID
        for (BusinessHours bh: [SELECT Name FROM BusinessHours WHERE Name IN :businessHrsSet])
        {
            bsHrsMap.put(bh.Name, bh.Id);
        }
        
        // GET RECORD TYPE IDS AND STORE IN A MAP
        Map<Id, String> rtMap = new Map<Id, String>();
        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.Task.getRecordTypeInfosByName();

		if (!recTypeBusHrsMap.isEmpty()) 
        {
            for (String recType : recordTypesMap.keyset()) 
            {
				if (recTypeBusHrsMap.containsKey(recType)) 
                {
                    Schema.RecordTypeInfo rr = recordTypesMap.get(recType);
                    rtMap.put(rr.getRecordTypeId(), recType);
                }
            }
        }
        
        for (Task t : newTrigger)
        {
            String recordTypeName = '';
            if (rtMap.containsKey(t.RecordTypeId))
            {
                tasksToProcess.add(t);
                // GET RECORDTYPE NAME OF CURRENT TASK RECORD
                recordTypeName = rtMap.get(t.RecordTypeId);
            }
            
            if (recTypeBusHrsMap.containsKey(recordTypeName))
            {
                String businessHours = recTypeBusHrsMap.get(recordTypeName);
                if (bsHrsMap.containsKey(businessHours))
                {
                    // GET ID OF BUSINESS HOURS OBJECT FROM NAME OF RECORDTYPE
                    Id bsHrs = bsHrsMap.get(businessHours);
                    t.Business_Hours__c = bsHrs;
                }
            }
        }
        
        // CALL METHOD TO SET TIME AS 'NOW' IF STATUS IS ON HOLD
        if (!tasksToProcess.isEmpty())
        {
            setOnHoldTime(tasksToProcess);
        }
        
    }
    
    public void OnBeforeUpdate(List<Task> newTrigger, Map<Id, Task> oldMapTrigger)
    {
        
        if (bypassTrigger(newTrigger))
        {
            return;
        }        
        
        // UPDATED BY SHASHIKANT FOR OPTIMIZATION on 04/27/2018
        // RETRIEVE DATA FROM CUSTOM SETTING - AH_Task_Business_Hours__c
        List<AH_Task_Business_Hours__c> list_AH_TaskBusinessHours = new List<AH_Task_Business_Hours__c>();
        list_AH_TaskBusinessHours = AH_Task_Business_Hours__c.getAll().Values();
        
        // CREATE SET OF RECORD TYPE NAMES LISTED IN CUSTOM SETTINGS - AH_Task_Business_Hours__c
        Set<String> recTypeSet = new Set<String>();
        if (!list_AH_TaskBusinessHours.isEmpty()) 
        {
            for (AH_Task_Business_Hours__c r : list_AH_TaskBusinessHours) 
            {
				recTypeSet.add(r.Name);
            }
        }
        
        // CREATE MAP {RECORD TYPE ID => RECORD TYPE NAME}
        Map<Id, String> rtMap = new Map<Id, String>();
        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.Task.getRecordTypeInfosByName();
        if (!recTypeSet.isEmpty()) 
        {
            for (String recType : recordTypesMap.keyset()) 
            {
                if (recTypeSet.contains(recType)) 
                {
                    Schema.RecordTypeInfo rr = recordTypesMap.get(recType);
                    rtMap.put(rr.getRecordTypeId(), recType);
                }
            }
        }
        
		// CREATE LIST OF TASKS TO PROCESS
        List<Task> validTasksToProcess = new List<Task>();
        for (Task t : newTrigger) 
        {
            if (rtMap.containsKey(t.RecordTypeId)) 
            {
                validTasksToProcess.add(t);
            }
        }
        
        // CALL calculateTurnAroundTimeNew METHOD TO CALCULATE TURN AROUND TIME
        if (!validTasksToProcess.isEmpty())
        {
            calculateTurnAroundTimeNew(newTrigger, oldMapTrigger);
        }  
        
    }
    
	public void OnAfterInsert(List<Task> newTrigger)
    {        
        
        if (bypassTrigger(newTrigger))
        {
            return;
        }        
        
        if (!NI_FUNCTIONS.bypassTriggerCode('TASK'))
        { 
            if (!NI_FUNCTIONS.bypassTriggerCode('CASE FLAGS'))
            {
                clearCaseFlag(newTrigger);
            }
            List<Task> lstValidTasks = new List<Task>();
            lstValidTasks = lstValidTasksToProcess(newTrigger);
            if (lstValidTasks.Size() > 0)
            {
                rollUpCallAndEmailCounts(lstValidTasks);
                // UpdateLastActivityDateOnCase(lstValidTasks);                
            }   
        }
    }
    
    public void OnAfterUpdate(List<Task> newTrigger, Map<Id, Task> oldMapTrigger)
    {
        
        if (bypassTrigger(newTrigger))
        {
            return;
        }        
        
        if (!NI_FUNCTIONS.bypassTriggerCode('TASK'))
        {
            if (!NI_FUNCTIONS.bypassTriggerCode('CASE FLAGS'))
            {  
                List<Task> tasksToProcessFurther = new List<Task>();
                for (Task t : newTrigger)
                {
                    Task oldTask = new Task();
                    oldTask = oldMapTrigger.get(t.Id);
                    if (t.Status != null && t.Status != oldTask.Status && t.Status == 'Completed')
                    {
                        tasksToProcessFurther.add(t);
                    }
                }
                
                if (!tasksToProcessFurther.isEmpty())
                {
                    clearCaseFlag(tasksToProcessFurther);
                }
            }
            //UpdateLastActivityDateOnCase(newTrigger);
        }
        
    }
    
    // =========================================================================
    //    FUNCTIONS ============================================================
    // ========================================================================= 
    
    private Boolean bypassTrigger(List<Task> newTrigger)
    {
        boolean bRetVal = false;
        for (Task tsk : newTrigger) 
        {
            if (tsk.Description != null && tsk.Description.contains(Label.AH_EmailServicesAddress)) 
            {
                bRetVal = true;
            }
        }
        return bRetVal;
    }     
    
    private void clearCaseFlag(List<Task> newTrigger)
    {
        
        system.debug('in Task clearCaseFlag => ' + newTrigger);

        // PREVENT AUTOMATION USERS FROM CLEARING FLAGS
//        if ((UserInfo.getUserId() == '00560000000yI7jAAE') || (UserInfo.getUserId() == '00532000005XHNIAA4'))
//        {
//            return;
//        }     
        
        List<Case> casesList = new List<Case>();
        Set<Id> caseIds = new Set<Id>();
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        List<String> selected_act_types = new List<String>();
        Map <String, String> MapSelectedActTypes = new Map <String, String>();
        AH_CaseFlagPreferences__c caseFlagCustomSetting = new AH_CaseFlagPreferences__c();
        caseFlagCustomSetting = AH_CaseFlagPreferences__c.getOrgDefaults();
        
        // GET ACTIVITY TYPES FOR WHICH CASE FLAG SHOULD BE CLEARED
        try
        {
            flagRecTypes = [SELECT Name, Enabled_Activity_Types__c, Clear_Case_Origins__c, Enabled_Case_Type__c            
                            FROM AH_Case_Flags_Store_Types__c
                            WHERE Name = 'Default' LIMIT 1];
            
            system.debug('flagRecTypes'+flagRecTypes);
            
            if (flagRecTypes.Enabled_Activity_Types__c != null)
            {
                selected_act_types = flagRecTypes.Enabled_Activity_Types__c.split(',');
            }
            else
            {
                selected_act_types.add('Call');
            }
            
            // CREATE A MAP OF ACTIVITY TYPES
            if (!selected_act_types.isEmpty())
            {
                for (String s : selected_act_types)
                {
                    MapSelectedActTypes.put(s, s);
                }
            }
        }
        catch (Exception e)
        {
            system.debug('e' + e.getMessage()); //DO NOTHING
        }

system.debug('===============================================');
        system.debug('    caseFlagCustomSetting.Clear_on_Activity__c = ' + caseFlagCustomSetting.Clear_on_Activity__c);
        system.debug('    UserInfo.getUserId() = ' + UserInfo.getUserId());

        // ITERATE OVER LIST OF TASKS TO CHECK WHETHER CASE FLAG SHOULD BE CLEARED OR NOT
        for (Task t : newTrigger)
        {
            
        system.debug('    t.Status = ' + t.Status);
        system.debug('    t.WhatId = ' + t.WhatId);
        system.debug('    t.Type = ' + t.Type);        
        system.debug('    t.Subject = ' + t.Subject);     
            
            if (caseFlagCustomSetting.Clear_on_Activity__c == true && 
                t.Status == 'Completed' && 
                t.WhatId != null && 
                String.ValueOf(t.WhatId).startsWith('500') && 
                MapSelectedActTypes.containsKey(t.Type))
            {

/*                
                boolean bIsValid = true;
                
                // DO NOT CLEAR FLAG IF USER = INTEGRATION USER & SUBJECT LIKE 'Email: Amadeus Hospitality Case'                
                if (UserInfo.getUserId() == '00560000000yI7jAAE' && t.Subject.startsWith('Email: Amadeus Hospitality Case')) 
                {
                    bIsValid = false;
                }
                
                // DO NOT CLEAR FLAG IF USER = CASE AUTOMATION USER & SUBJECT LIKE 'Email: Amadeus Hospitality Case'
                if (UserInfo.getUserId() == '00532000005XHNIAA4' && t.Subject.startsWith('Email: Amadeus Hospitality Case')) 
                {
                    bIsValid = false;
                }                
                
        system.debug('    SET CASE FLAG = ' + bIsValid);  
                
                if (bIsValid)
                {
                    caseIds.add(t.WhatId);
                }
*/                
                caseIds.add(t.WhatId);
                
            }
        }
        
system.debug('==============================================='); 
        
        // IF CASEIS SET IS NOT EMPTY GET THE LIST OF CASES AND PROCESS TO CLEAR FLAG
        if (!caseIds.isEmpty())
        {
            casesList = [SELECT Id, RecordTypeId, CaseNumber, BusinessHoursId, CreatedDate, AH_Flag__c, AH_Flag_BH__c, AH_Case_Flagged_Date__c, 
                         AH_Enable_Case_Flag__c, AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c,
                         AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c,
                         AH_Case_Flag_Business_Age__c, AH_Initial_response__c
                         FROM Case
                         WHERE Id IN :caseIds AND AH_Case_Flagged_Date__c != null
                        AND Status != 'New'];
system.debug('    casesList = ' + casesList);
            NI_Case_TriggerHandler caseHandler = new NI_Case_TriggerHandler();
            caseHandler.clearCaseFlagRelatedData(casesList, true, 'Task Completed');
        }
    }
    
    public void setOnHoldTime(List<Task> newTrigger)
    {
        for (Task t : newTrigger)
        {
            //if (t.Status == 'On Hold')
            if (t.Status == 'Awaiting Information')
            {
                t.On_Hold_Time__c = datetime.now();
            }
        }
    }
    
    public void calculateTurnAroundTimeNew(List<Task> newTrigger, Map<Id, Task> oldMapTrigger)
    {
        
        Set<Id> businessHoursSet = new Set<Id>();
        Map<Id, BusinessHours> businessHoursMap = new Map<Id, BusinessHours>();
        List<Task> tasksToProcessFurther = new List<Task>();
        
        for (Task t : newTrigger)
        {
            Task oldTask = oldMapTrigger.get(t.Id);
            if ((t.Status != oldTask.Status) && t.Business_Hours__c != null)
            {
                businessHoursSet.add(t.Business_Hours__c);
                tasksToProcessFurther.add(t);
            }
        }
        
        if (!businessHoursSet.isEmpty())
        {
            businessHoursMap = new Map<Id,BusinessHours>([SELECT Id, Name, MondayStartTime, MondayEndTime
                                                          FROM BusinessHours
                                                          WHERE Id IN : businessHoursSet]);
        }
        
        for (Task t : tasksToProcessFurther)
        {
            system.debug('t' + t);
            Datetime nowDateTime = datetime.now();
            Datetime createdDateTime = t.CreatedDate;
            //Datetime lastModifiedDate = t.LastModifiedDate;
            
            if (businessHoursMap.containsKey(t.Business_Hours__c))
            {
                BusinessHours bh = businessHoursMap.get(t.Business_Hours__c);
                Long workingHours = bh.MondayEndTime.hour() - bh.MondayStartTime.hour();
                Task oldTaskk = oldMapTrigger.get(t.Id);
                
                //if(t.Status != oldTaskk.Status && t.Status == 'On Hold'){
                //if (t.Status == 'On Hold')
                if (t.Status == 'Awaiting Information')
                {
                    t.On_Hold_Time__c = datetime.now();
                }
                
                //if(t.Status != oldTaskk.Status){
                //if (oldTaskk.Status == 'On Hold' && t.Status != 'On Hold')
                if (oldTaskk.Status == 'Awaiting Information' && t.Status != 'Awaiting Information')
                {
                    String onHoldTaskTimee = calculateBusinessHours(bh, t.On_Hold_Time__c, nowDateTime);
                    system.debug('onHoldTaskTimee'+onHoldTaskTimee);
                    if (oldTaskk.Store_On_Hold_Task_Time__c != '' && oldTaskk.Store_On_Hold_Task_Time__c != null)
                    {
                        String oldOnHoldTaskTime  = t.Store_On_Hold_Task_Time__c;
                        system.debug('oldOnHoldTaskTime'+oldOnHoldTaskTime);
                        //String s = addDaysOrHours(oldOnHoldTaskTime, onHoldTaskTimee, workingHours);
                        String s = addOrSubtractDaysOrHours(oldOnHoldTaskTime, onHoldTaskTimee, workingHours, 'add');
                        system.debug('s' + s);
                        t.Store_On_Hold_Task_Time__c = s;
                    }
                    else
                    {
                        system.debug('in else');
                        t.Store_On_Hold_Task_Time__c = onHoldTaskTimee;
                    }
                }
                
                system.debug('t.Store_On_Hold_Task_Time__c'+t.Store_On_Hold_Task_Time__c);
                
                if (t.Status == 'Completed')
                {
                    //String k3 = calculateBusinessHours(bh, createdDateTime,nowDateTime);
                    String totakTaskTime = calculateBusinessHours(bh, createdDateTime, nowDateTime);
                    system.debug('totakTaskTime' + totakTaskTime);
                    if (t.Store_On_Hold_Task_Time__c != '' && t.Store_On_Hold_Task_Time__c != null)
                    {
                        String onHoldTaskTime  = t.Store_On_Hold_Task_Time__c;
                        //String totakTaskTime = calculateBusinessHours(bh, createdDateTime,nowDateTime);
                        //String s = subtractDaysOrHours(onHoldTaskTime, totakTaskTime, workingHours);
                        String s = addOrSubtractDaysOrHours(onHoldTaskTime, totakTaskTime, workingHours, 'subtract');
                        system.debug('s' + s);
                        t.Total_Task_Time__c = s;
                        t.On_Hold_Task_Time__c = t.Store_On_Hold_Task_Time__c;
                        
                    }
                    else
                    {
                        system.debug('in last else');
                        //String totakTaskTime = calculateBusinessHours(bh, createdDateTime,nowDateTime);
                        system.debug('totakTaskTime'+totakTaskTime);
                        t.Total_Task_Time__c = totakTaskTime;
                        if (t.Store_On_Hold_Task_Time__c != null && t.Store_On_Hold_Task_Time__c != '')
                        {
                            t.On_Hold_Task_Time__c = t.Store_On_Hold_Task_Time__c;
                        }
                        
                    }
                }
                
            }
        }
    }    

    public String calculateBusinessHours(BusinessHours bh, DateTime strDate, DateTime endDate)
    {
        Double finalValue = 0.0;
        Long workingHours = bh.MondayEndTime.hour() - bh.MondayStartTime.hour();
        if (strDate != null && endDate != null)
        {
            finalValue = BusinessHours.diff(bh.Id, strDate, endDate);
        }
            
system.debug('finalValue' + finalValue);
        finalValue = finalValue/3600000;
       
system.debug('finalValue'+finalValue);
        String s = '';
        if (finalValue > workingHours)
        {
            finalValue = (finalValue / workingHours);
            //finalValue = finalValue;
system.debug('finalValue' + finalValue);
            s = ' days';
        }
        if (s == '')
        {
            s = ' hours';
        }
        Decimal d = Decimal.ValueOf(finalValue);
        d = d.setScale(2);
        String returnString = d + s;
system.debug('d' + d);
        return returnString;
    }
    
    public String addOrSubtractDaysOrHours(String onHoldTaskTime, String totakTaskTime, Long workingHours, String op)
    {
        String returnValue = '';
        
        Double onHoldTimeValue = Double.valueOf(onHoldTaskTime.substringBefore(' '));
system.debug('onHoldTimeValue'+onHoldTimeValue);
        String unitOfTime = String.valueOf(onHoldTaskTime.substringAfter(' '));
system.debug('unitOfTime'+unitOfTime);
        
        //String totakTaskTime = calculateBusinessHours(bh, createdDateTime,nowDateTime);
        Double totakTaskTimeValue = Double.valueOf(totakTaskTime.substringBefore(' '));
system.debug('totakTaskTimeValue'+totakTaskTimeValue);
        String unitOfTime2 = String.valueOf(totakTaskTime.substringAfter(' '));
system.debug('unitOfTime2' + unitOfTime2);
        
        //String finalValue = '';
        if (unitOfTime == unitOfTime2)
        {
            if (op == 'add')
            {
                totakTaskTimeValue = totakTaskTimeValue + onHoldTimeValue;
            }
            else if (op == 'subtract')
            {
                totakTaskTimeValue = totakTaskTimeValue - onHoldTimeValue;
            }
            Decimal d = Decimal.ValueOf(totakTaskTimeValue);
            d = d.setScale(2);
            returnValue = d + ' ' + unitOfTime;
        }
        else 
        {
            if (unitOfTime == 'hours' && unitOfTime2 == 'days')
            {
                totakTaskTimeValue = totakTaskTimeValue*workingHours;
                if (op == 'add')
                {
                    totakTaskTimeValue = totakTaskTimeValue + onHoldTimeValue;
                }
                if (op == 'subtract')
                {
                    totakTaskTimeValue = totakTaskTimeValue - onHoldTimeValue;
                }
            }
            if (unitOfTime == 'days' && unitOfTime2 == 'hours')
            {
                onHoldTimeValue = onHoldTimeValue*workingHours;
                if (op == 'add')
                {
                    totakTaskTimeValue = totakTaskTimeValue + onHoldTimeValue;
                }
                if (op == 'subtract')
                {
                    totakTaskTimeValue = totakTaskTimeValue - onHoldTimeValue;
                }
            }
            String s = '';
            if (totakTaskTimeValue > workingHours)
            {
                totakTaskTimeValue=totakTaskTimeValue/workingHours;
system.debug('totakTaskTimeValue'+totakTaskTimeValue);
                s = ' days';
            }
            if (s == '')
            {
                s = ' hours';
            }
            Decimal d = Decimal.ValueOf(totakTaskTimeValue);
            d = d.setScale(2);
            returnValue = d + s;
        }
        
        return returnValue;
        
    }
   
    private List<Task> lstValidTasksToProcess (List<Task> newTrigger)
    {
        
        // LIST OF VALID TASK TO BE RETURNED 
        List<Task> retLst = new List<Task>();
        
        // GET ALL VALID TASK RECORD TYPE NAMES FROM CUSTOM SETTING
        WinaproachIncidentSettings__c wcsRecordTypes = WinaproachIncidentSettings__c.getValues('Default'); 
        
        // IF NO RECORD TYPE NAMES FROM CUSTOM SETTING FOUND RETURN 0 SIZED TASK LIST
        if (wcsRecordTypes == null) {return retLst;}
        
        // PARSE RECORD TYPE NAMES FROM CUSTOM SETTING INTO LIST
        List<String> lstRecordtypes = String.valueOf(wcsRecordTypes.Task_Record_Type__c).split(',');
        
        // SET TO HOLD TASK RECORD TYPE IDS 
        Set<Id> setRecordTypeIds = new Set<Id>();

        // UPDATED BY SHASHIKANT FOR OPTIMIZATION on 04/26/2018
        // LOOP THROUGH TASK RECORD TYPES TO ASSIGN IDS TO SET 
        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.Task.getRecordTypeInfosByName();

        for (String recType : lstRecordtypes)
        {
            if (recordTypesMap.containsKey(recType)) 
            {
                Schema.RecordTypeInfo rr = recordTypesMap.get(recType);
                setRecordTypeIds.Add(rr.getRecordTypeId());
            }
        }
        
        for (Task t : newTrigger)
        {
            // IF TASK IS --NOT-- OF A WIN@PROACH / SERVICE NOW INTEGRATION RECORD TYPE 
            if (!setRecordTypeIds.contains(t.RecordTypeId))
            {
                retLst.Add(t);
            }
        }
        
        return retLst;
        
    }    
    
    // THIS FUNCTION INCREMENTS 2 FIELDS ON RELATED CASE OBJECT CALLED: Number_of_Calls__c & Number_of_Emails_Sent__c 
    // WHEN A LOG A CALL OR EMAIL TASK IS CREATED WITH A RECORD TYPE OF: 'NI Support'
    private void rollUpCallAndEmailCounts(List<Task> newTrigger)
    {
        
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'Task'
                         AND Name = 'NI Support' AND isActive = true];

        // COLLECT UNIQUE CASE IDS AND TASKS WHEN TASK RECORD TYPE IS VALID
        List<Task> lstSupportTasks = new List<Task>();
        Set<Id> setCaseIds = new Set<Id>();
        
        for (Task tsk : newTrigger)
        {
            if (tsk.RecordTypeId == rt.Id)
            {
                lstSupportTasks.Add(tsk);
                setCaseIds.Add(tsk.WhatId);
            }
        }
        
        // USE MAP OF CASES TO INCREMENT Number_of_Calls__c, Number_of_Emails_Sent__c VALUES LATER IN LOOP THROUGH VALID TASKS 
        // MAP IS USED IN FINAL UPDATE COMMIT
        Map<Id, Case> mapCases = new Map<Id, Case>([SELECT Id, Number_of_Calls__c, Number_of_Emails_Sent__c, Status FROM Case WHERE Id IN : setCaseIds]); 
        
        for (Task t : lstSupportTasks)
        {
            // IF THE CURRENT TASK'S CASE ID IS FOUND IN MAP 
            if (mapCases.containsKey(t.WhatId))
            {   
                // LOG A CALL TASK CONDITIONS
                if ((t.Type.Contains('Call')) || (t.Type.Contains('Left Message')))
                {
                    if (mapCases.get(t.WhatId).Number_of_Calls__c == null)
                    {
                        mapCases.get(t.WhatId).Number_of_Calls__c = 1;
                    }
                    else
                    {
                        mapCases.get(t.WhatId).Number_of_Calls__c += 1;
                    } 
                    // TO PREVENT VALIDATION RULE ISSUE 
                    if (mapCases.get(t.WhatId).Status == 'New')
                    {
                        mapCases.get(t.WhatId).Status = 'Working';
                    }
                }
            }           
        }
  
        // IF THERE ARE ANY CASES TO UPDATE, COMMIT
        if (mapCases.Size() > 0)
        {
            update mapCases.values();
        }
        
    }

}