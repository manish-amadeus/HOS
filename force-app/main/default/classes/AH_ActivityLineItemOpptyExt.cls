/****************************************************************************************
Name            : AH_ActivityLineItemOpptyExt Class
Author          : Stuart Emery
Created Date    : 10/06/2013
Last Mod Date   : 08/15/2019
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Controller for the AH_ActivityLineItemOpptyExt Visualforce page 
                : The AH_ActivityLineItemOpptyExt page is used by the Contracts Team 
                : to identify Activity Line Items that need to be cancelled as part of the 
                : related Opportunity.
                : Updated 08/15/2019 Per NICC-036683
******************************************************************************************/
public with sharing class AH_ActivityLineItemOpptyExt 
{
    
    private Opportunity o;
    
    // USED TO ENABLE OR DISABLE THE CANCEL CHECKBOX ON THE VF PAGE  
    public Boolean bDisabled {get; set;}
       
    // WRAPPER CLASS LIST TO HOLD THE ACTIVITY LINE ITEMS
    public List<actLineItemWrapper> lstActLineItems {get; set;}
    
    
    public AH_ActivityLineItemOpptyExt(ApexPages.StandardController stdController)
    {        
        this.o = (Opportunity)stdController.getRecord();        
        // CALL THE METHODS TO POPULATE THE LISTS
        disableListEdit();        
    } 
    
    //METHOD TO POPULATE A PICKLIST WITH THE VALUES FROM THE FLAGGED FOR CANCELLATION REASON FIELD.  ADDED BY STUART EMERY ON 5/17/2017
    public List<SelectOption> getFlaggForCancellationReasonOptionList(){
        List<SelectOption> selOptionLst = new List<SelectOption>();
        Schema.DescribeFieldResult al = Activity_Line_Item__c.Flagged_For_Cancellation_Reason__c.getDescribe();
        List<Schema.PickListEntry> reasonList = al.getPickListValues();
        selOptionLst.add(new SelectOption('','--None--'));
        for(Schema.PickListEntry obj:reasonList){
            selOptionLst.add(new SelectOption(obj.getLabel(),obj.getValue()));
        }
        return selOptionLst;
    }
    
    public void disableListEdit()
    {
        bDisabled = true;
        getActivityLineItems(); 
    }
    
    public void EnableListEdit()
    {
        bDisabled = false;
        getActivityLineItems();
    }
    
    // QUERY TO RETURN A LIST OF ACTIVITY LINE ITEMS
    public List<actLineItemWrapper> getActivityLineItems() 
    {
        
        lstActLineItems = new List<actLineItemWrapper>();
        
        //Updated 08/15/2019 Per NICC-036683
        for (Activity_Line_Item__c ali : 
             [SELECT Id, Name, Cancel_Line_Item__c, SKU__c, Product__r.Name, Contract_Start_Date__c, Contract_End_Date__c, Units__c, Status__c, 
              Contract_Total_Amount_Currency__c, Flagged_For_Cancellation_Reason__c, Product_Package__c, Product_Package__r.Name  
              FROM Activity_Line_Item__c 
              WHERE Billing_Contract__r.Account__c =: o.AccountId 
              AND Status__c = 'Active' 
              ORDER BY Product_Description__c]) 
        {
            lstActLineItems.add(new actLineItemWrapper(ali));
        }   
        
        return lstActLineItems;
        
    } 
    
    public PageReference saveSelected() 
    {        
        
        // LIST OF ACTIVITY LINE ITEMS THAT WILL BE POPULATED WITH ONLY THE SELECTED ACTIVITY LINE ITEMS
        List<Activity_Line_Item__c> lstSelectedLineItems = new List<Activity_Line_Item__c>();
        
        // LIST OF ACTIVITY LINE ITEMS THAT WILL BE POPULATED WITH ONLY THE NON-SELECTED ACTIVITY LINE ITEMS
        List<Activity_Line_Item__c> lstNonSelectedLineItems = new List<Activity_Line_Item__c>();  
        
        // LIST OF SELECTED ACTIVITY LINE ITEMS TO UPDATE  
        List<Activity_Line_Item__c> lstActLineItemsToUpdate = new List<Activity_Line_Item__c>();
        
        // LOOP THROUGH OUR lstActLineItems LIST TO SEE IF THE SELECTED PROPERTY IS SET TO TRUE AND ADD THE RECORD TO THE lstSelectedAssets LIST OR THE lstNonSelectedLineItems LIST
        for (actLineItemWrapper li : lstActLineItems) 
        {   
            if (li.isSelected == true) 
            {
                lstSelectedLineItems.add(li.ali);
            }
            else
            {
                lstNonSelectedLineItems.add(li.ali);
            }  
        } 
        
        // LOOP THROUGH THE lstSelectedLineItems LIST AND SET THE Cancel__c FIELD TO 'TRUE' FOR THE SELECTED RECORDS AND ADD THEM TO THE lstActLineItemsToUpdate LIST 
        for (Activity_Line_Item__c s : lstSelectedLineItems)
        {
            if(s.Flagged_For_Cancellation_Reason__c == null)
            { 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.AH_ActivityLineItemOpptyView_Save_Error));
            }
            else
            {
                    s.Cancel_Line_Item__c = true;
                    s.Flagged_For_Cancellation_Opportunity__c = o.Id;
                    lstActLineItemsToUpdate.add(s);
            }     
                }
        
        // LOOP THROUGH THE lstNonSelectedLineItems LIST AND SET THE Cancel__c FIELD TO 'FALSE' FOR THE SELECTED RECORDS AND ADD THEM TO THE lstActLineItemsToUpdate LIST   
        for (Activity_Line_Item__c n : lstNonSelectedLineItems)
        {
            n.Cancel_Line_Item__c = false;
            n.Flagged_For_Cancellation_Opportunity__c = null;
            n.Flagged_For_Cancellation_Reason__c = null;
            lstActLineItemsToUpdate.add(n);
        }   
        
        // USE DATABASE DML METHOD TO UPDATE ALL OF THE SELECTED AND NON-SELECTED RECORDS
        if (lstActLineItemsToUpdate.size() > 0)
        {
            database.update(lstActLineItemsToUpdate);
        }                     
        
        // SET THE LIST TO NULL SO A NEW LIST IS CREATED
        lstActLineItems.Clear(); 
        disableListEdit(); 
        
        return null;
        
    }
    
    public pageReference changeSelected()
    {
        //if (li.isSelected == true)
        //{
        
        // }
        return null;
    }
    
    // WRAPPER CLASS TO BUILD THE SOFTRAX ASSETS LIST  
    public class actLineItemWrapper 
    {
        public Activity_Line_Item__c ali {get; set;}
        public Boolean isSelected {get; set;}
        public Id idActLineItem {get; set;}
        public Id idProductPackage {get; set;} //ADDED 08/15/2019 Per NICC-036683
        
        public actLineItemWrapper(Activity_Line_Item__c a) 
        {
            ali = a;
            idActLineItem = ali.Id;
            idProductPackage = ali.Product_Package__c; //ADDED 08/15/2019 Per NICC-036683
            if (ali.Cancel_Line_Item__c) 
            {
                isSelected = true;
            }
            else
            {
                isSelected = false; 
            }
        }
    }
    
}