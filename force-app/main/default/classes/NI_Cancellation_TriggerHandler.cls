/************************************************************************************************
Name            : NI_Cancellation_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 07/31/2013
Last Mod Date   : 06/24/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class that handles all trigger code for the NI_Cancellation__c Object
                : 09/26/2017 - Cleaned up class. Removed commented code.
                : 03/27/2019 - NICC-033935 - Added Partner account lookup and share functions
                : NICC-034374 added Trigger execution control switch
				: NICC-035545 - Inactive Cancellation Case Rule bug fix
*************************************************************************************************/
public class NI_Cancellation_TriggerHandler
{
    
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    
    public NI_Cancellation_TriggerHandler()
    {
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries()); 
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults(); 
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries()); 
        
    }
    
    // ========================================================================================================================
    //  PUBLIC ENTRY METHODS 
    // ========================================================================================================================    
    public void OnBeforeInsert(List<NI_Cancellation__c> newTrigger)
    {
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.BypassNICancellation_ON__c)
        {
            Update_LookupFields(newTrigger);
            setAmadeusRSMUser(newTrigger, null);
            setPartnerAccount(newTrigger);
        }
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterInsert(List<NI_Cancellation__c> newTrigger)
    {
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        NI_TriggerManager.is1stInsert_Cancellation = false;
        
        if (!bpSwitch.BypassNICancellation_ON__c)
        {
            
            //CREATE  LIST TO HOLD ALL INSERTED RECORDS WHERE THE STATUS EQUALS CANCELLED
            List<NI_Cancellation__c> lstCancelled = new List<NI_Cancellation__c>();
            
            for (NI_Cancellation__c can : newTrigger) 
            {   
                //FIND THE CANCELLED RECORDS  
                if ((can.Status__c == 'Cancelled') && (can.General_Reason__c != 'User Reduction'))
                { 
                    lstCancelled.add(can);
                }
            }
            
            // CALL THE Update_DI_Status_Inactive METHOD
            if (lstCancelled.size() > 0)
            { 
                Update_DI_Status_Inactive(lstCancelled);
            } 
            
            rollupCancellationCounts(newTrigger, null);
            createRevenueSchedules(newTrigger, null, false);
            
            // LIST TO HOLD THE CANCELLATION RECORDS WHERE THE PARTNER NAME HAS CHANGED
            List<NI_Cancellation__c> lstPartnerNameChanges = new List<NI_Cancellation__c>();
            
            // LOOP THROUGH THE LIST OF UPDATED CANCELLATION RECORDS TO FIND THE RECORDS WHERE THE PARTNER NAME FIELD HAS BEEN UPDATED
            for (NI_Cancellation__c canc : newTrigger) 
            {
                if (canc.Partner_Name__c != null) 
                {
                    lstPartnerNameChanges.add(canc);
                }            
            }
            
            if (lstPartnerNameChanges.size() > 0)
            {     
                shareToPartners(lstPartnerNameChanges);
            }
            
            alertPartners(newTrigger);
            
        }
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }  
    
    public void OnBeforeUpdate(List<NI_Cancellation__c> newTrigger, Map<Id, NI_Cancellation__c> oldMapTrigger)
    {
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.BypassNICancellation_ON__c)
        {
            
            setPartnerAccount(newTrigger);
            
            //CREATE  LIST TO HOLD ALL RECORDS WHERE THE NEW DI DOESN'T MATCH THE OLD DI
            List<NI_Cancellation__c> lstDIChanges = new List<NI_Cancellation__c>();        
            Map<Id, NI_Cancellation__c> cancMap = new Map<Id, NI_Cancellation__c>();   
            
            for (NI_Cancellation__c c : newTrigger) 
            {
                //Old cancellation record
                NI_Cancellation__c oldCanc = oldMapTrigger.get(c.Id);
                
                //Check if DI value changed. If changed, add cancellation record to lstDIChanges list
                if (c.Deployment_Instance__c != oldCanc.Deployment_Instance__c)
                { 
                    lstDIChanges.add(c);
                }
                
            }
            
            // CALL THE DI_Change_UpdateLookupFields METHOD
            Update_LookupFields(lstDIChanges);        
            
            setAmadeusRSMUser(newTrigger, oldMapTrigger);
            
            // SO PROCESS BUILDER (START)
            if (checkCancellationRetentionSO(newTrigger, oldMapTrigger))
            {
                newTrigger[0].CurrencyIsoCode = newTrigger[0].Activity_Line_Item__r.CurrencyIsoCode;
                //newTrigger[0].Status__c = 'Pending Retention'; 										// COMMENTED AS A RESULT OF TESTING FOR (NICC-035969)
            }
            // SO PROCESS BUILDER (END)
            
        }
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterUpdate(List<NI_Cancellation__c> newTrigger, Map<Id, NI_Cancellation__c> oldMapTrigger)
    { 
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        NI_TriggerManager.is1stUpdate_Cancellation = false;
        
        if (!bpSwitch.BypassNICancellation_ON__c)
        {
            
            //CREATE LIST TO HOLD ALL RECORDS WHERE THE STATUS HAS CHANGED TO CANCELLED
            List<NI_Cancellation__c> lstCancelled = new List<NI_Cancellation__c>();
            List<NI_Cancellation__c> lstRetained = new List<NI_Cancellation__c>();
            
            for (NI_Cancellation__c can : newTrigger) 
            {
                
                NI_Cancellation__c canOld = oldMapTrigger.get(can.Id);
                
                // FIND THE CANCELLED RECORDS  
                if ((can.Status__c == 'Cancelled') && (can.Status__c != canOld.Status__c) && (can.General_Reason__c != 'User Reduction'))
                { 
                    lstCancelled.add(can);
                }
                
                // FIND THE RETAINED RECORDS  
                if (((can.Status__c == 'Successfully Retained') || (can.Status__c == 'Reactivated') || (can.Status__c == 'User Error')) && (can.Status__c != canOld.Status__c))
                { 
                    lstRetained.add(can);
                }
                
            }             
            
            // CALL THE Update_DI_Status_Inactive METHOD
            if (lstCancelled.size() > 0)
            { 
                Update_DI_Status_Inactive(lstCancelled);
            }    
            
            // CALL THE Update_DI_Installed METHOD FOR THE RETAINED NI CANCELLATION RECORDS
            if (lstRetained.size() > 0)
            {
                Update_DI_Installed(lstRetained);
            }
            
            rollupCancellationCounts(newTrigger, oldMapTrigger);
            createRevenueSchedules(newTrigger, oldMapTrigger, false);
            //createCancellationCase(newTrigger, oldMapTrigger);
            prepareCreateCase(newTrigger, oldMapTrigger);
            
            // SO PROCESS BUILDER (START)     
            if (NI_TriggerManager.isFirstSOChatterGroupPost)
            {
                if (checkCancellationRetentionSO(newTrigger, oldMapTrigger))
                {
                    
                    FeedItem post = new FeedItem();
                    
                    post.ParentId = Label.SO_Renewal_Cxl_Chatter_Group_ID;
                    String strBody = newTrigger[0].Name + ' has been created and requires retention efforts.\n\n';             
                    strBody += 'Account: ' + system.Url.getSalesforceBaseUrl().toExternalForm() + '/' + newTrigger[0].Account__c + '\n';  
                    strBody += 'Date Requested: ' + newTrigger[0].Renewal_Cancellation_Request_DateTime__c + '\n'; 
                    strBody += 'Anticipated Revenue Loss: ' + newTrigger[0].Anticipated_Revenue_Loss__c + '\n'; 
                    strBody += 'Quantity: ' + newTrigger[0].Renewal_Cancellation_Quantity__c + '\n';  
                    strBody += 'Product: ' + newTrigger[0].Product__c + '\n';  
                    strBody += 'Activity Line: ' + system.Url.getSalesforceBaseUrl().toExternalForm() + '/' + newTrigger[0].Activity_Line_Item__c + '\n'; 
                    post.Body = strBody; 
                    
                    insert post;
                    NI_TriggerManager.isFirstSOChatterGroupPost = false;
                }            
            }
            // SO PROCESS BUILDER (END)
            
            
            // LIST TO HOLD THE CANCELLATION RECORDS WHERE THE PARTNER NAME HAS CHANGED
            List<NI_Cancellation__c> lstPartnerNameChanges = new List<NI_Cancellation__c>();
            
            // LOOP THROUGH THE LIST OF UPDATED CANCELLATION RECORDS TO FIND THE RECORDS WHERE THE PARTNER NAME FIELD HAS BEEN UPDATED
            for (NI_Cancellation__c canc : newTrigger) 
            {
                NI_Cancellation__c oldCanc = oldMapTrigger.get(canc.Id);            
                
                if ((canc.Partner_Name__c != null && canc.Partner_Name__c != oldCanc.Partner_Name__c) || (canc.Partner_Name__c == null)) 
                {
                    lstPartnerNameChanges.add(canc);
                }
                
            }
            
            if (lstPartnerNameChanges.size() > 0)
            {     
                shareToPartners(lstPartnerNameChanges);
            }
            
        }
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }   
    
    public void OnAfterDelete(List<NI_Cancellation__c> oldTrigger)
    {
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.OnAfterDelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.BypassNICancellation_ON__c)
        {
            rollupCancellationCounts(oldTrigger, null);
            createRevenueSchedules(oldTrigger, null, true);
        }
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.OnAfterDelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterUndelete(List<NI_Cancellation__c> newTrigger)
    {
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.OnAfterUndelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.BypassNICancellation_ON__c)
        {
            rollupCancellationCounts(newTrigger, null);
            createRevenueSchedules(newTrigger, null, false);
        }
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.OnAfterUndelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    
    // ========================================================================================================================
    //  PRIVATE HANDLER METHODS/FUNCTIONS 
    // ========================================================================================================================  
    private void Update_DI_Status_Inactive(List<NI_Cancellation__c> newTrigger)
    {
        //THIS METHOD UPDATES THE STATUS AND DATE FIELDS ON THE DEPLOYMENT INSTANCE RECORD RELATED TO THE NI CANCELLATION
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.Update_DI_Status_Inactive() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String strDIStatus; //VARIABLE TO HOLD THE STATUS THAT THE DEPLOYMENT INSTANCE IS BEING UPDATED TO
        strDIStatus = 'Inactive';
        
        // Variable to hold values of NI Cancellation record which are cancelled
        List<NI_Cancellation__c> lstAllCancellationRecords = new List<NI_Cancellation__c>();
        Set<Id> setAssetIds = new Set<Id>();
        List<Asset> lstAssetsToUpdate = new List<Asset>();
        
        // Get NI Cancellation records
        lstAllCancellationRecords = ([SELECT Id,Deployment_Instance__c, Effective_Date__c, Number_of_Users_Reduced__c 
                                      FROM NI_Cancellation__c 
                                      WHERE Id IN : newTrigger]); 
        
        // Itearate over updated cancellation records to get DI Is in a set
        for (NI_Cancellation__c cxl : newTrigger) 
        {
            setAssetIds.add(cxl.Deployment_Instance__c);
        }  
        
        // Variable to hold DI values  
        List<Asset> lstAssets = new List<Asset>();
        
        // Map to hold values of cancellation record related to DI
        Map<Id, NI_Cancellation__c> mapCancellation = new Map<Id, NI_Cancellation__c>();
        
        for (NI_Cancellation__c nic : lstAllCancellationRecords)
        {
            mapCancellation.put(nic.Deployment_Instance__c, nic);
        }     
        
        // Get all the DI records associated to NI Cancellation records
        lstAssets = ([SELECT Id, Status, Status_Change_Date__c, Quantity_Cancelled__c 
                      FROM Asset a
                      WHERE a.Id IN : setAssetIds]);
        
        // Update status and Status change date
        for (Asset a : lstAssets)
        {                    
            a.Status = strDIStatus;
            a.Status_Change_Date__c = date.today();
            a.UsageEndDate = mapCancellation.get(a.Id).Effective_Date__c;
            lstAssetsToUpdate.add(a);
        }
        
        Database.update(lstAssetsToUpdate, false);
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.Update_DI_Status_Inactive() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    private void Update_DI_Installed(List<NI_Cancellation__c> newTrigger)
    {
        // THIS METHOD UPDATES THE STATUS AND DATE FIELDS ON THE DEPLOYMENT INSTANCE RECORD RELATED TO THE NI CANCELLATION
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.Update_DI_Installed() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String strDIStatus; //VARIABLE TO HOLD THE STATUS THAT THE DEPLOYMENT INSTANCE IS BEING UPDATED TO
        strDIStatus = 'Installed';
        
        List<NI_Cancellation__c> lstAllCancellationRecords = new List<NI_Cancellation__c>();
        Set<Id> setAssetIds = new Set<Id>();
        List<Asset> lstAssetsToUpdate = new List<Asset>();
        List<SFDC_CSP_Flash_Message__c> lstFlashMessagesToInsert = new List<SFDC_CSP_Flash_Message__c>();
        List<Task> lstTasksToInsert = new List<Task>();
        
        lstAllCancellationRecords = ([SELECT Id, Deployment_Instance__c, Effective_Date__c, Number_of_Users_Reduced__c 
                                      FROM NI_Cancellation__c 
                                      WHERE Id IN : newTrigger]); 
        
        for (NI_Cancellation__c cxl : newTrigger) 
        {
            setAssetIds.add(cxl.Deployment_Instance__c);
        }      
        
        List<Asset> lstAssets = new List<Asset>();
        
        lstAssets = ([SELECT Id, Status, Status_Change_Date__c, Quantity_Cancelled__c 
                      FROM Asset a
                      WHERE a.Id IN : setAssetIds]);          
        
        // LOOP THROUGH THE DEPLOYMENT INSTANCE RECORDS AND UPDATE THE APPROPRIATE FIELDS     
        for (Asset a : lstAssets)
        {                    
            a.Status = strDIStatus;
            a.Status_Change_Date__c = date.today();
            a.UsageEndDate = null;
            lstAssetsToUpdate.add(a);
        }
        
        // UPDATE DEPLOYMENT INSTANCE RECORDS  
        Database.update(lstAssetsToUpdate, false);
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.Update_DI_Installed() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }    
    
    private void Update_LookupFields(List<NI_Cancellation__c> newTrigger)
    {
        // THIS METHOD UPDATES THE NI CANCELLATION LOOKUP FIELDS BASED ON THE DEPLOYMENT INSTANCE
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.Update_LookupFields() - QUERIES ISSUED = ' + Limits.getQueries());
        
        //SET TO HOLD THE CANCELLATION ASSET IDs 
        Set<Id> setAssetIds = new Set<Id>();
        List<Asset> assets = new List<Asset>();
        
        //SET TO HOLD THE ACCOUNT IDs OF THE ASSET RECORDS   
        Set<Id> setAccountIds = new Set<Id>();  
        
        for (NI_Cancellation__c cxl : newTrigger) 
        {   
            if (cxl.Deployment_Instance__c != null)    
            {
                setAssetIds.add(cxl.Deployment_Instance__c);
            }
        }
        
        if (!setAssetIds.isEmpty())
        {
            //LIST OF ACCOUNTS RELATED TO CANCELLATION ASSET RECORDS
            assets = [SELECT Id, AccountId
                      FROM Asset
                      WHERE Id IN :setAssetIds];
        }
        
        //POPULATE THE setAccountIds
        for (Asset a2 : assets) 
        {
            setAccountIds.add(a2.AccountId);  
        }
        
        //REPLACE SA WITH ALI
        List<AggregateResult> lstSingleAliAssets = [SELECT Deployment_Instance__c, Count(Id) 
                                                    FROM Activity_Line_Item__c
                                                    WHERE Deployment_Instance__c IN :setAssetIds
                                                    AND Status__c = 'Active' 
                                                    GROUP BY Deployment_Instance__c
                                                    HAVING Count(Id) = 1];        
        
        // SET TO HOLD THE IDs OF THE DEPLOYMENT INSTANCE RECORDS THAT HAVE 1 RELATED SOFTRAX ASSET  
        Set<Id> setDeploymentInstanceIds = new Set<Id>();
        
        for (AggregateResult ar : lstSingleAliAssets)
        {
            setDeploymentInstanceIds.add((ID)ar.get('Deployment_Instance__c'));
        }
        
        //ADDED 7/4
        List<Activity_Line_Item__c> aliList = [SELECT Id, Deployment_Instance__c 
                                               FROM Activity_Line_Item__c 
                                               WHERE Deployment_Instance__c IN : setDeploymentInstanceIds];
        
        // MAP TO HOLD DIs THAT HAVE 1 RELATED SOFTRAX ASSET RECORD
        Map<Id, Id> mapDIsingleAliAsset = new Map<Id, Id>();
        
        for (Activity_Line_Item__c ali : aliList)
        {
            mapDIsingleAliAsset.put(ali.Deployment_Instance__c, ali.Id);
        }
        
        //MAP TO HOLD THE ASSET LOOKUP INFORMATION  
        Map<Id, Asset> mapAssets = new Map<Id, Asset>([SELECT a.Id, a.AccountId, a.Opportunity__c, a.Account.ParentId, a.Account.OwnerId, 
                                                       a.Account.Franchisor__c, Account.Ownership_Company__c, a.Account.Brand__c, a.Product2Id 
                                                       FROM Asset a
                                                       WHERE a.Id IN : setAssetIds]);
        
        //LIST TO HOLD THE ACCOUNT TEAM MEMBER RECORDS FOR THE ACCOUNTS RELATED TO THE CANCELLATIONS
        List<AccountTeamMember> lstAtm = [SELECT AccountId, UserId, TeamMemberRole
                                          FROM AccountTeamMember
                                          WHERE TeamMemberRole = 'NI Collector'
                                          AND AccountId IN :setAccountIds];
        
        //MAP TO HOLD ACCOUNT TEAM MEMBER ACCOUNTIDs AND USERIDs FOR THE ACCOUNTS RELATED TO THE CANCELLATIONS
        Map<Id, Id> mapAtm = new Map<Id, Id>();
        
        for (AccountTeamMember atm : lstAtm)
        {
            mapAtm.put(atm.AccountId, atm.UserId);
        }
        
        //LOOP THROUGH THE newTrigger COLLECTION AND UPDATE THE LOOKUP FIELDS
        for (NI_Cancellation__c c : newTrigger)
        {
            if (!mapAssets.isEmpty())
            {
                c.Account__c = mapAssets.get(c.Deployment_Instance__c).AccountId;
                c.Account_Owner__c = mapAssets.get(c.Deployment_Instance__c).Account.OwnerId;
                c.Brand__c = mapAssets.get(c.Deployment_Instance__c).Account.Brand__c;
                c.Franchisor__c = mapAssets.get(c.Deployment_Instance__c).Account.Franchisor__c;
                c.Management_Company__c = mapAssets.get(c.Deployment_Instance__c).Account.ParentId;
                c.Ownership_Company__c = mapAssets.get(c.Deployment_Instance__c).Account.Ownership_Company__c;
                
                // COMMENTED PER HEATHER'S REQUEST - NICC-024065        
                //                if (c.Status__c == 'Cancelled') //ADDED PER SALESFORCE.COM CHANGE REQUEST: NICC-018744
                //                {  
                //                    c.Updated_in_Activity_Line__c = true;
                //                }
                
                // ADDED THIS for "Change CXL.Product field to a Lookup" - https://na26.salesforce.com/aEP32000000CaRl Project backlog task
                c.Product2__c = mapAssets.get(c.Deployment_Instance__c).Product2Id;
                
                if (setDeploymentInstanceIds.contains(c.Deployment_Instance__c))
                {
                    c.Activity_Line_Item__c = mapDIsingleAliAsset.get(c.Deployment_Instance__c);
                }
                
                if (setAccountIds.contains(mapAssets.get(c.Deployment_Instance__c).AccountId))
                {
                    c.NI_Collector__c = mapAtm.get(mapAssets.get(c.Deployment_Instance__c).AccountId);
                } 
                
            }
            
        }
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.Update_LookupFields() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }  
    
    private void rollupCancellationCounts(List<NI_Cancellation__c> newTrigger, Map<Id, NI_Cancellation__c> oldMapTrigger)
    {
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.rollupCancellationCounts() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // IF SWITCH IS ON, ESCAPE
        if (bpSwitch.Bypass_Cancellation_Rollup__c) { return; }
        
        Set<Id> setActivityLineItemIds = new Set<Id>();
        
        for (NI_Cancellation__c c : newTrigger)
        {            
            if (c.Activity_Line_Item__c != null)
            {                
                if (oldMapTrigger != null)
                {
                    NI_Cancellation__c oldC = oldMapTrigger.get(c.Id);
                    // IF THE CANCELLED QUANTITY CHANGES  
                    if (c.Renewal_Cancellation_Quantity__c != oldC.Renewal_Cancellation_Quantity__c) 
                    {
                        setActivityLineItemIds.add(c.Activity_Line_Item__c);
                    }
                    // IF THE CANCELLATION STATUS CHANGES 
                    if (c.Status__c != oldC.Status__c) 
                    {
                        setActivityLineItemIds.add(c.Activity_Line_Item__c);
                    }    
                    // IF THE ACTVITY LINE ITEM CHANGES 
                    if ((c.Activity_Line_Item__c != oldC.Activity_Line_Item__c) && (oldC.Activity_Line_Item__c != null))
                    {
                        setActivityLineItemIds.add(c.Activity_Line_Item__c);
                    }                      
                }
                else
                {
                    setActivityLineItemIds.add(c.Activity_Line_Item__c);
                }    
            }            
        }
        
        system.debug(' **** setActivityLineItemIds = ' + setActivityLineItemIds); 
        
        if (!setActivityLineItemIds.isEmpty())
        {
            
            // GET ALL ACTIVITY LINE ITEM RECORDS 
            Map<Id, Activity_Line_Item__c> mapALIs = new Map<Id, Activity_Line_Item__c>(
                [SELECT Id, Units__c, Auto_Renewal__c   
                 FROM Activity_Line_Item__c 
                 WHERE Id IN : setActivityLineItemIds]); 
            
            // SELECT ALL RELATED ACTIVITY LINE ITEMS TO BE UPDATED
            List<Activity_Line_Item__c> lstALIUpdates = new List<Activity_Line_Item__c>([SELECT Id, Units_Cancelled__c, Auto_Renewal__c 
                                                                                         FROM Activity_Line_Item__c 
                                                                                         WHERE Id IN : setActivityLineItemIds 
                                                                                         FOR UPDATE]);

            // RESET Units_Cancelled__c TO ZERO PRIOR TO REASSIGNMENT
            for (Activity_Line_Item__c aliInit : lstALIUpdates)
            {               
                aliInit.Units_Cancelled__c = 0;
            }            
            
            // CREATE AGGREGATED LIST GROUPED BY ALI ID & SUMS OF CANCELLATION QUANTITIES
            List<AggregateResult> ag = new List<AggregateResult>([
                SELECT Activity_Line_Item__c, SUM(Renewal_Cancellation_Quantity__c) TotalCancellations  
                FROM NI_Cancellation__c 
                WHERE Renewal_Cancellation_Quantity__c != null 
                AND Status__c NOT IN ('Successfully Retained', 'Reactivated', 'User Error', 'Late Cancellation Rejected')  // , 'Pending Retention'
                AND Activity_Line_Item__c IN : setActivityLineItemIds 
                GROUP BY Activity_Line_Item__c 
            ]); 
            
            // LOOP THROUGH FINDING ID MATCHES AND UPDATING UNITS CANCELLED FIELDS
            for (AggregateResult x : ag)
            {
                for (Activity_Line_Item__c ali : lstALIUpdates)
                {               
                    if (x.get('Activity_Line_Item__c') == ali.Id) 
                    {   
                        ali.Units_Cancelled__c = (Decimal) x.get('TotalCancellations');
                        ali.Auto_Renewal__c = true;
                        if (ali.Units_Cancelled__c >= mapALIs.get(ali.Id).Units__c)
                        {
                            ali.Auto_Renewal__c = false;
                        }
                    }
                }
            }            
            
            // NICC-035969 (START): 
            // After the Cancellation.Status__c is changed TO 'Successfully Retained', 'User Error' or 'Late Cancellation Rejected' THEN  
            // Update the Activity_line_item__c.Auto_Renewal__c = true                        
            for (NI_Cancellation__c c2 : newTrigger)
            {        
                if (oldMapTrigger != null)
                {
                    // IF CANCELLATION STATUS CHANGED
                    NI_Cancellation__c oldC2 = oldMapTrigger.get(c2.Id);
                    if (c2.Status__c != oldC2.Status__c)
                    {
                        // AND CANCELLATION STATUS CHANGED TO ONE OF THE FOLLOWING:
                        if (c2.Status__c == 'Successfully Retained' || c2.Status__c == 'User Error' || c2.Status__c == 'Late Cancellation Rejected')
                        {
                            // LOOP THOUGH AND FIND RELATED ALI AND SET Auto_Renewal__c TO TRUE
                            for (Activity_Line_Item__c ali2 : lstALIUpdates)
                            {
                                if (c2.Activity_Line_Item__c == ali2.Id)
                                {
                                    ali2.Auto_Renewal__c = true;
                                }                      
                            }                        
                        }
                    }                   
                }
            }            
            // NICC-035969 (END)
            
            system.debug(' **** lstALIUpdates = ' + lstALIUpdates);    
            
            // COMMIT CHANGES
            if (!lstALIUpdates.isEmpty())
            {            
                database.update(lstALIUpdates);
            }
            
        }
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.rollupCancellationCounts() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    private void setAmadeusRSMUser(List<NI_Cancellation__c> newTrigger, Map<Id, NI_Cancellation__c> oldMapTrigger)
    {
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.setAmadeusRSMUser() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Set<Id> setAcctIds = new Set<Id>();
        for (NI_Cancellation__c cxl1 : newTrigger)
        {
            setAcctIds.add(cxl1.Account__c);        
        }
        
        Map<Id, Account> mapUserIds = new Map<Id, Account>();
        
        for (Account acc : [SELECT Id, OwnerId, Secondary_Account_Owner__c, MTech_Owner__c FROM Account WHERE Id IN : setAcctIds])
        {
            mapUserIds.put(acc.Id, acc);
        }
        
        Set<Id> setPrd2Ids = new Set<Id>();
        for (NI_Cancellation__c cxl2 : newTrigger)
        {
            system.debug(' **** cxl2.Product2__c = ' + cxl2.Product2__c);            
            setPrd2Ids.add(cxl2.Product2__c);        
        }
        
        Map<Id, Product2> mapSolDoms = new Map<Id, Product2>();
        
        for (Product2 p2 : [SELECT Id, Solution_Domain_Global__c FROM Product2 WHERE Id IN : setPrd2Ids AND Solution_Domain_Global__c != null])
        {
            mapSolDoms.put(p2.Id, p2);
        }        
        
        for (NI_Cancellation__c c : newTrigger)
        {
            
            // SET DEFAULT Amadeus_RSM__c TO ACCOUNT OWNER 
            c.Amadeus_RSM__c = mapUserIds.get(c.Account__c).OwnerId;
            
            if ((c.Product2__c != null) && mapSolDoms.containsKey(c.Product2__c))
            { 
                if (mapSolDoms.get(c.Product2__c).Solution_Domain_Global__c == 'Sales & Catering')
                {
                    if (mapUserIds.get(c.Account__c).Secondary_Account_Owner__c != null)                // NICC-027192 
                    {
                        c.Amadeus_RSM__c = mapUserIds.get(c.Account__c).Secondary_Account_Owner__c;
                    }
                }
                else
                {
                    if (mapSolDoms.get(c.Product2__c).Solution_Domain_Global__c == 'Service Optimization')
                    {
                        if (mapUserIds.get(c.Account__c).MTech_Owner__c != null)                        // NICC-027192 
                        {
                            c.Amadeus_RSM__c = mapUserIds.get(c.Account__c).MTech_Owner__c;
                        }
                    }
                }
            }
        }
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.setAmadeusRSMUser() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    private boolean checkCancellationRetentionSO(List<NI_Cancellation__c> newTrigger, Map<Id, NI_Cancellation__c> oldMapTrigger)
    {
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.createCancellationCase() - QUERIES ISSUED = ' + Limits.getQueries());
        
        boolean bRet = false;
        NI_Cancellation__c c = newTrigger[0];
        NI_Cancellation__c oldCxl = oldMapTrigger.get(c.Id);
        
        if (c.Anticipated_Revenue_Loss__c >= 1500 && !c.Late_Cancellation__c && c.Amadeus_RSM__c != null && c.Solution_Domain__c == 'Service Optimization')
        {
            if ((c.Renewal_Cancellation_Quantity__c != oldCxl.Renewal_Cancellation_Quantity__c && c.Retention_Completed__c) || !c.Retention_Completed__c)
            {
                bRet = true;
            }
        }
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.createCancellationCase() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return bRet;
        
    }

    private void createRevenueSchedules(List<NI_Cancellation__c> newTrigger, Map<Id, NI_Cancellation__c> oldMapTrigger, boolean isDelete)
    {
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.createRevenueSchedules() - QUERIES ISSUED = ' + Limits.getQueries());
             
        Set<String> setALI2CXLs = new Set<String>();
        
        // IF IN AFTER UPDATE CONTEXT
        if (oldMapTrigger != null)
        {
            for (NI_Cancellation__c cxl : newTrigger)
            {
                // CHECK FOR SPECIFIC CHANGES TO CALL A REVENUE SCHEDULE REBUILD
                NI_Cancellation__c oldCxl = oldMapTrigger.get(cxl.id);
                if (cxl.Effective_Date__c != oldCxl.Effective_Date__c ||                                // Effective_Date__c CHANGED
                    cxl.Renewal_Cancellation_Quantity__c != oldCxl.Renewal_Cancellation_Quantity__c)    // Renewal_Cancellation_Quantity__c CHANGED
                    // || cxl.Status__c != oldCxl.Status__c                                             // Status__c CHANGED                TODO: NEED MORE INPUT
                    // || cxl.Activity_Line_Item__c != oldCxl.Activity_Line_Item__c)                    // Activity_Line_Item__c CHANGED    TODO: NEED MORE INPUT   
                {
                    setALI2CXLs.add(String.valueOf(cxl.Activity_Line_Item__c) + ':' + String.valueOf(cxl.Id));
                }
            }          
        }
        else
        {
            for (NI_Cancellation__c cxl : newTrigger)
            {
                if (!isDelete)
                {
                    if (cxl.Activity_Line_Item__c != null)
                    {
                        setALI2CXLs.add(String.valueOf(cxl.Activity_Line_Item__c) + ':' + String.valueOf(cxl.Id));
                    }
                }                
            }             
        }                 

        if (!setALI2CXLs.isEmpty())
        {
            rebuildRevenueSchedules(setALI2CXLs);
        }
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.createRevenueSchedules() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    private void alertPartners(List<NI_Cancellation__c> newTrigger)
    {
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.alertPartners() - QUERIES ISSUED = ' + Limits.getQueries());
        
        try
        {
            
            Id communityID = [SELECT Id FROM Network WHERE Name = 'PartnerCentral' LIMIT 1].Id;
            
            // FILL SET OF PRODUCT2 IDs
            Set<Id> setPrd2Ids = new Set<Id>();
            for (NI_Cancellation__c cxl : newTrigger)
            {
                setPrd2Ids.add(cxl.Product2__c);
            }
            
            // FILL SET OF OPPORTUNITY IDS FOR USE IN ACCOUNT QUERY
            Set<Id> setParentAcctIds = new Set<Id>();  
            List<Product2> lstPrd2s = new List<Product2>([SELECT Id, Name, Partner_Name__c                                                                                                                                                     
                                                          FROM Product2 
                                                          WHERE Id IN : setPrd2Ids
                                                          AND Partner_Name__c != null]);
            
            if (!lstPrd2s.isEmpty())
            {
                
                for (Product2 p2 : lstPrd2s)
                {
                    setParentAcctIds.add(p2.Partner_Name__c);
                }
                
                Map<Id, FeedItem> mapPosts = new Map<Id, FeedItem>();
                
                List<Account> lstAccounts = new List<Account>([SELECT Id, Name, AccountNumber, Partner_Chatter_Group_ID__c 
                                                               FROM Account 
                                                               WHERE Partner_Chatter_Group_ID__c != null 
                                                               AND Id IN : setParentAcctIds]);
                
                Map<String, NI_Cancellation__c> mapCxls = new Map<String, NI_Cancellation__c>();
                for (NI_Cancellation__c cx : newTrigger)
                {
                    for (Product2 prd2 : lstPrd2s)
                    {
                        for (Account pa : lstAccounts)
                        { 
                            if (prd2.Partner_Name__c == pa.Id)
                            {
                                mapCxls.put(pa.Id + '-' + prd2.Id, cx);
                            }
                        }
                    }
                }            
                
                
                for (Account a : lstAccounts)
                { 
                    for (Product2 prd : lstPrd2s)
                    {                   
                        if (a.Id == prd.Partner_Name__c)
                        {   
                            // IF KEY NOT FOUND IT IS NEW
                            if (!mapPosts.containsKey(a.Id))
                            {
                                // INSTANTIATE NEW POST
                                FeedItem f = new FeedItem();
                                // ASSIGN COLLABORATION GROUP THAT IS ON PARTNER ACCOUNT
                                Id gId = (Id)a.Partner_Chatter_Group_ID__c;
                                f.ParentId = gId;
                                // ASSIGN POST TITLE
                                f.Title = 'Amadeus Cancellation Alert for ' + a.Name;
                                // ASSIGN POST BODY
                                String strBody = 'A product Cancellation has occurred: \n';
                                if (mapCxls.containsKey(a.Id + '-' + prd.Id))
                                {
                                    strBody += 'Link to Cancellation ' + mapCxls.get(a.Id + '-' + prd.Id).Name  + ' (login required): ' + Label.PartnerCentral_Base_URL + '/s/detail/' + mapCxls.get(a.Id + '-' + prd.Id).Id + ' \n';
                                }                                
                                strBody += 'Product: ' + prd.Name + ' \n';
                                // REMOVED PER NICC-034393 NOT PII strBody += 'Account: (' + mapCxls.get(a.Id + '-' + prd.Id).Account_Number__c + ') ' + mapCxls.get(a.Id + '-' + prd.Id).Account_Name__c + ' \n';
                                f.Body = strBody;
                                // ASSIGN COMMUNITY ID
                                f.NetworkScope = communityID;                            
                                mapPosts.put(a.Id, f); 
                            }
                        }
                    }
                }
                
                system.debug(' **** mapPosts.size() = ' + mapPosts.size()); 
                database.insert(mapPosts.values());
                
            }
            
        }
        catch (Exception ex)
        {
            String strDetails = 'Error occurred in .alertPartners() on Line#: ' + ex.getLineNumber() + ' - ' + ex.getMessage();
            NI_Error_Logger.WriteToLog(strDetails, 'PartnerCentral', 'NI_Cancellation_TriggerHandler', 'Insert'); 
        }
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.alertPartners() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    private void setPartnerAccount(List<NI_Cancellation__c> newTrigger)
    {
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.setPartnerAccount() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // SET TO HOLD THE VALUES FROM THE PRODUCT ID   
        Set<String> setProductIds = new Set<String>();  
        
        for (NI_Cancellation__c cxl : newTrigger) 
        {
            setProductIds.add(cxl.Product2__c);
        }
        
        // MAP TO HOLD THE PRODUCT LOOKUP INFORMATION  
        Map<Id, Product2> mapPrd2 = new Map<Id, Product2>([SELECT Id, Partner_Name__c FROM Product2 WHERE Id IN : setProductIds]);
        
        if (!mapPrd2.isEmpty())
        {
            for (NI_Cancellation__c c : newTrigger) 
            {
                if (c.Partner_Name__c != mapPrd2.get(c.Product2__c).Partner_Name__c)
                {
                    c.Partner_Name__c = mapPrd2.get(c.Product2__c).Partner_Name__c;
                }
            } 
        }
        
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.setPartnerAccount() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
   
    private void shareToPartners(List<NI_Cancellation__c> newTrigger)
    {          
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.shareToPartners() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // LIST TO HOLD THE PROFILES FROM THE "AH Partner Community Record Share Detail" CUSTOM SETTING  
        List<AH_Partner_Community_Record_Share__c> lstCS = AH_Partner_Community_Record_Share__c.getAll().values();
        
        Set<Id> setProfileIds = new Set<Id>();
        
        if (lstCS.size() > 0)
        {     
            
            Set<String> setProfileNames = new Set<String>();
            
            for (AH_Partner_Community_Record_Share__c cs :lstCS)    
            {
                setProfileNames.add(cs.Name);
            }            
            
            List<Profile> lstProfiles = [SELECT Id, Name FROM Profile WHERE Name IN : setProfileNames];
            
            for (Profile p : lstProfiles)
            {
                setProfileIds.add(p.Id);   
            }
            
        }
        
        //LIST OF SHARES THAT NEED TO BE REMOVED
        List<NI_Cancellation__Share> lstSharesToRemove = new List<NI_Cancellation__Share>([
            SELECT Id 
            FROM NI_Cancellation__Share 
            WHERE ParentId IN : newTrigger 
            AND RowCause = 'Partner_Community_User_Share__c']);
        
        // BULK REMOVE SHARE RECORDS
        if (lstSharesToRemove.size() > 0)
        {
            Database.DeleteResult[] drList = Database.delete(lstSharesToRemove, false);
            for (Database.DeleteResult dr : drList) 
            {
                if (dr.isSuccess()) 
                {
                    System.debug('**SUCCESSFULLY DELETED SHARE RECORD ID: ' + dr.getId());
                    system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Class: AH_SubscriptionActivationTriggerHandler.Update_PartnerAccount');
                }
                else 
                {
                    Database.Error err = dr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }        
        }
        
        //CODE THAT INSERTS THE NEW SHARE RECORDS
        
        List<User> lsPartnerUsersToInsert = new List<User>();
        
        Set<Id> setPartnerAccountIds = new Set<Id>();
        
        for (NI_Cancellation__c c : newTrigger)
        {
            if (c.Partner_Name__c != null)
            {
                setPartnerAccountIds.add(c.Partner_Name__c);
            }  
        }
        
        //LIST OF PARTNER USERS THAT NEED TO BE GRANTED ACCESS TO THE SUBSCRIPTION ACTIVATION RECORDS
        lsPartnerUsersToInsert = [SELECT Id, AccountId FROM User WHERE IsActive = true AND AccountId IN : setPartnerAccountIds AND ProfileId IN: setProfileIds];
        
        //LIST OF SHARES THAT NEED TO BE ADDED   
        List<NI_Cancellation__Share> lstSharesToInsert = new List<NI_Cancellation__Share>();
        
        for (NI_Cancellation__c cxl : newTrigger)
        {
            for (User pUser : lsPartnerUsersToInsert)
            {
                if (cxl.Partner_Name__c == pUser.AccountId)
                {
                    NI_Cancellation__Share saShare = new NI_Cancellation__Share();
                    saShare.ParentId = cxl.Id;
                    saShare.UserOrGroupId = pUser.Id;
                    saShare.AccessLevel = 'Edit';
                    saShare.RowCause = Schema.NI_Cancellation__Share.RowCause.Partner_Community_User_Share__c;
                    lstSharesToInsert.add(saShare);
                }                 
            }
        }
        
        // USE DATABASE DML METHOD TO ADD THE SHARES
        if (lstSharesToInsert.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(lstSharesToInsert,true);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }
        }
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.shareToPartners() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }    
    
    @future
    private static void rebuildRevenueSchedules(Set<String> setALI2CXLs)
    {
        
        // Deletes and Rebuilds the Revenue Schedules

        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.rebuildRevenueSchedules() - QUERIES ISSUED = ' + Limits.getQueries());

		system.debug(' **** setALI2CXLs = ' + setALI2CXLs);
        
        // THIS BLOCK IS A WAY TO GET AROUND THE DATATYPE RESTRICTIONS FOR @FUTURE ANNOTATED METHODS (START)        
        Set<Id> setALIIds = new Set<Id>();
        Set<Id> setCXLIds = new Set<Id>();
        Map<Id, Id> mapAID2CID = new Map<Id, Id>(); 
        Map<Id, NI_Cancellation__c> mapALI2CXLs = new Map<Id, NI_Cancellation__c>();
        
        for (String x : setALI2CXLs)
        {
            String[] strIDParse = x.Split(':');
            if (strIDParse.size() == 2)
            {
                Id aliID = (Id)strIDParse[0];
                Id cxlID = (Id)strIDParse[1];
                setALIIds.add(aliID);
                setCXLIds.add(cxlID); 
                mapAID2CID.put(aliID, cxlID);
            }
        }        

        for (NI_Cancellation__c cxl : [SELECT Id, Effective_Date__c, Anticipated_Revenue_Loss__c 
                                       FROM NI_Cancellation__c 
                                       WHERE Id IN : setCXLIds])
        {
            for (Id z : mapAID2CID.keySet())
            {
                if (mapAID2CID.get(z) == cxl.Id)
                {
                    mapALI2CXLs.put(z, cxl);
                }
            }
        }
        // THIS BLOCK IS A WAY TO GET AROUND THE DATATYPE RESTRICTIONS FOR @FUTURE ANNOTATED METHODS (END)        
        
        // FILL LIST OF ACTIVITY LINE ITEMS
        List<Activity_Line_Item__c> lstALIs = new List<Activity_Line_Item__c>(
            [SELECT Id, CurrencyIsoCode, Total_Revenue_to_Recognize__c 
             FROM Activity_Line_Item__c 
             WHERE Id IN : setALIIds]);
        
        // GET REVENUE SCHEDULE RECORDTYPE ID WITHOUT ISSUING A SOQL QUERY
        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.Revenue_Schedule__c.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtInfo = recordTypesMap.get('Lost Revenue');
        Id LostRevRecTypeId = rtInfo.getRecordTypeId(); 
        

        // 'Lost Revenue' REVENUE SCHEDULE DELETE LIST
        List<Revenue_Schedule__c> lstRevenueScheduleDeletes = new List<Revenue_Schedule__c>(); 
        
        // LOOK FOR 'Lost Revenue' REVENUE SCHEDULE RECORDS AND ADD TO LIST TO DELETE
        for (Revenue_Schedule__c rs : [SELECT Id FROM Revenue_Schedule__c WHERE Activity_Line_Item__c IN : setALIIds AND RecordTypeId =: LostRevRecTypeId])
        {
            lstRevenueScheduleDeletes.add(rs);
        }

        // IF 'Lost Revenue' REVENUE SCHEDULE RECORDS FOUND, DELETE THEM
        if (!setALIIds.isEmpty())
        {
            database.delete(lstRevenueScheduleDeletes);
        }   
        
        // 'Lost Revenue' REVENUE SCHEDULE INSERT LIST
        List<Revenue_Schedule__c> lstRevenueScheduleInserts = new List<Revenue_Schedule__c>();
        
        for (Activity_Line_Item__c ali : lstALIs)
        {

            NI_Cancellation__c cx = mapALI2CXLs.get(ali.Id);                        
            
            // LOST REVENUE SCHEDULE RECORDS 
            if (cx.Effective_Date__c != null && cx.Anticipated_Revenue_Loss__c != null)
            {
                
                Integer schedCreated = 0;
                Date dtEnd = cx.Effective_Date__c.addDays(364);
                Integer schedToCreate = cx.Effective_Date__c.monthsBetween(dtEnd); 
                Integer totalDays = cx.Effective_Date__c.daysBetween(dtEnd) + 1;
                Double totalDaysDouble = totalDays;
                Decimal totalAmountReleased = 0;
                Date schedDate = cx.Effective_Date__c;

                while (schedCreated <= schedToCreate)
                {
                    
                    Integer daysinPeriod = Date.daysinMonth(schedDate.year(), schedDate.month());
                    Integer allocationdays = daysinPeriod;
                    
                    // if it's the first then calculate the starting 
                    if (schedCreated == 0) 
                    {
                        allocationdays = daysinPeriod - cx.Effective_Date__c.day() + 1;
                    }
                    
                    // if this is the last item then account for potential partial periods
                    if (schedCreated == schedToCreate) 
                    {
                        allocationdays = dtEnd.day() - 1;
                    }
                    
                    Double allocationdaysDouble = allocationdays;             
                    Decimal deferredAmount = ((allocationdaysDouble / totalDaysDouble) * cx.Anticipated_Revenue_Loss__c).setScale(2); 
                    totalAmountReleased += deferredAmount;
                    
                    // if this is the last item then also account for rounding errors
                    if (schedCreated == schedToCreate)
                    {
                        if (totalAmountReleased != cx.Anticipated_Revenue_Loss__c)
                        {
                            deferredAmount -= (totalAmountReleased - cx.Anticipated_Revenue_Loss__c);
                        }
                    }
                    
                    Revenue_Schedule__c revSchedule = new Revenue_Schedule__c();
                    revSchedule.RecordTypeId = LostRevRecTypeId;
                    revSchedule.Start_Date__c = schedDate;
                    revSchedule.End_Date__c = dtEnd < schedDate.addMonths(1).toStartofMonth().addDays(-1) ? dtEnd : schedDate.addMonths(1).toStartofMonth().addDays(-1);
                    revSchedule.Activity_Line_Item__c = ali.id;
                    revSchedule.CurrencyIsoCode = ali.CurrencyIsoCode;
                    revSchedule.Deferred_Revenue_Amount__c = (deferredAmount * -1);
                    lstRevenueScheduleInserts.add(revSchedule);
                    
                    // increment some key variables:
                    schedDate = schedDate.addMonths(1).toStartofMonth();
                    schedCreated += 1;
                    
                }
            }
            
        }
        
        if (!lstRevenueScheduleInserts.isEmpty())
        {
            insert lstRevenueScheduleInserts;
        }
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.rebuildRevenueSchedules() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }   
    
    private void prepareCreateCase(List<NI_Cancellation__c> newTrigger, Map<Id, NI_Cancellation__c> oldMapTrigger)
    {
        
        Set<Id> setCxlIds = new Set<Id>();		// RELATED CANCELLATION IDS
        Set<Id> setAccIds = new Set<Id>();		// RELATED ACCOUNT IDS
        Set<Id> setP2Ids = new Set<Id>();		// RELATED PRODUCT IDS
        Set<Id> setDIIds = new Set<Id>();		// RELATED ASSERT IDS
        Set<Id> setUsrIds = new Set<Id>();		// RELATED USER IDS

        for (NI_Cancellation__c cxl : newTrigger)
        {
            
            NI_Cancellation__c oldC = oldMapTrigger.get(cxl.Id);  
            
            // IF Create_Cancellation_Case__c WAS CHANGED TO CHECKED 
            if (cxl.Create_Cancellation_Case__c && (cxl.Create_Cancellation_Case__c != oldC.Create_Cancellation_Case__c))
            {  
                
                setCxlIds.Add(cxl.Id);
                
                if (cxl.Account__c != null)
                {                
                    setAccIds.Add(cxl.Account__c);
                }
                
                if (cxl.Product2__c != null)
                {                
                    setP2Ids.Add(cxl.Product2__c);
                }
                
                if (cxl.Deployment_Instance__c != null)
                {                
                    setDIIds.Add(cxl.Deployment_Instance__c);
                }
                
                if (cxl.Renewal_Cancellation_Requester__c != null)
                {
                    setUsrIds.Add(cxl.Renewal_Cancellation_Requester__c);
                }

            }
            
        }
        
        if (!setCxlIds.isEmpty())
        {
            createCancellationCase(setCxlIds, setAccIds, setP2Ids, setDIIds, setUsrIds);
        }
        
    }
    
    @future
    private static void createCancellationCase(Set<Id> setCxlIds, Set<Id> setAccIds, Set<Id> setP2Ids, Set<Id> setDIIds, Set<Id> setUsrIds)
    {
        
        system.debug(' *** ENTERING NI_Cancellation_TriggerHandler.createCancellationCase() - QUERIES ISSUED = ' + Limits.getQueries());

        List<NI_Cancellation__c> lstValidCxls = new List<NI_Cancellation__c>(
            [SELECT Id, Account__c, Deployment_Instance__c, Product2__c, Specific_User_Names__c, 
             Renewal_Cancellation_Requester__c, Renewal_Cancellation_Quantity__c, Renewal_Cancellation_Note__c 
             FROM NI_Cancellation__c 
             WHERE Id IN : setCxlIds]);
        
        // IF NONE CHECKED THEN ESCAPE
        if (lstValidCxls.isEmpty())
        {
            return;
        }
        
        // MAP OF QUEUE IDS INDEXED BY QUEUE NAME
        Map<String, Id> mapQueues = new Map<String, Id>();
        for (Group q : [SELECT Id, Name FROM Group WHERE Type = 'Queue'])
        {
            mapQueues.put(q.Name, q.Id);
        }
       
        // MAP OF ACCOUNTS INDEXED BY CANCELLATION ID
        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        if (!setAccIds.isEmpty())
        { 
            for (Account acc : [SELECT Id, Name, Credit_Status__c FROM Account WHERE Id IN : setAccIds])
            {
                for (NI_Cancellation__c vCxl1 : lstValidCxls)
                {
                    if (acc.Id == vCxl1.Account__c)
                    {
                        mapAccounts.put(vCxl1.Id, acc);
                    }
                }
            }
        }
        
        // MAP OF ASSETS INDEXED BY CANCELLATION ID
        Map<Id, Asset> mapAssets = new Map<Id, Asset>();        
        if (!setDIIds.isEmpty())
        {
            for (Asset di : [SELECT Id, Name, Status, Product2Id FROM Asset WHERE Id IN : setDIIds])
            {
                for (NI_Cancellation__c vCxl2 : lstValidCxls)
                {
                    if (di.Id == vCxl2.Deployment_Instance__c)
                    {
                        mapAssets.put(vCxl2.Id, di);
                    }
                }
            }            
        }
        
        // MAP OF USERS INDEXED BY CANCELLATION ID
        Map<Id, User> mapUsers = new Map<Id, User>();
        if (!setUsrIds.isEmpty())
        {
            for (User usr : [SELECT Id, FirstName, LastName, Email FROM User WHERE Id IN : setUsrIds])
            {
                for (NI_Cancellation__c vCxl3 : lstValidCxls)
                {
                    if (usr.Id == vCxl3.Renewal_Cancellation_Requester__c)
                    {
                        mapUsers.put(vCxl3.Id, usr);
                    }
                }
            }            
        }
        
        // MAP OF CANCELLATION CASE RULES INDEXED BY RELATED PRODUCT2 ID
        Map<Id, Cancellation_Case_Rule_Product__c> mapCxlCaseRules = new Map<Id, Cancellation_Case_Rule_Product__c>();

        for (Cancellation_Case_Rule_Product__c ccrp : [SELECT Product__c, Product__r.Name, Cancellation_Case_Rule__r.Assignment_Queue__c, Cancellation_Case_Rule__r.Cancellation_Status__c, 
                                                       Cancellation_Case_Rule__r.Case_Description__c, Cancellation_Case_Rule__r.Case_Subject__c, Cancellation_Case_Rule__r.Inactive__c  
                                                       FROM Cancellation_Case_Rule_Product__c 
                                                       WHERE Product__c IN : setP2Ids])
        {
            mapCxlCaseRules.put(ccrp.Product__c, ccrp);
        }

        
		
        // CREATE AND INSERT CANCELLATION CASES
        List<Case> lstCaseInserts = new List<Case>();
        for (NI_Cancellation__c vCxl : lstValidCxls)
        { 
            
            boolean bRuleIsInactive = false;	// NICC-035545
            
            Case cs = new Case();
            cs.RecordTypeId = '0126000000011YUAAY';		// "Case" RECORDTYPE ID 
            cs.Origin = 'Cancellation';
            cs.Status = 'New';
            cs.Customer_Severity__c = '4 - Procedural';
            cs.Type = 'Proactive Case';
            cs.Case_Reason__c = 'Customer Resolved';
            cs.AccountId = vCxl.Account__c;
			cs.Has_No_DI__c = true;
            cs.OwnerId = mapQueues.get(Label.Cancellation_Case_Default_Queue);

            String strProdName = 'NOT FOUND';
            String strCxlDesc = '';
            
            // BUILD CASE SUBJECT
            string sSubj = 'Default Cancellation Case: No Case Rule Found';
            cs.Subject = sSubj;
	
			if (mapCxlCaseRules.containsKey(vCxl.Product2__c))
            {
                // SET INACTIVE BOOLEAN TO INCLUDE (OR EXCLUDE) CASE FROM INSERT LIST (NICC-035545)
                if (mapCxlCaseRules.get(vCxl.Product2__c).Cancellation_Case_Rule__r.Inactive__c == true)
                {
                    bRuleIsInactive = true;
                }
                
                sSubj = mapCxlCaseRules.get(vCxl.Product2__c).Cancellation_Case_Rule__r.Case_Subject__c;
                cs.Subject = sSubj;
                if (mapAssets.containsKey(vCxl.Id))
                {
                    cs.Subject = sSubj.replace('<<DI Name>>', mapAssets.get(vCxl.Id).Name);
                    cs.AssetId = mapAssets.get(vCxl.Id).Id;
                    cs.Has_No_DI__c = false;
                }
                
                // GET OTHER CASE FIELD VARIABLES STORED IN mapCxlCaseRules COLLECTION
                strProdName = mapCxlCaseRules.get(vCxl.Product2__c).Product__r.Name;
                strCxlDesc = mapCxlCaseRules.get(vCxl.Product2__c).Cancellation_Case_Rule__r.Case_Description__c;
                
                if (mapQueues.containsKey(mapCxlCaseRules.get(vCxl.Product2__c).Cancellation_Case_Rule__r.Assignment_Queue__c))
                {
                    string strQName = mapCxlCaseRules.get(vCxl.Product2__c).Cancellation_Case_Rule__r.Assignment_Queue__c;
                    cs.OwnerId = mapQueues.get(strQName);
                }
                
            }
            
            if (mapAccounts.containsKey(vCxl.Id))
            { 
                if (mapAccounts.get(vCxl.Id).Credit_Status__c != null && mapAccounts.get(vCxl.Id).Credit_Status__c == 'Support Hold')
                { 
                    cs.Subject = mapAccounts.get(vCxl.Id).Credit_Status__c + ' - ' + cs.Subject;
                } 
            }
            
            // BUILD CASE DESCRIPTION
            string sDesc = strCxlDesc;
            sDesc += '\n\nRenewal Cancellation Quantity : ' + vCxl.Renewal_Cancellation_Quantity__c;
            sDesc += '\nRenewal Cancellation Note : ' + vCxl.Renewal_Cancellation_Note__c;
            sDesc += '\nSpecific User Names : ' + vCxl.Specific_User_Names__c;
            sDesc += '\nProduct : ' + strProdName;

            if (mapUsers.containsKey(vCxl.Id)) 
            {
                sDesc += '\n\nRenewal Cancellation Requested By: [ ' + mapUsers.get(vCxl.Id).FirstName + ' ' + mapUsers.get(vCxl.Id).LastName + ', ' + mapUsers.get(vCxl.Id).Email + ' ]';
            }
            
            sDesc += '\n\n\n Cancellation Reference: ' + system.Url.getSalesforceBaseUrl().toExternalForm() + '/' + vCxl.Id;
            cs.Description = sDesc;

			if (bRuleIsInactive == false)	// NICC-035545
            {
                lstCaseInserts.add(cs); 
            }

        }

        // LINK SOLUTIONS
        if (!lstCaseInserts.isEmpty())
        {
            
            database.insert(lstCaseInserts);
            
            try 
            {
                
                Solution sol = [SELECT Id, SolutionName FROM Solution WHERE SolutionNumber =: Label.Cancellation_Case_Solution_Number];                
                
                if (sol.id != null) 
                {
                    List<CaseSolution> lstCaseSolutions = new List<CaseSolution>();
                    for (Case c: lstCaseInserts)
                    {
                        CaseSolution s = new CaseSolution(CaseId = c.Id, SolutionId = sol.Id);
                        lstCaseSolutions.add(s);
                    }
                    if (!lstCaseSolutions.isEmpty())
                    {
                        database.insert(lstCaseSolutions);
                    }
                }
            } 
            catch (Exception e)
            {
                system.debug(' **** Exception : ' + e);
            }
            
        }
        
        system.debug(' *** EXITING NI_Cancellation_TriggerHandler.createCancellationCase() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
        
}