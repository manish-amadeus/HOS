/***********************************************************************************************
Name            : AH_DTS_Integration_Logger
Author          : Sean Harris
Created Date    : 08/27/2022
Last Mod Date   : 08/27/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class used for logging Successes and Failures related to Integrations  
                : 
                : 
// AH_DTS_Integration_Logger.writeToDTSLog(dLogDateTime,sIntegrationName,sIntegrationStatus,sType,sSummary,sDetails,sIssueSeverity,sJobProcessId,sJobProcessName,sJobProcessType,sHostNameOrIP,bBiz2Resolve,bWillSelfResolve)            
AH_DTS_Integration_Logger.writeToDTSLog(system.now(), 'Medallia - Apex Job', 'Active', 'Error', 'Error Scheduling Apex Job', e.getMessage(), '3 - Medium', UserInfo.getUserName(), 'AH_MedalliaSurvey_Schedule', 'Apex Job Scheduling', 'Salesforce', true, false);
************************************************************************************************/
public class AH_DTS_Integration_Logger 
{

    public static void writeToDTSLog(datetime dLogDateTime, 	// Server-side timestamp for the log
                                     string sIntegrationName, 	// Integration that generated this log
                                     string sIntegrationStatus,	// Status of the integration at the time of this log ('Active', 'Failure', 'Inactive') 
                                     string sType,				// Type of incident or situation reported in the log ('Data Validation', 'Debug', 'Error', 'Failure', 'Information', 'Success', 'Warning')
                                     string sSummary,			// Summary of the information reported in the log
                                     string sDetails,			// Contents of the log
                                     string sIssueSeverity,		// Severity of the issues(s) reported in the log ('1 - Critical', '2 - Urgent', '3 - Medium', '4 - Minor')
                                     string sJobProcessId,		// ID of the job or integration sub-process that generated the log
                                     string sJobProcessName,	// Name of the job or integration sub-process that generated the log
                                     string sJobProcessType,	// Type of job or integration process that generated the log
                                     string sHostNameOrIP,		// Host name or IP Address of environment that generated the log
                                     boolean bBiz2Resolve, 		// Assistance from outside DTS/CBS is required to resolve the issue.
                                     boolean bWillSelfResolve	// The issue reported will be resolved when the job or process runs again.
                                    )
    {
        try
        {
            DTS_Integration_Log__c log = new DTS_Integration_Log__c();
            log.Date_Time__c = dLogDateTime;
            log.Integration_Name__c = sIntegrationName;
            log.Integration_Status__c = sIntegrationStatus;
            log.Type__c = sType;
            log.Summary__c = sSummary;
            log.Details__c = sDetails;
            log.Issue_Severity__c = sIssueSeverity; 
            log.Job_Process_ID__c = sJobProcessId; 
            log.Job_Process_Name__c = sJobProcessName;
            log.Job_Process_Type__c = sJobProcessType;
            log.Host_Name_IP__c = sHostNameOrIP;    
            log.Requires_Business_Assistance_to_Resolve__c = bBiz2Resolve;
            log.Will_Resolve_Upon_Next_Execution__c = bWillSelfResolve;       
            insert log;
        }
        catch (Exception ex)
        {
            system.debug(' ERROR CREATING DTS INTEGRATION LOG RECORD!: ' + ex.getMessage());
        }
        
    }
 
/*    
    @InvocableMethod(label='writeToDTSLog' description='Accepts a collection (List) of uncommited DTS_Integration_Log__c record for insertion under system context.')
    public static void writeToDTSLog(List<DTS_Integration_Log__c> lst)
    {
        try
        {
            database.insert(lst);
        } 
        catch (Exception ex) 
        { 
            system.debug(ex.getMessage()); 
        } 
    }
*/    
}