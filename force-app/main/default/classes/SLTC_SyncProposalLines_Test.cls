/****************************************************************************************
Name            : SLTC_SyncProposalLines_Test 
Author          : Japtej Lamba
Created Date    : 10/6/2022 
Last Mod Date   : 12/06/2022 
Last Mod By     : Japtej Lamba
NICC Reference  : 
Description     : Test Class for SLTC_SyncProposalLines
****************************************************************************************/
@isTest
public class SLTC_SyncProposalLines_Test{
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
	public static void synChildLineItemsTest(){
        
        //create Account
        List<Account> accountList = SLTC_TestDataFactory.createAccounts('Partner','Test','MDM Approved','SLTC_ParentAccount','Prospect',3);
        INSERT accountList;
        //create Opportunity
        List<Opportunity> opportunityList = SLTC_TestDataFactory.createopportunity('Initial Interest','New Business', accountList[0], 2, 'SLTC_Opportunity');
        INSERT opportunityList;
    	opportunityList[1].Master_Opportunity__c=opportunityList[0].Id;
    	UPDATE opportunityList;
        //create Contact
        List<Contact> contactList=SLTC_TestDataFactory.createcontact('Test Contact Role','Contact',accountList[0].id,1);
        INSERT contactList;
        //create Proposal 
        Apttus_Proposal__Proposal__c proposal= SLTC_TestDataFactory.createProposal(accountList[0].id, contactList[0].id,opportunityList[0].id,'Proposal'); 
    	proposal.Apttus_Proposal__Proposal_Name__c='Test proposalrecord123';
        INSERT proposal;
        
        //create Proposal 
        Apttus_Proposal__Proposal__c proposal1= SLTC_TestDataFactory.createProposal(accountList[0].id, contactList[0].id,opportunityList[1].id,'Proposal'); 
    	proposal1.SLTC_Renewal_Period__c=12;
        INSERT proposal1;
    
    	
        // create Product
        List<Product2> productList= SLTC_TestDataFactory.createProduct('Test_Pro',3);
        INSERT productList;
        
        // create Parent Proposal Template Data
        SLTC_Proposal_Template_Data__c tempData = new SLTC_Proposal_Template_Data__c(SLTC_Is_Bundle_Product__c=true,SLTC_Proposal__c=proposal.id,SLTC_Product_Name__c='Test1',
                                                                                      SLTC_Product__c=productList[1].Id,SLTC_Ship_To__c=accountList[0].Id);
        INSERT tempData;
        
        // create child Proposal Template Data
        SLTC_Proposal_Template_Data__c tempData1 = new SLTC_Proposal_Template_Data__c(SLTC_Is_Bundle_Product__c=true,SLTC_Proposal__c=proposal1.id,SLTC_Product_Name__c='Test1',
                                                                                      SLTC_Product__c=productList[0].Id,SLTC_Ship_To__c=accountList[0].Id);
        INSERT tempData1;
    
        // create Customer Story
    	CustomerStory__c customerStory = new CustomerStory__c(Name='TempStory',Account__c=accountList[0].id);
    	INSERT customerStory;
        
        // create Parent Proposal Customer Story
    	SLTC_Proposal_Customer_Story__c propCustomerStoryParent = new SLTC_Proposal_Customer_Story__c(SLTC_Customer_Story__c=customerStory.Id,SLTC_Proposal__c=proposal.Id);
    	INSERT propCustomerStoryParent;
    
        // create child Proposal Customer Story
    	SLTC_Proposal_Customer_Story__c propCustomerStory = new SLTC_Proposal_Customer_Story__c(SLTC_Customer_Story__c=customerStory.Id,SLTC_Proposal__c=proposal1.Id);
    	INSERT propCustomerStory;
    
        // create Oppty Team Members
    	User userData = [SELECT Id FROM User WHERE FirstName = 'First' limit 1];
    	OpportunityTeamMember opptyMember = new OpportunityTeamMember(UserId=userData.Id,TeamMemberRole='RVP',OpportunityId=opportunityList[1].Id,SLTC_Proposal__c=proposal1.Id);
        INSERT opptyMember;
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(proposal.Id));
        SLTC_SyncProposalLines  testSyncLines = new SLTC_SyncProposalLines();
        testSyncLines.syncChildLineItems();
        
        //Check if Child Template data is cloned to Parent record
    	List<SLTC_Proposal_Template_Data__c> tempDataList = new List<SLTC_Proposal_Template_Data__c>([SELECT Id FROM SLTC_Proposal_Template_Data__c WHERE SLTC_Proposal__c=:proposal.Id]);
        System.assertEquals(True, !tempDataList.isEmpty());
	}


}