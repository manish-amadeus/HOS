/****************************************************************************************** 
Name            : AH_Statement_Schedule_Test	
Author          : Bhagwat Garkal
Created Date    : 12/07/2020
Modified Date	: 12/07/2020
Last Mod By     : Bhagwat Garkal         	
NICC Reference  : 
Description     : Test class for AH_Statement_Schedule class
				: 
				:
**************************************************************************************/

@isTest
public class AH_Statement_Schedule_Test 
{

    public static c2g__codaCompany__c testCompany1;
    public static c2g__codaDimension2__c testDimension2;
    public static c2g__codaDimension3__c testDimension3;
    public static c2g__codaGeneralLedgerAccount__c testGLA;
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup 
    static void createTestData()
    {
        Test.StartTest();
        
        // CREATE TEST COMPANY & ACCOUNTING CURRENCY
        testCompany1 = ffaTestUtilities.createFFACompany('TEST COMPANY 111', true, 'USD');
        c2g__codaAccountingCurrency__c testcurr = [SELECT id, name from c2g__codaAccountingCurrency__c where c2g__ownerCompany__c = :testCompany1.id limit 1];
        system.debug('\n\n ***** ffaUtilities_TEST - setupTestData - testCompany1' + testCompany1);
        system.assertNotEquals(NULL, testCompany1.id, 'Company is not created.');
        system.assertNotEquals(NULL, testcurr.id, 'Accounting Currency is not created.');

        // CREATE TEST DIMENSIONS 1 & 2
        testGLA = ffaTestUtilities.create_IS_GLA();
        testDimension2 = ffaTestUtilities.createTestDimension2();
        testDimension3 = ffaTestUtilities.createTestDimension3();
        system.assertNotEquals(NULL, testDimension2.id, 'Dimension 2 has not created.');
        system.assertNotEquals(NULL, testDimension3.id, 'Dimension 3 has not created.');

       	c2g__codaGeneralLedgerAccount__c recAcc = new c2g__codaGeneralLedgerAccount__c();
        recAcc.Name = 'Test Receivable Account 1';
        recAcc.c2g__ReportingCode__c = '200';
        recAcc.c2g__Type__c = 'Balance Sheet';
        insert recAcc;
        system.assertNotEquals(NULL, recAcc.id, 'Ledger Account has not created.');
        
        // CREATE TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.c2g__CODAAccountTradingCurrency__c = testcurr.name;
        a.c2g__CODATaxCalculationMethod__c  = 'Net of Discount';
        a.c2g__CODAAccountsReceivableControl__c = recAcc.id;
        insert a;         
        List<Account> lstAccountAsserts = new List<Account>([SELECT Id FROM Account]);
        system.assertEquals(1, lstAccountAsserts.Size(), 'Failed to create test Account record in manageBillingContractRenewalControl_Test');         
        
        // GET OPPORTUNITY RECORDTYPE ID
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rt = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();
        
        // CREATE A TEST OPPORTUNITY RECORD
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.RecordTypeId = rt;
        o.Order_Status__c = 'DEFINITE';
        o.Purchase_Order__c = '111';
        insert o;   
        List<Opportunity> lstOpportunityAsserts = new List<Opportunity>([SELECT Id FROM Opportunity]);
        system.assertEquals(1, lstOpportunityAsserts.size(), 'Failed to create test Opportunity record in manageBillingContractRenewalControl_Test');   
        
        // CREATE A TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;         
        List<Product_Group__c> lstProductGroupAsserts = new List<Product_Group__c>([SELECT Id FROM Product_Group__c]);
        system.assertEquals(1, lstProductGroupAsserts.size(), 'Failed to create test Product_Group__c record in manageBillingContractRenewalControl_Test');   
        
        // CREATE A TEST DI INDEX RECORD
        NI_DeploymentInstanceIndex__c idx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX'); 
        insert idx1; 
        List<NI_DeploymentInstanceIndex__c> lstDIIndexAsserts = new List<NI_DeploymentInstanceIndex__c>([SELECT Id FROM NI_DeploymentInstanceIndex__c]);
        system.assertEquals(1, lstDIIndexAsserts.size(), 'Failed to create test NI_DeploymentInstanceIndex__c record in manageBillingContractRenewalControl_Test');   
        
        // CREATE A TEST PRODUCT RECORD
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        prd01.DI_Index__c = idx1.Id;
        prd01.Duration_Months__c = 2;
        prd01.c2g__CODASalesRevenueAccount__c = testGLA.id;
        prd01.Dimension_2__c = testDimension2.id;
        prd01.Dimension_3__c = testDimension3.id;
        insert prd01;
        List<Product2> lstProduct2Asserts = new List<Product2>([SELECT Id FROM Product2]);
        system.assertEquals(1, lstProduct2Asserts.size(), 'Failed to create test Product2 record in manageBillingContractRenewalControl_Test');
        
        // CREATE TEST REMITTANCE INFO RECORD
        Remittance_Info__c r = ffaTestUtilities.create_Remittance_Info('Test Remittance');
		system.assertNotEquals(NULL, r.id, 'Failed to create Remittacne Info record.');
               
        // CREATE TEST CONTACT
        Contact con = NI_TestClassData.createTestContact(1, a.id);
        insert con;
        system.assertNotEquals(NULL, con.id, 'Failed to create Contact record.');
        
        // CREATE A TEST BILLING CONTRACT RECORD
        Billing_Contract__c blgCnrct = NI_TestClassData.createBillingContract(1);
        blgCnrct.Account__c = a.Id;
        blgCnrct.Renewal_Increase_Cap_Percentage__c = 10;
        blgCnrct.Opportunity__c = o.id;
        blgCnrct.Remittance_Info__c = r.id;
        blgCnrct.Accounting_Currency__c = testcurr.id;
        blgCnrct.Company__c = testCompany1.id;
        blgCnrct.Billing_Hold__c = FALSE;
        blgCnrct.Invoice_Date_Override__c = Date.today()-30;
        blgCnrct.Bill_To_Contact__c = con.id;
        
        insert blgCnrct;

        List<Billing_Contract__c> lstBillingContractAsserts = new List<Billing_Contract__c>(
            [SELECT Id, Invoice_Due_Date__c, Invoice_Date__c,Next_Invoice_Date__c,Accounting_Currency__c, Remittance_Info__c 
             FROM Billing_Contract__c]);
        system.assertEquals(1, lstBillingContractAsserts.size(), 'Failed to create test Billing_Contract__c record in manageBillingContractRenewalControl_Test');   
        system.debug('lstBillingContractAsserts : '+lstBillingContractAsserts);
        
        // CREATE TEST PAYMENT TERM
        Payment_Terms__c pt = NI_TestClassData.createInvoicePaymentTerms();
        pt.Name = '4 Installments';
        pt.Invoice_Split_Method__c = 'Equal';
        insert pt;
        List<Payment_Terms__c> lstPaymentTerms = new List<Payment_Terms__c>([SELECT Id FROM Payment_Terms__c]);
        system.assertEquals(1, lstPaymentTerms.size(), 'Failed to create test Payment_Terms__c record in manageBillingContractRenewalControl_Test');   
        
        // CREATE A TEST ACTIVITY LINE ITEM RECORD
        List<Activity_Line_Item__c> aliList = new List<Activity_Line_Item__c>();
        
        Activity_Line_Item__c actLI = NI_TestClassData.createActivityLineItem(blgCnrct.Id);
        actLI.Cancel_Line_Item__c = false; 
        actLI.Product__c = prd01.Id; 
        actLI.Opportunity__c = o.id;
        actLI.Payment_Terms__c = pt.Id;
        actLI.Contract_Start_Date__c = Date.Today()+1;  
        actLI.Contract_End_Date__c = Date.Today() + 200; 
        actLI.Units__c = 1; 
        actLI.Status__c = 'Active';
        actLI.Origin__c = 'Renewal';
        actLI.Contract_Amount__c = 1000;
        actLI.Renewal_Base_Price__c = 500;
        actLI.Auto_Renewal__c = false;
        actLI.Renewal_Processed__c = false;
        actLI.Revenue_Category__c = 'Services';
        aliList.add(actLI);
        
        Database.insert(aliList);
        
        List<Activity_Line_Item__c> lstALIAsserts = new List<Activity_Line_Item__c>(
            [SELECT Id, Name, Product__r.Name, Opportunity__r.Name, Account_Name__c, 
             Status__c, Account__r.Name, Account__c 
             FROM Activity_Line_Item__c]);
        
		system.debug('lstALIAsserts : '+lstALIAsserts);
        system.assertEquals(1, lstALIAsserts.size(), 'Failed to create test Activity_Line_Item__c record.');   
        
        List<Billing_Contract_Line_Item__c> lstBCLIs = new List<Billing_Contract_Line_Item__c>();
        
        Billing_Contract_Line_Item__c blci1 = NI_TestClassData.createBillingContract(blgCnrct.Id, actLI.Id);
        blci1.Split_Order__c = 1;
        blci1.Status__c = 'Active';
        blci1.Activation_Required__c = false;
        blci1.Pro_Rated__c = false;
        blci1.Revenue_Category__c = 'Support';
        blci1.Ready_to_Invoice__c = true;
        blci1.Total_Amount__c = 500;
        blci1.Exclude_Automated_Invoicing__c = false; 
        blci1.Invoiced__c = false;
        blci1.Opportunity__c = o.id;
        blci1.Product__c = prd01.id;
        blci1.Invoice_Date__c = Date.today() - 15;   
        lstBCLIs.add(blci1);
        
        Database.insert(lstBCLIs);
        
        List<Billing_Contract_Line_Item__c> bcliList = new List<Billing_Contract_Line_Item__c>();
        bcliList = [ select ID, Name, Status__c, Activation_Required__c, Type__c, Product__c, Activity_Line_Item__r.Origin__c, 
                    Opportunity__c, Billing_Contract__c, Payment_Terms__c, Activity_Line_Item__c, SKU__c, Dimension_2__c, Dimension_3__c, 
                    Ready_to_Invoice__c, Total_Amount__c, Invoiced__c 
                    from Billing_Contract_Line_Item__c ];
        system.debug('bcliList : '+bcliList);
        system.assertEquals(1, bcliList.size(), 'Failed to create test Billing_Contract_Line_Item__c record.');   
        
        system.debug('Test Class Queries : '+ Limits.getQueries());
        
        Test.StopTest();
    }

