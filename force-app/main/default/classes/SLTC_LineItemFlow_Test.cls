/**********************************************************
*************************************
Name 				: SLTC_LineItemFlow_Test 
Author 				: Srividya G
Created Date 		: 11/28/22
Last Mod Date 		: 11/28/22
Last Mod By 		: Srividya G
NICC Reference 		: 
Description 		: Test class to test SLTC Line Item Flow
***********************************************************
*************************************/
@istest
public class SLTC_LineItemFlow_Test {
    //Create test data
	@testSetup static void setup(){
            List<User> user_data = new List<User>();
            user_data.Add(SLTC_TestDataFactory.createuser('SLTC Sales','Business Development','Manager','WWSales'));
            INSERT user_data;        
            List<PermissionSet> requirePermission_data = new List<PermissionSet>();
            List<PermissionSetAssignment> permissionassignment_data= new List<PermissionSetAssignment>();
            System.runAs(new User(Id=UserInfo.getUserId())){
            //stop running old legacy trigger code and Assign the Required permission set to user.
            INSERT new NI_TriggerBypassSwitches__c(Name ='Bypass Control Panel', BypassOpportunity_ON__c = true, BypassAccount_ON__c = true, Bypass_AH_Opportunity_Related_Account__c = true, Bypass_Contact__c = true,BypassContactSunsetContact__c =true);
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Contact_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Opportunity_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Account_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Proposal_Create_View_Modify'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTCCPQFullUser'));
            //requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Bypass_Permission'));    
            for(PermissionSet ps: requirePermission_data){
                permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[0].id, PermissionSetId = ps.Id));
            }
            INSERT permissionassignment_data;
            }
            System.runAs(user_data[0]){
            List<Account> account_data = SLTC_TestDataFactory.createAccounts('Request','Test','MDM Approved', 'SLTC_Property', 'Preliminary',1);
            INSERT account_data;
                
            List<Contact> contact_data = SLTC_TestDataFactory.createcontact('firstcontact', 'Contact', account_data[0].Id,1);
            contact_data.addAll(SLTC_TestDataFactory.createcontact('secondcontact_data', 'Contact', account_data[0].Id,1));
            contact_data.addAll(SLTC_TestDataFactory.createcontact('thridcontact_data', 'Contact', account_data[0].Id,1));
            contact_data.addAll(SLTC_TestDataFactory.createcontact('fourthcontact_data', 'Contact', account_data[0].Id,1));
            INSERT contact_data;
        	
            CurrencyType liCT = new CurrencyType();
            liCT.IsoCode='USD';
            liCT.isActive=TRUE;
            
            List<Opportunity> opportunity_data = SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', account_data[0], 1, 'SLTC_Opportunity');
            opportunity_data.addAll(SLTC_TestDataFactory.createopportunity('Initial Interest', 'Amendment', account_data[0], 1, 'SLTC_Opportunity'));
            //INSERT opportunity_data;
            opportunity_data[0].CurrencyIsoCode = liCT.IsoCode;
            opportunity_data[1].CurrencyIsoCode = liCT.IsoCode;
            INSERT opportunity_data;
            
            //New Price List
            Apttus_Config2__PriceList__c price_list = new Apttus_Config2__PriceList__c();
            price_list.Name = 'Global US Pricelist';
            price_list.Apttus_Config2__Type__c = 'Standard';
            price_list.Apttus_Config2__Active__c = true;
            price_list.CurrencyIsoCode = liCT.IsoCode;
            INSERT price_list;
            
            //New Bussiness proposal
            Apttus_Proposal__Proposal__c proposal_data1 = SLTC_TestDataFactory.createProposal(account_data[0].Id, contact_data[0].Id, opportunity_data[0].Id, 'Proposal'); 
           //INSERT proposal_data1;  
            proposal_data1.Apttus_Proposal__Approval_Stage__c = 'Draft';
            proposal_data1.SLTC_Type_of_Invoice__c = 'Ind to Corp';
            proposal_data1.SLTC_Renewal_Period__c = 12;
            proposal_data1.CurrencyIsoCode = liCT.IsoCode;
            proposal_data1.Apttus_Proposal__ExpectedEndDate__c =System.today().addYears(1);
            proposal_data1.Apttus_Proposal__ExpectedStartDate__c =System.today();
            INSERT proposal_data1;
                
            Apttus_Proposal__Proposal__c proposal_data2 = SLTC_TestDataFactory.createProposal(account_data[0].Id, contact_data[0].Id, opportunity_data[0].Id, 'Proposal'); 
            //INSERT proposal_data2;  
            proposal_data2.Apttus_Proposal__Approval_Stage__c = 'Draft';
            proposal_data2.SLTC_Type_of_Invoice__c = 'Ind to Ind';
            proposal_data2.SLTC_Renewal_Period__c = 12;
            proposal_data2.CurrencyIsoCode = liCT.IsoCode;
            proposal_data2.Apttus_Proposal__ExpectedEndDate__c =System.today().addYears(1);
            proposal_data2.Apttus_Proposal__ExpectedStartDate__c =System.today();
            INSERT proposal_data2;
                
            Apttus_Proposal__Proposal__c proposal_data3 = SLTC_TestDataFactory.createProposal(account_data[0].Id, contact_data[0].Id, opportunity_data[0].Id, 'Proposal'); 
            //INSERT proposal_data3;  
            proposal_data3.Apttus_Proposal__Approval_Stage__c = 'Draft';
            proposal_data3.SLTC_Type_of_Invoice__c = 'Corp to Corp';
            proposal_data3.SLTC_Renewal_Period__c = 12;
            proposal_data3.CurrencyIsoCode = liCT.IsoCode;
            proposal_data3.Apttus_Proposal__ExpectedEndDate__c =System.today().addYears(1);
            proposal_data3.Apttus_Proposal__ExpectedStartDate__c =System.today();
            INSERT proposal_data3;
            
            //New Products
            List<Product2> product = SLTC_TestDataFactory.createProduct('SLTC',1);
            product.addAll(SLTC_TestDataFactory.createProduct('Media',1));
            INSERT product;
			
            Id standardPB = Test.getStandardPricebookId();
            
            PricebookEntry pbe = new PricebookEntry();
            pbe.IsActive = true;
            pbe.Product2ID = product[0].Id;
            pbe.Pricebook2Id = standardPB;
            pbe.UnitPrice = 200;        
            insert pbe;
                
            //New PLI    
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c();
            pli.Apttus_Config2__ProductId__c = product[0].id;
            pli.Apttus_Config2__PriceListId__c = price_list.id;
            pli.Apttus_Config2__ListPrice__c = 545;
            pli.CurrencyIsoCode = liCT.IsoCode;
            pli.Apttus_Config2__ChargeType__c = 'Standard Price';
            pli.Apttus_Config2__PriceType__c = 'One Time';
            pli.Apttus_Config2__PriceMethod__c = 'Per Unit';
            pli.Apttus_Config2__PriceUom__c = 'Each';
            pli.Apttus_Config2__Active__c = true;
            INSERT pli;
                
            //New Brand
            SLTC_Brand__c brand = SLTC_TestDataFactory.createBrandOnAccount(account_data[0].Id,'Brand');
            INSERT brand;

            //Contracted Discount
            SLTC_Contracted_Discount__c contract_discount = new SLTC_Contracted_Discount__c();
            contract_discount.SLTC_Brand__c = 'Test';
            contract_discount.SLTC_Product_Sku__c = product[0].productCode;
            INSERT contract_discount;
            
            //Product Configuration
            Apttus_Config2__ProductConfiguration__c prod_config = new Apttus_Config2__ProductConfiguration__c();
            prod_config.Apttus_QPConfig__Proposald__c = proposal_data1.id;
            prod_config.Name = 'Test product configuration';
            prod_config.CurrencyIsoCode = liCT.IsoCode;
            prod_config.Apttus_Config2__PriceListId__c = price_list.id;
            prod_config.Apttus_Config2__SummaryGroupType__c = 'Category';
            prod_config.Apttus_Config2__EffectiveDate__c = proposal_data1.Apttus_Proposal__ExpectedStartDate__c;
            prod_config.Apttus_Config2__ExpectedStartDate__c = proposal_data1.Apttus_Proposal__ExpectedStartDate__c;
            prod_config.Apttus_Config2__ExpectedEndDate__c = proposal_data1.Apttus_Proposal__ExpectedEndDate__c;
            prod_config.Apttus_Config2__EffectivePriceListId__c = price_list.id;
            INSERT prod_config;
                
            Apttus_Config2__ProductConfiguration__c prod_config1 = new Apttus_Config2__ProductConfiguration__c();
            prod_config1.Apttus_QPConfig__Proposald__c = proposal_data2.id;
            prod_config1.Name = 'Test product configuration1';  
            prod_config1.CurrencyIsoCode = liCT.IsoCode;
            prod_config1.Apttus_Config2__PriceListId__c = price_list.id;
            prod_config1.Apttus_Config2__SummaryGroupType__c = 'Category';
            prod_config1.Apttus_Config2__EffectiveDate__c = proposal_data1.Apttus_Proposal__ExpectedStartDate__c;
            prod_config1.Apttus_Config2__ExpectedStartDate__c = proposal_data1.Apttus_Proposal__ExpectedStartDate__c;
            prod_config1.Apttus_Config2__ExpectedEndDate__c = proposal_data1.Apttus_Proposal__ExpectedEndDate__c;
            prod_config1.Apttus_Config2__EffectivePriceListId__c = price_list.id;
            INSERT prod_config1;
                
            Apttus_Config2__ProductConfiguration__c prod_config2 = new Apttus_Config2__ProductConfiguration__c();
            prod_config2.Apttus_QPConfig__Proposald__c = proposal_data3.id;
            prod_config2.Name = 'Test product configuration2'; 
            prod_config2.CurrencyIsoCode = liCT.IsoCode;
            prod_config2.Apttus_Config2__PriceListId__c = price_list.id;
            prod_config2.Apttus_Config2__SummaryGroupType__c = 'Category';
            prod_config2.Apttus_Config2__EffectiveDate__c = proposal_data1.Apttus_Proposal__ExpectedStartDate__c;
            prod_config2.Apttus_Config2__ExpectedStartDate__c = proposal_data1.Apttus_Proposal__ExpectedStartDate__c;
            prod_config2.Apttus_Config2__ExpectedEndDate__c = proposal_data1.Apttus_Proposal__ExpectedEndDate__c;
            prod_config2.Apttus_Config2__EffectivePriceListId__c = price_list.id;
            INSERT prod_config2;
            
            
        }
    }
    
    //Test for Quote invoice type Ind to Corp
    @isTest static void indToCorpMethodTest(){
            User Salesrep_user = [SELECT Id FROM User WHERE FirstName='Business Development' limit 1];
			List<Product2> product = [SELECT Id,Name FROM Product2 where Name = 'SLTC Product'];
            
			Apttus_Proposal__Proposal__c proposalId = [SELECT Id,Name,SLTC_Type_of_Invoice__c,Apttus_Proposal__Account__c FROM Apttus_Proposal__Proposal__c WHERE SLTC_Type_of_Invoice__c = 'Ind to Corp'];
          Apttus_Config2__ProductConfiguration__c prodConfig = [SELECT id, Name,Apttus_QPConfig__Proposald__c FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_QPConfig__Proposald__c =: proposalId.Id];    
         System.runAs(Salesrep_user){ 
            Test.startTest();    
            List<Apttus_Proposal__Proposal_Line_Item__c> ProposalLI = SLTC_TestDataFactory.createProposalLineItem(proposalId.Id, product, 'New');
             INSERT ProposalLI;
	 		Apttus_Config2__LineItem__c configLineItem = new Apttus_Config2__LineItem__c();
             configLineItem.Apttus_Config2__ItemSequence__c = 1;
              configLineItem.Apttus_Config2__LineNumber__c	 = 1;
              configLineItem.Apttus_Config2__ProductId__c = product[0].id;
             configLineItem.Apttus_Config2__ConfigurationId__c = prodConfig.id;
             insert configLineItem;
            
            System.assertEquals('Ind to Corp',proposalId.SLTC_Type_of_Invoice__c);
            Test.stopTest();
            }
    }
    
    //Test for Quote invoice type Ind to Ind
    @isTest static void indToIndMethodTest(){
            User Salesrep_user = [SELECT Id FROM User WHERE FirstName='Business Development' limit 1];
			List<Product2> product = [SELECT Id,Name FROM Product2 where Name = 'SLTC Product'];
			Apttus_Proposal__Proposal__c proposalId = [SELECT Id,Name,SLTC_Type_of_Invoice__c FROM Apttus_Proposal__Proposal__c WHERE SLTC_Type_of_Invoice__c = 'Ind to Ind'];
            System.runAs(Salesrep_user){
            Test.startTest();    
            List<Apttus_Proposal__Proposal_Line_Item__c> ProposalLI = SLTC_TestDataFactory.createProposalLineItem(proposalId.Id, product, 'New');
            INSERT ProposalLI;
            System.assertEquals('Ind to Ind',proposalId.SLTC_Type_of_Invoice__c);
            Test.stopTest();
            }
    }
    
    //Test for Quote invoice type Corp to Corp
        @isTest static void corpToCorpMethodTest(){
            User Salesrep_user = [SELECT Id FROM User WHERE FirstName='Business Development' limit 1];
			List<Product2> product = [SELECT Id,Name FROM Product2 where Name = 'SLTC Product'];
			Apttus_Proposal__Proposal__c proposalId = [SELECT Id,Name,SLTC_Type_of_Invoice__c FROM Apttus_Proposal__Proposal__c WHERE SLTC_Type_of_Invoice__c = 'Corp to Corp'];
            System.runAs(Salesrep_user){
            Test.startTest();    
            List<Apttus_Proposal__Proposal_Line_Item__c> ProposalLI = SLTC_TestDataFactory.createProposalLineItem(proposalId.Id, product, 'New');
            INSERT ProposalLI;
            System.assertEquals('Corp to Corp',proposalId.SLTC_Type_of_Invoice__c);
            Test.stopTest();
            }
    }

}