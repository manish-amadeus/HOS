/***********************************************************************************************
Name            : AH_ProcessCreditNote
Author          : Bhagwat Garkal
Created Date    : 9/23/2021
Last Mod Date   : 12/22/2021
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : Controller for the "Process Credit Note" button to Create Credit Note,Credit Note Line Item and Billing Contract Line Item.  
                :
                :
************************************************************************************************/
public class AH_ProcessCreditNote_Ctlr 
{
    
    public AH_Finance_Request__c financeRequest {get; set;}
    public AH_Finance_Request__c financeRequestDummy;
    public Billing_Contract__c billingContract {get; set;}
    public c2g__codaInvoice__c salesInvoiceObj {get; set;}
    public List<c2g__codaPeriod__c> currentPeriod {get; set;}
    public List<SILWrapper> wrapperList {get; set;}
    public Boolean isProcessCreditNote {get; set;}
    public Id billingContractid {get; set;}
    Public Map<String,Billing_Contract_Line_Item__c> bliMap; 
    Map<string,AH_Finance_Request_to_SIN_Line_Item__c> mapOfSINLineItem;
    public Set<Id> salesInvoiceIds ;
    public Set<Id> invoiceLineitemsIds;
    // CONSTRUCTOR
    public AH_ProcessCreditNote_Ctlr(ApexPages.StandardController controller) 
    {
		this.financeRequest = (AH_Finance_Request__c)controller.getRecord(); 
		fetchData();
	}
	
