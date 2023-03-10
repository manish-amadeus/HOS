public with sharing class SolutionDetailsExtension 
{

    public Case c;
    public Solution s;
    public String strCaseNumber {get; set;} 
    public Boolean showAttachCaseButton {get; set;} 

    private List<String> lstResos;
    public string currentResolution {get; set;}  
    public integer iCurrentResolution;
    public integer resoCount = 0;    
    
    
    public SolutionDetailsExtension(ApexPages.StandardController controller) 
    {       
        this.s = (Solution)controller.getRecord(); 
     
        showAttachCaseButton = false;
        getResolutions();
       
        if (ApexPages.CurrentPage().getParameters().containsKey('caseid')) 
        {            
            if ((ApexPages.CurrentPage().getParameters().get('caseid') != 'null') && (ApexPages.CurrentPage().getParameters().get('caseid') != null))
            {              
                c = [SELECT Id, CaseNumber FROM Case WHERE Id =: ApexPages.CurrentPage().getParameters().get('caseid')];
                strCaseNumber = c.CaseNumber; 
                showAttachCaseButton = true;
            }
        }
    }
    
    public PageReference attachCase()
    {
        if (ApexPages.CurrentPage().getParameters().containsKey('caseid')) 
        {    
            CaseSolution cs = new CaseSolution(CaseId = c.Id, SolutionId = s.Id);
            insert cs;
        }
        
        PageReference casePage = new ApexPages.StandardController(c).view();
        casePage.setRedirect(true);
        return casePage;
                      
    }

    public PageReference editSol() 
    {

        string strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + s.Id + '/e';
        PageReference solPage = new PageReference(strUrl);
        
        solPage.setRedirect(true);
        return solPage;        
        
    }
    
    
    public void getResolutions()
    {
		
        lstResos = new List<String>();
        List<String> strResos;
        currentResolution = '';
        iCurrentResolution = 1;
        resoCount = 1;
        
        if (s.SolutionNote != null)
        {
            strResos = s.SolutionNote.Split('RESOLUTION #');            
        }
        
        if (strResos != null)
        {
            
            for (integer i = 0; (i < (strResos.Size() - 1)); i++)
            {
                String s = strResos[(i + 1)];
                lstResos.add('RESOLUTION #' + s);
            }   
            
            iCurrentResolution = 0;
            
            if (lstResos.Size() == 0)
            {
                currentResolution = s.SolutionNote;
                iCurrentResolution = 1;
                resoCount = 1;
            }
            else
            {
                currentResolution = lstResos[iCurrentResolution]; 
                resoCount = (lstResos.Size() - 1);
            }        
            
        }
        
    }

    // NAVIGATION METHODS
    public PageReference moveFirst() 
    { 
        iCurrentResolution = 0;
        currentResolution = lstResos[0];
        return null;
    }
    
    public PageReference movePrev() 
    { 
        iCurrentResolution -= 1;
        currentResolution = lstResos[iCurrentResolution];
        return null;
    }
    
    public PageReference moveNext() 
    { 
        iCurrentResolution += 1;
        currentResolution = lstResos[iCurrentResolution];
        return null;
    }
    
    public PageReference moveLast() 
    { 
        iCurrentResolution = resoCount;
        currentResolution = lstResos[iCurrentResolution];
        return null;
    }      

    // PAGINATION
    public Integer getCurrentReso() 
    {
        integer i = lstResos.Size();
        if (i == 0)
        {
            i = 1;
        }
        else
        {
            i = (iCurrentResolution + 1);
        }
        return i;
    }
    
    public Integer getTotalResos() 
    {
        integer i = lstResos.Size();
        if (i == 0)
        {
            i = 1;
        }
        return i;
    }
    
    public Boolean getDisablePrevious() 
    { 
        if ((iCurrentResolution == 0) || (lstResos.Size() == 0))
        {
            return true; 
        }
        else 
        {
            return false;
        }
    }
    
    public Boolean getDisableNext() 
    {         
        if (iCurrentResolution == resoCount) 
        {
            return true; 
        }
        else 
        {
            return false;
        }
    }           

}