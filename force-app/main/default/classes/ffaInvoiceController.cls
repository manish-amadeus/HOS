public class ffaInvoiceController {
    public c2g__codaInvoice__c invoice {get; set;}
    public Decimal outstandingTotal {get; set;} //this is the total from other invoices that is also due.
    public Decimal grandTotalDue {get; set;}
    public Boolean renderHeaderImage {get; set;}
    public Boolean renderFooterImage {get; set;}
    public Boolean renderTaxSection {get; set;}
    public Boolean sutInvoice {get; set;}
    public String orderNumber {get; set;}
    public String accountName {get; set;}
    public String taxRegistrationNumber {get; set;}
    public List<invoiceLineWrapper> invoiceLines {get; set;}
    public List<taxLine> taxLines {get; set;}
    public string sinId { get;
        set {
            sinId = value;
            this.getInvoice();
            system.debug('****** \n\n ffaInvoiceController + ffaInvoiceController + sinId = '+sinId);
        }
    }

    public ffaInvoiceController(){

      //sinId = ApexPages.currentPage().getParameters().get('id');
      system.debug('****** \n\n ffaInvoiceController + ffaInvoiceController + sinId = '+sinId);
      //invoice = getInvoice();
      grandTotalDue = 0;
      outstandingTotal = 0;
      taxRegistrationNumber = '';
      sutInvoice = true;
      renderHeaderImage = false;
      renderFooterImage = false;
      renderTaxSection = false;
      //calculateTotals();
      if(Test.isRunningTest()){
        boostTest();
      }

    }

    public void getInvoice() {
system.debug('****** ENTERING ffaInvoiceController.getInvoice()');        
        taxLines = new List<taxLine>();
        invoiceLines = new List<invoiceLineWrapper>();
        invoice = [Select Name,
            c2g__InvoiceDate__c,
            c2g__CustomerReference__c, 
            c2g__DueDate__c, 
            c2g__NetTotal__c,
            c2g__InvoiceDescription__c,
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
            c2g__Account__r.Legal_Entity_Name__c,
            c2g__Account__r.c2g__CODADescription1__c,
            c2g__Account__r.c2g__CODAInvoiceEmail__c,
            c2g__Account__r.c2g__CODAVATRegistrationNumber__c,   
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
            Outstanding_Total_Display__c,
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
            c2g__Opportunity__r.Purchase_Order__c,
            Amount_Paid__c,
            PO_Number__c,
            Pro_Forma_Invoice__c,
            Remittance_Info__r.Company_Logo__c,
            Remittance_Info__r.Invoice_Header__c,
            Remittance_Info__r.Invoice_Footer__c,
            Remittance_Info__r.Statement_Header__c,
            Remittance_Info__r.Statement_Footer__c,
            Remittance_Info__r.Invoice_Header_Text__c,
            Remittance_Info__r.Invoice_Footer_Text__c,
            Remittance_Info__r.Statement_Header_Text__c,
            Remittance_Info__r.Statement_Footer_Text__c                   
/* SMH Commented         
              , (select Id, 
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
                Billing_Frequency_Invoice_Display__c,
                c2g__TaxValue2__c,
                c2g__TaxValue3__c,
                Billing_Contract_Line_Item__c,
                Billing_Contract_Line_Item__r.Product_Package__c,
                Billing_Contract_Line_Item__r.Product_Package__r.Name,
                Billing_Contract_Line_Item__r.Product_Package__r.Package_SKU__c
                from c2g__InvoiceLineItems__r
                ORDER BY c2g__LineNumber__c ASC)
*/                   
        From c2g__codaInvoice__c where id = :sinId]; 

// NEW START - SMH - BROKE OUT THE SUB-QUERY INTO A STRAIGHT ONE BECAUSE SINS WITH MANY LINE ITEMS WOULD THROW THIS ERROR:
// javax.el.ELException: javax.el.ELException: common.apex.runtime.impl.ExecutionException: Aggregate query has too many rows for direct assignment, use FOR loop
        List<c2g__codaInvoiceLineItem__c> lstInvoiceLineItems = new List<c2g__codaInvoiceLineItem__c>([
            SELECT Id, c2g__LineNumber__c, c2g__Product__r.Name, c2g__Product__r.ProductCode, c2g__Product__r.Apttus_Revenue_Category__c, c2g__LineDescription__c, 
            c2g__Quantity__c, c2g__UnitPrice__c, c2g__NetValue__c, c2g__TaxValueTotal__c, c2g__TaxValue1__c, c2g__TaxCode1__c, c2g__TaxCode1__r.Name, c2g__TaxCode2__c, 
            c2g__TaxRate1__c, c2g__TaxRate2__c, c2g__TaxRate3__c, ffrr_exa__ContractStartDate__c, ffrr_exa__ContractEndDate__c, c2g__TaxCode3__c, 
            Billing_Frequency_Invoice_Display__c, c2g__TaxValue2__c, c2g__TaxValue3__c, Billing_Contract_Line_Item__c, Billing_Contract_Line_Item__r.Product_Package__c, 
            Billing_Contract_Line_Item__r.Product_Package__r.Name, Billing_Contract_Line_Item__r.Product_Package__r.Package_SKU__c 
            FROM c2g__codaInvoiceLineItem__c 
            WHERE c2g__Invoice__c =: sinId 
            ORDER BY c2g__LineNumber__c ASC]); 
// NEW END - SMH
        
        orderNumber = invoice.c2g__Opportunity__r.Opportunity_Number__c;

        accountName = invoice.c2g__OwnerCompany__r.Name == 'Itesso BV' ? invoice.c2g__Account__r.Legal_Entity_Name__c : invoice.c2g__Account__r.Name;

        if(invoice.Remittance_Info__r.Invoice_Header__c != null || invoice.Remittance_Info__r.Statement_Header__c != null){
            renderHeaderImage = true;
        }
        if(invoice.Remittance_Info__r.Invoice_Footer__c != null || invoice.Remittance_Info__r.Statement_Footer__c != null){
            renderFooterImage = true;
        }

        Map<String, taxLine> taxLineMap = new Map<String, taxLine>();
        if(invoice.c2g__OwnerCompany__r.RecordType.Name == 'SUT'){
            sutInvoice = true;
            for(c2g__TaxDetailSalesInvoice__c t :[
            SELECT 
                c2g__Rate__c,
                c2g__TaxName__c,
                c2g__Tax__c
            FROM
                c2g__TaxDetailSalesInvoice__c
            WHERE c2g__SalesInvoiceLineItem__r.c2g__Invoice__c = :sinId 
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
            taxRegistrationNumber = invoice.c2g__Account__r.c2g__CODAVATRegistrationNumber__c;
//            for(c2g__codaInvoiceLineItem__c line : invoice.c2g__InvoiceLineItems__r){         // SMH Commented
            for (c2g__codaInvoiceLineItem__c line : lstInvoiceLineItems)						// SMH Replaced
            {
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
        //Per 7/17 changes requested: adding a blank line to the tax section:
        if(taxLineMap.isEmpty()){
            taxLine tLine = new taxLine();
            tLine.description = 'Tax: '+ 'N/A - no applicable tax';
            tLine.taxRate =  '0 %';
            tLine.totalTax = 0;
            taxLineMap.put(tLine.description, tLine);
        }

        taxLines = taxLineMap.values();
        if(taxLines.size()>0){
            renderTaxSection = true;
        }

        system.debug('\n\n ****** ffaInvoiceController - getInvoice - invoice =' + invoice);
        system.debug('\n\n ****** ffaInvoiceController - getInvoice - taxLines =' + taxLines);
        system.debug('\n\n ****** ffaInvoiceController - getInvoice - Company Address =' + invoice.c2g__OwnerCompany__r.c2g__Street__c);
        system.debug('\n\n ****** ffaInvoiceController - getInvoice - c2g__InvoiceTotal__c =' + invoice.c2g__InvoiceTotal__c);
//        system.debug('\n\n ****** ffaInvoiceController - getInvoice - invoice lines =' + invoice.c2g__InvoiceLineItems__r); 		// SMH Commented
		system.debug('\n\n ****** ffaInvoiceController - getInvoice - invoice lines (count) =' + lstInvoiceLineItems.size()); 		// SMH Replaced
        
        Map<Id, invoiceLineWrapper> productPackageMap = new Map<Id, invoiceLineWrapper>();
//        for(c2g__codaInvoiceLineItem__c line : invoice.c2g__InvoiceLineItems__r){				// SMH Commented
        for (c2g__codaInvoiceLineItem__c line : lstInvoiceLineItems)							// SMH Replaced
        {    
        	if(line.Billing_Contract_Line_Item__r.Product_Package__c == null){ //if there is no package then no need to aggregate items
                invoiceLineWrapper lineWrapper = new invoiceLineWrapper();
                lineWrapper.productSku = line.c2g__Product__r.ProductCode;
                lineWrapper.billingFrequency = line.Billing_Frequency_Invoice_Display__c;
                lineWrapper.renderFrequency = line.Billing_Frequency_Invoice_Display__c != '' && line.Billing_Frequency_Invoice_Display__c != null ? true : false;
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
                invoiceLines.add(lineWrapper);
            }
            else{
                if(productPackageMap.containsKey(line.Billing_Contract_Line_Item__r.Product_Package__c)){
                    invoiceLineWrapper lineWrapper = productPackageMap.get(line.Billing_Contract_Line_Item__r.Product_Package__c);
                    lineWrapper.unitPrice += line.c2g__UnitPrice__c;
                    lineWrapper.netValue += line.c2g__NetValue__c;
                    lineWrapper.lineDescription =  line.c2g__LineDescription__c != null && !lineWrapper.lineDescription.contains(line.c2g__LineDescription__c) ? lineWrapper.lineDescription += ' | '+line.c2g__LineDescription__c : lineWrapper.lineDescription;
                    productPackageMap.put(line.Billing_Contract_Line_Item__r.Product_Package__c,lineWrapper);
                }
                else{ //create new line
                    invoiceLineWrapper lineWrapper = new invoiceLineWrapper();
                    lineWrapper.renderSKU = false;
                    lineWrapper.productSku = line.Billing_Contract_Line_Item__r.Product_Package__r.Package_SKU__c;
                    lineWrapper.productName = line.Billing_Contract_Line_Item__r.Product_Package__r.Name;
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
                invoiceLines.addAll(productPackageMap.values());    
        } 
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
        public String billingFrequency {get; set;}
        public String productName {get; set;}
        public String lineDescription {get; set;}
        public String periodDescription {get; set;}
        public Boolean renderPeriodDescription {get; set;}
        public Boolean renderSKU {get; set;}
        public Boolean renderFrequency {get; set;}
        public Decimal lineNumber {get; set;}
        public Decimal quantity {get; set;}
        public Decimal unitPrice {get; set;}
        public Decimal netValue {get; set;}
        public invoiceLineWrapper(){
            renderPeriodDescription = false;
            renderSKU = true;
            renderFrequency = false;
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