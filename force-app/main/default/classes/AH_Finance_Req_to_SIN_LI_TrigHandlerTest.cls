/****************************************************************************************
Name            : AH_Finance_Req_to_SIN_LI_TrigHandlerTest Class 
Author          : Stuart Emery
Created Date    : 9/13/2018
Last Mod Date   : 10/29/2018 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-030091
Description     : Test Class for the AH_Finance_Req_to_SIN_LI_Trigger_Handler Class
                : 
				:
******************************************************************************************/
@isTest
public class AH_Finance_Req_to_SIN_LI_TrigHandlerTest 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData()
    {
        Test.startTest();
        
        // CREATE TEST USER
        User u = NI_TestClassData.createTestUser(1, 'System Administrator'); 
        u.Alias = 'SA01TST'; 
        insert u;    
        
        List<User> lstUserAsserts = new List<User>([SELECT Id FROM User WHERE Alias = 'SA01TST']);
        system.assertEquals(1, lstUserAsserts.Size());
        
        // CREATE TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST ACCOUNT 1';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Property Account').getRecordTypeId();
        a.c2g__CODAAccountTradingCurrency__c = 'USD'; 
        a.c2g__CODATaxCalculationMethod__c = 'Gross';
        insert a;
        
        List<Account> lstAccountAsserts = new List<Account>([SELECT Id FROM Account WHERE Name = 'APEX TEST ACCOUNT 1']);
        system.assertEquals(1, lstAccountAsserts.Size());
        
        // CREATE TEST PRODUCT
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
        insert pgp;
        
        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription');        
        insert prd;
        
        // CREATE FFA SETUP RECORDS ===========================================================================
        
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
        
        //CREATE A TEST FINANCE REQUEST RECORD
        AH_Finance_Request__c fr = NI_TestClassData.createFinanceRequest();
        insert fr;
        
        Test.stopTest();
        
    } 
    
    // TEST INSERTING A RECORD
    @isTest static void testRecordInsert()
    {
        
        Test.startTest();
        system.runAs([SELECT Id FROM User WHERE Id =: UserInfo.getUserId()][0]) 
        {
            
            AH_Finance_Request__c fr = [SELECT Id, CurrencyIsoCode FROM AH_Finance_Request__c LIMIT 1];
            
            c2g__codaInvoiceLineItem__c sinli = [SELECT Id FROM c2g__codaInvoiceLineItem__c LIMIT 1];         
            
            //INSERT AH_Finance_Request_to_SIN_Line_Item__c TO COVER AFTER INSERT TRIGGER & HANDLER CODE
            AH_Finance_Request_to_SIN_Line_Item__c fToSin = NI_TestClassData.createFinanceRequestToSINLineItem(sinli.Id,fr.Id);
            insert fToSin;
            
            //TEST THE BEFORE INSERT LOGIC FOR THE SetCurrency METHOD 
            //VERIFY THE CURRENCY ISO CODE ON THE AH_Finance_Request_to_SIN_Line_Item__c RECORD
            //MATCHES THE CURRENCY ISO CODE ON THE FINANCE REQUEST OBJECT 
            AH_Finance_Request_to_SIN_Line_Item__c fToSin2 = [SELECT Id, CurrencyIsoCode FROM AH_Finance_Request_to_SIN_Line_Item__c LIMIT 1];
            system.assertEquals(fToSin2.CurrencyIsoCode, fr.CurrencyIsoCode);
            
            //ASSERT THAT THE NET CREDIT AMOUNT IS CORRECT.  THE TAX AMOUNT ON THE FINANCE REQUEST RECORD IS
            //INCLUDED IN THE NET CREDIT AMOUNT
            AH_Finance_Request__c fr1 = [SELECT Id, Net_Credit_Amount__c FROM AH_Finance_Request__c LIMIT 1];
            system.assertEquals(fr1.Net_Credit_Amount__c, 110);
        }         
        Test.stopTest();
    }
    
    // TEST UPDATING A RECORD
    @isTest static void testRecordUpdate()
    {
        
        Test.startTest();
        system.runAs([SELECT Id FROM User WHERE Id =: UserInfo.getUserId()][0]) 
        {
            
            AH_Finance_Request__c fr = [SELECT Id FROM AH_Finance_Request__c LIMIT 1];
            
            c2g__codaInvoiceLineItem__c sinli = [SELECT Id FROM c2g__codaInvoiceLineItem__c LIMIT 1];         
            
            // INSERT AH_Finance_Request_to_SIN_Line_Item__c TO COVER AFTER INSERT TRIGGER & HANDLER CODE
            AH_Finance_Request_to_SIN_Line_Item__c fToSin = NI_TestClassData.createFinanceRequestToSINLineItem(sinli.Id,fr.Id);
            insert fToSin;
            
            //ASSERT THAT THE NET CREDIT AMOUNT IS CORRECT.  THE TAX AMOUNT ON THE FINANCE REQUEST RECORD IS
            //INCLUDED IN THE NET CREDIT AMOUNT
            AH_Finance_Request__c fr1 = [SELECT Id, Net_Credit_Amount__c FROM AH_Finance_Request__c LIMIT 1];
            system.assertEquals(fr1.Net_Credit_Amount__c, 110);
            
            //GET THE INSERTED FINANCE REQUEST TO SIN RECORD
            AH_Finance_Request_to_SIN_Line_Item__c fToSin2 = [SELECT Id, Requested_Credit_Amount__c FROM AH_Finance_Request_to_SIN_Line_Item__c LIMIT 1];
            
            //UPDATE THE REQUESTED CREDIT AMOUNT
            fToSin2.Requested_Credit_Amount__c = 150;
            update fToSin2;
            
            //ASSERT THAT THE NET CREDIT AMOUNT ON THE FINANCE REQUEST HAS BEEN UPDATED TO REFLECT THE NEW CREDIT AMOUNT.
            //THE TAX AMOUNT ON THE FINANCE REQUEST RECORD IS INCLUDED IN THE NET CREDIT AMOUNT
            AH_Finance_Request__c fr2 = [SELECT Id, Net_Credit_Amount__c FROM AH_Finance_Request__c LIMIT 1];
            system.assertEquals(fr2.Net_Credit_Amount__c, 160);    
        }         
        Test.stopTest();
    }
    
    
    // TEST DELETING A RECORD
    @isTest static void testRecordDelete()
    {
        
        Test.startTest();
        system.runAs([SELECT Id FROM User WHERE Id =: UserInfo.getUserId()][0]) 
        {
            
            AH_Finance_Request__c fr = [SELECT Id FROM AH_Finance_Request__c LIMIT 1];
            
            c2g__codaInvoiceLineItem__c sinli = [SELECT Id FROM c2g__codaInvoiceLineItem__c LIMIT 1];         
            
            // INSERT AH_Finance_Request_to_SIN_Line_Item__c TO COVER AFTER INSERT TRIGGER & HANDLER CODE
            AH_Finance_Request_to_SIN_Line_Item__c fToSin = NI_TestClassData.createFinanceRequestToSINLineItem(sinli.Id,fr.Id);
            insert fToSin;
            
            AH_Finance_Request__c fr1 = [SELECT Id, Net_Credit_Amount__c FROM AH_Finance_Request__c LIMIT 1];
            system.assertEquals(fr1.Net_Credit_Amount__c, 110);
            
            //GET THE INSERTED FINANCE REQUEST TO SIN RECORD
            AH_Finance_Request_to_SIN_Line_Item__c fToSin2 = [SELECT Id, Requested_Credit_Amount__c FROM AH_Finance_Request_to_SIN_Line_Item__c LIMIT 1];
            
            //DELETE THE FINANCE REQUEST TO SIN RECORD
            delete fToSin2;
            
            //ASSERT THAT THE NET CREDIT AMOUNT ON THE FINANCE REQUEST HAS BEEN UPDATED TO REFLECT THE NEW CREDIT AMOUNT
            AH_Finance_Request__c fr2 = [SELECT Id, Net_Credit_Amount__c FROM AH_Finance_Request__c LIMIT 1];
            system.assertEquals(fr2.Net_Credit_Amount__c, 10);    
        }         
        Test.stopTest();
    }
    
}