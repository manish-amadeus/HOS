public with sharing class CRDetailExtension 
{

    public Case c;
    public SFDC_CSP_Development_Request__c CR;
    public String strCaseNumber {get; set;} 
    public Boolean showAttachCaseButton {get; set;} 

    public CRDetailExtension(ApexPages.StandardController controller) 
    {
        this.CR = (SFDC_CSP_Development_Request__c)controller.getRecord(); 
        showAttachCaseButton = false;
        if (ApexPages.CurrentPage().getParameters().containsKey('caseid')) 
        {            
            if ((ApexPages.CurrentPage().getParameters().get('caseid') != 'null') && (ApexPages.CurrentPage().getParameters().get('caseid') != null))
            {              
                c = [SELECT Id, CaseNumber, Change_Request__c FROM Case WHERE Id =: ApexPages.CurrentPage().getParameters().get('caseid')];
                strCaseNumber = c.CaseNumber; 
                showAttachCaseButton = true;
            }
        }
    }
    
    public PageReference attachCase()
    {
        
        if (ApexPages.CurrentPage().getParameters().containsKey('caseid')) 
        {    
            c.Change_Request__c = CR.Id;
            update c;
        }
        
        PageReference casePage = new ApexPages.StandardController(c).view();
        casePage.setRedirect(true);
        return casePage;
                      
    }

    public PageReference editCR() 
    {

        string strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + CR.Id + '/e';
        PageReference crPage = new PageReference(strUrl);
        
        crPage.setRedirect(true);
        return crPage;        
        
    }    
    
}