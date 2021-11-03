/****************************************************************************************
Name            : NI_SoftraxAsset_TriggerHandler_Test Class
Author          : Sean Harris
Created Date    : 01/16/2015
Last Mod Date   : 2/3/2016
Last Mod By     : Prashant Wayal
NICC Reference  : 
Description     : 
                : 
                :  
******************************************************************************************/
@isTest //(SeeAllData=true)
public class NI_SoftraxAsset_TriggerHandler_Test
{
    
    public static testMethod void testRollupSummaryValues(){
        NI_SoftraxAsset_TriggerHandler handler = new NI_SoftraxAsset_TriggerHandler();
    }
  
    /*public static testMethod void testRollupSummaryValues(){
        
        // SCOPE VARIABLES =============================================================================================
        Date dt1 = Date.newInstance(2016, 1, 1);
        Date dt2 = Date.newInstance(2016, 6, 30);
        
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
        prd1_idx1.Name = 'PRODUCT #1';
        prd1_idx1.DI_Index__c = idx1.Id; 
        lstProduct2Insert.add(prd1_idx1); 
        
        Product2 prd2_idx1 = NI_TestClassData.createProduct2(2, pgp.Id, 'ZZZFULFILL-APEX-02', 'Subscription'); 
        prd2_idx1.Name = 'PRODUCT #2';
        prd2_idx1.DI_Index__c = idx1.Id; 
        lstProduct2Insert.add(prd2_idx1); 
        
        Product2 prd3_idx2 = NI_TestClassData.createProduct2(3, pgp.Id, 'ZZZFULFILL-APEX-03', 'Subscription'); 
        prd3_idx2.Name = 'PRODUCT #3';
        prd3_idx2.DI_Index__c = idx2.Id; 
        prd3_idx2.DI_DefaultStatus__c = 'Installed';        
        lstProduct2Insert.add(prd3_idx2); 
        
        Product2 prd4_idx2 = NI_TestClassData.createProduct2(4, pgp.Id, 'ZZZFULFILL-APEX-04', 'Subscription'); 
        prd4_idx2.Name = 'PRODUCT #4';
        prd4_idx2.DI_Index__c = idx2.Id; 
        lstProduct2Insert.add(prd4_idx2); 
        
        Product2 prd5_idx3 = NI_TestClassData.createProduct2(5, pgp.Id, 'ZZZFULFILL-APEX-05', 'Subscription'); 
        prd5_idx3.Name = 'PRODUCT #5';
        prd5_idx3.DI_Index__c = idx3.Id; 
        prd5_idx3.DI_DefaultStatus__c = 'Installed';
        lstProduct2Insert.add(prd5_idx3); 
        
        Product2 prd6_idx2 = NI_TestClassData.createProduct2(2, pgp.Id, 'ZZZFULFILL-APEX-06', 'Subscription'); 
        prd6_idx2.Name = 'PRODUCT #2';
        prd6_idx2.DI_Index__c = idx2.Id; 
        lstProduct2Insert.add(prd6_idx2);

        database.insert(lstProduct2Insert);
        
        test.startTest();
        List<Softrax_Asset__c> lstSoftraxAssetInsert = new List<Softrax_Asset__c>();
        
        // FOR ACCOUNT A ====================================================================================
        Softrax_Asset__c sa1_prd1_idx1 = NI_TestClassData.createSoftraxAsset(1, a1.Id, 'ZZZFULFILL-APEX-01');
        sa1_prd1_idx1.Quantity__c = 1;
        sa1_prd1_idx1.Product2Id__c = prd1_idx1.Id;
        sa1_prd1_idx1.Start_Date__c = dt1;                // 2015-01-01
        sa1_prd1_idx1.End_Date__c = dt1.addYears(1); // 2016-01-01
        sa1_prd1_idx1.Softrax_Status__c = 'A';
        sa1_prd1_idx1.SoftraxUploadRecordNumber__c = '000001';
        sa1_prd1_idx1.Fee__c = 1000;
        sa1_prd1_idx1.Total__c = 1000;
        lstSoftraxAssetInsert.Add(sa1_prd1_idx1);
        
        Softrax_Asset__c sa2_prd1_idx1 = NI_TestClassData.createSoftraxAsset(2, a1.Id, 'ZZZFULFILL-APEX-01');
        sa2_prd1_idx1.Quantity__c = 10;
        sa2_prd1_idx1.Product2Id__c = prd1_idx1.Id;
        sa2_prd1_idx1.Start_Date__c = dt1.addYears(2);   // 2017-01-01
        sa2_prd1_idx1.End_Date__c = dt1.addYears(3); // 2018-01-01
        sa2_prd1_idx1.Softrax_Status__c = 'A';
        sa2_prd1_idx1.SoftraxUploadRecordNumber__c = '000002';
        sa2_prd1_idx1.Fee__c = 1000;
        sa2_prd1_idx1.Total__c = 2000;        
        lstSoftraxAssetInsert.Add(sa2_prd1_idx1);
        
        // FOR ACCOUNT B ====================================================================================
        Softrax_Asset__c sa3_prd3_idx2 = NI_TestClassData.createSoftraxAsset(3, a2.Id, 'ZZZFULFILL-APEX-03');
        sa3_prd3_idx2.Quantity__c = 100;
        sa3_prd3_idx2.Product2Id__c = prd3_idx2.Id;
        sa3_prd3_idx2.Start_Date__c = dt2;                // 2015-06-30
        sa3_prd3_idx2.End_Date__c = dt2.addYears(1); // 2016-06-30
        sa3_prd3_idx2.Softrax_Status__c = 'A';
        sa3_prd3_idx2.SoftraxUploadRecordNumber__c = '000003';
        sa3_prd3_idx2.Fee__c = 1000;
        sa3_prd3_idx2.Total__c = 4000;
        lstSoftraxAssetInsert.Add(sa3_prd3_idx2);
        
        Softrax_Asset__c sa4_prd4_idx2 = NI_TestClassData.createSoftraxAsset(4, a2.Id, 'ZZZFULFILL-APEX-04');
        sa4_prd4_idx2.Quantity__c = 1000;
        sa4_prd4_idx2.Product2Id__c = prd4_idx2.Id;
        sa4_prd4_idx2.Start_Date__c = dt2.addYears(2);   // 2017-06-30
        sa4_prd4_idx2.End_Date__c = dt2.addYears(3); // 2018-06-30
        sa4_prd4_idx2.Softrax_Status__c = 'A';
        sa4_prd4_idx2.SoftraxUploadRecordNumber__c = '000004';
        sa4_prd4_idx2.Fee__c = 1000;
        sa4_prd4_idx2.Total__c = 5000;        
        lstSoftraxAssetInsert.Add(sa4_prd4_idx2); 
        
        Softrax_Asset__c sa5_prd5_idx3 = NI_TestClassData.createSoftraxAsset(5, a2.Id, 'ZZZFULFILL-APEX-05');
        sa5_prd5_idx3.Quantity__c = 10000;
        sa5_prd5_idx3.Product2Id__c = prd5_idx3.Id;
        sa5_prd5_idx3.Start_Date__c = dt2.addYears(2);   // 2017-06-30
        sa5_prd5_idx3.End_Date__c = dt2.addYears(3); // 2018-06-30
        sa5_prd5_idx3.Softrax_Status__c = 'A';
        sa5_prd5_idx3.SoftraxUploadRecordNumber__c = '000005';
        sa5_prd5_idx3.Fee__c = 1000;
        sa5_prd5_idx3.Total__c = 11000;        
        lstSoftraxAssetInsert.Add(sa5_prd5_idx3); 
       
        database.insert(lstSoftraxAssetInsert); 
        
        Test.stopTest();
        
        // GET ALL 3 DI RECORDS THAT WERE CREATED FROM THE SOFTRAX ASSET INSERT ========================================
        Asset di1 = [SELECT Id, Name, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status 
                     FROM Asset WHERE AccountId = : a1.Id AND DI_Index_Name__c = 'APEX TEST INDEX 1']; 
        Asset di2 = [SELECT Id, Name, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status 
                     FROM Asset WHERE AccountId = : a2.Id AND DI_Index_Name__c = 'APEX TEST INDEX 2']; 
        Asset di3 = [SELECT Id, Name, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status 
                     FROM Asset WHERE AccountId = : a2.Id AND DI_Index_Name__c = 'APEX TEST INDEX 3']; 
        
        // CHECK THAT ALL 3 DI RECORDS THAT WERE CREATED FROM THE SOFTRAX ASSET INSERT 
        // EXIST WITH CORRECT DI INDEX NAMES
        system.assertNotEquals(null, di1);
        system.assertNotEquals(null, di2);
        system.assertNotEquals(null, di3);
           
        // ASSERT DI DEFAULT STATUS VALUES
        system.assertEquals('Purchased', di1.Status); 
        system.assertEquals('Purchased', di2.Status);
        system.assertEquals('Installed', di3.Status);   
        
        // =============================================================================================================
        // RECORD VALUE ASSERTIONS
        // =============================================================================================================
                
        // TEST SOFTRAX BILLING TO DI ROLLUPS (START) ======================================================
        System.debug(' *** di1 Name *** '+di1.Name+' *** di1 *** '+di1.Quantity_Billed__c);
        system.assertEquals(11, di1.Quantity_Billed__c); 
        system.assertEquals(Date.newInstance(2018, 1, 1), di1.Purchase_Date__c);         
        system.assertEquals('APEX TEST INDEX 1', di1.DI_Index_Name__c);
        
        system.assertEquals(1100, di2.Quantity_Billed__c); 
        system.assertEquals(Date.newInstance(2018, 6, 30), di2.Purchase_Date__c); 
        system.assertEquals('APEX TEST INDEX 2', di2.DI_Index_Name__c);
        
        system.assertEquals(10000, di3.Quantity_Billed__c); 
        system.assertEquals(Date.newInstance(2018, 6, 30), di3.Purchase_Date__c); 
        system.assertEquals('APEX TEST INDEX 3', di3.DI_Index_Name__c); 
        
        delete sa1_prd1_idx1;
        
        undelete sa1_prd1_idx1;
    }
    public static testMethod void testRollups() 
    {
        
        // SCOPE VARIABLES =============================================================================================
        Date dt1 = Date.newInstance(2015, 1, 1);
        Date dt2 = Date.newInstance(2015, 6, 30);
        
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

        
        
for (NI_DeploymentInstanceIndex__c DI_INDEX : lstDeploymentInstanceIndex)
{
   system.debug(' !!!!! BASE STATE VALUES !!!!!    DI_INDEX = ' + DI_INDEX.Name + ' = ' + DI_INDEX.Id);
}   
system.debug(' =============================================================================================== ');
        
        // CREATE TEST PRODUCT GROUP ===================================================================================
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST GROUP X1'); 
 
        insert pgp; 
        
        // CREATE 5 TEST PRODUCTS (WITH 3 DIFFERENT DI INDEXS) =========================================================        
        List<Product2> lstProduct2Insert = new List<Product2>(); 
        
        Product2 prd1_idx1 = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-01', 'Subscription'); 
        prd1_idx1.Name = 'PRODUCT #1';
        prd1_idx1.DI_Index__c = idx1.Id; 
        lstProduct2Insert.add(prd1_idx1); 
        
        Product2 prd2_idx1 = NI_TestClassData.createProduct2(2, pgp.Id, 'ZZZFULFILL-APEX-02', 'Subscription'); 
        prd2_idx1.Name = 'PRODUCT #2';
        prd2_idx1.DI_Index__c = idx1.Id; 
        lstProduct2Insert.add(prd2_idx1); 
        
        Product2 prd3_idx2 = NI_TestClassData.createProduct2(3, pgp.Id, 'ZZZFULFILL-APEX-03', 'Subscription'); 
        prd3_idx2.Name = 'PRODUCT #3';
        prd3_idx2.DI_Index__c = idx2.Id; 
        prd3_idx2.DI_DefaultStatus__c = 'Installed';        
        lstProduct2Insert.add(prd3_idx2); 
        
        Product2 prd4_idx2 = NI_TestClassData.createProduct2(4, pgp.Id, 'ZZZFULFILL-APEX-04', 'Subscription'); 
        prd4_idx2.Name = 'PRODUCT #4';
        prd4_idx2.DI_Index__c = idx2.Id; 
        lstProduct2Insert.add(prd4_idx2); 
        
        Product2 prd5_idx3 = NI_TestClassData.createProduct2(5, pgp.Id, 'ZZZFULFILL-APEX-05', 'Subscription'); 
        prd5_idx3.Name = 'PRODUCT #5';
        prd5_idx3.DI_Index__c = idx3.Id; 
        prd5_idx3.DI_DefaultStatus__c = 'Installed';
        lstProduct2Insert.add(prd5_idx3); 
        
        Product2 prd6_idx2 = NI_TestClassData.createProduct2(2, pgp.Id, 'ZZZFULFILL-APEX-06', 'Subscription'); 
        prd6_idx2.Name = 'PRODUCT #2';
        prd6_idx2.DI_Index__c = idx2.Id; 
        lstProduct2Insert.add(prd6_idx2);
        
              
        database.insert(lstProduct2Insert);
        
        
for (Product2 NI_PRODUCT2 : lstProduct2Insert)
{
   system.debug(' !!!!! BASE STATE VALUES !!!!!    NI_PRODUCT2 = ' + NI_PRODUCT2.Name + ' = ' + NI_PRODUCT2.Id + ',  DI_Index__c = ' + NI_PRODUCT2.DI_Index__c);
}          
system.debug(' =============================================================================================== ');       
*/        
        
/*
        for (Product2 p2Test : [SELECT ProductCode, DI_DefaultStatus__c FROM Product2])
        {
            system.debug('p2Test.ProductCode = ' + p2Test.ProductCode +  ', p2Test.DI_DefaultStatus__c = ' + p2Test.DI_DefaultStatus__c);
            if ((p2Test.ProductCode == 'ZZZFULFILL-APEX-03') || (p2Test.ProductCode == 'ZZZFULFILL-APEX-05'))
            {
                system.assertEquals('Installed', p2Test.DI_DefaultStatus__c);
            }
            else
            {
                system.assertEquals('Purchased', p2Test.DI_DefaultStatus__c);
            }
        }
*/        
        // =============================================================================================================
        // CREATE 5 TEST SOFTRAX ASSETS ================================================================================
        // =============================================================================================================
       /* test.startTest();
        List<Softrax_Asset__c> lstSoftraxAssetInsert = new List<Softrax_Asset__c>();
        
        // FOR ACCOUNT A ====================================================================================
        Softrax_Asset__c sa1_prd1_idx1 = NI_TestClassData.createSoftraxAsset(1, a1.Id, 'ZZZFULFILL-APEX-01');
        sa1_prd1_idx1.Quantity__c = 1;
        sa1_prd1_idx1.Product2Id__c = prd1_idx1.Id;
        sa1_prd1_idx1.Start_Date__c = dt1;                // 2015-01-01
        sa1_prd1_idx1.End_Date__c = dt1.addYears(1); // 2016-01-01
        sa1_prd1_idx1.Softrax_Status__c = 'A';
        sa1_prd1_idx1.SoftraxUploadRecordNumber__c = '000001';
        sa1_prd1_idx1.Fee__c = 1000;
        sa1_prd1_idx1.Total__c = 1000;
        lstSoftraxAssetInsert.Add(sa1_prd1_idx1);
        
        Softrax_Asset__c sa2_prd1_idx1 = NI_TestClassData.createSoftraxAsset(2, a1.Id, 'ZZZFULFILL-APEX-01');
        sa2_prd1_idx1.Quantity__c = 10;
        sa2_prd1_idx1.Product2Id__c = prd1_idx1.Id;
        sa2_prd1_idx1.Start_Date__c = dt1.addYears(2);   // 2017-01-01
        sa2_prd1_idx1.End_Date__c = dt1.addYears(3); // 2018-01-01
        sa2_prd1_idx1.Softrax_Status__c = 'A';
        sa2_prd1_idx1.SoftraxUploadRecordNumber__c = '000002';
        sa2_prd1_idx1.Fee__c = 1000;
        sa2_prd1_idx1.Total__c = 2000;        
        lstSoftraxAssetInsert.Add(sa2_prd1_idx1);
        
        // FOR ACCOUNT B ====================================================================================
        Softrax_Asset__c sa3_prd3_idx2 = NI_TestClassData.createSoftraxAsset(3, a2.Id, 'ZZZFULFILL-APEX-03');
        sa3_prd3_idx2.Quantity__c = 100;
        sa3_prd3_idx2.Product2Id__c = prd3_idx2.Id;
        sa3_prd3_idx2.Start_Date__c = dt2;                // 2015-06-30
        sa3_prd3_idx2.End_Date__c = dt2.addYears(1); // 2016-06-30
        sa3_prd3_idx2.Softrax_Status__c = 'A';
        sa3_prd3_idx2.SoftraxUploadRecordNumber__c = '000003';
        sa3_prd3_idx2.Fee__c = 1000;
        sa3_prd3_idx2.Total__c = 4000;
        lstSoftraxAssetInsert.Add(sa3_prd3_idx2);
        
        Softrax_Asset__c sa4_prd4_idx2 = NI_TestClassData.createSoftraxAsset(4, a2.Id, 'ZZZFULFILL-APEX-04');
        sa4_prd4_idx2.Quantity__c = 1000;
        sa4_prd4_idx2.Product2Id__c = prd4_idx2.Id;
        sa4_prd4_idx2.Start_Date__c = dt2.addYears(2);   // 2017-06-30
        sa4_prd4_idx2.End_Date__c = dt2.addYears(3); // 2018-06-30
        sa4_prd4_idx2.Softrax_Status__c = 'A';
        sa4_prd4_idx2.SoftraxUploadRecordNumber__c = '000004';
        sa4_prd4_idx2.Fee__c = 1000;
        sa4_prd4_idx2.Total__c = 5000;        
        lstSoftraxAssetInsert.Add(sa4_prd4_idx2); 
        
        Softrax_Asset__c sa5_prd5_idx3 = NI_TestClassData.createSoftraxAsset(5, a2.Id, 'ZZZFULFILL-APEX-05');
        sa5_prd5_idx3.Quantity__c = 10000;
        sa5_prd5_idx3.Product2Id__c = prd5_idx3.Id;
        sa5_prd5_idx3.Start_Date__c = dt2.addYears(2);   // 2017-06-30
        sa5_prd5_idx3.End_Date__c = dt2.addYears(3); // 2018-06-30
        sa5_prd5_idx3.Softrax_Status__c = 'A';
        sa5_prd5_idx3.SoftraxUploadRecordNumber__c = '000005';
        sa5_prd5_idx3.Fee__c = 1000;
        sa5_prd5_idx3.Total__c = 11000;        
        lstSoftraxAssetInsert.Add(sa5_prd5_idx3); 
       
        database.insert(lstSoftraxAssetInsert); 

for (Softrax_Asset__c NI_SoftraxAsset : lstSoftraxAssetInsert)
{
   system.debug(' !!!!! BASE STATE VALUES !!!!!    NI_SoftraxAsset = ' + NI_SoftraxAsset.Name + ' = ' + NI_SoftraxAsset.Id);
}          
system.debug(' =============================================================================================== ');               
for (Asset di : [SELECT Quantity_Billed__c, Name, Id, Account.Name, AccountId, Product2.Name, Product2Id, DI_Index_Name__c, 
                                 Product2.DI_Index__r.Name, Product2.DI_Index__c, Status, AccountId_DIIndexID__c 
                                 FROM Asset])
{
    system.debug(' !!!!! BASE STATE VALUES !!!!!    DeploymentInstance = ' + 
                 di.Quantity_Billed__c + ', ' + 
                 di.Status + ', ' +                      
                 di.Name + ', ' + 
                 di.Id + ', ' +  
                 di.Account.Name + ', ' + 
                 di.AccountId + ', ' + 
                 di.Product2.Name + ', ' + 
                 di.Product2Id + ', ' + 
                 di.DI_Index_Name__c + ', ' + 
                 di.Product2.DI_Index__r.Name + ', ' + 
                 di.Product2.DI_Index__r.Id + ', ' + 
                 di.Status + ', ' + 
                 di.AccountId_DIIndexID__c      
                );
}        
system.debug(' =============================================================================================== ');        

         
        // =============================================================================================================
        // RECORD EXISTANCE ASSERTIONS
        // =============================================================================================================
        
        // CHECK 1 DI RECORD WAS CREATED FOR ACCOUNT A =================================================================

        List<Asset> lstAssetCheck1 = new List<Asset>(
            [SELECT Id, AccountId_DIIndexID__c, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c 
             FROM Asset 
             WHERE AccountId =: a1.Id] 
        );
        System.assertEquals(1, lstAssetCheck1.Size()); 
        
        // CHECK 2 DI RECORDS WERE CREATED FOR ACCOUNT B ===============================================================
     
        List<Asset> lstAssetCheck2 = new List<Asset>(
            [SELECT Id, AccountId_DIIndexID__c, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c 
             FROM Asset 
             WHERE AccountId =: a2.Id] 
        ); 
        System.assertEquals(2, lstAssetCheck2.Size()); 
              
        // GET ALL 3 DI RECORDS THAT WERE CREATED FROM THE SOFTRAX ASSET INSERT ========================================
        Asset di1 = [SELECT Id, Name, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status 
                     FROM Asset WHERE AccountId = : a1.Id AND DI_Index_Name__c = 'APEX TEST INDEX 1']; 
        Asset di2 = [SELECT Id, Name, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status 
                     FROM Asset WHERE AccountId = : a2.Id AND DI_Index_Name__c = 'APEX TEST INDEX 2']; 
        Asset di3 = [SELECT Id, Name, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status 
                     FROM Asset WHERE AccountId = : a2.Id AND DI_Index_Name__c = 'APEX TEST INDEX 3']; 
        
        // CHECK THAT ALL 3 DI RECORDS THAT WERE CREATED FROM THE SOFTRAX ASSET INSERT 
        // EXIST WITH CORRECT DI INDEX NAMES
        system.assertNotEquals(null, di1);
        system.assertNotEquals(null, di2);
        system.assertNotEquals(null, di3);
           
        // ASSERT DI DEFAULT STATUS VALUES
        system.assertEquals('Purchased', di1.Status); 
        system.assertEquals('Purchased', di2.Status);
        system.assertEquals('Installed', di3.Status);  */ 
        
