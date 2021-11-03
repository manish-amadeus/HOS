/****************************************************************************************
Name            : AH_CreateServiceOrder Class 
Author          : Suzanne LeDuc
Created Date    : 01/04/2015
Last Mod Date   : 01/18/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-010386
Description     : Class for creating a Service Order  
                : Sets up the Apex Page with products to order and matching Org
                : Updated 03/21/2018 per AH_CreateServiceOrder Class
                : 04/18/2017 - Major change. Pointed this code to insert & Update records
                : in Subscription Activation Transaction Object from Opportunity Line Item
                : 12/20/2018 - Change in send order method as per new version.
******************************************************************************************/
public class AH_CreateServiceOrder
{ 
    
    // OBJECT VARIABLES 
    public Opportunity oppty {get; set;}
    public String oppId {get; set;}
    public Account acc; 
    public Id accId {get; set;}
    
    // SERVICE ORDER VARIABLES 
    public CHANNEL_ORDERS__Service_Order__c so; 
    public String strDateCustomerSignedContract {get; set;} 
    public String strAmadeusSignedContract {get; set;} 
    public String strServiceStartDate {get; set;} 
    public String oppProjManager {get; set;} 
    public String additionalToEmail {get; set;}
    public Boolean notifyOppContact {get; set;} 
    public Note soNote {get; set;}
    public String products {get; set;}
    
    // PICKLIST VARIABLES
    public List<selectOption> ContractOptions {get; set;} 
    public string selectedContract {get; set;}
    
    public List<selectOption> OrgOptions {get; set;} 
    public string selectedOrg {get; set;} 
    
    public List<selectOption> OrderTypeOptions {get; set;} 
    public string selectedOrderType {get; set;}
    
    // INNER CLASS LIST VARIABLES
    public List<subscriptionActivation> lstSActs {get; set;} 
    
    // VISIBILTY VARIABLES
    public boolean displayButton {get; set;}
    
