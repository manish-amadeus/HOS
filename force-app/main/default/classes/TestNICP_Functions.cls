/****************************************************************************************
Name            : TestNICP_Functions Class
Author          : Sean Harris
Created Date    : 07/11/2012
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-005289 - https://c.na4.visual.force.com/apex/ni_change_control_tabbed_layout?id=a0s60000003oX0yAAE
Description     : NICP_Functions Test Class
                : 
                : 
******************************************************************************************/
@isTest
private class TestNICP_Functions
{

    static testMethod void testPreChat()   
    {

        //Profile p = [SELECT Id FROM Profile WHERE Name =: 'Customer Portal Manager Standard'];
        //User u = [SELECT id FROM User WHERE ProfileId =: p.Id AND IsActive = true AND AccountId != null LIMIT 1];
        User u = [SELECT id FROM User WHERE IsActive = true LIMIT 1];

        System.runAs(u) 
        {

            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());

            PageReference ref = Page.NICP_PreChat;
            Test.setCurrentPage(ref);         
            NICP_Functions controller = new NICP_Functions(new ApexPages.StandardController(u));
            string an = controller.getAccountName;

        }

    }
    
}