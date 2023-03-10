/****************************************************************************************
Name            : AH_PCC_CancellationDetails_Ctlr
Author          : Sean Harris
Created Date    : 05/16/2019
Last Mod Date   : 05/16/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller for the AH_PCC_CancellationDetails Visualforce page.
                : 
******************************************************************************************/
public class AH_PCC_CancellationDetails_Ctlr 
{

	// PUBLIC VARIABLES ======================================
    public NI_Cancellation__c cxl {get; set;}
    public User partnerUser {get; set;}    
    
    // COLLECTIONS
    public List<searchResult> lstSearchResults {get; set;} 
    public List<SelectOption> lstCancellationStatuses {get; set;} 
    
    public Boolean isEditMode {get; set;} 
    public Boolean allowEditMode {get; set;} 
    public String selField {get; set;}
    public String txtNotes {get; set;}
    
    // PRIVATE VARIABLES ======================================
    private Boolean isNotParterUser;     
    private String CxlId;    
    
    
    public AH_PCC_CancellationDetails_Ctlr() 
    {

        isNotParterUser = false;
        isEditMode = false;
        allowEditMode = false;
        
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
        
        if (ApexPages.currentPage().getParameters().get('id') != null)
        {
            CxlId = ApexPages.currentPage().getParameters().get('id'); 
            loadRecord(CxlId);
        }

    }   
    
    private void loadRecord(String strCxlId)
    {

        string q = 'SELECT ';
        q += 'Id, '; 
        q += 'Name, '; 
        q += 'Status__c, '; 
        q += 'Effective_Date__c, '; 
        q += 'Account_Number__c, '; 
        q += 'Account_Name__c, ';	
        q += 'Management_Company__r.Name, '; 
        q += 'Product_Code__c, '; 
        q += 'Product__c, '; 
        q += 'General_Reason__c, '; 
        q += 'Renewal_Cancellation_Reason__c, '; 
        q += 'Cancel_Renewal_By_Date__c, '; 
        q += 'Renewal_Cancellation_Note__c, '; 
        q += 'Sales_Retention_Notes__c, ';
        q += 'Renewal_Cancellation_Quantity__c, '; 
        q += 'Late_Cancellation__c ';
        q += 'FROM NI_Cancellation__c ';
        q += 'WHERE Id = \'' + strCxlId + '\' ';
        //q += 'AND Cancel_Renewal_By_Date__c >= TODAY ';
        //q += 'AND Status__c = \'Pending Retention\' ';
        //q += 'AND Late_Cancellation__c = false ';

        if (!isNotParterUser)
        {
            q += 'AND Product2__r.Partner_Name__c = \'' + partnerUser.AccountId + '\' ';
        }
        
system.debug(' *%* query = ' + q);           
        
        cxl = Database.query(q);
        
        fillPicklists();
        
        selField = cxl.Status__c;
        txtNotes = '';
        
        if (cxl.Sales_Retention_Notes__c != null)
        {
            txtNotes = cxl.Sales_Retention_Notes__c;
        }
        
        if ((cxl.Late_Cancellation__c == false) && (cxl.Status__c == 'Pending Retention'))
        {
            allowEditMode = true;
        }
        
        lstSearchResults = new List<searchResult>();
        
        searchResult sr = new searchResult(
            cxl.Id, 
            cxl.Name, 
            cxl.Status__c, 
            cxl.Effective_Date__c, 
            cxl.Account_Number__c, 
            cxl.Account_Name__c,     
            cxl.Management_Company__r.Name, 
            cxl.Product_Code__c, 
            cxl.Product__c, 
            cxl.General_Reason__c, 
            cxl.Renewal_Cancellation_Reason__c, 
            cxl.Cancel_Renewal_By_Date__c, 
            cxl.Renewal_Cancellation_Note__c,
            cxl.Sales_Retention_Notes__c,
        	String.valueOf(cxl.Renewal_Cancellation_Quantity__c),
        	cxl.Late_Cancellation__c);        
        lstSearchResults.add(sr);
        
    }
    
	private void fillPicklists()
    {
        
    	lstCancellationStatuses = new List<SelectOption>();
		lstCancellationStatuses.add(new SelectOption('Flagged to be Cancelled', 'Flagged to be Cancelled'));
		lstCancellationStatuses.add(new SelectOption('Successfully Retained', 'Successfully Retained'));
        
    }    
    
    public void doSave()
    {
        
        NI_Cancellation__c c = [SELECT Id, Status__c, Sales_Retention_Notes__c FROM NI_Cancellation__c WHERE Id =: CxlId];
        c.Status__c = selField;
        c.Sales_Retention_Notes__c = txtNotes;
        update c;
        
        isEditMode = false;
        loadRecord(CxlId);
        
    }
    
    public void doEdit()
    {
        isEditMode = true;
    }

    public void doCancel()
    {
        isEditMode = false;
    }    
    
    
    
    // ================================================================================================================================
	//  WRAPPER CLASSES ===============================================================================================================
    // ================================================================================================================================
    public class searchResult
    {    
 
        public Id CancellationId {get; set;}
        public String CancellationName {get; set;}
        public String CancellationStatus {get; set;}
        public Date CancellationEffectiveDate {get; set;}
        public String AccountNumber {get; set;}
        public String AccountName {get; set;}        
        public String ManagementCompanyName {get; set;} 
        public String ProductCode {get; set;}
        public String ProductName {get; set;}
		public String GeneralReason {get; set;}
        public String RenewalCancellationReason {get; set;}
        public Date CancelRenewalByDate {get; set;}
        public String CancellationNotes {get; set;}
        public String SalesRetentionNotes {get; set;}
        public String CancellationQty {get; set;}
        public Boolean isLate {get; set;}

        public searchResult(Id p1, String p2, String p3, Date p4, String p5, String p6, String p7, String p8, String p9, String p10, String p11, Date p12, String p13, String p14, String p15, Boolean isLate)
        {
        	this.CancellationId = p1;
        	this.CancellationName = p2;
        	this.CancellationStatus = p3;
        	this.CancellationEffectiveDate = p4;
        	this.AccountNumber = p5;
        	this.AccountName = p6;        
        	this.ManagementCompanyName = p7;
        	this.ProductCode = p8;
        	this.ProductName = p9;
        	this.GeneralReason = p10;
        	this.RenewalCancellationReason = p11;
        	this.CancelRenewalByDate = p12;
        	this.CancellationNotes = p13;
        	this.SalesRetentionNotes = p14;
            this.CancellationQty = p15;
            this.isLate = isLate;
        }
        
    }   
    
}