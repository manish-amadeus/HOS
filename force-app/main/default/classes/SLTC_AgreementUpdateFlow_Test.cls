/**********************************************************
*************************************
Name 				: SLTC_AgreementUpdateFlow_Test 
Author 				: Srividya G
Created Date 		: 11/30/22
Last Mod Date 		: 11/30/22
Last Mod By 		: Srividya G
NICC Reference 		: 
Description 		: Test class to test SLTC Agreement After Update Flow
***********************************************************
*************************************/
@istest
public class SLTC_AgreementUpdateFlow_Test {
    @testSetup static void createTestData(){
        List<User> user_data = new List<User>();
        user_data.Add(SLTC_TestDataFactory.createuser('SLTC Sales','Business Development','Manager','WWSales'));
        INSERT user_data;        
        List<PermissionSet> requirePermission_data = new List<PermissionSet>();
        List<PermissionSetAssignment> permissionassignment_data= new List<PermissionSetAssignment>();
        System.runAs(new User(Id = UserInfo.getUserId())){
            //stop running old legacy trigger code and Assign the Required permission set to user.
            INSERT new NI_TriggerBypassSwitches__c(Name ='Bypass Control Panel', BypassOpportunity_ON__c = true, BypassAccount_ON__c = true, Bypass_AH_Opportunity_Related_Account__c = true, Bypass_Contact__c = true,BypassContactSunsetContact__c =true, BypassApttusAgreement_ON__c = true);
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Contact_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Opportunity_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Account_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Proposal_Create_View_Modify'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTCCPQFullUser'));
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
            opportunity_data.addAll(SLTC_TestDataFactory.createopportunity('Initial Interest', 'Renewal', account_data[0], 1, 'SLTC_Opportunity'));
            INSERT opportunity_data;
            opportunity_data[0].CurrencyIsoCode = liCT.IsoCode;
            opportunity_data[1].CurrencyIsoCode = liCT.IsoCode;
            UPDATE opportunity_data;
            
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
            proposal_data1.Apttus_Proposal__Approval_Stage__c = 'Accepted';
            proposal_data1.SLTC_Type_of_Invoice__c = 'Ind to Corp';
            proposal_data1.SLTC_Renewal_Period__c = 12;
            proposal_data1.CurrencyIsoCode = liCT.IsoCode;
            proposal_data1.Apttus_Proposal__ExpectedEndDate__c =System.today().addYears(1);
            proposal_data1.Apttus_Proposal__ExpectedStartDate__c =System.today();
            INSERT proposal_data1;
                        
            //New Products
            List<Product2> product = SLTC_TestDataFactory.createProduct('SLTC',1);
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
                
           	//Proposal Line Item
            List<Apttus_Proposal__Proposal_Line_Item__c> ProposalLI = SLTC_TestDataFactory.createProposalLineItem(proposal_data1.Id, product, 'New');
            INSERT ProposalLI;
                
