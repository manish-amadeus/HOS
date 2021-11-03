/****************************************************************************************
Name            : NI_CR_Engagement_TriggerHandler_Test Class
Author          : Sean Harris
Created Date    : 04/08/2014
Last Mod Date   : 06/08/2014
Last Mod By     : Sean Harris
NICC Reference  : NICC-010052 - Customer Relations Engagement Project (TrackIt 110696) 
Description     : 
                : 
                : 
******************************************************************************************/
@isTest //(SeeAllData=true)
public class NI_CR_Engagement_TriggerHandler_Test
{ 

    public static testMethod void testTrigHandler() 
    {

// NOTE: THIS CODE IS BOMBING. THROWS: System.QueryException: List has no rows for assignment to SObject
        // Methods defined as TestMethod do not support Web service callouts, test skipped
        // ADDED PER FINANCIALFORCE SUPPORT TO PREVENT WEB SERVICES CALL OUT MESSAGE WHEN RUNNING TEST CLASSES THAT INVOLVE THE CONTACT OBJECT 
//        pse__Triggers__c pt = [SELECT Id, pse__Resource_Geolocation_Trigger_Disabled__c FROM pse__Triggers__c];
//        pt.pse__Resource_Geolocation_Trigger_Disabled__c = true;
//        update(pt);
            
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        insert cnt;
                     
        Account a2 = NI_TestClassData.createTestAccount(2);
        insert a2;
        
        Contact cnt2 = NI_TestClassData.createTestContact(2, a2.Id);
        insert cnt2;
                             
                        
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;

        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-001', 'Subscription');
        insert prd;
        
        Asset asset = NI_TestClassData.createTestAsset(1, a.Id, prd.Id);
        asset.Product_Group__c = pgp.Id;
        insert asset;
             
        NI_Customer_Relations_Engagement__c ni_cr_engagemnt = NI_TestClassData.createCustomerRelationsEngagement(1, a.Id, cnt.Id);
        
        // TRIGGER OnAfterInsert 
        insert ni_cr_engagemnt; 
        
        // TRIGGER OnBeforeUpdate & OnAfterUpdate
        ni_cr_engagemnt.Asset__c = asset.Id;
        update ni_cr_engagemnt;
        
        ni_cr_engagemnt.Account__c = a2.Id;
        ni_cr_engagemnt.Engagement_Contact__c = cnt2.Id;
        update ni_cr_engagemnt;
        
        ni_cr_engagemnt.Status__c = 'Closed - Hidden';
        update ni_cr_engagemnt;
        
    }
    
    public static testMethod void testBulkTester() 
    {
            
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        insert cnt;
        
        /*     
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;

        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-001', 'Subscription');
        insert prd;
        
        Asset asset = NI_TestClassData.createTestAsset(1, a.Id, prd.Id);
        asset.Product_Group__c = pgp.Id;
        insert asset;
        */
           
        List<NI_Customer_Relations_Engagement__c> lstNICRE = new List<NI_Customer_Relations_Engagement__c>();
        
        // LOOP THROUGH AND CREATE 200 ICESubscription__c, ICEProperty__c, ICEUser__c RECORDS 
        for (integer j = 1; j < 201; j++)
        {
            NI_Customer_Relations_Engagement__c ncre = new NI_Customer_Relations_Engagement__c();
            ncre.Type__c = 'Reactive';
            ncre.Account__c = a.Id;
            ncre.Engagement_Contact__c = cnt.Id;
            ncre.Summary__c = 'Apex Test #' + String.valueOf(j);  
            lstNICRE.Add(ncre);
        }
        
        // ASSERT THAT ALL 200 NI_Customer_Relations_Engagement__c RECORDS INSERTED  
        Database.Insert(lstNICRE);
        List<NI_Customer_Relations_Engagement__c> lstNICRETest = new List<NI_Customer_Relations_Engagement__c>([SELECT Id FROM NI_Customer_Relations_Engagement__c WHERE Account__c = : a.Id]);        
        System.assertEquals(lstNICRETest.Size(), 200, 'Bulk test failed because lstNICRETest.Size() is not equal to 200');
        
    }

    //COVERAGE FOR TRIGGERHANDLER PLACEHOLDER EVENTS  
    public static testMethod void testPlaceholders()  
    {   
        NI_CR_Engagement_TriggerHandler handler = new NI_CR_Engagement_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext; 
        List<NI_Customer_Relations_Engagement__c> lst = new List<NI_Customer_Relations_Engagement__c>();
        Map<Id, NI_Customer_Relations_Engagement__c> mp = new Map<Id, NI_Customer_Relations_Engagement__c>();
        handler.OnBeforeInsert(lst);
        handler.OnBeforeUpdate(lst, mp);
        handler.OnBeforeDelete(lst);        
        handler.OnAfterUpdate(lst, mp);        
        handler.OnAfterDelete(lst);
        handler.OnAfterUnDelete(lst);
    }    
    
}