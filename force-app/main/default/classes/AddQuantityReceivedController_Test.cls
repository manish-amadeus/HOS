@isTest
private class AddQuantityReceivedController_Test
{
    public static testMethod void testAssetList() 
    {        
        //CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
         //CREATE TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
                   
         //LIST OF PRODUCTS TO INSERT  
        List<Product2> lstProds = new List<Product2>();
        
         //CREATE TEST PRODUCT RECORD  
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        lstProds.add(prd01);
        
        //CREATE TEST PRODUCT RECORD  
        Product2 prd02 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-EMBP-10-3-TEST', 'Subscription');
        lstProds.add(prd02);
        Database.Insert(lstProds);
        
         //CREATE VERSION RECORD  
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        insert vrs01;
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset asset1 = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        asset1.Status = 'Shipped';
        asset1.Product_Group__c = pgp.Id;
        asset1.Version__c = vrs01.Id;
        Insert asset1;
                       
        Asset asset2 = NI_TestClassData.createTestAsset(1, a.Id, prd02.Id);
        asset2.Status = 'Shipped';
        asset2.Product_Group__c = pgp.Id;
        asset2.Version__c = vrs01.Id;
        asset2.Parent_DI__c = asset1.Id;
        Insert asset2;  
        
        ApexPages.currentPage().getParameters().put('id', asset1.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(asset1);
        AddQuantityReceivedController cntrler = new AddQuantityReceivedController(sc);        
        //Verify that Child Deployment Instance is selected in that list
        system.assertEquals(asset2.Id,cntrler.assetList[0].Id);
        cntrler.assetList[0].Quantity_Received__c = 20;
        cntrler.doSubmit();
        
        //Verify that Quantity Distributed is updated on Parent DI
        Asset depIns = [SELECT Id,Quantity_Distributed__c FROM Asset Where Id = : asset1.id];
        system.assertEquals(20,Integer.Valueof(depIns.Quantity_Distributed__c)) ;
    }    
}