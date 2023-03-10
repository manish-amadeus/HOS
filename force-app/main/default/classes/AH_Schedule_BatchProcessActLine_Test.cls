/********************************************************************************************************
Name            : AH_Schedule_BatchProcessActLine_Test Class
Author          : Ria Chawla
Created Date    : 05/18/2018
Last Mod Date   : 05/22/2018 
Last Mod By     : Ria Chawla
NICC Reference  : 
Description     : Test class for AH_Schedule_BatchProcessActivityLines apex class 
                :
/**********************************************************************************************************/
@isTest
public class AH_Schedule_BatchProcessActLine_Test {
    // =============================================================================================================
    // 		CREATE TEST DATA 
    // =============================================================================================================
    @testSetup static void createTestData() 
    {    
        
        system.debug(' *** AH_Schedule_BatchProcessActLine_Test.createTestData() - START ***'); 
        
        Test.startTest();
        
        // CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(10);        
        a.Name = 'APEX TEST 600';
        a.Type = 'Prospect';
        insert a;
        
        List<Account> lstAccountAsserts = new List<Account>([SELECT Id FROM Account]);
        system.assertEquals(1, lstAccountAsserts.size());
        
        // CREATE TEST CONTACT RECORD 
        Contact c = NI_TestClassData.createTestContact(1, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuser';    
        c.Email = 'testuser@cybage.com';
        insert c; 
        
        // CREATE TEST DI INDEX RECORDS 
        NI_DeploymentInstanceIndex__c testDiIndex1 = new NI_DeploymentInstanceIndex__c();
        testDiIndex1 = NI_TestClassData.createDI_Index(1, 'APEX TEST 1');
        insert testDiIndex1;
        
        NI_DeploymentInstanceIndex__c testDiIndex2 = new NI_DeploymentInstanceIndex__c();
        testDiIndex2 = NI_TestClassData.createDI_Index(2, 'APEX TEST 2');
        insert testDiIndex2;
        
        List<NI_DeploymentInstanceIndex__c> lstDIIndexAsserts = new List<NI_DeploymentInstanceIndex__c>([SELECT Id FROM NI_DeploymentInstanceIndex__c]);
        system.assertEquals(2, lstDIIndexAsserts.size());
        
        // CREATE TEST PRODUCT GROUP RECORD 
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST 1');
        insert pgp;
        
        List<Product_Group__c> lstProductGroupAsserts = new List<Product_Group__c>([SELECT Id FROM Product_Group__c]);
        system.assertEquals(1, lstProductGroupAsserts.size());
        
        // CREATE TEST PRODUCT2 RECORDS        
        Product2 prd1 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-PROD2-01', 'Subscription'); 
        prd1.DI_Index__c = testDiIndex1.Id;
        prd1.Product_Line_Global__c = 'Delphi';
        prd1.Hosted__c = true;
        insert prd1;
        
        Product2 prd2 = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-PROD2-02', 'Subscription'); 
        prd2.DI_Index__c = testDiIndex2.Id;
        prd2.Product_Line_Global__c = 'Delphi';
        prd2.Hosted__c = true;
        insert prd2;
        
        List<Product2> lstProduct2Asserts = new List<Product2>([SELECT Id FROM Product2]);
        system.assertEquals(2, lstProduct2Asserts.size());
        
        // CREATE TEST DEPLOYMENT INSTANCE RECORDS
        Asset di1 = NI_TestClassData.createTestAsset(1, a.Id, prd1.Id);
        di1.Status = 'Purchased';        
        di1.Product_Group__c = pgp.Id;
        di1.Quantity_Provisioned__c = 0; 
        insert di1; 
        
        Asset di2 = NI_TestClassData.createTestAsset(2, a.Id, prd2.Id);
        di2.Status = 'Purchased';        
        di2.Product_Group__c = pgp.Id;
        di2.Quantity_Provisioned__c = 0; 
        insert di2; 
        
        List<Asset> lstAssetAsserts = new List<Asset>([SELECT Id, Name, AccountId FROM Asset]);
        system.assertEquals(2, lstAssetAsserts.size());
        
        
        Test.stopTest(); 
        
        // CREATE TEST OPPORTUNITY RECORD 
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rt = OpportunityRecordTypeInfo.get('Small Deal Opportunity').getRecordTypeId();  
        
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.Name = 'APEX TEST 1';
        opp1.RecordTypeId = rt;
        insert opp1;
        
        List<Opportunity> lstOpportunityAsserts = new List<Opportunity>([SELECT Id FROM Opportunity]);
        system.assertEquals(1, lstOpportunityAsserts.size());        
        
        
        // CREATE BILLING CONTRACT RECORD 
        Billing_Contract__c bc1 = NI_TestClassData.createBillingContract(1);
        bc1.Account__c = a.Id;
        bc1.Opportunity__c = opp1.Id;            
        insert bc1;
        
        // CREATE ACTIVITY LINE ITEM RECORDS 
        List<Activity_Line_Item__c> aliList = new List<Activity_Line_Item__c>();
        
        Activity_Line_Item__c ali1 = NI_TestClassData.createActivityLineItem(bc1.Id);   
        ali1.Deployment_Instance__c = di1.Id;
        ali1.Opportunity__c = opp1.Id;
        ali1.Status__c = 'Active';
        ali1.Account__c = a.Id;
        ali1.Revenue_Category__c = 'Support';
        ali1.Auto_Renewal__c = true;
        ali1.Contract_End_Date__c = Date.today().addDays(90);
        ali1.Revenue_Category__c = 'Support';
        aliList.add(ali1);
        
        Activity_Line_Item__c ali2 = NI_TestClassData.createActivityLineItem(bc1.Id);   
        ali2.Deployment_Instance__c = di2.Id;
        ali2.Opportunity__c = opp1.Id;
        ali2.Status__c = 'Active';
        ali2.Account__c = a.Id;
        aliList.add(ali2);
        
        database.insert(aliList);
        
        List<Activity_Line_Item__c> lstActivityLineItemAsserts = new List<Activity_Line_Item__c>([SELECT Id FROM Activity_Line_Item__c]);
        system.assertEquals(2, lstActivityLineItemAsserts.size());    
        
    }
    
    @isTest static void testScheduleBatchProcessActLines()
    {
        Datetime n = Datetime.now();
        n = n.addMinutes(5);                                                                                      
        String CRON_EXP = '0 ' + n.format('m') + ' ' + n.format('H') + ' ' + n.format('d') + ' ' + n.format('M') + ' ? '+ n.format('yyyy');                                                                                                                        
        AH_Schedule_BatchProcessActivityLines scheduleClass = new AH_Schedule_BatchProcessActivityLines();
        Test.startTest();
        Id scheduledJobId = system.schedule('Test', CRON_EXP, scheduleClass);
        Test.stopTest();
        List<AsyncApexJob> asyncJob = new List<AsyncApexJob>();
        try{
            asyncJob = [SELECT ApexClassId, CompletedDate, CreatedById, CreatedDate, Id, NumberOfErrors, Status
                        FROM AsyncApexJob
                        WHERE Status = 'Queued'
                        AND ApexClassId IN (Select Id from ApexClass where Name = 'AH_Schedule_BatchProcessActivityLines')];
            System.assertEquals(1, asyncJob.size());
        }
        catch(Exception e){
            
        }
    }

}