/************************************************************************************************
                !!! INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : NI_BatchWinaproachResend Class
Integration     : Win@proach / Service Now
Author          : Swapnil Patil
Created Date    : 02/03/2016
Last Mod Date   : 12/06/2019 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
				: Updated 01/23/2019 per NICC-023347
                : Updated 12/06/2019 per NICC-039247
*************************************************************************************************/
global class NI_BatchWinaproachResend implements Database.Batchable<sObject>, Database.AllowsCallouts 
{
    
	public List<Case> lstCaseID;
	public String query;

	global Database.QueryLocator start(Database.BatchableContext bc)
    {
        
        system.debug(' *** ENTERING NI_BatchWinaproachResend.start() - QUERIES ISSUED = ' + Limits.getQueries());
        
		WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
		Integer maxRetries = 10;
		
        if (Integer.valueOf(winSettings.Max_Count_To_Resend_Failed_Message__c) != null)
        {
            maxRetries = Integer.valueOf(winSettings.Max_Count_To_Resend_Failed_Message__c);
        }
        
        query = 'SELECT Id, Case__c, Status__c, Transaction_Type__c, Integration_Name__c, UpdateFor__c, ';
        query += 'Retries_Performed__c, Do_Retries__c, XMLRequest__c, Attachment_Id__c, File_Id__c '; 
        query += 'FROM NI_Integration_Log__c ';
        query += 'WHERE status__c = \'Failed\' ';
        query += 'AND Integration_Name__c = \'Win@proach\' ';
        query += 'AND Integration_Case__c = null '; 			// ADDED THIS TO FILTER OUT NON-LEGACY INTEGRATION LOG RECORDS
        query += 'AND Do_Retries__c = true ';
        query += 'AND Retries_Performed__c < ' + maxRetries; 
        
        system.debug(' **** query = ' + query); 
        
        system.debug(' *** EXITING NI_BatchWinaproachResend.start() - QUERIES ISSUED = ' + Limits.getQueries());
        
		return Database.getQueryLocator(query);
        
	}
    
	global void execute(Database.BatchableContext bc, List<NI_Integration_Log__c> scope)
    {
		
        system.debug(' *** ENTERING NI_BatchWinaproachResend.execute() - QUERIES ISSUED = ' + Limits.getQueries());
        
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

        system.debug(' *** EXITING NI_BatchWinaproachResend.execute() - QUERIES ISSUED = ' + Limits.getQueries());
        		
	}
    
	global void finish(Database.BatchableContext bc)
    {
		
        system.debug(' *** ENTERING NI_BatchWinaproachResend.finish() - QUERIES ISSUED = ' + Limits.getQueries());
        
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
                            AND Integration_Case__c = null  			// ADDED THIS TO FILTER OUT NON-LEGACY INTEGRATION LOG RECORDS
                            AND Do_Retries__c = true 
                            AND Retries_Performed__c <: maxRetries];

		List<CronTrigger> lstBatch = new List<CronTrigger>([SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Resend_Message']);
		
        system.debug(' **** logCount = ' + logCount);
        system.debug(' **** lstBatch.size() = ' + lstBatch.size());
        
        // IF THERE ARE STILL INTEGRATION LOGS TO PROCESS AND THERE IS NOT SCHEDULED JOB 
		if (logCount > 0 && lstBatch.size() == 0)
        {
            system.debug(' **** Scheduling job named Resend_Message using apex class NI_BatchWinaproachResend');
			// Calling Batch to process Failed logs
			NI_BatchWinaproachResend resend = new NI_BatchWinaproachResend();
			// Setting Name of batch with call after(min) and batch size
			system.scheduleBatch(resend, 'Resend_Message', Integer.valueOf(winSettings.Resend_Failed_Message_Interval__c), 50);
		}
		
        system.debug(' *** EXITING NI_BatchWinaproachResend.finish() - QUERIES ISSUED = ' + Limits.getQueries());
        
	}

}