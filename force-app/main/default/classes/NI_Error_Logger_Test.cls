/****************************************************************************************
Name            : NI_Error_Logger_Test Class
Author          : Sean Harris
Created Date    : 04/19/2013
Last Mod Date   : 04/23/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for NI_Error_Logger
                : NICC-034313 - Added WriteToLogwithOrgDetailId() method back after accidental overwrite
                : 
******************************************************************************************/
@isTest 
public class NI_Error_Logger_Test
{

    public static testMethod void testNIErrorLogger() 
    {
        NI_Error_Logger.WriteToLog('An error has occurred!', 'NI_MYOBJECT', 'NI_MYCLASS', 'Insert'); 
        NI_Error_Logger.WriteToLog('An error has occurred!', 'NI_MYOBJECT', 'NI_MYCLASS', 'Insert', UserInfo.getUserId(), null);    
    	NI_Error_Logger.WriteToLogwithOrgDetailId(null, 'An error has occurred!', 'NI_MYOBJECT', 'NI_MYCLASS', 'Insert');
    }
    
}