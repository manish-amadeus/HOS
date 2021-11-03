/****************************************************************************************** 
Name            : AH_SINManager_FUNCTIONS
Author          : 
Created Date    : 10/17/2019
Modified Date	: 10/17/2019
Last Mod By     : 
NICC Reference  : 
Description     : Class that contains shared methods for AH_SINManager_Cntr & AH_SINManager_
				: AH_SINManager_Batch
				:
******************************************************************************************/
public class AH_SINManager_FUNCTIONS 
{
    
    // LIST COLLECTIONS OF WRAPPER CLASS OBJECTS
    public List<bcWrapper> wrapList {get; set;}
    public List<bcliWrapper> wrapperList {get; set;}    
    public List<SINWrapper> SINWrapperList {get; set;}
    // BCLI WRAPPER OBJ LIST FOR GLOBAL ACCESS
    Public List<bcliWrapper> wrapperList2;
    
    public static Boolean disablePostBtn {get; set;}
    public Map<String, String> successIds {get; set;}
    public Set<Id> bcIds {get; set;}
    public List<String> erroredBCs {get; set;}
    public Set<String> listOfErroredNames {get; set;}
    public String uniqueString {get; set;}
    public Integer totalRecordsCount {get; set;}
    
    public AH_SINManager_FUNCTIONS()                     
    {
        successIds = new Map<String, String>();
        bcIds = new Set<Id>();
        erroredBCs = new List<String>();
        listOfErroredNames = new Set<String>();
        uniqueString = '';
        totalRecordsCount = 0;  
        wrapperList2 = new List<bcliWrapper>();
    }
    
    public List<SINWrapper> createInvoices()
    {
        system.debug('**** INSIDE  CREATE INVOICE METHOD - AFTER SINMANAGER BATCH GETS CALLED  ******');  
        system.debug('SINWrapperList IN SIDE CREATE INVOICE METHOD SIN FUNCTION CLASS   :' + SINWrapperList);
        Integer recToProcess = 0;
        system.debug('wrapList  :' + wrapList);
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
            
            // VALIDATION OF BCLIs
            listOfErroredNames = new Set<String>(); 
            bcIds = new Set<Id>();
            validateBLIs();
            
            // SHOW ERROR MESSAGES 
            if (!listOfErroredNames.isEmpty())
            {
                for (String error : listOfErroredNames)
                {
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
                system.debug('sinList  :' + sinList);
                if (!sinList.isEmpty())
                {
                    try 
                    {
                        // INSERT SALES INVOICES
                        Database.SaveResult[] result = Database.Insert(sinList, false);
                        
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
                                ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.Info, 'Records remaining to be processed : ' + totalRecordsCount);
                                ApexPages.addMessage(myMsg2);
                            }
                            
                            List<c2g__codaInvoiceLineItem__c> lineItemsList = new List<c2g__codaInvoiceLineItem__c>();
                            
                            for (c2g__codaInvoiceLineItem__c lineItem: sinToLineItem.keyset())
                            {
                                c2g__codaInvoice__c SIN = new c2g__codaInvoice__c();
                                
                                SIN = sinToLineItem.get(lineItem);
                                if (SIN.Id != null) 
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
                            disablePostBtn = createSINWrapper();
                            system.debug('in createInvoice method disablePostBtn : '+disablePostBtn);
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
                            {
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Errors - ' + errList + ' Error in following Billing Contracts : '+erroredBCs)); 
                            }
                            NI_Error_Logger.WriteToLog ('Error Type: Fields are missing.' + ', \nCause: ' + errList + ' \n' + ' Error in following Billing Contracts : ' + erroredBCs, 'NI_Admin_Error_Log__c', 'AH_SINManage_FUNCTIONS.createInvoices', 'INSERT');
                        }
                        
                    }
                    catch (Exception e)
                    {
                        system.debug(' **** Error Occured: ' + e.getMessage() + '\n Line: ' + e.getLineNumber() + '\n Cause:' + e.getCause());
                        if (ApexPages.currentPage() != null) 
                        {
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + '\n Line: ' + e.getLineNumber() + '\n Cause:' + e.getCause())); 
                        }
                        NI_Error_Logger.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n', 'NI_Admin_Error_Log__c', 'AH_SINManage_FUNCTIONS.createInvoices', 'INSERT');
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
        
        system.debug('RETURN SINWrapperList IN CREATE INVOICE METHOD :' + SINWrapperList );
        return SINWrapperList;
        
    }
    
