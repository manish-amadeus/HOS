/****************************************************************************************
Name            : psaBillingEventItemBi_AddInfoFromMilestones
Author          : CLD
Created Date    : November 3, 2011
Description     : When a Billing Event Item is created during billing event generation,
                : if the item is of the Milestone type, this trigger performs a lookup
                : on the associated milestone, gets its Softrax Order Sequence Number, and
                : sets in in the new record's Softrax Order Sequence Number field so that 
                : it is available for Softrax integration.
                : Also, if there is a "Managed Property" Account associated with the Milestone,
                : this places the name of the account in the Managed Property Name field of
                : the billing event item.
                : Also, this sets the Billing Event Item description so that it includes information
                : about the milestone on related assignments, the milestone name, and dates
******************************************************************************************/
trigger psaBillingEventItemBi_AddInfoFromMilestones on pse__Billing_Event_Item__c (before insert) 
{
    public static final String BEI_CATEGORY_MILESTONE = 'Milestone';
  
    // Get the object Ids of any Milestones in the batch
    List<Id> milestoneIds = new List<Id>();
    for(pse__Billing_Event_Item__c bei: Trigger.New)
    {
        String category = bei.pse__Category__c;
        String itemObjectId = bei.pse__Object_Id__c;
        System.debug('BEI Category: ' + category + ' BEI Object Id: ' + itemObjectId);
        if(category.equals(BEI_CATEGORY_MILESTONE))
        {
            milestoneIds.add((Id)itemObjectId);
        }
    }
        
    // Process if there were milestones in tbe billing event items
    if(milestoneIds.size() > 0)
    {       
        // Get milestone info
        Map<Id, pse__Milestone__c> milestones = new Map<Id, pse__Milestone__c>(
            [select Id, Name, Softrax_Order_Sequence_Number__c, Managed_Property__r.Name, pse__Actual_Date__c from pse__Milestone__c where Id in :milestoneIds]);
    
        // Get any assignments related to the milestones
        List<pse__Assignment__c> assignments = new List<pse__Assignment__c> (
            [select pse__Milestone__c, pse__Start_Date__c, pse__End_Date__c, pse__Resource__r.Name from pse__Assignment__c where pse__Milestone__c in :milestoneIds ]);
        
        // Add the softrax order sequence number from the billing event item's associated milestone
        for(pse__Billing_Event_Item__c bei: Trigger.New)
        {
            try
            {
                pse__Milestone__c milestone = milestones.get((Id)bei.pse__Object_Id__c);
                if(milestone!=null)
                {
                    decimal softraxOSN = milestone.Softrax_Order_Sequence_Number__c;
                    String managedPropertyName = milestone.Managed_Property__r.Name;
                    System.debug('*** Softrax OSN: ' + softraxOSN);
                    System.debug('*** Managed Property: ' + managedPropertyName);
                    bei.Softrax_Order_Sequence_Number__c = softraxOSN;
                    bei.Managed_Property_Name__c = managedPropertyName;
                    
                    // Iterate through any assignments related to milestone and add their info
                    // to the bei invoice details field
                    String invoiceDesc = '';
                    boolean foundAssignment = false;
                    if(assignments!=null && assignments.size() > 0)
                    {
                        for(pse__Assignment__c assignment : assignments)
                        {
                            Id milestoneId = assignment.pse__Milestone__c;
                            if(milestoneId != null && milestoneId == milestone.Id)
                            {
                                System.debug('*** Found milestone assignment: ' + assignment.pse__Resource__r.Name);
                                
                                if(foundAssignment)
                                {
                                    invoiceDesc = invoiceDesc + '\r\n';
                                }
                                
                                invoiceDesc = invoiceDesc + assignment.pse__Resource__r.Name + ' - ' + String.valueOf(assignment.pse__Start_Date__c) +
                                    ' - ' + String.valueOf(assignment.pse__End_Date__c) + ' - ' + milestone.Name;
                                
                                if(milestone.Managed_Property__r.Name != null)
                                {
                                    invoiceDesc = invoiceDesc + ' - ' + milestone.Managed_Property__r.Name;
                                }

                                foundAssignment = true;
                            }
                        }
                    }
                    
                    // If there are no assignments associated with the milestone, create a bei 
                    // description with just milestone info
                    if(!foundAssignment)
                    {
                        invoiceDesc = String.valueOf(milestone.pse__Actual_Date__c) + ' - ' + milestone.Name;
                        if(milestone.Managed_Property__r.Name != null)
                        {
                            invoiceDesc = invoiceDesc + ' - ' + milestone.Managed_Property__r.Name;
                        }
                    }
                    
                    // Set the billing event item description. If it is longer than 255 characters chop it off.
                    System.debug('*** Invoice Description for BEI: ' + invoiceDesc);
                    if(invoiceDesc.length() > 255) invoiceDesc = invoiceDesc.substring(0, 254);
                    bei.Details_For_Invoice__c = invoiceDesc;
                }
            }
            catch(Exception e)
            {
                System.debug('Error setting milestone information in billing event item: ' + e.getMessage());
                bei.addError('Error setting milestone information in billing event item: ' + e.getMessage());
            }
        }
    }
}