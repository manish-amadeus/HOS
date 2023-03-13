/****************************************************************************************
Name            : NI_OrgDetailsLogController_TestClass Class
Author          : Stuart Emery
Created Date    : 9/7/2013
Last Mod Date   : 7/26/2015
Last Mod By     : Stuart Emery
NICC Reference  : NICC-007649
Description     : Test Class for the NI_OrgDetailsLogController Controller  
                : 
                : 
******************************************************************************************/
@isTest(SeeAllData=False)
private class NI_OrgDetailsLogController_TestClass 
{

    static testMethod void myUnitTest() 
    {
        
        //CREATE TEST Org_Details_Record_Type_VF_View_Page__c CUSTOM SETTINGS RECORDS
        // List<Org_Details_Record_Type_VF_View_Page__c> lstCSRecordType = new List<Org_Details_Record_Type_VF_View_Page__c>();
        
        Org_Details_Record_Type_VF_View_Page__c l1 = new Org_Details_Record_Type_VF_View_Page__c();
        l1.Name = 'LOD Support Admin';
        
        database.insert(l1);
        
        //GET THE ORG DETAILS RECORD TYPE ID FOR THE "LOD Support Admin" RECORD TYPE
        Id rtIdLod = NI_TestClassData.getRecordTypeId('NI_Org_Details__c', 'LOD Support Admin');
        System.Debug('rtIdStandard: ' + rtIdLod);
        
        //GET THE ORG DETAILS RECORD TYPE ID FOR THE "MB CRM Integration User" RECORD TYPE
        Id rtIdMb = NI_TestClassData.getRecordTypeId('NI_Org_Details__c', 'MB CRM Integration User');
        
        // NI_Org_Details__c OBJECT
        NI_Org_Details__c od = new NI_Org_Details__c(); 
        
        // PAGE REFERENCE
        //PageReference pageRef = Page.NI_OrgDetails;
        //Test.setCurrentPage(pageRef);
        
        User u = NI_TestClassData.createTestUser(1, 'System Administrator');
        insert u;

        //CREATE A TEST ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //CREATE A LIST OF ORG DETAIL RECORDS
        List<NI_Org_Details__c> lstToInsert = new List<NI_Org_Details__c>();
        
        //CREATE A TEST ORG DETAILS RECORD
        Id rtId = NI_TestClassData.getRecordTypeId('NI_Org_Details__c', 'LOD Support Admin');
        NI_Org_Details__c n = NI_TestClassData.createTestNiOrgDetails(rtId,1,'Salesforce Production');
        //n.AdminLoginName__c = 'test@test.com';
        //n.AdminPassword__c = 'test';
        n.Admin_Login_Name_Encrypted__c = 'test@test.com';
        n.Admin_Password_Encrypted__c = 'test';
        Database.insert(n);
        
        //CREATE A TEST ORG DETAILS RECORD
        NI_Org_Details__c n2 = NI_TestClassData.createTestNiOrgDetails(rtIdMb,1,'Salesforce Sandbox - Full');
        //n2.AdminLoginName__c = 'test@test.com';
        //n2.AdminPassword__c = 'test';
        n2.Admin_Login_Name_Encrypted__c = 'test@test.com';
        n2.Admin_Password_Encrypted__c = 'test';
        Database.insert(n2);        
        //Database.insert(lstToInsert);
        
        // PAGE REFERENCE TO TEST CUSTOM VISUALFORCE PAGE REDIRECT
        PageReference pageRef = Page.NI_OrgDetailsRedirectViewPage;
        pageRef.getParameters().put('id', n.Id);
        Test.setCurrentPage(pageRef);
        
        // PAGE REFERENCE TO TEST STANDARD PAGE LAYOUT REDIRECT
        PageReference pageRef2 = Page.NI_OrgDetailsRedirectViewPage;
        pageRef2.getParameters().put('id', n2.Id);
        Test.setCurrentPage(pageRef2);        
        
        // CONTROLLER 1
        NI_OrgDetailsLogController ctrl = new NI_OrgDetailsLogController(new ApexPages.StandardController(n));
        ctrl.verifyCred();
        ctrl.createLog();
        //System.AssertEquals(ctrl.CredentialsMsg,'Invalid Credentials');
        
        // ADDED 07/22/2013 =============================================
        ctrl.showPwdPopup();
        ctrl.closePwdPopup();
        ctrl.showPwd();
        boolean b1 = ctrl.bIsPwdReadWrite;
        boolean b2 = ctrl.bIsPwdRead;
        boolean b3 = ctrl.bIsButtonUser;
        
        // CONTROLLER 2
        NI_OrgDetailsLogController ctrl2 = new NI_OrgDetailsLogController(new ApexPages.StandardController(n2));
        NI_TriggerManager.isValidOrgDetails = false;        
        ctrl2.verifyCred();
        ctrl2.createLog();
 
        // CONTROLLER 3
        NI_OrgDetailsLogController ctrl3 = new NI_OrgDetailsLogController(new ApexPages.StandardController(n2));
        ctrl3.inValidCredPopupMsg = 'The customer org credentials are invalid for this NI Org Details record.';
        ctrl3.verifyCred();
        
        // PAGE REFERENCE REDIRECT TO THE VISUALFORCE VIEW PAGE
        PageReference redirectPageRef = Page.NI_OrgDetails;
        redirectPageRef.getParameters().put('RecordType', rtIdLod);
        Test.setCurrentPage(redirectPageRef);
        System.debug('TEST PAGE1 RECORD TYPE ID: ' + ApexPages.currentPage().getParameters().get('RecordType'));
        ctrl.redirectViewPage();       
        
        // CAUSE LOGIN FAILURE
        //ctrl3.ClientId = 'BOGUS.CLIENTID';
        //ctrl3.ClientSecret = 'BOGUS.SECRET';  
        string strEndPoint = 'https://login.salesforce.com/services/oauth2/token';
        boolean hasValidCreds = ctrl3.validateUserCredentials('test@test.com', 'test', strEndPoint);         

        
        User u2 = NI_TestClassData.createTestUser(2, 'AH Support CSR - Lightning');
        insert u2;
               
        Boolean b = NI_OrgDetailsLogController.hasAccessByPublicGroup(u2.Id, 'Development Group');
            
    }
    
}