        // CHECK THAT 2 DI_to_Softrax_Asset__c RECORD WERE CREATED FOR ACCOUNT A 
        // EVEN THOUGH 2 SOFTRAX ASSETS WITH THE SAME PRODUCT WERE INSERTED  
        
        /* List<DI_to_Softrax_Asset__c> lstDI2SoftraxAssetsCheck1 = new List<DI_to_Softrax_Asset__c>(
            [SELECT Id FROM DI_to_Softrax_Asset__c WHERE Deployment_Instance__c = : di1.Id]
        );
        system.assertEquals(0, lstDI2SoftraxAssetsCheck1.Size());
        */
        
        // CHECK THAT 2 DI_to_Softrax_Asset__c RECORD WERE CREATED FOR ACCOUNT B 
        // EVEN THOUGH 2 SOFTRAX ASSETS WITH THE SAME PRODUCT WERE INSERTED          
        /*List<DI_to_Softrax_Asset__c> lstDI2SoftraxAssetsCheck2 = new List<DI_to_Softrax_Asset__c>(
            [SELECT Id FROM DI_to_Softrax_Asset__c WHERE Deployment_Instance__c = : di2.Id]
        );
        system.assertEquals(0, lstDI2SoftraxAssetsCheck2.Size());
        
        // CHECK THAT 1 ADDITONAL DI_to_Softrax_Asset__c RECORD WAS CREATED FOR ACCOUNT B          
        List<DI_to_Softrax_Asset__c> lstDI2SoftraxAssetsCheck3 = new List<DI_to_Softrax_Asset__c>(
            [SELECT Id FROM DI_to_Softrax_Asset__c WHERE Deployment_Instance__c = : di3.Id]
        );
        system.assertEquals(1, lstDI2SoftraxAssetsCheck3.Size());         
        
        // ASSET THAT 5 TOTAL DI_to_Softrax_Asset__c EXIST =================================================
        List<DI_to_Softrax_Asset__c> lstDI2SoftraxAssetsAll = new List<DI_to_Softrax_Asset__c>(
            [SELECT Id FROM DI_to_Softrax_Asset__c]
        );
        system.assertEquals(5, lstDI2SoftraxAssetsAll.Size()); 
        */
        // =============================================================================================================
        // RECORD VALUE ASSERTIONS
        // =============================================================================================================
                
