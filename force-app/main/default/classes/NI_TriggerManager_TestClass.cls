/****************************************************************************************
Name            : NI_TriggerManager_TestClass Class
Author          : Sean Harris
Created Date    : 11/21/2012
Last Mod Date   : 03/22/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : test Class for NI_TriggerManager Class
                : 
                : 
******************************************************************************************/
@isTest 
private class NI_TriggerManager_TestClass 
{

    static testMethod void testSwitches() 
    {
      	
        system.assertEquals(true, NI_TriggerManager.isFirstTime);
        NI_TriggerManager.isFirstTime = false;
        system.assertEquals(false, NI_TriggerManager.isFirstTime);
        
        system.assertEquals(true, NI_TriggerManager.isFirstTimeCustService);
        NI_TriggerManager.isFirstTimeCustService = false;
        system.assertEquals(false, NI_TriggerManager.isFirstTimeCustService);
		             
        system.assertEquals(true, NI_TriggerManager.isFirstTimeCustDet);
        NI_TriggerManager.isFirstTimeCustDet = false;
        system.assertEquals(false, NI_TriggerManager.isFirstTimeCustDet);
        
        system.assertEquals(true, NI_TriggerManager.isBypassOppUdate);
        NI_TriggerManager.isBypassOppUdate = false;
        system.assertEquals(false, NI_TriggerManager.isBypassOppUdate);
        
        system.assertEquals(true, NI_TriggerManager.isValidOrgDetails);
        NI_TriggerManager.isValidOrgDetails = false;
        system.assertEquals(false, NI_TriggerManager.isValidOrgDetails);
        
        system.assertEquals(true, NI_TriggerManager.isFirstTimeCustAgreement);
        NI_TriggerManager.isFirstTimeCustAgreement = false;
        system.assertEquals(false, NI_TriggerManager.isFirstTimeCustAgreement);
        
        // NICC SWITCH TEST
        system.assertEquals(false, NI_TriggerManager.Bypass_NICC_Updates);
        NI_TriggerManager.Bypass_NICC_Updates = true;
        system.assertEquals(true, NI_TriggerManager.Bypass_NICC_Updates);
        
        // DEPLOYMENT INSTANCE SWITCH TEST
        system.assertEquals(false, NI_TriggerManager.isBypassDIUpdate);
        NI_TriggerManager.isBypassDIUpdate = true;
        system.assertEquals(true, NI_TriggerManager.isBypassDIUpdate);
        
        // OPPORTUNITY SWITCH TEST
        system.assertEquals(false, NI_TriggerManager.isOpportunityInvoked);
        NI_TriggerManager.isOpportunityInvoked = true;
        system.assertEquals(true, NI_TriggerManager.isOpportunityInvoked);
        
        // OPPORTUNITY LINE ITEM SWITCH TEST
        system.assertEquals(false, NI_TriggerManager.isOpptyLineItemInvoked);
        NI_TriggerManager.isOpptyLineItemInvoked = true;  
        system.assertEquals(true, NI_TriggerManager.isOpptyLineItemInvoked);
        
        system.assertEquals(false, NI_TriggerManager.isExecutingRollupAmount);
        NI_TriggerManager.isExecutingRollupAmount = true;
		system.assertEquals(true, NI_TriggerManager.isExecutingRollupAmount);
        
        system.assertEquals(1, NI_TriggerManager.intCauseDivByZero);
        NI_TriggerManager.intCauseDivByZero = 0;
		system.assertEquals(0, NI_TriggerManager.intCauseDivByZero);
        
        system.assertEquals(true, NI_TriggerManager.isFirstSoftraxBillingInsert);
        NI_TriggerManager.isFirstSoftraxBillingInsert = false;         
        system.assertEquals(false, NI_TriggerManager.isFirstSoftraxBillingInsert);
        
        system.assertEquals(false, NI_TriggerManager.bypassTriggersInvokedByCaseDML);
        NI_TriggerManager.bypassTriggersInvokedByCaseDML = true; 
        system.assertEquals(true, NI_TriggerManager.bypassTriggersInvokedByCaseDML);
        
		// CANCELLATION TRIGGER EXECUTION CONTROLLER TESTS
        system.assertEquals(true, NI_TriggerManager.isFirstSOChatterGroupPost);
        NI_TriggerManager.isFirstSOChatterGroupPost = false;         
		system.assertEquals(false, NI_TriggerManager.isFirstSOChatterGroupPost);
        
        system.assertEquals(true, NI_TriggerManager.is1stInsert_Cancellation);
        NI_TriggerManager.is1stInsert_Cancellation = false; 
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Cancellation);
        
