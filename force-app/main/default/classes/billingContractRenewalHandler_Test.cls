/****************************************************************************************
Name            : billingContractRenewalHandler_Test
Author          : Sean Harris
Created Date    : 09/01/2018
Last Mod Date   : 09/01/2018 
Last Mod By     : Sean Harris
Description     : 
                : 
				: 
******************************************************************************************/
@isTest
public class billingContractRenewalHandler_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {

        // CREATE TEST USER
        List<User> lstUserInsert = new List<User>();
        User u = NI_TestClassData.createTestUser(1, 'NI Finance'); 
        u.Alias = 'FIN01TST'; 
        insert u;         
        
        // CREATE TEST ACCOUNT
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id accRTId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();        

        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX billingContractRenewalHandler TEST';
        a.RecordTypeId = accRTId;
        insert a;
        
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
        insert pgp;

        // CREATE TEST OPPORTUNITY
        Schema.DescribeSObjectResult cfrSchema1 = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema1.getRecordTypeInfosByName(); 
        Id opptyRecTypeId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();
        
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.Name = 'APEX billingContractRenewalHandler OPPORTUNITY';
        o.RecordTypeId = opptyRecTypeId;
        insert o;
        
        // CREATE TEST DI INDEX RECORD
        NI_DeploymentInstanceIndex__c diIdx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST');     
        insert diIdx1; 
        
        // CREATE TEST PRODUCT RECORD
        Product2 p2 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-011', 'Support');
        p2.DI_Index__c = diIdx1.Id;
        p2.Apttus_Config2__HasOptions__c = false;
        p2.Duration_Months__c = 12;
        insert p2;
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset di = NI_TestClassData.createTestAsset(1, a.Id, p2.Id);
        di.Status = 'Purchased';
        di.Product_Group__c = pgp.Id; 
        di.Build_Number__c = '56';
        insert di;      

        // CREATE SETTINGS RECORD (MANAGED)
        ffrr__Settings__c st = NI_TestClassData.createSettings();
        st.Name = 'APEX Activity Line Item';
        insert st;
        
        // CREATE TEMPLATE RECORD (MANAGED)
        ffrr__Template__c tp = NI_TestClassData.createffrrTemplate(st.Id);
        tp.Name = 'APEX TEST - Deliverable';
        insert tp; 
        
        // CREATE TEST PAYMENT TERMS
        Payment_Terms__c pt = NI_TestClassData.createInvoicePaymentTerms();
        pt.Name = '4 Installments';
        pt.Invoice_Split_Method__c = 'Equal';
        insert pt;
        
        Payment_Terms__c pt2 = NI_TestClassData.createInvoicePaymentTerms();
        pt2.Name = 'Percent Installments';
        pt2.Invoice_Split_Method__c = 'Percent Breakdown';
      	pt2.Billed_through_PSA__c = true;
        insert pt2; 

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
        
