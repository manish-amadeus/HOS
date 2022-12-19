/**********************************************************
*************************************
Name          : SLTC_ProductSet_AssetLineItem_Test
Author        : Sreeharsha L
Created Date  : 11/21/22
Last Mod Date : 11/23/22
Last Mod By   : Sreeharsha L
Description   : Test Class for SLTC_ProductSet_AssetLineItem.
***********************************************************
*************************************/
@Istest
public class SLTC_ProductSet_AssetLineItem_Test {
    
    @testSetup static void setupProduct(){
        List<Account> account_data = SLTC_TestDataFactory.createAccounts('SLTC', 'Test', 'MDM Approved', 'SLTC_Property', 'Preliminary', 1);
        INSERT account_data;
        
        List<Product2> product = SLTC_TestDataFactory.createProduct('Ihotlier', 5);
        INSERT product;
        List<PricebookEntry> pricebookEntries =  SLTC_TestDataFactory.createPricebookEntry(product);
        INSERT pricebookEntries; 
        
        List<Apttus_Config2__AssetLineItem__c> lineItem_data = SLTC_TestDataFactory.createAssetLineItemwithproducts(account_data[0].Id, product);
        //creating duplicate proposalLine item for test
        lineItem_data.addAll(SLTC_TestDataFactory.createAssetLineItemwithproducts(account_data[0].Id, product));
        INSERT lineItem_data;       
    }
          
    //Perform test to remove duplicate product from Asset Line items.
  	@isTest static void getAssetLineItemTest(){
        Account account_data = [Select Id from Account WHERE Name like '%SLTC_Test'];

        Test.startTest();
        List<List<Apttus_Config2__AssetLineItem__c>>  assetLineitem_records = new List<List<Apttus_Config2__AssetLineItem__c>>();
        assetLineitem_records.add([SELECT Id, Apttus_Config2__OptionId__c, Apttus_Config2__ProductId__c, SLTC_Product_Names__c FROM Apttus_Config2__AssetLineItem__c WHERE (Apttus_Config2__AccountId__c =: account_data.Id)]);
        List<List<Product2>> product_data = SLTC_ProductSet_AssetLineItem.getAssetLineItem(assetLineitem_records);
        Test.stopTest();
  
        System.assertEquals(5, product_data[0].size(), 'No duplicate product found');
    }
}