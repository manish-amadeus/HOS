/****************************************************************************************
Name            : NI_CreateServiceOrder Class 
Author          : Suzanne LeDuc
Created Date    : 1/4/2015
Last Mod Date   : 7/22/2014
Last Mod By     : Stuart Emery
NICC Reference  : NICC-010386
Description     : Class for creating a Service Order  
: 
: 
******************************************************************************************/
public class NI_CreateServiceOrder
{
    //Represents Products that are selected for order
    public class selectedProducts
    {
        public OpportunityLineItem lineItem  {get; set;}
        public Boolean checked{get; set;}
        public Decimal quantityToOrder{get;set;}
        
        
        public selectedProducts(OpportunityLineItem m,Boolean s )
        {
            lineItem = m;
            checked = s;
            quantityToOrder = m.Quantity;
            
        }
    }
    
    //Global Variables
    private Opportunity opportunity;
    List<selectedProducts> products = new List<selectedProducts>();
    List<selectOption> contractOptions = new List<selectOption>(); 
    List<selectOption> orderTypeOptions = new List<selectOption>(); 
    public string selectedContract;
    List<selectOption> orgOptions = new List<selectOption>();
    public string selectedOrg;
    public CHANNEL_ORDERS__Service_Order__c serviceOrder;
    public Boolean disableCreateButton {get;set;}
    public Note soNote {get;set;}
    
    
    public void setserviceOrder( CHANNEL_ORDERS__Service_Order__c value )
    {
        serviceOrder = value;
    }
    
    public CHANNEL_ORDERS__Service_Order__c getserviceOrder()
    {
        return serviceOrder;
    }
    
    public string selectedOrderType;
    public string getSelectedOrderType()
    {
        return selectedOrderType;
    }
    
    public void setSelectedOrderType( string orderType )
    {
        selectedOrderType = orderType;
        
    }
    
    
    
    public void setServiceOrderStartDate( Date value )
    {
        serviceOrder.CHANNEL_ORDERS__Service_Start_Date__c = value;
    }
    public Date getServiceOrderStartDate()
    {
        return serviceOrder.CHANNEL_ORDERS__Service_Start_Date__c;
        
    }
    
    public void setServiceOrderNIDate( Date value )
    {
        serviceOrder.CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c = value;
    }
    
    public Date getServiceOrderNIDate()
    {
        return serviceOrder.CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c;
    }
    
    public void setServiceOrderCustDate( Date value )
    {
        serviceOrder.CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = value;
    }
    
    
    public Date getServiceOrderCustDate( )
    {
        return serviceOrder.CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c;
    }
    
    
    public void setServiceOrderCase( Id value )
    {
        serviceOrder.Case__c = value;
    }
    
    public Id getServiceOrderCase( )
    {
        return serviceOrder.Case__c;
    }
    
    public string getSelectedOrg()
    {
        return selectedOrg;
    }
    
    public void setSelectedOrg( string orgId )
    {
        selectedOrg = orgId;
    }
    
    public string getSelectedContract()
    {
        return selectedContract;
    }
    
    public void setSelectedContract( string contract )
    {
        selectedContract = contract;
    }
    
    public List<selectedProducts> getProducts()
    {
        return products;
    }
    
    public Opportunity getOpportunity()
    {
        return opportunity;
    }
    
    public List<selectOption> getContractOptions()
    {
        contractOptions.clear();
        Service_Order_Settings__c soSettings = Service_Order_Settings__c.getValues('AdminLicenseCodes');
        String defaultContractId = '';
        
        
        for (CHANNEL_ORDERS__Partner_Contract_Terms__c terms : [Select Name, Id From CHANNEL_ORDERS__Partner_Contract_Terms__c Where CHANNEL_ORDERS__Partner_Contract_Terms__c.Active__c = true ORDER BY Name ] ) { 
            contractOptions.add(  new SelectOption(  terms.Id,terms.Name )   ); 
            
            if( terms.Name == soSettings.Default_Contract__c)
                defaultContractId = terms.Id;
        }
        
        selectedContract = defaultContractId;
        return contractOptions; //return the picklist options
    }
    
    public List<selectOption> getOrderTypeOptions()
    {
        orderTypeOptions.clear();
        orderTypeOptions.add(  new SelectOption(  'Add-On','Add-On' )   ); 
        orderTypeOptions.add(  new SelectOption(  'Initial','Initial' )   ); 
        orderTypeOptions.add(  new SelectOption(  'Upgrade - Partner App','Upgrade - Partner App' )   ); 
        
        
        return orderTypeOptions; //return the picklist options
    }
    
