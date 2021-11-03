/****************************************************************************************
Name            : NI_CreateServiceOrderTest Class
Author          : Suzanne LeDuc
Created Date    : 4/18/2014
Last Mod Date   : 7/22/2014
Last Mod By     : Stuart Emery
NICC Reference  : NICC-010386
Description     : Test Class for the NI_CreateServiceOrder Class      
                : 
                : 
******************************************************************************************/
@isTest
public class NI_CreateServiceOrderTest  {
  
//Creates most of the data needed for the tests 
@testSetup static void setup() {

 //Setup Data
    CreateServiceOrderCustomSettings();
    
    Account a = NI_TestClassData.CreateTestAccount(1);
    a.Name = 'Apex Test Account for Auto SO';
    a.BillingPostalCode = '03801';
    a.BillingCountry = 'US';
    a.BillingState = 'NH';
    a.BillingStreet = '75 NH Ave';
    a.BillingCity = 'Portsmouth';
    a.Type = 'Customer';
            
    insert a;
    ID rTypeId = NI_testClassData.getRecordTypeId('NI_Org_Details__c', 'LOD Support Admin' );
    
    NI_Org_Details__c orgDetails = NI_TestClassData.createTestNIOrgDetails( rTypeId, 1, 'Salesforce Production');
    orgDetails.Org_Name__c = 'Service order Test';
    orgDetails.ORg_ID__c = '00D00000000abce';
    insert orgDetails;
    
    
    NI_Org_Details_to_Accounts__c orgDetailAcc = NI_TestClassData.createTestNIOrgDetails2Accounts(orgDetails.Id, a.Id);
    insert orgDetailAcc;
    
    CHANNEL_ORDERS__Customer__c customer = NI_TestClassData.CreateCustomer( '00D00000000abce' );
    customer.CHANNEL_ORDERS__Customer_Org_ID__c = '00D00000000abce';
    insert customer;
    
    
    
    Case c = NI_TestClassData.CreateTestCase(1,a.Id);
    c.Subject = 'Apex Test Case for Auto SO';
    c.Reason = 'NI Configuration';
    c.Has_No_DI__c = true;
        
    insert c;
    
    
    CHANNEL_ORDERS__Partner_Contract_Terms__c  contractTerms = NI_TestClassData.CreateContract();
    insert contractTerms;
    
    //Enterprise
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEnterprise = CreateProductCatalog( contractTerms, 'NMKT-PLT-STD-HRM-EE' );
    insert sfdcProductEnterprise;
    //Enterprise Partner Admin
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEnterprisePartnerAdmin = CreateProductCatalog( contractTerms, 'NMKT-PTR-ADM-HRM-EE' );
    insert sfdcProductEnterprisePartnerAdmin;
    //Enterprise Customer Admin
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEnterpriseCustomerAdmin = CreateProductCatalog( contractTerms, 'NMKT-PLT-ADM-HRM-EE' );
    insert sfdcProductEnterpriseCustomerAdmin;
    
     //Embedded Partner Admin
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbeddedPartnerAdmin = CreateProductCatalog( contractTerms, 'NMKT-PART-ADM-EE-HRM' );
    insert sfdcProductEmbeddedPartnerAdmin;
    //Embedded Customer Admin
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbeddedCustomerAdmin = CreateProductCatalog( contractTerms, 'NMKT-EMD-ADM-EE-HRM' );
    insert sfdcProductEmbeddedCustomerAdmin;
    //Embedded
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbedded = CreateProductCatalog( contractTerms, 'NMKT-EMD-STD-LOD' );
    insert sfdcProductEmbedded;
   
   //Embedded Plus Partner Admin
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbeddedPlusPartnerAdmin = CreateProductCatalog( contractTerms, 'NMKT-EMD-PLS-HRM-ADM-PART' );
    insert sfdcProductEmbeddedPlusPartnerAdmin;
    //Embedded Plus Customer Admin
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbeddedPlusCustomerAdmin = CreateProductCatalog( contractTerms, 'NMKT-EMD-PLS-HRM-ADM' );
    insert sfdcProductEmbeddedPlusCustomerAdmin;
    //Embedded Plus
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbeddedPlus = CreateProductCatalog( contractTerms, 'NMKT-EMD-PLS-HRM' );
    insert sfdcProductEmbeddedPlus;
    
     //Sales Cloud Partner Admin
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductSalesCloudPartnerAdmin = CreateProductCatalog( contractTerms, 'NMKT-SF-EE-PTR-ADM-CNX' );
    insert sfdcProductSalesCloudPartnerAdmin;
    //Sales Cloud Customer Admin
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductSalesCloudCustomerAdmin = CreateProductCatalog( contractTerms, 'NMKT-SF-EE-ADM-CNX' );
    insert sfdcProductSalesCloudCustomerAdmin;
    //Sales Cloud
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductSalesCloud = CreateProductCatalog( contractTerms, 'NMKT-SF-EE-STD-CNX' );
    insert sfdcProductSalesCloud;
   

    Opportunity opp = NI_TestClassData.createTestOpportunity(1,a.Id);
    insert opp;

    Product_Group__c pg = NI_TestClassData.createProductGroup(1,'HRM');
    insert pg;
}  
  

  
//Initial Order  - Tests an initial order - Typical flow
public static testMethod void NI_CreateServiceOrderTestInitial() 
{
    Account a = [SELECT Id, Name FROM Account WHERE Name='Apex Test Account for Auto SO' LIMIT 1];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :a.Id];
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEnterprise = [ SELECT ID From CHANNEL_ORDERS__Partner_Product_Catalog__c Where CHANNEL_ORDERS__Product_ID__c = 'NMKT-PLT-STD-HRM-EE' LIMIT 1];
    
    Product_Group__c pg = [SELECT ID FROM Product_Group__c WHERE Name = 'HRM' LIMIT 1];
    CHANNEL_ORDERS__Partner_Contract_Terms__c  contractTerms = [SELECT ID FROM CHANNEL_ORDERS__Partner_Contract_Terms__c WHERE Name = 'Apex Test Term' LIMIT 1];
    Case c = [SELECT ID FROM Case where Subject = 'Apex Test Case for Auto SO' LIMIT 1];
    
   
   
    NI_Org_Details__c orgDetails = [ SELECT ID, Org_Id__c, License_type__c, Org_Status__c FROM NI_Org_Details__C Where ORG_ID__C = '00D00000000abce' LIMIT 1];
    orgDetails.License_Type__c = 'Enterprise';
    orgDetails.Org_Status__c = 'In Process';
    update orgDetails;
   
    
    
    CHANNEL_ORDERS__Customer__c customer = [SELECT ID, CHANNEL_ORDERS__Customer_Org_ID__c FROM CHANNEL_ORDERS__Customer__c WHERE CHANNEL_ORDERS__Customer_Org_ID__c = '00D00000000abce'];
    
