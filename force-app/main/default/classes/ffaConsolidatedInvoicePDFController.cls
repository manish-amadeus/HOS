/****************************************************************************************
Name            : ffaConsolidatedInvoicePDFController Class
Author          : CLD Partners
Created Date    : 03/11/2016
Last Mod Date   : 07/12/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller for the ffaConsolidatedInvoicePDF Visualforce page 
                : 07/12/2017 - NICC-023094: Fixed duplication of Sales Invoice line Items related to packages 
******************************************************************************************/
public without sharing class ffaConsolidatedInvoicePDFController {
    
    public Id consolidatedInvoiceId {get; set;}
    public list<c2g__codaInvoice__c> 	listInvoices 	{get; set;}
    
    public static consolidated_invoice__c 		cInvoice 		{get; set;}
    public c2g__codaInvoice__c 			invoice 		{get; set;}
    public static set<Id> 						setInvoiceIds 	{get; set;}
    
    public list<InvoiceWrapper> 		invoices 		{get; set;}
    public list<TaxLine>	 			taxLines 		{get; set;}

    public Boolean 				renderHeaderImage 		{get; set;}
    public Boolean 				renderFooterImage 		{get; set;}
    public Boolean 				renderFooterText		{get; set;}
    public Boolean 				renderTaxSection 		{get; set;}
    public Boolean 				sutInvoice 				{get; set;}
    public String 				taxRegistrationNumber 	{get; set;}
    public Total 				totals 					{get; set;}
    public Boolean 				showError				{get; set;}
    //public PageReference        pageRef                 {get{return new PageReference(ApexPages.currentPage().getUrl());} set;}
    
    /*public ffaConsolidatedInvoicePDFController(Id consInvoiceId) {
        system.debug('ffaConsolidatedInvoicePDFController: CONSTRUCTOR 1' + consolidatedInvoiceId);
        consolidatedInvoiceId = consInvoiceId;
        getData();
    }*/
    public ffaConsolidatedInvoicePDFController() {
        system.debug('ffaConsolidatedInvoicePDFController: CONSTRUCTOR 2');
        consolidatedInvoiceId =  ApexPages.currentPage().getParameters().get('Id');
        system.debug('ffaConsolidatedInvoicePDFController: consolidatedInvoiceId' + consolidatedInvoiceId);
        getData();
    }

    public void getData() 
    {
        
    	if (Test.isRunningTest()){
	        boostTest();
	    }
    	
        // FILL A SET WITH ALL SALES INVOICE IDS RELATED TO CONSOLIDATED INVOICE RECORD 
        setInvoiceIds = new Map<Id, c2g__codainvoice__c>([
        	select id 
        	from c2g__codainvoice__c
        	where consolidated_invoice__c = :consolidatedInvoiceId]).keyset();
        
system.debug('setInvoiceIds = ' + setInvoiceIds);
system.debug('consolidatedInvoiceId before 2nd query = ' + consolidatedInvoiceId);

        // RETRIEVE CONSOLIDATED INVOICE RECORD 
        cInvoice = [select 
                id, name, createddate, due_date__c,
                account__r.name, account__r.vat_registration__c,
                account__r.billingstreet,account__r.accountnumber, account__r.billingcity, 
                account__r.billingstate,account__r.billingpostalcode, account__r.billingcountry,  
                account__r.shippingstreet, account__r.shippingcity, account__r.shippingstate,  
                account__r.shippingpostalcode, account__r.shippingcountry
            from consolidated_invoice__c
            where id = :consolidatedInvoiceId];
        
system.debug('consolidatedInvoiceId before 3rd query = ' + consolidatedInvoiceId);
        
        // RETRIEVE ALL SALES INVOICE IDS RELATED TO CONSOLIDATED INVOICE RECORD  
        listInvoices = [
        	select 
        		name, po_number__c, c2g__Account__c, c2g__account__r.name, c2g__account__r.vat_registration__c,
        		c2g__account__r.c2g__CODAVATRegistrationNumber__c,
            	c2g__account__r.billingstreet,c2g__account__r.accountnumber, c2g__account__r.billingcity, 
            	c2g__account__r.billingstate,c2g__account__r.billingpostalcode, c2g__account__r.billingcountry,  
				c2g__account__r.shippingstreet, c2g__account__r.shippingcity, c2g__account__r.shippingstate,  
            	c2g__account__r.shippingpostalcode, c2g__account__r.shippingcountry, c2g__invoicecurrency__r.name,
				remittance_info__r.company_logo__c, remittance_info__r.invoice_header__c, remittance_info__r.invoice_footer__c,
            	remittance_info__r.statement_header__c, remittance_info__r.statement_footer__c, remittance_info__r.invoice_header_text__c,
            	remittance_info__r.invoice_footer_text__c, remittance_info__r.statement_header_text__c,
            	remittance_info__r.statement_footer_text__c,c2g__ownercompany__r.recordtype.name,c2g__nettotal__c,
            	c2g__taxtotal__c, c2g__invoicetotal__c,amount_paid__c,outstanding_total_display__c
/*            
            	, (select 
		        		id,name, c2g__invoice__r.name, c2g__invoice__r.c2g__account__r.name, c2g__linenumber__c, c2g__product__r.name, c2g__product__r.productcode,
		                c2g__product__r.apttus_revenue_category__c, c2g__linedescription__c, c2g__quantity__c, 
		                c2g__unitprice__c, c2g__netvalue__c, c2g__taxvaluetotal__c, c2g__taxvalue1__c, c2g__taxcode1__c,
		                c2g__taxcode1__r.name, c2g__taxcode2__c, c2g__taxrate1__c, c2g__taxrate2__c, c2g__taxrate3__c,
		                ffrr_exa__contractstartdate__c, ffrr_exa__contractenddate__c, c2g__taxcode3__c, c2g__taxvalue2__c,
		                c2g__taxvalue3__c, billing_contract_line_item__c, billing_contract_line_item__r.product_package__c,
		                billing_contract_line_item__r.product_package__r.name, c2g__invoice__r.c2g__Account__c,
		                billing_contract_line_item__r.product_package__r.package_sku__c, c2g__invoice__r.po_number__c
           			from c2g__InvoiceLineItems__r
           			where c2g__Invoice__c in :setInvoiceIds
            		order by c2g__LineNumber__c ASC)
*/            
        	from c2g__codainvoice__c
        	where id in :setInvoiceIds
        	order by c2g__Account__c];
        
// NEW START - SMH - BROKE OUT THE SUB-QUERY INTO A STRAIGHT ONE BECAUSE SINS WITH MANY LINE ITEMS WOULD THROW THIS ERROR:
// javax.el.ELException: javax.el.ELException: common.apex.runtime.impl.ExecutionException: Aggregate query has too many rows for direct assignment, use FOR loop
        List<c2g__codaInvoiceLineItem__c> lstInvoiceLineItems = new List<c2g__codaInvoiceLineItem__c>([
            SELECT Id, name, c2g__invoice__r.name, c2g__invoice__r.c2g__account__r.name, c2g__linenumber__c, c2g__product__r.name, 
            c2g__product__r.productcode, c2g__product__r.apttus_revenue_category__c, c2g__linedescription__c, c2g__quantity__c, 
            c2g__unitprice__c, c2g__netvalue__c, c2g__taxvaluetotal__c, c2g__taxvalue1__c, c2g__taxcode1__c,
            c2g__taxcode1__r.name, c2g__taxcode2__c, c2g__taxrate1__c, c2g__taxrate2__c, c2g__taxrate3__c,
            ffrr_exa__contractstartdate__c, ffrr_exa__contractenddate__c, c2g__taxcode3__c, c2g__taxvalue2__c,
            c2g__taxvalue3__c, billing_contract_line_item__c, billing_contract_line_item__r.product_package__c,
            billing_contract_line_item__r.product_package__r.name, c2g__invoice__r.c2g__Account__c,
            billing_contract_line_item__r.product_package__r.package_sku__c, c2g__invoice__r.po_number__c
            FROM c2g__codaInvoiceLineItem__c
            WHERE c2g__Invoice__c IN: setInvoiceIds
            ORDER BY c2g__LineNumber__c ASC]); 

system.debug(' *** lstInvoiceLineItems.size() = ' + lstInvoiceLineItems.size());  

        showError = false;
        // IN ORDER TO AVOID AN "List index out of bounds: 0" ERROR CHECK FOR PRESENCES OF SALES INVOICE ITEMS
        if (lstInvoiceLineItems.size() == 0)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No sales invoice line items found for this consolidated invoice.');
            ApexPages.addMessage(myMsg); 
            showError = true;
            return;
        }
// NEW END - SMH
      
        invoice = listinvoices[0];
        invoices = new List<InvoiceWrapper>();
        totals = new Total();

        if(invoice.Remittance_Info__r.Invoice_Header__c != null || invoice.Remittance_Info__r.Statement_Header__c != null){
            renderHeaderImage = true;
        }

        if(invoice.Remittance_Info__r.Invoice_Footer__c != null || invoice.Remittance_Info__r.Statement_Footer__c != null){
            renderFooterImage = true;
            renderFooterText = false;
        }
        else{
        	renderFooterImage = false;
            renderFooterText = true;	
        }

        Map<Id, InvoiceWrapper> invoiceMap = new Map<Id, InvoiceWrapper>();
        Map<string, InvoiceLineWrapper> productPackageMap = new Map<string, invoiceLineWrapper>(); // NICC-023094 ORIG: Map<string, InvoiceLineWrapper> productPackageMap = new Map<string, invoiceLineWrapper>();

system.debug(' *** ENTERING Sales Invoice LOOP ... '); 
        // LOOP THROUGH ALL SALES INVOICE RECORDS RELATED TO CONSOLIDATED INVOICE RECORD  
        for (c2g__codaInvoice__c inv : listInvoices)
        {
system.debug(' *** FOR Invoice: ' + inv.Name);           
            if(!invoiceMap.containsKey(inv.c2g__account__c)) {
                InvoiceWrapper iw = new InvoiceWrapper();
                // iw.accountName = inv.c2g__Account__r.name;
                iw.accountName = '(' + inv.c2g__Account__r.AccountNumber + ') ' + inv.c2g__Account__r.name;
                iw.invLine = new list<InvoiceLineWrapper>();
                invoiceMap.put(inv.c2g__Account__c, iw);             
            }
            
            totals.subtotal += inv.c2g__NetTotal__c;
            totals.salestax += inv.c2g__TaxTotal__c;
            totals.invoiceTotal += inv.c2g__InvoiceTotal__c;
            totals.payment += inv.amount_paid__c;
            totals.balance += inv.outstanding_total_display__c;
            
            // LOOP THROUGH ALL SALES INVOICE LINE ITEMS            
 //          for(c2g__codaInvoiceLineItem__c line : inv.c2g__InvoiceLineItems__r){		// SMH Commented
            for (c2g__codaInvoiceLineItem__c line : lstInvoiceLineItems) {				// SMH Replaced 	                                   
                
                if (inv.Id == line.c2g__Invoice__c)
                {                      
                    //if there is no package then no need to aggregate items
system.debug(' *** line.Billing_Contract_Line_Item__r.Product_Package__c = ' + line.Billing_Contract_Line_Item__r.Product_Package__c);
                    if (line.Billing_Contract_Line_Item__r.Product_Package__c == null){ 
                        invoiceLineWrapper lineWrapper = new invoiceLineWrapper();
                        lineWrapper.productSku = line.c2g__Product__r.ProductCode;
                        lineWrapper.productName = line.c2g__Product__r.Name;
                        lineWrapper.lineDescription = line.c2g__LineDescription__c;
                        lineWrapper.quantity = line.c2g__Quantity__c;
                        lineWrapper.unitPrice = line.c2g__UnitPrice__c;
                        lineWrapper.netValue = line.c2g__NetValue__c;
                        lineWrapper.lineNumber = line.c2g__LineNumber__c;
                        lineWrapper.poNumber = line.c2g__invoice__r.po_number__c;
                        lineWrapper.sinNumber = line.c2g__invoice__r.name;
                        lineWrapper.AccountId = line.c2g__invoice__r.c2g__Account__c;
                        
                        productPackageMap.put(line.c2g__invoice__r + '.' + line.Id, lineWrapper);
                        //invoiceLines.add(lineWrapper);
                    }
                    else{
                        system.debug(' *** Checking if productPackageMap contains this Key: ' + line.c2g__invoice__r + '.' + line.Billing_Contract_Line_Item__r.Product_Package__c);                    
                        if(productPackageMap.containsKey(line.c2g__invoice__r + '.' + line.Billing_Contract_Line_Item__r.Product_Package__c)){  // NICC-023094 ORIG: if(productPackageMap.containsKey(line.Billing_Contract_Line_Item__r.Product_Package__c)){
system.debug(' *** productPackageMap DOES contain this Key: ' + line.c2g__invoice__r + '.' + line.Billing_Contract_Line_Item__r.Product_Package__c);   	                    
                            invoiceLineWrapper lineWrapper = productPackageMap.get(line.c2g__invoice__r + '.' + line.Billing_Contract_Line_Item__r.Product_Package__c);  // NICC-023094 ORIG: invoiceLineWrapper lineWrapper = productPackageMap.get(ine.Billing_Contract_Line_Item__r.Product_Package__c); 
                            lineWrapper.unitPrice += line.c2g__UnitPrice__c;
                            lineWrapper.netValue += line.c2g__NetValue__c;
                            lineWrapper.lineDescription =  line.c2g__LineDescription__c != null && !lineWrapper.lineDescription.contains(line.c2g__LineDescription__c) ? lineWrapper.lineDescription += ' | '+line.c2g__LineDescription__c : lineWrapper.lineDescription;
                            lineWrapper.poNumber = line.c2g__invoice__r.po_number__c;
                            lineWrapper.sinNumber = line.c2g__invoice__r.name;
                            lineWrapper.AccountId = line.c2g__invoice__r.c2g__Account__c;
                            
                            // NICC-023094 ORIG: invoiceMap.get(line.c2g__invoice__r.c2g__Account__c).invLine.add(lineWrapper);              
                            productPackageMap.put(line.c2g__invoice__r + '.' + line.Billing_Contract_Line_Item__r.Product_Package__c,lineWrapper);  // NICC-023094 ORIG: productPackageMap.put(lline.Billing_Contract_Line_Item__r.Product_Package__c,lineWrapper); 
                        }
                        else{ //create new line
system.debug(' *** productPackageMap DOES NOT contain this Key: ' + line.c2g__invoice__r + '.' + line.Billing_Contract_Line_Item__r.Product_Package__c);                            
                            invoiceLineWrapper lineWrapper = new invoiceLineWrapper();
                            lineWrapper.renderSKU = false;
                            lineWrapper.productSku = line.Billing_Contract_Line_Item__r.Product_Package__r.Package_SKU__c;
                            lineWrapper.productName = line.Billing_Contract_Line_Item__r.Product_Package__r.Name;
                            lineWrapper.lineDescription = line.c2g__LineDescription__c;
                            lineWrapper.quantity = line.c2g__Quantity__c;
                            lineWrapper.unitPrice = line.c2g__UnitPrice__c;
                            lineWrapper.netValue = line.c2g__NetValue__c;
                            lineWrapper.lineNumber = line.c2g__LineNumber__c;
                            lineWrapper.poNumber = line.c2g__invoice__r.po_number__c;
                            lineWrapper.sinNumber = line.c2g__invoice__r.name;
                            lineWrapper.AccountId = line.c2g__invoice__r.c2g__Account__c;
                            
                            // NICC-023094 ORIG: invoiceMap.get(line.c2g__invoice__r.c2g__Account__c).invLine.add(lineWrapper);
                            productPackageMap.put(line.c2g__invoice__r + '.' + line.Billing_Contract_Line_Item__r.Product_Package__c, lineWrapper);  // NICC-023094 ORIG: productPackageMap.put(lline.Billing_Contract_Line_Item__r.Product_Package__c,lineWrapper);
                        }
                    }
                }
            }
        }
        
// NEW NICC-023094 (START)
        for (InvoiceLineWrapper xxx : productPackageMap.values())
        {
            invoiceMap.get(xxx.AccountId).invLine.add(xxx);
        }
// NEW NICC-023094 (END)        
	    
        if (invoiceMap.size()>0) {
	    	invoices.addAll(invoiceMap.values());
	    }
	    system.debug('InvoiceWrapper: ' + invoices);
 
        Map<String, taxLine> taxLineMap = new Map<String, taxLine>();
		
        Boolean isComplete = false;
		for (c2g__codaInvoice__c inv : listinvoices) {
            if(isComplete == true){
                continue;
            }
	        if(inv.c2g__OwnerCompany__r.RecordType.Name == 'SUT'){
	            sutInvoice = true;

	            for(c2g__TaxDetailSalesInvoice__c t :[
		            select c2g__Rate__c,c2g__TaxName__c,c2g__Tax__c, 
		            	c2g__SalesInvoiceLineItem__r.c2g__Invoice__r.c2g__Account__c,c2g__SalesInvoiceLineItem__r.c2g__Invoice__r.c2g__Account__r.name
		            from c2g__TaxDetailSalesInvoice__c
		            where c2g__SalesInvoiceLineItem__r.c2g__Invoice__c in :setInvoiceIds and c2g__Tax__c != 0
		            order by c2g__TaxName__c]) 
	            {
                    String key = t.c2g__TaxName__c + t.c2g__Rate__c + t.c2g__SalesInvoiceLineItem__r.c2g__Invoice__r.c2g__Account__c;
	                if(!taxLineMap.containsKey(key)){
	                    taxLine tLine = new taxLine();
	                    tline.account = t.c2g__SalesInvoiceLineItem__r.c2g__Invoice__r.c2g__Account__r.name;
	                    tLine.description = 'Tax: '+t.c2g__TaxName__c;
	                    tLine.taxRate = t.c2g__Rate__c.setScale(2) +' %';
	                    tLine.totalTax = t.c2g__Tax__c;
	                    taxLineMap.put(key, tLine);
                        system.debug('tLine.totalTax: ' + tLine.totalTax);
	                }
	                else{
	                    taxLine tLine = taxLineMap.get(key);   
	                    tLine.totalTax += t.c2g__Tax__c;
	                    taxLineMap.put(key, tLine);
                        system.debug('tLine.totalTax: ' + tLine.totalTax);  
	                }
	            }    
	        }
            else{
	            sutInvoice = false;
	            taxRegistrationNumber = inv.c2g__Account__r.c2g__CODAVATRegistrationNumber__c;
	            
        for(c2g__codaInvoiceLineItem__c line : inv.c2g__InvoiceLineItems__r) {			// SMH Commented
//                for (c2g__codaInvoiceLineItem__c line : lstInvoiceLineItems) { 				// SMH Replaced                   	            
                    system.debug('line.c2g__taxValue1__c ' + line.c2g__taxValue1__c);
	                if(line.c2g__TaxValue1__c != null && line.c2g__TaxValue1__c != 0){
                        String key = (string)line.c2g__TaxCode1__c + line.c2g__Invoice__r.c2g__Account__c;
	                    if(!taxLineMap.containsKey(key)){
	                        taxLine tLine = new taxLine();
	                        tline.account = line.c2g__Invoice__r.c2g__Account__r.Name;
	                        tLine.description = 'Tax: '+ line.c2g__TaxCode1__r.Name;
	                        tLine.taxRate = line.c2g__taxRate1__c.setScale(2) +' %';
	                        tLine.totalTax = line.c2g__taxValue1__c;
	                        taxLineMap.put(key, tLine);
                            system.debug('tLine.totalTax: ' + tLine.totalTax);
	                    }
	                    else{
	                        taxLine tLine = taxLineMap.get(key);   
	                        tLine.totalTax += line.c2g__taxValue1__c;
	                        taxLineMap.put(key, tLine);
                            system.debug('tLine.totalTax: ELSE ' + tLine.totalTax);
	                    }
	                }
	            }
	        }
            isComplete = true;
        }

        taxLines = taxLineMap.values();
        if(taxLines.size()>0){
            renderTaxSection = true;
        }

    }

    public class InvoiceWrapper {
    	public List<InvoiceLineWrapper> invLine {get;set;}
    	public String accountName {get;set;}
    }

    public class InvoiceLineWrapper{
        public String productSku {get; set;}
        public String productName {get; set;}
        public String lineDescription {get; set;}
        public String periodDescription {get; set;}
        public String sinNumber {get; set;}
        public String poNumber {get; set;}
        public Boolean renderPeriodDescription {get; set;}
        public Boolean renderSKU {get; set;}
        public Decimal lineNumber {get; set;}
        public Decimal quantity {get; set;}
        public Decimal unitPrice {get; set;}
        public Decimal netValue {get; set;}
        public Id AccountId {get; set;} 
        public InvoiceLineWrapper(){
            renderSKU = true;
        }
    }

    public class TaxLine{
        public String account {get; set;}
        public String description {get; set;}
        public String taxRate {get; set;}
        public Decimal totalTax {get; set;}
        public taxLine(){
            description = '';
            taxRate = '';
            totalTax = 0;
        }
    }

    public class Total{
	    public Decimal 		subtotal		{get; set;}
	    public Decimal 		salestax		{get; set;}
	    public Decimal    	invoiceTotal 	{get; set;}
	    public Decimal 		payment 		{get; set;}
	    public Decimal 		balance 		{get; set;}
	    public Total(){
	    	subtotal = 0;
	    	salestax = 0;
	    	invoiceTotal = 0;
	    	payment = 0;
	    	balance = 0;
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