            SLTC_Proposal_Template_Data__c template_data = new SLTC_Proposal_Template_Data__c();
            template_data.SLTC_Proposal__c = proposal_data1.id;
            template_data.SLTC_Product_Name__c = product[0].Name;
            INSERT template_data;
            }        
    }
    
	@istest static void agreementFullySigned(){ 
            User Salesrep_user = [SELECT Id FROM User WHERE FirstName='Business Development' limit 1];
            List<Account> account_data = [SELECT Id FROM Account WHERE SLTC_Account_Validation_Status__c = 'MDM Approved'];
        	List<Opportunity> opportunity_data = [SELECT Id FROM Opportunity WHERE Type = 'New Business'];
        	List<Contact> contact_data = [SELECT Id FROM Contact WHERE LastName = 'firstcontact'];
        	Apttus_Proposal__Proposal__c proposal_data1 = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE SLTC_Type_of_Invoice__c = 'Ind to Corp' LIMIT 1];
        	
        	//Apttus_Proposal__Proposal__c proposal_data = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE SLTC_Type_of_Invoice__c = 'Corp to Corp' LIMIT 1];
            System.runAs(Salesrep_user){
            List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
            Apttus__APTS_Agreement__c agreement_data = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data1.Id,'Order_Form'); 
            agreementList.add(agreement_data);    
            Apttus__APTS_Agreement__c agreement_data1 = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data1.Id,'Order_Form'); 
            agreement_data1.Apttus__Parent_Agreement__c = agreement_data.id;
            agreementList.add(agreement_data1); 
           	INSERT agreementList;
                
          	Test.startTest();
                
            Apttus__AgreementLineItem__c AgreementLI = new Apttus__AgreementLineItem__c();
            AgreementLI.Apttus__AgreementId__c = agreementList[0].id;
            AgreementLI.Apttus_CMConfig__LineStatus__c = 'New';
            INSERT AgreementLI;
                
            Apttus__AgreementLineItem__c AgreementLI1 = new Apttus__AgreementLineItem__c();
            AgreementLI1.Apttus__AgreementId__c = agreementList[1].id;
            AgreementLI1.Apttus_CMConfig__LineStatus__c = 'New';
            INSERT AgreementLI1;
            {
            agreementList[0].Apttus__Status_Category__c = 'In Signatures';
            agreementList[0].Apttus__Status__c = 'Fully Signed';
            agreementList[0].Apttus__Auto_Renewal__c = true;
            agreementList[0].SLTC_Auto_renewal__c = false;
            UPDATE agreementList[0];
            }    
                
            System.assertEquals('Fully Signed',agreementList[0].Apttus__Status__c);
            System.assertEquals('In Signatures',agreementList[0].Apttus__Status_Category__c);

            Test.stopTest();
            }
    }

    @istest static void agreementNotFullySigned(){  
        User Salesrep_user = [SELECT Id FROM User WHERE FirstName='Business Development' limit 1];
        List<Account> account_data = [SELECT Id FROM Account WHERE SLTC_Account_Validation_Status__c = 'MDM Approved'];
        List<Opportunity> opportunity_data = [SELECT Id FROM Opportunity WHERE Type = 'New Business'];
        List<Contact> contact_data = [SELECT Id FROM Contact WHERE LastName = 'firstcontact'];
        Apttus_Proposal__Proposal__c proposal_data1 = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE SLTC_Type_of_Invoice__c = 'Ind to Corp' LIMIT 1];

        //Apttus_Proposal__Proposal__c proposal_data = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE SLTC_Type_of_Invoice__c = 'Corp to Corp' LIMIT 1];
        System.runAs(Salesrep_user){
            List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
            Apttus__APTS_Agreement__c agreement_data = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data1.Id,'Order_Form'); 
            agreementList.add(agreement_data);    
            Apttus__APTS_Agreement__c agreement_data1 = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data1.Id,'Order_Form'); 
            agreement_data1.Apttus__Parent_Agreement__c = agreement_data.id;
            agreementList.add(agreement_data1); 
            INSERT agreementList;         
            Test.startTest();
            Apttus__AgreementLineItem__c AgreementLI = new Apttus__AgreementLineItem__c();
            AgreementLI.Apttus__AgreementId__c = agreementList[0].id;
            AgreementLI.Apttus_CMConfig__LineStatus__c = 'New';
            INSERT AgreementLI;
                    
            Apttus__AgreementLineItem__c AgreementLI1 = new Apttus__AgreementLineItem__c();
            AgreementLI1.Apttus__AgreementId__c = agreementList[1].id;
            AgreementLI1.Apttus_CMConfig__LineStatus__c = 'New';
            INSERT AgreementLI1;
                
            //Apttus__APTS_Agreement__c agreement = [SELECT id,Apttus__Status_Category__c,Apttus__Status__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Parent_Agreement__c = null];
            {
            agreementList[0].Apttus__Status_Category__c = 'In Effect';
            agreementList[0].Apttus__Status__c = 'Activated';
            UPDATE agreementList[0];
            }
                
            System.assertNotEquals('Fully Signed',agreementList[0].Apttus__Status__c);
            System.assertNotEquals('In Signatures',agreementList[0].Apttus__Status_Category__c);

            Test.stopTest();
        }  
    }

    @istest static void agreementCreationAutoRenewTest(){                   
        User Salesrep_user = [SELECT Id FROM User WHERE FirstName='Business Development' limit 1];
        List<Account> account_data = [SELECT Id FROM Account WHERE SLTC_Account_Validation_Status__c = 'MDM Approved'];
        List<Opportunity> opportunity_data = [SELECT Id FROM Opportunity WHERE Type = 'New Business'];
        List<Contact> contact_data = [SELECT Id FROM Contact WHERE LastName = 'firstcontact'];
        Apttus_Proposal__Proposal__c proposal_data1 = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE SLTC_Type_of_Invoice__c = 'Ind to Corp' LIMIT 1];

        //Apttus_Proposal__Proposal__c proposal_data = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE SLTC_Type_of_Invoice__c = 'Corp to Corp' LIMIT 1];
        System.runAs(Salesrep_user){
            List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
            Apttus__APTS_Agreement__c agreement_data = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data1.Id,'Order_Form'); 
            agreementList.add(agreement_data);    
            Apttus__APTS_Agreement__c agreement_data1 = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data1.Id,'Order_Form'); 
            agreement_data1.Apttus__Parent_Agreement__c = agreement_data.id;
            agreementList.add(agreement_data1); 
            INSERT agreementList;

            Test.startTest();
            Apttus__AgreementLineItem__c AgreementLI = new Apttus__AgreementLineItem__c();
            AgreementLI.Apttus__AgreementId__c = agreementList[0].id;
            AgreementLI.Apttus_CMConfig__LineStatus__c = 'New';
            INSERT AgreementLI;
                    
            Apttus__AgreementLineItem__c AgreementLI1 = new Apttus__AgreementLineItem__c();
            AgreementLI1.Apttus__AgreementId__c = agreementList[1].id;
            AgreementLI1.Apttus_CMConfig__LineStatus__c = 'New';
            INSERT AgreementLI1;

            Apttus__APTS_Agreement__c agreement_data3 = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data1.Id,'Order_Form'); 
            agreement_data3.Apttus__Auto_Renewal__c = true;
            agreement_data3.SLTC_Auto_renewal__c = false;
            INSERT agreement_data3;
            System.assertEquals(true,agreement_data3.Apttus__Auto_Renewal__c);
            System.assertNotEquals(true,agreement_data3.SLTC_Auto_renewal__c);
            Test.stopTest();
        }
    }

    @istest static void agreementUpdationAutoRenewTest(){      
        User Salesrep_user = [SELECT Id FROM User WHERE FirstName='Business Development' limit 1];
        List<Account> account_data = [SELECT Id FROM Account WHERE SLTC_Account_Validation_Status__c = 'MDM Approved'];
        List<Opportunity> opportunity_data = [SELECT Id FROM Opportunity WHERE Type = 'New Business'];
        List<Contact> contact_data = [SELECT Id FROM Contact WHERE LastName = 'firstcontact'];
        Apttus_Proposal__Proposal__c proposal_data1 = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE SLTC_Type_of_Invoice__c = 'Ind to Corp' LIMIT 1];

        //Apttus_Proposal__Proposal__c proposal_data = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE SLTC_Type_of_Invoice__c = 'Corp to Corp' LIMIT 1];
        System.runAs(Salesrep_user){
            List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
            Apttus__APTS_Agreement__c agreement_data = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data1.Id,'Order_Form'); 
            agreementList.add(agreement_data);    
            Apttus__APTS_Agreement__c agreement_data1 = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data1.Id,'Order_Form'); 
            agreement_data1.Apttus__Parent_Agreement__c = agreement_data.id;
            agreementList.add(agreement_data1); 
            INSERT agreementList;

            Test.startTest();
            Apttus__AgreementLineItem__c AgreementLI = new Apttus__AgreementLineItem__c();
            AgreementLI.Apttus__AgreementId__c = agreementList[0].id;
            AgreementLI.Apttus_CMConfig__LineStatus__c = 'New';
            INSERT AgreementLI;
                    
            Apttus__AgreementLineItem__c AgreementLI1 = new Apttus__AgreementLineItem__c();
            AgreementLI1.Apttus__AgreementId__c = agreementList[1].id;
            AgreementLI1.Apttus_CMConfig__LineStatus__c = 'New';
            INSERT AgreementLI1;
                
            Apttus__APTS_Agreement__c agreement_data3 = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data1.Id,'Order_Form'); 
            INSERT agreement_data3;
            agreement_data3.Apttus__Auto_Renewal__c = true;
            agreement_data3.SLTC_Auto_renewal__c = false;
            UPDATE agreement_data3;
            Test.stopTest();  
            
            System.assertEquals(true,agreement_data3.Apttus__Auto_Renewal__c);
            System.assertNotEquals(true,agreement_data3.SLTC_Auto_renewal__c);
        }
    }

    @istest static void agreementUpdationAutoRenewMatchTest(){      
        User Salesrep_user = [SELECT Id FROM User WHERE FirstName='Business Development' limit 1];
        List<Account> account_data = [SELECT Id FROM Account WHERE SLTC_Account_Validation_Status__c = 'MDM Approved'];
        List<Opportunity> opportunity_data = [SELECT Id FROM Opportunity WHERE Type = 'New Business'];
        List<Contact> contact_data = [SELECT Id FROM Contact WHERE LastName = 'firstcontact'];
        Apttus_Proposal__Proposal__c proposal_data1 = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE SLTC_Type_of_Invoice__c = 'Ind to Corp' LIMIT 1];

        //Apttus_Proposal__Proposal__c proposal_data = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE SLTC_Type_of_Invoice__c = 'Corp to Corp' LIMIT 1];
        System.runAs(Salesrep_user){
            List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
            Apttus__APTS_Agreement__c agreement_data = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data1.Id,'Order_Form'); 
            agreementList.add(agreement_data);    
            Apttus__APTS_Agreement__c agreement_data1 = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data1.Id,'Order_Form'); 
            agreement_data1.Apttus__Parent_Agreement__c = agreement_data.id;
            agreementList.add(agreement_data1); 
            INSERT agreementList;

            Test.startTest();
            Apttus__AgreementLineItem__c AgreementLI = new Apttus__AgreementLineItem__c();
            AgreementLI.Apttus__AgreementId__c = agreementList[0].id;
            AgreementLI.Apttus_CMConfig__LineStatus__c = 'New';
            INSERT AgreementLI;
                    
            Apttus__AgreementLineItem__c AgreementLI1 = new Apttus__AgreementLineItem__c();
            AgreementLI1.Apttus__AgreementId__c = agreementList[1].id;
            AgreementLI1.Apttus_CMConfig__LineStatus__c = 'New';
            INSERT AgreementLI1;
                
            Apttus__APTS_Agreement__c agreement_data3 = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data1.Id,'Order_Form'); 
            agreement_data3.SLTC_Auto_renewal__c = true;
            INSERT agreement_data3;
            agreement_data3.Apttus__Auto_Renewal__c = true;        
            UPDATE agreement_data3;
            System.assertEquals(true,agreement_data3.Apttus__Auto_Renewal__c);
            System.assertEquals(true,agreement_data3.SLTC_Auto_renewal__c);
            Test.stopTest();
        }
    }
}