/*************************************************************************************************
Name            : NIUtil_TabURLsTestClass Test Class
Author          : Sean Harris
Created Date    : 02/03/2012
Last Mod Date   : 02/05/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
*************************************************************************************************/
@isTest
private class NIUtil_TabURLsTestClass
{

    static testMethod void NIUtil_TabURLsTest1() 
    {
        PageReference pageRef = Page.NIUtil_TabURLs;
        Test.setCurrentPage(pageRef);
        NIUtil_TabURLs ctrl = new NIUtil_TabURLs(); 
        Test.startTest();
        ctrl.strKeyword = 'account';
        ctrl.doSearch();
        Test.stopTest();
    }
    
}