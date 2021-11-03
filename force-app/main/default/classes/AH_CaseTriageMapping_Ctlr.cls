/****************************************************************************************
Name            : AH_CaseTriageMapping_Ctlr
Author          : Sean Harris
Created Date    : 05/19/2021
Last Mod Date   : 05/19/2021
Last Mod By     : Sean Harris
NICC Reference  : NICC-
Description     : Controller for the AH_CaseTriageMapping Visualforce page.
                :            
******************************************************************************************/
public class AH_CaseTriageMapping_Ctlr 
{
    
    public List<SelectOption> lstQueues {get; set;} 
    public AH_Case_Triage_Mapping__c ctm {get; set;} 
    public String selQueue {get; set;}
    public String redirectUrl {public get; private set;}
	public Boolean shouldRedirect {public get; private set;}
    public Boolean bInEdit {get; set;}
    public Boolean bHasEdit {public get; private set;}    
    
    
    public AH_CaseTriageMapping_Ctlr(ApexPages.StandardController ctlr)
    {
        
system.debug('in constructor');  
        
        redirectUrl = ctlr.view().getUrl();
        shouldRedirect = false;
        bHasEdit = FeatureManagement.checkPermission('AH_Case_Triage_Mapping_Admin');
        bInEdit = false;
        
        if (ApexPages.CurrentPage().getParameters().containsKey('id')) 
        {
            ctm = [SELECT Id, Queue_Assignment_ID__c, Queue_Assignment__c 
                   FROM AH_Case_Triage_Mapping__c 
                   WHERE Id =: ApexPages.CurrentPage().getParameters().get('id')];
        }        
        
        lstQueues = new List<SelectOption>();
        lstQueues.add(new SelectOption('0', 'SELECT QUEUE'));
        
        for (Group grp : [SELECT Id, Name FROM Group WHERE Type = 'Queue' ORDER BY Name ASC])
        {
            lstQueues.add(new SelectOption(grp.Id, grp.Name));
        }
        if (ctm.Queue_Assignment_ID__c != null)
        {
            selQueue = ctm.Queue_Assignment_ID__c;
        }
    }
    
    public pageReference saveQueueChange()
    {

        bInEdit = false;
        shouldRedirect = true;
        
        ctm.Queue_Assignment_ID__c = selQueue;
        update ctm;
        
        ctm = [SELECT Id, Queue_Assignment_ID__c, Queue_Assignment__c 
               FROM AH_Case_Triage_Mapping__c 
               WHERE Id =: ApexPages.CurrentPage().getParameters().get('id')];  

        return null;

    }
    
    public pageReference toggleEdit()
    {
        bInEdit = true;
        return null;
    }
    
    public pageReference doCancel()
    {
        bInEdit = false;
        shouldRedirect = true;
        return null;
    }
    
}