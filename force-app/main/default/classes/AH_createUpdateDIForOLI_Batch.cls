/****************************************************************************************
Name            : AH_createUpdateDIForOLI_Batch Class 
Author          : Shashikant Nikam
Created Date    : 10/23/2019 
Last Mod Date   : 02/07/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Batch class for createUpdateDIForOLI_New method of AH_Opportunity_FUNCTIONS class
				: 
				: 
******************************************************************************************/

global class AH_createUpdateDIForOLI_Batch implements Database.Batchable <sObject>,Database.AllowsCallouts, Database.Stateful 
{
    Boolean flag;
    Set<ID> accountIdSet1 = new Set<ID>();
    Set<ID> optyIdSet1 = new Set<ID>();
    Set<ID> AccIdSet_forLink1 = new Set<ID>();
    Set<ID> actIdSetThisOpp1 = new Set<ID>();
    List<Opportunity> opprList = new List<Opportunity>();
    Map<Id, Opportunity> opptyMap1 = new Map<Id, Opportunity>();
    public Boolean oppLineupdateFlag;
    
    public AH_createUpdateDIForOLI_Batch(List<Opportunity> oppList, boolean processChildDi, Set<Id> accountIdSe, Set<Id> optyIdSe, Set<Id> AccIdSet_forLin, Set<Id> actIdSetThisOp, Map<Id, Opportunity> opptyMa) 
    {
        oppLineupdateFlag = false;
		flag = processChildDi;
        opprList.addAll(oppList);
        accountIdSet1.addAll(accountIdSe);
        optyIdSet1.addAll(optyIdSe);
        AccIdSet_forLink1.addAll(AccIdSet_forLin);
        actIdSetThisOpp1.addAll(actIdSetThisOpp1);
        
        opptyMap1 = opptyMa.clone();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {

        system.debug('in start method : '+optyIdSet1);
        String retQuery = 'SELECT Id, Name, Account__c, Opportunity__c, Product__c, Quantity__c, '+
					'Product__r.DI_Index__r.Name,  Product__r.ProductCode, Deployment_Instance__c '+
					'FROM AH_Account_Product__c '+
                    'WHERE Opportunity__c IN: optyIdSet1 '+
                    'AND (Product__r.DI_Index__c != null AND Product__r.DI_Index__r.Name != \'N/A\')';
        
        system.debug('retQuery : '+retQuery); 
        
        return Database.getQueryLocator(retQuery);
    }
    
    
    global void execute(Database.BatchableContext bc , List<AH_Account_Product__c> accProdList)
    {
        createUpdateDIForOLI_New(opprList, flag, accountIdSet1, optyIdSet1, AccIdSet_forLink1, actIdSetThisOpp1, opptyMap1, accProdList);
    }
    
    
    global void finish(Database.BatchableContext bc)
    {
        system.debug('in finish method.. AH_createUpdateDIForOLI_Batch..'+optyIdSet1);
        String query = 'SELECT ID '+
					'FROM AH_Account_Product__c '+
                    'WHERE Opportunity__c IN: optyIdSet1 '+
                    'AND (Product__r.DI_Index__c != null AND Product__r.DI_Index__r.Name != \'N/A\')';
        
        system.debug('finish method query : '+query); 
        List<AH_Account_Product__c> acProdList = new List<AH_Account_Product__c>();
        acProdList = Database.query(query);
        
        if(acProdList.isEmpty())
        {
            createUpdateDIForOLI_New(opprList, flag, accountIdSet1, optyIdSet1, AccIdSet_forLink1, actIdSetThisOpp1, opptyMap1, acProdList);
        }
        
    }
    
    
    public void createUpdateDIForOLI_New(List<Opportunity> newTrigger, boolean processChildDi, Set<Id> accountIdSet, Set<Id> optyIdSet, Set<Id> AccIdSet_forLink, Set<Id> actIdSetThisOpp, Map<Id, Opportunity> opptyMap, List<AH_Account_Product__c> accountProdList) 
    {
        
        system.debug(' *** ENTERING NI_Opportunity_TriggerHandler.createUpdateDIForOLI_New() - QUERIES ISSUED = ' + Limits.getQueries());
        
        //Set<Id> optyIdSet = new Set<Id>();
        //VARIABLE TO HOLD THE VALUE OF OLI RECORDS
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        //HOLD ALL THE DI RECORDS
        Map<String, Asset> existingAssetMap = new Map<String, Asset>();
        //GET ALL ACCOUNT IDS
        //Set<Id> accountIdSet = new Set<Id>();
        //HOLD ALL DI INDEX IDS
        Set<Id> diIndexSet = new Set<Id>();
        //HOLD ALL THE PRODUCT IDS RELATED TO OLI
        Set<String> productIdSet = new Set<String>();
        //VARIABLE TO HOLD THE VALUE OF OPPORTUNITY IDS RELATED TO OLIE RECORD
        Set<Id> opptyIdSet = new Set<Id>();
        //HOLD OPPORTUNITY RECORDS
        //Map<Id, Opportunity> opptyMap;
        //HOLD PRODUCT RECORDS
        Map<Id, Product2> product2Map;
        
        system.debug('accountIdSet top : '+ accountIdSet);
        system.debug('optyIdSet top : '+optyIdSet);
        system.debug('AccIdSet_forLink 1 : '+AccIdSet_forLink);
        system.debug('actIdSetThisOpp  :' + actIdSetThisOpp);
        system.debug('opptyMap  SIZE :' + opptyMap.size());
        
        //COMMENTED EVEN IF THERE ARE RELATED ACCOUNTS, DI SHOULD CREATE ON PRIMARY ACCOUNT AS WELL(AS PER EXISTING BEHAVIOUR)
        oppLineItemList = [select Id, Name, OpportunityId, Product2Id, Product2.DI_Index__r.Name, 
                           DeploymentInstance__c, ProductCode, Quantity 
                           from OpportunityLineItem 
                           Where OpportunityId IN: optyIdSet   
                           AND (Product2.DI_Index__c != null AND Product2.DI_Index__r.Name != 'N/A')];
        
        system.debug('oppLineItemList Size  :' + oppLineItemList.size());
        
        
        //LOOP THROUGH ALL OLI RECORDS AND GET PRODUCT IDS
        if (oppLineItemList != null && (!oppLineItemList.isEmpty()))
        {
            for (OpportunityLineItem oliObj: oppLineItemList)
            {
                productIdSet.add(oliObj.Product2Id);
            }
        }
        
        system.debug('productIdSet :' + productIdSet);
        system.debug('accountProdList : '+ accountProdList);
        
        //LOOP THROUGH ALL AH_Account_Product__c(RELATED OLI) RECORDS AND GET PRODUCT IDS
        if (accountProdList != null && (!accountProdList.isEmpty()))
        {
            accountIdSet = new Set<Id>();
            for (AH_Account_Product__c accProd: accountProdList)
            {
                productIdSet.add(accProd.Product__c);
                accountIdSet.add(accProd.Account__c);
                AccIdSet_forLink.add(accProd.Account__c);
            }
        }
        
        system.debug('productIdSet  :' + productIdSet);
        system.debug('accountIdSet  :' + accountIdSet);
        system.debug('AccIdSet_forLink  :' + AccIdSet_forLink);

        //GET ALL PRODUCT VALUES FROM Product2 RELATED TO OLI OR AH_Account_Product__c(RELATED OLI)
        if (productIdSet != null)
        {
            product2Map = new Map<Id, Product2>([SELECT Id, ProductCode, DI_Index__c, DI_DefaultStatus__c,
                                                 DI_Priority__c,Product_Group__c,Product_Line__c FROM Product2 
                                                 WHERE Id IN : productIdSet
                                                 AND (DI_Index__c != null AND DI_Index__r.Name != 'N/A')]);
            system.debug('product2Map SIZE  :' + product2Map.size());
            
            for(Product2 prd: product2Map.values())
            {
                //ADD DI_Index__c TO SET
                diIndexSet.add(prd.DI_Index__c);
            }
        }
        
        system.debug('diIndexSet : ' + diIndexSet);
        
        //GET ALL EXISTING DI RECORDS RELATED TO ACCOUNT AND DI INDEX
        Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, AccountId, Product2Id, DI_Index_Name__c, Product2.DI_Index__c, InstallDate, 
                                                      Status, Product2.DI_Priority__c, Product_Group__c,Purchase_Date__c, Purchased_Product__c, CreatedDate
                                                      FROM Asset 
                                                      WHERE AccountId IN : accountIdSet 
                                                      AND Product2.DI_Index__c IN : diIndexSet]);

        system.debug('assetMap SIZE  :' + assetMap.size());
        
        //ADD VALUES TO existingAssetMap VARIABLE
        for (Asset asObj: assetMap.values())
        {
            existingAssetMap.put(asObj.AccountId + '' + asObj.Product2.DI_Index__c, asObj);
        }
        
        system.debug('existingAssetMap  SIZE  :' + existingAssetMap.size());
        
        //VARIABLE TO HOLD OLD PRIORITIES OF PRODUCT ADDED/UPDATED TO DI
        Map<String, Decimal> oldRecordPriorityMap = new Map<String, Decimal>();
        //VARIABLE TO ADD/UPDATE NEW DI RECORDS
        Map<String, Asset> assetToUpsertMap = new Map<String, Asset>();
        Id product2Id = null;
        String status = null;
        Date installDate = null;
        Date purchaseDate = null;//new
        Asset assetObject = new Asset();
        
        //CHECK IF OPPORTUNITY LINE ITEMS IS NOT EMPTY
        if (oppLineItemList != null && (!oppLineItemList.isEmpty()))
        {
            // ITERATE OVER OLI RECORDS
            for (OpportunityLineItem oli : oppLineItemList)
            {
                //INITIALIZE LOCAL VARIABLES
                product2Id = null;
                status = null;
                installDate = null;
                purchaseDate = null;
                assetObject = new Asset();
                
                //CHECK IF ASSET ID ALREADY PRESENT FOR SAME ACCOUNT AND DI INDEX
                if(existingAssetMap.keySet().contains((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c))
                {
                    system.debug('in if..');
                    system.debug('opptyMap.get(oli.OpportunityId).AccountId : '+opptyMap.get(oli.OpportunityId).AccountId);
                    system.debug('product2Map.get(oli.Product2Id).DI_Index__c : '+product2Map.get(oli.Product2Id).DI_Index__c);
                    
                    //ASSET IS PRESENT FOR NEW RECORD, PROCESS ACCORDINGLY
                    Asset extObj = (existingAssetMap.get((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c));
                    system.debug('extObj'+extObj);
                    if (extObj.InstallDate == null && extObj.Status == 'Installed')
                    {
                        installDate = extObj.CreatedDate.date(); //new
                    }
                    if (extObj.Purchase_Date__c == null &&
                        (extObj.Status == 'Installed' || extObj.Status == 'Purchased' ))
                    {
                        system.debug('in purchase date = null');
                        purchaseDate = extObj.CreatedDate.date(); //new
                    }
                    if (extObj.Purchase_Date__c == null && extObj.Status == 'Inactive')
                    {
                        purchaseDate = (opptyMap.get(oli.OpportunityId)).CloseDate;
                    }
                    
                    system.debug('oli.Product2Id : '+oli.Product2Id);
                    system.debug('extObj.Product2Id : '+extObj.Product2Id);
                    
                    //CHECK IF PRODUCT IS DIFFERENT
                    if (oli.Product2Id != extObj.Product2Id)
                    {
                        //CHECK PRODUCT PRIORITY AND UPDATE PRODUCT ACCORDINGLY
                        Boolean isGreaterPriority = (product2Map.get(oli.Product2Id).DI_Priority__c >= assetMap.get(extObj.Id).Product2.DI_Priority__c);
                        Boolean isLessPriority = (product2Map.get(oli.Product2Id).DI_Priority__c < assetMap.get(extObj.Id).Product2.DI_Priority__c);
                        if ((extObj.Status == 'Installed' && product2Map.get(oli.Product2Id).DI_DefaultStatus__c == 'Installed') && isGreaterPriority)
                        {
                            product2Id = oli.Product2Id;
                            status = 'Installed';
                            //COMPARE THE STATUS OS ASSET AND PRODUCT DEFAULT STATUS
                            //UPDATE EXISTING DI RECORD WITH NEW VALUES AND ADD TO assetToUpsertMap VARIABLE
                            Asset assetObj = AH_Opportunity_FUNCTIONS.createUpdateAsset(extObj.Id, null, (opptyMap.get(oli.OpportunityId).AccountId), product2Id, status, installDate, purchaseDate, null);
                            assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: ' + oli.Name;
                            assetObject = assetObj;
                            assetToUpsertMap.put((opptyMap.get(oli.OpportunityId).AccountId) + '' + product2Map.get(oli.Product2Id).DI_Index__c, assetObj);
                        }
                        
                        //IF PRODUCT'S DEFAULT STATUS IS 'Purchased', UPDATE "Purchased Product", "Status" AND "Install Date" FIELDS
                        else if(extObj.Status == 'Installed' && (product2Map.get(oli.Product2Id).DI_DefaultStatus__c == 'Purchased') && isGreaterPriority)
                        {
                            Asset assetObj = AH_Opportunity_FUNCTIONS.createUpdateAsset(extObj.Id, null, (opptyMap.get(oli.OpportunityId).AccountId), null, null, installDate, purchaseDate, null);
                            assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: ' + oli.Name;
                            assetObj.Purchased_Product__c = oli.Product2Id;
                            assetObj.Purchase_Status__c = 'Purchased';
                            assetObj.Opportunity__c = oli.OpportunityId;
                            assetObject = assetObj;
                            assetToUpsertMap.put((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c, assetObj);
                        }
                        else if(extObj.Status == 'Installed' && (product2Map.get(oli.Product2Id).DI_DefaultStatus__c == 'Purchased') && isLessPriority )
                        {
                           Asset assetObj = AH_Opportunity_FUNCTIONS.createUpdateAsset(extObj.Id, null, (opptyMap.get(oli.OpportunityId).AccountId), null, null, installDate, purchaseDate, null);
                            assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: '+oli.Name;
                            assetObject = assetObj;
                            assetToUpsertMap.put((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c, assetObj);
                        }
                        else if(extObj.Status == 'Installed' && (product2Map.get(oli.Product2Id).DI_DefaultStatus__c == 'Installed') && isLessPriority )
                        {
                          Asset assetObj = AH_Opportunity_FUNCTIONS.createUpdateAsset(extObj.Id, null, (opptyMap.get(oli.OpportunityId).AccountId), null, null, installDate, purchaseDate, null);
                            assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: ' + oli.Name;
                            assetObject = assetObj;
                            assetToUpsertMap.put((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c, assetObj);
                        }
                        else if(extObj.Status == 'Inactive' && product2Map.get(oli.Product2Id).DI_DefaultStatus__c != 'Inactive')
                        {
                            status = 'Purchased';
                            product2Id = oli.Product2Id;
                            Asset assetObj = AH_Opportunity_FUNCTIONS.createUpdateAsset(extObj.Id, null, null, product2Id, status, null, purchaseDate, null);
                            assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: '+oli.Name;
                            assetObject = assetObj;
                            assetToUpsertMap.put((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c, assetObj);
                        } //FOR 'Purchased' STATUS(ADDED BY SUPRIYA)
                        else if(extObj.Status == 'Purchased' && product2Map.get(oli.Product2Id).DI_DefaultStatus__c != null)
                        {
                            system.debug('in purchased');
                            Asset assetObj = AH_Opportunity_FUNCTIONS.createUpdateAsset(extObj.Id, null, (opptyMap.get(oli.OpportunityId).AccountId), null, null, null, purchaseDate, null);
                            assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: '+oli.Name;
                            assetObject = assetObj;
                            assetToUpsertMap.put((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c, assetObj);
                        }
                    }
                    
                    if (assetObject.Id == null)
                    {
                        if (extObj.Status == 'Inactive')
                        {
                             status = product2Map.get(oli.Product2Id).DI_DefaultStatus__c;
                        }
                        system.debug('if assetObject = null');
                        Asset assetObj = AH_Opportunity_FUNCTIONS.createUpdateAsset(extObj.Id, null, (opptyMap.get(oli.OpportunityId).AccountId), null, status, installDate, purchaseDate, null);
                        if (extObj.Status == 'Inactive' && assetObj.Status.equals('Installed'))
                        {
                           assetObj.Activation_Date__c = extObj.CreatedDate.date(); //new
                        }
                        assetToUpsertMap.put((opptyMap.get(oli.OpportunityId).AccountId) + '' + product2Map.get(oli.Product2Id).DI_Index__c, assetObj);
                    }
                }
                else
                {
                    system.debug('in else...');
                    system.debug('opptyMap.get(oli.OpportunityId).AccountId : '+opptyMap.get(oli.OpportunityId).AccountId);
                    system.debug('product2Map.get(oli.Product2Id).DI_Index__c : '+product2Map.get(oli.Product2Id).DI_Index__c);
                    
                    status = null;
                    
                    //CHECK THE DEFAULT STATUS OF PRODUCT
                    if(product2Map.get(oli.Product2Id).DI_DefaultStatus__c == 'Installed')
                    {
                        status = 'Installed';
                        installDate = Date.Today(); //(opptyMap.get(oli.OpportunityId)).CloseDate;
                        purchaseDate = (opptyMap.get(oli.OpportunityId)).CloseDate;
                    }
                    else
                    {
                        status = 'Purchased';
                        purchaseDate = (opptyMap.get(oli.OpportunityId)).CloseDate;
                    }
                    
                    //CREATE NEW ASSET OBJECT TO INSERT
                    Asset assetObj = AH_Opportunity_FUNCTIONS.createUpdateAsset(null, oli.ProductCode, (opptyMap.get(oli.OpportunityId).AccountId), oli.Product2Id, status, installDate, purchaseDate, null);
                    if (assetObj.Status.equals('Installed'))
                    {
                        assetObj.Activation_Date__c = Date.today();
                    }
                    assetObj.Integration_User_Source__c = 'Created per Opportunity Synchronization for line item: ' + oli.Name;
                    
                    //UPDATE THE PRODUCT ON NEW DI WITH HIGHEST PRIORITY
                    if (assetToUpsertMap.containsKey((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c))
                    {
                        if (oldRecordPriorityMap.get((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c) < product2Map.get(assetObj.Product2Id).DI_Priority__c)
                        {
                            oldRecordPriorityMap.remove((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c);
                            oldRecordPriorityMap.put((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c, product2Map.get(assetObj.Product2Id).DI_Priority__c);
                            assetToUpsertMap.remove((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c);
                            assetToUpsertMap.put((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c, assetObj);
                        }
                    }
                    else
                    {
                        assetToUpsertMap.put((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c, assetObj);
                        oldRecordPriorityMap.put((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c, product2Map.get(assetObj.Product2Id).DI_Priority__c);
                    }
                    
                }
            }
        }
        
        if (accountProdList != null && (!accountProdList.isEmpty()))
        {
            for (AH_Account_Product__c accProdObj : accountProdList)
            {
                
                system.debug('accProdObj : '+accProdObj);
                // INITIALIZE LOCAL VARIABLES
                product2Id = null;
                status = null;
                installDate = null;
                purchaseDate = null;
                assetObject = new Asset();

                system.debug('in if..');
                system.debug('accProdObj.Account__c : '+accProdObj.Account__c);
                system.debug('product2Map.get(String.ValueOf(accProdObj.Product__c)).DI_Index__c : '+product2Map.get(String.ValueOf(accProdObj.Product__c)).DI_Index__c);
                
                // CHECK IF ASSET ID ALREADY PRESENT FOR SAME ACCOUNT AND DI INDEX
                if ((!existingAssetMap.isEmpty()) && 
                    existingAssetMap.keySet().contains((String.ValueOf(accProdObj.Account__c)) + '' + product2Map.get(String.ValueOf(accProdObj.Product__c)).DI_Index__c))
                {
                    //ASSET IS PRESENT FOR NEW RECORD, PROCESS ACCORDINGLY
                    Asset extObj = (existingAssetMap.get((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c));
                    system.debug('extObj'+extObj);
                    if (extObj.InstallDate == null && extObj.Status == 'Installed')
                    {
                        installDate = extObj.CreatedDate.date(); //new
                    }
                    if (extObj.Purchase_Date__c == null &&
                       (extObj.Status == 'Installed' || extObj.Status == 'Purchased'))
                    {
                           system.debug('in purchase date = null');
                           purchaseDate = extObj.CreatedDate.date(); //new
                    }
                    if (extObj.Purchase_Date__c == null && extObj.Status == 'Inactive')
                    {
                        purchaseDate = (opptyMap.get(accProdObj.Opportunity__c)).CloseDate;
                    }
                    
                    system.debug('accProdObj.Product__c : '+accProdObj.Product__c);
                    system.debug('extObj.Product2Id : '+extObj.Product2Id);
                    
                    //CHECK IF PRODUCT IS DIFFERENT
                    if (accProdObj.Product__c != extObj.Product2Id)
                    {
                        
                        //CHECK PRODUCT PRIORITY AND UPDATE PRODUCT ACCORDINGLY
                        Boolean isGreaterPriority = (product2Map.get(accProdObj.Product__c).DI_Priority__c >= assetMap.get(extObj.Id).Product2.DI_Priority__c);
                        Boolean isLessPriority = (product2Map.get(accProdObj.Product__c).DI_Priority__c < assetMap.get(extObj.Id).Product2.DI_Priority__c);
                        
                        if ((extObj.Status == 'Installed' && product2Map.get(accProdObj.Product__c).DI_DefaultStatus__c == 'Installed') && isGreaterPriority)
                        {
                            product2Id = accProdObj.Product__c;
                            status = 'Installed';
                            //COMPARE THE STATUS OS ASSET AND PRODUCT DEFAULT STATUS
                            //UPDATE EXISTING DI RECORD WITH NEW VALUES AND ADD TO assetToUpsertMap VARIABLE
                            Asset assetObj = AH_Opportunity_FUNCTIONS.createUpdateAsset(extObj.Id, null, accProdObj.Account__c, product2Id, status, installDate, purchaseDate, null);
                            assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: '+accProdObj.Name;
                            assetObject = assetObj;
                            assetToUpsertMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, assetObj);
                        }
                        //IF PRODUCT'S DEFAULT STATUS IS 'Purchased', UPDATE "Purchased Product", "Status" AND "Install Date" FIELDS
                        else if (extObj.Status == 'Installed' && (product2Map.get(accProdObj.Product__c).DI_DefaultStatus__c == 'Purchased') && isGreaterPriority)
                        {
                            //UPDATE EXISTING DI RECORD
                            Asset assetObj = AH_Opportunity_FUNCTIONS.createUpdateAsset(extObj.Id, null, accProdObj.Account__c, null, null, installDate, purchaseDate, null);
                            assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: ' + accProdObj.Name;
                            assetObj.Purchased_Product__c = accProdObj.Product__c;
                            assetObj.Purchase_Status__c = 'Purchased';
                            assetObj.Opportunity__c = accProdObj.Opportunity__c;
                            assetObject = assetObj;
                            assetToUpsertMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, assetObj);
                        }
                        else if (extObj.Status == 'Installed' && (product2Map.get(accProdObj.Product__c).DI_DefaultStatus__c == 'Purchased') && isLessPriority)
                        {
                           Asset assetObj = AH_Opportunity_FUNCTIONS.createUpdateAsset(extObj.Id, null, accProdObj.Account__c, null, null, installDate, purchaseDate, null);
                            assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: '+accProdObj.Name;
                            assetObject = assetObj;
                            assetToUpsertMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, assetObj);
                        }
                        else if (extObj.Status == 'Installed' && (product2Map.get(accProdObj.Product__c).DI_DefaultStatus__c == 'Installed') && isLessPriority)
                        {
                            Asset assetObj = AH_Opportunity_FUNCTIONS.createUpdateAsset(extObj.Id, null, accProdObj.Account__c, null, null, installDate, purchaseDate, null);
                            assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: '+accProdObj.Name;
                            assetObject = assetObj;
                            assetToUpsertMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, assetObj);
                        }
                        else if (extObj.Status == 'Inactive' && product2Map.get(accProdObj.Product__c).DI_DefaultStatus__c != 'Inactive')
                        {
                            status = 'Purchased';
                            product2Id = accProdObj.Product__c;
                            Asset assetObj = AH_Opportunity_FUNCTIONS.createUpdateAsset(extObj.Id, null, null, product2Id, status, null, purchaseDate, null);
                            assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: ' + accProdObj.Name;
                            assetObject = assetObj;
                            assetToUpsertMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, assetObj);
                        }	//FOR 'Purchased' STATUS
                        else if (extObj.Status == 'Purchased' && product2Map.get(accProdObj.Product__c).DI_DefaultStatus__c != null)
                        {
                            Asset assetObj = AH_Opportunity_FUNCTIONS.createUpdateAsset(extObj.Id, null, accProdObj.Account__c, null, null, null, purchaseDate, null);
                            assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: '+accProdObj.Name;
                            assetObject = assetObj;
                            assetToUpsertMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, assetObj);
                        }
                    }
                    
                    if (assetObject.Id == null)
                    {
                        if (extObj.Status == 'Inactive')
                        {
                             status = product2Map.get(accProdObj.Product__c).DI_DefaultStatus__c;
                        }
                        Asset assetObj = AH_Opportunity_FUNCTIONS.createUpdateAsset(extObj.Id, null, accProdObj.Account__c, null, status, installDate, purchaseDate, null);
                        if (extObj.Status == 'Inactive' && assetObj.Status.equals('Installed'))
                        {
                           assetObj.Activation_Date__c = extObj.CreatedDate.date(); 
                        }
                        assetToUpsertMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, assetObj);
                    }
                }
                else
                {
                    status = null;
                    //CHECK THE DEFAULT STATUS OF PRODUCT
                    if (product2Map.get(accProdObj.Product__c).DI_DefaultStatus__c == 'Installed')
                    {
                        status = 'Installed';
                        installDate = Date.Today(); //(opptyMap.get(oli.OpportunityId)).CloseDate;
                        purchaseDate = (opptyMap.get(accProdObj.Opportunity__c)).CloseDate;
                    }
                    else
                    {
                        status = 'Purchased';
                        purchaseDate = (opptyMap.get(accProdObj.Opportunity__c)).CloseDate;
                    }
                    
                    //CREATE A NEW ASSET OBJECT TO INSERT
                    
                    system.debug('in else accProdObj.Product__c : '+accProdObj.Product__c);
                    system.debug('in else accProdObj.Account__c : '+accProdObj.Account__c);
                    
                    Asset assetObj = AH_Opportunity_FUNCTIONS.createUpdateAsset(null, accProdObj.Product__c, accProdObj.Account__c, accProdObj.Product__c, status, installDate, purchaseDate, null);
                    if (assetObj.Status.equals('Installed'))
                    {
                        assetObj.Activation_Date__c = Date.today();
                    }
                    assetObj.Integration_User_Source__c = 'Created per Opportunity Synchronization for line item: ' + accProdObj.Name;
                    //UPDATE THE PRODUCT ON NEW DI WITH HIGHEST PRIORITY
                    if (assetToUpsertMap.containsKey((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c))
                    {
                        system.debug('in first if...');
                        if(oldRecordPriorityMap.get((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c) < product2Map.get(assetObj.Product2Id).DI_Priority__c)
                        {
                            
                            system.debug('in inner if...');
                            
                            oldRecordPriorityMap.remove((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c);
                            oldRecordPriorityMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, product2Map.get(assetObj.Product2Id).DI_Priority__c);
                            assetToUpsertMap.remove((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c);
                            assetToUpsertMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, assetObj);
                        }
                    }
                    else
                    {
                        system.debug('in else...');
                        assetToUpsertMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, assetObj);
                        oldRecordPriorityMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, product2Map.get(assetObj.Product2Id).DI_Priority__c);
                    }
                    system.debug(String.ValueOf(accProdObj.Account__c)+''+product2Map.get(accProdObj.Product__c).DI_Index__c +' => ' + assetToUpsertMap.get((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c));
                }
            }
        }
        
        // ADDED BY SHAHSIKANT ON 08/10/2018
        Set<String> aliSet = new Set<String>();
        Set<String> DISet = new Set<String>();
        Map<String, DI_to_Activity_Line_Item__c> junctionObjMap = new Map<String, DI_to_Activity_Line_Item__c>();
        Set<ID> prIdSet = new Set<Id>();
        
        // INSERT INTO DI TO ACTIVITY LINE ITEM OBJECT 
        for (String str : productIdSet)
        {
            prIdSet.add(str);
        }

        system.debug('prIdSet : '+prIdSet);
        
        Set<string> diToProcess = new Set<string>();
        
        // ADDED BY SHASHIKANT ON 08/29/2018
        Map<String, Map<Integer,String>> ali_map_WithOpp = new Map<String, Map<Integer,String>>();
        String ali_key1 = '';
        
        
        List<Asset> childDiList = new List<Asset>();
        
        system.debug('assetToUpsertMap SIze  :' + assetToUpsertMap.size());
        if (!assetToUpsertMap.values().isEmpty())
        {
            //UPSERT DEPLOYMENT INSTANCE RECORDS
            Schema.SObjectField fld = Asset.Id;
            Database.UpsertResult[] upsertResultList = Database.upsert(assetToUpsertMap.values(), fld, false);

            for (Database.UpsertResult upsertRecs : upsertResultList)
            {
                if (upsertRecs.isCreated() && upsertRecs.isSuccess())
                {
                    diToProcess.add(upsertRecs.getId());
                }
            }
     		
            system.debug(' diToProcess :' + diToProcess);
            system.debug(' diToProcess size :' + diToProcess.size());
            
            // ADDED BY SHAHSIKANT ON 08/10/2018
            // QUERY ON DEPLOYMENT INSTANCE & CREATE DI_MAP USING ACCOUNT ID & PRODUCT ID
            Map<String, Asset> di_map = new Map<String, Asset>();
            di_map = AH_Opportunity_FUNCTIONS.fetchDeploymentInstance(AccIdSet_forLink, prIdSet);
            
            system.debug('di_map  :' + di_map);
            // QUREY ON ACTIVITY LINE ITEM & CREATE ALI_MAP 
            Integer i = 1;
            Map<String, Map<Integer, String>> ali_map = new Map<String, Map<Integer, String>>();
            String ali_key = '';
            for (Activity_Line_Item__c ALI: [SELECT Id, Account__c, Product__c, Opportunity__c 
                                             FROM Activity_Line_Item__c 
                                             WHERE Account__c IN : AccIdSet_forLink 
                                             AND Opportunity__c IN : optyIdSet 
                                             AND Product__c IN: productIdSet])
            {   
                // CREATE "ACCOUNT | PRODUCT => ALI" 	MAP 
                ali_key = ALI.Account__c + '|' + ALI.Product__c;
                
                if (ali_map != NULL && ali_map.containsKey(ali_key))
                {
                    Map<Integer, String> iMap = new Map<Integer, String>();
                    iMap = ali_map.get(ali_key);
                    iMap.put(i, ALI.id);
                    ali_map.put(ali_key, iMap);
                }
                else 
                {
                    Map<Integer, String> innerMap = new Map<Integer, String>();
                    innerMap.put(i, ALI.id);
                    ali_map.put(ali_key, innerMap);
                }

                // CREATE "OPPORTUNITY | PRODUCT => ALI" 	MAP 
                ali_key1 = ALI.Opportunity__c +'|'+ ALI.Product__c;
                
                if (ali_map_WithOpp != NULL && ali_map_WithOpp.containsKey(ali_key1))
                {
                    
                    Map<Integer,String> iMap = new Map<Integer,String>();
                    iMap = ali_map_WithOpp.get(ali_key1);
                    iMap.put(i, ALI.id);
                    ali_map_WithOpp.put(ali_key1,iMap);
                }
                else 
                {
                    Map<Integer,String> innerMap = new Map<Integer,String>();
                    innerMap.put(i, ALI.id);
                    ali_map_WithOpp.put(ali_key1,innerMap);
                }
                
                i++;
            }
            
            system.debug('ali_map  :' + ali_map);
            // CREATE MAP OF JUNCTION OBJECT 
            if (!ali_map.isEmpty()) 
            {
                for (String key :di_map.keyset()) 
                {
                    if (ali_map.containsKey(key))
                    {
                        for (String iVal : ali_map.get(key).values())
                        {
                            DI_to_Activity_Line_Item__c juncObj = new DI_to_Activity_Line_Item__c();
                            juncObj.Activity_Line_Item__c = iVal;
                            juncObj.Deployment_Instance__c = di_map.get(key).id;
                            
                            junctionObjMap.put(iVal + '_' + juncObj.Deployment_Instance__c, juncObj);
                            
                            aliSet.add(juncObj.Activity_Line_Item__c);
                            DISet.add(juncObj.Deployment_Instance__c);
                        }
                    }
                }
            }

        }
        
        system.debug('junctionObjMap : '+junctionObjMap);
        
        //ITERATE OVER OPPORTUNITY LINE ITEMS AND UPDATE THEIR DEPLOYMENT INSTANCE
        for (Integer i = 0; i < oppLineItemList.size(); i++)
        {
            if (assetToUpsertMap.containsKey((opptyMap.get(oppLineItemList[i].OpportunityId).AccountId)+''+product2Map.get(oppLineItemList[i].Product2Id).DI_Index__c))
            {
                system.debug(oppLineItemList[i].id+'in first if : '+assetToUpsertMap.get((opptyMap.get(oppLineItemList[i].OpportunityId).AccountId)+''+product2Map.get(oppLineItemList[i].Product2Id).DI_Index__c).Id);
                oppLineItemList[i].DeploymentInstance__c = assetToUpsertMap.get((opptyMap.get(oppLineItemList[i].OpportunityId).AccountId)+''+product2Map.get(oppLineItemList[i].Product2Id).DI_Index__c).Id;
            }
            else if (existingAssetMap.containsKey((opptyMap.get(oppLineItemList[i].OpportunityId).AccountId)+''+product2Map.get(oppLineItemList[i].Product2Id).DI_Index__c))
            {
                system.debug(oppLineItemList[i].id+'in else if : '+existingAssetMap.get((opptyMap.get(oppLineItemList[i].OpportunityId).AccountId)+''+product2Map.get(oppLineItemList[i].Product2Id).DI_Index__c).Id);
                oppLineItemList[i].DeploymentInstance__c = existingAssetMap.get((opptyMap.get(oppLineItemList[i].OpportunityId).AccountId)+''+product2Map.get(oppLineItemList[i].Product2Id).DI_Index__c).Id;
            } 
        }

        //ITERATE OVER AH_Account_Product__c(RELATED OLI) AND UPDATE THEIR DEPLOYMENT INSTANCE
        for (Integer i = 0; i < accountProdList.size(); i++)
        { 

            if (assetToUpsertMap.containsKey((String.ValueOf(accountProdList[i].Account__c))+''+product2Map.get(accountProdList[i].Product__c).DI_Index__c))
            {
                accountProdList[i].Deployment_Instance__c = assetToUpsertMap.get((String.ValueOf(accountProdList[i].Account__c))+''+product2Map.get(accountProdList[i].Product__c).DI_Index__c).Id;
            }
            else if(existingAssetMap.containsKey((String.ValueOf(accountProdList[i].Account__c))+''+product2Map.get(accountProdList[i].Product__c).DI_Index__c))
            {
                accountProdList[i].Deployment_Instance__c = existingAssetMap.get((String.ValueOf(accountProdList[i].Account__c))+''+product2Map.get(accountProdList[i].Product__c).DI_Index__c).Id;
            } 
            system.debug('Related Opp line item : '+accountProdList[i].Name +' => '+accountProdList[i].id +' => '+accountProdList[i].Deployment_Instance__c);
        }

        system.debug('upserting oppLineItemList 1 : '+oppLineItemList);
        system.debug('oppLineupdateFlag : '+oppLineupdateFlag);
        
        //UPDATE RECORDS
        try
        {
            if (!accountProdList.isEmpty())
            {
                upsert accountProdList;
            }
            //if (!oppLineItemList.isEmpty() )
			if (!oppLineItemList.isEmpty() && oppLineupdateFlag == false)
            {
                system.debug('upserting oppLineItemList : '+oppLineItemList[0].DeploymentInstance__c);
                system.debug('upserting oppLineItemList 2 : '+oppLineItemList);
                upsert oppLineItemList;
                oppLineupdateFlag = true;
            }  
        }
        catch (exception e)
        {
            system.debug('*** Error in AH_Opportunity_TriggerHandler.createUpdateDIForOLI while upserting oppLineItemList / accountProdList *** ' + e);
        }

        // ADDED BY SHAHSIKANT ON 08/10/2018        
        // QUREY ON RELATED OPPORTUNITY LINE ITEM(AH_Account_Product__c)  &  CREATE "OPPORTUNITY | PRODUCT => ALI" 	MAP
        Integer k = 1;
        Map<String, Map<Integer, String>> accProd_map_WithOpp = new Map<String, Map<Integer, String>>();
        for(AH_Account_Product__c accprod : [SELECT Id, Account__c, Product__c, Opportunity__c, Deployment_Instance__c 
                                             FROM AH_Account_Product__c 
                                             WHERE Opportunity__c in :optyIdSet 
                                             AND Product__c in :prIdSet])
        {
            String key = accprod.Opportunity__c + '|' + accprod.Product__c;
            if (accProd_map_WithOpp != NULL && accProd_map_WithOpp.containsKey(key))
            {
                Map<Integer,String> iMap = new Map<Integer,String>();
                iMap = accProd_map_WithOpp.get(key);
                iMap.put(k, accprod.Deployment_Instance__c);
                accProd_map_WithOpp.put(key, iMap);
            }
            else 
            {
                Map<Integer,String> innerMap = new Map<Integer,String>();
                innerMap.put(k, accprod.Deployment_Instance__c);
                accProd_map_WithOpp.put(key, innerMap);
            }
            k++;
        }

        // CREATE MAP OF JUNCTION OBJECT
        if (!accProd_map_WithOpp.isEmpty()) 
        {
            
            for(String key :accProd_map_WithOpp.keyset()) 
            {
                
                if (ali_map_WithOpp.containsKey(key))
                {
                    
                    for (String DI : accProd_map_WithOpp.get(key).values())
                    {
                        
                        for (String ALI : ali_map_WithOpp.get(key).values())
                        {
                            
                            DI_to_Activity_Line_Item__c juncObj = new DI_to_Activity_Line_Item__c();
                            juncObj.Activity_Line_Item__c = ALI;
                            juncObj.Deployment_Instance__c = DI;
                            
                            junctionObjMap.put(ALI+'_'+DI, juncObj);
                            
                            aliSet.add(juncObj.Activity_Line_Item__c);
                            DISet.add(juncObj.Deployment_Instance__c);
                        }
                    }
                }
            }
        }
        
        
        // ADDED THIS CODE TO REMOVE - 'Required fields are missing: [Deployment Instance]' error
        // IF Deployment Instance ID NULL IN junctionObjMap, THEN REMOVE IT FROM MAP
        system.debug('Before junctionObjMap size : '+junctionObjMap.size());
        for(String s : junctionObjMap.keyset())
        {
            if (junctionObjMap.get(s).Deployment_Instance__c == NULL)
            {
                junctionObjMap.remove(s);
                system.debug('Removed : '+s +' => '+junctionObjMap.get(s));
            }
        }
        system.debug('After junctionObjMap size : '+junctionObjMap.size());
        

        if (!aliSet.isEmpty() && !DISet.isEmpty()) 
        {
            
            // REMOVE DUPLICATES FROM JUNCTION OBJECT
            List<DI_to_Activity_Line_Item__c> All_DItoALI = new List<DI_to_Activity_Line_Item__c>();
            All_DItoALI = [SELECT ID, Activity_Line_Item__c, Deployment_Instance__c 
                           FROM DI_to_Activity_Line_Item__c 
                           WHERE Activity_Line_Item__c IN: aliSet 
                           AND Deployment_Instance__c IN: DISet FOR UPDATE ];

            if (!All_DItoALI.isEmpty()) 
            {
                for (DI_to_Activity_Line_Item__c d : All_DItoALI)
                {
                    if (junctionObjMap.containsKey(d.Activity_Line_Item__c+'_'+d.Deployment_Instance__c))
                    {
                        junctionObjMap.remove(d.Activity_Line_Item__c+'_'+d.Deployment_Instance__c);
                    }
                }
            }
            
            // CREATE LIST CONTAINING JUNCTION OBJECT
            List<DI_to_Activity_Line_Item__c> finalAll_DItoALI = new List<DI_to_Activity_Line_Item__c>();
            finalAll_DItoALI = junctionObjMap.values();
            system.debug('finalAll_DItoALI : ' + finalAll_DItoALI);
            try 
            {
                // INSERT RECORDS IN DI_to_Activity_Line_Item__c
                if (!finalAll_DItoALI.isEmpty()) 
                {
                    Database.insert(finalAll_DItoALI);
                }
            } 
            catch (Exception e)
            {
                system.debug('Exception while inserting records in DI_to_Activity_Line_Item__c : ' + e.getLineNumber() + ' => ' + e);
            }
        }
        
        system.debug(' *** EXITING NI_Opportunity_TriggerHandler.createUpdateDIForOLI_New() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
}