/****************************************************************************************
Name            : NI_Product2_Triggerhandler_Test Class
Author          : Sean Harris
Created Date    : 03/10/2015
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
@isTest //(SeeAllData=true)
public class NI_Product2_Triggerhandler_Test
{

    public static testMethod void testTrigHandler() 
    {

        // CREATE 2 TEST ACCOUNTS ======================================================================================
        List<Account> lstAccountInsert = new List<Account>(); 
        
        Account a1 = NI_TestClassData.createTestAccount(1); 
        a1.Name = 'APEX TEST ACCOUNT1'; 
        lstAccountInsert.add(a1); 
        
        Account a2 = NI_TestClassData.createTestAccount(2); 
        a2.Name = 'APEX TEST ACCOUNT2'; 
        lstAccountInsert.add(a2); 
      
        database.insert(lstAccountInsert);        
        
        // CREATE 3 TEST DI INDEXES ====================================================================================        
        List<NI_DeploymentInstanceIndex__c> lstDeploymentInstanceIndex = new List<NI_DeploymentInstanceIndex__c>(); 
        
        NI_DeploymentInstanceIndex__c idx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX'); 
        lstDeploymentInstanceIndex.add(idx1); 
        
        NI_DeploymentInstanceIndex__c idx2 = NI_TestClassData.createDI_Index(2, 'APEX TEST INDEX'); 
        lstDeploymentInstanceIndex.add(idx2); 
        
        NI_DeploymentInstanceIndex__c idx3 = NI_TestClassData.createDI_Index(3, 'APEX TEST INDEX'); 
        lstDeploymentInstanceIndex.add(idx3); 
         
        database.insert(lstDeploymentInstanceIndex); 
        
        // CREATE TEST PRODUCT GROUP ===================================================================================
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST GROUP X1'); 
 
        insert pgp; 
        
        // CREATE 5 TEST PRODUCTS (WITH 3 DIFFERENT DI INDEXS) =========================================================        
        List<Product2> lstProduct2Insert = new List<Product2>(); 
        
        Product2 prd1_idx1 = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-01', 'Subscription'); 
        prd1_idx1.DI_Index__c = idx1.Id; 
        lstProduct2Insert.add(prd1_idx1); 
        
        Product2 prd2_idx1 = NI_TestClassData.createProduct2(2, pgp.Id, 'ZZZFULFILL-APEX-02', 'Subscription'); 
        prd2_idx1.DI_Index__c = idx1.Id; 
        lstProduct2Insert.add(prd2_idx1); 
        
        Product2 prd3_idx2 = NI_TestClassData.createProduct2(3, pgp.Id, 'ZZZFULFILL-APEX-03', 'Subscription'); 
        prd3_idx2.DI_Index__c = idx2.Id; 
        prd3_idx2.DI_DefaultStatus__c = 'Installed';        
        lstProduct2Insert.add(prd3_idx2); 
        
        Product2 prd4_idx2 = NI_TestClassData.createProduct2(4, pgp.Id, 'ZZZFULFILL-APEX-04', 'Subscription'); 
        prd4_idx2.DI_Index__c = idx2.Id; 
        lstProduct2Insert.add(prd4_idx2); 
        
        Product2 prd5_idx3 = NI_TestClassData.createProduct2(5, pgp.Id, 'ZZZFULFILL-APEX-05', 'Subscription'); 
        prd5_idx3.DI_Index__c = idx3.Id; 
        prd5_idx3.DI_DefaultStatus__c = 'Installed';
        lstProduct2Insert.add(prd5_idx3); 

        database.insert(lstProduct2Insert);  
        
        prd1_idx1.DI_Index__c = idx2.Id;
        //Added By Prashant
        prd1_idx1.Hosted__c = true;
        update prd1_idx1;
        
        delete prd1_idx1;
        
        undelete prd1_idx1;
                
    }
    
     /*functionality no longer required. commented by kasim on 4/27/16    */
    /*
    public static testmethod void testAutoupdateDIIdex()
    {
        //Create Partner Cobtract Terms
        CHANNEL_ORDERS__Partner_Contract_Terms__c contractRec = new CHANNEL_ORDERS__Partner_Contract_Terms__c();
        contractRec.Name = 'Test Contract - 1';
        contractRec.CHANNEL_ORDERS__Partner_API_Key__c = 'Test API Key - 1';
        Database.Insert(contractRec);
        
        //Create bulk partner product catalog records
        List<CHANNEL_ORDERS__Partner_Product_Catalog__c> createRecList = new List<CHANNEL_ORDERS__Partner_Product_Catalog__c>();
        
        
        
        CHANNEL_ORDERS__Partner_Product_Catalog__c rec1 = new CHANNEL_ORDERS__Partner_Product_Catalog__c();
        rec1.Name = 'Test Prod Catalog 1';
        rec1.CHANNEL_ORDERS__Product_ID__c = 'Test Id 1';
        rec1.CHANNEL_ORDERS__Partner_Contract_Terms__c = contractRec.Id;
        createRecList.add(rec1);
        
        CHANNEL_ORDERS__Partner_Product_Catalog__c rec2 = new CHANNEL_ORDERS__Partner_Product_Catalog__c();
        rec2.Name = 'Test Prod Catalog 2';
        rec2.CHANNEL_ORDERS__Product_ID__c = 'Test Id 2';
        rec2.CHANNEL_ORDERS__Partner_Contract_Terms__c = contractRec.Id;
        createRecList.add(rec2);
       
        Database.Insert(createRecList); 
         
        //Once Partner Product Catalog is inserted,DI Index s autocreated so delete one Index for testing purpose
        NI_DeploymentInstanceIndex__c deleteIndex = [SELECT Id FROM NI_DeploymentInstanceIndex__c  WHERE Name = 'Test Prod Catalog 1'];
        delete deleteIndex;
              
        // CREATE TEST PRODUCT GROUP ===================================================================================
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST GROUP X1'); 
 
        insert pgp; 
        Test.startTest();
        
        // CREATE 5 TEST PRODUCTS (WITH 3 DIFFERENT DI INDEXS) =========================================================        
        List<Product2> lstProduct2Insert = new List<Product2>(); 
        
        Product2 prd1_idx1 = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-01', 'Subscription'); 
        prd1_idx1.Partner_Product_Catalog__c = rec1.Id; 
        lstProduct2Insert.add(prd1_idx1); 
        
        Product2 prd2_idx1 = NI_TestClassData.createProduct2(2, pgp.Id, 'ZZZFULFILL-APEX-02', 'Subscription'); 
        prd2_idx1.Partner_Product_Catalog__c = rec2.Id; 
        lstProduct2Insert.add(prd2_idx1);
        
        Database.Insert(lstProduct2Insert);
         
        Test.stopTest();
            
        //Verify that New DI Index is Created
        NI_DeploymentInstanceIndex__c indexQuery1 = [SELECT Id,Name FROM NI_DeploymentInstanceIndex__c WHERE Name = 'Test Prod Catalog 1'];
        system.assert(indexQuery1.Name == 'Test Prod Catalog 1');
        
        NI_DeploymentInstanceIndex__c indexQuery2 = [SELECT Id,Name FROM NI_DeploymentInstanceIndex__c WHERE Name = 'Test Prod Catalog 2'];
        system.assert(indexQuery2.Name == 'Test Prod Catalog 2');
        
        //Verify that DI Index on Product is auto Updated
        Map<Id,Product2> productMap = new Map<Id,Product2>([SELECT Id,DI_Index__c FROM Product2 WHERE Id IN (:prd1_idx1.Id,:prd2_idx1.Id)]);        
        system.assertEquals(indexQuery1.Id,productMap.get(prd1_idx1.Id).DI_Index__c);                   
        system.assertEquals(indexQuery2.Id,productMap.get(prd2_idx1.Id).DI_Index__c);
    }*/

}