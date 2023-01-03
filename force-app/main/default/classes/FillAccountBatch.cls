/************************************************************************************************
Name            : FillAccountBatch Batchable Class
Author          : Artem Glynskyi 
Created Date    : 02/01/2013
Last Mod By     : Sean Harris
Last Mod Date   : 07/16/2013
NICC Reference  : NICC-006221
Description     : 
                : 
                : 
*************************************************************************************************/
global class FillAccountBatch implements Database.Batchable<NI_Org_Details__c>, Database.AllowsCallouts 
{   
    
    global Boolean isTest { get; set; } 
    private string[] ids { get; set;} 
    
    // METHOD THAT ACCEPTS AN ARRAY OF ACCOUNT IDS OF TARGETED ORGS TO AUDIT. 
    // ===========================================================================
    // ids = An array of Account ids    
    global FillAccountBatch(string[] ids) 
    {
        isTest = false;
        this.ids = ids;
    }
    
    // METHOD THAT RETURNS TARGETED ORG'S LOGIN & PASSWORDS FROM NI_Org_Details__c FOR BATCH 
    global NI_Org_Details__c[] start(Database.BatchableContext bc) 
    {       
        return [SELECT Id, Name, Admin_Login_Name_Encrypted__c, Admin_Password_Encrypted__c, Org_Type__c, Security_Token_Encrypted__c   
                FROM NI_Org_Details__c 
                //WHERE AdminLoginName__c <> null 
                //AND AdminPassword__c <> null 
                // REMARKED FOLLOWING LINE TO PULL ALL ORG DETAILS THAT MEET CRITERIA ============= 
                // AND Id IN : ids 
                // ADDED 7/16/2013 (NEXT 3 LINES) ================================================= 
                
                WHERE Org_Type__c LIKE 'Salesforce%' 
                AND DisablePolling__c = false 
                AND RecordTypeId = '01260000000DnbPAAS'
                //AND Inactive__c = false
                
// TESTING FILTERS =======================
//AND Id = 'a4O32000000CjaD'
//AND License_Type_Compliant__c = false 
//LIMIT 60                
                ]; 
    }

    global void execute(Database.BatchableContext bc, NI_Org_Details__c[] accounts) 
    {

        NI_Org_Details__c account = accounts[0];
        FillAccount filler = new FillAccount();
        
        // QUERY FOR 1 NON-ERROR RECORD HAVING THE MAXIMUM DATE AND ACCOUNT ID OF CURRENT ACCOUNT IN BATCH
        PollingResult__c[] previous = [SELECT UnmanagedCustomTabs__c, UnmanagedCustomObjects__c, UnmanagedCustomApps__c, ReportingPeriod__c,
                                              TotalReservations__c, TotalEmailCampaigns__c, TotalBookings__c, Error__c, 
                                              DateTime__c, DataStorageUsage__c, DataStorageAllocation__c,  ApiUsage__c, ApiAllocation__c 
                                       FROM PollingResult__c 
                                       WHERE AccountId__c = : account.Id AND ErrorOccured__c = false
                                       ORDER BY DateTime__c DESC LIMIT 1];
                                   
        // QUERY FOR 1 RECORD CREATED TODAY AND ACCOUNT ID OF CURRENT ACCOUNT IN BATCH                         
        PollingResult__c[] previousToday = [SELECT UnmanagedCustomTabs__c, UnmanagedCustomObjects__c, UnmanagedCustomApps__c, ReportingPeriod__c,
                                                   TotalReservations__c, TotalEmailCampaigns__c, TotalBookings__c, Error__c, 
                                                   DateTime__c, DataStorageUsage__c, DataStorageAllocation__c,  ApiUsage__c, ApiAllocation__c, 
                                                   AccountId__c, Name
                                            FROM PollingResult__c 
                                            WHERE AccountId__c = : account.Id AND DateTime__c = TODAY LIMIT 1]; 
    
        // ? :  
        // Ternary operator (Right associative). This operator acts as a short-hand for if-then-else statements. 
        // If x, a Boolean, is true, y is the result. Otherwise z is the result. Note that x cannot be null.
        // Example; x ? y : z   
        // IF THE previous HAS RECORDS SET THE FillAccount's previous array variable to this.previous ELSE SET IT TO A NEW PollingResult__c RECORD                                                         
        filler.previous = previous.size() != 0 ? previous[0] : new PollingResult__c(DateTime__c = DateTime.now()); 
        filler.account = account; 
        
        if (previousToday.size() != 0) 
        {
            filler.result = previousToday[0]; 
        }
        
        // IF NOT IN TEST MODE
        if (!isTest) 
        {   
            filler.fill(); 
            upsert filler.result; 
        }
        
    }
    
    global void finish(Database.BatchableContext bc)
    {

    }

    // TEST METHOD FOR CLASS ===================================================    
    global static testmethod void testFake() 
    {
        FillAccountBatch fab = new FillAccountBatch(new String[0]);
        NI_Org_Details__c[] accounts = new NI_Org_Details__c[1]; 
        
        fab.isTest = true;
        accounts[0] = new NI_Org_Details__c();
        fab.start(null);
        fab.execute(null, accounts);
        fab.finish(null);
    }
    
}