/****************************************************************************************
Name            : NI_ThreeSixtyViewController Class
Author          : Suzanne LeDuc
Created Date    : 4/8/2013
Last Mod Date   : 7/30/2013
Last Mod By     : Stuart Emery
NICC Reference  : NICC-006873
Description     : test Class for NI_ThreeSixtyViewController Class
                : Create a custom Visualforce Page that will show on a consolidated 
                : screen the open activities, cases, projects, opportunities etc for an 
                : account as well as information on their Org Details
                : 
******************************************************************************************/

public class NI_ThreeSixtyViewController {

   
    private final Account account;
    private final List<Opportunity> opps;
    private final List<Task> tasks;
    private final List<Case> cases;
    private final List<pse__Proj__c> projects;
    private final List<Asset> assets;
    private final List<SFDC_CSP_Flash_Message__c> messages;
    /*COMMENTED 7/6 private final List<Softrax_Asset__c> sAssets;*/
    private final List<Activity_Line_Item__c> actLineItems;
    private final List<PollingResult__c> pResults;
    private final Report orgStats;
    private final Report orgUsage;
    private final Report projectStatus;
    private final Report caseByStatus;
    private final NI_Org_Details__c niOrgDetails;
    private final Report caseByProduct;
    
    
    public Report getCasebyProduct()
    {
        return caseByProduct;
    }
    
    
    public Report getCaseByStatus()
    {
        return caseByStatus;
    }
    public Report getProjectStatus()
    {
        return projectStatus;
    }
    public Report getOrgStats()
    {
        return orgStats;
    }
    
    public Report getOrgUsage()
    {
        return orgUsage;
    }
    public NI_Org_Details__c  getNiOrgDetails()
    {
        return niOrgDetails;
    }
    
    public List<PollingResult__c> getpResults()
    {
        return pResults;
    }
    
    /* COMMENTED 7/6 public List<Softrax_Asset__c> getsAssets()
    {
        return sAssets;
    }*/
    public List<Activity_Line_Item__c> getActLineItems()
    {
        return actLineItems;
    }
    public List<SFDC_CSP_Flash_Message__c> getMessages()
    {
        return messages;
    }

    public Account getAccount()
    {
        return account;
    }
    public List<Opportunity> getOpportunities() {
        return opps;
    }
    
    
    public List<Task> getTasks() {
        return tasks; 

    }
    
    public List<Case> getCases() {
        return cases; 

    }
    
    public List<pse__Proj__c> getProjects() {
        return projects; 
    }
    
    public List<Asset> getAssets() {
        return assets; 
    }
    
    
        public NI_ThreeSixtyViewController(){
      
        String AccountId = ApexPages.currentPage().getParameters().get('accId');
        System.Debug('here');
        System.Debug(AccountId);
        date monthDate = system.today().addDays(-30);
        
        
        Report[] statReports = [SELECT id from Report where DeveloperName = 'OrgStats'];
        if (statReports.size() > 0)
            orgStats = statReports[0];
    
        Report[] usageReports = [SELECT id from Report where DeveloperName = 'OrgUsage'];
        if (usageReports.size() > 0)
            orgUsage = usageReports[0];
    
        Report[] statusReports = [SELECT id from Report where DeveloperName = 'ProjectStatus'];
        if (statusReports.size() > 0)
            projectStatus = statusReports[0];
    
        Report[] caseStatusReports = [SELECT id from Report where DeveloperName = 'Case_by_Status'];
        if (caseStatusReports.size() > 0)
            caseByStatus = caseStatusReports[0];
    
        Report[] caseProductReports = [SELECT id from Report where DeveloperName = 'Cases_by_Product'];
        if (caseProductReports.size() > 0)
            caseByProduct = caseProductReports[0];
    
        
        opps = [SELECT Id, name,Opportunity_Number__c,OwnerId,Amount FROM Opportunity  WHERE  AccountId = :AccountId and StageName != 'ClosedWon'];
        if(opps.size()==0)
        {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This account has no opportunities')) ;
        }
        tasks = [SELECT Id, subject, status, ownerId,ActivityDate  FROM Task WHERE  WhatId = :AccountId and ActivityDate > :monthDate];
        if(tasks.size()==0)
        {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This account has no tasks')) ;
        }
        cases = [SELECT Id, subject, status FROM case WHERE  AccountId = :AccountId and status != 'Cancelled' and status != 'Closed'];
        if(cases.size()==0)
        {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This account has no cases')) ;
        }
        projects = [SELECT Id, name, pse__Stage__c FROM pse__Proj__c WHERE pse__Account__c = :AccountId and pse__Is_Active__c = true];
        if(projects.size()==0)
        {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This account has no projects')) ;
        }
        account = [SELECT Id, name,AccountNumber from Account WHERE Id = :AccountId ];
        
        assets = [SELECT Id,InstallDate,Version__c, name from Asset WHERE AccountId = :AccountId and status = 'Installed'];
        if(assets.size()==0)
        {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This account has no deployment instances')) ;
        }
        messages = [SELECT Id, Message__c, Priority__c from SFDC_CSP_Flash_Message__c WHERE Account__c = :AccountId ];
        if(messages.size()==0)
        {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This account has no flash messages')) ;
        }
        /*sAssets = [SELECT Id, Description__c from Softrax_Asset__c WHERE Account__c = :AccountId ];
        if(sAssets.size()==0)
        {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This account has no softtrax sssets')) ;
        }*/
        actLineItems = [SELECT Id, Product__c from Activity_Line_Item__c WHERE Account_Name__c = :account.Name ];
        if(actLineItems.size()==0)
        {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This account has no activity line items.')) ;
        }
            
            
        List<NI_Org_Details_to_Accounts__c> niOrgDetailsAcc = [Select NIOrgDetailsID__c from NI_Org_Details_to_Accounts__c where AccountID__c = :AccountId];
        if( niOrgDetailsAcc.size() == 0 )
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This account does not have an org detail record.')) ;
        }
        else
        {
            niOrgDetails = [ Select Id,Name from NI_Org_Details__c where Id = :niOrgDetailsAcc[0].NIOrgDetailsID__c];
                
            pResults = [SELECT Id, Name, ApiAllocation__c,ApiCallsRemaining__c,ApiUsage__c,DataStorageAllocation__c,DataStorageRemaining__c
            ,DataStorageUsage__c,DateTime__c,Error__c,ErrorOccured__c,HRMPackageVersion__c,AccountId__c,OrgName__c,PackageExpirationDate__c
            ,PackageAllowedLicenses__c,PackageUsedLicenses__c,ReportingPeriod__c,TotalActiveSalesforcePlatformUsers__c,TotalActiveSalesforceUsers__c
            ,TotalActiveUsers__c,TotalBookings__c,TotalEmailCampaigns__c,TotalLicensedSalesforcePlatformUsers__c,TotalLicensedSalesforceUsers__c
            ,TotalLicensedUsers__c,TotalMemberAccounts__c,TotalReservations__c,TotalUsersRemaining__c,UnmanagedCustomApps__c
            ,UnmanagedCustomObjects__c,UnmanagedCustomTabs__c from PollingResult__c Where AccountId__c = :niOrgDetails.Id order by DateTime__c DESC limit 5];
        }
    }
  
}