/****************************************************************************************
Name            : AH_PCC_CancellationDetails_Ctlr_Test
Author          : Sean Harris
Created Date    : 05/16/2019
Last Mod Date   : 05/16/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for the AH_PCC_CancellationDetails_Ctlr Controller
                : 
******************************************************************************************/
@isTest
public class AH_PCC_CancellationDetails_Ctlr_Test 
{

    // =======================================================================================================================================
    // = TEST METHOD 1: CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup static void createTestData() 
    {
        
        test.startTest();

        // CREATE TEST CUSTOMER ACCOUNT
        Account cust = NI_TestClassData.createTestAccount(1);
        cust.Name = 'APEX TEST - Customer Account #1';
        insert cust;        

        // CREATE TEST PARTNER ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'Cendyn';
        a.Partner_Chatter_Group_ID__c = Label.PartnerCentral_Chatter_Group_Id_for_Test_Classes;	
        insert a;
        
        // CREATE TEST DI INDEX
        NI_DeploymentInstanceIndex__c diIdx = NI_TestClassData.createDI_Index(1, 'APEX TEST PARTNER');
        insert diIdx;
        
        // CREATE TEST PRODUCT GROUP
        Product_Group__c pg = NI_TestClassData.createProductGroup(1, 'Cendyn');
        pg.IsActive__c = true;
        pg.IsCoreProduct__c = true;        
        insert pg;
        
        // CREATE TEST PRODUCT RELATED TO PARTNER ACCOUNT
        Product2 p1 = NI_TestClassData.createProduct2(1, pg.Id, 'Cendyn-SKU-001', 'Cendyn');
        p1.Partner_Name__c = a.Id;
        p1.DI_Index__c = diIdx.Id;
        p1.Product_Line__c = 'Cendyn Test';
        p1.Revenue_Category__c = 'Subscription';
        p1.Corporate_Product_Group__c = 'Newmarket';
        p1.Unit__c = 'Subscription';
        p1.IsActive = true;
        p1.Description = 'APEX Test Class';
        p1.Family = 'Cendyn';
        p1.Name = 'Cendyn Product Test 1';
        p1.Revenue_Category__c = 'Subscription';        
        insert p1;

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
        
        Payment_Terms__c payTrms = [SELECT Id FROM Payment_Terms__c WHERE Name = '4 Installments'];

        // CREATE TEST BILLING CONTRACT
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(1);
        bc.Account__c = cust.Id;
		insert bc;

        // CREATE TEST ACTIVITY LINE ITEM RECORDS
		// 	VISIBLE TO PARTNER
        Activity_Line_Item__c ali1 = NI_TestClassData.createActivityLineItem(bc.Id); 
        //ali1.Opportunity__c = opp.Id; 
        //ali1.Opp_Product_ID__c = oliId1; 
        ali1.Product__c = p1.Id; 
		ali1.Payment_Terms__c = payTrms.Id; 
        ali1.Activation_Date__c = Date.today() - 1; 
        ali1.Contract_Start_Date__c = Date.today() - 1; 
        ali1.Contract_End_Date__c = Date.today() + 364; 
        ali1.Activation_Required__c = true; 
        ali1.ffrrtemplate__c = tp.Id; 
        ali1.Contract_Amount__c = 1000; 
        ali1.Units__c = 1; 
        ali1.Revenue_Category__c = 'Subscription';
        //ali1.Cancel_Renewal_By_Date__c = IF(AND(ISPICKVAL(Product__r.Product_Line_Global__c,"Delphi.fdc")), Contract_End_Date__c -60, Contract_End_Date__c -30)
        insert ali1;         

        NI_Cancellation__c cxl = NI_TestClassData.createCancellation(a.Id);        
        cxl.Account__c = cust.Id;
        //cxl.Brand__c = a.Brand__c;
        //cxl.Opportunity__c = opp.Id;
        cxl.Product2__c = p1.Id;
        cxl.Activity_Line_Item__c = ali1.Id;        
        cxl.Effective_Date__c = Date.today() - 1;
        cxl.Status__c = 'Pending Retention';
        cxl.General_Reason__c = 'Affiliation Change';
        cxl.Invoice_Number__c = 'APEX TEST CANCELLATION #1';
        cxl.Cancellation_Notes__c = 'APEX TEST 1';
        cxl.Late_Cancellation__c = false;
        cxl.Retention_Completed__c = false; 
        cxl.Late_Cancellation_Not_Approved__c = false;

        //cxl.Cancel_Renewal_By_Date__c = IF(AND(ISPICKVAL(Product__r.Product_Line_Global__c,"Delphi.fdc")), Contract_End_Date__c -60, Contract_End_Date__c -30)
        insert cxl;        
        
        test.stopTest();
        
    }

    // =======================================================================================================================================
    // = TEST METHOD 1: 
    // =======================================================================================================================================    
    @isTest static void test1() 
    {

        NI_Cancellation__c cxl = [SELECT Id, Name, Status__c, Effective_Date__c, Account_Number__c, Account_Name__c, 
                                   Management_Company__r.Name, Product_Code__c, Product__c, General_Reason__c, Late_Cancellation__c, 
                                   Renewal_Cancellation_Reason__c, Cancel_Renewal_By_Date__c, Cancellation_Notes__c, Sales_Retention_Notes__c                                   
                                   FROM NI_Cancellation__c 
                                   WHERE Invoice_Number__c = 'APEX TEST CANCELLATION #1'];
        
system.debug(' *%* cxl = ' + cxl);        
        
        test.startTest();
        
        // SET THE CURRENT VF PAGE
        PageReference pr = Page.AH_PCC_CancellationDetails;
        Test.setCurrentPage(pr);
        system.currentPageReference().getParameters().put('id', cxl.Id);
        AH_PCC_CancellationDetails_Ctlr ctrl = new AH_PCC_CancellationDetails_Ctlr(); 
        
        ctrl.doEdit();
        system.assertEquals('Pending Retention', ctrl.selField); 
        system.assertEquals(true, ctrl.isEditMode); 
        
        ctrl.doCancel();
		system.assertEquals(false, ctrl.isEditMode); 
        
        ctrl.doEdit();
        system.assertEquals('Pending Retention', ctrl.selField); 
        system.assertEquals(true, ctrl.isEditMode); 
        
        ctrl.selField = 'Successfully Retained';
        ctrl.txtNotes = 'Successfully Retained';
        
        ctrl.doSave();
        
        NI_Cancellation__c cxlAssert = [SELECT Id, Status__c, Sales_Retention_Notes__c FROM NI_Cancellation__c WHERE Id =: cxl.Id];
        system.assertEquals('Successfully Retained', cxlAssert.Status__c);
        system.assertEquals('Successfully Retained', cxlAssert.Sales_Retention_Notes__c);
        
        test.stopTest();        
    }
    
}