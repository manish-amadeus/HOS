/****************************************************************************************
Name            : NI_CancellationChildCancellationController Class
Author          : Stuart Emery
Created Date    : 1/22/2015
Last Mod Date   : 1/22/2015
Last Mod By     : Stuart Emery
NICC Reference  : NICC-008353
Description     : Controller for the NI_CancellationChildAccountsVF Visualforce page.
                : This controller displays the Deployment Instance records of Accounts
                : that have the Account of the current NI Cancellation record as the
                : Parent Account. Only Deployment Instances that match the DI of the
                : current NI Cancellation record are displayed                
******************************************************************************************/
public with sharing class NI_CancellationChildCancellationCtrlr 
{
    
    NI_Cancellation__c cxl {get; set;}
    public List<childCancellationWrapper> lstChildCancellations {get; set;}	// WRAPPER CLASS LIST TO HOLD THE CHILD ACCOUNTS 
    public Boolean bShowCancel {get; set;}		// USED TO CONDITIONALLY RENDER THE CANCEL BUTTON  
    public Boolean bShowCreate {get; set;}		// USED TO CONDITIONALLY RENDER THE CREATE CANCELLATION RECORDS BUTTON  
    public Boolean bShowClose {get; set;}		// USED TO CONDITIONALLY RENDER THE CLOSE BUTTON  
    
    
    public NI_CancellationChildCancellationCtrlr(ApexPages.StandardController stdController)
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
            getChildCancellations();                        
            
        }
		
    }
    
    // QUERY TO RETURN A LIST OF CHILD DEPLOYMENT INSTANCES AND ACCOUNTS
    public List<childCancellationWrapper> getChildCancellations()
    {
        
        bShowCancel = false;
        bShowCreate = false;
        bShowClose = true;
        
        if (lstChildCancellations == null) 
        {
            lstChildCancellations = new List<childCancellationWrapper>();
            for (NI_Cancellation__c nic: [SELECT nic2.Id, nic2.Name, nic2.Account__r.Name, nic2.Account__r.AccountNumber, nic2.Deployment_Instance__r.Product2.ProductCode, 
                                          nic2.Status__c, nic2.Reviewed_By_Fulfillment__c, nic2.Deployment_Instance__r.Name, nic2.Deployment_Instance__r.Status           
                                          FROM NI_Cancellation__c nic2
                                          WHERE nic2.Master_Cancellation_Record__c =: cxl.Id
                                          ORDER BY nic2.Account__r.Name ASC]) 
            {
                // AS EACH DEPLOYMENT INSTANCE RECORD IS PROCESSED WE CREATE A NEW childCancellationWrapper OBJECT AND ADD IT TO THE lstChildAccounts LIST
                lstChildCancellations.add(new childCancellationWrapper(nic, cxl.Status__c));
            }
        }
        
        if (lstChildCancellations.size() > 0)
        {
            bShowCancel = true;
            bShowCreate = true;
            bShowClose = false;
        }  

        return lstChildCancellations;
        
    } 
    
    public PageReference saveSelected() 
    {
        
        bShowCancel = false;
        bShowCreate = false;
        bShowClose = true; 
        
        List<NI_Cancellation__c> lstSelectedCancellations = new List<NI_Cancellation__c>();  
        
        // Map to store child cancellation reviewed by fulfillment
        Map<Id, Boolean> reviewedStatus = new Map<Id, Boolean>();
        Map<Id, String> childStatus = new Map<Id, String>();
        
        // LIST OF NI CANCELLATION RECORDS TO INSERT  
        List<NI_Cancellation__c> lstNICancellationsToUpdate = new List<NI_Cancellation__c>();
                   
        for (childCancellationWrapper w : lstChildCancellations) 
        {
            reviewedStatus.put(w.idNic, w.isReviewedSelected);
            // Check for checked status to update it with master record.
            if (w.isStatusSelected == true) 
            {
                childStatus.put(w.idNic, cxl.Status__c);
            } 
            lstSelectedCancellations.add(w.c);
        } 
        
        for (NI_Cancellation__c nc : lstSelectedCancellations)
        {
            if (childStatus.get(nc.Id) != null)
            {
                nc.Status__c = childStatus.get(nc.Id);  
            }    
            nc.Reviewed_By_Fulfillment__c = reviewedStatus.get(nc.Id);                                     
            lstNICancellationsToUpdate.add(nc);
        }      
        
        // USE DATABASE DML METHOD TO UPDATE ALL OF THE SELECTED AND NON-SELECTED RECORDS
        if (lstNICancellationsToUpdate.size() > 0)
        {
            
            integer intSuccess = 0;
            Database.SaveResult[] results = Database.update(lstNICancellationsToUpdate,false);
            
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage())); 
                }
                else
                {
                    system.debug('Successfully updated NI Cancellation record. NI CANCELLATION ID: ' + sr.getId());
                }
            }
            
            return new PageReference('javascript:window.close()');

        }
		
        return null;
        
    }      
    
    //============================================================================================================                  
    // WRAPPER CLASS 
    //============================================================================================================ 
    public class childCancellationWrapper 
    {
        
        public NI_Cancellation__c c {get; set;}
        public Boolean isSelected {get; set;}
        public Boolean isStatusSelected {get; set;}
        public Boolean isReviewedSelected {get; set;}
//        public Boolean isDisabled {get; set;}
//        public Boolean disableEdit {get; set;}
//        public Boolean disableSave {get; set;}
//        public Boolean disableCancel {get; set;}
        public Id idNic {get; set;}
        public Boolean statusDisable{get;set;}
        
        public childCancellationWrapper(NI_Cancellation__c nic, String Status) 
        {
            
            c = nic;
            idNic = c.Id;
            isSelected = false;
            
            isReviewedSelected = c.Reviewed_By_Fulfillment__c;
            //Check if Child status match with master record set statusSelected flag true
            if (c.Status__c == Status) 
            {
                isStatusSelected = true;
                statusDisable = true;
            } 
            else  
            {
                isStatusSelected = false;
                statusDisable = false;
            }
            
        }
        
    }
    
}