    // ======================================================
	// FETCH INVOICE LINE ITEM RECORDS FROM FINANCE REQUEST
	// ======================================================
	public void fetchData()
    {
        
        wrapperList = new List<SILWrapper>();
        mapOfSINLineItem = new Map<string,AH_Finance_Request_to_SIN_Line_Item__c>();
        bliMap = new  Map<String,Billing_Contract_Line_Item__c>();
        financeRequestDummy = new AH_Finance_Request__c();
        isProcessCreditNote = false;
        salesInvoiceIds = new Set<Id>();
        if (financeRequest != null )
        {
            
            billingContract = new Billing_Contract__c();
            
            for (AH_Finance_Request__c financeReq : [Select Id,Name,Billing_Contract__c,Credit_Note_Reason__c,Billing_Contract__r.Account__c,Sales_Credit_Note__c,
                                                    Billing_Contract__r.Company__c,Billing_Contract__r.Remittance_Info__c,Reason_Subcategory__c,
                                                    Billing_Contract__r.Accounting_Currency__c,Billing_Contract__r.Opportunity__c,
                                                    Sales_Invoice__r.c2g__Dimension3__c,Sales_Invoice__r.c2g__Period__c,
                                                    Sales_Invoice__r.Billing_Contract__c,Sales_Invoice__r.c2g__Opportunity__c,
                                                    Sales_Invoice__r.c2g__InvoiceCurrency__c,Sales_Invoice__r.c2g__InvoiceDate__c,
                                                    Sales_Invoice__r.c2g__OwnerCompany__c,Sales_Invoice__r.c2g__Account__c,
                                                    Sales_Invoice__r.c2g__Dimension1__c,Sales_Invoice__r.c2g__Dimension4__c,
                                                    Sales_Invoice__r.c2g__Dimension2__c,Sales_Invoice__r.Remittance_Info__c,
                                                    Sales_Invoice__c from  AH_Finance_Request__c where Id =:financeRequest.Id])
            {
                if (financeReq != null && financeReq.Sales_Invoice__c != null )
                {
                    if(financeReq.Sales_Credit_Note__c != null)
                    {
                        isProcessCreditNote = true;
                    }
                    
                    salesInvoiceIds.add(financeReq.Sales_Invoice__c);
                    salesInvoiceObj = financeReq.Sales_Invoice__r;
                    financeRequestDummy = financeReq;
                    //ADDED BY STUART EMERY 10/23/2021
                    //GET THE CORRECT PERIOD TO ADD TO THE CREDIT NOTE
                    currentPeriod = [SELECT Id FROM c2g__codaPeriod__c
                                                        WHERE c2g__OwnerCompany__c =: salesInvoiceObj.c2g__OwnerCompany__c
                                                        AND c2g__Description__c = 'Trading Period'
                                                        AND c2g__StartDate__c = THIS_MONTH
                                                        AND c2g__EndDate__c = THIS_MONTH
                                                        LIMIT 1];
               }
                
               if (financeReq.Billing_Contract__c != null)
               {
                   billingContractid = financeReq.Billing_Contract__c;
                   billingContract = financeReq.Billing_Contract__r;
               }
                
            }
            
            for(AH_Finance_Request_to_SIN_Line_Item__c sinLineItem : [Select Id,Finance_Request__c,Requested_Credit_Amount__c,Sales_Invoice_Line_Item__c,SIN_Line_Item_Net_Value__c 
                                                                      from AH_Finance_Request_to_SIN_Line_Item__c where Finance_Request__c =: financeRequest.Id])
            {
                if(sinLineItem.Sales_Invoice_Line_Item__c != null)
                {
                	mapOfSINLineItem.put(sinLineItem.Sales_Invoice_Line_Item__c,sinLineItem);    
                }   
            }    
            
            
            // Fetch the Finance_Request_to_SIN_Line_Item records
            invoiceLineitemsIds = new Set<Id>();
            for(AH_Finance_Request_to_SIN_Line_Item__c frsli : [Select Id,Sales_Invoice_Line_Item__c,Finance_Request__c from AH_Finance_Request_to_SIN_Line_Item__c where Finance_Request__c =: financeRequest.id])
            {
                if(frsli.Sales_Invoice_Line_Item__c != null)
                {
                	invoiceLineitemsIds.add(frsli.Sales_Invoice_Line_Item__c);     
                }    
            }    
            
           	// CREATEING WRAPPER OBJECT LIST FROM INVOICE LINE ITEM TO DISPLAY ON VF PAGE.
            if (salesInvoiceIds != null && salesInvoiceIds.size() != 0)
            {
                
                for (c2g__codaInvoiceLineItem__c sil : [Select Id, Name,c2g__NetValue__c,Billing_Contract_Line_Item__c,Billing_Contract_Line_Item__r.Revenue_Category__c,Billing_Contract_Line_Item__r.Credit_Processed__c,c2g__Invoice__c,c2g__Product__c,c2g__Product__r.Name,c2g__Quantity__c,
                                                           c2g__UnitPrice__c,Activity_Line_Item__c,
                                                           c2g__LineNumber__c from c2g__codaInvoiceLineItem__c where c2g__Invoice__c IN: salesInvoiceIds and Id IN : invoiceLineitemsIds order by c2g__LineNumber__c asc])
                                                           
                {
                	SILWrapper wrapper = new SILWrapper();
                    wrapper.silObject = sil;
                    wrapper.creditValue = (sil.c2g__NetValue__c).setScale(2);
                    if(mapOfSINLineItem != null && mapOfSINLineItem.containsKey(sil.Id))
                    {
                    	wrapper.unitPrice =  ((mapOfSINLineItem.get(sil.Id).Requested_Credit_Amount__c)*-1).setScale(2);    
                    }    
                    //wrapper.unitPrice =  ((sil.c2g__UnitPrice__c)*-1).setScale(2);
                    wrapper.check = true;
                    
                    if(sil.Billing_Contract_Line_Item__c != null)
                    {
                        wrapper.disabled = sil.Billing_Contract_Line_Item__r.Credit_Processed__c;
                        if(wrapper.disabled == true)
                        {
                        wrapper.check = false;        
                        }    
                        bliMap.put(sil.Billing_Contract_Line_Item__c,sil.Billing_Contract_Line_Item__r);
                    }   
                    wrapperList.add(wrapper);
                }
            }
        }
        
    }
    
