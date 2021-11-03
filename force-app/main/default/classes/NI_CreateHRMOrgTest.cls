/****************************************************************************************
Name            : NI_CreateHRMOrgTest Class 
Author          : Suzanne LeDuc
Created Date    : 11/03/2015 
Last Mod Date   : 05/03/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Tests NI_CreateHRMOrg
                :  
                : 
                : 
******************************************************************************************/
@isTest                                      
public class NI_CreateHRMOrgTest 
{

    public static testMethod void NI_CreateHRMOrgTest() 
    {
        
        // SETUP THE DATA NEEDED FOR THE TEST
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.StopTest();
        
        CreateHRMSettings();
        
        Account a = NI_TestClassData.CreateTestAccount(1);
        a.Name = 'Apex Test Account for Auto SO';
        a.BillingPostalCode = '03801';
        a.BillingCountry = 'US';
        a.BillingState = 'NH';
        a.BillingStreet = '75 NH Ave';
        a.BillingCity = 'Portsmouth';
        a.Type = 'Customer';
        insert a;
        
        Opportunity opp = NI_TestClassData.createTestOpportunity(1, a.Id);
        insert opp;
        
        Contact cntct = NI_TestClassData.createTestContact(1, a.Id);
        insert cntct;
        
        OpportunityContactRole contactRole = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Customer Project Contact');    
        insert contactRole;       
        
        Product_Group__c pg = NI_TestClassData.createProductGroup(1, 'HRM');
        insert pg;        
        
        Product2 p2 = NI_TestClassData.createProduct2(1, pg.Id, 'APEX-TEST-087', 'Subscription'); 
        p2.Product_Line__c = 'HRM Test';
        p2.Revenue_Category__c = 'Services';
        p2.Corporate_Product_Group__c = 'Newmarket';
        p2.Unit__c = 'Subscription';
        p2.IsActive = true;
        p2.ProductCode = 'HRMTEST';
        p2.Description = 'APEX Test Class';
        p2.Family = 'HRM';
        p2.Name = 'Embrace';
        p2.Salesforce_com_Subscription_Type__c = 'Enterprise';
        insert p2;
        
        PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry(Test.getStandardPricebookId(), p2.Id, 1500.00);
        insert pbe;        
        
        OpportunityLineItem lineItem = NI_TestClassData.CreateTestOpportunityLineItem(1, opp.Id, pbe.Id, 10);
        insert lineItem;
        
        // CREATE SOME TEMPLATES
        HRM_Template__c template1 = new HRM_Template__c();
        template1.Name = 'Standard';
        template1.Template_Id__c = '0TTi0000003MCWl'; 
        insert template1;
        
        HRM_Template__c template2 = new HRM_Template__c();
        template2.Name = 'EMEA';
        template2.Template_Id__c = '0TTi0000003cbjv';
        insert template2;        
        
        List<HRM_Template__c> lstHRMTemplates = new List<HRM_Template__c>([SELECT Id, Name, Template_Id__c FROM HRM_Template__c]);
        system.assertEquals(2, lstHRMTemplates.size());
        
        // SET THE CURRENT PAGE AND PUT THE OPPORTUNITY ID
        PageReference pageRef = Page.NI_Create_HRM_Org;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('OppId', opp.Id);
        
        // INSTANTIATE THE CLASS 
        NI_CreateHRMORg controller = new NI_CreateHRMOrg();
        
        // MAKE SURE THE OPP IS SET CORRECTLY 
        Opportunity o = controller.getOpportunity();
        System.AssertEquals( o.Id,opp.Id ); 

        // SET THE TEMPLATE
        List<System.SelectOption> tOptions = controller.templateOptions;     
        controller.selectedTemplate = tOptions[1].getValue();
      
        // GET THE PICKLISTS     
        list<SelectOption> currOptions = controller.currencyOptions;
        list<SelectOption> tzOptions = controller.timeZoneOptions;
        
        // SETUP VALUES FOR THE ORG
        NI_Org_Details__c org = controller.orgDetails;
        org.License_Type__C = 'Enterprise';
        org.AdminLoginName__c = 'Test@newmarketinc.com';
        
        // CREATE THE ORG
        controller.CreateOrg();

        // TEST THE SAVE ORG DETAILS METHOD
        controller.SaveOrgDetailsRecord( '00D610000007PcZ' );
        NI_Org_Details__c orgDetails = controller.getOrgDetails();
        System.assertEquals( orgDetails.Org_Id__c, '00D610000007PcZ' );
        
        // CREATE THE CASE
        controller.CreateCase();
        
    }
    
