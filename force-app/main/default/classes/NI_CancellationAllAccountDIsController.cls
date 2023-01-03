/****************************************************************************************
Name            : NI_CancellationAllAccountDIsController Class
Author          : Stuart Emery
Created Date    : 09/27/2013
Last Mod Date   : 01/20/2015
Last Mod By     : Stuart Emery
NICC Reference  : NICC-008353
Description     : Controller for the NI_CancellationAllAccountDIsVF Visualforce page.
                : This controller displays all of the Deployment Instance records of 
                : the Account of the current NI Cancellation record. 
                :  
******************************************************************************************/
public with sharing class NI_CancellationAllAccountDIsController 
{
    
    NI_Cancellation__c cxl {get; set;}
    public List<AccountDIWrapper> lstAllDIs {get; set;}	// WRAPPER CLASS LIST TO HOLD THE CHILD ACCOUNTS 
    public Boolean bShowCancel {get; set;}				// USED TO CONDITIONALLY RENDER THE CANCEL BUTTON  
    public Boolean bShowCreate {get; set;}				// USED TO CONDITIONALLY RENDER THE CREATE CANCELLATION RECORDS BUTTON  
    public Boolean bShowClose {get; set;}				// USED TO CONDITIONALLY RENDER THE CLOSE BUTTON      
    
    
    public NI_CancellationAllAccountDIsController(ApexPages.StandardController stdController)
    {                                  
        
        if (ApexPages.CurrentPage().getParameters().containsKey('id')) 
        {  
            
            Id cxlId = ApexPages.CurrentPage().getParameters().get('id');
            
            cxl = ([SELECT Id, Deployment_Instance__c, Reviewed_By_Fulfillment__c, Management_Company__c, Account__c, 
                    Account__r.Name, Product_Code__c, Effective_Date__c, General_Reason__c, 
                    Specific_Reason__c, Status__c, Competitor_Lost_To__c, Contact__c, 
                    Engagement__c, Cancellation_Notes__c 
                    FROM NI_Cancellation__c 
                    WHERE Id =: cxlId 
                    LIMIT 1]);             
            
            // CALL THE METHODS TO POPULATE THE LISTS
            getAllDIs();                        
            
        }        
        
    }
    
    //QUERY TO RETURN A LIST OF CHILD DEPLOYMENT INSTANCES AND ACCOUNTS
    public List<AccountDIWrapper> getAllDIs()
    {
        
        bShowCancel = false;
        bShowCreate = false;
        bShowClose = true;
        
        List<NI_Cancellation__c> lstAllCancellations = [SELECT Id, Name, Deployment_Instance__c 
                                                        FROM NI_Cancellation__c
                                                        WHERE Account__c =: cxl.Account__c];
        Set<Id> setDIs = new Set<Id>();    
        
        If(lstAllCancellations.size()>0)
        {
            for (NI_Cancellation__c nic : lstAllCancellations)
            {
                setDIs.Add(nic.Deployment_Instance__c);
            }         
        }
        
        if (lstAllDIs == null) 
        {
            lstAllDIs = new List<AccountDIWrapper>();
            for (Asset di: [SELECT a.Id, a.AccountId, a.Account.Name, a.Account.AccountNumber, 
                            a.Account.ParentId, a.Name, a.Product2.ProductCode, 
                            a.Product2.Family,a.Status,a.Quantity 
                            FROM Asset a
                            WHERE a.AccountId = : cxl.Account__c
                            AND a.Product2.ProductCode != : cxl.Product_Code__c
                            AND a.Status != 'Inactive'
                            AND a.Id NOT IN : setDIs      
                            ORDER BY a.Name ASC]) 
            {
                
                //AS EACH DEPLOYMENT INSTANCE RECORD IS PROCESSED WE CREATE A NEW childAccountWrapper OBJECT AND ADD IT TO THE  lstAllDIs LIST
                lstAllDIs.add(new AccountDIWrapper(di));
            }
        }
        
        if (lstAllDIs.size()>0)
        {
            bShowCancel = true;
            bShowCreate = true;
            bShowClose = false;
        }  
        
        return lstAllDIs;
        
    } 
    
    public PageReference saveSelected() 
    {
        
        bShowCancel = false;
        bShowCreate = false;
        bShowClose = true;         
        
        //LIST OF SELECTED DEPLOYMENT INSTANCE ASSETS
        List<Asset> lstSelectedAssets = new List<Asset>();  
        
        //LIST OF NI CANCELLATION RECORDS TO INSERT  
        List<NI_Cancellation__c> lstNICancellationsToInsert = new List<NI_Cancellation__c>();
        
        //WE LOOP THROUGH OUR lstAllDIs LIST TO SEE IF THE SELECTED PROPERTY IS SET TO TRUE AND ADD THE RECORD TO THE lstSelectedAssets LIST OR THE
        for (AccountDIWrapper w: lstAllDIs) 
        {
            if (w.isSelected == true) 
            {
                lstSelectedAssets.add(w.Di);
            }
        } 
        
        //LOOP THROUGH THE lstSelectedAssets LIST OF SELECTED RECORDS AND ADD THEM TO THE lstNICancellationsToInsert LIST 
        for (asset a : lstSelectedAssets)
        {
            NI_Cancellation__c nc = new NI_Cancellation__c();
            nc.Master_Cancellation_Record__c = cxl.Id;
            nc.Deployment_Instance__c = a.Id;
            nc.General_Reason__c = cxl.General_Reason__c;
            nc.Specific_Reason__c = cxl.Specific_Reason__c;
            nc.Effective_Date__c = cxl.Effective_Date__c;
            nc.Status__c = cxl.Status__c;
            nc.Competitor_Lost_To__c = cxl.Competitor_Lost_To__c;
            nc.Contact__c = cxl.Contact__c;
            nc.Engagement__c = cxl.Engagement__c;
            nc.Cancellation_Notes__c = cxl.Cancellation_Notes__c;   
            lstNICancellationsToInsert.add(nc);
        }
        
        //USE DATABASE DML METHOD TO INSERT THE NEW CANCELLATION RECORDS
        if (lstNICancellationsToInsert.size() > 0)
        {
            integer intSuccess = 0;
            Database.SaveResult[] results = Database.insert(lstNICancellationsToInsert,false);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,err.getMessage())); 
                }
                else
                {
                    intSuccess += 1;
                    system.debug('Successfully inserted NI Cancellation record. NI CANCELLATION ID: ' + sr.getId());
                }
            }
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Total NI Cancellation records created:  ' + intSuccess));
        }
        
        return null;
        
    }      
    
    //============================================================================================================                  
    // WRAPPER CLASS 
    //============================================================================================================ 
    public class AccountDIWrapper 
    {
        
        public Asset di {get; set;}
        public Boolean isSelected {get; set;}
//        public Boolean isDisabled {get; set;}
//        public Boolean disableEdit {get; set;}
//        public Boolean disableSave {get; set;}
//        public Boolean disableCancel {get; set;}
        public Id idAsset {get; set;}
        
        public AccountDIWrapper(Asset a) 
        {
            di = a;
            idAsset = di.Id;
            isSelected = false;
        }
        
    }
    
}