        // TEST SOFTRAX BILLING TO DI ROLLUPS (START) ======================================================
       /* System.debug(' *** di1 Name *** '+di1.Name+' *** di1 *** '+di1.Quantity_Billed__c);
        system.assertEquals(0, di1.Quantity_Billed__c); 
        system.assertEquals(Date.newInstance(2017, 1, 1), di1.Purchase_Date__c);         
//        system.assertEquals(Date.newInstance(2018, 1, 1), di1.Usage_End_Date__c); 
        system.assertEquals('APEX TEST INDEX 1', di1.DI_Index_Name__c);
        
        system.assertEquals(0, di2.Quantity_Billed__c); 
        system.assertEquals(Date.newInstance(2017, 6, 30), di2.Purchase_Date__c); 
//        system.assertEquals(Date.newInstance(2018, 6, 30), di2.Usage_End_Date__c); 
        system.assertEquals('APEX TEST INDEX 2', di2.DI_Index_Name__c);
        
        system.assertEquals(0, di3.Quantity_Billed__c); 
        system.assertEquals(Date.newInstance(2017, 6, 30), di3.Purchase_Date__c); 
//        system.assertEquals(Date.newInstance(2018, 6, 30), di3.Usage_End_Date__c); 
        system.assertEquals('APEX TEST INDEX 3', di3.DI_Index_Name__c);        
        // TEST SOFTRAX BILLING TO DI ROLLUPS ( END ) ======================================================

        // TEST CHANGING A DI INDEX ON A PRODUCT ===========================================================
        prd1_idx1.DI_Index__c = idx2.Id; 
 
//system.debug('=============================================================================================');  
//system.debug(' UPDATE Product 1 to DI Index 2 from DI Index 1 (START) =====================================');

        update prd1_idx1; 

system.debug(' =============================================================================================== ');               
for (Asset di : [SELECT Quantity_Billed__c, Name, Id, Account.Name, AccountId, Product2.Name, Product2Id, DI_Index_Name__c, 
                                 Product2.DI_Index__r.Name, Product2.DI_Index__c, Status, AccountId_DIIndexID__c 
                                 FROM Asset])
{
    system.debug(' !!!!! PRODUCT 1 VALUES !!!!!    DeploymentInstance = ' + 
                 di.Quantity_Billed__c + ', ' + 
                 di.Status + ', ' +                      
                 di.Name + ', ' + 
                 di.Id + ', ' +  
                 di.Account.Name + ', ' + 
                 di.AccountId + ', ' + 
                 di.Product2.Name + ', ' + 
                 di.Product2Id + ', ' + 
                 di.DI_Index_Name__c + ', ' + 
                 di.Product2.DI_Index__r.Name + ', ' + 
                 di.Product2.DI_Index__r.Id + ', ' + 
                 di.Status + ', ' + 
                 di.AccountId_DIIndexID__c      
                );
}        
system.debug(' =============================================================================================== ');          
//system.debug('=============================================================================================');  
//system.debug(' UPDATE Product 1 to DI Index 2 from DI Index 1 (END) =======================================');
        
        system.assertEquals(idx2.Id, prd1_idx1.DI_Index__c); 
 
        integer i1 = 0;
        integer i2 = 0;
        integer i3 = 0;
        
        // GET CURRENT VERSIONS OF ALL 3 DI RECORDS THAT WERE CREATED FROM THE SOFTRAX ASSET INSERT ==========
        di1 = [SELECT Id, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status FROM Asset WHERE Id = : di1.Id]; 
        di2 = [SELECT Id, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status FROM Asset WHERE Id = : di2.Id]; 
        di3 = [SELECT Id, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status FROM Asset WHERE Id = : di3.Id]; */
        /*
        for (DI_to_Softrax_Asset__c lstDITests1 : [SELECT Id, Deployment_Instance__c FROM DI_to_Softrax_Asset__c])
        {
            if (lstDITests1.Deployment_Instance__c == di1.Id)
            {
                i1++;
            }
            if (lstDITests1.Deployment_Instance__c == di2.Id)
            {
                i2++;
            }
            if (lstDITests1.Deployment_Instance__c == di3.Id)
            {
                i3++;
            }
        }
        
        system.assertEquals(2, i1); 
        system.assertEquals(2, i2); 
        system.assertEquals(1, i3); 
        */
        /*system.assertEquals(0, di1.Quantity_Billed__c); 
        system.assertEquals(0, di2.Quantity_Billed__c); 
        system.assertEquals(0, di3.Quantity_Billed__c);   
        
        system.assertEquals('APEX TEST INDEX 2', di1.DI_Index_Name__c); 
        system.assertEquals('APEX TEST INDEX 2', di2.DI_Index_Name__c);
        system.assertEquals('APEX TEST INDEX 3', di3.DI_Index_Name__c);        
        
        // TEST CHANGING A DI INDEX ON A PRODUCT =========================================================== 
        prd5_idx3.DI_Index__c = idx1.Id;

//system.debug('=============================================================================================');  
//system.debug(' UPDATE Product 5 to DI Index 1 from DI Index 3 (START) =====================================');
        
        update prd5_idx3; 
        
system.debug(' =============================================================================================== ');               
for (Asset di : [SELECT Quantity_Billed__c, Name, Id, Account.Name, AccountId, Product2.Name, Product2Id, DI_Index_Name__c, 
                                 Product2.DI_Index__r.Name, Product2.DI_Index__c, Status, AccountId_DIIndexID__c 
                                 FROM Asset])
{
    system.debug(' !!!!! PRODUCT 5 VALUES !!!!!    DeploymentInstance = ' + 
                 di.Quantity_Billed__c + ', ' + 
                 di.Status + ', ' +                      
                 di.Name + ', ' + 
                 di.Id + ', ' +  
                 di.Account.Name + ', ' + 
                 di.AccountId + ', ' + 
                 di.Product2.Name + ', ' + 
                 di.Product2Id + ', ' + 
                 di.DI_Index_Name__c + ', ' + 
                 di.Product2.DI_Index__r.Name + ', ' + 
                 di.Product2.DI_Index__r.Id + ', ' + 
                 di.Status + ', ' + 
                 di.AccountId_DIIndexID__c      
                );
}        
system.debug(' =============================================================================================== ');          
//system.debug('=============================================================================================');  
//system.debug(' UPDATE Product 5 to DI Index 1 from DI Index 3 (END) =======================================');
        
        system.assertEquals(idx1.Id, prd5_idx3.DI_Index__c); 
        
        // RESET QUANTITY ASSERTION VARIABLES ================================================================
        i1 = 0;
        i2 = 0;
        i3 = 0;

        // GET CURRENT VERSIONS OF ALL 3 DI RECORDS THAT WERE CREATED FROM THE SOFTRAX ASSET INSERT ==========
        di1 = [SELECT Id, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status FROM Asset WHERE Id = : di1.Id]; 
        di2 = [SELECT Id, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status FROM Asset WHERE Id = : di2.Id]; 
        di3 = [SELECT Id, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status FROM Asset WHERE Id = : di3.Id];*/
        
