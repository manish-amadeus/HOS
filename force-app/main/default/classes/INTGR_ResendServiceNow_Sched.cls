/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                             
*************************************************************************************************
Name            : INTGR_ResendServiceNow_Sched Class
Author          : Sean Harris
Created Date    : 01/15/2019 
Last Mod Date   : 01/15/2019 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
*************************************************************************************************/
global class INTGR_ResendServiceNow_Sched implements Schedulable 
{
    
    global final String strJobName;
    global final Id intgrAcctId;
    global final Integer iMaxResendTimes;
    global final Integer iResendInterval;
    
    global INTGR_ResendServiceNow_Sched(String sJobName, Id iAcctId, Integer iMaxTimes, Integer iResendInt)
    {        
        strJobName = sJobName;
        intgrAcctId = iAcctId; 
        iMaxResendTimes = iMaxTimes; 
        iResendInterval = iResendInt;
    }   
    
    global void execute(SchedulableContext sc)
    {
        
        system.debug(' *** ENTERING INTGR_ResendServiceNow_Sched.execute() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // QUERY FOR EXISTING JOB
        List<CronTrigger> lstBatch = new List<CronTrigger>([SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name =: strJobName]);

        system.debug(' **** lstBatch.size() = ' + lstBatch.size());
        
        try
        {
            
            if (lstBatch.size() == 0)
            {
                
                // CALLING BATCH TO PROCESS FAILED LOGS
                INTGR_ResendServiceNow resend = new INTGR_ResendServiceNow(strJobName, intgrAcctId, iMaxResendTimes, iResendInterval); 
                
                // SETTING NAME OF BATCH WITH CALL AFTER(MIN) AND BATCH SIZE
                system.scheduleBatch(resend, strJobName, iResendInterval, 50);

            }
            
            // ABORT "INIT" JOB
            system.abortJob(sc.getTriggerId());
            
        } 
        catch (Exception e)
        {
            system.debug(' **** Error occurred: ' + e.getMessage());
        }	
        
        system.debug(' *** EXITING INTGR_ResendServiceNow_Sched.execute() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
}