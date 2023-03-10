/****************************************************************************************
Name            : NI_FailedMessages_Test Test Class
Author          : Sean Harris
Created Date    : 1/15/2017
Last Mod Date   : 1/15/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : test Class for NI_FailedMessages Class
                : 
                : 
******************************************************************************************/
@isTest
public class NI_FailedMessages_Test 
{

    static testMethod void testFailedMessages() 
    {
        Test.startTest();
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        test.stopTest();
        NI_FailedMessages f = new NI_FailedMessages();
    }
    
}