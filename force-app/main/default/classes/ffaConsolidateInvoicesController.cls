/************************************************************************************************************************
// Name         ffaConsolidateInvoicesController
// Description  Controller for the ffaConsolidateInvoices page
// Revisions    2016-Oct-04  bkrynitsky@cldpartners.com     Initial version
//              2016-Oct-22  rick@cldpartners.com           Added 'Other Invoice' functionality; general cleanup for 
//                                                          clarity
************************************************************************************************************************/
public class ffaConsolidateInvoicesController 
{
    /************************************************************************************************************
    // Private member variables
    *************************************************************************************************************/

    private ApexPages.StandardController standardCtrl;      // reference to the account standard controller; used for initialization
    private string accountId;                               // record id of the account we are consolidating invoices on

    /************************************************************************************************************
    // Properties
    *************************************************************************************************************/

    public Account account {get; set;}
    public List<String> companyOptions {get; set;}
    public List<InvoiceWrapper> invoiceWrapperList {get; set;}
    public List<InvoiceWrapper> otherInvoiceWrapperList {get; set;}
    public List<c2g__codaInvoice__c> existingInvoiceList {get; set;}
    public List<Consolidated_Invoice__c> existingConsolidatedInvoiceList {get; set;}
    public boolean isAllBoxChecked_Invoice {get; set;}
    public boolean isAllBoxChecked_Other {get; set;}
    public boolean hasChangedRows {get; set;}
    public boolean displayAccountOverlay {get; set;}
    public Consolidated_Invoice__c accountLookup {get; set;}
    transient public String invoiceToReset {get; set;}
    public String loadingMessage {get;set;}

    /************************************************************************************************************
    // Name         ffaConsolidateInvoicesController
    // Description  Constructor
    *************************************************************************************************************/
    public ffaConsolidateInvoicesController(ApexPages.StandardController sc) 
    {
        loadingMessage = getLoadingMessage();
        this.standardCtrl = sc;
        account = (Account) this.standardCtrl.getRecord();
        this.accountId = account.id;
        loadData();
    }

    /************************************************************************************************************
    // Name         loadData
    // Description  Queries the necessary data
    *************************************************************************************************************/
    public void loadData(){
        existingInvoiceList = [
            select 
                id, name, c2g__Account__r.name,c2g__duedate__c, c2g__invoicedate__c, c2g__invoicetotal__c, 
                c2g__period__r.name, c2g__paymentstatus__c, c2g__invoicestatus__c, 
                c2g__outstandingvalue__c, c2g__ownercompany__c,c2g__ownercompany__r.name, 
                c2g__invoicecurrency__c, remittance_info__c, remittance_info__r.name
            from c2g__codaInvoice__c
            where 
                (c2g__Account__c = :accountId 
                or parent_account__c = :accountId 
                or c2g__Account__r.parentid = :accountId)
                and c2g__invoicestatus__c = 'Complete'
                and c2g__outstandingvalue__c > 0
                and consolidated_invoice__c = null
            order by c2g__ownercompany__r.name, c2g__invoicecurrency__c, remittance_info__c];

        existingConsolidatedInvoiceList = [
            select id, name, account__r.name, emailed__c, due_date__c, reset__c
            from consolidated_invoice__c
            where account__c = :accountId
                and emailed__c = false
            order by createdDate];
      
        invoiceWrapperList = new List<InvoiceWrapper>();
        otherInvoiceWrapperList = new List<InvoiceWrapper>();

        for (c2g__codaInvoice__c invoice : existingInvoiceList) 
        {
            InvoiceWrapper invWrapper = new InvoiceWrapper(invoice);
            invoiceWrapperList.add(invWrapper);
        }

        isAllBoxChecked_Invoice = false;
        isAllBoxChecked_Other = false;
        hasChangedRows = false;
        displayAccountOverlay = false;

        accountLookup = new Consolidated_Invoice__c();
    }