    public static testMethod void NI_CreateHRMOrgNegativeTest() 
    {
        
        // SETUP THE DATA
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.StopTest();
        
        CreateHRMSettings();
        
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        Opportunity opp = NI_TestClassData.createTestOpportunity(1,a.Id);
        insert opp;
        
        // SET THE CURRENT PAGE
        PageReference pageRef = Page.NI_Create_HRM_Org;
        Test.setCurrentPage(pageRef);
        
        // PUT THE OPPORTUNITY
        ApexPages.currentPage().getParameters().put('OppId', opp.Id);
        
        // INSTANTIATE THE CLASS
        NI_CreateHRMORg controller = new NI_CreateHRMOrg();
        
        // SET PICKLIST VALUES THAT WILL CAUSE IT TO FAIL
        controller.getPickListValues('test', 'test');
        controller.getPickListValues('User', 'test');
        
        // GET THE ORG DETAILS
        NI_Org_Details__c orgDetails = Controller.GetOrgDetails();
        
        // SET THE ADMIN LOGIN THAT WILL CAUSE IT TO FAIL
        orgDetails.AdminLoginName__c = 'test';
        
        // CALL CREATE ORG
        controller.createOrg();

    }
    
    // CREATES THE CUSTOM SETTINGS THAT ARE NEEDED FOR THE TEST
    public static void CreateHRMSettings()
    {
        
        NI_HRM_SignUp_Request_Settings__c hrmSettings;  
        hrmSettings = NI_HRM_SignUp_Request_Settings__c.getValues('HRMSignUpSettings');
        
        if (hrmSettings == null)
        {
            
            String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
            hrmSettings = new NI_HRM_SignUp_Request_Settings__c();
            hrmSettings.Name = 'HRMSignUpSettings';
            hrmSettings.Org_Details_Record_Type__c = 'LOD Support Admin';
            hrmSettings.SignUp_Request_Case_Owner__c = 'Q-Subscription Management';
            hrmSettings.SignUp_Request_Email__c = 'sleduc@newmarketinc.com';
            hrmSettings.Org_Details_Record_Type__c = 'LOD Support Admin';
            hrmSettings.SignUp_Request_Case_Owner__c = 'Q-Subscription Management';
            hrmSettings.SignUp_Request_Email__c = 'sleduc@newmarketinc.com';
            hrmSettings.SignUp_Request_Get_URL__c = '/services/data/v27.0/sobjects/SignupRequest/Id/';
            hrmSettings.SignUp_Request_URL__c = '/services/data/v27.0/sobjects/SignupRequest/';
            hrmSettings.TSO_Auth_Endpoint__c = baseURL + '/services/oauth2/token';
            hrmSettings.TSO_ClientId__c = '3MVG9A2kN3Bn17hvDn2BxxKxE65ay9FYQN6yXlry_Lt_Us2_bg8DS.VdNEPBXrrOAfGHv7tIPkkb0hZ4C.EpB';
            hrmSettings.TSO_Client_Secret__c = '4548215696913861118';
            hrmSettings.TSO_Password__c = '0llieRocks!AUnWGPWdQ7mgFV1uOx1uX5gn';
            hrmSettings.TSO_Server__c = baseURL;
            hrmSettings.TSO_User_Name__c = 'sleduc@trialforcemanagement.org';
            hrmSettings.TSO_Templates__c = '0TTi0000003UUzM,Standard';
            Database.insert(hrmSettings);
            
        }
    }
    
    public static CHANNEL_ORDERS__Partner_Product_Catalog__c CreateProductCatalog(CHANNEL_ORDERS__Partner_Contract_Terms__c terms, String ProductId)
    {
        
        CHANNEL_ORDERS__Partner_Product_Catalog__c product = new CHANNEL_ORDERS__Partner_Product_Catalog__c();
        product.Name = 'Apex Test Product';
        product.CHANNEL_ORDERS__Product_ID__c = ProductId;
        product.CHANNEL_ORDERS__Partner_Contract_Terms__c = terms.id;
        
        if (ProductId.Contains('EMD'))
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
    
    public static Product2 CreateProduct2ForServiceOrder(Id sfdcProductId, Product_Group__c pg, Integer iRecordNumber)
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

}