       /* for (DI_to_Softrax_Asset__c lstDITests2 : [SELECT Id, Deployment_Instance__c FROM DI_to_Softrax_Asset__c])
        {
            if (lstDITests2.Deployment_Instance__c == di1.Id)
            {
                i1++;
            }
            if (lstDITests2.Deployment_Instance__c == di2.Id)
            {
                i2++;
            }
            if (lstDITests2.Deployment_Instance__c == di3.Id)
            {
                i3++;
            }
        }
        
        system.assertEquals(2, i1); 
        system.assertEquals(2, i2); 
        system.assertEquals(1, i3); 
        */
        /*system.assertEquals(0, di1.Quantity_Billed__c); 
        system.assertEquals(0, di2.Quantity_Billed__c); 
        system.assertEquals(0, di3.Quantity_Billed__c);   
        
        system.assertEquals('APEX TEST INDEX 2', di1.DI_Index_Name__c); 
        system.assertEquals('APEX TEST INDEX 2', di2.DI_Index_Name__c); 
        system.assertEquals('APEX TEST INDEX 1', di3.DI_Index_Name__c); 
        
        // TEST CHANGING A DI INDEX ON A PRODUCT =========================================================== 
        prd4_idx2.DI_Index__c = idx3.Id;  

//system.debug('=============================================================================================');  
//system.debug(' UPDATE Product 4 to DI Index 3 from DI Index 2 (START) =====================================');    

system.debug(' =============================================================================================== ');               
for (Asset di : [SELECT Quantity_Billed__c, Name, Id, Account.Name, AccountId, Product2.Name, Product2Id, DI_Index_Name__c, 
                                 Product2.DI_Index__r.Name, Product2.DI_Index__c, Status, AccountId_DIIndexID__c 
                                 FROM Asset])
{
    system.debug(' !!!!! PRODUCT 4 CHANGED VALUES !!!!!    DeploymentInstance = ' + 
                 di.Quantity_Billed__c + ', ' + 
                 di.Status + ', ' +                      
                 di.Name + ', ' + 
                 di.Id + ', ' +  
                 di.Account.Name + ', ' + 
                 di.AccountId + ', ' + 
                 di.Product2.Name + ', ' + 
                 di.Product2Id + ', ' + 
                 di.DI_Index_Name__c + ', ' + 
                 di.Product2.DI_Index__r.Name + ', ' + 
                 di.Product2.DI_Index__r.Id + ', ' + 
                 di.Status + ', ' + 
                 di.AccountId_DIIndexID__c      
                );
}        
system.debug(' =============================================================================================== ');          
        
        update prd4_idx2; 
        
//system.debug(' UPDATE Product 4 to DI Index 3 from DI Index 2 (END) =======================================');           
//system.debug('=============================================================================================');  
        
        system.assertEquals(idx3.Id, prd4_idx2.DI_Index__c);             
              
        // RESET QUANTITY ASSERTION VARIABLES ================================================================
        i1 = 0;
        i2 = 0;
        i3 = 0;
        integer i4 = 0;  
        
        // GET CURRENT VERSIONS OF ALL DI RECORDS THAT WERE CREATED FROM THE SOFTRAX ASSET INSERT ==========
        di1 = [SELECT Id, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status FROM Asset WHERE Id = : di1.Id]; 
        di2 = [SELECT Id, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status FROM Asset WHERE Id = : di2.Id]; 
        di3 = [SELECT Id, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status FROM Asset WHERE Id = : di3.Id];            */
        /*Asset di4 = [SELECT Id, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status  
                     FROM Asset WHERE AccountId = : a2.Id AND DI_Index_Name__c = 'APEX TEST INDEX 2']; 
        
        for (DI_to_Softrax_Asset__c lstDITests3 : [SELECT Id, Deployment_Instance__c FROM DI_to_Softrax_Asset__c])
        {
            if (lstDITests3.Deployment_Instance__c == di1.Id)
            {
                i1++;
            }
            if (lstDITests3.Deployment_Instance__c == di2.Id)
            {
                i2++;
            }
            if (lstDITests3.Deployment_Instance__c == di3.Id)
            {
                i3++;
            }
            if (lstDITests3.Deployment_Instance__c == di4.Id)
            {
                i4++;
            }
        }

        */
/*system.debug(' =============================================================================================== ');               
for (Asset di : [SELECT Quantity_Billed__c, Name, Id, Account.Name, AccountId, Product2.Name, Product2Id, DI_Index_Name__c, 
                                 Product2.DI_Index__r.Name, Product2.DI_Index__c, Status, AccountId_DIIndexID__c 
                                 FROM Asset])
{
    system.debug(' !!!!! FINAL VALUES !!!!!    DeploymentInstance = ' + 
                 di.Quantity_Billed__c + ', ' + 
                 di.Status + ', ' +                  
                 di.Name + ', ' + 
                 di.Id + ', ' +  
                 di.Account.Name + ', ' + 
                 di.AccountId + ', ' + 
                 di.Product2.Name + ', ' + 
                 di.Product2Id + ', ' + 
                 di.DI_Index_Name__c + ', ' + 
                 di.Product2.DI_Index__r.Name + ', ' + 
                 di.Product2.DI_Index__r.Id + ', ' + 
                 di.Status + ', ' + 
                 di.AccountId_DIIndexID__c
                );
}        
system.debug(' =============================================================================================== ');          
        
*/
        
