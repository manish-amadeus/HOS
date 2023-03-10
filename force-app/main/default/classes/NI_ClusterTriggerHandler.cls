/************************************************************************************************
Name            : NI_ClusterTriggerHandler Class
Author          : Sunita Mittal
Created Date    : 12/07/2015
Last Mod Date   : 01/04/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-016293
Description     : Handles the Logic for the Cluster Triggers
                : NICC-032132: Added code to allow members of a public group to perform certain
				: tasks.
*************************************************************************************************/
public class NI_ClusterTriggerHandler 
{
    
    public static List<Asset> assetToUpdateStatus; 
    private boolean bHasPermission;
    private string profileName;
    
    public NI_ClusterTriggerHandler()
    {
        
        bHasPermission = false;
        Id profileId = userInfo.getProfileId();
        profileName = [SELECT Id, Name FROM Profile WHERE Id =: profileId LIMIT 1].Name;        
        
        // RUNNING USER BELONGS TO PUBLIC GROUP
        if (NI_FUNCTIONS.hasAccessByPublicGroup(UserInfo.getUserId(), 'MPE Cluster Managers'))
        {
            bHasPermission = true;
        }
        
        // RUNNING USER HAS System Administrator OR NI Contracts PROFILE
        if ((profileName.equals('System Administrator')) || (profileName.equals('NI Contracts')))
        {
            bHasPermission = true;
        }
        
        assetToUpdateStatus = new List<Asset>();
        
    }
    
    public void onBeforeInsert(List<Cluster__c> newListTrigger)
    { 
        
        system.debug('__ ENTERING NI_ClusterTriggerHandler.onBeforeInsert()'); 
        
        // TARGET NEWLY INSERTED CLUSTER RECORDS THAT HAVE Product_Line_Global__c POPULATED
        List<Cluster__c> updateDIIndexList = new List<Cluster__c>();        
        for (Cluster__c clus : newListTrigger)
        {
            if (clus.Product_Line_Global__c != null)
            {
                updateDIIndexList.add(clus);
            }           
        }
        
        // CALL THE METHOD THAT UPDATES THE DI_Index__c FIELD ON CLUSTER
        if (!updateDIIndexList.isEmpty())
        {                        
            updateClusterObj(updateDIIndexList, newListTrigger);                               
        }     
        
    }
    
