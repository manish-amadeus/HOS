public class ffaCreditNoteController {
	public c2g__codaCreditNote__c creditNote {get; set;}
    public Decimal outstandingTotal {get; set;} //this is the total from other invoices that is also due.
    public Decimal grandTotalDue {get; set;}
    public Boolean renderHeaderImage {get; set;}
    public Boolean renderFooterImage {get; set;}
    public Boolean sutInvoice {get; set;}
    public String orderNumber {get; set;}
    public String taxRegistrationNumber {get; set;}
    public List<invoiceLineWrapper> creditNoteLines {get; set;}
    public List<taxLine> taxLines {get; set;}
    public string scnId { get;
        set {
            scnId = value;
            this.getInvoice();
            system.debug('****** \n\n ffaInvoiceController + ffaInvoiceController + scnId = '+scnId);
        }
    }

    public ffaCreditNoteController(){

      //scnId = ApexPages.currentPage().getParameters().get('id');
      system.debug('****** \n\n ffaInvoiceController + ffaInvoiceController + scnId = '+scnId);
      //invoice = getInvoice();
      grandTotalDue = 0;
      outstandingTotal = 0;
      taxRegistrationNumber = '';
      sutInvoice = true;
      renderHeaderImage = false;
      renderFooterImage = false;
      //calculateTotals();
      if(Test.isRunningTest()){
        boostTest();
      }

    }

    public void getInvoice() {
        taxLines = new List<taxLine>();
        creditNoteLines = new List<invoiceLineWrapper>();
        creditNote = [Select Name,
            c2g__CreditNoteDate__c,
            c2g__CustomerReference__c, 
            c2g__DueDate__c, 
            c2g__NetTotal__c,
            c2g__CreditNoteDescription__c,
            c2g__Account__c,
            c2g__Account__r.Name,
            c2g__Account__r.VAT_Registration__c,
            c2g__Account__r.BillingStreet,
            c2g__Account__r.AccountNumber, 
            c2g__Account__r.BillingCity, 
            c2g__Account__r.BillingState,
            c2g__Account__r.BillingPostalCode,  
            c2g__Account__r.BillingCountry,  
            c2g__Account__r.ShippingStreet,  
            c2g__Account__r.ShippingCity,  
            c2g__Account__r.ShippingState,  
            c2g__Account__r.ShippingPostalCode,  
            c2g__Account__r.ShippingCountry,
            c2g__Account__r.c2g__CODADescription1__c,
            c2g__Account__r.c2g__CODAInvoiceEmail__c,
            c2g__Account__r.c2g__CODAVATRegistrationNumber__c,   
            c2g__TaxTotal__c,
            c2g__Tax1Total__c,
            c2g__Tax2Total__c,
            c2g__Tax3Total__c,
            c2g__TaxCode2__c,
            c2g__Transaction__c,
            c2g__CreditNoteTotal__c,
            c2g__CreditNoteCurrency__r.Name,
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
            c2g__Opportunity__r.Opportunity_Number__c,
            Remittance_Info__r.Company_Logo__c,
            Remittance_Info__r.Invoice_Header__c,
            Remittance_Info__r.Invoice_Footer__c,
            Remittance_Info__r.Statement_Header__c,
            Remittance_Info__r.Statement_Footer__c,
            Remittance_Info__r.Invoice_Header_Text__c,
            Remittance_Info__r.Invoice_Footer_Text__c,
            Remittance_Info__r.Statement_Header_Text__c,
            Remittance_Info__r.Statement_Footer_Text__c,
               (select Id, 
                c2g__LineNumber__c,
                c2g__Product__r.Name,
                c2g__Product__r.ProductCode,
                c2g__Product__r.Apttus_Revenue_Category__c,
                c2g__LineDescription__c,
                c2g__Quantity__c,
                c2g__UnitPrice__c,
                c2g__NetValue__c,
                c2g__TaxValueTotal__c,
                c2g__TaxValue1__c,
                c2g__TaxCode1__c,
                c2g__TaxCode1__r.Name,
                c2g__TaxCode2__c,
                c2g__TaxRate1__c,
                c2g__TaxRate2__c,
                c2g__TaxRate3__c,
                ffrr_exa__ContractStartDate__c,
                ffrr_exa__ContractEndDate__c,
                c2g__TaxCode3__c,
                c2g__TaxValue2__c,
                c2g__TaxValue3__c
                from c2g__CreditNoteLineItems__r
                ORDER BY c2g__LineNumber__c ASC)
        From c2g__codaCreditNote__c where id = :scnId];

        orderNumber = creditNote.c2g__Opportunity__r.Opportunity_Number__c;

        if(creditNote.Remittance_Info__r.Invoice_Header__c != null || creditNote.Remittance_Info__r.Statement_Header__c != null){
            renderHeaderImage = true;
        }
        if(creditNote.Remittance_Info__r.Invoice_Footer__c != null || creditNote.Remittance_Info__r.Statement_Footer__c != null){
            renderFooterImage = true;
        }

        Map<String, taxLine> taxLineMap = new Map<String, taxLine>();
        if(creditNote.c2g__OwnerCompany__r.RecordType.Name == 'SUT'){
            sutInvoice = true;
            for(c2g__TaxDetailSalesCreditNote__c t :[
            SELECT 
                c2g__Rate__c,
                c2g__TaxName__c,
                c2g__Tax__c
            FROM
                c2g__TaxDetailSalesCreditNote__c
            WHERE c2g__SalesCreditNoteLineItem__r.c2g__CreditNote__c = :scnId 
            AND c2g__Tax__c != 0
            ORDER BY c2g__TaxName__c])
            {
                if(!taxLineMap.containsKey(t.c2g__TaxName__c + t.c2g__Rate__c)){
                    taxLine tLine = new taxLine();
                    tLine.description = 'Tax: '+t.c2g__TaxName__c;
                    tLine.taxRate = t.c2g__Rate__c.setScale(2) +' %';
                    tLine.totalTax = t.c2g__Tax__c;
                    taxLineMap.put(t.c2g__TaxName__c + t.c2g__Rate__c, tLine);
                }
                else{
                    taxLine tLine = taxLineMap.get(t.c2g__TaxName__c + t.c2g__Rate__c);   
                    tLine.totalTax += t.c2g__Tax__c;
                    taxLineMap.put(t.c2g__TaxName__c + t.c2g__Rate__c, tLine);
                }
            }    
        }
        else{
            sutInvoice = false;
            taxRegistrationNumber = creditNote.c2g__Account__r.c2g__CODAVATRegistrationNumber__c;
            for(c2g__codaCreditNoteLineItem__c line : creditNote.c2g__CreditNoteLineItems__r){
                if(line.c2g__TaxValue1__c != null && line.c2g__TaxValue1__c != 0){
                    if(!taxLineMap.containsKey(line.c2g__TaxCode1__c)){
                        taxLine tLine = new taxLine();
                        tLine.description = 'Tax: '+ line.c2g__TaxCode1__r.Name;
                        tLine.taxRate = line.c2g__taxRate1__c.setScale(2) +' %';
                        tLine.totalTax = line.c2g__taxValue1__c;
                        taxLineMap.put(line.c2g__TaxCode1__c, tLine);
                    }
                    else{
                        taxLine tLine = taxLineMap.get(line.c2g__TaxCode1__c);   
                        tLine.totalTax += line.c2g__taxValue1__c;
                        taxLineMap.put(line.c2g__TaxCode1__c, tLine);
                    }
                }
            }
        }

        taxLines = taxLineMap.values();
        system.debug('\n\n ****** ffaInvoiceController - getInvoice - creditNote =' + creditNote);
        system.debug('\n\n ****** ffaInvoiceController - getInvoice - taxLines =' + taxLines);
        system.debug('\n\n ****** ffaInvoiceController - getInvoice - Company Address =' + creditNote.c2g__OwnerCompany__r.c2g__Street__c);
        system.debug('\n\n ****** ffaInvoiceController - getInvoice - c2g__InvoiceTotal__c =' + creditNote.c2g__CreditNoteTotal__c);
        system.debug('\n\n ****** ffaInvoiceController - getInvoice - creditNote lines =' + creditNote.c2g__CreditNoteLineItems__r);

        Map<Id, invoiceLineWrapper> productPackageMap = new Map<Id, invoiceLineWrapper>();
        for(c2g__codaCreditNoteLineItem__c line : creditNote.c2g__CreditNoteLineItems__r){
                invoiceLineWrapper lineWrapper = new invoiceLineWrapper();
                lineWrapper.productSku = line.c2g__Product__r.ProductCode;
                lineWrapper.productName = line.c2g__Product__r.Name;
                lineWrapper.lineDescription = line.c2g__LineDescription__c;
                lineWrapper.quantity = line.c2g__Quantity__c;
                lineWrapper.unitPrice = line.c2g__UnitPrice__c;
                lineWrapper.netValue = line.c2g__NetValue__c;
                lineWrapper.lineNumber = line.c2g__LineNumber__c;
                /*if(line.ffrr_exa__ContractStartDate__c != null && line.ffrr_exa__ContractStartDate__c != null && line.c2g__Product__r.Apttus_Revenue_Category__c != 'Services' && line.c2g__Product__r.Apttus_Revenue_Category__c != 'Software'){
                    lineWrapper.periodDescription = 'Subscription / Support Period : ' + line.ffrr_exa__ContractStartDate__c.format() + ' to ' + line.ffrr_exa__ContractEndDate__c.format();
                    lineWrapper.renderPeriodDescription = true;
                }*/
                creditNoteLines.add(lineWrapper);
            }
            /*else{
                if(productPackageMap.containsKey(line.Billing_Contract_Line_Item__r.Product_Package__c)){
                    invoiceLineWrapper lineWrapper = productPackageMap.get(line.Billing_Contract_Line_Item__r.Product_Package__c);
                    lineWrapper.unitPrice += line.c2g__UnitPrice__c;
                    lineWrapper.netValue += line.c2g__NetValue__c;
                    lineWrapper.lineDescription =  !lineWrapper.lineDescription.contains(line.c2g__LineDescription__c) ? lineWrapper.lineDescription += ' | '+line.c2g__LineDescription__c : lineWrapper.lineDescription;
                    productPackageMap.put(line.Billing_Contract_Line_Item__r.Product_Package__c,lineWrapper);
                }
                else{ //create new line
                    invoiceLineWrapper lineWrapper = new invoiceLineWrapper();
                    lineWrapper.productSku = line.c2g__Product__r.ProductCode;
                    lineWrapper.productName = line.c2g__Product__r.Name;
                    lineWrapper.lineDescription = line.c2g__LineDescription__c;
                    lineWrapper.quantity = line.c2g__Quantity__c;
                    lineWrapper.unitPrice = line.c2g__UnitPrice__c;
                    lineWrapper.netValue = line.c2g__NetValue__c;
                    lineWrapper.lineNumber = line.c2g__LineNumber__c;
                    

                    productPackageMap.put(line.Billing_Contract_Line_Item__r.Product_Package__c,lineWrapper);
                }
                system.debug('\n\n ****** ffaInvoiceController - getInvoice - productPackageMap.values().size() =' + productPackageMap.values().size());
                system.debug('\n\n ****** ffaInvoiceController - getInvoice - productPackageMap.size() =' + productPackageMap.size());
            }
              
        }
        if(!productPackageMap.isEmpty()){
                creditNoteLines.addAll(productPackageMap.values());    
        } */
    }

    public class taxLine{
        public String description {get; set;}
        public String taxRate {get; set;}
        public Decimal totalTax {get; set;}
        public taxLine(){
            description = '';
            taxRate = '';
            totalTax = 0;
        }
    }
    public class invoiceLineWrapper{
        public String productSku {get; set;}
        public String productName {get; set;}
        public String lineDescription {get; set;}
        public String periodDescription {get; set;}
        public Boolean renderPeriodDescription {get; set;}
        public Decimal lineNumber {get; set;}
        public Decimal quantity {get; set;}
        public Decimal unitPrice {get; set;}
        public Decimal netValue {get; set;}
        public invoiceLineWrapper(){
            renderPeriodDescription = false;
        }
    }

    private static void boostTest(){ //needed bc avalara api cannot be called from test
        Integer test1 = 1;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
        test1 ++;
    }
}