    Test.StartTest();     
    
    opp.Target_HRM_Org__c = orgDetails.Id;
    upsert opp;
    
  
    Product2 p2 =  CreateProduct2ForServiceOrder( sfdcProductEnterprise.Id, pg, 1 );
    insert p2;
    
    PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry( Test.getStandardPricebookId(), p2.Id, 1500.00 );
    insert pbe;
    
    
    OpportunityLineItem lineItem = NI_TestClassData.CreateTestOpportunityLineItem( 1, opp.Id,  pbe.Id, 1 );
    insert lineItem;
   // OpportunityLineItem lineItem2 = NI_TestClassData.CreateTEstOpportunityLineItem( 2, opp.Id, pbe.Id, 10 );
   // insert lineItem2;
    Test.StopTest(); 
    
    //Set the current page
    PageReference pageRef = Page.CreateServiceOrder;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('OppId', opp.Id);
  
    // Instantiate a new controller with all parameters in the page
    NI_CreateServiceOrder controller = new NI_CreateServiceOrder();
    
    //Contract
    controller.setSelectedContract( contractTerms.Id );
    string contractId = controller.getSelectedContract();
    System.assertEquals( contractTerms.Id, contractId );
    
    //Opportunity
    Opportunity opportunity = controller.getOpportunity();
    System.assertEquals( opp.Id, opportunity.Id );
   
    //Products, Contracts, Orgs
     List<NI_CreateServiceOrder.selectedProducts> products = controller.getProducts();
     products[0].quantityToOrder = 1;
    
    
    controller.getContractOptions();
    controller.getOrgOptions();
    controller.getOrderTypeOptions();
    
   
    controller.setServiceOrderCase( c.Id );
    Id caseId = controller.getServiceOrderCase();
    System.assertEquals( c.Id, caseId);
    
    controller.setServiceOrderNIDate( date.Today());
    Date NIDate = controller.getServiceOrderNIDate();
    System.assertEquals( date.Today(), NIDate );
    
    controller.setServiceOrderCustDate( date.Today());
    Date CustDate = controller.getServiceOrderCustDate();
    System.assertEquals( date.Today(), CustDate );
    
    
    controller.setserviceOrderStartDate( date.Today());
    Date startDate = Controller.getServiceOrderStartDate();
    System.assertEquals( date.Today(), startDate );
    
    
    Controller.setSelectedOrderType( 'Initial');
    String orderType = Controller.GetSelectedOrderType();
    System.AssertEquals( orderType, 'Initial');
    
    controller.setSelectedOrg( orgDetails.Org_ID__c);
    string orgDetailsId = controller.getSelectedOrg();
    System.assertEquals( orgDetails.Org_ID__c, orgDetailsId );
    
    
    Note soNote = controller.soNote;
    soNote.Body = 'abcdeghijklmnopqrstuvwxyz';
    
  
    controller.CreateServiceOrder();
    
    CHANNEL_ORDERS__Service_Order__c sOrder = controller.getServiceOrder();
    controller.setServiceOrder( sOrder );
    System.assertEquals( sOrder, controller.getServiceOrder() );
    
    
  
  
}





//Initial Order but already provisioned - Tests that you cannot create an iniital order for an org that has already been provisioned
public static testMethod void NI_CreateServiceOrderTestInitialProvisioned() 
{

    Account a = [SELECT Id, Name FROM Account WHERE Name='Apex Test Account for Auto SO' LIMIT 1];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :a.Id];
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEnterprise = [ SELECT ID From CHANNEL_ORDERS__Partner_Product_Catalog__c Where CHANNEL_ORDERS__Product_ID__c = 'NMKT-PLT-STD-HRM-EE' LIMIT 1];
    
    Product_Group__c pg = [SELECT ID FROM Product_Group__c WHERE Name = 'HRM' LIMIT 1];
    CHANNEL_ORDERS__Partner_Contract_Terms__c  contractTerms = [SELECT ID FROM CHANNEL_ORDERS__Partner_Contract_Terms__c WHERE Name = 'Apex Test Term' LIMIT 1];
    Case c = [SELECT ID FROM Case where Subject = 'Apex Test Case for Auto SO' LIMIT 1];

    
    
    NI_Org_Details__c orgDetails = [ SELECT ID, Org_Id__c, License_type__c, Org_Status__c FROM NI_Org_Details__C Where ORG_ID__C = '00D00000000abce' LIMIT 1];
    orgDetails.License_Type__c = 'Enterprise';
    orgDetails.Org_Status__c = 'Provisioned';
    upsert orgDetails;
    
    CHANNEL_ORDERS__Customer__c customer = [SELECT ID, CHANNEL_ORDERS__Customer_Org_ID__c FROM CHANNEL_ORDERS__Customer__c WHERE CHANNEL_ORDERS__Customer_Org_ID__c = '00D00000000abce'];
    
    
    
    Test.StartTest();     
   
    opp.Target_HRM_Org__c = orgDetails.Id;
    upsert opp;
    
  
    Product2 p2 =  CreateProduct2ForServiceOrder( sfdcProductEnterprise.Id, pg, 1 );
    insert p2;
    
    PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry( Test.getStandardPricebookId(), p2.Id, 1500.00 );
    insert pbe;
    
    
    OpportunityLineItem lineItem = NI_TestClassData.CreateTestOpportunityLineItem( 1, opp.Id,  pbe.Id, 10 );
    insert lineItem;
    OpportunityLineItem lineItem2 = NI_TestClassData.CreateTEstOpportunityLineItem( 2, opp.Id, pbe.Id, 10 );
    insert lineItem2;
    Test.StopTest(); 
    
    //Set the current page
    PageReference pageRef = Page.CreateServiceOrder;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('OppId', opp.Id);
  
    // Instantiate a new controller with all parameters in the page
    NI_CreateServiceOrder controller = new NI_CreateServiceOrder();
    
    //Contract
    controller.setSelectedContract( contractTerms.Id );
    string contractId = controller.getSelectedContract();
    System.assertEquals( contractTerms.Id, contractId );
    
    //Opportunity
    Opportunity opportunity = controller.getOpportunity();
    System.assertEquals( opp.Id, opportunity.Id );
   
    //Products, Contracts, Orgs
     List<NI_CreateServiceOrder.selectedProducts> products = controller.getProducts();
     products[1].quantityToOrder = 1;
    
    
    controller.getContractOptions();
    controller.getOrgOptions();
    controller.getOrderTypeOptions();
    
   
    controller.setServiceOrderCase( c.Id );
    Id caseId = controller.getServiceOrderCase();
    System.assertEquals( c.Id, caseId);
    
    controller.setServiceOrderNIDate( date.Today());
    Date NIDate = controller.getServiceOrderNIDate();
    System.assertEquals( date.Today(), NIDate );
    
    controller.setServiceOrderCustDate( date.Today());
    Date CustDate = controller.getServiceOrderCustDate();
    System.assertEquals( date.Today(), CustDate );
    
    Controller.setSelectedOrderType( 'Initial');
    String orderType = Controller.GetSelectedOrderType();
    System.AssertEquals( orderType, 'Initial');
    
    controller.setSelectedOrg( orgDetails.Org_ID__c);
    string orgDetailsId = controller.getSelectedOrg();
    System.assertEquals( orgDetails.Org_ID__c, orgDetailsId );

    
  
    //With Org Details
    controller.CreateServiceOrder();
  
}


