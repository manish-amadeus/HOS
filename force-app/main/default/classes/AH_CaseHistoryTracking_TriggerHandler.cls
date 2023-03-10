/****************************************************************************************
Name            : AH_CaseHistoryTracking_TriggerHandler Class
Author          : Cybage Developer - Ria Chawla
Created Date    : 01/15/2018
Last Mod Date   : 04/18/2018
Last Mod By     : Cybage Developer - Ria Chawla
NICC Reference  : NICC-026092
Description     : Handler class for AH_Case_Flags_History_Tracking__c object
                :
				:
*****************************************************************************************/
public class AH_CaseHistoryTracking_TriggerHandler 
{
    //METHOD CALLED ON BEFORE INSERT
    public void onBeforeInsert(List<AH_Case_Flags_History_Tracking__c> newTrigger)
    {
        if (!NI_FUNCTIONS.bypassTriggerCode('CASE FLAGS'))
        {  
            caseFlagsOBeforeInsert(newTrigger);
        } 
    }
    
    // PRIVATE METHOD TO SET START TIME AND BUSINESS HOURS OF THE CASE REMAINED IN EACH VOLOURED FLAG
    private void caseFlagsOBeforeInsert(List<AH_Case_Flags_History_Tracking__c> newTrigger)
    {
        //VARIABLES
        Set<Id> caseIdSet = new Set<Id>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        List<AH_Case_Flags_History_Tracking__c> prevhistoryTrackList = new List<AH_Case_Flags_History_Tracking__c>();
        List<AH_Case_Flags_History_Tracking__c> prevhistoryTrackList2 = new List<AH_Case_Flags_History_Tracking__c>();
        Map<Id, AH_Case_Flags_History_Tracking__c> prevHistoryRecMap = new Map<Id, AH_Case_Flags_History_Tracking__c>();
        List<AggregateResult> prevAgeHours = new List<AggregateResult>();
        List<AggregateResult> maxEndDateFS = new List<AggregateResult>();
        List<AggregateResult> caseHistoryNumber = new List<AggregateResult>();
        Map<Id, Decimal> mapOfAge1Hours = new Map<Id, Decimal>();
        Map<Id, Decimal> mapOfAge2Hours = new Map<Id, Decimal>();
        Map<Id, Decimal> mapOfAge3Hours = new Map<Id, Decimal>();
        Map<Id, Decimal> mapOfBSAge1Hours = new Map<Id, Decimal>();
        Map<Id, Decimal> mapOfBSAge2Hours = new Map<Id, Decimal>();
        Map<Id, Decimal> mapOfBSAge3Hours = new Map<Id, Decimal>();
        Map<Id, Datetime> maxEndDateFSMap = new Map<Id, Datetime>();
        Map<Id, Integer> hisNumberMap = new Map<Id, Integer>();
        
        //ITERATE OVER NEWLY INSERTED RECORDS TO GET CASE ID
        for (AH_Case_Flags_History_Tracking__c historyObj : newTrigger)
        {
            if (historyObj.Case__c != null)
            {
                caseIdSet.add(historyObj.Case__c);
            }
        }
        
        //IF CASE ID SET IS NOT EMPTY
        if (!caseIdSet.isEmpty())
        {
            //GET DETAILS FROM CASE
            caseMap = new Map<Id, Case>([SELECT Id, BusinessHoursId, CaseNumber, AH_Flag__c, AH_Flag_BH__c, AH_Case_Flagged_Date__c, 
                                         AH_Enable_Case_Flag__c, AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c,
                                         AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c,
                                         AH_Case_Flag_Business_Age__c, CreatedDate
                                         FROM Case
                                         WHERE Id IN :caseIdSet]);
            
            //GET DETAILS OF PREVIOUS HISTORY TRACKING RECORDS
            prevhistoryTrackList = [SELECT Id, Flag_Set__c, Start__c, End_Date_Time__c, Case__c, Hours_Elapsed__c, Hours_Offset__c,
                                    Event__c, Business_Hours_Offset__c, Business_Hours_Elapsed__c, Hours_in_Age_1__c,
                                    Hours_in_Age_2__c, Hours_in_Age_3__c, Hours_in_Age_4__c, Business_Hours_in_Age_1__c,
                                    Business_Hours_in_Age_2__c, Business_Hours_in_Age_3__c, Business_Hours_in_Age_4__c
                                    FROM AH_Case_Flags_History_Tracking__c 
                                    WHERE Case__c IN :caseIdSet
                                    ORDER BY End_Date_Time__c DESC];
            
system.debug('prevhistoryTrackList'+prevhistoryTrackList);
            /*caseHistoryNumber = [SELECT Count(ID) cnt, Case__c 
                                 FROM AH_Case_Flags_History_Tracking__c
                                 WHERE Case__c IN :caseIdSet GROUP BY Case__c];
            
            for (AggregateResult hisNumber : caseHistoryNumber)
            {
                hisNumberMap.put((ID)hisNumber.get('Case__c'), (Integer) hisNumber.get('cnt'));
            }*/
            
            Map<Id, AH_Case_Flags_History_Tracking__c> prevHisMap = new Map<Id, AH_Case_Flags_History_Tracking__c>(); 
            
            //GET MAXIMUM END DATE OF HISTORY TRACKING RECORD WHOSE EVENT WAS FLAG SET IN ORDER TO CONSIDER
            //HISTORY TRACKING RECORDS AFTER THIS DATE
            maxEndDateFS = [SELECT Max(End_Date_Time__c) endDateFS, Case__c
                            FROM AH_Case_Flags_History_Tracking__c
                            WHERE Case__c IN :caseIdSet
                            AND Event__c = 'Flag Set' GROUP BY Case__c];
            
            //ITERATE OVER AGGREGATE RESULT AND PUT IN A MAP
            for (AggregateResult agr : maxEndDateFS)
            {
                maxEndDateFSMap.put((ID)agr.get('Case__c'), (DateTime) agr.get('endDateFS'));
            }
            
            // THIS IS TO SUM UP ALL THE HOURS OF PREVIOUSLY INSERTED HISTORY TRACKING RECORDS
            for (AH_Case_Flags_History_Tracking__c ahHT : prevhistoryTrackList)
            {
                //IN ORDER TO CONSIDER RECORDS AFTER THE FLAGGED DATE OF CASE WAS SET
                DateTime minDateToConsider;
                Case myCase = caseMap.get(ahHT.Case__c);
                
                if (prevHisMap.containsKey(ahHT.Case__c))
                {
                    AH_Case_Flags_History_Tracking__c obj = prevHisMap.get(ahHT.Case__c);
                    if (obj.End_Date_Time__c < ahHT.End_Date_Time__c)
                    {
                        prevHisMap.put(ahHT.Case__c, ahHT);
                    }
                }
                else
                {
                    prevHisMap.put(ahHT.Case__c, ahHT);
                }
                
                if (myCase.AH_Case_Flagged_Date__c != null)
                {
                    minDateToConsider = myCase.AH_Case_Flagged_Date__c;
                }
                else 
                {
                    if(!maxEndDateFSMap.isEmpty())
                    {
                        if(maxEndDateFSMap.containsKey(ahHT.Case__c))
                        {
                            minDateToConsider = maxEndDateFSMap.get(ahHT.Case__c);
                        }
                    }                    
                }
                
system.debug('ahHT.Start__c'+ahHT.Start__c);
system.debug('minDateToConsider'+minDateToConsider);
                
                if (ahHT.Start__c >= minDateToConsider && ahHT.Flag_Set__c == true)
                {
                    
                    if (mapOfAge1Hours.get(ahHT.Case__c) != null)
                    {
                        Decimal k = 0.0;
                        k = mapOfAge1Hours.get(ahHT.Case__c);
                        k = k + ahHT.Hours_in_Age_1__c;
                        mapOfAge1Hours.put(ahHT.Case__c, k);
                    }
                    else
                    {
                        mapOfAge1Hours.put(ahHT.Case__c, ahHT.Hours_in_Age_1__c);
                    }
                    
                    if (mapOfAge2Hours.get(ahHT.Case__c) != null)
                    {
                        Decimal k = mapOfAge2Hours.get(ahHT.Case__c);
                        k = k + ahHT.Hours_in_Age_2__c;
                        mapOfAge2Hours.put(ahHT.Case__c, k);
                    }
                    else
                    {
                        mapOfAge2Hours.put(ahHT.Case__c, ahHT.Hours_in_Age_2__c);
                    }
                    
                    if (mapOfAge3Hours.get(ahHT.Case__c) != null)
                    {
                        Decimal k = mapOfAge3Hours.get(ahHT.Case__c);
                        k = k + ahHT.Hours_in_Age_3__c;
                        mapOfAge3Hours.put(ahHT.Case__c, k);
                    }
                    else
                    {
                        mapOfAge3Hours.put(ahHT.Case__c, ahHT.Hours_in_Age_3__c);
                    }
                    
                    if (mapOfBSAge1Hours.get(ahHT.Case__c) != null)
                    {
                        Decimal k = mapOfBSAge1Hours.get(ahHT.Case__c);
                        k = k + ahHT.Business_Hours_in_Age_1__c;
                        mapOfBSAge1Hours.put(ahHT.Case__c, k);
                    }
                    else
                    {
                        mapOfBSAge1Hours.put(ahHT.Case__c, ahHT.Business_Hours_in_Age_1__c);
                    }
                    
                    if (mapOfBSAge2Hours.get(ahHT.Case__c) != null)
                    {
                        Decimal k = mapOfBSAge2Hours.get(ahHT.Case__c);
                        k = k + ahHT.Business_Hours_in_Age_2__c;
                        mapOfBSAge2Hours.put(ahHT.Case__c, k);
                    }
                    else
                    {
                        mapOfBSAge2Hours.put(ahHT.Case__c, ahHT.Business_Hours_in_Age_2__c);
                    }
                    
                    if (mapOfBSAge3Hours.get(ahHT.Case__c) != null)
                    {
                        Decimal k = mapOfBSAge3Hours.get(ahHT.Case__c);
                        k = k + ahHT.Business_Hours_in_Age_3__c;
                        mapOfBSAge3Hours.put(ahHT.Case__c, k);
                    }
                    else
                    {
                        mapOfBSAge3Hours.put(ahHT.Case__c, ahHT.Business_Hours_in_Age_3__c);
                    }
                    
                }
                
            }
            
            //GET MAXIMUM END DATE OF PREVIOUSLY INSERTED RECORD, TO SET START DATE OF NEWLY INSERTED RECORD
            List<AggregateResult> prevHisTrackingEndDate = new List<AggregateResult>();
            prevHisTrackingEndDate = [SELECT max(End_Date_Time__c) prevEndDate, Case__c caseC
                                      FROM AH_Case_Flags_History_Tracking__c
                                      WHERE Case__c IN :caseIdSet
                                      GROUP BY Case__c];
            
            Map<Id, Datetime> caseEndDateMap = new Map<Id, DateTime>();
            
            for (AggregateResult agr : prevHisTrackingEndDate)
            {
                caseEndDateMap.put((Id)agr.get('caseC'), (Datetime)agr.get('prevEndDate'));
            }
            
            for (AH_Case_Flags_History_Tracking__c prevTrackList : prevhistoryTrackList)
            {
                prevHistoryRecMap.put(prevTrackList.Case__c, prevTrackList);
            }
            
            
            for (AH_Case_Flags_History_Tracking__c historyObj : newTrigger)
            {
                Integer countOfFlagCleared = 0;
                Case cs = caseMap.get(historyObj.Case__c);
                AH_Case_Flags_History_Tracking__c prevHistoryRec = new AH_Case_Flags_History_Tracking__c();
                
                prevHistoryRec = prevHisMap.get(historyObj.Case__c);
                
                if (historyObj.Event__c == 'Flag Set' || prevHistoryRec == null || prevHistoryRec.Event__c == 'Flag Set')
                {
                    mapOfAge1Hours.put(historyObj.Case__c, 0.0);
                    mapOfAge2Hours.put(historyObj.Case__c, 0.0);
                    mapOfAge3Hours.put(historyObj.Case__c, 0.0);
                    mapOfBSAge1Hours.put(historyObj.Case__c, 0.0); 
                    mapOfBSAge2Hours.put(historyObj.Case__c, 0.0);
                    mapOfBSAge3Hours.put(historyObj.Case__c, 0.0);
                }
                
// SMH (START)                
                Decimal age1 = 0;
                Decimal age2 = 0;
                Decimal age3 = 0;
                Decimal age4 = 0;
                
                if (historyObj.Case_Flags_Age_1_Hours__c != null)
                {
                    age1 = historyObj.Case_Flags_Age_1_Hours__c;
                }
                
                if (historyObj.Case_Flags_Age_2_Hours__c != null)
                {
                    age2 = historyObj.Case_Flags_Age_2_Hours__c;
                }
                
                if (historyObj.Case_Flags_Age_3_Hours__c != null)
                {
                    age3 = historyObj.Case_Flags_Age_3_Hours__c;
                }
                
                if (historyObj.Case_Flags_Age_4_Hours__c != null)
                {
                    age4 = historyObj.Case_Flags_Age_4_Hours__c;
                }        
// SMH (END)                  
                
                Decimal actualAge1 = age2 - age1;
                Decimal actualAge2 = age3 - age2;
                Decimal actualAge3 = age4 - age3;
                
                if (historyObj.Business_Hours__c == null)
                {
                    historyObj.Business_Hours__c = cs.BusinessHoursId;
                }
                
                if (!caseEndDateMap.isEmpty() && historyObj.Start__c == null)
                {
system.debug('in if');
                    if (caseEndDateMap.get(cs.Id) != null)
                    {
                        historyObj.Start__c = caseEndDateMap.get(cs.Id);
                    }
                }
                else 
                {
                    if (caseEndDateMap.isEmpty() && historyObj.Start__c == null)
                    {
                        historyObj.Start__c = cs.CreatedDate;
                    }                    
                    else 
                    {
                        if (historyObj.Start__c == null)
                        {
system.debug('in else');
                            historyObj.Start__c = Datetime.now();
                        }
                    }
                }
                
                if (cs.AH_Case_Flagged_Date__c != null || historyObj.Event__c == 'Flag Cleared')
                {
                    historyObj.Flag_Set__c = true;
                }
                
                if (historyObj.Event__c == 'Flag Set')
                {
                    historyObj.Flag_Set__c = FALSE;
                }
                
                // STANDARD HOURS
                Decimal nowTime = DateTime.now().getTime();
                Decimal startTime = historyObj.Start__c.getTime();
                Decimal hoursElapsed = nowTime - startTime;          
                hoursElapsed = hoursElapsed / (60*60*1000);
                
                // BUSINESS HOURS
                Decimal bsHours = BusinessHours.diff(historyObj.Business_Hours__c, historyObj.Start__c, DateTime.now());
                bsHours = bsHours / (60*60*1000);
                
                historyObj.Hours_Elapsed__c = hoursElapsed;
                historyObj.Business_Hours_Elapsed__c = bsHours;

                //IF PREVIOUS HISTORY TRACKING RECORD IS NOT FLAG SET, AND NOW'S IS ALSO NOT FLAG SET THEN SET OFFSET HOURS
                if (historyObj.Flag_Set__c == true)
                {
                    if (prevHistoryRec != null)
                    {
system.debug('prevHistoryRec.Hours_Elapsed__c'+prevHistoryRec.Hours_Elapsed__c);
system.debug('prevHistoryRec.Hours_Offset__c'+prevHistoryRec.Hours_Offset__c);
system.debug('age1'+age1);
                        if (prevHistoryRec.Event__c != 'Flag Set' && historyObj.Event__c != 'Flag Set')
                        {
                            historyObj.Hours_Offset__c = prevHistoryRec.Hours_Elapsed__c+ prevHistoryRec.Hours_Offset__c;
                            historyObj.Business_Hours_Offset__c = prevHistoryRec.Business_Hours_Elapsed__c+ prevHistoryRec.Business_Hours_Offset__c;
                        }
                    }
                }
                
system.debug('mapOfAge1Hours'+mapOfAge1Hours);
system.debug('mapOfAge2Hours'+mapOfAge2Hours);
system.debug('mapOfAge3Hours'+mapOfAge3Hours);
                
                //SETTING EACH FLAG'S AGE IN HOURS, WE NEED TO CONSIDER THEIR TIME IN PREVIOUS HISTORY TRACKING RECORDS
                if (hoursElapsed > 0.00)
                {
                    if (!mapOfAge1Hours.isEmpty())
                    {
system.debug('not empty');
                        Decimal prevAge1 = 0.0;
                        prevAge1 = mapOfAge1Hours.get(historyObj.Case__c);
                        
system.debug('prevAge1'+prevAge1);
system.debug('countOfFlagCleared'+countOfFlagCleared);
system.debug('actualAge1'+actualAge1);
                        
                        if (prevAge1 < actualAge1)
                        {
                            Decimal lessBy1 =  actualAge1 - prevAge1;
                            if (hoursElapsed > lessBy1)
                            {
                                hoursElapsed  = hoursElapsed - lessBy1;
                                historyObj.Hours_in_Age_1__c = lessBy1;
                            }
                            else
                            {
                                historyObj.Hours_in_Age_1__c = hoursElapsed;
                                hoursElapsed = 0.00;
                            }
                        }
                    }
                    
                    if (hoursElapsed > 0.00)
                    {
                        if (!mapOfAge2Hours.isEmpty())
                        {
                            Decimal prevAge2 = mapOfAge2Hours.get(historyObj.Case__c);
                            if (prevAge2 < actualAge2)
                            {
                                Decimal lessBy2 = actualAge2 - prevAge2;
                                if (hoursElapsed > lessBy2)
                                {
                                    hoursElapsed  = hoursElapsed - lessBy2;
                                    historyObj.Hours_in_Age_2__c = lessBy2;
                                }
                                else
                                {
                                    historyObj.Hours_in_Age_2__c = hoursElapsed;
                                    hoursElapsed = 0.00;
                                }
                            }
                        }
                    }
                    
                    if (hoursElapsed > 0.00)
                    {
                        if (!mapOfAge3Hours.isEmpty())
                        {
                            Decimal prevAge3 = mapOfAge3Hours.get(historyObj.Case__c);
                            if (prevAge3 < actualAge3)
                            {
                                
                                Decimal lessBy3 =  actualAge3 - prevAge3;
                                
                                if (hoursElapsed > lessBy3)
                                {
                                    hoursElapsed  = hoursElapsed - lessBy3;
                                    historyObj.Hours_in_Age_3__c = lessBy3;
                                }
                                else
                                {
                                    historyObj.Hours_in_Age_3__c = hoursElapsed;
                                    hoursElapsed = 0.00;
                                }
                            }
                        }
                    }
                    
                    if (hoursElapsed > 0.00)
                    {
                        historyObj.Hours_in_Age_4__c = hoursElapsed;
                    }
                    
                }
                
                if (bsHours > 0.00)
                {   
                    if (!mapOfBSAge1Hours.isEmpty())
                    {
                        Decimal prevBsAge1 = 0.0;
                        
                        prevBsAge1 = mapOfBSAge1Hours.get(historyObj.Case__c);
                        
system.debug('prevAge1'+prevBsAge1);
system.debug('countOfFlagCleared'+countOfFlagCleared);
system.debug('actualAge1'+actualAge1);
                        
                        if (prevBsAge1 < actualAge1)
                        {
                            
                            Decimal lessByBs1 = actualAge1 - prevBsAge1;
                            if(bsHours > lessByBs1)
                            {
                                bsHours  = bsHours - lessByBs1;
                                historyObj.Business_Hours_in_Age_1__c = lessByBs1;
                            }
                            else
                            {
                                historyObj.Business_Hours_in_Age_1__c = bsHours;
                                bsHours = 0.00;
                            }
                        }
                    }
                    
                    if (bsHours > 0.00)
                    {
                        if (!mapOfBSAge2Hours.isEmpty())
                        {
                            Decimal prevBsAge2 = mapOfAge2Hours.get(historyObj.Case__c);
                            
                            if (prevBsAge2 < actualAge2)
                            {
                                
                                Decimal lessByBs2 = actualAge2 - prevBsAge2;
                                
                                if (bsHours > lessByBs2)
                                {
                                    bsHours  = bsHours - lessByBs2;
                                    historyObj.Business_Hours_in_Age_2__c = lessByBs2;
                                }
                                else
                                {
                                    historyObj.Business_Hours_in_Age_2__c = bsHours;
                                    bsHours = 0.00;
                                }
                            }
                        }
                    }
                    
                    if (bsHours > 0.00)
                    {
                        if (!mapOfBSAge3Hours.isEmpty())
                        {
                            Decimal prevBsAge3 = mapOfAge3Hours.get(historyObj.Case__c);
                            
                            if (prevBsAge3 < actualAge3)
                            {
                                
                                Decimal lessByBs3 = actualAge3 - prevBsAge3;
                                
                                if (bsHours > lessByBs3)
                                {
                                    bsHours  = bsHours - lessByBs3;
                                    historyObj.Business_Hours_in_Age_3__c = lessByBs3;
                                }
                                else
                                {
                                    historyObj.Business_Hours_in_Age_3__c = bsHours;
                                    bsHours = 0.00;
                                }
                            }
                        }
                    }
                    
                    if (bsHours > 0.00)
                    {
                        historyObj.Business_Hours_in_Age_4__c = bsHours;
                    }
                    
                }
                
                if (historyObj.End_Date_Time__c == null)
                {
                    historyObj.End_Date_Time__c = DateTime.now();
                }
                
            }
        }
        
    }
    
    
}