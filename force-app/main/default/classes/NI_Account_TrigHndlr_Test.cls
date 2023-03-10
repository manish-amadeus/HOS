/****************************************************************************************
Name            : NI_Account_TrigHndlr_Test Test Class
Author          : Stuart Emery
Created Date    : 1/09/2014
Last Mod Date   : 4/9/2016
Last Mod By     : Stuart Emery
NICC Reference  : NICC-009172
Description     : test Class for NI_Account_TriggerHandler Class
				:  
******************************************************************************************/
@isTest
private class NI_Account_TrigHndlr_Test 
{
    
    //====================================================================================================================     
    static testMethod void SingleAccountDelete() 
    {    
        
        //CREATE A TEST ACCOUNT  
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;

        a.Integrate_w_Softrax__c = true;
        update a;
        
        //INVOKE THE BEFORE DELETE LOGIC  
        Test.startTest();
        
        try 
        {
            delete a;
        } 
        catch(DmlException e) 
        {
            System.assert(e.getMessage().contains('This Account is integrated with Softrax and cannot be deleted'));
        }
        
        Test.stopTest();
        
    }
    
    //====================================================================================================================                         
    static testMethod void BulkAccountDelete() 
    {    

        //CREATE LIST OF ACCOUNTS TO INSERT
        List<Account> lstAccountsToInsert = new List<Account>();
        
        for (Integer j = 0; j < 25; j++) 
        {
            Account a = NI_TestClassData.createTestAccount(j);
//            a.Integrate_w_Softrax__c = true;
            lstAccountsToInsert.add(a);
        }
        
        Database.insert(lstAccountsToInsert);
        
        //LIST TO HOLD THE INSERTED Accounts
        List<Account> lstInsertedAccounts = [SELECT Id FROM Account];        
        
        
        List<Account> lstAccountsToUpdate = new List<Account>();
        
        for (Account a : lstInsertedAccounts)
        {
            lstAccountsToUpdate.Add(a);
            a.Integrate_w_Softrax__c = true;
        }
        
        Database.update(lstAccountsToUpdate);        

        //VALIDATE THAT ALL 25 Accounts WERE INSERTED  
        System.assertEquals(25, lstInsertedAccounts.size()); 
        
        //INVOKE THE BEFORE DELETE LOGIC
        Test.startTest();
        
        List<Id> lstAccountsNotDeleted = new List<Id>();  //LIST TO HOLD THE DELETED ACCOUNT ID's
//        Database.DeleteResult[] drList = Database.delete(lstInsertedAccounts, false);
		Database.DeleteResult[] drList = Database.delete(lstInsertedAccounts, false);

        for (Database.DeleteResult dr : drList) 
        {
            if (!dr.isSuccess()) 
            {
                lstAccountsNotDeleted.add(dr.getId());
            }
        }
        
        //VALIDATE THAT ALL 25 Accounts WERE NOT DELETED  
        System.assertEquals(25, lstAccountsNotDeleted.size());
        
        Test.stopTest();                                       
        
    } 

