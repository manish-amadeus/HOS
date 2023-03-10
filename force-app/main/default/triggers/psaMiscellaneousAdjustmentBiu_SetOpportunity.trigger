/****************************************************************************************
Name            : psaMiscellaneousAdjustmentBiu_SetOpportunity
Author          : CLD
Created Date    : November 22, 2011
Description     : When a misc adjustment is created or updated, obtain the Opportunity associated with 
                : the misc adjustment's project and set it in the misc adjustment.  This is needed in order
                : to allow filtered lookup of the Softrax Order Sequence Number on the misc adjustment.
******************************************************************************************/
trigger psaMiscellaneousAdjustmentBiu_SetOpportunity on pse__Miscellaneous_Adjustment__c (before insert, before update) 
{
    List<Id> projectIds = new List<Id>();
    
    // Get Ids of projects associated with the misc adjustments, since references to projects
    // aren't available before insert
    for (pse__Miscellaneous_Adjustment__c m: Trigger.new) {    
        projectIds.add(m.pse__Project__c);
    }
    
    Map<Id, pse__Proj__c> projects = new Map<Id, pse__Proj__c>(
        [select Id, Name, pse__Opportunity__c from pse__Proj__c where id in :projectIds]);
    
    for (pse__Miscellaneous_Adjustment__c m: Trigger.new) 
    {
        try
        {
            // Set the project's opportunity in the misc adjustment
            Id opportunityId = projects.get(m.pse__Project__c).pse__Opportunity__c;
            m.Opportunity__c = opportunityId;
        }
        catch(Exception e)
        {
            System.debug('Error setting opportunity in misc adjustment: ' + e.getMessage());
            m.addError('Error setting opportunity in misc adjustment: ' + e.getMessage());
        }
    }
}