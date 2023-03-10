/***********************************************************************************************
Name            : AH_DTS_Integration_Logger_Test
Author          : Sean Harris
Created Date    : 08/27/2022
Last Mod Date   : 08/27/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for AH_DTS_Integration_Logger_Test 
                : 
                : 
// AH_DTS_Integration_Logger.writeToDTSLog(dLogDateTime,sIntegrationName,sIntegrationStatus,sType,sSummary,sDetails,sIssueSeverity,sJobProcessId,sJobProcessName,sJobProcessType,sHostNameOrIP,bBiz2Resolve,bWillSelfResolve)            
AH_DTS_Integration_Logger.writeToDTSLog(system.now(), 'Medallia - Apex Job', 'Active', 'Error', 'Error Scheduling Apex Job', e.getMessage(), '3 - Medium', UserInfo.getUserName(), 'AH_MedalliaSurvey_Schedule', 'Apex Job Scheduling', 'Salesforce', true, false);
************************************************************************************************/
@isTest
public class AH_DTS_Integration_Logger_Test 
{

    @isTest static void test1()
    {

        // ASSERT THAT ZERO DTS_Integration_Log__c RECORDS EXIST 
        List<DTS_Integration_Log__c> lstAssert0 = new List<DTS_Integration_Log__c>([SELECT Id FROM DTS_Integration_Log__c]);
        system.assertEquals(0, lstAssert0.size());
        
        try
        {
            // TRIGGER A TRY CATCH EXCEPTION
            integer j = (1 / 0);
        }
        catch (Exception e)
        {
            AH_DTS_Integration_Logger.writeToDTSLog(system.now(), 'Medallia - Apex Job', 'Active', 'Error', 'Error Scheduling Apex Job', e.getMessage(), '3 - Medium', UserInfo.getUserName(), 'AH_MedalliaSurvey_Schedule', 'Apex Job Scheduling', 'Salesforce', true, false);
        }
        
        // ASSERT THAT THE ABOVE TRY CATCH CREATED A DTS_Integration_Log__c RECORD 
        List<DTS_Integration_Log__c> lstAssert1 = new List<DTS_Integration_Log__c>([SELECT Id FROM DTS_Integration_Log__c]);
        system.assertEquals(1, lstAssert1.size());
        
        // TRIGGER A TRY CATCH EXCEPTION IN AH_DTS_Integration_Logger FOR COVERAGE AND ASSERTIONS
        string strToLong = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890|1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890|1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        AH_DTS_Integration_Logger.writeToDTSLog(system.now(), 'Medallia - Apex Job', 'Active', 'Error', strToLong, 'Sum ting wong', '3 - Medium', UserInfo.getUserName(), 'AH_MedalliaSurvey_Schedule', 'Apex Job Scheduling', 'Salesforce', true, false);
        
		// ASSERT THAT THE ABOVE INSERT ATTEMPT DID NOT CREATE AN ADDITIONAL DTS_Integration_Log__c RECORD 
        List<DTS_Integration_Log__c> lstAssert2 = new List<DTS_Integration_Log__c>([SELECT Id FROM DTS_Integration_Log__c]);
        system.assertEquals(1, lstAssert2.size());
        
    }
 
}