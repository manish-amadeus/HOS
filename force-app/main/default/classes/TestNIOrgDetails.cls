/****************************************************************************************
Name            : TestNIOrgDetails Test Class
Author          : Sean Harris
Created Date    : 07/10/2012
Last Mod Date   : 09/12/2014
Last Mod By     : Stuart Emery
NICC Reference  : NICC-005291 - https://c.na4.visual.force.com/apex/ni_change_control_tabbed_layout?id=a0s60000003oX6NAAU
Description     : Test Class for tgrNIOrgDetailsToAccounts Trigger
                : 
                : 
******************************************************************************************/
@isTest
private class TestNIOrgDetails 
{
    static testMethod void testtgrNIOrgDetailsToAccounts()   
    {
        Account a = new Account(Name = 'Apex Test Account', BillingPostalCode = '03801', BillingCountry = 'US', BillingState = 'NH', BillingStreet = '75 NH Ave', BillingCity = 'Portsmouth', Type = 'Customer');
        insert a;

      //GET THE ORGANIZATION ID OF THE CURRENT USER.  ADDED PER NICC-011439  
        String orgId = UserInfo.getOrganizationId();
        orgId = orgId.substring(0, 15); //SET THE ORGID TO THE 15 CHARACTER ORGID
        System.debug('ORGID: ' + orgId);
        
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Org_Details__c' AND Name = 'LOD Support Admin' AND isActive = true];
        NI_Org_Details__c d = new NI_Org_Details__c(ParentAccountId__c = a.Id, RecordTypeId = rt.Id, Org_Type__c = 'Salesforce Production', Org_ID__c = orgId); 
        insert d;
    }
}