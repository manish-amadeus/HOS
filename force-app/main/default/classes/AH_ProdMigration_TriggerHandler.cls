/************************************************************************************************
Name            : AH_ProdMigration_TriggerHandler
Author          : Sean Harris
Created Date    : 04/16/2019
Last Mod Date   : 08/20/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-034281
Description     : Class that handles all trigger code for the AH_Product_Migration__c Object
                : 
                : 
*************************************************************************************************/
public class AH_ProdMigration_TriggerHandler 
{

    // VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING 
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    // BYPASS @FUTURE ANNOTATED METHODS
    public static Boolean bBypassFutures = false;
    
    public AH_ProdMigration_TriggerHandler()
    {        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();                
    }

    // ======================================================================================================================== 
    //  ENTRY METHODS 
    // ========================================================================================================================     
    public void OnAfterUpdate(List<AH_Product_Migration__c> newTrigger, Map<Id, AH_Product_Migration__c> oldMapTrigger)
    {       
        
        system.debug(' *** ENTERING AH_ProdMigration_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        syncActivityLineItems(newTrigger, oldMapTrigger);

        if (!bBypassFutures)
        {
            prepareCasesAndAssets(newTrigger, oldMapTrigger); 
        }
        
        system.debug(' *** EXITING AH_ProdMigration_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }

    // ========================================================================================================================
    //  HANDLER METHODS & FUNCTIONS 
    // ========================================================================================================================      
    private void syncActivityLineItems(List<AH_Product_Migration__c> newTrigger, Map<Id, AH_Product_Migration__c> oldMapTrigger)
    {

		// UPDATES ALL RELATED Activity_Line_Item__c RECORDS WHEN THE Cut_Off_Date__c DATE CHANGES ON AH_Product_Migration__c RECORD
		// FIELDS UPDATED: 	Product_Migration_Date__c  
		// 					Renewal Eligible (Auto_Renewal__c) WHEN Cut Off Date < Renewal Date
		
        system.debug(' *** ENTERING AH_ProdMigration_TriggerHandler.syncActivityLineItems() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // FILL SET OF AH_Product_Migration__c IDS
        Set<Id> setPMIDs = new Set<Id>();
        for (AH_Product_Migration__c pm : newTrigger)
        {
            AH_Product_Migration__c oldPM = oldMapTrigger.get(pm.Id); 
            // IF Cut_Off_Date__c WAS CHANGED
            if (pm.Cut_Off_Date__c != oldPM.Cut_Off_Date__c)
            {
                setPMIDs.add(pm.Id);
            }
        }
        
        if (!setPMIDs.isEmpty())
        {
            
            // MAP caused by: System.ListException: Duplicate id in list: aMb0d000000D3pdCAC: Class.AH_ProdMigration_TriggerHandler.syncActivityLineItems: line 89, column 1
            Map<Id, Activity_Line_Item__c> mapUniqueALIUpdates = new Map<Id, Activity_Line_Item__c>();
            
            // LIST USED FOR FINAL ACTIVITY LINE ITEM UPDATE 
            //List<Activity_Line_Item__c> lstALIUpdates = new List<Activity_Line_Item__c>();
            
            // LOOP THROUGH RELATED AH_Product_Migration_Line_Item__c RECORDS HAVING A RECORD TYPE OF 'Activity Line Item'
            for (AH_Product_Migration_Line_Item__c pmli : [SELECT Id, Product_Migration_Cut_off_Date__c, Activity_Line_Item__c, Activity_Line_Item__r.Renewal_Date__c 
                                                           FROM AH_Product_Migration_Line_Item__c 
                                                           WHERE Product_Migration__c IN : setPMIDs  
                                                           AND RecordTypeId =: Schema.SObjectType.AH_Product_Migration_Line_Item__c.getRecordTypeInfosByName().get('Activity Line Item').getRecordTypeId()])
            {
                Activity_Line_Item__c aliUp = new Activity_Line_Item__c();
                aliUp.Id = pmli.Activity_Line_Item__c;
                aliUp.Product_Migration_Date__c = pmli.Product_Migration_Cut_off_Date__c;
                if (pmli.Product_Migration_Cut_off_Date__c < pmli.Activity_Line_Item__r.Renewal_Date__c)
                {
                    aliUp.Auto_Renewal__c = false;
                }
                mapUniqueALIUpdates.put(pmli.Activity_Line_Item__c, aliUp);
                //lstALIUpdates.add(aliUp);                
            }

            // COMMIT ACTIVITY LINE ITEM UPDATE
            // (!lstALIUpdates.isEmpty())
            //
            //  database.update(lstALIUpdates);
            //   
            
            if (!mapUniqueALIUpdates.isEmpty())
            {
                database.update(mapUniqueALIUpdates.values());
            }              
            
            
        }
        
        system.debug(' *** EXITING AH_ProdMigration_TriggerHandler.syncActivityLineItems() - QUERIES ISSUED = ' + Limits.getQueries());
          
    }

    private void prepareCasesAndAssets(List<AH_Product_Migration__c> newTrigger, Map<Id, AH_Product_Migration__c> oldMapTrigger)
    {
        
        Set<Id> setPMIds = new Set<Id>();
        Set<Id> setDIIds = new Set<Id>();
        
        for (AH_Product_Migration__c pm : newTrigger)
        {
            AH_Product_Migration__c oldPM = oldMapTrigger.get(pm.Id);
            
            if ((pm.Create_Migration_Case__c == true) && (pm.Create_Migration_Case__c != oldPM.Create_Migration_Case__c))
            {  
//                if (pm.BypassCaseAndAsset__c == false)
//                {
                    setPMIds.add(pm.Id);
//                }
            }            
        }

        for (AH_Product_Migration_Line_Item__c pmli : 
             [SELECT Id, Asset__c 
              FROM AH_Product_Migration_Line_Item__c 
              WHERE Product_Migration__c IN : setPMIds
              AND RecordTypeId =: Schema.SObjectType.AH_Product_Migration_Line_Item__c.getRecordTypeInfosByName().get('Deployment Instance').getRecordTypeId()])
        {
            setDIIds.add(pmli.Asset__c);
        }
        
        if (!setPMIds.isEmpty())
        {
            processCasesAndAssets(setPMIds, setDIIds);
        }

    }
 
    private static Case createCase(Id accountId, Id ContactId, String credStat, Id ownerId, Id diId, String sDIName, String sUser, AH_Product_Migration__c pm, Cancellation_Case_Rule__c cr)
    {
                
        system.debug(' *** ENTERING AH_ProdMigration_TriggerHandler.createCase() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Case cs = new Case();
        String strServerURL = URL.getSalesforceBaseUrl().toExternalForm(); 
        
        Schema.DescribeSObjectResult schm = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> rtInfo = schm.getRecordTypeInfosByName(); 
        Id rtId = rtInfo.get('Case').getRecordTypeId();         
        
        cs.RecordTypeId = rtId;
        cs.OwnerId = ownerId;
        cs.AccountId = accountId;
        cs.AssetId = diId;  
        cs.ContactId = ContactId;  
        
        if (diId == null)
        {
            cs.Has_No_DI__c = true;
        }         

        // BUILD CASE SUBJECT
		if (cr == null)
        {
            cs.Subject = 'Default Migration Case: No Case Rule Found';
        }
        else
        {
            string sSubj = cr.Case_Subject__c;
            if (sDIName != null)
            {
                cs.Subject = sSubj.replace('<<DI Name>>', sDIName);   
            }
            else
            {
                cs.Subject = sSubj.replace('<<DI Name>>', pm.From_Product_Name__c); 
            }
        }

        if (credStat != null && credStat == 'Support Hold')
        {
            cs.Subject += ' - ' + credStat;
        }
        
        // BUILD CASE DESCRIPTION
        string sDesc = '';
        
        if (cr != null)
        {
            if (cr.Case_Description__c != null) 
            {
                sDesc += cr.Case_Description__c + '\n\n\n';
            }
        }

        sDesc += ' ========================= \n';
        sDesc += ' Product Migration Details \n';
        sDesc += ' ========================= \n';
        sDesc += '\n Product Migration Reference: ' + strServerURL + '/' + pm.Id;
        if (pm.Cut_Off_Date__c != null)
        {
            sDesc += '\n\n Cut Off Date: ' + pm.Cut_Off_Date__c;
        }
        if (pm.Live_Date__c != null)
        {
            sDesc += '\n\n Live Date: ' + pm.Live_Date__c;
        }
        sDesc += '\n\n FROM PRODUCT: ' + pm.From_SKU__c + ' - ' + pm.From_Product_Name__c;
        sDesc += '\n\n TO PRODUCT: ' + pm.To_SKU__c + ' - ' + pm.To_Product_Name__c;
        sDesc += '\n\n Requested By: [ ' + sUser + ' ] \n\n\n\n'; 
        sDesc += '*** PLEASE DISABLE THIS PRODUCT: ' + pm.From_SKU__c + ' - ' + pm.From_Product_Name__c + '\n\n\n\n'; 

        cs.Description = sDesc;
        if (sDIName != null)
        {
            cs.Description = sDesc.replace('<<DI Name>>', sDIName);
        }        
        
        cs.Customer_Severity__c = '4 - Procedural';
        cs.Type = 'Proactive Case';
        cs.Case_Reason__c = 'Customer Resolved';
        cs.Origin = 'Internal';
        cs.Status = 'New';
        
        system.debug(' *** EXITING AH_ProdMigration_TriggerHandler.createCase() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return cs; 
        
    }

    // ========================================================================================================================
    //  HANDLER FUTURE METHODS
    // ========================================================================================================================      
    @future
    private static void processCasesAndAssets(Set<Id> setPMs, Set<Id> setDIs)
    {
        
        List<AH_Product_Migration__c> lstProductMigrations = new List<AH_Product_Migration__c>(
            [SELECT Id, Name, Account__c, Account__r.Credit_Status__c, Owner.Name, Owner.Email, Cut_Off_Date__c, Live_Date__c, 
             From_Product__c, From_SKU__c, From_Product_Name__c, To_SKU__c, To_Product__c, To_Product_Name__c, Opportunity__c 
             FROM AH_Product_Migration__c 
             WHERE Id IN : setPMs]);
        List<Asset> lstAsset = new List<Asset>([SELECT Id, Name, Integration_User_Source__c, Status, AccountId, Account.Credit_Status__c FROM Asset WHERE Id IN : setDIs]);
        List<Case> lstCaseInserts = new List<Case>();
        
        // ===========================
        // DEPLOYMENT INSTANCE SECTION
        // ===========================
        
		// FILL MAPS 
        Map<Id, Id> mapDI2PMId = new Map<Id, Id>();
        Map<Id, String> mapDI2PMName = new Map<Id, String>();

        for (AH_Product_Migration_Line_Item__c pmli : 
             [SELECT Id, Asset__c, Product_Migration__r.Name, Product_Migration__c 
              FROM AH_Product_Migration_Line_Item__c 
              WHERE Product_Migration__c IN : setPMs
              AND RecordTypeId =: Schema.SObjectType.AH_Product_Migration_Line_Item__c.getRecordTypeInfosByName().get('Deployment Instance').getRecordTypeId()])
        {
            if (pmli.Asset__c != null)
            {
                mapDI2PMId.put(pmli.Asset__c, pmli.Product_Migration__c);
                mapDI2PMName.put(pmli.Asset__c, pmli.Product_Migration__r.Name);                
            }
        }
        
        // DEACTIVATE DEPLOYMENT INSTANCE RECORDS
        List<Asset> lstAssetStatusUpdates = new List<Asset>();
        
        for (Asset di : lstAsset)
        {
            Asset upDI = new Asset();
            upDI.Id = di.Id;
            upDI.Status = 'Inactive';
            upDI.Integration_User_Source__c = 'Deployment Instance status set to Inactive from Product Migration Record: ' + mapDI2PMName.get(di.Id);
            lstAssetStatusUpdates.add(upDI);
        }
        
        if (!lstAssetStatusUpdates.isEmpty()) 
        {
            database.update(lstAssetStatusUpdates);
        }        
        
        
        // ===========================
        // CASE SECTION
        // ===========================
                
        
        // FILL SET WITH ALL "TO PRODUCT" IDS
        Set<Id> setProductIds = new Set<Id>();
        // FILL SET WITH ALL OPPORTUNITY IDS TO QUERY FOR CONTACT FOR CASE IN OPPORTUNITY CONTACT ROLES
        Set<Id> setOpportunityIds = new Set<Id>();
        for (AH_Product_Migration__c pm1 : lstProductMigrations)
        {
            setProductIds.add(pm1.From_Product__c);
            setOpportunityIds.add(pm1.Opportunity__c);
        }
        
        // FILL MAP TO BE ABLE TO GET CASE RULE FROM PRODUCT ID LATER
        Map<Id, Id> mapProduct2Rule = new Map<Id, Id>();
        for (Cancellation_Case_Rule_Product__c ccrp : [SELECT Product__c, Cancellation_Case_Rule__c FROM Cancellation_Case_Rule_Product__c WHERE Product__c IN : setProductIds])
        {
            mapProduct2Rule.put(ccrp.Product__c, ccrp.Cancellation_Case_Rule__c);
        }        

        // FILL MAP TO BE ABLE TO GET CONTACT ID FROM PRODUCT MIGRATION ID LATER FOR CASE CONTACT
        Map<Id, Id> mapPMId2ContactId = new Map<Id, Id>();
        for (OpportunityContactRole ocr : [SELECT Contact.Id, OpportunityId FROM OpportunityContactRole WHERE Role = 'Decision Maker' AND OpportunityId IN : setOpportunityIds])
        {
            for (AH_Product_Migration__c pm2 : lstProductMigrations)
            {
                if (pm2.Opportunity__c == ocr.OpportunityId)
                {
                    mapPMId2ContactId.put(pm2.Id, ocr.Contact.Id);
                } 
            }
        }
        
        // GET CASE RULE(S) RELATED TO THE From_Product__c ON PRODUCT MIGRATION
        List<Cancellation_Case_Rule__c> lstCCR = new List<Cancellation_Case_Rule__c>(
            [SELECT Id, Assignment_Queue__c, Cancellation_Status__c, Case_Description__c, Case_Subject__c, Inactive__c 
             FROM Cancellation_Case_Rule__c]); 
             // WHERE Id IN (SELECT Cancellation_Case_Rule__c FROM Cancellation_Case_Rule_Product__c WHERE Product__c IN : setProductIds)]);        
        
        // FILL A MAP WITH ALL QUEUES FOR LOOKUP
        Map<String, Id> mapQueues = new Map<String, Id>();
        for (Group q : [SELECT Id, Name FROM Group WHERE Type = 'Queue'])
        {
            mapQueues.put(q.Name, q.Id);
        } 


		// LOOP THROUGH AND CONDITIONALLY CREATE CASES
        for (AH_Product_Migration__c pm : lstProductMigrations)
        {
       
            // SET FLAG TO FALSE WHEN THE PRODUCT MIGRATION IS NOT ASSOCIATED WITH A DI   
            Boolean bPMLIHasAssetId = false;
            for (Id x : mapDI2PMId.values())
            {
                if (pm.Id == x)
                {
                    bPMLIHasAssetId = true;
                }
            }            

            // STRING TO HOLD USER NAME AND EMAIL FOR CASE DETAILS
            String strUser = pm.Owner.Name + ', ' + pm.Owner.Email;
          
            // IF THE "FROM PRODUCT" IS ASSOCIATED TO A CASE RULE
            if (mapProduct2Rule.containsKey(pm.From_Product__c))
            {
                // LOOP THROUGH AND FIND THE CASE RULE
                for (Cancellation_Case_Rule__c ccr : lstCCR)
                {  
                   
                    // NOTE: MAKING A CASE RULE INACTIVE IS A WAY TO -NOT- CREATE CASE RECORDS
                    if (mapProduct2Rule.get(pm.From_Product__c) == ccr.Id && !ccr.Inactive__c)
                    {                    

                        String sDI_Name = null;
                        Id DI_id = null;
                        
                        for (Asset di : lstAsset)
                        {                              
                            if (mapDI2PMId.get(di.Id) == pm.Id)
                            {
                                sDI_Name = di.Name;
                                DI_id = di.Id;
                                break;
                            }
                        }
                      
                        lstCaseInserts.add(createCase(pm.Account__c, mapPMId2ContactId.get(pm.Id), pm.Account__r.Credit_Status__c, mapQueues.get(ccr.Assignment_Queue__c), DI_id, sDI_Name, strUser, pm, ccr));
                        
                    }
                }
            }
            else
            {
                lstCaseInserts.add(createCase(pm.Account__c, mapPMId2ContactId.get(pm.Id), pm.Account__r.Credit_Status__c, mapQueues.get(Label.Cancellation_Case_Default_Queue), null, null, strUser, pm, null));
            }
            
        }

        // CREATE CASE RECORD
        if (!lstCaseInserts.isEmpty())
        {
            
            NI_Case_TriggerHandler.callFuture = false;
            database.insert(lstCaseInserts);
            
            Solution sol = new Solution();
            try 
            {
                if (Test.isRunningTest())
                {
                    sol = [SELECT Id, SolutionName FROM Solution LIMIT 1];
                }
                else
                {
                    sol = [SELECT Id, SolutionName FROM Solution WHERE SolutionNumber =: Label.Cancellation_Case_Solution_Number];
                }                    
                
                if (sol.id != null) 
                {
                    List<CaseSolution> list_caseSol = new List<CaseSolution>();
                    for (Case c: lstCaseInserts)
                    {
                        CaseSolution s = new CaseSolution(CaseId = c.id, SolutionId = sol.id);
                        list_caseSol.add(s);
                    }
                    if (!list_caseSol.isEmpty())
                    {
                        database.insert(list_caseSol);
                    }
                }
            } 
            catch (Exception e)
            {
                system.debug('Exception : ' + e);
            }
            
        }        

    }
    
}