    public List<selectOption> getOrgOptions()
    {
        
        orgOptions.clear(); //CLEAR THE ORGOPTIONS LIST
        //orgOptions.add( new SelectOption( '0','Please Select'));
        
        //IF the target HRM has been selected, only allow that in the list
        System.Debug( 'Target HRM ' + Opportunity.Target_HRM_ORg__c );
        if( opportunity.Target_HRM_Org__c != null )
        {
            for (NI_Org_Details__c orgs : [Select Org_Name__c, Org_ID__c From NI_Org_Details__c WHERE Id = :opportunity.Target_HRM_Org__c ] ) { 
                orgOptions.add(  new SelectOption(  orgs.Org_ID__c,orgs.Org_Name__c )   ); 
                
            }
        }
        else
        {  //Org details records associated with the account
            
            List<NI_Org_Details__c> orgs = [Select Org_Name__c, Org_ID__c From NI_Org_Details__c WHERE NI_Org_Details__c.Inactive__c = false and NI_Org_Details__c.Cancellation_Date__c = null and NI_Org_Details__c.ORg_Id__c <> null and Org_Name__c <> null and Id in ( Select NI_Org_Details_To_Accounts__c.NIOrgDetailsId__c from NI_Org_Details_To_Accounts__c Where AccountID__C = :opportunity.accountid) ];       
            System.Debug( 'Org Options: Org Details size ' + orgs.size() );
            if( !orgs.isEmpty() )  
            {
                for (NI_Org_Details__C o : orgs ) { 
                    orgOptions.add(  new SelectOption(  o.Org_ID__c,o.Org_Name__c )   ); 
                    
                }
            }
            else
            {  //All Org Details Records
                for (NI_Org_Details__c allorgs : [Select Org_Name__c, Org_ID__c From NI_Org_Details__c WHERE Org_ID__c <> null AND Org_Name__c <> null and Inactive__c = false ORDER BY Org_Name__c ] ) { 
                    orgOptions.add(  new SelectOption(  allorgs.Org_ID__c, allorgs.Org_Name__c )   ); 
                    
                }
            }
        }
        
        return orgOptions; //return the picklist options
    }
    
    
    //Constructor
    //Sets up the Apex Page with products to order and matching Org
    public NI_CreateServiceOrder(){
        
        setupServiceOrder();
        
    }
    
    public void setupServiceOrder()
    {
        serviceOrder = new CHANNEL_ORDERS__Service_Order__c();
        
        serviceOrder.CHANNEL_ORDERS__Service_Start_Date__c = Date.Today();
        disableCreateButton = false;
        String oppId = ApexPages.currentPage().getParameters().get('OppId');
        
        opportunity = [ Select Name, Opportunity_Number__c,AccountId,OwnerID, CloseDate, currencyisocode,Target_HRM_Org__C,
                       
                       (SELECT op.Id, op.Quantity, op.UnitPrice, op.TotalPrice,  op.ServiceDate, op.LOD_Licensed_Property__c, op.Service_Order__c,
                        op.PricebookEntry.Name, op.OpportunityId, op.PricebookEntry.ProductCode,op.Release_Date__c,op.Deferred__c,          
                        op.PricebookEntry.Product2.Family,op.CurrencyIsoCode,op.Discount__c, op.Family__c,op.LineType__c,op.ListPrice, op.PricebookEntryId
                        FROM OpportunityLineItems op)
                       FROM Opportunity Where Id = :oppId ];                
        
        
        
        for (OpportunityLineItem o : [SELECT  Id, Quantity, Remaining_to_Order__c, UnitPrice, PricebookEntry.Product2.Name, Product2.Partner_Product_Catalog__c, Service_Order__c FROM OpportunityLineItem WHERE OpportunityId = :opportunity.Id and Product2.Partner_Product_Catalog__c != NULL and Service_Order__c = NULL ]) {
            
            selectedProducts product = new selectedProducts(o,true);
            products.add(product);
            
        }
        
        soNote = new Note();
        
    }
    
    
    //Command Button
    //Calls the create service order method
    public void CreateServiceOrder() {
        
        if( CreateServiceOrder( products, opportunity) != false ) 
        {
            //Save the note
            System.Debug( 'note body ' + soNote.Body);
            if( !String.isBlank(soNote.Body) )
            {
                soNote.ParentId = serviceOrder.Id;
                if( soNote.Body.length() > 20 )
                    soNote.Title = soNote.Body.substring(0,20);
                else
                    soNote.Title = soNote.Body;
                
                upsert( soNote );
            }
            
            
            
            
            string message = 'Your order was created successfully.\n';
            ApexPages.Message myMsg = new ApexPages.Message( ApexPages.Severity.INFO, message );
            ApexPages.addMessage(myMsg);
            disableCreateButton = true;
        }
        
    }
    