    public OpportunityContactRole oppContact {get; set;}
    
    
    // CONSTRUCTOR
    public AH_CreateServiceOrder()
    {  
        
        system.debug(' *** ENTERING AH_CreateServiceOrder CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
		
        if (ApexPages.currentPage().getParameters().get('OppId') != null)
        {
            oppId = ApexPages.currentPage().getParameters().get('OppId');

            if(oppId != null){
                Opportunity opprtnty = new Opportunity();
                opprtnty = [SELECT Id, //Amadeus_Signed_Contract_Date__c, Customer_Signed_Contract_Date__c, 
                            CloseDate, Effective_Date__c, 
                            pse__Primary_Project__c, pse__Primary_Project__r.pse__Project_Manager__r.Name, pse__Primary_Project__r.pse__Project_Manager__c
                            FROM Opportunity 
                            WHERE Id = :oppId LIMIT 1];
                

                //                if(opprtnty.Customer_Signed_Contract_Date__c != null)
                //                	strDateCustomerSignedContract = opprtnty.Customer_Signed_Contract_Date__c.format();
                //                if(opprtnty.Amadeus_Signed_Contract_Date__c != null)
                //                	strAmadeusSignedContract = opprtnty.Amadeus_Signed_Contract_Date__c.format();

                if (opprtnty.CloseDate != null)
                {
                    strDateCustomerSignedContract = opprtnty.CloseDate.format();
                }
                
                if (opprtnty.Effective_Date__c != null)
                {
                    strAmadeusSignedContract = opprtnty.Effective_Date__c.format();   
                }
                
                oppProjManager = UserInfo.getName(); 
                oppContact = [SELECT Id, Opportunity.Id, Contact.Email, Contact.FirstName, Role 
                              FROM OpportunityContactRole 
                              WHERE Opportunity.Id =: oppId 
                              AND Role = 'Customer Project Contact' 
                              LIMIT 1];
                
            }
            setupServiceOrder();            
        }
        
        system.debug(' *** EXITING AH_CreateServiceOrder CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
		
    }
    
    // PAGE INITIALIZATION FUNCTION 
    public void setupServiceOrder()
    {
        
        system.debug(' *** EXITING AH_CreateServiceOrder.setupServiceOrder() - QUERIES ISSUED = ' + Limits.getQueries());
		
        // SET ADMIN BUTTON VISIBLITY SWITCH 
        displayButton = NI_FUNCTIONS.hasAccessByPublicGroup(UserInfo.getUserId(), 'Create Service Order - Admin Buttons');
        
        // LOAD OPPORTUNITY FROM RETRIEVED URL PARAM OPPORTUNITY ID
        oppty = [SELECT Name, Opportunity_Number__c, AccountId, OwnerID, CloseDate, currencyisocode, Target_HRM_Org__c, Action_Date__c, Target_HRM_Org_Name__c,Owner.Name,
                 (SELECT op.Id, op.Quantity, op.UnitPrice, op.TotalPrice, op.ServiceDate, op.LOD_Licensed_Property__c, op.Service_Order__c,
                  op.PricebookEntry.Name, op.OpportunityId, op.PricebookEntry.ProductCode, op.Release_Date__c, op.Deferred__c,          
                  op.PricebookEntry.Product2.Family, op.CurrencyIsoCode, op.Discount__c, op.Family__c, op.LineType__c, op.ListPrice, op.PricebookEntryId
                  FROM OpportunityLineItems op)
                 FROM Opportunity 
                 WHERE Id =: oppId]; 
        
        // SET ACCOUNT LOOKUP DEFAULT
        if (accId == null)
        {
            accId = oppty.AccountId;
        }
        
        setSelectedAccount();        

        // BECAUSE THERE IS NO LOOKUP TO Product2 ON Subscription_Activation__c OBJECT, CREATE A MAP TO RETRIEVE Partner_Product_Catalog__c IDS
        Map<String, Id> mapProduct2PartnerProductCatalogId = new Map<String, Id>();
        for (OpportunityLineItem oli : [SELECT Id, Product2.Partner_Product_Catalog__c                                      
                                        FROM OpportunityLineItem 
                                        WHERE OpportunityId =: oppty.Id 
                                        AND Product2.Partner_Product_Catalog__c != null])
        {
            mapProduct2PartnerProductCatalogId.put(oli.Id, oli.Product2.Partner_Product_Catalog__c);
        }

        // FILL LIST THAT DISPLAYS VALID PRODUCTS
        lstSActs = new List<subscriptionActivation>();
        for (Subscription_Activation__c sAct : [SELECT Id, Contracted_Quantity__c, Backlog_Quantity__c, Activated_Quantity__c, Canceled_Quantity__c, 
                                                Product_Name__c, Product_Code__c, Product_ID__c, Sales_Prices__c  
                                                FROM Subscription_Activation__c
                                                WHERE Opportunity__c =: oppty.Id 
                                                AND Backlog_Quantity__c > 0 
                                                ORDER BY Product_Name__c ASC]) 
        { 

            // IF RECORD HAS NO PARTNER CATALOG ASSOCIATED TO NOT LOAD
            if (mapProduct2PartnerProductCatalogId.get(sAct.Product_ID__c) != null)
            {
                subscriptionActivation product = new subscriptionActivation(sAct, false, 0, mapProduct2PartnerProductCatalogId.get(sAct.Product_ID__c)); 
                lstSActs.add(product); 
            }
        } 
        
        soNote = new Note();
        
        // FILL CONTRACTS SELECT LIST
        ContractOptions = new List<selectOption>();
        Service_Order_Settings__c soSettings = Service_Order_Settings__c.getValues('AdminLicenseCodes');
        String defaultContractId = '';
        
        for (CHANNEL_ORDERS__Partner_Contract_Terms__c terms : [SELECT Id, Name  
                                                                FROM CHANNEL_ORDERS__Partner_Contract_Terms__c 
                                                                WHERE CHANNEL_ORDERS__Partner_Contract_Terms__c.Active__c = true 
                                                                ORDER BY Name]) 
        { 
            ContractOptions.add(new SelectOption(terms.Id, terms.Name)); 
            
            if (terms.Name == soSettings.Default_Contract__c)
            {
                defaultContractId = terms.Id;                
            }
            
        }
        
        selectedContract = defaultContractId;        
        
        
        // FILL ORG PICKLIST
        OrgOptions = new List<selectOption>();
        
        // IF THE TARGET HRM HAS BEEN SELECTED, ONLY ALLOW THAT IN THE LIST
        if (oppty.Target_HRM_Org__c != null)
        {
            for (NI_Org_Details__c orgs : [SELECT Org_Name__c, Org_ID__c 
                                           FROM NI_Org_Details__c 
                                           WHERE Org_Name__c != null 
                                           AND Org_ID__c != null 
                                           AND Id =: oppty.Target_HRM_Org__c]) 
            { 
                OrgOptions.add(new SelectOption(orgs.Org_ID__c, orgs.Org_Name__c)); 
            }
        }
        else
        {  
            // ORG DETAILS RECORDS ASSOCIATED WITH THE ACCOUNT
            List<NI_Org_Details__c> orgs = [SELECT Org_Name__c, Org_ID__c 
                                            FROM NI_Org_Details__c 
                                            WHERE NI_Org_Details__c.Inactive__c = false 
                                            AND NI_Org_Details__c.Cancellation_Date__c = null 
                                            AND NI_Org_Details__c.ORg_Id__c != null 
                                            AND Org_Name__c != null 
                                            AND Id IN (SELECT NI_Org_Details_To_Accounts__c.NIOrgDetailsId__c 
                                                       FROM NI_Org_Details_To_Accounts__c 
                                                       WHERE AccountID__c =: oppty.accountid)]; 
            
            if (!orgs.isEmpty())  
            {
                for (NI_Org_Details__c o : orgs) 
                { 
                    OrgOptions.add(new SelectOption(o.Org_Id__c, o.Org_Name__c)); 
                }
            }
            else
            {  
                // ALL ORG DETAILS RECORDS
                for (NI_Org_Details__c allorgs : [SELECT Org_Name__c, Org_ID__c 
                                                  FROM NI_Org_Details__c 
                                                  WHERE Org_ID__c != null 
                                                  AND Org_Name__c != null 
                                                  AND Inactive__c = false 
                                                  ORDER BY Org_Name__c]) 
                { 
                    OrgOptions.add(new SelectOption(allorgs.Org_Id__c, allorgs.Org_Name__c)); 
                }
            }
        }
        
        
        // FILL ORDER TYPES PICKLIST
        OrderTypeOptions = new List<selectOption>();
        OrderTypeOptions.add(new SelectOption('Add-On', 'Add-On')); 
        OrderTypeOptions.add(new SelectOption('Initial', 'Initial')); 
        OrderTypeOptions.add(new SelectOption('Upgrade - Partner App', 'Upgrade - Partner App')); 
        
    }     
    
    public Opportunity getSelectedOpportunity()
    {
        return oppty;
    }
    
    public Account getSelectedAccount() 
    {
        return acc;
    }
    
    public void setSelectedAccount()
    {
        try
        {
            acc = [SELECT Id, Name FROM Account WHERE Id =: accId];
        }
        catch (exception ex)  {
            system.debug(' *** ERROR !!! in setSelectedAccount() ');
        }            
    }
    
    public string getSelectedContract()
    {
        return selectedContract;
    }
    
    public void setSelectedContract(string cntrct)
    {
        selectedContract = cntrct;
    }
    
    public string getSelectedOrderType()
    {
        return selectedOrderType;
    }
    
    public void setSelectedOrderType(string orderType)
    {
        selectedOrderType = orderType;        
    }
    
    public string getSelectedOrg()
    {
        return selectedOrg;
    }
    
    public void setSelectedOrg(string orgId)
    {
        selectedOrg = orgId;
    }
    
    public PageReference createSubcriptionActivations()
    {
        
        system.debug(' *** ENTERING AH_CreateServiceOrder.createSubcriptionActivations() - QUERIES ISSUED = ' + Limits.getQueries());
		
        // CREATE Subscription_Activation__c RECORDS VIA BUTTON ON VF PAGE
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>(
            [SELECT Id, Quantity, UnitPrice, TotalPrice, OpportunityId, Opportunity.AccountId, ProductCode, Product2.Name, CurrencyIsoCode                                         
             FROM OpportunityLineItem 
             WHERE OpportunityId =: oppty.Id 
             AND Product2.Partner_Product_Catalog__c != null 
             AND Service_Order__c = null
             AND Synched__c = false 
             AND (Order_of_Delivery__c = 1 OR Order_of_Delivery__c = null)]);         
        
        createMissingSubsActRecords(lstOLIs);   
        setupServiceOrder(); 
        
        system.debug(' *** EXITING AH_CreateServiceOrder.createSubcriptionActivations() - QUERIES ISSUED = ' + Limits.getQueries());
		
        return null;
        
    }
    
    // CALLS THE CREATE SERVICE ORDER METHOD
    public PageReference CreateServiceOrder() 
    {
        
        system.debug(' *** ENTERING AH_CreateServiceOrder.CreateServiceOrder() - QUERIES ISSUED = ' + Limits.getQueries());
		
        if (noProductsChecked(lstSActs))
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No products were checked off to process.');
            ApexPages.addMessage(myMsg);            
            return null;
        }
        
        // SET SELECTED ACCOUNT 
        setSelectedAccount();
        
        // CREATE NEW SERVICE ORDER RECORD
        so = new CHANNEL_ORDERS__Service_Order__c();        
        so.CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = Date.parse(strDateCustomerSignedContract);
        so.CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c = Date.parse(strAmadeusSignedContract);
        so.CHANNEL_ORDERS__Service_Start_Date__c = Date.parse(strServiceStartDate); 
        
        // CREATE Subscription_Activation__c RECORDS IF NEEDED 
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>(
            [SELECT Id, Quantity, UnitPrice, TotalPrice, OpportunityId, Opportunity.AccountId, ProductCode, Product2.Name, CurrencyIsoCode                                         
             FROM OpportunityLineItem 
             WHERE OpportunityId =: oppty.Id 
             AND Product2.Partner_Product_Catalog__c != null 
             AND Service_Order__c = null
             AND Synched__c = false 
             AND (Order_of_Delivery__c = 1 OR Order_of_Delivery__c = null)]);         
        
        createMissingSubsActRecords(lstOLIs);  
        
        // IF THE SERVICE ORDER IS CREATED SUCESSFULLY THEN CREATE A NOTE  
        if (bCreateServiceOrder(lstSActs, oppty) != false)
        {
            // SAVE THE NOTE
            if (!String.isBlank(soNote.Body))
            {
                soNote.ParentId = so.Id;
                if (soNote.Body.length() > 20)
                {
                    soNote.Title = soNote.Body.substring(0, 20);
                }
                else
                {
                    soNote.Title = soNote.Body;
                }
                upsert(soNote);               
            } 
            
            string message = 'Your order was created successfully.\n';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, message);
            ApexPages.addMessage(myMsg);

            // REFRESH THE PAGE
            setupServiceOrder(); 
            
        }
        
        system.debug(' *** EXITING AH_CreateServiceOrder.CreateServiceOrder() - QUERIES ISSUED = ' + Limits.getQueries());
		
        return null;
        
    }
    
