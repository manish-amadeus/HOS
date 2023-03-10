/****************************************************************************************
Name            : AH_ActivityLineItemCancExt Class
Author          : Ria Chawla
Created Date    : 08/03/2017
Last Mod Date   : 08/08/2017
Last Mod By     : Ria Chawla
NICC Reference  : 
Description     : Controller for the AH_ActivityLineItemsCancView Visualforce page 
                : The AH_ActivityLineItemsCancView page is used by the Contracts Team 
                : to identify Activity Line Items that need to be cancelled as part of the 
                : related Cancellation record. 
******************************************************************************************/
public class AH_ActivityLineItemCancExt 
{
    
    private NI_Cancellation__c cancObj;
    
    // USED TO ENABLE OR DISABLE THE CANCEL CHECKBOX ON THE VF PAGE  
    public Boolean bDisabled {get; set;}
    
    // WRAPPER CLASS LIST TO HOLD THE ACTIVITY LINE ITEMS
    public List<actLineItemWrapper> lstActLineItems {get; set;}
    
    public AH_ActivityLineItemCancExt(ApexPages.StandardController stdController)
    {     
        NI_Cancellation__c cn = (NI_Cancellation__c)stdController.getRecord();
        this.cancObj = [SELECT Id, Account__c, Product2__c FROM NI_Cancellation__c WHERE Id =: cn.Id];
        // CALL THE METHODS TO POPULATE THE LISTS
        disableListEdit();      
        //EnableListEdit();
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
        
        for (Activity_Line_Item__c ali : 
             [SELECT Id, Name, Cancel_Line_Item__c, SKU__c, Product__r.Name, Contract_Start_Date__c, Contract_End_Date__c, Units__c, Status__c, 
              Contract_Total_Amount_Currency__c, Flagged_For_Cancellation_Reason__c, Flagged_For_Cancellation_Record__c,
              Billing_Contract__c, Product__c
              FROM Activity_Line_Item__c 
              WHERE Billing_Contract__r.Account__c =: cancObj.Account__c 
              AND Product__c =: cancObj.Product2__c
              AND Status__c = 'Active' 
              ORDER BY Product_Description__c]) 
        {
            system.debug('ali'+ali);
            lstActLineItems.add(new actLineItemWrapper(ali));
        }   
        
        return lstActLineItems;
        
    } 
    
    public PageReference saveSelected() 
    {        
        
        // LIST OF ACTIVITY LINE ITEMS THAT WILL BE POPULATED WITH ONLY THE SELECTED ACTIVITY LINE ITEMS
        List<Activity_Line_Item__c> lstSelectedLineItems = new List<Activity_Line_Item__c>();

        Set<Id> selBillingContractIdSet = new Set<Id>();
        Set<Id> selProductIdSet = new Set<Id>();
        
        /* COMMENTED THIS FUNCTIONALITY PER HEATHER'S REQUEST 
        //Set<Id> nonselBillingContractIdSet = new Set<Id>();
        //Set<Id> nonselProductIdSet = new Set<Id>();
        List<c2g__codaInvoiceLineItem__c> selSalesInvLineItemList = new List<c2g__codaInvoiceLineItem__c>();
        //List<c2g__codaInvoiceLineItem__c> nonSelsalesInvLineItemList = new List<c2g__codaInvoiceLineItem__c>();
        List<c2g__codaInvoiceLineItem__c> salesInvLineItemToUpdate = new List<c2g__codaInvoiceLineItem__c>();
        Map<String, c2g__codaInvoiceLineItem__c> mapInvLineItem = new Map<String, c2g__codaInvoiceLineItem__c>();
        */
        
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
                //selBillingContractIdSet.add(li.ali.Billing_Contract__c);
                //selProductIdSet.add(li.ali.Product__c);
            } 
            
