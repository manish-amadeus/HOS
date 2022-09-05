/**********************************************************
*************************************
Name          : SLTC_TerminatedProducts_List_Test
Author        : Sreeharsha L
Created Date  : 08-05-22
Last Mod Date : 08-05-22
Last Mod By   : Sreeharsha L
Description   : Test class for SLTC_TerminatedProducts_List
***********************************************************
*************************************/

@isTest
public class SLTC_TerminatedProducts_List_Test {
    //setup test data product and pricebook entries
    @testSetup static void setupProduct(){
        List<Product2> product = SLTC_TestDataFactory.createProduct('Ihotlier', 5);
        INSERT product;
        List<PricebookEntry> pricebookEntries =  createPricebookEntry(product);
        INSERT pricebookEntries;
        
    }
    //Perform test to remove duplicate product from Proposal Line items
    @isTest static void getProposalLineItemTest(){
        List<Account> account_data = SLTC_TestDataFactory.createAccounts('SLTC', 'Test', 'Approved', 'SLTC_Corporate', 'Preliminary', 1);
        INSERT account_data;
        
        List<Contact> contact_data = SLTC_TestDataFactory.createContact('contact', 'SLTC_Contact', account_data[0].Id, 1);
        INSERT contact_data;
        
        List<Opportunity> opportunity_data = SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', account_data[0], 1, 'SLTC_Opportunity');
        INSERT opportunity_data;
        
        Apttus_Proposal__Proposal__c proposal_data = SLTC_TestDataFactory.createProposal(account_data[0].Id, contact_data[0].Id, opportunity_data[0].Id, 'Proposal');
        INSERT proposal_data;
        
        List<Product2> products = [SELECT Id FROM Product2];
        
        List<Apttus_Proposal__Proposal_Line_Item__c> lineItem_data = SLTC_TestDataFactory.createProposalLineItem(proposal_data.Id, products, 'Cancelled');
        //creating duplicate proposalLine item for test
        lineItem_data.addAll(SLTC_TestDataFactory.createProposalLineItem(proposal_data.Id, products, 'Cancelled'));
        INSERT lineItem_data;

        Test.startTest();
        List<List<Apttus_Proposal__Proposal_Line_Item__c>>  proposalLine = new List<List<Apttus_Proposal__Proposal_Line_Item__c>>();
        proposalLine.add([SELECT Id, Apttus_QPConfig__OptionId__c, Apttus_Proposal__Product__c,Product_for_Template__c FROM Apttus_Proposal__Proposal_Line_Item__c]);
        List<List<Product2>> prducts_data = SLTC_TerminatedProducts_List.getProposalLineItem(proposalLine);
        Test.stopTest();
        
        System.assertEquals(5, prducts_data[0].size(), 'No duplicate product found at Proposal Line item');
        
    }
    

    //Pricebook entries for each products
    private static List<PricebookEntry> createPricebookEntry(List<Product2> productList){
        List<PricebookEntry> pricebookEntry = new List<PricebookEntry>();
        for(Product2 item : productList){
            PricebookEntry standardPrice = new PricebookEntry();
            standardPrice.Pricebook2Id = Test.getStandardPricebookId();
            standardPrice.Product2Id = item.Id;
            standardPrice.UnitPrice = 100;
            standardPrice.IsActive = true;
            standardPrice.UseStandardPrice = false;
            pricebookEntry.add(standardPrice);
        }
        return pricebookEntry;
    }
    
}