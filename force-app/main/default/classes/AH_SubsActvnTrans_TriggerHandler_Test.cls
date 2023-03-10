/****************************************************************************************
Name            : AH_SubsActvnTrans_TriggerHandler_Test 
Author          : Stuart Emery
Created Date    : 9/11/2017
Last Mod Date   : 9/19/2017
Last Mod By     : Stuart Emery
NICC Reference  : NICC-023846
Description     : test Class for AH_SubsActvnTrans_TriggerHandler Class
                : 
                : 
******************************************************************************************/
@isTest
public class AH_SubsActvnTrans_TriggerHandler_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {

        system.debug(' *** AH_SubsActvnTrans_TriggerHandler_Test.createTestData() - START ***'); 

        test.startTest();  
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtSalesOrderId = OpportunityRecordTypeInfo.get('Sales Order').getRecordTypeId(); 
        Id rtHRMAMOId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId(); 
        
        // CREATE A TEST ACCOUNT RECORD FOR THE 'ACCOUNT' FIELD ON THE SUBSCRIPTION ACTIVATION RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST ACCOUNT'; 
        insert a;
        
        //CREATE A TEST PRODUCT GROUP
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        //CREATE A TEST PRODUCT
        Product2 p = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Support');
        p.Apttus_Config2__HasOptions__c = false;
        insert p;
        
        //GET THE ID FOR THE STANDARD PRICEBOOK
        Id pbkId = Test.getStandardPricebookId(); 
        
        //CREATE A TEST PRICEBOOK ENTRY RECORD
        PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry(pbkId, p.Id, 1000);
        insert pbe;
        
        //CREATE A TEST OPPORTUNITY
        Opportunity opp = NI_TestClassData.createTestOpportunity(1, a.Id);
        opp.RecordTypeId = rtHRMAMOId;
        opp.Name = 'APEX TEST OPPORTUNITY';
        insert opp;
        
        //CREATE A TEST OPPORTUNITY LINE ITEM
        OpportunityLineItem oli = NI_TestClassData.createTestOpportunityLineItem(1, opp.Id, pbe.Id, 1);
        insert oli;
        
        // CREATE A TEST SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c sa = NI_TestClassData.createSubscriptionActivation();
        sa.Opportunity__c = opp.Id;
        sa.Product_ID__c = oli.Id;
        sa.Account__c = a.Id;
        sa.Product_Code__c = 'APEX-TEST-01';
        insert sa;
     
        // CREATE ANOTHER PRODUCT
        Product2 prd2 = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-02', 'Subscription'); 
        insert prd2;
        
        // CREATE A TEST PRODUCT MIGRATION RECORD
		AH_Product_Migration__c pm = NI_TestClassData.createProductMigration(a.Id, opp.Id, prd2.Id, p.Id);
        insert pm;
        
        test.stopTest();
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_SubsActvnTrans_TriggerHandler_Test.createTestData');  
        system.debug(' *** AH_SubsActvnTrans_TriggerHandler_Test.createTestData() - END ***'); 
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD BEFORE INSERT: 
    // ======================================================================================================================================= 
    @isTest static void SubActivTransactionTrigBeforeInsert() 
    {    
        
        system.debug(' *** AH_SubsActvnTrans_TriggerHandler_Test.SubActivTransactionTrigBeforeInsert() - START ***');
                
        test.startTest();  

        //GET THE INSERTED SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c sa = [SELECT Id, Account__c FROM Subscription_Activation__c];
        
        //CREATE A TEST SUBSCRIPTION ACTIVATION TRANSACTION RECORD
        Subscription_Activation_Transaction__c sat = NI_TestClassData.createSubscriptionActivationTransaction(sa.Id);
        insert sat;        
        
        //GET THE INSERTED SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation_Transaction__c satInserted = [SELECT Id, Subscription_Activation_No__c, Related_Account__c  
                                                              FROM Subscription_Activation_Transaction__c];        
        
        //VERIFY THE RELATED ACCOUNT ON THE SUBSCRIPTION ACTIVATION TRANSACTION RECORD MATCHES THE ACCOUNT ON THE SUBSCRIPTION ACTIVATION RECORD 
        system.AssertEquals(sa.Account__c, satInserted.Related_Account__c);

        test.stopTest();  
                
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_SubsActvnTrans_TriggerHandler_Test.SubActivTransactionTrigBeforeInsert');        
        system.debug(' *** AH_SubsActvnTrans_TriggerHandler_Test.SubActivTransactionTrigBeforeInsert() - END ***'); 

    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD BEFORE INSERT HAS A RELATED ACCOUNT: 
    // ======================================================================================================================================= 
    @isTest static void SubActivTransactionTrigBeforeInsertHasAccount() 
    {    
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST ACCOUNT']; 
        
        test.startTest();  
        
        system.debug(' *** AH_SubsActvnTrans_TriggerHandler_Test.SubActivTransactionTrigBeforeInsertHasAccount() - START ***');
        
        //GET THE INSERTED SUBSCRIPTION ACTIVATION RECORD
        Subscription_Activation__c sa = [SELECT Id, Account__c FROM Subscription_Activation__c];
        
        //CREATE A TEST SUBSCRIPTION ACTIVATION TRANSACTION RECORD
        Subscription_Activation_Transaction__c sat = NI_TestClassData.createSubscriptionActivationTransaction(sa.Id);
        sat.Related_Account__c = sa.Account__c; 
        insert sat;

        //GET THE INSERTED SUBSCRIPTION ACTIVATION TRANSACTION RECORD 
        Subscription_Activation_Transaction__c satInserted = [SELECT Id, Subscription_Activation_No__c, Related_Account__c, Related_Account_Partner_Updated__c, Related_Account__r.Name
                                                              FROM Subscription_Activation_Transaction__c];
        
        
        //VERIFY THE RELATED ACCOUNT ON THE SUBSCRIPTION ACTIVATION TRANSACTION RECORD MATCHES THE ACCOUNT ON THE SUBSCRIPTION ACTIVATION RECORD 
        // Not a valid test anymore since change in NICC-033935
        //system.AssertEquals(satInserted.Related_Account__r.Name, satInserted.Related_Account_Partner_Updated__c);
        
        // UPDATE DATE SUBSCRIPTION ACTIVATION TRANSACTION RECORD 
        Date dt = system.Date.today();
        sat.Date__c = dt;
        update sat;
            
        // ASSERT THE LIVE DATE WAS UPDATED 
        AH_Product_Migration__c pm = [SELECT Id, Live_Date__c FROM AH_Product_Migration__c WHERE Account__c =: a.Id];
        system.assertEquals(dt, pm.Live_Date__c);
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_SubsActvnTrans_TriggerHandler_Test.SubActivTransactionTrigBeforeInsertHasAccount');        
        system.debug(' *** AH_SubsActvnTrans_TriggerHandler_Test.SubActivTransactionTrigBeforeInsertHasAccount() - END ***'); 
        
        test.stopTest();  
        
    }        
    
}