    public void onBeforeUpdate(List<Cluster__c> newListTrigger, Map<Id, Cluster__c> oldMapTrigger)
    {
        
        system.debug('__ ENTERING NI_ClusterTriggerHandler.onBeforeUpdate()'); 
        
        List<Cluster__c> updateDIIndexList = new List<Cluster__c>();
        Set<Id> accIds = new Set<Id>();               
        List<Cluster__c> createDIList = new List<Cluster__c>();
        Map<String, List<Cluster__c>> accIdToClusMap = new Map<String, List<Cluster__c>>();
        
        // added by Ria-5/5/2017 (START)
        // To get profile name of user updating field on MPE Cluster record
//        Id profileId = userInfo.getProfileId();
//        String profileName = [SELECT Id, Name FROM Profile WHERE Id =: profileId LIMIT 1].Name;
        
        for (Cluster__c clus : newListTrigger)
        {                 
            Cluster__c old_clus = (Cluster__c)oldMapTrigger.get(clus.Id);
            
            // Check whether Product_Line_Global__c is updated
            if (((clus.Product_Line_Global__c != null) && (clus.Product_Line_Global__c != old_clus.Product_Line_Global__c)) || (clus.DI_Index__c == null))
            {
                if (old_clus.Product_Line_Global__c != null && profileName.equals('System Administrator'))
                {
                    updateDIIndexList.add(clus);
                }
                else 
                {
                    if (old_clus.Product_Line_Global__c == null && bHasPermission)
                    {
                        updateDIIndexList.add(clus);
                    }
                    else
                    {
                        clus.Product_Line_Global__c.addError('Insufficient privileges (Line 99). The Product Line cannot be updated. You need to be System Administrator or belong to the MPE Cluster Managers public group');
                    }
                }
            }
            
            // Check whether DI Index is updated
            if ((clus.DI_Index__c != null) && (clus.DI_Index__c != old_clus.DI_Index__c))
            {
                // Check previous value is not equal to null and Profile is not System Administrator
                if (old_clus.DI_Index__c != null && profileName != 'System Administrator')
                {
                    clus.DI_Index__c.addError('Insufficient privileges (Line 110). The DI Index cannot be updated. You need to be System Administrator.');
                }
                
                //if previous value was null->check profile.
                if (old_clus.DI_Index__c == null)
                {
                    if (!bHasPermission)
                    {
                        clus.DI_Index__c.addError('Insufficient privileges (Line 118). The DI Index cannot be updated. You need to be System Administrator or belong to the MPE Cluster Managers public group');
                    }
                }
                
            }
            
            // Check if any of the fields is updated by any of the three profiles. If not display error.
            if ((clus.Hosted__c != null && clus.Hosted__c != old_clus.Hosted__c) ||
                (clus.Version_New__c != null && clus.Version_New__c != old_clus.Version_New__c) ||
                (clus.Purchased_Version__c != null && clus.Purchased_Version__c != old_clus.Purchased_Version__c) ||
                (clus.Management_Company__c != null && clus.Management_Company__c != old_clus.Management_Company__c))
            {
                if (!bHasPermission)
                {
                    clus.addError('Insufficient privileges (Line 132). Field cannot be updated. You need to be System Administrator or belong to the MPE Cluster Managers public group');
                }  
            }           
            
            // added by Ria-5/5/2017 (END)
            
            // CHECK IF THE MANAGEMENT COMPANY IS REMOVED FROM CLUSTER                                    
            if (clus.Management_Company__c == null && old_Clus.Management_Company__c != null)
            {           
                if (accIdToClusMap.containsKey(old_Clus.Management_Company__c))
                {
                    accIdToClusMap.get(String.valueOf(old_Clus.Management_Company__c)).add(clus);   
                }                     
                else
                {
                    accIdToClusMap.put(String.valueOf(old_Clus.Management_Company__c), new List<Cluster__c>{clus}); 
                }                             
            }
            
            // CHECK IF THE MANAGEMENT COMPANY IS UPDATED AND NOT NULL 
            if ((clus.Management_Company__c != null && old_Clus.Management_Company__c != clus.Management_Company__c && clus.Product_Line_Global__c == old_clus.Product_Line_Global__c && clus.Cluster_Status__c == 'Installed') || 
                (old_clus.Cluster_Status__c != clus.Cluster_Status__c && clus.Cluster_Status__c == 'Installed'))
            {
                accIds.add(clus.Management_Company__c);                           
            }                       
            
        }   
        
        // CALL THE METHOD THAT UPDATE THE DI_Index__c FIELD ON CLUSTER      
        if (!updateDIIndexList.isEmpty())
        {                         
            updateClusterObj(updateDIIndexList,newListTrigger);                                 
        } 
        
        // CALL METHOD THAT REMOVES MANAGEMENT COMPANY'S CURRENT CLUSTER
        if (!accIdToClusMap.isEmpty())
        {
            removeClusterOnAccount(accIdToClusMap);
        }
        
        // CALL THE METHOD THAT VALIDATE THE MANAGEMENT COMPANY SELETED
        if (!accIds.isEmpty())
        {            
            checkDIExistsOnMangCompy(newListTrigger,accIds);
        }     
        
        if (!assetToUpdateStatus.isEmpty())
        {
            database.update(assetToUpdateStatus);
        }
        
    }
    