            selBillingContractIdSet.add(li.ali.Billing_Contract__c);
            selProductIdSet.add(li.ali.Product__c);
        }  
        
        /* COMMENTED THIS FUNCTIONALITY PER HEATHER'S REQUEST 
        system.debug('selBillingContractIdSet'+selBillingContractIdSet);
        system.debug('selProductIdSet'+selProductIdSet);
        if (selBillingContractIdSet.size() > 0 || selProductIdSet.size() > 0)
        {
            selSalesInvLineItemList = [SELECT Id, Name, Activity_Line_Item__c, c2g__Invoice__c, c2g__Product__c,
                                       Billing_Contract__c FROM c2g__codaInvoiceLineItem__c
                                       WHERE Billing_Contract__c IN :selBillingContractIdSet AND
                                       c2g__Product__c IN :selProductIdSet];
        }
		
        
        for (c2g__codaInvoiceLineItem__c invLineItem : selSalesInvLineItemList)
        {
            String mapKey = invLineItem.Billing_Contract__c+''+invLineItem.Activity_Line_Item__c+''+invLineItem.c2g__Product__c;
            mapInvLineItem.put(mapKey, invLineItem);
        }
        */
        
        // LOOP THROUGH THE lstSelectedLineItems LIST AND SET THE Cancel__c FIELD TO 'TRUE' FOR THE SELECTED RECORDS AND ADD THEM TO THE lstActLineItemsToUpdate LIST 
        for (Activity_Line_Item__c s : lstSelectedLineItems)
        {
            if (s.Flagged_For_Cancellation_Reason__c == null)
            { 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AH_ActivityLineItemOpptyView_Save_Error));
            }
            else
            {
                s.Cancel_Line_Item__c = true;
                s.Flagged_For_Cancellation_Record__c = cancObj.Id;
                lstActLineItemsToUpdate.add(s);
                /* COMMENTED THIS FUNCTIONALITY PER HEATHER'S REQUEST 
                String searchKey = s.Billing_Contract__c+''+s.Id+''+s.Product__c;
                
                if(mapInvLineItem.containsKey(searchKey)){
                    c2g__codaInvoiceLineItem__c invObjectToUpdate = mapInvLineItem.get(searchKey);
                    invObjectToUpdate.Flagged_For_Cancellation_Record__c = cancObj.Id;
                    invObjectToUpdate.Flagged_For_Cancellation__c = true;
                    invObjectToUpdate.Flagged_For_Cancellation_Reason__c = s.Flagged_For_Cancellation_Reason__c;
                    salesInvLineItemToUpdate.add(invObjectToUpdate);
                }
				*/
            }     
        }
        
        // LOOP THROUGH THE lstNonSelectedLineItems LIST AND SET THE Cancel__c FIELD TO 'FALSE' FOR THE SELECTED RECORDS AND ADD THEM TO THE lstActLineItemsToUpdate LIST   
        for (Activity_Line_Item__c n : lstNonSelectedLineItems)
        {

            n.Cancel_Line_Item__c = false;
            n.Flagged_For_Cancellation_Record__c = null;
            n.Flagged_For_Cancellation_Reason__c = null;
            lstActLineItemsToUpdate.add(n);
            /* COMMENTED THIS FUNCTIONALITY PER HEATHER'S REQUEST 
            String searchKey = n.Billing_Contract__c+''+n.Id+''+n.Product__c;

            if(mapInvLineItem.containsKey(searchKey)){
                c2g__codaInvoiceLineItem__c invObjectToUpdate = mapInvLineItem.get(searchKey);
                invObjectToUpdate.Flagged_For_Cancellation_Record__c = null;
                invObjectToUpdate.Flagged_For_Cancellation__c = false;
                invObjectToUpdate.Flagged_For_Cancellation_Reason__c = null;
                salesInvLineItemToUpdate.add(invObjectToUpdate);
            }
			*/
        }  

		/* COMMENTED THIS FUNCTIONALITY PER HEATHER'S REQUEST        
        for(c2g__codaInvoice__c salesInv : salesInvList)
		{
            system.debug('in sales inv for each');
            if(!selectedMap.isEmpty())
			{
                SYSTEM.debug('selectedMap');
                if(selectedMap.containsKey(salesInv.Billing_Contract__c)){
                    salesInv.Cancel_Invoice__c = true;
                    salesInv.Flagged_For_Cancellation_Record__c = cancObj.Id;
                    if(billingIdCancReason.containsKey(salesInv.Billing_Contract__c)){
                        salesInv.Flagged_For_Cancellation_Reason__c = billingIdCancReason.get(salesInv.Billing_Contract__c);
                    }
                    salesInvListToUpdate2.add(salesInv);
                }
            }
            system.debug('check');
            if(!nonSelectedMap.isEmpty()){
                SYSTEM.debug('nonSelectedMap');
                if(nonSelectedMap.containsKey(salesInv.Billing_Contract__c)){
                    salesInv.Cancel_Invoice__c = false;
                    salesInv.Flagged_For_Cancellation_Record__c = null;
                    salesInv.Flagged_For_Cancellation_Reason__c = null;
                    salesInvListToUpdate.add(salesInv);
                }
            }
            
        }
		*/
        
        // USE DATABASE DML METHOD TO UPDATE ALL OF THE SELECTED AND NON-SELECTED RECORDS
        if (lstActLineItemsToUpdate.size() > 0)
        {
            database.update(lstActLineItemsToUpdate);
        } 
        
// COMMENTED THIS FUNCTIONALITY PER HEATHER'S REQUEST         
//        if (!salesInvLineItemToUpdate.isEmpty())
//        {
//            database.update(salesInvLineItemToUpdate);
//        }
        
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
        
        public actLineItemWrapper(Activity_Line_Item__c a) 
        {
            ali = a;
            idActLineItem = ali.Id;  
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