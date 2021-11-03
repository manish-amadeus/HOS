trigger AttachSolutionToCase on Solution (after insert) 
{

    if (trigger.isInsert)
    {
        for (Solution s : trigger.new)
        {
        	if (s.Origin_Case__c != null)
        	{
            	CaseSolution cs = new CaseSolution(CaseId = s.Origin_Case__c, SolutionId = s.Id);
            	insert cs;
        	}
        }
    }
        
}