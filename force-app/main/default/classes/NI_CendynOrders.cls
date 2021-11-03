/****************************************************************************************
Name            : NI_CendynOrders Class
Author          : Stuart Emery
Created Date    : 5/4/2015
Last Mod Date   : 9/9/2015
Last Mod By     : Suzanne LeDuc
NICC Reference  : NICC-014143
Description     : Controller for the CendynOrderDetail Visualforce page.
                :  Last Updated Per NICC-014793
******************************************************************************************/
public class NI_CendynOrders {
    
    // Removed "with sharing" to filter records based on queried results.
    
    Boolean disableSaveButton;
    public String newNoteBody { get; set; }
    public String currentUSDPriceBookName = null;
    
    private Set<String> GetExcludedProductCodes()
    {
        
        List<Cendyn_Excluded_Products__c> lstCS = Cendyn_Excluded_Products__c.getAll().values();
        Set<string> excludedProductCodes = new Set<String>();
        
        
        for (Cendyn_Excluded_Products__c las : lstCS)
        {
            if(las.Name != null)
            {
                excludedProductCodes.add(las.Name);
                
            }  
        }
        
        return excludedProductCodes;
        
    }
    
    
    
    String searchText = '';
    public String getSearchText() {
        return searchText;
    }
    
    public void setSearchText(String s) {
        searchText = s;
    }
    
    //LIST TO HOLD THE VALUES FROM THE "NI Partner Channel Order" CUSTOM SETTING  
    List<NI_Partner_Channel_Order__c> lstCSPartnerChannel = NI_Partner_Channel_Order__c.getAll().values();
    
    
    public string OppId {get;set;}
    
    list<OpportunityLineItem> oppLineItems;
    public List<OpportunityLineItem> getOppLineItems()
    {
        if( oppLineItems != null )
            System.Debug( 'Opp Line Items ' + oppLineItems.Size() );
        
        return oppLineItems;
    }
    private void setOppLineItems()
    {
        if( Opp != null )
        {
            oppLineItems = Opp.OpportunityLineItems;
            for( OpportunityLineItem ol : oppLineItems )
            {
                
                //get the name of this pricebook and see if it is different
                
                System.Debug('pb name ' + ol.PricebookEntry.PriceBook2.Name );
                if( ol.PricebookEntry.PriceBook2.Name != currentUSDPriceBookName )
                {
                    //Check for discount
                    decimal discountValue = ol.PriceBookEntry.UNitPrice - ol.UnitPrice ;
                    
                    
                    PriceBookEntry usdpb = null;
                    
                    System.Debug( 'ol product code ' + ol.PricebookEntry.ProductCode );
                    usdpb = getPricebookEntry( ol.PricebookEntry.ProductCode);
                    
                    if( usdpb != null )
                    {
                        System.debug('usdpb price ' + usdpb.UnitPrice );
                        
                        ol.UnitPrice = usdpb.UnitPrice;
                        Decimal totalPriceUsd = usdpb.UnitPrice * ol.Quantity;
                        ol.TotalPrice = totalPriceUsd.setScale(2);
                        
                        if( discountValue > 0 )
                        {
                            ol.UnitPrice =  usdpb.UnitPrice - discountValue;
                            Decimal totalPrice =   (usdpb.UnitPrice - discountValue ) * ol.Quantity;          
                            ol.TotalPrice = totalPrice.setScale(2);
                            
                        }
                    }
                }
            }
        }
        
        System.Debug('In setOppLineItems');
    }
    
    
    
    
    
    private OpportunityContactRole ShipTo;
    private OpportunityContactRole ProjectContact;
    
    public OpportunityContactRole getShipTo()
    {
        return ShipTo;
    }
    public OpportunityContactRole getProjectContact()
    {
        return ProjectContact;
    }
    
    private DateTime orderDate;
    public DateTime getOrderDate()
    {
        return orderDate;
    }
    public void setOrderDate()
    {
        if( !Test.isRunningTest()  )
        {
            for( OpportunityFieldHistory hist : Opp.Histories )
            {
                
                if( hist.NewValue == 'Integrated' )
                {
                    orderDate = hist.createdDate;
                }
                else
                {
                    orderDate = opp.CloseDate;
                }
            }
        }
    }
    
    public string getProjectManager()
    {
        string projectOwnerName = '';
        List<pse__Proj__c> projects = [ SELECT Owner.Name from pse__proj__c where pse__Opportunity__c = :Oppid  ];
        if( projects.size() > 0 )
            projectOwnerName = projects[0].Owner.Name;
        
        Return projectOwnerName;
        
    }
    private void setContactRoles()
    {
        for( OpportunityContactRole ocr: Opp.OpportunityContactRoles )
        {
            if( ocr.Role == 'Ship to' )
                ShipTo = ocr;
            
            if( ocr.Role == 'Customer Project Contact' )
                ProjectContact = ocr;
        }
    }
    
