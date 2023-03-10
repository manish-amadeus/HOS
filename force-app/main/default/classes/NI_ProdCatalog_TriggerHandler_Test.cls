@IsTest
private class NI_ProdCatalog_TriggerHandler_Test
{
    public static testMethod void craetepartnerCatlogRecord()
    {
        
        //Create Partner Cobtract Terms
        CHANNEL_ORDERS__Partner_Contract_Terms__c contractRec = new CHANNEL_ORDERS__Partner_Contract_Terms__c();
        contractRec.Name = 'Test Contract - 1';
        contractRec.CHANNEL_ORDERS__Partner_API_Key__c = 'Test API Key - 1';
        Database.Insert(contractRec);
        
        
            
        
        //Create DI Index
        NI_DeploymentInstanceIndex__c index1 = new NI_DeploymentInstanceIndex__c();
        index1.Name = 'Test Prod Catalog 2 Updated';
        Database.Insert(index1);
        
        Test.startTest();
        //Create bulk partner product catalog records
        List<CHANNEL_ORDERS__Partner_Product_Catalog__c> createRecList = new List<CHANNEL_ORDERS__Partner_Product_Catalog__c>();
        
        CHANNEL_ORDERS__Partner_Product_Catalog__c rec1 = new CHANNEL_ORDERS__Partner_Product_Catalog__c();
        rec1.Name = 'Test Prod Catalog 1';
        rec1.CHANNEL_ORDERS__Product_ID__c = 'Test Id 1';
        rec1.CHANNEL_ORDERS__Partner_Contract_Terms__c = contractRec.Id;
        createRecList.add(rec1);
        
        /*
        /*** code commented as this functinality no longer required 
        NI_PartnerProductCatalog_TriggerHandler prodCatalogTriggHandle = new NI_PartnerProductCatalog_TriggerHandler(true);
        prodCatalogTriggHandle.OnBeforeInsert(createRecList);
        
        CHANNEL_ORDERS__Partner_Product_Catalog__c rec2 = new CHANNEL_ORDERS__Partner_Product_Catalog__c();
        rec2.Name = 'Test Prod Catalog 2';
        rec2.CHANNEL_ORDERS__Product_ID__c = 'Test Id 2';
        rec2.CHANNEL_ORDERS__Partner_Contract_Terms__c = contractRec.Id;
        createRecList.add(rec2);
        
        Database.Insert(createRecList);
        
        //Update the Partner Product catalog records
        createRecList = new List<CHANNEL_ORDERS__Partner_Product_Catalog__c>();
        rec1.Name = 'Test Prod Catalog 1 Updated'; 
        createRecList.add(rec1);
        rec2.Name = 'Test Prod Catalog 2 Updated';
        createRecList.add(rec2);
        
        Database.Update(createRecList);
        */
        Test.stopTest();
        /*** code commented as this functinality no longer required 
        //Verify that DI Index's are Created
        List<NI_DeploymentInstanceIndex__c> IndexList= new List<NI_DeploymentInstanceIndex__c>([SELECT Id,Name FROM NI_DeploymentInstanceIndex__c WHERE Name IN  ('Test Prod Catalog 1','Test Prod Catalog 2','Test Prod Catalog 1 Updated','Test Prod Catalog 2 Updated')]);
        system.assert(indexList.size() == 4);
        **/
    }
    
    
    //COVERAGE FOR TRIGGERHANDLER PLACEHOLDER EVENTS  
    public static testMethod void testPlaceholders()  
    {   
        NI_PartnerProductCatalog_TriggerHandler handler = new NI_PartnerProductCatalog_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;                        
    }
}