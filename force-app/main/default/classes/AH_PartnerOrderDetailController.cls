/****************************************************************************************
Name            : AH_PartnerOrderDetailController Class
Author          : Suzanne LeDuc
Created Date    : 08/07/2017
Last Mod Date   : 04/13/2018
Last Mod By     : Sean Harris
NICC Reference  : NICC-023514
Description     : Controller for the AH_PartnerOrderDetail Visualforce page.
: 
******************************************************************************************/
public without sharing class AH_PartnerOrderDetailController 
{
    
    public Opportunity opp {get; set;}
    public List<oppDetails> lstOppDetails {get; set;} 
    public List<oppLineItemDetails> lstOppLineItemDetails {get; set;}  
    public User partnerUser {get; set;}
    public String currentUSDPriceBookName {get; set;} 
    
    private List<OpportunityLineItem> oppLineItems; 
    private DateTime orderDate; 
    private boolean isNotParterUser; 
    private string OppId; 
    private OpportunityContactRole ShipTo; 
    private OpportunityContactRole ProjectContact; 
    private List<NI_Partner_Channel_Order__c> lstCSPartnerChannel {get; set;} 
    
    // CONSTRUCTOR
    public AH_PartnerOrderDetailController() 
    {
        
        currentUSDPriceBookName = null;  
        isNotParterUser = false;
        
        // GET USER DETAILS
        partnerUser = [SELECT Id, AccountId, IsActive, UserType, FirstName, LastName   
                       FROM User 
                       WHERE Id =: UserInfo.getUserId()];
        
        // IF THE USER IS NOT ACTIVE RETURN
        if (partnerUser.IsActive == false)
        {
            return;
        }
        
        // IF AN INTERNAL USER IS VISITING THE PAGE SET isNotParterUser TO TRUE
        if ((partnerUser.AccountId == null) && (partnerUser.UserType == 'Standard'))
        {
            isNotParterUser = true;
        }
        
        if (ApexPages.currentPage().getParameters().get('OppId') != null)
        {
            OppId = ApexPages.currentPage().getParameters().get('OppId'); 
            setOpp(); 
        }
        
        // INIT CUSTOM SETTINGS LIST
        lstCSPartnerChannel = NI_Partner_Channel_Order__c.getAll().values();
        
        for (NI_Partner_Channel_Order__c cs : lstCSPartnerChannel)
        {
            if (cs.Name == 'Cendyn')
            {
                currentUSDPriceBookName = cs.CurrentUSDPriceBook__c;
            }
        }
        
        
    }
    
    private void setOpp()
    {
        system.debug(' **** ENTERING setOpp()');  
        system.debug(' **** partnerUser.Id = ' + partnerUser.Id + ', partnerUser.AccountId = ' + partnerUser.AccountId + ', OppId = ' + OppId);        
        opp = [SELECT                
               Opportunity.Name,
               Opportunity.Id,
               Opportunity.Opportunity_Number__c,
               Opportunity.Notes_to_Partners__c,
               Opportunity.Account.Name,
               Opportunity.Account.AccountNumber,
               Opportunity.Account.BillingCountry,
               Opportunity.Account.BillingCity,
               Opportunity.Account.BillingPostalCode,
               Opportunity.Account.BillingState,
               Opportunity.Account.BillingStreet,
               Opportunity.Account.Phone,
               Opportunity.Account.Fax,
               Opportunity.Order_Status__c,
               Opportunity.LastActivityDate,
               Opportunity.Owner.Name,
               Opportunity.StageName,
               Opportunity.Account.Parent.Name,  
               Opportunity.Account.Franchisor__c,   
               Opportunity.Account.Website,
               Opportunity.Account.Guest_Rooms__c,
               Opportunity.CloseDate,                         
               (SELECT Body, Title FROM Notes WHERE CreatedById =: partnerUser.Id), 
               (SELECT Createdby.Name, CreatedDate, Field, NewValue, OldValue FROM Histories),              
               (SELECT Role, contact.name, contact.phone, Contact.MailingCity, Contact.MailingCountry, Contact.MailingPostalCode, Contact.MailingStreet, Contact.MailingState, Contact.Fax, Contact.Email, Contact.Title FROM OpportunityContactRoles),              
               (SELECT op.Id, op.Quantity, op.UnitPrice, op.TotalPrice,  op.ServiceDate, op.Projected_Go_Live__c, op.PricebookEntry.Name, op.Product2.Name, op.PricebookEntry.ProductCode, op.PricebookEntry.Product2.Family, op.PricebookEntry.PriceBook2.Name, op.Family__c, op.LineType__c, op.ListPrice, op.PricebookEntry.Product2.Unit__c, op.PricebookEntry.UnitPrice, op.Product2.Apttus_Revenue_Category__c FROM OpportunityLineItems Op WHERE Op.Product2.Partner_Name__c =: partnerUser.AccountId AND (Op.Order_of_Delivery__c = null OR Op.Order_of_Delivery__c = 1))
               FROM Opportunity 
               WHERE Id =: OppId];
        
        system.debug(' **** setOpp(): 1st Query returned a record.');          
        setOppLineItems();      
        setContactRoles();
        setOrderDate();
        
        if (opp != null)
        {
            
            string ShipToContactName = ''; 
            string ShipToContactTitle = ''; 
            string ShipToContactEmail = ''; 
            string ShipToContactPhone = ''; 
            string ProjectContactContactName = ''; 
            string ProjectContactContactTitle = ''; 
            string ProjectContactContactEmail = ''; 
            string ProjectContactContactPhone = '';
            
            if (ShipTo != null)
            {
                ShipToContactName = ShipTo.Contact.Name; 
                ShipToContactTitle = ShipTo.Contact.Title; 
                ShipToContactEmail = ShipTo.Contact.Email; 
                ShipToContactPhone = ShipTo.Contact.Phone;                
            }
            
            if (ProjectContact != null)
            {
                ProjectContactContactName = ProjectContact.Contact.Name; 
                ProjectContactContactTitle = ProjectContact.Contact.Title; 
                ProjectContactContactEmail = ProjectContact.Contact.Email; 
                ProjectContactContactPhone = ProjectContact.Contact.Phone;                
            }
            
            lstOppDetails = new List<oppDetails>(); 
            oppDetails o = new oppDetails( 
                String.valueOf(opp.Id), 
                opp.Opportunity_Number__c, 
                opp.StageName, 
                opp.Owner.Name, 
                opp.Account.Name, 
                opp.Account.AccountNumber, 
                opp.Account.BillingStreet, 
                opp.Account.BillingState, 
                opp.Account.BillingCity,
                opp.Account.BillingCountry, 
                opp.Account.BillingPostalCode, 
                opp.Account.Phone, 
                opp.Account.Fax, 
                opp.Account.Parent.Name, 
                opp.Account.Franchisor__c, 
                opp.Account.Website, 
                String.valueOf(opp.Account.Guest_Rooms__c), 
                String.valueOf(orderDate), 
                getProjectManager(), 
                'New Install/Upgrade', 
                ShipToContactName, 
                ShipToContactTitle, 
                ShipToContactEmail, 
                ShipToContactPhone, 
                ProjectContactContactName, 
                ProjectContactContactTitle, 
                ProjectContactContactEmail, 
                ProjectContactContactPhone 
            );
            lstOppDetails.Add(o);
        }
        
    }
    
    private void setOppLineItems()
    {
        if (Opp != null)
        {
            oppLineItems = Opp.OpportunityLineItems;
            for (OpportunityLineItem ol : oppLineItems)
            {                
                //get the name of this pricebook and see if it is different                
                system.debug('pb name ' + ol.PricebookEntry.PriceBook2.Name );
                if (ol.PricebookEntry.PriceBook2.Name != currentUSDPriceBookName)
                {
                    //Check for discount
                    decimal discountValue = ol.PriceBookEntry.UNitPrice - ol.UnitPrice ;
                    
                    PriceBookEntry usdpb = null;
                    
                    system.debug( 'ol product code ' + ol.PricebookEntry.ProductCode );
                    usdpb = getPricebookEntry(ol.PricebookEntry.ProductCode);
                    
                    if (usdpb != null)
                    {
                        system.debug('usdpb price ' + usdpb.UnitPrice );
                        
                        ol.UnitPrice = usdpb.UnitPrice;
                        Decimal totalPriceUsd = usdpb.UnitPrice * ol.Quantity;
                        ol.TotalPrice = totalPriceUsd.setScale(2);
                        
                        if (discountValue > 0)
                        {
                            ol.UnitPrice = usdpb.UnitPrice - discountValue;
                            Decimal totalPrice = (usdpb.UnitPrice - discountValue) * ol.Quantity;          
                            ol.TotalPrice = totalPrice.setScale(2);
                        }
                    }
                }
            }
        }
        
        if (oppLineItems.size() > 0)
        {
            lstOppLineItemDetails = new List<oppLineItemDetails>();
            for (OpportunityLineItem i : oppLineItems)
            {             
                oppLineItemDetails x = new oppLineItemDetails(
                    String.valueOf(i.Quantity), 
                    i.PricebookEntry.ProductCode, 
                    i.Product2.Name, 
                    String.valueOf(i.UnitPrice), 
                    String.valueOf(i.TotalPrice));                
                lstOppLineItemDetails.add(x);
            }
        }
    }
    
    private void setContactRoles()
    {
        for (OpportunityContactRole ocr : Opp.OpportunityContactRoles)
        {
            if (ocr.Role == 'Ship to')
            {
                ShipTo = ocr;
            }
            
            if (ocr.Role == 'Customer Project Contact')
            {
                ProjectContact = ocr;
            }
            
        }
    }    
    
    public void setOrderDate()
    {
        for (OpportunityFieldHistory hist : Opp.Histories)
        {            
            if (hist.NewValue == 'Integrated')
            {
                orderDate = hist.createdDate;
            }
            else
            {
                orderDate = opp.CloseDate;
            }
        }
    }
    
    public string getProjectManager()
    {
        
        string projectOwnerName = '';
        List<pse__Proj__c> projects = [SELECT Owner.Name FROM pse__proj__c WHERE pse__Opportunity__c =: OppId];
        
        if (projects.size() > 0)
        {
            projectOwnerName = projects[0].Owner.Name;
        }
        
        return projectOwnerName;
        
    }    
    
    private Pricebookentry getPricebookEntry(string productCode)
    {
        
        PriceBookEntry pbEntry;
        List<PricebookEntry> pbEntries = [SELECT pricebookentry.unitprice, pricebookentry.productcode FROM pricebookentry WHERE pricebook2.Name =: currentUSDPriceBookName];
        
        for (PricebookEntry pb: pbEntries)
        {
            if (pb.ProductCode == ProductCode)
            {
                pbEntry = pb;
            }                
        }
        
        return pbEntry;
        
    }
    
    public class oppDetails
    {    
        public String OpportunityId {get; set;}			// Id
        public String OpportunityNumber {get; set;}		// Opportunity_Number__c
        public String Status {get; set;}				// StageName
        public String SalesManager {get; set;}			// Owner.Name        
        public String AccountName {get; set;}			// Account.Name
        public String AccountNumber {get; set;}			// Account.AccountNumber
        public String AccountStreet {get; set;}			// Account.BillingStreet
        public String AccountState {get; set;}			// Account.BillingState
        public String AccountCity {get; set;}			// Account.BillingCity
        public String AccountCountry {get; set;}		// Account.BillingCountry
        public String AccountPostal {get; set;}			// Account.BillingPostalCode
        public String AccountPhone {get; set;}			// Account.Phone
        public String AccountFax {get; set;}			// Account.Fax
        public String ManagementCo {get; set;}			// Account.Parent.Name
        public String Franchisor {get; set;}			// Account.Franchisor__c
        public String Website {get; set;}				// Account.Website
        public String GuestRooms {get; set;}			// Account.Guest_Rooms__c        
        public String OrderDate {get; set;}
        public String ProjectManager {get; set;}
        public String InstallType {get; set;}        
        public String ShipToName {get; set;}			// ShipTo.Contact.Name
        public String ShipToTitle {get; set;}			// ShipTo.Contact.Title
        public String ShipToEmail {get; set;}			// ShipTo.Contact.Email
        public String ShipToPhone {get; set;}			// ShipTo.Contact.Phone        
        public String ClientServicesContact {get; set;}	// ProjectContact.Contact.Name
        public String ClientServicesTitle {get; set;}	// ProjectContact.Contact.Title
        public String ClientServicesEmail {get; set;}	// ProjectContact.Contact.Email
        public String ClientServicesPhone {get; set;}	// ProjectContact.Contact.Phone
        
        public oppDetails (
            String OpportunityId, 
            String OpportunityNumber, 
            String Status, 
            String SalesManager,             
            String AccountName, 
            String AccountNumber, 
            String AccountStreet, 
            String AccountState, 
            String AccountCity, 
            String AccountCountry, 
            String AccountPostal, 
            String AccountPhone, 
            String AccountFax, 
            String ManagementCo, 
            String Franchisor, 
            String Website, 
            String GuestRooms,             
            String OrderDate, 
            String ProjectManager, 
            String InstallType,             
            String ShipToName, 
            String ShipToTitle, 
            String ShipToEmail, 
            String ShipToPhone,             
            String ClientServicesContact, 
            String ClientServicesTitle, 
            String ClientServicesEmail, 
            String ClientServicesPhone
        )
        {
            this.OpportunityId = OpportunityId;
            this.OpportunityNumber = OpportunityNumber;
            this.Status = Status;
            this.SalesManager = SalesManager;            
            this.AccountName = AccountName;
            this.AccountNumber = AccountNumber;
            this.AccountStreet = AccountStreet;
            this.AccountState = AccountState;
            this.AccountCity = AccountCity; 
            this.AccountCountry = AccountCountry;
            this.AccountPostal = AccountPostal;
            this.AccountPhone = AccountPhone;
            this.AccountFax = AccountFax;
            this.ManagementCo = ManagementCo;
            this.Franchisor = Franchisor;
            this.Website = Website;
            this.GuestRooms = GuestRooms;            
            this.OrderDate = OrderDate;
            this.ProjectManager = ProjectManager;
            this.InstallType = InstallType;            
            this.ShipToName = ShipToName;
            this.ShipToTitle = ShipToTitle;
            this.ShipToEmail = ShipToEmail;
            this.ShipToPhone = ShipToPhone;            
            this.ClientServicesContact = ClientServicesContact;
            this.ClientServicesTitle = ClientServicesTitle;
            this.ClientServicesEmail = ClientServicesEmail;
            this.ClientServicesPhone = ClientServicesPhone;         
        }
        
    }  
    
    public class oppLineItemDetails
    {    
        
        public String Quantity {get; set;}		// Quantity
        public String SKU {get; set;}			// PricebookEntry.ProductCode
        public String Description {get; set;}	// Product2.Name
        public String Rate {get; set;}			// UnitPrice
        public String Price {get; set;}			// TotalPrice 
        
        public oppLineItemDetails (
            String Quantity, 
            String SKU, 
            String Description, 
            String Rate, 
            String Price
        )
        {
            this.Quantity = Quantity;
            this.SKU = SKU;
            this.Description = Description;
            this.Rate = Rate;
            this.Price = Price;        
        }
        
    }   
    
}