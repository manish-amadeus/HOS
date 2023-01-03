/****************************************************************************************
Name            : NI_Account_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 1/09/2013
Last Mod Date   : 1/14/2013 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-009172
Description     : Class that handles all trigger code for the Account Object
                : Originally created to prevent accounts that are integrated with Softrax
                : from being deleted
                : 
******************************************************************************************/
public with sharing class NI_Account_TriggerHandler 
{
    
    
    public NI_Account_TriggerHandler() 
    {
        
    }

    // ========================================================================================================================
    //  ENTRY METHODS =========================================================================================================
    // ========================================================================================================================    

    public void OnBeforeInsert(List<Account> newListTrigger)
    {
        for(Account acc : newListTrigger)
        {
            // Update "Type"
            if (acc.Billing_Verification__c)
            {
                acc.Type = 'Needs Verification';
            }
            else {
                if (acc.Permanently_Closed__c)
                {
                    acc.Type = 'Permanently Closed';
                }
            }
        }   
    }

    public void OnAfterInsert(Map<Id,Account> newMapTrigger)
    {     
        List<Id> updateDIListcurClus = new List<Id>();
        List<Id> updateDIListtarClus = new List<Id>();       
        for (Account acc : newMapTrigger.values())
        {
            //Check Current Cluster or Current Meetingmatrix clutser is Not a Null Value    
            if (acc.current_MPE_Cluster__c != null || acc.Current_MeetingMatrix_MPE_Cluster__c != Null)
            {
                updateDIListcurClus.add(acc.Id);
            }                               
        }
        updateDIObj(updateDIListcurClus);
    }
 
    public void OnBeforeUpdate(List<Account> newListTrigger, Map<Id, Account> oldMapTrigger)
    {
        Set<Id> targetClusdelList = new Set<Id>();
        Set<Id> targetmeetMatrixClusdelList = new Set<Id>();
        Set<Id> delphiClusterIds = new Set<Id>();
        Set<Id> meetMatrixClusterIds = new Set<Id>();
        Map<Id, Account> accMap = new Map<Id, Account>(); 
        Map<String, Account> clusAccMap = new Map<String, Account>();
        Map<String, Account> meetMtrixaccMap = new Map<String, Account>();
        
        for (Account acc : newListTrigger)
        {        
            Account oldAcc = (Account)oldMapTrigger.get(acc.Id);
        
			// Update Type Field to "Permanently Closed" if "Permanently Closed" field is Checked 
            if (acc.Billing_Verification__c == true)
            {
                acc.Type = 'Needs Verification';
            }
            else 
            {
                if (acc.Permanently_Closed__c == True && acc.Type != 'Customer')
                {
                    acc.Type = 'Permanently Closed';
                }
            }
            
            // Check that current MPE Cluster is Updated
            if (acc.Current_MPE_Cluster__c != oldAcc.Current_MPE_Cluster__c && acc.Current_MPE_Cluster__c != null)
            {                
                delphiClusterIds.add(acc.Current_MPE_Cluster__c);
                accMap.put(acc.Id, acc);
            }
            
            // Check that current MeetingMatrix MPE Cluster is Updated
            if (acc.Current_MeetingMatrix_MPE_Cluster__c != oldAcc.Current_MeetingMatrix_MPE_Cluster__c && acc.Current_MeetingMatrix_MPE_Cluster__c != null)
            {
                meetMatrixClusterIds.add(acc.Current_MeetingMatrix_MPE_Cluster__c);
                accMap.put(acc.Id,acc);
            }
            
        }
        
        // Call the method that validate the selected Cluster
        if (!meetMatrixClusterIds.isEmpty() || !delphiClusterIds.isEmpty())
        {
            checkDIExistsforCluster(delphiClusterIds, meetMatrixClusterIds, accMap, newListTrigger);
        }
        
    }

    public void OnAfterUpdate(Map<Id,Account> newMapTrigger, Map<Id,Account> oldMapTrigger)
    {        
       
        List<Id> updateDIcurClus = new List<Id>();
        List<Id> updateDItarClus = new List<Id>();
        Set<Id> callUpdateAccTypeIds = new Set<Id>();               
        
        for (Account acc : newMapTrigger.values())
        {
            Account oldAcc = (Account)oldMapTrigger.get(acc.Id);
			// Check Current Cluster or Current Meetingmatrix Cluster is Changed 
            if (
                (acc.current_MPE_Cluster__c != oldAcc.current_MPE_Cluster__c && acc.current_MPE_Cluster__c != null) || 
                (acc.Current_MeetingMatrix_MPE_Cluster__c != oldAcc.Current_MeetingMatrix_MPE_Cluster__c && acc.Current_MeetingMatrix_MPE_Cluster__c != null)
               )
            {
                updateDIcurClus.add(acc.Id);
            }            
            
            if (acc.Permanently_Closed__c == false && oldAcc.Permanently_Closed__c == true)
            {
                callUpdateAccTypeIds.add(acc.Id);        
            }                      
        }
        
        updateDIObj(updateDIcurClus);

        if (!callUpdateAccTypeIds.isEmpty())
        {
            NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
            handler.updateAccntType(callUpdateAccTypeIds); 
        }                                         
    }
    
    public void OnBeforeDelete(List<Account> oldTrigger)
    {
        set<id> deletedAccs = new set<id>();
        // Loop through the oldTrigger List of Accounts
        for (Account a : oldTrigger) 
        {
            deletedAccs.add(a.id);
            if (a.Integrate_w_Softrax__c == true) 
            {
                a.addError('This Account is integrated with Softrax and cannot be deleted');
                System.debug('Account: ' + a.Id + ' is integrated with Softrax and cannot be deleted');
            } 
        }
    } 
    
//    public void OnAfterDelete(List<Account> oldTrigger)
//    {
//    }
    

    
    // ========================================================================================================================
    //  HANDLER FUNCTIONS =====================================================================================================
    // ========================================================================================================================  
    
    // Added By: Sunita Mittal
    // Added On: 12/10/2015
    // Description:Updates the Version, Products, Status Fields on Deployment Instaces if Deployment Instance found related Cluster    
    //             Create new Deployment Instance if related DI no found
    public void updateDIObj(List<Id> updateDIcurClus)
    {
        
        Set<Id> clusAccIds = new Set<Id>(); 
        Set<Id> meetMatrxclusAccIds = new Set<Id>(); 
        Map<String, String> diIndexProdMap = new Map<String, String>(); 
        Map<String, List<String>> diClusMap = new Map<String, List<String>>(); 
        Map<String, List<String>> diMeetmtrxClusMap = new Map<String, List<String>>(); 

		// Update "Version" field on Deployment Instances(Asset) when Current MPE Cluster field is updated                
        if (!updateDIcurClus.isEmpty())
        {                                           
            for (List<Account> accList : [SELECT Id, current_MPE_Cluster__c, 
                                          current_MPE_Cluster__r.Version_New__c, 
                                          current_MPE_Cluster__r.Hosted__c,
                                          current_MPE_Cluster__r.DI_Index__c, 
                                          Current_MeetingMatrix_MPE_Cluster__c, 
                                          Current_MeetingMatrix_MPE_Cluster__r.Version_New__c, 
                                          Current_MeetingMatrix_MPE_Cluster__r.Hosted__c, 
                                          Current_MeetingMatrix_MPE_Cluster__r.DI_Index__c 
                                          FROM Account 
                                          WHERE Id IN : updateDIcurClus 
                                          AND (current_MPE_Cluster__r.DI_Index__c != null OR Current_MeetingMatrix_MPE_Cluster__r.DI_Index__c != null)])
            {
                for (Account a : accList)
                { 
                    List<String> clusDataList = new List<String>();
                    List<String> meetmtrxDataList = new List<String>(); 
                    if (a.current_MPE_Cluster__c != null)
                    {
                        clusAccIds.add(a.Id);
                        clusDataList.add(a.current_MPE_Cluster__r.Version_New__c);
                        clusDataList.add(String.valueOf(a.current_MPE_Cluster__r.Hosted__c));                      
                        diClusMap.put(String.valueOf(a.Id)+String.valueOf(a.current_MPE_Cluster__r.DI_Index__c), clusDataList);
                    }
                    if (a.Current_MeetingMatrix_MPE_Cluster__c != null)
                    {
                        meetMatrxclusAccIds.add(a.Id);
                        meetmtrxDataList.add(a.Current_MeetingMatrix_MPE_Cluster__r.Version_New__c);
                        meetmtrxDataList.add(String.valueOf(a.Current_MeetingMatrix_MPE_Cluster__r.Hosted__c));                        
                        diMeetmtrxClusMap.put(String.valueOf(a.Id) + String.valueOf(a.Current_MeetingMatrix_MPE_Cluster__r.DI_Index__c), meetmtrxDataList);
                    }                    
                } 
                // system.debug('****diClusMap*****'+diClusMap);                                                            
            }
            
            for (List<Asset> depInsList : [SELECT Version__c, IsHostedDI__c, AccountId_DIIndexID__c, Account.current_MPE_Cluster__c 
                                           FROM Asset 
                                           WHERE (AccountId IN :clusAccIds OR AccountId IN :meetMatrxclusAccIds) 
                                           AND (AccountId_DIIndexID__c IN : diClusMap.keyset() OR AccountId_DIIndexID__c IN : diMeetmtrxClusMap.keySet())])
            {
                List<Asset> diList = new List<Asset>();
                // system.debug('****depInsList *****' + depInsList ); 
                // if DI's related to Current Cluster or Current Meeting Matrix cluster are found, then update the DI with cluster's Data
                for (Asset depIns : depInsList)
                {   
                    if (diClusMap.containsKey(depIns.AccountId_DIIndexID__c))
                    {
                        depIns.Version__c = diClusMap.get(depIns.AccountId_DIIndexID__c)[0]; 
                        depIns.IsHostedDI__c = Boolean.valueOf(diClusMap.get(depIns.AccountId_DIIndexID__c)[1]);                       
                        clusAccIds.remove(depIns.AccountId);    
                    }
                    if (diMeetmtrxClusMap.containsKey(depIns.AccountId_DIIndexID__c))
                    {
                        depIns.Version__c = diMeetmtrxClusMap.get(depIns.AccountId_DIIndexID__c)[0]; 
                        depIns.IsHostedDI__c = Boolean.valueOf(diMeetmtrxClusMap.get(depIns.AccountId_DIIndexID__c)[1]);                       
                        meetMatrxclusAccIds.remove(depIns.AccountId);                       
                    }
                    diList.add(depIns);                                     
                }  
                
                update diList;
                
            }
            
        } 
        
    }  
    
    //@ Added On: 02/19/2016
    //@ Description:Verify that Account has the active DI related to selected DI 
    public void checkDIExistsforCluster(Set<Id> delphiClusterIds, Set<Id> meetMatrixClusterIds, Map<id, Account> accntMap, List<Account> accList)
    { 
        
        Set<String> accIdIndexId = new Set<String>();
        
        //Get the Cluster Details of Seleted Cluster
        Map<Id, Cluster__c> clusterMap = new Map<Id, Cluster__c>([SELECT Id, DI_Index__c, RecordType.DeveloperName FROM Cluster__c WHERE Id IN : delphiClusterIds OR Id IN : meetMatrixClusterIds]);
        
        //Get the Deployment Instances related Account
        Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, AccountId_DIIndexId__c FROM Asset WHERE AccountId IN : accntMap.KeySet() AND Status != 'Inactive']);
        
        for (Asset a : assetMap.values())        
        {
            accIdIndexId.add(a.AccountId_DIIndexId__c);
        }
        
        for (Account a : accList)
        {
            // Check DI Exists for Delphi/Daylight Cluster
            if (delphiClusterIds.contains(a.current_MPE_Cluster__c))
            {
                if (!accIdIndexId.contains(String.valueOf(a.Id) + String.valueOf(clusterMap.get(a.current_MPE_Cluster__c).DI_Index__c)))
                {
                    a.current_MPE_Cluster__c.addError('This Account does not have an active Deployment Instance that matches the selected Cluster\'s DI Index');
                }
            } 
            // Check DI Exists for MeetingMatrix Cluster          
            if (meetMatrixClusterIds.contains(a.current_MeetingMatrix_MPE_Cluster__c))
            {
                if (!accIdIndexId.contains(String.valueOf(a.Id) + String.valueOf(clusterMap.get(a.current_MeetingMatrix_MPE_Cluster__c).DI_Index__c)))
                {
                    a.current_MeetingMatrix_MPE_Cluster__c.addError('This Account does not have an active Deployment Instance that matches the selected Cluster\'s DI Index');
                }
            }           
        }
        
    } 
    
}