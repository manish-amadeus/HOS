/****************************************************************************************
Name            : Psa411ReportExtract
Author          : CLD
Created Date    : December 30, 2011
Description     : Performs queries and loads data into 6 custom objects that will allow 
                : export of data for generating a periodic 411 report.  The extract can 
                : be performed as an Apex Scheduled Job by invoking the execute() method
                : from the job scheduler.  It also allows the extract to be invoked from
                : the salesforce UI by manually creating a new PSA 411 Report record. A
                : trigger on that object calls the runExtractFromUI method to allow ad hoc
                : extraction of report data.
******************************************************************************************/
global class Psa411ReportExtract implements Schedulable
{
    
    Public List<Id> assignmentOpportunities;
    Map<Id, Id> assignmentProjects;
    Map<Id, Id> assignmentAccounts;
    Decimal daysPast = 0;
    Decimal daysForward = 1;
    
    public Psa411ReportExtract()
    {
        assignmentOpportunities = new List<Id>();
        assignmentProjects = new Map<Id, Id>();
        assignmentAccounts = new Map<Id, Id>();
    }
    
    // When a report header has already been created from the UI, use its information to perform the extract. This is invoked by the after insert trigger on PSA_411_Report__c
    public void runExtractFromUI(PSA_411_Report__c reportHeader)
    {
        extractReportData(reportHeader);
    }
    
	// Executes the batch extraction of report data, invoked as a Scheduled Apex job. This called runScheduledExtract in order to create a new PSA_411_Report__c using from/to dates calculated from custom settings
    global void execute(SchedulableContext SC)
    {
        runScheduledExtract();
    }
    
    // Create a report header automatically using custom settings to determine from and to dates, then run the exract
    public void runScheduledExtract()
    {
        PSA_411_Report__c reportHeader = createReport();
        extractReportData(reportHeader);
    }
    
    // Calls the queries to load detail tables
    private void extractReportData(PSA_411_Report__c reportHeader)
    {
        extractAssignmentInfo(reportHeader);        
        extractProductInfo(reportHeader.Id, reportHeader.Name, assignmentOpportunities);        
        extractOtherAssignmentInfo(reportHeader.Id, reportHeader.Name, assignmentProjects);        
        extractAssetInfo(reportHeader.Id, reportHeader.Name, assignmentAccounts);        
        extractCaseInfo(reportHeader.Id, reportHeader.Name, assignmentAccounts);       
    }
    
    // Creates a PSA_411_Report__c record, setting from and to dates for the report based on custom settings
    private PSA_411_Report__c createReport()
    {
        
        PSA_411_Report__c report = new PSA_411_Report__c();
        
        daysPast = 1;
        daysForward = 1;
        
        Date fromDate = System.today() - Integer.valueOf(daysPast);
        Date toDate = System.today() + Integer.valueOf(daysForward);
        report.From_Date__c = fromDate;
        report.To_Date__c = toDate;
        report.Run_As_Scheduled_Batch__c = true;
        insert report;
        
        PSA_411_Report__c updatedReport = [SELECT Id, Name, From_Date__c, To_Date__c FROM PSA_411_Report__c WHERE Id =: report.Id];
        return updatedReport;
        
    }
    
    //  Performs the main query to get assignment information. Values obtained in this query will load teh PSA_411_Assignment__c object and will be used in subsequent queries.
    private void extractAssignmentInfo(PSA_411_Report__c reportHeader)
    {
        
        List<PSA_411_Assignment__c> assignmentInfoList = new List<PSA_411_Assignment__c>();
        
        pse__Assignment__c [] assignments = 
            [SELECT Id, Name, pse__Project__c, pse__Project__r.Id, pse__Project__r.Name, pse__Resource__r.Id, pse__Resource__r.Name, pse__Start_Date__c, pse__End_Date__c, 
             pse__Project__r.pse__Project_Manager__r.Name, pse__Project__r.pse__Account__r.Id, pse__Project__r.pse__Account__r.Name, pse__Project__r.Account_Number__c, Milestone_Practice_Name__c, 
             pse__Project__r.pse__Account__r.Parent.Name, pse__Project__r.pse__Notes__c, pse__Project__r.Customer_Project_Contact__r.Name,
             pse__Project__r.Customer_Project_Contact__r.Phone, pse__Project__r.Customer_Project_Contact__r.Email,
             pse__Project__r.pse__Account__r.ShippingStreet, pse__Project__r.pse__Account__r.ShippingCity, pse__Project__r.pse__Account__r.ShippingState, pse__Project__r.pse__Account__r.ShippingPostalCode, pse__Project__r.pse__Account__r.ShippingCountry,
             pse__Milestone__r.Managed_Property__r.ShippingStreet, pse__Milestone__r.Managed_Property__r.ShippingCity, pse__Milestone__r.Managed_Property__r.ShippingState, pse__Milestone__r.Managed_Property__r.ShippingPostalCode, pse__Milestone__r.Managed_Property__r.ShippingCountry, 
             pse__Project__r.Opportunity_Number__c, pse__Project__r.pse__Opportunity__r.MPE_Cluster__r.Name, pse__Project__r.pse__Opportunity__r.Owner.Name,
             pse__Project__r.pse__Project_Status_Notes__c, pse__Project__r.pse__Opportunity__c, Contact_Name__r.Name, Contact_Name__r.Phone, Contact_Name__r.Email
             FROM pse__Assignment__c
             WHERE pse__Status__c = 'Scheduled'
             AND pse__Start_Date__c <= :reportHeader.To_Date__c
             AND pse__End_Date__c >= :reportHeader.From_Date__c 
            ];
        
        if (assignments != null && assignments.size() > 0)
        {
            for (pse__Assignment__c assignment : assignments)
            {
                PSA_411_Assignment__c assignmentInfo = new PSA_411_Assignment__c (
                    Name = assignment.Name,
                    Report_Number__c = reportHeader.Name,
                    Assignment__c = assignment.Id,
                    Project__c = assignment.pse__Project__r.Id,
                    Project_Name__c = assignment.pse__Project__r.Name,
                    Resource__c = assignment.pse__Resource__r.Id,
                    Resource_Name__c = assignment.pse__Resource__r.Name,
                    Start_Date__c = assignment.pse__Start_Date__c,
                    End_Date__c = assignment.pse__End_Date__c,
                    Project_Manager__c = assignment.pse__Project__r.pse__Project_Manager__r.Name,
                    Account__c = assignment.pse__Project__r.pse__Account__r.Id,
                    Account_Name__c = assignment.pse__Project__r.pse__Account__r.Name,
                    Account_Number__c = assignment.pse__Project__r.Account_Number__c,
                    Type_of_Service__c = assignment.Milestone_Practice_Name__c,
                    Management_Company__c = assignment.pse__Project__r.pse__Account__r.Parent.Name,
                    Project_Notes__c = assignment.pse__Project__r.pse__Notes__c,
                    Opportunity_Number__c = assignment.pse__Project__r.Opportunity_Number__c,
                    Opportunity__c = assignment.pse__Project__r.pse__Opportunity__c,
                    DMPE_Cluster__c = assignment.pse__Project__r.pse__Opportunity__r.MPE_Cluster__r.Name,
                    Opportunity_Owner__c = assignment.pse__Project__r.pse__Opportunity__r.Owner.Name, 
                    Project_Status_Notes__c = assignment.pse__Project__r.pse__Project_Status_Notes__c,
                    PSA_411_Report__c = reportHeader.Id
                );
                
                // The assignment may have a contact associated with it. If so, use the assignment contact info. Otherwise, use the customer project contact info from the assignment project
                String assignmentContactName = assignment.Contact_Name__r.Name;
                
                assignmentInfo.Customer_Project_Contact__c = assignment.pse__Project__r.Customer_Project_Contact__r.Name;
                assignmentInfo.Customer_Contact_Phone__c = assignment.pse__Project__r.Customer_Project_Contact__r.Phone;
                assignmentInfo.Customer_Contact_Email__c = assignment.pse__Project__r.Customer_Project_Contact__r.Email;  
                
                if (assignmentContactName != null && assignmentContactName.length() > 0)
                {
                    assignmentInfo.Customer_Project_Contact__c = assignment.Contact_Name__r.Name;
                    assignmentInfo.Customer_Contact_Phone__c = assignment.Contact_Name__r.Phone;
                    assignmentInfo.Customer_Contact_Email__c = assignment.Contact_Name__r.Email;
                }
                
                // Set the physical address to the address of the milestone's managed property, if it exists Otherwise use the shipping address of the project's account
                String propertyAddress = null;
                String managedPropertyStreet = assignment.pse__Milestone__r.Managed_Property__r.ShippingStreet;
                propertyAddress = assignment.pse__Project__r.pse__Account__r.ShippingStreet + ' ' + assignment.pse__Project__r.pse__Account__r.ShippingCity + ' ' + assignment.pse__Project__r.pse__Account__r.ShippingState + ' ' + assignment.pse__Project__r.pse__Account__r.ShippingPostalCode + ' ' + assignment.pse__Project__r.pse__Account__r.ShippingCountry;
                
                if (managedPropertyStreet != null && managedPropertyStreet.length() > 0)
                {
                    propertyAddress = assignment.pse__Milestone__r.Managed_Property__r.ShippingStreet + ' ' + assignment.pse__Milestone__r.Managed_Property__r.ShippingCity + ' ' + assignment.pse__Milestone__r.Managed_Property__r.ShippingState + ' ' + assignment.pse__Milestone__r.Managed_Property__r.ShippingPostalCode + ' ' + assignment.pse__Milestone__r.Managed_Property__r.ShippingCountry;
                }
              
                assignmentInfo.Property_Address__c = propertyAddress;     
                
                assignmentInfoList.add(assignmentInfo);
                
                // Add the opportunity Id to the opportunity list in order to make it available for looking up products
                assignmentOpportunities.add(assignment.pse__Project__r.pse__Opportunity__c);
                
                // Add Project Id to list for lookup of other assignments
                assignmentProjects.put(assignment.pse__Project__c, assignment.pse__Project__c);
                
                // Add Account Id to account list for lookup of assets and cases
                assignmentAccounts.put(assignment.pse__Project__r.pse__Account__r.Id, assignment.pse__Project__r.pse__Account__r.Id);
            }
        }
        
        // Create PSA_411_Assignment__c records
        if (assignmentInfoList.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(assignmentInfoList);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess()) { Database.Error err = sr.getErrors()[0]; }
            }
        }
    }
    
    // Queries OpportunityLineItems using opportunities gathered from the assignment query, and loads the PSA_411_Product__c table with Opportunity Product info related to the assignments found
    @future
    private static void extractProductInfo(Id reportId, String reportName, List<Id> opportunitiesForAssignments)
    {
        
        List<PSA_411_Product__c> oppLineItems = new List<PSA_411_Product__c>();
        
        List<OpportunityLineItem> oppProducts = new List<OpportunityLineItem>(
            [SELECT Id, OpportunityId, Quantity, Description, UnitPrice, 
             TotalPrice, PricebookEntry.Name, PricebookEntry.ProductCode, Family__c, PricebookEntry.Product2.Unit__c
             FROM OpportunityLineItem
             WHERE OpportunityId in : opportunitiesForAssignments]);
        
        if (oppProducts != null && oppProducts.size() > 0)
        {
            for (OpportunityLineItem oppProduct : oppProducts)
            {
                PSA_411_Product__c product411 = new PSA_411_Product__c(
                    Report_Number__c = reportName,
                    PSA_411_Report__c = reportId,
                    Name = oppProduct.PricebookEntry.ProductCode,
                    Opportunity__c = oppProduct.OpportunityId,
                    Quantity__c = oppProduct.Quantity,
                    Description__c = oppProduct.Description,
                    Sales_Price__c = oppProduct.UnitPrice,
                    Total_Price__c = oppProduct.TotalPrice,
                    Revenue_Category__c = oppProduct.Family__c,
                    Product_Name__c = oppProduct.PricebookEntry.Name,
                    Unit__c = oppProduct.PricebookEntry.Product2.Unit__c
                );
                
                oppLineItems.add(product411);
            }
        }
        
        oppProducts = null;
        opportunitiesForAssignments = null;
        
        // Create PSA_411_Product__c records
        if (oppLineItems.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(oppLineItems);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess()) { Database.Error err = sr.getErrors()[0];} 
            }
        }
        
        oppLineItems = null;
    }
    
    // Queries Assignments using Projects gathered from the assignment query, and loads the PSA_411_OtherAssignments__c table with other Assignment info related to the projects for assignments found
    @future
    private static void extractOtherAssignmentInfo(Id reportId, String reportName, Map<Id, Id> projectsForAssignments)
    {
        
        List<PSA_411_OtherAssignments__c> other411Assignments = new List<PSA_411_OtherAssignments__c>();
        Set<Id> projectIds = projectsForAssignments.keySet();
        
        List<pse__Assignment__c> assignments = new List<pse__Assignment__c>([
            SELECT Id, Name, pse__Resource__r.Name, pse__Start_Date__c, pse__End_Date__c, pse__Project__c
            FROM pse__Assignment__c
            WHERE pse__Project__c in :projectIds
            AND pse__Status__c = 'Scheduled'
            // SMH - ADDED THIS LIMIT TO FIX THIS ISSUE:
            // System.LimitException: Too many DML rows: 10001 
            // Stack Trace: Class.Psa411ReportExtract.extractOtherAssignmentInfo: line 321, column 1 
            // BECAUSE THIS FUNCTION IS NOT USED, IT SHOULD NOT HAVE ADVERSE AFFECTS 
            // -- START  
            LIMIT 1000
            // -- END              
        ]);
        
        if (assignments != null && assignments.size() > 0)
        {
            for (pse__Assignment__c assignment : assignments)
            {
                PSA_411_OtherAssignments__c other411Assignment = new PSA_411_OtherAssignments__c(
                    Report_Number__c = reportName,
                    Name = assignment.Name,
                    Assignment__c = assignment.Id,
                    Project__c = assignment.pse__Project__c,
                    Resource_Name__c = assignment.pse__Resource__r.Name,
                    Start_Date__c = assignment.pse__Start_Date__c,
                    End_Date__c = assignment.pse__End_Date__c,
                    PSA_411_Report__c = reportId
                );
                
                other411Assignments.add(other411Assignment);
            }
        }
        
        assignments = null;
        
        // Create PSA_411_OtherAssignments__c records
        if (other411Assignments.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(other411Assignments);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess()) { Database.Error err = sr.getErrors()[0]; }
            }
        }
        
        other411Assignments = null;
    }
    
    // Queries Assets using Accounts gathered from the assignment query, and loads the PSA_411_Asset__c table with Asset info related to the accounts found
    @future
    private static void extractAssetInfo(Id reportId, String reportName, Map<Id, Id> accountsForAssignments)
    {
        
        List<PSA_411_Asset__c> assets411 = new List<PSA_411_Asset__c>();
        Set<Id> accountIds = accountsForAssignments.keySet();
        
        Asset[] assets = [SELECT Id, AccountId, Name, Quantity, InstallDate, Status
                          FROM Asset
                          WHERE AccountId IN : accountIds LIMIT 10000];
        
        if (assets != null && assets.size() > 0)
        {
            for (Asset asset :assets)
            {
                PSA_411_Asset__c asset411 = new PSA_411_Asset__c(
                    Report_Number__c = reportName,
                    PSA_411_Report__c = reportId,
                    Asset_Name__c = asset.Name,
                    Account__c = asset.AccountId,
                    Quantity__c = asset.Quantity,
                    Install_Date__c = asset.InstallDate,
                    Status__c = asset.Status
                );
                
                assets411.add(asset411);
            }
        }
        
        assets = null;
        accountIds = null;
        
        // Create PSA_411_Asset__c records
        if (assets411.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(assets411);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                }
            }
        }
        
        assets411 = null;
    }
    
    // Queries Cases using Accounts gathered from the assignment query, and loads the PSA_411_Case__c table with Case info related to the accounts found
    @future
    private static void extractCaseInfo(Id reportId, String reportName, Map<Id, Id> accountsForAssignments)
    {
        
        List<PSA_411_Case__c> cases411 = new List<PSA_411_Case__c>();
        Set<Id> accountIds = accountsForAssignments.keySet();
        
        Case[] cases = [SELECT Id, AccountId, CaseNumber, CreatedDate, Status, Contact.Name, Subject, Owner.Name
                        FROM Case
                        WHERE AccountId in :accountIds
                        AND Status != 'Closed'];
        
        if (cases != null && cases.size() > 0)
        {
            for (Case accountCase : cases)
            {
                PSA_411_Case__c case411 = new PSA_411_Case__c(
                    Report_Number__c = reportName,
                    PSA_411_Report__c = reportId,
                    Name = accountCase.CaseNumber,
                    Subject__c = accountCase.Subject,
                    Account__c = accountCase.AccountId,
                    CaseNumber__c = accountCase.CaseNumber,
                    CreatedDate__c = accountCase.CreatedDate,
                    Status__c = accountCase.Status,
                    Contact_Name__c = accountCase.Contact.Name,
                    Case_Owner__c = accountCase.Owner.Name);
                
                cases411.add(case411);
            }
        }
        
        cases = null;
        accountIds = null;
        accountsForAssignments = null;
        
        // Create PSA_411_Case__c records
        if (cases411.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(cases411);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                }
            }
        }
        
        cases411 = null;
        
    }
    
}