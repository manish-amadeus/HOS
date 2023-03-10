/************************************************************************************************
Name            : AH_SINManager_Cntr Class
Author          : Shashikant Nikam
Created Date    : 10/22/2018
Last Mod By     : Shashikant Nikam
Last Mod Date   : 12/17/2019
NICC Reference  : 
Description     : Controller for AH_SINManager VF Page.
: Contains code to create & post Sales Invoices from BCLIs.
: 
: 
*************************************************************************************************/
public class AH_SINManager_Cntr 
{
    
    // PUBLIC OBJECT VARIABLES 
    public Billing_Contract__c dummyBC {get; set;}
    public Billing_Contract_Line_Item__c dummyBCLI {get; set;}
    
    // PUBLIC COLLECTIONS 
    public List<AH_SINManager_FUNCTIONS.bcWrapper> wrapList {get; set;}
    public List<AH_SINManager_FUNCTIONS.SINWrapper> SINWrapperList {get; set;}
    public List<apxjobs> apexJobsList {get; set;}
    public List<apxjobs1> apexjobsList1 {get; set;}
    public List<errorLogWrapper> errorWrapList {get; set;}
   // public List<SINWrapper> SINWrapperList2 ;
    
    // PUBLIC VARIABLES 
    public Boolean isAllChecked {get; set;} 
    public Boolean isCheckAllBCs {get; set;}
    public Integer listNumber {get; set;}
    public Integer totalPages {get; set;}  
    public Boolean disablePostBtn {get; set;}
    
    // PRIVATE VARIABLES 
    private List<AH_SINManager_FUNCTIONS.bcliWrapper> wrapperList;
    private List<AsyncApexJob> asyncJobList;
    private Transient List<NI_Admin_Error_Log__c> errorLogsList;
    private Map<Integer, List<String>> pageNumTobcliIDMap;
    private Set<String> bcQueryIds;
    private Set<Id> companyIds;
    private Id inputBC;
    private Id inputAccount;
    private Id inputCompany; 
    private integer iMode;
    private Integer paginationSize;
    
    private AH_SINManager_FUNCTIONS sinFuncs;
    private Map<String, String> successIds;
    private Set<Id> bcIds; 
    private List<String> erroredBCs;
    private Set<String> listOfErroredNames;
    private String uniqueString;
    private Integer totalRecordsCount; 
    
    // NEW ADDITIONAL VARIABLE.
    // VARIABLE TO COLLECT THE AGGREGATE QUERY RESULT.
    
    String groupByQuery2;
    // CONSTRUCTOR ====================================================
    public AH_SINManager_Cntr()
    {
        
        // INIT VARIABLES 
        dummyBC = new Billing_Contract__c();
        dummyBCLI = new Billing_Contract_Line_Item__c();  
        
        wrapperList = new List<AH_SINManager_FUNCTIONS.bcliWrapper>();
        SINWrapperList = new List<AH_SINManager_FUNCTIONS.SINWrapper>();
        
       // SINWrapperList2 = new List<SINWrapper>();
               
        isAllChecked = true;
        isCheckAllBCs = true;
        paginationSize = 30;
        listNumber = 0;
        totalPages = 0;
        pageNumTobcliIDMap = new Map<Integer, List<String>>();
        iMode = 1;	// DEFAULT TO RENEWALS SALES INVOICES 
        
        sinFuncs = new AH_SINManager_FUNCTIONS();        
        successIds = sinFuncs.successIds;
        bcIds = sinFuncs.bcIds;
        erroredBCs = sinFuncs.erroredBCs;
        listOfErroredNames = sinFuncs.listOfErroredNames;
        uniqueString = sinFuncs.uniqueString;
        totalRecordsCount = sinFuncs.totalRecordsCount;               
        
        if (ApexPages.CurrentPage().getParameters().containsKey('mode')) 
        {
            iMode = Integer.valueOf(ApexPages.CurrentPage().getParameters().get('mode'));
        }
        system.debug(' BEFORE RUN HISTORY()   *****');
        // GET THE LIST OF LAST 5 RUNS TO SHOW ON VF PAGE        
        getRunHistory(iMode);
        getErrorLogsList();  
        
        system.debug(' END OF COMSTRUCTOR   *****');
          
    }
    