//No Customer Record - Tests that the code will create a customer record if one does not exist
public static testMethod void NI_CreateServiceOrderNoCustomerRecord() 
{

    Account a = [SELECT Id, Name FROM Account WHERE Name='Apex Test Account for Auto SO' LIMIT 1];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :a.Id];
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEnterprise = [ SELECT ID From CHANNEL_ORDERS__Partner_Product_Catalog__c Where CHANNEL_ORDERS__Product_ID__c = 'NMKT-PLT-STD-HRM-EE' LIMIT 1];
    
    Product_Group__c pg = [SELECT ID FROM Product_Group__c WHERE Name = 'HRM' LIMIT 1];
    CHANNEL_ORDERS__Partner_Contract_Terms__c  contractTerms = [SELECT ID FROM CHANNEL_ORDERS__Partner_Contract_Terms__c WHERE Name = 'Apex Test Term' LIMIT 1];
    Case c = [SELECT ID FROM Case where Subject = 'Apex Test Case for Auto SO' LIMIT 1];
    
    NI_Org_Details__c orgDetails = [ SELECT ID, Org_Id__c, License_type__c, Org_Status__c FROM NI_Org_Details__C Where ORG_ID__C = '00D00000000abce' LIMIT 1];
    orgDetails.Org_Id__c = '00D00000000abcg';
    orgDetails.License_Type__C = 'Enterprise';
  
    upsert orgDetails;
    
    
  
  
    Test.StartTest();     
    opp.Target_HRM_Org__c = orgDetails.Id;
    upsert opp;
    
   
    Product2 p2 =  CreateProduct2ForServiceOrder( sfdcProductEnterprise.Id, pg, 1 );
    insert p2;
    
    PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry( Test.getStandardPricebookId(), p2.Id, 1500.00 );
    insert pbe;
    
    
    OpportunityLineItem lineItem = NI_TestClassData.CreateTestOpportunityLineItem( 1, opp.Id,  pbe.Id, 10 );
    insert lineItem;
    OpportunityLineItem lineItem2 = NI_TestClassData.CreateTEstOpportunityLineItem( 2, opp.Id, pbe.Id, 10 );
    insert lineItem2;
    Test.StopTest(); 
    
    //Set the current page
    PageReference pageRef = Page.CreateServiceOrder;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('OppId', opp.Id);
  
    // Instantiate a new controller with all parameters in the page
    NI_CreateServiceOrder controller = new NI_CreateServiceOrder();
    
    //Contract
    controller.setSelectedContract( contractTerms.Id );
    string contractId = controller.getSelectedContract();
    System.assertEquals( contractTerms.Id, contractId );
    
    //Opportunity
    Opportunity opportunity = controller.getOpportunity();
    System.assertEquals( opp.Id, opportunity.Id );
   
    //Products, Contracts, Orgs
     List<NI_CreateServiceOrder.selectedProducts> products = controller.getProducts();
     products[1].quantityToOrder = 1;
     products[1].checked = true;
    
    
    controller.getContractOptions();
    controller.getOrgOptions();
    controller.getOrderTypeOptions();
    
   
    controller.setServiceOrderCase( c.Id );
    Id caseId = controller.getServiceOrderCase();
    System.assertEquals( c.Id, caseId);
    
    controller.setServiceOrderNIDate( date.Today());
    Date NIDate = controller.getServiceOrderNIDate();
    System.assertEquals( date.Today(), NIDate );
    
    controller.setServiceOrderCustDate( date.Today());
    Date CustDate = controller.getServiceOrderCustDate();
    System.assertEquals( date.Today(), CustDate );
    
    
    controller.setserviceOrderStartDate( date.Today());
    Date startDate = Controller.getServiceOrderStartDate();
    System.assertEquals( date.Today(), startDate );
    
    
    Controller.setSelectedOrderType( 'Initial');
    String orderType = Controller.GetSelectedOrderType();
    System.AssertEquals( orderType, 'Initial');
    
    controller.setSelectedOrg( orgDetails.Org_ID__c);
    string orgDetailsId = controller.getSelectedOrg();
    System.assertEquals( orgDetails.Org_ID__c, orgDetailsId );

  
    //With Org Details
    controller.CreateServiceOrder();
  
   
}

//Add-On Order - Tests an "Add On" order
public static testMethod void NI_CreateServiceOrderTestAddOn() 
{
    Account a = [SELECT Id, Name FROM Account WHERE Name='Apex Test Account for Auto SO' LIMIT 1];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :a.Id];
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbedded = [ SELECT ID From CHANNEL_ORDERS__Partner_Product_Catalog__c Where CHANNEL_ORDERS__Product_ID__c = 'NMKT-PART-ADM-EE-HRM' LIMIT 1];
    
    Product_Group__c pg = [SELECT ID FROM Product_Group__c WHERE Name = 'HRM' LIMIT 1];
    CHANNEL_ORDERS__Partner_Contract_Terms__c  contractTerms = [SELECT ID FROM CHANNEL_ORDERS__Partner_Contract_Terms__c WHERE Name = 'Apex Test Term' LIMIT 1];
    Case c = [SELECT ID FROM Case where Subject = 'Apex Test Case for Auto SO' LIMIT 1];
   
    NI_Org_Details__c orgDetails = [ SELECT ID, Org_Id__c, License_type__c, Org_Status__c FROM NI_Org_Details__C Where ORG_ID__C = '00D00000000abce' LIMIT 1];
    orgDetails.License_Type__c = 'Embedded';
    orgDetails.Org_Status__c = 'Provisioned';
  
    upsert orgDetails;
  
    CHANNEL_ORDERS__Customer__c customer = [SELECT ID, CHANNEL_ORDERS__Customer_Org_ID__c FROM CHANNEL_ORDERS__Customer__c WHERE CHANNEL_ORDERS__Customer_Org_ID__c = '00D00000000abce'];
  
    
    //Test.StartTest();     
  
    upsert opp;
    Product2 p2 =  CreateProduct2ForServiceOrder( sfdcProductEmbedded.Id, pg, 1 );
    insert p2;
    PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry( Test.getStandardPricebookId(), p2.Id, 1500.00 );
    insert pbe;
    
    
    OpportunityLineItem lineItem = NI_TestClassData.CreateTestOpportunityLineItem( 1,opp.Id,  pbe.Id,10 );
    insert lineItem;
    OpportunityLineItem lineItem2 = NI_TestClassData.CreateTestOpportunityLineItem( 2,opp.Id, pbe.Id,10 );
    insert lineItem2;
    //Test.StopTest(); 
    
    //Set the current page
    PageReference pageRef = Page.CreateServiceOrder;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('OppId', opp.Id);
  
    // Instantiate a new controller with all parameters in the page
    NI_CreateServiceOrder controller = new NI_CreateServiceOrder();
    
    //Contract
    controller.setSelectedContract( contractTerms.Id );
    string contractId = controller.getSelectedContract();
    System.assertEquals( contractTerms.Id, contractId );
    controller.setSelectedOrderType( 'Add-On');
    
    //Opportunity
    Opportunity opportunity = controller.getOpportunity();
    System.assertEquals( opp.Id, opportunity.Id );
   
    //Products, Contracts, Orgs
     List<NI_CreateServiceOrder.selectedProducts> products = controller.getProducts();
     products[1].quantityToOrder = 1;
    
    
    controller.getContractOptions();
    controller.getOrgOptions();
    
    
    System.Debug('ORG ID HERE ' + orgDetails.Org_Id__c );
    controller.setSelectedOrg( orgDetails.Org_ID__c);
    string orgDetailsId = controller.getSelectedOrg();
    System.assertEquals( orgDetails.Org_ID__c, orgDetailsId );

    
    controller.setServiceOrderCase( c.Id );
    Id caseId = controller.getServiceOrderCase();
    System.assertEquals( c.Id, caseId);
    
    controller.setServiceOrderNIDate( date.Today());
    Date NIDate = controller.getServiceOrderNIDate();
    System.assertEquals( date.Today(), NIDate );
    
    controller.setServiceOrderCustDate( date.Today());
    controller.setServiceOrderStartDate( Null );
    
    
    
    
    controller.CreateServiceOrder();
    
  
  
}


