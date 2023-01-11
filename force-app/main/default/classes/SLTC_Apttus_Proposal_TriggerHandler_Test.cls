/**********************************************************
*************************************
Name : sltc_Apttus_Proposal_Trigger_Test
Author : Japtej Lamba
Created Date : 4/4/2022
Last Mod Date : 12/5/2022
Last Mod By : Japtej Lamba
NICC Reference :
Description : Test for the sltc_Apttus_Proposal_TriggerHandler class
***********************************************************
*************************************/
@isTest
public class SLTC_Apttus_Proposal_TriggerHandler_Test {
    
    @testSetup static void setup(){ 
        User user = SLTC_TestDataFactory.createuser('SLTC Sales','First','Last','SLTC_Sales_Manger'); 
        User user_exec = SLTC_TestDataFactory.createuser('SLTC Sales','Second','Last','SLTC_Sales_Manger'); 
        INSERT user;
        INSERT user_exec;
        PermissionSet requirePermission_data = new PermissionSet();
        requirePermission_data = SLTC_TestDataFactory.createPermissionSet('SLTC_Skip_the_contact_Role_ValIdation');
        List<PermissionSet> requirePermission = new List<PermissionSet>();
        List<PermissionSetAssignment> permissionassignment = new List<PermissionSetAssignment>();
        System.runAs(new User(Id=UserInfo.getUserId())){
            INSERT new NI_TriggerBypassSwitches__c(Name='Bypass Control Panel',BypassOpportunity_ON__c = true,BypassAccount_ON__c = true,  Bypass_AH_Opportunity_Related_Account__c = true);
            requirePermission.add(SLTC_TestDataFactory.getpermissionset('SLTCCPQSalesUser'));
            requirePermission.add(SLTC_TestDataFactory.getpermissionset('SLTCCPQFullUser'));
            for(PermissionSet ps: requirePermission){
                permissionassignment.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id));
            }
            permissionassignment.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = requirePermission_data.Id));
        }
        INSERT permissionassignment;
    } 

    @isTest
    public static void testUpdateProposalProperties(){
    
        User userData = [SELECT Id FROM User WHERE FirstName = 'First' limit 1];
        System.runAs(userData)
        {
            //create Account
            List<Account> accountList = SLTC_TestDataFactory.createAccounts('Partner','Test','MDM Approved','SLTC_ParentAccount','Prospect',3);
            accountList[1].Name+='123';
            INSERT accountList;
            //create Opportunity
            List<Opportunity> opportunityList = SLTC_TestDataFactory.createopportunity('Initial Interest','New Business', accountList[0], 1, 'SLTC_Opportunity');
            INSERT opportunityList;
            //create Contact
            List<Contact> contactList=SLTC_TestDataFactory.createcontact('Test Contact Role','Contact',accountList[0].id,1);
            INSERT contactList;
            //create Proposal 
            Apttus_Proposal__Proposal__c proposal= SLTC_TestDataFactory.createProposal(accountList[0].id, contactList[0].id,opportunityList[0].id,'Proposal'); 
            INSERT proposal;
            // create Product
            List<Product2> productList= SLTC_TestDataFactory.createProduct('Test_Pro',4);
            productList[1].Name+='1';
            productList[2].Name+='2';
            productList[3].Name+='3';
            INSERT productList;
            //create Proposal Line Item 
            List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList=SLTC_TestDataFactory.createProposalLineItem(proposal.id, productList,'New');

            Apttus_Config2__ProductOptionComponent__c poc1 = new Apttus_Config2__ProductOptionComponent__c(Apttus_Config2__Sequence__c=1.0);
            Apttus_Config2__ProductOptionComponent__c poc2 = new Apttus_Config2__ProductOptionComponent__c(Apttus_Config2__Sequence__c=1.0);

            insert poc1;
            insert poc2;
            
            Apttus_Config2__ClassificationName__c hierarchy1 = new Apttus_Config2__ClassificationName__c(Name='h1',Apttus_Config2__HierarchyLabel__c='h1');
            insert hierarchy1;
            Apttus_Config2__ClassificationName__c hierarchy2 = new Apttus_Config2__ClassificationName__c(Name='h2',Apttus_Config2__HierarchyLabel__c='h2');
            insert hierarchy2;

            Apttus_Config2__ClassificationHierarchy__c category1 = new Apttus_Config2__ClassificationHierarchy__c(Name='TEST1',Apttus_Config2__Label__c='TEST1',Apttus_Config2__HierarchyId__c=hierarchy1.id);
            Apttus_Config2__ClassificationHierarchy__c category2 = new Apttus_Config2__ClassificationHierarchy__c(Name='TEST2',Apttus_Config2__Label__c='TEST2',Apttus_Config2__HierarchyId__c=hierarchy2.id);

            INSERT category1; 
            INSERT category2;
            

            Test.startTest();

            proposalLineItemList[0].Apttus_QPConfig__ShipToAccountId__c=accountList[0].Id;
            proposalLineItemList[0].Apttus_QPConfig__LineNumber__c=1;
            proposalLineItemList[0].Apttus_Proposal__Product__c=productList[0].Id;
            proposalLineItemList[0].Apttus_QPConfig__ItemSequence__c=1;
            
            proposalLineItemList[1].Apttus_QPConfig__ShipToAccountId__c=accountList[0].Id;
            proposalLineItemList[1].Apttus_QPConfig__LineNumber__c=1;
            proposalLineItemList[1].Apttus_Proposal__Product__c=productList[0].Id;
            proposalLineItemList[1].Apttus_QPConfig__ItemSequence__c=2;
            
            proposalLineItemList[2].Apttus_QPConfig__ShipToAccountId__c=accountList[1].Id;
            proposalLineItemList[2].Apttus_QPConfig__LineNumber__c=2;
            proposalLineItemList[2].Apttus_Proposal__Product__c=productList[2].Id;
            proposalLineItemList[2].Apttus_QPConfig__ItemSequence__c=1;
            
            proposalLineItemList[3].Apttus_QPConfig__ShipToAccountId__c=accountList[1].Id;
            proposalLineItemList[3].Apttus_QPConfig__LineNumber__c=2;
            proposalLineItemList[3].Apttus_Proposal__Product__c=productList[2].Id;
            proposalLineItemList[3].Apttus_QPConfig__ItemSequence__c=2;

            
            proposalLineItemList[1].Apttus_QPConfig__ProductOptionId__c = poc1.Id;
            proposalLineItemList[1].Apttus_QPConfig__OptionId__c = productList[1].Id;
            proposalLineItemList[1].Apttus_QPConfig__LineType__c = 'Option';
            proposalLineItemList[1].Apttus_QPConfig__ClassificationId__c=category1.Id;
            proposalLineItemList[1].Apttus_QPConfig__PriceType__c='One Time';
            proposalLineItemList[1].Apttus_QPConfig__SellingFrequency__c='One Time';
            proposalLineItemList[1].Apttus_QPConfig__Quantity2__c=2;
            
            proposalLineItemList[3].Apttus_QPConfig__ProductOptionId__c = poc2.Id;
            proposalLineItemList[3].Apttus_QPConfig__OptionId__c = productList[3].Id;
            proposalLineItemList[3].Apttus_QPConfig__LineType__c = 'Option';
            proposalLineItemList[3].Apttus_QPConfig__ClassificationId__c=category2.Id;
            proposalLineItemList[3].Apttus_QPConfig__PriceType__c='Recurring';
            proposalLineItemList[3].Apttus_QPConfig__SellingFrequency__c='Recurring';
            proposalLineItemList[3].Apttus_QPConfig__Quantity2__c=20;

            INSERT proposalLineItemList;
            
            Apttus_Proposal__Proposal__c prop = [SELECT Id,Apttus_QPConfig__ConfigurationFinalizedDate__c,SLTC_Number_Of_Properties__c from Apttus_Proposal__Proposal__c WHERE Id=:proposal.Id ];
            prop.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.now();
            UPDATE prop;
            
            List<SLTC_Proposal_Template_Data__c> tempDataList = [SELECT Id from SLTC_Proposal_Template_Data__c WHERE SLTC_Proposal__c=:prop.Id];
            
            System.assertEquals(2, prop.SLTC_Number_Of_Properties__c);
            System.assertEquals(True, !tempDataList.isEmpty());
            
            Test.stopTest();
        }
        
    }
    
    @isTest
    public static void testSingleProperty(){
    
        User userData = [SELECT Id FROM User WHERE FirstName = 'First' limit 1];
        System.runAs(userData)
        {
            //create Account
            List<Account> accountList = SLTC_TestDataFactory.createAccounts('Partner','Test','MDM Approved','SLTC_ParentAccount','Prospect',3);
            INSERT accountList;
            //create Opportunity
            List<Opportunity> opportunityList = SLTC_TestDataFactory.createopportunity('Initial Interest','New Business', accountList[0], 1, 'SLTC_Opportunity');
            INSERT opportunityList;
            //create Contact
            List<Contact> contactList=SLTC_TestDataFactory.createcontact('Test Contact Role','Contact',accountList[0].id,1);
            INSERT contactList;
            //create Proposal 
            Apttus_Proposal__Proposal__c proposal= SLTC_TestDataFactory.createProposal(accountList[0].id, contactList[0].id,opportunityList[0].id,'Proposal'); 
            INSERT proposal;
            // create Product
            List<Product2> productList= SLTC_TestDataFactory.createProduct('Test_Pro',3);
            INSERT productList;
            //create Proposal Line Item 
            List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList=SLTC_TestDataFactory.createProposalLineItem(proposal.id, productList,'New');

            Apttus_Config2__ProductOptionComponent__c poc1 = new Apttus_Config2__ProductOptionComponent__c(Apttus_Config2__Sequence__c=1.0);
            Apttus_Config2__ProductOptionComponent__c poc2 = new Apttus_Config2__ProductOptionComponent__c(Apttus_Config2__Sequence__c=1.0);

            insert poc1;
            insert poc2;
            
            Apttus_Config2__ClassificationName__c hierarchy1 = new Apttus_Config2__ClassificationName__c(Name='h1',Apttus_Config2__HierarchyLabel__c='h1');
            insert hierarchy1;
            Apttus_Config2__ClassificationName__c hierarchy2 = new Apttus_Config2__ClassificationName__c(Name='h2',Apttus_Config2__HierarchyLabel__c='h2');
            insert hierarchy2;

            Apttus_Config2__ClassificationHierarchy__c category1 = new Apttus_Config2__ClassificationHierarchy__c(Name='TEST1',Apttus_Config2__Label__c='TEST1',Apttus_Config2__HierarchyId__c=hierarchy1.id);
            Apttus_Config2__ClassificationHierarchy__c category2 = new Apttus_Config2__ClassificationHierarchy__c(Name='TEST2',Apttus_Config2__Label__c='TEST2',Apttus_Config2__HierarchyId__c=hierarchy2.id);

            INSERT category1; 
            INSERT category2;

            proposalLineItemList[0].Apttus_QPConfig__ShipToAccountId__c=accountList[0].Id;
            proposalLineItemList[1].Apttus_Proposal__Product__c=productList[0].Id;
            proposalLineItemList[2].Apttus_Proposal__Product__c=productList[0].Id;
            

            proposalLineItemList[1].Apttus_QPConfig__ProductOptionId__c = poc1.Id;
            proposalLineItemList[1].Apttus_QPConfig__OptionId__c = productList[1].Id;
            proposalLineItemList[1].Apttus_QPConfig__LineType__c = 'Option';
            proposalLineItemList[1].Apttus_QPConfig__ClassificationId__c=category1.Id;
            proposalLineItemList[1].Apttus_QPConfig__ShipToAccountId__c=accountList[0].Id;
            proposalLineItemList[1].Apttus_QPConfig__PriceType__c='One Time';
            proposalLineItemList[1].Apttus_QPConfig__SellingFrequency__c='One Time';
            proposalLineItemList[2].Apttus_QPConfig__ProductOptionId__c = poc2.Id;
            proposalLineItemList[2].Apttus_QPConfig__OptionId__c = productList[2].Id;
            proposalLineItemList[2].Apttus_QPConfig__LineType__c = 'Option';
            proposalLineItemList[2].Apttus_QPConfig__ClassificationId__c=category2.Id;
            proposalLineItemList[2].Apttus_QPConfig__ShipToAccountId__c=accountList[0].Id;
            proposalLineItemList[2].Apttus_QPConfig__PriceType__c='Recurring';
            proposalLineItemList[2].Apttus_QPConfig__SellingFrequency__c='Recurring';

            INSERT proposalLineItemList;

            Test.startTest();
            
            Apttus_Proposal__Proposal__c prop = [SELECT Id,Apttus_QPConfig__ConfigurationFinalizedDate__c,SLTC_Number_Of_Properties__c from Apttus_Proposal__Proposal__c WHERE Id=:proposal.Id ];
            prop.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.now();
            UPDATE prop;
            
            List<SLTC_Proposal_Template_Data__c> tempDataList = [SELECT Id from SLTC_Proposal_Template_Data__c WHERE SLTC_Proposal__c=:prop.Id];
            System.assertEquals(1, prop.SLTC_Number_Of_Properties__c);
            
            Test.stopTest();
        }
    }
    
}