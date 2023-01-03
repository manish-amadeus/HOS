/************************************************************************************************
Name            : AH_ManageSalesInvoicesController Class
Author          : Shashikant Nikam
Created Date    : 10/22/2018
Last Mod By     : Shashikant Nikam
Last Mod Date   : 01/29/2019
NICC Reference  : 
Description     : Controller for AH_ManageSalesInvoices VF Page.
                : Contains code to create & post Sales Invoices from BCLIs.
                : 
				: 
*************************************************************************************************/
public class AH_ManageSalesInvoicesController 
{

    // VARIABLES ======================================================
    public Billing_Contract__c dummyBC {get; set;}
    public Billing_Contract_Line_Item__c dummyBCLI {get; set;}
    
    // LIST COLLECTIONS OF WRAPPER CLASS OBJECTS
    public List<bcWrapper> wrapList {get; set;}
    public List<bcliWrapper> wrapperList {get; set;}
    public List<SINWrapper> SINWrapperList {get; set;}
    public List<errorLogWrapper> errorWrapList {get; set;}
    public List<apxjobs> apexJobsList {get; set;}
    public List<apxjobs1> apexjobsList1 {get; set;}
    
    public Transient List<NI_Admin_Error_Log__c> errorLogsList {get; set;}
    public List<AsyncApexJob> asyncJobList {get; set;}
	
    public Boolean isAllChecked {get; set;} 
    public Boolean isCheckAllBCs {get; set;}
    public Set<String> listOfErroredNames; 
    public Set<Id> bcIds; 
    public List<String> erroredBCs;
    public Map<String, String> successIds;

    public Integer paginationSize;
    public Integer listNumber {get; set;}
    public Integer totalPages {get; set;}
    private Integer totalRecordsCount {get; set;}
    public static Boolean disablePostBtn {get; set;}
    public String uniqueString;
    
    private Id inputBC;
    private Id inputAccount;
    private Id inputCompany;
    private Set<String> bcQueryIds;
    
	private Map<Integer, List<String>> pageNumTobcliIDMap;
    private Set<Id> companyIds;
    
    
    // CONSTRUCTOR ====================================================
    public AH_ManageSalesInvoicesController()
    {
		
        system.debug(' *** ENTERING AH_ManageSalesInvoicesController - CONSTRUCTOR  - QUERIES ISSUED = ' + Limits.getQueries());
		
        SINWrapperList = new List<SINWrapper>();

        paginationSize = 30;
        listNumber = 0;
        totalPages = 0;
        
        dummyBCLI = new Billing_Contract_Line_Item__c();  
        dummyBC = new Billing_Contract__c();
        wrapperList = new List<bcliWrapper>();
        isAllChecked = true;
        isCheckAllBCs = true;
        listOfErroredNames = new Set<String>();
        bcIds = new Set<ID>();
        erroredBCs = new List<String>();

        pageNumTobcliIDMap = new Map<Integer, List<String>>();
        
        //GET THE LIST OF LAST 5 RUNS TO SHOW ON VF PAGE        
        getRunHistory();
        
        // GET THE ERROR LOGS
        getErrorLogsList();
        
        system.debug(' *** EXITING AH_ManageSalesInvoicesController - CONSTRUCTOR  - QUERIES ISSUED = ' + Limits.getQueries());
		
    }

