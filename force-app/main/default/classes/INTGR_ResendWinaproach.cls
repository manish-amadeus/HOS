/************************************************************************************************
                  INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : INTGR_ResendWinaproach Class
Author          : Sean Harris
Created Date    : 01/15/2019
Last Mod Date   : 01/15/2019 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
*************************************************************************************************/
global class INTGR_ResendWinaproach implements Database.Batchable<sObject>, Database.AllowsCallouts 
{

    global final String strJobName;
    global final Id intgrAcctId;
    global final Integer iResendInterval;

    global INTGR_ResendWinaproach(String sJobName, Id iAcctId, Integer iResendInt)
    {      
        strJobName = sJobName;
        intgrAcctId = iAcctId; 
        iResendInterval = iResendInt;
    }    

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        
        system.debug(' *** ENTERING INTGR_ResendWinaproach.start() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // FETCH WINAPROACH RETRIES FROM CUSTOM SETTINGS
		WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
		Integer maxRetries = 10;
		
        if (Integer.valueOf(winSettings.Max_Count_To_Resend_Failed_Message__c) != null)
        {
            maxRetries = Integer.valueOf(winSettings.Max_Count_To_Resend_Failed_Message__c);
        }
        
        String query = 'SELECT Id, Case__c, Status__c, Transaction_Type__c, Integration_Name__c, UpdateFor__c, ';
        query += 'Retries_Performed__c, Do_Retries__c, XMLRequest__c, Attachment_Id__c, File_Id__c ';  
        query += 'FROM NI_Integration_Log__c ';
        query += 'WHERE status__c = \'Failed\' ';
        query += 'AND Integration_Name__c = \'Win@proach\' ';
        query += 'AND Integration_Case__r.INTGR_Account__c = \'' + intgrAcctId + '\' ';  			// ADDED THIS TO FILTER OUT LEGACY INTEGRATION LOG RECORDS
        query += 'AND Do_Retries__c = true ';
        query += 'AND Retries_Performed__c < ' + maxRetries;         
        
        system.debug(' **** query = ' + query);
                     
        system.debug(' *** EXITING INTGR_ResendWinaproach.start() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return Database.getQueryLocator(query);
        
    }
    
	global void execute(Database.BatchableContext bc, List<NI_Integration_Log__c> scope)
    {
		
        system.debug(' *** ENTERING INTGR_ResendWinaproach.execute() - QUERIES ISSUED = ' + Limits.getQueries());

		Map<Id, Id> mapLogCaseIds = new Map<Id, Id>();
		Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();
		Map<Id, Id> mapLogCaseIdsUpdate = new Map<Id, Id>();
		Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id, NI_Integration_Log__c>();

        for (NI_Integration_Log__c nlog : scope)
        {
            if (nlog.Transaction_Type__c == 'Insert')
            {
                MapLogCaseIds.put(nlog.id, nlog.Case__c);
                mapRetriesID.put(nlog.id, Integer.valueOf(nlog.Retries_Performed__c));
            } 
            else 
            {
                if (nlog.Transaction_Type__c == 'Update')
                {
                    mapLogCaseIdsUpdate.put(nlog.id, nlog.Case__c);
                    mapNiIntLog.put(nlog.id, nlog);
                }
            }
        }

		if (mapLogCaseIds.size() > 0)
        {
			system.debug(' **** mapLogCaseIds = ' + mapLogCaseIds);
            system.debug(' **** mapRetriesID = ' + mapRetriesID);            
            NI_WinaproachServiceHelper.resendRequestToWinaproach(mapLogCaseIds, mapRetriesID);
        }
        
	    if (mapLogCaseIdsUpdate.size() > 0)
        {
			system.debug(' **** mapLogCaseIdsUpdate = ' + mapLogCaseIdsUpdate);
            system.debug(' **** mapNiIntLog = ' + mapNiIntLog);
            NI_WinaproachServiceHelper.resendRequestToWinaproachUpdate(mapLogCaseIdsUpdate, mapNiIntLog);	
        }

        system.debug(' *** EXITING INTGR_ResendWinaproach.execute() - QUERIES ISSUED = ' + Limits.getQueries());

	}
    
	global void finish(Database.BatchableContext bc)
    {
		
        system.debug(' *** ENTERING INTGR_ResendWinaproach.finish() - QUERIES ISSUED = ' + Limits.getQueries());
 
        // FETCH WINAPROACH RETRIES FROM CUSTOM SETTINGS
		WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
		Integer maxRetries = 10;
		
        if (Integer.valueOf(winSettings.Max_Count_To_Resend_Failed_Message__c) != null)
        {
            maxRetries = Integer.valueOf(winSettings.Max_Count_To_Resend_Failed_Message__c);
        }
        
		Integer logCount = [SELECT COUNT() 
                            FROM NI_Integration_Log__c 
                            WHERE status__c = 'Failed'  
                            AND Integration_Name__c = 'Win@proach' 
                            AND Integration_Case__r.INTGR_Account__c =: intgrAcctId  			// ADDED THIS TO FILTER OUT LEGACY INTEGRATION LOG RECORDS
                            AND Do_Retries__c = true 
                            AND Retries_Performed__c <: maxRetries];        

		List<CronTrigger> lstBatch = new List<CronTrigger>([SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name =: strJobName]); 

        system.debug(' **** logCount = ' + logCount);
        system.debug(' **** lstBatch.size() = ' + lstBatch.size());
        
        // IF THERE ARE STILL INTEGRATION LOGS TO PROCESS AND THERE IS NOT SCHEDULED JOB 
		if (logCount > 0 && (lstBatch.size() == 0))
        {
            system.debug(' **** Scheduling job named ' + strJobName + ' using apex class INTGR_ResendWinaproach');
			// CALLING BATCH TO PROCESS FAILED LOGS
			INTGR_ResendWinaproach resend = new INTGR_ResendWinaproach(strJobName, intgrAcctId, iResendInterval);
			// SETTING NAME OF BATCH WITH CALL AFTER(MIN) AND BATCH SIZE
            system.scheduleBatch(resend, strJobName, iResendInterval, 50);
		}
		
        system.debug(' *** EXITING INTGR_ResendWinaproach.finish() - QUERIES ISSUED = ' + Limits.getQueries());
 
	}
    
}