//Initial embedded - Tests an initial order for Embedded Licenses
public static testMethod void NI_CreateServiceOrderTestInitialEmbedded() 
{
    Account a = [SELECT Id, Name FROM Account WHERE Name='Apex Test Account for Auto SO' LIMIT 1];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :a.Id];
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbedded = [ SELECT ID From CHANNEL_ORDERS__Partner_Product_Catalog__c Where CHANNEL_ORDERS__Product_ID__c = 'NMKT-EMD-STD-LOD' LIMIT 1];
    
    Product_Group__c pg = [SELECT ID FROM Product_Group__c WHERE Name = 'HRM' LIMIT 1];
    CHANNEL_ORDERS__Partner_Contract_Terms__c  contractTerms = [SELECT ID FROM CHANNEL_ORDERS__Partner_Contract_Terms__c WHERE Name = 'Apex Test Term' LIMIT 1];
    Case c = [SELECT ID FROM Case where Subject = 'Apex Test Case for Auto SO' LIMIT 1];
  
   
   
    NI_Org_Details__c orgDetails = [ SELECT ID, Org_Id__c, License_type__c, Org_Status__c FROM NI_Org_Details__C Where ORG_ID__C = '00D00000000abce' LIMIT 1];
    orgDetails.License_Type__c = 'Embedded';
    orgDetails.Org_Status__c = 'In Process';
  
    upsert orgDetails;
    CHANNEL_ORDERS__Customer__c customer = [SELECT ID, CHANNEL_ORDERS__Customer_Org_ID__c FROM CHANNEL_ORDERS__Customer__c WHERE CHANNEL_ORDERS__Customer_Org_ID__c = '00D00000000abce'];
  
    Test.StartTest();     
  
    upsert opp;
    
    Product2 p2 =  CreateProduct2ForServiceOrder( sfdcProductEmbedded.Id, pg, 1 );
    insert p2;
    PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry( Test.getStandardPricebookId(), p2.Id, 1500.00 );
    insert pbe;
    
    
    OpportunityLineItem lineItem = NI_TestClassData.CreateTestOpportunityLineItem( 1,opp.Id,  pbe.Id,10 );
    insert lineItem;
    OpportunityLineItem lineItem2 = NI_TestClassData.CreateTestOpportunityLineItem( 2,opp.Id, pbe.Id,10 );
    insert lineItem2;
    Test.StopTest(); 
    
    //Set the current page
    PageReference pageRef = Page.CreateServiceOrder;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('OppId', opp.Id);
  
    // Instantiate a new controller with all parameters in the page
    NI_CreateServiceOrder controller = new NI_CreateServiceOrder();
    
    //Contract
    controller.setSelectedContract( contractTerms.Id );
    string contractId = controller.getSelectedContract();
    System.assertEquals( contractTerms.Id, contractId );
    controller.setSelectedOrderType( 'Initial');
    
    //Opportunity
    Opportunity opportunity = controller.getOpportunity();
    System.assertEquals( opp.Id, opportunity.Id );
   
    //Products, Contracts, Orgs
     List<NI_CreateServiceOrder.selectedProducts> products = controller.getProducts();
     products[1].quantityToOrder = 1;
    
    
    controller.getContractOptions();
    controller.getOrgOptions();
    
    controller.setSelectedOrg( orgDetails.Org_ID__c);
    string orgDetailsId = controller.getSelectedOrg();
    System.assertEquals( orgDetails.Org_ID__c, orgDetailsId );

    
    controller.setServiceOrderCase( c.Id );
    Id caseId = controller.getServiceOrderCase();
    System.assertEquals( c.Id, caseId);
    
    controller.setServiceOrderNIDate( date.Today());
    Date NIDate = controller.getServiceOrderNIDate();
    System.assertEquals( date.Today(), NIDate );
    
    controller.setServiceOrderCustDate( date.Today());
    Date CustDate = controller.getServiceOrderCustDate();
    System.assertEquals( date.Today(), CustDate );
    
    Note soNote = controller.soNote;
    soNote.Body = 'Test';
    controller.CreateServiceOrder();
   
  
   
}

