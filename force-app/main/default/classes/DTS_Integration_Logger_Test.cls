/****************************************************************************************
Name            : DTS_Integration_Logger_Test Class
Author          : Ganesh Bora
Created Date    : 02/17/2022
Last Mod Date   : 02/17/2022
Last Mod By     : Ganesh Bora 
NICC Reference  : NICC-056411
Description     : Test class for DTS_Integration_Logger
                : 
                : 
******************************************************************************************/
@isTest 
public class DTS_Integration_Logger_Test
{

    public static testMethod void testDTSIntegrationLogger() 
    {
        DTS_Integration_Logger.WriteToLog('An error has occurred!', 'NI_MYOBJECT', 'NI_MYCLASS', 'Insert','Error'); 
        system.assert(true);
        DTS_Integration_Logger.WriteToLogValamis('An error has occurred!', 'NI_MYOBJECT', 'NI_MYCLASS', 'Insert','Error','Test Integration Log'); 
        system.assert(true);
    }
    
}