    public void OnAfterInsert(Map<Id, Cluster__c> newMapTrigger)
    {
        
        system.debug('__ ENTERING NI_ClusterTriggerHandler.OnAfterInsert()');  
        
        Set<Id> newAccIds = new Set<Id>();
        Map<Id, List<Cluster__c>> oldAccIds = new Map<Id, List<Cluster__c>>();
        List<Cluster__c> createDIList = new List<Cluster__c>();
        
        for (SObject clus : newMapTrigger.values())
        {
            
            Cluster__c new_clus = (Cluster__c)clus;
            
            system.debug('____ new_clus' + new_clus);
            
            // CHECK IF MANAGEMENT COMPANY IS NOT NULL AND UPDATE THE RELATED DI
            if (new_clus.Management_Company__c != null && new_clus.Cluster_Status__c == 'Installed')                                   
            {
                createDIList.add(new_clus);
                newAccIds.add(new_clus.Management_Company__c);                               
            } 
            
        }
        
        // CALL METHOD THAT CREATES NEW DI AND UPDATE "CURRENT CLUSTER" FOELD ON MANAGEMNET COMPANY ACCOUNT
        if (!createDIList.isEmpty())
        {
            linkToDI(createDIList, newAccIds, oldAccIds);
        } 
        
    }
    
    public void OnAfterUpdate(Map<Id, Cluster__c> newMapTrigger, Map<Id, Cluster__c> oldMapTrigger)
    {            
        
        system.debug('__ ENTERING NI_ClusterTriggerHandler.OnAfterUpdate()');  
        
        Map<Id, Cluster__c> updateDIVerMap = new Map<Id, Cluster__c>();
        Set<Id> newAccIds = new Set<Id>();
        Map<Id, List<Cluster__c>> oldAccIds = new Map<Id, List<Cluster__c>>();
        List<Cluster__c> createDIList = new List<Cluster__c>();
        
        for (SObject clus : newMapTrigger.values())
        {
            
            Cluster__c new_clus = (Cluster__c)clus;
            Cluster__c old_clus = (Cluster__c)oldMapTrigger.get(new_clus.Id);
            
            // CHECK THAT VERSION OR HOSTED IS UPDATED                        
            if (new_clus.Version_New__c != old_clus.Version_New__c || new_clus.Hosted__c != old_clus.Hosted__c)
            {
                updateDIVerMap.put(new_clus.Id, new_clus);                
            }
            
            // CHECK IF MANAGEMENT COMPANY IS UPDATED
            if ((new_clus.Management_Company__c != null && old_clus.Management_Company__c != new_clus.Management_Company__c))                                   
            {                
                createDIList.add(new_clus);
                newAccIds.add(new_clus.Management_Company__c);
                
                if (old_clus.Management_Company__c != null)
                {
                    if (oldAccIds.containsKey(old_clus.Management_Company__c))
                    {
                        oldAccIds.get(old_clus.Management_Company__c).add(new_clus); 
                    }                                         
                    else
                    {
                        oldAccIds.put(old_clus.Management_Company__c, new List<Cluster__c>{new_clus}); 
                    }
                }                                   
            }                       
        }
        
        // CALL METHOD THAT UPDATES THE VERSION AND HOSTED DI ON RELATED DI        
        if (!updateDIVerMap.isEmpty())
        {
            updateDIObj(updateDIVerMap);          
        } 
        
        // CALL METHOD THAT UPDATES "CURRENT CLUSTER" FIELD ON MANAGEMNET COMPANY ACCOUNT
        if (!createDIList.isEmpty())
        {
            linkToDI(createDIList, newAccIds, oldAccIds);
        }  
        
    }

    // =====================================================================================================
    //   TRIGGER FUNCTIONS 
    // =====================================================================================================
    
    public void updateClusterObj(List<Cluster__c> clusList, List<Cluster__c> allclus)
    {

        // Added By: Sunita Mittal
        // Added On: 12/11/2015
        // Description: Method to Update the "DI Index" Lookup field on Cluster
        //              DI Index Should match the "Product Group" Name         
        
        system.debug('__ ENTERING NI_ClusterTriggerHandler.updateClusterObj()');  
        
        Map<String, String> productLines = new map<String, String>();
        Set<Id> accIds = new Set<Id>();     
        
        // GET ALL PRODUCT LINE PICKLIST VALUES
        Schema.DescribeFieldResult fieldResult = Cluster__c.Product_Line_Global__c.getDescribe();
        List<Schema.PicklistEntry> prodLinesPicklist = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry pl : prodLinesPicklist)
        {
            productLines.put(pl.getValue(), pl.getValue());
        } 
        
