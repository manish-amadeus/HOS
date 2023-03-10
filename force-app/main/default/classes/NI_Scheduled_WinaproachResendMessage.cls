/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : NI_Scheduled_WinaproachResendMessage 
Author          : Swapnil Patil
Created Date    : 03/10/2016
Last Mod Date   : 01/17/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
				: 
				: 
*************************************************************************************************/
global class NI_Scheduled_WinaproachResendMessage implements Schedulable 
{
    
    global void execute(SchedulableContext sc)
    {
        
        system.debug(' *** ENTERING NI_Scheduled_WinaproachResendMessage.execute() - QUERIES ISSUED = ' + Limits.getQueries());
        
        WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
        Integer Message_Interval = 10;
        
        if (winSettings.Resend_Failed_Message_Interval__c != null)
        {
            Message_Interval = Integer.valueOf(winSettings.Resend_Failed_Message_Interval__c);
        }
        
        List<CronTrigger> lstBatch = new List<CronTrigger>([SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Resend_Message']);
        
        try
        {
            // CALLING BATCH TO PROCESS FAILED LOGS
            NI_BatchWinaproachResend resend = new NI_BatchWinaproachResend();
            
            if (lstBatch.size() == 0)
            {            
                // SETTING NAME OF BATCH WITH CALL AFTER(MIN) AND BATCH SIZE
                system.scheduleBatch(resend, 'Resend_Message', Message_Interval, 50);
            }
            
            // ABORT "INIT" JOB
            system.abortJob(sc.getTriggerId()); 
            
        } 
        catch (Exception e) 
        { 
            system.debug('Error Occurred: ' + e.getMessage()); 
        } 
        
        system.debug(' *** EXITING NI_Scheduled_WinaproachResendMessage.execute() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
}