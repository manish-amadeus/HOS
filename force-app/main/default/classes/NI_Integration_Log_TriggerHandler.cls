/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                             
*************************************************************************************************
Name            : NI_Integration_Log_TriggerHandler Class
Author          : Swapnil Patil
Created Date    : 03/10/2016
Last Mod Date   : 01/16/2019 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class that handles all trigger code for the NI_Integration_Log Object
                :    
                : 
                : 
*************************************************************************************************/
public class NI_Integration_Log_TriggerHandler 
{

    
    public NI_Integration_Log_TriggerHandler()
    {
        
    }
    
    public void OnAfterInsert(List<NI_Integration_Log__c> newTrigger)
    {    

        system.debug(' *** ENTERING NI_Integration_Log_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!NI_FUNCTIONS.bypassTriggerCode('NI_Integration_Log__c'))
        {  
            initiateResend(newTrigger);
        } 
        
        system.debug(' *** ENTERING NI_Integration_Log_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnBeforeUpdate(List<NI_Integration_Log__c> newTrigger, Map<Id, NI_Integration_Log__c> oldMapTrigger)
    {    

        system.debug(' *** ENTERING NI_Integration_Log_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!NI_FUNCTIONS.bypassTriggerCode('NI_Integration_Log__c'))
        {  
            
            Boolean isInitiateResend = false;
            
            for (NI_Integration_Log__c nlog : newTrigger)
            {
                if (nlog.Do_Retries__c == true && oldMapTrigger.get(nlog.Id).Do_Retries__c == false)
                {
                    nlog.Retries_Performed__c = 0;
                    isInitiateResend = true;
                }
            }
            
            if (isInitiateResend)
            {
                initiateResend(newTrigger);
            }
            
        }
        
        system.debug(' *** EXITING NI_Integration_Log_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    public void initiateResend(List<NI_Integration_Log__c> newTrigger)
    {
        
        system.debug(' *** ENTERING NI_Integration_Log_TriggerHandler.initiateResend() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // READ IN LEGACY INTEGRATION CUSTOM SETTINGS
        WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
        Integer wpMaxCount = (Integer)winSettings.Max_Count_To_Resend_Failed_Message__c;
        Integer wpResendInt = (Integer)winSettings.Resend_Failed_Message_Interval__c;
        
        ServiceNowIncidentSettings__c ServiceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
        Integer snMaxCount = (Integer)ServiceNowSettings.Max_Count_To_Resend_Failed_Message__c;
        Integer snResendInt = (Integer)ServiceNowSettings.Resend_Failed_Message_Interval__c;
        
system.debug(' **** winSettings.Max_Count_To_Resend_Failed_Message__c = ' + wpMaxCount);
system.debug(' **** winSettings.Resend_Failed_Message_Interval__c = ' + wpResendInt);
system.debug(' **** ServiceNowSettings.Max_Count_To_Resend_Failed_Message__c = ' + snMaxCount);
system.debug(' **** ServiceNowSettings.Resend_Failed_Message_Interval__c = ' + snResendInt);
        
		// GET DEFAULT IHG ACCOUNT RECORD
        Account accIHG;
  
        if (ServiceNowSettings.AccountId__c != null)
        {
            accIHG = [SELECT Id, Name, AccountNumber FROM Account WHERE Id =: ServiceNowSettings.AccountId__c];
        }

system.debug(' **** accIHG = ' + accIHG);
        
		Map<String, failedLog> mapKey2Failed = new Map<String, failedLog>();
        
        // LOOP THROUGH ALL INTEGRATION LOGS IN THE TRIGGER AND POPULATE A UTILITY MAP THAT IS USED TO GATHER FAILED RECORDS BY 
        // INTEGRATION ACCOUNT ID / INTEGRATION NAME SO THAT AT THE END SEPARATE APEX JOBS CAN BE CREATED TO KEEP THEM AUTONOMOUS 
        for (NI_Integration_Log__c iLog : newTrigger)
        {
            
system.debug(' **** iLog.Status__c = ' + iLog.Status__c);  
            
            // ONLY TARGET FAILED LOGS FOR RESEND
            if (iLog.Status__c == 'Failed')
            {
                
system.debug(' **** iLog.Integration_Case__c = ' + iLog.Integration_Case__c); 
system.debug(' **** iLog.Integration_Account_Id__c = ' + iLog.Integration_Account_Id__c);  
                
                // IF TRUE THIS IS A LOG FOR A LEGACY IHG CASE
                if (iLog.Integration_Case__c == null && iLog.Integration_Account_Id__c == null)
                {
    
system.debug(' **** LEGACY MAPKEY = ' + accIHG.Id + '~' + iLog.Integration_Name__c);  
                                    
                    if (!mapKey2Failed.containsKey(accIHG.Id + '~' + iLog.Integration_Name__c))
                    {
                        
system.debug(' **** iLog.Integration_Name__c = ' + iLog.Integration_Name__c);     
                        
                        if (iLog.Integration_Name__c == 'Win@proach')
                        {
                            failedLog fl = new failedLog(null, accIHG.AccountNumber, iLog.Integration_Name__c, wpMaxCount, wpResendInt, 1, false);
                            mapKey2Failed.put(accIHG.Id + '~' + iLog.Integration_Name__c, fl);                           
                        }
                        else
                        {
                            failedLog fl = new failedLog(null, accIHG.AccountNumber, iLog.Integration_Name__c, snMaxCount, snResendInt, 1, false);
                            mapKey2Failed.put(accIHG.Id + '~' + iLog.Integration_Name__c, fl);                            
                        }
                    }
                    else
                    {
                        
system.debug(' **** iFailCount = ' + mapKey2Failed.get(accIHG.Id + '~' + iLog.Integration_Name__c).iFailCount);
                        
                        mapKey2Failed.get(accIHG.Id + '~' + iLog.Integration_Name__c).iFailCount += 1;
                    }
                }
                else
                {
    
system.debug(' **** MAPKEY = ' + iLog.Integration_Account_Id__c + '~' + iLog.Integration_Name__c);  
                    
                    if (!mapKey2Failed.containsKey(iLog.Integration_Account_Id__c + '~' + iLog.Integration_Name__c))
                    {
                        failedLog fl = new failedLog(iLog.Integration_Account_Id__c, iLog.Account_Number__c, iLog.Integration_Name__c, snMaxCount, snResendInt, 1, false);
                        mapKey2Failed.put(iLog.Integration_Account_Id__c + '~' + iLog.Integration_Name__c, fl);
                    }
                    else
                    {
                        mapKey2Failed.get(iLog.Integration_Account_Id__c + '~' + iLog.Integration_Name__c).iFailCount += 1;
                    }
                }
            }
        }

system.debug(' **** mapKey2Failed.size() = ' + mapKey2Failed.size());
system.debug(' **** mapKey2Failed = ' + mapKey2Failed);
        
        Set<Id> setIAccIds = new Set<Id>();
        Boolean hasLegacyFails = false;
        
        // LOOP THROUGH AND DO 2 THINGS: SEE IF ANY LOGS ARE LEGACY & POPULATE A LIST OF INTEGRATION ACCOUNT IDS
        for (NI_Integration_Log__c nLog : newTrigger)
        {
            if (nLog.Integration_Case__c == null && nLog.Integration_Account_Id__c == null)
            {
                hasLegacyFails = true;
            }
            else
            {
                setIAccIds.add(nLog.Integration_Account_Id__c);
            }
        }

system.debug(' **** setIAccIds = ' + setIAccIds);
        
        List<failedLog> lstFailedLog = new List<failedLog>(); 
        
        // GO AHEAD AND ADD LEGACY LOGS TO THE FINAL LIST
        if (hasLegacyFails)
        {
            for (failedLog fl : mapKey2Failed.values())
            {
                if (fl.INTGR_AccountId == null)
                {
                    lstFailedLog.add(fl);                    
                }
            }
        }
        
        // THEN LOOP THROUGH AND ADD NEW LOGS TO THE FINAL LIST 
        for (INTGR_Account__c iAcc : [SELECT Id, Account__c, AccountNumber__c, External_Integration_System_Name__c, 
                                      Max_Count_To_Resend_Failed_Message__c, Resend_Failed_Message_Interval_in_Min__c 
                                      FROM INTGR_Account__c
                                      WHERE Active__c = true 
                                      AND Id IN : setIAccIds])
        {
            for (failedLog fl : mapKey2Failed.values())
            {
                
system.debug(' **** iAcc.Id = ' + iAcc.Id + ', fl.INTGR_AccountId = ' + fl.INTGR_AccountId);
system.debug(' **** iAcc.External_Integration_System_Name__c = ' + iAcc.External_Integration_System_Name__c + ', fl.ExternalSystemName = ' + fl.ExternalSystemName);  
             
                if (iAcc.Id == fl.INTGR_AccountId) 
                {
                    if (iAcc.External_Integration_System_Name__c != 'Win@proach')
                    {
                        fl.AccountNumber = iAcc.AccountNumber__c;
                        fl.iMaxResendTimes = (Integer)iAcc.Max_Count_To_Resend_Failed_Message__c;
                        fl.iResendInterval = (Integer)iAcc.Resend_Failed_Message_Interval_in_Min__c;                          
                    }
                    lstFailedLog.add(fl);
                }
            }
        }

system.debug(' **** lstFailedLog.size() = ' + lstFailedLog.size());
system.debug(' **** lstFailedLog = ' + lstFailedLog);
        
        List<CronTrigger> lstCron = new List<CronTrigger>([SELECT Id, CronJobDetail.Name 
                                                           FROM CronTrigger 
                                                           WHERE CronJobDetail.Name IN ('ResendJob', 'ResendJobServiceNow') 		//', 'Resend_ServiceNowMessage' Resend_Message', 
                                                           OR CronJobDetail.Name LIKE 'INTGR_Init_%']);
        
        // CHECK FOR EXISTING JOBS AND SET THE FLAG IN LIST
        for (CronTrigger ct1 : lstCron)
        {
            for (failedLog fLog : lstFailedLog)
            {
                
                if (fLog.INTGR_AccountId != null)
                {
                    if (ct1.CronJobDetail.Name.contains(fLog.AccountNumber)) 
                    {
                        fLog.bJobExists = true;
                    }
                }
                else
                {
                    if ((fLog.ExternalSystemName == 'Win@proach' && ct1.CronJobDetail.Name.contains('ResendJob')) || (fLog.ExternalSystemName == 'ServiceNow' && ct1.CronJobDetail.Name.contains('ResendJobServiceNow'))) 
                    {
                        fLog.bJobExists = true;
                    }
                }
            }
        }

system.debug(' **** lstFailedLog = ' + lstFailedLog);
                
        // LOOP THROUGH FINAL LIST AND SCHEDULE RESEND JOBS
        for (failedLog fLog : lstFailedLog)
        { 

system.debug(' **** fLog = ' + fLog);
                    
            if (fLog.bJobExists == false && fLog.iFailCount > 0)
            {

system.debug(' **** fLog.bJobExists = ' + fLog.bJobExists);
                
                Datetime n = Datetime.now();
                Integer i = 1;
                if (Test.isRunningTest())
                {
                    i = 2;
                    // CLEAR OUT AND SCHEDULED LEGACY TEST & NEW JOBS
//                    for (CronTrigger crnTrg : [SELECT Id, CronJobDetail.Name 
//                                               FROM CronTrigger 
//                                               WHERE CronJobDetail.Name IN ('ResendJob', 'Resend_Message', 'ResendJobServiceNow', 'Resend_ServiceNowMessage') 
//                                               OR CronJobDetail.Name LIKE 'INTGR_%'])
//                    {
//system.debug(' **** IS TEST so Aborting Apex Job Named: ' + crnTrg.CronJobDetail.Name);                        
//                        system.abortJob(crnTrg.Id);
//                    }
                }
                n = n.addMinutes(i);
                String CRON_EXP = '0 ' + n.format('m') + ' ' + n.format('H') + ' ' + n.format('d') + ' ' + n.format('M') + ' ? ' + n.format('yyyy'); 

system.debug(' **** CRON_EXP = ' + CRON_EXP);
system.debug(' **** fLog.ExternalSystemName = ' + fLog.ExternalSystemName);
                
                // CALLING LEGACY WINAPROACH SCHEDULING CLASSES
                if (fLog.INTGR_AccountId == null && fLog.ExternalSystemName == 'Win@proach')
                {
system.debug(' **** Scheduling LEGACY Win@proach Resend');                       
                    NI_Scheduled_WinaproachResendMessage resend = new NI_Scheduled_WinaproachResendMessage();						
                    system.schedule('ResendJob', CRON_EXP, resend); 
                }
                
                // CALLING LEGACY SERVICENOW SCHEDULING CLASSES
                if (fLog.INTGR_AccountId == null && fLog.ExternalSystemName == 'ServiceNow')
                {
system.debug(' **** Scheduling LEGACY ServiceNow Resend');                        
                    NI_Scheduled_ServiceNowResendMessage resendServ = new NI_Scheduled_ServiceNowResendMessage();						
                    system.schedule('ResendJobServiceNow', CRON_EXP, resendServ); 
                }                 
                
                // IF THIS IS A Win@proach RELATED FAILED LOG
                if (fLog.INTGR_AccountId != null && fLog.ExternalSystemName == 'Win@proach')
                {
system.debug(' **** Scheduling Win@proach Resend');                    
                    INTGR_ResendWinaproach_Sched resend = new INTGR_ResendWinaproach_Sched('INTGR_Resend_WINAPRCH_' + fLog.AccountNumber, fLog.INTGR_AccountId, fLog.iResendInterval);						
                    system.schedule('INTGR_Init_Resend_WINAPRCH_' + fLog.AccountNumber, CRON_EXP, resend); 
                }
                
                // IF THIS IS A ServiceNow RELATED FAILED LOG
                if (fLog.INTGR_AccountId != null && fLog.ExternalSystemName == 'ServiceNow')
                { 
system.debug(' **** Scheduling ServiceNow Resend');                        
                    INTGR_ResendServiceNow_Sched resendSvcNow = new INTGR_ResendServiceNow_Sched('INTGR_Resend_SVCNOW_' + fLog.AccountNumber, fLog.INTGR_AccountId, fLog.iMaxResendTimes, fLog.iResendInterval);						
                    system.schedule('INTGR_Init_Resend_SVCNOW_' + fLog.AccountNumber, CRON_EXP, resendSvcNow); 
                } 
                
                // FOR FUTURE: TO ADD NEW BATCH RESENDS TO OTHER CUSTOMER SYSTEMS HERE ...
                
            }
            
        }

        system.debug(' *** EXITING NI_Integration_Log_TriggerHandler.initiateResend() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    // WRAPPER CLASS 
    public class failedLog
    {
        
        public Id INTGR_AccountId {get; set;} 
        public String AccountNumber {get; set;} 
        public String ExternalSystemName {get; set;} 
        public Integer iMaxResendTimes {get; set;} 
        public Integer iResendInterval {get; set;} 
        public Integer iFailCount {get; set;}  
        public Boolean bJobExists {get; set;} 
        
        public failedLog(Id INTGR_AccountId, String AccountNumber, String ExternalSystemName, Integer iMaxResendTimes, Integer iResendInterval, Integer iFailCount, Boolean bJobExists)
        {
            
            this.INTGR_AccountId = INTGR_AccountId;
            this.AccountNumber = AccountNumber;
            this.ExternalSystemName = ExternalSystemName;
            this.iMaxResendTimes = iMaxResendTimes;
            this.iResendInterval = iResendInterval;
            this.iFailCount = iFailCount;
            this.bJobExists = bJobExists;
            
        }
        
    }
    
    
/*    
    public void initiateResend_OLD(List<NI_Integration_Log__c> newTrigger)
    {
        
        // After Insert: When Integarion log message status is failed then initiate resend logic
        
        system.debug(' *** ENTERING NI_Integration_Log_TriggerHandler.initiateResend() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // Win@proach Integration: Verify for the Win@proach integration username 
        WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
        ServiceNowIncidentSettings__c ServiceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
        
        if ((winSettings.Integration_Username__c != null && winSettings.Integration_Username__c != UserInfo.getUserName()) ||
            ServiceNowSettings.Integration_Username__c != null && 
            ServiceNowSettings.Integration_Username__c != UserInfo.getUserName())
        {
            
            List<NI_Integration_Log__c> lstLog = new List<NI_Integration_Log__c>();
            List<NI_Integration_Log__c> lstServiceLog = new List<NI_Integration_Log__c>();
            List<CronTrigger> lstBatch = new List<CronTrigger>();
            List<CronTrigger> lstResendJob = new List<CronTrigger>();
            List<CronTrigger> lstBatchServiceNow = new List<CronTrigger>();
            List<CronTrigger> lstResendJobServiceNow = new List<CronTrigger>();
            Integer batchCount = 0;
            
            for (NI_Integration_Log__c nlog : newTrigger)
            {
                if (nlog.Status__c == 'Failed' && nlog.Integration_Name__c == 'Win@proach')
                {
                    lstLog.add(nlog);
                }
                if (nlog.Status__c == 'Failed' && nlog.Integration_Name__c == 'ServiceNow')
                {
                    lstServiceLog.add(nlog);
                }
            }
            
            //Resend for Win@proach messages
            if (lstLog.size() > 0 || lstServiceLog.size() > 0)
            {
                
                lstBatch = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Resend_Message'];			
                lstBatchServiceNow = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Resend_ServiceNowMessage'];			

                lstResendJob = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'ResendJob'];
                lstResendJobServiceNow = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'ResendJobServiceNow'];
                
                //if(lstBatch.size()== 0 && lstResendJob.size() == 0){
                //String CRON_EXP = '0 10 * 1 * ? *';
                Datetime n = Datetime.now();	
                
                Integer i = Test.isRunningTest() ? 2 : 1;
                n = n.addMinutes(i);						
                String CRON_EXP = '0 ' + n.format('m') + ' ' + n.format('H') + ' ' + n.format('d') + ' ' + n.format('M') + ' ? ' + n.format('yyyy'); 
                
                // Calling Batch to process Failed logs
                if (lstLog.size() > 0 && lstBatch.size() == 0 && lstResendJob.size() == 0)
                {
                    NI_Scheduled_WinaproachResendMessage resend = new NI_Scheduled_WinaproachResendMessage();						
                    //Database.executeBatch(new NI_Scheduled_WinaproachResendMessage());
                    system.schedule('ResendJob', CRON_EXP, resend); 
                }
                
                if (lstServiceLog.size() > 0 && lstBatchServiceNow.size() == 0 && lstResendJobServiceNow.size() == 0)
                {
                    NI_Scheduled_ServiceNowResendMessage resendServ = new NI_Scheduled_ServiceNowResendMessage();						
                    //Database.executeBatch(new NI_Scheduled_WinaproachResendMessage());
                    system.schedule('ResendJobServiceNow', CRON_EXP, resendServ); 
                }
                
                //}
            }
            
        } 
        
        system.debug(' *** EXITING NI_Integration_Log_TriggerHandler.initiateResend() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }    
*/    
 
    
}