/****************************************************************************************
Name            : psaMilestoneBatchGenerationAi_GenerateMilestones
Author          : CLD
Created Date    : October 31, 2011
Description     : Generates Milestones for a project based on the Product Package selected
                : in the creation of the record, along with the other parameters specified
******************************************************************************************/
trigger psaMilestoneBatchGenerationAi_GenerateMilestones on Milestone_Batch_Generation__c (after insert) 
{
    public static final String MILESTONE_STATUS_DRAFT = 'Draft/Tentative';
    
    List<Id> packageIds = new List<Id>();
    List<Id> accountIds = new List<Id>();
    List<id> projectIds = new List<Id>();
    List<pse__Milestone__c> newMilestones = new List<pse__Milestone__c>();
    
    // Get a list of all of the packages referenced, in order to get all package milestones
    for (Milestone_Batch_Generation__c mbg: Trigger.New)
    {
        packageIds.add(mbg.Product_Package__c);
        accountIds.add(mbg.Managed_Property__c);
        projectIds.add(mbg.Project__c);
    }
    
    // Get information on all of the package milestones that will be used to create milestones
    Map<Id, PSA_Product_Package_Milestone__c> packageMilestones = new Map<Id, PSA_Product_Package_Milestone__c>(
        [select Product_Package__c, Milestone_Name_Prefix__c, Percent__c, Milestone_Type__c, Offset_Days__c, Practice__c
            from PSA_Product_Package_Milestone__c where Product_Package__c in :packageIds order by Offset_Days__c]);
    
    // Get account names of managed properties to use in the milestone naming
    Map<Id, Account> managedProperties = new Map<Id, Account>(
        [select Name, AccountNumber from Account where Id in :accountIds]);
    
    // Get the Project currencies so we can set them in the milestones
    Map<Id, pse__Proj__c> projects = new Map<Id, pse__Proj__c> (
        [select Id, CurrencyIsoCode, Opportunity_Number__c from pse__Proj__c where Id in :projectIds]);
    
    for (Milestone_Batch_Generation__c mbg: Trigger.New)
    {
        try
        {
            // Get the project currency
            String projectCurrency = projects.get(mbg.Project__c).CurrencyIsoCode;
            String projectOpportunityNum = projects.get(mbg.Project__c).Opportunity_Number__c;
            System.debug('***********The project currency is: ' + projectCurrency);
            System.debug('***********The project opportunity number is: ' + projectOpportunityNum);
            
            // Iterate through the set of package milestones that need to be created
            for(Id packageMilestoneId: packageMilestones.keySet())
            {
                PSA_Product_Package_Milestone__c packageMilestone = packageMilestones.get(packageMilestoneId);
                if(packageMilestone.Product_Package__c == mbg.Product_Package__c)
                {
                    // Construct a new Milestone
                    // Note: Opportunity and Approver are already set separately through separate triggers
                    // TO DO: Set Milestone Name to be Unique. For now, append the name of the managed property
                    Date firstMilestoneDate = mbg.First_Milestone_Date__c;
                    Integer offsetDays = packageMilestone.Offset_Days__c.intValue();
                    Date targetDate = firstMilestoneDate.addDays(offsetDays);
                    String managedPropertyName = '';
                    
                    if(mbg.Managed_Property__c != null) 
                    {
                        //managedPropertyName = ': ' + managedProperties.get(mbg.Managed_Property__c).Name;
                        managedPropertyName = ' Property: ' + managedProperties.get(mbg.Managed_Property__c).AccountNumber;
                        System.debug('Managed property acct for milestone: ' + managedPropertyName);    
                    }
                    else
                    {
                        managedPropertyName = '';
                    }
                    
                    // Provide Override Practice audit notes if a practice is specified for the
                    // new Milestone different from the Project practice
                    Id milestonePracticeId = packageMilestone.Practice__c;
                    boolean adminGlobalEdit = false;
                    String auditNotes = null;
                    if(milestonePracticeId != null && milestonePracticeId != mbg.Project__r.pse__Practice__c)
                    {
                        // Practice was supplied and doesn't match project.  Add override practice.
                        adminGlobalEdit = true;
                        auditNotes = 'Override Project Practice: ' + System.Now() + ' User: ' + UserInfo.getUserName();
                    }
                    else
                    {
                        // Practice was not supplied or already matches project, so don't add override
                        milestonePracticeId = null;
                    }
                    
                    String milestoneName = packageMilestone.Milestone_Name_Prefix__c + ' (' + projectOpportunityNum + ')' + managedPropertyName;
                    
                    pse__Milestone__c milestone = new pse__Milestone__c (
                        pse__Project__c = mbg.Project__c,
                        Name = milestoneName,
                        pse__Closed_for_Expense_Entry__c = true,
                        pse__Closed_for_Time_Entry__c = true,
                        Managed_Property__c = mbg.Managed_Property__c,
                        pse__Milestone_Amount__c = mbg.Total_Package_Amount__c * (packageMilestone.Percent__c/100),
                        Milestone_Type__c = packageMilestone.Milestone_Type__c,
                        pse__Admin_Global_Edit__c = adminGlobalEdit,
                        pse__Override_Project_Practice__c = milestonePracticeId,
                        pse__Audit_Notes__c = auditNotes,
                        pse__Status__c = MILESTONE_STATUS_DRAFT,
                        pse__Target_Date__c = targetDate,
                        CurrencyIsoCode = projectCurrency
                    );
                    
                    // Add the new milestone to a list for batch insert
                    newMilestones.add(milestone);
                }
            }
        }
        catch(Exception e)
        {
            System.debug('Error creating milestone: ' + e.getMessage());
            mbg.addError('Error creating milestone: ' + e.getMessage());
        }
    }
    
    // Create the new milestones
    if(newMilestones.size() > 0)
    {
        Database.SaveResult[] results = Database.insert(newMilestones);
        for(Database.SaveResult sr: results)
        {
            if(!sr.isSuccess())
            {
                Database.Error err = sr.getErrors()[0];
                System.debug(err.getMessage());
            }
        }
    }
}