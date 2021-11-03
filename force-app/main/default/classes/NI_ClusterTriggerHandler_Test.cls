/************************************************************************************************
Name            : ClusterTriggerHandler Class
Author          : Sunita Mittal
Created Date    : 12/07/2015
Last Mod Date   : 01/04/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-016293
Description     : Test class for NI_ClusterTriggerHandler
                : 
*************************************************************************************************/
@isTest
private class NI_ClusterTriggerHandler_Test 
{
  
    public static testMethod void testUpdateDIIndex() 
    {
        
        // Create Test Delphi Data
        NI_DeploymentInstanceIndex__c diIndexDelphi = createDIIndex('Delphi'); 
        Product_Group__c prodGrpDelphi = createProductGroup('Delphi');
        SFDC_CSP_Version__c versionDelphi = createVersion('V1Delphi', prodGrpDelphi.Id, 'Delphi');
        SFDC_CSP_Version__c versionDelphi1 = createVersion('V2Delphi', prodGrpDelphi.Id, 'Delphi'); 
        Product2 prodDelphi = createProduct('Cyb Product Code', 'Cyb Test Product Name', prodGrpDelphi.Id, prodGrpDelphi.Id, diIndexDelphi.Id);      
        
        // Create Test Daylight Data
        NI_DeploymentInstanceIndex__c diIndexDayli = createDIIndex('Daylight');
        Product_Group__c prodGrpDayLi = createProductGroup('Daylight');
        SFDC_CSP_Version__c versionDayLi = createVersion('V2', prodGrpDayli.Id, 'Daylight');
        Product2 prodDayLi = createProduct('Cyb Product Code1', 'Cyb Test Product Name1', prodGrpDayli.Id, prodGrpDayli.Id, diIndexDayli.Id);
        
        // Create Test MeetingMatrix Cluster
        NI_DeploymentInstanceIndex__c meetMatrixIndex = createDIIndex('MeetingMatrix');
        Product_Group__c meetMatrixProdGrp = createProductGroup('MeetingMatrix');
        SFDC_CSP_Version__c meetMatrixVersion = createVersion('MeetingMatrix Vertion 1.1', meetMatrixProdGrp.Id, 'MeetingMatrix');
        Product2 meetMatrixProd = createProduct('ProdMeetingmatrix-1', 'Meetingmatrixprod-1', meetMatrixProdGrp.Id, meetMatrixProdGrp.Id, meetMatrixIndex.Id);        
        
        // Create Account
        Account acc = createAccount('Cyb Test Account11', null, null, 'IN', 'AB', '12, west', 'New South Wales');

        // fetch all picklist value of product line 
        map<string,string> productLines = new map<string,string>();
        productLines = getPicklistProductLines();

        Test.startTest();
        
        List<Cluster__c> clusterList = new List<Cluster__c>();
        
        // Create Delphi Cluster
        Cluster__c clus1 = NI_TestClassData.createMPECluster(1);
        clus1.Name = 'Cyb Delphi Cluster Test';
        clus1.Product_Line_Global__c = productLines.get('Delphi');		   
        clus1.Version_New__c = versionDelphi.Id;        
        clus1.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'Delphi/Daylight');
        clus1.Management_Company__c = acc.Id;
        clusterList.add(clus1);
        
