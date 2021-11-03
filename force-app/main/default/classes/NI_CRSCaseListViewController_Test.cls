/****************************************************************************************
Name            : NI_CRSCaseListViewController_Test Test Class
Author          : Sean Harris
Created Date    : 1/15/2017
Last Mod Date   : 1/15/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : test Class for NI_CRSCaseListViewController Class
                : 
                : 
******************************************************************************************/
@isTest
public class NI_CRSCaseListViewController_Test 
{
    static testMethod void testCRSCaseListViewCtlr() 
    {
        Test.startTest();
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        test.stopTest();
        NI_CRSCaseListViewController c = new NI_CRSCaseListViewController();
    }
}