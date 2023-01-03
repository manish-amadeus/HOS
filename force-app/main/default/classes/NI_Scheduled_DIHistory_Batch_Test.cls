/****************************************************************************************
Name            : NI_Scheduled_DIHistory_Batch_Test
Author          : Sean Harris
Created Date    : 7/28/2014
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-010621 - Product Group Consolidation Data Project 
Description     : If any of the following fields on Asset is changed:
                :     Name, Annual_Subscription_Amount__c, Cendyn_Location_ID__c, InstallDate, IsHostedDI__c, 
				:     MeetingMatrix_Product_Key__c, Product2Id, PurchaseDate, Quantity_Billed__c, Quantity_Ordered__c, 
				:     Quantity_Provisioned__c, Ship_Date__c, Status, UsageEndDate, Product_Group__c, Product_Line__c, Version__c
                : the WriteHistory__c field gets set to true.
				: The class writes a NI_Deployment_Instance_History__c record for every record flagged then unflags them.
				: 
******************************************************************************************/
@isTest //(SeeAllData=true)
public class NI_Scheduled_DIHistory_Batch_Test 
{

    public static testMethod void testDIHistoryBatch() 
    {      
        
      //CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        List<Account> lstAccAsserts = new List<Account>([SELECT Id FROM Account]); 
		System.assertEquals(lstAccAsserts.Size(), 1);
        
      //CREATE TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        List<Product_Group__c> lstPGAsserts = new List<Product_Group__c>([SELECT Id FROM Product_Group__c]); 
		System.assertEquals(lstPGAsserts.Size(), 1);
        
      //LIST OF PRODUCTS TO INSERT  
        List<Product2> lstProds = new List<Product2>();
        
      //LIST OF ASSETS TO INSERT  
        List<Asset> lstAssets = new List<Asset>();
        
      //CREATE TEST PRODUCT RECORD  
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        lstProds.add(prd01);
        
      //CREATE TEST PRODUCT RECORD  
        Product2 prd02 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-EMBP-10-3-TEST', 'Subscription');
        lstProds.add(prd02);
        Database.Insert(lstProds);

        List<Product2> lstPrd2Asserts = new List<Product2>([SELECT Id FROM Product2]); 
		System.assertEquals(lstPrd2Asserts.Size(), 2);
        
      //CREATE VERSION RECORD  
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        insert vrs01;
        List<SFDC_CSP_Version__c> lstVersionAsserts = new List<SFDC_CSP_Version__c>([SELECT Id FROM SFDC_CSP_Version__c]); 
		System.assertEquals(lstVersionAsserts.Size(), 1);
        
      //CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset asset1 = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        asset1.Status = 'Shipped';
        asset1.Product_Group__c = pgp.Id;
        asset1.Version__c = vrs01.Id;
        Insert asset1; 

        List<Asset> lstAssetAsserts = new List<Asset>([SELECT Id FROM Asset]); 
		System.assertEquals(lstAssetAsserts.Size(), 1);        
        
        NI_TriggerManager.isBypassDIUpdate = false; //SET THIS SWITCH TO FALSE SO THE TRIGGER FIRES
      //UPDATE TEST DEPLOYMENT INSTANCE RECORD
        asset1.WriteHistory__c = true; 
        Update asset1; 
        List<Asset> lstAsset2Asserts = new List<Asset>([SELECT Id FROM Asset WHERE WriteHistory__c = true]); 
		System.assertEquals(lstAsset2Asserts.Size(), 1);           
        
        Test.startTest();
        NI_Scheduled_DIHistory_Batch bTest = new NI_Scheduled_DIHistory_Batch();
        ID batchprocessid = Database.executeBatch(bTest);
    	System.assertNotEquals(null, batchprocessid);
        Test.stopTest();    
    
	}
}