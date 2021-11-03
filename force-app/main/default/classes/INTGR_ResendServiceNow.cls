/************************************************************************************************
                  INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : INTGR_ResendServiceNow Class
Author          : Sean Harris
Created Date    : 01/15/2019
Last Mod Date   : 01/15/2019 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
*************************************************************************************************/
global class INTGR_ResendServiceNow implements Database.Batchable<sObject>, Database.AllowsCallouts 
{

    global final String strJobName;
    global final Id intgrAcctId;
    global final Integer iMaxResendTimes;
    global final Integer iResendInterval;

    global INTGR_ResendServiceNow(String sJobName, Id iAcctId, Integer iMaxTimes, Integer iResendInt)
    {      
        strJobName = sJobName;
        intgrAcctId = iAcctId; 
        iMaxResendTimes = iMaxTimes;
        iResendInterval = iResendInt;
    }    

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        
        system.debug(' *** ENTERING INTGR_ResendServiceNow.start() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String query = 'SELECT Id, Case__c, Status__c, Transaction_Type__c, Integration_Name__c, UpdateFor__c, ';
        query += 'Retries_Performed__c, Do_Retries__c, XMLRequest__c, Web_Service_Endpoint__c, Attachment_Id__c, File_Id__c ';
        query += 'FROM NI_Integration_Log__c ';
        query += 'WHERE Status__c = \'Failed\' ';
        query += 'AND Integration_Name__c = \'ServiceNow\' ';
        query += 'AND Integration_Case__r.INTGR_Account__c = \'' + intgrAcctId + '\' '; 
        query += 'AND Do_Retries__c = true '; 
        query += 'AND Retries_Performed__c < ' + iMaxResendTimes; 

        system.debug(' **** query = ' + query);
                     
        system.debug(' *** EXITING INTGR_ResendServiceNow.start() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return Database.getQueryLocator(query);
        
    }
    
	global void execute(Database.BatchableContext bc, List<NI_Integration_Log__c> scope)
    {
		
        system.debug(' *** ENTERING INTGR_ResendServiceNow.execute() - QUERIES ISSUED = ' + Limits.getQueries());

		Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();
		Map<Id, Id> mapLogCaseIdsCreate = new Map<Id, Id>();
		Map<Id, Id> mapLogCaseIdsUpdate = new Map<Id, Id>();
		Map<Id, String> mapUpdateFor = new Map<Id, String>();
		Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id, NI_Integration_Log__c>();
        
		system.debug(' **** scope.size() = ' + scope.size());
        
		for (NI_Integration_Log__c nlog : scope)
        {
            if (nlog.Transaction_Type__c == 'Update')
            {
                mapLogCaseIdsUpdate.put(nlog.id, nlog.Case__c);
                mapNiIntLog.put(nlog.id, nlog);
                mapUpdateFor.put(nlog.id, nlog.UpdateFor__c);
            }
            else 
            {
                if (nlog.Transaction_Type__c == 'Insert')
                {
                    mapLogCaseIdsCreate.put(nlog.id, nlog.Case__c);
                    mapNiIntLog.put(nlog.id, nlog);
                    mapUpdateFor.put(nlog.id, nlog.UpdateFor__c);
                }                
            }
		}		
		
	    if (mapLogCaseIdsUpdate.size() > 0)
        {
            NI_ServicenowFunctions.resendRequestToServiceNowUpdate(mapLogCaseIdsUpdate, mapLogCaseIdsCreate, mapNiIntLog);
        }

        if (mapLogCaseIdsCreate.size() > 0)
        {
            NI_ServicenowFunctions.resendRequestToServiceNowUpdate(mapLogCaseIdsUpdate, mapLogCaseIdsCreate, mapNiIntLog);	
        }

        system.debug(' *** EXITING INTGR_ResendServiceNow.execute() - QUERIES ISSUED = ' + Limits.getQueries());

	}
    
	global void finish(Database.BatchableContext bc)
    {
		
        system.debug(' *** ENTERING INTGR_ResendServiceNow.finish() - QUERIES ISSUED = ' + Limits.getQueries());
 
		Integer logCount = [SELECT COUNT() 
                            FROM NI_Integration_Log__c 
                            WHERE Status__c = 'Failed' 
                            AND Integration_Name__c = 'ServiceNow' 
                            AND Integration_Case__r.INTGR_Account__c =: intgrAcctId			// ADDED THIS TO FILTER OUT LEGACY INTEGRATION LOG RECORDS
                            AND Do_Retries__c = true 
                            AND Retries_Performed__c <: iMaxResendTimes];

		List<CronTrigger> lstBatch = new List<CronTrigger>([SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name =: strJobName]); 

        system.debug(' **** logCount = ' + logCount);
        system.debug(' **** lstBatch.size() = ' + lstBatch.size());
        
        // IF THERE ARE STILL INTEGRATION LOGS TO PROCESS AND THERE IS NOT SCHEDULED JOB 
		if (logCount > 0 && (lstBatch.size() == 0))
        {
            system.debug(' **** Scheduling job named ' + strJobName + ' using apex class INTGR_ResendServiceNow');
			// CALLING BATCH TO PROCESS FAILED LOGS
			INTGR_ResendServiceNow resend = new INTGR_ResendServiceNow(strJobName, intgrAcctId, iMaxResendTimes, iResendInterval);
			// SETTING NAME OF BATCH WITH CALL AFTER(MIN) AND BATCH SIZE
            system.scheduleBatch(resend, strJobName, iResendInterval, 50);
		}
		
        system.debug(' *** EXITING INTGR_ResendServiceNow.finish() - QUERIES ISSUED = ' + Limits.getQueries());
 
	}
    
}