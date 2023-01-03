/****************************************************************************************
Name            : createBillingContractController
Author          : CLD Partners
Created Date    : 11/11/2015 
Last Mod Date   : 11/22/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Controller for creating billing contracts and line items from an Opportunity.
				: Updated per NICC-039872
				: 
******************************************************************************************/
public class createBillingContractController 
{  
    
    // RECORDS
    public Opportunity opp {get; set;} 
    public Billing_Contract__c bc {get; set;} 
    public Apttus__APTS_Agreement__c agr {get; set;} 
    // COLLECTIONS 
    public List<oliWrapper> lstOpenOLIs {get; set;} 
    public List<OpportunityLineItem> lstClosedOLIs {get; set;} 
    public List<Billing_Contract_Line_Item__c> lstBCLIs {get; set;} 
    public Map<String, Payment_Terms__c> mapPaymentTerms {get; set;} 	// THE KEY FOR THIS MAP IS THE APTTUS REVENUE CATEGORY
    // IDS
    public Id billingContractId {get; set;} 							// SET BY DEFAULT INITALLY BUT CAN BE CHANGED BY THE USER
    public Id defaultRenewalPricebook;
    // BOOLEANS
    public Boolean bcExists {get; set;} 
    public Boolean loadError {get; set;} 
    // STRINGS
    public String loadingMessage {get; set;} 
    private String strOppId; 
    
    public String strConsole {get; set;}  
    public Boolean showConsole {get; set;}  
    
    
    public createBillingContractController() 
    {
       
        system.debug(' *** ENTERING createBillingContractController() CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());	
        
        loadingMessage = 'Processing...';
        
        if (ApexPages.CurrentPage().getParameters().containsKey('id')) 
        {        
            
            strConsole = 'DEBUG CONSOLE: \n\n'; 
            showConsole = false;
            
            if (ApexPages.CurrentPage().getParameters().containsKey('debug')) 
            { 
                if (Apexpages.currentpage().getParameters().get('debug') == '1')
                {
                    showConsole = true;
                }
            }
            
            loadError = false;
            
            strOppId = Apexpages.currentpage().getParameters().get('id');
            
            initVariables();
            
            loadOpportunityLineItems(opp); 
            
        }
        else
        {
            // RAISE LOAD ERROR
            loadError = true;
            string message = 'Page is missing Opportunity Id in URL. Please launch via the "Create Billing Contract" button on an Opportunity page.';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, message);
            ApexPages.addMessage(myMsg);              
        }        
        
        system.debug(' *** EXITING createBillingContractController() CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    
    // ============================================================================================================================
    //  VF PAGE LOADING METHODS
    // ============================================================================================================================    
    private void initVariables()
    {
        
        // LOAD OPPORTUNITY RECORD VARIABLE
        opp = [SELECT Id, AccountId, Account.Name, Account.Remittance_Info__c, currencyIsoCode, Account.ParentId, Annual_Salesforce_Renewal_Date__c, 
               Account.Parent.Name, Pricebook2Id, Company__c, StageName, License_Program_Payment_Terms__c, Support_Payment_Terms__c, Order_Status__c, 
               Services_Payment_Terms__c, Subscription_Payment_Terms__c, Hosting_and_Support_Payment_Terms__c, Opportunity_Number__c, 
               HRM_Subscription_Invoice_Terms__c, HRM_Service_Invoice_Terms__c, Billing_Cycle_Date_Pro_Rata__c, CloseDate, Effective_Date__c, Billing_Contract__c, 
               (SELECT Id, Product2Id, Product2.Apttus_Revenue_Category__c, Product2.Override_Invoice_Terms__c, Product2.Duration_Months__c, 
                Product2.Product_Group__r.Name, Product2.Product_Line__c, Product2.Product_Group__c, Order_of_Delivery__c, Delivery_Offset_Months__c, 
                Quantity, Renewal_Pricebook__c, OpportunityId, Name, Pro_Rata_Billing__c, Product2.Product_Package__c, Product2.ProductCode, 
                Product2.Auto_Renew__c, Product2.Name, Description, Opportunity.CloseDate, Opportunity.AccountId, BC_Line_Created__c, Activity_Line_Created__c, 
                Number_of_Instances__c, UnitPrice, ListPrice, TotalPrice, Auto_Renew__c, Pro_Rated_Date__c, Invoice_Terms__c 
                FROM OpportunityLineItems 
                ORDER BY Product2.Apttus_Revenue_Category__c, ProductCode), 
               (SELECT Id, CreatedDate, License_Program_Payment_Terms__c, Hosting_and_Support_Payment_Terms__c, Support_Payment_Terms__c, APTS_Legal_Entity__c,  
                Services_Payment_Terms__c, Subscription_Payment_Terms__c, APTS_Customer_Account_Billing_Country__c, Customer_Account_Physical_Country__c 
                FROM Apttus__R00N50000001Xl0FEAS__r 
                ORDER BY CreatedDate DESC LIMIT 1) 
               FROM Opportunity 
               WHERE Id =: strOppId]; 
        
        // LOAD PAYMENT "INVOICE" TERMS MAP VARIABLE
        mapPaymentTerms = queryOppPaymentTerms(opp); 
        
        // RUN VALIDATION AND THROW AND ERROR TO USER IF INVALID
        String errMessage = validateOpp(opp); 
        
        if (loadError == true) 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, errMessage));
        }
        
        // SET BILLING RENEWAL PRICEBOOK ID VARIABLE
        for (Renewal_Pricebook__c rpb : [SELECT Id, Name FROM Renewal_Pricebook__c WHERE Is_Default__c = true LIMIT 1])
        {
            defaultRenewalPricebook = rpb.Id;
        }
        
        bcExists = false;
        
        if (opp.Billing_Contract__c != null)
        {
            
            bcExists = true;
            
            // LOAD BILLING CONTRACT RECORD VARIABLE
            bc = [SELECT Id, Activation_Date__c, Effective_Date__c, CurrencyIsoCode, Attn_to_Contact__c, Bill_to_Contact__c, Ship_to_Contact__c
                  FROM Billing_Contract__c
                  WHERE Id =: opp.Billing_Contract__c];
            
            // SET BILLING CONTRACT ID VARIABLE
            billingContractId = opp.Billing_Contract__c;
            
        }
        