        // Create MeetingMatrix Cluster
        Cluster__c clus2 = NI_TestClassData.createMPECluster(1);
        clus2.Name = 'Cyb Meeting Matrix Cluster Test';
        clus2.Product_Line_Global__c = productLines.get('MeetingMatrix');
        clus2.Management_Company__c = acc.Id;       
        clus2.Version_New__c = meetMatrixVersion.Id;        
        clus2.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'MeetingMatrix Cluster');
        clusterList.add(clus2);
        
        insert clusterList; 
        
        try
        {
            clus1.Management_Company__c = acc.Id;
            //clus1.Cluster_Status__c = 'Installed';
            clus1.Product_Line_Global__c = productLines.get('MeetingMatrix');
            clus2.Management_Company__c = acc.Id;
            //clus2.Cluster_Status__c = 'Installed';
            clusterList = new List<Cluster__c>();
            clusterList.add(clus1);
            clusterList.add(clus2);
            update clusterList;
        }
        catch (Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('The Product Line cannot be updated.') ? true : false;
        }
        
        Test.stopTest();
        
        // Verify that DI_Index is Auto updated
        Map<Id,Cluster__c> ClusterIndex = new Map<Id,Cluster__c>([SELECT Id,DI_Index__c FROM Cluster__c WHERE Id =: clus2.Id OR Id =: clus1.Id]);           
        system.assertEquals(ClusterIndex.get(clus1.Id).DI_Index__c, diIndexDelphi.Id);
        system.assertEquals(ClusterIndex.get(clus2.Id).DI_Index__c, meetMatrixIndex.Id);   
        
    }
    
    public static testMethod void testUpdateDI() 
    {
        
        // Create Test Delphi Data
        NI_DeploymentInstanceIndex__c diIndexDelphi = createDIIndex('Delphi'); 
        Product_Group__c prodGrpDelphi = createProductGroup('Delphi');
        SFDC_CSP_Version__c versionDelphi = createVersion('V1Delphi', prodGrpDelphi.Id,'Delphi');
        SFDC_CSP_Version__c versionDelphi1 = createVersion('V2Delphi', prodGrpDelphi.Id,'Delphi'); 
        Product2 prodDelphi = createProduct('Cyb Product Code', 'Cyb Test Product Name', prodGrpDelphi.Id, prodGrpDelphi.Id, diIndexDelphi.Id);        
        
        // Create Test MeetingMatrix Cluster
        NI_DeploymentInstanceIndex__c meetMatrixIndex = createDIIndex('MeetingMatrix');
        Product_Group__c meetMatrixProdGrp = createProductGroup('MeetingMatrix');
        SFDC_CSP_Version__c meetMatrixVersion = createVersion('MeetingMatrix Vertion 1.1', meetMatrixProdGrp.Id, 'MeetingMatrix');
        SFDC_CSP_Version__c meetMatrixVersion1 = createVersion('MeetingMatrix Vertion 1.2', meetMatrixProdGrp.Id, 'MeetingMatrix');
        Product2 meetMatrixProd = createProduct('ProdMeetingmatrix-1', 'Meetingmatrixprod-1', meetMatrixProdGrp.Id, meetMatrixProdGrp.Id, meetMatrixIndex.Id);
        
        // CREATE ACCOUNT
        Account acc = createAccount('Cyb Test Account1', null, null, 'IN', 'AB', '12, west', 'New South Wales');         
        
        // CREATE TEST DEPLOYMENT INSTANCE RECORD 
        List<Asset> assetList = new List<Asset>();  
        Asset asset1 = NI_TestClassData.createTestAsset(1, acc.Id, prodDelphi.Id);
        asset1.Status = 'Shipped';
        asset1.Product_Group__c = prodGrpDelphi.Id;
        asset1.Version__c = versionDelphi.Id;
        assetList.add(asset1); 
        
        // CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset asset2 = NI_TestClassData.createTestAsset(2, acc.Id, meetMatrixProd.Id);
        asset2.Status = 'Shipped';
        asset2.Product_Group__c = meetMatrixProdGrp.Id;
        asset2.Version__c = meetMatrixVersion.Id;
        assetList.add(asset2);
        Insert assetList;
        
        // fetch all picklist value of product line 
        Map<string,string> productLines = new Map<string,string>();
        productLines = getPicklistProductLines();
        
        Test.startTest();
        
        List<Cluster__c> clusterList = new List<Cluster__c>();
        
        Cluster__c clus = NI_TestClassData.createMPECluster(1);
        clus.Name = 'Cyb Cluster Test2';
        clus.Product_Line_Global__c = productLines.get('Delphi');
        clus.Cluster_Status__c = 'Installed' ;	    
        clus.Version_New__c = versionDelphi.Id;        
        clus.Purchased_Version__c = versionDelphi1.Id;        
        clus.Management_Company__c = acc.Id;        
        clus.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'Delphi/Daylight');
        clusterList.add(clus);
        
        Cluster__c clus1 = NI_TestClassData.createMPECluster(1);
        clus1.Name = 'Cyb Cluster Test1';
        
        clus1.Product_Line_Global__c = productLines.get('MeetingMatrix');
        clus1.Cluster_Status__c = 'Installed'; 
        clus1.Version_New__c = meetMatrixVersion.Id;        
        clus1.Purchased_Version__c = meetMatrixVersion.Id;        
        clus1.Management_Company__c = acc.Id;        
        clus1.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'MeetingMatrix Cluster');
        clusterList.add(clus1);
        
        insert clusterList;
        
        acc.Current_MPE_Cluster__c = clus.Id;
        acc.Current_MeetingMatrix_MPE_Cluster__c = clus1.Id;
        update acc;
        
        // Update Cluster: Change Version and Remove Management Company;
        clus.Version_New__c = versionDelphi1.Id;  
        clus1.Version_New__c = meetMatrixVersion1.Id; 
        clusterList = new List<cluster__c>();
        clusterList.add(clus);
        clusterList.add(clus1);
        update clusterList;
        Test.stopTest();                
        
        // Verify that "Current MPE Cluster" and "Current MeetingMatrix Cluster" is upated on Account
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Current_MPE_Cluster__c, Current_MeetingMatrix_MPE_Cluster__c FROM Account WHERE Id =: acc.Id]);         
        system.assertEquals(accMap.get(acc.Id).Current_MPE_Cluster__c, clus.Id);
        system.assertEquals(accMap.get(acc.Id).Current_MeetingMatrix_MPE_Cluster__c, clus1.Id); 
        
        // Verify that Version is changed on related DI
        Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, Version__c FROM Asset WHERE AccountId =: acc.Id]);
        system.assertEquals(versionDelphi1.Id, assetMap.get(asset1.Id).Version__c);
        system.assertEquals(meetMatrixVersion1.Id, assetMap.get(asset2.Id).Version__c);
        
    }
    
    public static testMethod void testUpdateManagementCompany() 
    {
        
        // Create Test Delphi Data
        NI_DeploymentInstanceIndex__c diIndexDelphi = createDIIndex('Delphi'); 
        Product_Group__c prodGrpDelphi = createProductGroup('Delphi');
        SFDC_CSP_Version__c versionDelphi = createVersion('V1Delphi', prodGrpDelphi.Id, 'Delphi');
        SFDC_CSP_Version__c versionDelphi1 = createVersion('V2Delphi', prodGrpDelphi.Id, 'Delphi'); 
        Product2 prodDelphi = createProduct('Cyb Product Code', 'Cyb Test Product Name', prodGrpDelphi.Id, prodGrpDelphi.Id, diIndexDelphi.Id);        
        
        // Create Test MeetingMatrix Cluster
        NI_DeploymentInstanceIndex__c meetMatrixIndex = createDIIndex('MeetingMatrix');
        Product_Group__c meetMatrixProdGrp = createProductGroup('MeetingMatrix');
        SFDC_CSP_Version__c meetMatrixVersion = createVersion('MeetingMatrix Vertion 1.1', meetMatrixProdGrp.Id,'MeetingMatrix');
        SFDC_CSP_Version__c meetMatrixVersion1 = createVersion('MeetingMatrix Vertion 1.2', meetMatrixProdGrp.Id,'MeetingMatrix');
        Product2 meetMatrixProd = createProduct('ProdMeetingmatrix-1', 'Meetingmatrixprod-1', meetMatrixProdGrp.Id, meetMatrixProdGrp.Id, meetMatrixIndex.Id);
        
        // Create Account
        Account acc = createAccount('Cyb Test Account1',null,null,'IN','AB','12, west','New South Wales');
        
        // UPDATED PER NICC-017489 TO PREVENT ACCOUNT DUPLICATE MANAGEMENT RULE FROM FIRING
        Account acc1 = createAccount('Cyb2', null, null, 'IN', 'AB', '12, west', 'New South Wales'); 
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD
        List<Asset> assetList = new List<Asset>();  
        Asset asset1 = NI_TestClassData.createTestAsset(1, acc.Id, prodDelphi.Id);
        asset1.Status = 'Shipped';
        asset1.Product_Group__c = prodGrpDelphi.Id;
        asset1.Version__c = versionDelphi.Id;
        assetList.add(asset1); 
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset asset2 = NI_TestClassData.createTestAsset(2, acc.Id, meetMatrixProd.Id);
        asset2.Status = 'Shipped';
        asset2.Product_Group__c = meetMatrixProdGrp.Id;
        asset2.Version__c = meetMatrixVersion.Id;
        assetList.add(asset2);
        
        Asset asset3 = NI_TestClassData.createTestAsset(3, acc1.Id, prodDelphi.Id);
        asset3.Status = 'Shipped';
        asset3.Product_Group__c = prodGrpDelphi.Id;
        asset3.Version__c = versionDelphi.Id;
        assetList.add(asset3); 
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset asset4 = NI_TestClassData.createTestAsset(4, acc1.Id, meetMatrixProd.Id);
        asset4.Status = 'Shipped';
        asset4.Product_Group__c = meetMatrixProdGrp.Id;
        asset4.Version__c = meetMatrixVersion.Id;
        assetList.add(asset4);
        
        insert assetList;
        
        Test.startTest();
        
        List<Cluster__c> clusterList = new List<Cluster__c>();
        
        // fetch all picklist value of product line 
        map<string,string> productLines = new map<string,string>();
        productLines = getPicklistProductLines();
        
        Cluster__c clus = NI_TestClassData.createMPECluster(1);
        clus.Name = 'Cyb Cluster Test2';
        clus.Product_Line_Global__c = productLines.get('Delphi');
        
        clus.Version_New__c = versionDelphi.Id;        
        clus.Purchased_Version__c = versionDelphi1.Id;        
        clus.Management_Company__c = acc.Id;       
        clus.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'Delphi/Daylight');
        clusterList.add(clus);
        
        Cluster__c clus1 = NI_TestClassData.createMPECluster(1);
        clus1.Name = 'Cyb Cluster Test1';
        clus1.Product_Line_Global__c = productLines.get('MeetingMatrix');
        clus1.Version_New__c = meetMatrixVersion.Id;        
        clus1.Purchased_Version__c = meetMatrixVersion.Id;        
        clus1.Management_Company__c = acc.Id;       
        clus1.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'MeetingMatrix Cluster');
        clusterList.add(clus1);
        
        insert clusterList;
        
        clus.Management_Company__c = acc1.Id;
        clus.Cluster_Status__c = 'Installed';
        clus1.Management_Company__c = acc1.Id;
        clus1.Cluster_Status__c = 'Installed';
        clusterList = new List<Cluster__c>();
        clusterList.add(clus);
        clusterList.add(clus1);
        
        try
        {
            update clusterList;
        }
        catch (Exception e)
        {
            system.debug(e.getMessage());
        }                
        
        Test.stopTest();
        
        // Verify that "Current MPE Cluster" and "Current MeetingMatrix Cluster" is upated on Account
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Current_MPE_Cluster__c, Current_MeetingMatrix_MPE_Cluster__c FROM Account WHERE Id =: acc1.Id]);         
        system.assertEquals(accMap.get(acc1.Id).Current_MPE_Cluster__c, clus.Id);
        system.assertEquals(accMap.get(acc1.Id).Current_MeetingMatrix_MPE_Cluster__c, clus1.Id); 
        
    }
    
    public static testMethod void testRemoveManagementCompany() 
    {
        
        // Create Test Delphi Data
        NI_DeploymentInstanceIndex__c diIndexDelphi = createDIIndex('Delphi'); 
        Product_Group__c prodGrpDelphi = createProductGroup('Delphi');
        Product_Group__c prodGrpDaylight = createProductGroup('Daylight');
        SFDC_CSP_Version__c versionDelphi = createVersion('V1Delphi', prodGrpDelphi.Id,'Delphi');
        SFDC_CSP_Version__c versionDelphi1 = createVersion('V2Delphi', prodGrpDelphi.Id,'Delphi'); 
        Product2 prodDelphi = createProduct('Cyb Product Code', 'Cyb Test Product Name', prodGrpDelphi.Id, prodGrpDelphi.Id, diIndexDelphi.Id);        
        
        // Create Test MeetingMatrix Cluster
        NI_DeploymentInstanceIndex__c meetMatrixIndex = createDIIndex('MeetingMatrix');
        Product_Group__c meetMatrixProdGrp = createProductGroup('MeetingMatrix');
        SFDC_CSP_Version__c meetMatrixVersion = createVersion('MeetingMatrix Vertion 1.1', meetMatrixProdGrp.Id, 'MeetingMatrix');
        SFDC_CSP_Version__c meetMatrixVersion1 = createVersion('MeetingMatrix Vertion 1.2', meetMatrixProdGrp.Id, 'MeetingMatrix');
        Product2 meetMatrixProd = createProduct('ProdMeetingmatrix-1', 'Meetingmatrixprod-1', meetMatrixProdGrp.Id, meetMatrixProdGrp.Id, meetMatrixIndex.Id);
        
        // CREATE ACCOUNT
        Account acc = createAccount('Cyb Test Account1', null, null, 'IN', 'AB', '12, west', 'New South Wales');
        
        // CREATE TEST DEPLOYMENT INSTANCE RECORD
        List<Asset> assetList = new List<Asset>();  
        Asset asset1 = NI_TestClassData.createTestAsset(1, acc.Id, prodDelphi.Id);
        asset1.Status = 'Shipped';
        asset1.Product_Group__c = prodGrpDelphi.Id;
        asset1.Version__c = versionDelphi.Id;
        assetList.add(asset1); 
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset asset2 = NI_TestClassData.createTestAsset(2, acc.Id, meetMatrixProd.Id);
        asset2.Status = 'Shipped';
        asset2.Product_Group__c = meetMatrixProdGrp.Id;
        asset2.Version__c = meetMatrixVersion.Id;
        assetList.add(asset2);
        insert assetList;

        // fetch all picklist value of product line 
        Map<string, string> productLines = new Map<string, string>();
        productLines = getPicklistProductLines();
        
        Test.startTest();
        
        List<Cluster__c> clusterList = new List<Cluster__c>();
        
        Cluster__c clus = NI_TestClassData.createMPECluster(1);
        clus.Name = 'Cyb Cluster Test2';
        clus.Product_Line_Global__c = productLines.get('Delphi');
        
        clus.Version_New__c = versionDelphi.Id;        
        clus.Management_Company__c = acc.Id;        
        clus.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'Delphi/Daylight');
        clusterList.add(clus);
        
        Cluster__c clus1 = NI_TestClassData.createMPECluster(1);
        clus1.Name = 'Cyb Cluster Test1';
        clus1.Product_Line_Global__c = productLines.get('MeetingMatrix');
        
        clus1.Version_New__c = meetMatrixVersion.Id;        
        clus1.Purchased_Version__c = meetMatrixVersion.Id;        
        clus1.Management_Company__c = acc.Id;        
        clus1.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'MeetingMatrix Cluster');
        clusterList.add(clus1);
        
        insert clusterList;
        
        acc.Current_MPE_Cluster__c = clus.Id;
        acc.Current_MeetingMatrix_MPE_Cluster__c = clus1.Id;
        update acc;
        
        // Update Cluster: Change Version and Remove Management Company;
        clus.Management_Company__c = null;       
        clus1.Management_Company__c = null;
        
        clusterList = new List<cluster__c>();
        clusterList.add(clus);
        clusterList.add(clus1);
        update clusterList;
        
        Test.stopTest();  
        
        //Verfy that "Current MPE Cluster" and  "Current MeetingMatrix Cluster" is upated on Account
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Current_MPE_Cluster__c, Current_MeetingMatrix_MPE_Cluster__c FROM Account WHERE Id =: acc.Id]);         
        system.assertEquals(null,accMap.get(acc.Id).Current_MPE_Cluster__c);
        system.assertEquals(null,accMap.get(acc.Id).Current_MeetingMatrix_MPE_Cluster__c);     
        
    }

    public static testMethod void testDifferentProfileUser1() 
    {
        
        User u = NI_TestClassData.createTestUser(11, 'System Administrator'); 
        insert u;
        
        //Create Test Delphi Data
        system.runAs(u) 
        {
            
            NI_DeploymentInstanceIndex__c diIndexDelphi = createDIIndex('Delphi'); 
            Product_Group__c prodGrpDelphi = createProductGroup('Delphi');
            Product_Group__c prodGrpDaylight = createProductGroup('Daylight');
            SFDC_CSP_Version__c versionDelphi = createVersion('V1Delphi', prodGrpDelphi.Id, 'Delphi');
            SFDC_CSP_Version__c versionDelphi1 = createVersion('V2Delphi', prodGrpDelphi.Id, 'Delphi'); 
            Product2 prodDelphi = createProduct('Cyb Product Code', 'Cyb Test Product Name', prodGrpDelphi.Id, prodGrpDelphi.Id, diIndexDelphi.Id);
            
            //Create Test Daylight Data
            NI_DeploymentInstanceIndex__c diIndexDayli = createDIIndex('Daylight');
            Product_Group__c prodGrpDayLi = createProductGroup('Daylight');
            SFDC_CSP_Version__c versionDayLi = createVersion('V2', prodGrpDayli.Id, 'Daylight');
            Product2 prodDayLi = createProduct('Cyb Product Code1', 'Cyb Test Product Name1', prodGrpDayli.Id, prodGrpDayli.Id, diIndexDayli.Id);

            //Create Test MeetingMatrix Cluster
            NI_DeploymentInstanceIndex__c meetMatrixIndex = createDIIndex('MeetingMatrix');
            Product_Group__c meetMatrixProdGrp = createProductGroup('MeetingMatrix');
            SFDC_CSP_Version__c meetMatrixVersion = createVersion('MeetingMatrix Vertion 1.1', meetMatrixProdGrp.Id, 'MeetingMatrix');
            SFDC_CSP_Version__c meetMatrixVersion1 = createVersion('MeetingMatrix Vertion 1.2', meetMatrixProdGrp.Id, 'MeetingMatrix');
            Product2 meetMatrixProd = createProduct('ProdMeetingmatrix-1', 'Meetingmatrixprod-1', meetMatrixProdGrp.Id, meetMatrixProdGrp.Id, meetMatrixIndex.Id);
            
            // Create Account
            Account acc = createAccount('Cyb Test Account1', null, null, 'IN','AB','12, west','New South Wales');
            
            //CREATE TEST DEPLOYMENT INSTANCE RECORD
            List<Asset> assetList = new List<Asset>();  
            Asset asset1 = NI_TestClassData.createTestAsset(1, acc.Id, prodDelphi.Id);
            asset1.Status = 'Shipped';
            asset1.Product_Group__c = prodGrpDelphi.Id;
            asset1.Version__c = versionDelphi.Id;
            assetList.add(asset1); 
            
            //CREATE TEST DEPLOYMENT INSTANCE RECORD  
            Asset asset2 = NI_TestClassData.createTestAsset(2, acc.Id, meetMatrixProd.Id);
            asset2.Status = 'Shipped';
            asset2.Product_Group__c = meetMatrixProdGrp.Id;
            asset2.Version__c = meetMatrixVersion.Id;
            assetList.add(asset2);
            insert assetList;
            
            // fetch all picklist value of product line 
            Map<string, string> productLines = new Map<string, string>();
            productLines = getPicklistProductLines();
            
            Test.startTest();
            
            List<Cluster__c> clusterList = new List<Cluster__c>();
            
            Cluster__c clus = NI_TestClassData.createMPECluster(1);
            clus.Name = 'Cyb Cluster Test--1';
            clus.Product_Line_Global__c = productLines.get('Delphi');
            clus.DI_Index__c = diIndexDelphi.Id;      
            clus.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'Delphi/Daylight');
            clusterList.add(clus);
            
            Cluster__c clus1 = NI_TestClassData.createMPECluster(1);
            clus1.Name = 'Cyb Cluster Test--2';
            clus1.DI_Index__c = null;
            clus1.Product_Line_Global__c = productLines.get('MeetingMatrix');        
            clus1.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'MeetingMatrix Cluster');
            clusterList.add(clus1); 
            
            Cluster__c clus2 = NI_TestClassData.createMPECluster(1);
            clus2.Name = 'Cyb Cluster Test--3';
            clus2.DI_Index__c = null;
            clus2.Product_Line_Global__c = productLines.get('Delphi');       
            clus2.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'Delphi/Daylight');
            clusterList.add(clus2);
            
            insert clusterList;
            
            clus1.Product_Line_Global__c = productLines.get('MeetingMatrix');
            clus.Product_Line_Global__c = productLines.get('Delphi');
            clus2.DI_Index__c = diIndexDayli.Id;
            clusterList = new List<cluster__c>();
            clusterList.add(clus);
            clusterList.add(clus1);
            clusterList.add(clus2);
            update clusterList;
            
            Test.stopTest();  
            
            Map<Id, Cluster__c> ClusterIndex = new Map<Id, Cluster__c>([SELECT Id, DI_Index__c FROM Cluster__c WHERE Id =: clus.Id OR Id =: clus1.Id]);           
            system.assertEquals(ClusterIndex.get(clus.Id).DI_Index__c, diIndexDelphi.Id);
            system.assertEquals(ClusterIndex.get(clus1.Id).DI_Index__c, meetMatrixIndex.Id);
            
        } 
        
    } 
    
    // COVERAGE FOR TRIGGERHANDLER PLACEHOLDER EVENTS  
    public static testMethod void testPlaceholders()  
    {   
        NI_clusterTriggerHandler handler = new NI_clusterTriggerHandler();
        List<Cluster__c> lst = new List<Cluster__c>();
        Map<Id, Cluster__c> mp = new Map<Id, Cluster__c>();
        handler.OnAfterInsert(mp);               
        handler.OnAfterUpdate(mp, mp);                
    } 
        
    // ==============================================================================================
    // 		TEST RECORD CREATION METHODS 
    // ==============================================================================================
    public static Product_Group__c createProductGroup(String prodGrpName)
    {
        //Product_Group__c prodGrp = new Product_Group__c(Name = prodGrpName);
        Product_Group__c prodGrp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
        prodGrp.Name = prodGrpName;
        insert prodGrp;        
        return prodGrp;
    }
    
    public static SFDC_CSP_Version__c createVersion(String verNum, Id ProdGrpId, string productLine)
    {
        //SFDC_CSP_Version__c version = new SFDC_CSP_Version__c(Name = verNum, Product_Group__c = ProdGrpId, Product_Line_Global__c = productLine);
        SFDC_CSP_Version__c version = NI_TestClassData.createVersion('v1.', ProdGrpId, 1);
        version.Name = verNum;
        version.Product_Line_Global__c = productLine;
        insert version;        
        return version;
    }
    
    public static NI_DeploymentInstanceIndex__c createDIIndex(String DIIndexName)
    {
        // NI_DeploymentInstanceIndex__c DIIndex = new NI_DeploymentInstanceIndex__c(Name = DIIndexName);
        NI_DeploymentInstanceIndex__c DIIndex = NI_TestClassData.createDI_Index(1, 'APEX TEST');
        DIIndex.Name = DIIndexName;
        insert DIIndex;        
        return DIIndex;
    }
    
    public static Product2 createProduct(String prodcode, String prodName, Id ProdGrpId, Id corpProdGrp, Id diIndex)
    {
        // Product2 prod = new Product2(productCode = prodcode, Name = prodName, Product_Group__c = ProdGrpId, Corporate_Product_Group__c = corpProdGrp, DI_Index__c = diIndex, Line_Classification_Global__c = 'Connector', Line_Subclassification_Global__c = 'I-Server',  Interface_Classification__c = 'Portal', Support_Classification__c = 'Gold', Edition__c = 'Enterprise', Revenue_Category__c = 'Services');
        Product2 prod = NI_TestClassData.createProduct2(1, ProdGrpId, prodcode, 'Subscription'); 
        prod.Name = prodName;
        prod.Corporate_Product_Group__c = corpProdGrp;
        prod.DI_Index__c = diIndex;
        prod.Line_Classification_Global__c = 'Connector';
        prod.Line_Subclassification_Global__c = 'I-Server';
        prod.Interface_Classification__c = 'Portal';
        prod.Support_Classification__c = 'Gold';
        prod.Edition__c = 'Enterprise';
        prod.Revenue_Category__c = 'Services';        
        insert prod;        
        return prod;
    }
    
    public static Asset createDI(String DIName, Id prodId, Id AccId)
    {
        // Asset DI= new Asset(Name = DIName,AccountId = AccId,Product2Id = prodId);
        Asset DI = NI_TestClassData.createTestAsset(1, AccId, prodId);
        DI.Name = DIName;        
        insert DI;        
        return DI;
    }
    
    public static Account createAccount(String AccName, Id curCluster, Id tarCluster, String billCoun, String billState, String billStreet, String billCity)
    {
        // Account acc= new Account(Name = AccName, Current_MPE_Cluster__c = curCluster, Cluster__c = tarCluster, BillingCountry = billCoun, BillingState = billState, BillingStreet = billStreet, BillingCity = billCity);
        Account acc = NI_TestClassData.createTestAccount(1);
        acc.Name = AccName;
        acc.Current_MPE_Cluster__c= curCluster;
        acc.Cluster__c = tarCluster;
        acc.BillingCountry = billCoun;
        acc.BillingState = billState;
        acc.BillingStreet = billStreet;
        acc.BillingCity = billCity;
        insert acc;        
        return acc;
    }        
    
    public static map<string, string> getPicklistProductLines()
    {
        map<string, string> productLines = new map<string, string>();
        Schema.DescribeFieldResult fieldResult = Cluster__c.Product_Line_Global__c.getDescribe();
        List<Schema.PicklistEntry> prodLinesPicklist = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pl : prodLinesPicklist)
        {
            productLines.put(pl.getValue(), pl.getValue());
        } 
        return productLines;
    }
    
}