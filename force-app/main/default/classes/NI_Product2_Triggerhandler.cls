/************************************************************************************************
Name            : NI_Product2_Triggerhandler Class
Author          : Sean Harris
Created Date    : 03/10/2015
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : Class that handles all trigger code for the Product2 Object
                : 
                : 
*************************************************************************************************/
public with sharing class NI_Product2_Triggerhandler 
{

    public NI_Product2_Triggerhandler()
    {
    
    }

    // BEFORE HANDLERS =============================================
    
   /*functionality no longer required. commented by kasim on 4/27/16*/
   
    public void OnBeforeInsert(List<Product2> newTrigger)
    {
        /*If (!NI_FUNCTIONS.bypassTriggerCode('PRODUCT2'))
        {
        
            Set<Id> prodCatalogIds = new Set<Id>();
            Map<Id,Product2> productMap = new Map<Id,Product2>();
            
            for(Product2 prod : newTrigger){
                //Check that Partner Product catalog is seleted while insert
                if(prod.Partner_Product_Catalog__c != Null){
                    prodCatalogIds.add(prod.Partner_Product_Catalog__c);
                }
            } 
            //Call a method that auto update the DI Index related to selected Partner Product Catalog 
            If(!prodCatalogIds.IsEmpty())
                updateDIIndex(newTrigger,prodCatalogIds,productMap,False);   
           
        }*/
    }
  /*functionality no longer required. commented by kasim on 4/27/16*/
    public void OnBeforeUpdate(List<Product2> newTrigger, Map<Id, Product2> oldMapTrigger)
    {    
        /*if (!NI_FUNCTIONS.bypassTriggerCode('PRODUCT2'))
        {             
            
            // @Added On: 02/22/2016
            
            Set<Id> prodCatalogIds = new Set<Id>();
            for(Product2 newProd : newTrigger)
            {
                Product2 oldProd = oldMapTrigger.get(newProd.Id);
                
                //Check that Partner Product Catalog is updated
                
                If((newProd.Partner_Product_Catalog__c != oldProd.Partner_Product_Catalog__c && newProd.Partner_Product_Catalog__c != Null) || newProd.DI_Index__c != oldProd.DI_Index__c)
                   prodCatalogIds.add(newProd.Partner_Product_Catalog__c);
            }
            
            //Call a method that auto update the DI Index related to selected Partner Product Catalog 
           
           If(!prodCatalogIds.IsEmpty()) functionality commented
               updateDIIndex(newTrigger,prodCatalogIds,oldMapTrigger,True);           
                            
        }*/ 
    }
	/** Commented by kasim on 04/28/2016 as this function is not called from any trigger*/
    /*public void OnBeforeDelete(List<Product2> newTrigger, Map<Id, Product2> oldMapTrigger)
    {
        if (!NI_FUNCTIONS.bypassTriggerCode('PRODUCT2'))
        {                 
            if (!processDIIndexChanges(newTrigger, oldMapTrigger, true))
            { 
                newTrigger[0].DI_Index__c.addError('This Deployment Instance Index is related to 1 or more Deployment Instances and may not be deleted. This change requires technical assistance from the System Administrator.');
            }
        }
    }*/
    
    // AFTER HANDLERS ==============================================
    public void OnAfterInsert(List<Product2> newTrigger)
    {
       
    }
    
    public void OnAfterUpdate(List<Product2> newTrigger, Map<Id, Product2> oldMapTrigger)
    {
        if (!NI_FUNCTIONS.bypassTriggerCode('PRODUCT2'))
        {                      
            processDIIndexChanges(newTrigger, oldMapTrigger, false);
            // @Added On: 02/15/2016
            Set<Id> prodIdList = new Set<Id>();
            for(Product2 newProd : newTrigger)
            {   
                Product2 oldProd = oldMapTrigger.get(newProd.Id);
                //Check that "Hosted" is updated
                if(newProd.Hosted__c != oldProd.Hosted__c){
                    prodIdList.add(newProd.Id);
                }
            }
            //Call the method that updates the DI related to product whose "Hosted" is updated      
            if(!prodIdList.isEmpty())
                callUpdateHostedOnDI(prodIdList);            
        }
    } 
        
    public void OnAfterDelete(List<Product2> newTrigger)
    {
        
    }
    
    public void OnAfterUnDelete(List<Product2> newTrigger)
    {
        
    }    

    
    // FUNCTIONS ==================================================
    private boolean processDIIndexChanges(List<Product2> nTrig, Map<Id, Product2> oTrig, boolean validateOnly)
    {
        system.debug('****Enter DIProcess Method*****');
        Set<Id> setAssetsIds = new Set<Id>();               // 
        Set<Id> setProduct2Ids = new Set<Id>();             // HOLDS PRODUCT2 IDS FOR RECORDS WITH CHANGED DI INDEX(S)
        Set<Id> setOldIndexIds = new Set<Id>();             // HOLDS PREVIOUS DI INDEX ID VALUES 
        Set<Id> setNewIndexIds = new Set<Id>();             // HOLDS NEW DI INDEX ID VALUES 
        Set<String> setOldAcctDIIndx = new Set<String>();   // 
        Set<String> setNewAcctDIIndx = new Set<String>();   // 
                
        // TARGET PRODUCTS WITH CHANGED DI INDEX FIELDS
        for (Product2 nPs : nTrig) 
        { 
            Product2 oPs = oTrig.get(nPs.Id); 
            if (nPs.DI_Index__c != oPs.DI_Index__c) 
            { 
                setProduct2Ids.Add(nPs.Id); 
                setOldIndexIds.Add(oPs.DI_Index__c); 
                setNewIndexIds.Add(nPs.DI_Index__c); 
            } 
        } 
        system.debug('****setProduct2Ids****'+setProduct2Ids);
        system.debug('****setOldIndexIds****'+setOldIndexIds);
        system.debug('****setNewIndexIds****'+setNewIndexIds);
        // IF NO DI INDEXS WERE CHANGED EXIT RETURNING A POSITIVE VALUE
        if (setNewIndexIds.Size() == 0) 
        { 
            return true; 
        } 
        
        // LIST OF ALL ASSETS HAVING PRODUCTS WHERE THE DI INDEX WAS CHANGED
        List<Asset> lstOldDIs = new List<Asset>( 
            [SELECT Id, AccountId, Account.Name, Product2Id, Product2.DI_Index__c, AccountId_DIIndexID__c, Name  
             FROM Asset 
             WHERE Product2Id IN : setProduct2Ids] 
        ); 

        // LIST OF ALL ASSETS HAVING PRODUCTS WITH THE DESTINATION DI INDEX
        /* List<Asset> lstNewDIs = new List<Asset>(
            [SELECT Id, AccountId, Account.Name, Product2Id, Product2.DI_Index__c, AccountId_DIIndexID__c 
             FROM Asset 
             WHERE Product2.DI_Index__c IN : setNewIndexIds]
        );        
        
        system.debug('****lstOldDIs****'+lstOldDIs);
        system.debug('****lstNewDIs****'+lstNewDIs);
        */
        
// NEW SECTION 2015-10-16 (START) ==============================================      
// UPDATE ALL Asset.AccountId_DIIndexID__c VALUES MANUALLY
        if (!validateOnly)
        {
        
            
            Map<Id, String> mapAccountId_DIIndexID = new Map<Id, String>();
            for (Asset lstOLD : lstOldDIs)
            {
                for (Product2 lstPrd2 : nTrig)
                {
                    if (lstOLD.Product2Id == lstPrd2.Id)
                    {
                        mapAccountId_DIIndexID.put(lstOLD.Id, (String.valueOf(lstOLD.AccountId) + string.valueOf(lstPrd2.DI_Index__c)));
                    }
                }
                
            }

            List<Asset> lstOldDIUpdates = new List<Asset>();
            for (Asset lstDIUps : lstOldDIs)
            {
                lstDIUps.AccountId_DIIndexID__c = mapAccountId_DIIndexID.get(lstDIUps.Id);
                lstOldDIUpdates.Add(lstDIUps);
            }
            // INVOKE WORKFLOW RULE "Update AccountId & DI Index Id" ON ASSET 
            Database.Update(lstOldDIUpdates, false);            

        }

// NEW SECTION 2015-10-16 (END) ==============================================


        /*
            * Added by Prashant Wayal
            * Since we are deprecating the use of DI_to_Softrax_Asset__c we don't need below code
            
        if (validateOnly)
        {
            system.debug('****Enter Validate IF****');        
            // LIST OF ALL ASSETS HAVING PRODUCTS WITH THE ORIGINAL "PREVIOUS" DI INDEX
            //     USED IN TARGETING WHAT DI_to_Softrax_Asset__c RECORDS TO REMOVE AND RECALC
            List<Asset> lstOldIndexs = new List<Asset>(
                [SELECT Id, AccountId, Account.Name, Product2Id, Product2.DI_Index__c, AccountId_DIIndexID__c, DI_Index_Name__c  
                 FROM Asset 
                 WHERE Product2.DI_Index__c IN : setOldIndexIds AND Product2.DI_Index__c != null]
            ); 
//            NI_TriggerManager.lstDIsWithOldDIIndexes.Clear(); 
            system.debug('****lstOldIndexs****'+lstOldIndexs);
            NI_TriggerManager.lstDIsWithOldDIIndexes = lstOldIndexs;
             
        }
        
        Set<Id> setAllAccountIds = new Set<Id>();
        Set<Id> setOldAccountIds = new Set<Id>();
        Set<Id> setNewAccountIds = new Set<Id>();     
        
        // GATHER DISTINCT AccountId VALUES FROM ALL ASSETS HAVING PRODUCTS WHERE THE DI INDEX WAS CHANGED
        for (Asset di2 : lstOldDIs)
        {
            setOldAccountIds.Add(di2.AccountId);
            setAllAccountIds.Add(di2.AccountId);
        } 
        
        // GATHER DISTINCT AccountId VALUES FROM ALL ASSETS PRODUCTS WITH THE DESTINATION DI INDEX 
        // GATHER DISTINCT AccountId_DIIndexID__c VALUES FROM ALL ASSETS PRODUCTS WITH THE DESTINATION DI INDEX 
        for (Asset di1 : lstNewDIs)
        {
            setNewAccountIds.Add(di1.AccountId); 
            setAllAccountIds.Add(di1.AccountId); 
            setNewAcctDIIndx.Add(di1.AccountId_DIIndexID__c); 
        } 
        
        // GATHER DISTINCT Id VALUES FROM ALL ASSETS HAVING PRODUCTS WITH THE ORIGINAL "PREVIOUS" DI INDEX
        // GATHER DISTINCT AccountId_DIIndexID__c VALUES FROM ALL ASSETS HAVING PRODUCTS WITH THE ORIGINAL "PREVIOUS" DI INDEX
        for (Asset di3 : NI_TriggerManager.lstDIsWithOldDIIndexes)
        {
            setAssetsIds.Add(di3.Id); 
            setOldAcctDIIndx.Add(di3.AccountId_DIIndexID__c); 
        }
        system.debug('****setNewAccountIds****'+setNewAccountIds);
        system.debug('****setOldAccountIds****'+setOldAccountIds);
        system.debug('****setAllAccountIds****'+setAllAccountIds);
        // VALIDATE ONLY SECTION ===============================================================
        if (validateOnly)
        { 
            system.debug('****Enter Validate IF 2*****');
            // CHECK TO SEE THAT ALL DISTINCT ACCOUNTID FROM BOTH OLD & NEW ARE DISTINCT
            if (setAllAccountIds.size() < (setOldAccountIds.size() + setNewAccountIds.size()))
            { 
                return false; 
            } 
            return true;            
        } 
        // RECORD PROCESSING SECTION ============================================================
        else
        {
            
            
            
            // RETRIEVE A LIST OF DI_to_Softrax_Asset__c JUNCTION RECORDS TO BE DELETED
            List<DI_to_Softrax_Asset__c> lstDI2Softrax = new List<DI_to_Softrax_Asset__c>(
                [SELECT Id, Deployment_Instance__c, Softrax_Asset__c 
                 FROM DI_to_Softrax_Asset__c 
                 WHERE Deployment_Instance__c IN : setAssetsIds]
            );
            
            // RETRIEVE SET OF SOFTRAX ASSET IDs OF THE JUNCTION RECORDS TO BE DELETED
            Set<Id> setSoftraxAssetIds = new Set<Id>();
            
            for (DI_to_Softrax_Asset__c d2s : lstDI2Softrax)
            {
                setSoftraxAssetIds.Add(d2s.Softrax_Asset__c);
            } 
    
            // DELETE DI_to_Softrax_Asset__c JUNCTION RECORDS
            Database.delete(lstDI2Softrax); 
            
            // RETRIEVE A LIST OF SOFTRAX ASSETS THAT HAD RELATED JUNCTION RECORDS DELETED 
            List<Softrax_Asset__c> lstSoftraxAssets = new List<Softrax_Asset__c>(
                [SELECT Id, Name, Account__c, Product2Id__c, Cancel_Asset__c, Start_Date__c, End_Date__c, Fee__c, Quantity__c, Renewal_Group__c, 
                 Softrax_Last_Modified_Date__c, Softrax_Status__c, SoftraxUploadRecordNumber__c, Description__c, Status__c, Total__c 
                 FROM Softrax_Asset__c 
                 WHERE Deployment_Instance__c IN : setAssetsIds] 
            ); 
       
            NI_SoftraxAsset_TriggerHandler obj = new NI_SoftraxAsset_TriggerHandler();
            //obj.syncBillingRecords(lstSoftraxAssets); 
            obj.createUpdateDIForSA(lstSoftraxAssets);
            
            NI_TriggerManager.lstDIsWithOldDIIndexes.Clear(); 
            
            return true; 
                       
        } */
        return true; 
    }
    
    /*----------------------------------------
    * @Added By: Prashant Wayal
    * @Added On: 02/04/2016
    * @Description: Call the method that update the "IsHostedDI" on Deployment Instance
    ------------------------------------------*/
    public void callUpdateHostedOnDI(Set<Id> prodIds)
    {
        //List<Softrax_Asset__c> saList = [SELECT Id,Product2ID__c,
        //Deployment_Instance__r.Parent_DI__r.Product2Id FROM Softrax_Asset__c WHERE Product2ID__c IN : prodIds];
        //NI_SoftraxAsset_TriggerHandler handler = new NI_SoftraxAsset_TriggerHandler();
        //handler.updateHostedOnDI(saList);
        List<Activity_Line_Item__c> aliList = [SELECT Id, Product__c, 
                                              Deployment_Instance__r.Parent_DI__r.Product2Id 
                                              FROM Activity_Line_Item__c WHERE Product__c IN : prodIds];
        NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
        handler.updateHostedOnDI(aliList);
    }
    
    /*----------------------------------------
    * @Added By: Kasim Badami
    * @Added On: 02/17/2016
    
    * @Description: Method that Auto update the "DI Index" on Product
      
      // functionality commented by Kasim as per stu's email dated 4/27/16 as follows,
      // A new Product Classification system is being put in place that will eliminate the need for individual DIs for each Salesforce Product.
    ------------------------------------------*/
   /*public void updateDIIndex(List<Product2> newTrigger,Set<Id> prodCatalogIds,Map<Id,Product2> oldMapTrigger,Boolean IsUpdate){               
        Map<Id,String> prodCatalogToNameMap = new Map<Id,String>();
        Map<String,Id> indexNameToIdMap = new Map<String,Id>();
        Set<String> partnerProdCatlogNames = new Set<String>();        
        for(List<CHANNEL_ORDERS__Partner_Product_Catalog__c> prodCatalogList : [SELECT Id,Name FROM CHANNEL_ORDERS__Partner_Product_Catalog__c WHERE Id IN : prodCatalogIds])
        {
            //List all Partner Product catalog names
            for(CHANNEL_ORDERS__Partner_Product_Catalog__c prodCatlog : prodcatalogList){
                prodCatalogToNameMap.put(prodCatlog.Id,prodCatlog.Name);
                partnerProdCatlogNames.add(prodCatlog.Name);
            }
        }        
        system.debug('******prodCatalogToNameMap*******'+prodCatalogToNameMap);         
        for(List<NI_DeploymentInstanceIndex__c> IndexList : [SELECT Id,Name FROM NI_DeploymentInstanceIndex__c WHERE Name IN : prodCatalogToNameMap.Values()]){
            for(NI_DeploymentInstanceIndex__c index : indexList)
            {                            
                indexNameToIdMap.put(index.Name,Index.Id);
                //Check that DI Index Exists
                If(partnerProdCatlogNames.contains(index.Name))
                    partnerProdCatlogNames.remove(index.Name);
            }
        }
        //Create the new DI Index if not Exist related to the Partner Product catalog
        if(!partnerProdCatlogNames.IsEmpty()){
            List<NI_DeploymentInstanceIndex__c> newIndexList = new List<NI_DeploymentInstanceIndex__c>();
            for(String s : partnerProdCatlogNames){
                NI_DeploymentInstanceIndex__c newIndex = new NI_DeploymentInstanceIndex__c();
                newIndex.Name = s;
                newIndexList.add(newIndex);    
            } 
            Database.Insert(newIndexList);
            for(List<NI_DeploymentInstanceIndex__c> IndexList : [SELECT Id,Name FROM NI_DeploymentInstanceIndex__c WHERE Name IN : partnerProdCatlogNames]){
                for(NI_DeploymentInstanceIndex__c index : indexList)
                {                
                    indexNameToIdMap.put(index.Name,Index.Id);                    
                }
            }           
        }
        system.debug('******indexNameToNIdMap*******'+indexNameToIdMap);
        for(Product2 prod : newTrigger){
            if(prodCatalogToNameMap.containsKey(prod.Partner_Product_Catalog__c))
                prod.DI_Index__c = indexNameToIdMap.get(prodCatalogToNameMap.get(prod.Partner_Product_Catalog__c));            
        }
        system.debug('******newTrigger*******'+newTrigger);
        //Call the validate method on update action which validates duplicate DI's
        If(IsUpdate){
            if (!processDIIndexChanges(newTrigger, oldMapTrigger, true))
            { 
                // IF FAILED. MAY RESULT IN CREATION OF DUPLICATE DI (SAME DI INDEX) 
                // AND ALSO MAY FAIL DUE TO REASSIGNMENT OF SOFTRAX ASSETS
                newTrigger[0].DI_Index__c.addError('The requested DI Index change may result in one or more duplicate Deployment Instances. This change requires technical assistance from the System Administrator.');
            }
        }
         
    }*/
    
}