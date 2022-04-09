/************************************************************************************************
Name            : DTS_Integration_Logger Class
Created By      : Ganesh Bora
Created Date    : 02/17/2022
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-056411
Description     : Class that contains static method for writing apex and custom log messages
                : to the custom object DTS_Integration_Log_c
				: Concept replicated from NI_Error_Logger.cls
*************************************************************************************************/
public class DTS_Integration_Logger
{
    
    public static void WriteToLog(string strMessage, string strObjectName, string strClassName, string strDMLType, string strLogType)    
    {    
        
        system.debug(' *** ENTERING DTS_Integration_Logger.WriteToLog() #1 - QUERIES ISSUED = ' + Limits.getQueries());
        
        system.debug(' **** Params: (' + strMessage + '), (' + strObjectName + '), (' + strClassName + '), (' + strDMLType + ')');        
        
        try
        {
           
            /*DTS_Integration_Log__c log = new DTS_Integration_Log__c();
            log.Summary__c = 'Object :'+strObjectName+'Apex Class : '+strClassName+'DML Type:'+strDMLType+' Message:'+strMessage;
			log.Type__c = strLogType;
            log.Date_Time__c = Datetime.now();
            log.Integration_Status__c = 'Active';            
            insert log;*/
			
        } 
        catch (Exception ex) 
        {
            system.debug(' ****Error Occured: ' + ex.getMessage());
        }            
        system.debug(' *** EXITING DTS_Integration_Logger.WriteToLog() #1 - QUERIES ISSUED = ' + Limits.getQueries());
    }
}