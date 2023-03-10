public class ffaStatementController{
	public Account customerAccount {get; set;}
	public c2g__codaInvoice__c dummyInvoice {get; set;}
    public Decimal outstandingTotal {get; set;} //this is the total from other invoices that is also due.
    public Decimal grandTotalDue {get; set;}
    public List<c2g__codaInvoice__c> outstandingInvoices {get; set;}
    public Boolean renderHeaderImage {get; set;}
    public Boolean renderFooterImage {get; set;}
    public String accountobjID {get; set{
            accountobjID = value;
            this.getData();
            this.calculateTotals();
            system.debug('****** \n\n ffaInvoiceController + ffaInvoiceController + accountobjID = '+accountobjID);
            }
        }
  
    
    public ffaStatementController(){
      dummyInvoice = new c2g__codaInvoice__c(
      	c2g__InvoiceDate__c = Date.today());
      //accountobjID = ApexPages.currentPage().getParameters().get('id');
      customerAccount = new Account();
      //getData();
      grandTotalDue = 0;
      outstandingTotal = 0;
      renderHeaderImage = false;
      renderFooterImage = false;
      //calculateTotals();
    }

    public void getData() {
    	customerAccount = [
    	SELECT Id,
    	 	Name,
            BillingStreet,
            AccountNumber, 
            BillingCity, 
            BillingState,
            BillingPostalCode,  
            BillingCountry,  
            ShippingStreet,  
            ShippingCity,  
            ShippingState,  
            ShippingPostalCode,  
            c2g__CODADescription1__c,
            c2g__CODAInvoiceEmail__c,
            Remittance_Info__r.Company_Logo__c,
            Remittance_Info__r.Invoice_Header__c,
            Remittance_Info__r.Invoice_Footer__c,
            Remittance_Info__r.Statement_Header__c,
            Remittance_Info__r.Statement_Footer__c,
            Remittance_Info__r.Invoice_Header_Text__c,
            Remittance_Info__r.Invoice_Footer_Text__c,
            Remittance_Info__r.Statement_Header_Text__c,
            Remittance_Info__r.Statement_Footer_Text__c
       	FROM Account 
       	WHERE Id = :accountobjID];

        if(customerAccount.Remittance_Info__r.Invoice_Header__c != null || customerAccount.Remittance_Info__r.Statement_Header__c != null){
        renderHeaderImage = true;
        }
        if(customerAccount.Remittance_Info__r.Invoice_Footer__c != null || customerAccount.Remittance_Info__r.Statement_Footer__c != null){
            renderFooterImage = true;
        }

        outstandingInvoices = [
        SELECT Name,
            c2g__InvoiceDate__c,
            c2g__CustomerReference__c, 
            c2g__DueDate__c, 
            c2g__NetTotal__c,
            c2g__InvoiceDescription__c,
            c2g__TaxTotal__c,
            c2g__Tax1Total__c,
            c2g__Tax2Total__c,
            c2g__Tax3Total__c,
            c2g__TaxCode2__c,
            c2g__Transaction__c,
            c2g__InvoiceTotal__c,
            c2g__PaymentSchedule__c,  
            c2g__InvoiceGroup__r.Name,
            c2g__InvoiceCurrency__r.Name,
            c2g__OwnerCompany__r.Name,
            c2g__OwnerCompany__r.RecordType.Name,
            c2g__OwnerCompany__r.c2g__LogoURL__c, 
            c2g__OwnerCompany__r.c2g__Street__c,
            c2g__OwnerCompany__r.c2g__City__c,
            c2g__OwnerCompany__r.c2g__StateProvince__c,
            c2g__OwnerCompany__r.c2g__ZipPostCode__c,
            c2g__OwnerCompany__r.c2g__Country__c,
            c2g__OwnerCompany__r.c2g__Phone__c,
            c2g__OwnerCompany__r.c2g__Fax__c,                                    
            c2g__OwnerCompany__r.c2g__Website__c,
            c2g__OwnerCompany__r.c2g__ContactEmail__c,
            c2g__Dimension1__r.Name,
            c2g__Dimension2__r.Name,
            c2g__OutstandingValue__c,
            Amount_Paid__c,
               (SELECT Id, 
                c2g__LineNumber__c,
                c2g__Product__r.Name,
                c2g__Product__r.ProductCode,
                c2g__LineDescription__c,
                c2g__Quantity__c,
                c2g__UnitPrice__c,
                c2g__NetValue__c,
                c2g__TaxValueTotal__c,
                c2g__TaxValue1__c,
                c2g__TaxValue2__c,
                c2g__TaxValue3__c
                FROM c2g__InvoiceLineItems__r
                ORDER BY c2g__LineNumber__c ASC)
        FROM c2g__codaInvoice__c 
        WHERE c2g__Account__c = :accountobjID
        AND c2g__PaymentStatus__c != 'Paid'
        AND c2g__InvoiceStatus__c = 'Complete'];
  }

    //method to calculate the outstanding total of other invoices
    public void calculateTotals(){

        for(c2g__codaInvoice__c inv : outstandingInvoices)
        {
            outstandingTotal += inv.c2g__OutstandingValue__c;
        }
        system.debug('\n\n ****** ffaInvoiceController - calculateTotals - grandTotalDue =' + grandTotalDue);
        system.debug('\n\n ****** ffaInvoiceController - calculateTotals - outstandingTotal =' + outstandingTotal);
    }
}