        system.assertEquals(true, NI_TriggerManager.is1stUpdate_Cancellation);
        NI_TriggerManager.is1stUpdate_Cancellation = false; 
        system.assertEquals(false, NI_TriggerManager.is1stUpdate_Cancellation);
        
        // ACTIVITY LINE ITEM TRIGGER EXECUTION SWITCHES 
        system.assertEquals(true, NI_TriggerManager.is1stInsert_ActivityLineItem);
        NI_TriggerManager.is1stInsert_ActivityLineItem = false; 
        system.assertEquals(false, NI_TriggerManager.is1stInsert_ActivityLineItem);
        
        system.assertEquals(true, NI_TriggerManager.is1stUpdate_ActivityLineItem);
        NI_TriggerManager.is1stUpdate_ActivityLineItem = false; 
        system.assertEquals(false, NI_TriggerManager.is1stUpdate_ActivityLineItem);
        
        // PSA PROJECT TRIGGER EXECUTION SWITCHES TEST
        system.assertEquals(true, NI_TriggerManager.is1stInsert_Project);
        system.assertEquals(true, NI_TriggerManager.is1stUpdate_Project);        
        NI_TriggerManager.is1stInsert_Project = false; 
        NI_TriggerManager.is1stUpdate_Project = false; 
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Project);
        system.assertEquals(false, NI_TriggerManager.is1stUpdate_Project);
        
        // PSA MILESTONE TRIGGER EXECUTION SWITCHES TEST
        system.assertEquals(true, NI_TriggerManager.is1stInsert_Milestone);
        system.assertEquals(true, NI_TriggerManager.is1stUpdate_Milestone);        
        NI_TriggerManager.is1stInsert_Milestone = false; 
        NI_TriggerManager.is1stUpdate_Milestone = false;  
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Milestone);
        system.assertEquals(false, NI_TriggerManager.is1stUpdate_Milestone);
        
        // PSA ASSIGNMENT TRIGGER EXECUTION SWITCHES TEST
		system.assertEquals(true, NI_TriggerManager.is1stInsert_Assignment);
        system.assertEquals(true, NI_TriggerManager.is1stUpdate_Assignment);        
        NI_TriggerManager.is1stInsert_Assignment = false; 
        NI_TriggerManager.is1stUpdate_Assignment = false;         
		system.assertEquals(false, NI_TriggerManager.is1stInsert_Assignment);
        system.assertEquals(false, NI_TriggerManager.is1stUpdate_Assignment);
        
        // CASE DETAIL TRIGGER EXECUTION SWITCH
        NI_TriggerManager.is1stInsert_Case_Report_Detail = false;
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Case_Report_Detail);
        
    }

    static testMethod void testDIIndexGlobals() 
    {    
        
        List<Asset> lstDIs = new List<Asset>();
        
        system.assertEquals(0, lstDIs.size());
        
        // DI INDEX VARAIABLES TEST
        Account a = NI_TestClassData.createTestAccount(1);
        insert a; 
        
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-001', 'Subscription');
        insert prd;
        
        Asset di = NI_TestClassData.createTestAsset(1, a.Id, prd.Id);
        di.Product_Group__c = pgp.Id;
        insert di;
        
        lstDIs.add(di);    
        NI_TriggerManager.lstDIsWithOldDIIndexes = lstDIs; 
        
        system.assertEquals(1, NI_TriggerManager.lstDIsWithOldDIIndexes.size());
        
    }
    
}