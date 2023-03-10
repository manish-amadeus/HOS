/****************************************************************************************
Name            : Salesforce_User_TrgrHndlr_Test
Author          : Supriya Galinde
Created Date    : 2/16/2017
Last Mod Date   : 3/15/2017
Last Mod By     : Supriya Galinde
NICC Reference  : 
Description     : Test class for Salesforce_User_TriggerHandler
                : 
                : 
******************************************************************************************/
@isTest
public class Salesforce_User_TrgrHndlr_Test 
{ 
    
    public static testmethod void testBeforeInsertUpdate()
    {
        
        // GET RECORD TYPE OF NI_Org_Details__c
        Id rtInit = NI_TestClassData.getRecordTypeId('NI_Org_Details__c', 'LOD Support Admin');
        
        // CREATE TEST ACCOUNT
        List<Account> accList = new List<Account>();
        Account a = NI_TestClassData.createTestAccount(1);
        accList.add(a);
        
        Account a2 = NI_TestClassData.createTestAccount(2);
        accList.add(a2);
        insert accList;
        
        // GET THE ORGANIZATION ID OF THE CURRENT USER  
        String orgId = UserInfo.getOrganizationId();
        orgId = orgId.substring(0, 15); //SET THE ORGID TO THE 15 CHARACTER ORGID
        
        //CREATE TEST ORGS
        List<NI_Org_Details__c> orgDetailsList = new List<NI_Org_Details__c>();
        NI_Org_Details__c od = NI_TestClassData.createTestNiOrgDetails(rtInit, 1, 'Salesforce Production');
        orgDetailsList.add(od);
        
        NI_Org_Details__c od2 = NI_TestClassData.createTestNiOrgDetails(rtInit, 2, 'Salesforce Production');
        orgDetailsList.add(od2);
        insert orgDetailsList; 
        
        // CREATE TEST NI_Org_Details_to_Accounts__c
        List<NI_Org_Details_to_Accounts__c> niOrgDetails2AccList  = new List<NI_Org_Details_to_Accounts__c>();
        NI_Org_Details_to_Accounts__c orgAcc1 = NI_TestClassData.createTestNIOrgDetails2Accounts(od.Id, a.Id);
        orgAcc1.Status__c = 'Active';
        niOrgDetails2AccList.add(orgAcc1);
        
        NI_Org_Details_to_Accounts__c orgAcc2 = NI_TestClassData.createTestNIOrgDetails2Accounts(od.Id, a2.Id);
        orgAcc2.Status__c = 'Active';
        niOrgDetails2AccList.add(orgAcc2);
        insert niOrgDetails2AccList;
        
        // CREATE TEST BILLING CONTRACT
        List<Billing_Contract__c> billingConList  = new List<Billing_Contract__c>();
        Billing_Contract__c b1 = new Billing_Contract__c();
        b1.Name = 'Billing-Contract-1';
        b1.Account__c = a.Id;
        billingConList.add(b1);
        
        Billing_Contract__c b2 = new Billing_Contract__c();
        b2.Name = 'Billing-Contract-2';
        b2.Account__c = a2.Id;
        billingConList.add(b2);
        insert billingConList;
        
        // CREATE TEST PRODUCT GROUP
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        // CREATE TEST DI INDEX
        NI_DeploymentInstanceIndex__c diIdx1 = new NI_DeploymentInstanceIndex__c();
        diIdx1.Name = 'Delphi.fdc';
        insert diIdx1;
        
        // CREATE TEST PRODUCT
        Product2 p2_1 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Support');
        p2_1.DI_Index__c = diIdx1.Id;
        p2_1.Limited_User__c = true;
        p2_1.Apttus_Config2__HasOptions__c = false;
        p2_1.Product_Line_Global__c = 'Delphi.fdc';
        insert p2_1;        
        
        // CREATE TEST ACTIVITY LINE ITEM
        List<Activity_Line_Item__c> activityLineItemLst = new List<Activity_Line_Item__c>();
        Activity_Line_Item__c ali1 = new Activity_Line_Item__c();
        ali1.Billing_Contract__c = b1.Id;
        ali1.Units__c = 10;
        ali1.Contract_Start_Date__c = Date.today().addDays(-10);
        ali1.Status__c = 'Active';
        ali1.Product__c = p2_1.Id;
        activityLineItemLst.add(ali1);
        
        // CREATE TEST ACTIVITY LINE ITEM
        Activity_Line_Item__c ali2 = new Activity_Line_Item__c();
        ali2.Billing_Contract__c = b2.Id;
        ali2.Units__c = 10;
        ali2.Contract_Start_Date__c = Date.today().addDays(-10);
        ali2.Status__c = 'Active';
        ali2.Product__c = p2_1.Id;
        activityLineItemLst.add(ali2);
        
        // CREATE TEST ACTIVITY LINE ITEM
        Activity_Line_Item__c ali3 = new Activity_Line_Item__c();
        ali3.Billing_Contract__c = b2.Id;
        ali3.Contract_Start_Date__c = Date.today().addDays(-10);
        ali3.Status__c = 'Active';
        ali3.Product__c = p2_1.Id;
        activityLineItemLst.add(ali3);
        insert activityLineItemLst;  

        // CREATE TEST SALESFORCE USER TO CHECK BEFORE INSERT TRIGGER
        Salesforce_User__c user1 = new Salesforce_User__c();
        user1.OrgName__c = od.Id;
        insert user1;
        
        // CREATE TEST SALESFORCE USER TO CHECK BEFORE INSERT TRIGGER
        Salesforce_User__c user2 = new Salesforce_User__c();
        user2.OrgName__c = od2.Id;
        insert user2;
        
        // UPDATE USERNAME TO CHECK BEFORE UPDATE TRIGGER
        user1.UserName__c = 'testUserName';
        update user1;
        
        List<NI_Org_Details__c> odList = [SELECT Id, Purchased_Limited_Users__c FROM NI_Org_Details__c WHERE Org_Name__c = 'TEST1' LIMIT 1];
        system.assertEquals(20, odList[0].Purchased_Limited_Users__c);
        
    }
/*    
    public static testmethod void testBulkInsertUpdate()
    {
        
        // GET RECORD TYPE OF NI_Org_Details__c
        Id rtInit = NI_TestClassData.getRecordTypeId('NI_Org_Details__c', 'LOD Support Admin');
        
        // CREATE TEST ACCOUNT
        List<Account> accList = new List<Account>();
        Account a = NI_TestClassData.createTestAccount(1);
        accList.add(a);
        
        Account a2 = NI_TestClassData.createTestAccount(2);
        accList.add(a2);
        
        Account a3 = NI_TestClassData.createTestAccount(3);
        accList.add(a3);
        
        Account a4 = NI_TestClassData.createTestAccount(4);
        accList.add(a4);
        insert accList;

        // CREATE TEST ORGS
        List<NI_Org_Details__c> orgDetailsList = new List<NI_Org_Details__c>();
        NI_Org_Details__c od = NI_TestClassData.createTestNiOrgDetails(rtInit, 3, 'Salesforce Production');
        orgDetailsList.add(od);
        
        NI_Org_Details__c od2 = NI_TestClassData.createTestNiOrgDetails(rtInit, 4, 'Salesforce Production');
        orgDetailsList.add(od2);
        
        NI_Org_Details__c od3 = NI_TestClassData.createTestNiOrgDetails(rtInit, 5, 'Salesforce Production');
        orgDetailsList.add(od3);
        insert orgDetailsList; 
        
        // CREATE TEST NI_Org_Details_to_Accounts__c
        List<NI_Org_Details_to_Accounts__c> niOrgDetails2AccList  = new List<NI_Org_Details_to_Accounts__c>();
        NI_Org_Details_to_Accounts__c orgAcc1 = NI_TestClassData.createTestNIOrgDetails2Accounts(od.Id, a.Id);
        orgAcc1.Status__c = 'Active';
        niOrgDetails2AccList.add(orgAcc1);
        
        NI_Org_Details_to_Accounts__c orgAcc2 = NI_TestClassData.createTestNIOrgDetails2Accounts(od.Id, a2.Id);
        orgAcc2.Status__c = 'Active';
        niOrgDetails2AccList.add(orgAcc2);
        
        NI_Org_Details_to_Accounts__c orgAcc3 = NI_TestClassData.createTestNIOrgDetails2Accounts(od3.Id, a3.Id);
        orgAcc3.Status__c = 'Active';
        niOrgDetails2AccList.add(orgAcc3);
        insert niOrgDetails2AccList;
        
        // CREATE TEST BILLING CONTRACT
        List<Billing_Contract__c> billingConList  = new List<Billing_Contract__c>();
        Billing_Contract__c b1 = new Billing_Contract__c();
        b1.Name = 'Billing-Contract-1';
        b1.Account__c = a.Id;
        billingConList.add(b1);
        
        Billing_Contract__c b2 = new Billing_Contract__c();
        b2.Name = 'Billing-Contract-2';
        b2.Account__c = a2.Id;
        billingConList.add(b2);
        insert billingConList;
        
        // CREATE TEST PRODUCT GROUP
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        // CREATE TEST DI INDEX
        NI_DeploymentInstanceIndex__c diIdx1 = new NI_DeploymentInstanceIndex__c();
        diIdx1.Name = 'Delphi.fdc';
        insert diIdx1;
        
        // CREATE TEST PRODUCT
        Product2 p2_1 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Support');
        p2_1.DI_Index__c = diIdx1.Id;
        p2_1.Limited_User__c = true;
        p2_1.Apttus_Config2__HasOptions__c = false;
        p2_1.Product_Line_Global__c = 'Delphi.fdc';
        insert p2_1;        
        
        // CREATE TEST ACTIVITY LINE ITEM
        List<Activity_Line_Item__c> activityLineItemLst = new List<Activity_Line_Item__c>();
        for (Integer i = 1 ; i <= 100 ; i++)
        {
            Activity_Line_Item__c ali1 = new Activity_Line_Item__c();
            ali1.Billing_Contract__c = b1.Id;
            ali1.Units__c = 1;
            ali1.Contract_Start_Date__c = Date.today().addDays(-10);
            ali1.Status__c = 'Active';
            ali1.Product__c = p2_1.Id;
            activityLineItemLst.add(ali1);
        }
        
        // CREATE TEST ACTIVITY LINE ITEM
        for (Integer i = 1 ; i <= 100 ; i++)
        {
            Activity_Line_Item__c ali2 = new Activity_Line_Item__c();
            ali2.Billing_Contract__c = b2.Id;
            ali2.Units__c = 1;
            ali2.Contract_Start_Date__c = Date.today().addDays(-10);
            ali2.Status__c = 'Active';
            ali2.Product__c = p2_1.Id;
            activityLineItemLst.add(ali2);
        }  
        
        insert activityLineItemLst; 
        
        List<Salesforce_User__c> usersList = new List<Salesforce_User__c>();
        for (Integer i = 1 ; i <= 200 ; i++)
        {
            Salesforce_User__c user1 = new Salesforce_User__c();
            user1.OrgName__c = od.Id;
            usersList.add(user1);
        }
        
        insert usersList;
        
        List<NI_Org_Details__c> odList = [SELECT Id, Purchased_Limited_Users__c FROM NI_Org_Details__c WHERE Org_Name__c = 'TEST3' LIMIT 1];
        system.assertEquals(200, odList[0].Purchased_Limited_Users__c);
        
    }
*/    
}