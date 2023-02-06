/****************************************************************************************** 
Name            : AH_SAPCashEntryJournal_Schedule_Test	
Author          : Bhagwat Garkal
Created Date    : 10/11/2021
Modified Date	: 18/11/2021
Last Mod By     : Bhagwat Garkal         	
NICC Reference  : 
Description     : Test class for AH_SAPCashEntryJournal_Schedule class
				: 
				:
**************************************************************************************/
@isTest
public class AH_SAPCashEntryJournal_Schedule_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup static void createTestData()
    {
        
        c2g__codaGeneralLedgerAccount__c testGLA = NI_TestClassData.createGeneralLedgerAccount('Income Statement Account');
        insert testGLA;
        
        // CREATE TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST ACCOUNT 1';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Property Account').getRecordTypeId();
        a.c2g__CODAAccountTradingCurrency__c = 'USD'; 
        a.c2g__CODATaxCalculationMethod__c = 'Gross';
        a.AccountNumber = '17050';
        a.c2g__CODAAccountsReceivableControl__c = testGLA.Id;
        a.c2g__CODAAccountsPayableControl__c = testGLA.Id;
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
        Group q = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name = 'APEX ACME CO'];
        
        system.assertEquals('APEX ACME CO', q.Name);
        
        c2g__codaYear__c yr = NI_TestClassData.createFFAYear(String.valueOf(Date.today().year()), co.Id, q.Id);
        insert yr;
       
        c2g.CODAYearWebService.calculatePeriods(yr.Id);
        
        c2g__codaAccountingCurrency__c ac = NI_TestClassData.createFFAAccountingCurrency('USD', co.Id, q.Id);
        insert ac;
       
        c2g__codaExchangeRate__c er = NI_TestClassData.createFFAcodaExchangeRate(co.Id, ac.id);
        
        insert er;
       
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
        
		// CREATE BANK ACCOUNT RECORD
        c2g__codaBankAccount__c testBankAccount = new c2g__codaBankAccount__c (
            Name = 'Test bank account',
            c2g__reportingcode__c = '10029304930',
            c2g__bankname__c = 'Testing Bank',
            c2g__accountname__c = 'TESTing account',
            c2g__accountnumber__c = '1920384903',
            c2g__GeneralLedgerAccount__c = testGLA.Id,
            c2g__ownerCompany__c = co.Id,
            c2g__BankAccountCurrency__c = ac.Id
        );
        
        insert testBankAccount;
    }
    
    // ======================================================================================================================================= 
    //  TEST METHODS FOR AH_SAPCashEntryJournal_Schedule SCHEDULABLE CLASS 
    // ==========================================================================================================================
    @isTest static void testSchedulableClass()
    {
        
        Test.startTest();
        
        AH_SAPCashEntryJournal_Schedule sch2 = new AH_SAPCashEntryJournal_Schedule(); 	// Schedule apex class name
        String sch = '0 0 23 * * ?'; 													// schedule interval time
        system.schedule('TEST Batch', sch, sch2); 										// system method to schedule apex class
      	
        // CHECK AH_SAPCashEntryJournal_Schedule CLASS SCHEDULED OR NOT
        List<CronJobDetail> lstcronJob = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'TEST Batch'];
        system.assertEquals(1, lstcronJob.Size(), 'AH_SAPCashEntryJournal_Schedule Class has not scheduled.');
        
        Test.StopTest();
        
    }
    
    // ===========================================================================================================================
    // = TEST METHOD FOR AH_SAPCashEntryJournal_Batch BATCH CLASS 
    // ==========================================================================================================================
    @isTest static void testBatchClass()
    {
        
        Test.startTest();
        
        Account acc = [SELECT Id, Name, AccountNumber FROM Account WHERE Name = 'APEX TEST ACCOUNT 1'];
        c2g__codaBankAccount__c bankAccount = [SELECT Id, Name, c2g__BankAccountCurrency__c, c2g__GeneralLedgerAccount__c, c2g__accountnumber__c 
                                               FROM c2g__codaBankAccount__c 
                                               WHERE Name = 'Test bank account'];
        
        c2g__codaInvoice__c salesInv = [SELECT Id, Name, c2g__Dimension1__c, c2g__Dimension2__c, c2g__Dimension3__c, c2g__Dimension4__c FROM c2g__codaInvoice__c LIMIT 1];
        
        c2g__codaCompany__c company = [SELECT Id, Name FROM c2g__codaCompany__c LIMIT 1];
       
        // Create Sap Transaction record
       
        AH_SAP_Transaction__c sapTrans = new AH_SAP_Transaction__c();
        
        sapTrans.Bank_Account_Number__c = bankAccount.c2g__accountnumber__c;
        sapTrans.Bank_Account_Value__c = 847.31;
        sapTrans.Bank_Reference_Number__c = 'TESTSITHOS1135/A';
        sapTrans.Company_Code__c = '1135';
        sapTrans.Customer_Number__c = acc.AccountNumber;
        sapTrans.Document_Amount__c = 100;
        sapTrans.Document_Currency__c ='USD';
        sapTrans.Document_Currency_Conversion__c = 50;
        sapTrans.Document_Date__c = System.Today();
        sapTrans.FFA_Processing_Date_Time__c = System.now();
        sapTrans.Import_Date_Time__c = System.now();
        sapTrans.Import_File_Name__c ='Test File';
        sapTrans.Import_Status__c ='Imported Successfully';
        sapTrans.Invoice_Number__c = salesInv.Name;
        sapTrans.Line_Description__c = 'Test';
        sapTrans.Payment_Method__c ='CASH';
        sapTrans.Posting_Date__c = System.Today();
        sapTrans.Transaction_Type__c = 'W';
        
        insert sapTrans;
        
        // Create Sap Transaction record
        
        AH_SAP_Transaction__c sapTrans2 = new AH_SAP_Transaction__c();
        
        sapTrans2.Bank_Account_Number__c = bankAccount.c2g__accountnumber__c;
        sapTrans2.Bank_Account_Value__c = 100.00;
        sapTrans2.Bank_Reference_Number__c = 'TESTSITHOS1135/A';
        sapTrans2.Company_Code__c = '1135';
        sapTrans2.Customer_Number__c = acc.AccountNumber;
        sapTrans2.Document_Amount__c = 100;
        sapTrans2.Document_Currency__c ='USD';
        sapTrans2.Document_Currency_Conversion__c = 50;
        sapTrans2.Document_Date__c = System.Today();
        sapTrans2.FFA_Processing_Date_Time__c = System.now();
        sapTrans2.Import_Date_Time__c = System.now();
        sapTrans2.Import_File_Name__c ='Test File';
        sapTrans2.Import_Status__c ='Imported Successfully';
        sapTrans.Invoice_Number__c = salesInv.Name;
        sapTrans2.Line_Description__c = 'Test';
        sapTrans2.Payment_Method__c ='CASH';
        sapTrans2.Posting_Date__c = System.Today();
        sapTrans2.Transaction_Type__c = 'P';
        
        insert sapTrans2; 

        String sapTransQuery = 'SELECT Name, Bank_Account_Number__c, FFA_Company__c, Bank_Account_Value__c, Import_Date_Time__c, FFA_Cash_Entry__c, '; 
        sapTransQuery += 'Transaction_Type__c, FFA_Transaction_Type__c, FFA_Journal__c, Invoice_Number__c, Document_Amount__c, Document_Currency__c, Line_Description__c, ';
        sapTransQuery += 'Posting_Date__c, Customer_Number__c, Bank_Reference_Number__c, Document_Currency_Conversion__c, FFA_Processing_Status__c ';
        sapTransQuery += 'FROM AH_SAP_Transaction__c ';
        sapTransQuery += 'WHERE CreatedDate = LAST_N_DAYS : 1 ';
        sapTransQuery += 'AND FFA_Processing_Status__c != \''+ 'Processed Successfully' + '\' ';
        
        List<AH_SAP_Transaction__c> saplist = Database.query(sapTransQuery);
        
        // CHECK SAP TRANSACTION SHOULD NOT BE 0
        system.assertNotEquals(0, saplist.size(),'SAP TRANSACTION Record SHOULD NOT BE 0');
        
        // CALLING BATCH CLASS
        AH_SAPCashEntryJournal_Batch batchable = new AH_SAPCashEntryJournal_Batch(company.Name);
        Id batchprocessid = Database.executeBatch(batchable, 5);
        batchable.execute(null, saplist);
        
        List<AsyncApexJob> aajLst = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchprocessid ];
        
        // CHECK BATCH EXECUTED OR NOT
        system.assertEquals(1, aajLst.size(), 'Batch not Executed !');
        
        // ASSERT THAT CASH ENTRY RECORDS WERE CREATED VIA BATCH CLASS
        List<c2g__codaCashEntry__c> lstCE_Assert = new List<c2g__codaCashEntry__c>([SELECT Id FROM c2g__codaCashEntry__c WHERE AH_SAP_Transaction__c =: sapTrans2.Id]);
            
        system.assertEquals(1, lstCE_Assert.size(), 'Cash entry record creation failed!');
        
        Test.stopTest(); 
      
    }
    
}