        /*system.assertEquals(0, i1); 
        system.assertEquals(1, i2); 
        system.assertEquals(1, i3); 
        system.assertEquals(1, i4); 
        */
        /*system.assertEquals(0, di1.Quantity_Billed__c); 
        system.assertEquals(0, di2.Quantity_Billed__c); 
        system.assertEquals(0, di3.Quantity_Billed__c);   
        //system.assertEquals(100, di4.Quantity_Billed__c);   
        
        system.assertEquals('APEX TEST INDEX 2', di1.DI_Index_Name__c); 
        system.assertEquals('APEX TEST INDEX 3', di2.DI_Index_Name__c);
        system.assertEquals('APEX TEST INDEX 1', di3.DI_Index_Name__c);      
        //system.assertEquals('APEX TEST INDEX 2', di4.DI_Index_Name__c); 
        
        // ASSERT DI DEFAULT STATUS VALUES
        system.assertEquals('Purchased', di1.Status); 
        system.assertEquals('Purchased', di2.Status);
        system.assertEquals('Installed', di3.Status);   
        //system.assertEquals('Installed', di4.Status);
        
        Softrax_Asset__c sa6_prd1_idx1 = NI_TestClassData.createSoftraxAsset(1, a1.Id, 'ZZZFULFILL-APEX-06');
        sa6_prd1_idx1.Quantity__c = 3;
        sa6_prd1_idx1.Product2Id__c = prd6_idx2.Id;
        sa6_prd1_idx1.Start_Date__c = dt1;                // 2015-01-01
        sa6_prd1_idx1.End_Date__c = dt1.addYears(1); // 2016-01-01
        sa6_prd1_idx1.Softrax_Status__c = 'A';
        sa6_prd1_idx1.SoftraxUploadRecordNumber__c = '000001';
        sa6_prd1_idx1.Fee__c = 1000;
        sa6_prd1_idx1.Total__c = 1000;
        
        insert sa6_prd1_idx1;
        
        Asset asset1 = [SELECT Id, Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c, DI_Index_Name__c, Status 
                     FROM Asset WHERE AccountId = : a1.Id AND Product2Id =: prd6_idx2.Id];
                     
        Softrax_Asset__c asObj = [select Deployment_Instance__c from Softrax_Asset__c where Id =: sa6_prd1_idx1.Id];
        System.assertEquals(asset1.Id, asObj.Deployment_Instance__c);
        
test.stopTest();          
        
        sa1_prd1_idx1.Softrax_Status__c = 'I';
        update sa1_prd1_idx1;
        
        delete sa1_prd1_idx1;

        undelete sa1_prd1_idx1;
        
        Map<Id,Softrax_Asset__c> oldMap = new Map<Id,Softrax_Asset__c >();
        NI_SoftraxAsset_TriggerHandler handler = new NI_SoftraxAsset_TriggerHandler();
        //handler.OnBeforeUpdate(lstSoftraxAssetInsert,oldMap);
        handler.OnAfterDelete(lstSoftraxAssetInsert);                                
    }
    
    //Added By: Sunita Mittal
    //Description: Test the updation of "Billing Status" field on Account
    public static testmethod void updateBillingStatusTest()
    {
        NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;
        
        //CREATE TEST ACCOUNT RECORD 
        Account acc1 = NI_TestClassData.createTestAccount(1);
        insert acc1;
        
        Account acc2 = NI_TestClassData.createTestAccount(2);
        insert acc2;*/
        
