/****************************************************************************************
Name            : AssetLineItemTriggerHandler 
Author          : Heema solanki
Created Date    : 02/10/2022
Last Mod Date   : 12/05/2022 
Last Mod By     : Japtej Lamba
NICC Reference  : 
Description     : This class create the line items for the renewal quote from the asset line item. Also it covers the amendents scenario and update the amend line item for renewal quote
****************************************************************************************/

public class SLTC_AssetLineItemTriggerHandler {
    
    public void onAfterUpdate(Map <Id, Apttus_Config2__AssetLineItem__c> triggerNewmap, Map <Id, Apttus_Config2__AssetLineItem__c> triggeroldmap, List <Apttus_Config2__AssetLineItem__c> assetList) {
        if(SLTC_checkRecursive.runOnce() || Test.isRunningTest()){
            List<Id> AccountId = new List<Id>();
            List <Id> assetIds = new List <Id> ();
            for (Apttus_Config2__AssetLineItem__c assetLine : assetList) {
                if (((assetLine.Apttus_Config2__AssetStatus__c == SLTC_Global_Constant.ACTIVATED || assetLine.Apttus_Config2__AssetStatus__c == SLTC_Global_Constant.CANCELED) && assetLine.Apttus_Config2__AssetStatus__c != triggeroldmap.get(assetLine.ID).Apttus_Config2__AssetStatus__c &&  assetLine.Apttus_Config2__AutoRenew__c == false ) || (assetLine.Apttus_Config2__AutoRenew__c == false && assetLine.Apttus_Config2__AutoRenew__c != triggeroldmap.get(assetLine.ID).Apttus_Config2__AutoRenew__c)) 
                {
                    AccountId.add(assetLine.Apttus_Config2__AccountId__c);
                    assetIds.add(assetLine.Id);
                }
            }
            if(!assetIds.isEmpty()){
                createRenewalline(assetIds, AccountId);
            }
        }
    }

