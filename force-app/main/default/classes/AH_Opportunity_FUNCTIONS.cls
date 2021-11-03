/****************************************************************************************
Name            : AH_Opportunity_FUNCTIONS Class 
Author          : Sean Harris
Created Date    : 06/12/2019 
Last Mod Date   : 11/08/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Static functions related to the Opportunity Object
				: Referenced by the following apex classes: 
                : AH_Opportunity_TriggerHandler
                : AH_LinkAccountWithProduct_Ext
				: Updated per NICC-039872
				:  
******************************************************************************************/
public class AH_Opportunity_FUNCTIONS 
{
    
    public static void createUpdateDIForOLI_New(List<Opportunity> newTrigger, boolean processChildDi)
    {
        
        system.debug(' *** ENTERING NI_Opportunity_TriggerHandler.createUpdateDIForOLI_New() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Set<Id> optyIdSet = new Set<Id>();
        //VARIABLE TO HOLD THE VALUE OF OLI RECORDS
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        //HOLD ALL THE DI RECORDS
        Map<String, Asset> existingAssetMap = new Map<String, Asset>();
        //GET ALL ACCOUNT IDS
        Set<Id> accountIdSet = new Set<Id>();
        //HOLD ALL DI INDEX IDS
        Set<Id> diIndexSet = new Set<Id>();
        //HOLD ALL THE PRODUCT IDS RELATED TO OLI
        Set<String> productIdSet = new Set<String>();
        //VARIABLE TO HOLD THE VALUE OF OPPORTUNITY IDS RELATED TO OLIE RECORD
        Set<Id> opptyIdSet = new Set<Id>();
        //HOLD OPPORTUNITY RECORDS
        Map<Id, Opportunity> opptyMap;
        //HOLD PRODUCT RECORDS
        Map<Id, Product2> product2Map;
        //INITIALIZE VARIABLE
        opptyMap = new Map<Id, Opportunity>();
        //ADDED-4/12/2018- HOLD ACCOUNT RELATED PRODUCTS
        List<AH_Account_Product__c> accountProdList = new List<AH_Account_Product__c>();
        
        // GET ALL ACCOUNT IDS OF CURRENT OPPORTUNITY + RELATED ACCOUNTS
        Set<Id> AccIdSet_forLink = new Set<Id>(); 
        // GET ALL ACCOUNT IDS OF CURRENT OPPORTUNITY
        Set<Id> actIdSetThisOpp = new Set<Id>();
        
        //ITERATE THROUGH OPPORTUNITY RECORDS
        for (Opportunity op: newTrigger)
        {
            optyIdSet.add(op.Id);
            accountIdSet.add(op.AccountId);
            opptyMap.put(op.Id, op);
            actIdSetThisOpp.add(op.AccountId);
            AccIdSet_forLink.add(op.AccountId);
        }
        
        system.debug('accountIdSet top : '+ accountIdSet);
        system.debug('optyIdSet top : '+optyIdSet);
        system.debug('AccIdSet_forLink 1 : '+AccIdSet_forLink);
        system.debug('actIdSetThisOpp  :' + actIdSetThisOpp);
        system.debug('opptyMap  SIZE :' + opptyMap.size());
        
        //CHECK IF SET IS NOT EMPTY
        if (!optyIdSet.isEmpty())   
        {
            //GET ALL AH_Account_Product__c(RELATED OLI) RECORDS RELATED TO OPPORTUNITIES
            try
            {
                /*
// COMMNETED BY SHASHIKANT NIKAM ON 10/23/2019 
//ADDED-4/12/2018
accountProdList = [SELECT Id, Name, Account__c, Opportunity__c, Product__c, Quantity__c,
Product__r.DI_Index__r.Name,  Product__r.ProductCode, Deployment_Instance__c
FROM AH_Account_Product__c
WHERE Opportunity__c IN :optyIdSet
AND (Product__r.DI_Index__c != null AND Product__r.DI_Index__r.Name != 'N/A')];

system.debug('accountProdList Size  :' + accountProdList.size());
*/
                
                //if(accountProdList.size() > 0)
                //{
                // call the batch class - params => newTrigger,  processChildDi, 
                AH_createUpdateDIForOLI_Batch btch = new AH_createUpdateDIForOLI_Batch(newTrigger,  processChildDi, accountIdSet, optyIdSet, AccIdSet_forLink, actIdSetThisOpp,opptyMap);
                Database.executeBatch(btch, 50);
                //}
                
            }
            catch (Exception e)
            {
                system.debug('no products to process');
                system.debug(e.getMessage() + '\n Line: ' + e.getLineNumber() + '\n Cause:' + e.getCause());
            }
            
            /*
//COMMENTED EVEN IF THERE ARE RELATED ACCOUNTS, DI SHOULD CREATE ON PRIMARY ACCOUNT AS WELL(AS PER EXISTING BEHAVIOUR)
oppLineItemList = [select Id, Name, OpportunityId, Product2Id, Product2.DI_Index__r.Name, 
DeploymentInstance__c, ProductCode, Quantity 
from OpportunityLineItem 
Where OpportunityId IN: optyIdSet   
AND (Product2.DI_Index__c != null AND Product2.DI_Index__r.Name != 'N/A')];

system.debug('oppLineItemList Size  :' + oppLineItemList.size());
*/
        }
        else
        {
            system.debug('** no opportunity ***');
            return; // IF NO OPPORTUNITY TO PROCESS. added by kasim 03/22/16
        }
        
        // COMMNETED BY SHASHIKANT NIKAM ON 10/23/2019 
        /*	
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
Asset assetObj = createUpdateAsset(extObj.Id, null, (opptyMap.get(oli.OpportunityId).AccountId), product2Id, status, installDate, purchaseDate, null);
assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: ' + oli.Name;
assetObject = assetObj;
assetToUpsertMap.put((opptyMap.get(oli.OpportunityId).AccountId) + '' + product2Map.get(oli.Product2Id).DI_Index__c, assetObj);
}

//IF PRODUCT'S DEFAULT STATUS IS 'Purchased', UPDATE "Purchased Product", "Status" AND "Install Date" FIELDS
else if(extObj.Status == 'Installed' && (product2Map.get(oli.Product2Id).DI_DefaultStatus__c == 'Purchased') && isGreaterPriority)
{
Asset assetObj = createUpdateAsset(extObj.Id, null, (opptyMap.get(oli.OpportunityId).AccountId), null, null, installDate, purchaseDate, null);
assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: ' + oli.Name;
assetObj.Purchased_Product__c = oli.Product2Id;
assetObj.Purchase_Status__c = 'Purchased';
assetObj.Opportunity__c = oli.OpportunityId;
assetObject = assetObj;
assetToUpsertMap.put((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c, assetObj);
}
else if(extObj.Status == 'Installed' && (product2Map.get(oli.Product2Id).DI_DefaultStatus__c == 'Purchased') && isLessPriority )
{
Asset assetObj = createUpdateAsset(extObj.Id, null, (opptyMap.get(oli.OpportunityId).AccountId), null, null, installDate, purchaseDate, null);
assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: '+oli.Name;
assetObject = assetObj;
assetToUpsertMap.put((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c, assetObj);
}
else if(extObj.Status == 'Installed' && (product2Map.get(oli.Product2Id).DI_DefaultStatus__c == 'Installed') && isLessPriority )
{
Asset assetObj = createUpdateAsset(extObj.Id, null, (opptyMap.get(oli.OpportunityId).AccountId), null, null, installDate, purchaseDate, null);
assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: ' + oli.Name;
assetObject = assetObj;
assetToUpsertMap.put((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c, assetObj);
}
else if(extObj.Status == 'Inactive' && product2Map.get(oli.Product2Id).DI_DefaultStatus__c != 'Inactive')
{
status = 'Purchased';
product2Id = oli.Product2Id;
Asset assetObj = createUpdateAsset(extObj.Id, null, null, product2Id, status, null, purchaseDate, null);
assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: '+oli.Name;
assetObject = assetObj;
assetToUpsertMap.put((opptyMap.get(oli.OpportunityId).AccountId)+''+product2Map.get(oli.Product2Id).DI_Index__c, assetObj);
} //FOR 'Purchased' STATUS(ADDED BY SUPRIYA)
else if(extObj.Status == 'Purchased' && product2Map.get(oli.Product2Id).DI_DefaultStatus__c != null)
{
system.debug('in purchased');
Asset assetObj = createUpdateAsset(extObj.Id, null, (opptyMap.get(oli.OpportunityId).AccountId), null, null, null, purchaseDate, null);
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
Asset assetObj = createUpdateAsset(extObj.Id, null, (opptyMap.get(oli.OpportunityId).AccountId), null, status, installDate, purchaseDate, null);
if (extObj.Status == 'Inactive' && assetObj.Status.equals('Installed'))
{
assetObj.Activation_Date__c = extObj.CreatedDate.date(); //new
}
assetToUpsertMap.put((opptyMap.get(oli.OpportunityId).AccountId) + '' + product2Map.get(oli.Product2Id).DI_Index__c, assetObj);
}
}
else
{
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
Asset assetObj = createUpdateAsset(null, oli.ProductCode, (opptyMap.get(oli.OpportunityId).AccountId), oli.Product2Id, status, installDate, purchaseDate, null);
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
// INITIALIZE LOCAL VARIABLES
product2Id = null;
status = null;
installDate = null;
purchaseDate = null;
assetObject = new Asset();

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
Asset assetObj = createUpdateAsset(extObj.Id, null, accProdObj.Account__c, product2Id, status, installDate, purchaseDate, null);
assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: '+accProdObj.Name;
assetObject = assetObj;
assetToUpsertMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, assetObj);
}
//IF PRODUCT'S DEFAULT STATUS IS 'Purchased', UPDATE "Purchased Product", "Status" AND "Install Date" FIELDS
else if (extObj.Status == 'Installed' && (product2Map.get(accProdObj.Product__c).DI_DefaultStatus__c == 'Purchased') && isGreaterPriority)
{
//UPDATE EXISTING DI RECORD
Asset assetObj = createUpdateAsset(extObj.Id, null, accProdObj.Account__c, null, null, installDate, purchaseDate, null);
assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: ' + accProdObj.Name;
assetObj.Purchased_Product__c = accProdObj.Product__c;
assetObj.Purchase_Status__c = 'Purchased';
assetObj.Opportunity__c = accProdObj.Opportunity__c;
assetObject = assetObj;
assetToUpsertMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, assetObj);
}
else if (extObj.Status == 'Installed' && (product2Map.get(accProdObj.Product__c).DI_DefaultStatus__c == 'Purchased') && isLessPriority)
{
Asset assetObj = createUpdateAsset(extObj.Id, null, accProdObj.Account__c, null, null, installDate, purchaseDate, null);
assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: '+accProdObj.Name;
assetObject = assetObj;
assetToUpsertMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, assetObj);
}
else if (extObj.Status == 'Installed' && (product2Map.get(accProdObj.Product__c).DI_DefaultStatus__c == 'Installed') && isLessPriority)
{
Asset assetObj = createUpdateAsset(extObj.Id, null, accProdObj.Account__c, null, null, installDate, purchaseDate, null);
assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: '+accProdObj.Name;
assetObject = assetObj;
assetToUpsertMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, assetObj);
}
else if (extObj.Status == 'Inactive' && product2Map.get(accProdObj.Product__c).DI_DefaultStatus__c != 'Inactive')
{
status = 'Purchased';
product2Id = accProdObj.Product__c;
Asset assetObj = createUpdateAsset(extObj.Id, null, null, product2Id, status, null, purchaseDate, null);
assetObj.Integration_User_Source__c = 'Updated per Opportunity Synchronization for line item: ' + accProdObj.Name;
assetObject = assetObj;
assetToUpsertMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, assetObj);
}	//FOR 'Purchased' STATUS
else if (extObj.Status == 'Purchased' && product2Map.get(accProdObj.Product__c).DI_DefaultStatus__c != null)
{
Asset assetObj = createUpdateAsset(extObj.Id, null, accProdObj.Account__c, null, null, null, purchaseDate, null);
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
Asset assetObj = createUpdateAsset(extObj.Id, null, accProdObj.Account__c, null, status, installDate, purchaseDate, null);
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
Asset assetObj = createUpdateAsset(null, accProdObj.Product__c, accProdObj.Account__c, accProdObj.Product__c, status, installDate, purchaseDate, null);
if (assetObj.Status.equals('Installed'))
{
assetObj.Activation_Date__c = Date.today();
}
assetObj.Integration_User_Source__c = 'Created per Opportunity Synchronization for line item: ' + accProdObj.Name;
//UPDATE THE PRODUCT ON NEW DI WITH HIGHEST PRIORITY
if (assetToUpsertMap.containsKey((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c))
{
if(oldRecordPriorityMap.get((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c) < product2Map.get(assetObj.Product2Id).DI_Priority__c)
{
oldRecordPriorityMap.remove((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c);
oldRecordPriorityMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, product2Map.get(assetObj.Product2Id).DI_Priority__c);
assetToUpsertMap.remove((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c);
assetToUpsertMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, assetObj);
}
}
else
{
assetToUpsertMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, assetObj);
oldRecordPriorityMap.put((String.ValueOf(accProdObj.Account__c))+''+product2Map.get(accProdObj.Product__c).DI_Index__c, product2Map.get(assetObj.Product2Id).DI_Priority__c);
}

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

// ADDED BY SHAHSIKANT ON 08/10/2018
// QUERY ON DEPLOYMENT INSTANCE & CREATE DI_MAP USING ACCOUNT ID & PRODUCT ID
Map<String, Asset> di_map = new Map<String, Asset>();
di_map = fetchDeploymentInstance(AccIdSet_forLink, prIdSet);

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
oppLineItemList[i].DeploymentInstance__c = assetToUpsertMap.get((opptyMap.get(oppLineItemList[i].OpportunityId).AccountId)+''+product2Map.get(oppLineItemList[i].Product2Id).DI_Index__c).Id;
}
else if (existingAssetMap.containsKey((opptyMap.get(oppLineItemList[i].OpportunityId).AccountId)+''+product2Map.get(oppLineItemList[i].Product2Id).DI_Index__c))
{
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
}

//UPDATE RECORDS
try
{
if (!accountProdList.isEmpty())
{
upsert accountProdList;
}
if (!oppLineItemList.isEmpty())
{
upsert oppLineItemList;
}  
}
catch (exception e)
{
system.debug('*** Error in NI_Opportunity_TriggerHandler.createUpdateDIForOLI *** ' + e);
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

if (!aliSet.isEmpty() && !DISet.isEmpty()) 
{

// REMOVE DUPLICATES FROM JUNCTION OBJECT
List<DI_to_Activity_Line_Item__c> All_DItoALI = new List<DI_to_Activity_Line_Item__c>();
All_DItoALI = [SELECT ID, Activity_Line_Item__c, Deployment_Instance__c 
FROM DI_to_Activity_Line_Item__c 
WHERE Activity_Line_Item__c IN: aliSet 
AND Deployment_Instance__c IN: DISet];

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
insert finalAll_DItoALI;
}
} 
catch (Exception e)
{
system.debug('Exception while inserting records in DI_to_Activity_Line_Item__c : ' + e.getLineNumber() + ' => ' + e);
}
}

system.debug(' *** EXITING NI_Opportunity_TriggerHandler.createUpdateDIForOLI_New() - QUERIES ISSUED = ' + Limits.getQueries());

*/
    }
    
    public static Asset createUpdateAsset(Id diId, String diName, Id diAccountId, Id diProductId, String status, Date installDate, Date purchaseDate, Decimal quantityOrdered)
    {
        
        //Create new Deployment Instance record
        Asset assetObj;
        
        if (diId == null)
        {
            assetObj = new Asset();
        }
        else
        {
            assetObj = new Asset(Id = diId);
        }
        
        if (diName != null)
        {
            assetObj.Name = diName;
        }
        
        if (diAccountId != null) 
        {
            assetObj.AccountId = diAccountId;
        }
        
        if (diProductId != null)
        {
            assetObj.Product2Id = diProductId;
        }
        
        if (status != null) 
        {
            assetObj.Status = status;
        }
        
        //If installDate is null, don't update it
        if (installDate != null)
        {
            assetObj.InstallDate = installDate;
        }
        
        //if PurchaseDate is not null, update with new value
        if (purchaseDate != null)
        {
            assetObj.Purchase_Date__c = purchaseDate;
        }
        
        //If quantityOrdered is not null, update it with new value
        if (quantityOrdered != null)
        {
            assetObj.Quantity_Ordered__c = quantityOrdered;
        }
        
        return assetObj;
        
    }
    
    public static Map<String, Asset> fetchDeploymentInstance(Set<Id> accountIds, Set<Id> productIds)
    {   
        
        // Method for Querying the Deployment Instances related to a particular set of Accounts and Products 
        Map<String, Asset> di_map = new Map<String, Asset>();
        
        for (Asset deploymentInstance : [SELECT AccountId, Id, Product2Id, InstallDate
                                         FROM Asset
                                         WHERE AccountId IN : accountIds 
                                         AND Product2Id IN : productIds])
        {       
            String key = deploymentInstance.AccountId + '|' + deploymentInstance.Product2Id;
            di_map.put(key, deploymentInstance); 
        }
        
        return di_map;
        
    }
    
    public static void rollupCustomAmount(List<OpportunityLineItem> newTrigger, Map<Id, OpportunityLineItem> oldMapTrigger)
    {  
        // THIS FUNCTION IS CALLED FROM Opportunity & Opportunity Line Item TRIGGERHANDLERS
        // IT UPDATES THE CUSTOM ROLLUP (COMMISSIONABLE) AMOUNT FIELD ON Opportunity (Amount__c)
        // IT LOOKS TO A CUSTOM SETTING CALLED NI_OpportunityCalculatedAmount__c TO GET DIVISORS BY PRODUCT2 FAMILY
        // PERFORMS THE UPDATE ONLY WHEN THERE IS A CHANGE TO AN OpportunityLineItem.TotalPrice OR OpportunityLineItem.Non_Commissionable__c
        // WHEN OpportunityLineItem.Non_Commissionable__c IS TRUE THEN THE TOTAL AMOUNT FOR THE OpportunityLineItem IS IGNORED IN THE ROLLUP 
        decimal dAmount = 0;
        decimal dAvgSubsRate = 0;			// ADDED PER NICC-027220
        Set<Id> setOppIds = new Set<Id>(); 
        Set<Id> setRTypes = new Set<Id>();
        List<opptyLineItem> lstOpptyLineItems = new List<opptyLineItem>();	
        List<Opportunity> lstOpptyUpdate = new List<Opportunity>();	
        
        // GET IDS OF RELATED OPPORTUNITIES
        for (OpportunityLineItem o1 : newTrigger)
        {
            if (oldMapTrigger != null)  
            {
                OpportunityLineItem oldOLI = oldMapTrigger.get(o1.Id); 
                if ((o1.TotalPrice != oldOLI.TotalPrice) || (o1.Non_Commissionable__c != oldOLI.Non_Commissionable__c)) // SMH CHANGE Non_Commissionable__c checkbox exception
                {
                    setOppIds.Add(o1.OpportunityId); 
                }
            }
            else
            {
                setOppIds.Add(o1.OpportunityId); 
            }   
        } 
        
        if (setOppIds.size() == 0)
        {
            return;
        }
        
        // LOOP THOUGH ALL RELATED OPPORTUNITIES' LINE ITEMS GRABBING THE MATCHING MULTIPLIER FROM CUSTOM SETTINGS 
        List<NI_OpportunityCalculatedAmount__c> lstCustSets = NI_OpportunityCalculatedAmount__c.getAll().values();
        
        
        // MULTI-YEAR DIVISON METHOD =======        
        List<AggregateResult> ag = new List<AggregateResult>([
            SELECT OpportunityId, Opportunity.RecordType.Name RecordTypeName, 
            Product2Id, Product2.Family ProductFamily, Product2.Revenue_Category__c RevCategory, 
            Opportunity.CurrencyIsoCode, Opportunity.CloseDate, Opportunity.Name OpportunityName, SUM(TotalPrice) TotalPrice, COUNT(Id) ItemCount 
            , SUM(Order_of_Delivery__c) OrderOfDeliverySum          // ADDED PER NICC-027220  
            FROM OpportunityLineItem 
            WHERE OpportunityId IN : setOppIds 
            AND Non_Commissionable__c != true 						// SMH CHANGE Non_Commissionable__c checkbox exception
            GROUP BY OpportunityId, Opportunity.RecordType.Name, 
            Product2Id, Product2.Family, Product2.Revenue_Category__c, 
            Opportunity.CurrencyIsoCode, Opportunity.CloseDate, Opportunity.Name 
        ]);
        system.debug(' *** setOppIds = ' + setOppIds);          
        system.debug(' *** ag.size() = ' + ag.size());        
        for (AggregateResult x : ag)
        {
            for (NI_OpportunityCalculatedAmount__c cst : lstCustSets)
            {               
                if ((x.get('RecordTypeName') == cst.Opportunity_Record_Type_Name__c) && (x.get('ProductFamily') == cst.Product_Family__c))
                {                 
                    // INNER CLASS PROTOTYPE: Id oppId, String oppRecType, Id product2Id, Decimal oppItemTotalPrice, String oppItemFamily, Decimal dMultiplier, String revCategory, Integer iItemCount                      
                    Id p1 = (Id) x.get('OpportunityId');
                    String p2 = (String) x.get('RecordTypeName'); 
                    Id p3 = (Id) x.get('Product2Id'); 
                    string sIsoCode = (String) x.get('CurrencyIsoCode');
                    Date d = (Date) x.get('CloseDate');
                    Decimal p4 = (Decimal) x.get('TotalPrice');
                    if (sIsoCode != 'USD')
                    {
                        if (d != null)
                        {
                            p4 = nonUSDAmountDated(p4, sIsoCode, d);
                        }
                        else
                        {
                            p4 = nonUSDAmountCurrent(p4, sIsoCode);
                        }                        
                    }
                    String p5 = (String) x.get('ProductFamily');
                    Decimal p6 = (Decimal) cst.Multiplier__c; 
                    String p7 = (String) x.get('RevCategory');
                    Integer p8 = (Integer) x.get('ItemCount'); 
                    Decimal p9 = (Decimal) x.get('OrderOfDeliverySum');							// ADDED PER NICC-027220
                    
                    opptyLineItem oli = new opptyLineItem(p1, p2, p3, p4, p5, p6, p7, p8, p9);  // UPDATED PER NICC-027220                  
                    lstOpptyLineItems.add(oli);
                    
                }                	
            } 
        }       
        
        for (Opportunity oppty : [SELECT Id, Amount__c, Name, Rollup_Amount_Adjustment__c 
                                  , Multi_year_Deal__c 										// NICC-024231 (SELECT FIELD)
                                  , Average_Subscription_Rate__c                            // ADDED PER NICC-027220
                                  FROM Opportunity WHERE Id IN : setOppIds])
        { 
            
            dAmount = 0;
            dAvgSubsRate = 0;							// ADDED PER NICC-027220
            oppty.Multi_year_Deal__c = false; 			// NICC-024231 (INITIALIZE CHECKBOX)
            
            for (opptyLineItem opLIs : lstOpptyLineItems)
            {             
                if (oppty.Id == opLIs.oppId) 
                {                    
                    if (opLIs.oppItemTotalPrice != null)
                    {
                        
                        // ADDED PER NICC-027220 (START)
                        // IF FAMILY IS 'Subscription' AND THE SUM OF ORDER OF DELIVERY VALUES IS GREATER THAN THE COUNT OF OLIs
                        system.debug(' *** opLIs = ' + opLIs);                        
                        if (opLIs.oppItemFamily == 'Subscription')
                        {
                            if (opLIs.OrderOfDeliverySum > opLIs.iItemCount)
                            {
                                dAvgSubsRate += ((opLIs.oppItemTotalPrice / opLIs.iItemCount) * opLIs.dMultiplier);
                            }
                            else
                            {
                                dAvgSubsRate += (opLIs.oppItemTotalPrice * opLIs.dMultiplier);
                            }
                        }
                        // ADDED PER NICC-027220 (END)
                        system.debug(' *** dAvgSubsRate = ' + dAvgSubsRate);  
                        
                        if ((opLIs.OrderOfDeliverySum > opLIs.iItemCount) && 
                            ((opLIs.revCategory == 'Software - Subscription') || (opLIs.revCategory == 'Maintenance'))) 								// UPDATED PER NICC-027220
                            // if ((opLIs.iItemCount > 1) && ((opLIs.revCategory == 'Software - Subscription') || (opLIs.revCategory == 'Maintenance'))) 	// UPDATED PER NICC-027220
                        {                        
                            dAmount += ((opLIs.oppItemTotalPrice / opLIs.iItemCount) * opLIs.dMultiplier);
                            oppty.Multi_year_Deal__c = true; 		// NICC-024231 (CHECK WHEN IS MULTI-YEAR DEAL)
                        }
                        else
                        {                      
                            dAmount += (opLIs.oppItemTotalPrice * opLIs.dMultiplier);
                        }
                        //                            System.debug('NI_OpportunityProduct_TriggerHandler.rollupCustomAmount:  ' + opLIs.oppId + ', ' + opLIs.oppRecType + ', ' + opLIs.product2Id + ', ' + opLIs.oppItemTotalPrice + ', ' + opLIs.oppItemFamily + ', ' + opLIs.dMultiplier);
                    }
                }
            }
            
            if (oppty.Rollup_Amount_Adjustment__c != null)
            {
                Decimal dAdjustment = (Decimal)oppty.Rollup_Amount_Adjustment__c;
                oppty.Amount__c = (dAmount + dAdjustment);
            }
            else
            {
                oppty.Amount__c = dAmount;
            }
            
            oppty.Average_Subscription_Rate__c = dAvgSubsRate;
            
            lstOpptyUpdate.Add(oppty);		// ADDED PER NICC-027220
            
        }
        
        Database.update(lstOpptyUpdate);
        
    }
    
    public static decimal nonUSDAmountCurrent(decimal dAmount, string sCurrencyCode)
    {
        decimal dCorrectedVal = 0.00;        
        decimal conversionRate = [SELECT conversionrate FROM currencytype WHERE isocode =: sCurrencyCode LIMIT 1].conversionRate;
        dCorrectedVal = (dAmount.setScale(10) * conversionRate.setScale(10));
        return dCorrectedVal;
    }
    
    public static decimal nonUSDAmountDated(decimal dAmount, string sCurrencyCode, date dStartDate)
    {
        
        date myDate = date.newInstance(dStartDate.Year(), dStartDate.Month(), 1);
        decimal dCorrectedVal = 0.00;
        decimal conversionRate = 0.00;
        
        List<DatedConversionRate> lstDCR = new List<DatedConversionRate>([SELECT conversionrate FROM DatedConversionRate WHERE isocode =: sCurrencyCode AND StartDate =: myDate LIMIT 1]);
        
        if (lstDCR.size() > 0)	// IF DATED CONVERSION RATE FOUND
        {
            conversionRate = lstDCR[0].conversionRate;
            dCorrectedVal = (dAmount.setScale(10) * conversionRate.setScale(10));
        }
        else 					// ELSE GET CURRENT CONVERSION RATE
        {
            dCorrectedVal = nonUSDAmountCurrent(dAmount, sCurrencyCode);
        }
        
        return dCorrectedVal;
        
    }    
    
    
    // ============================================================================================================================================    
    // WRAPPER CLASS     
    // ============================================================================================================================================    
    public class opptyLineItem
    {
        
        public Id oppId {get; set;}
        public String oppRecType {get; set;}
        public Id product2Id {get; set;}
        public Decimal oppItemTotalPrice {get; set;}
        public String oppItemFamily {get; set;}
        public Decimal dMultiplier {get; set;}
        public String revCategory {get; set;}
        public Integer iItemCount {get; set;}
        public Decimal OrderOfDeliverySum {get; set;}
        
        public opptyLineItem (Id oppId, 
                              String oppRecType, 
                              Id product2Id, 
                              Decimal oppItemTotalPrice, 
                              String oppItemFamily, 
                              Decimal dMultiplier, 
                              String revCategory,
                              Integer iItemCount,
                              Decimal OrderOfDeliverySum) 
        {
            this.oppId = oppId;
            this.oppRecType = oppRecType; 
            this.product2Id = product2Id; 
            this.oppItemTotalPrice = oppItemTotalPrice; 
            this.oppItemFamily = oppItemFamily;
            this.dMultiplier = dMultiplier;
            this.revCategory = revCategory;
            this.iItemCount = iItemCount;
            this.OrderOfDeliverySum = OrderOfDeliverySum;
        }
        
    }  
    
}