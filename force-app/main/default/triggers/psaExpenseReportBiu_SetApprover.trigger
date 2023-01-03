/****************************************************************************************
Name            : psaExpenseReportBiu_SetApprover
Author          : CLD
Created Date    : October 28, 2011
Description     : When an expense report is saved (but before it is approved) this sets the
                : expense report's Approver.  If the expense is an internal one, it uses the 
                : user's manager (User.Manager).  If it is for a client project, it looks up the
                : Central Expense Approver from the Project's region and sets that user as the approver. 
******************************************************************************************/
trigger psaExpenseReportBiu_SetApprover on pse__Expense_Report__c (before insert, before update) 
{   
	// Expenses submitted against Projects whose name starts with "Internal Expenses" 
	// will be treated as internal expenses and routed to the submitter's manager. 
    public static final String INTERNAL_EXPENSE_PROJECT='Internal Expenses';
    
    // Create a set of unique project Ids and Contact(Resource) Ids associated with the expense report entries
    Set<Id> projectIds = new Set<Id>();
    Set<Id> resourceIds = new Set<Id>();
    

    for (pse__Expense_Report__c er : Trigger.new) 
    {
        projectIds.add(er.pse__Project__c);
        resourceIds.add(er.pse__Resource__c);
    }

    // Look up associated projects to get the project name, which will determine whether it is the Internal Expense project   
    Map<Id, pse__Proj__c> projects = new Map<Id, pse__Proj__c>(
        [select Name, pse__Region__c, pse__Region__r.Central_Expense_Approver__c from pse__Proj__c where id in :projectIds]);
        
    // Look up associated resources to get Resource Region which will provide central expense approver
    Map<Id, Contact> resources = new Map<Id, Contact>(
        [select pse__Region__r.Name, pse__salesforce_user__r.ManagerId from Contact where id in :resourceIds]);
        
    // Use the map to set the Approver value on Expense Reports when:
    // Expense is not already approved
    // Expense is not associated with the "Internal Expense" project (different approval rules apply)
    // (took this out) Approver is not already set
    for (pse__Expense_Report__c er: Trigger.new) 
    {
    	try
    	{
	        // Only manage auto approval setting if status is 'Submitted', the entry is specified as billable
	        boolean expApproved = er.pse__Approved__c;
	        System.debug('Expense Report approved: ' + expApproved);
	        String projectName = projects.get(er.pse__Project__c).Name;
	        System.debug('Project: ' + projectName);
	        
	        if (!expApproved) 
	        {
	            System.debug('Expense not approved.');
	            if(!projectName.startsWith(INTERNAL_EXPENSE_PROJECT))
	            {
	                System.debug('Expense not internal.');
	                String regionName = resources.get(er.pse__Resource__c).pse__Region__r.Name;
	                System.debug('Region ' + regionName);
	                Id approver = projects.get(er.pse__Project__c).pse__Region__r.Central_Expense_Approver__c;
	                System.debug('Central Expense Approver: ' + approver);
	                if(approver==null)
	                {
	                    er.addError('Central expense approver for region ' + regionName + ' not set.');
	                }
	                er.pse__Approver__c = approver;
	            }
	            else
	            {
	                System.debug('Expense is internal. Approver will be User.Manager');
	                Id manager = resources.get(er.pse__Resource__c).pse__Salesforce_User__r.ManagerId;
	                if(manager==null)
	                {
	                    er.addError('Manager for submitting resource not set in User record.');
	                }
	                er.pse__Approver__c = manager;
	            }
	        }
	        else
	        {
	            System.debug('Expense already approved or internal. No changes to make.');
	        }
    	}
    	catch(Exception e)
    	{
    		System.debug('Error setting expense report approver: ' + e.getMessage());
    		er.addError('Error setting expense report approver: ' + e.getMessage());
    	}
    }
}