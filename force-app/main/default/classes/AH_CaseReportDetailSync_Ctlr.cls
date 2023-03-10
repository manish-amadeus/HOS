/****************************************************************************************
Name            : AH_CaseReportDetailSync_Ctlr
Author          : Sean Harris
Created Date    : 04/30/2021
Last Mod Date   : 04/30/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller for the AH_CaseReportDetailSync Visualforce page.
                :            
******************************************************************************************/
public class AH_CaseReportDetailSync_Ctlr 
{
    
    public Case c {get; set;} 
    public List<AH_Case_Report_Detail__c> lstCaseRptDetsCurrent {get; set;} 
    public List<AH_Case_Report_Detail__c> lstCaseRptDetInserts {get; set;} 
	public string sortByField {get; set;} 
    public string sortByDirection {get; set;} 
    public boolean showRebuild {get; set;}      
    public boolean displayConfirm {get; set;}  
//    public Double dTotalTimeElapsed {get; set;} 
        
    
    public AH_CaseReportDetailSync_Ctlr(ApexPages.StandardSetController stdSetController) 
    {        
        if (ApexPages.CurrentPage().getParameters().containsKey('id')) 
        {
            initVariables();   
        }        
    }
    
    private void initVariables()
    {

        sortByField = 'Log_DateTime__c';
        sortByDirection = 'ASC';
        showRebuild = false;
        displayConfirm = false;

        c = [SELECT Id, CaseNumber, Subject, OwnerId, Owner.Name, CreatedDate, CreatedById, Status, Resolved_Date_and_Time__c, Support_Tier__c,   
             L1T1_Time__c, L1T2_Time__c, L1T3_Time__c, L1_Time__c, L2T1_Time__c, NonSupport_Time__c, Contractor_Time__c, Total_Work_Time__c, 
             RecordType.Name, IsClosed 
             FROM Case 
             WHERE Id =: ApexPages.CurrentPage().getParameters().get('id')];

        getCurrentCaseRptDets(sortByField + ' ' + sortByDirection);
        
    }

    @testVisible
    private void getCurrentCaseRptDets(String strSort)
    {
        
        string q = 'SELECT Id, Name, CreatedById, Event_Type__c, Log_DateTime__c, Case__c, ';
        q += 'Time_Elapsed__c, Old_Value__c, New_Value__c, IsOverridden__c, Detail__c ';
        q += 'FROM AH_Case_Report_Detail__c ';
        q += 'WHERE Case__c = \'' + c.Id + '\' ';
        
         // ORDER BY 
        if (strSort != null)
        {
            q += 'ORDER BY ' + strSort + ' ';
        }          
        else
        {
            q += 'ORDER BY Log_DateTime__c ASC ';
        }
        
        system.debug(q);
        
        try 
        { 
            lstCaseRptDetsCurrent = Database.query(q);
        }
        catch (Exception ex)
        {
            system.debug(ex.getMessage());
        }
        
    }

    public pageReference doRollupRecalc() 
    {      

        List<AggregateResult> lstL1T1s = new List<AggregateResult>(
            [SELECT Case__c, SUM(Time_Elapsed__c) TimeElapsed 
             FROM AH_Case_Report_Detail__c 
             WHERE Case__c =: c.Id 
             AND Old_Value__c = 'Level 1 Support Tier 1'
             GROUP BY Case__c]);
        
        List<AggregateResult> lstL1T2s = new List<AggregateResult>(
            [SELECT Case__c, SUM(Time_Elapsed__c) TimeElapsed 
             FROM AH_Case_Report_Detail__c 
             WHERE Case__c =: c.Id 
             AND Old_Value__c = 'Level 1 Support Tier 2'
             GROUP BY Case__c]);
        
        List<AggregateResult> lstL1T3s = new List<AggregateResult>(
            [SELECT Case__c, SUM(Time_Elapsed__c) TimeElapsed 
             FROM AH_Case_Report_Detail__c 
             WHERE Case__c =: c.Id 
             AND Old_Value__c = 'Level 1 Support Tier 3'
             GROUP BY Case__c]);
        
        List<AggregateResult> lstL1s = new List<AggregateResult>(
            [SELECT Case__c, SUM(Time_Elapsed__c) TimeElapsed 
             FROM AH_Case_Report_Detail__c 
             WHERE Case__c =: c.Id 
             AND Old_Value__c LIKE 'Level 1 Support%'
             GROUP BY Case__c]); 
        
        List<AggregateResult> lstL2s = new List<AggregateResult>(
            [SELECT Case__c, SUM(Time_Elapsed__c) TimeElapsed 
             FROM AH_Case_Report_Detail__c 
             WHERE Case__c =: c.Id 
             AND Old_Value__c = 'Level 2 Support'
             GROUP BY Case__c]); 
        
        List<AggregateResult> lstCons = new List<AggregateResult>(
            [SELECT Case__c, SUM(Time_Elapsed__c) TimeElapsed 
             FROM AH_Case_Report_Detail__c 
             WHERE Case__c =: c.Id 
             AND Old_Value__c = 'Contractor'
             GROUP BY Case__c]);
        
        List<AggregateResult> lstTotals = new List<AggregateResult>(
            [SELECT Case__c, SUM(Time_Elapsed__c) TimeElapsed 
             FROM AH_Case_Report_Detail__c 
             WHERE Case__c =: c.Id
             GROUP BY Case__c]);

        List<Case> lstCaseUpdates = new List<Case>([SELECT Id, L1T1_Time__c, L1T2_Time__c, L1T3_Time__c, L1_Time__c, L2T1_Time__c, Contractor_Time__c, Total_Work_Time__c FROM Case WHERE Id =: c.Id]);

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
                NI_Error_Logger.WriteToLog(e.getMessage(), 'Case', 'AH_CaseReportDetailSync_Ctlr', 'Update');
            }
        }
        		
        pageReference pr = new pageReference('/apex/AH_CaseReportDetailSync?id=' + c.Id);
        pr.setRedirect(true);
        return pr;
        
    } 

    public void rebuildFromCaseHistory()
    {
        showRebuild = true;
        lstCaseRptDetInserts = AH_CaseReportDetailSyncHelper.rebuildCaseDetailsFromCaseHistory(c.Id);       
    }

    // =========================================================================
    // 		BUTTON METHODS
    // =========================================================================
    public void rebuildPrompt()
    {
        displayConfirm = true;
    }

    public pageReference hideConfirmation()
    {
        displayConfirm = false; 
        return null;
    }
 
    public void closeRebuildView()
    {
        showRebuild = false;
    }
        
    public pageReference doRebuild()
    {
        try
        {
            List<AH_Case_Report_Detail__c> lstCRDDeletes = new List<AH_Case_Report_Detail__c>([SELECT Id FROM AH_Case_Report_Detail__c WHERE Case__c =: c.Id]);
            database.delete(lstCRDDeletes);
            database.insert(lstCaseRptDetInserts); 
            showRebuild = false;
            initVariables();
        }
        catch (Exception ex)
        {
            system.debug(' *** ERROR OCCURRED: ' + ex.getMessage());
        }
        return null;
    }    
    
    public pageReference backToCase()
    {
        string strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Case/' + c.Id + '/view';
        PageReference pr = new PageReference(strUrl); 
        pr.setRedirect(true); 
        return pr;
    }
    
    public void doSort()
    {
        if (sortByDirection == 'ASC')
        {
            sortByDirection = 'DESC';
        }
        else
        {
            sortByDirection = 'ASC';
        }        
        getCurrentCaseRptDets(sortByField + ' ' + sortByDirection);
    }
 
}