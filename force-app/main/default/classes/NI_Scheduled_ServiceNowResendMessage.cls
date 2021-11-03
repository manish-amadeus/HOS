/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                             
*************************************************************************************************
Name            : NI_Scheduled_ServiceNowResendMessage Class
Author          : Swapnil Patil
Created Date    : 3/10/2016
Last Mod Date   : 1/15/2019 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
*************************************************************************************************/
global class NI_Scheduled_ServiceNowResendMessage implements Schedulable 
{
    
    global void execute(SchedulableContext sc)
    {
        
        system.debug(' *** ENTERING NI_Scheduled_ServiceNowResendMessage.execute() - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<CronTrigger> lstBatch = new List<CronTrigger>();
        ServiceNowIncidentSettings__c ServiceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
        Integer Message_Interval = 10;
        
        if (Integer.valueOf(ServiceNowSettings.Resend_Failed_Message_Interval__c) != null)
        {
            Message_Interval = Integer.valueOf(ServiceNowSettings.Resend_Failed_Message_Interval__c);
        }
        
        lstBatch = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Resend_ServiceNowMessage'];			

        try
        {
            // CALLING BATCH TO PROCESS FAILED LOGS
            NI_BatchServiceNowResend resend = new NI_BatchServiceNowResend();
            
            if (lstBatch.size() == 0)
            {            
                // SETTING NAME OF BATCH WITH CALL AFTER(MIN) AND BATCH SIZE
                system.scheduleBatch(resend, 'Resend_ServiceNowMessage', Message_Interval, 50);
            }
            
            // ABORT "INIT" JOB
            system.abortJob(sc.getTriggerId());
            
        } 
        catch (Exception e)
        {
            system.debug(e.getMessage());
        }	
        
        system.debug(' *** EXITING NI_Scheduled_ServiceNowResendMessage.execute() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
}