//Initial embedded plus - Tests an inital order for Embedded Plus Licenses
public static testMethod void NI_CreateServiceOrderTestInitialEmbeddedPlus() 
{
   
    Account a = [SELECT Id, Name FROM Account WHERE Name='Apex Test Account for Auto SO' LIMIT 1];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :a.Id];
    
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbeddedPlus = [ SELECT ID From CHANNEL_ORDERS__Partner_Product_Catalog__c Where CHANNEL_ORDERS__Product_ID__c = 'NMKT-EMD-PLS-HRM-ADM-PART' LIMIT 1];
    
    Product_Group__c pg = [SELECT ID FROM Product_Group__c WHERE Name = 'HRM' LIMIT 1];
    CHANNEL_ORDERS__Partner_Contract_Terms__c  contractTerms = [SELECT ID FROM CHANNEL_ORDERS__Partner_Contract_Terms__c WHERE Name = 'Apex Test Term' LIMIT 1];
    Case c = [SELECT ID FROM Case where Subject = 'Apex Test Case for Auto SO' LIMIT 1];
    
    NI_Org_Details__c orgDetails = [ SELECT ID, Org_Id__c, License_type__c, Org_Status__c FROM NI_Org_Details__C Where ORG_ID__C = '00D00000000abce' LIMIT 1];
    orgDetails.License_Type__c = 'Embedded Plus';
    orgDetails.Org_Status__c = 'In Process';
  
    upsert orgDetails;
    
    Test.StartTest();     
   
    upsert opp;
    Product2 p2 =  CreateProduct2ForServiceOrder( sfdcProductEmbeddedPlus.Id, pg, 1 );
    insert p2;
    PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry( Test.getStandardPricebookId(), p2.Id, 1500.00 );
    insert pbe;
    
    
    OpportunityLineItem lineItem = NI_TestClassData.CreateTestOpportunityLineItem( 1,opp.Id,  pbe.Id,10 );
    insert lineItem;
    OpportunityLineItem lineItem2 = NI_TestClassData.CreateTestOpportunityLineItem( 2,opp.Id, pbe.Id,10 );
    insert lineItem2;
    Test.StopTest(); 
    
    //Set the current page
    PageReference pageRef = Page.CreateServiceOrder;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('OppId', opp.Id);
  
    // Instantiate a new controller with all parameters in the page
    NI_CreateServiceOrder controller = new NI_CreateServiceOrder();
    
    //Contract
    controller.setSelectedContract( contractTerms.Id );
    string contractId = controller.getSelectedContract();
    System.assertEquals( contractTerms.Id, contractId );
    controller.setSelectedOrderType( 'Initial');
    
    //Opportunity
    Opportunity opportunity = controller.getOpportunity();
    System.assertEquals( opp.Id, opportunity.Id );
   
    //Products, Contracts, Orgs
     List<NI_CreateServiceOrder.selectedProducts> products = controller.getProducts();
     products[1].quantityToOrder = 1;
    
    
    controller.getContractOptions();
    controller.getOrgOptions();
    
    controller.setSelectedOrg( orgDetails.Org_ID__c);
    string orgDetailsId = controller.getSelectedOrg();
    System.assertEquals( orgDetails.Org_ID__c, orgDetailsId );
  
    
    controller.setServiceOrderCase( c.Id );
    Id caseId = controller.getServiceOrderCase();
    System.assertEquals( c.Id, caseId);
    
    controller.setServiceOrderNIDate( date.Today());
    Date NIDate = controller.getServiceOrderNIDate();
    System.assertEquals( date.Today(), NIDate );
    
    controller.setServiceOrderCustDate( date.Today());
    Date CustDate = controller.getServiceOrderCustDate();
    System.assertEquals( date.Today(), CustDate );
    
    
    controller.CreateServiceOrder();
  }



//Initial Sales Cloud - Tests an initial order for Sales Cloud licenses
public static testMethod void NI_CreateServiceOrderTestInitialSalesCloud() 
{
    
    Account a = [SELECT Id, Name FROM Account WHERE Name='Apex Test Account for Auto SO' LIMIT 1];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :a.Id];
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductSalesCloud = [ SELECT ID From CHANNEL_ORDERS__Partner_Product_Catalog__c Where CHANNEL_ORDERS__Product_ID__c = 'NMKT-SF-EE-PTR-ADM-CNX' LIMIT 1];
    
    Product_Group__c pg = [SELECT ID FROM Product_Group__c WHERE Name = 'HRM' LIMIT 1];
    CHANNEL_ORDERS__Partner_Contract_Terms__c  contractTerms = [SELECT ID FROM CHANNEL_ORDERS__Partner_Contract_Terms__c WHERE Name = 'Apex Test Term' LIMIT 1];
    Case c = [SELECT ID FROM Case where Subject = 'Apex Test Case for Auto SO' LIMIT 1];
    
    
    NI_Org_Details__c orgDetails = [ SELECT ID, Org_Id__c, License_type__c, Org_Status__c FROM NI_Org_Details__C Where ORG_ID__C = '00D00000000abce' LIMIT 1];
    orgDetails.License_Type__c = 'Sales Cloud';
    orgDetails.Org_Status__c = 'In Process';
  
    upsert orgDetails;
    CHANNEL_ORDERS__Customer__c customer = [SELECT ID, CHANNEL_ORDERS__Customer_Org_ID__c FROM CHANNEL_ORDERS__Customer__c WHERE CHANNEL_ORDERS__Customer_Org_ID__c = '00D00000000abce'];
       
    
  
    Test.StartTest();     
    upsert opp;
    
    Product2 p2 =  CreateProduct2ForServiceOrder( sfdcProductSalesCloud.Id, pg, 1 );
    insert p2;
    PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry( Test.getStandardPricebookId(), p2.Id, 1500.00 );
    insert pbe;
    
    
    OpportunityLineItem lineItem = NI_TestClassData.CreateTestOpportunityLineItem( 1,opp.Id,  pbe.Id,10 );
    insert lineItem;
    OpportunityLineItem lineItem2 = NI_TestClassData.CreateTestOpportunityLineItem( 2,opp.Id, pbe.Id,10 );
    insert lineItem2;
    Test.StopTest(); 
    
    //Set the current page
    PageReference pageRef = Page.CreateServiceOrder;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('OppId', opp.Id);
  
    // Instantiate a new controller with all parameters in the page
    NI_CreateServiceOrder controller = new NI_CreateServiceOrder();
    
    //Contract
    controller.setSelectedContract( contractTerms.Id );
    string contractId = controller.getSelectedContract();
    System.assertEquals( contractTerms.Id, contractId );
    controller.setSelectedOrderType( 'Initial');
    
    //Opportunity
    Opportunity opportunity = controller.getOpportunity();
    System.assertEquals( opp.Id, opportunity.Id );
   
    //Products, Contracts, Orgs
     List<NI_CreateServiceOrder.selectedProducts> products = controller.getProducts();
     products[1].quantityToOrder = 1;
    
    
    controller.getContractOptions();
    controller.getOrgOptions();
    
    controller.setSelectedOrg( orgDetails.Org_ID__c);
    string orgDetailsId = controller.getSelectedOrg();
    System.assertEquals( orgDetails.Org_ID__c, orgDetailsId );

    
    controller.setServiceOrderCase( c.Id );
    Id caseId = controller.getServiceOrderCase();
    System.assertEquals( c.Id, caseId);
    
    controller.setServiceOrderNIDate( date.Today());
    Date NIDate = controller.getServiceOrderNIDate();
    System.assertEquals( date.Today(), NIDate );
    
    controller.setServiceOrderCustDate( date.Today());
    Date CustDate = controller.getServiceOrderCustDate();
    System.assertEquals( date.Today(), CustDate );
    
    
    controller.CreateServiceOrder();
   
   
}