    public static testMethod void testCreateDI() 
    {
        
        //Craete an Account with Permanently closed Checked
        Account accforpermClosed = NI_TestClassData.createTestAccount(1);
        accforpermClosed.Name = 'Test Permanently Closed Checkbox';
        accforpermClosed.BillingPostalCode = '03801';
        accforpermClosed.BillingCountry = 'US';
        accforpermClosed.BillingState = 'NH';
        accforpermClosed.BillingStreet = '75 NH Ave';
        accforpermClosed.BillingCity = 'Portsmouth';
        accforpermClosed.Type = 'Prospect';
        accforpermClosed.Permanently_Closed__c = false;
        insert accforpermClosed;
        
        //Update the Account Permanently Closed to UnCheck
        accforpermClosed.Permanently_Closed__c = true;
        update accforpermClosed;       
        
        //Create Test Delphi Data
//NI_DeploymentInstanceIndex__c diIndexDelphi = createDIIndex('Delphi');
		NI_DeploymentInstanceIndex__c diIndexDelphi = NI_TestClassData.createDI_Index(1, 'Delphi');
        insert diIndexDelphi;
        
//Product_Group__c prodGrpDelphi = createProductGroup('Delphi');        
        Product_Group__c prodGrpDelphi = NI_TestClassData.createProductGroup(1, 'Delphi');
        insert prodGrpDelphi;        
        
//SFDC_CSP_Version__c versionDelphi = createVersion('V1', prodGrpDelphi.id,'Delphi');
        SFDC_CSP_Version__c versionDelphi = NI_TestClassData.createVersion('V1', prodGrpDelphi.Id, 1);
        versionDelphi.Product_Line_Global__c = 'Delphi';
        insert versionDelphi;
        
//SFDC_CSP_Version__c versionDelphi1 = createVersion('V3', prodGrpDelphi.id,'Delphi');
        SFDC_CSP_Version__c versionDelphi1 = NI_TestClassData.createVersion('V3', prodGrpDelphi.Id, 2);
        versionDelphi1.Product_Line_Global__c = 'Delphi';
        insert versionDelphi1;

//Product2 prodDelphi = createProduct('Cyb Product Code', 'Cyb Test Product Name', prodGrpDelphi.id, prodGrpDelphi.id, diIndexDelphi.Id);                
        Product2 prodDelphi = NI_TestClassData.createProduct2(1, prodGrpDelphi.Id, 'APEX-TEST-01', 'Subscription');        
        prodDelphi.productCode = 'Cyb Product Code';
        prodDelphi.Name = 'Cyb Test Product Name';
        prodDelphi.Product_Group__c = prodGrpDelphi.id;
        prodDelphi.Corporate_Product_Group__c = prodGrpDelphi.id;
        prodDelphi.DI_Index__c = diIndexDelphi.Id;
        prodDelphi.Line_Classification_Global__c = 'Connector';
        prodDelphi.Line_Subclassification_Global__c = 'I-Server';
        prodDelphi.Interface_Classification__c = 'Portal';
        prodDelphi.Support_Classification__c = 'Gold';                        
        prodDelphi.Edition__c = 'Enterprise';        
        insert prodDelphi; 
        
        
        
        // Create Test MeetingMatrix Data
//NI_DeploymentInstanceIndex__c meetMatrixIndex = createDIIndex('MeetingMatrix');
		NI_DeploymentInstanceIndex__c meetMatrixIndex = NI_TestClassData.createDI_Index(2, 'MeetingMatrix');
        insert meetMatrixIndex;
        
//Product_Group__c meetMatrixProdGrp = createProductGroup('MeetingMatrix');
        Product_Group__c meetMatrixProdGrp = NI_TestClassData.createProductGroup(2, 'MeetingMatrix');
        insert meetMatrixProdGrp;        
        
//SFDC_CSP_Version__c meetMatrixVersion = createVersion('MeetingMatrix Vertion 1.1', meetMatrixProdGrp.id,'MeetingMatrix');
        SFDC_CSP_Version__c meetMatrixVersion = NI_TestClassData.createVersion('MeetingMatrix Vertion 1.1', meetMatrixProdGrp.Id, 3);
        meetMatrixVersion.Product_Line_Global__c = 'MeetingMatrix';
        insert meetMatrixVersion;
        
//SFDC_CSP_Version__c meetMatrixVersion1 = createVersion('MeetingMatrix Vertion 1.2', meetMatrixProdGrp.id,'MeetingMatrix');
        SFDC_CSP_Version__c meetMatrixVersion1 = NI_TestClassData.createVersion('MeetingMatrix Vertion 1.2', meetMatrixProdGrp.Id, 4);
        meetMatrixVersion1.Product_Line_Global__c = 'MeetingMatrix';
        insert meetMatrixVersion1;
        
//Product2 meetMatrixProd = createProduct('ProdMeetingmatrix-1','Meetingmatrixprod-1',meetMatrixProdGrp.id,meetMatrixProdGrp.id,meetMatrixIndex.Id); 
        Product2 meetMatrixProd = NI_TestClassData.createProduct2(2, meetMatrixProdGrp.Id, 'APEX-TEST-02', 'Subscription');        
        meetMatrixProd.productCode = 'ProdMeetingmatrix-1';
        meetMatrixProd.Name = 'Meetingmatrixprod-1';
        meetMatrixProd.Product_Group__c = meetMatrixProdGrp.id;
        meetMatrixProd.Corporate_Product_Group__c = meetMatrixProdGrp.id;
        meetMatrixProd.DI_Index__c = meetMatrixIndex.Id;
        meetMatrixProd.Line_Classification_Global__c = 'Connector';
        meetMatrixProd.Line_Subclassification_Global__c = 'I-Server';
        meetMatrixProd.Interface_Classification__c = 'Portal';
        meetMatrixProd.Support_Classification__c = 'Gold';                        
        meetMatrixProd.Edition__c = 'Enterprise';        
        insert meetMatrixProd;         
        
        
        /** fetch all picklist value of product line */
        map<string, string> productLines = new map<string, string>();
        Schema.DescribeFieldResult fieldResult = Cluster__c.Product_Line_Global__c.getDescribe();
        List<Schema.PicklistEntry> prodLinesPicklist = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry pl : prodLinesPicklist)
        {
            productLines.put(pl.getValue(),pl.getValue());
        } 