        /*=======================================================================*/
        
         // CREATE 3 TEST DI INDEXES ====================================================================================        
        /*List<NI_DeploymentInstanceIndex__c> lstDeploymentInstanceIndex = new List<NI_DeploymentInstanceIndex__c>(); 
        
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
        prd1_idx1.Name = 'PRODUCT #1';
        prd1_idx1.DI_Index__c = idx1.Id; 
        lstProduct2Insert.add(prd1_idx1); 
        
        Product2 prd2_idx1 = NI_TestClassData.createProduct2(2, pgp.Id, 'ZZZFULFILL-APEX-02', 'Subscription'); 
        prd2_idx1.Name = 'PRODUCT #2';
        prd2_idx1.DI_Index__c = idx1.Id; 
        lstProduct2Insert.add(prd2_idx1); 
        
        Product2 prd3_idx2 = NI_TestClassData.createProduct2(3, pgp.Id, 'ZZZFULFILL-APEX-03', 'Subscription'); 
        prd3_idx2.Name = 'PRODUCT #3';
        prd3_idx2.DI_Index__c = idx2.Id; 
        prd3_idx2.DI_DefaultStatus__c = 'Installed';        
        lstProduct2Insert.add(prd3_idx2); 
        
        Product2 prd4_idx2 = NI_TestClassData.createProduct2(4, pgp.Id, 'ZZZFULFILL-APEX-04', 'Subscription'); 
        prd4_idx2.Name = 'PRODUCT #4';
        prd4_idx2.DI_Index__c = idx2.Id; 
        lstProduct2Insert.add(prd4_idx2); 
        
        Product2 prd5_idx3 = NI_TestClassData.createProduct2(5, pgp.Id, 'ZZZFULFILL-APEX-05', 'Subscription'); 
        prd5_idx3.Name = 'PRODUCT #5';
        prd5_idx3.DI_Index__c = idx3.Id; 
        prd5_idx3.DI_DefaultStatus__c = 'Installed';
        lstProduct2Insert.add(prd5_idx3); 

        database.insert(lstProduct2Insert);*/
        /*=======================================================================*/
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD
        //ParentDI  
        /*Asset asset1 = NI_TestClassData.createTestAsset(1, acc1.Id, prd1_idx1.Id);
        asset1.Status = 'Shipped';
        //asset1.Product_Group__c = pgp.Id;
        //asset1.Version__c = vrs01.Id;
        Insert asset1;
        
        //ChildDI
        Asset asset2 = NI_TestClassData.createTestAsset(2, acc2.Id, prd2_idx1.Id);
        asset2.Status = 'Shipped';
        asset2.Parent_DI__c = asset1.Id;
        //asset1.Version__c = vrs01.Id;
        Insert asset2;
        
        Test.StartTest();
        List<Softrax_Asset__c> lstSoftraxAssetInsert = new List<Softrax_Asset__c>();
        //CREATE TEST SOFTRAX ASSET RECORD 
        Softrax_Asset__c sa1_prd1_idx1 = NI_TestClassData.createSoftraxAsset(1, acc1.Id, 'ZZZFULFILL-APEX-01');
        sa1_prd1_idx1.Quantity__c = 1;
        sa1_prd1_idx1.Account__c = acc1.Id;
        sa1_prd1_idx1.Product2Id__c = prd1_idx1.Id;
        sa1_prd1_idx1.Deployment_Instance__c = asset2.Id;
        sa1_prd1_idx1.Start_Date__c = Date.today();                
        sa1_prd1_idx1.End_Date__c = Date.today().addDays(60); // 2016-01-01
        sa1_prd1_idx1.Softrax_Status__c = 'A';
        sa1_prd1_idx1.SoftraxUploadRecordNumber__c = '000001';
        sa1_prd1_idx1.Fee__c = 1000;
        sa1_prd1_idx1.Total__c = 1000;
        lstSoftraxAssetInsert.Add(sa1_prd1_idx1);*/
            
