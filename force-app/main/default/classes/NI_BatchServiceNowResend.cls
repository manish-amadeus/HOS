/************************************************************************************************
                !!! INTEGRATION CLASS - DO NOT ALTER !!!
*************************************************************************************************
Name            : NI_BatchServiceNowResend Class
Integration     : Win@pproach / Service Now
Author          : Swapnil Patil
Created Date    : 02/03/2016
Last Mod Date   : 01/23/2019 
Last Mod By     : Sean Harris
NICC Reference  : Last Updated Per NICC-023347
Description     : 
                : 
*************************************************************************************************/
global class NI_BatchServiceNowResend implements Database.Batchable<sObject>, Database.AllowsCallouts 
{
    
	//public List<Case> lstCaseID;
	//public String query;
	
	
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        
        system.debug(' *** ENTERING NI_BatchServiceNowResend.start() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String query;
        
        ServiceNowIncidentSettings__c ServiceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
        Integer maxRetries = 10;
        
        if (ServiceNowSettings.Max_Count_To_Resend_Failed_Message__c != null)
        {
            maxRetries = Integer.valueOf(ServiceNowSettings.Max_Count_To_Resend_Failed_Message__c);
        }

        query = 'SELECT Id, Case__c, Status__c, Transaction_Type__c, Integration_Name__c, UpdateFor__c, ';
        query += 'Retries_Performed__c, Do_Retries__c, XMLRequest__c, Web_Service_Endpoint__c, Attachment_Id__c ';
        query += 'FROM NI_Integration_Log__c ';
        query += 'WHERE Status__c = \'Failed\' ';
        query += 'AND Integration_Name__c = \'ServiceNow\' ';
        query += 'AND Integration_Case__c = null '; 			// ADDED THIS TO FILTER OUT NON-LEGACY INTEGRATION LOG RECORDS
        query += 'AND Do_Retries__c = true '; 
        query += 'AND Retries_Performed__c < ' + maxRetries; 

        system.debug(' *** EXITING NI_BatchServiceNowResend.start() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return Database.getQueryLocator(query);
        
    }
    
	global void execute(Database.BatchableContext bc, List<NI_Integration_Log__c> scope)
    {
		
        system.debug(' *** ENTERING NI_BatchServiceNowResend.execute() - QUERIES ISSUED = ' + Limits.getQueries());

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
                    mapLogCaseIdsCreate.put(nlog.id,nlog.Case__c);
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

        system.debug(' *** EXITING NI_BatchServiceNowResend.execute() - QUERIES ISSUED = ' + Limits.getQueries());

	}
    
	global void finish(Database.BatchableContext bc)
    {
		
        system.debug(' *** ENTERING NI_BatchServiceNowResend.finish() - QUERIES ISSUED = ' + Limits.getQueries());
 
        // FETCH SERVICE NOW RETRIES FROM CUSTOM SETTINGS
		ServiceNowIncidentSettings__c ServiceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
		Integer maxRetries = 10;
        
		if (ServiceNowSettings.Max_Count_To_Resend_Failed_Message__c != null)
        {
            maxRetries = Integer.valueOf(ServiceNowSettings.Max_Count_To_Resend_Failed_Message__c);
        }
			
		Integer logCount = [SELECT COUNT() FROM NI_Integration_Log__c 
                            WHERE status__c = 'Failed' 
                            AND Integration_Name__c = 'ServiceNow' 
                            AND Integration_Case__c = null  			// ADDED THIS TO FILTER OUT NON-LEGACY INTEGRATION LOG RECORDS
                            AND Do_Retries__c = true AND Retries_Performed__c <: maxRetries];
		
		List<CronTrigger> lstBatch = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Resend_ServiceNowMessage'];	
        
        system.debug(' **** logCount = ' + logCount);
        system.debug(' **** lstBatch.size() = ' + lstBatch.size());
        
        // IF THERE ARE STILL INTEGRATION LOGS TO PROCESS AND THERE IS NOT SCHEDULED JOB 
		if (logCount > 0 && (lstBatch.size() == 0))
        {
            system.debug(' **** Scheduling job named Resend_ServiceNowMessage using apex class NI_BatchServiceNowResend');
			// Calling Batch to process Failed logs
			NI_BatchServiceNowResend resend = new NI_BatchServiceNowResend();
			// Setting Name of batch with call after(min) and batch size
			system.scheduleBatch(resend, 'Resend_ServiceNowMessage', Integer.valueOf(ServiceNowSettings.Resend_Failed_Message_Interval__c), 50);
		}
		
        system.debug(' *** EXITING NI_BatchServiceNowResend.finish() - QUERIES ISSUED = ' + Limits.getQueries());
 
	}

}