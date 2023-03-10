/************************************************************************************************
Name            : OrgInfoBatch_Test - Test Class
Author          : Michael Pedro
Last Mod Date   : 05/05/2022
Last Mod By     : Michael Pedro
Description     : Test class for OrgSearchBatch and OrgSearchSchedule classes
*************************************************************************************************/

@IsTest
public class OrgInfoBatch_Test {
    
    @IsTest 
    public static void testOrgInfoBatch() {
        NI_Org_Details__c details = new NI_Org_Details__c();
        details.Admin_Login_Name_Encrypted__c = 'test';
        details.Org_Name__c = 'test org';
        details.Org_Type__c = 'Salesforce Production';
        details.Org_ID__c = 'orgId';
        details.RecordTypeId = '01260000000DnbPAAS';
        NI_Org_Details__c details2 = new NI_Org_Details__c();
        details2.Admin_Login_Name_Encrypted__c = 'test2';
        details2.Org_Type__c = 'Salesforce Production';
        insert details;
        insert details2;

        List<string> detailList = new List<string>{details.Id, details2.Id};
        OrgInfoBatch orgInfoBatch = new OrgInfoBatch(detailList);
        
        OrgInfoBatch.OrgQueryInfo queryInfo = new OrgInfoBatch.OrgQueryInfo();
        queryInfo.OrgInfoResult = new OrgInfo__c();
        queryInfo.OrgLimitResult = new List<OrgLimit__c>{new OrgLimit__c()};
        queryInfo.OrgPackageResult = new List<OrgPackage__c>{new OrgPackage__c()};
        queryInfo.OrgSandboxResult = new List<OrgSandbox__c>{new OrgSandbox__c()};
        queryInfo.OrgProcessorResult = new List<OrgProcessor__c>{new OrgProcessor__c()};
        queryInfo.OrgLicenseResult = new List<OrgLicense__c>{new OrgLicense__c()};
        queryInfo.OrgUserResult = new List<OrgUser__c>{new OrgUser__c()};
        queryInfo.OrgProfileResult = new List<OrgProfile__c>{new OrgProfile__c()};
        queryInfo.OrgPropertyResult = new List<OrgProperty__c>{new OrgProperty__c()};
        queryInfo.orgPropertyIntegrationSettingResult = new List<OrgPropertyIntegrationSetting__c>{new OrgPropertyIntegrationSetting__c()};
        // queryInfo.OrgPropertyMenuItemCountsResult = new List<OrgPropMenuItemCount__c>{new OrgPropMenuItemCount__c()};
        // queryInfo.OrgPropDocumentTemplateResult = new List<OrgPropDocTemplateCount__c>{new OrgPropDocTemplateCount__c()};
        queryInfo.OrgSystemResult = new List<OrgSystem__c>{new OrgSystem__c()};
        queryInfo.OrgReportCountResult = new List<OrgReportCount__c>{new OrgReportCount__c()};
        queryInfo.OrgSetupValueResult = new List<OrgSetupValue__c>{new OrgSetupValue__c()};
        // queryInfo.OrgValidationRuleResult = new List<OrgValidationRule__c>{new OrgValidationRule__c()};
        // queryInfo.OrgWorkflowResult = new List<OrgWorkflow__c>{new OrgWorkflow__c()};
        // queryInfo.OrgApexClassResult = new List<OrgApexClass__c>{new OrgApexClass__c()};
        // queryInfo.OrgApexTriggerResult = new List<OrgApexTrigger__c>{new OrgApexTrigger__c()};
        // queryInfo.OrgApprovalProcessResult = new List<OrgApprovalProcess__c>{new OrgApprovalProcess__c()};
        // queryInfo.OrgCustomObjectResult = new List<OrgCustomObject__c>{new OrgCustomObject__c()};
        // queryInfo.OrgCustomTabResult = new List<OrgCustomTab__c>{new OrgCustomTab__c()};
        // queryInfo.OrgProcessResult = new List<OrgProcess__c>{new OrgProcess__c()};
        // queryInfo.OrgCustomFieldResult = new List<OrgCustomField__c>{new OrgCustomField__c()};

        Test.startTest();  
        orgInfoBatch.isTest = true;
        orgInfoBatch.OrgQueryInfo = queryInfo;
        Database.executeBatch(orgInfoBatch, 1);
        Test.stopTest();

        List<OrgInfo__c> createdInfos = [SELECT Id FROM OrgInfo__c];
        System.assertEquals(1, createdInfos.size()); 
    }

    @IsTest 
    public static void testOrgInfoSchedule() {
        NI_Org_Details__c details = new NI_Org_Details__c();
        details.Admin_Login_Name_Encrypted__c = 'test';
        details.Org_Name__c = 'test org';
        details.Org_Type__c = 'Salesforce Production';
        details.RecordTypeId = '01260000000DnbPAAS';
        insert details;
        
        OrgSearchSchedule sched = new OrgSearchSchedule(new List<string>{details.Id}, 1, '');		
        sched.isTest = true;
        sched.execute(null);
    }
}