/****************************************************************************************
Name            : CaseFlashAlertExtension_Test 
Author          : Sean Harris
Created Date    : 04/17/2017
Last Mod Date   : 04/17/2017 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                :
****************************************************************************************/
@isTest
public class CaseFlashAlertExtension_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        Test.startTest(); 
        
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();

        // CREATE TEST ACCOUNTS ===============================
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtParentAccountId = AccountRecordTypeInfo.get('Parent Account').getRecordTypeId();
        Id rtPropertyAccountId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();        
        
        List<Account> lstAccountInsert = new List<Account>();
        
        Account a1 = NI_TestClassData.createTestAccount(1);
        a1.Name = 'APEX TEST PARENT ACCOUNT 1';
        a1.RecordTypeId = rtParentAccountId;
        lstAccountInsert.Add(a1);
        Account a2 = NI_TestClassData.createTestAccount(2);
        a2.Name = 'APEX TEST PROPERTY ACCOUNT 1';
        a2.RecordTypeId = rtPropertyAccountId;
        lstAccountInsert.Add(a2);
        Database.insert(lstAccountInsert); 
        
        List<Account> lstAccountAsserts = new List<Account>([SELECT Id FROM Account WHERE Name LIKE 'APEX TEST %']);
        system.assertEquals(2, lstAccountAsserts.Size());        

        // CREATE ASSET
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
        insert pgp;
        
        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription');        
        insert prd;        
        
        Asset d = NI_TestClassData.createTestAsset(1, a1.Id, prd.Id);
        d.Product_Group__c = pgp.Id;
        insert d;        

        // CREATE TEST CASES =====================================
        Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName(); 
        
        Id rtCaseId = CaseRecordTypeInfo.get('Case').getRecordTypeId();
                
        Account aP = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        Case c1 = NI_TestClassData.createTestCase(1, aP.Id);
        c1.Subject = 'APEX TEST PARENT CASE 1';
        c1.RecordTypeId = rtCaseId;
        c1.AssetId = d.Id; 
        c1.Status = 'Working';
        c1.Resolution_Type__c = 'Released to Customer SPT';
        insert c1;
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1'];
        Case c2 = NI_TestClassData.createTestCase(2, a.Id);
        c2.ParentId = c1.Id;
        c2.Subject = 'APEX TEST PROPERTY CASE 1';
        c2.RecordTypeId = rtCaseId;
        c2.AssetId = d.Id;
        insert c2;

        List<Case> lstCaseAsserts = new List<Case>([SELECT Id FROM Case]);
        system.assertEquals(2, lstCaseAsserts.Size());    

        // CREATE TEST SOLUTIONS 
        Solution s1 = NI_TestClassData.createSolution(1); 
        insert s1;

        Solution s2 = NI_TestClassData.createSolution(2); 
        insert s2;

        // LINK TEST SOLUTIONS TO TEST CASES RECORDS 
		List<CaseSolution> lstCaseSolution = new List<CaseSolution>();
        CaseSolution cs1 = NI_TestClassData.createCaseSolution(c1.Id, s1.Id);
        lstCaseSolution.add(cs1);
        CaseSolution cs2 = NI_TestClassData.createCaseSolution(c2.Id, s2.Id);
        lstCaseSolution.add(cs2);
        database.insert(lstCaseSolution);

        List<CaseSolution> lstCaseSolutionAsserts = new List<CaseSolution>([SELECT Id FROM CaseSolution]);
        system.assertEquals(2, lstCaseSolutionAsserts.size(), 'Problem with inserted CaseSolution test records!');
    
        Test.stopTest(); 
        
    }

    static testMethod void CaseFlashAlertExtensionTest() 
    {
        
        Account aP = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1'];
        
        a.ParentId = aP.Id;
        update a;
        
		Case c = [SELECT Id, AccountId, First_Time_Flash_Message_Count__c FROM Case WHERE Subject = 'APEX TEST PROPERTY CASE 1'];    

        ApexPages.StandardController stdCon = new ApexPages.StandardController(c);
        CaseFlashAlertExtension ext = new CaseFlashAlertExtension(stdCon);

        // TEST ACTION TAG ON VF PAGE
        PageReference pr1 = Page.CaseFlashAlertPopup;
        Test.setCurrentPage(pr1); 
        PageReference result1 = ext.updateCase(); 
        
        // ASSERT THERE ARE NO MESSAGES 
        System.assertEquals(0, ext.numberOfMessages);
       
        // CREATE A FLASHMESSAGE - COUNT SHOULD BE ONE MESSAGE 
        SFDC_CSP_Flash_Message__c fm1 = NI_TestClassData.createFlashMessage(a.Id);
        insert fm1;
        
        stdCon = new ApexPages.StandardController(c); 
        ext = new CaseFlashAlertExtension(stdCon); 
        
        // ASSERT THERE IS ONE MESSAGES 
        System.assertEquals(1, ext.numberOfMessages); 
        
        // CREATE A FLASHMESSAGE ON THE PARENT WITH CHILDREN VISIBLE - COUNT SHOULD BE TWO MESSAGES 
        SFDC_CSP_Flash_Message__c fm2 = NI_TestClassData.createFlashMessage(aP.Id); 
		fm2.Viewable_to_All_Children__c = true; 
        insert fm2; 
        
        stdCon = new ApexPages.StandardController(c); 
        ext = new CaseFlashAlertExtension(stdCon); 
        
        // ASSERT THERE ARE TWO MESSAGES 
        system.assertEquals(2, ext.numberOfMessages);
        
        // CREATE A FLASHMESSAGE ON THE PARENT WITH CHILDREN NOT VISIBLE - COUNT SHOULD STILL BE TWO MESSAGES 
        SFDC_CSP_Flash_Message__c fm3 = NI_TestClassData.createFlashMessage(aP.Id);
		fm3.Viewable_to_All_Children__c = false;
        insert fm3;
        
        stdCon = new ApexPages.StandardController(c);
        ext = new CaseFlashAlertExtension(stdCon);
        
        // ASSERT THERE ARE TWO MESSAGES 
        system.assertEquals(2, ext.numberOfMessages);        
        
        // TEST ACTION TAG ON VF PAGE AGAIN
        PageReference pr2 = Page.CaseFlashAlertPopup;
        Test.setCurrentPage(pr2); 
        PageReference result2 = ext.updateCase();        

    }
    
}