//No Org Details for associated account - tests that the code will associate the account on the opportunity to the org details record
public static testMethod void NoCustomerOrgIdTest() 
{
    
       
        Account a = NI_TestClassData.CreateTestAccount(1);
        a.Name = 'Apex Test Account Without Org Details';
        a.BillingPostalCode = '03801';
        a.BillingCountry = 'US';
        a.BillingState = 'NH';
        a.BillingStreet = '75 NH Ave';
        a.BillingCity = 'Portsmouth';
        a.Type = 'Customer';
        insert a;
       
       
       NI_Org_Details__c orgDetails = [ SELECT ID, Org_Id__c, License_type__c, Org_Status__c FROM NI_Org_Details__C Where ORG_ID__C = '00D00000000abce' LIMIT 1];
       orgDetails.License_Type__c = 'Enterprise';
       orgDetails.Org_Status__c = 'Provisioned';
       update orgDetails;
       
       
        CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEnterprise = [ SELECT ID From CHANNEL_ORDERS__Partner_Product_Catalog__c Where CHANNEL_ORDERS__Product_ID__c = 'NMKT-PLT-STD-HRM-EE' LIMIT 1];
        
        Product_Group__c pg = [SELECT ID FROM Product_Group__c WHERE Name = 'HRM' LIMIT 1];
        CHANNEL_ORDERS__Partner_Contract_Terms__c  contractTerms = [SELECT ID FROM CHANNEL_ORDERS__Partner_Contract_Terms__c WHERE Name = 'Apex Test Term' LIMIT 1];
        
        PageReference pageRef = Page.CreateServiceOrder;
        Test.setCurrentPage(pageRef);
    
        
        Test.StartTest();       
        Opportunity opp = NI_TestClassData.createTestOpportunity(1,a.Id);
        insert opp;
        
        Product2 p2 =  CreateProduct2ForServiceOrder( sfdcProductEnterprise.Id, pg, 1 );
        insert p2;
        PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry( Test.getStandardPricebookId(), p2.Id, 1500.00 );
        insert pbe;
        
        
        OpportunityLineItem lineItem = NI_TestClassData.CreateTestOpportunityLineItem(1, opp.Id,  pbe.Id,10 );
        insert lineItem;
        OpportunityLineItem lineItem2 = NI_TestClassData.CreateTEstOpportunityLineItem(2, opp.Id, pbe.Id,10 );
        insert lineItem2;
        Test.StopTest();
        
        ApexPages.currentPage().getParameters().put('OppId', opp.Id);
     
     
     
        
        // Instantiate a new controller with all parameters in the page
        NI_CreateServiceOrder controller = new NI_CreateServiceOrder();
        
        
        //Contract
        controller.setSelectedContract( contractTerms.Id );
        string contractId = controller.getSelectedContract();
        System.assertEquals( contractterms.Id, contractId );
        
        //Opportunity
        Opportunity opportunity = controller.getOpportunity();
        System.assertEquals( opp.Id, opportunity.Id );
        
          
        //Products, Contracts, Orgs
         List<NI_CreateServiceOrder.selectedProducts> products = controller.getProducts();
         products[1].quantityToOrder = 1;
        
        
        controller.getContractOptions();
        List<selectOption> orgOptions = controller.getOrgOptions();
        System.Debug( 'Org Options length ' + orgOptions.Size() );
        
        controller.setSelectedOrg( orgOptions[0].getvalue() );
        string orgDetailsId = controller.getSelectedOrg();
        System.assertEquals( orgOptions[0].getvalue(), orgDetailsId );
       
        Controller.setSelectedOrderType( 'Add-On');  
        
        controller.setServiceOrderNIDate( date.Today());
        Date NIDate = controller.getServiceOrderNIDate();
        System.assertEquals( date.Today(), NIDate );
        
        controller.setServiceOrderCustDate( date.Today());
        Date CustDate = controller.getServiceOrderCustDate();
        System.assertEquals( date.Today(), CustDate );
        
     
        controller.CreateServiceOrder();
      
 }
 
 
 
 //Cancelled Org - tests to make sure we cannot order for a cancelled org
public static testMethod void NI_CreateServiceOrderCancelledOrg() 
{
    Account a = [SELECT Id, Name FROM Account WHERE Name='Apex Test Account for Auto SO' LIMIT 1];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :a.Id];
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbedded = [ SELECT ID From CHANNEL_ORDERS__Partner_Product_Catalog__c Where CHANNEL_ORDERS__Product_ID__c = 'NMKT-PART-ADM-EE-HRM' LIMIT 1];
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEnterprise = [ SELECT ID From CHANNEL_ORDERS__Partner_Product_Catalog__c Where CHANNEL_ORDERS__Product_ID__c = 'NMKT-PLT-STD-HRM-EE' LIMIT 1];
    //
    Product_Group__c pg = [SELECT ID FROM Product_Group__c WHERE Name = 'HRM' LIMIT 1];
    CHANNEL_ORDERS__Partner_Contract_Terms__c  contractTerms = [SELECT ID FROM CHANNEL_ORDERS__Partner_Contract_Terms__c WHERE Name = 'Apex Test Term' LIMIT 1];
    Case c = [SELECT ID FROM Case where Subject = 'Apex Test Case for Auto SO' LIMIT 1];
        
  
     NI_Org_Details__c orgDetails = [ SELECT ID, Org_Id__c, License_type__c, Org_Status__c FROM NI_Org_Details__C Where ORG_ID__C = '00D00000000abce' LIMIT 1];
     orgDetails.License_Type__c = 'Embedded';
     orgDetails.Org_Id__c = '00D00000000abce';
     orgDetails.Org_Status__c = 'Cancelled';
     orgDetails.Cancellation_date__c = Date.Today();
     upsert orgDetails;
 
  
    Test.StartTest();     
    opp.Target_HRM_Org__c = orgDetails.Id;
    upsert opp;
    
    Product2 p2 =  CreateProduct2ForServiceOrder( sfdcProductEnterprise.Id, pg, 1 );
    insert p2;
    
    PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry( Test.getStandardPricebookId(), p2.Id, 1500.00 );
    insert pbe;
    
    
    OpportunityLineItem lineItem = NI_TestClassData.CreateTestOpportunityLineItem( 1, opp.Id,  pbe.Id, 10 );
    insert lineItem;
    OpportunityLineItem lineItem2 = NI_TestClassData.CreateTEstOpportunityLineItem( 2, opp.Id, pbe.Id, 10 );
    insert lineItem2;
    Test.StopTest(); 
    
    //Set the current page
    PageReference pageRef = Page.CreateServiceOrder;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('OppId', opp.Id);
  
    // Instantiate a new controller with all parameters in the page
    NI_CreateServiceOrder controller = new NI_CreateServiceOrder();
    
    //Contract
    controller.setSelectedContract( contractTerms.Id );
    string contractId = controller.getSelectedContract();
    System.assertEquals( contractTerms.Id, contractId );
    
    //Opportunity
    Opportunity opportunity = controller.getOpportunity();
    System.assertEquals( opp.Id, opportunity.Id );
   
    //Products, Contracts, Orgs
     List<NI_CreateServiceOrder.selectedProducts> products = controller.getProducts();
     products[1].quantityToOrder = 1;
   
    controller.setServiceOrderCase( c.Id );
    Id caseId = controller.getServiceOrderCase();
    System.assertEquals( c.Id, caseId);
    
    controller.setServiceOrderNIDate( date.Today());
    Date NIDate = controller.getServiceOrderNIDate();
    System.assertEquals( date.Today(), NIDate );
    
    controller.setServiceOrderCustDate( date.Today());
    Date CustDate = controller.getServiceOrderCustDate();
    System.assertEquals( date.Today(), CustDate );
    
    Controller.setSelectedOrderType( 'Add-On');
    String orderType = Controller.GetSelectedOrderType();
    System.AssertEquals( orderType, 'Add-On');
    
    controller.setSelectedOrg( orgDetails.Org_ID__c);
    string orgDetailsId = controller.getSelectedOrg();
    System.assertEquals( orgDetails.Org_ID__c, orgDetailsId );

    controller.CreateServiceOrder();
  
}

 //Quantity test - testing if user choosed more than are available to order
