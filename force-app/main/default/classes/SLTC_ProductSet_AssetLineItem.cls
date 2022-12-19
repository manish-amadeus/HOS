/**********************************************************
*************************************
Name          : SLTC_ProductSet_AssetLineItem
Author        : Sreeharsha L
Created Date  : 10/19/22
Last Mod Date : 10/19/22
Last Mod By   : Sreeharsha L
Description   : Class is used to overcome the flow limitation to filter and remove duplicate from List<sObject>. It called from Request 
                Object screen flow (SLTC Request Clone Button) .
***********************************************************
*************************************/
global class SLTC_ProductSet_AssetLineItem {
    
	//Method generate unique list of Product form AssetLineItem
    @InvocableMethod(label='List of Products' description='Returns the unique Products')
    global static List<List<Product2>> getAssetLineItem(List<List<Apttus_Config2__AssetLineItem__c>> assetLineItems_data) {
        List<Product2> products = new List<Product2>();
        try{
            List<Apttus_Config2__AssetLineItem__c> List_of_AssetLineItems = new List<Apttus_Config2__AssetLineItem__c>();
            for(List<Apttus_Config2__AssetLineItem__c> item : assetLineItems_data){
                List_of_AssetLineItems.addAll(item);
            }
            
            Set<Id> productIds = new Set<Id>();
            for(Apttus_Config2__AssetLineItem__c item : List_of_AssetLineItems){
                Id productId = item.Apttus_Config2__OptionId__c != NULL ? item.Apttus_Config2__OptionId__c : item.Apttus_Config2__ProductId__c;
                if(productIds.contains(productId)){
                    continue;
                }
                products.add(new Product2(Id= productId, Name = item.SLTC_Product_Names__c));
                productIds.add(productId);
            }
            
        }Catch(Exception exec){
            String message = exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(); 
            NI_Error_Logger.WriteToLog(message, 'Apttus_Config2__AssetLineItem__c', 'SLTC_ProductSet_AssetLineItem', 'Query');              
        }
        List<List<Product2>> productList= new  List<List<Product2>>();
        productList.add(products);
        return productList;
    }
}