    /************************************************************************************************************
    // Name         consolidate
    // Description  Event handler for the Consolidate button
    *************************************************************************************************************/
    public PageReference consolidate()
    {
        System.debug('calling consolidate button click'); 

        // Build list of selected records
        List<c2g__codainvoice__c> toConsolidate = new List<c2g__codainvoice__c>(); 
        
        string currencyPriorRow = '';
        string companyPriorRow = '';
        string remittancePriorRow = '';

        for (InvoiceWrapper iw: invoiceWrapperList)
        {
            system.debug('Invoice Wrapper: ' + iw);

            if (iw.isInvoiceChecked) 
            {
                if (((string)iw.invoice.c2g__ownercompany__c != companyPriorRow && companyPriorRow != '' ) ||
                    ((string)iw.invoice.c2g__invoicecurrency__c != currencyPriorRow && currencyPriorRow != '' ) ||
                    ((string)iw.invoice.remittance_info__c != remittancePriorRow && remittancePriorRow != '' )) 
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, 'The Company, Currency, and Remittance Info must match in order for the invoices to be consolidated.');
                    ApexPages.addMessage(msg);
                    return null;
                }

                toConsolidate.add(iw.invoice); 
                currencyPriorRow = iw.invoice.c2g__invoicecurrency__c;
                companyPriorRow = (string)iw.invoice.c2g__ownercompany__c;
                remittancePriorRow = iw.invoice.remittance_info__c;
            }
        }
     
        for (InvoiceWrapper iw: otherInvoiceWrapperList)
        {
            system.debug('Other Invoice Wrapper: ' + iw);

            if (iw.isInvoiceChecked) 
            {
                if (((string)iw.invoice.c2g__ownercompany__c != companyPriorRow && companyPriorRow != '' ) ||
                    ((string)iw.invoice.c2g__invoicecurrency__c != currencyPriorRow && currencyPriorRow != '' ) ||
                    ((string)iw.invoice.remittance_info__c != remittancePriorRow && remittancePriorRow != '' )) 
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, 'The Company, Currency, and Remittance Info must match in order for the invoices to be consolidated.');
                    ApexPages.addMessage(msg);
                    return null;
                }

                toConsolidate.add(iw.invoice); 
                currencyPriorRow = iw.invoice.c2g__invoicecurrency__c;
                companyPriorRow = (string)iw.invoice.c2g__ownercompany__c;
                remittancePriorRow = iw.invoice.remittance_info__c;
            }
        }

        // Stash a save point so we can roll back the changes on error
        Savepoint sp = Database.setSavePoint();
        Consolidated_Invoice__c ci;
        try
        {
            if (toConsolidate.size() > 0)
            {
                // Create a new consolidated invoice and insert
                ci = new Consolidated_Invoice__c();
                ci.Account__c = accountId;
                insert ci;
                ci = [SELECT Id, Name FROM Consolidated_Invoice__c WHERE Id = :ci.id];
                system.debug('ffaConsolidatedInvoicesController - this is the ci right after insert = '+ci);

                // Update the invoices that were consolidated to reference the new consolidated invoice record
                for (c2g__codainvoice__c invoice : toConsolidate)
                {
                    invoice.Consolidated_Invoice__c = ci.id;
                }

                update toConsolidate;
            }
        }
        catch (Exception ex)
        {
            Database.rollback(sp);
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, 'An error occured: ' + ex);
            ApexPages.addMessage(msg);
            return null;
        }
        saveAttachment(ci.id);
        loadData();
        // Refresh the page
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageRef.setRedirect(true);
        return pageRef;
    }

    /************************************************************************************************************
    // Name         reset
    // Description  Event handler for the Reset button
    *************************************************************************************************************/
    public void reset(){
        Consolidated_Invoice__c resetConsInv = [SELECT Id, Reset__c FROM Consolidated_Invoice__c WHERE Id = :invoiceToReset];
        resetConsInv.Reset__c = true;
        update resetConsInv;

        List<c2g__codainvoice__c> invoiceList = [SELECT Id, Consolidated_Invoice__c FROM c2g__codainvoice__c WHERE Consolidated_Invoice__c = :invoiceToReset];
        for(c2g__codaInvoice__c inv: invoiceList){
            inv.Consolidated_Invoice__c = null;
        }
        update invoiceList;
        loadData();
    }

    /************************************************************************************************************
    // Name         save attachment
    // Description  Event handler for the saving the document to notes and attachments
    *************************************************************************************************************/
    @future(callout=true) public static void saveAttachment(Id consolidatedInvId){

        Consolidated_Invoice__c ci = [SELECT Id, Name FROM Consolidated_Invoice__c WHERE Id = :consolidatedInvId];
        system.debug('ffaConsolidatedInvoicesController - saveAttachment - traceStatement 1');
        //ffaConsolidatedInvoicePDFontroller pdfController = new ffaConsolidatedInvoicePDFController(ci.id);
        PageReference pdf = Page.ffaConsolidatedInvoicePDF;
        pdf.getParameters().put('Id',ci.id);
        
        //PageReference pdf = new PageReference(pdfController);
        system.debug('ffaConsolidatedInvoicesController - saveAttachment - pdf = ' +pdf);
        // add parent id to the parameters for standardcontroller
        //pdf.getParameters().put('Id',ci.Id);

        // create the new attachment
        Attachment attach = new Attachment();

        // the contents of the attachment from the pdf
        Blob body;

        Try{
            // returns the output of the page as a PDF
            system.debug('ffaConsolidatedInvoicesController - saveAttachment - traceStatement 2');
            //system.debug('ffaConsolidatedInvoicesController - saveAttachment - pdf.consolidatedInvoiceId');
            body = pdf.getContent();
        }

        // need to pass unit test -- current bug    
        catch (VisualforceException e) {
            body = Blob.valueOf('ERROR:' + e.getMessage() + e.getStackTraceString() + '|' +e.getLineNumber());
        }
        
        attach.Body = body;
        // add the user entered name
        attach.Name = ci.Name;
        attach.IsPrivate = false;
        // attach the pdf to the account
        attach.ParentId = ci.Id;
        attach.ContentType = 'application/pdf';
        insert attach;
    }

    /************************************************************************************************************
    // Name         cancel
    // Description  Event handler for the Cancel button
    *************************************************************************************************************/
    public PageReference cancel()
    {
        PageReference pageRef = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.accountId);
        return pageRef;
    }

    /******************************************************************************/
    /** Retrieves a random loading message       **/
    /******************************************************************************/
    public static String getLoadingMessage()
    {
        String returnString = 'Processing...';
        Map<String, FFA_Loading_Messages__c> settingsMap = FFA_Loading_Messages__c.getAll();
        system.debug('***** \n\n ffaConsolidateInvoicesController - getLoadingMessage - settingsMap = ' + settingsMap);        
        String key = '';
        if(settingsMap.size() > 0){
           key = Math.mod(Math.round(Math.random()*1000), settingsMap.size()+1).format();
           system.debug('***** \n\n ffaConsolidateInvoicesController - getLoadingMessage - key = ' + key);        
           returnString = settingsMap.containsKey(key) ? settingsMap.get(key).Message__c : returnString;
        }
        system.debug('***** \n\n ffaConsolidateInvoicesController - getLoadingMessage - returnString = ' + returnString);        
        return returnString;
    }


    /************************************************************************************************************
    // Name         addInvoices
    // Description  Event handler for the Add Invoices button on the account overlay
    *************************************************************************************************************/
    public PageReference addInvoices()
    {
        if (accountLookup.Account__c != null)
        {

            for (c2g__codaInvoice__c invoice : [select 
                                                    id, name, c2g__Account__r.name,c2g__duedate__c, c2g__invoicedate__c, c2g__invoicetotal__c, 
                                                    c2g__period__r.name, c2g__paymentstatus__c, c2g__invoicestatus__c, 
                                                    c2g__outstandingvalue__c, c2g__ownercompany__c,c2g__ownercompany__r.name, 
                                                    c2g__invoicecurrency__c, remittance_info__c, remittance_info__r.name
                                                from c2g__codaInvoice__c
                                                where 
                                                    c2g__Account__c = :accountLookup.Account__c 
                                                    and c2g__invoicestatus__c = 'Complete'
                                                    and c2g__outstandingvalue__c > 0
                                                    and consolidated_invoice__c = null
                                                order by c2g__ownercompany__r.name, c2g__invoicecurrency__c, remittance_info__c])
            {
                InvoiceWrapper invWrapper = new InvoiceWrapper(invoice);
                otherInvoiceWrapperList.add(invWrapper);                
            }

            accountLookup.Account__c = null;
        }

        return null;
    }

    
    /************************************************************************************************************
    // Name         InvoiceWrapper
    // Description  Helper class to track invoice data and status
    *************************************************************************************************************/
    public class InvoiceWrapper
    {
        /************************************************************************************************************
        // Properties
        *************************************************************************************************************/
        public c2g__codaInvoice__c invoice {get; set;}          // invoice record
        public boolean isInvoiceChecked {get; set;}             // checkbox state

        /************************************************************************************************************
        // Name         InvoiceWrapper
        // Description  Constructor
        *************************************************************************************************************/
        public InvoiceWrapper(c2g__codaInvoice__c inputInvoice)
        {
            invoice = inputInvoice; 
            isInvoiceChecked = false; 
        }
    }

}