/****************************************************************************************
Name            : CloseCasesExtension_Test 
Author          : Sean Harris
Created Date    : 04/13/2017
Last Mod Date   : 04/13/2017 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Tests Extension Controller for the VisualForce page called CloseCases
                :
****************************************************************************************/
@isTest
public class CloseCasesExtension_Test 
{

    // ======================================================================================================================================= //
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        Test.startTest(); 
        
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();

        // CREATE TEST SUPPORT USER
        User u1 = NI_TestClassData.createTestUser(1, 'NI Support CSR'); 
        u1.FirstName = 'Joe';
        u1.LastName = 'Support';
        u1.Alias = 'SPT01TST'; 
        insert u1;
        
        List<User> lstUserAsserts = new List<User>([SELECT Id FROM User WHERE Alias = 'SPT01TST']);
        system.assertEquals(1, lstUserAsserts.Size());    
        
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
    
    static testMethod void testCloseCasesExtension() 
    {
        
        User sUser = [SELECT Id FROM User WHERE Alias = 'SPT01TST'];
		Case pCase = [SELECT Id, Status, Resolution_Type__c, ParentId FROM Case WHERE Subject = 'APEX TEST PARENT CASE 1'];
        Case cCase = [SELECT Id, Status, Resolution_Type__c, ParentId FROM Case WHERE Subject = 'APEX TEST PROPERTY CASE 1'];

        // TEST AS NI Support CSR USER
        system.runAs(sUser)
        {
            
            PageReference pr = Page.CloseCases;
            pr.getParameters().put('retURL', 'returnURL');
            Test.setCurrentPage(pr);
            
            ApexPages.StandardSetController stdCon = new ApexPages.StandardSetController(new Case[] { pCase });
            stdCon.setSelected(new Case[] { cCase });
            CloseCasesExtension ext = new CloseCasesExtension(stdCon);
            
            ext.cancel();
            ext.load();
            ext.comments = 'APEX TEST COMMENT';
            ext.saveNew();
            
            List<CaseComment> lstCaseCommentAsserts = new List<CaseComment>([SELECT Id 
                                                                             FROM CaseComment 
                                                                             WHERE ParentId =: cCase.Id
                                                                             AND IsPublished = false 
                                                                             AND CommentBody = 'APEX TEST COMMENT']);
            system.assertEquals(1, lstCaseCommentAsserts.size(), 'Issue with Case Comment count');
            
            List<Case> lstCaseAsserts = new List<Case>([SELECT Id FROM Case 
                                                        WHERE Id =: cCase.Id  
                                                        AND Status =: pCase.Status 
                                                        AND Resolution_Type__c =: pCase.Resolution_Type__c]);
            system.assertEquals(1, lstCaseCommentAsserts.size(), 'Issue with Case count');
            
            // EMULATE USER CLICKING Close Cases BUTTON WITH NO CHILD CASES SELECTED
            ApexPages.StandardSetController stdCon2 = new ApexPages.StandardSetController(new Case[] { pCase });
            CloseCasesExtension ext2 = new CloseCasesExtension(stdCon2);
            ext2.load();
            
        }
        
    }
    
}