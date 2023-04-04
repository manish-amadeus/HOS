trigger ShareToAssociate on StatusReport__c (after insert, after update) 
{

    // We only execute the trigger after a record has been inserted or updated
    // because we need the Id of the StatusReport__c record to already exist.
    if (trigger.isInsert)
    {
     
        // Allocate storage for a list of StatusReport__Share records.
        List<StatusReport__Share> ReportShares = new List<StatusReport__Share>();

        // For each of the Status Report records being inserted, do the following:
        for (StatusReport__c  rpt  : trigger.new)
        {

            // Create a new StatusReport__Share record to be inserted in to the StatusReport__Share table.
            StatusReport__Share compShr = new StatusReport__Share();
            
            // Populate the StatusReport__Share record with the ID of the record to be shared.
            compShr.ParentId = rpt.Id;
            
            // Then, set the ID of user or group being granted access. In this case,
            // we’re setting the Id of the Associate__c  
            compShr.UserOrGroupId = rpt.Associate__c;
            
            // Specify that the Associate should have read access 
            compShr.AccessLevel = 'read';
            
            // Associate_Share__c is the Apex Sharing Reason
            compShr.RowCause = Schema.StatusReport__Share.RowCause.Associate_Share__c;
            
            // Add the new Share record to the list of new Share records.
            ReportShares.add(compShr);
            
        }
        
        // Insert all of the newly created Share records and capture save result 
        Database.SaveResult[] ReportSharesInsertResult = Database.insert(ReportShares,false);
        
        // Add Error handling code at a later date    
    
    }
    
}