        system.debug('____ productLines = ' + productLines);
        
        Map<Id, NI_DeploymentInstanceIndex__c> diIndexMap = new Map<Id, NI_DeploymentInstanceIndex__c>([SELECT Id, Name FROM NI_DeploymentInstanceIndex__c WHERE Name IN : productLines.values()]);
        Map<String, String> di_prodGrpName = new Map<String, String>();                
        
        if (!diIndexMap.isEmpty())
        {
            for (NI_DeploymentInstanceIndex__c dindex : diIndexMap.values())
            {
                di_prodGrpName.put(dindex.Name, dindex.Id);
            }  
            
            system.debug('____ di_prodGrpName = ' + di_prodGrpName);     
            
            for (cluster__c c : allclus)
            { 
                c.DI_Index__c = di_prodGrpName.get(productLines.get(c.Product_Line_Global__c));
                if (c.Management_Company__c != null && c.Cluster_Status__c == 'Installed')
                {
                    accIds.add(c.Management_Company__c);
                }
                
            }
            
            // CALL THE METHOD THAT CHECKS THE MANAGEMENT COMPANY VALIDATION
            if (!accIds.isEmpty()) 
            {
                checkDIExistsOnMangCompy(allclus, accIds);
            }
            
        }
        
    }

    public void checkDIExistsOnMangCompy(List<Cluster__c> clusterList, Set<Id> accIds)
    {

        // Added On: 02/18/2016
        // Description: Verify that related DI exists on selected Management Company
            
        system.debug('__ ENTERING NI_ClusterTriggerHandler.checkDIExistsOnMangCompy()');  
        
        // GET ALL DIS RELATED TO MANAGEMENT COMPANY
        List<Asset> assetList = [SELECT Id, AccountId, AccountId_DIIndexID__c, Status FROM Asset WHERE AccountId IN : accIds AND Status != 'Inactive'];       
        map<string, asset> existingDIs = new map<string, asset>();
        
        for (Asset a : assetList)
        {
            existingDIs.put(a.AccountId_DIIndexID__c, a);            
        } 
        
        system.debug('____ existingDIs = ' + existingDIs); 
        
        for (Cluster__c c : clusterList)
        {
            
            // CHECK THAT DI EXISTS ON MANAGEMENT COMPANY IF NOT ADD ERROR MESSAGE
            if (!existingDIs.containskey(String.valueOf(c.Management_Company__c) + String.valueOf(c.DI_Index__c)))
            {
                c.Management_Company__c.addError('The Cluster’s Management Company must have an active Deployment Instance with a matching DI Index in order for the Cluster Status to be updated to Installed.');
            }
            else
            {
                if (c.Cluster_Status__c == 'Installed')
                {
                    asset assetUpdt = existingDIs.get(String.valueOf(c.Management_Company__c) + String.valueOf(c.DI_Index__c));
                    assetUpdt.status = 'Installed';
                    assetToUpdateStatus.add(assetUpdt);
                }
            }
        }
    }

    public void updateDIObj(Map<Id, Cluster__c> clusMap)
    {
        
        // Added By: Sunita Mittal
        // Added On: 12/10/2015
        // Description: Method to update the "Version" field on Deployment instances(Asset)
        //              When the Version is updated on Cluster, DI Version should be updated which relates to Account        
        
        system.debug('__ ENTERING NI_ClusterTriggerHandler.updateDIObj()');        
        system.debug('____ clusMap = ' + clusMap);
        
        // GET THE RECORDTYPES OF CLUSTER
        Map<Id, RecordType> recType = new Map<Id, RecordType>([SELECT DeveloperName FROM RecordType WHERE SobjectType = 'Cluster__c']); 
        
        List<Cluster__c> clusObj = [SELECT Id, Name, DI_Index__c, DI_Index__r.Name, Version_New__c, Purchased_Version__c, RecordTypeId, Management_Company__c, Hosted__c FROM Cluster__c WHERE Id IN : clusMap.keySet()];
        Map<String, Cluster__c> delphiClusMap = new Map<String, Cluster__c>();
        Map<String, Cluster__c> meetMatrixClusMap = new Map<String, Cluster__c>();                
        Map<Id, Id> clusIdMap = new Map<Id, Id>();          
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, current_MPE_Cluster__c, Current_MeetingMatrix_MPE_Cluster__c FROM Account WHERE current_MPE_Cluster__c IN : clusMap.keySet() OR Current_MeetingMatrix_MPE_Cluster__c IN : clusMap.keySet()]); 
        Map<Id, List<String>> clusterAccidsMap = new Map<Id, List<String>>();
        
        system.debug('____ accMap = ' + accMap);
        
        // GET THE ACCOUNTS RELATED TO CLUSTERS BUT MANAGEMENT COMPANY ON CLUSTER IS NULL
        for (Account a : accMap.values())
        {
            // DELPHI/DAYLIGHT CLUSTER
            if (a.current_MPE_Cluster__c != null)
            {
                if (clusterAccidsMap.containsKey(a.current_MPE_Cluster__c))
                {
                    clusterAccidsMap.get(a.current_MPE_Cluster__c).add(a.Id);
                }
                else
                {
                    clusterAccidsMap.Put(a.current_MPE_Cluster__c, new List<String>{a.id}); 
                }                               
            }
            
            // MEETINGMATRIX CLUSTER
            if (a.Current_MeetingMatrix_MPE_Cluster__c != null)
            {
                if (clusterAccidsMap.containsKey(a.Current_MeetingMatrix_MPE_Cluster__c))
                {
                    clusterAccidsMap.get(a.Current_MeetingMatrix_MPE_Cluster__c).add(a.Id);
                }
                else
                {
                    clusterAccidsMap.Put(a.Current_MeetingMatrix_MPE_Cluster__c, new List<String>{a.id}); 
                }                                    
            } 
            
        }
        
        for (Cluster__c c : clusObj)
        {
            
            if ('Delphi_Daylight' == recType.get(c.RecordTypeId).DeveloperName)
            {
                if (!clusterAccidsMap.isEmpty()) 
                { 
                    for(String s : clusterAccidsMap.get(c.Id)) 
                    { 
                        delphiClusMap.put(s + String.valueOf(c.DI_Index__c), c); 
                    }
                }
                
                delphiClusMap.put(String.valueOf(c.Management_Company__c) + String.valueOf(c.DI_Index__c), c);
                
            } 
            
            if ('MeetingMatrix_Cluster' == recType.get(c.RecordTypeId).DeveloperName)
            {
                if (!clusterAccidsMap.isEmpty()) 
                { 
                    for (String s : clusterAccidsMap.get(c.Id))
                    { 
                        meetMatrixClusMap.put(s + String.valueOf(c.DI_Index__c), c); 
                    }                     
                }
                
                meetMatrixClusMap.put(String.valueOf(c.Management_Company__c) + String.valueOf(c.DI_Index__c), c);
                
            }
            
            clusIdMap.put(c.Id, c.Id);
            
        } 
        
        system.debug('____ clusIdMap.keySet() = ' + clusIdMap.keySet() + ' -> delphiClusMap.keyset() = ' + delphiClusMap.keyset()); 
        system.debug('____ delphiClusMap.keyset() = ' + delphiClusMap.keyset() + ' -> meetMatrixClusMap.keyset() = ' + meetMatrixClusMap.keyset());
        system.debug('____ accMap.keySet() = ' + accMap.keySet());
        
        for (List<Asset> lstdepIns : [SELECT Version__c, AccountId, Name, Account.current_MPE_Cluster__c, AccountId_DIIndexID__c, 
                                      Account.Current_MeetingMatrix_MPE_Cluster__c, IsHostedDI__c 
                                      FROM Asset 
                                      WHERE ((Account.current_MPE_Cluster__r.Id IN : clusIdMap.keySet() 
                                              OR Account.Current_MeetingMatrix_MPE_Cluster__r.Id IN : clusIdMap.keySet()) 
                                             AND (AccountId_DIIndexID__c IN : delphiClusMap.keyset() 
                                                  OR AccountId_DIIndexID__c IN : meetMatrixClusMap.keyset() 
                                                  OR AccountId IN : accMap.keySet()) 
                                             AND (Status != 'Inactive'))]
            )
        {
            
            List<Asset> diList = new List<Asset>();
            
            for (Asset depIns : lstdepIns)
            {                    
                if (delphiClusMap.containsKey(depIns.AccountId_DIIndexID__c))
                {
                    if (depIns.Account.Current_MPE_Cluster__c == delphiClusMap.get(depIns.AccountId_DIIndexID__c).Id)
                    {
                        depIns.Version__c = delphiClusMap.get(depIns.AccountId_DIIndexID__c).Version_New__c;
                        depIns.IsHostedDI__c = delphiClusMap.get(depIns.AccountId_DIIndexID__c).Hosted__c;                             
                    }                                              
                }
                if (meetMatrixClusMap.containsKey(depIns.AccountId_DIIndexID__c))
                {
                    if (depIns.Account.Current_MeetingMatrix_MPE_Cluster__c == meetMatrixClusMap.get(depIns.AccountId_DIIndexID__c).Id)
                    {
                        depIns.Version__c = meetMatrixClusMap.get(depIns.AccountId_DIIndexID__c).Version_New__c;
                        depIns.IsHostedDI__c = meetMatrixClusMap.get(depIns.AccountId_DIIndexID__c).Hosted__c;                           
                    }                                                                                       
                }  
                diList.add(depIns);                                          
            }
            
            system.debug('____ diList = ' + diList);
            
            try
            {
                update diList;
            }
            catch(DMLException e) 
            {
                for (Cluster__c cust2 : (List<Cluster__c>)trigger.new) 
                {
                    cust2.addError('This Version is not related to the Cluster’s Product Line.  Please enter a valid Version.');
                }
            }
        }                                   
    }
    
    public void linkToDI(List<Cluster__c> clusList, Set<Id> newAccIds, Map<Id, List<Cluster__c>> oldAccIds)
    { 

        // Description: Create Deployment Instance for Management Company Account and Links the Cluster to Management Company Account
        // Added By: Swapnil
        // Added On: 01/25/2016
        
        system.debug('__ ENTERING NI_ClusterTriggerHandler.linkToDI()'); 
        
        Map<Id, Account> accToUpdate = new Map<Id, Account>();
        Map<String, Asset> accIdProdIdtoAssetMap = new Map<String, Asset>();
        
        // GET THE RECORDTYPES OF CLUSTER
        Map<Id, RecordType> recType = new Map<Id, RecordType>([SELECT DeveloperName FROM RecordType WHERE SobjectType = 'Cluster__c']);  
        
        for (Cluster__c clus : clusList)
        { 
            
            // UPDATE THE CURRENT MPE CLUSTER ON ACCOUNT TO 
            Account newAcc = new Account();          
            newAcc.Id = clus.Management_Company__c;
            
            if (accToUpdate.containsKey(clus.Management_Company__c))
            {
                Account acc = accToUpdate.get(clus.Management_Company__c);
                if ('Delphi_Daylight' == recType.get(clus.RecordTypeId).DeveloperName)
                {
                    acc.Current_MPE_Cluster__c = clus.Id;
                }
                
                else 
                {
                    if ('MeetingMatrix_Cluster' == recType.get(clus.RecordTypeId).DeveloperName) 
                    {
                        acc.Current_MeetingMatrix_MPE_Cluster__c = clus.Id;
                    }
                    
                }
                accToUpdate.put(clus.Management_Company__c, acc);
            }
            else
            {
                if ('Delphi_Daylight' == recType.get(clus.RecordTypeId).DeveloperName)
                {
                    newAcc.Current_MPE_Cluster__c = clus.Id;
                }
                else
                {
                    if ('MeetingMatrix_Cluster' == recType.get(clus.RecordTypeId).DeveloperName) 
                    {
                        newAcc.Current_MeetingMatrix_MPE_Cluster__c = clus.Id;   
                    }
                    
                }                
                accToUpdate.put(clus.Management_Company__c, newAcc);
            }
            
        } 
        
        // UPDATE THE OLD MANAGEMENT COMPANY ACCOUNT'S CURRENT CLUSTER TO NULL      
        for (Id c : oldAccIds.keySet())
        {                       
            Account oldAcc = new Account();
            List<cluster__c> clusterWithOldAccIds = oldAccIds.get(c);
            oldAcc.Id = c;
            
            for (Cluster__c clus : clusterWithOldAccIds)
            {
                if ('Delphi_Daylight' == recType.get(clus.RecordTypeId).DeveloperName)
                {
                    oldAcc.Current_MPE_Cluster__c = null;
                }
                else 
                {
                    if ('MeetingMatrix_Cluster' == recType.get(clus.RecordTypeId).DeveloperName) 
                    {
                        oldAcc.Current_MeetingMatrix_MPE_Cluster__c = null;
                    }
                }
                
            }            
            accToUpdate.put(c, oldAcc);                
        }
        
        if (!accToUpdate.isEmpty())
        {
            try
            {
                Database.update(accToUpdate.values());
            }
            catch(exception e)
            {
                for (Cluster__c cust2 : (List<Cluster__c>)trigger.new) 
                {
                    if (e.getMessage().indexof('Account does not have an active Deployment Instance') != -1)
                    {
                        cust2.Management_Company__c.addError('The Cluster’s Management Company must have an active Deployment Instance with a matching DI Index in order for the Cluster Status to be updated to Installed.');
                    }
                    else
                    {	
                        cust2.addError(e.getMessage());
                    }
                }
            }            
        } 
    }
    
    public void removeClusterOnAccount(Map<String, List<Cluster__c>> accIdToClusMap)
    {
        
        // Added By: Swapnil
        // Added On: 01/27/2016
        // Description: Create Cancellation Record for Deployment Instance related Management Company Account    
        
        system.debug('__ ENTERING NI_ClusterTriggerHandler.removeClusterOnAccount()'); 
        
        // GET THE RECORDTYPES OF CLUSTER
        Map<Id, RecordType> recType = new Map<Id, RecordType>([SELECT DeveloperName FROM RecordType WHERE SobjectType = 'Cluster__c']); 
        
        // UPDATE THE CURRENT CLUSTER ON MANAGEMENT COMPANY TO NULL
        Map<Id, Account> accntMap = new Map<Id, Account>([SELECT Id, Current_MPE_Cluster__c, Current_MeetingMatrix_MPE_Cluster__c, 
                                                          Current_MPE_Cluster__r.RecordTypeId, Current_MeetingMatrix_MPE_Cluster__r.RecordTypeId 
                                                          FROM Account 
                                                          WHERE Id IN : accIdToClusMap.keySet() 
                                                          AND (Current_MPE_Cluster__c != null OR Current_MeetingMatrix_MPE_Cluster__c != null)]);
        
        for (Account a : accntMap.values())
        {
            List<Cluster__c> clusterList = accIdToClusMap.get(a.Id);
            for (Cluster__c c : clusterList)
            {
                if ('Delphi_Daylight' == recType.get(c.recordTypeId).DeveloperName)
                {
                    a.Current_MPE_Cluster__c = null;
                }                
                else 
                {
                    if ('MeetingMatrix_Cluster' == recType.get(c.recordTypeId).DeveloperName) 
                    {
                        a.Current_MeetingMatrix_MPE_Cluster__c = null;
                    }                    
                }
            }                                 
        }
        
        update accntMap.values(); 
        
    }        
    
}