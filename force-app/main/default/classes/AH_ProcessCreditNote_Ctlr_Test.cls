/***********************************************************************************************
Name            : AH_ProcessCreditNote_Controller_Test
Author          : Bhagwat Garkal
Created Date    : 9/28/2021
Last Mod Date   : 03/02/2022
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : Test Class for the "AH_ProcessCreditNote_Ctlr".  
                :
                :
************************************************************************************************/

@istest
public class AH_ProcessCreditNote_Ctlr_Test {
    
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
        	
        	// CREATE TES Invoice LineItem
            c2g__codaInvoiceLineItem__c sinli = NI_TestClassData.createSalesInvoiceLineItem(prd.Id, 100, sin.Id, null, dim2.Id, dim3.Id, null);
            insert sinli;
    }
    
    // TEST INSERTING A RECORD
    @isTest static void testRecordInsert()
    {
        
        Test.startTest();
        
            // CREATE TEST SALES INVOICE LINE ITEM
            Product2 prd = [Select id, Name,Productcode from Product2 where Productcode ='APEX-TEST-01' limit 1];
        
            c2g__codaInvoice__c sin = [Select Id from c2g__codaInvoice__c limit 1];
        
            c2g__codaInvoiceLineItem__c sinli = [Select Id,Name,c2g__NetValue__c,Billing_Contract_Line_Item__c,Billing_Contract_Line_Item__r.Revenue_Category__c,
                                                 Billing_Contract_Line_Item__r.Credit_Processed__c,c2g__Invoice__c,
                                                 c2g__Product__c,c2g__Product__r.Name,c2g__Quantity__c,c2g__UnitPrice__c,Activity_Line_Item__c,
                                                 c2g__LineNumber__c from c2g__codaInvoiceLineItem__c limit 1];
        	
        	// CREATE TEST Billing Contract Record
            Billing_Contract__c bc = NI_TestClassData.createBillingContract(1);
            insert bc;
        	
        	// CREATE TEST Finance Request Record
            AH_Finance_Request__c fr = NI_TestClassData.createFinanceRequest();
            fr.Sales_Invoice__c = sin.Id;
            fr.Billing_Contract__c = bc.Id; 
            insert fr;
          
        	// CREATE TEST  Activity Line Item Record
            Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(bc.Id);
            insert ali;
        	
        	// CREATE TEST SIN Record
        	AH_Finance_Request_to_SIN_Line_Item__c frsin1 = new AH_Finance_Request_to_SIN_Line_Item__c();
            frsin1.Finance_Request__c = fr.Id;
            frsin1.Sales_Invoice_Line_Item__c = sinli.Id;
            frsin1.Requested_Credit_Amount__c = 100;
            insert frsin1;
        
            ApexPages.StandardController sc = new ApexPages.StandardController(fr);
            AH_ProcessCreditNote_Ctlr testAddSIL = new AH_ProcessCreditNote_Ctlr(sc);
        	
            List<Billing_Contract_Line_Item__c> createBLIList = new List<Billing_Contract_Line_Item__c>();
            Billing_Contract_Line_Item__c newBLI = new Billing_Contract_Line_Item__c();
            newBLI.Quantity__c =1;
            newBLI.Unit_Price__c = -100;
            newBLI.Billing_Contract__c = bc.Id;
            newBLI.Activity_Line_Item__c = ali.Id;
            newBLI.Sales_Invoice_Line_Item__c = sinli.Id;
            newBLI.Total_Amount__c = 100;
            newBLI.Product__c = prd.id;
            newBLI.Invoiced__c = true;
            newBLI.Revenue_Category__c = 'Services';
            newBLI.Ready_to_Invoice__c = true;
            insert newBLI;
       
        	sinli.Billing_Contract_Line_Item__c = newBLI.Id;
        	sinli.Activity_Line_Item__c = ali.Id;
        	sinli.c2g__Quantity__c = 1;
        	Update sinli;
        
        	testAddSIL.fetchData();
        
            //Test retrieve records on Load data.
            system.assertEquals(1, testAddSIL.wrapperList.size(), 'Failed to retrieve records on Load');
        	
        	testAddSIL.createBCLI();
        
            //Test The Records are Inserted or Not
            List<Billing_Contract_Line_Item__c> testBLIList = [Select Id,Sales_Invoice_Line_Item__c,Billing_Contract__c,Activity_Line_Item__c from Billing_Contract_Line_Item__c where Billing_Contract__c =: bc.Id];
            system.assertequals(testBLIList.size(),2,'Failed to insert records.');
        
        	// Check Exception
        	try{
                ApexPages.Message[] pageMessages = ApexPages.getMessages();
                System.debug('pageMessages==>'+pageMessages);
                
                // Check Page Error Messages
                System.assertNotequals(0, pageMessages.size());
            }catch(Exception e)
            {
                system.debug('Error : '+e);
            }
        
        	// Called back button method
        	testAddSIL.backToBC();
        
        Test.stopTest();
    }
}