    public Boolean postInvoices(Boolean disableBtnFlag)
    {
        
        NI_TriggerBypassSwitches__c bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();  
        
        if (bpSwitch.BypassSINPosting_ON__c == true) { return false; }

        system.debug('********** INSIDE POST METHOD AFTER HITTING FROM VF PAGE **********');
        
        disablePostBtn = disableBtnFlag;
        system.debug('in postInvoice method disablePostBtn : '+ disablePostBtn);
        system.debug('******BEFORE TRY erroredBCs ****** ' + erroredBCs);
        List<String> finalIDList = new List<String>();
        
        system.debug('SINWrapperList  IN POST INVOICE METHOD  :' + SINWrapperList );
        system.debug('disablePostBtn  :' +  disablePostBtn);
        
        for (SINWrapper sinWrapObj : SINWrapperList)
        {
            if (sinWrapObj.check == true)    
            {
                finalIDList.add(sinWrapObj.SINObj.id);
            } 
        }  
        
        system.debug('finalIDList  :' + finalIDList);
        
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
                
                system.debug('**** POST INVOICE BATCH HAS BEEN EXECUTED *****');
                system.debug('After Post Invoice BATCH- CPU Time : '+ Limits.getCpuTime());
                
                if (ApexPages.currentPage() != null) 
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, 'Records are being posted. Use Refresh List button to check the status.')); 
                }
                
            }
            catch (Exception e)
            {
                system.debug('Error occured while posting an invoice ... at line number : '+ e.getLineNumber() +' => ' + e);
                NI_Error_Logger.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n','c2g__codaInvoice__c',  'AH_BatchPostInvoices', 'UPDATE');
            }

        }
        else 
        {
            if (ApexPages.currentPage() != null) 
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info, 'Records not selected or posting.')); 
            }
        }
        
        system.debug('RETURN disablePostBtn  :' + disablePostBtn);
        return disablePostBtn;
        
    }
    
    public Map<String, List<String>> refreshInvoices() 
    {
        
        system.debug('******* INSIDE REFRESH INVOICE METHOD *****');
        // MAP TO COMBINE BOOLEAN AND LIST VALUES IN REFRESH INVOICE BTN METHOD 
        Map<String, List<String>> combineSINidMap = new Map<String, List<String>>();
        // LIST TO HOLD SIN ID VALUE
        List<String> sinIDList = new List<String>();
        // LIST TO HOLD POSTBUTTON VALUE
        List<String> disPostBtList = new List<String>();
        
        disablePostBtn = createSINWrapper();   
        disPostBtList.add(String.valueOf( disablePostBtn ));
        
        for (SINWrapper sinWrapObj : SINWrapperList)
        {    
            sinIDList.add(sinWrapObj.SINObj.id);
        }       
        
        combineSINidMap.put('sinLst',sinIDList);
        combineSINidMap.put('disablePostBtn',disPostBtList);
        
        system.debug('combineSINidMap IN FUNCTION ***  :' + combineSINidMap );
        return combineSINidMap;
        
    }
    
    public Void updateInvoiceDate(List<bcliWrapper> wrapperList)
    {
        
        // COLLECT RECORDS TO UPDATE BCLI's INVOICE DATE AS TODAY'S DATE
        List<Billing_Contract_Line_Item__c> bcliUpdateList = new List<Billing_Contract_Line_Item__c>();
        wrapperList2.addAll(wrapperList);
        
        if (!wrapperList2.isEmpty())
        {
            for (bcliWrapper wrap1 : wrapperList2)
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
        
    }
    
    private Boolean createSINWrapper()   
    {  
        
        SINWrapperList = new List<SINWrapper>();
        Integer successCnt = 0;
        
        if (successIds != null && !successIds.isEmpty())
        {
            system.debug('INSIDE IF LOOP   :');
            // CREATE SIN WRAPPER
            List<c2g__codaInvoice__c> insertedList = new List<c2g__codaInvoice__c>([
                SELECT Id, Name, Billing_Contract__c, c2g__Account__c,
                Billing_Contract__r.Name, 
                c2g__Account__r.Name, 
                c2g__InvoiceTotal__c,
                c2g__InvoiceStatus__c 
                FROM c2g__codaInvoice__c 
                WHERE Id IN : successIds.values()]);
            
            system.debug('insertedList  :' + insertedList );
            
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
        
        system.debug('SINWrapperList  INSIDE createSINWrapper Method :' + SINWrapperList);
        system.debug('uniqueString  :' +  uniqueString);
        
        if (uniqueString != null)
        {
            
            List<Job_Run_History__c> histRecList = new List<Job_Run_History__c>([SELECT ID, Unique_Timestamp__c 
                                                                                 FROM Job_Run_History__c 
                                                                                 WHERE Unique_Timestamp__c =: uniqueString]);
            
            system.debug(' **** histRecList = ' + histRecList);
            
            if (histRecList != null && !histRecList.isEmpty())
            {
                disablePostBtn = false;
            }
            else 
            {
                disablePostBtn = true;
            }
                     
        }
        
        system.debug(' INSIN disablePostBtn  : ' + disablePostBtn);      
        return disablePostBtn;
        
    }    
    
    private void validateBLIs()  
    {
        
        for (bcWrapper wr : wrapList)
        {
            if (wr.processed == true)
            {
                for (bcliWrapper wrap : wr.bcliWrapperList)
                {
                    if (wrap.check == true)
                    {
                        
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
                            NI_Error_Logger.WriteToLog(wrap.bcliObj.Name +' : '+errorMsg + ' \n', 'NI_Admin_Error_Log__c', 'AH_SINManage_FUNCTIONS.validateBLIs', 'INSERT');
                        }
                        
                        // VALIDATION #2
                        if (wrap.bcliObj.Billing_Contract__r.Remittance_Info__c == null)
                        {
                            system.debug(' **** VALIDATION FAILED: wrap.bcliObj.Billing_Contract__r.Remittance_Info__c IS NULL ');
                            errorMsg = 'Remittance Info should be present on Billing Contract : ' + wrap.bcliObj.Billing_Contract__r.Name;
                            listOfErroredNames.add(wrap.bcliObj.Name + ' : ' + errorMsg);
                            errorFlag = true;
                            wrap.isErrored = true;
                            NI_Error_Logger.WriteToLog(wrap.bcliObj.Name +' : '+errorMsg + ' \n', 'NI_Admin_Error_Log__c', 'AH_SINManage_FUNCTIONS.validateBLIs', 'INSERT');
                        }
                        
                        // VALIDATION #3
                        if (wrap.bcliObj.Product__r.Dimension_2__c == null)
                        {
                            system.debug(' **** VALIDATION FAILED: wrap.bcliObj.Product__r.Dimension_2__c IS NULL ');
                            errorMsg = 'Attention: Dimension 2 is required on all Sales Invoices.';
                            listOfErroredNames.add(wrap.bcliObj.Name + ' : ' + errorMsg);
                            errorFlag = true;
                            wrap.isErrored = true;
                            NI_Error_Logger.WriteToLog(wrap.bcliObj.Name + ' : ' + errorMsg + ' \n', 'NI_Admin_Error_Log__c', 'AH_SINManage_FUNCTIONS.validateBLIs', 'INSERT');
                        }
                        
                        // VALIDATION #4
                        if (wrap.bcliObj.Product__r.Dimension_3__c == null)
                        {
                            system.debug(' **** VALIDATION FAILED: wrap.bcliObj.Product__r.Dimension_3__c IS NULL ');
                            errorMsg = 'Attention: Dimension 3 is required on all Sales Invoices.';
                            listOfErroredNames.add(wrap.bcliObj.Name + ' : ' + errorMsg);
                            errorFlag = true;
                            wrap.isErrored = true;
                            NI_Error_Logger.WriteToLog(wrap.bcliObj.Name + ' : ' + errorMsg + ' \n', 'NI_Admin_Error_Log__c', 'AH_SINManage_FUNCTIONS.validateBLIs', 'INSERT');
                        }
                        
                        // VALIDATION #5
                        if (!wrap.bcliObj.Product__r.IsActive)
                        {
                            system.debug(' **** VALIDATION FAILED: wrap.bcliObj.Product__r.IsActive = false');
                            errorMsg = 'Attention: Product Is Inactive';
                            listOfErroredNames.add(wrap.bcliObj.Name + ' : ' + errorMsg);
                            errorFlag = true;
                            wrap.isErrored = true;
                            NI_Error_Logger.WriteToLog(wrap.bcliObj.Name + ' : ' + errorMsg + ' \n', 'NI_Admin_Error_Log__c', 'AH_SINManage_FUNCTIONS.validateBLIs', 'INSERT');
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
    
}