/******************************************************************************************
******************************
Name 			: SLTC_AssetLineItemTriggerHandler_Test
Author 			: Srividya
Created Date 	: 6/12/22
Last Mod Date 	: 01/12/23
Last Mod By 	: Japtej Lamba
NICC Reference 	: 
Description 	: Test class for SLTC_AssetLineItemTriggerHandler
*******************************************************************************************
*******************************/
@isTest
public class SLTC_AssetLineItemTriggerHandler_Test {
    
    @testSetup static void createTestData(){
        
        List<User> user_data = new List<User>();
        user_data.add(SLTC_TestDataFactory.createuser('SLTC Sales','Business Development','Manager','WWSales'));
        INSERT user_data; 

        
        // PermissionSet Creation
        List<PermissionSet> requirePermission_data = new List<PermissionSet>();
        List<PermissionSetAssignment> permissionassignment_data= new List<PermissionSetAssignment>();
        System.runAs(new User(Id=UserInfo.getUserId())){
            INSERT new NI_TriggerBypassSwitches__c(Name ='Bypass Control Panel', BypassOpportunity_ON__c = true, BypassAccount_ON__c = true, Bypass_AH_Opportunity_Related_Account__c = true, Bypass_Contact__c = true, BypassContactSunsetContact__c =true, BypassApttusAgreement_ON__c = true);
        
            //stop running old legacy trigger code and Assign the Required permission set to user.
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Opportunity_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Account_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Bypass_Permission'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTCCPQFullUser'));
            for(PermissionSet ps: requirePermission_data){
                permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[0].id, PermissionSetId = ps.Id));
            }
            INSERT permissionassignment_data;
        }
        System.runAs(user_data[0]){
            // New Account
            List<Account> account_data = SLTC_TestDataFactory.createAccounts('Request','Test','MDM Approved', 'SLTC_Property', 'Preliminary',1);
            INSERT account_data; 
            
            List<Contact> contact_data = SLTC_TestDataFactory.createcontact('firstcontact', 'Contact', account_data[0].Id,1);
            contact_data.addAll(SLTC_TestDataFactory.createcontact('secondcontact_data', 'Contact', account_data[0].Id,1));
            contact_data.addAll(SLTC_TestDataFactory.createcontact('thridcontact_data', 'Contact', account_data[0].Id,1));
            contact_data.addAll(SLTC_TestDataFactory.createcontact('fourthcontact_data', 'Contact', account_data[0].Id,1));
            INSERT contact_data;
            
            // CurrencyType
            CurrencyType liCT = new CurrencyType();
            liCT.IsoCode='USD';
            liCT.isActive=TRUE;
            
            //New Opportunity
            List<Opportunity> opportunity_data = SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', account_data[0], 1, 'SLTC_Opportunity');
            opportunity_data.addAll(SLTC_TestDataFactory.createopportunity('Initial Interest', 'Renewal', account_data[0], 1, 'SLTC_Renewal_Opportunity'));
            
            opportunity_data[0].CurrencyIsoCode = liCT.IsoCode;
            opportunity_data[1].CurrencyIsoCode = liCT.IsoCode;
            INSERT opportunity_data;
            
            //New Price List
            Apttus_Config2__PriceList__c price_list = SLTC_TestDataFactory.createPriceList();
            price_list.CurrencyIsoCode = liCT.IsoCode;
            INSERT price_list;
            
            //New Bussiness proposal
            Apttus_Proposal__Proposal__c proposal_data1 = SLTC_TestDataFactory.createProposal(account_data[0].Id, contact_data[0].Id, opportunity_data[0].Id, 'Proposal'); 
            proposal_data1.Apttus_Proposal__Approval_Stage__c = 'Accepted';
            proposal_data1.SLTC_Type_of_Invoice__c = 'Ind to Corp';
            proposal_data1.SLTC_Renewal_Period__c = 12;
            proposal_data1.CurrencyIsoCode = liCT.IsoCode;
            proposal_data1.Apttus_Proposal__ExpectedEndDate__c =System.today().addYears(1);
            proposal_data1.Apttus_Proposal__ExpectedStartDate__c =System.today();
            INSERT proposal_data1;
            
            //add proposal
            List<Apttus_Proposal__Proposal__c> proposalsList = new List<Apttus_Proposal__Proposal__c>();
            proposalsList.add(proposal_data1);
            
            List<Id> cartIds = SLTC_CommonUtils.createCart(proposalsList); 
            System.assertEquals(True, !cartIds.isEmpty());
            //Test.stopTest();
            
            //New Products
            List<Product2> product = SLTC_TestDataFactory.createProduct('SLTC',1);
            product.addAll(SLTC_TestDataFactory.createProduct('Media',1));
            INSERT product;
            
            //new PricebookEntry
            List<PricebookEntry> pbe = SLTC_TestDataFactory.createPricebookEntry(product);      
            insert pbe;
            
            //Product Configuration
            Apttus_Config2__ProductConfiguration__c prod_config= SLTC_TestDataFactory.createProductConfig(proposal_data1);
            prod_config.CurrencyIsoCode = liCT.IsoCode;
            prod_config.Apttus_Config2__PriceListId__c = price_list.id;
            prod_config.Apttus_Config2__EffectivePriceListId__c = price_list.id;
            INSERT prod_config;

            //New LineItem
            List<Apttus_Config2__LineItem__c> lineItemList = new List<Apttus_Config2__LineItem__c>();
            Apttus_Config2__LineItem__c lineItem = SLTC_TestDataFactory.createProductConfigLine(prod_config.id, product[0].id);
            lineItemList.add(lineItem);

            Apttus_Config2__LineItem__c lineItem1 = SLTC_TestDataFactory.createProductConfigLine(prod_config.id, product[1].id);
            lineItem1.Apttus_Config2__ItemSequence__c = 2;
            lineItem1.Apttus_Config2__LineNumber__c = 2;
            lineItemList.add(lineItem1);
            INSERT lineItemList;
            
            //Proposal Line Item
            List<Apttus_Proposal__Proposal_Line_Item__c> proposals = SLTC_TestDataFactory.createProposalLineItem(proposal_data1.Id, product, 'New');
            INSERT proposals;
            
            //New Bussiness Agreement
            Apttus__APTS_Agreement__c agreement_data = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data1.Id,'Order_Form'); 
            agreement_data.Apttus__Status_Category__c = 'In Effect';
            agreement_data.Apttus__Status__c = 'Activated';
            agreement_data.Apttus__Contract_End_Date__c = proposal_data1.Apttus_Proposal__ExpectedEndDate__c;
            INSERT agreement_data;
            
            //New Agreement Line Item
            List<Apttus__AgreementLineItem__c> AgreementLIList = new List<Apttus__AgreementLineItem__c>();
            Apttus__AgreementLineItem__c AgreementLI = SLTC_TestDataFactory.createAgreementLine(agreement_data.id,lineItemList[0].id);
            AgreementLIList.add(AgreementLI);
            
            Apttus__AgreementLineItem__c AgreementLI1 = SLTC_TestDataFactory.createAgreementLine(agreement_data.id,lineItemList[1].id);
            AgreementLIList.add(AgreementLI1);
            INSERT AgreementLIList;
            
            //Create Contact Roles
            List<OpportunityContactRole> contactRoleList = SLTC_TestDataFactory.createOpportunityContactRole(opportunity_data[0].Id, contact_data[0].Id,'Customer Project Contact');
            contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunity_data[0].Id, contact_data[1].Id,'Bill To'));
            contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunity_data[0].Id, contact_data[2].Id,'Sold To'));
            contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunity_data[0].Id, contact_data[3].Id,'Authorizer'));
            INSERT contactRoleList;
            
            //Update Opportunity
            opportunity_data[0].StageName = 'Closed Won';
            opportunity_data[1].SLTC_Renewal_Opportunity__c = opportunity_data[0].Id;
            opportunity_data[1].Type = SLTC_Global_Constant.RENEWAL;
            Update opportunity_data; 
            
            //Renewal Proposal
            Apttus_Proposal__Proposal__c proposal_data2 = SLTC_TestDataFactory.createProposal(account_data[0].Id, contact_data[0].Id, opportunity_data[1].Id, 'Proposal'); 
            proposal_data2.Apttus_Proposal__Approval_Stage__c = 'Draft';
            proposal_data2.SLTC_Renewal_Period__c = 12;
            proposal_data2.CurrencyIsoCode = liCT.IsoCode;
            proposal_data2.Apttus_Proposal__ExpectedEndDate__c =System.today().addYears(2);
            proposal_data2.Apttus_Proposal__ExpectedStartDate__c =System.today().addYears(1);
            INSERT proposal_data2;
            // New AssetLineItem
            List<Apttus_Config2__AssetLineItem__c> AssetLI = SLTC_TestDataFactory.createAssetLineItemwithproducts(account_data[0].id, product);
            AssetLI[1].Apttus_Config2__LineType__c = SLTC_Global_Constant.OPTION;
            AssetLI[0].Apttus_Config2__LineType__c = 'Product/Service';
            AssetLI[0].SLTC_Related_Opportunity__c = opportunity_data[0].id;
            AssetLI[1].SLTC_Related_Opportunity__c = opportunity_data[0].id;
            AssetLI[0].Apttus_CMConfig__AgreementLineItemId__c = AgreementLIList[0].id;
            AssetLI[1].Apttus_CMConfig__AgreementLineItemId__c = AgreementLIList[1].id;
            INSERT AssetLI;
            //Renewal Proposal Line Items
            List<Apttus_Proposal__Proposal_Line_Item__c> ProposalLI1 = SLTC_TestDataFactory.createProposalLineItem(proposal_data2.Id, product, 'Renewed');
            ProposalLI1[0].Apttus_QPConfig__AssetLineItemId__c = AssetLI[0].id;
            ProposalLI1[1].Apttus_QPConfig__AssetLineItemId__c = AssetLI[1].id;
            INSERT ProposalLI1;
        }      
    }
    //testing the functionality of Updating the AssetlineItem status to activated and trigerring manual renew functionality
    @istest static void assetAfterUpdate(){
        User Salesrep_user = [SELECT Id FROM User WHERE FirstName='Business Development' limit 1];
        List<Apttus_Config2__AssetLineItem__c> assetLI = [SELECT Id,Name,Apttus_Config2__LineType__c,Apttus_Config2__BundleAssetId__c,Apttus_CMConfig__AgreementLineItemId__c,SLTC_Related_Opportunity__c,
                                                          Apttus_Config2__AutoRenew__c,Apttus_Config2__AssetStatus__c,Apttus_Config2__AccountId__c FROM Apttus_Config2__AssetLineItem__c WHERE Apttus_Config2__LineType__c != 'Misc' LIMIT 2];
        System.runAs(Salesrep_user){
            Test.startTest();
            List<Apttus_Config2__AssetLineItem__c> assetLineItems = new List<Apttus_Config2__AssetLineItem__c>();
            List<Id> assetLIId = new List<Id>();
            Id assetId1;
            
            for(Apttus_Config2__AssetLineItem__c assetLine :AssetLI){
                if(assetLine.Apttus_Config2__LineType__c == 'Product/Service'){
                    assetId1 = assetLine.id;
                }
                if(assetLine.Apttus_Config2__LineType__c == SLTC_Global_Constant.OPTION){
                    assetLine.Apttus_Config2__BundleAssetId__c = assetId1;
                }
                assetLine.Apttus_Config2__AutoRenew__c = false;
                assetLine.Apttus_Config2__AssetStatus__c = SLTC_Global_Constant.ACTIVATED;
                assetLineItems.add(assetLine);
                assetLIId.add(assetLine.Id);
            }
            UPDATE assetLineItems;
             Test.stopTest();
            List<Apttus_Config2__LineItem__c> configLineItem = [SELECT Id FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__AssetLineItemId__c IN:assetLIId];
            System.assertEquals(True, !configLineItem.isEmpty());
           
        }
    }
    
}