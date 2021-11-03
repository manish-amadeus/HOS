/*******************************************************************************************
Name            : AH_Billing_Contract_TriggerHandler_Test Class
Author          : CLD Partners
Created Date    : 05/05/2016
Last Mod Date   : 03/26/2019 
Last Mod By     : Sean Harris
NICC Reference  : NICC-033935
Description     : test class for AH_Billing_Contract_TriggerHandler
                : 
*******************************************************************************************/
@isTest
public class AH_Billing_Contract_TriggerHandler_Test 
{

    
    // =======================================================================================================================================
    // = CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup static void createTestData() 
    {
        
        // CREATE PARTNER ACCOUNT
        Account pa = NI_TestClassData.createTestAccount(1);
        pa.Name = 'APEX TEST - PartnerCentral Account #1';
        pa.Partner_Chatter_Group_ID__c = Label.PartnerCentral_Chatter_Group_Id_for_Test_Classes;	// PRODUCTION '0F90d000000H8qmCAC'     
        insert pa;        
        
        // GET RUNNING USER RECORD
        User ru = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];        

        // CREATE TEST COMPANIES
        c2g__codaCompany__c testCompany1 = NI_TestClassData.createFFACompany('TEST COMPANY 1', ru, true);
        insert testCompany1;        
        
        c2g__codaCompany__c testCompany2 = NI_TestClassData.createFFACompany('TEST COMPANY 2', ru, false);
        insert testCompany2;               

        c2g__codaCompany__c co1 = [SELECT Id, Name, Legal_Entity_Name__c FROM c2g__codaCompany__c WHERE Name = 'TEST COMPANY 1'];
		c2g__codaCompany__c co2 = [SELECT Id, Name, Legal_Entity_Name__c FROM c2g__codaCompany__c WHERE Name = 'TEST COMPANY 2'];
        
        Group q1 = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'TEST COMPANY 1' LIMIT 1];
        
        c2g__codaAccountingCurrency__c ac1 = NI_TestClassData.createFFAAccountingCurrency('USD', co1.Id, q1.Id);
        insert ac1;     
        
//        Group q2 = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'TEST COMPANY 2' LIMIT 1];
        
//        c2g__codaAccountingCurrency__c ac2 = NI_TestClassData.createFFAAccountingCurrency('EUR', co2.Id, null);
//        insert ac2;          
        