public static testMethod void NI_CreateServiceOrderQuantity() 
{
    Account a = [SELECT Id, Name FROM Account WHERE Name='Apex Test Account for Auto SO' LIMIT 1];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :a.Id];
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEmbedded = [ SELECT ID From CHANNEL_ORDERS__Partner_Product_Catalog__c Where CHANNEL_ORDERS__Product_ID__c = 'NMKT-PART-ADM-EE-HRM' LIMIT 1];
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEnterprise = [ SELECT ID From CHANNEL_ORDERS__Partner_Product_Catalog__c Where CHANNEL_ORDERS__Product_ID__c = 'NMKT-PLT-STD-HRM-EE' LIMIT 1];
    
    Product_Group__c pg = [SELECT ID FROM Product_Group__c WHERE Name = 'HRM' LIMIT 1];
    CHANNEL_ORDERS__Partner_Contract_Terms__c  contractTerms = [SELECT ID FROM CHANNEL_ORDERS__Partner_Contract_Terms__c WHERE Name = 'Apex Test Term' LIMIT 1];
    Case c = [SELECT ID FROM Case where Subject = 'Apex Test Case for Auto SO' LIMIT 1];
    
    NI_Org_Details__c orgDetails = [ SELECT ID, Org_Id__c, License_type__c, Org_Status__c FROM NI_Org_Details__C Where ORG_ID__C = '00D00000000abce' LIMIT 1];
 
  
    Test.StartTest();     
    opp.Target_HRM_Org__c = orgDetails.Id;
    upsert opp;
    
    Product2 p2 =  CreateProduct2ForServiceOrder( sfdcProductEnterprise.Id, pg, 1 );
    insert p2;
    
    PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry( Test.getStandardPricebookId(), p2.Id, 1500.00 );
    insert pbe;
    
    
    OpportunityLineItem lineItem = NI_TestClassData.CreateTestOpportunityLineItem( 1, opp.Id,  pbe.Id, 10 );
    insert lineItem;
    OpportunityLineItem lineItem2 = NI_TestClassData.CreateTEstOpportunityLineItem( 2, opp.Id, pbe.Id, 10 );
    insert lineItem2;
    Test.StopTest(); 
    
    //Set the current page
    PageReference pageRef = Page.CreateServiceOrder;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('OppId', opp.Id);
  
    // Instantiate a new controller with all parameters in the page
    NI_CreateServiceOrder controller = new NI_CreateServiceOrder();
    
    //Contract
    controller.setSelectedContract( contractTerms.Id );
    string contractId = controller.getSelectedContract();
    System.assertEquals( contractTerms.Id, contractId );
    
    //Opportunity
    Opportunity opportunity = controller.getOpportunity();
    System.assertEquals( opp.Id, opportunity.Id );
   
    //Products, Contracts, Orgs
     List<NI_CreateServiceOrder.selectedProducts> products = controller.getProducts();
     products[1].quantityToOrder = 100;
   
    controller.setServiceOrderCase( c.Id );
    Id caseId = controller.getServiceOrderCase();
    System.assertEquals( c.Id, caseId);
    
    controller.setServiceOrderNIDate( date.Today());
    Date NIDate = controller.getServiceOrderNIDate();
    System.assertEquals( date.Today(), NIDate );
    
    controller.setServiceOrderCustDate( date.Today());
    Date CustDate = controller.getServiceOrderCustDate();
    System.assertEquals( date.Today(), CustDate );
    
    Controller.setSelectedOrderType( 'Add-On');
    String orderType = Controller.GetSelectedOrderType();
    System.AssertEquals( orderType, 'Add-On');
    
    controller.setSelectedOrg( orgDetails.Org_ID__c);
    string orgDetailsId = controller.getSelectedOrg();
    System.assertEquals( orgDetails.Org_ID__c, orgDetailsId );
   
    controller.CreateServiceOrder();
  
}

