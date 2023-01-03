/****************************************************************************************
Name            : CaseControllerExtension 
Author          : Black Iron Group
Created Date    : 07/18/2010 
Last Mod Date   : 04/13/2017 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : This class is used by the VisualForce page called OverrideCase.
                : OverrideCase is setup to open everytime some views a case.
				: The need for this is because of the fact that there is no way
				: to put a trigger on the CaseSolution object that we could
				: use to update the case with the number of solutions field that
				: is used in validation rule to block case closure when not solutions 
				: are attached to a case.
				: 
****************************************************************************************/
public with sharing class CaseControllerExtension 
{

	private final Id caseId;
//	private final Case caseInst; 
    
    public CaseControllerExtension(ApexPages.StandardController controller) 
    { 
	    caseId = controller.getRecord().Id;
	    // caseInst = (Case)controller.getRecord(); 
    } 
    
    public pageReference caseRedirect() 
    {
     	if (ApexPages.CurrentPage().getParameters().containsKey('a_case_soln')) 
     	{
        	
        	Integer count = [SELECT COUNT() FROM Solution WHERE Parent_Solution__c =: ApexPages.CurrentPage().getParameters().get('a_case_soln')];
        	
        	if (count > 0) 
        	{
        		PageReference pr = Page.ParentSolution;
        		pr.getParameters().put('id', caseId);
        		return pr;
        	}
        	else 
        	{
        		CaseSolution cs = new CaseSolution(CaseId = caseId, SolutionId = ApexPages.CurrentPage().getParameters().get('a_case_soln'));
        		insert cs;
        	}
    	}
    	else if (ApexPages.CurrentPage().getParameters().containsKey('r_case_soln')) 
    	{	
    		try 
    		{ 
    			CaseSolution cs = [SELECT Id FROM CaseSolution WHERE SolutionId =: ApexPages.CurrentPage().getParameters().get('r_case_soln')];
    			delete cs;
    		}
    		catch (Exception ex) {}
    	} 
    	
 		Integer solutions = 0; 
		for (CaseSolution[] css : [SELECT Id, CaseId FROM CaseSolution WHERE CaseId =: caseId]) 
		{
			solutions += css.size();
		}
		
		Solution_Count__c sc;
		
		try 
		{ 
			sc = [SELECT Id FROM Solution_Count__c WHERE Case__c = :caseId];
			sc.Number_of_Solutions__c = solutions;
			update sc;
		}
		catch (Exception ex) 
		{
			sc = new Solution_Count__c(Case__c = caseId, Number_Of_Solutions__c = solutions);
			try 
			{
				insert sc;
			}
            catch (Exception ex2) {}
		}

        // NICC-020860 - UPDATE Number_of_Cases_Linked__c ROLLUP ON CR
        try 
        {
        	Case c = [SELECT Id, Change_Request__c FROM Case WHERE Id =: caseId]; 
            SFDC_CSP_Development_Request__c cr = [SELECT Id, Number_of_Cases_Linked__c FROM SFDC_CSP_Development_Request__c WHERE Id =: c.Change_Request__c];
            decimal caseCount = [SELECT COUNT() FROM Case WHERE Change_Request__c =: cr.Id];
            if (cr.Number_of_Cases_Linked__c != caseCount)
            {
                cr.Number_of_Cases_Linked__c = caseCount;
                update cr;
            }
        }
        catch (Exception ex3) {}
        
        
		return new pageReference('/' + caseId + '?nooverride=1');

	} 

}