    //Creates the Order   
    //Checks to make sure the Org exists
    //Checks to make sure the product has a matching SFDC product
    //If user chooses not to order the entire quantity, creates a new line item with the remainder
    public boolean CreateServiceOrder( List<selectedProducts> products, Opportunity opportunity) 
    {
        
        NI_Org_Details__c orgForOrder = [SELECT Org_ID__c,Org_Status__c,Inactive__c,Cancellation_Date__c,License_Type__c FROM NI_Org_Details__c WHERE  Org_ID__c = :selectedOrg LIMIT 1];
        System.Debug( 'Selected org ' +  selectedOrg );
        
        Account accountRecord = [SELECT Name, Id from ACCOUNT Where Id = :opportunity.AccountId LIMIT 1]; 
        List<NI_Org_Details__c> accountOrgs = [Select Org_Name__c, Org_ID__c From NI_Org_Details__c WHERE NI_Org_Details__c.ORg_Id__c = :selectedOrg and Id in ( Select NI_Org_Details_To_Accounts__c.NIOrgDetailsId__c from NI_Org_Details_To_Accounts__c Where AccountID__C = :opportunity.accountid) ];       
        
        
        //There is no Org Details Record 
        System.Debug( 'Account ' + accountRecord.Name );
        if( accountOrgs.IsEmpty() )
        {
            NI_Org_Details_to_Accounts__c newOrgDetailToAccount = new NI_Org_Details_to_Accounts__c();
            newOrgDetailToAccount.AccountID__c = opportunity.AccountId;
            newOrgDetailToAccount.NiOrgDetailsID__c = orgForOrder.Id;
            insert newOrgDetailToAccount;
        }
        
        
        //Check for cancellation
        if( orgForOrder.Cancellation_Date__c != NULL )
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'This Org has been cancelled.');
            ApexPages.addMessage(myMsg);
            disableCreateButton = true;
            return false;
        } 
        
        //If it's already provisioned, don't allow an initial order
        System.Debug('Order Type ' + serviceOrder.CHANNEL_ORDERS__Order_Type__c);
        System.Debug('org Status ' + orgForOrder.Org_Status__c);
        if( selectedOrderType == 'Initial' && orgForOrder.Org_Status__c == 'Provisioned' )
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'This org has already been provisioned, please change the order type to Add-On.');
            ApexPages.addMessage(myMsg);
            return false;
        }
        
        if( selectedOrderType == 'Add-On' && orgForOrder.Org_Status__c != 'Provisioned' )
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'This org has not yet been provisioned, please change the order type to Initial.');
            ApexPages.addMessage(myMsg);
            return false;
        }
        
        //There is no customer record
        CHANNEL_ORDERS__Customer__c[] customer = [SELECT Id FROM  CHANNEL_ORDERS__Customer__c WHERE CHANNEL_ORDERS__Customer_Org_ID__c = :selectedOrg];
        CHANNEL_ORDERS__Customer__c customerRecord = null;
        if( customer.size() == 0 )
        {
            
            //Create a customer record
            customerRecord = new CHANNEL_ORDERS__Customer__c(); 
            Account a = [Select Name, BillingCity, BillingCountry, Billingstate, BillingStreet, BillingPostalCode FROM ACCOUNT where Id = :opportunity.AccountId];
            
            customerRecord.CHANNEL_ORDERS__Customer_Company_Name__c = a.Name; 
            customerRecord.CHANNEL_ORDERS__Customer_City__c = String.isNotBlank(a.BillingCity) ? a.BillingCity : '.'; 
            customerRecord.CHANNEL_ORDERS__Customer_Country__c =String.isNotBlank(a.BillingCity) ? a.BillingCountry : '.'; 
            customerRecord.CHANNEL_ORDERS__Customer_Org_ID__c = selectedOrg; 
            customerRecord.CHANNEL_ORDERS__Customer_State__c = String.isNotBlank(a.BillingState) ? a.BillingState : '.';
            customerRecord.CHANNEL_ORDERS__Customer_Street__c = String.isNotBlank(a.BillingStreet) ? a.BillingStreet : '.'; 
            customerRecord.CHANNEL_ORDERS__Customer_ZIP_Postal_Code__c = String.isNotBlank( a.BillingPostalCode) ? a.BillingPostalCode : '.';
            
            System.Debug('Inserting Customer Record');
            insert customerRecord;
            
            System.Debug('customer record ' + customerRecord.Id);
            
        } 
        else
        {
            customerRecord = customer[0]; 
        }
        
        //Create the Service Order Record
        CreateServiceOrderRecord( opportunity,  customerRecord );
        
        boolean adminsCreated = false;
        Service_Order_Settings__c soSettings = Service_Order_Settings__c.getValues('AdminLicenseCodes');
        
        
        for(selectedProducts p: products){
            if( p.checked == true )
            {    
                CHANNEL_ORDERS__Partner_Product_Catalog__c[] partnerItem = [SELECT Id, Name,CHANNEL_ORDERS__Billing_Frequency__c,CHANNEL_ORDERS__Contract_Auto_Renew__c,
                                                                            CHANNEL_ORDERS__Contract_Length__c,CHANNEL_ORDERS__Pricing_Type__c,CHANNEL_ORDERS__Pricing_Unit__c,
                                                                            CHANNEL_ORDERS__Cancellation_Terms__c,CHANNEL_ORDERS__Renewal_Terms__c,CHANNEL_ORDERS__Partner_Contract_Terms__c,
                                                                            CHANNEL_ORDERS__Product_ID__c,CHANNEL_ORDERS__PNR__c,CHANNEL_ORDERS__Floor_Price__c,CHANNEL_ORDERS__Fixed_Price__c
                                                                            from CHANNEL_ORDERS__Partner_Product_Catalog__c where Id = :p.lineItem.Product2.Partner_Product_Catalog__c];
                
                
                
                
                
                
                //Lets check out the licenses...as we cannot mix license types
                //If its an upgrade though, we don't care and will upgrade the org Details record to 'Mixed'
                
                System.Debug('selected order type: '  + selectedOrderType );
                System.Debug('PartnerItemSize: ' +partnerItem.Size() );
                if( partnerItem.size() > 0 )
                    System.Debug('Pricing Unit: '  + partnerItem[0].CHANNEL_ORDERS__Pricing_Unit__c);
                
                if( selectedOrderType != 'Upgrade - Partner App' && partnerItem.size() > 0 && partnerItem[0].CHANNEL_ORDERS__Pricing_Unit__c == 'User')
                {
                    System.Debug('Checking Licenses');
                    //Need to make sure we are ordering for the correct org
                    //Get the license Types
                    List<String> licenseTypes = soSettings.License_Types__c.Split('\n');
                    for( String licenseType: licenseTypes )
                    {
                        List<String> licenseInfo = licenseType.Split(',');
                        if( orgForOrder.License_Type__c == licenseInfo[0] && !partnerItem[0].CHANNEL_ORDERS__Product_ID__c.Containsignorecase( licenseInfo[1].trim())  )
                        {
                            delete serviceOrder;
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'This Org has ' + orgForOrder.License_Type__c +' Licenses, which means you cannot order these licenses for it.');
                            ApexPages.addMessage(myMsg);
                            disableCreateButton = true;
                            return false;
                        }
                    }
                    
                }
                
                //Don't allow an order of more than are contracted
                if( p.quantityToOrder > p.lineItem.Quantity )
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You can only order ' + p.lineItem.Quantity.toPlainString()+ ' or less of ' + p.lineItem.PricebookEntry.Product2.Name );
                    ApexPages.addMessage(myMsg);
                    disableCreateButton = true;
                    delete serviceOrder;
                    return false;
                }
                
                
                //We will create a new lineitem for this amount
                Decimal remainingToOrder = p.lineItem.Quantity - p.quantityToOrder;
                //We will update the existing line item that we are ordering for with this amount
                Decimal amountToUpdate = p.quantityToOrder;
                
                
                System.Debug(' iso ' + Opportunity.currencyisoCode );
                //If this is an embedded license, we need to figure out the customer cost
                DatedConversionRate[] conversionRates = [SELECT StartDate, IsoCode, ConversionRate FROM DatedConversionRate WHERE IsoCode = :Opportunity.currencyisocode ORDER BY StartDate DESC LIMIT 1];
                Decimal unitPrice = 0;
                
                if( p.LineItem.UnitPrice > 0 )
                    unitPrice = (p.LineItem.UnitPrice/(conversionRates[0].ConversionRate))/12;
                
                
                System.Debug( 'Unit Price ' + unitPrice );
                System.Debug( 'Line Item unit price ' + p.LineItem.UnitPrice );
                System.Debug( 'Conversion Rate ' + conversionRates[0].ConversionRate );
                
                System.Debug( 'Partner Item ' + partnerItem.size() );
                //If this is an initial order, we need to order a customer admin, and partner admins
                if( partnerItem.size() > 0 && partnerItem[0].CHANNEL_ORDERS__Pricing_Unit__c == 'User' && serviceOrder.CHANNEL_ORDERS__Order_Type__c == 'Initial' && adminsCreated == false )
                {
                    
                    String customerAdminCode;
                    String partnerAdminCode;
                    Decimal numberOfCustomerAdmins = soSettings.Number_of_Customer_Admins__c;
                    Decimal numberOfPartnerAdmins = soSettings.Number_of_Partner_Admins__c;
                    
                    if( orgForOrder.License_Type__c == 'Embedded Plus' )
                    {             
                        customerAdminCode = soSettings.Embedded_Plus_Customer_Admin__c;
                        partnerAdminCode = soSettings.Embedded_Plus_Partner_Admin__c;
                    }
                    
                    
                    if( orgForOrder.License_Type__c == 'Embedded' )
                    {             
                        customerAdminCode = soSettings.Embedded_Customer_Admin__c;
                        partnerAdminCode = soSettings.Embedded_Partner_Admin__c;
                    }
                    
                    if( orgForOrder.License_Type__c == 'Enterprise' )
                    {             
                        customerAdminCode = soSettings.Enterprise_Customer_Admin__c;
                        partnerAdminCode = soSettings.Enterprise_Partner_Admin__c;
                    }
                    
                    if( orgForOrder.License_Type__c == 'Sales Cloud' )
                    {             
                        customerAdminCode = soSettings.Sales_Cloud_Customer_Admin__c;
                        partnerAdminCode = soSettings.Sales_Cloud_Partner_Admin__c;
                    }
                    
                    if (orgForOrder.License_Type__c == 'EDA')
                    {             
                        customerAdminCode = soSettings.EDA_Customer_Admin__c;
                        partnerAdminCode = soSettings.EDA_Partner_Admin__c;
                    }
                    
                    
                    //Customer Admin    
                    CHANNEL_ORDERS__Partner_Product_Catalog__c[] customerAdmin = [SELECT Id, Name,CHANNEL_ORDERS__Billing_Frequency__c,CHANNEL_ORDERS__Contract_Auto_Renew__c,
                                                                                  CHANNEL_ORDERS__Contract_Length__c,CHANNEL_ORDERS__Pricing_Type__c,CHANNEL_ORDERS__Pricing_Unit__c,
                                                                                  CHANNEL_ORDERS__Cancellation_Terms__c,CHANNEL_ORDERS__Renewal_Terms__c,CHANNEL_ORDERS__Partner_Contract_Terms__c,
                                                                                  CHANNEL_ORDERS__Product_ID__c,CHANNEL_ORDERS__PNR__c,CHANNEL_ORDERS__Floor_Price__c,CHANNEL_ORDERS__Fixed_Price__c
                                                                                  from CHANNEL_ORDERS__Partner_Product_Catalog__c 
                                                                                  WHERE  CHANNEL_ORDERS__Product_ID__c  = :customerAdminCode];
                    
                    System.Debug( 'Customer Admin Size ' + customerAdmin.size() );
                    
                    CreateDetailItem( customerAdmin[0], numberOfCustomerAdmins, unitPrice );
                    
                    p.quantityToOrder = p.quantityToOrder - numberOfCustomerAdmins;
                    
                    
                    //Partner Admins
                    CHANNEL_ORDERS__Partner_Product_Catalog__c[] partnerAdmin = [SELECT Id, Name,CHANNEL_ORDERS__Billing_Frequency__c,CHANNEL_ORDERS__Contract_Auto_Renew__c,
                                                                                 CHANNEL_ORDERS__Contract_Length__c,CHANNEL_ORDERS__Pricing_Type__c,CHANNEL_ORDERS__Pricing_Unit__c,
                                                                                 CHANNEL_ORDERS__Cancellation_Terms__c,CHANNEL_ORDERS__Renewal_Terms__c,CHANNEL_ORDERS__Partner_Contract_Terms__c,
                                                                                 CHANNEL_ORDERS__Product_ID__c,CHANNEL_ORDERS__PNR__c,CHANNEL_ORDERS__Floor_Price__c,CHANNEL_ORDERS__Fixed_Price__c
                                                                                 from CHANNEL_ORDERS__Partner_Product_Catalog__c where  CHANNEL_ORDERS__Product_ID__c  = :partnerAdminCode];
                    
                    CreateDetailItem( partnerAdmin[0], numberOfPartnerAdmins, 0 );    
                    adminsCreated = true;
                }
                
                
                Decimal numberOfCustomerAdmins = soSettings.Number_of_Customer_Admins__c; 
                //Create Service Order Detail Item  
                if( p.quantityToOrder > 0 )  
                {                    
                    CreateDetailItem(partnerItem[0], p.quantityToOrder, unitPrice);
                }    
                
                //Update opportunity line Item
                
                p.lineItem.Service_Order__c = serviceOrder.Id;
                p.lineItem.LOD_Licensed_Property__c = opportunity.AccountId;
                
                p.lineItem.Quantity = amounttoUpdate;   
                upsert p.lineItem;
                
                
                
                
                //Create new Opportunity Line Item
                if( remainingToOrder > 0 )
                {
                    p.lineItem.Quantity = p.quantityToOrder;
                    CreateLineItem( p.lineItem, remainingToOrder);
                }
                
                
            }
        }
        return true;
    }
    
    
    public void CreateDetailItem(CHANNEL_ORDERS__Partner_Product_Catalog__c partnerItem, Decimal quantity, Decimal customerCost)
    {
        
        CHANNEL_ORDERS__Service_Order_Detail__c detailItem = new CHANNEL_ORDERS__Service_Order_Detail__c();
        
        detailItem.CHANNEL_ORDERS__Application__c = 'Hospitality Management';
        detailItem.CHANNEL_ORDERS__Partner_Order__c = serviceOrder.Id;
        detailItem.CHANNEL_ORDERS__Product_Name__c = partnerItem.Id;
        detailItem.CHANNEL_ORDERS__Quantity__c = quantity;
        
        //additional fields
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
        
        if( partnerItem.CHANNEL_ORDERS__PNR__c != null )
            detailItem.CHANNEL_ORDERS__Customer_Price_Per_Month__c = customerCost;
        
        insert detailItem;   
        
    }
    
    public void CreateServiceOrderRecord(Opportunity opportunity,  CHANNEL_ORDERS__Customer__c customer) 
    {
        
        
        CHANNEL_ORDERS__Partner_Contract_Terms__c partnerContract = [ SELECT Id FROM CHANNEL_ORDERS__Partner_Contract_Terms__c WHERE Id = :selectedContract ];
        
        
        date todaysDate = Date.Today();
        
        serviceOrder.CHANNEL_ORDERS__Created_with_new_COA__c = True;
        serviceOrder.CHANNEL_ORDERS__Customer_Org_ID__c = selectedOrg;
        serviceOrder.CHANNEL_ORDERS__Customer__c = customer.Id;
        serviceOrder.CHANNEL_ORDERS__I_certify__c = 'Yes';
        serviceOrder.CHANNEL_ORDERS__Partner_Contract_Rules__c = partnerContract.Id;
        serviceOrder.CHANNEL_ORDERS__Related_Opportunity__c = opportunity.Id;
        if( serviceOrder.Channel_Orders__Service_start_Date__C == NULL )
            serviceOrder.CHANNEL_ORDERS__Service_Start_Date__c = todaysDate;
        serviceOrder.Account__C = opportunity.AccountId;
        serviceOrder.CHANNEL_ORDERS__Order_Type__c = selectedOrderType;
        insert serviceOrder;
    }
    
    
    public void CreateLineItem( OpportunityLineItem itemToCopy, Decimal quantity )
    {
        OpportunityLineItem lineItem = new OpportunityLineItem();
        
        try
        {
            lineItem.Quantity = quantity;
            lineItem.UnitPrice = itemToCopy.UnitPrice;
            lineItem.OpportunityId = opportunity.Id;
            lineItem.Description = itemToCopy.Description;
            lineItem.PricebookEntryId = itemToCopy.PricebookEntryId;
            lineItem.Release_Date__c = itemToCopy.Release_Date__c;
            // lineItem.TotalPrice = quantity*itemToCopy.UnitPrice;
            
            insert lineItem;
            
        }
        catch (Exception e) {
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'The following exception has occurred: ' + e.getmessage() );
            ApexPages.addMessage(myMsg);
            
            
        }
        
        
        
    }
    
}