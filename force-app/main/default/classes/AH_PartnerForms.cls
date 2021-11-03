/****************************************************************************************
Name            : AH_PartnerForms Class
Author          : Sean Harris
Created Date    : 10/13/2017
Last Mod Date   : 10/13/2017
Last Mod By     : Sean Harris
NICC Reference  : NICC-024156
Description     : 
                : 
                : 
******************************************************************************************/
public class AH_PartnerForms 
{

    // LIST TO HOLD THE HARDWARE RECORDS  
    public List<Partners_Form_Template_to_Account__c> lstForms {get; set;} 
    public Partners_Form_Template__c frm {get; set;} 
    public User usr {get; set;}
    public boolean displayPopup {get; set;}  
    public boolean isAccepted {get; set;}  
    public boolean showActivationButton {get; set;}  
    public Id accId {get; set;} 
    public Id formId {get; set;} 
    public string ipAddress {get; set;} 
    
    
    public AH_PartnerForms()
    {            
    
        ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        usr = [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId()];
        accId = usr.AccountId;
        
        lstForms = [SELECT Id, Accepted_By__r.Name, 
                    Accepted_Terms__c, 
                    Account__c, 
                    Date_Accepted__c, 
                    Form_Subject__c, 
                    Partners_Form_Template__c 
                    FROM Partners_Form_Template_to_Account__c 
                    WHERE Account__c =: accId 
                    ORDER BY Accepted_Terms__c, Form_Subject__c];            
        
        showActivationButton = false;
        
        if (allFormsAccepted(accId))
        {
            showActivationButton = true;
        }
        
    }
	
    public void closePopup() 
    {        
        displayPopup = false; 
    } 
	
    public void openForm() 
    {        
        displayPopup = true;      
        frm = [SELECT Id, End_Date__c, Start_Date__c, Subject__c, Terms__c FROM Partners_Form_Template__c WHERE Id =: formId];
    }
    
    public PageReference acceptTerms() 
    {   
        
        PageReference pr = new PageReference('/AH_PartnerForms');        
        
        Partners_Form_Template_to_Account__c pft = [SELECT Id, Accepted_By__c, 
                                                    Accepted_Terms__c, 
                                                    Account__c, 
                                                    Date_Accepted__c, 
                                                    Form_Subject__c, 
                                                    Partners_Form_Template__c, 
                                                    Partners_Form_Template__r.Template_Type__c 
                                                    FROM Partners_Form_Template_to_Account__c 
                                                    WHERE Account__c =: accId 
                                                    AND Partners_Form_Template__c =: formId];  
        
        pft.Accepted_Terms__c = true;
        pft.Date_Accepted__c = DateTime.now();
        pft.Accepted_By__c = usr.Id;
        pft.IP_Address__c = ipAddress;
        update pft;
        
        Date dtStartDate = Date.today();
        Date dtEndDate; 
        List<PartnerCentralTemplateTypes__c> lstCustSets = PartnerCentralTemplateTypes__c.getAll().values();

        for (PartnerCentralTemplateTypes__c cs : lstCustSets)
        {
            if (cs.Name == pft.Partners_Form_Template__r.Template_Type__c)
            {
                dtEndDate = dtStartDate.addDays((integer)cs.TermLength__c);
            }
        }

        createContract(usr.Id, accId, pft.Id, dtStartDate, dtEndDate, ipAddress, pft.Form_Subject__c, pft.Partners_Form_Template__r.Template_Type__c);

        pr.setRedirect(true);
        return pr;
        
    }
    
    private void createContract(Id userID, Id AccountId, Id PartnersFormTemplatetoAccountId, Date dStartDate, Date dEndDate, string strIP, string strContractName, string strTemplateType)
    {

        Contact ct = [SELECT Id, Name, Email, Title FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id =: userID) LIMIT 1];

        Contract c = new Contract(); 
        c.AccountId = AccountId;
        c.Name = strContractName;
        c.StartDate = dStartDate;
        c.EndDate = dEndDate;
        c.Contract_Type__c = 'Click Through Agreement';
        c.PartnerForm__c = PartnersFormTemplatetoAccountId;
        c.ct_ContactIPAddress__c = strIP;
        c.Type_of_Term__c = 'Expires';
        c.Status = 'Executed';
        c.ct_Contact_ID__c = ct.Id;
        c.ct_Contact_Name__c = ct.Name;
        c.ct_Contact_Email__c = ct.Email;
        c.ct_Contact_Title__c = ct.Title;   
        c.ct_DateTime__c = DateTime.Now();
        c.OwnerId = '00560000000yI7jAAE';
        c.ct_Has_Authority__c = true;
        c.Type_of_Term__c = strTemplateType;
        insert c;
        
    }
    
    public PageReference accessCommunity()
    {
        PageReference pr = new PageReference('https://amadeus-community.force.com/partnercentral');  
        pr.setRedirect(true);
        return pr;        
    }
	
    public boolean allFormsAccepted(Id AccountId)
    {

		boolean bRetVal = true;
        
        List<Partners_Form_Template_to_Account__c> lstPFTs = new List<Partners_Form_Template_to_Account__c>(
            [SELECT Id 
             FROM Partners_Form_Template_to_Account__c 
             WHERE Account__c =: AccountId 
             AND Accepted_Terms__c = false]);          
        
		if (lstPFTs.size() > 0)
        {
            bRetVal = false;
        }
        
        return bRetVal;
        
    }

}