        //CREATE TEST SOFTRAX ASSET RECORD
        /*Softrax_Asset__c sa2_prd3_idx2 = NI_TestClassData.createSoftraxAsset(3, acc2.Id, 'ZZZFULFILL-APEX-03');
        sa2_prd3_idx2.Quantity__c = 100;
        sa2_prd3_idx2.Product2Id__c = prd3_idx2.Id;
        sa1_prd1_idx1.Deployment_Instance__c = asset2.Id;
        sa2_prd3_idx2.Start_Date__c = Date.today();                
        sa2_prd3_idx2.End_Date__c = Date.today().addDays(90);
        sa2_prd3_idx2.Softrax_Status__c = 'I';
        sa2_prd3_idx2.SoftraxUploadRecordNumber__c = '000003';
        sa2_prd3_idx2.Fee__c = 1000;
        sa2_prd3_idx2.Total__c = 4000;
        lstSoftraxAssetInsert.Add(sa2_prd3_idx2);
        
        //CREATE TEST SOFTRAX ASSET RECORD
        Softrax_Asset__c sa3_prd3_idx2 = NI_TestClassData.createSoftraxAsset(3, acc1.Id, 'ZZZFULFILL-APEX-03');
        sa3_prd3_idx2.Quantity__c = 100;
        sa3_prd3_idx2.Product2Id__c = prd3_idx2.Id;
        sa3_prd3_idx2.Start_Date__c = Date.today();                
        sa3_prd3_idx2.End_Date__c = Date.today().addDays(60);
        sa3_prd3_idx2.Softrax_Status__c = 'A';
        sa3_prd3_idx2.SoftraxUploadRecordNumber__c = '000003';
        sa3_prd3_idx2.Fee__c = 1000;
        sa3_prd3_idx2.Total__c = 4000;
        lstSoftraxAssetInsert.Add(sa3_prd3_idx2);
        
        //CREATE TEST SOFTRAX ASSET RECORD
        Softrax_Asset__c sa3_prd4_idx2 = NI_TestClassData.createSoftraxAsset(4, acc1.Id, 'ZZZFULFILL-APEX-03');
        sa3_prd4_idx2.Quantity__c = 100;
        sa3_prd4_idx2.Product2Id__c = prd3_idx2.Id;
        sa3_prd4_idx2.Start_Date__c = Date.today();                
        sa3_prd4_idx2.End_Date__c = Date.today().addDays(60);
        sa3_prd4_idx2.Softrax_Status__c = 'A';
        sa3_prd4_idx2.SoftraxUploadRecordNumber__c = '000003';
        sa3_prd4_idx2.Fee__c = 1000;
        sa3_prd4_idx2.Total__c = 4000;
        lstSoftraxAssetInsert.Add(sa3_prd4_idx2);
        */
        //After Insert
        /*database.insert(lstSoftraxAssetInsert);
        
        //After Delete
        //delete sa3_prd3_idx2;
        
        
        //After Undelete
        //delete sa3_prd4_idx2;        
        //undelete sa3_prd4_idx2;        
        
        Test.StopTest();
        
        //Verify that "Type" field on Account is updated.
        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,Type,Billing_Status__c FROM Account WHERE Id IN  (:acc1.Id,:acc2.Id)]);
        system.debug(accMap);
        system.assertEquals('Billable',accMap.get(acc1.Id).Billing_Status__c);
        system.assertEquals('Consumer',accMap.get(acc2.Id).Billing_Status__c);
        
        //Verify that "status" Field on child DI's are Updated to " Installed"
        Asset depIns = [Select Status FROM Asset Where Id = : asset2.Id];
        system.assertEquals('Installed',depIns.Status);
        
        //After Update
        sa1_prd1_idx1.Account__c = acc2.Id;
        sa1_prd1_idx1.Quantity__c = 10;
        sa1_prd1_idx1.Product2Id__c = prd3_idx2.Id;
        database.update(sa1_prd1_idx1);
        
    }*/

}