    // PASS ServiceOrder ID TO ServiceOrderProcessor METHOD TO SEND THE ODER TO SALESFORCE
    public PageReference sendOrder()
    {
        
        system.debug(' *** ENTERING AH_CreateServiceOrder.sendOrder() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // UPDATED AS PER THE NEW VERSION 2.0 ON 12/13/2018 
        List<CHANNEL_ORDERS.COA_ServiceOrderSubmit.COA_ServiceOrderSubmitInput> serviceOrderSubmitInput = new List<CHANNEL_ORDERS.COA_ServiceOrderSubmit.COA_ServiceOrderSubmitInput>();
        
        CHANNEL_ORDERS.COA_ServiceOrderSubmit.COA_ServiceOrderSubmitInput input = new CHANNEL_ORDERS.COA_ServiceOrderSubmit.COA_ServiceOrderSubmitInput();
        input.serviceOrderId = so.Id;
        serviceOrderSubmitInput.add(input);
        
        List<CHANNEL_ORDERS.COA_ServiceOrderSubmit.COA_ServiceOrderSubmitOutput> serviceOrderSubmitOutputs = CHANNEL_ORDERS.COA_ServiceOrderSubmit.submit(serviceOrderSubmitInput);
        
        for (CHANNEL_ORDERS.COA_ServiceOrderSubmit.COA_ServiceOrderSubmitOutput serviceOrderSubmitOutput: serviceOrderSubmitOutputs)
        {
            
            system.debug(' **** serviceOrderSubmitOutput : ' + serviceOrderSubmitOutput);
            system.debug(' **** Service Order Id: ' + serviceOrderSubmitOutput.serviceOrderId);
            system.debug(' **** Success?: ' + serviceOrderSubmitOutput.isSuccess);             
            system.debug(' **** Response Messages: ' + serviceOrderSubmitOutput.responseMessages);
            
            String message = String.valueOf(serviceOrderSubmitOutput.responseMessages);
            message = message.removeStart('(');
            message = message.removeEnd(')');

            if (serviceOrderSubmitOutput.isSuccess == true)
            {
                // 2019-01-18 (START)
                so.CHANNEL_ORDERS__Service_Order_Status__c = 'Received';
                so.CHANNEL_ORDERS__Date_Service_Order_Received_by_SFDC__c = DateTime.Now();
                update so;
                // 2019-01-18 (END)
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, message);
            	ApexPages.addMessage(myMsg);
            }
            else 
            {
                if (serviceOrderSubmitOutput.isSuccess == false)
                {
                    // 2019-01-18 (START)
                    so.CHANNEL_ORDERS__Service_Order_Status__c = 'Error';
                    update so;
                    // 2019-01-18 (END)
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, message);
                    ApexPages.addMessage(myMsg);
                }
            }
        }
        
