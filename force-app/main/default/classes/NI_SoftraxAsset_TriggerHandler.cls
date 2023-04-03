/**********************************************************************************************************
Name            : NI_SoftraxAsset_TriggerHandler Class
Author          : Sean Harris
Created Date    : 01/13/2015
Last Mod Date   : Sean Harris
Last Mod By     : 04/02/2015
NICC Reference  :
Description     : Class that handles all trigger code for the Softrax_Asset__c Object
                : 
                : 
***********************************************************************************************************/
public with sharing class NI_SoftraxAsset_TriggerHandler
{
    public NI_SoftraxAsset_TriggerHandler(){}
        /*public static Asset createUpdateAsset(Id diId, String diName, Id diAccountId, Id diProductId, String status, Date installDate, Date purchaseDate, Decimal quantityOrdered){
        //Create new Deployment Instance record
        Asset assetObj;
        if(diId == null){
            assetObj = new Asset();
        }
        else{
            assetObj = new Asset(Id = diId);
        }
        if(diName != null)
        assetObj.Name = diName;
        
        if(diAccountId != null) 
        assetObj.AccountId = diAccountId;
         
        if(diProductId != null)
        assetObj.Product2Id = diProductId;
        
        if(status != null) 
        assetObj.Status = status;
        
        //If installDate is null, don't update it
        if(installDate != null)
        assetObj.InstallDate = installDate;
        
        //If Quantity Billed is null, don't update the value
        //if(quantityBilled != null)
        //assetObj.Quantity_Billed__c = quantityBilled;
        
        //if PurchaseDate is not null, update with new value
        if(purchaseDate != null)
        assetObj.Purchase_Date__c = purchaseDate;
        
        //If endDate is not null, update with new value
        //if(endDate != null)
        //assetObj.Usage_End_Date__c = endDate;
        
        //If quantityOrdered is not null, update it with new value
        if(quantityOrdered != null)
        assetObj.Quantity_Ordered__c = quantityOrdered;
        
        return assetObj;
    }*/
}
/*  
    public NI_SoftraxAsset_TriggerHandler()
    {
        
    }
    
        public void OnBeforeInsert(List<Softrax_Asset__c> newTrigger)
    {
        updateProductIds(newTrigger); //Added by Prashant
        if (!NI_FUNCTIONS.bypassTriggerCode('SOFTRAX ASSET'))
        {         
            List<Softrax_Asset__c> saList = new List<Softrax_Asset__c>();
            Set<Id> assetIds = new Set<Id>();
            for(Softrax_Asset__c asObj: newTrigger){
                //Check if account id and product2Id is null, if yes, don't call function
                if((asObj.Softrax_Status__c == 'A' || asObj.Softrax_Status__c == 'I') && asObj.Account__c != null && asObj.Product2Id__c != null)
                saList.add(asObj);
                
                if(asObj.Softrax_Status__c != Null && asObj.Softrax_Status__c == 'A'){
                    assetIds.add(asObj.Deployment_Instance__c);
                }
            }
            
            if(!saList.isEmpty()){
                createUpdateDIForSA(saList);
            }*/
            
            //updateProductIds(newTrigger);
            
            /*-----------------
            * @Added By: Prashant Wayal
            * @Added On: 02/03/2016         
            ------------------*/
                        
                
                //Call Method that Update the Status field on Deploment Instance                
                /*if(!assetIds.isEmpty()){
                    updateDIStatus(assetIds);
                }                         
        }
    }

    
    public void OnBeforeUpdate(List<Softrax_Asset__c> newTrigger,Map<Id,Softrax_Asset__c> oldTriggerMap)
    {
        //createUpdateDIForSA(newTrigger);
        
        if (!NI_FUNCTIONS.bypassTriggerCode('SOFTRAX ASSET'))
        {
            Set<Id> assetIds = new Set<Id>();
            List<Softrax_Asset__c> saInactiveList = new List<Softrax_Asset__c>();
            Set<Id> diIdSet = new Set<Id>();
            List<Softrax_Asset__c> saList = new List<Softrax_Asset__c>();
            
            for(Softrax_Asset__c sa : newTrigger)
            {
                system.debug('sa' + sa);
                
                Softrax_Asset__c oldSA = oldTriggerMap.get(sa.Id);
                system.debug('oldsa' + oldSA);
                if(sa.Softrax_Status__c != oldSA.Softrax_Status__c && sa.Softrax_Status__c == 'A')
                        assetIds.add(sa.Deployment_Instance__c);
                // Added Inactive condition to create DI
                if((sa.Softrax_Status__c == 'A' || sa.Softrax_Status__c == 'I') && sa.Account__c != null && sa.Product2Id__c != null || ((sa.Account__c != oldSA.Account__c) || (sa.Product2Id__c != oldSA.Product2Id__c)))
                //if((sa.Softrax_Status__c == 'A' || sa.Softrax_Status__c == 'I') && sa.Account__c != null && sa.Product2Id__c != null )                    
                saList.add(sa);
                
                if((sa.Softrax_Status__c == 'I' && (sa.Softrax_Status__c != oldSA.Softrax_Status__c)) && sa.Account__c != null && sa.Product2Id__c != null){
                    // && ((sa.Account__c != oldSA.Account__c) || (sa.Product2Id__c != oldSA.Product2Id__c))
                    diIdSet.add(sa.Deployment_Instance__c);
                    saInactiveList.add(sa);
                }
                
            }
            
                
            if(!assetIds.isEmpty()){
                updateDIStatus(assetIds);
            }
            if(!saList.isEmpty()){
                System.debug('salist'+saList);
                createUpdateDIForSA(saList);
            }
            
            //Update the product on DI
            if(!diIdSet.isEmpty()){
                updateDIProductForInactiveSA(saInactiveList, diIdSet);
            }
        }
    }
    
    public void OnBeforeDelete(List<Softrax_Asset__c> oldTrigger)
    {
        if (!NI_FUNCTIONS.bypassTriggerCode('SOFTRAX ASSET'))
        { 
            //updateDIs(oldTrigger, true);
            //Added by Prashant Wayal
            Set<Id> diIdSet = new Set<Id>();
            for(Softrax_Asset__c asObj: oldTrigger){
                diIdSet.add(asObj.Deployment_Instance__c);
            }
            if(!diIdSet.isEmpty())
            updateRollupSummaryFields(diIdSet);
            
        }              
    }
    
    public void OnAfterInsert(List<Softrax_Asset__c> newTrigger)
    {
        if (!NI_FUNCTIONS.bypassTriggerCode('SOFTRAX ASSET'))
        {
            //syncBillingRecords(newTrigger);
            
            
            Map<Id, Softrax_Asset__c> oldMapTrigger = new Map<Id, Softrax_Asset__c>();*/
            
             /*--------------------------
            Added by: Sunita Mittal
            Added on:01/04/2016
            Description:For Update the Type on Account
            ---------------------------*/
           /* Set<Id> accIdList = new Set<Id>();
            Set<Id> diIdSet = new Set<Id>();
            Set<Id> saIdList = new Set<Id>();
            for(Softrax_Asset__c sftRax : newTrigger)
            {
                if(sftRax.Account__c != Null)
                    accIdList.add(sftRax.Account__c);     
                    
                if(sftRax.Softrax_Status__c == 'A')    
                diIdSet.add(sftRax.Deployment_Instance__c);
                
                if(sftRax.Product2ID__c != Null && sftRax.Deployment_Instance__c != Null && sftRax.Status__c == 'Active'){
                    saIdList.add(sftRax.Id);
                }       
            }
            if(!accIdList.isEmpty())
                updateBillingStatus(accIdList);                  
            
            //Added by Prashant Wayal
            if(!diIdSet.isEmpty())
            updateRollupSummaryFields(diIdSet);
            
            //Update "IsHostedDI" field on Deployment Instance
            if(!saIdList.isEmpty()){
                system.debug('******saIdList******'+saIdList);
                List<Softrax_Asset__c> saList = [Select Id,Product2Id__c,Deployment_Instance__r.Parent_DI__r.Product2Id FROM Softrax_Asset__c WHERE Id IN : saIdList];
                updateHostedOnDI(saList);
            }
            
           //updateCancellationRecordForSA(newTrigger,false,oldMapTrigger);
         }
    }
    
    public void OnAfterUpdate(List<Softrax_Asset__c> newTrigger, Map<Id, Softrax_Asset__c> oldMapTrigger)
    {      
        if (!NI_FUNCTIONS.bypassTriggerCode('SOFTRAX ASSET'))
        {         
            //updateDIs(newTrigger, false);
            //Added by Prashant Wayal
            Set<Id> diIdSet = new Set<Id>();
            Set<Id> accIdList = new Set<Id>();
            Set<Id> saIdList = new Set<Id>();
            List<Softrax_Asset__c> saCancList = new List<Softrax_Asset__c>();
            for(Softrax_Asset__c asObj: newTrigger)
            {
                Softrax_Asset__c oldObj = oldMapTrigger.get(asObj.Id);
                if((asObj.Softrax_Status__c!=oldObj.Softrax_Status__c) || (asObj.Quantity__c != oldObj.Quantity__c) || (asObj.Deployment_Instance__c != oldObj.Deployment_Instance__c))
                diIdSet.add(asObj.Deployment_Instance__c);*/
                
                //if(asObj.Softrax_Status__c=='A' && asObj.Deployment_Instance__c != oldObj.Deployment_Instance__c)
                //diIdSet.add(oldObj.Deployment_Instance__c);
                
                 /*--------------------------
                    Added by: Sunita Mittal
                    Added on:01/04/2016
                    Description:For Update the Type on Account
                  ---------------------------*/
               /* if(asObj.Account__c != Null && asObj.Account__c != oldObj.Account__c)
                {
                    accIdList.add(asObj.Account__c);
                    accIdList.add(oldObj.Account__c); 
                }
                
                if(asObj.Product2ID__c != Null && asObj.Product2ID__c != oldObj.Product2ID__c && asObj.Status__c == 'Active' && asObj.Deployment_instance__c != Null){
                    saIdList.add(asObj.Id);
                }*/
                
                //Check if Billing Record's status is updated
                /* if(asObj.Softrax_Status__c != '' && (asObj.Softrax_Status__c != oldObj.Softrax_Status__c)){
                    saCancList.add(asObj);
                }
                else if((asObj.Quantity__c != oldObj.Quantity__c) && (asObj.Quantity__c <= oldObj.Quantity__c)){
                    saCancList.add(asObj);
                } */
                
            /*}*/
            
            //Create cancellation records
            /*if(!saCancList.isEmpty()){
                createCancellationRecordsForSA(saCancList, oldMapTrigger);
            }*/
            
            //updateCancellationRecordForSA(newTrigger,false,oldMapTrigger);
            //Call Method that Update the "Billing Status" on related Account                                  
            /*if(!accIdList.isEmpty())
                updateBillingStatus(accIdList); 
                
            //Call the method that Updates the "IsHostedDI" on Child DIs
             if(!saIdList.isEmpty()){                
                List<Softrax_Asset__c> saList = [Select Id,Product2Id__c,Deployment_Instance__r.Parent_DI__r.Product2Id FROM Softrax_Asset__c WHERE Id IN : saIdList];
                updateHostedOnDI(saList);
            }
            
            if(!diIdSet.isEmpty())
            updateRollupSummaryFields(diIdSet);
        }        
    }
    
    public void OnAfterDelete(List<Softrax_Asset__c> oldTrigger)
    {  */      
         /*--------------------------
            Added by: Sunita Mittal
            Added on:01/04/2016
            Description:For Update the Type on Account
            ---------------------------*/
            /*Set<Id> accIdList = new Set<Id>();
            Set<Id> diIdSet = new Set<Id>();
            for(Softrax_Asset__c sftRax : oldTrigger)
            {
                if(sftRax.Account__c != Null)
                    accIdList.add(sftRax.Account__c);            
                if(sftrax.Deployment_Instance__c != null){
                    diIdSet.add(sftrax.Deployment_Instance__c);
                }
            }
            if(!accIdList.isEmpty())
                updateBillingStatus(accIdList);
            
            //Update Product information when the 
            if(!diIdSet.isEmpty()){
                //Update product on DI
                updateDIProductForInactiveSA(oldTrigger, diIdSet);
                
                //Calculate Rollup Summary values
                updateRollupSummaryFields(diIdSet);
            }
    }
    
    public void OnAfterUnDelete(List<Softrax_Asset__c> newTrigger)
    {
        if (!NI_FUNCTIONS.bypassTriggerCode('SOFTRAX ASSET'))
        {           
            //updateDIs(newTrigger, false);
            
            //Added by Prashant Wayal
            Set<Id> diIdSet = new Set<Id>();
            for(Softrax_Asset__c asObj: newTrigger){
                diIdSet.add(asObj.Deployment_Instance__c);
            }
            updateRollupSummaryFields(diIdSet);*/
             /*--------------------------
            Added by: Sunita Mittal
            Added on:01/04/2016
            Description:For Update the Type on Account
            ---------------------------*/
            /*Set<Id> accIdList = new Set<Id>();
            for(Softrax_Asset__c sftRax : newTrigger)
            {
                if(sftRax.Account__c != Null)
                    accIdList.add(sftRax.Account__c);            
            }
            if(!accIdList.isEmpty())
                updateBillingStatus(accIdList);
        }              
    }   
    
    // ======================================================================================
    // FUNCTIONS ============================================================================
    // ======================================================================================
    
    /**
    * @author Prashant Wayal
    * @date 4-march-2016
    * @description create cancellation and billing cancellation records for Softrax Asset records
    */
    /*
    public String getCancellationStatus(String cancStatus){
        //Set<String> openStatus = new Set<String>{''}
        if(cancStatus.equals('New') || cancStatus.equals('Working')){
            return 'Open';
        }
        else if(cancStatus.equals('Retained') || cancStatus.equals('Reactivated') || cancStatus.equals('User Error')){
            return 'ReOpen';
        }
        else if(cancStatus.equals('Pending') || cancStatus.equals('Cancelled')){
            return 'Closed';
        }
        return null;
    }
    
    public void createCancellationRecordsForSA(List<Softrax_Asset__c> saList, Map<Id, Softrax_Asset__c> oldSAMap){
        
        //Get values for Deployement Instance records
        Set<Id> dIIDSet = new Set<Id>();
        Map<Id, List<Softrax_Asset__c>> diSAMap = new Map<Id, List<Softrax_Asset__c>>();
        Map<Id, Asset> assetMap = new Map<Id, Asset>();
        Map<String, Softrax_Asset_to_Cancellation__c> billingCancMap = new Map<String, Softrax_Asset_to_Cancellation__c>();
        //Get all Softrax Asset records related to DI in Map
        for(Softrax_Asset__c asObj: saList){
            diIDSet.add(asObj.Deployment_Instance__c);
            //Get all billing records related to DI
            if(diSAMap.get(asObj.Deployment_Instance__c) != null){
                diSAMap.get(asObj.Deployment_Instance__c).add(asObj);
            }
            else{
                diSAMap.put(asObj.Deployment_Instance__c, new List<Softrax_Asset__c>{asObj});
            }
        }
        
        //get all cancellation records for SA records
        Map<String, NI_Cancellation__c> diCancListMap = new Map<String, NI_Cancellation__c>();
        Map<String, List<NI_Cancellation__c>> diCancListMap1 = new Map<String, List<NI_Cancellation__c>>();
        Set<Id> diCancIdSet = new Set<Id>();
        //Get all Active DI count under DI
        map<id,Integer> activeSACountUnderDIMap = new map<id,Integer>();
        //Get the DI records 
        if(!diIdSet.isEmpty()){
            //Get the DI records 
            assetMap = new Map<Id, Asset>([select Id, Name, AccountId, Status from Asset where Id IN: diIdSet]);
        	//get all cancellation records for SA records
            for(List<NI_Cancellation__c> cancObjList: [select Id, Name, Deployment_Instance__c, Status__c, Number_of_Users_Reduced__c, General_Reason__c, Softrax_Asset__c from NI_Cancellation__c where Deployment_Instance__c IN: diIDSet]){
                for(NI_Cancellation__c cancObj: cancObjList){
                    diCancIdSet.add(cancObj.Deployment_Instance__c);
                    //Check if multiple cancellation records present for DI
                    //Get the Generalized status for Cancellaion record
                    String status = getCancellationStatus(cancObj.Status__c);
                    System.debug('*** cancListMap key *** '+cancObj.Deployment_Instance__c+''+status);
                    diCancListMap.put(cancObj.Deployment_Instance__c+''+status, cancObj); //+''+cancObj.General_Reason__c
                    //Add values to diCancListMap1 based on ID
                    if(diCancListMap1.containsKey(cancObj.Deployment_Instance__c+''+status)){
                        diCancListMap1.get(cancObj.Deployment_Instance__c+''+status).add(cancObj);
                    }
                    else{
                        diCancListMap1.put(cancObj.Deployment_Instance__c+''+status, new List<NI_Cancellation__c>{cancObj});
                    }
                }
            }
            //Get all Active DI count under DI
            for (AggregateResult d2sCount : [SELECT COUNT(id) cnt , Deployment_Instance__c from  Softrax_Asset__c where (Status__c = 'Active' AND Deployment_Instance__c IN: diIdSet AND Id NOT IN: saList ) GROUP BY Deployment_Instance__c]){   
                System.debug('*** active SA cnt *** '+(integer)d2sCount.get('cnt'));
                activeSACountUnderDIMap.put((ID)d2sCount.get('Deployment_Instance__c'),(integer)d2sCount.get('cnt'));
            }
        }
        //Get all Softrax Asset to Cancellation records
        if(!saList.isEmpty()){
            for(Softrax_Asset_to_Cancellation__c sacObj: [select Id, Name, Softrax_Asset__c, Status__c, Cancellation__c, Deployment_Instance__c, 
                                                          Cancellation_Reason__c from Softrax_Asset_to_Cancellation__c where Softrax_Asset__c IN: saList]){
                billingCancMap.put(sacObj.Softrax_Asset__c+''+sacObj.Cancellation__c+''+sacObj.Status__c+''+sacObj.Cancellation_Reason__c, sacObj);
            }
        }
        
        List<NI_Cancellation__c> cancList = new List<NI_Cancellation__c>();
        //Variable used to check if cancellation record is created in the current context for same DI and reason
        Set<String> cancCheckSet = new Set<String>();
        Boolean isActivated = false;
        Boolean isDeactivated = false;
        Boolean isQuantityChanged = false;
        Decimal usersReduced = 0;
        String status = '';
        String generalReason = '';
        //Iterate over the Billing records being updated
        for(Softrax_Asset__c asObj: saList){
            //Check if Deployment Instance is blank. If blank then proceed to next record
            if(asObj.Deployment_Instance__c == null){
                continue;
            }
            //Initialize local variables to empty string
            status = '';
            generalReason = '';
            String genStatus = '';
            //Check if billing record is activated or deactivated
            isActivated = (asObj.Softrax_Status__c == 'A' && oldSAMap.get(asObj.Id).Softrax_Status__c != asObj.Softrax_Status__c);
            isDeactivated = (asObj.Softrax_Status__c == 'I' && oldSAMap.get(asObj.Id).Softrax_Status__c != asObj.Softrax_Status__c);
            //Check if quantity is changed. If changed, calculate the quantity changed value
            isQuantityChanged = (oldSAMap.get(asObj.Id).Quantity__c != asObj.Quantity__c);
            if(isQuantityChanged)
                usersReduced = (oldSAMap.get(asObj.Id).Quantity__c - asObj.Quantity__c);
            else
                usersReduced = asObj.Quantity__c;
            
            //If quantity changed, set status = new and reason = user reduction
            if(isQuantityChanged && usersReduced>0){
                generalReason = 'User Reduction';
                status= 'New';
                genStatus = 'Open';
            }
            //Check if status is changed
            else{
                //Check if there are any active billing record present for DI
                if(activeSACountUnderDIMap.get(asObj.Deployment_Instance__c) == null || (activeSACountUnderDIMap.get(asObj.Deployment_Instance__c) == 0)){
                    //If active billing records present, set the status values based on isActivated/idDeactivated
                    if(isActivated){
                        generalReason = 'User Reduction';
                        status= 'Reactivated';
                        genStatus = 'ReOpen';
                    }
                    else if(isDeactivated){
                        generalReason = 'Unknown';
                        status = 'New';
                        genStatus = 'Open';
                    }
                }
                else{
                    if(isActivated){
                        generalReason = 'User Reduction';
                        status= 'Reactivated';
                        genStatus = 'ReOpen';
                    }
                    else if(isDeactivated){
                        generalReason = 'User Reduction';
                        status = 'New';
                        genStatus = 'Open';
                    }
                }
            }            
            //Check if cancellation record is already present, if not, create new cancellation record
            //if(!diCancIdSet.contains(asObj.Deployment_Instance__c)){
            //Check if DI is active or not. If not active, no need to create cancellation record
            Set<String> activeStatus = new Set<String>{'Purchased', 'Installed'}; 
                //+''+generalReason
            //If there is no present DI cancellation record
            //if(!diCancListMap.containsKey(asObj.Deployment_Instance__c+''+genStatus)){
            if(!diCancListMap1.containsKey(asObj.Deployment_Instance__c+''+genStatus)){
                Boolean createCanc = true;
                //Get cancellation record for Cancelled record
                //NI_Cancellation__c canceRecord1 = diCancListMap.get(asObj.Deployment_Instance__c+'Closed');//+generalReason
                List<NI_Cancellation__c> canceRecordList = diCancListMap1.get(asObj.Deployment_Instance__c+'Closed');
                //Check if deactivated
                NI_Cancellation__c canceRecord1 = null;
                //Check if cancRecordList is not null or not empty
                if(canceRecordList != null && !canceRecordList.isEmpty()){
                    System.debug('*** canceRecordList size *** '+canceRecordList.size());
                    //Iterate over canceRecordList
                    for(NI_Cancellation__c canc: canceRecordList){
                        System.debug('*** '+canc.Name+'*** Users Reduced *** '+canc.Number_of_Users_Reduced__c+' *** quantity *** '+asObj.Quantity__c);
                        //Check if quantity and no of users reduced are equals
                        if(canc.Number_of_Users_Reduced__c != null && canc.Number_of_Users_Reduced__c == asObj.Quantity__c){
                            if(isDeactivated){
                                //Do not create cancellation record
                                createCanc = false;
                                break;
                            }
                            else if(isActivated){
                                //create cancellation record
                                createCanc = true;
                                canceRecord1 = canc;
                                status = 'Reactivated';
                                break;
                            }
                        }
                        else{
                            continue;
                        }
                    }
                }
                System.debug('*** DI Status *** '+assetMap.get(asObj.Deployment_Instance__c).Status);
                //Check if DI is active or not
                if(activeStatus.contains(assetMap.get(asObj.Deployment_Instance__c).Status) && createCanc){
                    NI_Cancellation__c canceRecord;
                    //If canceRecord1 is not null, then update existing record else create new record
                    //String id = '';
                    //Decimal usersRed = 0;
                    if(canceRecord1 != null){
                        canceRecord = canceRecord1;
                        //id = canceRecord1.Id;
                    }
                    else{
                        canceRecord = new NI_Cancellation__c();
                    }
                    canceRecord.Account__c = assetMap.get(asObj.Deployment_Instance__c).AccountId;
                    canceRecord.Deployment_Instance__c = asObj.Deployment_Instance__c;
                    canceRecord.General_Reason__c = generalReason;
                    canceRecord.Status__c = status;
                    
                    if(isDeactivated || (isActivated && createCanc)){
                        canceRecord.Number_of_Users_Reduced__c = asObj.Quantity__c;
                        //usersRed = asObj.Quantity__c;
                    }
                    else if(isQuantityChanged){
                        //If quantity is changed, update the Number of Users Reduced field
                        if(canceRecord.Number_of_Users_Reduced__c == null){
                            canceRecord.Number_of_Users_Reduced__c = usersReduced;
                            //usersRed = usersReduced;
                        }
                        else{
                            canceRecord.Number_of_Users_Reduced__c += usersReduced;
                            //usersRed = canceRecord1.Number_of_Users_Reduced__c + asObj.Quantity__c;
                        }
                    }
                    if(generalReason.equals('User Reduction')){
                        canceRecord.Specific_User_Names__c = 'Unknown';
                    }
                    //canceRecord = createCancellationObject(id, assetMap.get(asObj.Deployment_Instance__c).AccountId, asObj.Deployment_Instance__c, generalReason, status, 0, 'Unknown');
                    
                    //Check if cancellation is created in current context for same DI and reason
                    if(!cancCheckSet.contains(asObj.Deployment_Instance__c+''+canceRecord.Status__c+''+canceRecord.General_Reason__c) && ((isDeactivated || (isActivated && createCanc)) || isQuantityChanged)){
                        cancCheckSet.add(asObj.Deployment_Instance__c+''+canceRecord.Status__c+''+canceRecord.General_Reason__c);
                        cancList.add(canceRecord);
                    }
                }
                //else{
                    //No need to create any cancellation record
                //}    
            }
            //If there is an existing cancellation record present, update it accordingly
            else{
                //Check if billing record is active and quantity is changed
                if(asObj.Softrax_Status__c == 'A' && isQuantityChanged){
                    //Get all cancellation records present for new status
                    List<NI_Cancellation__c> canceRecordList = diCancListMap1.get(asObj.Deployment_Instance__c + genStatus);
                    //flag to check if we have to process the record updation or not
                    Boolean process = false;
                    NI_Cancellation__c canceRecord = null;
                    if(canceRecordList!= null && !canceRecordList.isEmpty()){
                        for(NI_Cancellation__c canc: canceRecordList){
                            //Check if General Reason is User Reduction
                            if(canc.General_Reason__c == 'User Reduction'){
                                canceRecord = canc;
                                process = true;
                                break;
                            }
                        }
                    }
                    if(process){
                        canceRecord.Number_of_Users_Reduced__c += usersReduced;
                        if(!cancCheckSet.contains(asObj.Deployment_Instance__c+''+canceRecord.Status__c+''+canceRecord.General_Reason__c)){
                            cancCheckSet.add(asObj.Deployment_Instance__c+''+canceRecord.Status__c+''+canceRecord.General_Reason__c);
                            cancList.add(canceRecord);
                        }
                    }
                }
                else if(isActivated){
                    List<NI_Cancellation__c> canceRecordList = diCancListMap1.get(asObj.Deployment_Instance__c + 'Closed');
                    //Check if deactivated
                    Boolean process = false;
                    NI_Cancellation__c canceRecord = null;
                    if(canceRecordList!= null && !canceRecordList.isEmpty()){
                        for(NI_Cancellation__c canc: canceRecordList){
                            //Check if old quantity and no of users reduced are equals
                            if(canc.Number_of_Users_Reduced__c == asObj.Quantity__c){
                                canceRecord = canc;
                                process = true;
                                break;
                            }
                        }
                    }
                    if(process){
                        canceRecord.Status__c = 'Reactivated';
                        if(!cancCheckSet.contains(asObj.Deployment_Instance__c+''+canceRecord.Status__c+''+canceRecord.General_Reason__c)){
                            cancCheckSet.add(asObj.Deployment_Instance__c+''+canceRecord.Status__c+''+canceRecord.General_Reason__c);
                            cancList.add(canceRecord);
                        }
                    }
                }
                else{
                    List<NI_Cancellation__c> canceRecordList = diCancListMap1.get(asObj.Deployment_Instance__c + 'Open');
                    Boolean process = false;
                    NI_Cancellation__c canceRecord = null;
                    if(canceRecordList!= null && !canceRecordList.isEmpty()){
                        for(NI_Cancellation__c canc: canceRecordList){
                            if(activeSACountUnderDIMap.get(asObj.Deployment_Instance__c) == null || (activeSACountUnderDIMap.get(asObj.Deployment_Instance__c) == 0)){
                                if(canc.General_Reason__c == 'Unknown' || canc.General_Reason__c == 'User Reduction'){
                                    canceRecord = canc;
                                    process = true;
                                    break;
                                }
                            }
                            else{
                                if(canc.General_Reason__c == 'User Reduction'){
                                    canceRecord = canc;
                                    process = true;
                                    break;
                                }
                            }
                        }
                    }
                    if(process){
                        if(activeSACountUnderDIMap.get(asObj.Deployment_Instance__c) == null || (activeSACountUnderDIMap.get(asObj.Deployment_Instance__c) == 0)){
                            canceRecord.General_Reason__c = 'Unknown';
                        }
                        canceRecord.Number_of_Users_Reduced__c += asObj.Quantity__c;
                        if(!cancCheckSet.contains(asObj.Deployment_Instance__c+''+canceRecord.Status__c+''+canceRecord.General_Reason__c)){
                            cancCheckSet.add(asObj.Deployment_Instance__c+''+canceRecord.Status__c+''+canceRecord.General_Reason__c);
                            cancList.add(canceRecord);
                        }
                    }
                }
            }
        }
        
        try{
            //Upsert cancellation list
            Database.upsertResult[] result = database.upsert(cancList);
            for(Integer i=0; i<result.size(); i++){
                if(result[i].isSuccess()){
                    NI_Cancellation__c cancObj = cancList[i];
                    String distatus = getCancellationStatus(cancObj.Status__c);
                    //Add newly created cancellation records to map variable
                    if(diCancListMap.get(cancObj.Deployment_Instance__c+''+distatus) == null){
                        diCancListMap1.put(cancObj.Deployment_Instance__c+''+distatus, new List<NI_Cancellation__c> {cancObj});
                    }
                    else{
                        diCancListMap1.get(cancObj.Deployment_Instance__c+''+distatus).add(cancObj);
                    }
                }
            }
        }
        catch(Exception ex){
            System.debug('*** DML Exception in while creating DI Cancellation records *** '+ex.getMessage());
        }
        
        List<Softrax_Asset_to_Cancellation__c> billObjList = new List<Softrax_Asset_to_Cancellation__c>();
        //String status = '';
        String cancId = '';
        //Create Billing cancellation records for all Billing records which are inactivated
        for(Softrax_Asset__c asObj: saList){
        	//Check if Deployment Instance is blank. If blank then proceed to next record
            if(asObj.Deployment_Instance__c == null){
                continue;
            }
            status = '';
            cancId = '';
            isActivated = (asObj.Softrax_Status__c == 'A' && oldSAMap.get(asObj.Id).Softrax_Status__c != asObj.Softrax_Status__c);
            isDeactivated = (asObj.Softrax_Status__c == 'I' && oldSAMap.get(asObj.Id).Softrax_Status__c != asObj.Softrax_Status__c);
            isQuantityChanged = (oldSAMap.get(asObj.Id).Quantity__c != asObj.Quantity__c);
            usersReduced = (oldSAMap.get(asObj.Id).Quantity__c - asObj.Quantity__c);
            List<NI_Cancellation__c> cancTmpList;
            //Check if all billing records are inactive
            //If quantity changed, set status = new and reason = user reduction
            if(isQuantityChanged && usersReduced>0){
                generalReason = 'User Reduction';
                status= 'New';
                cancTmpList = (diCancListMap1.get(asObj.Deployment_Instance__c+'Open') == null)?(new List<NI_Cancellation__c>()):(diCancListMap1.get(asObj.Deployment_Instance__c+'Open'));
                //cancId = (diCancListMap.get(asObj.Deployment_Instance__c+'Open') == null)?'':(diCancListMap.get(asObj.Deployment_Instance__c+'Open').Id); //+'User Reduction'
                //genStatus = 'Open';
            }
            //Check if status is changed
            else{
                //Get the DI cancellation ID based on the status and general reason
                if(activeSACountUnderDIMap.get(asObj.Deployment_Instance__c) == null || (activeSACountUnderDIMap.get(asObj.Deployment_Instance__c) == 0)){
                    //Check if SA is activated or inactivated
                    if(isActivated){
                        //cancId = (diCancListMap.get(asObj.Deployment_Instance__c+'ReOpen') == null)?'':(diCancListMap.get(asObj.Deployment_Instance__c+'ReOpen').Id); //+'User Reduction'
                        cancTmpList = (diCancListMap1.get(asObj.Deployment_Instance__c+'ReOpen') == null)?(new List<NI_Cancellation__c>()):(diCancListMap1.get(asObj.Deployment_Instance__c+'ReOpen'));
                        status = 'Reactivated';
                        generalReason = 'Reactivated';
                    }
                    else if(isDeactivated){
                        //cancId = (diCancListMap.get(asObj.Deployment_Instance__c+'Open') == null)?'':(diCancListMap.get(asObj.Deployment_Instance__c+'Open').Id); //+'Unknown'
                        cancTmpList = (diCancListMap1.get(asObj.Deployment_Instance__c+'Open') == null)?(new List<NI_Cancellation__c>()):(diCancListMap1.get(asObj.Deployment_Instance__c+'Open'));
                        status = 'New';
                        generalReason = 'Inactivated';
                    }
                }
                else{
                    if(isActivated){
                        System.debug('*** key *** '+diCancListMap.get(asObj.Deployment_Instance__c+'ReOpen'));
                        //cancId = (diCancListMap.get(asObj.Deployment_Instance__c+'ReOpen') == null)?'':(diCancListMap.get(asObj.Deployment_Instance__c+'ReOpen').Id); //+'User Reduction'
                        cancTmpList = (diCancListMap1.get(asObj.Deployment_Instance__c+'ReOpen') == null)?(new List<NI_Cancellation__c>()):(diCancListMap1.get(asObj.Deployment_Instance__c+'ReOpen'));
                        status = 'Reactivated';
                        generalReason = 'Reactivated';
                    }
                    else if(isDeactivated){
                        //cancId = (diCancListMap.get(asObj.Deployment_Instance__c+'Open') == null)?'':(diCancListMap.get(asObj.Deployment_Instance__c+'Open').Id);//+'User Reduction'
                        cancTmpList = (diCancListMap1.get(asObj.Deployment_Instance__c+'Open') == null)?(new List<NI_Cancellation__c>()):(diCancListMap1.get(asObj.Deployment_Instance__c+'Open'));
                        status = 'New';
                        generalReason = 'Inactivated';
                    }
                    
                }
            }
            //Check if billing cancellation is already present or not. If not present, create the new record
            //Add condition to check if quantity changed
            if(cancTmpList!= null &&  !cancTmpList.isEmpty()){
                //if(!(billingCancMap.containsKey(asObj.Id+''+cancId+''+status)))
                
                Boolean process = false;
                for(NI_Cancellation__c c: cancTmpList){
                    if(activeSACountUnderDIMap.get(asObj.Deployment_Instance__c) == null || (activeSACountUnderDIMap.get(asObj.Deployment_Instance__c) == 0)){
                        if(c.General_Reason__c == 'Unknown' || c.General_Reason__c == 'User Reduction'){
                            cancId = c.Id;
                            process = true;
                            break;
                        }
                    }
                    else{
                        if(c.General_Reason__c == 'User Reduction'){
                            cancId = c.Id;
                            process = true;
                            break;
                        }
                    }
                }
                if(process){
                    Softrax_Asset_to_Cancellation__c billObj = new Softrax_Asset_to_Cancellation__c();
                    billObj.Account__c = asObj.Account__c;
                    billObj.Softrax_Asset__c = asObj.Id;
                    billObj.Deployment_Instance__c = asObj.Deployment_Instance__c;
                    billObj.Cancellation_Effective_Date__c = asObj.CancellationEffectiveDate__c;
                    if(isQuantityChanged && usersReduced>0){
                        billObj.Quantity__c = usersReduced;
                    }
                    else{
                        billObj.Quantity__c = asObj.Quantity__c;
                    }
                    billObj.Cancellation__c = cancId;
                    billObj.Status__c = status;
                    billObj.Cancellation_Reason__c = generalReason;
                    //If quantity changed, create new billing cancellation
                    if(isQuantityChanged && usersReduced>0){
                        billObjList.add(billObj);
                    }
                    //If no billing cancellation present, create new billing cancellation
                    else if(!(billingCancMap.containsKey(asObj.Id+''+cancId+''+status+generalReason))){
                        billObjList.add(billObj);
                    }
                }
                //If billing cancellation record is already present, then don't create any new record
            }   
        }
        
        try{
            if(!billObjList.isEmpty())
            insert billObjList;
        }
        Catch(DMLException ex){
            System.debug('*** DML Exception in while creating Billing Cancellation records *** '+ex.getMessage());
        }
        
    }
    */
    /*
    public NI_Cancellation__c createCancellationObject(String Id, String AccountId, String dIId, String genReason, String status, Decimal usersReduced, String userNames){
        NI_Cancellation__c cancObj;
        if(String.isEmpty(id)){
            cancObj = new NI_Cancellation__c();
        }
        else{
            cancObj = new NI_Cancellation__c(id=id);
        }
        cancObj.Account__c = AccountId;
        cancObj.Deployment_Instance__c = dIId;
        cancObj.General_Reason__c = genReason;
        cancObj.Status__c = status;
        cancObj.Number_of_Users_Reduced__c = usersReduced;
        cancObj.Specific_User_Names__c = userNames;
        return cancObj;
    }
    */
    // This function creates cancellation record for Deploymnent Instance if all
    // softrax asset under DI is inactive.
    /*
    private void updateCancellationRecordForSA(List<Softrax_Asset__c> nTrig, boolean isDelete,Map<Id, Softrax_Asset__c> oTrig){
        Set<Id> setSoftraxAssetIds = new Set<Id>();
        Set<Id> setAssetIds = new Set<Id>();
        Set<Id> setRelatedSoftraxAssetIds = new Set<Id>();
        //map<id,list<map<id,DI_to_Softrax_Asset__c>>> activeDis = new  map<id,list<map<id,DI_to_Softrax_Asset__c>>>();
        //map<id,list<map<id,DI_to_Softrax_Asset__c>>> inActiveDis = new map<id,list<map<id,DI_to_Softrax_Asset__c>>>();
        map<id,map<id,NI_Cancellation__c>> cancelledMapSA = new map<id,map<id,NI_Cancellation__c>>();
        //map<id,map<id>> cancelledMapSA = new map<id,set<id>>();
        list<NI_Cancellation__c> fetchCancelledSA = new list<NI_Cancellation__c>();
        list<NI_Cancellation__c> cancelledSAToAdd  = new list<NI_Cancellation__c>();
        list<NI_Cancellation__c> cancelledSAToUpdate  = new list<NI_Cancellation__c>();
        for (Softrax_Asset__c sf : nTrig)
        {   
            if(oTrig.size() > 0 && sf.Status__c != oTrig.get(sf.Id).Status__c){
                setSoftraxAssetIds.Add(sf.Id);
            }else{
                setSoftraxAssetIds.Add(sf.Id);
            }
        } 
        
        string notes ;
        map<id,integer> totalSaCountUnderDI = new map<id,integer>();
        map<id,integer> InactiveSaCountUnderDI = new map<id,integer>();
        //list<AggregateResult> groupedInactiveDi =  [SELECT COUNT(id) cnt , Deployment_Instance__c from  DI_to_Softrax_Asset__c where (Softrax_Asset__r.Status__c = 'Inactive') GROUP BY Deployment_Instance__c];
        for (AggregateResult d2sCount : [SELECT COUNT(id) cnt , Deployment_Instance__c from  Softrax_Asset__c where (Status__c = 'Inactive') GROUP BY Deployment_Instance__c])
        {   
           InactiveSaCountUnderDI.put((ID)d2sCount.get('Deployment_Instance__c'),(integer)d2sCount.get('cnt'));
        }
        for (AggregateResult d2sCount : [SELECT COUNT(id) cnt , Deployment_Instance__c from  Softrax_Asset__c GROUP BY Deployment_Instance__c])
        {   
           totalSaCountUnderDI.put((ID)d2sCount.get('Deployment_Instance__c'),(integer)d2sCount.get('cnt'));
        }
        //system.debug('setSoftraxAssetIds===='+setSoftraxAssetIds);
        // fetch list of existing cancelled softrax asset.
        //fetchCancelledSA = 
        //if(fetchCancelledSA.size()>0){
        for (list<NI_Cancellation__c> canHeap : [select Cancellation_Notes__c,Deployment_Instance__c,Softrax_Asset__c from NI_Cancellation__c where Softrax_Asset__c in: setSoftraxAssetIds]){
                for(NI_Cancellation__c  can:canHeap){
                    if(cancelledMapSA.containsKey(can.Deployment_Instance__c)){
                        cancelledMapSA.get(can.Deployment_Instance__c).put(can.Softrax_Asset__c,can);
                    }else{
                        map<id,NI_Cancellation__c> addSa = new map<id,NI_Cancellation__c>();
                        addSa.put(can.Softrax_Asset__c,can);
                        cancelledMapSA.put(can.Deployment_Instance__c, addSa);                    
                    }
                }     
           
        }
        
        
        //map<id,DI_to_Softrax_Asset__c> saMap;
        // Fetch all related softrax asset and deployment instance, bifurcate them into
        // active and inactive deployment instances and add softrax asset under respective
        // deployment instances.
       for (list<Softrax_Asset__c> d2sHeap : [SELECT End_Date__c,Status__c,
                     Deployment_Instance__r.Status,id,
                     Deployment_Instance__c,Account__c, 
                     Account__r.Franchisor__c,                     
                     Account__r.Ownerid,
                     Account__r.Brand__c,
                     Account__r.Parentid,
                     Quantity__c,
                     Account__r.Ownership_Company__c,
                     Start_Date__c,CancellationEffectiveDate__c,
                     Deployment_Instance__r.Product2.Classification__c
                     FROM Softrax_Asset__c  WHERE id IN :setSoftraxAssetIds])
        {
            cancelledSAToAdd  = new list<NI_Cancellation__c>();
            cancelledSAToUpdate  = new list<NI_Cancellation__c>();
            for (Softrax_Asset__c d2s: d2sHeap){
                NI_Cancellation__c canceRecord = new NI_Cancellation__c();
                canceRecord.Account__c = d2s.Account__c;
                // not writable canceRecord.Account_Number__c=d2s.Softrax_Asset__r.Account__r.AccountNumber;
                canceRecord.Brand__c = d2s.Account__r.Brand__c;
                canceRecord.Account_Owner__c = d2s.Account__r.Ownerid;
                canceRecord.Deployment_Instance__c = d2s.Deployment_Instance__c;
                
                canceRecord.Franchisor__c = d2s.Account__r.Franchisor__c;
                canceRecord.General_Reason__c = 'Unknown';
                //not writable canceRecord.Install_Date__c = d2s.Deployment_Instance__r.InstallDate;
                canceRecord.Management_Company__c =  d2s.Account__r.Parentid;
                //canceRecord.NI_Collector__c
                canceRecord.Cancellation_Quantity__c = 1;
                
                if(InactiveSaCountUnderDI.containskey(d2s.Deployment_Instance__c)  && InactiveSaCountUnderDI.get(d2s.Deployment_Instance__c) == totalSaCountUnderDI.get(d2s.Deployment_Instance__c)){
                    canceRecord.Number_of_Users_Reduced__c = null;
                    canceRecord.Status__c = 'Cancelled';
                }else{
                    canceRecord.Number_of_Users_Reduced__c = d2s.Quantity__c;
                    canceRecord.Status__c = 'User Reduction';
                }            
                
                canceRecord.Ownership_Company__c = d2s.Account__r.Ownership_Company__c;
                //- not writable canceRecord.Product__c = d2s.Deployment_Instance__r.Product2id;
                canceRecord.Product_Classification__c = d2s.Deployment_Instance__r.Product2.Classification__c;
                //not writable canceRecord.Product_Code__c = d2s.Deployment_Instance__r.Product2.ProductCode;
                canceRecord.Reviewed_by_Collector__c = true;
                canceRecord.Reviewed_By_Fulfillment__c = false;
                canceRecord.Softrax_Asset__c = d2s.id;
                canceRecord.Updated_in_Softrax__c = true;
                //not writable canceRecord.Territory__c = d2s.Softrax_Asset__r.Account__r.Territory__c;
                
                //not writable canceRecord.Softrax_Asset_End_Date__c;
                //not writable canceRecord.Softrax_Asset_Fee__c;
                //not writable canceRecord.Softrax_Asset_Quantity__c;
                //not writable canceRecord.Softrax_Asset_Start_Date__c;
                //not writable canceRecord.Softrax_Status__c;
                //not writable canceRecord.SoftraxUploadRecordNumber__c;
                if((!cancelledMapSA.containskey(d2s.Deployment_Instance__c) || (cancelledMapSA.containskey(d2s.Deployment_Instance__c) && !cancelledMapSA.get(d2s.Deployment_Instance__c).containskey(d2s.id))) && d2s.Status__c == 'Inactive'){
                    // Create Cancellation per "Billing Record Deactivation"
                    canceRecord.Cancellation_Notes__c = 'This Cancellation was auto-generated based on the inactivation of the related Billing Record.';
                    canceRecord.Effective_Date__c =   d2s.CancellationEffectiveDate__c;
                    cancelledSAToAdd.add(canceRecord);
                }else if((!cancelledMapSA.containskey(d2s.Deployment_Instance__c) || (cancelledMapSA.containskey(d2s.Deployment_Instance__c) && !cancelledMapSA.get(d2s.Deployment_Instance__c).containskey(d2s.id)))  && d2s.Status__c == 'Active' && d2s.Deployment_Instance__r.Status == 'Inactive'){
                    // Create Cancellation per "Billing Record Activation"
                    canceRecord.Effective_Date__c = d2s.Start_Date__c;  
                    canceRecord.Status__c = 'Reactivated';
                    canceRecord.Cancellation_Notes__c = 'This Cancellation was reactivated based on the reactivation of the related Billing Record.';
                    cancelledSAToAdd.add(canceRecord);
                }else if(cancelledMapSA.containskey(d2s.Deployment_Instance__c) && cancelledMapSA.get(d2s.Deployment_Instance__c).containskey(d2s.id) && d2s.Status__c == 'Active'){
                   NI_Cancellation__c updateRecord = cancelledMapSA.get(d2s.Deployment_Instance__c).get(d2s.id);
                   updateRecord.Status__c = 'Reactivated';
                   //updateRecord.Cancellation_Notes__c = updateRecord.Cancellation_Notes__c+'\n\n';
                   notes = updateRecord.Cancellation_Notes__c ;
                   updateRecord.Cancellation_Notes__c = notes  +' '+'\n\nThis Cancellation was reactivated based on the reactivation of the related Billing Record.';
                   cancelledSAToUpdate.add(updateRecord);
                }else if(cancelledMapSA.containskey(d2s.Deployment_Instance__c) && cancelledMapSA.get(d2s.Deployment_Instance__c).containskey(d2s.id) && d2s.Status__c == 'Inactive'){
                   NI_Cancellation__c updateRecord = cancelledMapSA.get(d2s.Deployment_Instance__c).get(d2s.id);
                   updateRecord.Status__c = 'User Reduction';
                   notes = updateRecord.Cancellation_Notes__c ;
                   updateRecord.Cancellation_Notes__c = notes +' '+'\n\nThis Cancellation was auto-generated based on the inactivation of the related Billing Record.';
                   cancelledSAToUpdate.add(updateRecord);
                }
          }  
            if(cancelledSAToAdd.size() > 0){
                insert cancelledSAToAdd;
            }
            if(cancelledSAToUpdate.size() > 0){
                update cancelledSAToUpdate;
            }
        }
            
            
        } // end function updateCancellationRecordForSA
       
      */
    /**
    * @author Prashant Wayal
    * @description - Method added to calculate the rollup summary value for Quantity Billed field
    *              - Future annotation used to avaoid the SOQL governor limit
    */     
    /*@future
    public static void updateRollupSummaryFields(Set<Id> newTrigger){
        List<AggregateResult> result = [SELECT Deployment_Instance__c, SUM(Quantity__c) quantity FROM Softrax_Asset__c WHERE Deployment_Instance__c IN: newTrigger AND Status__c = 'Active' GROUP BY Deployment_Instance__c];
        
        List<Asset> assetToUpdate = new List<Asset>(); //[SELECT Id, Quantity_Billed__c FROM Asset WHERE Id IN: newTrigger];
        For(Asset diObj: [SELECT Id, Name, Quantity_Billed__c FROM Asset WHERE Id IN: newTrigger]){
            System.debug('Before *** For DI *** '+diObj.Name+' *** Qantity is *** '+diObj.Quantity_Billed__c);
            diObj.Quantity_Billed__c = 0; 
            for(AggregateResult res: result){
                if(res.get('Deployment_Instance__c') != null && diObj.Id == (Id)res.get('Deployment_Instance__c')){
                    diObj.Quantity_Billed__c +=  (res.get('quantity') != null)?((Decimal)res.get('quantity')):0;
                }
            }
            System.debug('*** For DI *** '+diObj.Name+' *** Qantity is *** '+diObj.Quantity_Billed__c);
            assetToUpdate.add(diObj);
        }
        update assetToUpdate;
    }
    
    // ======================================================================================
    // FUNCTIONS ============================================================================
    // ======================================================================================
    
    // THIS FUNCTION FIRES WHEN --UPDATES-- HAPPEN ON SOFTRAX_ASSET__C RECORDS.
    // DUE TO THE INABILITY TO CREATE ROLLUP SUMMARIES on Asset THROUGH THE DI_to_Softrax_Asset__c JUNCTION OBJECT to Softrax_Asset__c 
    // WE HAVE TO QUERY ALL Softrax_Asset__c RECORDS RELATED TO Asset RECORD AND MANUALLY: 
    //     SUM QUANTITIES, FIND MIN START DATES, FIND MAX END DATES ... THEN 
    // UPDATE THE Asset RECORD'S Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c FIELDS WITH COLLECTED VALUES 
    //      -- OLD SIGNATURE private void updateDIs(List<Softrax_Asset__c> nTrig, Map<Id, Softrax_Asset__c> oMapTrig) --
    // isDelete BOOLEAN IS USED TO LET THE CODE KNOW WHEN TO NOT INCLUDE DELETED Softrax_Asset__c RECORDS IN ROLLUPS   
    
    /*
    private void updateDIs(List<Softrax_Asset__c> nTrig, boolean isDelete)        
    {
        
        Set<Id> setSoftraxAssetIds = new Set<Id>();
        Set<Id> setAssetIds = new Set<Id>();
        Set<Id> setRelatedSoftraxAssetIds = new Set<Id>();
        
        for (Softrax_Asset__c sf : nTrig)
        {
            setSoftraxAssetIds.Add(sf.Id);
        } 
    
        // GET ALL Asset IDS RELATED TO UPDATED Softrax_Asset__c RECORDS
        for (DI_to_Softrax_Asset__c d2s : [SELECT Deployment_Instance__c FROM DI_to_Softrax_Asset__c WHERE Softrax_Asset__c IN : setSoftraxAssetIds])
        {
            setAssetIds.Add(d2s.Deployment_Instance__c);
        } 

        List<objAssetRollups> lstAssetRollups = new List<objAssetRollups>();

        // THEN GET ALL Softrax_Asset__c IDS RELATED TO Asset IDs FOUND IN ABOVE ROUTINE
        for (DI_to_Softrax_Asset__c s2d : [SELECT Deployment_Instance__c, Softrax_Asset__c 
                                           FROM DI_to_Softrax_Asset__c 
                                           WHERE Deployment_Instance__c IN : setAssetIds 
                                           ORDER BY Deployment_Instance__c ASC])
        {         
            if (!isDelete) 
            {               
                setRelatedSoftraxAssetIds.Add(s2d.Softrax_Asset__c); 
                // DEF: new objAssetRollups(DeploymentInstanceId, SoftraxAssetId, ProductCode, dQuantity, dtStartDate, isActive)            
                lstAssetRollups.Add(new objAssetRollups(s2d.Deployment_Instance__c, s2d.Softrax_Asset__c, null, 0, null, false)); 
            }
            else
            {   // IF RECORD IS BEING DELETED DO NOT INCLUDE IT IN ROLLUP CALCULATIONS
                if (!setSoftraxAssetIds.contains(s2d.Softrax_Asset__c))
                {
                    setRelatedSoftraxAssetIds.Add(s2d.Softrax_Asset__c); 
                    // DEF: new objAssetRollups(DeploymentInstanceId, SoftraxAssetId, ProductCode, dQuantity, dtStartDate, isActive)            
                    lstAssetRollups.Add(new objAssetRollups(s2d.Deployment_Instance__c, s2d.Softrax_Asset__c, null, 0, null, false));
                }
            }
            
        }

        for (Softrax_Asset__c sas : [SELECT Id, Name, Start_Date__c, End_Date__c, Quantity__c, Status__c, Softrax_Status__c 
                                     FROM Softrax_Asset__c 
                                     WHERE Id IN : setRelatedSoftraxAssetIds])
                                     // WHERE Status__c = 'Active' 
                                     // WHERE Softrax_Status__c = 'A' AND             
        {
            for (objAssetRollups r : lstAssetRollups) 
            {            
                if (sas.Id == r.SoftraxAssetId)
                {
                    r.ProductCode = sas.Name;
                    if (sas.Softrax_Status__c == 'A')
                    {                    
                        r.dQuantity = sas.Quantity__c;
                        r.dtStartDate = sas.Start_Date__c;                       
                        r.isActive = true;
                    }
                }
            }
        }        
        
        Map<id, objAssetRollups> mapAssetRollups = new Map<id, objAssetRollups>();
        
        for (objAssetRollups r2 : lstAssetRollups) 
        {          
            if (!mapAssetRollups.containsKey(r2.DeploymentInstanceId))
            {
                mapAssetRollups.put(r2.DeploymentInstanceId, r2);
            }
            else
            {             
                if ((r2.dQuantity != null) && (r2.isActive))
                {
                    mapAssetRollups.Get(r2.DeploymentInstanceId).dQuantity += r2.dQuantity;
                }
                else
                {
                    mapAssetRollups.Get(r2.DeploymentInstanceId).dQuantity += 0;
                }
                
                if ((r2.dtStartDate != null) && (r2.isActive))
                {
                    if (mapAssetRollups.Get(r2.DeploymentInstanceId).dtStartDate == null)
                    {
                        mapAssetRollups.Get(r2.DeploymentInstanceId).dtStartDate = r2.dtStartDate;
                    }
                    else 
                    {
                        if (mapAssetRollups.Get(r2.DeploymentInstanceId).dtStartDate > r2.dtStartDate)
                        {
                            mapAssetRollups.Get(r2.DeploymentInstanceId).dtStartDate = r2.dtStartDate;
                        } 
                    }
                  
                } 
            }
        }

        List<objAssetRollups> lstAssetRollupFinal = new List<objAssetRollups>();
        
        for (objAssetRollups oars : mapAssetRollups.values()) 
        {
            lstAssetRollupFinal.Add(oars);
        }

        List<Asset> lstDIUpdate = new List<Asset>();

        for (Asset lstAs : [SELECT Id, Quantity_Billed__c, Purchase_Date__c, InstallDate, Status FROM Asset WHERE Id IN : setAssetIds])
        {            
            for (objAssetRollups r3 : lstAssetRollupFinal)
            {
                if (lstAs.Id == r3.DeploymentInstanceId)
                {
                    lstAs.Quantity_Billed__c = r3.dQuantity;
                    if (lstAs.Purchase_Date__c == null)
                    {
                        lstAs.Purchase_Date__c = r3.dtStartDate;
                    }
                    if ((lstAs.Status == 'Installed') && (lstAs.InstallDate == null))
                    {
                        lstAs.InstallDate = r3.dtStartDate;
                    }
                    lstDIUpdate.Add(lstAs);
                }                
            }
        }
     
        database.update(lstDIUpdate);

    }
    */
    /**
    * @author Prashant Wayal
    * @date 19-Feb-2016
    * @description Method to update the product of Deployment Instance record when
    *             a related Softrax Asset record is deleted
    */
    
    /*public void updateDIProductForInactiveSA(List<Softrax_Asset__c> saList, Set<Id> diIdSet){
        //List<Asset> assetListToUpdate = new List<Asset>();
        Map<Id, Asset> asMap = new Map<Id, Asset>();
        if(!diIdSet.isEmpty()){
            //Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, Product2Id, Status, Product2.DI_Priority__c, Product2.DI_Index__c,  (SELECT Deployment_Instance__c, Product2Id__c, Product2Id__r.DI_Index__c, Product2Id__r.DI_Priority__c FROM Softrax_Assets__r where Id NOT IN: saList AND Status__c='Active') FROM Asset WHERE Id IN:diIdSet]);
            Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, Product2Id, Status, Product2.DI_Priority__c, Product2.DI_Index__c,  (SELECT Deployment_Instance__c, Product2Id__c, Product2Id__r.DI_Index__c, Product2Id__r.DI_Priority__c FROM Softrax_Assets__r where Id NOT IN: saList AND Status__c='Active') FROM Asset where Id IN:diIdSet]);
            Boolean isStatusChanged = false;
             System.debug('salist'+saList);
            for(Softrax_Asset__c saObj: saList){
                Asset asObj = assetMap.get(saObj.Deployment_Instance__c);
                System.debug('asObj'+asObj);
                System.debug('*** sa index *** '+saObj.Product2Id__c+' *** DI Index *** '+ asObj.Product2Id);*/
                //Check if all Softrax Asset(Billing Records) are inactive. If yes, set DI Status = Inactive
                //As per updated requirement, below code is no longer valid
                /*if(asObj.Softrax_Assets__r.size() == 0){
                    asObj.Status = 'Inactive';
                    isStatusChanged = true;
                }*/
                //Check for same product
                /*if(saObj.Product2Id__c == asObj.Product2Id){
                    if(asObj.Softrax_Assets__r.size() > 0){
                        //If product is same, update the product with max priority
                        Decimal priority = 0;
                        String prodId = '';
                        //Get highest priority product
                        for(Softrax_Asset__c sObj: asObj.Softrax_Assets__r){
                            if(sObj.Product2Id__r.DI_Priority__c >= priority){
                                priority = sObj.Product2Id__r.DI_Priority__c;
                                prodId = sObj.Product2Id__c;
                            }
                        }
                        //Update new product on DI
                        if(!String.isEmpty(prodId)){
                            asObj.Product2Id = prodId;
                        }
                        asMap.put(asObj.Id, asObj);
                        //assetListToUpdate.add(asObj);
                    }
                }*/
                /*if(!asMap.containsKey(asObj.Id) && isStatusChanged){
                    asMap.put(asObj.Id, asObj);
                    isStatusChanged = false;
                }*/
            /*}
            try{
                if(!asMap.values().isEmpty())
                update asMap.values();
            }
            catch(Exception e){
                System.debug('*** Error *** '+e.getMessage());
            }
        }
    }*/
    
    /**
     * @authot Prashant Wayal
     * @description Method to create new DI record or link existing
     * DI record with newly created/updated billing record
     * 
    */
    /*public void createUpdateDIForSA(List<Softrax_Asset__c> saList){
        Map<String, Asset> existingAssetMap = new Map<String, Asset>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> diIndexSet = new Set<Id>();
        Set<String> productIdSet = new Set<String>();
        Map<Id, Product2> product2Map;
        //Check if saList is null or not
        if(saList != null){
            //Iterate over the saList
            for(Softrax_Asset__c sa: saList){
                System.debug('*** sa *** '+sa.Name);
                //Add account Id to accountIdSet set
                accountIdSet.add(sa.Account__c);
                productIdSet.add(sa.Product2Id__c);
            }
        }
        //Get all products values from Product2 related to SA or OLI
        if(productIdSet != null){
            product2Map = new Map<Id, Product2>();
            for(Product2 prd: [SELECT Id, ProductCode, DI_Index__c, DI_DefaultStatus__c, DI_Priority__c FROM Product2 WHERE Id IN : productIdSet AND DI_Index__c != null]){
                //Add DI_Index__c value to diIndexSet set
                diIndexSet.add(prd.DI_Index__c);
                product2Map.put(prd.Id, prd);
            }
        }
        //If accountIdSet is null and empty or diIndexSet is empty, exit from trigger 
        if((accountIdSet == null && accountIdSet.isEmpty()) || (diIndexSet.isEmpty())){
            return;
        }
        Map<Id, Asset> assetMap = new Map<Id, Asset>();
        //add values to existingAssetMap variable
        for(Asset asObj: [SELECT Id, AccountId, InstallDate, Purchase_Date__c, Product2Id, DI_Index_Name__c, Core_DI__c, Product2.DI_Index__c, Status, Product2.DI_Priority__c FROM Asset WHERE AccountId IN : accountIdSet AND Product2.DI_Index__c IN: diIndexSet]){
            assetMap.put(asObj.id, asObj);
            existingAssetMap.put(asObj.AccountId+''+asObj.Product2.DI_Index__c, asObj);
        }
        //Clear unused variables
        diIndexSet.clear();
        
        Map<String, Decimal> oldRecordPriorityMap = new Map<String, Decimal>();
        Map<String, Asset> assetToUpsertMap = new Map<String, Asset>();
        if(saList != null){
            //Iterate over the saList
            for(Softrax_Asset__c sa: saList){
                
                //Check if Asset id already present for same account and DI Index
                if(existingAssetMap != null && (!existingAssetMap.isEmpty()) && existingAssetMap.keySet().contains(sa.Account__c+''+product2Map.get(sa.Product2Id__c).DI_Index__c)){
                    //Asset is present for new SA record, process accordingly
                    Id product2Id = null;
                    String status = null;
                    Date installDate = null;
                    Date purchaseDate = null;
                    Asset extObj = (existingAssetMap.get(sa.Account__c+''+product2Map.get(sa.Product2Id__c).DI_Index__c));
                    //Check product priority and update product accordingly
                    if(sa.Product2Id__c != extObj.Product2Id){
                        //Compare the status of Softrax Asset and product default status
                        Boolean isStatus = (extObj.Status != 'Installed' || product2Map.get(sa.Product2Id__c).DI_DefaultStatus__c == 'Installed');
                        if(sa.Status__c.equals('Active') && product2Map.get(sa.Product2Id__c).DI_Priority__c >= assetMap.get(extObj.Id).Product2.DI_Priority__c){
                            product2Id = sa.Product2Id__c;
                        }
                            
                        if(sa.Status__c.equals('Active') && isStatus){
                            status = 'Installed';
                        }
                        
                        if(sa.Status__c.equals('Active') && extObj.InstallDate == null && isStatus){
                            if(extObj.Purchase_Date__c != null && (extObj.Purchase_Date__c > sa.Start_Date__c)){
                                installDate = extObj.Purchase_Date__c;
                            }
                            else{
                                installDate = sa.Start_Date__c;
                            }
                        }
                        //Check if Purchase Date is null or not, if null, update to start date
                        if(sa.Status__c.equals('Active') && extObj.Purchase_Date__c == null){
                            purchaseDate = sa.Start_Date__c;
                        }
                        Asset assetObj = NI_SoftraxAsset_TriggerHandler.createUpdateAsset(extObj.Id, null, sa.Account__c, product2Id, status, installDate, purchaseDate, null);
                        
                        //If billing records is going to associate with this peripheral DI, delete the value of Core DI field 
                        if(extObj.Core_DI__c != null){
                            assetObj.Core_DI__c = null;
                        }
                        assetToUpsertMap.put(sa.Account__c+''+product2Map.get(sa.Product2Id__c).DI_Index__c, assetObj);
                    }
                    else{
                        if(sa.Status__c.equals('Active') && extObj.InstallDate == null){
                            if(extObj.Purchase_Date__c != null && (extObj.Purchase_Date__c > sa.Start_Date__c)){
                                extObj.InstallDate = extObj.Purchase_Date__c;
                            }
                            else{
                                extObj.InstallDate = sa.Start_Date__c;
                            }
                        }
                        //Check if Purchase Date is null or not, if null, update to start date
                        if(sa.Status__c.equals('Active') && extObj.Purchase_Date__c == null){
                            extObj.Purchase_Date__c = sa.Start_Date__c;
                        }
                        //If billing records is going to associate with this peripheral DI, delete the value of Core DI field
                        if(extObj.Core_DI__c != null){
                            extObj.Core_DI__c = null;
                        }
                        assetToUpsertMap.put(sa.Account__c+''+product2Map.get(sa.Product2Id__c).DI_Index__c, extObj);
                    }
                }
                else{
                    //Create new Deployment Instance record
                    String status = null;
                    Date installDate = null;
                    //If SA status is inactive, create inactive DI
                    if(sa.Softrax_Status__c == 'I'){
                        status = 'Inactive';
                    }
                    else if(product2Map.get(sa.Product2Id__c).DI_DefaultStatus__c == 'Installed'){
                        status = 'Installed';
                        installDate = sa.Start_Date__c; 
                    }
                    
                    
                    Asset assetObj = NI_SoftraxAsset_TriggerHandler.createUpdateAsset(null, sa.Name, sa.Account__c, sa.Product2Id__c, status, installDate, sa.Start_Date__c, null);
                    
                    if(assetToUpsertMap.containsKey(sa.Account__c+''+product2Map.get(sa.Product2Id__c).DI_Index__c)){
                        if(oldRecordPriorityMap.get(sa.Account__c+''+product2Map.get(sa.Product2Id__c).DI_Index__c) >= product2Map.get(assetObj.Product2Id).DI_Priority__c){
                            oldRecordPriorityMap.remove(sa.Account__c+''+product2Map.get(sa.Product2Id__c).DI_Index__c);
                            oldRecordPriorityMap.put(sa.Account__c+''+product2Map.get(sa.Product2Id__c).DI_Index__c, product2Map.get(assetObj.Product2Id).DI_Priority__c);
                            assetToUpsertMap.remove(sa.Account__c+''+product2Map.get(sa.Product2Id__c).DI_Index__c);
                            assetToUpsertMap.put(sa.Account__c+''+product2Map.get(sa.Product2Id__c).DI_Index__c, assetObj);
                        }
                    }
                    else{
                        assetToUpsertMap.put(sa.Account__c+''+product2Map.get(sa.Product2Id__c).DI_Index__c, assetObj);
                        oldRecordPriorityMap.put(sa.Account__c+''+product2Map.get(sa.Product2Id__c).DI_Index__c, product2Map.get(assetObj.Product2Id).DI_Priority__c);
                    }
                    
                }//END ELSE
            }//END FOR
        }//END IF
        
        //clear unused variables
        assetMap.clear();
        //Check if newAssetList is empty or not
        if(!assetToUpsertMap.values().isEmpty()){
            //Upsert Deployment Instance records
            Schema.SObjectField fld = Asset.Id;
            Database.UpsertResult[] upsertResultList = Database.upsert(assetToUpsertMap.values(), fld, false);
            Integer cnt = 0;
        }
        
        
        for(Integer i=0; i<saList.size(); i++){            
            if(assetToUpsertMap.containsKey(saList[i].Account__c+''+product2Map.get(saList[i].Product2Id__c).DI_Index__c)){
                saList[i].Deployment_Instance__c = assetToUpsertMap.get(saList[i].Account__c+''+product2Map.get(saList[i].Product2Id__c).DI_Index__c).Id;
            }
            else if(existingAssetMap.containsKey(saList[i].Account__c+''+product2Map.get(saList[i].Product2Id__c).DI_Index__c)){
                saList[i].Deployment_Instance__c = existingAssetMap.get(saList[i].Account__c+''+product2Map.get(saList[i].Product2Id__c).DI_Index__c).Id;
            } 
        }        
    }
    
    public static Asset createUpdateAsset(Id diId, String diName, Id diAccountId, Id diProductId, String status, Date installDate, Date purchaseDate, Decimal quantityOrdered){
        //Create new Deployment Instance record
        Asset assetObj;
        if(diId == null){
            assetObj = new Asset();
        }
        else{
            assetObj = new Asset(Id = diId);
        }
        if(diName != null)
        assetObj.Name = diName;
        
        if(diAccountId != null) 
        assetObj.AccountId = diAccountId;
         
        if(diProductId != null)
        assetObj.Product2Id = diProductId;
        
        if(status != null) 
        assetObj.Status = status;
        
        //If installDate is null, don't update it
        if(installDate != null)
        assetObj.InstallDate = installDate;
        
        //If Quantity Billed is null, don't update the value
        //if(quantityBilled != null)
        //assetObj.Quantity_Billed__c = quantityBilled;
        
        //if PurchaseDate is not null, update with new value
        if(purchaseDate != null)
        assetObj.Purchase_Date__c = purchaseDate;
        
        //If endDate is not null, update with new value
        //if(endDate != null)
        //assetObj.Usage_End_Date__c = endDate;
        
        //If quantityOrdered is not null, update it with new value
        if(quantityOrdered != null)
        assetObj.Quantity_Ordered__c = quantityOrdered;
        
        return assetObj;
    }
    
    // THIS FUNCTION FIRES WHEN --INSERTS-- HAPPEN ON SOFTRAX_ASSET__C RECORDS.
    // CHECKS Asset FOR EXISTING RELATED RECORD. 
    //     IF FOUND CREATES LINKING RECORD IN DI_to_Softrax_Asset__c JUNCTION OBJECT
    //     IF --NOT-- FOUND CREATES AN Asset RECORD --AND-- LINKING RECORD IN DI_to_Softrax_Asset__c JUNCTION OBJECT
    // THE Asset RECORD'S ATTRIBUTES ARE SET BASED ON WHAT IS QUERIED FROM PRODUCT WHICH IS FOUND BY PRODUCTCODE "Name" ON Softrax_Asset__c RECORD BEING INSERTED
    //         
    // DUE TO THE INABILITY TO CREATE ROLLUP SUMMARIES on Asset THROUGH THE DI_to_Softrax_Asset__c JUNCTION OBJECT to Softrax_Asset__c 
    // WE HAVE TO QUERY ALL Softrax_Asset__c RECORDS RELATED TO Asset RECORD AND MANUALLY: 
    //     SUM QUANTITIES, FIND MIN START DATES, FIND MAX END DATES ... THEN 
    // UPDATE THE Asset RECORD'S Quantity_Billed__c, Purchase_Date__c, Usage_End_Date__c FIELDS WITH COLLECTED VALUES    
  /*  public void syncBillingRecords(List<Softrax_Asset__c> nTrig)        
    {

//for (Asset diTester : [SELECT Id, AccountId, Product2Id, DI_Index_Name__c, Product2.DI_Index__c, Status, Product2.DI_Priority__c FROM Asset])
//{
//   system.debug(' ?#?#?#??#?#?#    diTester = ' + diTester);
//}
        
        // SET OF ACCOUNT IDS TO TARGET RELATED DI RECORDS
        Set<Id> setAccountIds = new Set<Id>();
        
        // SET OF PRODUCT CODES TO TARGET RELATED PRODUCT RECORDS
        Set<String> setProductCodes = new Set<String>();
        
        // DUPE CHECKER SET
        Set<String> setAccounts2DIIndexes = new Set<String>();
        
        // LOOP THROUGH TRIGGER AND POPULATE SET AND LIST WITH CUSTOM OBJECT (INNER CLASS) RECORDS 
        List<objSoftraxAssetProduct> lstSoftraxAssetProducts = new List<objSoftraxAssetProduct>();  
        
        for (Softrax_Asset__c sf : nTrig)
        {
            setAccountIds.Add(sf.Account__c);
            setProductCodes.Add(sf.Name);
            // def: new objSoftraxAssetProduct(SoftraxAssetId, SoftraxAccountId, SoftraxProductId, SoftraxProductCode, DeploymentInstanceId, DeploymentInstanceIndexId, 
            // DeploymentInstanceProductId, forInsert, SoftraxProductDefaultStatus, DeploymentInstanceProductPriority, SoftraxPriority, SoftraxStatus, DeploymentInstanceStatus)
            lstSoftraxAssetProducts.Add(new objSoftraxAssetProduct(sf.Id, sf.Account__c, null, sf.Name, null, null, null, false, 'Installed', 0, 0, sf.Softrax_Status__c, null)); 
        }

        // FILL IN PRODUCT2 INFO =======================================================================
        // LOOP THOUGH LIST WITH CUSTOM OBJECT RECORDS FILLING IN Product2Id & DeploymentInstanceIndexId
        for (Product2 p : [SELECT Id, ProductCode, DI_Index__c, DI_DefaultStatus__c, DI_Priority__c FROM Product2 WHERE ProductCode IN : setProductCodes])
        {
            for (objSoftraxAssetProduct oSAP1 : lstSoftraxAssetProducts)
            {
                if (p.ProductCode == oSAP1.SoftraxProductCode)
                {                 
                    oSAP1.forInsert = false;
                    if (!setAccounts2DIIndexes.contains(string.valueOf(oSAP1.SoftraxAccountId) + string.valueOf(p.DI_Index__c)))
                    {
                        setAccounts2DIIndexes.Add(string.valueOf(oSAP1.SoftraxAccountId) + string.valueOf(p.DI_Index__c));                    
                        oSAP1.forInsert = true;
                    }
                    oSAP1.SoftraxProductId = p.Id;
                    oSAP1.DeploymentInstanceIndexId = p.DI_Index__c; 
                    oSAP1.SoftraxPriority = Integer.valueOf(p.DI_Priority__c);
                    // NULL CHECKING ROUTINE
                    if (p.DI_DefaultStatus__c != 'Installed')
                    {
                        oSAP1.SoftraxProductDefaultStatus = 'Purchased';
                    }                    
                }
            }
        }

for (objSoftraxAssetProduct diOSAP1 : lstSoftraxAssetProducts)
{
    system.debug(' ...::: oSAP1 = ' + diOSAP1);     
}        
system.debug(' ================================================================ ');
system.debug('setAccountIds = ' + setAccountIds);  
        
        // FILL IN DEPLOYMENT INSTANCE INFO =============================================================================
        // LOOP THOUGH LIST WITH CUSTOM OBJECT RECORDS FILLING IN Asset Ids BASED ON ACCOUNT ID & DI INDEX ID COMBINATION
        //     IF NOT ASSIGNED A DeploymentInstanceId, NO DI EXISTS FOR IT
        for (Asset di : [SELECT Id, AccountId, Product2Id, DI_Index_Name__c, Product2.DI_Index__c, Status, Product2.DI_Priority__c FROM Asset WHERE AccountId IN : setAccountIds])
        {
system.debug(' di = ' + di);            
            for (objSoftraxAssetProduct oSAP2 : lstSoftraxAssetProducts)
            {
                if ((di.AccountId == oSAP2.SoftraxAccountId) && (di.Product2.DI_Index__c == oSAP2.DeploymentInstanceIndexId))
                {                 
                    oSAP2.DeploymentInstanceId = di.Id;
                    oSAP2.DeploymentInstanceProductId = di.Product2Id;
                    oSAP2.DeploymentInstanceProductPriority = Integer.valueOf(di.Product2.DI_Priority__c);
                    oSAP2.DeploymentInstanceStatus = di.Status;
                    oSAP2.forInsert = false;
                }
            }
        }

for (objSoftraxAssetProduct diOSAP2 : lstSoftraxAssetProducts)
{
    system.debug(' ...::: oSAP2 = ' + diOSAP2);     
}
system.debug(' ================================================================ ');
        
        // SET OF ACCOUNT IDS TO TARGET RELATED DI RECORDS
        List<Asset> lstDIUpdate = new List<Asset>();
        
        // LOOP THOUGH LIST WITH CUSTOM OBJECT RECORDS 
        // WHEN A RECORD HAS DeploymentInstanceId, ADD A DI_to_Softrax_Asset__c RECORD TO INSERT LIST
        // WHEN A RECORD HAS NO DeploymentInstanceId, ADD AN DI to the RECORD TO THE INSERT LIST
        List<DI_to_Softrax_Asset__c> lstDItoSoftraxAssetInsert = new List<DI_to_Softrax_Asset__c>();
        List<Asset> lstDIInsert = new List<Asset>();
        Set<Id> setNewDIAccountIds = new Set<Id>();
        
        for (objSoftraxAssetProduct oSAP3 : lstSoftraxAssetProducts)
        {
            if (oSAP3.forInsert)
            {
                setNewDIAccountIds.add(oSAP3.SoftraxAccountId);
                Asset objDI = new Asset(); 
                objDI.Name = oSAP3.SoftraxProductCode; 
                objDI.AccountId = oSAP3.SoftraxAccountId; 
                objDI.Product2Id = oSAP3.SoftraxProductId; 
                objDI.Status = oSAP3.SoftraxProductDefaultStatus;
                lstDIInsert.Add(objDI);                    
            }
        }

for (objSoftraxAssetProduct diOSAP3 : lstSoftraxAssetProducts)
{
    system.debug(' ...::: oSAP3 = ' + diOSAP3);     
}        
system.debug(' ================================================================ ');
system.debug(' EXECUTING DI INSERT ');
system.debug(' lstDIInsert = ' + lstDIInsert);       
        
        // INSERT THE MISSING Asset RECORDS
        database.insert(lstDIInsert, true); 

for (Asset diTester : [SELECT Id, AccountId, Product2Id, DI_Index_Name__c, Product2.DI_Index__c, Status, Product2.DI_Priority__c FROM Asset WHERE AccountId IN : setAccountIds])
{
   system.debug(' ?#?#?#??#?#?#    diTester = ' + diTester);
}
        
        // LOOP THOUGH ALL DIs ON ACCOUNT WITH NEWLY INSERTED DIs AND UPDATE THE DATASET WITH NEWLY CREATED DI INFORMATION 
        //     
        for (Asset di2 : [SELECT Id, AccountId, Product2Id, Product2.DI_Index__c, Status, Product2.DI_Priority__c FROM Asset WHERE AccountId IN : setNewDIAccountIds])
        {
//system.debug(' ...::: di2 = ' + di2);             
            for (objSoftraxAssetProduct oSAP4 : lstSoftraxAssetProducts)
            {
//system.debug(' ...::: di2.Product2.DI_Index__c = ' + di2.Product2.DI_Index__c + ', oSAP4.DeploymentInstanceIndexId = ' + oSAP4.DeploymentInstanceIndexId);                 
                if ((di2.AccountId == oSAP4.SoftraxAccountId) && (di2.Product2.DI_Index__c == oSAP4.DeploymentInstanceIndexId))
                {
                    oSAP4.DeploymentInstanceId = di2.Id;
                    oSAP4.DeploymentInstanceProductId = di2.Product2Id; 
                    oSAP4.DeploymentInstanceProductPriority = Integer.valueOf(di2.Product2.DI_Priority__c);
                    oSAP4.DeploymentInstanceStatus = di2.Status;
//system.debug(' ...::: oSAP4 = ' + oSAP4);                      
                }
            }
        }
        
for (objSoftraxAssetProduct diOSAP4 : lstSoftraxAssetProducts)
{
    system.debug(' ...::: oSAP4 = ' + diOSAP4);     
}        
        
        // LOOP THROUGH TO CREATE LINK RECORDS
        for (objSoftraxAssetProduct oSAP5 : lstSoftraxAssetProducts)
        {
            DI_to_Softrax_Asset__c objDtSA = new DI_to_Softrax_Asset__c();
            objDtSA.Deployment_Instance__c = oSAP5.DeploymentInstanceId;
            objDtSA.Softrax_Asset__c = oSAP5.SoftraxAssetId; 
            lstDItoSoftraxAssetInsert.Add(objDtSA);             
        }   
        
        
system.debug(' ...::: lstDItoSoftraxAssetInsert.size() = ' + lstDItoSoftraxAssetInsert.size()); 
        
for (objSoftraxAssetProduct diOSAP5 : lstSoftraxAssetProducts)
{
    system.debug(' ...::: oSAP5 = ' + diOSAP5);     
}
        
system.debug(' ...::: Attempting insert of junction record '); 
        // INSERT ALL DI_to_Softrax_Asset__c RECORDS
        
            database.insert(lstDItoSoftraxAssetInsert); 
            
        
        // For PRIORITY ASSIGNMENT (FUTURE)
        Map<Id, objSoftraxAssetProduct> mapDI2NewProductId = new Map<Id, objSoftraxAssetProduct>();
        //Set<Id> setDIUpdateIds = new Set<Id>();
                
        for (objSoftraxAssetProduct oSAP6 : lstSoftraxAssetProducts)
        {
            // GATHER A SET OF DI IDs WHERE THE PRIORITY EVALUATION DETERMINES THE PRODUCT2ID UPDATE
            if ((oSAP6.SoftraxProductId != oSAP6.DeploymentInstanceProductId) && (oSAP6.SoftraxPriority >= oSAP6.DeploymentInstanceProductPriority) && (oSAP6.SoftraxStatus == 'A'))
            {
                if (mapDI2NewProductId.containsKey(oSAP6.DeploymentInstanceId))
                {
                    if (oSAP6.DeploymentInstanceProductPriority >= mapDI2NewProductId.get(oSAP6.DeploymentInstanceId).DeploymentInstanceProductPriority)
                    {
                        mapDI2NewProductId.remove(oSAP6.DeploymentInstanceId);
                        mapDI2NewProductId.put(oSAP6.DeploymentInstanceId, oSAP6);  
                    }
                }
                else
                { 
                    mapDI2NewProductId.put(oSAP6.DeploymentInstanceId, oSAP6);                             
                }
            }             
        } 
        
        
        
        // UPDATE PRODUCT IDS ON DI RECORDS BASE ON PRIOR PROIRTY LOGIC FILTERING ABOVE        
        for (Asset diUps : [SELECT Id, Product2Id FROM Asset WHERE Id IN : mapDI2NewProductId.keySet()])
        {
            if (mapDI2NewProductId.containsKey(diUps.Id))
            {
                diUps.Product2Id = mapDI2NewProductId.get(diUps.Id).SoftraxProductId;
                lstDIUpdate.add(diUps); 
            }
        }
       
        // UPDATE Asset RECORDS WITH NEW PRODUCT2IDs
        database.update(lstDIUpdate, false); 
        
        if (NI_TriggerManager.isFirstSoftraxBillingInsert)
        {
            updateDIStatuses(lstSoftraxAssetProducts); 
        }    
        
        NI_TriggerManager.isFirstSoftraxBillingInsert = false;
        
        // CALL THIS FUNCTION TO ROLLUP VALUES TO Asset
        updateDIs(nTrig, false);
        
    }    

    
    private void updateDIStatuses(List<objSoftraxAssetProduct> lstSAPs)
    {
        
        List<Asset> lstDIStatusUpdates = new List<Asset>();
        Set<Id> setDI_Ids = new Set<Id>(); 
        Map<Id, String> mapId2Status = new Map<Id, String>();
        
        for (objSoftraxAssetProduct o : lstSAPs)
        {            
            if ((o.DeploymentInstanceStatus != 'Installed') && (o.SoftraxProductDefaultStatus != null))
            {            
                setDI_Ids.add(o.DeploymentInstanceId);
                if (mapId2Status.containsKey(o.DeploymentInstanceId))
                {
                    if (mapId2Status.get(o.DeploymentInstanceId) != 'Installed')
                    {
                        mapId2Status.remove(o.DeploymentInstanceId);
                        mapId2Status.Put(o.DeploymentInstanceId, o.SoftraxProductDefaultStatus);
                    }
                }
                else
                {
                    mapId2Status.Put(o.DeploymentInstanceId, o.SoftraxProductDefaultStatus);
                }            
            }
        }
        
        for (Asset di : [SELECT Id, Status FROM Asset WHERE Id IN : setDI_Ids])
        {
            di.Status = mapId2Status.get(di.Id);
            lstDIStatusUpdates.Add(di);       
        }         
        
        Database.update(lstDIStatusUpdates);
        
    }
    */
    
    /*private void updateProductIds(List<Softrax_Asset__c> nTrig)
    {
        
        Set<String> setProductCodes = new Set<String>();
                
        for (Softrax_Asset__c sf : nTrig)
        {
            setProductCodes.Add(sf.Name);
        }            
        
        for (Product2 p : [SELECT Id, ProductCode FROM Product2 WHERE ProductCode IN : setProductCodes])
        {
            for (Softrax_Asset__c sa : nTrig)
            {
                if (p.ProductCode == sa.Name)
                {
                    sa.Product2Id__c = p.Id;
                }
            }            
        }
        
    }
    
    // ============================================================
    //  INNER CLASS OBJECTS 
    // ============================================================
    /* public class objSoftraxAssetProduct
    {
        public Id SoftraxAssetId { get; set; }
        public Id SoftraxAccountId { get; set; }
        public Id SoftraxProductId { get; set; }
        public String SoftraxProductCode { get; set; }
        public Id DeploymentInstanceId { get; set; }
        public Id DeploymentInstanceIndexId { get; set; }
        public Id DeploymentInstanceProductId { get; set; } 
        public boolean forInsert { get; set; }  
        public string SoftraxProductDefaultStatus { get; set; }  
        public integer DeploymentInstanceProductPriority { get; set; }  
        public integer SoftraxPriority { get; set; } 
        public string SoftraxStatus { get; set; } 
        public string DeploymentInstanceStatus { get; set; } 
        
        public objSoftraxAssetProduct(Id SoftraxAssetId, 
                                      Id SoftraxAccountId, 
                                      Id SoftraxProductId, 
                                      String SoftraxProductCode, 
                                      Id DeploymentInstanceId, 
                                      Id DeploymentInstanceIndexId, 
                                      Id DeploymentInstanceProductId, 
                                      boolean forInsert,
                                      string SoftraxProductDefaultStatus,
                                      integer DeploymentInstanceProductPriority,
                                      integer SoftraxPriority,
                                      string SoftraxStatus,
                                      string DeploymentInstanceStatus 
                                     ) 
        {
            this.SoftraxAssetId = SoftraxAssetId;
            this.SoftraxAccountId = SoftraxAccountId;
            this.SoftraxProductId = SoftraxProductId;
            this.SoftraxProductCode = SoftraxProductCode;
            this.DeploymentInstanceId = DeploymentInstanceId;
            this.DeploymentInstanceIndexId = DeploymentInstanceIndexId;
            this.DeploymentInstanceProductId = DeploymentInstanceProductId;
            this.forInsert = forInsert;
            this.SoftraxProductDefaultStatus = SoftraxProductDefaultStatus;
            this.DeploymentInstanceProductPriority = DeploymentInstanceProductPriority;
            this.SoftraxPriority = SoftraxPriority;
            this.SoftraxStatus = SoftraxStatus; 
            this.DeploymentInstanceStatus = DeploymentInstanceStatus;
        }
        
    }    

    public class objAssetRollups
    {
        public Id DeploymentInstanceId { get; set; }
        public Id SoftraxAssetId { get; set; }
        public String ProductCode { get; set; }        
        public Decimal dQuantity { get; set; } 
        public Date dtStartDate { get; set; } 
        public boolean isActive { get; set; }  
        
        public objAssetRollups (
            Id DeploymentInstanceId, 
            Id SoftraxAssetId, 
            String ProductCode,         
            Decimal dQuantity, 
            Date dtStartDate, 
            boolean isActive
        ) 
        {
            this.DeploymentInstanceId = DeploymentInstanceId;
            this.SoftraxAssetId = SoftraxAssetId;
            this.ProductCode = ProductCode;
            this.dQuantity = dQuantity;
            this.dtStartDate = dtStartDate;
            this.isActive = isActive;
        }
        
    }   */
    /**
    Author: Sunita Mittal
    Created On: 01/04/2016
    Descrition: Update the "Billing Status" Field On Account
    **/
       
    /*public void updateBillingStatus(Set<Id> accIdList)
    {                
        Map<Id,Integer> accntIdTosftRaxCntMap = new Map<Id,Integer>();
        integer cntSftRax,cntOfActiveDI;
        //Calculate the count of Softrax Assets realed to each Account and Active DI's related to each Account
        for(List<Softrax_Asset__c> sftraxList : [SELECT Id,Account__c FROM Softrax_Asset__c WHERE Account__c IN : accIdList])        
        {
             for(Softrax_Asset__c sftrax : sftraxList)
            {
                if(accntIdTosftRaxCntMap.containsKey(sftrax.Account__c))
                {
                    cntSftRax = accntIdTosftRaxCntMap.get(sftrax.Account__c);                
                }
                else
                {
                    cntSftRax = 0;                 
                }            
                    cntSftRax += 1;                
                    accntIdTosftRaxCntMap.put(sftrax.Account__c,cntSftRax);                                       
            }   
        }        
        
        List<Account> accList = new List<Account>();       
        Map<Id,Account> accMap;
        //Check if Account does not have any Softrax Assets's related.
        if(accIdList.size() > accntIdTosftRaxCntMap.keySet().size())
        {
            accMap = new Map<Id,Account>([Select Id, (SELECT Id FROM Assets WHERE status = 'Installed' OR Status = 'Purchased') FROM Account WHERE Id IN : accIdList]);
        }
        //Update Billing Status On Account
        for(Id accId : accIdList)
        {
            if(accId == null){
                continue;
            }
            if(accntIdTosftRaxCntMap.containsKey(accId))
            {
                Account acc = new Account();
                acc.Id = accId;
                if(accntIdTosftRaxCntMap.get(accId) > 0)
                   acc.Billing_Status__c = 'Billable';               
                accList.add(acc);
            }
            else
            {
                Account acc = new Account();
                acc.Id = accId;
                Account a = accMap.get(accId);
                if(a.Assets.size() > 0)
                    acc.Billing_Status__c = 'Consumer';
                else
                    acc.Billing_Status__c = '';
                accList.add(acc);        
            }
        }
        update accList;
    }*/
    
    /*---------------------
    * @ Author: Prashant Wayal
    * @ Added On: 03/02/2016
    * @ Description: Update the Status field On DI to "Installed" If Softrax Asset is Active
    -----------------------*/
    /*public void updateDIStatus(Set<id> assetIds)
    {        
        for(List<Asset> DIList : [SELECT Status FROM Asset Where Id IN : assetIds AND Status != 'Installed'])
        {            
            for(Asset DI : DIList)
            {   
                DI.Status = 'Installed';
            }
            if(!DIList.isEmpty())
                Database.Update(DIList);
        }       
    }
    //Update the "IsHostedDI" on Child DIs if SA Product != Parent Product
    public void updateHostedOnDI(List<Softrax_Asset__c> saList)
    {        
        Set<Id> assetIds = new Set<Id>();        
        for(Softrax_Asset__c sa : saList)
        {
            if(sa.Product2Id__c != sa.Deployment_Instance__r.Parent_DI__r.Product2Id)
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
}*/