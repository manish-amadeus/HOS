/************************************************************************************************************************
Name            : NI_Scheduled_DIHistory_Batch Batchable Class
Author          : Sean Harris
Created Date    : 7/28/2014
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-010621 - Product Group Consolidation Data Project 
Description     : If any of the following fields on Asset is changed:
                :     Name, Annual_Subscription_Amount__c, Cendyn_Location_ID__c, InstallDate, IsHostedDI__c, 
                :     MeetingMatrix_Product_Key__c, Product2Id, PurchaseDate, Quantity_Billed__c, Quantity_Ordered__c, 
                :     Quantity_Provisioned__c, Ship_Date__c, Status, UsageEndDate, Product_Group__c, Product_Line__c, Version__c
                : the WriteHistory__c field gets set to true.
                : The class writes a NI_Deployment_Instance_History__c record for every record flagged then unflags them.
                : 
*************************************************************************************************************************/
global class NI_Scheduled_DIHistory_Batch implements Database.Batchable<sObject>
{

    global NI_Scheduled_DIHistory_Batch()
    {        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator([
            SELECT Id, Name, Annual_Subscription_Amount__c, Cendyn_Location_ID__c, InstallDate,
            IsHostedDI__c, MeetingMatrix_Product_Key__c, Product2.ProductCode, Product2.Name, WriteHistory__c, 
            PurchaseDate, Quantity_Billed__c, Quantity_Ordered__c, Quantity_Provisioned__c, Product_Family__c,
            Ship_Date__c, Status, UsageEndDate, Version__r.Name, Product2Id, Product_Line__c, Product_Group__c, 
            Market_Vision__c 
            FROM Asset
            WHERE WriteHistory__c = true
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Asset> scope)
    {
        
        // A LIST OF ASSETS TO REMOVE CHECK FROM WriteHistory__c
        List<Asset> lstAssetUpdates = new List<Asset>();
        
        // CREATE A LIST OF DEPLOYMENT INSTANCE HISTORY RECORDS TO INSERT
        List<NI_Deployment_Instance_History__c> lstDIHistoryToInsert = new List<NI_Deployment_Instance_History__c>();
        
        // CREATE A SET TO HOLD THE PRODUCT2ID VALUES OF THE DEPLOYMENT INSTANCES IN THE OLDMAPTRIGGER
        Set<Id> SetProduct2Id = new Set<Id>();
        
        // CREATE A SET TO HOLD THE VERSION ID's OF THE DEPLOYMENT INSTANCES IN THE OLDMAPTRIGGER
        Set<Id> SetVersionId = new Set<Id>();
        
        // CREATE A SET TO HOLD THE PRODUCT GROUP ID's OF THE DEPLOYMENT INSTANCES IN THE OLDMAPTRIGGER
        Set<Id> SetGroupId = new Set<Id>();      
        
        for (Asset di: scope)
        {
            SetProduct2Id.add(di.Product2Id);
            SetVersionId.add(di.Version__c);
            SetGroupId.add(di.Product_Group__c);
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
        
        
        //LOOP THROUGH THE NEWTRIGGER LIST OF DEPLOYMENT INSTANCES
        for (Asset a : scope) 
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
            
            if (mapGroup.get(a.Product_Group__c).Name != null)
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
            
            d.Market_Vision__c = a.Market_Vision__c;
            
            lstDIHistoryToInsert.add(d);
            
            a.WriteHistory__c = false;
            lstAssetUpdates.Add(a);
            
        }   
        
        
        //USE DATABASE DML METHOD TO INSERT THE DEPLOYMENT INSTANCE HISTORY RECORDS
        if (lstDIHistoryToInsert.size() > 0)
        {
            Database.SaveResult[] results = Database.Insert(lstDIHistoryToInsert, false);
            for (Database.SaveResult sr1: results)
            {
                if (!sr1.isSuccess())
                {
                    //                    Database.Error err1 = sr1.getErrors()[0];
                    //                    System.debug(err1.getMessage());
                } 
            }             
            
            Database.SaveResult[] srUpdated = Database.Update(lstAssetUpdates, false);
            for (Database.SaveResult sr2: srUpdated)
            {
                if (!sr2.isSuccess())
                {
                    //                    Database.Error err2 = sr2.getErrors()[0];
                    //                    System.debug(err2.getMessage());
                } 
            }  
            
        } 
        
        
    }
    
    global void finish(Database.BatchableContext bc)
    {
    }

}