    //calling future method
    @future
    private static void createRenewalline(List <Id> assetIds, List<Id> AccountId) {
        List<Id> cartIds;
        List < Apttus_Config2__LineItem__c > finalList = new List < Apttus_Config2__LineItem__c > ();
        Map <Id, Apttus_Config2__AssetLineItem__c> AssetLineItemId = new Map < Id, Apttus_Config2__AssetLineItem__c > ();
        Set<Id> renewalOppty = new Set<Id>();
        Map < Id, Id > AssetRenewalLineItemId = new Map < Id, Id > ();
        Map<Id,Id> ConfigRenewId = new Map<Id,Id>();

        //Map store the line item, with assocaited asset line item when aseet gets activated
        List < Apttus_Config2__AssetLineItem__c > assetLineList = [SELECT Id,Apttus_Config2__AssetStatus__c,SLTC_Related_Opportunity__c, Apttus_Config2__PriceType__c,Apttus_CMConfig__AgreementLineItemId__r.Apttus_CMConfig__DerivedFromId__c, Apttus_Config2__LineType__c, Apttus_Config2__BundleAssetId__r.Apttus_Config2__AssetStatus__c FROM Apttus_Config2__AssetLineItem__c WHERE Apttus_Config2__AccountId__c IN : AccountId and Apttus_Config2__AssetStatus__c =: SLTC_Global_Constant.ACTIVATED /*AND Apttus_Config2__PriceType__c = 'Recurring'*/];
        if(assetLineList != null){
            For(Apttus_Config2__AssetLineItem__c assetLine: assetLineList) {
                if ((assetLine.Apttus_Config2__LineType__c == SLTC_Global_Constant.OPTION && (assetLine.Apttus_Config2__BundleAssetId__r.Apttus_Config2__AssetStatus__c == SLTC_Global_Constant.ACTIVATED || assetLine.Apttus_Config2__BundleAssetId__r.Apttus_Config2__AssetStatus__c == SLTC_Global_Constant.CANCELED)) || (assetLine.Apttus_Config2__LineType__c == SLTC_Global_Constant.PRODUCT_SERVICE)) {
                    AssetLineItemId.put(assetLine.Apttus_CMConfig__AgreementLineItemId__r.Apttus_CMConfig__DerivedFromId__c, assetLine);
                    renewalOppty.add(assetLine.SLTC_Related_Opportunity__c);
                }
            }
        }

        //query if already renewal oppty/quote exists
        List < Apttus_Proposal__Proposal__c > quote = [SELECT Id, Apttus_Proposal__ExpectedEndDate__c, Apttus_Proposal__ExpectedStartDate__c,Apttus_Proposal__Opportunity__r.SLTC_Renewal_Opportunity__c FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Account__c IN : AccountId AND Apttus_Proposal__Opportunity__r.Type =: SLTC_Global_Constant.RENEWAL AND Apttus_Proposal__Opportunity__r.SLTC_Renewal_Opportunity__c in : renewalOppty];
        if(!quote.isEmpty()){
            List < Apttus_Config2__ProductConfiguration__c > cart = [SELECT Id, Apttus_Config2__Status__c,Apttus_QPConfig__Proposald__c,SLTC_Related_Opportunity__c FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_QPConfig__Proposald__c IN : quote];
            for(Apttus_Config2__ProductConfiguration__c configId : cart){
                if(configId.Apttus_Config2__Status__c == 'Saved'){
                ConfigRenewId.put(configId.SLTC_Related_Opportunity__c,configId.Id);
                }
            }
            If(cart.isEmpty()){
                try {
                    cartIds = SLTC_CommonUtils.createCart(quote);
                } catch (Exception exec) {
                    String message = exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(); 
                    NI_Error_Logger.WriteToLog(message, ' AssetLineItem', 'AssetLineItemTriggerHandler-createRenewalline', 'INSERT');
                }
            }
        }
        
        List < Apttus_Config2__ProductConfiguration__c > newlyCartIds = [SELECT Id, Apttus_Config2__Status__c,SLTC_Related_Opportunity__c,Apttus_QPConfig__Proposald__c FROM Apttus_Config2__ProductConfiguration__c WHERE Id in : cartIds];
        for(Apttus_Config2__ProductConfiguration__c configId : newlyCartIds){
            ConfigRenewId.put(configId.SLTC_Related_Opportunity__c,configId.Id);
        }
        Set <Id> keys = AssetLineItemId.keySet();

        String str = 'SELECT ' + String.join(new List < String > (Schema.getGlobalDescribe().get(SLTC_Global_Constant.LINE_ITEM_OBJ).getDescribe().fields.getMap().keySet()), ',') + ' FROM Apttus_Config2__LineItem__c WHERE Id IN ';
        str += ':keys';

        //create the map of existing line item with asset line item of renewal cart( amend scenaior)
        List <Apttus_Config2__LineItem__c> lineItems = [SELECT Id, Apttus_Config2__AssetLineItemId__c from Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c =: cartIds];
        for(Apttus_Config2__LineItem__c li: lineItems) {
            AssetRenewalLineItemId.put(li.Apttus_Config2__AssetLineItemId__c, li.Id);
        }

        //Get the line item and clone it for renewal cart.
        List <Apttus_Config2__LineItem__c> lineItemList = Database.query(str); 

        for(Apttus_Config2__LineItem__c ali: lineItemList) {
            Apttus_Config2__LineItem__c li = new Apttus_Config2__LineItem__c();

            li = ali.clone(false, false, false, false);
            if(AssetLineItemId!=null && AssetLineItemId.get(ali.Id).SLTC_Related_Opportunity__c == quote[0].Apttus_Proposal__Opportunity__r.SLTC_Renewal_Opportunity__c){
                li.Apttus_Config2__ConfigurationId__c = ConfigRenewId.get(AssetLineItemId.get(ali.Id).SLTC_Related_Opportunity__c);
                li.Apttus_Config2__AssetLineItemId__c = AssetLineItemId.get(ali.Id).Id;
                li.Apttus_Config2__IsHidden__c = true;
                if(AssetLineItemId.get(ali.Id).Apttus_Config2__AssetStatus__c==SLTC_Global_Constant.CANCELED){
                    li.Apttus_Config2__LineStatus__c = SLTC_Global_Constant.CANCELED;
                }
                else{
                    li.Apttus_Config2__LineStatus__c = SLTC_Global_Constant.RENEWED;
                }
                li.Apttus_Config2__StartDate__c = quote[0].Apttus_Proposal__ExpectedStartDate__c;
                li.Apttus_Config2__EndDate__c = quote[0].Apttus_Proposal__ExpectedEndDate__c;
                if (AssetRenewalLineItemId.ContainsKey(AssetLineItemId.get(ali.Id).Id)) {
                    li.Id = AssetRenewalLineItemId.get(AssetLineItemId.get(ali.Id).Id);
                }
                finalList.add(li);
            }
        }
        if (!finalList.isEmpty()) {
            try {
                UPSERT finalList;
            } catch (Exception exec) {
                String message = exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(); 
                NI_Error_Logger.WriteToLog(message, ' AssetLineItem', 'AssetLineItemTriggerHandler-createRenewalline', 'UPSERT');
            }
        }
       
        if(cartIds!=null){
            saveConfiguration(cartIds);
        }
    }


    //After adding the line item, save the configuration/cart
    @TestVisible
    private static void saveConfiguration(List<Id> cartIds) {
        List<Apttus_Config2__ProductConfiguration__c> prodConfigList = new List<Apttus_Config2__ProductConfiguration__c>();
        List < Apttus_Config2__ProductConfiguration__c> config = [SELECT Apttus_Config2__Status__c FROM Apttus_Config2__ProductConfiguration__c WHERE Id =: cartIds];
        for(Apttus_Config2__ProductConfiguration__c cart : config){
            cart.Apttus_Config2__Status__c = 'Saved';
            cart.SLTC_Renewal_Configuration__c = true;
            prodConfigList.add(cart);
        }
        try {
            if(!prodConfigList.isEmpty()){
                UPDATE prodConfigList;
            }
        }  catch (Exception exec) {
            String message = exec.getTypeName() +':'+exec.getLineNumber() +':message'+ exec.getMessage(); 
            NI_Error_Logger.WriteToLog(message, ' AssetLineItem', 'AssetLineItemTriggerHandler-saveConfiguration', 'UPDATE');
        }
    }
}