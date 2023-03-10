/*************************************************************************************************************
Name            : DTS_Integration_Logger Class
Created By      : Ganesh Bora
Created Date    : 02/17/2022
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-056411
Description     : Class that contains static methods for writing apex and custom log messages
                : Note:After making ang changes to This Class Schedule the Dependent Cron job Again 
				  // CODE TO SCHEDULE THIS IN EXEC ANON
                  System.schedule('SCIM Scheduler 1',  '0 00 * * * ?', new AH_SCIM_UserSyncCallout_Schedule());
                  System.schedule('SCIM Scheduler 2',  '0 15 * * * ?', new AH_SCIM_UserSyncCallout_Schedule());
                  System.schedule('SCIM Scheduler 3',  '0 30 * * * ?', new AH_SCIM_UserSyncCallout_Schedule());
                  System.schedule('SCIM Scheduler 4',  '0 45 * * * ?', new AH_SCIM_UserSyncCallout_Schedule());
				  //
**************************************************************************************************************/
global class DTS_Integration_Logger
{
    
    // For Valamis Integration
    public static void WriteToLogValamis(string strMessage, string strObjectName, string strClassName, string strDMLType, string strLogType,String strIntegrationName)    
    {    
        try
        {
           
            DTS_Integration_Log__c log = new DTS_Integration_Log__c();
            log.Summary__c = 'Object: ' + strObjectName + 'Apex Class: ' + strClassName + 'DML Type: ' + strDMLType + ' Message: ' + strMessage;
			log.Type__c = strLogType;
            log.Date_Time__c = Datetime.now();
            log.Integration_Status__c = 'Active';
			log.Integration_Name__c = strIntegrationName;            
            insert log; 
        } 
        catch (Exception ex) { 
            system.debug(' ****Error Occured: ' + ex.getMessage()); 
        }
    }

    public static void WriteToLog(string strMessage, string strObjectName, string strClassName, string strDMLType, string strLogType)    
    {    
        
        system.debug(' *** ENTERING DTS_Integration_Logger.WriteToLog() #1 - QUERIES ISSUED = ' + Limits.getQueries());
        
        system.debug(' **** Params: (' + strMessage + '), (' + strObjectName + '), (' + strClassName + '), (' + strDMLType + ')');        
        
        try
        {
           
            DTS_Integration_Log__c log = new DTS_Integration_Log__c();
            log.Summary__c = 'Object :'+strObjectName+'Apex Class : '+strClassName+'DML Type:'+strDMLType+' Message:'+strMessage;
			log.Type__c = strLogType;
            log.Date_Time__c = Datetime.now();
            log.Integration_Status__c = 'Active';            
            insert log;
			
        } 
        catch (Exception ex) 
        {
            system.debug(' ****Error Occured: ' + ex.getMessage());
        }            
        system.debug(' *** EXITING DTS_Integration_Logger.WriteToLog() #1 - QUERIES ISSUED = ' + Limits.getQueries());
    }	
}