        // LOAD APTTUS AGREEMENT RECORD VARIABLE (WE ONLY EXPECT 1 AGREEMENT IN THIS LIST)
        for (Apttus__APTS_Agreement__c agreement : opp.Apttus__R00N50000001Xl0FEAS__r)
        {		
            agr = agreement; 	
        }
        
    }
    
    public List<selectOption> getBC_Options() 
    {
        
        List<SelectOption> bcOptions = new List<SelectOption>();
        
        bcOptions.add(new selectOption('', '- None -'));
        
        for (Billing_Contract__c b : [SELECT Id, Name
                                      FROM Billing_Contract__c
                                      WHERE Account__r.Id =: opp.AccountId
                                      ORDER BY Name ASC]) 
        {
            bcOptions.add(new SelectOption(b.Id, b.Name));
        }
        
        if (opp.Billing_Contract__c != null)
        {
            billingContractId = opp.Billing_Contract__c;
        }
        
        return bcOptions;
        
    }
    
    private String validateOpp(Opportunity oppRecord)
    {
        
        String returnMessage = 'valid'; 
        
        // GET ALL VALUES FROM "Billing SKU Validations" CUSTOM SETTING
        Map<String, Billing_SKU_Validations__c> mapInvalidSKUs = Billing_SKU_Validations__c.getAll();
        Set<String> setRevCatNames = new Set<String>();
        
        for (OpportunityLineItem oli : oppRecord.OpportunityLineItems)
        {
            
            if (oli.Product2.Apttus_Revenue_Category__c == 'Services')
            {
                setRevCatNames.add('Services');
            }
            
            if (oli.Product2.Apttus_Revenue_Category__c == 'Software')
            {
                setRevCatNames.add('Software');
            }
            
            if (oli.Product2.Apttus_Revenue_Category__c == 'Subscription' && oli.Product2.Product_Line__c == 'HRM')
            {
                setRevCatNames.add('HRM Subscription');
            }
            
            if (oli.Product2.Apttus_Revenue_Category__c == 'Subscription')
            {
                setRevCatNames.add('Subscription');
            }
            
            if (oli.Product2.Apttus_Revenue_Category__c == 'Support')
            {
                setRevCatNames.add('Support');
            }
            
            if (oli.Product2.Apttus_Revenue_Category__c == 'Hosting and Support')
            {
                setRevCatNames.add('Hosting and Support');
            }
            
            // VALIDATE THAT NONE OF THE SKU'S ARE VALIDATED AGAINST
            if (mapInvalidSKUs.keyset().contains(oli.Product2.ProductCode))
            {
                returnMessage = 'Attention: This Opportunity contains an invalid sku that cannot be processed onto a Billing Contract (' + oli.Product2.ProductCode + ') - Please remove this item before continuing';
                loadError = true;
                return returnMessage;
            }
            
        }
        
        if ((oppRecord.License_Program_Payment_Terms__c == null && setRevCatNames.contains('Software')) ||
            (oppRecord.Support_Payment_Terms__c == null && setRevCatNames.contains('Support')) ||
            (oppRecord.Services_Payment_Terms__c == null && setRevCatNames.contains('Services')) ||
            (oppRecord.Subscription_Payment_Terms__c == null && setRevCatNames.contains('Subscription')) ||
            (oppRecord.Hosting_and_Support_Payment_Terms__c == null && setRevCatNames.contains('Hosting and Support')))
        {
            returnMessage = 'Attention: The Opportunity is missing payment terms, please select payment terms for each applicable product category before continuing.';
            loadError = true;
        }
        
        if (oppRecord.StageName != 'Closed Won')
        {
            returnMessage = 'Attention: The Opportunity is not Closed Won, only finalized orders can have Billing Contracts created.';
            loadError = true;
        }
        
        return returnMessage;
        
    }
    
    private void loadOpportunityLineItems(Opportunity oppRecord)
    {
        
        lstOpenOLIs = new List<oliWrapper>();
        lstClosedOLIs = new List<OpportunityLineItem>();
        
        if (bc != null)
        {
            lstBCLIs = new List<Billing_Contract_Line_Item__c>([SELECT Id, Name, Invoiced__c, Invoice_Date__c, Product__r.Name, Product__r.ProductCode, 
                                                                Total_Amount__c, Revenue_Category__c, Ready_to_Invoice__c, Type__c, Unit_Price__c
                                                                FROM Billing_Contract_Line_Item__c
                                                                WHERE Billing_Contract__c = : bc.Id]);
        }
        
        for (OpportunityLineItem oli : oppRecord.OpportunityLineItems)
        {
            
            // IF BILLING CONTACT WAS CREATED AND LINKED ALREADY ADD TO "CLOSED" OPPORTUNITY LINE ITEM LIST
            if (oli.BC_Line_Created__c == true)
            {
                lstClosedOLIs.add(oli);
            }
            else
            {
                // OTHERWISE ADD TO "OPEN" OPPORTUNITY LINE ITEM LIST
                String invoiceTermsKey = oli.Product2.Apttus_Revenue_Category__c;
                oliWrapper oliModel = new oliWrapper();
                
                oliModel.oli_object = oli;         
                if (mapPaymentTerms.containsKey(invoiceTermsKey))
                {
                    oliModel.oli_object.Invoice_Terms__c = mapPaymentTerms.get(invoiceTermsKey).Id;
                }
                
                if (oli.Product2.Override_Invoice_Terms__c != null)
                {
                    oliModel.oli_object.Invoice_Terms__c = oli.Product2.Override_Invoice_Terms__c;
                }
                
                oliModel.check = true;
                
                if (defaultRenewalPricebook != null && 
                    oli.Product2.Apttus_Revenue_Category__c != 'Services' && 
                    oli.Product2.Apttus_Revenue_Category__c != 'Software')
                {
                    oliModel.oli_object.Renewal_Pricebook__c = defaultRenewalPricebook;
                }
                
                oliModel.activationRequired = false;
                if (mapPaymentTerms.containsKey(oli.Product2.Apttus_Revenue_Category__c))
                {
                    oliModel.activationRequired = mapPaymentTerms.get(oli.Product2.Apttus_Revenue_Category__c).Activation_Required__c;
                }      
                
                oliModel.disableProRata = false;
                if (oli.Product2.Apttus_Revenue_Category__c == 'Services' || oliModel.activationRequired == true)
                {
                    oliModel.disableProRata = true;
                }
                
                lstOpenOLIs.add(oliModel);
                
            }
            
        }
        
        system.debug('lstOpenOLIs : '+lstOpenOLIs);
    }    
    
    // ============================================================================================================================
    //  BUTTON METHODS
    // ============================================================================================================================
    public PageReference createBillingContract()
    {        
        
        system.debug(' *** ENTERING createBillingContractController.createBillingContract() - QUERIES ISSUED = ' + Limits.getQueries());
        
        PageReference pr = null;
        
        try
        {
            bc = createBillingContractHeader(opp, agr);
            pr = new PageReference('/apex/createBillingContract?Id=' + opp.Id);
            pr.setRedirect(true);  
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + 'STACK' + e.getStackTraceString()  + '\n Line: ' + e.getLineNumber() + '\n Cause:' + e.getCause())); 
        }
        
        system.debug(' *** EXITING createBillingContractController.createBillingContract() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return pr; 
        
    }
    
    public void processLines()
    {
        
        // METHOD TO CREATE BILLING AND ACTIVITY LINES FROM THE OPPORTUNITY
        
        system.debug(' *** ENTERING createBillingContractController.processLines() - QUERIES ISSUED = ' + Limits.getQueries());
        
        system.debug(' *** createBillingContractController - Validating Data ...');
        
        // IF THERE IS NO BILLING CONTRACT RECORD LOADED THROW ERROR TO USER
        if (billingContractId == null)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'No Billing Contract Selected!'));   
            return;
        }
        
        // MAKE SURE ALL CHECKED OPPORTUNITY LINE ITEMS HAVE PAYMENT "INVOICE" TERMS ASSIGNED TO THEM. IF NOT THROW ERROR TO USER
        for (oliWrapper oppItem : lstOpenOLIs)
        {           
            if (oppItem.check == true)
            {
                if (oppItem.oli_object.Invoice_Terms__c == null)
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You must select invoice terms to continue!'));   
                    return; 
                }
            }
        }        
        
        system.debug(' *** createBillingContractController - Gathering Data ...');
        
        bc = [SELECT Id, Activation_Date__c, Effective_Date__c, CurrencyIsoCode, Attn_to_Contact__c, Bill_to_Contact__c, Ship_to_Contact__c
              FROM Billing_Contract__c
              WHERE Id =: billingContractId];
        
        List<OpportunityLineItem> oliProcessList = new List<OpportunityLineItem>();
        Set<oliWrapper> setUpdatedoliWrappers = new Set<oliWrapper>();
        setUpdatedoliWrappers.addAll(lstOpenOLIs);
        
        for (oliWrapper oppItem : lstOpenOLIs)
        {
            if (oppItem.check == true)
            {
                oliProcessList.add(oppItem.oli_object); 	// add to the list to pass to the handler
                setUpdatedoliWrappers.remove(oppItem); 		// remove from the open list
                lstClosedOLIs.add(oppItem.oli_object); 		// add to the close list
            }
        }
        
        lstOpenOLIs = new List<oliWrapper>();
        lstOpenOLIs.addAll(setUpdatedoliWrappers);
        
        lineItemWrapper lineWrapper = new lineItemWrapper();
        
        if (oliProcessList.size() > 0)
        {
            Savepoint sp1 = Database.setSavepoint();
            try
            {
                system.debug('oliProcessList : '+oliProcessList);
                // CALL THE METHOD TO CREATE THE LINE ITEMS
                lineWrapper = createLineItems(oliProcessList, opp, bc); 
                
                lstBCLIs = [SELECT Id, Name, Invoiced__c, Invoice_Date__c, Product__r.Name, Product__r.ProductCode, Total_Amount__c, Revenue_Category__c, 
                            Ready_to_Invoice__c, Type__c, Unit_Price__c 
                            FROM Billing_Contract_Line_Item__c
                            WHERE Billing_Contract__c =: bc.Id];
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Save Successful!'));  
                
            }
            catch (Exception e)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + 'STACK' + e.getStackTraceString() + '\n Line: ' + e.getLineNumber() + '\n Cause:' + e.getCause())); 
                Database.rollback(sp1);
            }            
        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'No Line Items Selected!'));   
        }
        
        system.debug(' *** EXITING createBillingContractController.processLines() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public PageReference backToOpp()
    {
        PageReference ref = new PageReference('/'+ opp.Id); 
        return ref; 
    }
    
    public PageReference goToBC()
    {
        PageReference ref = new PageReference('/' + billingContractId); 
        return ref; 
    }
    
    
    // ============================================================================================================================
    //  BILLING CONTRACT FUNCTIONS
    // ============================================================================================================================
    private Billing_Contract__c createBillingContractHeader(Opportunity oppRecord, Apttus__APTS_Agreement__c agrRecord) 
    {        
        
        system.debug(' *** createBillingContractHeader - Gathering Dependency Data ...');
                
        Id contractGroupAccountID;
        String contractGroupAccountName;
        if (oppRecord.Account.ParentId != null)
        {
            contractGroupAccountID = oppRecord.Account.ParentId;
            contractGroupAccountName = oppRecord.Account.Parent.Name;
        }
        else 
        {
            if (oppRecord.accountid != null)
            {
                contractGroupAccountID = oppRecord.AccountId;
                contractGroupAccountName = oppRecord.Account.Name;
            }
        }
        
        Parent_Contract_Group__c parentContractGroup;
        for (Parent_Contract_Group__c pcg : [SELECT Id FROM Parent_Contract_Group__c WHERE Account__c =: contractGroupAccountID])
        {
            parentContractGroup = pcg;
        }
        
        if (parentContractGroup == null)
        {
            Parent_Contract_Group__c pcg = new Parent_Contract_Group__c();
            pcg.Name = contractGroupAccountName;
            pcg.Account__c = contractGroupAccountID;
            insert pcg;
            parentContractGroup = pcg;
        }        
        
        Map<String, Id> ffaCurrencymap = new Map<String, Id>();
        for (c2g__codaAccountingCurrency__c acctCurr : [SELECT Id, Name, c2g__ownerCompany__c FROM c2g__codaAccountingCurrency__c])
        {
            ffaCurrencymap.put(acctCurr.c2g__ownerCompany__c + '|' + acctCurr.Name, acctCurr.Id);
        }
        
        Map<String, c2g__codaCompany__c> ffaCompanymap = new Map<String, c2g__codaCompany__c>();
        for (c2g__codaCompany__c company : [SELECT Id, Legal_Entity_Name__c, Remittance_Info__c, Physical_Countries__c FROM c2g__codaCompany__c])
        {
            ffaCompanymap.put(company.Legal_Entity_Name__c, company);
        }        
        
        Map<Id, Id> accountCollectorMap = new Map<Id, Id>(); 
        for (AccountTeamMember atm : [SELECT AccountId, UserId, TeamMemberRole FROM AccountTeamMember WHERE AccountId =: oppRecord.AccountId AND TeamMemberRole = 'NI Collector'])
        {
            accountCollectorMap.put(atm.AccountId, atm.UserId);
        }  
        
        Map<String, Id> contactRoleMap = new Map<String, Id>();
        for (OpportunityContactRole oc : [SELECT Id, OpportunityId, ContactId, Role FROM OpportunityContactRole WHERE OpportunityId =: oppRecord.Id])
        {
            contactRoleMap.put(oc.Role, oc.ContactId);
        }
        
        //Apttus__APTS_Agreement__c aptusAgreement;
        //for (Apttus__APTS_Agreement__c agreement : oppRecord.Apttus__R00N50000001Xl0FEAS__r)
       	//{		
        //    aptusAgreement = agreement; 
        //}

        system.debug(' *** createBillingContractHeader - Finished Gathering Dependency Data - QUERIES ISSUED = ' + Limits.getQueries());
        
        
        Billing_Contract__c billContract = new Billing_Contract__c();
        
        // IF THE OPPORTUNITY DOES NOT HAVE A BILLING CONTRACT THEN CREATE ONE AND LINK IT
        if (oppRecord.Billing_Contract__c == null)
        {
            
            system.debug(' *** createBillingContractHeader - Creating Billing Contract Record ...');
            
            billContract.Opportunity__c = oppRecord.Id;
            billContract.Account__c = oppRecord.AccountId;
            billContract.CurrencyIsoCode = oppRecord.CurrencyIsoCode;
            billContract.Pricebook__c = oppRecord.Pricebook2Id;
            billContract.Name = 'BC - ' + oppRecord.Opportunity_Number__c;
            billContract.Parent_Contract_Group__c = parentContractGroup.Id;
            billContract.Company__c = oppRecord.Company__c;
            
            billContract.Effective_Date__c = oppRecord.CloseDate;
            if (oppRecord.Effective_Date__c != null)
            {
                billContract.Effective_Date__c = oppRecord.Effective_Date__c;
            }
            
            if (accountCollectorMap.containsKey(oppRecord.AccountId))
            {
                billContract.Collector__c = accountCollectorMap.get(oppRecord.AccountId);
            }
            
            if (ffaCurrencymap.containsKey(billContract.Company__c + '|' + billContract.CurrencyIsoCode))
            {
                billContract.Accounting_Currency__c = ffaCurrencymap.get(billContract.Company__c + '|' + billContract.CurrencyIsoCode);
            }
            
            if (contactRoleMap.containsKey('Bill To'))
            {
                billContract.Bill_to_Contact__c = contactRoleMap.get('Bill To');
            }
            
            if (contactRoleMap.containsKey('Ship To'))
            {
                billContract.Ship_to_Contact__c = contactRoleMap.get('Ship To');
            }
            
            if (contactRoleMap.containsKey('Customer Project Contact'))
            {
                billContract.Attn_to_Contact__c = contactRoleMap.get('Customer Project Contact');
            }
            
            // IF AGREEMENT RECORD EXISTS 
            if (agrRecord != null) 
            {          
                
                billContract.Agreement__c = agrRecord.Id;
                
                // LOOP THOUGH ALL COMPANIES WHERE Physical_Countries__c IS FILLED IN 
                for (c2g__codaCompany__c company : [SELECT Id, Legal_Entity_Name__c, Remittance_Info__c, Physical_Countries__c FROM c2g__codaCompany__c]) 
                { 
                    // IF AGREEMENT LEGAL NAME MATCHES LEGAL NAME ON COMPANY 
                    if (company.Legal_Entity_Name__c == agrRecord.APTS_Legal_Entity__c && company.Physical_Countries__c == null) 
                    { 
                        billContract.Remittance_Info__c = company.Remittance_Info__c; 
                    }                     
                    // IF COUNTRY ON AGREEMENT IS CONTAINED IN Billing_Countries__c ON COMPANY 
                    if (company.Legal_Entity_Name__c == agrRecord.APTS_Legal_Entity__c && 
                        company.Physical_Countries__c != null && 
                        company.Physical_Countries__c.contains(agrRecord.Customer_Account_Physical_Country__c)) 
                    { 
                        billContract.Remittance_Info__c = company.Remittance_Info__c; 
                        break; 
                    } 
                }                 
            }
            
            insert billContract;
        	
            system.debug(' *** createBillingContractHeader - Finished Creating Billing Contract - QUERIES ISSUED = ' + Limits.getQueries());
            
        } 
        else
        {
            billContract = [SELECT Id, Effective_Date__c FROM Billing_Contract__c WHERE Id = : oppRecord.Billing_Contract__c];
        }
        
        system.debug(' *** createBillingContractHeader - Updating Billing_Contract__c & Order_Status__c on Opportunity Record ...');
        
        oppRecord.Billing_Contract__c = billContract.Id;
        oppRecord.Order_Status__c = 'Integrated';
        update oppRecord;
        
        system.debug(' *** createBillingContractHeader - Finished Updating Opportunity - QUERIES ISSUED = ' + Limits.getQueries());
            
        return billContract;
        
    }    

    private lineItemWrapper createLineItems(List<OpportunityLineItem> oliList, Opportunity oppRecord, Billing_Contract__c bcRecord)
    {
        
        // THIS FUNCTION FIRST INSTANTIATES BILLING CONTRACT LINE ITEMS AND ACTIVITY LINE AND ADDS THEM TO TEMPORARY LIST COLLECTIONS
        // THE TEMPORARY LISTS ARE THEN PASSED INTO FUNCTIONS THAT DOES SPLITING BASED ON PAYMENT "INVOICE" TERMS WHICH CREATES COPIES
        
        system.debug(' *** createLineItems - Gathering Dependency Data ...'+oliList);
        
        Map<String, Id> oppProductActivityLineMap;
        lineItemWrapper returnWrapper = new lineItemWrapper();
        Map<Id, Integer> deliveryOffsetMap = calculateDeliveryOffset(oppRecord.Id);
        Map<Id, Activity_Line_Item__c> oliALIMap = new Map<Id, Activity_Line_Item__c>();
        List<Billing_Contract_Line_Item__c> tmpBillingList = new List<Billing_Contract_Line_Item__c>();

        Map<Id, Payment_Terms__c> invoiceTermsMap = new Map<Id, Payment_Terms__c>([
            SELECT Id, Offset_Date__c, Activation_Required__c, Invoice_Split_Method__c, Billed_through_PSA__c, Bill_if_Activation_Date_comes_first__c, 
            (SELECT Id, Order__c, Offset_Measure__c, Offset_Units__c, Percent_of_Total__c, Invoice_Line_Description__c FROM Payment_Term_Line_Items__r ORDER BY Order__c)
            FROM Payment_Terms__c]);        
        
        // FETCH THE DEPLOYMENT INSTANCES
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        accountIdSet.add(oppRecord.AccountId);
        for (OpportunityLineItem oli : oliList)
        {
            productIdSet.add(oli.Product2Id);
        }
        
        system.debug('oliList : '+oliList);
        
        system.debug(' *** createLineItems - Creating Activity Line Items ...');
        
        // INIT THE BILLING AND ACTIVITY LINES
        List<Activity_Line_Item__c> tmpActivityList = new List<Activity_Line_Item__c>();
        
        tmpActivityList = initActivityLine(oliList, oppRecord, bcRecord, invoiceTermsMap, deliveryOffsetMap);
        
        system.debug(' *** createLineItems - Initialized ' + tmpActivityList.size() + ' Activity Line Items');
        
        system.debug(' *** createLineItems - Spliting Initialized Activity Line Items from Packages ...');
        
        returnWrapper.activityLineList = packageSplit_Activity(tmpActivityList, oliList);
        system.debug('returnWrapper.activityLineList   : '+ returnWrapper.activityLineList);
        
        for (Activity_Line_Item__c ali : returnWrapper.activityLineList)
        {
            oliALIMap.put(ali.Opp_Product_ID__c, ali);
        }

        tmpBillingList = initBillingLine(oliList, oppRecord, bcRecord, invoiceTermsMap, deliveryOffsetMap, oliALIMap);
        
        // PRODUCT PACKAGE BURST OUT
        returnWrapper.billingLineList = packageSplit_Billing(tmpBillingList, oliList);
        
        // SPLIT BILLING LINES BY PAYMENT TERMS
        returnWrapper.billingLineList = paymentSplit_Billing(returnWrapper.billingLineList, bcRecord);
        
        // INSERT THE ACTIVITY LINE ITEMS
        insert returnWrapper.activityLineList;
        
        system.debug('m here..');
        // Populate the opp Product ALI map
        oppProductActivityLineMap = new Map<String, Id>();
        
        for (Activity_Line_Item__c ali : returnWrapper.activityLineList)
        {
            oppProductActivityLineMap.put(ali.Opp_Product_Id__c + '|' + ali.Product_Package_Item__c, ali.id);
        }
        
        // Loop through the Billing Lines and populated the ALI lookup
        for (Billing_Contract_Line_Item__c bli : returnWrapper.billingLineList)
        {
            if (oppProductActivityLineMap.containsKey(bli.Opp_Line_Item_ID__c + '|' + bli.Product_Package_Item__c))
            {
                bli.Activity_Line_Item__c = oppProductActivityLineMap.get(bli.Opp_Line_Item_ID__c + '|' + bli.Product_Package_Item__c);
            }
        }
        
        // Populate the line descriptions where applicable:
        // returnWrapper.billingLineList = populateBillingLineDescription(returnWrapper.billingLineList);

        Set<Id> aliIds = new Set<Id>();
        Set<String> revenueCategoriesToApply = new Set<String>{'Support', 'Hosting and Support', 'Subscription'};
        String strbillingPeriodStart;
        String strbillingPeriodEnd;
        
        for (Billing_Contract_Line_Item__c bli : returnWrapper.billingLineList)
        {
            aliIds.add(bli.Activity_Line_Item__c);
        }
        
        Map<Id, Activity_Line_Item__c> aliMap = new Map<Id, Activity_Line_Item__c>(
            [SELECT Id, Contract_Start_Date__c, Contract_End_Date__c, Revenue_Category__c
             FROM Activity_Line_Item__c
             WHERE Id IN : aliIds
             AND Contract_Start_Date__c != null
             AND Contract_End_Date__c != null]);
        
        for (Billing_Contract_Line_Item__c bli : returnWrapper.billingLineList)
        {
            if (bli.Pro_Rated__c == false && (bli.Line_Item_Description__c == '' || bli.Line_Item_Description__c == null))
            {
                if (aliMap.containsKey(bli.Activity_Line_Item__c))
                {
                    Activity_Line_Item__c ali = aliMap.get(bli.Activity_Line_Item__c);					
                    if (revenueCategoriesToApply.contains(bli.Revenue_Category__c))
                    {
                        strbillingPeriodEnd = DateTime.NewInstance(ali.Contract_End_Date__c.year(), ali.Contract_End_Date__c.month(), ali.Contract_End_Date__c.day()).format('d MMM yyyy');
                        strbillingPeriodStart = DateTime.NewInstance(ali.Contract_Start_Date__c.year(), ali.Contract_Start_Date__c.month(), ali.Contract_Start_Date__c.day()).format('d MMM yyyy');
                        bli.Line_Item_Description__c = bli.Revenue_Category__c + ' - Start: ' + strbillingPeriodStart + ' End: ' + strbillingPeriodEnd;
                    }
                }
            }
        }

        // INSERT THE BILLING LINE ITEMS:
        insert returnWrapper.billingLineList;
        
        return returnWrapper;
        
    }

    // ============================================================================================================================
    //  BILLING CONTRACT LINE ITEM FUNCTIONS
    // ============================================================================================================================    
    private List<Billing_Contract_Line_Item__c> initBillingLine(List<OpportunityLineItem> lstOpportunityLineItems, Opportunity oppRecord, Billing_Contract__c bcRecord, Map<Id, Payment_Terms__c> invoiceTermsMap, Map<Id, Integer> deliveryOffsetMap, Map<Id, Activity_Line_Item__c> mapOLI2ALIs)
    {
        
        // METHOD FOR INITIALIZING THE BILLING LINE
        
        system.debug(' *** initBillingLine - Creating Billing Contract Line Items ...');
                
        List<Billing_Contract_Line_Item__c> returnList = new List<Billing_Contract_Line_Item__c>();
        
        Payment_Terms__c pmtTerms = null;
        Payment_Term_Line_Item__c pmtLine;

strConsole += 'Instantiating Billing Contract Line Items...\n\n';
        
        for (OpportunityLineItem oli : lstOpportunityLineItems)
        {
            
strConsole += '.. OLI, Id: ' + oli.Id + ', Name: ' + oli.Product2.Name + ', Quantity: ' + oli.Quantity + ', Sales Price: ' + oli.unitPrice + ', List Price: ' + oli.ListPrice  + ' Total Price: ' + oli.TotalPrice + '\n'; 
                        
            if (invoiceTermsMap.containsKey(oli.Invoice_Terms__c))
            {
                pmtTerms = invoiceTermsMap.get(oli.Invoice_Terms__c);
            }

            Date invoiceDate = bcRecord.Effective_Date__c;
            
            if (deliveryOffsetMap.containsKey(oli.id))
            {
                invoiceDate = bcRecord.Effective_Date__c.addMonths(deliveryOffsetMap.get(oli.id));
            }
            
            if (mapOLI2ALIs.containsKey(oli.Id) && mapOLI2ALIs.get(oli.id).Contract_Start_Date__c != null)
            {
                invoiceDate = mapOLI2ALIs.get(oli.Id).Contract_Start_Date__c;
            }
            
            if (pmtTerms.Billed_through_PSA__c == true)
            {
                // DO NOT CREATE A BILLING CONTRACT LINE ITEM SINCE IT WILL BE INVOICED OUT OF PSA
                continue; 
            }
            
            if (pmtTerms.Payment_Term_Line_Items__r.size() > 0)
            {
                pmtLine = pmtTerms.Payment_Term_Line_Items__r[0];	
            }
            else
            {
                continue;
            }

            String strDescription = '';
            
            if (pmtLine.Invoice_Line_Description__c != null)
            {
                strDescription = pmtLine.Invoice_Line_Description__c;
            }
            
            // JUST CREATE A SINGLE LINE ITEM BASED ON THE OPP
            Decimal unitPrice = oli.UnitPrice;

            Billing_Contract_Line_Item__c bcli = new Billing_Contract_Line_Item__c();
            
            // QUANTITIES, PRICING & AMOUNTS
            bcli.Quantity__c = oli.Quantity;
            bcli.Unit_Price__c = unitPrice.setScale(2);
            bcli.Total_Amount__c = (unitPrice * oli.Quantity).setScale(2);

            system.debug(' *** initBillingLine - BC Details (before pro-rating): Quantity__c = ' + bcli.Quantity__c + ', Unit_Price__c = ' + bcli.Unit_Price__c + ', Total_Amount__c = ' + bcli.Total_Amount__c);
            
            bcli.Invoice_Date__c = invoiceDate;
            bcli.Product__c = oli.Product2Id;
            bcli.CurrencyIsoCode = bcRecord.CurrencyIsoCode;
            bcli.Opp_Line_Item_ID__c = oli.Id;
            bcli.Product_Package__c = oli.Product2.Product_Package__c;
            bcli.Line_Item_Description__c = strDescription;
            bcli.Billing_Contract__c = bcRecord.Id;
            bcli.Revenue_Category__c = oli.Product2.Apttus_Revenue_Category__c;
            bcli.Split_Order__c = 1;			
            bcli.Opportunity__c = oli.OpportunityId;
            bcli.Payment_Terms__c = pmtTerms.Id;
            
            if (pmtLine != null)
            {
                bcli.Payment_Term_Line_Item__c = pmtline.Id;
            }
            
            bcli.Activation_Required__c = pmtTerms.Activation_Required__c;
            if (oli.Product2.Product_Group__r.Name == 'Cendyn')
            {
                bcli.Activation_Required__c = true;
            }
            
            bcli.Status__c = 'Active';
            if (bcli.Activation_Required__c == true)
            {
                bcli.Status__c = 'Pending';
            }
                        
            // SET THE INVOICE DATE BASED ON THE UNITS OFFSET FROM THE PMT LINE
            if (pmtLine.Offset_Measure__c == 'Days' && pmtLine.Offset_Units__c != 0 && pmtLine.Offset_Units__c != null)
            {
                bcli.Invoice_Date__c = invoiceDate.addDays(pmtLine.Offset_Units__c.intValue());
            }
            
            if (pmtLine.Offset_Measure__c == 'Months' && pmtLine.Offset_Units__c != 0 && pmtLine.Offset_Units__c != null)
            {
                bcli.Invoice_Date__c = invoiceDate.addMonths(pmtLine.Offset_Units__c.intValue());
            }
            
            if (pmtLine.Offset_Measure__c == 'Years' && pmtLine.Offset_Units__c != 0 && pmtLine.Offset_Units__c != null)
            {
                bcli.Invoice_Date__c = invoiceDate.addYears(pmtLine.Offset_Units__c.intValue());
            }
                
strConsole += '.... BCLI (uncommitted), Id: ' + bcli.Id + ', Name: ' + bcli.Name + ', Quantity: ' + bcli.Quantity__c + ' Unit Price: ' + bcli.Unit_Price__c + ' Total Amount: ' + bcli.Total_Amount__c + '\n';
                        
            //calculate any pro-rated prices
            Date proRateDate;
            
            if (oli.Pro_Rated_Date__c != null)
            {
                proRateDate = oli.Pro_Rated_Date__c;
            }

            if (proRateDate != null && 
                (oli.Order_of_Delivery__c <= 1 || oli.Order_of_Delivery__c == null) &&
                oli.Pro_Rata_Billing__c == true &&
                oli.Product2.Duration_Months__c != null
               )
            {
                //bcli = proRateInvoiceAmount_Billing(bcli, bc.Effective_Date__c, bc.Effective_Date__c.addMonths(oli.Product2.Duration_Months__c.intValue()), proRataDate, oli.UnitPrice, mapOLI2ALIs.get(oli.id));

                // CALCULATE THE PRO-RATED AMOUNT ON BILLING LINES
                Date startDate = bcRecord.Effective_Date__c;
                Date endDate = bcRecord.Effective_Date__c.addMonths(oli.Product2.Duration_Months__c.intValue()); 
                Decimal amount = oli.UnitPrice; 
                
                Activity_Line_Item__c ali = mapOLI2ALIs.get(oli.Id);
                Decimal numerator = startDate.daysBetween(proRateDate) + 1;
                Decimal denominator = startDate.daysBetween(endDate) - 1;
                Decimal proRataPercent = numerator/denominator.setScale(2);
                bcli.Pro_Rated__c = true;
                // PRICING & AMOUNTS
                bcli.Total_Amount__c = (amount * proRataPercent * ali.Units__c).setScale(2);
                bcli.Unit_Price__c = (amount * proRataPercent).setScale(2);
                
                bcli.Line_Item_Description__c = 'Annual amount has been pro-rated for ' + numerator.setScale(2).format() + ' days to sync to the following date: \n' + proRateDate.format() + ' | ' + amount.setScale(2).format() + ' / ' + denominator.setScale(2).format() + ' * ' + numerator.setScale(2).format() + ' days = ' + (amount * proRataPercent).setScale(2).format() + '\n | ' + (amount * proRataPercent).setScale(2).format() + ' * ' + ali.Units__c.setScale(0).format() + ' = ' + (bcli.Total_Amount__c).setScale(2).format();
                bcli.Line_Item_Description__c += '\n ' + bcli.Revenue_Category__c + ' - Start: ' + ali.Contract_Start_Date__c.format() + ' End: ' + ali.Contract_End_Date__c.format();
                
                if (bcli.Line_Item_Description__c.length() > 255)
                {
                    bcli.Line_Item_Description__c = bcli.Line_Item_Description__c.left(255);
                }

strConsole += '.... BCLI (uncommitted after pro-rating), Id: ' + bcli.Id + ', Name: ' + bcli.Name + ', Quantity: ' + bcli.Quantity__c + ' Unit Price: ' + bcli.Unit_Price__c + ' Total Amount: ' + bcli.Total_Amount__c + '\n';                
                
            }
              
            system.debug(' *** initBillingLine - BC Details (after pro-rating): Quantity__c = ' + bcli.Quantity__c + ', Unit_Price__c = ' + bcli.Unit_Price__c + ', Total_Amount__c = ' + bcli.Total_Amount__c);
            
            returnList.add(bcli);
 
            // FLAG OPPORTUNITY LINE ITEM 
            oli.BC_Line_Created__c = true;
            oli.Auto_Renew__c = oli.Product2.Auto_Renew__c;
            
        }

        if (!lstOpportunityLineItems.isEmpty())
        {
            system.debug(' *** initBillingLine - Updating ' + lstOpportunityLineItems.size() + ' flagged Opportunity Line Items...');
            database.update(lstOpportunityLineItems);
        } 
        
strConsole += '\n\n';  
        
        return returnList;
        
    }
    
    private List<Billing_Contract_Line_Item__c> packageSplit_Billing(List<Billing_Contract_Line_Item__c> oldBillinglist, List<OpportunityLineItem> oliList)
    {
        
        // METHOD FOR SPLITTING BILLING LINES BY PACKAGE COMPONENTS
        
        List<Billing_Contract_Line_Item__c> returnList = new List<Billing_Contract_Line_Item__c>();
        Map<String, List<PSA_Product_Package_Milestone__c>> packageMap = fetchProductPackage(oliList);
        
        for (Billing_Contract_Line_Item__c old_bcli : oldBillinglist)
        {
            // SPLIT OUT THE ITEMS BY PACKAGE
            if (packageMap.containsKey(old_bcli.Product_Package__c))
            {
                
strConsole += 'Apply Product Package Milestone to Billing Contract Line Item...\n\n';      
                
                Integer numberOfLinesToCreate = packageMap.get(old_bcli.Product_Package__c).size();
                Integer linesCreated = 0;
                Decimal billingLinesTotal = 0; 	// THIS WILL STORE THE SUMMED AMOUNT, WE MAY NEED TO ADJUST THIS FOR ROUNDING
                Decimal roundingAdjustment = 0;
                
                for (PSA_Product_Package_Milestone__c pkg : packageMap.get(old_bcli.Product_Package__c))
                {
                    
                    Billing_Contract_Line_Item__c bcli = new Billing_Contract_Line_Item__c();
                    
                    // QUANTITIES, PRICING & AMOUNTS
                    bcli.Quantity__c = old_bcli.Quantity__c;
                    bcli.Unit_Price__c = (old_bcli.Unit_Price__c * (pkg.Percent__c / 100));
                    bcli.Total_Amount__c = (old_bcli.Total_Amount__c * (pkg.Percent__c / 100));                   
                    
                    if (pkg.Product__c != null)
                    {
                        bcli.Product__c = pkg.Product__c;
                    }
                    
                    bcli.Invoice_Date__c = old_bcli.Invoice_Date__c;
                    bcli.Opp_Line_Item_ID__c = old_bcli.Opp_Line_Item_ID__c;
                    bcli.Product_Package__c = pkg.Product_Package__c;
                    bcli.Product_Package_Item__c = pkg.id;
                    bcli.Billing_Contract__c = old_bcli.Billing_Contract__c;
                    bcli.Revenue_Category__c = old_bcli.Revenue_Category__c;
                    bcli.Pro_Rated__c = old_bcli.Pro_Rated__c;
                    bcli.Line_Item_Description__c = old_bcli.Line_Item_Description__c;
                    bcli.Payment_Term_Line_Item__c = old_bcli.Payment_Term_Line_Item__c;
                    bcli.Payment_Terms__c = old_bcli.Payment_Terms__c;
                    bcli.Activation_Required__c = old_bcli.Activation_Required__c;
                    bcli.Status__c = old_bcli.Status__c;
                    bcli.Deployment_Instance__c = old_bcli.Deployment_Instance__c;
                    bcli.CurrencyIsoCode = old_bcli.CurrencyIsoCode;
                    
                    // KEEP TRACK OF THE TOTAL AMOUNT BEING APPLIED TO THE LINES
                    billingLinesTotal += bcli.Total_Amount__c; 
                    
                    linesCreated ++;
                    
                    // THIS IS THE LAST ITEM TO CREATE SO ACCOUNT FOR ANY ROUNDING
                    if (linesCreated == numberOfLinesToCreate) 
                    {
                        roundingAdjustment = (old_bcli.Total_Amount__c - billingLinesTotal);
                        bcli.Unit_Price__c += roundingAdjustment;
                        bcli.Total_Amount__c += roundingAdjustment;
                    }
                    
                    returnList.add(bcli);
                    
strConsole += '.... BCLI (uncommitted after Package Split), Id: ' + bcli.Id + ', Name: ' + bcli.Name + ', Quantity: ' + bcli.Quantity__c + ' Unit Price: ' + bcli.Unit_Price__c + ' Total Amount: ' + bcli.Total_Amount__c + '\n';                

                }
            }
            else
            { 
                returnList.add(old_bcli);
            }
        }
        
strConsole += '\n';  
                
        return returnList;
        
    }
    
    private List<Billing_Contract_Line_Item__c> paymentSplit_Billing(List<Billing_Contract_Line_Item__c> oldBillinglist, Billing_Contract__c bcRecord)
    {
        
        // Method for Splitting Billing Lines by Payment Terms	
        
        List<Billing_Contract_Line_Item__c> returnList = new List<Billing_Contract_Line_Item__c>();
        
        Set<Id> setTermsIds = new Set<Id>();
        for (Billing_Contract_Line_Item__c bli : oldBillinglist)
        {
            setTermsIds.add(bli.Payment_Terms__c);
        }
        
        Map<Id, Payment_Terms__c> paymentTermsMap = new Map<Id, Payment_Terms__c>([
            SELECT Id, Offset_Date__c, Activation_Required__c, Invoice_Split_Method__c, Billed_through_PSA__c, Bill_if_Activation_Date_comes_first__c,
            (SELECT Id, Order__c, Offset_Measure__c, Offset_Units__c, Percent_of_Total__c, Invoice_Line_Description__c 
             FROM Payment_Term_Line_Items__r
             ORDER BY Order__c)
            FROM Payment_Terms__c
            WHERE Id IN : setTermsIds]);
        
        for (Billing_Contract_Line_Item__c old_bcli : oldBillinglist)
        {
            
            Payment_Terms__c pmtTerms;
            pmtTerms = paymentTermsMap.containsKey(old_bcli.Payment_Terms__c) ? paymentTermsMap.get(old_bcli.Payment_Terms__c) : null;
            system.assert(pmtTerms != null, 'No applicable payment terms found!');
            Integer numberOfInvoicesToCreate = pmtTerms.Payment_Term_Line_Items__r.size();
            Date invoiceDate = old_bcli.Invoice_Date__c;
            
            //SKIP SPLITTING BECAUSE THERE IS ONLY 1 INVOICE IN THE PAYMENT TERMS
            if (numberOfInvoicesToCreate == 1)
            {
                returnList.add(old_bcli);
                continue;
            }
            
            //PRO RATA THE INVOICE BASED ON THE PRO-RATA DATE, DISREGARD THE OTHER PAYMENT TERMS
            if (old_bcli.Pro_Rated__c == true)
            {
                returnList.add(old_bcli);
                continue;
            }
            
            // if number of invoices is > 1, split out the single Opp line into multiple billing line items.
            if (numberOfInvoicesToCreate > 1)
            {
                
                system.debug(' *** billingContractHandler - paymentSplit_Billing - ENTER > 1 *****');
                Integer invoicesCreated = 0;
                Map<Decimal, Decimal> invoiceAmountMap = new Map<Decimal, Decimal>();
                Map<Decimal, Decimal> invoiceUnitPriceMap = new Map<Decimal, Decimal>();

strConsole += 'Apply Payment Splits to Billing Contract Line Item...\n\n';      
                                
                for (Payment_Term_Line_Item__c pmtLine : pmtTerms.Payment_Term_Line_Items__r) // populate the invoice amount map based on the order
                {
                    Decimal invoiceAmount;
                    Decimal unitPrice;
                    if (pmtTerms.Invoice_Split_Method__c == 'Equal')
                    {
                        invoiceAmount = (old_bcli.Total_Amount__c / numberOfInvoicesToCreate).setscale(2);
                        unitPrice = (old_bcli.Unit_Price__c / numberOfInvoicesToCreate).setscale(2);
                        invoiceAmountMap.put(pmtLine.Order__c, invoiceAmount);
                        invoiceUnitPriceMap.put(pmtLine.Order__c, unitPrice);
                    }
                    if (pmtTerms.Invoice_Split_Method__c == 'Percent Breakdown')
                    {
                        invoiceAmount = (old_bcli.Total_Amount__c * (pmtLine.Percent_of_Total__c / 100)).setscale(2);
                        unitPrice = (old_bcli.Unit_Price__c * (pmtLine.Percent_of_Total__c / 100)).setscale(2);
                        invoiceAmountMap.put(pmtLine.Order__c, invoiceAmount);
                        invoiceUnitPriceMap.put(pmtLine.Order__c, unitPrice);
                    }
                }
                
                Decimal billingLinesTotal = 0; //this will store the summed amount, we may need to adjust this for rounding
                Decimal roundingAdjustment = 0;
                
                for (Payment_Term_Line_Item__c pmtLine : pmtTerms.Payment_Term_Line_Items__r)
                {
                    if (invoicesCreated != 0) //if this is not the first item in the list, then add months / days / years.
                    {
                        if (pmtLine.Offset_Measure__c == 'Days' && pmtLine.Offset_Units__c != 0 && pmtLine.Offset_Units__c != null)
                        {
                            invoiceDate = bcRecord.Effective_Date__c.addDays(pmtLine.Offset_Units__c.intValue());
                        }
                        if (pmtLine.Offset_Measure__c == 'Months' && pmtLine.Offset_Units__c != 0 && pmtLine.Offset_Units__c != null)
                        {
                            invoiceDate = bcRecord.Effective_Date__c.addMonths(pmtLine.Offset_Units__c.intValue());
                        }
                        if (pmtLine.Offset_Measure__c == 'Years' && pmtLine.Offset_Units__c != 0 && pmtLine.Offset_Units__c != null)
                        {
                            invoiceDate = bcRecord.Effective_Date__c.addYears(pmtLine.Offset_Units__c.intValue());
                        }
                    }
                    
                    String lineDescription = pmtLine.Invoice_Line_Description__c != null ? pmtLine.Invoice_Line_Description__c : old_bcli.Line_Item_Description__c;
                    
                    Billing_Contract_Line_Item__c bcli = new Billing_Contract_Line_Item__c();
                    
                    // QUANTITIES, PRICING & AMOUNTS
                    bcli.Quantity__c = old_bcli.Quantity__c;
                    bcli.Unit_Price__c = invoiceUnitPriceMap.get(pmtLine.Order__c).setScale(2);
                    bcli.Total_Amount__c = invoiceAmountMap.get(pmtLine.Order__c).setScale(2);
                    
                    bcli.Invoice_Date__c = invoiceDate;
                    bcli.Product__c = old_bcli.Product__c;
                    bcli.Opp_Line_Item_ID__c = old_bcli.Opp_Line_Item_ID__c;
                    bcli.Payment_Term_Line_Item__c = pmtLine.id;
                    bcli.Billing_Contract__c = old_bcli.Billing_Contract__c;
                    bcli.Product_Package__c = old_bcli.Product_Package__c;
                    bcli.Pro_Rated__c = old_bcli.Pro_Rated__c;
                    bcli.Product_Package_Item__c = old_bcli.Product_Package_Item__c;
                    bcli.Revenue_Category__c = old_bcli.Revenue_Category__c;
                    bcli.Line_Item_Description__c = lineDescription;
                    bcli.Opportunity__c = old_bcli.Opportunity__c;
                    bcli.Split_Order__c = invoicesCreated + 1;
                    bcli.Payment_Terms__c = old_bcli.Payment_Terms__c;
                    bcli.Activation_Required__c = old_bcli.Activation_Required__c;
                    bcli.Status__c = old_bcli.Status__c;
                    bcli.Deployment_Instance__c = old_bcli.Deployment_Instance__c;
                    bcli.CurrencyIsoCode = old_bcli.CurrencyIsoCode;
                    
                    billingLinesTotal += bcli.Total_Amount__c; //keep track of the total amount being applied to the lines
                    
                    invoicesCreated ++;
                    if (invoicesCreated == numberOfInvoicesToCreate) //this is the last item to create so account for any rounding.
                    {
                        roundingAdjustment = (old_bcli.Total_Amount__c - billingLinesTotal).setScale(2);
                        bcli.Unit_Price__c += roundingAdjustment;
                        bcli.Total_Amount__c += roundingAdjustment;
                    }
                    
strConsole += '.... BCLI (uncommitted after Payment Split), Id: ' + bcli.Id + ', Name: ' + bcli.Name + ', Quantity: ' + bcli.Quantity__c + ' Unit Price: ' + bcli.Unit_Price__c + ' Total Amount: ' + bcli.Total_Amount__c + '\n';                

                    returnList.add(bcli);
                }

                continue;
            }
        }
        
strConsole += '\n'; 
    
        return returnList;
        
    }

    // ============================================================================================================================
    //  ACTIVITY LINE ITEM FUNCTIONS
    // ============================================================================================================================     
    private List<Activity_Line_Item__c> initActivityLine(List<OpportunityLineItem> lstOpportunityLineItems, Opportunity oppRecord, Billing_Contract__c bcRecord, Map<Id, Payment_Terms__c> invoiceTermsMap, Map<Id, Integer> deliveryOffsetMap)
    {

        // METHOD FOR INITIALIZING THE ACTIVITY LINE
        
        system.debug(' *** initActivityLine - Gathering Data ...');
        
        Payment_Terms__c pmtTerms;
        
        Set<Id> packageId_Set = new Set<Id>();
        Map<String, VSOE_Pricing_Item__c> vsoePricingMap = new Map<String, VSOE_Pricing_Item__c>();
        List<Activity_Line_Item__c> returnList = new List<Activity_Line_Item__c>();
        
        for (VSOE_Pricing_Item__c vsoe : [SELECT Id, Software_Discount__c, Service_Discount__c, Customer_Account__c, Product__c
                                          FROM VSOE_Pricing_Item__c
                                          WHERE Customer_Account__c = : oppRecord.AccountId])
        {
            if (vsoe.Product__c != null)
            {
                vsoePricingMap.put(vsoe.Customer_Account__c + '|' + vsoe.Product__c, vsoe);	
            }
            else
            {
                vsoePricingMap.put(vsoe.Customer_Account__c + '|', vsoe);	
            }	
        }
        
        Date aliStartDate;
        // MAP USED TO TRACK THE APPROPRIATE ACTIVITY LINE START DATE IN THE CASE OF MULTI-YEAR LINES
        Map<String, Date> proRataStartDateMap = new Map<String, Date>(); 

strConsole += 'Instantiating Activity Line Items...\n\n';
               
        // LOOP THROUGH AND CREATE THE ACTIVITY LINE ITEMS
        for (OpportunityLineItem oli : lstOpportunityLineItems)
        {
            
strConsole += '.. OLI, Id: ' + oli.Id + ', Name: ' + oli.Product2.Name + ', Quantity: ' + oli.Quantity + ', Sales Price: ' + oli.unitPrice + ', List Price: ' + oli.ListPrice  + ' Total Price: ' + oli.TotalPrice + '\n'; 

            pmtTerms = null;
            
            if (invoiceTermsMap.containsKey(oli.Invoice_Terms__c))
            {
                pmtTerms = invoiceTermsMap.get(oli.Invoice_Terms__c);
            }
            
            system.debug(' *** initActivityLine - pmtTerms = ' + pmtTerms);
            system.assert(pmtTerms != null, 'ERROR: No applicable payment terms were found, please check the Agreement record related to this Opportunity');
            
            system.debug(' *** initActivityLine - Creating Activity Line Items...');
            
            system.debug('oli.Activity_Line_Created__c : '+oli.Activity_Line_Created__c);
            
            if (oli.Activity_Line_Created__c == false)
            {

                system.debug('in if...');
                
                Decimal unitPrice = oli.UnitPrice;
                
                Activity_Line_Item__c ali = new Activity_Line_Item__c();
                
                // QUANTITIES, PRICING & AMOUNTS
                ali.Units__c = oli.Quantity;
                ali.Contract_Amount__c = unitPrice;
                ali.Renewal_Base_Price__c = unitPrice;
                ali.List_Price__c = oli.ListPrice;

                system.debug(' *** initActivityLine - ALI Details (before pro-rating): Units__c = ' + ali.Units__c + ', Contract_Amount__c = ' + ali.Contract_Amount__c + ', List_Price__c = ' + ali.List_Price__c);
                
                ali.Billing_Contract__c = bcRecord.Id;
                ali.Attn_to_Contact__c = bcRecord.Attn_to_Contact__c;
                ali.CurrencyIsoCode = bcRecord.CurrencyIsoCode;
                ali.Product_Package__c = oli.Product2.Product_Package__c;
                ali.Origin__c = 'New Order';
                ali.Opportunity__c = oli.OpportunityId;
                ali.Renewal_Pricebook__c = oli.Renewal_Pricebook__c;
                ali.Auto_Renewal__c = false;
                
                if (unitPrice > 0  && oli.Quantity > 0)
                {
                    ali.Auto_Renewal__c = oli.Product2.Auto_Renew__c;
                }
                
                ali.Send_Customer_Renewal_Notice__c = oli.Product2.Auto_Renew__c;
                ali.Payment_Terms__c = pmtTerms.Id;
                ali.Order_of_Delivery__c = oli.Order_of_Delivery__c;
                ali.Opp_Product_ID__c = oli.Id;
                ali.Delivery_Offset_Months__c = 0;                
                ali.Product__c = oli.Product2Id;
                ali.Activation_Required__c = pmtTerms.Activation_Required__c;
                ali.Revenue_Category__c = oli.Product2.Apttus_Revenue_Category__c;
                
                if (oli.Product2.Product_Group__r.Name == 'Cendyn')
                {
                    ali.Activation_Required__c = true;
                }

strConsole += '.... ALI (uncommitted), Id: ' + ali.Id + ', Name: ' + ali.Name + ', Quantity: ' + ali.Units__c + ', Units: ' + ali.Units__c + ', Unit Price: ' + ali.Contract_Amount__c + ', List Price: ' + ali.List_Price__c + '\n';

                // CALCULATE ANY PRO-RATED PRICES
                Date proRateDate;
                Date proRateEndDate;
                
                if (oli.Pro_Rata_Billing__c == true)
                {
                    if (oli.Pro_Rated_Date__c != null)
                    {
                        proRateDate = oli.Pro_Rated_Date__c;
                    }
                    
                    if (proRateEndDate != null)
                    {
                        proRataStartDateMap.put(oli.Product2.ProductCode, proRateDate);
                    }
                    
                    if (proRateDate != null && 
                        (oli.Order_of_Delivery__c <= 1 || oli.Order_of_Delivery__c == null) &&
                        oli.Pro_Rata_Billing__c == true &&
                        oli.Product2.Duration_Months__c != null
                       )
                    {
                        // activityLine = proRateInvoiceAmount_Activity(activityLine, bc.Effective_Date__c, bc.Effective_Date__c.addMonths(oli.Product2.Duration_Months__c.intValue()), proRataDate, oli.UnitPrice);

                        // CALCULATE THE PRO-RATED AMOUNT ON ACTIVITY LINE ITEMS
                        Date startDate = bcRecord.Effective_Date__c;
                        Date endDate = bcRecord.Effective_Date__c.addMonths(oli.Product2.Duration_Months__c.intValue()); 
                        Decimal numerator = startDate.daysBetween(proRateDate) + 1;
                        Decimal denominator = startDate.daysBetween(endDate);
                        Decimal proRatePercent = numerator/denominator.setScale(2);
                        Decimal amount = oli.UnitPrice;
                        ali.Pro_Rated__c = true;
                        ali.Pro_Rated_Date__c = proRateDate;
                        ali.Contract_Amount__c = (amount * proRatePercent).setScale(2);
                        proRateEndDate = proRateDate;
                    }
                }
                
                // vsoe pricing considerations
                if (vsoePricingMap.containsKey(oli.Opportunity.AccountId + '|' + oli.Product2id))
                {
                    ali.VSOE_Pricing_Item__c = vsoePricingMap.get(oli.Opportunity.AccountId + '|' + oli.Product2id).Id;
                    if (ali.Revenue_Category__c == 'Services')
                    {
                        ali.VSOE_Discount__c = vsoePricingMap.get(oli.Opportunity.AccountId + '|' + oli.Product2id).Service_Discount__c;
                    }
                    if (ali.Revenue_Category__c == 'Software')
                    {
                        ali.VSOE_Discount__c = vsoePricingMap.get(oli.Opportunity.AccountId + '|' + oli.Product2id).Software_Discount__c;
                    }
                }
                else 
                {
                    if (vsoePricingMap.containsKey(oli.Opportunity.AccountId + '|'))
                    {
                        ali.VSOE_Pricing_Item__c = vsoePricingMap.get(oli.Opportunity.AccountId + '|').Id;
                        if (ali.Revenue_Category__c == 'Services')
                        {
                            ali.VSOE_Discount__c = vsoePricingMap.get(oli.Opportunity.AccountId + '|').Service_Discount__c;
                        }
                        if (ali.Revenue_Category__c == 'Software')
                        {
                            ali.VSOE_Discount__c = vsoePricingMap.get(oli.Opportunity.AccountId + '|').Software_Discount__c;
                        }
                    }
                    else
                    {
                        ali.VSOE_Discount__c = 0;
                    }
                }
                
                // vsoe element type
                if (ali.Revenue_Category__c == 'Support' || 
                    ali.Revenue_Category__c == 'Software'|| 
                    ali.Revenue_Category__c == 'Hosting and Support')
                {
                    ali.VSOE_Element_Type__c = 'Software';
                }
                
                if (ali.Revenue_Category__c == 'Subscription' || 
                    ali.Revenue_Category__c == 'Services')
                {
                    ali.VSOE_Element_Type__c = 'Non-Software';
                }
                
                // contract start and end dates
                if (oli.Product2.Duration_Months__c != null)
                {
                    
                    aliStartDate = oppRecord.CloseDate.addMonths(ali.Delivery_Offset_Months__c.intValue());
                    if (proRataStartDateMap.containsKey(oli.Product2.ProductCode) && proRateEndDate == null)
                    {
                        aliStartDate = proRataStartDateMap.get(oli.Product2.ProductCode);
                    }
                        
                    if (ali.Activation_Required__c == false && 
                        ali.Revenue_Category__c != 'Subscription' && 
                        ali.Revenue_Category__c != 'Hosting and Support')
                    {
                        
                        ali.Contract_Start_Date__c = oppRecord.CloseDate.addMonths(ali.Delivery_Offset_Months__c.intValue());
                        if (aliStartDate != null)
                        {
                            ali.Contract_Start_Date__c = aliStartDate;
                        }
                        
                        ali.Contract_End_Date__c = ali.Contract_Start_Date__c.addMonths(oli.Product2.Duration_Months__c.intValue());
                        if (proRateEndDate != null)
                        {
                            ali.Contract_End_Date__c = proRateEndDate;
                        }
                        
                        // ali.Activation_Date__c = diObject != null && diObject.InstallDate != null ? diObject.InstallDate : null;
                        
                    }
                    if (ali.Revenue_Category__c == 'Support')
                    {
                        ali.Activation_Date__c = oppRecord.CloseDate.addDays(60);
                        ali.Contract_Start_Date__c = oppRecord.CloseDate.addDays(60);
                        ali.Contract_End_Date__c = ali.Contract_Start_Date__c.addMonths(oli.Product2.Duration_Months__c.intValue());
                        if (proRateEndDate != null)
                        {
                            ali.Contract_End_Date__c = proRateEndDate;
                        }
                             
                    }
                }

strConsole += '.... ALI (uncommitted after pro-rating), Id: ' + ali.Id + ', Name: ' + ali.Name + ', Quantity: ' + ali.Units__c + ', Units: ' + ali.Units__c + ', Unit Price: ' + ali.Contract_Amount__c + ', List Price: ' + ali.List_Price__c + '\n';

                system.debug(' *** initActivityLine - ALI Details (after pro-rating): Units__c = ' + ali.Units__c + ', Contract_Amount__c = ' + ali.Contract_Amount__c + ', List_Price__c = ' + ali.List_Price__c);
                
                returnList.add(ali);
                
            }
            
            // FLAG OPPORTUNITY LINE ITEM 
            oli.Activity_Line_Created__c = true;
            
        }

        Set<ID> oppLineIDSet = new Set<ID>();
		for (OpportunityLineItem oli : lstOpportunityLineItems)
        {
            oppLineIDSet.add(oli.id);
        }
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>([select ID, Opportunity.AccountID from OpportunityLineItem where ID IN : oppLineIDSet]);
        
        Set<ID> accIDSet = new Set<ID>();
		for (OpportunityLineItem oli1 : oliList)
        {
            accIDSet.add(oli1.id);
        }
        List<Account> accList = new List<Account>([select ID from Account where ID IN : accIDSet FOR UPDATE]);
        
        
        
        if (!lstOpportunityLineItems.isEmpty())
        {
            system.debug(' *** initActivityLine - Updating ' + lstOpportunityLineItems.size() + ' flagged Opportunity Line Items...');
            database.update(lstOpportunityLineItems);
        }

strConsole += '\n';
        
        return returnList;
        
    }    
    
    private List<Activity_Line_Item__c> packageSplit_Activity(List<Activity_Line_Item__c> oldActivityList, List<OpportunityLineItem> oliList)
    {
        
        // Method for Splitting Activity Lines by Package Components	
        
        List<Activity_Line_Item__c> returnList = new List<Activity_Line_Item__c>();
        Map<String, List<PSA_Product_Package_Milestone__c>> packageMap = fetchProductPackage(oliList);

        for (Activity_Line_Item__c old_ali : oldActivityList)
        {
            // split out the items by package
            if (packageMap.containsKey(old_ali.Product_Package__c)) 
            {

strConsole += 'Apply Product Package Milestone to Activity Line Item...\n\n';      
                
                Integer numberOfLinesToCreate = packageMap.get(old_ali.Product_Package__c).size();
                Integer linesCreated = 0;
                Decimal activityLinesTotal = 0; //this will store the summed amount, we may need to adjust this for rounding
                Decimal roundingAdjustment = 0;
                
                for (PSA_Product_Package_Milestone__c pkg : packageMap.get(old_ali.Product_Package__c))
                {
                    
                    Activity_Line_Item__c ali = new Activity_Line_Item__c();
                    ali.Billing_Contract__c = old_ali.Billing_Contract__c; 
                    
strConsole += '..Package detail: Percent__c = ' + pkg.Percent__c + '\n'; 
                    
                    // QUANTITIES, PRICING & AMOUNTS
                    ali.Units__c = old_ali.Units__c; 
                    ali.List_Price__c = old_ali.List_Price__c * (pkg.Percent__c / 100);
                    ali.Renewal_Base_Price__c = (old_ali.Contract_Amount__c * (pkg.Percent__c / 100));
                    ali.Contract_Amount__c = (old_ali.Contract_Amount__c * (pkg.Percent__c / 100));
                    
                    if (pkg.Product__c != null)
                    {
                        ali.Product__c = pkg.Product__c; 
                    }
                    
                    ali.Attn_to_Contact__c = old_ali.Attn_to_Contact__c; 
                    ali.Product_Package__c = pkg.Product_Package__c; 
                    ali.Product_Package_Item__c = pkg.Id; 
                    ali.Opp_Product_ID__c = old_ali.Opp_Product_ID__c; 
                    ali.Pro_Rated__c = old_ali.Pro_Rated__c; 
                    ali.Opportunity__c = old_ali.Opportunity__c; 
                    ali.Revenue_Category__c = old_ali.Revenue_Category__c; 
                    ali.Order_of_Delivery__c = old_ali.Order_of_Delivery__c; 
                    ali.Origin__c = old_ali.Origin__c; 
                    ali.Auto_Renewal__c = old_ali.Auto_Renewal__c; 
                    ali.Send_Customer_Renewal_Notice__c = old_ali.Send_Customer_Renewal_Notice__c; 
                    
                    ali.VSOE_Element_Type__c = old_ali.VSOE_Element_Type__c; 
                    ali.Renewal_Pricebook__c = old_ali.Renewal_Pricebook__c; 
                    ali.Payment_Terms__c = old_ali.Payment_Terms__c; 
                    ali.Delivery_Offset_Months__c = old_ali.Delivery_Offset_Months__c; 
                    ali.VSOE_Pricing_Item__c = old_ali.VSOE_Pricing_Item__c; 
                    ali.Activation_Required__c = old_ali.Activation_Required__c; 
                    ali.VSOE_Discount__c = old_ali.VSOE_Discount__c; 
                    ali.Deployment_Instance__c = old_ali.Deployment_Instance__c; 
                    ali.CurrencyIsoCode = old_ali.CurrencyIsoCode; 
                    ali.Milestone_Name_Prefix__c = pkg.Milestone_Name_Prefix__c; 
                    
                    // keep track of the total amount being applied to the lines
                    activityLinesTotal += ali.Contract_Amount__c; 
                    
                    linesCreated ++;
                    
                    // this is the last item to create so account for any rounding.                    
                    if (linesCreated == numberOfLinesToCreate) 
                    {
                        roundingAdjustment = (old_ali.Contract_Amount__c - activityLinesTotal);
                        ali.Contract_Amount__c += roundingAdjustment;
                        ali.List_Price__c += roundingAdjustment;
                    }
                    
                    returnList.add(ali);
                    
strConsole += '.. roundingAdjustment = ' + roundingAdjustment + '\n';
strConsole += '.... ALI (uncommitted after package Split), Id: ' + ali.Id + ', Name: ' + ali.Name + ', Quantity: ' + ali.Units__c + ', Units: ' + ali.Units__c + ', Unit Price: ' + ali.Contract_Amount__c + ', List Price: ' + ali.List_Price__c + '\n';
           	
                }
            }
            else
            {           
                returnList.add(old_ali);
            }
        }

strConsole += '\n';  
     
        return returnList;
        
    }
    
    // ============================================================================================================================
    //  UTILITY FUNCTIONS
    // ============================================================================================================================
    private Map<String, Payment_Terms__c> queryOppPaymentTerms(Opportunity oppRecord)
    {
        
        // METHOD FOR RETURNING THE PAYMENT APPLICABLE PAYMENT TERMS FROM THE OPPORTUNITY
        
        Set<Id> setTermIds = new Set<Id>();
        setTermIds.add(oppRecord.License_Program_Payment_Terms__c);
        setTermIds.add(oppRecord.Hosting_and_Support_Payment_Terms__c);
        setTermIds.add(oppRecord.Support_Payment_Terms__c);
        setTermIds.add(oppRecord.Services_Payment_Terms__c);
        setTermIds.add(oppRecord.Subscription_Payment_Terms__c);
        setTermIds.add(oppRecord.HRM_Subscription_Invoice_Terms__c);
        setTermIds.add(oppRecord.HRM_Service_Invoice_Terms__c);
        
        Map<String, Payment_Terms__c> mapOppPaymentTerms = new Map<String, Payment_Terms__c>([
            SELECT Id, Offset_Date__c, Activation_Required__c, Invoice_Split_Method__c, Billed_through_PSA__c, Bill_if_Activation_Date_comes_first__c,
            (SELECT Id, Order__c, Offset_Measure__c, Offset_Units__c, Percent_of_Total__c, Invoice_Line_Description__c
             FROM Payment_Term_Line_Items__r 
             ORDER BY Order__c)
            FROM Payment_Terms__c
            WHERE Id IN : setTermIds]);
        
        Map<String, Payment_Terms__c> mapAllPaymentTerms = new Map<String, Payment_Terms__c>([
            SELECT Id, Offset_Date__c, Activation_Required__c, Invoice_Split_Method__c, Billed_through_PSA__c, Bill_if_Activation_Date_comes_first__c,
            (SELECT Id, Order__c, Offset_Measure__c, Offset_Units__c, Percent_of_Total__c, Invoice_Line_Description__c
             FROM Payment_Term_Line_Items__r
             ORDER BY Order__c)
            FROM Payment_Terms__c]);
        
        Map<String, Payment_Terms__c> mapTermsFinal = new Map<String, Payment_Terms__c>(); 
        
        // TRANSFORM THIS MAP INTO ONE BASED ON APTTUS REVENUE CATEGORY
        if (mapOppPaymentTerms.containsKey(oppRecord.Services_Payment_Terms__c))
        {
            mapTermsFinal.put('Services', mapOppPaymentTerms.get(oppRecord.Services_Payment_Terms__c));
        }
        if (mapOppPaymentTerms.containsKey(oppRecord.License_Program_Payment_Terms__c))
        {
            mapTermsFinal.put('Software', mapOppPaymentTerms.get(oppRecord.License_Program_Payment_Terms__c));
        }
        if (mapOppPaymentTerms.containsKey(oppRecord.Subscription_Payment_Terms__c))
        {
            mapTermsFinal.put('Subscription', mapOppPaymentTerms.get(oppRecord.Subscription_Payment_Terms__c));
        }
        if (mapOppPaymentTerms.containsKey(oppRecord.Support_Payment_Terms__c))
        {
            mapTermsFinal.put('Support', mapOppPaymentTerms.get(oppRecord.Support_Payment_Terms__c));
        }
        if (mapOppPaymentTerms.containsKey(oppRecord.Hosting_and_Support_Payment_Terms__c))
        {
            mapTermsFinal.put('Hosting and Support', mapOppPaymentTerms.get(oppRecord.Hosting_and_Support_Payment_Terms__c));
        }
        if (mapOppPaymentTerms.containsKey(oppRecord.HRM_Subscription_Invoice_Terms__c))
        {
            mapTermsFinal.put('HRM Subscription', mapOppPaymentTerms.get(oppRecord.HRM_Subscription_Invoice_Terms__c));
        }
        if (mapOppPaymentTerms.containsKey(oppRecord.HRM_Service_Invoice_Terms__c))
        {
            mapTermsFinal.put('HRM Services', mapOppPaymentTerms.get(oppRecord.HRM_Service_Invoice_Terms__c));
        }
        
        // OVERLOAD THE MAP WITH THE PAYMENT TERM IDS AS KEYS (THIS WILL BE USEFUL FOR OVERRIDING AT THE PRODUCT LEVEL)
        mapTermsFinal.putAll(mapAllPaymentTerms);
        
        return mapTermsFinal;
        
    }        
    
    private Map<String, List<PSA_Product_Package_Milestone__c>> fetchProductPackage(List<OpportunityLineItem> lstOpportunityLineItems)
    {
        
        // METHOD FOR RETURNING THE APPLICABLE PAYMENT TERMS FROM THE OPPORTUNITY
        
        Map<String, List<PSA_Product_Package_Milestone__c>> package_Map = new Map<String, List<PSA_Product_Package_Milestone__c>>();
        Set<Id> setPackageIds = new Set<Id>();
        
        // LOOP THROUGH THE OPP LINE ITEMS AND COLLECT THE IDS FROM ANY PRODUCT PACKAGE OBJECTS
        for (OpportunityLineItem oli : lstOpportunityLineItems)
        {
            if (oli.Product2.Product_Package__c != null)
            {
                setPackageIds.add(oli.Product2.Product_Package__c);
            }
        }
        
        // GRAB NECESSARY DISTRIBUTION DATA
        for (PSA_Product_Package_Milestone__c packageLine : [SELECT Id, Product__c, Percent__c, Milestone_Name_Prefix__c, Product_Package__c, Milestone_Type__c
                                                             FROM PSA_Product_Package_Milestone__c
                                                             WHERE Product_Package__c IN : setPackageIds])
        {
            if (package_Map.containsKey(packageLine.Product_Package__c))
            {
                List<PSA_Product_Package_Milestone__c> tmpList = package_Map.get(packageLine.Product_Package__c);
                tmpList.add(packageLine);
                package_Map.put(packageLine.Product_Package__c, tmpList);
            }
            else
            {
                List<PSA_Product_Package_Milestone__c> tmpList = new List<PSA_Product_Package_Milestone__c>();
                tmpList.add(packageLine);
                package_Map.put(packageLine.Product_Package__c, tmpList);
            }
        }
        
        return package_Map;
        
    }
    
    private Map<Id, Integer> calculateDeliveryOffset(Id oppId)
    {
        
        // CALCULATE THE DELIVERY OFFSET OF EACH OPPORTUNITY LINE ITEM
        
        Map<Id, Integer> deliveryOffsetMap = new Map<Id, Integer>();
        Set<String> productProcessedSet = new Set<String>();
        
        List<OpportunityLineItem> oppLinestoUpdate = [SELECT Id, OpportunityId, Product2.Duration_Months__c, Product2id, Order_of_Delivery__c, Delivery_Offset_Months__c 
                                                      FROM OpportunityLineItem
                                                      WHERE OpportunityId =: oppId
                                                      AND Product2.Duration_Months__c != null
                                                      AND Order_of_Delivery__c != null
                                                      ORDER BY Product2id, Order_of_Delivery__c];
        Integer deliveryOffset;
        
        for (OpportunityLineItem oli : oppLinestoUpdate)
        {
            if (!productProcessedSet.contains(oli.Product2id))
            {
                deliveryOffset = 0;
                productProcessedSet.add(oli.Product2id);
                deliveryOffsetMap.put(oli.id, deliveryOffset);
            }
            else
            {
                deliveryOffset = deliveryOffset + oli.Product2.Duration_Months__c.intValue();
                deliveryOffsetMap.put(oli.id, deliveryOffset);
            }
        }
        
        return deliveryOffsetMap;
        
    } 

    // ============================================================================================================================
    //  WRAPPER CLASSES
    // ============================================================================================================================
    public class lineItemWrapper 
    {
        
        public List<Billing_Contract_Line_Item__c> billingLineList;
        public List<Activity_Line_Item__c> activityLineList;
        
        public void lineItemWrapper()
        {
            billingLineList = new List<Billing_Contract_Line_Item__c>();
            activityLineList = new List<Activity_Line_Item__c>();
        }
        
    }    
    
    public class oliWrapper
    {
        
        public OpportunityLineItem oli_object {get; set;}
        public Activity_Line_Item__c dummyALI {get; set;}
        public boolean check {get; set;}
        public boolean disableProRata {get; set;}
        public boolean activationRequired {get; set;}
        
        public oliWrapper()
        {
            dummyALI = new Activity_Line_Item__c();
            oli_object = new OpportunityLineItem();
            check = false;
        }
        
    }
    
}