///Add-On Order but not yet provisioned - Tests that you cannot create an add-on order for an org that has note yet been provisioned
public static testMethod void NI_CreateServiceOrderTestAddOnnTrial() 
{

    Account a = [SELECT Id, Name FROM Account WHERE Name='Apex Test Account for Auto SO' LIMIT 1];
    Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :a.Id];
    CHANNEL_ORDERS__Partner_Product_Catalog__c sfdcProductEnterprise = [ SELECT ID From CHANNEL_ORDERS__Partner_Product_Catalog__c Where CHANNEL_ORDERS__Product_ID__c = 'NMKT-PLT-STD-HRM-EE' LIMIT 1];
    
    Product_Group__c pg = [SELECT ID FROM Product_Group__c WHERE Name = 'HRM' LIMIT 1];
    CHANNEL_ORDERS__Partner_Contract_Terms__c  contractTerms = [SELECT ID FROM CHANNEL_ORDERS__Partner_Contract_Terms__c WHERE Name = 'Apex Test Term' LIMIT 1];
    Case c = [SELECT ID FROM Case where Subject = 'Apex Test Case for Auto SO' LIMIT 1];

    
    
    NI_Org_Details__c orgDetails = [ SELECT ID, Org_Id__c, License_type__c, Org_Status__c FROM NI_Org_Details__C Where ORG_ID__C = '00D00000000abce' LIMIT 1];
    orgDetails.License_Type__c = 'Enterprise';
    orgDetails.Org_Status__c = 'Trial';
    upsert orgDetails;
    
    CHANNEL_ORDERS__Customer__c customer = [SELECT ID, CHANNEL_ORDERS__Customer_Org_ID__c FROM CHANNEL_ORDERS__Customer__c WHERE CHANNEL_ORDERS__Customer_Org_ID__c = '00D00000000abce'];
    
    
    
    Test.StartTest();     
   
    opp.Target_HRM_Org__c = orgDetails.Id;
    upsert opp;
    
  
    Product2 p2 =  CreateProduct2ForServiceOrder( sfdcProductEnterprise.Id, pg, 1 );
    insert p2;
    
    PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry( Test.getStandardPricebookId(), p2.Id, 1500.00 );
    insert pbe;
    
    
    OpportunityLineItem lineItem = NI_TestClassData.CreateTestOpportunityLineItem( 1, opp.Id,  pbe.Id, 10 );
    insert lineItem;
    OpportunityLineItem lineItem2 = NI_TestClassData.CreateTEstOpportunityLineItem( 2, opp.Id, pbe.Id, 10 );
    insert lineItem2;
    Test.StopTest(); 
    
    //Set the current page
    PageReference pageRef = Page.CreateServiceOrder;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('OppId', opp.Id);
  
    // Instantiate a new controller with all parameters in the page
    NI_CreateServiceOrder controller = new NI_CreateServiceOrder();
    
    //Contract
    controller.setSelectedContract( contractTerms.Id );
    string contractId = controller.getSelectedContract();
    System.assertEquals( contractTerms.Id, contractId );
    
    //Opportunity
    Opportunity opportunity = controller.getOpportunity();
    System.assertEquals( opp.Id, opportunity.Id );
   
    //Products, Contracts, Orgs
     List<NI_CreateServiceOrder.selectedProducts> products = controller.getProducts();
     products[1].quantityToOrder = 1;
    
    
    controller.getContractOptions();
    controller.getOrgOptions();
    controller.getOrderTypeOptions();
    
   
    controller.setServiceOrderCase( c.Id );
    Id caseId = controller.getServiceOrderCase();
    System.assertEquals( c.Id, caseId);
    
    controller.setServiceOrderNIDate( date.Today());
    Date NIDate = controller.getServiceOrderNIDate();
    System.assertEquals( date.Today(), NIDate );
    
    controller.setServiceOrderCustDate( date.Today());
    Date CustDate = controller.getServiceOrderCustDate();
    System.assertEquals( date.Today(), CustDate );
    
    Controller.setSelectedOrderType( 'Add-On');
    String orderType = Controller.GetSelectedOrderType();
    System.AssertEquals( orderType, 'Add-On');
    
    controller.setSelectedOrg( orgDetails.Org_ID__c);
    string orgDetailsId = controller.getSelectedOrg();
    System.assertEquals( orgDetails.Org_ID__c, orgDetailsId );

    
  
    //With Org Details
    controller.CreateServiceOrder();
  
}





//Creates a Salesforce Product Catalog record 
public static  CHANNEL_ORDERS__Partner_Product_Catalog__c  CreateProductCatalog( CHANNEL_ORDERS__Partner_Contract_Terms__c terms, String ProductId )
{
     CHANNEL_ORDERS__Partner_Product_Catalog__c product = new CHANNEL_ORDERS__Partner_Product_Catalog__c();
     product.Name = 'Apex Test Product';
     product.CHANNEL_ORDERS__Product_ID__c = ProductId;
     product.CHANNEL_ORDERS__Partner_Contract_Terms__c = terms.id;
     
     if( ProductId.Contains('EMD') )
     {
         product.CHANNEL_ORDERS__PNR__c = 10.00;
         product.CHANNEL_ORDERS__Pricing_Type__c = 'PNR';
         product.CHANNEL_ORDERS__Floor_Price__c = 10.00;
         product.CHANNEL_ORDERS__Pricing_Unit__c = 'User';
     }
     else
     {
         product.CHANNEL_ORDERS__Pricing_Type__c = 'FIXED';
         product.CHANNEL_ORDERS__Fixed_Price__c = 10.00;
         product.CHANNEL_ORDERS__Floor_Price__c = 10.00;
         product.CHANNEL_ORDERS__Pricing_Unit__c = 'User';
     }
    
     return product;   
}


//Creates a Product2 record specifically for Service Order Testing.
  public static Product2 CreateProduct2ForServiceOrder( Id sfdcProductId, Product_Group__c pg, Integer iRecordNumber)
    {
        
        Product2 p2 = new Product2();
        p2.Product_Group__c = pg.Id;
        p2.Product_Line__c = 'HRM Test';
        p2.Revenue_Category__c = 'Services';
        p2.Corporate_Product_Group__c = 'Newmarket';
        p2.Unit__c = 'Subscription';
        p2.IsActive = true;
        p2.ProductCode = 'HRMTEST' + iRecordNumber;
        p2.Description = 'APEX Test Class';
        p2.Family = 'HRM';
        p2.Name = 'Embrace';
        p2.Partner_Product_Catalog__c = sfdcProductId;
      
        return p2;
    }
    
 //Creates the Custom Settings
 public static void CreateServiceOrderCustomSettings()
 {
 
  Service_Order_Settings__c soSettings;
  soSettings = Service_Order_Settings__c.getValues('AdminLicenseCodes');
  if( soSettings == null )
  {
      soSettings = new Service_Order_Settings__c();
      soSettings.Name = 'AdminLicenseCodes';
      soSettings.Embedded_Customer_Admin__c ='NMKT-EMD-ADM-EE-HRM';
      soSettings.Embedded_Partner_Admin__c ='NMKT-PART-ADM-EE-HRM';
      soSettings.Enterprise_Customer_Admin__c ='NMKT-PLT-ADM-HRM-EE';
      soSettings.Enterprise_Partner_Admin__c ='NMKT-PTR-ADM-HRM-EE';
      soSettings.Sales_Cloud_Customer_Admin__c ='NMKT-SF-EE-ADM-CNX';
      soSettings.Sales_Cloud_Partner_Admin__c ='NMKT-SF-EE-PTR-ADM-CNX';
      soSettings.Number_of_Customer_Admins__c  =1;
      soSettings.Number_of_Partner_Admins__c = 2;
      soSettings.License_Types__c ='Embedded, EMD-STD\r\nEmbedded Plus, EMD-PLS\r\nEnterprise, PLT\r\nSales Cloud,CNX\r\n';
      soSettings.Embedded_Plus_Customer_Admin__c ='NMKT-EMD-PLS-HRM-ADM';
      soSettings.Embedded_Plus_Partner_Admin__c ='NMKT-EMD-PLS-HRM-ADM-PART';
      soSettings.Default_Contract__c = 'Apex Test Term';
      Database.insert( soSettings );
  }
  
 }
    
 }