        Payment_Term_Line_Item__c ptLI4 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt2.Id);
        ptLI4.Order__c = 4;
        ptLI4.Offset_Measure__c = 'Days';
        lstPTLineItem.add(ptLI4);
        
        database.insert(lstPTLineItem); 

        Test.startTest();
        
        // CREATE BILLING CONTRACT
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(1);
        bc.Account__c = a.Id;
        bc.Opportunity__c = o.Id;        
		insert bc;
        
        // CREATE TEST ACTIVITY LINE ITEM RECORD
        Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(bc.Id);
        ali.Billing_Contract__c = bc.Id;
        ali.Account__c = a.Id;
        ali.Billing_Renewal_Lead_Time_Days__c = 30;
        ali.Renewal_Base_Price__c = 1000;
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
        ali.Deployment_Instance__c = di.Id; 
        insert ali;
       
        List<Activity_Line_Item__c> aliAssert = new List<Activity_Line_Item__c>([SELECT Id, Contract_Total_Amount__c FROM Activity_Line_Item__c WHERE Account__c =: a.Id]);
        system.assertEquals(1, aliAssert.size());
        system.assertEquals(1000, aliAssert[0].Contract_Total_Amount__c);
        
        Billing_Contract_Line_Item__c bcli = NI_TestClassData.createBillingContract(bc.Id, ali.Id);
        bcli.Split_Order__c = 1;
        bcli.Status__c = 'Active';
        bcli.Pro_Rated__c = true;
        insert bcli; 
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= //
    // = TEST METHOD 1: 
    // ======================================================================================================================================= //
    @isTest static void billingContractRenewal1() 
    {
        
        Test.startTest();

        List<manageBillingContractRenewalController.aliWrapper> wrapperList = new List<manageBillingContractRenewalController.aliWrapper>();
        List<Activity_Line_Item__c> aliList = new List<Activity_Line_Item__c>(
            [SELECT Id, Renewal_Base_Price__c, Payment_Terms__c, Units_Remaining__c, Billing_Renewal_Lead_Time_Days__c, Billing_Contract__c,
             Contract_Start_Date__c, Contract_End_Date__c, Contract_Total_Amount__c, Product__r.Duration_Months__c, Revenue_Category__c      
             FROM Activity_Line_Item__c]);

        system.assertEquals(1, aliList.size());

        for (Activity_Line_Item__c actLine : aliList)
        {       

            manageBillingContractRenewalController.aliWrapper w = new manageBillingContractRenewalController.aliWrapper();
            Activity_Line_Item__c dumALI = new Activity_Line_Item__c();
            
            w.ali_object = actLine;
            w.dummy_ali_object = dumALI;
            w.dummy_ali_object.Payment_Terms__c = actLine.Payment_Terms__c;
            w.dummy_ali_object.Units__c = actLine.Units_Remaining__c;            
            w.dummy_ali_object.Billing_Contract__c = actLine.Billing_Contract__c;
            w.check = true;
            w.disabled = false;
            w.rpe = null;            
            w.renewalAmount = 1000;             
            w.percentIncrease = 1;
            w.basePrice = actLine.Renewal_Base_Price__c;
            w.renewalPriceMethodology = 'Contract Spec - No Increase'; 
            
            wrapperList.add(w);
            
        }
        
		billingContractRenewalHandler.processBCRenewals(wrapperList);
        
        Test.stopTest();
        
    }

    // ======================================================================================================================================= //
    // = TEST METHOD 2: 
    // ======================================================================================================================================= //
    @isTest static void billingContractRenewal2() 
    {

		Account a = [SELECT Id FROM Account WHERE Name = 'APEX billingContractRenewalHandler TEST'];
        Billing_Contract__c bc = [SELECT Id FROM Billing_Contract__c WHERE Account__c =: a.Id];       
        Product2 p2 = [SELECT Id FROM Product2 WHERE ProductCode = 'APEX-TEST-011'];         
        ffrr__Template__c tp = [SELECT Id FROM ffrr__Template__c WHERE Name = 'APEX TEST - Deliverable'];
        Payment_Terms__c pt = [SELECT Id FROM Payment_Terms__c WHERE Name = 'Percent Installments'];
        Payment_Term_Line_Item__c ptli = [SELECT Id FROM Payment_Term_Line_Item__c WHERE Offset_Measure__c = 'Days' AND Order__c = 4];
        Payment_Term_Line_Item__c ptLI1 = [SELECT Id FROM Payment_Term_Line_Item__c WHERE Offset_Measure__c = 'Days' AND Order__c = 1]; 
        Payment_Term_Line_Item__c ptLI2 = [SELECT Id FROM Payment_Term_Line_Item__c WHERE Offset_Measure__c = 'Months']; 
        Payment_Term_Line_Item__c ptLI3 = [SELECT Id FROM Payment_Term_Line_Item__c WHERE Offset_Measure__c = 'Years'];         
        Asset di = [SELECT Id FROM Asset WHERE Build_Number__c = '56'];
                
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
        ali.Contract_Amount__c = 2000; 
        ali.Units__c = 1;
        ali.Deployment_Instance__c = di.Id; 
        insert ali;
       
        // CREATE TEST BILLING CONTRACT LINE ITEM RECORDS
        List<Billing_Contract_Line_Item__c> lstBCLIs = new List<Billing_Contract_Line_Item__c>();
        
        Billing_Contract_Line_Item__c blci1 = NI_TestClassData.createBillingContract(bc.Id, ali.Id);
        blci1.Split_Order__c = 1;
        blci1.Status__c = 'Active';
        blci1.Pro_Rated__c = true;
        blci1.Payment_Term_Line_Item__c = ptli.Id;
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
        
        Test.startTest();

        List<manageBillingContractRenewalController.aliWrapper> wrapperList = new List<manageBillingContractRenewalController.aliWrapper>();
        
        List<Activity_Line_Item__c> aliList = new List<Activity_Line_Item__c>(
            [SELECT Id, Renewal_Base_Price__c, Payment_Terms__c, Units_Remaining__c, Billing_Renewal_Lead_Time_Days__c, Billing_Contract__c,
             Contract_Start_Date__c, Contract_End_Date__c, Contract_Total_Amount__c, Product__r.Duration_Months__c, Revenue_Category__c      
             FROM Activity_Line_Item__c]);

        system.assertEquals(2, aliList.size());

        for (Activity_Line_Item__c actLine : aliList)
        {       

            manageBillingContractRenewalController.aliWrapper w = new manageBillingContractRenewalController.aliWrapper();
            Activity_Line_Item__c dumALI = new Activity_Line_Item__c();
            
            w.ali_object = actLine;
            w.dummy_ali_object = dumALI;
            w.dummy_ali_object.Payment_Terms__c = actLine.Payment_Terms__c;
            w.dummy_ali_object.Units__c = actLine.Units_Remaining__c;            
            w.dummy_ali_object.Billing_Contract__c = actLine.Billing_Contract__c;
            w.check = true;
            w.disabled = false;
            w.rpe = null;            
            w.renewalAmount = 1000;             
            w.percentIncrease = 1;
            w.basePrice = actLine.Renewal_Base_Price__c;
            w.renewalPriceMethodology = 'Contract Spec - No Increase'; 
            wrapperList.add(w);
            
        }
        
		billingContractRenewalHandler.processBCRenewals(wrapperList);
        
        Test.stopTest();
        
    }
    
}