    // =========================================================================
	// CREATE CREDIT NOTE,CREDIT NOTE LINE ITEM AND BILLING CONTRACT LINE ITEM.
	// =========================================================================
    public PageReference createBCLI()
    {
        
        List<Billing_Contract_Line_Item__c> newBLIList = new List<Billing_Contract_Line_Item__c>();
        Map<String, String> mapOfNewlyCreatedBLI = new Map<String, String>();
        List<c2g__codaInvoiceLineItem__c> updateSLIWithNewlyCreatedBLI = new List<c2g__codaInvoiceLineItem__c>();
        List<c2g__codaCreditNoteLineItem__c> insertSCNLI = new List<c2g__codaCreditNoteLineItem__c>();
        List<Billing_Contract_Line_Item__c> bliUpdateList = new List<Billing_Contract_Line_Item__c>();
        
        if (wrapperList != null && wrapperList.Size() != 0)
        {
            // GENERATE BLI OBJECT LIST FROM WRAPPER LIST WHICH IS SELECTED. 
            for (SILWrapper wrapper : wrapperList)
            {
                // ADD ONLY SELECTED RECORD
                if (wrapper.check == true)
                {
                	Billing_Contract_Line_Item__c newBLI = new Billing_Contract_Line_Item__c();
                    newBLI.Quantity__c = ((wrapper.unitPrice/wrapper.silObject.c2g__UnitPrice__c)*-1).setScale(2);//wrapper.silObject.c2g__Quantity__c;
                    newBLI.Unit_Price__c = (wrapper.silObject.c2g__UnitPrice__c)*-1;//((wrapper.unitPrice)/wrapper.silObject.c2g__Quantity__c).setScale(2);
                    newBLI.Billing_Contract__c = billingContractid;
                    newBLI.Activity_Line_Item__c = wrapper.silObject.Activity_Line_Item__c;
                    newBLI.Sales_Invoice_Line_Item__c = wrapper.silObject.Id;
                    newBLI.Total_Amount__c = (wrapper.silObject.c2g__Quantity__c * wrapper.silObject.c2g__UnitPrice__c *-1).setScale(2);
                    newBLI.Product__c = wrapper.silObject.c2g__Product__c;
                    newBLI.Invoiced__c = true;
                    newBLI.Revenue_Category__c = wrapper.silObject.Billing_Contract_Line_Item__r.Revenue_Category__c;
                    newBLI.Ready_to_Invoice__c = true;
                    newBLI.Credit_Processed__c = true;
                    newBLIList.add(newbli);
                    
                    // CHECK NEGATIVE PRICE VALIDATION
                    if (wrapper.unitPrice > 0)
                    {
						ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Attention: you must enter a negative amount!')); 
						return null;
					}
                    
                    if(bliMap != null && wrapper.silObject.Billing_Contract_Line_Item__c != null && bliMap.containskey(wrapper.silObject.Billing_Contract_Line_Item__c))
                    {
                       bliUpdateList.add(bliMap.get(wrapper.silObject.Billing_Contract_Line_Item__c)); 
                    }    
                }
            }
            
            try
            {
                System.debug('newBLIList==>'+newBLIList);
                if (newBLIList != null && newBLIList.Size() != 0)
                {
                    Set<Id> bliIds = new Set<Id>();
                    
                    // INSERT BILLING LINE ITEMS
                    Database.SaveResult[] srList = Database.insert(newBLIList, false);
                 
                    for(Integer index = 0, size = srList.size(); index < size; index++)
                    {
                        if(srList[index].isSuccess())
                        {
                            bliIds.add(srList[index].getId());
                            System.debug(' was created'+ newBLIList[index].Sales_Invoice_Line_Item__c);
                            mapOfNewlyCreatedBLI.put(newBLIList[index].Sales_Invoice_Line_Item__c,srList[index].getId());
                        }
                        else 
                        {             
                            for (Database.Error err : srList[index].getErrors()) 
                            {
                                // Operation failed, so get all errors   
                                system.debug('The following error has occurred ==>'+err.getStatusCode() + ': ' + err.getMessage() + '. Fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
                    
                    if(mapOfNewlyCreatedBLI != null)
                    {
                        
                        for (c2g__codaInvoiceLineItem__c salesInvoiceLineItem : [Select Id, Name,c2g__NetValue__c,Billing_Contract_Line_Item__c from c2g__codaInvoiceLineItem__c where Id IN : mapOfNewlyCreatedBLI.Keyset()])
                        {
                            if(mapOfNewlyCreatedBLI.containskey(salesInvoiceLineItem.Id) && mapOfNewlyCreatedBLI.get(salesInvoiceLineItem.Id) != null)
                            {
                            	salesInvoiceLineItem.Billing_Contract_Line_Item__c = mapOfNewlyCreatedBLI.get(salesInvoiceLineItem.Id);
                            	updateSLIWithNewlyCreatedBLI.add(salesInvoiceLineItem);    
                            }
                        }    
                    }
                    
                    System.debug('mapOfNewlyCreatedBLI==>'+mapOfNewlyCreatedBLI);
                    System.debug('updateSLIWithNewlyCreatedBLI==>'+updateSLIWithNewlyCreatedBLI);
                    
                    System.debug('billingContractid==>'+billingContractid);
                    System.debug('bliIds==>'+bliIds);
                    // CREATE CREDIT NOTE RECORD
                    if (bliIds != null && bliIds.size() != 0 && billingContractid != null)
                    {
                        c2g__codaCreditNote__c salesCreditNoteObj = new c2g__codaCreditNote__c();
                        
                        if (salesInvoiceObj != null && salesInvoiceObj.Id != null)
                        {
                            salesCreditNoteObj.Billing_Contract__c = salesInvoiceObj.Billing_Contract__c;
                            salesCreditNoteObj.c2g__OwnerCompany__c = salesInvoiceObj.c2g__OwnerCompany__c;
                            salesCreditNoteObj.Remittance_Info__c = salesInvoiceObj.Remittance_Info__c;
                            salesCreditNoteObj.c2g__Account__c = salesInvoiceObj.c2g__Account__c;
                            salesCreditNoteObj.c2g__Opportunity__c = salesInvoiceObj.c2g__Opportunity__c;
                            salesCreditNoteObj.c2g__CreditNoteCurrency__c = salesInvoiceObj.c2g__InvoiceCurrency__c;
                            salesCreditNoteObj.c2g__Invoice__c = salesInvoiceObj.Id;
                            
                            if (currentPeriod != null && currentPeriod.Size() != 0)
                            {
                            	salesCreditNoteObj.c2g__Period__c = currentPeriod[0].Id;    
                            }
                            
                            //salesCreditNoteObj.c2g__Period__c = salesInvoiceObj.c2g__Period__c;
                            salesCreditNoteObj.c2g__InvoiceDate__c = salesInvoiceObj.c2g__InvoiceDate__c;
                            salesCreditNoteObj.c2g__DeriveDueDate__c = true;
                            salesCreditNoteObj.c2g__DeriveCurrency__c = true;
                            salesCreditNoteObj.c2g__Dimension1__c =  salesInvoiceObj.c2g__Dimension1__c;
                            salesCreditNoteObj.c2g__Dimension2__c = salesInvoiceObj.c2g__Dimension2__c;
                            salesCreditNoteObj.c2g__Dimension3__c = salesInvoiceObj.c2g__Dimension3__c;
                            salesCreditNoteObj.c2g__Dimension4__c =  salesInvoiceObj.c2g__Dimension4__c;
                            salesCreditNoteObj.c2g__DerivePeriod__c = true;
                            salesCreditNoteObj.c2g__CustomerReference__c = 'AR';
                            
                            if(financeRequestDummy != null)
                            {
                                salesCreditNoteObj.c2g__CreditNoteReason__c = financeRequestDummy.Credit_Note_Reason__c;
                                salesCreditNoteObj.Reason_Subcategory__c = financeRequestDummy.Reason_Subcategory__c;    
                            }    
							
                            if(!Test.isRunningTest())
                            {
                            	insert salesCreditNoteObj;    
                            }
                        }
                        
                        System.debug('salesCreditNoteObj==>'+salesCreditNoteObj);
                        
                        // CREATE CREDIT NOTE LINE ITEM RECORD
                        if ((salesCreditNoteObj != null && salesCreditNoteObj.Id != null) || Test.isRunningTest())
                        {
                            for (Billing_Contract_Line_Item__c bcli : [Select Id,Sales_Invoice_Line_Item__c,Billing_Contract__c,Activity_Line_Item__c,Unit_Price__c,
                                                                     Quantity__c,Product__c from Billing_Contract_Line_Item__c where Id IN : bliIds])
                            {
                                c2g__codaCreditNoteLineItem__c cnli = new c2g__codaCreditNoteLineItem__c();
                                cnli.Billing_Contract__c = bcli.Billing_Contract__c;
                                cnli.Billing_Contract_Line_Item__c = bcli.Id;
                                cnli.c2g__CreditNote__c = salesCreditNoteObj.Id;
                                System.debug('bcli.Unit_Price__c==>'+bcli.Unit_Price__c);
                                cnli.c2g__UnitPrice__c = (bcli.Unit_Price__c)*-1;//bcli.Quantity__c;
                                cnli.c2g__Quantity__c = bcli.Quantity__c;
                                cnli.Activity_Line_Item__c = bcli.Activity_Line_Item__c;
                                cnli.c2g__Product__c = bcli.Product__c;
                                insertSCNLI.add(cnli);
                            }
                        }
                        System.debug('insertSCNLI==>'+insertSCNLI);
                        // CREATE CREDIT NOTE LINE ITEM RECORD
                        if (!insertSCNLI.isEmpty())
                        {
                            upsert insertSCNLI;   
                        }
                        
                        if (!updateSLIWithNewlyCreatedBLI.isEmpty())
                        {
                            update updateSLIWithNewlyCreatedBLI;
                        }
                        
                        //UPDATE ANY BILLING LINES THAT HAVE BEEN CREDITED SO THE CAN BE 
                        if(!bliUpdateList.isEmpty())
                        {
                            for(Billing_Contract_Line_Item__c updateBli : bliUpdateList)
                            {
                                updateBli.Credit_Processed__c = true;
                            }
                            
                            update bliUpdateList;
                        }    
                        
                        // UPDATE FINANCE REQUEST WITH CREATED SALES CREDIT NOTE 
                        if(financeRequest != null && salesCreditNoteObj != null && salesCreditNoteObj.Id != null)
                        {
                            financeRequest.Sales_Credit_Note__c = salesCreditNoteObj.Id;
                            Update financeRequest;
                            PageReference ref = new PageReference('/'+salesCreditNoteObj.Id); 
        					return ref;
                        }
                        System.debug('financeRequest==>'+financeRequest);
                    }
                }
            }
            Catch (Exception e)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage() + '\n Line: '+e.getLineNumber() +'\n Cause:'+e.getCause())); 
                return null;
            }
        }
        return null;
    }
    
    // ==========================================
	// REDIRECT BACK TO FINANCE REQUEST RECORD
	// ==========================================
	public PageReference backToBC()
    {
        
        PageReference ref = new PageReference('/'+financeRequest.Id); 
        return ref; 
    }
    
    // ============================================
	// WRAPPER CLASSES TO DISPLAY RECORDS ON VF PAGE
	// ============================================
    public class SILWrapper
    {
        
        public c2g__codaInvoiceLineItem__c silObject {get;set;}
        public boolean check {get;set;}
        public boolean disabled {get;set;}
        public decimal creditValue{get;set;}
        public decimal unitPrice{get;set;}
        
        public SILWrapper()
        {
            silObject = new c2g__codaInvoiceLineItem__c();
        }
    }	
}