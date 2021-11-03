/****************************************************************************************
Name            : NI_DeploymentInstance_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 2/6/2014
Last Mod Date   : 7/14/2017 
Last Mod By     : Ria Chawla
NICC Reference  : NICC-009258
Description     : Class that handles all trigger code for the Deployment Instance Object
                : Updated CreateCancellationRecords method on 2/4/2016 to deprecate the use of
                : DI_to_Softrax_Asset__c junction object
                : 
                : 
******************************************************************************************/
public class NI_DeploymentInstance_TriggerHandler 
{
    
    private boolean m_isExecuting = false;
    public static boolean mergeProcessStatus = false;
    public static boolean isBypassTrigger;
    
    public NI_DeploymentInstance_TriggerHandler(boolean isExecuting)
    {
        
        m_isExecuting = isExecuting;
        NI_DeploymentInstance_TriggerHandler.isBypassTrigger = NI_FUNCTIONS.bypassTriggerCode('ASSET');
    }
    
    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }
    
    // ========================================================================================================================
    //  TRIGGER EVENTS ========================================================================================================
    // ========================================================================================================================    
    
    public void OnBeforeInsert(List<Asset> newTrigger)
    {
        if (!NI_DeploymentInstance_TriggerHandler.isBypassTrigger)
        {     
            set<id> SetProduct2Id = new set<id>();
            //List<AggregateResult> accList = new List<AggregateResult>();
            for (Asset di : newTrigger)
            {
                SetProduct2Id.add(di.Product2Id);      
                if(di.Core_DI__c == null) 
                    di.IsHostedDI__c = di.Hosted__c;
            }
            
            if(!SetProduct2Id.isempty())
                syncFieldsToProducts(newTrigger,SetProduct2Id);
            
            //FUNCTION IS CALLED TO UPDATE DATES ON DI BEFORE INSERT ADDED BY RIA 7/14
            updateQuanDatesonDI(newTrigger);
            
            //by kasim
            //updateDIHosted(newTrigger); 
        }                      
    }
    
    public void OnBeforeUpdate(List<Asset> newTrigger, Map<Id, Asset> oldMapTrigger)
    {
        system.debug('onBeforeupdate');
        //set<id> updatedAccDIs = new set<id>();
        //map<string,string> updatedDIAccMap = new map<string,string>();
        //map<string,string> updatedDIProdMap = new map<string,string>();
        Set<String> versionIdSet = new set<string>();
        set<id> SetProduct2Id = new set<id>();         
        set<Id> SetPurchasedProductId = new set<Id>();
        Set<Id> coreDIUpdatedSet = new Set<Id>();
        Set<Id> versionORHostedUpdatedDI = new Set<Id>();
        List<Asset> coreDIUpdatedAssets = new List<Asset>();        
        Set<Id> purProdIdSet = new Set<Id>();
        Set<Id> prod2IdSet = new Set<Id>();
        //        Set<Id> diIdSet = new Set<Id>();
        Set<Id> diIdSetDate = new Set<Id>();
        Set<Id> diIdSetDateNull = new Set<Id>();
        
        
        if (!NI_DeploymentInstance_TriggerHandler.isBypassTrigger)
        {            
            for(Asset asObj: newTrigger){				
                Asset oldAsset = oldMapTrigger.get(asObj.Id);
                
                //                if((asObj.Recalculate_Quantity_Ordered__c != oldAsset.Recalculate_Quantity_Ordered__c) &&
                //                  asObj.Recalculate_Quantity_Ordered__c == true){
                //                      diIdSet.add(asObj.Id);
                //                      asObj.Recalculate_Quantity_Ordered__c = false; 
                //                }
                
                if((oldAsset.Purchased_Version__c != asObj.Purchased_Version__c) &&
                   (asObj.Purchased_Version__c != null)){
                       System.debug('*** version Id *** '+asObj.Purchased_Version__c);
                       versionIdSet.add(asObj.Purchased_Version__c);
                       if(oldAsset.Product2Id != null){
                           prod2IdSet.add(oldAsset.Product2Id);
                       }
                   }
                
                if(asObj.Product2Id != NULL && asObj.Product2Id != oldAsset.Product2Id){
                    asObj.IsHostedDI__c = asObj.Hosted__c;  
                    SetProduct2Id.add(asObj.Product2Id);
                }
                
                if(asObj.Purchase_Status__c != oldAsset.Purchase_Status__c && asObj.Purchase_Status__c != null){
                    //CHECK IF PURCHASE STATUS CHANGES FROM 'PURCHASED' TO 'INSTALLED'
                    if(asObj.Purchase_Status__c.equals('Installed') && 
                       oldAsset.Purchase_Status__c.equals('Purchased') && 
                       asObj.Status.equals('Installed')){
                           if(asObj.Purchased_Product__c != null){
                               asObj.Activation_Date__c = Date.today(); 
                           }
                           //CHECK IF PURCHASED VERSION IS NULL OR NOT
                           if((asObj.Purchased_Version__c != null)){
                               versionIdSet.add(asObj.Purchased_Version__c);
                               //added by Ria-5/2/2017
                               //CREATE A SET TO HOLD ASSET'S PURCHASED PRODUCT'S ID TO FETCH DI INDEX OF IT
                               if(asObj.Purchased_Product__c != null){
                                   purProdIdSet.add(asObj.Purchased_Product__c);
                               }
                               //CREATE A SET TO HOLD ASSET'S PRODUCT2 ID TO FETCH DI INDEX OF IT
                               if(oldAsset.Product2Id != null){
                                   prod2IdSet.add(oldAsset.Product2Id);
                               }
                           }
                           //IF PURCHASED VERSION IS NULL
                           else{
                               if(asObj.Purchased_Product__c != null){
                                   SetPurchasedProductId.add(asObj.Purchased_Product__c);
                               }
                           }
                       }
                }
                
                //ADDED BY RIA 7/14 TO CALL FUNCTION TO UPDATE DATES ON DI IF STATUS IS CHANGED
                if((asObj.Status != null) && (asObj.Status != oldAsset.Status)){
                    diIdSetDate.add(asObj.Id);
                }
                
                //added by Supriya
                if((asObj.Status != 'Inactive') && (asObj.Quantity_Ordered__c != oldAsset.Quantity_Ordered__c) &&
                   (oldAsset.Quantity_Provisioned__c == oldAsset.Quantity_Ordered__c) &&
                   (asObj.Quantity_Ordered__c != null)){
                       asObj.Quantity_Provisioned__c = asObj.Quantity_Ordered__c;
                   }
                
                if ((asObj.Core_DI__c != null) && (asObj.Core_DI__c != oldAsset.Core_DI__c))
                {
                    coreDIUpdatedSet.add(asObj.Core_DI__c);
                    coreDIUpdatedAssets.add(asObj);
                }
                
                /*SHIFTED THIS PART OF CODE TO A FUNCTION IN NI_DeploymentInstanceTrgHndlrFunctns CLASS BY RIA 7/14
* if (asObj.Status == 'Inactive' && asObj.Status != oldAsset.Status){
asObj.Activation_Date__c = null;
asObj.Usage_End_Date__c = Date.Today();
}
else 
{
if ((asObj.Status != 'Inactive') && (asObj.Status != oldAsset.Status) && (oldAsset.Status == 'Inactive'))
{   
asObj.Usage_End_Date__c = null;
}
}*/
                //added By Supriya on 3/7/2017
                /*if((asObj.Status != oldAsset.Status) && (asObj.Status == 'Installed')){
if(asObj.InstallDate == null){
asObj.InstallDate = Date.today();
asobj.Activation_Date__c = Date.today();
}
else{
asobj.Activation_Date__c = asObj.InstallDate; 
}
}*/
                
                if(asObj.Version__c != oldAsset.Version__c || asObj.IsHostedDI__c != oldAsset.IsHostedDI__c){   
                    versionORHostedUpdatedDI.add(asObj.id);
                }
                
                if((asObj.Purchased_Product__c != null) && (asObj.Purchased_Product__c != oldMapTrigger.get(asObj.Id).Purchased_Product__c)){
                    SetPurchasedProductId.add(asObj.Purchased_Product__c);
                    if(oldAsset.Product2Id != null){
                        prod2IdSet.add(oldAsset.Product2Id);
                    }
                }
                
                //added by Supriya on 3/31/2017
                //if any of the Date fields is null and user makes an update to DI
                //the Date fields are set to the Created Date of DI
                if(asObj.installDate == null && asObj.Status.equals('Installed')){
                    asObj.installDate = asObj.CreatedDate.date(); //new
                    asObj.Activation_Date__c = asObj.CreatedDate.date(); //new
                }
                if(asObj.Purchase_Date__c == null && (asObj.Status.equals('Installed') || asObj.Status.equals('Purchased'))){
                    asObj.Purchase_Date__c = asObj.CreatedDate.date(); //new
                }
                if(asObj.installDate != null && asObj.Activation_Date__c == null && asObj.Status.equals('Installed')){
                    asObj.Activation_Date__c = asObj.installDate;
                }
            }
            
            if (!SetProduct2Id.isempty())
            {
                syncFieldsToProducts(newTrigger, SetProduct2Id);
            }
            
            
            if (!SetPurchasedProductId.isempty())
            {
                syncFieldsToPurchase(newTrigger, oldMapTrigger, SetPurchasedProductId, prod2IdSet);
            }
            
            
            
            if (!versionIdSet.isempty())	 
            {
                updatePurchasedProductInformation(newTrigger, oldMapTrigger, versionIdSet, purProdIdSet, prod2IdSet);
            }
            
            
            if (!coreDIUpdatedSet.isEmpty())
            {
                updateDIHosted(coreDIUpdatedSet,coreDIUpdatedAssets);
            }
            
            if (!versionORHostedUpdatedDI.isempty())
            {
                checkVersionUpdated(newTrigger,oldMapTrigger);
            }
            
            
            if (!diIdSetDate.isEmpty())
            {
                updateDateOnStatChng(newTrigger, oldMapTrigger);
            }
            
            updateRollupSummaryFields(newTrigger, oldMapTrigger);
            
        }
        
    }
    
    
    
    
    public void OnBeforeDelete(List<Asset> oldTrigger)
    {
        set<id> deletedCoreAssetIds= new set<id>();
        //Loop through deleted records
        for(Asset a : oldTrigger)
        {
            deletedCoreAssetIds.add(a.id);
        }
        //delete peripheral assets if exists for the deleted asset.
        if(!deletedCoreAssetIds.isEmpty())
            deletePeripheralDIs(deletedCoreAssetIds);
    }
    
    
    public void OnAfterInsert(List<Asset> newTrigger)
    {   
        if (!NI_DeploymentInstance_TriggerHandler.isBypassTrigger)
        {            
            writeNewHistory(newTrigger);
            
            /*-------------------------------------------           
Added by: Sunita Mittal
Added on:12/31/2015
Description:For Update the Type on Account           
----------------------------------------------*/                    
            //Variables to hold values of updated records
            Set<Id> accIdList = new Set<Id>();
            Set<Id> assetIds = new Set<Id>();
            Set<Id> parentDIIds = new Set<Id>();
            Set<Id> statusInstallIds = new Set<Id>();
            
            // this set will store all child di's whose status is updated to Inactive
            
            set<id> allParentIdForStatus = new set<id>();
            
            //Loop through updated DI records   
            for(Asset a : newTrigger)
            {
                //Check if accountId is null
                if(a.AccountId != Null)
                {
                    accIdList.add(a.AccountId);
                    assetIds.add(a.Id);
                }                 
                //Check if Quantity Received is null and Parent DI is null
                if(a.Quantity_Received__c != Null && a.Parent_DI__c != Null)
                {
                    parentDIIds.add(a.Parent_DI__c);
                }
                //Check if status is Installed
                if(a.Status != Null && a.Status == 'Installed')
                {
                    statusInstallIds.add(a.Id);
                }         
                if(a.Parent_DI__c != NULL && a.Status == 'Inactive' )
                {
                    allParentIdForStatus.add(a.Parent_DI__c);
                }    
            }
            if(!accIdList.isEmpty())
            {
                //Call method that update the "Type" field on Account
                updateAccntType(accIdList);
                //Call method that links the Deployment Instance to OpportunityLineItem  
                //OptyLineItemrelatedList(accIdList,assetIds);
            }
            
            //Call Method that Rollup of "Quantity Recevied" and Update the Status field on Child Dis if Parent DI's Status is 'Installed'            
            if(!parentDIIds.isempty())
                rollupQuantReceive(parentDIIds,statusInstallIds);
            //Call method to update Core-Peripheral DI's
            if(!assetIds.isempty())
                assignCorePeripheralDis(assetIds);                   
            
            
            
            //change status of parent di to inactive if all child di's are inactive
            if(!allParentIdForStatus.isempty())
            {
                updateParentDIStatus(allParentIdForStatus);
            } 
            
        }
        
    }
    
    
    public void OnAfterUpdate(List<Asset> newTrigger, Map<Id, Asset> oldMapTrigger)
    {
        system.debug('OnAfterUpdate');
        if (!NI_DeploymentInstance_TriggerHandler.isBypassTrigger)
        {
            /*---------------------------------------
Added by: Sunita Mittal
Added on:12/31/2015
Description:For Update the Type on Account
-------------------------------------------*/
            //Variables to hold values of updated DI records
            Set<Id> accIdList = new Set<Id>();
            Set<Id> assetids = new Set<Id>();
            Set<Id> childIds = new Set<Id>();
            Set<Id> parentDIIds = new Set<Id>();
            Set<Id> statusInstallIds = new Set<Id>();
            set<id> mergeDI = new set<id>();
            Set<Id> parentStatusInstall = new Set<Id>();
            
            
            //Variable to hold values of Code DI Id's
            Set<String> coreDIIdSet = new Set<String>();
            //Set variable to hold values of DI Status
            Set<String> coreDIIdStatusSet = new Set<String>();
            //hold values of inactivated DI's
            List<Asset> coreInactiveDIList = new List<Asset>();
            
            
            
            set<id> mergeChainDI = new set<id>();
            // this set will store all child di's whose status is updated to Inactive
            
            set<id> allParentIdForStatus = new set<id>();
            
            //Loop through updated records
            for(Asset a : newTrigger)
            {
                //Get old values of updated record
                Asset oldAsset = oldMapTrigger.get(a.Id);
                
                //Check if Core DI is updated and Hosted__c is set to true
                if(a.Core_DI__c == null && (a.IsHostedDI__c != oldAsset.IsHostedDI__c)){
                    coreDIIdSet.add(a.Id);
                }
                //status values of DI
                Set<String> statusSet = new Set<String>{'Inactive', 'Purchased', 'Installed'};
                    //Check if Core DI's status is updated to any value added on above set
                    //If yes, update Core DI record
                    if(a.Core_DI__c == null && statusSet.contains(a.Status) && (a.Status != oldAsset.Status)){
                        coreDIIdStatusSet.add(a.Id);
                        
                        if(a.Status == 'Inactive')
                            coreInactiveDIList.add(a);
                    }
                
                
                
                //Check if accountId is not null and status is changed
                if((a.AccountId != Null && a.AccountId != oldAsset.AccountId) || (a.Status != oldAsset.Status))
                    accIdList.add(a.AccountId);
                //Check if product is changed OR isHostedDI is changed OR status is changed 
                if((a.Product2Id != oldAsset.Product2Id) || (a.IsHostedDI__c != oldAsset.IsHostedDI__c) || (a.Status != oldAsset.Status))
                {
                    assetids.add(a.Id);
                    //accids.add(a.AccountId);
                } 
                
                /*
* @ Added On: 2/2/2016
* @ Description: Rollup of Quantity Recevied
*/  
                //Check that Quantity Received is Updated
                if(a.Quantity_Received__c != oldAsset.Quantity_Received__c){
                    parentDIIds.add(a.Parent_DI__c);
                }  
                
                /*//Check that status is updated to "Installed" on Parent DI
if(a.Status == 'Installed' && (a.Status != oldAsset.Status)){
parentStatusInstall.add(a.Id);
}*/
                //Check that "Parent DI" is Updated
                if(a.Parent_DI__c != NULL && a.Parent_DI__c != oldAsset.Parent_DI__c){
                    childIds.add(a.Id);
                }     
                
                if(a.Parent_DI__c != NULL && a.Status != oldAsset.Status && a.Status == 'Inactive' ){
                    allParentIdForStatus.add(a.Parent_DI__c);
                }
                
                /*if(a.Status == 'Installed' && (a.Status != oldAsset.Status)){
statusInstallIds.add(a.Id);
}*/
                
                /*
if((a.AccountId_DIIndexID__c == null || a.AccountId_DIIndexID__c == '') && NI_DeploymentInstance_TriggerHandler.mergeProcessStatus == false){
mergeDI.add(a.id);
}else{
mergeChainDI.add(a.id);
}*/          
            }
            
            //Update Peripheral DI
            updatePeripheralDI(coreDIIdSet,coreDIIdStatusSet,coreInactiveDIList);
            
            //Call method that update the "Type" field on Account
            if(!accIdList.isEmpty()){
                updateAccntType(accIdList);
            }
            //Call method that links the Deployment Instance to OpportunityLineItem 
            //if(!assetids.isEmpty())
            //{
            //OptyLineItemrelatedList(accids,assetIds);
            //} 
            
            //Call Method that Rollup of "Quantity Recevied"            
            rollupQuantReceive(parentDIIds,statusInstallIds);
            
            //CAll Method that update "IsHostedDI" field
            if(!assetids.isEmpty() || !childIds.isEmpty()){
                callUpdateHostedOnDI(assetIds,childIds,accIdList,oldMapTrigger);
            }                                                   
            
            //change status of parent di to inactive if all child di's are inactive
            if(!allParentIdForStatus.isempty()){
                updateParentDIStatus(allParentIdForStatus);
            }
            
            
            // if any duplicate DI detected, merge that di into found master DI
            // Note: always keep merge method call at the end.
            
            //system.debug('mergeDI==='+mergeDI);
            //&& NI_DeploymentInstance_TriggerHandler.mergeProcessStatus == false
            /*if(!mergeDI.isempty() && NI_DeploymentInstance_TriggerHandler.mergeProcessStatus == false){
system.debug('future method called');
//NI_DIMergeController dimerge = new NI_DIMergeController();
//NI_DIMergeController.processDIMerge(mergeDI,NI_Product2_Triggerhandler.productOldDIXTrack);

}else if(!mergeDI.isempty() && NI_DeploymentInstance_TriggerHandler.mergeProcessStatus == true){

}*/
        }       
        
    } 
    
    
    public void OnAfterDelete(List<Asset> oldTrigger)
    {
        if (!NI_FUNCTIONS.bypassTriggerCode('ASSET'))
        {
            /*-----------------------------------------
Added by: Sunita Mittal
Added on:12/31/2015
Description:For Update the Type on Account
-------------------------------------------*/
            //Variables to hold values of deleted records
            Set<Id> accIdList = new Set<Id>();
            Set<Id> parentDIIds = new Set<Id>();
            Set<Id> statusInstallIds = new Set<Id>();
            set<id> deletedCoreAssetIds= new set<id>();
            //Loop through deleted records
            for(Asset a : oldTrigger)
            {
                deletedCoreAssetIds.add(a.id);
                if(a.AccountId != Null)
                    accIdList.add(a.AccountId);
                
                if(a.Parent_DI__c != Null && a.Quantity_Received__c != Null){
                    parentDIIds.add(a.Parent_DI__c);
                }            
            }
            //Call method that update the "Type" field on Account
            if(!accIdList.isEmpty())
                updateAccntType(accIdList); 
            
            //Call Method that Rollup of "Quantity Recevied"           
            rollupQuantReceive(parentDIIds,statusInstallIds);       
            
            
        }                 
    }
    
    
    public void OnAfterUnDelete(List<Asset> newTrigger)
    {
        if (!NI_FUNCTIONS.bypassTriggerCode('ASSET'))
        {
            /*-------------------------------------------------------
Added by: Sunita Mittal
Added on:12/31/2015
Description:For Update the Type on Account
---------------------------------------------------------*/
            //Variables to hold values of undeleted records
            Set<Id> accIdList = new Set<Id>();
            Set<Id> assetIds = new Set<Id>();
            Set<Id> parentDIIds = new Set<Id>();
            Set<Id> statusInstallIds = new Set<Id>();
            //Loop through undeleted DI records
            for(Asset a : newTrigger)
            {
                if(a.AccountId != Null){
                    accIdList.add(a.AccountId);
                    assetids.add(a.Id);
                }
                //Check if Parent Id and Quantity Received is not null
                if(a.Parent_DI__c != Null && a.Quantity_Received__c != Null){
                    parentDIIds.add(a.Parent_DI__c);
                } 
                //Check if Status is Installed
                if(a.Status != Null && a.Status == 'Installed')
                {
                    statusInstallIds.add(a.Id);
                } 
                
            }
            if(!accIdList.isEmpty()){
                //Call method that update the "Type" field on Account
                updateAccntType(accIdList);
            } 
            
            //Call Method that Rollup of "Quantity Recevied"           
            rollupQuantReceive(parentDIIds,statusInstallIds);                  
        }
        
    } 
    
    public void writeNewHistory(List<Asset> newTrigger){
        
        // CREATE A LIST OF DEPLOYMENT INSTANCE RECORDS THAT WERE INSERTED
        List<Asset> lstAssets = new List<Asset>([
            SELECT Id, Name, Annual_Subscription_Amount__c, Cendyn_Location_ID__c, InstallDate,
            IsHostedDI__c, MeetingMatrix_Product_Key__c, Product2.ProductCode, Product2.Name, WriteHistory__c, 
            PurchaseDate, Quantity_Billed__c, Quantity_Ordered__c, Quantity_Provisioned__c, Product_Family__c,
            Ship_Date__c, Status, UsageEndDate, Version__r.Name, Product2Id, Product_Line__c, Product_Group__c
            FROM Asset
            WHERE Id IN: newTrigger
        ]);
        
        // CREATE A LIST OF DEPLOYMENT INSTANCE HISTORY RECORDS TO INSERT
        List<NI_Deployment_Instance_History__c> lstDIHistoryToInsert = new List<NI_Deployment_Instance_History__c>();
        
        // CREATE A SET TO HOLD THE PRODUCT2ID VALUES OF THE DEPLOYMENT INSTANCES IN THE OLDMAPTRIGGER
        Set<Id> SetProduct2Id = new Set<Id>();
        
        // CREATE A SET TO HOLD THE VERSION ID's OF THE DEPLOYMENT INSTANCES IN THE OLDMAPTRIGGER
        Set<Id> SetVersionId = new Set<Id>();
        
        // CREATE A SET TO HOLD THE PRODUCT GROUP ID's OF THE DEPLOYMENT INSTANCES IN THE OLDMAPTRIGGER
        Set<Id> SetGroupId = new Set<Id>();  
        
        // CREATE A SET TO HOLD THE PRODUCT Line ID's OF THE DEPLOYMENT INSTANCES IN THE OLDMAPTRIGGER
        Set<String> SetLineId = new Set<String>();
        
        
        for (Asset di: lstAssets)
        {
            SetProduct2Id.add(di.Product2Id);
            SetVersionId.add(di.Version__c);
            SetGroupId.add(di.Product_Group__c);
            SetLineId.add(di.Product_Line__c);
        }  
        
        //CREATE A MAP TO HOLD THE RELATED PRODUCT RECORDS FOR THE DEPLOYMENT INSTANCES THAT HAVE BEEN UPDATED  
        Map<Id, Product2> mapProd = new Map<Id, Product2>([SELECT Id, ProductCode,Name, Product_Line__c, Product_Group__c,
                                                           Product_Group__r.Name 
                                                           FROM Product2
                                                           WHERE Id IN: SetProduct2Id]);
        
        //CREATE A MAP TO HOLD THE RELATED VERSION RECORDS FOR THE DEPLOYMENT INSTANCES THAT HAVE BEEN UPDATED  
        Map<Id, SFDC_CSP_Version__c> mapVersion = new Map<Id, SFDC_CSP_Version__c>([SELECT Id, Name 
                                                                                    FROM SFDC_CSP_Version__c
                                                                                    WHERE Id IN: SetVersionId]);
        
        //CREATE A MAP TO HOLD THE RELATED VERSION RECORDS FOR THE DEPLOYMENT INSTANCES THAT HAVE BEEN UPDATED  
        Map<Id, Product_Group__c> mapGroup = new Map<Id, Product_Group__c>([SELECT Id, Name 
                                                                            FROM Product_Group__c
                                                                            WHERE Id IN: SetGroupId]);    
        
        /*Map<Id, Product_Line__c> mapLine = new Map<Id, Product_Line__c>([Select Id, Name 
from Product_Line__c 
where Id IN : SetLineId]);*/
        
        //LOOP THROUGH THE NEWTRIGGER LIST OF DEPLOYMENT INSTANCES
        for (Asset a : lstAssets) 
        {
            
            NI_Deployment_Instance_History__c d = new NI_Deployment_Instance_History__c(); 
            
            d.Name = a.Name;
            d.Annual_Subscription_Amount__c = a.Annual_Subscription_Amount__c;
            d.Cendyn_Location_ID__c = a.Cendyn_Location_ID__c;
            d.Install_Date__c = a.InstallDate;
            d.IsHostedDI__c = a.IsHostedDI__c;
            d.MeetingMatrix_Product_Key__c = a.MeetingMatrix_Product_Key__c;
            d.Modified_By__c = UserInfo.getName();
            
            if (MapProd.get(a.Product2Id).ProductCode != null)
            {
                d.Product_Code__c = MapProd.get(a.Product2Id).ProductCode;
            }  
            
            if (MapProd.get(a.Product2Id).Name != null)
            {
                d.Product_Name__c = MapProd.get(a.Product2Id).Name;
            }  
            
            d.Purchase_Date__c = a.PurchaseDate;
            d.Quantity_Billed__c = a.Quantity_Billed__c;
            d.Quantity_Ordered__c = a.Quantity_Ordered__c;
            d.Quantity_Provisioned__c = a.Quantity_Provisioned__c;
            d.Product_Family__c = a.Product_Family__c;
            d.Related_Deployment_Instance__c = a.Id;
            d.Ship_Date__c = a.Ship_Date__c;
            d.Status__c = a.Status;
            d.Usage_End_Date__c = a.UsageEndDate;
            
            if (a.Version__c != null)
            {
                d.Version__c = mapVersion.get(a.Version__c).Name;
            }  
            
            if (mapGroup.containskey(a.Product_Group__c) && mapGroup.get(a.Product_Group__c).Name != null)
            {
                d.Product_Group__c = mapGroup.get(a.Product_Group__c).Name;
            }
            
            d.Product_Line__c = a.Product_Line__c;
            
            if (mapProd.get(a.Product2Id).Product_Group__r.Name != null)
            {
                d.Product_Product_Group__c = mapProd.get(a.Product2Id).Product_Group__r.Name;
                
            } 
            
            if (mapProd.get(a.Product2Id).Product_Line__c != null)
            {
                d.Product_Product_Line__c = mapProd.get(a.Product2Id).Product_Line__c;
            }  
            
            lstDIHistoryToInsert.add(d);
            
        }   
        
        //USE DATABASE DML METHOD TO INSERT THE DEPLOYMENT INSTANCE HISTORY RECORDS
        if (lstDIHistoryToInsert.size() > 0)
        {
            Database.SaveResult[] results = Database.Insert(lstDIHistoryToInsert, false);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess())
                {
                    //                    Database.Error err = sr.getErrors()[0];
                    //                    System.debug(err.getMessage());
                } 
            } 
        } 
    }  
    
    public void updateDateOnStatChng(List<Asset> newTrigger, Map<Id, Asset> oldMapTrigger){
        for(Asset asObj: newTrigger){				
            Asset oldAsset = oldMapTrigger.get(asObj.Id);
            if((asObj.Status == 'Installed')){
                if(asObj.InstallDate == null){
                    asObj.InstallDate = Date.today();
                    asobj.Activation_Date__c = Date.today();
                }
                else{
                    asobj.Activation_Date__c = asObj.InstallDate; 
                }
            }
            
            if (asObj.Status == 'Inactive'){
                asObj.Activation_Date__c = null;
                asObj.Usage_End_Date__c = Date.Today();
            }
            else 
            {
                if ((asObj.Status != 'Inactive') && (oldAsset.Status == 'Inactive'))
                {   
                    asObj.Usage_End_Date__c = null;
                }
            }
        }
    }
    
    /**
*
* @description Mehtod to update the Product2Id, Version and Fields under "New Purchase" section
* @params List<Asset> newTrigger, Map<Id, Asset> oldMapTrigger
* @date 12/07/2015
*/
    public void updatePurchasedProductInformation(List<Asset> newTrigger, Map<Id, Asset> oldMapTrigger,Set<String> versionIdSet, Set<Id> purProdIdSet, Set<Id> prod2IdSet){
        Boolean executeMethod = true;
        Map<Id, Product2> oldMapDI_Index;
        Map<Id, Product2> newMapDI_Index;
        //Get version related to Deployment Instance
        /*  for(Asset asset: newTrigger){
//Check if Purchase status is null
if(asset.Purchase_Status__c != null && oldMapTrigger.get(asset.Id).Purchase_Status__c != null){
//Check if purchase status change from "Purchased" to "Installed"
if(asset.Purchase_Status__c.equals('Installed') && oldMapTrigger.get(asset.Id).Purchase_Status__c.equals('Purchased')){
//Check if Purchased Version is null or not
if(asset.Purchased_Version__c != null){
System.debug('*** version Id *** '+asset.Purchased_Version__c);
versionIdSet.add(asset.Purchased_Version__c);
}
}
}
}*/
        //If versionIdSet is empty, don't fire SOQL query
        Map<String, SFDC_CSP_Version__c> versionMap;
        if(!versionIdSet.isEmpty()){
            versionMap = new Map<String, SFDC_CSP_Version__c>([SELECT Id, Product_Group__c,Product_Line_Global__c
                                                               from SFDC_CSP_Version__c 
                                                               where Id IN: versionIdSet]);
        }
        else{
            versionMap = new Map<String, SFDC_CSP_Version__c>();
        }
        //added by Ria-5/2/2017
        if(!purProdIdSet.isEmpty()){
            newMapDI_Index = new Map<Id, Product2>([SELECT Id, ProductCode, DI_Index__c,Product_Line_Global__c,Hosted__c
                                                    FROM Product2 
                                                    WHERE Id IN :purProdIdSet]);
        }
        else{
            newMapDI_Index = new Map<Id, Product2>();
        }
        if(!prod2IdSet.isEmpty()){
            oldMapDI_Index = new Map<Id, Product2>([SELECT Id, ProductCode, DI_Index__c,Product_Line_Global__c,Hosted__c
                                                    FROM Product2 
                                                    WHERE Id  =: prod2IdSet]); 
        }
        else{
            oldMapDI_Index = new Map<Id, Product2>();
        }
        //Update values of Product and Version
        for(Asset asset: newTrigger){  
            //Check if Purchase Status is not null
            if(asset.Purchase_Status__c != null && oldMapTrigger.get(asset.Id).Purchase_Status__c != null &&
               asset.Purchase_Status__c != oldMapTrigger.get(asset.Id).Purchase_Status__c){
                   //Check if Purchase Status is updated from Purchsed to Installed
                   if(asset.get('Purchase_Status__c').equals('Installed') && 
                      ((oldMapTrigger.get(asset.Id)).get('Purchase_Status__c')).equals('Purchased') && 
                      oldMapTrigger.get(asset.Id).Status.equals('Installed')){
                          if(asset.Purchased_Version__c != null){ 
                              asset.Version__c = asset.Purchased_Version__c;
                          }                                         
                          //If Purchased Product is not null, update product on DI
                          if(asset.Purchased_Product__c != null){
                              asset.Product2Id = asset.Purchased_Product__c;
                              asset.IsHostedDI__c = newMapDI_Index.get(asset.Purchased_Product__c).Hosted__c;                             
                          }
                          
                          //If purchased Version is not null, update product group and version on DI
                          if(versionMap.get(asset.Purchased_Version__c) != null)
                              asset.Product_Group__c = versionMap.get(asset.Purchased_Version__c).Product_Group__c; 
                          
                          //Set Purchased Product, Purchased Version and Opportunity field to blank
                          asset.Purchased_Product__c = NULL;
                          asset.Purchased_Version__c = NULL;                                     
                          asset.Opportunity__c = NULL;
                          asset.Purchase_Status__c = NULL;
                          asset.Integration_User_Source__c = 'Updated when Purchased Status updated to Installed for DI#'+asset.Name;
                          System.debug('*** version *** '+asset.Version__c);
                      }
               }
            if(asset.Purchased_Version__c != null){
                if(versionMap.get(asset.Purchased_Version__c).Product_Line_Global__c != oldMapDI_Index.get(asset.Product2Id).Product_Line_Global__c){
                    asset.Purchased_Version__c.addError('The selected Purchased Version is not valid for this Deployment Instance (Product Line mismatch).');
                } 
            }
        }
    }
    
    
    
    public static void syncFieldsToProducts(List<Asset> newTrigger, set<id> SetProduct2Id)
    {
        //CREATE A MAP TO HOLD THE RELATED PRODUCT RECORDS FOR THE DEPLOYMENT INSTANCES THAT HAVE BEEN UPDATED  
        Map<Id, Product2> mapProd = new Map<Id, Product2>([SELECT Id, ProductCode, Name, Product_Line__c, Product_Group__c,
                                                           Product_Group__r.Name, Product2.DI_Index__r.Name, DI_DefaultStatus__c
                                                           FROM Product2
                                                           WHERE Id IN: SetProduct2Id]);
        
        //system.debug('========== mapProd.Size() = ' + mapProd.Size());
        //system.debug('========== mapProd = ' + mapProd);
        //system.debug('newTrigger==='+newTrigger);
        set<id> testid = new set<id>();
        //LOOP THROUGH THE NEWTRIGGER LIST OF DEPLOYMENT INSTANCES
        for (Asset a : newTrigger) 
        {	           
            //          Asset oldAsset = oldMapTrigger.get(a.Id); 
            //            if (a.Product_Group__c != oldAsset.Product_Group__c)
            //            {            
            if (MapProd.containskey(a.Product2Id) && MapProd.get(a.Product2Id).Product_Group__c != null)
            {                
                a.Product_Group__c = MapProd.get(a.Product2Id).Product_Group__c;                    
            } 
            //            }
            //            if (a.Product_Line__c != oldAsset.Product_Line__c)
            //            {    
            //system.debug('a.Product2Id==='+a.Product2Id+'product code=='+ProductCode);
            //testid.add(a.Product2Id);
            if (MapProd.containskey(a.Product2Id) && MapProd.get(a.Product2Id).Product_Line__c != null)
            {                
                a.Product_Line__c = MapProd.get(a.Product2Id).Product_Line__c;
            }
            //added by Supriya
            /*if(MapProd.containskey(a.Product2Id) && MapProd.get(a.Product2Id).DI_DefaultStatus__c != null 
&& MapProd.get(a.Product2Id).DI_DefaultStatus__c.equals('Installed') && a.InstallDate == null){
a.InstallDate = Date.today();
a.Status = 'Installed';
}*/
            
            //            }
            //Added by Prashant Wayal
            //If Purchansed Product is null, blank out all the fields in New Purchase section
            if(a.Purchased_Product__c == null){
                a.Purchased_Version__c = null;
                a.Purchase_Status__c = null;
                a.Opportunity__c = null;
            }
            
            
        }
        //system.debug('testid=='+testid);
        
    }
    
    
    
    //FUNCTION TO UPDATE QUANTITY AND DATE FIELDS ON DI BEFORE INSERT BY RIA 7/14 
    public static void updateQuanDatesonDI(List<Asset> newTrigger){
        for (Asset di : newTrigger){
            if(di.Status.equals('Installed')){
                if(di.InstallDate == null){
                    di.InstallDate = Date.today();
                    di.Activation_Date__c = Date.today();
                }
                else{
                    di.Activation_Date__c = di.InstallDate;
                }
            }
            if(di.Status.equals('Purchased') || di.Status.equals('Installed')){
                if(di.Purchase_Date__c == null){
                    di.Purchase_Date__c = Date.today();                       
                }
            }
            /*if((di.Status != 'Inactive') && (di.Quantity_Ordered__c != null)){
di.Quantity_Provisioned__c = di.Quantity_Ordered__c;
}*/
        }
    }
    
    /**
* @author Sunita Mittal
* @description Method to update the Hosted field on DI
*/
    public void callUpdateHostedOnDI(Set<Id> parentDIIds, Set<Id> childDIIds, Set<Id> accIdList, Map<Id, Asset> oldMapTrigger)
    {
        //Variable to hold child DI records
        List<Asset> childDIList = new List<Asset>();
        /*COMMENTED 7/7 List<Softrax_Asset__c> saListToCheck = new List<Softrax_Asset__c>();*/
        List<Activity_Line_Item__c> aliListToCheck = new List<Activity_Line_Item__c>();
        system.debug('accIdList'+accIdList);
        List<Account> parentAccList = [SELECT Current_MPE_Cluster__c, Current_MeetingMatrix_MPE_Cluster__c FROM Account Where Id IN :accIdList ];
        Asset oldAsset;
        //Get all DI records and associated billing records related to Parent DI and child DI
        /*COMMENTED 7/7for(Asset asObj: [SELECT Id, AccountId, IsHostedDI__c, Status, Parent_DI__r.IsHostedDI__c, Parent_DI__r.Status, 
(SELECT Id,Product2ID__c,Deployment_Instance__r.Parent_DI__r.Product2Id 
FROM Softrax_Assets__r WHERE Status__c = 'Active') 
FROM Asset WHERE  Parent_DI__c IN : parentDIIds OR Id IN : childDIIds])*/
        for(Asset asObj: [SELECT Id, AccountId, IsHostedDI__c, Status, Parent_DI__r.IsHostedDI__c, Parent_DI__r.Status, 
                          (SELECT Id,Product__c,Deployment_Instance__r.Parent_DI__r.Product2Id 
                           FROM Activity_Line_Item__r WHERE Status__c = 'Active') 
                          FROM Asset WHERE  Parent_DI__c IN : parentDIIds OR Id IN : childDIIds])
        {                               
            //Check if DI has any associated billing records
            //If does not have any billing record then update IsHosted and Status field
            /* COMMENTED 7/7 if(asObj.Softrax_Assets__r.size()>0){
saListToCheck.addAll(asObj.Softrax_Assets__r);
} */
            if(asObj.Activity_Line_Item__r.size()>0){
                aliListToCheck.addAll(asObj.Activity_Line_Item__r);
            }
            if(asObj.Parent_DI__r.Id != null){
                if(oldMapTrigger.get(asObj.Parent_DI__r.Id) != null){
                    oldAsset = oldMapTrigger.get(asObj.Parent_DI__r.Id);                                 
                    if((asObj.Parent_DI__r.Status != 'Installed')){
                        asObj.IsHostedDI__c = asObj.Parent_DI__r.IsHostedDI__c;
                        asObj.Status = asObj.Parent_DI__r.Status;
                        childDIList.add(asObj);
                    }            
                    else if((asObj.Parent_DI__r.Status == 'Installed')){
                        List<Account> accList = [SELECT Current_MPE_Cluster__c, Current_MeetingMatrix_MPE_Cluster__c FROM Account Where Id = :asObj.AccountId ];
                        if(accList[0].Current_MPE_Cluster__c == null && accList[0].Current_MeetingMatrix_MPE_Cluster__c == null ){
                            asObj.IsHostedDI__c = asObj.Parent_DI__r.IsHostedDI__c;
                            asObj.Status = asObj.Parent_DI__r.Status;
                            childDIList.add(asObj);
                        }              
                    }
                }  
                else{
                    asObj.IsHostedDI__c = asObj.Parent_DI__r.IsHostedDI__c;
                    asObj.Status = asObj.Parent_DI__r.Status;
                    childDIList.add(asObj);
                }        
            }  
        }
        //Update child DI records
        if(!childDIList.isEmpty()){
            update childDIList;
        }
        //Update hosted field on DI
        
        /*COMMENTED 7/4*/
        /*if(!saListToCheck.isEmpty()){

//NI_SoftraxAsset_TriggerHandler handler = new NI_SoftraxAsset_TriggerHandler();
//handler.updateHostedOnDI(saListToCheck);
}*/
        if(!aliListToCheck.isEmpty()){
            
            //NI_SoftraxAsset_TriggerHandler handler = new NI_SoftraxAsset_TriggerHandler();
            //handler.updateHostedOnDI(aliListToCheck);
            updateHostedOnDI(aliListToCheck);
        }
    }
    
    /*METHOD ADDED FROM NI_SoftraxAsset_TriggerHandler class BY RIA 7/13*/
    public void updateHostedOnDI(List<Activity_Line_Item__c> saList)
    {        
        Set<Id> assetIds = new Set<Id>();        
        for(Activity_Line_Item__c sa : saList)
        {
            if(sa.Product__c != sa.Deployment_Instance__r.Parent_DI__r.Product2Id)
            {                
                assetIds.add(sa.Deployment_Instance__c);
            }
        }        
        for(List<Asset> diList : [SELECT Id,IsHostedDI__c,Hosted__c FROM Asset WHERE Id IN : assetIds]){
            for(Asset a : diList)
            {
                a.IsHostedDI__c = a.Hosted__c;
            }            
            database.Update(diList);
        }                
    }
    
    //Added On: 02/15/2016
    //Check If Version/Product is updated and it is linked to Cluster then restrict update
    public void checkVersionUpdated(List<Asset> newTrigger,Map<Id,Asset> oldMapTrigger){
        //Get DI records associated with oldMapTrigger
        Map<Id,Asset> assetMap = new Map<Id,Asset>([SELECT Id,AccountId,AccountId_DIIndexID__c,Account.Current_MPE_Cluster__c,
                                                    Account.Current_MPE_Cluster__r.Version_New__c,Account.Current_MPE_Cluster__r.DI_Index__c,
                                                    Account.Current_MPE_Cluster__r.Hosted__c, Account.Current_MeetingMatrix_MPE_Cluster__c,
                                                    Account.Current_MeetingMatrix_MPE_Cluster__r.Version_New__c,
                                                    Account.Current_MeetingMatrix_MPE_Cluster__r.DI_Index__c,
                                                    Account.Current_MeetingMatrix_MPE_Cluster__r.Hosted__c 
                                                    FROM Asset WHERE id IN: oldMapTrigger.keySet()]);
        Map<Id,Asset> updatedAssetMap = new Map<Id,Asset>();
        //Iterate over all DI records
        for(Asset newAsset : newTrigger){
            //Get old record
            Asset oldAsset = oldMapTrigger.get(newAsset.Id);
            String delphiaccIdIndexId = string.valueOf(assetMap.get(newAsset.Id).AccountId)+string.valueOf(assetMap.get(newAsset.Id).Account.Current_MPE_Cluster__r.DI_Index__c);
            String meetMatrixAccIdIndexId = string.valueOf(assetMap.get(newAsset.Id).AccountId)+string.valueOf(assetMap.get(newAsset.Id).Account.Current_MeetingMatrix_MPE_Cluster__r.DI_Index__c);                
            //Version Change Validation: Check that Version on DI is changed and it is not matches the Cluster Version
            if(newAsset.Version__c != oldAsset.Version__c){
                
                //Delphi DI Version Change
                if(newAsset.AccountId_DIIndexID__c == delphiaccIdIndexId && newAsset.Version__c != assetMap.get(newAsset.Id).Account.Current_MPE_Cluster__r.Version_New__c)
                    newAsset.Version__c.addError('Cannot modify the Version on a DI that is related to a Cluster');
                //Meetingmatrix DI Version Change
                if(newAsset.AccountId_DIIndexID__c == meetMatrixAccIdIndexId && newAsset.Version__c != assetMap.get(newAsset.Id).Account.Current_MeetingMatrix_MPE_Cluster__r.Version_New__c)
                    newAsset.Version__c.addError('Cannot modify the Version on a DI that is related to a Cluster');                    
                if(oldAsset.Version__c != null && newAsset.Status == 'Installed'){
                    newAsset.Activation_Date__c = date.today();
                }                
            }            
            //IsHostedDI Change Validation:Check that IsHostedDI on DI is changed and it is not matches the Cluster Hosted
            if( newAsset.IsHostedDI__c != oldAsset.IsHostedDI__c){                
                //Delphi DI IsHostedDI Change
                if(newAsset.AccountId_DIIndexID__c == delphiaccIdIndexId && newAsset.IsHostedDI__c != assetMap.get(newAsset.Id).Account.Current_MPE_Cluster__r.Hosted__c)
                    newAsset.IsHostedDI__c.addError('Cannot modify the Hosted checkbox on a DI that is related to a Cluster');
                //Meetingmatrix DI IsHostedDI Change                
                if(newAsset.AccountId_DIIndexID__c == meetMatrixAccIdIndexId && newAsset.IsHostedDI__c != assetMap.get(newAsset.Id).Account.Current_MeetingMatrix_MPE_Cluster__r.Hosted__c)                    
                    newAsset.IsHostedDI__c.addError('Cannot modify the Hosted checkbox on a DI that is related to a Cluster');                                          
            }
            
        }
    }
    
    public void syncFieldsToPurchase(List<Asset> newTrigger, Map<Id, Asset> oldMapTrigger,Set<Id> SetPurchasedProductId, Set<Id> prod2IdSet){
        Map<Id, Product2> oldMapDI_Index;
        Map<Id, Product2> purchasedProdMap;
        if(!SetPurchasedProductId.isEmpty()){
            purchasedProdMap = new Map<Id, Product2>([SELECT Id, ProductCode, DI_Index__c,Hosted__c
                                                      FROM Product2 where Id IN: SetPurchasedProductId] );
        }
        else{
            purchasedProdMap = new Map<Id, Product2>();
        }
        
        //added by Ria-5/2/2017
        if(!prod2IdSet.isEmpty()){
            oldMapDI_Index = new Map<Id, Product2>([SELECT Id, ProductCode, DI_Index__c,Hosted__c
                                                    FROM Product2 
                                                    WHERE Id  IN : prod2IdSet]);	
        }
        else{
            oldMapDI_Index = new Map<Id, Product2>();
        }
        //iterate through new trigger
        for(Asset asset1 : newTrigger){
            if(asset1.Purchased_Product__c != oldMapTrigger.get(asset1.Id).Purchased_Product__c){
                //CHECK WHETHER PURCHASED PRODUCT IS UPDATED
                if(asset1.Purchased_Product__c != null){
                    if((!purchasedProdMap.isEmpty())  && (!oldMapDI_Index.isEmpty())){
                        //CHECK THE DI INDEXES OF PRODUCT UPDATED AND PRODUCT PRESENT ON DI
                        if((purchasedProdMap.get(asset1.Purchased_Product__c).DI_Index__c) != (oldMapDI_Index.get(asset1.Product2Id).DI_Index__c)){
                            asset1.Purchased_Product__c.addError('The selected Purchased Product is not valid for this Deployment Instance (DI Index mismatch).');
                        }
                    }
                }
            }
            
            //Check if Purchase Status is not null
            if(asset1.Purchase_Status__c != null && oldMapTrigger.get(asset1.Id).Purchase_Status__c != null){
                //Check if Purchase Status is updated from Purchsed to Installed
                if(asset1.get('Purchase_Status__c').equals('Installed') && ((oldMapTrigger.get(asset1.Id)).get('Purchase_Status__c')).equals('Purchased')){
                    //If Purchased Product is not null, update product on DI
                    if(asset1.Purchased_Product__c != null){
                        asset1.Product2Id = asset1.Purchased_Product__c;
                        asset1.IsHostedDI__c = purchasedProdMap.get(asset1.Purchased_Product__c).Hosted__c;
                    } 
                    if(asset1.Purchased_Version__c == null){                     
                        //Set Purchased Product, Purchased Version and Opportunity field to blank
                        asset1.Purchased_Product__c = NULL;
                        asset1.Purchased_Version__c = NULL;                   
                        asset1.Opportunity__c = NULL;
                        asset1.Purchase_Status__c = NULL;
                    }
                }
            }             
        }
    }
    
    
    /**
* This function creates peripheral di automatically for di being inserted if DI INDEX of current di  
* being inserted has an record same as DI INDEX in DI Management object. DI Management object has two feilds 
* DI Index and Product. If DI INDEX found in DI Management object it will create peripheral DI with the respective product.
*
* @param Set<Id> allAssetID all di to process
* @author Kasim badami
* @return void
* @Created On : 
* @Last modified By : kasim
* @Last modified on : 04/29/2016
*/ 
    public void assignCorePeripheralDis(Set<Id> allAssetID){
        
        if(allAssetID.size() > 0){
            // fetch all di id of all di being inserted and create map
            // that will save all DI di_index wise so that we can map it with DI management object
            set<string> diIndexes = new set<string>();
            map<string,list<asset>> diIndexeAsset = new map<string,list<asset>>();
            map<string,list<string>> diIndexWiseAcconnts = new map<string,list<string>>();
            //map<string,list<asset>> diIndexes = new map<string,list<asset>>();
            //Added Status, IsHostedDI__c fields in query
            // by Prashant Wayal as per change request https://na26.salesforce.com/aM232000000CaRM
            for(list<Asset> allDis : [SELECT Id,name,Product2Id, Product2.DI_Index__c,accountid,account.Franchisor__c, 
                                      Status, IsHostedDI__c from asset where id IN: allAssetID]){
                                          for(Asset di: allDis){
                                              if(diIndexWiseAcconnts.containskey(di.Product2.DI_Index__c)){
                                                  diIndexWiseAcconnts.get(di.Product2.DI_Index__c).add(di.accountid);
                                              }else{
                                                  list<string> tmpacc = new list<string>();
                                                  tmpacc.add(di.accountid);
                                                  diIndexWiseAcconnts.put(di.Product2.DI_Index__c,tmpacc);
                                                  
                                              }
                                              if(di.Product2.DI_Index__c != null){
                                                  diIndexes.add(di.Product2.DI_Index__c);
                                                  if(diIndexeAsset.containskey(di.Product2.DI_Index__c)){
                                                      diIndexeAsset.get(di.Product2.DI_Index__c).add(di);
                                                  }else{
                                                      list<asset> tmpDi = new list<asset>();
                                                      tmpDi.add(di);
                                                      diIndexeAsset.put(di.Product2.DI_Index__c,tmpDi);
                                                  }
                                              }
                                          }
                                      }
            
            system.debug('diIndexWiseAcconnts=='+diIndexWiseAcconnts);
            
            if(diIndexes.size() > 0){
                // fetch all di_index from di mangement and create list of di management records for specific DI_INDEX
                // store di management data into map DI_Index wise
                map<string,list<DI_Management__c>> coreDIIndexWiseProducts = new map<string,list<DI_Management__c>>();
                set<string> chkExistingDI = new set<string>();
                for(list<DI_Management__c> allCoreDis : [SELECT Core_DI_Index__c ,name,Peripheral_DI_Product__c, Peripheral_DI_Product__r.DI_Index__c,Franchisor__c,Relationship__c from DI_Management__c  where Core_DI_Index__c IN: diIndexes ]){
                    for(DI_Management__c coredi: allCoreDis ){
                        if(!diIndexWiseAcconnts.isempty()){
                            
                            list<string> allAcc = new list<string>();
                            if(diIndexWiseAcconnts.containskey(coredi.Core_DI_Index__c)){
                                allAcc = diIndexWiseAcconnts.get(coredi.Core_DI_Index__c);
                                for(string acc :allAcc ){
                                    chkExistingDI.add(acc+''+coredi.Peripheral_DI_Product__r.DI_Index__c);
                                }
                            }
                        }                
                        if(coreDIIndexWiseProducts.containskey(coredi.Core_DI_Index__c)){
                            coreDIIndexWiseProducts.get(coredi.Core_DI_Index__c).add(coredi);
                        }else{
                            list<DI_Management__c> tmp = new list<DI_Management__c>();
                            tmp.add(coredi);
                            coreDIIndexWiseProducts.put(coredi.Core_DI_Index__c,tmp);
                        }
                        
                    }
                }
                //system.debug('chkExistingDI=='+chkExistingDI);
                //system.debug('coreDIIndexWiseProducts=='+coreDIIndexWiseProducts);
                set<string> skipDI = new set<string>();
                if(!chkExistingDI.isempty()){
                    
                    for(list<Asset> existingDi : [SELECT Id,AccountId_DIIndexID__c from asset where AccountId_DIIndexID__c IN: chkExistingDI]){
                        for(Asset exDi: existingDi){
                            skipDI.add(exDi.AccountId_DIIndexID__c);
                        }
                    }
                }
                //system.debug('skipDI=='+skipDI);
                // for all di being added, add peripheral di based on 
                // records in di management. loop through map created above
                list<asset> periDiToAdd = new list<asset>();
                for (string diindex : diIndexeAsset.keySet()) { 
                    //asset coredi  = diIndexeAsset.get(diindex );
                    list<asset> coreDiToProcess = new list<asset>();
                    coreDiToProcess = diIndexeAsset.get(diindex);
                    if(!coreDiToProcess.isempty()){
                        for (asset coreDi: coreDiToProcess ) {
                            if(coreDIIndexWiseProducts.containsKey(diindex)){
                                list<DI_Management__c> peripheraldis = new list<DI_Management__c>();
                                peripheraldis = coreDIIndexWiseProducts.get(diindex);
                                //system.debug('accToProcess='+accToProcess);
                                for (DI_Management__c dim: peripheraldis ) {
                                    if(dim.Relationship__c == 'Core-Peripheral' || (dim.Relationship__c == 'Franchisor' && (dim.Franchisor__c == '' || (dim.Franchisor__c == coreDi.account.Franchisor__c)) )){
                                        if(!skipDI.contains(coreDi.accountid+''+dim.Peripheral_DI_Product__r.DI_Index__c)){
                                            asset periPheralDi = new asset();
                                            //coreDi.accountid
                                            //dim.Peripheral_DI_Product__r.DI_Index__c
                                            periPheralDi = createPeripheralAsset(dim,coreDi);
                                            periDiToAdd.add(periPheralDi);
                                            skipDI.add(coreDi.accountid+''+dim.Peripheral_DI_Product__r.DI_Index__c);
                                        }
                                    } 
                                }    
                            }
                        }
                    }
                }
                if(!periDiToAdd.isempty()){
                    //try{
                    insert periDiToAdd;
                    //}catch(DMLException e){
                    //     for (asset asseterr: periDiToAdd) {
                    //             asseterr.addError('An error occured while inserting peripheral DI. Peripheral DI might be already present');
                    // }
                    //}
                }
                
            }    
            
        }
    }
    
    public asset createPeripheralAsset(DI_Management__c dim, asset coreDi){
        asset periPheralDi = new asset();
        periPheralDi.name = coreDi.name+' - Peripheral';
        periPheralDi.Accountid = coreDi.accountid;
        periPheralDi.Product2id = dim.Peripheral_DI_Product__c;
        periPheralDi.Core_DI__c = coreDi.id;
        //Added by Prashant Wayal as per change request https://na26.salesforce.com/aM232000000CaRM
        periPheralDi.Status = coreDi.Status; 
        periPheralDi.IsHostedDI__c = coreDi.IsHostedDI__c;
        //Upto here
        periPheralDi.Integration_User_Source__c = 'Created as per Core Peripheral DI Mainatainance';
        return periPheralDi;
    }
    
    /*
* @Author: 
* @Added On: 02/02/2016
* @Description: Roll up of "Quantity Recevied" to "Quantity Distributed" on parent DI
*/   
    public void rollupQuantReceive(Set<Id> parentDIIds,Set<Id> statusInstalledIds)
    {
        //Variable to hold all DI records being updated
        List<Asset> updateDiList = new List<Asset>();
        //Update the "Quantitty Distributed" on Parent DI i.e Roll Up of Child DI's Quantity Received
        if(!parentDIIds.isEmpty())
        {
            //List all Child DIs for each Parent DI
            Map<Id,Asset> childDIList = new Map<Id,Asset>([SELECT Quantity_Received__c,Parent_DI__c FROM Asset Where Parent_DI__c IN : parentDIIds]);
            Map<Id,Integer> parentDIIdtoQuantMap = new Map<Id,Integer>();
            //Map of parentDI to sum of Quantity Received of its Child
            for(Asset a : childDIList.values())
            {
                //Check for parent DI and update Quantity Received
                if(parentDIIdtoQuantMap.containsKey(a.Parent_DI__c))
                {
                    integer cnt = parentDIIdtoQuantMap.get(a.Parent_DI__c);
                    cnt += a.Quantity_Received__c == Null ? 0 : Integer.valueOf(a.Quantity_Received__c);
                    parentDIIdtoQuantMap.put(a.Parent_DI__c,cnt);                                                                
                }
                else
                {
                    parentDIIdtoQuantMap.put(a.Parent_DI__c,a.Quantity_Received__c == Null ? 0 : Integer.valueOf(a.Quantity_Received__c));
                }
            }
            //Update parent DI Quantity Distributed
            for(Id DIId : parentDIIds)
            {
                if(DIId!=null){ // added by kasim
                    Asset parentDI = new Asset();
                    parentDI.Id = DIId;
                    parentDI.Quantity_Distributed__c = parentDIIdtoQuantMap.get(DIId);
                    parentDI.Integration_User_Source__c = 'Updated per Quantity Distribution';
                    updateDiList.add(parentDI);
                }
            }
            system.debug('updateDiList==='+updateDiList);
            //Update DI records
            if(updateDiList.size() > 0){
                Database.update(updateDiList);
            }
        }
        
        //Update the Status of the Child DIs if its Parent Status is Installed
        /*if(!statusInstalledIds.isEmpty()){
List<Asset> childDIs = [SELECT Id,Status FROM Asset WHERE Parent_DI__c IN : statusInstalledIds AND Status != 'Installed'];
//Update the Child DI Status                        
for(Asset cDI : childDIs)
{   
cDI.Status = 'Installed';
updateDiList.add(cDI);
}           
}*/
        
    }
    
    
    
    /*
* Author: Sunita Mittal
* Created On: 12/31/2015
* Descrition: to update IsHostedDI__c over DI
*/  
    //public void updateDIHosted(List <Asset>newTrigger, Map<Id, Asset>oldMapTrigger)
    public void updateDIHosted(Set<Id> coreDIUpdatedSet, List<Asset> coreDIUpdatedAssets)
    {      
        
        //Set<Id> coreDIUpdatedSet = new Set<Id>();
        //List<Asset> coreDIUpdatedAssets = new List<Asset>();
        
        /* for (Asset a : newTrigger)
{

Asset oldAssetRecord = oldMapTrigger.get(a.Id);

if (a.Product2Id != oldAssetRecord.Product2Id)
{   
a.IsHostedDI__c = a.Hosted__c;                              
}

if ((a.Core_DI__c != null) && (a.Core_DI__c != oldAssetRecord.Core_DI__c))
{
coreDIUpdatedSet.add(a.Core_DI__c);
coreDIUpdatedAssets.add(a);
}

if (a.Status == 'Inactive' && a.Status != oldAssetRecord.Status){
a.Usage_End_Date__c = Date.Today();
}
else 
{
if ((a.Status != 'Inactive') && (a.Status != oldAssetRecord.Status) && (oldAssetRecord.Status == 'Inactive'))
{
a.Usage_End_Date__c = null;
}
}
}*/
        
        //Update Core-Peripheral DI related records
        if (coreDIUpdatedSet != null && !coreDIUpdatedSet.isEmpty())
        {
            Map<Id, Asset> coreDIMap = new Map<Id, Asset>([SELECT Id, Status, IsHostedDI__c FROM Asset WHERE Id IN: coreDIUpdatedSet]);
            for (Asset asObj: coreDIUpdatedAssets)
            {
                asObj.Status = coreDIMap.get(asObj.Core_DI__c).Status;
                asObj.IsHostedDI__c = coreDIMap.get(asObj.Core_DI__c).IsHostedDI__c;
            }
        }
    } 
    /**
* Delete all peripheral di if core di is deleted.
*
* @param set<id> deletedCoreAssetIds List of core di to delete
* @author Kasim badami
* @return void
* @Created On : 05/05/2016
* @Last modified By : kasim
* @Last modified on : 05/05/2016
*/ 
    public void deletePeripheralDIs(set<id> deletedCoreAssetIds){
        // remove peripheral di history data
        set<id> assetHistoryData = new set<id>();
        List<Asset> peripheralToDelete = new list<Asset>();
        
        for(List<Asset> lstPeriAssets: [ SELECT Id FROM Asset WHERE Core_DI__c IN: deletedCoreAssetIds]){
            for(asset peri: lstPeriAssets){
                peripheralToDelete.add(peri);
            }
        }
        // before removing peripheral di, remove its related record from DI History
        
        
        for(List<NI_Deployment_Instance_History__c> lstPeriAssetsHist: [ SELECT Id FROM NI_Deployment_Instance_History__c WHERE Related_Deployment_Instance__c IN :peripheralToDelete ]){
            for(NI_Deployment_Instance_History__c periHist: lstPeriAssetsHist){
                delete periHist;
            }
        }    
        // delete peripheral di
        if(peripheralToDelete.size() > 0){
            delete peripheralToDelete;
        }
    }
    
    /**
* Author: Sunita Mittal
* Created On: 12/31/2015
* Descrition: Update the Account Type Field
**/       
    public void updateAccntType(Set<ID> accIdList)
    {        
        Map<Id,List<Integer>> accntIdToassetCntMap = new Map<Id,List<Integer>>();
        integer cntActiveAsset,cntInActiveAsset;
        //Get all DI's associated account
        for(List<Asset> assetList : [SELECT Id,Status,AccountId FROM Asset WHERE AccountId IN : accIdList])
        {
            //Iterate over all DI's
            for( Asset a : assetList)
            {
                //Calculate the count of Active and Inactive DIs
                if(accntIdToassetCntMap.containsKey(a.AccountId))
                {
                    cntActiveAsset = accntIdToassetCntMap.get(a.AccountId)[0];
                    cntInActiveAsset = accntIdToassetCntMap.get(a.AccountId)[1];
                }
                else
                {
                    cntActiveAsset = 0;
                    cntInActiveAsset = 0;
                }
                //If status is active i.e. Purchased or Installed then it is a active DI
                //else it is inactive DI
                if(a.Status == 'Purchased' || a.Status == 'Installed')
                {
                    cntActiveAsset += 1;
                }
                else
                {
                    cntInActiveAsset += 1;
                }
                accntIdToassetCntMap.put(a.AccountId,new List<Integer>()); 
                accntIdToassetCntMap.get(a.AccountId).add(cntActiveAsset);
                accntIdToassetCntMap.get(a.AccountId).add(cntInActiveAsset);            
            }
        }
        
        List<Account> accList = new List<Account>();
        //Get accounts
        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,Billing_Status__c,Type,Permanently_Closed__c FROM Account WHERE Id IN : accIdList]);        
        //Iterate over all accIdList        
        for(Id accId : accIdList) 
        {
            //Get account 
            Account acc = accMap.get(accId);            
            if(accntIdToassetCntMap.containsKey(accId))
            {   
                //Update the Type Field and Billing Status field if "Billing Status" is Not Billable
                if(accntIdToassetCntMap.get(accId)[0] > 0)
                {
                    acc.Permanently_Closed__c = false;
                    acc.Type = 'Customer';
                    if(acc.Billing_Status__c != 'Billable')
                        acc.Billing_Status__c = 'Consumer';
                }                    
                else if(accntIdToassetCntMap.get(accId)[0] == 0 && accntIdToassetCntMap.get(accId)[1] > 0)
                {
                    acc.Type = 'Former Customer';
                    if(acc.Billing_Status__c != 'Billable')
                        acc.Billing_Status__c = '';
                }                                   
            }
            else
            {
                acc.Type = 'Prospect';
                if(acc.Billing_Status__c != 'Billable')
                    acc.Billing_Status__c = '';
            }                
            accList.add(acc);
        }               
        //Update accounts in accList
        update accList;
    }
    
    /**
* @author Prashant Wayal
* @date 18/12/2015
* @description Method to update the peripheral DI's when Hosted__c field of Core DI is updated
* @params List<Asset> newTrigger, Map<Id, Asset> oldMapTrigger
* 
**/
    //public void updatePeripheralDI(List<Asset> newTrigger, Map<Id, Asset> oldMapTrigger){
    public void updatePeripheralDI(Set<String> coreDIIdSet, Set<String> coreDIIdStatusSet,List<Asset> coreInactiveDIList){
        //Variable to hold values of Code DI Id's
        /* by kasim
Set<String> coreDIIdSet = new Set<String>();
//Set variable to hold values of DI Status
Set<String> coreDIIdStatusSet = new Set<String>();
//hold values of inactivated DI's
List<Asset> coreInactiveDIList = new List<Asset>();

//Iterate over DI list
for(Asset assetObj: newTrigger){
Asset oldAsset = oldMapTrigger.get(assetObj.Id);
//Check if Core DI is updated and Hosted__c is set to true
if(assetObj.Core_DI__c == null && (assetObj.IsHostedDI__c != oldAsset.IsHostedDI__c)){
coreDIIdSet.add(assetObj.Id);
}
//status values of DI
Set<String> statusSet = new Set<String>{'Inactive', 'Purchased', 'Installed'};
//Check if Core DI's status is updated to any value added on above set
//If yes, update Core DI record
if(assetObj.Core_DI__c == null && statusSet.contains(assetObj.Status) && (assetObj.Status != oldAsset.Status)){
coreDIIdStatusSet.add(assetObj.Id);
if(assetObj.Status == 'Inactive')
coreInactiveDIList.add(assetObj);
}
}*/
        //Get the peripheral DI list
        Map<Id, Asset> peripheralDIMap = new Map<Id, Asset>();
        
        //Check if coreDIIsSet is empty or not. If not empty, get related peripheral DI list
        if(!coreDiIdSet.isEmpty() || !coreDIIdStatusSet.isEmpty()){
            
            List<Asset> assetUpdateList = new List<Asset>();
            
            //Set Hosted to true for all peripheral records
            for(Asset assetObj: [SELECT Id, IsHostedDI__c, Status, Core_DI__c, Core_DI__r.Name, Core_DI__r.Status, Core_DI__r.IsHostedDI__c 
                                 from Asset 
                                 where (Core_DI__c IN: coreDIIdSet OR Core_DI__c IN: coreDIIdStatusSet)])
            {
                peripheralDIMap.put(assetObj.Id, assetObj);
                // Set IsHostedDI__c to Core DI value
                if(coreDIIdSet.contains(assetObj.Core_DI__c))
                    assetObj.IsHostedDI__c = assetObj.Core_DI__r.IsHostedDI__c;
                
                if(coreDIIdStatusSet.contains(assetObj.Core_DI__c))
                    assetObj.Status = assetObj.Core_DI__r.Status;
                assetObj.Integration_User_Source__c = 'Updated per Core-Peripheral for DI #'+assetObj.Core_DI__r.Name;
                //Add to update list
                assetUpdateList.add(assetObj);
            }
            
            try{
                if(!assetUpdateList.isEmpty())
                    update assetUpdateList;
            }
            catch(Exception e){
                System.debug('*** Error in NI_DeploymentInstance_TriggerHelper.updatePeripheralDI() *** '+e.getMessage());
            }
        }
        
        //Create/update cancellation record for Inactivated Peripheral DI's
        if(!coreInactiveDIList.isEmpty() && !peripheralDIMap.isEmpty()){
            createCancellationRecords(coreInactiveDIList,'This Cancellation was auto-generated based on the inactivation of the related Core DI Record.');
        }
        
    }
    
    /**
* @author Prashant Wayal
* @date 24/12/2015
* @description Method to update the peripheral DI's and create/update cancellation records when Status field of Core DI is updated to Inactive
* @params List<Asset> newTrigger, Map<Id, Asset> oldMapTrigger
* @modified By Prashant Wayal
* @modification Updated method to remove the use of DI_to_Softrax_Asset__c junction object
* 
*/
    public void createCancellationRecords(List<Asset> newTrigger,String cancelNotes){
        //Check if Core DI list is not empty
        if(!newTrigger.isEmpty()){
            //Map to hold values of cancellation records, key is cancellation record Id
            Map<Id, NI_Cancellation__c> cancMap = new Map<Id, NI_Cancellation__c>();
            
            //Map to hold values of cancellation records for unique combination of DI and SA
            Map<String, NI_Cancellation__c> disaCancMap = new Map<String, NI_Cancellation__c>();
            //Get all cancellation records related to DI whose status is not cancelled and add it to map variables
            /*for(NI_Cancellation__c canc: [SELECT Id, Status__c, Deployment_Instance__c, Softrax_Asset__c from NI_Cancellation__c 
where (Deployment_Instance__c IN: newTrigger) AND Status__c != 'Cancelled'])*/
            for(NI_Cancellation__c canc: [SELECT Id, Status__c, Deployment_Instance__c, Activity_Line_Item__c
                                          from NI_Cancellation__c 
                                          where (Deployment_Instance__c IN: newTrigger) AND Status__c != 'Cancelled'])
            {
                cancMap.put(canc.Id, canc);
                disaCancMap.put(canc.Deployment_Instance__c, canc);
            }
            //Variables to store count of total and inactive billing records under DI record
            Map<id,integer> totalSaCountUnderDI = new Map<id,integer>();
            Map<id,integer> inactiveSaCountUnderDI = new Map<id,integer>();
            
            //Get count of inactive billing records
            /*COMMENTED for (AggregateResult disaCount : [SELECT COUNT(id) cnt , Deployment_Instance__c FROM  Softrax_Asset__c 
WHERE (Status__c = 'Inactive' 
AND (Deployment_Instance__c IN: newTrigger)
) 
GROUP BY Deployment_Instance__c])*/
            for (AggregateResult disaCount : [SELECT COUNT(id) cnt , Deployment_Instance__c FROM  Activity_Line_Item__c 
                                              WHERE (Status__c = 'Inactive' 
                                                     AND (Deployment_Instance__c IN: newTrigger)
                                                    ) 
                                              GROUP BY Deployment_Instance__c])
            {                                     
                inactiveSaCountUnderDI.put((ID)disaCount.get('Deployment_Instance__c'),(integer)disaCount.get('cnt'));
            }
            
            //Get count of all billing records associated with DI
            /*for (AggregateResult disaCount : [SELECT COUNT(id) cnt , Deployment_Instance__c FROM  Softrax_Asset__c 
WHERE (Deployment_Instance__c IN: newTrigger) 
GROUP BY Deployment_Instance__c])*/
            for (AggregateResult disaCount : [SELECT COUNT(id) cnt , Deployment_Instance__c FROM  Activity_Line_Item__c 
                                              WHERE (Deployment_Instance__c IN: newTrigger) 
                                              GROUP BY Deployment_Instance__c])
            {   
                totalSaCountUnderDI.put((ID)disaCount.get('Deployment_Instance__c'),(integer)disaCount.get('cnt'));
            }
            system.debug('inactiveSaCountUnderDI=='+inactiveSaCountUnderDI);
            system.debug('totalSaCountUnderDI=='+totalSaCountUnderDI);
            //Variable to hold cancellation records being created/updated
            List<NI_Cancellation__c> upsertCancList = new List<NI_Cancellation__c>();
            //Get all billing records associated with DI records
            /*for (list<Softrax_Asset__c> saList : [SELECT Id, End_Date__c,Status__c,Deployment_Instance__r.Status,
Deployment_Instance__c,Account__c, Account__r.Franchisor__c,                     
Account__r.Ownerid,Account__r.Brand__c,Account__r.Parentid,
Quantity__c,Account__r.Ownership_Company__c, CancellationEffectiveDate__c,
Deployment_Instance__r.Product2.Classification__c
FROM Softrax_Asset__c 
WHERE 
(Deployment_Instance__c IN: newTrigger)])*/
            for (list<Activity_Line_Item__c> aliList : [SELECT Id, Contract_End_Date__c, Status__c, Deployment_Instance__r.Status,
                                                        Deployment_Instance__c,Billing_Contract__r.Account__c, Billing_Contract__r.Account__r.Franchisor__c,                     
                                                        Billing_Contract__r.Account__r.Ownerid, Billing_Contract__r.Account__r.Brand__c,
                                                        Billing_Contract__r.Account__r.Parentid,
                                                        Units__c, Billing_Contract__r.Account__r.Ownership_Company__c, 
                                                        //CancellationEffectiveDate__c,
                                                        Deployment_Instance__r.Product2.Classification__c
                                                        FROM Activity_Line_Item__c 
                                                        WHERE 
                                                        (Deployment_Instance__c IN: newTrigger)])
            {    
                for(Activity_Line_Item__c disa: aliList){
                    //Check if DI has all inactive Softrax Asset records
                    Boolean chkInactive = (inactiveSaCountUnderDI.containskey(disa.Deployment_Instance__c)  && (inactiveSaCountUnderDI.get(disa.Deployment_Instance__c) == totalSaCountUnderDI.get(disa.Deployment_Instance__c)));
                    
                    //if all inactive softrax assets present, then check if any cancellation record present
                    if(chkInactive){
                        if(disaCancMap.keySet().contains(disa.Deployment_Instance__c+''+disa.Id)){
                            //Get existing cancellation record
                            NI_Cancellation__c canc = disaCancMap.get(disa.Deployment_Instance__c+''+disa.Id);
                            //Check if cancellation record's status is not 'Cancelled', if 'Cancelled' then don't update it
                            if(canc.Status__c != 'Cancelled'){
                                canc.Status__c = 'Cancelled';
                                //add to updateCancList
                                upsertCancList.add(canc);
                            }
                        }
                        else{
                            //Create new Cancellation record
                            NI_Cancellation__c canc = new NI_Cancellation__c();
                            canc.Account__c = disa.Billing_Contract__r.Account__c;
                            canc.Brand__c = disa.Billing_Contract__r.Account__r.Brand__c;
                            canc.Account_Owner__c = disa.Billing_Contract__r.Account__r.Ownerid;
                            canc.Deployment_Instance__c = disa.Deployment_Instance__c;
                            //canc.Effective_Date__c = disa.CancellationEffectiveDate__c;
                            canc.Franchisor__c = disa.Billing_Contract__r.Account__r.Franchisor__c;
                            canc.General_Reason__c = 'Unknown';
                            canc.Management_Company__c =  disa.Billing_Contract__r.Account__r.Parentid;
                            canc.Cancellation_Quantity__c = 1;
                            canc.Ownership_Company__c = disa.Billing_Contract__r.Account__r.Ownership_Company__c;
                            canc.Product_Classification__c = disa.Deployment_Instance__r.Product2.Classification__c;
                            canc.Reviewed_by_Collector__c = true;
                            canc.Reviewed_By_Fulfillment__c = false;
                            canc.Activity_Line_Item__c = disa.Id;
                            //canc.Softrax_Asset__c = disa.Id;
                            //canc.Updated_in_Softrax__c = true;
                            canc.Updated_in_Activity_Line__c = true;
                            canc.Cancellation_Notes__c = cancelNotes;//'This Cancellation was auto-generated based on the inactivation of the related Core DI Record.';
                            canc.Status__c = 'Cancelled';
                            
                            //add to updateCancList
                            upsertCancList.add(canc);
                            
                        }
                    }
                }
            }
            
            try{
                //Check if upsertCancList is not empty before making DML call
                if(!upsertCancList.isEmpty()){                    
                    Database.UpsertResult[] result = Database.upsert(upsertCancList);
                }
                
            }
            catch(Exception ex){
                System.debug('*** Error in NI_DeploymentInstance_TriggerHandler.createCancellationRecords method *** '+ex.getMessage());
            }
        }
    }
    
    
    
    
    /**
* Update parent status to inactive if all child di are inactive.
*
* @param set<id> updateParentDIStatus List of parent di to process
* @author Kasim badami
* @return void
* @Created On : 05/16/2016
* @Last modified By : kasim
* @Last modified on : 05/16/2016
*/     
    public void updateParentDIStatus(set<id> allParentIdForStatus){
        //system.debug('allParentIdForStatus==='+allParentIdForStatus);
        if(!allParentIdForStatus.isEmpty()){
            // create map that will store all child di with parent
            // key will be the parentid and values will be list of all child.
            
            
            map<string,integer> inactiveChildCountUnderDI = new map<string,integer>();
            map<string,integer> activeSACountUnderDI = new map<string,integer>();
            for (AggregateResult activeChildCount : [SELECT COUNT(id) cnt , Parent_DI__c FROM  asset 
                                                     WHERE Parent_DI__c in :allParentIdForStatus and (status = 'Installed' OR status = 'Purchased')
                                                     GROUP BY Parent_DI__c]){
                                                         
                                                         inactiveChildCountUnderDI.put((ID)activeChildCount.get('Parent_DI__c'),(integer)activeChildCount.get('cnt'));                                
                                                     }
            
            /*COMMENTED 7/7 for (AggregateResult activeSACount : [SELECT COUNT(id) cntSA , Deployment_Instance__c FROM  Softrax_Asset__c 

WHERE Deployment_Instance__c in :allParentIdForStatus and (Status__c = 'Active' )
GROUP BY Deployment_Instance__c]){*/
            
            for (AggregateResult activeSACount : [SELECT COUNT(id) cntSA , Deployment_Instance__c FROM  Activity_Line_Item__c 
                                                  
                                                  WHERE Deployment_Instance__c in :allParentIdForStatus and (Status__c = 'Active' )
                                                  GROUP BY Deployment_Instance__c]){
                                                      
                                                      activeSACountUnderDI.put((ID)activeSACount.get('Deployment_Instance__c'),(integer)activeSACount.get('cntSA'));                                
                                                  } 
            /* system.debug('activeSACountUnderDI=='+activeSACountUnderDI);
system.debug('allParentIdForStatus=='+allParentIdForStatus);
system.debug('activeSACountUnderDI=='+activeSACountUnderDI);
system.debug('inactiveChildCountUnderDI=='+inactiveChildCountUnderDI);*/
            
            /*map<string,list<asset>> parentChildDis = new map<string,list<asset>>();
for(list<asset> allChilds :[select id,status,name,Parent_DI__c from asset where Parent_DI__c in :allParentIdForStatus]){
for(asset childdi : allChilds){
if(parentChildDis.containskey(childdi.Parent_DI__c)){
parentChildDis.get(childdi.Parent_DI__c).add(childdi);
}else{
list<asset> tmpAsset = new list<asset>();
tmpAsset.add(childdi);
parentChildDis.put(childdi.Parent_DI__c,tmpAsset);
}
}
}*/
            // map creation ends here
            
            // process the map created above and get parent with all childs inactive 
            set<string>  parentWithAllChildInactive = new set<string>();
            if(!allParentIdForStatus.isempty()){
                for (string parentid: allParentIdForStatus) { 
                    if(((inactiveChildCountUnderDI.containskey(parentid) && inactiveChildCountUnderDI.get(parentid)  == 0) 
                        || !inactiveChildCountUnderDI.containskey(parentid) && allParentIdForStatus.contains(parentid)
                       ) && ((activeSACountUnderDI.containskey(parentid) && activeSACountUnderDI.get(parentid)  == 0) 
                             || !activeSACountUnderDI.containskey(parentid) && allParentIdForStatus.contains(parentid))){
                                 parentWithAllChildInactive.add(parentid);
                             } 
                }
            }
            /*for (string parentid: parentChildDis.keySet()) { 
// put all child di for parent in temporary list.
list<asset> childdis = new list<asset>();
if(parentChildDis.containskey(parentid)){
childdis  = parentChildDis.get(parentid);
// boolean to determine which parent has all child di's as inactive
boolean isallinactive = true;
// loop through all child di's of parent
if(!childdis.isempty()){
for(asset chdi : childdis  ){
if(chdi.status != 'Inactive'){
// if any one of the child di is not Inactive, set boolean to false
isallinactive = false;
}
}
if(isallinactive == true){
parentWithAllChildInactive.add(parentid);
}
}

}
}*/
            
            //system.debug('parentWithAllChildInactive==='+parentWithAllChildInactive);
            
            // update the status of all parent di having all child as inactive
            
            list<asset> parentDIToupdate = new list<asset>();
            if(!parentWithAllChildInactive.isempty()){
                for(list<asset> allParentDi :[select id,status,name from asset where id in :parentWithAllChildInactive]){
                    for(asset parentdi : allParentDi){
                        parentdi.status = 'Inactive';
                        parentDIToupdate.add(parentdi);
                    }
                    if(!parentDIToupdate.isempty()){
                        update parentDIToupdate;
                    }
                }
            }
        }
        
    }
    
    /**
* This function sets AccountId_DIIndexID__c to null of all DI's which would
* on after updating Account ID would result in duplication of DI. 
*
* @param map<string,string> updatedDIAccMap all di to process
* @param map<string,string> updatedDIProdMap all di to process
* @param List<Asset> newTrigger all di to process
* @author Kasim badami
* @return void
* @Created On : 09/08/2016
* @Last modified By : kasim
* @Last modified on : 09/08/2016
*/ 
    /*public void updateAccDIIndexOnAccountUpdate(map<string,string> updatedDIAccMap,map<string,string> updatedDIProdMap,List<Asset> newTrigger){
// store all product wise DI Index ID
map<string,string> prodDIIndexMap = new  map<string,string>();


map<string,integer> existingDICount = new map<string,integer> ();

// create map of all product wise DI Index;
for(List<product2> prodList : [SELECT Id,DI_Index__c FROM product2 WHERE id IN : updatedDIProdMap.values()])
{
//Iterate over products
for( product2 p : prodList)
{
prodDIIndexMap.put(p.id,p.DI_Index__c);
}
}

map<string,string> diWiseAccDIIndex = new map<string,string>();
set<string> uniqueAccDIX = new set<string>();
string accDIX = '';
for(string diId : updatedDIAccMap.keyset()){
accDIX = updatedDIAccMap.get(diId)+''+prodDIIndexMap.get(updatedDIProdMap.get(diId));
if(!uniqueAccDIX.contains(accDIX)){
diWiseAccDIIndex.put(diId,accDIX);
}else{
diWiseAccDIIndex.put(diId,null);

}
uniqueAccDIX.add(accDIX);
}
system.debug('uniqueAccDIX==='+uniqueAccDIX);
system.debug('BEFORE diWiseAccDIIndex==='+diWiseAccDIIndex);
for (AggregateResult disaCount : [SELECT COUNT(AccountId_DIIndexID__c) cnt , id  FROM  asset 
WHERE (AccountId_DIIndexID__c IN: uniqueAccDIX)

GROUP BY id])
{                                     
existingDICount.put((string)disaCount.get('id'),(integer)disaCount.get('cnt'));
}

system.debug('existingDICount==='+existingDICount);
if(!existingDICount.isempty()){
for(string diidcnt :existingDICount.keyset()){
if(existingDICount.get(diidcnt) > 0 && diWiseAccDIIndex.containskey(diidcnt) ){
diWiseAccDIIndex.put(diidcnt,null);
}
}
}

system.debug('After diWiseAccDIIndex==='+diWiseAccDIIndex);
for(Asset a : newTrigger)
{
if(diWiseAccDIIndex.containskey(a.id)){
a.AccountId_DIIndexID__c = null;
}
}
}
*/
    // ========================================================================================================================
    //  HANDLER FUNCTIONS =====================================================================================================
    // ========================================================================================================================  
    
    
    //CLD ADDITION
    /* private void handleDIActivation (List<Asset> newTrigger, Map<Id, Asset> oldMapTrigger){

Map<Id, Date> activityLineActivationMap = new Map<Id, Date>();
for(Asset di : newTrigger){
Asset oldDi = oldMapTrigger.get(di.id);
if(di.InstallDate != oldDi.InstallDate && di.InstallDate != null){
activityLineActivationMap.put(di.id, di.InstallDate);
}
}
List<Activity_Line_Item__c> aliUpdateList = [
SELECT Id, Activation_Date__c, Deployment_Instance__c FROM Activity_Line_Item__c WHERE Deployment_Instance__c in : activityLineActivationMap.keyset()];
for(Activity_Line_Item__c ali : aliUpdateList){
ali.Activation_Date__c = activityLineActivationMap.get(ali.Deployment_Instance__c);
}

update aliUpdateList;
}*/
    
    
    
    
    /*
* IF STATUS OF PARENT DI IS CHANGED TO 'INSTALLED'
* CHECK WHETHER MPE CLUSTER ON ACCOUNT OF CHILD DI IS SAME AS THAT OF ACCOUNT OF PARENT DI
* AND UPDATE CHILD DI'S STATUS
* /
public void updateChildDI(){

}



/*
* Author: Sunita Mittal
* Created On: 12/31/2015
* Descrition: to update IsHostedDI__c over DI
*/  
    /*public void updateDIHosted (List<Asset> newTrigger)
{
//Update DI's IsHostedDI field
for(Asset a : newTrigger)
{
// condition added by kasim to prevent IsHostedDI__c to be same as Hosted__c in case of Peripheral DI
if(a.Core_DI__c == null) 
a.IsHostedDI__c = a.Hosted__c;
}
}  */
    
    
    
    
    
    /*
public void createCancellationRecordForDI(List<Asset> assetList){
Map<Id, NI_Cancellation__c> diCancellationMap = new Map<Id, NI_Cancellation__c>();
set<Id> cancIdSet = new Set<Id>();
//Check if assetList is empty or not
if(!assetList.isEmpty()){
//Get all cancellation records present for the DI's
Map<String, NI_Cancellation__c> disaCancMap = new Map<String, NI_Cancellation__c>();
for(NI_Cancellation__c canc: [SELECT Id, Status__c, Deployment_Instance__c, Softrax_Asset__c from NI_Cancellation__c 
where (Deployment_Instance__c IN: assetList)]){

disaCancMap.put(canc.Deployment_Instance__c, canc);
System.debug('*** cancellation add for *** '+canc.Deployment_Instance__c);
}
Map<Id, Asset> assetMap = new Map<Id, Asset>();
for(Asset asObj: [select Id, Name, Status, AccountId, Account.Franchisor__c,                     
Account.Ownerid,Account.Brand__c,Account.Parentid,
Account.Ownership_Company__c, Product2Id, Product2.Classification__c from Asset where Id IN: assetList]){

assetMap.put(asObj.Id, asObj);
}
//List to hold the values of cancellation list to insert
List<NI_Cancellation__c> upsertCancList = new List<NI_Cancellation__c>();
for(Asset asObj: assetList){
//Check if Cancellation record is already present or not
if(disaCancMap != null && disaCancMap.get(asObj.Id) == null){
//If no cancellation record is present for DI, then create new cancellation record
//Create new Cancellation record
NI_Cancellation__c canc = new NI_Cancellation__c();
canc.Account__c = asObj.AccountId;
canc.Brand__c = asObj.Account.Brand__c;
canc.Account_Owner__c = asObj.Account.Ownerid;
canc.Deployment_Instance__c = asObj.Id;
canc.Franchisor__c = asObj.Account.Franchisor__c;
canc.General_Reason__c = 'Unknown';
canc.Management_Company__c =  asObj.Account.Parentid;
canc.Cancellation_Quantity__c = 1;
canc.Ownership_Company__c = asObj.Account.Ownership_Company__c;
canc.Product_Classification__c = asObj.Product2.Classification__c;
canc.Reviewed_by_Collector__c = true;
canc.Reviewed_By_Fulfillment__c = false;
canc.Cancellation_Notes__c = 'This Cancellation was auto-generated based on the inactivation of the related DI Record.';
canc.Status__c = 'Cancelled';

//add to updateCancList
upsertCancList.add(canc);
}
}
}


}
*/
    
    
    /* 
// A METHOD THAT LOOKS AT A CUSTOM SETTING TO BYPASS ALL TRIGGER HANDLING FUNCTIONS
private boolean setEnabledFlag()
{

boolean bIsTrue = false;

//LIST TO HOLD THE VALUES IN THE NI_Insert_DI_History_Record__c CUSTOM SETTING
List<NI_Insert_DI_History_Record__c> lstCS = NI_Insert_DI_History_Record__c.getall().values();

//IF THE lstCS LIST CONTAINS RECORDS, CONTINUE WITH THE REST OF THE CODE  
if (lstCS.size() > 0)
{   
//LOOP THROUGH THE lstCS LIST.  IF THE Enabled__c VALUE IS SET TO TRUE, CALL THE Insert_DI_History METHOD  
for (NI_Insert_DI_History_Record__c cs : lstCS)
{
if ((cs.Name == 'NI Insert DI History Method') && (cs.Enabled__c == true))
{ 
bIsTrue = true;
}
}
}        

return bIsTrue;

}
*/
    
    /**
* Author: Sunita Mittal
* Created On: 01/18/2016
* Descrition: Method to Link Deployment Instance to Opportunity Line Item
**/
    
    /*
public void OptyLineItemrelatedList(Set<Id> AccIds,Set<Id> assetIds)
{                       
List<OpportunityLineItem> updateOptyLItemList = new List<OpportunityLineItem>();                        
Set<Id> diIndexIds = new Set<Id>();
Map<string,string> prodDiIndexMap = new Map<String,String>();
Map<String,List<OpportunityLineItem>> pordOptyLineItemMap = new Map<String,List<OpportunityLineItem>>();        
//List All OpportunityLineItem related to thier Products 
for(List<OpportunityLineItem> optyLitemList : [SELECT Opportunity.AccountId,Product2.DI_Index__c,Product2Id FROM OpportunityLineItem WHERE Opportunity.AccountId IN : AccIds])        
{
for(OpportunityLineItem  o : optyLItemList)
{                
prodDiIndexMap.put(o.Product2Id,o.Product2.DI_Index__c);
if(pordOptyLineItemMap.containsKey(o.Product2Id))
{
pordOptyLineItemMap.get(o.Product2Id).add(o);
}
else
{
pordOptyLineItemMap.put(o.Product2Id,new List<OpportunityLineItem>{o});
}
} 
} 
//Link OpportunityLineItem with the Deployment Instance          
for(List<Asset> diInsList : [SELECT Id,AccountId,Product2.DI_Index__c,Product2Id FROM Asset WHERE Id IN : assetIds])                            
{
for(Asset a : diInsList)
{
if(prodDiIndexMap.containsKey(a.Product2Id)){                    
if(prodDiIndexMap.get(a.Product2Id) == a.Product2.DI_Index__c){                        
List<OpportunityLineItem> updateOptyLine = pordOptyLineItemMap.get(a.Product2Id);
for(OpportunityLineItem o : updateOptyLine)
{
o.DeploymentInstance__c = a.Id;
updateOptyLItemList.add(o);
}

}                        
}
}
}                                          
Database.update(updateOptyLItemList);
}*/
    
    
    private void updateRollupSummaryFields(List<Asset> newTrigger, Map<Id, Asset> oldMapTrigger)
    {
        
        Map<String, Map<String, Decimal>> rollupQuantMap = new Map<String, Map<String, Decimal>>();
        Set<Id> setDIIds = new Set<Id>();
        
        Map<String, String> productFamilyUnitMap = new Map<String, String>();
        List<String> unitList = new List<String>();
        
        for (Asset di : newTrigger)
        {
            setDIIds.add(di.Id);
        }
        
        //FETCH PRODUCT FAMILY AND UNIT FROM CUSTOM SETTING
        for(AH_Products_Family_Unit__c prodFamily : [SELECT Id, Name, Product_Unit__c
                                                     FROM AH_Products_Family_Unit__c]){                                    
                                                         productFamilyUnitMap.put(prodFamily.Name, prodFamily.Product_Unit__c);
                                                     }
        
        // Get all the OLI records related to DI
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem> (
            [SELECT DeploymentInstance__c, Quantity, Product2.Family, Product2.Unit__c, Product2.License_Type__c, Opportunity.Order_Status__c
             FROM OpportunityLineItem 
             WHERE Opportunity.StageName = 'Closed Won' 
             AND (Product2.DI_Index__c != NULL OR Product2.DI_Index__r.Name != 'N/A') 
             AND DeploymentInstance__c IN : setDIIds]);
        
        // Iterate over the OLI records
        Map<String, Decimal> countMap = new Map<String, Decimal>();
        
        for (OpportunityLineItem oliObj : oliList)
        {
            Set<String> unitSet = new Set<String>();
            //{'User', 'Named User', 'Concurrent User'};
            Set<String> familySet = new Set<String>();
            
            if (!productFamilyUnitMap.isEmpty())
            {
                if (productFamilyUnitMap.containsKey(oliObj.Product2.Family))
                {
                    String prodFamUnit = productFamilyUnitMap.get(oliObj.Product2.Family);
                    familySet.add(oliObj.Product2.Family);
                    if (prodFamUnit != null)
                    {
                        unitList = prodFamUnit.split(',');
                        unitSet.addAll(unitList);
                    }
                }
                system.debug('familySet'+familySet);
                system.debug('unitSet'+unitSet);
            }
            else
            {
                familySet.add('None');
            }
            
            
            // ONLY TALLY QUANTITIES WHEN Opportunity.Order_Status__c IS Integrated, Shipped or Definite
            if (oliObj.Opportunity.Order_Status__c == 'Integrated' || oliObj.Opportunity.Order_Status__c == 'Shipped' || oliObj.Opportunity.Order_Status__c == 'Definite')            
            {   
                Boolean quantOrdered = false;
                //Check for Software License
                Boolean softLicense = (oliObj.Product2.Family == 'Software' && unitSet.contains(oliObj.Product2.Unit__c)) ? true : false;
                //Check for Full License
                Boolean fullLicense = (familySet.contains(oliObj.Product2.Family) && oliObj.Product2.License_Type__c == 'Full') ? true : false;
                //Check for Limited License
                Boolean limtdLicense = (familySet.contains(oliObj.Product2.Family) && oliObj.Product2.License_Type__c == 'Limited') ? true : false;
                //Check for quantity ordered
                if (!unitSet.isEmpty())
                {
                    quantOrdered = (familySet.contains(oliObj.Product2.Family) && unitSet.contains(oliObj.Product2.Unit__c));
                }
                else
                {
                    quantOrdered = familySet.contains(oliObj.Product2.Family);
                }
                
                //Varaible to hold quantity of softLice, fullLicense, LimtdLicense and quantOrdered related to DI record             
                if (softLicense)
                {
                    //check if rollupQuantMap has any record for DI, if not, create new map to add quantity values
                    if(countMap.get(oliObj.DeploymentInstance__c + 'softLicense') != null)
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'softLicense', countMap.get(oliObj.DeploymentInstance__c + 'softLicense') + oliObj.Quantity);
                    }
                    else
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'softLicense', oliObj.Quantity);
                    }
                }
                
                if (fullLicense)
                {
                    //check if rollupQuantMap has any record for DI, if not, create new map to add quantity values
                    if (countMap.get(oliObj.DeploymentInstance__c + 'fullLicense') != null)
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'fullLicense', countMap.get(oliObj.DeploymentInstance__c + 'fullLicense') + oliObj.Quantity);
                    }
                    else
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'fullLicense', oliObj.Quantity);
                    }
                }
                
                if (limtdLicense)
                {
                    // check if rollupQuantMap has any record for DI, if not, create new map to add quantity values
                    if (countMap.get(oliObj.DeploymentInstance__c + 'limtdLicense') != null)
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'limtdLicense', countMap.get(oliObj.DeploymentInstance__c + 'limtdLicense') + oliObj.Quantity);
                    }
                    else
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'limtdLicense', oliObj.Quantity);
                    }
                }
                
                if (quantOrdered || softLicense)
                {
                    // check if rollupQuantMap has any record for DI, if not, create new map to add quantity values
                    if (countMap.get(oliObj.DeploymentInstance__c + 'quantOrdered') != null)
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'quantOrdered', countMap.get(oliObj.DeploymentInstance__c + 'quantOrdered') + oliObj.Quantity);
                    }
                    else
                    {
                        countMap.put(oliObj.DeploymentInstance__c + 'quantOrdered', oliObj.Quantity);
                    }
                }
                
            }
            
        }
        
        // Iterate over all the DI records related to OLI
        for (Asset diObj : newTrigger)
        {
            
            Asset oldAsset = oldMapTrigger.get(diObj.Id);
            
            if ((diObj.Recalculate_Quantity_Ordered__c != oldAsset.Recalculate_Quantity_Ordered__c) && diObj.Recalculate_Quantity_Ordered__c == true)
            {      
                
                // INITIALIZE QUANTITY FIELDS                              
                diObj.Software_Licenses__c = 0;                              
                diObj.Subscription_Licenses_Full__c = 0;                             
                diObj.Subscription_Licenses_Limited__c = 0;
                diObj.Quantity_Ordered__c = 0;
                
                // Update Software License quantity
                diObj.Software_Licenses__c = ((countMap.get(diObj.Id + 'softLicense') != null) ? countMap.get(diObj.Id + 'softLicense') : diObj.Software_Licenses__c);
                // Update Full License quantity
                diObj.Subscription_Licenses_Full__c = ((countMap.get(diObj.Id + 'fullLicense') != null) ? countMap.get(diObj.Id + 'fullLicense') : diObj.Subscription_Licenses_Full__c);
                // Update Limited License quantity
                diObj.Subscription_Licenses_Limited__c = ((countMap.get(diObj.Id + 'limtdLicense') != null) ? countMap.get(diObj.Id + 'limtdLicense') : diObj.Subscription_Licenses_Limited__c);
                // Update Quantity Ordered
                diObj.Quantity_Ordered__c = ((countMap.get(diObj.Id + 'quantOrdered') != null) ? countMap.get(diObj.Id + 'quantOrdered') : diObj.Quantity_Ordered__c);
                // UNCHECK Recalculate_Quantity_Ordered__c
                diObj.Recalculate_Quantity_Ordered__c = false; 
                
            } 
            
        }
        
    }
    
}