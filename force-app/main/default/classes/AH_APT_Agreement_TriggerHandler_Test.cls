/************************************************************************************************
Name            : AH_APT_Agreement_TriggerHandler_Test Class
Author          : Stuart Emery
Created Date    : 11/14/2013
Last Mod Date   : 05/29/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test Class for the AH_APT_Agreement_TriggerHandler Class
                : UPDATED on 1/14/2014 Per NICC: NICC-009144
                : 
*************************************************************************************************/
@isTest
public class AH_APT_Agreement_TriggerHandler_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        Test.startTest();        
        
        // CREATE TEST PAYMENT TERM RECORDS
        List<Payment_Terms__c> lstPaymentTerms = new List<Payment_Terms__c>();
        
        Payment_Terms__c pt1 = NI_TestClassData.createInvoicePaymentTerms();
        pt1.Name = 'test1';
        pt1.Offset_Date__c = 'Effective Date';
        pt1.Billed_Through_PSA__c = false;
        pt1.Aptus_Payment_Terms__c = 'Standard';
        pt1.Invoice_Split_Method__c = 'Percent Breakdown'; 
        pt1.Type__c = 'Services';
        lstPaymentTerms.add(pt1);
        
        Payment_Terms__c pt2 = NI_TestClassData.createInvoicePaymentTerms();
        pt2.Name = 'test2';
        pt2.Offset_Date__c = 'Activation Date';
        pt2.Billed_Through_PSA__c = false;
        pt2.Aptus_Payment_Terms__c = 'Standard';
        pt2.Invoice_Split_Method__c = 'Equal'; 
        pt2.Type__c = 'Licensed Program';
        lstPaymentTerms.add(pt2);
        
        Payment_Terms__c pt3 = NI_TestClassData.createInvoicePaymentTerms();
        pt3.Name = 'test3';
        pt3.Offset_Date__c = 'Activation Date';
        pt3.Billed_Through_PSA__c = true;
        pt3.Aptus_Payment_Terms__c = 'Standard';
        pt3.Invoice_Split_Method__c = 'Equal'; 
        pt3.Type__c = 'Support';
        lstPaymentTerms.add(pt3);
        
        Payment_Terms__c pt4 = NI_TestClassData.createInvoicePaymentTerms();
        pt4.Name = 'test4';
        pt4.Offset_Date__c = 'Activation Date';
        pt4.Billed_Through_PSA__c = true;
        pt4.Aptus_Payment_Terms__c = 'Standard';
        pt4.Invoice_Split_Method__c = 'Equal'; 
        pt4.Type__c = 'Support';
        lstPaymentTerms.add(pt4);
        
        Payment_Terms__c pt5 = NI_TestClassData.createInvoicePaymentTerms();
        pt5.Name = 'test5';
        pt5.Offset_Date__c = 'Activation Date';
        pt5.Billed_Through_PSA__c = true;
        pt5.Aptus_Payment_Terms__c = 'Standard';
        pt5.Invoice_Split_Method__c = 'Equal'; 
        pt5.Type__c = 'Subscription';
        lstPaymentTerms.add(pt5);
        
        Payment_Terms__c pt6 = NI_TestClassData.createInvoicePaymentTerms();
        pt6.Name = 'test6';
        pt6.Offset_Date__c = 'Activation Date';
        pt6.Billed_Through_PSA__c = true;
        pt6.Aptus_Payment_Terms__c = 'Standard';
        pt6.Invoice_Split_Method__c = 'Equal'; 
        pt6.Type__c = 'HRM Subscription';
        lstPaymentTerms.add(pt6);
        
        Payment_Terms__c pt7 = NI_TestClassData.createInvoicePaymentTerms();
        pt7.Name = 'test7';
        pt7.Offset_Date__c = 'Activation Date';
        pt7.Billed_Through_PSA__c = true;
        pt7.Aptus_Payment_Terms__c = 'Standard';
        pt7.Invoice_Split_Method__c = 'Equal'; 
        pt7.Type__c = 'HRM Services';
        lstPaymentTerms.add(pt7);
        
		database.insert(lstPaymentTerms);

        // CREATE TEST PAYMENT TERMS LINE ITEM RECORDS
        List<Payment_Term_Line_Item__c> lstPayTermLines = new List<Payment_Term_Line_Item__c>();
        
        Payment_Term_Line_Item__c ptl1 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt1.Id); 
        ptl1.Order__c = 1;
        ptl1.Offset_Measure__c = 'Months';
        ptl1.Offset_Units__c = 1;
        ptl1.Duration_Units__c = 1;
        ptl1.Percent_of_Total__c = 50; 
        lstPayTermLines.add(ptl1);
        
        Payment_Term_Line_Item__c ptl2 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt2.Id); 
        ptl2.Order__c = 1;
        ptl2.Offset_Measure__c = 'Years';
        ptl2.Offset_Units__c = 1;
        ptl2.Duration_Units__c = 1;
        ptl2.Percent_of_Total__c = 50;
        lstPayTermLines.add(ptl2);
        
        Payment_Term_Line_Item__c ptl3 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt3.Id); 
        ptl3.Order__c = 1;
        ptl3.Offset_Measure__c = 'Years';
        ptl3.Offset_Units__c = 1;
        ptl3.Duration_Units__c = 1;
        ptl3.Percent_of_Total__c = 50; 
        lstPayTermLines.add(ptl3); 
        
        database.insert(lstPayTermLines);
        
        //CREATE TEST PRICE BOOK RECORD  
        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'Apex Test Pricebook';   
        pb2.Description = 'Apex Test Pricebook';
        pb2.IsActive = true;
        insert pb2;
        
        //CREATE TEST APTTUS PRICE LIST RECORD  
        Apttus_Config2__PriceList__c apl = new Apttus_Config2__PriceList__c();
        apl.Name = 'Apex Test Pricebook';
        apl.Related_Salesforce_Price_Book__c = pb2.Id;   
        apl.Apttus_Config2__Active__c = true;
        insert apl;  
        
         //CREATE TEST ACCOUNT RECORD 
         Account a = NI_TestClassData.createTestAccount(1);
         a.Name = 'AH_APT_Agreement_TriggerHandler_Test Account';
         insert a;   
        
        //CREATE TEST OPPORTUNITY RECORD  
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.Name = 'AH_APT_Agreement_TriggerHandler_Test';
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Small Deal Opportunity').getRecordTypeId();
        o.Pricebook2Id = pb2.Id;
        o.License_Program_Payment_Terms__c = pt1.Id;
        o.Services_Payment_Terms__c = pt1.Id;
        o.Subscription_Payment_Terms__c = pt1.Id;
        o.Hosting_and_Support_Payment_Terms__c = pt1.Id; 
        insert o;
        
        Test.stopTest();
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: 
    // =======================================================================================================================================     
    static testMethod void test1() 
    {    
        
        Account a = [SELECT Id FROM Account WHERE Name = 'AH_APT_Agreement_TriggerHandler_Test Account'];
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Name = 'AH_APT_Agreement_TriggerHandler_Test'];
        Apttus_Config2__PriceList__c apl = [SELECT Id FROM Apttus_Config2__PriceList__c WHERE Name = 'Apex Test Pricebook'];
        
        Test.StartTest();
        
        //INSERT TEST APTTUS AGREEMENT RECORD
        Apttus__APTS_Agreement__c agr1 = new Apttus__APTS_Agreement__c(); 
        
        agr1.Name = 'APTTUS TEST AGREEMENT';
        agr1.Apttus__Related_Opportunity__c = o.Id;      
        
        agr1.APTS_Licensed_Program__c = 'Standard';        
        agr1.APTS_Services__c = 'Standard';
        agr1.APTS_Hosting_and_Support__c = 'Standard';
        agr1.APTS_Subscription__c = 'Standard';
        agr1.APTS_Support__c = 'Standard';
        agr1.APTS_HRM_Apps_Subscription_Term__c = 'Standard';
        agr1.HRM_Apps_Services_Terms__c = 'Package';
        
        insert agr1;
        
        agr1.APTS_Licensed_Program__c = '6 Month Payment Terms';        
        agr1.APTS_Services__c = 'Package Service';
        agr1.APTS_Hosting_and_Support__c = 'Package Support';
        agr1.APTS_Subscription__c = 'Quarterly Billing';
        agr1.APTS_Support__c = 'Package Service';
        agr1.APTS_HRM_Apps_Subscription_Term__c = 'Quarterly';
        agr1.HRM_Apps_Services_Terms__c = '3 Annual Installments';
        
        update agr1;         
        
        Test.StopTest();
        