    // BUTTON METHODS =================================================
    public void fetchData()
    { 
        
        system.debug(' *** ENTERING AH_ManageSalesInvoicesController.fetchData() - QUERIES ISSUED = ' + Limits.getQueries());
		
        successIds = new Map<String, String>();
        wrapperList = new List<bcliWrapper>();
        
        // INPUT PARAMETERS
        inputBC = dummyBCLI.Billing_Contract__c;
        inputAccount = dummyBC.Account__c;
        inputCompany = dummyBC.Company__c;
        
        // COMPANY IDS
        List<c2g__codaCompany__c> currentCompanies = ffaUtilities.gerCurrentCompanies();
        companyIds = new Set<Id>();
        if (inputCompany != null)
        {
            companyIds.add(inputCompany);
        }
        else
        {
            for (c2g__codaCompany__c c : currentCompanies)
            {
                companyIds.add(c.id);
            }
        }

        // BUILD SOQL QUERY
        String groupByQuery = 'SELECT Billing_Contract__c, COUNT(ID) recCount ';
        groupByQuery += 'FROM Billing_Contract_Line_Item__c ';
        groupByQuery += 'WHERE Ready_to_Invoice__c = true ';
        groupByQuery += 'AND Type__c != \'Credit\' ';
        groupByQuery += 'AND Total_Amount__c > 0 ';
        //groupByQuery += 'AND Exclude_Automated_Invoicing__c = false ';
        groupByQuery += 'AND Invoiced__c = false ';
        groupByQuery += 'AND Activity_Line_Item__r.Origin__c = \'Renewal\' ';
        
        if (inputBC != null)
        {
            groupByQuery += 'AND Billing_Contract__r.Id =: inputBC ';
        }
        
        if (inputAccount != null)
        {
            groupByQuery += 'AND Billing_Contract__r.Account__c =: inputAccount ';
        }
        
        if (inputCompany != null)
        {
            groupByQuery += 'AND Billing_Contract__r.Company__c =: inputCompany ';
        }
        
        groupByQuery += 'GROUP BY Billing_Contract__c ';

        system.debug(' **** groupByQuery = ' + groupByQuery);
        system.debug(' **** inputBC = ' + inputBC);
        system.debug(' **** inputAccount = ' + inputAccount);
        
        bcQueryIds = new Set<String>();
        AggregateResult[] groupedResults = Database.query(groupByQuery);
        
        system.debug(' **** groupedResults.size() = ' + groupedResults.size());
        
        if (groupedResults != null && groupedResults.size() > 0)
        { 
            for(AggregateResult ar : groupedResults)
            {             
                bcQueryIds.add(String.valueOf(ar.get('Billing_Contract__c')));
            }
        }
        
        Integer totalRecords = 0;
        totalRecords = bcQueryIds.size();
        totalPages = Integer.valueOf(totalRecords / paginationSize);
        Integer remainder = math.mod(totalRecords, paginationSize);
        
        system.debug(' **** bcQueryIds size = ' + totalRecords);
        system.debug(' **** totalPages = ' + totalPages);
        
        if (remainder != 0)
        {
            totalPages = totalPages + 1;
        }
        
        system.debug(' **** Total no of pages = ' + totalPages);
        
        // MAP OF PAGE NO TO BC IDS
        pageNumTobcliIDMap = new Map<Integer, List<String>>();
		List<String> bcIDList  = new List<String>();
        for (Integer i = 0; i < totalPages; i++)
        {
            pageNumTobcliIDMap.put(i, bcIDList);
        }
        
        String queryPart1 = getQuery();
        
        //String query = queryPart1 + ' WHERE Id IN : bcQueryIds ORDER BY Id LIMIT : paginationSize ';
        String query = queryPart1 + ' WHERE Exclude_Automated_Invoicing__c = false AND ID IN : bcQueryIds ORDER BY ID LIMIT : paginationSize ';
                
        system.debug(' **** query = ' + query);
                
        List<Billing_Contract__c> BCS = new List<Billing_Contract__c>();
        BCS = Database.query(query);
        
        system.debug(' **** BCS.size() = ' + BCS.size());
        
        totalRecordsCount = 0;
            
        if (!BCS.isEmpty())
        {
            wrapList = new List<bcWrapper>();
            for (Billing_Contract__c bc : BCS)
            {
system.debug(' **** bc.Name = ' + bc.Name);
                //if (!bc.Billing_Contract_Line_Items__r.isEmpty() && bc.Billing_Contract_Line_Items__r != null)
                if (bc.Billing_Contract_Line_Items__r != null)
                {
system.debug(' **** bc has items ');                    
                    bcWrapper wr = new bcWrapper();
                    wr.check = true;
                    wr.processed = false;
                    wr.bc = bc;
                    
                    List<bcliWrapper> bcliWrapList = new List<bcliWrapper>();
                    for (Billing_Contract_Line_Item__c bcli : bc.Billing_Contract_Line_Items__r)
                    {
                        bcliWrapper bcliWrap = new bcliWrapper();
                        bcliWrap.bcId = bcli.Billing_Contract__c;
                        bcliWrap.check = true;
                        bcliWrap.bcliObj = bcli;
                        bcliWrap.bcliObj.Invoice_Date__c = Date.today();
                        
                        bcliWrapList.add(bcliWrap);
                        wrapperList.add(bcliWrap);
                        totalRecordsCount++;
                    }
                    
                    wr.bcliWrapperList = bcliWrapList;
                    wrapList.add(wr);
                }
            }

            system.debug(' **** wrapList.size() = ' + wrapList.size());
            
            system.debug(' **** After query - CPU Time = ' + Limits.getCpuTime());
                
            // UPDATE INVOICE DATE ON BCLI RECORDS
            updateInvoiceDate();
            
            system.debug(' **** After update Invoice Date - CPU Time = ' + Limits.getCpuTime());
            
            if (!wrapList.isEmpty())
            {
                List<String> idList = new List<String>();
                idList.add(wrapList[0].bc.id);
                idList.add(wrapList[wrapList.size()-1].bc.id);
                pageNumTobcliIDMap.put(listNumber, idList);
                
                system.debug(' **** pageNumTobcliIDMap = ' + pageNumTobcliIDMap);
                system.debug(' **** totalPages = ' + totalPages);
            }
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,  + 'Total Records count : ' + totalRecordsCount));
        }
        else 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, 'Records not found.'));
        }
        
        system.debug(' *** EXITING AH_ManageSalesInvoicesController.fetchData() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }

    public void nextRefreshList(String pageType)
    {
        
        system.debug(' *** ENTERING AH_ManageSalesInvoicesController.nextRefreshList() - QUERIES ISSUED = ' + Limits.getQueries());
		
        system.debug(' **** listNumber = ' + listNumber);
        system.debug(' **** pageNumTobcliIDMap = ' + pageNumTobcliIDMap);
                     
        List<String> bcIDList1 = new List<String>();
        
        if (!pageNumTobcliIDMap.isEmpty())
        {
            if (pageType == 'Next')
            {
                bcIDList1 = pageNumTobcliIDMap.get(listNumber - 1);
            }
            else 
            {
                if (pageType == 'Previous') 
                {
                    bcIDList1 = pageNumTobcliIDMap.get(listNumber);
                }
            }
        }
        
        system.debug(' **** pageNumTobcliIDMap = ' + pageNumTobcliIDMap);
        
        Id firstBCID = bcIDList1[0];
        Id lastBCID = bcIDList1[bcIDList1.size() - 1];
        String queryPart1 = getQuery();
        String query = queryPart1;
        query += ' WHERE ID IN: bcQueryIds ';
        
        if (lastBCID != null && pageType == 'Next')
        {
            query += ' AND Id >: lastBCID ';
        }
        else 
        {
            if (firstBCID != null && lastBCID != null && pageType == 'Previous')
            {
                if (paginationSize == 1)
                {
                    query += ' AND Id <: lastBCID ';
                }
                else 
                {
                    query += ' AND Id >=: firstBCID AND Id <=: lastBCID ';
                }
            }
        }
        
        query += ' ORDER BY Id LIMIT : paginationSize ';
        
        List<Billing_Contract__c> BCS = new List<Billing_Contract__c>();
        
        system.debug(' **** query = ' + query);
        
        BCS = Database.query(query);

        wrapperList = new List<bcliWrapper>();
        wrapList = new List<bcWrapper>();
        totalRecordsCount = 0;
        for (Billing_Contract__c bc : BCS)
        {
            //if (!bc.Billing_Contract_Line_Items__r.isEmpty() && bc.Billing_Contract_Line_Items__r != null)
            if (bc.Billing_Contract_Line_Items__r != null)
            {
                bcWrapper wr = new bcWrapper();
                wr.check = true;
                wr.bc = bc;
                
                List<bcliWrapper> bcliWrapList = new List<bcliWrapper>();
                for (Billing_Contract_Line_Item__c bcli : bc.Billing_Contract_Line_Items__r)
                {
                    bcliWrapper bcliWrap = new bcliWrapper();
                    bcliWrap.bcId = bcli.Billing_Contract__c;
                    bcliWrap.check = true;
                    bcliWrap.bcliObj = bcli;
                    
                    bcliWrapList.add(bcliWrap);
                    wrapperList.add(bcliWrap);
                    totalRecordsCount++;
                }
                
                wr.bcliWrapperList = bcliWrapList;
                wrapList.add(wr);
        	}
        }

        if (!wrapList.isEmpty())
        {
            // UPDATE INVOICE DATE ON BCLI RECORDS
            updateInvoiceDate();
        
            system.debug(' **** wrapList[0].bc.id : ' + wrapList[0].bc.id);
            system.debug(' **** wrapList[wrapList.size() - 1].bc.id : ' + wrapList[wrapList.size() - 1].bc.id);
            
            if (pageNumTobcliIDMap.get(listNumber).isEmpty())
            {
                List<String> idList = new List<String>();
                idList.add(wrapList[0].bc.id);
                idList.add(wrapList[wrapList.size()-1].bc.id);
                
                pageNumTobcliIDMap.put(listNumber, idList);
            }
            
            system.debug(' **** pageNumTobcliIDMap = ' + pageNumTobcliIDMap);
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,  + 'Total Records count : ' + totalRecordsCount));
        }
        
        system.debug(' *** EXITING AH_ManageSalesInvoicesController.nextRefreshList() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }

    public void createInvoices()
    {
        
        system.debug(' *** ENTERING AH_ManageSalesInvoicesController.createInvoices() - QUERIES ISSUED = ' + Limits.getQueries());
        
        system.debug(' **** wrapList = ' + wrapList); 
        
        Integer recToProcess = 0;
        
        if (!wrapList.isEmpty())
        {
            List<bcliWrapper> wrapperList1 = new List<bcliWrapper>();
            for (bcWrapper wr : wrapList)
            {
                Integer i = recToProcess; 
                
                if (wr.check == true && wr.processed == false)
                {
                    i = i + wr.bcliWrapperList.size();
                    if (i <= 30)
                    {
                        wr.processed = true;
                        for (bcliWrapper bcliWrap : wr.bcliWrapperList)
                        {
                            if (bcliWrap.check == true)
                            {
                                recToProcess ++;
                                wrapperList1.add(bcliWrap);
                            }
                        }
                    }
                    else 
                    {
                        if (i > 30)
                        {
                            system.debug(' **** Limit crossed : ' + i);
                            break;
                        }
                    }
                }
            }
            
            system.debug(' **** recToProcess = ' + recToProcess);
            system.debug(' **** wrapperList1 size = ' + wrapperList1.size());
            
            // VALIDATION OF BCLIs
            listOfErroredNames = new Set<String>(); 
            bcIds = new Set<Id>();
            validateBLIs();
            
            system.debug(' **** Errored records size = ' + listOfErroredNames.size());
            
            // SHOW ERROR MESSAGES 
            if (!listOfErroredNames.isEmpty())
            {
                for (String error : listOfErroredNames)
                {
                    system.debug(' **** Error record : ' + error);
                    if (ApexPages.currentPage() != null)
                    {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, + error)); 
                    }
                }
                if (ApexPages.currentPage() != null)
                {
                	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,  + 'After fixing errors, click on Load Data & Create Invoice(s) again.'));
                }
            }
            
            system.debug(' **** bcIds = ' + bcIds);

            // PROCESS VALID RECORDS HERE
            if (!bcIds.isEmpty())
            {
                
                Map<Id, Billing_Contract__c> mapId2InvoiceDate = new Map<Id, Billing_Contract__c>();
                for (Billing_Contract__c bcs : [SELECT Id, Invoice_Date__c, Invoice_Due_Date__c FROM Billing_Contract__c WHERE Id IN : bcIds])
                {
                    mapId2InvoiceDate.put(bcs.Id, bcs);
                }
                
                List<c2g__codaInvoice__c> sinList = new List<c2g__codaInvoice__c>();
                List<c2g__codaInvoiceLineItem__c> sinLineItemList = new List<c2g__codaInvoiceLineItem__c>();
                List<Billing_Contract_Line_Item__c> updateBCLIList = new List<Billing_Contract_Line_Item__c>();
                
                Map<c2g__codaInvoiceLineItem__c, c2g__codaInvoice__c> sinToLineItem = new Map<c2g__codaInvoiceLineItem__c, c2g__codaInvoice__c>();
                Map<c2g__codaInvoiceLineItem__c, Billing_Contract_Line_Item__c> sinLineToBCLI = new Map<c2g__codaInvoiceLineItem__c, Billing_Contract_Line_Item__c>();
                
                Map<String, c2g__codaInvoice__c> bcToSinMap = new Map<String, c2g__codaInvoice__c>();
                
                for (bcWrapper wr : wrapList)
                {
                    system.debug(' **** wr.processed = ' + wr.processed);
                    if (wr.processed == true)
                    {
                        for (bcliWrapper bcliWrap : wr.bcliWrapperList)
                        {
                            if (bcliWrap.check == true && bcliWrap.isErrored == false)
                            {
                                bcliWrap.isDisabled = true;
                                bcliWrap.check = false;
                                
                                c2g__codaInvoice__c sinRecord = new c2g__codaInvoice__c();
                                
                                if (!bcToSinMap.containskey(bcliWrap.bcliObj.Billing_Contract__c))
                                {
                                    // CREATE SALES INVOICE
                                    sinRecord.Billing_Contract__c = bcliWrap.bcliObj.Billing_Contract__c;
                                    sinRecord.c2g__Opportunity__c = bcliWrap.bcliObj.Billing_Contract__r.Opportunity__c;
                                    sinRecord.c2g__Account__c = bcliWrap.bcliObj.Billing_Contract__r.Account__c;
                                    // HEATHER & SEAN CHANGE (START)
                                    //sinRecord.c2g__InvoiceDate__c = bcliWrap.bcliObj.Billing_Contract__r.Invoice_Date__c;
                                    sinRecord.c2g__InvoiceDate__c = mapId2InvoiceDate.get(bcliWrap.bcliObj.Billing_Contract__c).Invoice_Date__c;
                                    //sinRecord.c2g__DueDate__c = bcliWrap.bcliObj.Billing_Contract__r.Invoice_Due_Date__c;
                                    sinRecord.c2g__DueDate__c = mapId2InvoiceDate.get(bcliWrap.bcliObj.Billing_Contract__c).Invoice_Due_Date__c;
                                    // HEATHER & SEAN CHANGE (END)
                                    sinRecord.Collector__c = bcliWrap.bcliObj.Billing_Contract__r.Collector__c;
                                    sinRecord.c2g__OwnerCompany__c = bcliWrap.bcliObj.Billing_Contract__r.Company__c;
                                    if (bcliWrap.bcliObj.Billing_Contract__r.Accounting_Currency__c != null) 
                                    {
                                        sinRecord.c2g__InvoiceCurrency__c = bcliWrap.bcliObj.Billing_Contract__r.Accounting_Currency__c; 
                                    }
                                    sinRecord.Parent_Account__c = bcliWrap.bcliObj.Billing_Contract__r.Parent_Account_Id__c;
                                    sinRecord.Remittance_Info__c = bcliWrap.bcliObj.Billing_Contract__r.Remittance_Info__c;
                                    sinRecord.Summarize_Service_Lines__c = bcliWrap.bcliObj.Billing_Contract__r.Summarize_Service_Lines__c;
                                    sinRecord.PO_Number__c = bcliWrap.bcliObj.Billing_Contract__r.PO_Number__c;
                                    sinRecord.Bill_To_Contact__c = bcliWrap.bcliObj.Billing_Contract__r.Bill_to_Contact__c;
                                    sinRecord.c2g__Dimension3__c = bcliWrap.bcliObj.Product__r.Dimension_3__c;
                                    sinRecord.c2g__DeriveCurrency__c = false;
                                    sinRecord.c2g__CopyAccountValues__c = false;
                                    sinRecord.c2g__DeriveDueDate__c = false;
                                    
                                    system.debug(' **** sinRecord = ' + sinRecord);
                                    
                                    sinList.add(sinRecord);
                                    
                                    bcToSinMap.put(bcliWrap.bcliObj.Billing_Contract__c, sinRecord);
                                }
                                else 
                                {
                                    sinRecord = bcToSinMap.get(bcliWrap.bcliObj.Billing_Contract__c);
                                }
                                
                                // CREATE SALES INVOICE LINE ITEM
                                c2g__codaInvoiceLineItem__c sinLine = new c2g__codaInvoiceLineItem__c();

                                sinLine.Billing_Contract__c = bcliWrap.bcliObj.Billing_Contract__c;
                                sinLine.Activity_Line_Item__c = bcliWrap.bcliObj.Activity_Line_Item__c;
                                sinLine.ffrr_exa__ContractStartDate__c = bcliWrap.bcliObj.Start_Date__c;
                                //sinLine.c2g__UnitPrice__c = bcliWrap.bcliObj.Unit_Price__c;
                                if (bcliWrap.bcliObj.Unit_Price__c.scale() > 2)
                                {
                                    sinLine.c2g__UnitPrice__c = bcliWrap.bcliObj.Unit_Price__c.setScale(2, RoundingMode.HALF_UP);
                                }
                                else 
                                {
                                    sinLine.c2g__UnitPrice__c = bcliWrap.bcliObj.Unit_Price__c;
                                } 
                                sinLine.c2g__Dimension2__c = bcliWrap.bcliObj.Product__r.Dimension_2__c;
                                sinLine.c2g__Quantity__c = bcliWrap.bcliObj.Quantity__c;
                                sinLine.c2g__Product__c = bcliWrap.bcliObj.Product__c;
                                sinLine.c2g__Dimension3__c = bcliWrap.bcliObj.Product__r.Dimension_3__c;
                                sinLine.Billing_Contract_Line_Item__c = bcliWrap.bcliObj.id;
                                sinLine.c2g__DeriveUnitPriceFromProduct__c = false;
                                sinLine.ffrr_exa__ContractEndDate__c = bcliWrap.bcliObj.End_Date__c;
                                sinLine.c2g__LineDescription__c = bcliWrap.bcliObj.Line_Item_Description__c;
                                
                                system.debug(' **** sinLine = ' + sinLine);
                                
                                sinLineItemList.add(sinLine);                                
                                sinToLineItem.put(sinLine, sinRecord);
                                
                                Billing_Contract_Line_Item__c bcli = new Billing_Contract_Line_Item__c(id = bcliWrap.bcliObj.id);
                                bcli.Invoiced__c = true;
                                sinLineToBCLI.put(sinLine, bcli);
                            }
                        }
                    }
                }
                
                system.debug(' **** sinList size : '+sinList.size());

                if (!sinList.isEmpty())
                {
                    try 
                    {
                        // INSERT SALES INVOICES
                        Database.SaveResult[] result = Database.Insert(sinList, false);
                        
                        system.debug(' **** result = ' + result);    
                        
                        if (successIds == null || successIds.isEmpty())
                        {
                            successIds = new Map<String, String>();
                        }
                        
                        List<String> errors = new List<String>();
                        
                        // ITERATE THROUGH EACH RETURNED RESULT
                        for (Database.SaveResult sr : result) 
                        {
                            // OPERATION WAS SUCCESSFUL, SO GET THE ID OF THE RECORD THAT WAS PROCESSED
                            if (sr.isSuccess()) 
                            {
                                successIds.put(sr.getId(),sr.getId());
                            }
                            else 
                            {
                                // OPERATION FAILED, SO GET ALL ERRORS
                                for (Database.Error err : sr.getErrors()) 
                                {
                                    system.debug(' **** The following error has occurred: ' + err);
                                    system.debug(' **** ' + err.getStatusCode() + ': ' + err.getMessage());
                                    system.debug(' **** Fields that affected this error: ' + err.getFields());
                                    errors.add(String.valueOf(err.getFields()));
                                }
                            }
                        }

                        if (!successIds.isEmpty()) 
                        {
                            if (ApexPages.currentPage() != null) 
                            {
                                String IDList = String.join(successIds.values(), ',\n');
                                
                                ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.severity.CONFIRM, 'Successfully created Sales Invoices. Record size : ' + successIds.size());
                                ApexPages.addMessage(myMsg1);
                                
                                totalRecordsCount = totalRecordsCount - recToProcess;
                                ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.Info,'Records remaining to be processed : '+totalRecordsCount);
                                ApexPages.addMessage(myMsg2);
                            }
                            
                            system.debug(' **** sinToLineItem : '+sinToLineItem);
                            List<c2g__codaInvoiceLineItem__c> lineItemsList = new List<c2g__codaInvoiceLineItem__c>();
                            for (c2g__codaInvoiceLineItem__c lineItem: sinToLineItem.keyset())
                            {
                                c2g__codaInvoice__c SIN = new c2g__codaInvoice__c();
                                
                                SIN = sinToLineItem.get(lineItem);
                                if (SIN.ID != null) 
                                {    
                                    lineItem.c2g__Invoice__c = SIN.ID;
                                    lineItemsList.add(lineItem);
                                }
                                else 
                                {
                                    sinLineToBCLI.remove(lineItem);
                                }
                            }
                            
                            // INSERT SALES INVOICE LINE ITEMS
                            system.debug(' **** line item size : '+lineItemsList.size());
                            
                            if (!lineItemsList.isEmpty())
                            {
                                Database.insert(lineItemsList);
                            }
                            
                            // UPDATE BILLING COONTRACT LINE ITEMS AS Invoiced AFTER CREATING SIN RECORDS
                            updateBCLIList = sinLineToBCLI.values();
                            if (!updateBCLIList.isEmpty())
                            {
                                Database.update(updateBCLIList); 
                            }
                            
                            // CREATE SIN WRAPPER
                            createSINWrapper();
                        }
                        
                        system.debug(' **** errors = ' + errors);
                        
                        if (!errors.isEmpty())
                        {
                            erroredBCs = new List<String>();
                            for (c2g__codaInvoice__c sin : sinList)
                            {
                                if (sin.id == null)
                                {
                                    erroredBCs.add(sin.Billing_Contract__c);
                                }
                            }
                            
                            system.debug(' **** Error while creating invoices: ' + erroredBCs);
                            
                            String errList = String.join(errors, ',\n\n');
                            if (ApexPages.currentPage() != null) 
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Errors - ' + errList + ' Error in following Billing Contracts : '+erroredBCs)); 
                            WriteToLog ('Error Type: Fields are missing.' + ', \nCause: ' + errList + ' \n' + ' Error in following Billing Contracts : ' + erroredBCs, 'NI_Admin_Error_Log__c', 'AH_ManageSalesInvoicesController.createInvoices', 'INSERT');
                        }
                        
                        system.debug(' **** Queries after creating invoice : ' + Limits.getQueries());
                        system.debug(' **** After Create Invoice - CPU Time : ' + Limits.getCpuTime());
                    }
                    catch (Exception e)
                    {
                        system.debug(' **** Error Occured: ' + e.getMessage() + '\n Line: ' + e.getLineNumber() + '\n Cause:' + e.getCause());
                        if (ApexPages.currentPage() != null) 
                        {
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + '\n Line: ' + e.getLineNumber() + '\n Cause:' + e.getCause())); 
                        }
                        WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n', 'NI_Admin_Error_Log__c', 'AH_ManageSalesInvoicesController.createInvoices', 'INSERT');
                    }
                }
                else 
                {
                    if (ApexPages.currentPage() != null) 
                    {
                        system.debug(' **** Error Occured: #3');
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, 'Records not available to create Sales Invoice.'));
                    } 
                }
            }
            else 
            {
                if (ApexPages.currentPage() != null) 
                {
                    system.debug(' **** Error Occured: #2');
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, 'Records not available to create Sales Invoice.')); 
                }
            }
        }
        else
        { 
            if (ApexPages.currentPage() != null) 
            {
                system.debug(' **** Error Occured: #1');
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, 'Records not available to create Sales Invoice.')); 
            }
        }
        
        system.debug(' *** EXITING AH_ManageSalesInvoicesController.createInvoices() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    public void postInvoices()
    {
		
        system.debug(' *** ENTERING AH_ManageSalesInvoicesController.postInvoices() - QUERIES ISSUED = ' + Limits.getQueries());
		
        List<String> finalIDList = new List<String>();

        for (SINWrapper sinWrapObj : SINWrapperList)
        {
            if (sinWrapObj.check == true)
            {
                finalIDList.add(sinWrapObj.SINObj.id);
            }
        }
        system.debug('finalIDList size : '+finalIDList.size());
        
        if (!finalIDList.isEmpty())
        {
            disablePostBtn = true;
            DateTime myDateTime1 = DateTime.now();
            String s = myDateTime1.format();
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(s));
            uniqueString = EncodingUtil.convertToHex(hash).substring(0,30);
            
            try 
            {
                // POST SALES INVOICES USING BATCH - AH_BatchPostInvoices
                AH_BatchPostInvoices bch = new AH_BatchPostInvoices(finalIDList, erroredBCs, uniqueString);
                Database.executebatch(bch, 1);

                system.debug('After Post Invoice - CPU Time : '+Limits.getCpuTime());
                
                if (ApexPages.currentPage() != null) 
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, 'Records are being posted. Use Refresh List button to check the status.')); 
                }
                	
            }
            catch (Exception e)
            {
                system.debug('Error occured while posting an invoice ... at line number : '+ e.getLineNumber() +' => '+e);
                WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n','c2g__codaInvoice__c',  'AH_BatchPostInvoices', 'UPDATE');
            }
        }
        else 
        {
            if (ApexPages.currentPage() != null) 
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, 'Records not selected or posting.')); 
            }
        }
        
        system.debug(' *** EXITING AH_ManageSalesInvoicesController.postInvoices() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }
    
    public void refreshInvoices()
    {
        
        system.debug(' *** ENTERING AH_ManageSalesInvoicesController.refreshInvoices() - QUERIES ISSUED = ' + Limits.getQueries());
		
        system.debug(' **** SINWrapperList.size() = ' + SINWrapperList.size());
        createSINWrapper();
        
        system.debug(' *** EXITING AH_ManageSalesInvoicesController.refreshInvoices() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }

    public PageReference reset()
    {
        
        system.debug(' *** ENTERING AH_ManageSalesInvoicesController.reset() - QUERIES ISSUED = ' + Limits.getQueries());
		
        paginationSize = 30;
        listNumber = 0;
        totalPages = 0;
        disablePostBtn = false;
        uniqueString = '';
        
        SINWrapperList = new List<SINWrapper>();
        bcQueryIds = new Set<String>();
        dummyBCLI = new Billing_Contract_Line_Item__c();  
        dummyBC = new Billing_Contract__c();
        wrapperList = new List<bcliWrapper>();
        isAllChecked = true;
        isCheckAllBCs = true;
        listOfErroredNames = new Set<String>();
        bcIds = new Set<Id>();
        erroredBCs = new List<String>();
        successIds = new Map<String, String>();
        
        pageNumTobcliIDMap = new Map<Integer, List<String>>();
        wrapList = new List<bcWrapper>();
        
        //GET THE LIST OF LAST 5 RUNS TO SHOW ON VF PAGE        
        getRunHistory();
        
        // GET THE ERROR LOGS
        getErrorLogsList();
        
        system.debug(' *** EXITING AH_ManageSalesInvoicesController.reset() - QUERIES ISSUED = ' + Limits.getQueries());
		
        return null;
        
    }            

    // UTILITY METHODS ===============================================
    public void updateInvoiceDate()
    {
        
        system.debug(' *** ENTERING AH_ManageSalesInvoicesController.updateInvoiceDate() - QUERIES ISSUED = ' + Limits.getQueries());
		
        // COLLECT RECORDS TO UPDATE BCLI's INVOICE DATE AS TODAY'S DATE
        List<Billing_Contract_Line_Item__c> bcliUpdateList = new List<Billing_Contract_Line_Item__c>();
        if (!wrapperList.isEmpty())
        {
            for (bcliWrapper wrap1 : wrapperList)
            {
                if (wrap1.isUpdated == false)
                {
                    wrap1.bcliObj.Invoice_Date__c = Date.today();
                    wrap1.isUpdated = true;
                    bcliUpdateList.add(wrap1.bcliObj);
                }
            }
            
            if (!bcliUpdateList.isEmpty())
            {
                Database.update(bcliUpdateList);
            }
        }

        system.debug(' *** EXITING AH_ManageSalesInvoicesController.updateInvoiceDate() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }

    public String getQuery()
    {
        
        system.debug(' *** ENTERING AH_ManageSalesInvoicesController.getQuery() - QUERIES ISSUED = ' + Limits.getQueries());
		
        string retQuery = 'SELECT Id, Name, Account__c, ' +
            ' Account__r.Name, Ready_to_Invoice_Numeric__c, ' +
            ' Company__c, Company__r.Name, ' + 
            ' (SELECT ID, Name,' + 
            ' Billing_Contract__c, ' +
            ' Billing_Contract__r.Company__c, ' +
            ' Billing_Contract__r.Account__c, ' +
            ' Billing_Contract__r.Name, ' +
            ' Billing_Contract__r.Account__r.Name, ' +
            ' Billing_Contract__r.Company__r.Name, ' +
            ' Billing_Contract__r.Accounting_Currency__c, ' +
            ' Billing_Contract__r.Accounting_Currency__r.c2g__Home__c, ' +
            ' Billing_Contract__r.Accounting_Currency__r.c2g__Dual__c, ' +
            ' Billing_Contract__r.Account__r.c2g__CODATaxCalculationMethod__c, ' +
            ' Billing_Contract__r.Remittance_Info__c, ' +
            ' Billing_Contract__r.Opportunity__c,' +
            ' Billing_Contract__r.Invoice_Date__c, ' +
            ' Billing_Contract__r.Collector__c, ' +
            ' Billing_Contract__r.Invoice_Due_Date__c, ' +
            ' Billing_Contract__r.Parent_Account_Id__c, ' +
            ' Billing_Contract__r.Summarize_Service_Lines__c, ' +
            ' Billing_Contract__r.PO_Number__c, ' +
            ' Billing_Contract__r.Bill_to_Contact__c, ' +
            ' Billing_Contract__r.Invoice_Date_Override__c, ' +
            ' Billing_Contract__r.Next_Invoice_Date__c, ' +
            ' Activity_Line_Item__r.Payment_Terms__c, ' +
            ' Activity_Line_Item__r.Name, ' +
            ' Product__c, '+
            ' Product__r.Name, '+
            ' Product__r.IsActive, ' +
            ' Product__r.Dimension_3__c, ' +
            ' Product__r.Dimension_2__c, ' +
            ' Product__r.Dimension_3__r.Name, ' +
            ' Product__r.c2g__CODASalesRevenueAccount__c, ' +
            ' Activity_Line_Item__c, ' +
            ' Start_Date__c, ' +
            ' Unit_Price__c, ' +
            ' Dimension_2__c, ' +
            ' Quantity__c, ' +
            ' Dimension_3__c, ' +
            ' End_Date__c, ' +
            ' Line_Item_Description__c, ' +
            ' Total_Amount__c, ' +
            ' Invoiced__c, ' +
            ' Ready_to_Invoice__c, ' +
            ' Invoice_Date__c ' +
            ' FROM Billing_Contract_Line_Items__r ' +
            ' WHERE  Ready_to_Invoice__c = true ' +
            ' AND Type__c != \'Credit\' ' +
            ' AND Total_Amount__c > 0 ' +
            //' AND Exclude_Automated_Invoicing__c = false ' +
            ' AND Invoiced__c = false ';

        if (Test.isRunningTest() == false)
        {
            retQuery += ' AND Activity_Line_Item__r.Origin__c = \'Renewal\' ';
            retQuery += ' AND Billing_Contract__r.Company__c IN : companyIds ';
        }
        
        if (inputBC != null)
        {
            retQuery += ' AND Billing_Contract__r.Id =: inputBC ';
        }
        
        if (inputAccount != null)
        {
            retQuery += ' AND Billing_Contract__r.Account__c =: inputAccount ';
        }

        if (inputCompany != null)
        {
            retQuery += ' AND Billing_Contract__r.Company__c =: inputCompany '; 
        }
        
        retQuery +=  ' ) FROM Billing_Contract__c ';

        system.debug(' *** EXITING AH_ManageSalesInvoicesController.getQuery() - QUERIES ISSUED = ' + Limits.getQueries());
		
        return retQuery;
        
    }

    private void createSINWrapper()
    {
        
        system.debug(' *** ENTERING AH_ManageSalesInvoicesControllerNew.createSINWrapper() - QUERIES ISSUED = ' + Limits.getQueries());
        
		SINWrapperList = new List<SINWrapper>();
        Integer successCnt = 0;
            
        system.debug(' **** successIds = ' + successIds);

        if (successIds != null && !successIds.isEmpty())
        {
            // CREATE SIN WRAPPER
            List<c2g__codaInvoice__c> insertedList = new List<c2g__codaInvoice__c>([
                SELECT Id, Name, Billing_Contract__c, c2g__Account__c,
                Billing_Contract__r.Name, 
                c2g__Account__r.Name, 
                c2g__InvoiceTotal__c,
                c2g__InvoiceStatus__c 
                FROM c2g__codaInvoice__c 
                WHERE Id IN : successIds.values()]);
            
            system.debug(' **** insertedList.size() = '+insertedList.size());
            
            for (c2g__codaInvoice__c sin : insertedList)
            {
                
                SINWrapper sinWrapObj = new SINWrapper();
                sinWrapObj.SINObj = sin;
                
                if (sin.c2g__InvoiceStatus__c == 'In Progress')
                {
                    sinWrapObj.isDisabled = false;
                    sinWrapObj.check = true;
                }
                else 
                {
                    if (sin.c2g__InvoiceStatus__c == 'Complete')
                    {
                        sinWrapObj.isDisabled = true;
                        successCnt++;
                    }
                }
                
                SINWrapperList.add(sinWrapObj);
                
            }
        }

        system.debug(' **** successCnt = ' + successCnt);

		if (uniqueString != null)
        {
            
            List<Job_Run_History__c> histRecList = new List<Job_Run_History__c>([SELECT ID, Unique_Timestamp__c 
                                                                                 FROM Job_Run_History__c 
                                                                                 WHERE Unique_Timestamp__c =: uniqueString]);
            
            system.debug(' **** histRecList = ' + histRecList);
            
            if (histRecList != null && !histRecList.isEmpty())
            {
                system.debug(' **** disablePostBtn = ' + disablePostBtn);
                system.debug(' **** All successfully posted');
                disablePostBtn = false;
            }
            else 
            {
                disablePostBtn = true;
            }
        }
        
        getRunHistory();
        getErrorLogsList();  
        
        system.debug(' *** EXITING AH_ManageSalesInvoicesControllerNew.createSINWrapper() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    private void validateBLIs()
    {
		
        system.debug(' *** ENTERING AH_ManageSalesInvoicesControllerNew.validateBLIs() - QUERIES ISSUED = ' + Limits.getQueries());
        
        system.debug(' **** wrapList.size() = ' + wrapList.size());

        for (bcWrapper wr : wrapList)
        {
            if (wr.processed == true)
            {
                for (bcliWrapper wrap : wr.bcliWrapperList)
                {
                    if (wrap.check == true)
                    {
                        //system.debug('in innner if');
                        Boolean errorFlag = false;
                        String errorMsg = '';
                        
                        // VALIDATION #1
                        if (wrap.bcliObj.Activity_Line_Item__r.Payment_Terms__c == null)
                        {
                            system.debug(' **** VALIDATION FAILED: wrap.bcliObj.Activity_Line_Item__r.Payment_Terms__c IS NULL ');
                            errorMsg = 'Invoice Term should be present on Activity Line Item : ' + wrap.bcliObj.Activity_Line_Item__r.Name;
                            listOfErroredNames.add(wrap.bcliObj.Name + ' : ' + errorMsg);
                            errorFlag = true;
                            wrap.isErrored = true;
                            WriteToLog(wrap.bcliObj.Name +' : '+errorMsg + ' \n', 'NI_Admin_Error_Log__c', 'AH_ManageSalesInvoicesController.validateBLIs', 'INSERT');
                        }
                        
                        // VALIDATION #2
                        if (wrap.bcliObj.Billing_Contract__r.Remittance_Info__c == null)
                        {
                            system.debug(' **** VALIDATION FAILED: wrap.bcliObj.Billing_Contract__r.Remittance_Info__c IS NULL ');
                            errorMsg = 'Remittance Info should be present on Billing Contract : ' + wrap.bcliObj.Billing_Contract__r.Name;
                            listOfErroredNames.add(wrap.bcliObj.Name + ' : ' + errorMsg);
                            errorFlag = true;
                            wrap.isErrored = true;
                            WriteToLog(wrap.bcliObj.Name +' : '+errorMsg + ' \n', 'NI_Admin_Error_Log__c', 'AH_ManageSalesInvoicesController.validateBLIs', 'INSERT');
                        }
                        
                        // VALIDATION #3
                        if (wrap.bcliObj.Product__r.Dimension_2__c == null)
                        {
                            system.debug(' **** VALIDATION FAILED: wrap.bcliObj.Product__r.Dimension_2__c IS NULL ');
                            errorMsg = 'Attention: Dimension 2 is required on all Sales Invoices.';
                            listOfErroredNames.add(wrap.bcliObj.Name + ' : ' + errorMsg);
                            errorFlag = true;
                            wrap.isErrored = true;
                            WriteToLog(wrap.bcliObj.Name + ' : ' + errorMsg + ' \n', 'NI_Admin_Error_Log__c', 'AH_ManageSalesInvoicesController.validateBLIs', 'INSERT');
                        }
                        
                        // VALIDATION #4
                        if (wrap.bcliObj.Product__r.Dimension_3__c == null)
                        {
                            system.debug(' **** VALIDATION FAILED: wrap.bcliObj.Product__r.Dimension_3__c IS NULL ');
                            errorMsg = 'Attention: Dimension 3 is required on all Sales Invoices.';
                            listOfErroredNames.add(wrap.bcliObj.Name + ' : ' + errorMsg);
                            errorFlag = true;
                            wrap.isErrored = true;
                            WriteToLog(wrap.bcliObj.Name + ' : ' + errorMsg + ' \n', 'NI_Admin_Error_Log__c', 'AH_ManageSalesInvoicesController.validateBLIs', 'INSERT');
                        }
                        
                        // VALIDATION #5
                        if (!wrap.bcliObj.Product__r.IsActive)
                        {
                            system.debug(' **** VALIDATION FAILED: wrap.bcliObj.Product__r.IsActive = false');
                            errorMsg = 'Attention: Product Is Inactive';
                            listOfErroredNames.add(wrap.bcliObj.Name + ' : ' + errorMsg);
                            errorFlag = true;
                            wrap.isErrored = true;
                            WriteToLog(wrap.bcliObj.Name + ' : ' + errorMsg + ' \n', 'NI_Admin_Error_Log__c', 'AH_ManageSalesInvoicesController.validateBLIs', 'INSERT');
                        }
                        
                        // COLLECT BILLING CONTRACTS TO CREATE SIN
                        if (errorFlag == false && wrap.isErrored == false)
                        {
                            bcIds.add(wrap.bcId);
                        }
                    }
                }
            }
        }
        
        system.debug(' **** bcIds : ' + bcIds);

        system.debug(' *** EXITING AH_ManageSalesInvoicesControllerNew.validateBLIs() - QUERIES ISSUED = ' + Limits.getQueries());
                     
    }
    
    private void getErrorLogsList() 
    {
        
        system.debug(' *** ENTERING AH_ManageSalesInvoicesControllerNew.getErrorLogsList() - QUERIES ISSUED = ' + Limits.getQueries());
        
        errorLogsList = new List<NI_Admin_Error_Log__c>();
    
        List<String> classNames = new List<String>{
            'AH_ManageSalesInvoicesController.getRunHistory',
            'AH_ManageSalesInvoicesController.getErrorLogsList',
            'AH_ManageSalesInvoicesController.validateBLIs',
            'AH_ManageSalesInvoicesController.createInvoices',
			'AH_ManageSalesInvoicesController',
			'AH_Schedule_SalesInvoices',
            'AH_BatchCreateInvoices',
			'AH_BatchPostInvoices'
		};
        
        try 
        {
            errorLogsList = [SELECT Id, 
                             Name, 
                             Apex_Class_Name__c, 
                             DML_Type__c, 
                             Message__c, 
                             Object_Name__c, 
                             CreatedBy.Name, 
                             CreatedDate 
                             FROM NI_Admin_Error_Log__c 
                             WHERE Apex_Class_Name__c IN : classNames  
                             ORDER BY createdDate DESC 
                             LIMIT 5
                            ];
            
            errorWrapList = new List<errorLogWrapper>();    
            
            if (!errorLogsList.isEmpty())
            {
                for (NI_Admin_Error_Log__c err: errorLogsList)
                {
                    errorLogWrapper e = new errorLogWrapper();
                    e.errorId = err.id;
                    e.Name = err.Name;
                    e.Object_Name = err.Object_Name__c;
                    e.Apex_Class_Name = err.Apex_Class_Name__c;
                    e.DML_Type = err.DML_Type__c;
                    e.Message = err.Message__c;
                    e.CreatedByName = err.CreatedBy.Name;
                    if (err.CreatedDate != null) 
                    {
                        e.CreatedDate = err.CreatedDate;
                    }
                    errorWrapList.add(e);
                }
            }
        }
        catch (Exception e)
        {
            system.debug(' **** Error Occurred: ' + e.getMessage());
            WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n', 'NI_Admin_Error_Log__c', 'AH_ManageSalesInvoicesController.getErrorLogsList', 'SELECT');
        }
        
        system.debug(' **** errorWrapList = ' + errorWrapList);
		
        system.debug(' *** EXITING AH_ManageSalesInvoicesControllerNew.getErrorLogsList() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void WriteToLog(String error, String obj, String className, String dml)
    {
        
        system.debug(' *** ENTERING AH_ManageSalesInvoicesControllerNew.WriteToLog() - QUERIES ISSUED = ' + Limits.getQueries());
        
        NI_Error_Logger.WriteToLog(error, obj, className, dml);
        getErrorLogsList();
        
        system.debug(' *** EXITING AH_ManageSalesInvoicesControllerNew.WriteToLog() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    private void getRunHistory() 
    {
        
        system.debug(' *** ENTERING AH_ManageSalesInvoicesControllerNew.getRunHistory() - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<String> classNames = new List<String>();
        classNames.add('AH_Schedule_SalesInvoices');
        
        try
        {
            asyncJobList  = new List<AsyncApexJob>();
            apexJobsList = new List<apxjobs>();
            
            asyncJobList = [SELECT Id,
                            ApexClassId, 
                            ApexClass.Name,
                            CompletedDate, 
                            CreatedBy.Name,  
                            Status, 
                            CreatedDate,  
                            ExtendedStatus, 
                            TotalJobItems, 
                            JobItemsProcessed, 
                            NumberOfErrors
                            FROM AsyncApexJob
                            WHERE ApexClassId IN (SELECT Id from ApexClass WHERE Name IN : classNames)
                            ORDER BY CreatedDate 
                            DESC LIMIT 5];
            
            if (!asyncJobList.isEmpty())
            {
                for (AsyncApexJob a : asyncJobList)
                {
                    apxjobs obj = new apxjobs();
                    obj.ApexClassID = a.ApexClassID;
                    obj.ApexClassName = a.ApexClass.Name;
                    obj.CreatedByName = a.CreatedBy.Name;
                    obj.Status = a.Status;
                    obj.CreatedDate = a.CreatedDate;
                    obj.TotalJobItems = a.TotalJobItems;
                    obj.JobItemsProcessed = a.JobItemsProcessed;
                    obj.NumberOfErrors = a.NumberOfErrors;
                    
                    if (a.CompletedDate != null) 
                    {
                        obj.CompletedDate = a.CompletedDate;
                    }
                    if (a.ExtendedStatus != null) 
                    {
                        obj.ExtendedStatus = a.ExtendedStatus;
                    }
                    
                    apexJobsList.add(obj);
                }
            }
            
            apexjobsList1 = new List<apxjobs1>();
            
            for (Job_Run_History__c r : [SELECT ID, Apex_Class__c, Created_Date__c, Status__c, 
                                         Target_Object__c, CreatedBy.Name, Status_Detail__c, No_of_Items_Processed__c  
                                         FROM Job_Run_History__c 
                                         WHERE Apex_Class__c IN : classNames 
                                         ORDER BY CreatedDate DESC 
                                         LIMIT 5])
            {
                apxjobs1 ap = new apxjobs1();
                ap.Apex_Class = r.Apex_Class__c;
                ap.user = r.CreatedBy.Name;
                ap.Status = r.Status__c;
                ap.Status_Detail = r.Status_Detail__c;
                ap.No_of_Items_Processed = Integer.valueOf(r.No_of_Items_Processed__c);
                ap.CreatedDate = r.Created_Date__c;
                ap.Target_Object = r.Target_Object__c;
                
                apexjobsList1.add(ap);
            }
        }
        catch (Exception e) 
        {
            system.debug(' **** Error Occurred: ' + e.getMessage());
            WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n', 'AsyncApexJob', 'AH_ManageSalesInvoicesController.getRunHistory', 'SELECT');
        }
        
        system.debug(' **** apexjobsList1 = ' + apexjobsList1);
        
        system.debug(' *** EXITING AH_ManageSalesInvoicesControllerNew.getRunHistory() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    // NAVIGATION METHODS ============================================
    public void next()
    {        
        if (pageNumTobcliIDMap.size() -1 > listNumber)
        {
            ++listNumber;
            nextRefreshList('Next');
            SINWrapperList = new List<SINWrapper>();
            successIds = new Map<String, String>();
        }
    }
    
    public boolean gethasNext()
    {
        if (listNumber < pageNumTobcliIDMap.size() -1)
        {
            return true;    
        }
        return false;
    }
    
    public void previous()
    {
        if (0 < listNumber)
        {
            --listNumber;
            nextRefreshList('Previous');
            SINWrapperList = new List<SINWrapper>();
            successIds = new Map<String, String>();
        }
        
    }
        
    public boolean gethasPrevious()
    {
        if (listNumber > 0)
        { 
            return true;    
        }
        return false;
    }

    // WRAPPER CLASSES ===============================================
    public class bcWrapper 
    {
        
        public Billing_Contract__c bc {get; set;}
        public List<bcliWrapper> bcliWrapperList {get; set;} 
        public boolean check {get; set;}
        public boolean isDisabled {get; set;}
        public boolean processed {get; set;}
        
        public bcWrapper()
        {
			check = true;
            bc = new Billing_Contract__c();
            bcliWrapperList = new List<bcliWrapper>();
            isDisabled = false;
            processed = false;
        }
    }

    public class bcliWrapper
    {
        public Billing_Contract_Line_Item__c bcliObj {get; set;}
        public ID bcId {get; set;}
        public ID accId {get; set;}
        public ID companyId {get; set;}
        public boolean readyToInvoice {get; set;}
        public Integer totalAmt {get; set;}
        public boolean check {get; set;}
        public boolean isErrored {get; set;} 
        public boolean isUpdated {get; set;}
        public boolean isDisabled {get; set;}
        
        public bcliWrapper()
        {
            bcliObj = new Billing_Contract_Line_Item__c();
            check = false;
            readyToInvoice = false;
            isErrored = false;
            isUpdated = false;
            isDisabled = false;
        }
    }
 
    public class SINWrapper 
    {
        public c2g__codaInvoice__c SINObj {get; set;}
        public boolean check {get; set;}
        public boolean isDisabled {get; set;}
        public SINWrapper()
        {
            SINObj = new c2g__codaInvoice__c();
        }
    }

    public class errorLogWrapper 
    {
        public ID errorId {get; set;}
        public String Name {get; set;}
        public String Object_Name {get; set;}
        public String Apex_Class_Name {get; set;}
        public String DML_Type {get; set;}
        public String Message {get; set;}
        public String CreatedByName {get; set;}
        public Datetime CreatedDate {get; set;}
        
        public errorLogWrapper() 
        {
            this.Name = '';
            this.Object_Name = '';
            this.Apex_Class_Name = '';
            this.DML_Type = '';
            this.Message = '';
            this.CreatedByName = '';
        }
    }

    public class apxjobs
    {            
        public Id ApexClassID {get; set;}
        public String ApexClassName {get; set;}
        public Datetime CompletedDate {get; set;}
        public String CreatedByName {get; set;}
        public String Status {get; set;}
        public Datetime CreatedDate {get; set;}
        public String ExtendedStatus {get; set;}
        public Integer TotalJobItems {get; set;}
        public Integer JobItemsProcessed {get; set;}
        public Integer NumberOfErrors {get; set;}
        
        public apxjobs()
        {
            this.CreatedByName = '';
            this.Status = '';
            this.ExtendedStatus = '';
            this.ApexClassName = '';
        }
    }
    
    public class apxjobs1
    {            
        public String Apex_Class {get; set;}
        public String user {get; set;}
        public String Status {get; set;}
        public Datetime CreatedDate {get; set;}
        public String Target_Object {get; set;}
        public String Status_Detail {get; set;}
        public Integer No_of_Items_Processed {get; set;}
        
        public apxjobs1()
        {
            this.Apex_Class = '';
            this.Status = '';
            this.Target_Object = '';
        }
    }
    
}