        system.debug(' *** EXITING AH_CreateServiceOrder.sendOrder() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return null;
        
    }

    public boolean bCreateServiceOrder(List<subscriptionActivation> saItems, Opportunity oppty) 
    {
		
        system.debug(' *** ENTERING AH_CreateServiceOrder.bCreateServiceOrder() - QUERIES ISSUED = ' + Limits.getQueries());
		
        // CREATES THE ORDER   
        // CHECKS TO MAKE SURE THE ORG EXISTS
        // CHECKS TO MAKE SURE THE PRODUCT HAS A MATCHING SFDC PRODUCT
        // IF USER CHOOSES NOT TO ORDER THE ENTIRE QUANTITY, CREATES A NEW LINE ITEM WITH THE REMAINDER 
        
        // RETRIEVE SELECTED ORG DETAILS RECORD
        products = '';
        NI_Org_Details__c orgForOrder = [SELECT Org_ID__c, Org_Status__c, Inactive__c, Cancellation_Date__c, License_Type__c 
                                         FROM NI_Org_Details__c 
                                         WHERE Org_ID__c =: selectedOrg LIMIT 1];
        
        List<NI_Org_Details__c> accountOrgs = [SELECT Org_Name__c, Org_ID__c 
                                               FROM NI_Org_Details__c 
                                               WHERE NI_Org_Details__c.ORg_Id__c =: selectedOrg 
                                               AND Id IN (SELECT NI_Org_Details_To_Accounts__c.NIOrgDetailsId__c 
                                                          FROM NI_Org_Details_To_Accounts__c 
                                                          WHERE AccountID__c =: oppty.AccountId)];
        
        List<CHANNEL_ORDERS__Service_Order__c> serviceOrdersList = new List<CHANNEL_ORDERS__Service_Order__c>();
        serviceOrdersList = [SELECT Id, CHANNEL_ORDERS__Order_Type__c, CHANNEL_ORDERS__Customer_Org_ID__c
                             FROM CHANNEL_ORDERS__Service_Order__c
                             WHERE CHANNEL_ORDERS__Order_Type__c = 'Initial'
                             AND CHANNEL_ORDERS__Customer_Org_ID__c = :orgForOrder.Org_ID__c];
        
        // THERE IS NO ORG DETAILS RECORD 
        if (accountOrgs.IsEmpty())
        {
            NI_Org_Details_to_Accounts__c newOrgDetailToAccount = new NI_Org_Details_to_Accounts__c();
            newOrgDetailToAccount.AccountID__c = oppty.AccountId;
            newOrgDetailToAccount.NiOrgDetailsID__c = orgForOrder.Id;
            insert newOrgDetailToAccount;
        }
        
        // CHECK FOR CANCELLATION
        if (orgForOrder.Cancellation_Date__c != null)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'This Org has been cancelled.');
            ApexPages.addMessage(myMsg);
            return false;
        }         
        
        // IF IT'S ALREADY PROVISIONED, DON'T ALLOW AN INITIAL ORDER
        if (selectedOrderType == 'Initial' && orgForOrder.Org_Status__c == 'Provisioned')
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'This org has already been provisioned, please change the order type to Add-On.');
            ApexPages.addMessage(myMsg);
            return false;
        }
        
        if (selectedOrderType == 'Add-On' && orgForOrder.Org_Status__c != 'Provisioned')
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'This org has not yet been provisioned, please change the order type to Initial.');
            ApexPages.addMessage(myMsg);
            return false;
        }
        
        if (selectedOrderType == 'Initial' && serviceOrdersList.size() >0)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'There is an existing Initial for this org, please select Add-On.');
            ApexPages.addMessage(myMsg);
            return false;
        }
        
        // THERE IS NO CUSTOMER RECORD
        CHANNEL_ORDERS__Customer__c[] customer = [SELECT Id FROM CHANNEL_ORDERS__Customer__c WHERE CHANNEL_ORDERS__Customer_Org_ID__c =: selectedOrg];
        CHANNEL_ORDERS__Customer__c customerRecord = null;
        
        if (customer.size() == 0)
        {           
            // CREATE A CUSTOMER RECORD
            customerRecord = new CHANNEL_ORDERS__Customer__c(); 
            Account a = [SELECT Name, BillingCity, BillingCountry, Billingstate, BillingStreet, BillingPostalCode FROM ACCOUNT WHERE Id =: oppty.AccountId];
            
            customerRecord.CHANNEL_ORDERS__Customer_Company_Name__c = a.Name; 
            customerRecord.CHANNEL_ORDERS__Customer_City__c = String.isNotBlank(a.BillingCity) ? a.BillingCity : '.'; 
            customerRecord.CHANNEL_ORDERS__Customer_Country__c = String.isNotBlank(a.BillingCity) ? a.BillingCountry : '.'; 
            customerRecord.CHANNEL_ORDERS__Customer_Org_ID__c = selectedOrg; 
            customerRecord.CHANNEL_ORDERS__Customer_State__c = String.isNotBlank(a.BillingState) ? a.BillingState : '.';
            customerRecord.CHANNEL_ORDERS__Customer_Street__c = String.isNotBlank(a.BillingStreet) ? a.BillingStreet : '.'; 
            customerRecord.CHANNEL_ORDERS__Customer_ZIP_Postal_Code__c = String.isNotBlank(a.BillingPostalCode) ? a.BillingPostalCode : '.';
            
            insert customerRecord;
            
        } 
        else
        {
            customerRecord = customer[0]; 
        }
        
        // CREATE THE SERVICE ORDER RECORD
        CreateServiceOrderRecord(oppty, customerRecord);
        
        // GET CUSTOM SETTINGS ==========================================================================
        Service_Order_Settings__c soSettings = Service_Order_Settings__c.getValues('AdminLicenseCodes');  
        
        // LICENSE TYPES
        List<String> licenseTypes = soSettings.License_Types__c.Split('\n');
        
        // NUMBER OF CUSTOMER ADMINS
        Decimal numberOfCustomerAdmins = soSettings.Number_of_Customer_Admins__c;
        
        // NUMBER OF PARTNER ADMINS
        Decimal numberOfPartnerAdmins = soSettings.Number_of_Partner_Admins__c;
        
        // LIST OF Subscription_Activation_Transaction__c RECORDS TO INSERT
        List<Subscription_Activation_Transaction__c> lstSubsActTransInserts = new List<Subscription_Activation_Transaction__c>();        
        
        // BOOLEAN SWITCH
        boolean adminsCreated = false;              
        
        // FILL SET WITH ALL SELECTED PARTNER PRODUCT CATALOG IDS
        Set<Id> setPartnerProductCatalogId = new Set<Id>();     
        
        for (subscriptionActivation ppcIds : saItems)
        {
            if (ppcIds.checked == true)
            {
                setPartnerProductCatalogId.Add(ppcIds.PartnerProductCatalogId);
            }
        }
        
        List<CHANNEL_ORDERS__Partner_Product_Catalog__c> lstPartnerProductCatalog = new List<CHANNEL_ORDERS__Partner_Product_Catalog__c>(
            [SELECT Id, Name, CHANNEL_ORDERS__Billing_Frequency__c, CHANNEL_ORDERS__Contract_Auto_Renew__c, 
             CHANNEL_ORDERS__Contract_Length__c, CHANNEL_ORDERS__Pricing_Type__c, CHANNEL_ORDERS__Pricing_Unit__c, 
             CHANNEL_ORDERS__Cancellation_Terms__c, CHANNEL_ORDERS__Renewal_Terms__c, CHANNEL_ORDERS__Partner_Contract_Terms__c, 
             CHANNEL_ORDERS__Product_ID__c, CHANNEL_ORDERS__PNR__c, CHANNEL_ORDERS__Floor_Price__c, CHANNEL_ORDERS__Fixed_Price__c 
             FROM CHANNEL_ORDERS__Partner_Product_Catalog__c 
             WHERE Id IN : setPartnerProductCatalogId]
        );
        
        // LOOP THROUGH ALL PRODUCTS ON VF PAGE
        for (subscriptionActivation p : saItems)
        {
            
            CHANNEL_ORDERS__Partner_Product_Catalog__c partnerItem;
            
            if (p.checked == true)
            {        
                // GET ASSOCIATED CHANNEL_ORDERS__Partner_Product_Catalog__c AND ASSIGN IT TO partnerItem VARIABLE 
                for (CHANNEL_ORDERS__Partner_Product_Catalog__c ppc : lstPartnerProductCatalog)
                {
                    if (p.PartnerProductCatalogId == ppc.Id)
                    {
                        partnerItem = ppc;
                        break;
                    }
                }
                /*
                // CHECK OUT THE LICENSES...AS WE CANNOT MIX LICENSE TYPES
                // IF ITS AN UPGRADE THOUGH, WE DON'T CARE AND WILL UPGRADE THE ORG DETAILS RECORD TO 'MIXED'                
                if (selectedOrderType != 'Upgrade - Partner App' && partnerItem != null && partnerItem.CHANNEL_ORDERS__Pricing_Unit__c == 'User')
                {
                // NEED TO MAKE SURE WE ARE ORDERING FOR THE CORRECT ORG
                for (String licenseType : licenseTypes)
                {
                List<String> licenseInfo = licenseType.Split(',');
                if (orgForOrder.License_Type__c == licenseInfo[0] && !partnerItem.CHANNEL_ORDERS__Product_ID__c.Containsignorecase(licenseInfo[1].trim()))
                {
                delete so;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'This Org has ' + orgForOrder.License_Type__c + ' Licenses, which means you cannot order these licenses for it.');
                ApexPages.addMessage(myMsg);
                return false;
                }
                }
                
                }
                */              
                // DON'T ALLOW AN ORDER OF MORE THAN ARE CONTRACTED
                if (p.quantityToOrder > p.lineItem.Backlog_Quantity__c)
                {
                    delete so;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You can only order ' + p.lineItem.Backlog_Quantity__c.toPlainString() + ' or less of ' + p.lineItem.Product_Name__c);
                    ApexPages.addMessage(myMsg);
                    return false;
                }                
                
                // WE WILL UPDATE THE EXISTING LINE ITEM THAT WE ARE ORDERING FOR WITH THIS AMOUNT
                Decimal amountToUpdate = p.quantityToOrder; 
                
                // IF THIS IS AN EMBEDDED LICENSE, WE NEED TO FIGURE OUT THE CUSTOMER COST
                DatedConversionRate[] conversionRates = [SELECT StartDate, IsoCode, ConversionRate FROM DatedConversionRate WHERE IsoCode =: oppty.currencyisocode ORDER BY StartDate DESC LIMIT 1];
                Decimal unitPrice = 0;
                
                if (p.LineItem.Sales_Prices__c > 0)
                {
                    unitPrice = (p.LineItem.Sales_Prices__c / (conversionRates[0].ConversionRate)) / 12;
                }
                
                // IF THIS IS AN INITIAL ORDER, WE NEED TO ORDER A CUSTOMER ADMIN, AND PARTNER ADMINS
                if (partnerItem != null && partnerItem.CHANNEL_ORDERS__Pricing_Unit__c == 'User' && so.CHANNEL_ORDERS__Order_Type__c == 'Initial' && adminsCreated == false)
                {
                    String customerAdminCode;
                    String partnerAdminCode;
                    
                    if (orgForOrder.License_Type__c == 'EDA') 
                    {
                        customerAdminCode = soSettings.EDA_Customer_Admin__C; 
                        partnerAdminCode = soSettings.EDA_Partner_Admin__C; 
                    }
                    
                    if (orgForOrder.License_Type__c == 'Embedded Plus')
                    {             
                        customerAdminCode = soSettings.Embedded_Plus_Customer_Admin__c;
                        partnerAdminCode = soSettings.Embedded_Plus_Partner_Admin__c;
                    }
                    
                    if (orgForOrder.License_Type__c == 'Embedded')
                    {             
                        customerAdminCode = soSettings.Embedded_Customer_Admin__c;
                        partnerAdminCode = soSettings.Embedded_Partner_Admin__c;
                    }
                    
                    if (orgForOrder.License_Type__c == 'Enterprise')
                    {             
                        customerAdminCode = soSettings.Enterprise_Customer_Admin__c;
                        partnerAdminCode = soSettings.Enterprise_Partner_Admin__c;
                    }
                    
                    if (orgForOrder.License_Type__c == 'Sales Cloud')
                    {             
                        customerAdminCode = soSettings.Sales_Cloud_Customer_Admin__c;
                        partnerAdminCode = soSettings.Sales_Cloud_Partner_Admin__c;
                    }
                    
                    List<String> customerAdminCodes = new List<String>();
                    List<String> partnerAdminCodes = new List<String>();
                    
                    customerAdminCodes = customerAdminCode.split(',');
                    partnerAdminCodes = partnerAdminCode.split(',');
                    
                    // CUSTOMER ADMIN    
                    CHANNEL_ORDERS__Partner_Product_Catalog__c[] customerAdmin = [SELECT Id, Name, CHANNEL_ORDERS__Billing_Frequency__c, CHANNEL_ORDERS__Contract_Auto_Renew__c,
                                                                                  CHANNEL_ORDERS__Contract_Length__c, CHANNEL_ORDERS__Pricing_Type__c, CHANNEL_ORDERS__Pricing_Unit__c,
                                                                                  CHANNEL_ORDERS__Cancellation_Terms__c, CHANNEL_ORDERS__Renewal_Terms__c, CHANNEL_ORDERS__Partner_Contract_Terms__c,
                                                                                  CHANNEL_ORDERS__Product_ID__c, CHANNEL_ORDERS__PNR__c, CHANNEL_ORDERS__Floor_Price__c, CHANNEL_ORDERS__Fixed_Price__c
                                                                                  FROM CHANNEL_ORDERS__Partner_Product_Catalog__c 
                                                                                  WHERE CHANNEL_ORDERS__Product_ID__c IN: customerAdminCodes];
                    //WHERE CHANNEL_ORDERS__Product_ID__c =: customerAdminCode];
                    
                    CreateDetailItem(customerAdmin[0], numberOfCustomerAdmins, unitPrice);
                    
                    p.quantityToOrder = p.quantityToOrder - numberOfCustomerAdmins;
                    
                    // PARTNER ADMINS
                    CHANNEL_ORDERS__Partner_Product_Catalog__c[] partnerAdmin = [SELECT Id, Name, CHANNEL_ORDERS__Billing_Frequency__c, CHANNEL_ORDERS__Contract_Auto_Renew__c,
                                                                                 CHANNEL_ORDERS__Contract_Length__c, CHANNEL_ORDERS__Pricing_Type__c, CHANNEL_ORDERS__Pricing_Unit__c,
                                                                                 CHANNEL_ORDERS__Cancellation_Terms__c, CHANNEL_ORDERS__Renewal_Terms__c, CHANNEL_ORDERS__Partner_Contract_Terms__c,
                                                                                 CHANNEL_ORDERS__Product_ID__c, CHANNEL_ORDERS__PNR__c,CHANNEL_ORDERS__Floor_Price__c,CHANNEL_ORDERS__Fixed_Price__c
                                                                                 FROM CHANNEL_ORDERS__Partner_Product_Catalog__c 
                                                                                 WHERE CHANNEL_ORDERS__Product_ID__c IN: partnerAdminCodes];
                    //WHERE CHANNEL_ORDERS__Product_ID__c =: partnerAdminCode];
                    
                    CreateDetailItem(partnerAdmin[0], numberOfPartnerAdmins, 0);    
                    adminsCreated = true;
                    
                }
                
                //                Decimal numberOfCustomerAdmins = soSettings.Number_of_Customer_Admins__c; 
                
                // CREATE SERVICE ORDER DETAIL ITEM  
                if (p.quantityToOrder > 0)  
                {                    
                    CreateDetailItem(partnerItem, p.quantityToOrder, unitPrice);
                    if (p.lineItem.Product_Name__c != null)
                    {
                        products += p.lineItem.Product_Name__c +'(Quantity:' + p.quantityToOrder+'), ';
                    }
                }    
                
                // CREATE NEW Subscription_Activation_Transaction__c RECORDS
                if (amountToUpdate > 0)
                {
                    Subscription_Activation_Transaction__c sat = new Subscription_Activation_Transaction__c(); 
                    sat.Subscription_Activation_No__c = p.lineItem.Id;
                    sat.Related_Account__c = accId;
                    sat.Quantity__c = amountToUpdate;
                    sat.Date__c = so.CHANNEL_ORDERS__Service_Start_Date__c; 
                    sat.Service_Order__c = so.Id;
                    lstSubsActTransInserts.Add(sat);                  
                }                
                
            }
            
        }
        
        if (products != null && products != '')
        {
            so.Products_Added__c = products.removeEnd(', ');
            update so;
        }
        
        // ONLY ISSUE INSERT IF THERE ARE RECORDS TO INSERT
        if (lstSubsActTransInserts.size() > 0)
        {          
            database.insert(lstSubsActTransInserts);
        }        
        
        system.debug(' *** EXITING AH_CreateServiceOrder.bCreateServiceOrder() - QUERIES ISSUED = ' + Limits.getQueries());
		
        return true;
        
    }   
    
    // NEW FUNCTION
    private void createMissingSubsActRecords(List<OpportunityLineItem> lstOLIs)
    {
        
        system.debug(' *** ENTERING AH_CreateServiceOrder.createMissingSubsActRecords() - QUERIES ISSUED = ' + Limits.getQueries());
		
        // FILL A SET OF OPPORTUNITY LINE ITEM IDS. 
        // USED IN NEXT BLOCK TO QUERY FOR EXISTING Subscription_Activation__c RECORDS HAVING Product_ID__c REFERENCED PREVIOUSLY
        Set<String> setOLIs = new Set<String>();
        for (OpportunityLineItem oli1 : lstOLIs)
        {
            setOLIs.add((String)oli1.Id);
        }        
        
        // FILL A SET OF Product_ID__c VALUES FROM EXISTING Subscription_Activation__c RECORDS
        // USED IN NEXT BLOCK TO DECIDE WHETHER TO CREATE A NEW Subscription_Activation__c OR NOT
        Set<String> setPrd2Ids = new Set<String>();
        for (Subscription_Activation__c sa : [SELECT Id, Product_ID__c 
                                              FROM Subscription_Activation__c 
                                              WHERE Product_ID__c IN : setOLIs])
        {
            setPrd2Ids.add(sa.Product_ID__c);
        }
        
        Set<Id> setOLIs2UpdateSyncedCheckbox = new Set<Id>();
        
        // LIST FOR NEW Subscription_Activation__c TO BE INSERTED
        List<Subscription_Activation__c> lstSAs2Create = new List<Subscription_Activation__c>();
        
        // LOOP THROUGH ALL OpportunityLineItems PASSED IN TO DETECT ABSENCE OF Subscription_Activation__c RECORDS
        for (OpportunityLineItem oli2 : lstOLIs) 
        { 
            // IF THERE ISN'T AN EXISTING Subscription_Activation__c RECORD WITH Product_ID__c OF CURRENT OpportunityLineItem.Id
            // THEN ADD IT TO THE LIST FOR INSERTION 
            if (!setPrd2Ids.contains((String)oli2.Id))
            {
                Subscription_Activation__c newSA = new Subscription_Activation__c();
                newSA.Account__c = oli2.Opportunity.AccountId;
                newSA.Opportunity__c = oli2.OpportunityId;
                newSA.Product_ID__c = oli2.Id;
                newSA.Product_Code__c = oli2.ProductCode;
                newSA.Product_Name__c = oli2.Product2.Name;
                newSA.CurrencyIsoCode = oli2.CurrencyIsoCode;
                newSA.Contracted_Quantity__c = oli2.Quantity;
                newSA.Sales_Prices__c = oli2.UnitPrice;
                newSA.TotalPrice__c = oli2.TotalPrice; 
                lstSAs2Create.add(newSA);
                setOLIs2UpdateSyncedCheckbox.Add(oli2.Id);
            }			
        }
        
        // ONLY ISSUE INSERT IF THERE ARE RECORDS TO INSERT
        if (lstSAs2Create.size() > 0)
        {          
            database.insert(lstSAs2Create);
        }
        
        // UPDATE Synced CHECKBOX ON OPPORTUNITY LINE ITEMS
        List<OpportunityLineItem> lstOLIUpdates = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem oliSyncs : [SELECT Id, Synched__c FROM OpportunityLineItem WHERE Id IN : setOLIs2UpdateSyncedCheckbox])
        {
            oliSyncs.Synched__c = true;
            lstOLIUpdates.add(oliSyncs);
        }
        
        if (lstOLIUpdates.size() > 0)
        {
            database.update(lstOLIUpdates);
        }
        
        system.debug(' *** EXITING AH_CreateServiceOrder.createMissingSubsActRecords() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }
    
    public void CreateDetailItem(CHANNEL_ORDERS__Partner_Product_Catalog__c partnerItem, Decimal quantity, Decimal customerCost)
    {
        
        system.debug(' *** ENTERING AH_CreateServiceOrder.CreateDetailItem() - QUERIES ISSUED = ' + Limits.getQueries());
		
        CHANNEL_ORDERS__Service_Order_Detail__c detailItem = new CHANNEL_ORDERS__Service_Order_Detail__c();
        
        detailItem.CHANNEL_ORDERS__Application__c = 'Hospitality Management';
        detailItem.CHANNEL_ORDERS__Partner_Order__c = so.Id;
        detailItem.CHANNEL_ORDERS__Product_Name__c = partnerItem.Id;
        detailItem.CHANNEL_ORDERS__Quantity__c = quantity;
        
        // ADDITIONAL FIELDS
        Service_Order_Settings__c soSettings = Service_Order_Settings__c.getValues('AdminLicenseCodes');
        
        detailItem.CHANNEL_ORDERS__pc_Billing_Frequency__c = soSettings.Billing_Frequency__c;
        detailItem.CHANNEL_ORDERS__pc_Contract_Auto_Renew__c = partnerItem.CHANNEL_ORDERS__Contract_Auto_Renew__c;
        detailItem.CHANNEL_ORDERS__pc_Contract_Length__c = partnerItem.CHANNEL_ORDERS__Contract_Length__c;
        detailItem.CHANNEL_ORDERS__pc_Pricing_Type__c = partnerItem.CHANNEL_ORDERS__Pricing_Type__c;
        detailItem.CHANNEL_ORDERS__pc_Pricing_Unit__c = partnerItem.CHANNEL_ORDERS__Pricing_Unit__c;
        detailItem.CHANNEL_ORDERS__pc_Cancellation_Terms__c = partnerItem.CHANNEL_ORDERS__Cancellation_Terms__c;
        detailItem.CHANNEL_ORDERS__pc_Renewal_Terms__c = partnerItem.CHANNEL_ORDERS__Renewal_Terms__c;
        detailItem.CHANNEL_ORDERS__pc_Partner_Contract_Term__c = partnerItem.CHANNEL_ORDERS__Partner_Contract_Terms__c;
        detailItem.CHANNEL_ORDERS__pc_Product_ID__c = partnerItem.CHANNEL_ORDERS__Product_ID__c;
        detailItem.CHANNEL_ORDERS__pc_Floor_Price__c = partnerItem.CHANNEL_ORDERS__Floor_Price__c;
        detailItem.CHANNEL_ORDERS__pc_Fixed_Price__c = partnerItem.CHANNEL_ORDERS__Fixed_Price__c;
        detailItem.CHANNEL_ORDERS__pct_Currency__c = 'USD';
        
        if (partnerItem.CHANNEL_ORDERS__PNR__c != null)
        {
            detailItem.CHANNEL_ORDERS__Customer_Price_Per_Month__c = customerCost;
        }
        
        insert detailItem;   
        
        system.debug(' *** EXITING AH_CreateServiceOrder.CreateDetailItem() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }
    
    public void CreateServiceOrderRecord(Opportunity opp, CHANNEL_ORDERS__Customer__c customer) 
    {
		
        system.debug(' *** ENTERING AH_CreateServiceOrder.CreateServiceOrderRecord() - QUERIES ISSUED = ' + Limits.getQueries());
		
        CHANNEL_ORDERS__Partner_Contract_Terms__c partnerContract = [SELECT Id FROM CHANNEL_ORDERS__Partner_Contract_Terms__c WHERE Id =: selectedContract];
        NI_Org_Details__c selectedOrgName = new NI_Org_Details__c();
        Date todaysDate = Date.Today();
        
        so.CHANNEL_ORDERS__Created_with_new_COA__c = true;
        so.CHANNEL_ORDERS__Customer_Org_ID__c = selectedOrg;
        so.CHANNEL_ORDERS__Customer__c = customer.Id;
        so.CHANNEL_ORDERS__I_certify__c = 'Yes';
        so.CHANNEL_ORDERS__Partner_Contract_Rules__c = partnerContract.Id;
        so.CHANNEL_ORDERS__Related_Opportunity__c = oppty.Id;
        
        if (so.Channel_Orders__Service_start_Date__c == null)
        {
            so.CHANNEL_ORDERS__Service_Start_Date__c = todaysDate;
        }
        
        so.Account__c = opp.AccountId;
        so.CHANNEL_ORDERS__Order_Type__c = selectedOrderType;
        so.CHANNEL_ORDERS__Service_Order_Status__c = 'Draft';
        so.Opportunity_Contact_Email__c = oppContact.Contact.Email;
        
        if (SelectedOrg != null)
        {
            selectedOrgName = [SELECT Id, Org_ID__c, Org_Name__c
                               FROM NI_Org_Details__c 
                               WHERE Org_ID__c =: SelectedOrg 
                               LIMIT 1];
            so.Org_Name__c = selectedOrgName.Org_Name__c;
        }
        
        // so.Org_Name__c = opp.Target_HRM_Org_Name__c;
        so.Opportunity_Contact_First_Name__c = oppContact.Contact.FirstName;
        so.Opportunity_Owner__c = opp.Owner.Name;
        
        // so.Products_Added__c = '';
        if (additionalToEmail != '' && additionalToEmail != null)
        {
            so.Additional_To_Email__c = additionalToEmail;
        }
        
        // so.Products_Added__c = products;	
        so.Notify_Opportunity_Contact__c = notifyOppContact;
        if (acc.Id != null)
        {
            so.Service_Order_Target_Account__c = acc.Id;
        }
            
        insert so;
        
        //CHANNEL_ORDERS.ServiceOrderProcessor.sendOrder(so.Id);
        
        system.debug(' *** ENTERING AH_CreateServiceOrder.CreateServiceOrderRecord() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }    
    
    private boolean noProductsChecked(List<subscriptionActivation> lst)
    {
        boolean bRetVal = true;
        
        for (subscriptionActivation sa : lst)
        {
            if (sa.checked)
            {
                bRetVal = false;
            }
        }
        
        return bRetVal;
    }
    
    // INNER CLASS THAT REPRESENTS PRODUCTS THAT ARE SELECTED FOR ORDER
    public class subscriptionActivation
    {
        
        public Subscription_Activation__c lineItem {get; set;}
        public Boolean checked {get; set;}
        public Decimal quantityToOrder {get; set;}
        //		public Decimal OrderOfDelivery {get; set;}
        public Id PartnerProductCatalogId {get; set;}
        
        public subscriptionActivation(Subscription_Activation__c m, Boolean s, Decimal q, Id i)
        {
            this.lineItem = m; 
            this.checked = s; 
            this.quantityToOrder = q; 
            this.PartnerProductCatalogId = i;
        }
        
    }
    
}