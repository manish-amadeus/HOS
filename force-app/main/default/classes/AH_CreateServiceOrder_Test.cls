/****************************************************************************************
Name            : AH_CreateServiceOrder_Test Class
Author          : Suzanne LeDuc
Created Date    : 04/18/2014
Last Mod Date   : 07/02/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-010386
Description     : Test Class for the AH_CreateServiceOrder Class      
                : 
                : 
******************************************************************************************/
@isTest
public class AH_CreateServiceOrder_Test  
{
    
    // ======================================================================================================================================= 
    //  CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        Test.StartTest();     
        
        // CREATE CUSTOM SETTINGS
        Service_Order_Settings__c soSettings;
        soSettings = Service_Order_Settings__c.getValues('AdminLicenseCodes');
        
        if (soSettings == null)
        {
            soSettings = new Service_Order_Settings__c();
            soSettings.Name = 'AdminLicenseCodes';
            soSettings.Embedded_Customer_Admin__c = 'NMKT-EMD-ADM-EE-HRM';
            soSettings.Embedded_Partner_Admin__c = 'NMKT-PART-ADM-EE-HRM';
            soSettings.Enterprise_Customer_Admin__c = 'NMKT-PLT-ADM-HRM-EE';
            soSettings.Enterprise_Partner_Admin__c = 'NMKT-PTR-ADM-HRM-EE';
            soSettings.Sales_Cloud_Customer_Admin__c = 'NMKT-SF-EE-ADM-CNX';
            soSettings.Sales_Cloud_Partner_Admin__c = 'NMKT-SF-EE-PTR-ADM-CNX';
            soSettings.Number_of_Customer_Admins__c  =1;
            soSettings.Number_of_Partner_Admins__c = 2;
            soSettings.License_Types__c = 'EDA,Embedded, EMD-STD\r\nEmbedded Plus, EMD-PLS\r\nEnterprise, PLT\r\nSales Cloud,CNX\r\n';
            soSettings.Embedded_Plus_Customer_Admin__c = 'NMKT-EMD-PLS-HRM-ADM';
            soSettings.Embedded_Plus_Partner_Admin__c = 'NMKT-EMD-PLS-HRM-ADM-PART';
            soSettings.Default_Contract__c = 'Apex Test Term';
            soSettings.EDA_Customer_Admin__C = 'DELF-USD-EMD-PLS-OBJ-EDA';
            soSettings.EDA_Partner_Admin__C = 'DELF-USD-EMD-PLS-OBJ-EDA1';
            Database.insert(soSettings);
        }

        // CREATE TEST PARTNER CONTRACT TERMS RECORD 
        CHANNEL_ORDERS__Partner_Contract_Terms__c pct = NI_TestClassData.CreateContract();
        insert pct;
        
        // CREATE TEST CHANNEL_ORDERS__Partner_Product_Catalog__c RECORDS
        List<CHANNEL_ORDERS__Partner_Product_Catalog__c> lstPPCats = new List<CHANNEL_ORDERS__Partner_Product_Catalog__c>();
        // Enterprise
        CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEnterprise = NI_TestClassData.CreateProductCatalog(pct.Id, 'NMKT-PLT-STD-HRM-EE');
        lstPPCats.Add(sfdcProductEnterprise);
        // Enterprise Partner Admin
        CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEnterprisePartnerAdmin = NI_TestClassData.CreateProductCatalog(pct.Id, 'NMKT-PTR-ADM-HRM-EE');
        lstPPCats.Add(sfdcProductEnterprisePartnerAdmin);
        // Enterprise Customer Admin
        CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEnterpriseCustomerAdmin = NI_TestClassData.CreateProductCatalog(pct.Id, 'NMKT-PLT-ADM-HRM-EE');
        lstPPCats.Add(sfdcProductEnterpriseCustomerAdmin);
        
        // Embedded Partner Admin
        CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbeddedPartnerAdmin = NI_TestClassData.CreateProductCatalog(pct.Id, 'NMKT-PART-ADM-EE-HRM');
        lstPPCats.Add(sfdcProductEmbeddedPartnerAdmin);
        // Embedded Customer Admin
        CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbeddedCustomerAdmin = NI_TestClassData.CreateProductCatalog(pct.Id, 'NMKT-EMD-ADM-EE-HRM');
        lstPPCats.Add(sfdcProductEmbeddedCustomerAdmin);
        // Embedded
        CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbedded = NI_TestClassData.CreateProductCatalog(pct.Id, 'NMKT-EMD-STD-LOD');
        lstPPCats.Add(sfdcProductEmbedded);
        