for (Apttus__APTS_Agreement__c x : [SELECT Id, Name, Apttus__Account__c, Apttus_CMConfig__PriceListId__c FROM Apttus__APTS_Agreement__c])   
{
    system.debug('*^* Apttus__APTS_Agreement__c = ' + x);
}
        
        
/*        
        // VERIFY THAT THE AGREEMENT FIELDS HAVE BEEN UPDATED  
        Apttus__APTS_Agreement__c agrAssert = [SELECT Id, Apttus__Account__c 
                                               FROM Apttus__APTS_Agreement__c 
                                               WHERE Id =: agr1.Id
                                               AND Name =: o.Name
                                               AND Apttus_CMConfig__PriceListId__c =: apl.Id];
        
        system.Assert(agrAssert.Apttus__Account__c == a.Id);
*/        
    }
    
    //================================================================================================================================
    // BULK INSERT AGREEMENT TEST  
    //================================================================================================================================
/*
    static testMethod void bulkInsertAgreementTest() 
    {    
        
        AH_APT_Agreement_TriggerHandler handler = new AH_APT_Agreement_TriggerHandler();

        //CREATE TEST PRICE BOOK RECORD  
        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'Apex Test Pricebook';   
        pb2.Description = 'Apex Test Pricebook';
        pb2.IsActive = true;
        insert pb2;
        
        //CREATE TEST APTTUS PRICE LIST RECORD  
        Apttus_Config2__PriceList__c apl = new Apttus_Config2__PriceList__c();
        apl.Name = 'Apex Test Pricebook';
        apl.Related_Salesforce_Price_Book__c = pb2.Id;   
        apl.Apttus_Config2__Active__c = true;
        insert apl;    
        
        //GET OPPORTUNITY RECORD TYPE ID
        Id rtInit = NI_TestClassData.getRecordTypeId('Opportunity', 'Small Deal Opportunity');
        
        //CREATE TEST ACCOUNT RECORD  
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;     
        
        //CREATE TEST OPPORTUNITY RECORD  
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.RecordTypeId = rtInit;
        opp1.Pricebook2Id = pb2.Id;
        lstOppInserts.add(opp1);
        
        Database.Insert(lstOppInserts);
        
        //CREATE TEST AGREEMENT RECORDS
        List<Apttus__APTS_Agreement__c> lstAgreementsToInsert = new List<Apttus__APTS_Agreement__c>();  
        
        for (Integer j = 0; j < 200; j++) 
        {
            Apttus__APTS_Agreement__c agr = new Apttus__APTS_Agreement__c();
            agr.Name = 'APTTUS TEST AGREEMENT' + j;
            agr.Apttus__Related_Opportunity__c = opp1.Id; 
            lstAgreementsToInsert.add(agr);
        }
        
        //START TEST TO INVOKE AFTER INSERT TRIGGER LOGIC  
        Test.StartTest();
        Database.Insert(lstAgreementsToInsert);
        Test.StopTest();      
        
        
        //VERIFY THAT THE AGREEMENT FIELDS HAVE BEEN UPDATED USING SYSTEM.ASSERT METHOD  
        List<Apttus__APTS_Agreement__c> lstInsertedAgreements = [SELECT Id, Apttus__Account__c 
                                                                 FROM Apttus__APTS_Agreement__c 
                                                                 WHERE Apttus__Account__c =: a.Id
                                                                 AND Name =: opp1.Name
                                                                 AND Apttus_CMConfig__PriceListId__c =: apl.Id];
        
        //VERIFY THERE ARE 200 AGREEMENT RECORDS WHERE Apttus__Account__c IS EQUAL TO THE a.Id  
        system.Assert(lstInsertedAgreements.size() == 200);
        
    }    
*/    
}