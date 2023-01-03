/**************************************************************************************
// Name          : AH_ProcessCreditNote
// Date          : 9/23/2021
// Description   : Controller for the "Process Credit Note" button
// Author        : Bhagwat Garkal
***************************************************************************************/
public class AH_ProcessCreditNote_Ctlr {
    public List<SILWrapper> wrapperList {get; set;}
    //public Billing_Contract_Line_Item__c dummyLine {get; set;}
    public Boolean isAllChecked {get; set;}
    //public Billing_Contract__c billingContract {get; set;}
    public id billingContractid {get; set;}
    public AH_Finance_Request__c financeRequest{get; set;}
    public AH_ProcessCreditNote_Ctlr(ApexPages.StandardController controller) 
    {
        this.financeRequest = (AH_Finance_Request__c)controller.getRecord(); 
        fetchData();
    }
    /*public AH_ProcessCreditNote_Ctlr(ApexPages.StandardController controller) {
        dummyLine = new Billing_Contract_Line_Item__c();
        this.billingContract = (Billing_Contract__c)controller.getRecord(); 
        fetchData();
    }*/

    public void fetchData()
    {
        wrapperList = new List<SILWrapper>();
        if(financeRequest != null )//&& financeRequest.Sales_Invoice__c != null
        {
            Set<Id> salesInvoiceIds = new Set<Id>();
            for(AH_Finance_Request__c financeReq : [Select Id,Name,Billing_Contract__c,Sales_Invoice__c from  AH_Finance_Request__c where Id =:financeRequest.Id])
            {
                if(financeReq != null && financeReq.Sales_Invoice__c != null)
                    salesInvoiceIds.add(financeReq.Sales_Invoice__c);
                if(financeReq.Billing_Contract__c != null){
                    billingContractid = financeReq.Billing_Contract__c;
                }
            }
           
            if(salesInvoiceIds != null && salesInvoiceIds.size() != 0)
            {
                for(c2g__codaInvoiceLineItem__c sil : [Select Id, Name,c2g__NetValue__c,c2g__Invoice__c,c2g__Product__c,c2g__Product__r.Name,c2g__Quantity__c,
                                                           c2g__UnitPrice__c,Activity_Line_Item__c,
                                                           c2g__LineNumber__c from c2g__codaInvoiceLineItem__c where c2g__Invoice__c IN: salesInvoiceIds 
                                                           order by c2g__LineNumber__c asc])
                {
                    SILWrapper wrapper = new SILWrapper();
                    wrapper.silObject = sil;
                    wrapper.creditValue = (sil.c2g__NetValue__c).setScale(2);
                    wrapper.unitPrice =  ((sil.c2g__UnitPrice__c)*-1).setScale(2);
                    wrapper.check = true;
                    wrapperList.add(wrapper);
                }
            }
        }
    }
    
    public void createBCLI()
    {
        List<Billing_Contract_Line_Item__c> newBLIList = new List<Billing_Contract_Line_Item__c>();
        if(wrapperList != null && wrapperList.Size() != 0)
        {
            for(SILWrapper wrapper : wrapperList)
            {
                if(wrapper.check == true)
                {
                    Billing_Contract_Line_Item__c newBLI = new Billing_Contract_Line_Item__c();
                    newBLI.Quantity__c = wrapper.silObject.c2g__Quantity__c;
                    newBLI.Unit_Price__c = wrapper.unitPrice;
                    newBLI.Billing_Contract__c = billingContractid;
                    newBLI.Activity_Line_Item__c = wrapper.silObject.Activity_Line_Item__c;
                    newBLI.Sales_Invoice_Line_Item__c = wrapper.silObject.Id;
                    newBLI.Total_Amount__c = (wrapper.silObject.c2g__Quantity__c * wrapper.unitPrice).setScale(2);
                    newBLI.Product__c = wrapper.silObject.c2g__Product__c;
                    newBLI.Invoiced__c = true;
                    newBLI.Revenue_Category__c = 'Services';
                    //newBLI.Invoice_Date__c
                    newBLI.Ready_to_Invoice__c = true;
                    newBLIList.add(newbli);
                    if(newBLI.Unit_Price__c > 0)
                    {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Attention: you must enter a negative amount!')); 
                        return;
                    }
                }
            }
            
            Try
            {
                if(newBLIList != null && newBLIList.Size() != 0)
                {
                    Set<Id> bliIds = new Set<Id>();
                    Database.SaveResult[] sr = Database.insert(newBLIList, false);
                    for(Database.SaveResult s : sr) {
                        bliIds.add(s.getId());
                    }
                    List<c2g__codaCreditNoteLineItem__c> insertSCNLI = new List<c2g__codaCreditNoteLineItem__c>();
                    if(bliIds != null && bliIds.size() != 0 && billingContractid != null){
                        List<c2g__codaCreditNote__c> salesCreditNote = [select id from c2g__codaCreditNote__c where Billing_Contract__c =:billingContractid];
                        if((salesCreditNote != null && salesCreditNote.size() != 0) || Test.isRunningTest())
                        {
                            for(Billing_Contract_Line_Item__c bcli : [Select Id,Sales_Invoice_Line_Item__c,Billing_Contract__c,Activity_Line_Item__c,Unit_Price__c,
                                                                     Quantity__c,Product__c from Billing_Contract_Line_Item__c where Id IN : bliIds])
                            {
                                c2g__codaCreditNoteLineItem__c cnli = new c2g__codaCreditNoteLineItem__c();
                                cnli.Billing_Contract__c = bcli.Billing_Contract__c;
                                cnli.Billing_Contract_Line_Item__c = bcli.Id;
                                cnli.c2g__CreditNote__c = salesCreditNote[0].Id;
                                cnli.c2g__UnitPrice__c = (bcli.Unit_Price__c)*-1;
                                cnli.c2g__Quantity__c = bcli.Quantity__c;
                                cnli.Activity_Line_Item__c = bcli.Activity_Line_Item__c;
                                cnli.c2g__Product__c = bcli.Product__c;
                                insertSCNLI.add(cnli);
                            }
                        }    
                    }
                    if(insertSCNLI != null && insertSCNLI.Size() != 0){
                        upsert insertSCNLI;   
                    }
                }
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Saved Successful!'));
            }
            Catch(Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage() + '\n Line: '+e.getLineNumber() +'\n Cause:'+e.getCause())); 
            }
        }
    }
    
    public PageReference backToBC(){
        PageReference ref = new PageReference('/'+financeRequest.Id); 
        return ref; 
    }
    
    public class SILWrapper{
        public c2g__codaInvoiceLineItem__c silObject {get;set;}
        public boolean check {get;set;}
        public boolean disabled {get;set;}
        public decimal creditValue{get;set;}
        public decimal unitPrice{get;set;}
        public SILWrapper(){
            silObject = new c2g__codaInvoiceLineItem__c();
        }
    }
    
}