        // Embedded Plus Partner Admin
        CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbeddedPlusPartnerAdmin = NI_TestClassData.CreateProductCatalog(pct.Id, 'NMKT-EMD-PLS-HRM-ADM-PART');
        lstPPCats.Add(sfdcProductEmbeddedPlusPartnerAdmin);
        // Embedded Plus Customer Admin
        CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbeddedPlusCustomerAdmin = NI_TestClassData.CreateProductCatalog(pct.Id, 'NMKT-EMD-PLS-HRM-ADM');
        lstPPCats.Add(sfdcProductEmbeddedPlusCustomerAdmin);
        // Embedded Plus
        CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbeddedPlus = NI_TestClassData.CreateProductCatalog(pct.Id, 'NMKT-EMD-PLS-HRM');
        lstPPCats.Add(sfdcProductEmbeddedPlus);
        
        // Sales Cloud Partner Admin
        CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductSalesCloudPartnerAdmin = NI_TestClassData.CreateProductCatalog(pct.Id, 'NMKT-SF-EE-PTR-ADM-CNX');
        lstPPCats.Add(sfdcProductSalesCloudPartnerAdmin);
        // Sales Cloud Customer Admin
        CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductSalesCloudCustomerAdmin = NI_TestClassData.CreateProductCatalog(pct.Id, 'NMKT-SF-EE-ADM-CNX');
        lstPPCats.Add(sfdcProductSalesCloudCustomerAdmin);
        CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEDACustomerAdmin = NI_TestClassData.CreateProductCatalog(pct.Id, 'DELF-USD-EMD-PLS-OBJ-EDA');
        lstPPCats.Add(sfdcProductEDACustomerAdmin);
        CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEDAPartnerAdmin = NI_TestClassData.CreateProductCatalog(pct.Id, 'DELF-USD-EMD-PLS-OBJ-EDA1');
        lstPPCats.Add(sfdcProductEDAPartnerAdmin);
        // Sales Cloud
        CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductSalesCloud = NI_TestClassData.CreateProductCatalog(pct.Id, 'NMKT-SF-EE-STD-CNX');
        lstPPCats.Add(sfdcProductSalesCloud);
        
        database.insert(lstPPCats);        
        
        // CREATE A TEST EMBRACE PRODUCT
        //CHANNEL_ORDERS__Partner_Product_Catalog__c ppc = [SELECT Id FROM CHANNEL_ORDERS__Partner_Product_Catalog__c WHERE CHANNEL_ORDERS__Product_ID__c = 'NMKT-PLT-STD-HRM-EE' LIMIT 1]; 
        
        
        Test.StopTest();     
        
        
        // CREATE TEST ACCOUNT RECORDS
        List<Account> lstAccounts = new List<Account>();
        
        Account a = NI_TestClassData.CreateTestAccount(1);
        a.Name = 'Apex Test Account for Auto SO';
        a.BillingPostalCode = '03801';
        a.BillingCountry = 'US';
        a.BillingState = 'NH';
        a.BillingStreet = '75 NH Ave';
        a.BillingCity = 'Portsmouth';
        a.Type = 'Customer'; 
        lstAccounts.add(a);

        Account a2 = NI_TestClassData.CreateTestAccount(2);
        a2.Name = 'Apex Test Arbitrary Account';
        lstAccounts.add(a2);
        
        Database.insert(lstAccounts);
        
        // CREATE A TEST CONTACT
        Contact con = NI_TestClassData.createTestContact(1, a.Id);
        con.FirstName = 'Apex';
        con.LastName = 'Testuser';        
        insert con;         
        
        // CREATE A TEST PRODUCT GROUP
        Product_Group__c pg = NI_TestClassData.createProductGroup(1, 'HRM');
        insert pg;

        // CREATE A TEST PRODUCT
        Product2 p2 = NI_TestClassData.createProduct2(1, pg.Id, 'APEX-HRM-TEST-01', 'HRM');     
        p2.Product_Group__c = pg.Id;
        p2.Product_Line__c = 'HRM Test';
        p2.Revenue_Category__c = 'Services';
        p2.Corporate_Product_Group__c = 'Newmarket';
        p2.Unit__c = 'Subscription';
        p2.IsActive = true;
        p2.Description = 'APEX Test Class';
        p2.Name = 'Embrace';
        p2.Partner_Product_Catalog__c = sfdcProductEnterprise.Id;        
        insert p2;
        
