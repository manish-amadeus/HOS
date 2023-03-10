/****************************************************************************************
Name            : NI_Orgs_Additional_Logins_Logs_Test Class
Author          : Swapnil Patil
Created Date    : 7/31/2016
Last Mod Date   : 8/31/2016
Last Mod By     : Stuart Emery
NICC Reference  : NICC-019058
Description     : Test Class for the Controller for the 
                : NI_Orgs_Additional_Logins_Logs Controller.
                : This controller creates an NI Org Details Additional Logins Log record
                : everytime an Org Details Additional Login record is viewed
                : There is an override on the standard "View" page to redirect to the 
                : NI Orgs Additional Logins Logs Visualforce page                
******************************************************************************************/
@isTest
public class NI_Orgs_Additional_Logins_Logs_Test {
    static testMethod void validateLogins() {
        
        //system.runAs(user, block)
        Account a = new Account(Name = 'Apex Test Account', BillingPostalCode = '03801', BillingCountry = 'US', BillingState = 'NH', BillingStreet = '75 NH Ave', BillingCity = 'Portsmouth', Type = 'Customer');
        insert a;

        //GET THE ORGANIZATION ID OF THE CURRENT USER.  ADDED PER NICC-011439  
        String orgId = UserInfo.getOrganizationId();
        orgId = orgId.substring(0, 15); //SET THE ORGID TO THE 15 CHARACTER ORGID
        System.debug('ORGID: ' + orgId);
        
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Org_Details__c' AND Name = 'LOD Support Admin' AND isActive = true];
        NI_Org_Details__c d = new NI_Org_Details__c(ParentAccountId__c = a.Id, RecordTypeId = rt.Id, Org_Type__c = 'Salesforce Production', Org_ID__c = orgId); 
        insert d;
        
        
        NI_Org_Details_Additional_Logins__c nlogin = new NI_Org_Details_Additional_Logins__c();
        
        nlogin.NI_Org_Details__c = d.id;
        nlogin.Type__c = 'PMS';
        nlogin.Login_Name_Encrypted__c = 'tlogin';
        nlogin.Security_Token_Encrypted__c = '123456';
        
        insert nlogin;
        Apexpages.Standardcontroller stdTra = new Apexpages.Standardcontroller(nlogin);
         
        NI_Orgs_additional_Logins_Logs nlogs = new NI_Orgs_additional_Logins_Logs(stdTra);
        nlogs.insertViewDetail();
        
    }
}