    private Opportunity opp;
    public Opportunity getOpp()
    {
        return opp;
    }
    
    
    private Pricebookentry getPricebookEntry( string productCode)
    {
        
        PriceBookEntry pbEntry;
        List<PricebookEntry> pbEntries = [SELECT pricebookentry.unitprice, pricebookentry.productcode from pricebookentry where pricebook2.Name = :currentUSDPriceBookName];
        
        System.Debug('current price book ' + currentUsdPriceBookName );
        
        for( PricebookEntry pb: pbEntries )
        {
            System.debug( 'product code ' + pb.productcode );
            if( pb.ProductCode == ProductCode )
                pbEntry = pb;
        }
        
        return pbEntry;
    }
    
    private void setOpp()
    {
        
        Set<String> excluded = getExcludedProductCodes();
        Opp =  [ SELECT
                
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
                
                
                ( select Body,
                 Title from Notes Where CreatedById = :UserInfo.getUserId() ), 
                
                ( Select Createdby.Name, CreatedDate, Field, NewValue, OldValue from Histories ),
                
                
                (select 
                 Role,
                 contact.name, 
                 contact.phone, 
                 Contact.MailingCity, 
                 Contact.MailingCountry,
                 Contact.MailingPostalCode,
                 Contact.MailingStreet,
                 Contact.MailingState,
                 Contact.Fax,
                 Contact.Email,
                 Contact.Title from OpportunityContactRoles  ),
                
                
                ( select   op.Id, 
                 op.Quantity, 
                 op.UnitPrice, 
                 op.TotalPrice,  
                 op.ServiceDate,
                 op.Projected_Go_Live__c,
                 op.PricebookEntry.Name, 
                 op.Product2.Name,
                 op.PricebookEntry.ProductCode,
                 op.PricebookEntry.Product2.Family,
                 op.PricebookEntry.PriceBook2.Name,
                 
                 op.Family__c,
                 op.LineType__c,
                 op.ListPrice, 
                 
                 op.PricebookEntry.Product2.Unit__c,
                 op.PricebookEntry.UnitPrice,
                 op.Product2.Apttus_Revenue_Category__c,
                 op.Product2.Line__c      from OpportunityLineItems Op Where  Op.Product2.Product_Group__r.Name = 'Cendyn' AND ( NOT Op.Product2.ProductCode in :excluded )  )
                
                
                
                
                
                
                FROM Opportunity where Id = :OppId];
        
        setOppLineItems();      
        setContactRoles();
        setOrderDate();
        
    }
    
    
    List<OpportunityLineItem> lineItems;
    public List<OpportunityLineItem> getLineItems()
    {
        return lineItems;
    }
    
    private list<OpportunityLineItem> queryLineItems( String sortOrder)
    {
        Date dtToday = date.today(); //GET THE CURRENT DATE OF THE RUNNING USER
        Date dtStartDate;
        Integer intOppMonths = 12; //SET A DEFAULT VALUE IF THERE IS NO VALUE SET IN THE CUSTOM SETTING
        Integer intOppMonthsNegative;
        
        for (NI_Partner_Channel_Order__c cs : lstCSPartnerChannel)
        {
            if(cs.Name == 'Cendyn')
            {
                intOppMonths = Integer.valueOf(cs.Opp_Close_Date_Months__c); 
            }
        }
        
        intOppMonthsNegative = intOppMonths * -1;  //CONVERT THE INTEGER TO A NEGATIVE NUMBER TO SET THE NUMBER OF MONTHS TO GO BACK
        dtStartDate = dtToday.AddMonths(intOppMonthsNegative);
        System.debug('OPP CLOSED DATE START DATE: ' + dtStartDate);
        
        Set<String> excluded = getExcludedProductCodes();
        
        list<OpportunityLineItem> InitiallineItems = Database.query(' SELECT op.Id, op.Quantity,op.UnitPrice,op.TotalPrice,op.ServiceDate, op.Projected_Go_Live__c, op.LOD_Licensed_Property__c,op.PricebookEntry.Name, op.Product2.Name,op.OpportunityId, op.PricebookEntry.ProductCode, op.Release_Date__c, op.Deferred__c,op.PricebookEntry.Product2.Family, op.CurrencyIsoCode,op.Discount__c, op.Family__c,'
                                                                    +'op.LineType__c, op.ListPrice, op.PricebookEntryId,  op.PriceBookEntry.UnitPrice, op.PriceBookEntry.Pricebook2.Name, op.PricebookEntry.Product2.Unit__c, op.LOD_Start_Date__c, op.Opportunity.Name, op.Opportunity.Id, op.Opportunity.Opportunity_Number__c,op.Opportunity.Account.Name, op.Opportunity.Account.AccountNumber, op.Opportunity.CloseDate,op.Product2.Line__c FROM OpportunityLineItem op'
                                                                    + ' Where op.Opportunity.CloseDate >=: dtStartDate AND  op.Opportunity.stagename = \'Closed Won\' AND Product2.Product_Group__r.Name = \'Cendyn\' AND ( NOT op.product2.ProductCode  in :excluded )  AND  op.ServiceDate = NULL and op.Quantity > 0 ORDER BY ' + sortOrder + ' LIMIT 1000' );
        
        Return InitialLineItems;           
        
    }
    