        // CREATE A TEST PRICEBOOK ENTRY RECORD
        PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry(Test.getStandardPricebookId(), p2.Id, 1500.00);
        insert pbe;

        // CREATE TEST NI ORG DETAIL RECORD
        Id rTypeId = Schema.SObjectType.NI_Org_Details__c.getRecordTypeInfosByName().get('LOD Support Admin').getRecordTypeId();
        
        NI_Org_Details__c orgDetails = NI_TestClassData.createTestNIOrgDetails(rTypeId, 1, 'Salesforce Production');
        orgDetails.Org_Name__c = 'Service order Test';
        orgDetails.Org_Id__c = '00D00000000abce';
        insert orgDetails;

        // CREATE TEST NI ORG DETAILS TO ACCOUNT RECORD
        NI_Org_Details_to_Accounts__c orgDetailAcc = NI_TestClassData.createTestNIOrgDetails2Accounts(orgDetails.Id, a.Id);
        insert orgDetailAcc;

        // CREATE A CASE RECORD 
        Case c = NI_TestClassData.CreateTestCase(1, a.Id);
        c.Subject = 'Apex Test Case for Auto SO';
        c.Reason = 'NI Configuration';
        c.Has_No_DI__c = true;
        insert c;

        // CREATE TEST OPPORTUNITY RECORDS
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id);
        opp1.Name = 'APEX TEXT OPPORTUNITY WITH TARGET HRM ORG';
        opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HRM New Org Opportunity').getRecordTypeId();
        opp1.Enterprise_License__c = false;
        opp1.CloseDate = Date.today();
        opp1.Effective_Date__c = Date.today();        
        lstOpportunity.add(opp1);

        Opportunity opp2 = NI_TestClassData.createTestOpportunity(2, a.Id);
        opp2.Name = 'APEX TEXT OPPORTUNITY WITHOUT TARGET HRM ORG';
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HRM New Org Opportunity').getRecordTypeId();
        opp2.CloseDate = Date.today();
        opp2.Effective_Date__c = Date.today();          
        lstOpportunity.add(opp2);

        Opportunity opp3 = NI_TestClassData.createTestOpportunity(3, a.Id);
        opp3.Name = 'APEX TEXT OPPORTUNITY WITHOUT TARGET HRM ORG 3';
        opp3.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HRM New Org Opportunity').getRecordTypeId();
        opp3.Enterprise_License__c = false;
        opp3.CloseDate = Date.today();
        opp3.Effective_Date__c = Date.today();          
        lstOpportunity.add(opp3);
        
        database.insert(lstOpportunity);

        // CREATE TEST OPPORTUNITY LINE ITEM RECORDS
        List<OpportunityLineItem> lstOLIInserts = new List<OpportunityLineItem>();
        
        OpportunityLineItem oli1 = NI_TestClassData.createTestOpportunityLineItem(1, opp1.Id, pbe.Id, 100);
        oli1.Order_of_Delivery__c = 1;
        lstOLIInserts.add(oli1);
        
        OpportunityLineItem oli2 = NI_TestClassData.createTestOpportunityLineItem(2, opp2.Id, pbe.Id, 10);
        oli2.Order_of_Delivery__c = 1;
        lstOLIInserts.add(oli2);
     
        OpportunityLineItem oli3 = NI_TestClassData.createTestOpportunityLineItem(3, opp3.Id, pbe.Id, 100);
        oli3.Order_of_Delivery__c = 1;
        lstOLIInserts.add(oli3);
        
        database.insert(lstOLIInserts);        

        // CREATE TEST OPPORTUNITY CONTACT ROLE RECORDS
        List<OpportunityContactRole> lstOpportunityContactRoles = new List<OpportunityContactRole>();
        
        OpportunityContactRole ocr3 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, con.Id, 'Customer Project Contact');
        lstOpportunityContactRoles.add(ocr3);       
        
        OpportunityContactRole ocr4 = NI_TestClassData.createTestOpportunityContactRole(opp3.Id, con.Id, 'Customer Project Contact');
        lstOpportunityContactRoles.add(ocr4);
        
        database.insert(lstOpportunityContactRoles);
        
        system.debug(' *** END AH_CreateServiceOrder_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }  
        
    // =======================================================================================================================================
    // = TEST METHOD 1: 
    // =======================================================================================================================================
    @isTest static void test1() 
    {  
        
        // RETRIEVE TEST RECORDS
        Account a = [SELECT Id, Name FROM Account WHERE Name = 'Apex Test Account for Auto SO']; 
        Account a2 = [SELECT Id, Name FROM Account WHERE Name = 'Apex Test Arbitrary Account']; 
        Opportunity opp1 = [SELECT Id FROM Opportunity WHERE AccountId =: a.Id AND Name = 'APEX TEXT OPPORTUNITY WITH TARGET HRM ORG'];
        Opportunity opp2 = [SELECT Id FROM Opportunity WHERE AccountId =: a.Id AND Name = 'APEX TEXT OPPORTUNITY WITHOUT TARGET HRM ORG'];
        CHANNEL_ORDERS__Partner_Contract_Terms__c contractTerms = [SELECT Id FROM CHANNEL_ORDERS__Partner_Contract_Terms__c WHERE Name = 'Apex Test Term' LIMIT 1];
        NI_Org_Details__c orgDetails = [SELECT Id, Org_Id__c, License_type__c, Org_Status__c FROM NI_Org_Details__c WHERE Org_Id__c = '00D00000000abce' LIMIT 1];

        // UPDATE ORG DETAILS
        orgDetails.License_Type__c = 'Enterprise';
        orgDetails.Org_Status__c = 'In Process';
        update orgDetails;
        
        // UPDATE OPPORTUNITY
        opp1.Target_HRM_Org__c = orgDetails.Id;
        update opp1;
        
        // SET THE CURRENT VF PAGE
        PageReference pageRef = Page.AH_CreateServiceOrder;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('OppId', opp1.Id);
        
        // Instantiate a new controller with all parameters in the page
        //        CHANNEL_ORDERS__Service_Order__c sOrder = new CHANNEL_ORDERS__Service_Order__c();
        AH_CreateServiceOrder ctrl = new AH_CreateServiceOrder();
        ctrl.notifyOppContact = true;
        
        // TEST "Create Missing Subscription Activation Records" BUTTON TO INITIALIZE THE FORM
        PageReference pr1 = ctrl.createSubcriptionActivations();
        
        Opportunity opp = ctrl.getSelectedOpportunity();
        Account acc = ctrl.getSelectedAccount(); 
        
        // ASSERT THAT A Subscription_Activation__c RECORD WAS CREATED
        List<Subscription_Activation__c> lstSAAsserts1 = new List<Subscription_Activation__c>([SELECT Id, Contracted_Quantity__c FROM Subscription_Activation__c WHERE Opportunity__c =: opp1.Id]);
        system.assertEquals(1, lstSAAsserts1.size(), 'Subscription_Activation__c test record was not created.');
        system.assertEquals(1, ctrl.lstSActs.size(), 'No products on Create Service Order form.');
        system.assertEquals(100, lstSAAsserts1.get(0).Contracted_Quantity__c, 'Unexpected value for Contracted_Quantity__c.'); 
        
        // TEST FILLING FORM OUT AND SUBMITTING IT
        
        // Opportunity
        //        Opportunity opportunity = ctrl.getSelectedOpportunity();
        //        system.assertEquals(opp1.Id, opportunity.Id);
        
        // SELECT PICK LISTS 
        ctrl.setSelectedContract(contractTerms.Id);
        string contractId = ctrl.getSelectedContract();
        system.assertEquals(contractTerms.Id, contractId);
        
        ctrl.setSelectedOrderType('Initial'); 
        String orderType = ctrl.GetSelectedOrderType(); 
        system.assertEquals(orderType, 'Initial'); 
        
        ctrl.setSelectedOrg(orgDetails.Org_ID__c); 
        string orgDetailsId = ctrl.getSelectedOrg(); 
        system.assertEquals(orgDetails.Org_ID__c, orgDetailsId); 
        
        // Products, Contracts, Orgs
        //        List<AH_CreateServiceOrder.selectedProducts> products = ctrl.getProducts(); 
        //        products[0].quantityToOrder = 1;         
        
        // ENTER DATE FIELDS
        Date d1 = Date.Today() - 10; 
        Date d2 = Date.Today() - 1; 
        Date d3 = Date.Today(); 
        
        ctrl.strDateCustomerSignedContract = String.valueOf(d1.month()) + '/' + String.valueOf(d1.day()) + '/' + String.valueOf(d1.year()); 
        ctrl.strAmadeusSignedContract = String.valueOf(d2.month()) + '/' + String.valueOf(d2.day()) + '/' + String.valueOf(d2.year()); 
        ctrl.strServiceStartDate = String.valueOf(d3.month()) + '/' + String.valueOf(d3.day()) + '/' + String.valueOf(d3.year()); 
        
        // SELECT ACCOUNT
        ctrl.accId = a2.Id; 
        
        // ENTER SERVICE ORDER NOTE
        Note soNote = ctrl.soNote; 
        soNote.Body = 'abcdeghijklmnopqrstuvwxyz'; 
        
        // TEST THAT ERROR IS THROWN WHEN A USER SUMBITS A FORM WITHOUT CHECKING ANY PRODUCTS
        try
        {
            ctrl.CreateServiceOrder(); 
        }
        catch(Exception e)
        {
            boolean expectedExceptionThrown = e.getMessage().contains('No products were checked off to process.') ? true : false;
            system.assertEquals(true, expectedExceptionThrown, e.getMessage());
        }            
        
        // CHECK THE BOX AND CHANGE THE QUANTITY
        ctrl.lstSActs.get(0).checked = true; 
        ctrl.lstSActs.get(0).quantityToOrder = 1; 
        
        Test.StartTest(); 
        
        // CLICK "Create Service Order" BUTTON ON FORM 
        ctrl.CreateServiceOrder(); 
        
        
        
        List<Subscription_Activation__c> lstSAAsserts2 = new List<Subscription_Activation__c>([SELECT Id, Contracted_Quantity__c, Backlog_Quantity__c, Activated_Quantity__c, Canceled_Quantity__c FROM Subscription_Activation__c]);
        system.assertEquals(1, lstSAAsserts2.size(), 'error.');        
        //system.debug(lstSAAsserts2);
        
        // ASSERT THAT SERVICE ORDER WAS CREATED
        List<CHANNEL_ORDERS__Service_Order__c> lstSOAsserts1 = new List<CHANNEL_ORDERS__Service_Order__c>(
            [SELECT Id,CHANNEL_ORDERS__Service_Order_Status__c,CHANNEL_ORDERS__Service_Start_Date__c FROM CHANNEL_ORDERS__Service_Order__c WHERE CHANNEL_ORDERS__Related_Opportunity__c =: opp1.Id]);
        system.assertEquals(1, lstSOAsserts1.size(), 'Service Order was not created.');
        
        // ASSERT THAT THE SERVICE ORDER NOTE WAS CREATED
        List<Note> lstSONoteAsserts1 = new List<Note>([SELECT Id FROM Note WHERE ParentId =: lstSOAsserts1.get(0).Id]);
        system.assertEquals(1, lstSONoteAsserts1.size(), 'Service Order Note was not created.');
        
        // ASSERT THAT THE Subscription_Activation__c ROLLUPS ARE CORRECT
        Subscription_Activation__c SA1 = [SELECT Id, Contracted_Quantity__c, Backlog_Quantity__c, Activated_Quantity__c, Canceled_Quantity__c 
                                          FROM Subscription_Activation__c WHERE Opportunity__c =: opp1.Id]; 
        system.assertEquals(100, SA1.Contracted_Quantity__c, 'Unexpected value for Contracted_Quantity__c.'); 
        system.assertEquals(99, SA1.Backlog_Quantity__c, 'Unexpected value for Backlog_Quantity__c.'); 
        system.assertEquals(1, SA1.Activated_Quantity__c, 'Unexpected value for Activated_Quantity__c.'); 
        system.assertEquals(0, SA1.Canceled_Quantity__c, 'Unexpected value for Canceled_Quantity__c.'); 
        
        // ASSERT THAT Subscription_Activation_Transaction__c RECORD WAS CREATED 
        List<Subscription_Activation_Transaction__c> lstSATAsserts1 = new List<Subscription_Activation_Transaction__c>(
            [SELECT Id FROM Subscription_Activation_Transaction__c WHERE Subscription_Activation_No__c =: SA1.Id AND Related_Account__c =: a2.Id]);
        system.assertEquals(1, lstSATAsserts1.size(), 'Subscription Activation Transaction was not created.');
        
        CHANNEL_ORDERS__Service_Order__c sotest = NI_TestClassData.createTestCO_ServiceOrder();
        sotest.CHANNEL_ORDERS__Service_Order_Status__c = 'Provisioned';
        sotest.CHANNEL_ORDERS__Order_Type__c = 'Upgrade - Partner App';
        
        CHANNEL_ORDERS__Service_Order__c sotest1 = NI_TestClassData.createTestCO_ServiceOrder();
        sotest1.CHANNEL_ORDERS__Service_Order_Status__c = 'Provisioned';
        sotest1.CHANNEL_ORDERS__Order_Type__c = 'Initial';  
        
        CHANNEL_ORDERS__Service_Order__c sotest2 = NI_TestClassData.createTestCO_ServiceOrder();
        sotest2.CHANNEL_ORDERS__Service_Order_Status__c = 'Provisioned';
        sotest2.CHANNEL_ORDERS__Order_Type__c = 'Cancellation Order';  
        
        CHANNEL_ORDERS__Service_Order__c sotest3 = NI_TestClassData.createTestCO_ServiceOrder();
        sotest3.CHANNEL_ORDERS__Service_Order_Status__c = 'Error';
        sotest3.CHANNEL_ORDERS__Order_Type__c = 'Error';   
        lstSOAsserts1.add(sotest);
        lstSOAsserts1.add(sotest1);
        //lstSOAsserts1.add(sotest2);
        lstSOAsserts1.add(sotest3);
        
        NI_ServiceOrderTriggerHandler.handleServiceOrderProvision(lstSOAsserts1,lstSOAsserts1);
        
        Test.StopTest();  
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 2: TEST EDA LICENSE TYPE
    // =======================================================================================================================================
    @isTest static void test2() 
    {  
        
        // RETRIEVE TEST RECORDS
        Account a = [SELECT Id, Name FROM Account WHERE Name = 'Apex Test Account for Auto SO']; 
        Opportunity opp1 = [SELECT Id FROM Opportunity WHERE AccountId =: a.Id AND Name = 'APEX TEXT OPPORTUNITY WITHOUT TARGET HRM ORG 3'];
        CHANNEL_ORDERS__Partner_Contract_Terms__c contractTerms = [SELECT Id FROM CHANNEL_ORDERS__Partner_Contract_Terms__c WHERE Name = 'Apex Test Term' LIMIT 1];
        NI_Org_Details__c orgDetails = [SELECT Id, Org_Id__c, License_type__c, Org_Status__c FROM NI_Org_Details__c WHERE Org_Id__c = '00D00000000abce' LIMIT 1];
        
        // UPDATE ORG DETAILS
        orgDetails.License_Type__c = 'EDA';
        orgDetails.Org_Status__c = 'In Process';
        update orgDetails;
        
        // UPDATE OPPORTUNITY
        opp1.Target_HRM_Org__c = orgDetails.Id;
        update opp1;
        
        // SET THE CURRENT VF PAGE
        PageReference pageRef = Page.AH_CreateServiceOrder;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('OppId', opp1.Id);
        
        // Instantiate a new controller with all parameters in the page
        AH_CreateServiceOrder ctrl = new AH_CreateServiceOrder();
        ctrl.notifyOppContact = true;
        
        // TEST "Create Missing Subscription Activation Records" BUTTON TO INITIALIZE THE FORM
        PageReference pr1 = ctrl.createSubcriptionActivations();
        
        Opportunity opp = ctrl.getSelectedOpportunity();
        Account acc = ctrl.getSelectedAccount(); 
        
        // ASSERT THAT A Subscription_Activation__c RECORD WAS CREATED
        List<Subscription_Activation__c> lstSAAsserts1 = new List<Subscription_Activation__c>([SELECT Id, Contracted_Quantity__c FROM Subscription_Activation__c WHERE Opportunity__c =: opp1.Id]);
        system.assertEquals(1, lstSAAsserts1.size(), 'Subscription_Activation__c test record was not created.');
        system.assertEquals(1, ctrl.lstSActs.size(), 'No products on Create Service Order form.');
        system.assertEquals(100, lstSAAsserts1.get(0).Contracted_Quantity__c, 'Unexpected value for Contracted_Quantity__c.'); 
        
        // SELECT PICK LISTS 
        ctrl.setSelectedContract(contractTerms.Id);
        string contractId = ctrl.getSelectedContract();
        system.assertEquals(contractTerms.Id, contractId);
        
        ctrl.setSelectedOrderType('Initial'); 
        String orderType = ctrl.GetSelectedOrderType(); 
        system.assertEquals(orderType, 'Initial'); 
        
        ctrl.setSelectedOrg(orgDetails.Org_ID__c); 
        string orgDetailsId = ctrl.getSelectedOrg(); 
        system.assertEquals(orgDetails.Org_ID__c, orgDetailsId); 
        
        // ENTER DATE FIELDS
        Date d1 = Date.Today() - 10; 
        Date d2 = Date.Today() - 1; 
        Date d3 = Date.Today(); 
        
        ctrl.strDateCustomerSignedContract = String.valueOf(d1.month()) + '/' + String.valueOf(d1.day()) + '/' + String.valueOf(d1.year()); 
        ctrl.strAmadeusSignedContract = String.valueOf(d2.month()) + '/' + String.valueOf(d2.day()) + '/' + String.valueOf(d2.year()); 
        ctrl.strServiceStartDate = String.valueOf(d3.month()) + '/' + String.valueOf(d3.day()) + '/' + String.valueOf(d3.year()); 
        
        // ENTER SERVICE ORDER NOTE
        Note soNote = ctrl.soNote; 
        soNote.Body = 'abcdeghijklmnopqrstuvwxyz'; 
        
        // TEST THAT ERROR IS THROWN WHEN A USER SUMBITS A FORM WITHOUT CHECKING ANY PRODUCTS
        try
        {
            ctrl.CreateServiceOrder(); 
        }
        catch(Exception e)
        {
            boolean expectedExceptionThrown = e.getMessage().contains('No products were checked off to process.') ? true : false;
            system.assertEquals(true, expectedExceptionThrown, e.getMessage());
        }            
        
        // CHECK THE BOX AND CHANGE THE QUANTITY
        ctrl.lstSActs.get(0).checked = true; 
        ctrl.lstSActs.get(0).quantityToOrder = 1; 
        
        Test.StartTest(); 
        
        // CLICK "Create Service Order" BUTTON ON FORM 
        ctrl.CreateServiceOrder(); 
        
        //ctrl.sendOrder(); 
        
        Test.StopTest(); 
        
        List<Subscription_Activation__c> lstSAAsserts2 = new List<Subscription_Activation__c>([SELECT Id, Contracted_Quantity__c, Backlog_Quantity__c, Activated_Quantity__c, Canceled_Quantity__c FROM Subscription_Activation__c]);
        system.assertEquals(1, lstSAAsserts2.size(), 'error.');        
        system.debug(lstSAAsserts2);
        
        // ASSERT THAT SERVICE ORDER WAS CREATED
        List<CHANNEL_ORDERS__Service_Order__c> lstSOAsserts1 = new List<CHANNEL_ORDERS__Service_Order__c>(
            [SELECT Id FROM CHANNEL_ORDERS__Service_Order__c WHERE CHANNEL_ORDERS__Related_Opportunity__c =: opp1.Id]);
        system.assertEquals(1, lstSOAsserts1.size(), 'Service Order was not created.');
        
        // ASSERT THAT THE SERVICE ORDER NOTE WAS CREATED
        List<Note> lstSONoteAsserts1 = new List<Note>([SELECT Id FROM Note WHERE ParentId =: lstSOAsserts1.get(0).Id]);
        system.assertEquals(1, lstSONoteAsserts1.size(), 'Service Order Note was not created.');
        
        // ASSERT THAT THE Subscription_Activation__c ROLLUPS ARE CORRECT
        Subscription_Activation__c SA1 = [SELECT Id, Contracted_Quantity__c, Backlog_Quantity__c, Activated_Quantity__c, Canceled_Quantity__c 
                                          FROM Subscription_Activation__c WHERE Opportunity__c =: opp1.Id]; 
        system.assertEquals(100, SA1.Contracted_Quantity__c, 'Unexpected value for Contracted_Quantity__c.'); 
        system.assertEquals(99, SA1.Backlog_Quantity__c, 'Unexpected value for Backlog_Quantity__c.'); 
        system.assertEquals(1, SA1.Activated_Quantity__c, 'Unexpected value for Activated_Quantity__c.'); 
        system.assertEquals(0, SA1.Canceled_Quantity__c, 'Unexpected value for Canceled_Quantity__c.'); 
        
    }
    
}