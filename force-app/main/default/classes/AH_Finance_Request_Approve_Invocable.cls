/*****************************************************************************************************
Name            : AH_Finance_Request_Approve_Invocable
Author          : Stuart Emery
Created Date    : 03/24/2020
Last Mod Date   : 03/24/2020 
Last Mod By     : Stuart Emery
Version         : 1.0
Description     : Invocable Apex Class that is called from the 'Finance Request - COVID19 Process Builder' 
				: This class approves Finance Requests
******************************************************************************************************/
public class AH_Finance_Request_Approve_Invocable 
{
    
    @InvocableMethod(label='Approve Finance Request' description='Approve the current approval step')
    
    public static void approveRequest(List<AH_Finance_Request__c> lstFinanceRequests)
    {  
        
        system.debug(' *** ENTERING AH_Finance_Request_Approve_Invocable.approveRequest() - QUERIES ISSUED = ' + Limits.getQueries());
        
        for (AH_Finance_Request__c fr : lstFinanceRequests)
        {
            
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('APPROVED BY AUTOMATED PROCESS');
            req.setAction('Approve');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            
            Id workItemId = getWorkItemId(fr.Id); 
            
            if (workItemId == null)
            {
                fr.addError('Error occured in auto-approval');
            }
            else
            {
                req.setWorkitemId(workItemId);
                //APPROVE THE REQUEST
                Approval.ProcessResult result =  Approval.process(req);
            }
        } 

        system.debug(' *** EXITING AH_Finance_Request_Approve_Invocable.approveRequest() - QUERIES ISSUED = ' + Limits.getQueries());
    } 
    
    public static Id getWorkItemId(Id targetObjectId)
    {
        Id retVal = null;
        
        for(ProcessInstanceWorkitem workItem : [SELECT p.Id from ProcessInstanceWorkitem p
                                                 WHERE p.ProcessInstance.TargetObjectId =: targetObjectId])
        {
            retVal = workItem.Id;
        }
        
        return retVal;
    }
    
}