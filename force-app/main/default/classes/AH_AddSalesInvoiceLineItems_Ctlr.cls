/****************************************************************************************
Name            : AH_AddSalesInvoiceLineItems_Controller
Author          : Bhagwat Garkal
Created Date    : september 20, 2021
Description     : Add Sales Invoice LineItems
******************************************************************************************/
public class AH_AddSalesInvoiceLineItems_Ctlr {
    public List<SILWrapper> wrapperList {get; set;}
    public AH_Finance_Request__c financeRequest{get; set;}
    public AH_AddSalesInvoiceLineItems_Ctlr(ApexPages.StandardController controller) 
    {
        this.financeRequest = (AH_Finance_Request__c)controller.getRecord(); 
        fetchData();
    }
    
    public void fetchData(){
       wrapperList = new List<SILWrapper>();
        if(financeRequest != null )//&& financeRequest.Sales_Invoice__c != null
        {
            AH_Finance_Request__c financeReq = [Select Id,Name, Sales_Invoice__c from  AH_Finance_Request__c where id =:financeRequest.Id];
            if(financeReq != null && financeReq.Sales_Invoice__c != null)
            {
                for(c2g__codaInvoiceLineItem__c sil : [Select Id, Name,c2g__NetValue__c,c2g__Invoice__c,c2g__Product__c,c2g__Product__r.Name,c2g__Quantity__c,c2g__UnitPrice__c,
                                                       c2g__LineNumber__c from c2g__codaInvoiceLineItem__c where c2g__Invoice__c =: financeReq.Sales_Invoice__c 
                                                       order by c2g__LineNumber__c asc])
                {
                    SILWrapper wrapper = new SILWrapper();
                    wrapper.silObject = sil;
                    wrapper.creditValue = sil.c2g__NetValue__c;
                    wrapper.check = true;
                    wrapperList.add(wrapper);
                }
            }        
        }
    }
    
    public PageReference backToBC(){
        PageReference ref = new PageReference('/'+financeRequest.Id); 
        return ref; 
    }
    
    public void saveCredit()
    {
        List<AH_Finance_Request_to_SIN_Line_Item__c> creditList = new List<AH_Finance_Request_to_SIN_Line_Item__c>();
        Map<String,AH_Finance_Request_to_SIN_Line_Item__c> mapOfSINLineItem = new Map<String,AH_Finance_Request_to_SIN_Line_Item__c>();
        for(AH_Finance_Request_to_SIN_Line_Item__c frsinlineitem : [select Id,Finance_Request__c,Sales_Invoice_Line_Item__c,Requested_Credit_Amount__c 
                                                                    from AH_Finance_Request_to_SIN_Line_Item__c where Finance_Request__c =: financeRequest.Id]){
           mapOfSINLineItem.put(frsinlineitem.Sales_Invoice_Line_Item__c,frsinlineitem);                                                             
            
        }
        
        for(SILWrapper wrapper : wrapperList){
            if(wrapper.check == true){
                AH_Finance_Request_to_SIN_Line_Item__c sin;
                if(mapOfSINLineItem != null && mapOfSINLineItem.containskey(wrapper.silObject.Id)){
                    sin = mapOfSINLineItem.get(wrapper.silObject.Id);
                }else{
                    sin = new AH_Finance_Request_to_SIN_Line_Item__c();
                    sin.Finance_Request__c = financeRequest.Id;
                    sin.Sales_Invoice_Line_Item__c = wrapper.silObject.Id;
                }    
                sin.Requested_Credit_Amount__c = wrapper.creditValue;
                creditList.add(sin);
            }
        }

        Try{
            //billingContractCreditHandler.processBCCredits(creditList);
            if(creditList != null && creditList.size() != 0){
                upsert creditList;
            }
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Saved Successful!'));
        }
        Catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage() + '\n Line: '+e.getLineNumber() +'\n Cause:'+e.getCause())); 
        }
    }
    
    public class SILWrapper{
        public c2g__codaInvoiceLineItem__c silObject {get;set;}
        public boolean check {get;set;}
        public boolean disabled {get;set;}
        public decimal creditValue{get;set;}
        public SILWrapper(){
            silObject = new c2g__codaInvoiceLineItem__c();
           /* if(silObject != null){
                creditValue = silObject.c2g__NetValue__c;
            }    
            check = false;*/
        }
    }
}