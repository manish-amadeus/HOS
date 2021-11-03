/************************************************************************************************
Name            : AH_ActivityLineItem_Statics_Test
Author          : Sean Harris
Created Date    : 05/01/2019
Last Mod Date   : 05/01/2019
Last Mod By     : Sean Harris
NICC Reference  :
Description     : Test class for AH_ActivityLineItem_Statics
                :
*************************************************************************************************/
@isTest 
public class AH_ActivityLineItem_Statics_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
		system.debug(' *** START AH_ActivityLineItem_Statics_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Test.startTest();
        
        // CREATE A TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST AH_ActivityLineItem_Statics_Test ACCOUNT';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Property Account').getRecordTypeId();
        insert a;           
        
        // CREATE TEST PRODUCT GROUP RECORD
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
        insert pgp;        
        
        // CREATE TEST PRODUCT RECORD
        Product2 p2 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription'); 
        p2.Product_Line__c = 'Delphi Single Property';
        p2.Revenue_Category__c = 'Services';
        p2.Unit__c = 'Subscription';
        p2.IsActive = true;
        p2.Description = 'APEX AH_ActivityLineItem_Statics_Test TEST';
        p2.Name = 'APEX AH_ActivityLineItem_Statics_Test TEST';
        p2.Duration_Months__c = 12;
        p2.Line__c = 'Delphi';
        p2.Edition__c = 'Enterprise';
        p2.Classification__c = 'TEST DATA';
        p2.Support_Classification__c = 'Gold';
        p2.Interface_Classification__c = 'PMS';
        p2.Corporate_Product_Group__c = 'Newmarket';        
        insert p2;        

        // CREATE TEST OPPORTUNITY RECORD
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id);
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Non-HRM Opportunity').getRecordTypeId();
        o.Name = 'APEX TEST AH_ActivityLineItem_Statics_Test OPPORTUNITY';
        insert o;

        // CREATE SETTINGS RECORD (MANAGED)
        ffrr__Settings__c st = NI_TestClassData.createSettings();
        st.Name = 'APEX Activity Line Item';
        insert st;
        
        // CREATE TEMPLATE RECORD (MANAGED)
        ffrr__Template__c tp = NI_TestClassData.createffrrTemplate(st.Id);
        tp.Name = 'APEX TEST - Deliverable';
    	insert tp; 
        
        // CREATE TEST PAYMENT TERM
        Payment_Terms__c pt = NI_TestClassData.createInvoicePaymentTerms();
        pt.Name = '4 Installments';
        pt.Invoice_Split_Method__c = 'Equal';
        insert pt;
        
        // CREATE TEST PAYMENT TERM LINE ITEMS
        List<Payment_Term_Line_Item__c> lstPTLineItem = new List<Payment_Term_Line_Item__c>();
        
        Payment_Term_Line_Item__c ptLI1 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt.Id);
        ptLI1.Order__c = 1;
        ptLI1.Offset_Measure__c = 'Days';
        ptLI1.Offset_Units__c = 1;
        lstPTLineItem.add(ptLI1);
        
        Payment_Term_Line_Item__c ptLI2 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt.Id);
        ptLI2.Order__c = 2;
        ptLI2.Offset_Measure__c = 'Months';
        ptLI2.Offset_Units__c = 1;
        lstPTLineItem.add(ptLI2);
        
        Payment_Term_Line_Item__c ptLI3 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt.Id);
        ptLI3.Order__c = 3;
        ptLI3.Offset_Measure__c = 'Years';
        ptLI3.Offset_Units__c = 1;
        lstPTLineItem.add(ptLI3);
        
        Payment_Term_Line_Item__c ptLI4 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt.Id);
        ptLI3.Order__c = 4;
        lstPTLineItem.add(ptLI4);
        
        database.insert(lstPTLineItem); 

        // CREATE TEST BILLING CONTRACT RECORD
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(10);
        bc.Account__c = a.Id;
        bc.Opportunity__c = o.Id;
        insert bc;

        // CREATE TEST ACTIVITY LINE ITEM RECORD
        Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(bc.Id);
        ali.Activation_Date__c = Date.today();
        ali.Contract_Start_Date__c = Date.today().addMonths(1);
        ali.Contract_End_Date__c = Date.today().addMonths(2);
        ali.Product__c = p2.Id;
        ali.Payment_Terms__c = pt.Id;
        ali.Opp_Product_ID__c = p2.Id;
        ali.Activation_Required__c = true;
        ali.ffrrtemplate__c = tp.Id;
        ali.Contract_Amount__c = 1000; 
        ali.Units__c = 1;
        ali.Pro_Rated__c = false;
        ali.Revenue_Category__c = 'Support';
        //ali.Deployment_Instance__c = di.Id; 
        insert ali;

        List<Activity_Line_Item__c> lstALIAssert1 = new List<Activity_Line_Item__c>([SELECT Id 
                                                                                     FROM Activity_Line_Item__c
                                                                                     WHERE Revenue_Category__c IN ('Subscription', 'Support', 'Hosting and Support')
                                                                                     AND Pro_Rated__c = false 
                                                                                     AND Contract_Start_Date__c != null
                                                                                     AND Id =: ali.Id]);
        system.assertEquals(1, lstALIAssert1.size());		
        
        // CREATE TEST BILLING CONTRACT LINE ITEM RECORDS
        List<Billing_Contract_Line_Item__c> lstBCLIs = new List<Billing_Contract_Line_Item__c>();
        
        Billing_Contract_Line_Item__c blci1 = NI_TestClassData.createBillingContract(bc.Id, ali.Id);
        blci1.Split_Order__c = 1;
        blci1.Status__c = 'Active';
        blci1.Pro_Rated__c = true;
        lstBCLIs.add(blci1);
        
        Billing_Contract_Line_Item__c blci2 = NI_TestClassData.createBillingContract(bc.Id, ali.Id);
        blci2.Split_Order__c = 1;
        blci2.Status__c = 'Active';
        blci2.Activation_Required__c = true;
        blci2.Payment_Term_Line_Item__c = ptLI1.Id; 
        blci2.Pro_Rated__c = false;
        blci2.Revenue_Category__c = 'Support';
        lstBCLIs.add(blci2);
        
        Billing_Contract_Line_Item__c blci3 = NI_TestClassData.createBillingContract(bc.Id, ali.Id);
        blci3.Split_Order__c = 1;
        blci3.Status__c = 'Active';
        blci3.Activation_Required__c = true;
        blci3.Payment_Term_Line_Item__c = ptLI2.Id; 
        blci3.Pro_Rated__c = false;
        blci3.Revenue_Category__c = 'Hosting and Support';
        lstBCLIs.add(blci3);
        
        Billing_Contract_Line_Item__c blci4 = NI_TestClassData.createBillingContract(bc.Id, ali.Id);
        blci4.Split_Order__c = 1;
        blci4.Status__c = 'Active';
        blci4.Activation_Required__c = true;
        blci4.Payment_Term_Line_Item__c = ptLI3.Id; 
        blci4.Pro_Rated__c = false;
        blci4.Revenue_Category__c = 'Subscription'; 
        lstBCLIs.add(blci4);
         
        database.insert(lstBCLIs);
        
        Test.stopTest();
        
		system.debug(' ***  END  AH_ActivityLineItem_Statics_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
   
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
		
		system.debug(' *** START AH_ActivityLineItem_Statics_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());	

        Product2 p2 = [SELECT Id FROM Product2 WHERE Name = 'APEX AH_ActivityLineItem_Statics_Test TEST'];
		Activity_Line_Item__c ali = [SELECT Id FROM Activity_Line_Item__c WHERE Product__c =: p2.Id];  
        
		Test.startTest();

        ali.Revenue_Category__c = 'Subscription';
        update ali;
        
		List<Billing_Contract_Line_Item__c> lstBLIAssert1 = new List<Billing_Contract_Line_Item__c>([SELECT Id FROM Billing_Contract_Line_Item__c WHERE Activity_Line_Item__c =: ali.Id]);
        system.assertEquals(4, lstBLIAssert1.size());        

        Test.stopTest();
        
		system.debug(' ***  END  AH_ActivityLineItem_Statics_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
                
}