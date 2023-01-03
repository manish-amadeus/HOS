/************************************************************************************************
Name            : AH_CBS_LicenseReq_ctrl Class
Author          : Sean Harris
Created Date    : 08/21/2020
Last Mod Date   : 08/21/2020
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller class for AH_CBS_LicenseReq VF Page 
                : 
                : 
*************************************************************************************************/
public class AH_CBS_LicenseReq_ctrl 
{
    
    // PUBLIC VARIABLES ======================================
    public CBS_License_Request__c cbsLQ {get; set;}
    public List<SelectOption> lstLicenseTypes {get; set;}
    public List<LicenseLineItem> lstLicenseLineItems {get; set;} 
    public Boolean bShowLicenses {get; set;}
    public String strMsg {get; set;} 
        
    public AH_CBS_LicenseReq_ctrl()
    {
        
        bShowLicenses = false;
        
        if (ApexPages.CurrentPage().getParameters().containsKey('id')) 
        {    
            
            bShowLicenses = true;
            cbsLQ = [SELECT Id FROM CBS_License_Request__c WHERE Id =: ApexPages.CurrentPage().getParameters().get('id')]; 
            
            lstLicenseLineItems = new List<LicenseLineItem>(); 
            
            for (CBS_License_Type__c licType : [SELECT Id, Amadeus_License_Type__c, License_Description__c, Cost__c,
                                                Total_Licenses__c, Used_Licenses__c, Reserved_Licenses__c, Available_Licenses__c 
                                                FROM CBS_License_Type__c 
                                                WHERE Is_Retired__c = false
                                                ORDER BY Amadeus_License_Type__c ASC])
            {
                LicenseLineItem x = new LicenseLineItem(
                    false,
                    cbsLQ.Id, 
                    licType.Id, 
                    licType.Amadeus_License_Type__c, 
                    licType.License_Description__c,
                    licType.Cost__c,                    
                    null,                    
                    null,
                    false, licType.Total_Licenses__c, licType.Used_Licenses__c, licType.Reserved_Licenses__c, licType.Available_Licenses__c
                );
                lstLicenseLineItems.add(x);                
            }

            lstLicenseTypes = new List<SelectOption>();
            Schema.DescribeFieldResult dfr2 = CBS_License_Type__c.Amadeus_License_Type__c.getDescribe();
            lstLicenseTypes.add(new SelectOption('CHOOSE ONE', 'CHOOSE ONE'));
            for (Schema.PicklistEntry plv2 : dfr2.getPicklistValues())
            {
                lstLicenseTypes.add(new SelectOption(plv2.getValue(), plv2.getLabel()));
            }            
            
        }        

    }
    
    // BUTTON METHODS
    public PageReference doCancel() 
    {
        string strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + cbsLQ.Id;
        PageReference pr = new PageReference(strUrl); 
        pr.setRedirect(true); 
        return pr; 
    }   
    
    public void doLineEdit()
    {
        for (LicenseLineItem lli : lstLicenseLineItems)
        {
            lli.inEditMode = false;
            if (lli.isSelected)
            {
                lli.inEditMode = true;
            }
        }
    }
    
    public PageReference doSubmit() 
    {    
        
        PageReference pr;
        try
        {
            
            List<CBS_License_Request_Line_Item__c> lstLLIInserts = new List<CBS_License_Request_Line_Item__c>();
            
            for (LicenseLineItem lli : lstLicenseLineItems)
            {
                if (lli.isSelected)
                {
                    CBS_License_Request_Line_Item__c x = new CBS_License_Request_Line_Item__c();
                    x.CBS_License_Request__c = lli.CBSLicenseRequestId;
                    x.CBS_License_Type__c = lli.CBSLicenseTypeId;
                    x.Quantity__c = lli.dQuantity;
                    x.Notes_to_Admin__c = lli.strNote;
                    lstLLIInserts.add(x);                    
                }
            }

            if (!lstLLIInserts.isEmpty())
            {
                Database.insert(lstLLIInserts);
            }
            strMsg = 'Your license request has been submitted.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, strMsg));
           
            // ADDED BY CYBAGE TO REIRECT TO ORIGINAL RECORD PAGE - 03/31/2021
            string strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + cbsLQ.Id;
            system.debug('Redirect URL : '+strUrl);
            pr = new PageReference(strUrl); 
            pr.setRedirect(true); 
        }            
        catch (Exception e)
        {
            strMsg = 'The following error occurred when saving: ' + e.getMessage();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, strMsg));
            pr = null;
        }      
        
        return pr; 
    }  
    
    // INNER CLASSES =======================================  
    public class LicenseLineItem
    {    
        
        public Boolean isSelected {get; set;} 
        public Id CBSLicenseRequestId {get; set;} 
        public Id CBSLicenseTypeId {get; set;}
        public String strLicenseTypeName {get; set;} 
        public String strLicenseTypeDesc {get; set;} 
        public Decimal dCost {get; set;}
        public Decimal dQuantity {get; set;}
        public String strNote {get; set;}         
        public Boolean inEditMode {get; set;}
        public Decimal Total_Licenses {get; set;}
        public Decimal Used_Licenses {get; set;}
        public Decimal Reserved_Licenses {get; set;}
        public Decimal Available_Licenses {get; set;}
        
        //Total_Licenses__c, Used_Licenses__c, Reserved_Licenses__c, Available_Licenses__c 
        
        public LicenseLineItem(Boolean b1, Id id1, Id id2, String s1, String s2, Decimal d1, Decimal d2, String s3, Boolean b2, Decimal totalLicenses, Decimal usedLicenses, Decimal reservedLicenses, Decimal availableLicenses)
        {
            this.isSelected = b1;  
            this.CBSLicenseRequestId = id1;  
            this.CBSLicenseTypeId = id2; 
            this.strLicenseTypeName = s1;
            this.strLicenseTypeDesc = s2; 
            this.dCost = d1;
            this.dQuantity = d2; 
            this.strNote = s3;
            this.inEditMode = b2;
            this.Total_Licenses = totalLicenses;
            this.Used_Licenses = usedLicenses;
            this.Reserved_Licenses = reservedLicenses;
            this.Available_Licenses = availableLicenses;
        }
        
    }
    
}