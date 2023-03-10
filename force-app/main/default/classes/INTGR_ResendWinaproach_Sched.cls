/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                             
*************************************************************************************************
Name            : INTGR_ResendWinaproach_Sched Class
Author          : Sean Harris
Created Date    : 01/15/2019 
Last Mod Date   : 01/15/2019 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
*************************************************************************************************/
global class INTGR_ResendWinaproach_Sched implements Schedulable 
{
    
    global final String strJobName;
    global final Id intgrAcctId;
    global final Integer iResendInterval;
    
    global INTGR_ResendWinaproach_Sched(String sJobName, Id iAcctId, Integer iResendInt)
    {        
        strJobName = sJobName;
        intgrAcctId = iAcctId; 
        iResendInterval = iResendInt;
    }   
    
    global void execute(SchedulableContext sc)
    {
        
        system.debug(' *** ENTERING INTGR_ResendWinaproach_Sched.execute() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // QUERY FOR EXISTING JOB
        List<CronTrigger> lstBatch = new List<CronTrigger>([SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name =: strJobName]);

        system.debug(' **** lstBatch.size() = ' + lstBatch.size());
        
        try
        {

            if (lstBatch.size() == 0)
            {
                
                // CALLING BATCH TO PROCESS FAILED LOGS
                INTGR_ResendWinaproach resend = new INTGR_ResendWinaproach(strJobName, intgrAcctId, iResendInterval); 

                // SETTING NAME OF BATCH WITH CALL AFTER(MIN) AND BATCH SIZE
                system.scheduleBatch(resend, strJobName, iResendInterval, 50);

            }
            
            // ABORT "INIT" JOB
            system.abortJob(sc.getTriggerId());
            
        } 
        catch (Exception e)
        {
            system.debug(' **** Error occurred: ' + e.getMessage());
            NI_Error_Logger.WriteToLog(e.getMessage(), 'INTGR_ResendWinaproach_Sched', 'INTGR_ResendWinaproach_Sched', 'Schedule'); 
        }	
        
        system.debug(' *** EXITING INTGR_ResendWinaproach_Sched.execute() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
}