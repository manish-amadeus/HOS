/************************************************************************************************
Name            : AH_FinancePolicy_BC_Ctlr Class
Author          : Sean Harris
Created Date    : 07/17/2020
Last Mod Date   : 07/17/2020
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller class for AH_FinancePolicy_BC VF Page 
                : 
                : 
*************************************************************************************************/
public class AH_FinancePolicy_BC_Ctlr 
{
    
    // PUBLIC VARIABLES ======================================
    
    // OBJECT VARIABLES
    public Account a {get; set;}
    public AH_Account_Finance_Policy__c afp {get; set;}
    public List<bContract> lstBCs {get; set;} 
    public string strMsg {get; set;} 
    public boolean bShowBCs {get; set;} 
    
    public AH_FinancePolicy_BC_Ctlr()
    {
        
     	if (ApexPages.CurrentPage().getParameters().containsKey('id')) 
     	{    
            
            strMsg = '';
            bShowBCs = true;
            
            afp = [SELECT Id, Account__c, Billing_Contracts__c FROM AH_Account_Finance_Policy__c WHERE Id =: ApexPages.CurrentPage().getParameters().get('id')];
            a = [SELECT Id, Name, AccountNumber FROM Account WHERE Id =: afp.Account__c];
            
            lstBCs = new List<bContract>();
            
            for (Billing_Contract__c bc : [SELECT Id, Name, Account__r.Name, Account__r.AccountNumber, Company__r.Name, Accounting_Currency__r.Name 
                                           FROM Billing_Contract__c 
                                           WHERE Account__c =: afp.Account__c
                                           ORDER BY Name])
            {
                bContract x = new bContract(
                	false,
                    bc.Id, 
                    bc.Name, 
                    bc.Account__r.Name,
                    bc.Account__r.AccountNumber,                    
					bc.Company__r.Name,                    
                    bc.Accounting_Currency__r.Name 
                );
                lstBCs.add(x);
            }
            
            String strBCIds = afp.Billing_Contracts__c;
            
            if (!String.isEmpty(strBCIds) && !String.isBlank(strBCIds))
            {
                List<Id> lstBCIds = strBCIds.split(',');
                
                for (bContract x2 : lstBCs)
                {
                    for (Id i : lstBCIds) 
                    {
                        if (x2.bcId == i)
                        {
                            x2.isSelected = true;
                        }
                    }
                } 
            }
            
        }        

    }
    
	// BUTTON METHODS
    public PageReference doCancel() 
    {
        string strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + afp.Id;
        PageReference pr = new PageReference(strUrl); 
        pr.setRedirect(true); 
        return pr; 
    }   
    
    public void doSubmit() 
    {    
        
        String strBCIDs = '';
        boolean bFirst = true;
        bShowBCs = true;
        
        for (bContract bc : lstBCs)
        {
            if (bc.isSelected)
            {
                if (bFirst)
                {
                    strBCIDs += bc.bcId;
                    bFirst = false;
                }
                else
                {
                    strBCIDs += ',' + bc.bcId;
                }                
            }
        }
        
        try
        {
            afp.Billing_Contracts__c = strBCIDs;
            update afp;  
            bShowBCs = false;
            strMsg = 'Billing Contacts were associated to the Finance Policy successfully!';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, strMsg));
        }            
        catch (Exception e)
        {
            strMsg = 'The following error occurred when saving: ' + e.getMessage();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, strMsg));
        }      
        
    }  
    
    // INNER CLASSES =======================================  
    public class bContract
    {    
        
        public Boolean isSelected {get; set;} 
        public Id bcId {get; set;} 
        public String bcName {get; set;} 
        public String bcAccountName {get; set;} 
        public String bcAccountNumber {get; set;} 
        public String bcCompanyName {get; set;} 
        public String bcAccountCurrency {get; set;}         
        
        public bContract(Boolean b1, Id id1, String s1, String s2, String s3, String s4, String s5)
        {
        	this.isSelected = b1;  
            this.bcId = id1;  
        	this.bcName = s1; 
        	this.bcAccountName = s2; 
        	this.bcAccountNumber = s3; 
            this.bcCompanyName = s4; 
        	this.bcAccountCurrency = s5; 
        }
        
    }
    
}