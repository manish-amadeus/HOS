/****************************************************************************************
Name            : NI_Invoice_Detail_TriggerHandler Test Class
Author          : Stuart Emery
Created Date    : 1/7/2016
Last Mod Date   : 1/7/2016
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : test Class for NI_Invoice_Detail_TriggerHandler Class
                : 
                : 
******************************************************************************************/
@isTest
public class NI_Invoice_Detail_TriggerHandler_Test {

     // ======================================================================================================================================= //
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        test.startTest();  
        system.debug(' *** NI_Customer_Agreement_TriggerHandlerTest.createTestData() - START ***'); 
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 

        Id rtLargeDealId = OpportunityRecordTypeInfo.get('Large Deal Opportunity').getRecordTypeId();
        Id rtSalesOrderId = OpportunityRecordTypeInfo.get('Sales Order').getRecordTypeId(); 
        
        // CREATE A TEST USER WITH THE NI ADMINISTRATOR PROFILE TO USE AS THE RUNAS USER
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        u.FirstName = 'Apex';
        u.LastName = 'Testuser';
        insert u;    
        
        // CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TESTER ACCOUNT'; 
        insert a;
        
        // CREATE TEST CONTACT RECORD 
        Contact c = NI_TestClassData.createTestContact(1, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuser';        
        insert c; 
        
        // CREATE TEST PRODUCT GROUP RECORD
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;        
        
        // CREATE TEST PRODUCT RECORDS 
        List<Product2> lstProds = new List<Product2>();
        
        Product2 p2_2 = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-02', 'Services');
        lstProds.add(p2_2);
        
        Database.Insert(lstProds);        
        
        // CREATE TEST PRICEBOOK ENTRY RECORDS
        List<PricebookEntry> lstPBEs = new List<PricebookEntry>();
        
        Id pbkId = Test.getStandardPricebookId(); 
        
        PricebookEntry pbe2 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_2.Id, 1000);
        lstPBEs.add(pbe2);          
        
        Database.Insert(lstPBEs);   
        
        // CREATE TEST OPPORTUNITY RECORDS
        List<Opportunity> lstOpptys = new List<Opportunity>();
        
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.RecordTypeId = rtLargeDealId; 
        opp1.Name = 'APEX TEST - LARGE DEAL OPPORTUNITY 1';
        lstOpptys.add(opp1);
        
        Database.Insert(lstOpptys);
        
        // CREATE TEST OPPORTUNITY CONTACT ROLE RECORDS ==================================================================================
        List<OpportunityContactRole> lstOppContcRole = new List<OpportunityContactRole>();
        
        // Bill To contact
        OpportunityContactRole ocr1 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Bill To');
        lstOppContcRole.add(ocr1);
        // Ship To contact
        OpportunityContactRole ocr2 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Ship To');
        lstOppContcRole.add(ocr2);         
        // Customer Project Contact 
        OpportunityContactRole ocr3 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Customer Project Contact');
        lstOppContcRole.add(ocr3);        
        // Decision Maker Contact 
        OpportunityContactRole ocr4 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Decision Maker');
        lstOppContcRole.add(ocr4);        
        
        Database.Insert(lstOppContcRole); 
        
        // CREATE TEST OPPORTUNITY LINE ITEM RECORDS  ===================================================================================== 
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
        
        // Subscription Product
        OpportunityLineItem oli01 = NI_TestClassData.createTestOpportunityLineItem(1, opp1.Id, pbe2.Id, 1);
        oli01.TotalPrice = 1200;
        lstOLIs.add(oli01);
        
        Database.Insert(lstOLIs);
        
        //CREATE A TEST VENDOR AGREEMENT RECORD
        NI_Vendor_Agreement__c va  = NI_TestClassData.createTestVendorAgreement(1);
        va.Royalty_Distribution_Trigger__c = 'Installed';
        insert va;
        
        p2_2.Vendor_Agreement_Rule__c = va.Id;
        update p2_2;
        
        //CREATE A TEST CUSTOM VENDOR AGREEMENT RECORD
        NI_Vendor_Agreement__c cva  = NI_TestClassData.createTestVendorAgreement(2);
        cva.Vendor_Agreement__c = va.Id;
        cva.Franchisor__c = 'Apex Text';
        insert cva;
        
        //CREATE A TEST CUSTOMER AGREEMENT RECORD
        NI_Customer_Agreement__c ca  = NI_TestClassData.createTestCustomerAgreement(opp1.Id,p2_2.Id,a.Id,va.Id);
        ca.Royalty_Distribution_Trigger__c = 'Installed';
        ca.Discount__c = 20;
        insert ca;
        
        System.debug('INSERTED CUSTOMER AGREEMENT ID: ' + ca.Id);
        System.debug('Royalty_Distribution_Trigger__c: ' + ca.Royalty_Distribution_Trigger__c);
        System.debug('Install_Date__c: ' + ca.Install_Date__c);
        System.debug('Amortization_Term__c: ' + ca.Amortization_Term__c);
        System.debug('Royalty_Percentage__c: ' + ca.Royalty_Percentage__c);
        System.debug('Royalty_Base_Amount__c: ' + ca.Royalty_Base_Amount__c);
        System.debug('Sale_Price__c: ' + ca.Sale_Price__c);
        
        
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: NI_Customer_Agreement_TriggerHandlerTest.createTestData');  
        system.debug(' *** NI_Customer_Agreement_TriggerHandlerTest.createTestData() - END ***'); 
        test.stopTest();  
        
    }
}