/*        
        // CREATE TEST USER
        List<User> lstUserInsert = new List<User>();
        User u = NI_TestClassData.createTestUser(1, 'NI Finance'); 
        u.Alias = 'FIN01TST'; 
        insert u;         
        
        
        
        c2g__codaAccountingCurrency__c curr = [SELECT Id, Name FROM c2g__codaAccountingCurrency__c LIMIT 1];
        
        Remittance_Info__c rem = NI_TestClassData.createRemittanceInfo('Rem Info 1');
        rem.FFA_Currency__c = curr.Id;
        insert rem;
        
        system.runAs(u) 
        {
            co1.Remittance_Info__c = rem.Id;
            update co1;
            co2.Remittance_Info__c = rem.Id;
            update co2;            
        }            
*/        
        // CREATE TEST ACCOUNT
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id accRTId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();        

        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX AH_Billing_Contract_TriggerHandler_Test TEST';
        a.RecordTypeId = accRTId;
        a.Brand__c = 'Apex';      
        insert a;

        // CREATE TEST CONTACT RECORDS 
        Contact cnt1 = NI_TestClassData.createTestContact(1, a.Id);
        cnt1.FirstName = 'First';
        cnt1.LastName = 'Testuser';        
        insert cnt1; 
        
        Contact cnt2 = NI_TestClassData.createTestContact(1, a.Id);
        cnt2.FirstName = 'Second';
        cnt2.LastName = 'Testuser';        
        insert cnt2;         
        
        // CREATE TEST OPPORTUNITY
        Schema.DescribeSObjectResult cfrSchema1 = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema1.getRecordTypeInfosByName(); 
        Id opptyRecTypeId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();
        
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.Name = 'APEX AH_Billing_Contract_TriggerHandler_Test OPPORTUNITY';
        o.RecordTypeId = opptyRecTypeId;
        insert o;
        
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
        insert pgp;
        
        // CREATE TEST DI INDEX RECORD
        NI_DeploymentInstanceIndex__c diIdx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST');     
        insert diIdx1; 
        
        // CREATE TEST PRODUCT RECORDS
		List<Product2> lstProds = new List<Product2>();
        
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription');
        prd01.DI_Index__c = diIdx1.Id;
        prd01.Apttus_Config2__HasOptions__c = false;
        prd01.Duration_Months__c = 12;
        prd01.Partner_Name__c = pa.Id;
        lstProds.add(prd01);  
        
        Product2 prd02 = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-02', 'Support');
        prd02.DI_Index__c = diIdx1.Id;
        prd02.Apttus_Config2__HasOptions__c = false;
        prd02.License_Type__c = 'Limited'; 
        prd02.Duration_Months__c = 12;
        prd02.Partner_Name__c = pa.Id;
        lstProds.add(prd02);  
        
        Product2 prd03 = NI_TestClassData.createProduct2(3, pgp.Id, 'APEX-TEST-03', 'Hosting');
        prd03.DI_Index__c = diIdx1.Id;
        prd03.Apttus_Config2__HasOptions__c = false;
        prd03.License_Type__c = 'Full';
		prd03.Unit__c = 'User';
        prd03.Duration_Months__c = 12;
        prd03.Partner_Name__c = pa.Id;
        lstProds.add(prd03);
        
        Database.Insert(lstProds);
        
        // CREATE PRICEBOOK TEST RECORD
        Id pbkId = Test.getStandardPricebookId(); 
        
        // CREATE PRICEBOOKENTRY RECORDS
        List<PricebookEntry> lstPBEs = new List<PricebookEntry>();
        PricebookEntry pbe01 = NI_TestClassData.createTestPricebookEntry(pbkId, prd01.Id, 1000);
        lstPBEs.add(pbe01);    
        PricebookEntry pbe02 = NI_TestClassData.createTestPricebookEntry(pbkId, prd02.Id, 1000);
        lstPBEs.add(pbe02);   
        PricebookEntry pbe03 = NI_TestClassData.createTestPricebookEntry(pbkId, prd03.Id, 1000);
        lstPBEs.add(pbe03);    
        Database.Insert(lstPBEs);
        
		// CREATE OPPORTUNITY LINE ITEMS
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();        
        OpportunityLineItem oli01 = NI_TestClassData.createTestOpportunityLineItem(1, o.Id, pbe01.Id, 1);
        oli01.Order_of_Delivery__c = 1;
        lstOLIs.add(oli01);
        OpportunityLineItem oli02 = NI_TestClassData.createTestOpportunityLineItem(2, o.Id, pbe02.Id, 1);
        oli02.Order_of_Delivery__c = 2;
        lstOLIs.add(oli02); 
        OpportunityLineItem oli03 = NI_TestClassData.createTestOpportunityLineItem(3, o.Id, pbe03.Id, 1);
        oli03.Order_of_Delivery__c = 3;
        lstOLIs.add(oli03);                    
		Database.insert(lstOLIs); 

		// ASSERTION
        List<OpportunityLineItem> oliAssert = [SELECT Id
                                               FROM OpportunityLineItem
                                               WHERE OpportunityId =: o.Id
                                               AND Product2.Duration_Months__c != null
                                               AND Order_of_Delivery__c != null
                                               AND Product2.Partner_Name__c =: pa.Id];
        system.assertEquals(3, oliAssert.size());

        Test.startTest();
        
        // CREATE BILLING CONTRACT
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(1);
        bc.Account__c = a.Id;
        bc.Opportunity__c = o.Id;  
        bc.Attn_to_Contact__c = cnt1.Id;
        bc.Company__c = testCompany1.Id;
		insert bc;
        
        Test.stopTest();
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: 
    // =======================================================================================================================================
    @isTest static void billingContractTest1() 
    {

        Account a = [SELECT Id FROM Account WHERE Name = 'APEX AH_Billing_Contract_TriggerHandler_Test TEST'];
		Billing_Contract__c bc = [SELECT Id, Attn_to_Contact__c FROM Billing_Contract__c WHERE Account__c =: a.Id];
        Contact cnt2 = [SELECT Id FROM Contact WHERE FirstName = 'Second' AND LastName = 'Testuser'];    
        c2g__codaCompany__c co2 = [SELECT Id, Name, Legal_Entity_Name__c FROM c2g__codaCompany__c WHERE Name = 'TEST COMPANY 2'];
        
        Test.startTest();    
    
        bc.Company__c = co2.Id;
        bc.Attn_to_Contact__c = cnt2.Id;
        update bc;
        
        delete bc;
        
        system.assert(true);
        
        Test.stopTest();
        
    }
    
}