    private void setLineItems( List<OpportunityLineItem> value )
    {
        System.Debug(' Set Line Items ');
        lineItems =value;
    }
    
    
    public boolean getdisableSaveButton()
    {
        return disableSaveButton;
    } 
    
    public void setdisableSaveButton( boolean value )
    {
        disableSaveButton = value;
    }
    
    
    
    
    
    
    // init the controller and display some sample data when the page loads
    public NI_CendynOrders() {
        
        for(NI_Partner_Channel_Order__c cs : lstCSPartnerChannel)
        {
            if(cs.Name == 'Cendyn')
            {
                currentUSDpriceBookName = cs.CurrentUSDPriceBook__c;
            }
        }
        
        if( lineItems == null )
            setLineItems( queryLineItems( ' op.Opportunity.Account.Name, op.Opportunity.Name'));
        
        OppId = ApexPages.currentPage().getParameters().get('OppId'); 
        System.Debug(  'Oppid ' + OppId );
        if( OppId != null )
        {
            System.Debug(  'Oppid ' + OppId );
            setOpp();
            
        }
    }
    
    
    public void SaveOrder() 
    {
        List<OpportunityLineItem> lstOppLineItemsToUpsert = new List <OpportunityLineItem>();
        List<Note> oppNotesforUpdate = new List<Note>();
        
        for( OpportunityLineItem l: lineItems){
            
            System.Debug('Start Date ' + l.ServiceDate);
            if( l.ServiceDate != NULL || l.Projected_Go_Live__c != null)
            {  
                lstOppLineItemsToUpsert.add(l);
            }
            
            
        }
        
        if( lstOppLIneItemsToUpsert.Size() > 0 )
            Database.upsert(lstOppLineItemsToUpsert);
        
        
        if( newNoteBody != null && newNoteBody.length() > 0 )
        {
            Note newNote = new Note();
            newNote.ParentId = OppId;
            if( newNoteBody.length() > 25 )
            {
                newNote.Title = newNoteBody.Substring(0,25);
            }
            else
            {
                newNote.Title = newNoteBody;
                
            }
            
            
            newNote.Body = newNoteBody;
            oppNotesForUpdate.Add( newNote );
            
        }
        
        if( oppNotesForUpdate.Size() > 0 )
            Database.Upsert( oppNotesForUpdate );
        
        string message = 'Your order was saved successfully.\n';
        ApexPages.Message myMsg = new ApexPages.Message( ApexPages.Severity.INFO, message );
        ApexPages.addMessage(myMsg);
        disableSaveButton = true;
        
    }
    
    
    
    // runs the search with parameters passed via Javascript
    public PageReference runSearch() {
        
        System.Debug( ' >>> Search Text ' + searchText );
        
        //Need to reset the List
        LineItems = queryLineItems( ' op.Opportunity.Account.Name, op.Opportunity.Name');
        List<OpportunityLineItem> lstOppLineItemsSearch = new List <OpportunityLineItem>();
        for( OpportunityLineItem oi : LineItems )
        {
            //|| oi.Opportunity.Name.Contains(searchText) 
            if( oi.Product2.Name.contains(searchText) || oi.Opportunity.Opportunity_Number__c.Contains( searchText)|| oi.Opportunity.Account.Name.Contains(searchtext))
            {
                lstOppLineItemsSearch.Add( oi );
            }
            
            if( lstOppLineItemsSearch.size() > 0 )
                setLineItems( lstOppLineItemsSearch );
        }
        
        System.Debug( ' >>> line items ' + LineItems.Size() );
        
        return null;
    }
    
    private String sortDirection = 'ASC';
    private String sortExp = 'name'; 
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }
    
    public String getSortDirection()
    {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value)
    {  
        sortDirection = value;
    }
    
    
    public PageReference ViewData() {
        //build the full sort expression
        string sortFullExp = sortExpression  + ' ' + sortDirection;
        
        //query the database based on the sort expression
        LineItems = queryLineItems( sortFullexp );
        
        return null;
    }
    
    
    
}