     // ======================================================================================================================================= 
    //  TEST METHODS 1 FOR SCHEDULABLE CLASS 
    // ==========================================================================================================================
    @isTest static void testSchedulableClass(){
        
        Test.startTest();
        
        AH_Statement_Schedule sch2 = new AH_Statement_Schedule(); //Schedule apex class name
        String sch = '0 0 23 * * ?'; //schedule interval time
        system.schedule('TEST Schedule Invoices', sch, sch2); //system method to schedule apex class
        
        try {
            CronJobDetail cronJob = new CronJobDetail();
            cronJob = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'TEST Schedule Invoices'];
            system.debug('cronJob : ' +cronJob.Id);
            system.assertNotEquals(NULL, cronJob.Id, 'AH_SINManager_Sched_Renewals Class has not scheduled.');
        }
        catch(Exception e)
        {
            system.debug('Exception while scheduling job in test class : '+e);
        }
        Test.StopTest();
    }
   // ======================================================================================================================================= 
    // = TEST METHODS 2 FOR BATCH CLASS 
    // ==========================================================================================================================
   @isTest static void testBatchClass()
    {
        Test.startTest();
        String  accQuery = 'SELECT Account.Id,Statement_Eligible__c ';       
                accQuery += 'FROM Account ';
                accQuery += 'WHERE Account.Id IN (SELECT c2g__Account__c ';
                accQuery += 'FROM c2g__codaTransactionLineItem__c ';
                accQuery += 'WHERE c2g__Account__c != null ';
                accQuery += 'AND c2g__LineType__c = \'Account\' ';
                accQuery += 'AND c2g__MatchingStatus__c != \'Matched\' ';
                //accQuery += 'AND c2g__OwnerCompany__c = \'a6832000000M2CX\')  '; 
                accQuery += 'AND c2g__OwnerCompany__c = '+testCompany1+') '; 
                accQuery += 'AND Account.Exclude_from_Automated_Statement_Run__c = False  ' ; 
                accQuery += 'AND Account.Statement_Sent__c = False ' ; 
                accQuery += 'AND Account.c2g__CODAFinanceContact__c !=null ';                                         
                accQuery += 'ORDER BY Account.Id ';
        
        system.debug('accQuery : '+accQuery);
        
        Set<String> bcQueryIds = new Set<String>();
        integer iMode = 1;
        
        List<Account> acclist= Database.query(accQuery);
        System.debug('acclist==>'+acclist);
        AH_Statement_Batch batchable = new AH_Statement_Batch();
        Database.executeBatch(batchable, 1);
        batchable.execute(null,acclist);

        Test.StopTest();
    }
}