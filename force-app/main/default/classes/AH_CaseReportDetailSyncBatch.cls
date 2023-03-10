/****************************************************************************************
Name            : AH_CaseReportDetailSyncBatch
Author          : Sean Harris
Created Date    : 04/30/2021
Last Mod Date   : 04/30/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test for thiso class is: AH_CaseReportDetailSync_Ctlr_Test 
                :
// TO TARGET DATE RANGE
DateTime dt1 = DateTime.newInstance(2021, 1, 1, 0, 0, 0);
DateTime dt2 = DateTime.newInstance(2021, 2, 1, 0, 0, 0);
Database.executeBatch(new AH_CaseReportDetailSyncBatch(dt1, dt2), 1, false);

// TO TARGET RETRO CASES PRIOR TO 1/1/2021
Database.executeBatch(new AH_CaseReportDetailSyncBatch(system.now(), system.now(), true), 1);
******************************************************************************************/
global class AH_CaseReportDetailSyncBatch implements Database.Batchable<sObject> 
{    
    
    private DateTime dtStart;
    private DateTime dtEnd;
	private Boolean bRetro;
        
    global AH_CaseReportDetailSyncBatch(DateTime dt1, DateTime dt2, Boolean doRetro)
    {
        dtStart = dt1;
        dtEnd = dt2;  
        bRetro = doRetro;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {        
        
        String strSOQL = 'SELECT Id FROM Case ';
        
        if (bRetro)
        {
            strSOQL += 'WHERE CreatedDate < 2021-01-01T00:00:00.000Z ';
            strSOQL += 'AND ( ';
            strSOQL += '(IsClosed = false AND RecordType.Name IN (\'Case\', \'Rally Support\')) ';
            strSOQL += 'OR ';
            strSOQL += '(ClosedDate > 2021-01-01T00:00:00.000Z AND RecordType.Name = \'Close Case\')) ';            
        }
        else
        {
            strSOQL += 'WHERE CreatedDate >: dtStart AND CreatedDate <: dtEnd';           
        }

        system.debug('strSOQL = ' + strSOQL);
        return Database.getQueryLocator(strSOQL);
        
    }
    
    global void execute(Database.BatchableContext bc, List<Case> scope) 
    {
        
		system.debug(' STARTING Execute method.  scope = ' + scope);
        
        try
        {
            Id CaseId = scope[0].Id;
            List<AH_Case_Report_Detail__c> lstCaseRptDetInserts = AH_CaseReportDetailSyncHelper.rebuildCaseDetailsFromCaseHistory(CaseId);  
            List<AH_Case_Report_Detail__c> lstCRDDeletes = new List<AH_Case_Report_Detail__c>([SELECT Id FROM AH_Case_Report_Detail__c WHERE Case__c =: CaseId]);
            database.delete(lstCRDDeletes);
            database.insert(lstCaseRptDetInserts);  
        }
        catch (Exception ex)
        {
            system.debug(' The following error occurred: ' + ex.getMessage());
        }
               
    }   
    
    global void finish(Database.BatchableContext bc) 
    {      
    }
    
}