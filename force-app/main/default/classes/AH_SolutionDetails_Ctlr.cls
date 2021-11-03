/****************************************************************************************
Name            : AH_SolutionDetails_Ctlr
Author          : Sean Harris
Created Date    : 04/10/2019
Last Mod Date   : 04/10/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-034157
Description     : Controller for the AH_SolutionDetails Visualforce page.
                :            
******************************************************************************************/
public class AH_SolutionDetails_Ctlr 
{
    
    public Case c;
    public Solution s;
    public String strCaseNumber {get; set;} 
    public Boolean attachCaseButtonVisible {get; set;}     

    public AH_SolutionDetails_Ctlr(ApexPages.StandardController controller) 
    {      
        
        this.s = (Solution)controller.getRecord();   

        if (ApexPages.CurrentPage().getParameters().containsKey('caseid')) 
        {            

            attachCaseButtonVisible = false; 
            
            if ((ApexPages.CurrentPage().getParameters().get('caseid') != 'null') && 
                (ApexPages.CurrentPage().getParameters().get('caseid') != null) && 
                (ApexPages.CurrentPage().getParameters().get('caseid') != '')
               )
            {    
                c = [SELECT Id, CaseNumber FROM Case WHERE Id =: ApexPages.CurrentPage().getParameters().get('caseid')];
                strCaseNumber = c.CaseNumber; 
                attachCaseButtonVisible = true; 
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

}