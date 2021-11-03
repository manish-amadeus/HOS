/****************************************************************************************
Name            : NI_ThreeSixtyViewController_Test Test Class
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

public class NI_ThreeSixtyViewController_Test {

    public static testMethod void NI_ThreeSixtyViewController_Test() {
        PageReference pageRef = Page.View360;
        Test.setCurrentPage(pageRef);
      
        // Add parameters to page URL
        Account testAccount = NI_TestClassData.createTestAccount(1);
        insert testAccount;
        
        Id rtInit = NI_TestClassData.getRecordTypeId('NI_Org_Details__c', 'LOD Support Admin');
       
       
        NI_Org_Details__c od = NI_TestClassData.createTestNiOrgDetails(rtInit, 1, 'Salesforce Production');
        insert od;
        
        NI_Org_Details_to_Accounts__c orgDetailAccount = new NI_Org_Details_to_Accounts__c();
        orgDetailAccount.AccountID__c = testAccount.Id;
        orgDetailAccount.NIOrgDetailsID__c = od.Id;
        insert orgDetailAccount;
           
       
        ApexPages.currentPage().getParameters().put('accId', testAccount.Id);
      
        // Instantiate a new controller with all parameters in the page
        NI_ThreeSixtyViewController controller = new NI_ThreeSixtyViewController();
        Report caseReport = controller.getCasebyProduct();
        Report caseStatusReport = controller.getCasebyStatus();
        Report projectStatusReport = controller.getProjectStatus();
        Report OrgStatReport = controller.getOrgStats();
        Report orgUsageReport = controller.getOrgUsage();
        NI_Org_Details__c orgDetails = controller.getNiOrgDetails();
        List<PollingResult__c> pResults = controller.getpResults();
        //List<Softrax_Asset__c> assets = controller.getsAssets();
        List<Activity_Line_Item__c> actLines = controller.getActLineItems();
        List<SFDC_CSP_Flash_Message__c> messages = controller.getMessages();
        Account acct = controller.getAccount();
        List<Opportunity> opps = controller.getOpportunities();
        List<Task> tasks = controller.getTasks();
        List<Case> cases = controller.getCases();
        List<pse__Proj__c> projects = controller.getProjects();
        List<Asset> otherAssets = controller.getAssets();
      
    }
    }