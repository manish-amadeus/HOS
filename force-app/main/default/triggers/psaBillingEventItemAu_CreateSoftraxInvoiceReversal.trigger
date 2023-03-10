/****************************************************************************************
Name            : psaBillingEventItemAu_CreateSoftraxInvoiceReversal
Author          : CLD
Created Date    : November 30, 2011
Description     : When a a billing event item has just been updated with a value of TRUE in its 
                : Reverse Softrax Invoicing field, this creates a Softrax Invoice Reversal record, 
                : allowing the Softrax integration process to get a record of the needed reversal, 
                : so that the billing data for the related milestone or expense can be cleared.  
                : This will allow the milestone or expense to be adjusted and reapproved once the
                : Clear Billing Data function is used.
******************************************************************************************/
trigger psaBillingEventItemAu_CreateSoftraxInvoiceReversal on pse__Billing_Event_Item__c (after update) 
{
    public static final String SOFTRAX_STATUS_REVERSE = 'Submitted for Reversal';
    List<Softrax_Invoice_Reversal__c> reversalsToCreate = new List<Softrax_Invoice_Reversal__c>();
    
    // Get list of Billing Events for parent object lookups
    List<Id> beIds = new List<Id>();
    for(pse__Billing_Event_Item__c b : Trigger.New)
    {
        beIds.add(b.pse__Billing_Event__c);
    }
    
    Map<Id, pse__Billing_Event__c> billingEvents = new Map<Id, pse__Billing_Event__c> (
        [SELECT pse__Summary_Amount__c, pse__Status__c, pse__Skip_Sync_Check__c, pse__Project__c, pse__Is_Released__c, 
            pse__Is_Approved__c, pse__Invoiced__c, pse__Invoice_Number__c, pse__Invoice_Date__c, pse__Event_Key__c, 
            pse__Date__c, pse__Budget_Remaining__c, pse__Billing_Event_Batch__c, pse__Billing_Contact__c, 
            pse__Approver__c, SystemModstamp, OwnerId, Name, LastModifiedDate, LastModifiedById, 
            IsDeleted, Id, CurrencyIsoCode, CreatedDate, CreatedById 
            FROM pse__Billing_Event__c WHERE Id IN :beIds]);
    
    for(pse__Billing_Event_Item__c item : Trigger.New)
    {
        boolean oldInvoiceReverse = Trigger.OldMap.get(item.Id).Reverse_Softrax_Invoicing__c;
        if(item.Reverse_Softrax_Invoicing__c==true && oldInvoiceReverse==false)
        {
            // Reverse Invoicing was just set. Create the record.
            Softrax_Invoice_Reversal__c reversal = new Softrax_Invoice_Reversal__c();
            pse__Billing_Event__c billingEvent = billingEvents.get(item.pse__Billing_Event__c);
    
            reversal.beId__c = billingEvent.Id;
            reversal.beCreatedBy__c = billingEvent.CreatedById;
            reversal.beCurrencyIsoCode__c = billingEvent.CurrencyIsoCode;
            reversal.beLastModifiedBy__c = billingEvent.LastModifiedById;
            reversal.beName__c = billingEvent.Name;

            DateTime beCreateDT = billingEvent.CreatedDate;
            Date beCreateDate = Date.newinstance(beCreateDT.year(), beCreateDT.month(), beCreateDT.day());
            reversal.beCreatedDate__c = beCreateDate;
            
            reversal.beIsDeleted__c = billingEvent.IsDeleted;
            
            Date beLMD = null;
            DateTime beLMDT = billingEvent.LastModifiedDate;
            if(beLMDT != null)
            {
                beLMD = Date.newinstance(beLMDT.year(), beLMDT.month(), beLMDT.day());
            }
            reversal.beLastModifiedDate__c = beLMD;
            reversal.beOwnerId__c = billingEvent.OwnerId;
            reversal.bePse_Approver__c = billingEvent.pse__Approver__c;
            reversal.bePse_Billing_Contact__c = billingEvent.pse__Billing_Contact__c;
            reversal.bePse_Billing_Event_Batch__c = billingEvent.pse__Billing_Event_Batch__c;
            reversal.bePse_Budget_Remaining__c = billingEvent.pse__Budget_Remaining__c;
            reversal.bePse_Date__c = billingEvent.pse__Date__c;
            reversal.bePse_Event_Key__c = billingEvent.pse__Event_Key__c;
            reversal.bePse_Invoice_Date__c = billingEvent.pse__Invoice_Date__c;
            reversal.bePse_Invoice_Number__c = billingEvent.pse__Invoice_Number__c;
            reversal.bePse_Invoiced__c = billingEvent.pse__Invoiced__c;
            reversal.bePse_Is_Approved__c = billingEvent.pse__Is_Approved__c;
            reversal.bePse_Is_Released__c = billingEvent.pse__Is_Released__c;
            reversal.bePse_Project__c = billingEvent.pse__Project__c;
            reversal.bePse_Skip_Sync_Check__c = billingEvent.pse__Skip_Sync_Check__c;
            reversal.bePse_Status__c = SOFTRAX_STATUS_REVERSE;
            reversal.bePse_Summary_Amount__c = billingEvent.pse__Summary_Amount__c;
            
            DateTime beSMDT = billingEvent.SystemModstamp;
            Date beSMD = null;
            if(beSMDT != null)
            {
                beSMD = Date.newinstance(beSMDT.year(), beSMDT.month(), beSMDT.day());
            }
            reversal.beSystemModstamp__c = beSMD;
            
            reversal.beiCreatedById__c = item.CreatedById;
            
            DateTime beiCDT = item.CreatedDate;
            Date beiCD = null;
            if(beiCDT != null)
            {
                beiCD = Date.newinstance(beiCDT.year(), beiCDT.month(), beiCDT.day());
            }
            reversal.beiCreatedDate__c = beiCD;
            
            reversal.beiCurrencyIsoCode__c = item.CurrencyIsoCode;
            reversal.beiDetails_For_Invoice__c = item.Details_For_Invoice__c;
            reversal.beiId__c = item.Id;
            reversal.beiIsDeleted__c = item.IsDeleted;
            reversal.beiLastModifiedById__c = item.LastModifiedBy.Id;
            
            DateTime beiLMDT = item.LastModifiedDate;
            Date beiLMD = null;
            if(beiLMDT != null)
            {
                beiLMD = Date.newinstance(beiLMDT.year(), beiLMDT.month(), beiLMDT.day());
            }
            reversal.beiLastModifiedDate__c = beiLMD;
            
            reversal.beiManaged_Property_Name__c = item.Managed_Property_Name__c;
            reversal.beiName__c = item.Name;
            reversal.beiOwnerId__c = item.Owner.Id;
            reversal.beiReverse_Softrax_Invoicing__c = item.Reverse_Softrax_Invoicing__c;
            reversal.beiSoftrax_Order_Sequence_Number__c = item.Softrax_Order_Sequence_Number__c;
            reversal.beiSystemModstamp__c = item.SystemModstamp;
            reversal.beiPse_Billing_Event__c = item.pse__Billing_Event__c;
            reversal.beiPse_Billing_Event_Batch__c = item.pse__Billing_Event_Batch__c;
            reversal.beiPse_Category__c = item.pse__Category__c;
            reversal.beiPse_Date__c = item.pse__Date__c;
            reversal.beiPse_Description__c = item.pse__Description__c;
            reversal.beiPse_Object_Id__c = item.pse__Object_Id__c;
            reversal.beiPse_Project__c = item.pse__Project__c;
            reversal.beiPse_Quantity__c = item.pse__Quantity__c;
            reversal.beiPse_Subcategory__c = item.pse__Subcategory__c;
            reversal.beiPse_Unit_Price__c = item.pse__Unit_Price__c;
            reversal.beiPse_Amount__c = item.pse__Amount__c;
            
            reversalsToCreate.add(reversal);
            
            System.debug('Setting billing event item for reversal: ' + item.Name);
        }
    }
    
    // Create reversals
    if(reversalsToCreate.size() > 0)
    {
        Database.SaveResult[] results = Database.insert(reversalsToCreate);
        for(Database.SaveResult sr: results)
        {
            if(!sr.isSuccess())
            {
                Database.Error err = sr.getErrors()[0];
                System.debug(err.getMessage());
            }
        }
    }

}