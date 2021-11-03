/**************************************************************************************
// Name          : AH_AddSalesInvoiceLineItems_Ctlr_Test
// Date          : 9/27/2021
// Description   : Test Class for the "AH_AddSalesInvoiceLineItems_Ctlr" button
// Author        : Bhagwat Garkal
***************************************************************************************/
@istest
public class AH_AddSalesInvoiceLineItems_Ctlr_Test {
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup 
    static void createTestData()
    {
        // CREATE TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST ACCOUNT 1';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Property Account').getRecordTypeId();
        a.c2g__CODAAccountTradingCurrency__c = 'USD'; 
        a.c2g__CODATaxCalculationMethod__c = 'Gross';
        insert a;
        
        // GET RUNNING USER RECORD
        User ru = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        
        // CREATE TEST COMPANY
        c2g__codaCompany__c co = NI_TestClassData.createFFACompany('APEX ACME CO', ru, true);
        insert co;
        
        // ADD USER RUNNING TEST TO THE TEST COMPANY
        c2g__codaUserCompany__c uCo = NI_TestClassData.createFFAUserCompany(co.Id, ru.Id);
        insert uCo;  
        
        system.assertEquals('APEX ACME CO', c2g.CODAAPICompany_2_0.GetCurrentCompanies(null)[0]);
        
        // GET QUEUE CREATED BY NI_TestClassData.createFFACompany FUNCTION
        Group q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'APEX ACME CO'];
        
        c2g__codaYear__c yr = NI_TestClassData.createFFAYear(String.valueOf(Date.today().year()), co.Id, q.Id);
        insert yr;
        c2g.CODAYearWebService.calculatePeriods(yr.Id);
        
        c2g__codaAccountingCurrency__c ac = NI_TestClassData.createFFAAccountingCurrency('USD', co.Id, q.Id);
        insert ac; 
        // CREATE TEST PRODUCT
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
        insert pgp;
        
        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription');        
        insert prd;
        // INSERT TEST DIMENSIONS
        c2g__codaDimension2__c dim2 = NI_TestClassData.createTestDimension2();
        dim2.Name = 'TEST DIM 2';
        insert dim2;
        
        c2g__codaDimension3__c dim3 = NI_TestClassData.createTestDimension3();
        dim3.Name = 'TEST DIM 3';
        insert dim3;
        
        // CREATE TEST SALES INVOICE
        Date dt = system.date.today();
        c2g__codaInvoice__c sin = NI_TestClassData.createSalesInvoice(a.Id, dt, 100, null, dim2.Id, dim3.Id, null);
        insert sin;
        
        // CREATE TEST SALES INVOICE LINE ITEM
        c2g__codaInvoiceLineItem__c sinli = NI_TestClassData.createSalesInvoiceLineItem(prd.Id, 100, sin.Id, null, dim2.Id, dim3.Id, null);
        insert sinli; 
    }
    
    // TEST INSERTING A RECORD
    @isTest static void testRecordInsert()
    {
        Test.startTest();
            c2g__codaInvoice__c sin = [Select Id from c2g__codaInvoice__c limit 1];
            c2g__codaInvoiceLineItem__c sinli = [Select Id from c2g__codaInvoiceLineItem__c limit 1];
            AH_Finance_Request__c fr = NI_TestClassData.createFinanceRequest();
            fr.Sales_Invoice__c = sin.Id;
            insert fr;
            ApexPages.StandardController sc = new ApexPages.StandardController(fr);
            AH_AddSalesInvoiceLineItems_Ctlr testAddSIL = new AH_AddSalesInvoiceLineItems_Ctlr(sc);
        
            //Test retrieve records on Load data on "Add Sales Invoice" button.
            system.assertEquals(1, testAddSIL.wrapperList.size(), 'Failed to retrieve records on Load "Add Sales Invoice" button..');
        
            testAddSIL.backToBC();
            List<AH_Finance_Request_to_SIN_Line_Item__c> creditList = new List<AH_Finance_Request_to_SIN_Line_Item__c>();
            AH_Finance_Request_to_SIN_Line_Item__c frsin = new AH_Finance_Request_to_SIN_Line_Item__c();
            frsin.Finance_Request__c = fr.Id;
            frsin.Sales_Invoice_Line_Item__c = sinli.Id;
            frsin.Requested_Credit_Amount__c = -10;
            creditList.add(frsin);
            AH_Finance_Request_to_SIN_Line_Item__c frsin1 = new AH_Finance_Request_to_SIN_Line_Item__c();
            frsin1.Finance_Request__c = fr.Id;
            frsin1.Sales_Invoice_Line_Item__c = sinli.Id;
            frsin1.Requested_Credit_Amount__c = -100;
            creditList.add(frsin1);
            insert creditList;
            testAddSIL.saveCredit();
            List<AH_Finance_Request_to_SIN_Line_Item__c> frsinlineitem = [select Id,Finance_Request__c,Sales_Invoice_Line_Item__c,Requested_Credit_Amount__c from AH_Finance_Request_to_SIN_Line_Item__c]; 
            
            //Test that Records are Inserted
            system.assertequals(frsinlineitem.size(),2,'Failed to insert records.');
            
        Test.stopTest();
    }
}