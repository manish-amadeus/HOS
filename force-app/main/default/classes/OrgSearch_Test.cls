/************************************************************************************************
Name            : OrgSearch_Test - Test class
Author          : Michael Pedro
Last Mod Date   : 05/05/2022
Last Mod By     : Michael Pedro
Description     : Test class for org search methods
*************************************************************************************************/

@IsTest
public class OrgSearch_Test {

    @IsTest 
    public static void testScheduleTimes() {
        SelectOption[] options = new OrgSearchExt().getTimesOptions();
        for(Integer i = 1; i < 48; i++) {
            System.assertEquals(string.valueOf(i), options[i - 1].getValue());
            System.assertEquals(string.valueOf(i), options[i - 1].getLabel());
        }
    }

    @IsTest 
    public static void testSearch() {
       OrgSearchExt orgSearch = new OrgSearchExt();

       orgSearch.isTest = true;
       orgSearch.search();
       System.assertEquals('Batch submited successfully', orgSearch.message);

       orgSearch.scheduleOrgSearch();
       System.assertEquals('Scheduled successfully', orgSearch.message);
    }
  
    @IsTest 
    public static void testOrgInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        boolean orgInfoRes = search.getOrgInfo();
        System.assertEquals(true, orgInfoRes);
        System.assertNotEquals(null, search.OrgInfoResult);
        System.assertEquals('Test Org', search.OrgInfoResult.OrgName__c);
    }

    @IsTest 
    public static void testOrgPackageInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getPackageInfo();
        System.assertNotEquals(null, search.orgPackageResult);
        System.assertEquals(1, search.orgPackageResult.size());
        System.assertEquals('nihrm', search.orgPackageResult[0].NamespacePrefix__c);
        System.assertEquals('Sales & Event Management R44 P1', search.OrgInfoResult.MajorVersion__c);
        System.assertNotEquals(null, search.orgVersion);
        System.assertEquals(44, search.orgVersion);
    }

    @IsTest 
    public static void testOrgPropertyInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getPropertyInfo();
        System.assertNotEquals(null, search.OrgPropertyResult);
        System.assertEquals(1, search.OrgPropertyResult.size());
        System.assertEquals('Test Property', search.OrgPropertyResult[0].PropertyName__c);
        System.assertEquals(1, search.OrgPropertyResult[0].NumberOfUsers__c);
        System.assertNotEquals(null, search.OrgPropertyResult[0].HistoryCreatedDate__c);
        System.assertNotEquals(null, search.OrgPropertyResult[0].AHWSEnabled__c);
        System.assertNotEquals(null, search.OrgPropertyResult[0].BookingCount__c);
        System.assertNotEquals(null, search.OrgPropertyResult[0].EventCount__c);
        System.assertNotEquals(null, search.OrgPropertyResult[0].DBRFPCount__c);
    }

    @IsTest 
    public static void testUserInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getUserInfo();
        System.assertNotEquals(null, search.OrgUserResult);
        System.assertEquals(1, search.OrgUserResult.size());
        System.assertEquals('Test User', search.OrgUserResult[0].FirstName__c);
        System.assertNotEquals(null, search.OrgUserResult[0].UserFrozen__c);
    }

    @IsTest 
    public static void testSupportUserInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getSupportUser();
        System.assertNotEquals(null, search.OrgUserResult);
        System.assertEquals(1, search.OrgUserResult.size());
        System.assertEquals('Test User', search.OrgUserResult[0].FirstName__c);
        System.assertNotEquals(null, search.OrgUserResult[0].UserFrozen__c);
    }

    @IsTest 
    public static void testProfileInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getProfileInfo();
        System.assertNotEquals(null, search.OrgProfileResult);
        System.assertEquals(1, search.OrgProfileResult.size());
        System.assertEquals('Test Profile', search.OrgProfileResult[0].ProfileName__c);
    }

    @IsTest 
    public static void testCustomSettingInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getCustomSettingInfo();
        System.assertEquals(true, search.OrgInfoResult.AllowLimitedService__c);
        System.assertEquals(true, search.OrgInfoResult.UseCanvasReporting__c);
        System.assertEquals(true, search.OrgInfoResult.EnableAccountSecurity__c);
    }

    @IsTest 
    public static void testOrgLimitInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getOrgLimitInfo();
        System.assertNotEquals(null, search.OrgLimitResult);
        System.assertEquals(4, search.OrgLimitResult.size());
    }

    @IsTest 
    public static void testLogCountInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getLogCountInfo();
        System.assertEquals(100, search.OrgInfoResult.ProcessorLogCount__c);
        System.assertEquals(100, search.OrgInfoResult.LogCount__c);
        System.assertEquals(100, search.OrgInfoResult.MessageLogCount__c);
    }

    @IsTest 
    public static void testByPassInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getByPassInfo();
        System.assertEquals(true, search.OrgInfoResult.ByPassRules__c);
    }

    @IsTest 
    public static void testIsPermCountInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getIsPermCountInfo();
        System.assertEquals(1, search.OrgInfoResult.IsPermCount__c);
    }

    @IsTest 
    public static void testSCPicklistInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getSCPicklistInfo();
        System.assertEquals(true, search.OrgInfoResult.SCPicklistEnabled__c);
    }

    @IsTest 
    public static void testAccountInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getAccountInfo();
        System.assertEquals(90, search.OrgInfoResult.TotalAccounts__c);
        System.assertNotEquals(null, search.OrgInfoResult.MaxAccountCreateDate__c);
        System.assertNotEquals(null, search.OrgInfoResult.MaxAccountModifiedDate__c);
    }

    @IsTest 
    public static void testLogInInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getOrgLoginInfo();
        System.assertNotEquals(null, search.OrgInfoResult.MaxLastLoginDate__c);
    }

    @IsTest 
    public static void testLicenseInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getLicenseInfo();
        System.assertNotEquals(null, search.OrgLicenseResult);
        System.assertEquals(1, search.OrgLicenseResult.size());
        System.assertEquals('Salesforce Platform', search.OrgLicenseResult[0].LicenseName__c);
    }

    @IsTest 
    public static void testProcessorInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getProcessorInfo();
        System.assertNotEquals(null, search.OrgProcessorResult);
        System.assertEquals(1, search.OrgProcessorResult.size());
        System.assertEquals('processorId', search.OrgProcessorResult[0].ProcessorId__c);
        System.assertEquals('Completed', search.OrgProcessorResult[0].ProcessorStatus__c);
    }

    @IsTest 
    public static void testPropertyIntegrationInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getPropertyIntegrationInfo();
        System.assertNotEquals(null, search.orgPropertyIntegrationSettingResult);
        System.assertEquals(1, search.orgPropertyIntegrationSettingResult.size());
        System.assertEquals('PropertyIntegration', search.orgPropertyIntegrationSettingResult[0].IntegrationName__c);
    }

    @IsTest 
    public static void testPropMenuItemCountsCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getPropMenuItemCounts();
        System.assertNotEquals(null, search.OrgPropMenuItemCountResult);
        System.assertEquals(1, search.OrgPropMenuItemCountResult.size());
        System.assertEquals(14, search.OrgPropMenuItemCountResult[0].Count__c);
    }

    @IsTest 
    public static void testReportCountsCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getReportCountInfo();
        System.assertNotEquals(null, search.OrgReportCountResult);
        System.assertEquals(1, search.OrgReportCountResult.size());
        System.assertEquals(13, search.OrgReportCountResult[0].Count__c);
    }

    @IsTest 
    public static void testSetupValueInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getSetupValueInfo();
        System.assertNotEquals(null, search.OrgSetupValueResult);
        System.assertEquals(1, search.OrgSetupValueResult.size());
        System.assertEquals('SV Name', search.OrgSetupValueResult[0].SetupValueName__c);
    }

    @IsTest 
    public static void testSystemInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getSystemInfo();
        System.assertNotEquals(null, search.OrgSystemResult);
        System.assertEquals(1, search.OrgSystemResult.size());
        System.assertEquals('Test System', search.OrgSystemResult[0].SystemName__c);
    }

    @IsTest 
    public static void testSanboxInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getSandboxInfo();
        System.assertNotEquals(null, search.OrgSandboxResult);
        System.assertEquals(1, search.OrgSandboxResult.size());
        System.assertEquals('TESTSB', search.OrgSandboxResult[0].SandboxName__c);
    }

    @IsTest 
    public static void tesValidationRuleInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getValidationRuleInfo();
        System.assertNotEquals(null, search.OrgValidationRuleResult);
        System.assertEquals(1, search.OrgValidationRuleResult.size());
        System.assertEquals('Test Rule', search.OrgValidationRuleResult[0].ValidationRuleName__c);
    }

    @IsTest 
    public static void tesWorkFlowInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getWorkFlowInfo();
        System.assertNotEquals(null, search.OrgWorkFlowResult);
        System.assertEquals(1, search.OrgWorkFlowResult.size());
        System.assertEquals('WF Rule', search.OrgWorkFlowResult[0].WorkflowName__c);
    }

    @IsTest 
    public static void tesCustomFieldInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getCustomFieldInfo();
        System.assertNotEquals(null, search.OrgCustomFieldResult);
        System.assertEquals(1, search.OrgCustomFieldResult.size());
        System.assertEquals('Test Name', search.OrgCustomFieldResult[0].FieldName__c);
    }

    @IsTest 
    public static void tesApexClassInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getApexClassInfo();
        System.assertNotEquals(null, search.OrgApexClassResult);
        System.assertEquals(1, search.OrgApexClassResult.size());
        System.assertEquals('Class Name', search.OrgApexClassResult[0].ClassName__c);
    }

    @IsTest 
    public static void tesApprovalProcessInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getApprovalProcessInfo();
        System.assertNotEquals(null, search.OrgApprovalProcessResult);
        System.assertEquals(1, search.OrgApprovalProcessResult.size());
        System.assertEquals('test approval process', search.OrgApprovalProcessResult[0].ApprovalProcessName__c);
    }

    @IsTest 
    public static void tesApexTriggerInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getApexTriggerInfo();
        System.assertNotEquals(null, search.OrgApexTriggerResult);
        System.assertEquals(1, search.OrgApexTriggerResult.size());
        System.assertEquals('Test Trigger', search.OrgApexTriggerResult[0].TriggerName__c);
    }

    @IsTest 
    public static void tesCustomObjectInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getCustomObjectInfo();
        System.assertNotEquals(null, search.OrgCustomObjectResult);
        System.assertEquals(1, search.OrgCustomObjectResult.size());
        System.assertEquals('Test Object', search.OrgCustomObjectResult[0].ObjectName__c);
    }

    @IsTest 
    public static void tesCustomTabInfoCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getCustomTabInfo();
        System.assertNotEquals(null, search.OrgCustomTabResult);
        System.assertEquals(1, search.OrgCustomTabResult.size());
        System.assertEquals('Test Tab', search.OrgCustomTabResult[0].Description__c);
    }

    @IsTest 
    public static void tesPropDocTemplateCountsCallout() {
        Test.setMock(HttpCalloutMock.class, new OrgSearch_Mock());
        OrgSearchCls search = new OrgSearchCls();
        search.OrgInfoResult = new OrgInfo__c();
        search.orgVersion = 44;
        search.orgDetail = new NI_Org_Details__c();
        search.domain = 'https://domain.my.';
        search.getPropDocTemplateCounts();
        System.assertNotEquals(null, search.OrgPropDocumentTemplateResult);
        System.assertEquals(1, search.OrgPropDocumentTemplateResult.size());
        System.assertEquals(2, search.OrgPropDocumentTemplateResult[0].Count__c);
    }
}