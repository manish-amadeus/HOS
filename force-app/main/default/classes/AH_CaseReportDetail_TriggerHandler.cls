/************************************************************************************************
Name            : AH_CaseReportDetail_TriggerHandler
Author          : Sean Harris
Created Date    : 02/05/2021 
Last Mod Date   : 02/05/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class that handles all trigger code for the AH_Case_Report_Detail__c Object
                : 
                : 
*************************************************************************************************/
public class AH_CaseReportDetail_TriggerHandler 
{
    
    // VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING 
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}

    
    public AH_CaseReportDetail_TriggerHandler()
    {        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();                
    }

    // ======================================================================================================================== 
    //  ENTRY METHODS 
    // ========================================================================================================================     
    public void OnAfterInsert(List<AH_Case_Report_Detail__c> newTrigger)
    {  
        if (!bpSwitch.BypassCaseReportDetail_ON__c)
        {           
            prepRollup(newTrigger);
        }
    }
    
    public void OnAfterUpdate(List<AH_Case_Report_Detail__c> newTrigger, Map<Id, AH_Case_Report_Detail__c> oldMapTrigger)
    {   
        if (!bpSwitch.BypassCaseReportDetail_ON__c)
        {   
            prepRollup(newTrigger);
        }
    }
    
    private void prepRollup(List<AH_Case_Report_Detail__c> newTrigger)
    {
        Set<Id> setCaseIds = new Set<Id>();
        for (AH_Case_Report_Detail__c cd1 : newTrigger)
        {
            setCaseIds.add(cd1.Case__c);
        }
		rollupTimeSums(setCaseIds);
    }
    
    //@future
    private static void rollupTimeSums(Set<Id> setCaseIds)
    {

        List<AggregateResult> lstL1T1s = new List<AggregateResult>(
            [SELECT Case__c, SUM(Time_Elapsed__c) TimeElapsed 
             FROM AH_Case_Report_Detail__c 
             WHERE Case__c IN : setCaseIds 
             AND Old_Value__c = 'Level 1 Support Tier 1'
             GROUP BY Case__c]);
        
        List<AggregateResult> lstL1T2s = new List<AggregateResult>(
            [SELECT Case__c, SUM(Time_Elapsed__c) TimeElapsed 
             FROM AH_Case_Report_Detail__c 
             WHERE Case__c IN : setCaseIds 
             AND Old_Value__c = 'Level 1 Support Tier 2'
             GROUP BY Case__c]);
        
        List<AggregateResult> lstL1T3s = new List<AggregateResult>(
            [SELECT Case__c, SUM(Time_Elapsed__c) TimeElapsed 
             FROM AH_Case_Report_Detail__c 
             WHERE Case__c IN : setCaseIds 
             AND Old_Value__c = 'Level 1 Support Tier 3'
             GROUP BY Case__c]);
        
        List<AggregateResult> lstL1s = new List<AggregateResult>(
            [SELECT Case__c, SUM(Time_Elapsed__c) TimeElapsed 
             FROM AH_Case_Report_Detail__c 
             WHERE Case__c IN : setCaseIds 
             AND Old_Value__c LIKE 'Level 1 Support%'
             GROUP BY Case__c]); 
        
        List<AggregateResult> lstL2s = new List<AggregateResult>(
            [SELECT Case__c, SUM(Time_Elapsed__c) TimeElapsed 
             FROM AH_Case_Report_Detail__c 
             WHERE Case__c IN : setCaseIds 
             AND Old_Value__c = 'Level 2 Support'
             GROUP BY Case__c]); 
        
        List<AggregateResult> lstCons = new List<AggregateResult>(
            [SELECT Case__c, SUM(Time_Elapsed__c) TimeElapsed 
             FROM AH_Case_Report_Detail__c 
             WHERE Case__c IN : setCaseIds 
             AND Old_Value__c = 'Contractor'
             GROUP BY Case__c]);
        
        List<AggregateResult> lstTotals = new List<AggregateResult>(
            [SELECT Case__c, SUM(Time_Elapsed__c) TimeElapsed 
             FROM AH_Case_Report_Detail__c 
             WHERE Case__c IN : setCaseIds
             GROUP BY Case__c]);

        List<Case> lstCaseUpdates = new List<Case>([SELECT Id, L1T1_Time__c, L1T2_Time__c, L1T3_Time__c, L1_Time__c, L2T1_Time__c, Contractor_Time__c, Total_Work_Time__c FROM Case WHERE Id IN : setCaseIds]);

        for (Case c : lstCaseUpdates)
        {
            
            c.L1T1_Time__c = 0;
            c.L1T2_Time__c = 0;
            c.L1T3_Time__c = 0;
            c.L1_Time__c = 0;
            c.L2T1_Time__c = 0;
			c.Contractor_Time__c = 0;
            c.Total_Work_Time__c = 0;
            
            for (AggregateResult ag1 : lstL1T1s)
            {
                if (c.Id == (Id) ag1.get('Case__c'))
                {
                    c.L1T1_Time__c = (decimal) ag1.get('TimeElapsed'); 
                }
            }
            for (AggregateResult ag2 : lstL1T2s)
            {
                if (c.Id == (Id) ag2.get('Case__c'))
                {
                    c.L1T2_Time__c = (decimal) ag2.get('TimeElapsed'); 
                }
            }
            for (AggregateResult ag3 : lstL1T3s)
            {
                if (c.Id == (Id) ag3.get('Case__c'))
                {
                    c.L1T3_Time__c = (decimal) ag3.get('TimeElapsed'); 
                }
            }
            for (AggregateResult ag4 : lstL1s)
            {
                if (c.Id == (Id) ag4.get('Case__c'))
                {
                    c.L1_Time__c = (decimal) ag4.get('TimeElapsed'); 
                }
            }
            for (AggregateResult ag5 : lstL2s)
            {
                if (c.Id == (Id) ag5.get('Case__c'))
                {
                    c.L2T1_Time__c = (decimal) ag5.get('TimeElapsed'); 
                }
            }
            for (AggregateResult ag6 : lstCons)
            {
                if (c.Id == (Id) ag6.get('Case__c'))
                {
                    c.Contractor_Time__c = (decimal) ag6.get('TimeElapsed'); 
                }
            }            
            for (AggregateResult ag7 : lstTotals)
            {
                if (c.Id == (Id) ag7.get('Case__c'))
                {
                    c.Total_Work_Time__c = (decimal) ag7.get('TimeElapsed'); 
                }
            }            
        }
        
        if (!lstCaseUpdates.isEmpty())
        {
            try
            {
                database.update(lstCaseUpdates);
            }
            catch (Exception e)
            {
                NI_Error_Logger.WriteToLog(e.getMessage(), 'Case', 'AH_CaseReportDetail_TriggerHandler', 'Update');
            }
        }
        
    }
    
}