    // PUBLIC BUTTON METHODS ==========================================
    public void fetchData()
    { 
        
        sinFuncs.successIds = new Map<String, String>();
        wrapperList = new List<AH_SINManager_FUNCTIONS.bcliWrapper>();
        
        // INPUT PARAMETERS
        inputBC = dummyBCLI.Billing_Contract__c;
        inputAccount = dummyBC.Account__c;
        inputCompany = dummyBC.Company__c;
        
        // COMPANY IDS
        List<c2g__codaCompany__c> currentCompanies = ffaUtilities.gerCurrentCompanies();
        companyIds = new Set<Id>();
        
        system.debug('inputCompany  :' + inputCompany);
        
        if (inputCompany != null)
        {
            companyIds.add(inputCompany);
        }
        else
        {
            system.debug('INSIDE ELSE ' + currentCompanies.size() );
            for (c2g__codaCompany__c c : currentCompanies)
            {
                companyIds.add(c.Id);
                
            }
        }  
        
        // GROUP BY RECORDS PER BILLING CONTRACT
        String groupByQuery = 'SELECT Billing_Contract__c, COUNT(ID) recCount ';
        groupByQuery += 'FROM Billing_Contract_Line_Item__c ';
        groupByQuery += 'WHERE Ready_to_Invoice__c = true ';
        groupByQuery += 'AND Invoiced__c = false ';
        groupByQuery += 'AND Total_Amount__c >= 0 ';
        groupByQuery += 'AND Type__c != \'Credit\' ';
        
        if(iMode == 1)           
        {
            groupByQuery += 'AND Activity_Line_Item__r.Origin__c = \'Renewal\'  ';
            groupByQuery += 'AND Billing_Contract__r.Company__r.Exclude_from_Automated_Renewal_Invoicing__c = false ' ;
        }
        else if(iMode == 2)    
        {
           
            groupByQuery += ' AND Activity_Line_Item__r.Origin__c != \'Renewal\' ';
            groupByQuery += 'AND Billing_Contract__r.Company__r.Excl_frm_Automated_NonRenewal_Invoicing__c = false ' ;
            groupByQuery += 'AND Billing_Contract__r.Opportunity__r.Order_Status__c = \'Definite\' ';
        }
        
        groupByQuery += 'AND Billing_Contract__r.Exclude_Automated_Invoicing__c = false  ';
        groupByQuery += 'AND Billing_Contract__r.Billing_Hold__c = FALSE  '; 
        
            
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
        
        SYSTEM.DEBUG('groupByQuery  :' + groupByQuery);
        
        system.debug('groupByQuery2  :' + groupByQuery2);
        groupByQuery2 = groupByQuery;
        
        
        bcQueryIds = new Set<String>();
        AggregateResult[] groupedResults = Database.query(groupByQuery2);
        
        system.debug('groupedResults  :' + groupedResults);
        
        if (groupedResults != null && groupedResults.size() > 0)
        { 
            for(AggregateResult ar : groupedResults)
            {             
                bcQueryIds.add(String.valueOf(ar.get('Billing_Contract__c')));
            }
        }
        system.debug('bcQueryIds  :' + bcQueryIds );
        Integer totalRecords = 0;
        totalRecords = bcQueryIds.size();
        totalPages = Integer.valueOf(totalRecords / paginationSize);
        Integer remainder = math.mod(totalRecords, paginationSize);
        
        if (remainder != 0)
        {
            totalPages = totalPages + 1;
        }
        
        // MAP OF PAGE NO TO BC IDS
        pageNumTobcliIDMap = new Map<Integer, List<String>>();
        List<String> bcIDList  = new List<String>();
        
        for (Integer i = 0; i < totalPages; i++)
        {
            pageNumTobcliIDMap.put(i, bcIDList);
        }
        
        String queryPart1 = getQuery();
        SYSTEM.DEBUG('queryPart1  :' + queryPart1);
        String query = queryPart1 + ' WHERE Exclude_Automated_Invoicing__c = false AND ID IN : bcQueryIds ORDER BY ID LIMIT : paginationSize ';
        
        SYSTEM.DEBUG('query  :' + query);
        List<Billing_Contract__c> BCS = new List<Billing_Contract__c>();
        BCS = Database.query(query);
        SYSTEM.DEBUG('query  :' + query);
        system.debug('BCS  :' + BCS);
        sinFuncs.totalRecordsCount = 0;
        if (!BCS.isEmpty())
        {
            wrapList = new List<AH_SINManager_FUNCTIONS.bcWrapper>();
            for (Billing_Contract__c bc : BCS)
            {
                
                if (bc.Billing_Contract_Line_Items__r != null)
                {                
                    AH_SINManager_FUNCTIONS.bcWrapper wr = new AH_SINManager_FUNCTIONS.bcWrapper();
                    wr.check = true;
                    wr.processed = false;
                    wr.bc = bc;
                    
                    List<AH_SINManager_FUNCTIONS.bcliWrapper> bcliWrapList = new List<AH_SINManager_FUNCTIONS.bcliWrapper>();
                    for (Billing_Contract_Line_Item__c bcli : bc.Billing_Contract_Line_Items__r)
                    {
                        AH_SINManager_FUNCTIONS.bcliWrapper bcliWrap = new AH_SINManager_FUNCTIONS.bcliWrapper();
                        bcliWrap.bcId = bcli.Billing_Contract__c;
                        bcliWrap.check = true;
                        bcliWrap.bcliObj = bcli;
                        bcliWrap.bcliObj.Invoice_Date__c = Date.today();
                        
                        bcliWrapList.add(bcliWrap);
                        wrapperList.add(bcliWrap);
                        sinFuncs.totalRecordsCount++;
                    }
                    
                    wr.bcliWrapperList = bcliWrapList;
                    wrapList.add(wr);
                }
            }
            system.debug('wrapperList  :' + wrapperList);
            // UPDATE INVOICE DATE ON BCLI RECORDS
            sinFuncs.updateInvoiceDate(wrapperList);
            
            if (!wrapList.isEmpty())
            {
                List<String> idList = new List<String>();
                idList.add(wrapList[0].bc.Id);
                idList.add(wrapList[wrapList.size()-1].bc.Id);
                pageNumTobcliIDMap.put(listNumber, idList);
            }
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, + 'Total Records count : ' + sinFuncs.totalRecordsCount));
        }
        else 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, 'Records not found.'));
        }
        
    }
    
    public void createInvoices()
    {
        sinFuncs.wrapList = wrapList;
        sinFuncs.wrapperList = wrapperList;  
        sinFuncs.SINWrapperList = SINWrapperList;
        SINWrapperList = sinFuncs.createInvoices();
    }
          
    public void postInvoices()
    {
     	system.debug('****** INSIDE POST METHOD AFTER HITING POST BUTN FROM VF PAGE ******');   
        sinFuncs.wrapList = wrapList;
        sinFuncs.wrapperList = wrapperList;  
        sinFuncs.SINWrapperList = SINWrapperList;
        system.debug('***** AFTER CLICKING POST BTN FRON VF PAGE BEFORE POST METHOD GET EXECUTE ******* ');
        disablePostBtn = sinFuncs.postInvoices(disablePostBtn); 
        system.debug('***** INSIDE POST METHOD disablePostBtn  :' + disablePostBtn);
    }
    
    public void refreshInvoices()
    {
        sinFuncs.wrapList = wrapList;
        sinFuncs.wrapperList = wrapperList;  
        sinFuncs.SINWrapperList = SINWrapperList;
        sinFuncs.refreshInvoices();
        Map<String,List<String>> refresCombinehMap = sinFuncs.refreshInvoices();
        disablePostBtn = false; 
        
        system.debug('disablePostBtn' + disablePostBtn);
        system.debug('refreshMap  :' + refresCombinehMap);

        List<String> convertedList = new List<String>();
        
        List<String> postBtnLst = new List<String>();
        
        if( !refresCombinehMap.isEmpty() && refresCombinehMap.ContainsKey('sinLst') )
        {
            system.debug(' *** INSIDE IF LOOP ****');
       		 convertedList = refresCombinehMap.get('sinLst');
        }
   
        if (convertedList != null && !convertedList.isEmpty())    
        {
            SINWrapperList = new List<AH_SINManager_FUNCTIONS.SINWrapper>();
            
            List<c2g__codaInvoice__c> insertedList2 = new List<c2g__codaInvoice__c>([
                SELECT Id, Name, Billing_Contract__c, c2g__Account__c,
                Billing_Contract__r.Name, 
                c2g__Account__r.Name, 
                c2g__InvoiceTotal__c,
                c2g__InvoiceStatus__c 
                FROM c2g__codaInvoice__c 
                WHERE Id IN : convertedList]); 
            
            system.debug('insertedList2  :' + insertedList2);
            
            for (c2g__codaInvoice__c sin : insertedList2)
            {
                AH_SINManager_FUNCTIONS.SINWrapper sinWrapObj = new AH_SINManager_FUNCTIONS.SINWrapper();
                sinWrapObj.SINObj = sin;
                
                if (sin.c2g__InvoiceStatus__c == 'In Progress')
                {
                    sinWrapObj.isDisabled = false;
                }
                else 
                {
                    if (sin.c2g__InvoiceStatus__c == 'Complete')
                    {
                        sinWrapObj.isDisabled = true;
                    }
                }    
                SINWrapperList.add(sinWrapObj);
            }  
            system.debug('UPDATED SINWrapperList  :' + SINWrapperList);
        }        
    }       
    
    public PageReference reset()   
    {
        
        paginationSize = 30;
        listNumber = 0;
        totalPages = 0;
        disablePostBtn = false;
        SINWrapperList = new List<AH_SINManager_FUNCTIONS.SINWrapper>();
        bcQueryIds = new Set<String>();
        dummyBCLI = new Billing_Contract_Line_Item__c();  
        dummyBC = new Billing_Contract__c();
        wrapperList = new List<AH_SINManager_FUNCTIONS.bcliWrapper>();
        isAllChecked = true;
        isCheckAllBCs = true;
        
        sinFuncs = new AH_SINManager_FUNCTIONS();        
        successIds = sinFuncs.successIds;
        bcIds = sinFuncs.bcIds;
        erroredBCs = sinFuncs.erroredBCs;
        listOfErroredNames = sinFuncs.listOfErroredNames;
        uniqueString = sinFuncs.uniqueString;
        totalRecordsCount = sinFuncs.totalRecordsCount;
        
        pageNumTobcliIDMap = new Map<Integer, List<String>>();
        wrapList = new List<AH_SINManager_FUNCTIONS.bcWrapper>();
        
        //GET THE LIST OF LAST 5 RUNS TO SHOW ON VF PAGE        
        getRunHistory(iMode);
        
        // GET THE ERROR LOGS
        getErrorLogsList();
        
        return null;
             
    }                    
    
    // PRIVATE METHODS ===============================================
    private String getQuery()
    {
        
        system.debug(' *** ENTERING AH_SINManager_Cntr.getQuery() - QUERIES ISSUED = ' + Limits.getQueries());
        
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
            ' WHERE Ready_to_Invoice__c = true ' +
            ' AND Invoiced__c = false '+
            ' AND Total_Amount__c >= 0 ' +
            ' AND Type__c != \'Credit\' ' ;
        
        	retQuery += 'AND Billing_Contract__r.Exclude_Automated_Invoicing__c = false ';
        	retQuery += 'AND Billing_Contract__r.Billing_Hold__c = false ';
   
            if(iMode == 1)                      
            {
                retQuery += ' AND Activity_Line_Item__r.Origin__c = \'Renewal\' ';
                retQuery += 'AND Billing_Contract__r.Company__r.Exclude_from_Automated_Renewal_Invoicing__c = false ' ;
            }  
            else if(iMode == 2)
            {
                retQuery += ' AND Activity_Line_Item__r.Origin__c != \'Renewal\' ';
                retQuery += ' AND Billing_Contract__r.Company__r.Excl_frm_Automated_NonRenewal_Invoicing__c = false ' ;
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

        system.debug('retQuery  :' + retQuery );
        return retQuery;
        
    }
    
    private void getRunHistory(Integer mode) 
    {
        
        List<String> classNames = new List<String>();
        
        if (mode == 2)
        {
            classNames.add('AH_SINManager_Sched_NonRenewals');
        }
        else 
        {
            classNames.add('AH_SINManager_Sched_Renewals');
        }        
        
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
                system.debug('apexJobsList  :' + apexJobsList );
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
            WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n', 'AsyncApexJob', 'AH_SINManager_Cntr.getRunHistory', 'SELECT');
        }
        
    }
    
    private void WriteToLog(String error, String obj, String className, String dml)
    {
        
        NI_Error_Logger.WriteToLog(error, obj, className, dml);
        getErrorLogsList();
        
    }    
    
    private void getErrorLogsList() 
    {
        
        errorLogsList = new List<NI_Admin_Error_Log__c>();
        
        List<String> classNames = new List<String>{
            'AH_SINManager_Cntr.getRunHistory',
                'AH_SINManager_Cntr.getErrorLogsList',
                'AH_SINManager_Cntr.validateBLIs',
                'AH_SINManager_Cntr.createInvoices',
                'AH_SINManager_Cntr',
                'AH_SINManager_Batch',
                'AH_SINManager_Sched_Renewals',
                'AH_SINManager_Sched_NonRenewals'
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
                        for (NI_Admin_Error_Log__c err : errorLogsList)
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
            WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n', 'NI_Admin_Error_Log__c', 'AH_SINManager_Cntr.getErrorLogsList', 'SELECT');
        }
        
    }
    
    // NAVIGATION METHODS ============================================
    public void next()
    {        
        if (pageNumTobcliIDMap.size() -1 > listNumber)
        {
            ++listNumber;
            nextRefreshList('Next');
            SINWrapperList = new List<AH_SINManager_FUNCTIONS.SINWrapper>();
            successIds = new Map<String, String>();
        }
    }
    
    public void previous()
    {
        if (0 < listNumber)
        {
            --listNumber;
            nextRefreshList('Previous');
            SINWrapperList = new List<AH_SINManager_FUNCTIONS.SINWrapper>();
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
    
    public boolean gethasPrevious()
    {
        if (listNumber > 0)
        { 
            return true;    
        }
        return false;
    }
    
    private void nextRefreshList(String pageType)
    {
        
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
        
        Id firstBCID = bcIDList1[0];
        Id lastBCID = bcIDList1[bcIDList1.size() - 1];
        String queryPart1 = getQuery();
        String query = queryPart1;
        query += ' WHERE Id IN : bcQueryIds ';
        
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
                    query += ' AND Id < : lastBCID ';
                }
                else 
                {
                    query += ' AND Id >=: firstBCID AND Id <=: lastBCID ';
                }
            }
        }
        
        query += ' ORDER BY Id LIMIT : paginationSize ';
        
        List<Billing_Contract__c> BCS = new List<Billing_Contract__c>();
        
        BCS = Database.query(query);  
        wrapperList = new List<AH_SINManager_FUNCTIONS.bcliWrapper>();
        wrapList = new List<AH_SINManager_FUNCTIONS.bcWrapper>();
        totalRecordsCount = 0;
        for (Billing_Contract__c bc : BCS)
        {
            if (bc.Billing_Contract_Line_Items__r != null)
            {
                AH_SINManager_FUNCTIONS.bcWrapper wr = new AH_SINManager_FUNCTIONS.bcWrapper();
                wr.check = true;
                wr.bc = bc;
                
                List<AH_SINManager_FUNCTIONS.bcliWrapper> bcliWrapList = new List<AH_SINManager_FUNCTIONS.bcliWrapper>();
                for (Billing_Contract_Line_Item__c bcli : bc.Billing_Contract_Line_Items__r)
                {
                    AH_SINManager_FUNCTIONS.bcliWrapper bcliWrap = new AH_SINManager_FUNCTIONS.bcliWrapper();
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
            sinFuncs.wrapList = wrapList;
            sinFuncs.wrapperList = wrapperList;  
            sinFuncs.SINWrapperList = SINWrapperList;
            sinFuncs.updateInvoiceDate(wrapperList);              
            
            if (pageNumTobcliIDMap.get(listNumber).isEmpty())
            {
                List<String> idList = new List<String>();
                idList.add(wrapList[0].bc.Id);
                idList.add(wrapList[wrapList.size() - 1].bc.Id);
                
                pageNumTobcliIDMap.put(listNumber, idList);
            }
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,  + 'Total Records count : ' + totalRecordsCount));
        }
        
    }    
    
    // WRAPPER CLASSES =============================================== 
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
	
}