        List<Cluster__c> clusterList = new List<Cluster__c>();
        Cluster__c currentCluster = new Cluster__c();
        currentCluster.Name = 'Cyb Cluster Test';
        currentCluster.Product_Line_Global__c = productLines.get('Delphi');
        currentCluster.Version_New__c = versionDelphi.Id;
        currentCluster.Purchased_Version__c = versionDelphi1.Id;        
        currentCluster.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'Delphi/Daylight');
        currentCluster.DI_Index__c = diIndexDelphi.Id;
        clusterList.add(currentCluster);
        
        Cluster__c currentCluster2 = new Cluster__c();
        currentCluster2.Name = 'Cyb Cluster Test2';
        currentCluster2.Product_Line_Global__c = productLines.get('Delphi');
        currentCluster2.Version_New__c = versionDelphi1.Id;        
        currentCluster2.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'Delphi/Daylight');
        currentCluster2.DI_Index__c = diIndexDelphi.Id;
        clusterList.add(currentCluster2);
        
        Cluster__c meetingMatrixclus1 = new Cluster__c();
        meetingMatrixclus1.Name = 'Cyb meetingMatrix Cluster Test1';
        meetingMatrixclus1.Product_Line_Global__c = productLines.get('MeetingMatrix');
        meetingMatrixclus1.Version_New__c = meetMatrixVersion.Id;       
        meetingMatrixclus1.Purchased_Version__c = meetMatrixVersion.Id;               
        meetingMatrixclus1.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'MeetingMatrix Cluster');
        meetingMatrixclus1.DI_Index__c = meetMatrixIndex.Id; 
        clusterList.add(meetingMatrixclus1);
        
        Cluster__c meetingMatrixclus2 = new Cluster__c();
        meetingMatrixclus2.Name = 'Cyb meetingMatrix Cluster Test2';
        meetingMatrixclus2.Product_Line_Global__c = productLines.get('MeetingMatrix');
        meetingMatrixclus2.Version_New__c = meetMatrixVersion.Id;        
        meetingMatrixclus2.Purchased_Version__c = meetMatrixVersion.Id;                
        meetingMatrixclus2.Hosted__c = true;
        meetingMatrixclus2.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'MeetingMatrix Cluster');
        meetingMatrixclus2.DI_Index__c = meetMatrixIndex.Id; 
        clusterList.add(meetingMatrixclus2);
        
        database.insert(clusterList);
        
        // Create an Account with Permanently closed Checked
        Account acc1 = NI_TestClassData.createTestAccount(1);
        acc1.Permanently_Closed__c = true;
        insert acc1;  
        acc1.Permanently_Closed__c = false;            
        update acc1;
        
        Test.startTest();
        
        // CREATE TEST ACCOUNT RECORD 
        Account acc = NI_TestClassData.createTestAccount(2); //CHANGED PER NICC-017489 TO PREVENT ACCOUNT DUPLICATE MANAGEMENT RULE FROM FIRING
        acc.Current_MPE_Cluster__c = currentCluster.Id;
        acc.Cluster__c = currentCluster.Id;
        acc.Current_meetingMatrix_MPE_Cluster__c = meetingMatrixclus1.Id;
        acc.Target_meetingMatrix_MPE_Cluster__c = meetingMatrixclus1.Id;        
        insert acc;        
        
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
        
        // Update the "Current MPE Cluster" and Current Meeting Matrix Cluster on Account
        acc.Current_MPE_Cluster__c = currentCluster2.Id;
        acc.cluster__c = currentCluster2.Id;
        acc.Current_meetingMatrix_MPE_Cluster__c = meetingMatrixclus2.Id;
        acc.Target_meetingMatrix_MPE_Cluster__c = meetingMatrixclus2.Id;        
        update acc;
        
        Account testErrorAccount =  NI_TestClassData.createTestAccount(3);
        insert testErrorAccount;
        
        try
        {
            testErrorAccount.current_MPE_Cluster__c = currentCluster.Id;
            testErrorAccount.current_MeetingMatrix_MPE_Cluster__c = meetingMatrixclus1.Id;
            update testErrorAccount;
        }
        catch (Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('This Account does not have an active Deployment Instance that matches the selected Cluster\'s DI Index') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
        Test.StopTest();   
        
        // Verfy DI for delphi and meeting matrix is created and matches the Cluster's data
        Map<Id,Asset> depIns = new Map<Id,Asset>([SELECT Version__c, isHostedDI__c FROM Asset WHERE AccountId =: acc.Id]);
        system.assertEquals(depIns.get(asset1.Id).Version__c, versionDelphi1.Id);
        system.assertEquals(depIns.get(asset2.Id).isHostedDI__c, meetingMatrixclus2.Hosted__c);   
        
    }
    
    //COVERAGE FOR TRIGGERHANDLER PLACEHOLDER EVENTS  
    public static testMethod void testPlaceholders()  
    {   
        NI_Account_TriggerHandler handler = new NI_Account_TriggerHandler();
        List<Account> lst = new List<Account>();
        Map<Id, Account> mp = new Map<Id, Account>();
        handler.onAfterInsert(mp);               
        handler.OnAfterUpdate(mp, mp);                
    }

}