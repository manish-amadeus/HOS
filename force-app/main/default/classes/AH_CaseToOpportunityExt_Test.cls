/****************************************************************************************
Name            : AH_CaseToOpportunityExt
Author          : Archita Shrotriya
Created Date    : 26/09/2017
Last Mod Date   : 01/10/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test Class for AH_CaseToOpportunityExt Controller class
				: 
				: 
******************************************************************************************/
@isTest
public class AH_CaseToOpportunityExt_Test 
{
    
    @testSetup static void createTestData() 
    {

        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        u.Alias = 'NA01TST'; 
        insert u;

        User rou = NI_TestClassData.createTestUser(77, 'NI Chatter Free User');
        rou.Alias = 'ROU01TST'; 
        insert rou;
        
        User usr = [SELECT Id, Email FROM User WHERE Id =: UserInfo.getUserId()];
        
        EmailTemplate et = new EmailTemplate (developerName = 'test', TemplateType = 'Text', Name = 'Test', FolderId = usr.Id); 
        
        system.RunAs(usr)
        { 
            insert et;
        } 
        
        Account a = NI_TestClassData.createTestAccount(1); 
        a.Name = 'AH_CaseToOpportunityExt_Test Account';
        a.MTech_Owner__c = u.Id; 
        a.Secondary_Account_Owner__c = u.Id;
        insert a;  
        
        Contact cn = NI_TestClassData.createTestContact(1, a.Id);
        insert cn;

        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
        insert pgp;

        Product2 prd1 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription');    
        prd1.Solution_Domain_Global__c = 'Service Optimization';
        prd1.Edition__c = 'Enterprise';
        prd1.Interface_Classification__c = 'PMS';  
        prd1.Classification__c = '1';        
        insert prd1;

        Product2 prd2 = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-02', 'Subscription');    
        prd2.Solution_Domain_Global__c = 'Sales & Catering';
        prd2.Edition__c = 'Enterprise';
		prd2.Interface_Classification__c = 'PMS';        
        prd2.Classification__c = '2';          
        insert prd2;
        
        Asset di1 = NI_TestClassData.createTestAsset(1, a.Id, prd1.Id);
        di1.Product_Group__c = pgp.Id;
        insert di1;
        
        Asset di2 = NI_TestClassData.createTestAsset(2, a.Id, prd2.Id);
        di2.Product_Group__c = pgp.Id;
        insert di2;

Test.startTest();
        
        // CREATE TEST CASE RECORDS
        List<Case> lstCaseInsert = new List<Case>();
        
        Case c1 = NI_TestClassData.createTestCase(1, a.Id); 
        c1.ContactId = cn.id;
        c1.Subject = 'AH_CaseToOpportunityExt_Test Test Case #1';
        c1.AssetId = di1.Id;
        lstCaseInsert.Add(c1);
        
        Case c2 = NI_TestClassData.createTestCase(2, a.Id); 
        c2.ContactId = cn.id;
        c2.Subject = 'AH_CaseToOpportunityExt_Test Test Case #2'; 
		c2.AssetId = di2.Id;        
        lstCaseInsert.Add(c2); 

        Case c3 = NI_TestClassData.createTestCase(3, a.Id); 
        c3.ContactId = cn.id;
        c3.Subject = 'AH_CaseToOpportunityExt_Test Test Case #3';         
        lstCaseInsert.Add(c3); 

        Case c4 = NI_TestClassData.createTestCase(4, a.Id); 
        c4.ContactId = cn.id;
        c4.Subject = 'AH_CaseToOpportunityExt_Test Test Case #4';         
        lstCaseInsert.Add(c4); 
        
        Database.insert(lstCaseInsert);

Test.stopTest();
        

        Solution sol = NI_TestClassData.createSolution(1); 
        sol.SolutionName = 'APEX TEST CLASS SOLUTION #1';
        insert sol;
        
/*   REMARKED BECAUSE Solution__c VALUE WAS NOT PERSISTING.     
        // CREATE CUSTOM SETTING
        AH_Case_Solution__c cs = new AH_Case_Solution__c();
        cs.Name = 'Support to Sales';
        cs.Solution__c = sol.SolutionNumber;
        insert cs;        

        AH_Case_Solution__c csAssertion = AH_Case_Solution__c.getValues('Support to Sales'); 
        system.assertEquals(sol.SolutionNumber, csAssertion.Solution__c);
*/ 
        
    }
   
    @isTest static void testCaseToOpportunity1() 
    {      

        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_CaseToOpportunityExt_Test Test Case #1'];
		Solution sol = [SELECT Id, SolutionNumber FROM Solution WHERE SolutionName = 'APEX TEST CLASS SOLUTION #1'];
        
        AH_Case_Solution__c cs = new AH_Case_Solution__c();
        cs.Name = 'Support to Sales';
        cs.Solution__c = sol.SolutionNumber;
        insert cs;        

        AH_Case_Solution__c csAssertion = AH_Case_Solution__c.getValues('Support to Sales'); 
        system.assertEquals(sol.SolutionNumber, csAssertion.Solution__c);
        
        //PAGE REFERENCE
        PageReference pageRef = Page.AH_CaseToOpportunity;
        Test.setCurrentPage(pageRef);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('caseid', c.Id);
Test.StartTest();        
        //INSTANTIATE CONTROLLER
        ApexPages.StandardController ctrl = new ApexPages.standardController(c); 
        AH_CaseToOpportunityExt casectrl = new AH_CaseToOpportunityExt(ctrl);
        casectrl.save();
        casectrl.viewOpportunity();
        casectrl.closeAndReturn();
Test.StopTest();        
        Case caseclosed = [SELECT Id, Reason, Status FROM Case WHERE Id =: c.id];
        system.assertEquals('Closed', caseclosed.Status);

        Opportunity opp = [SELECT Id, Name, Opportunity_Source__c FROM Opportunity WHERE Name = 'AH_CaseToOpportunityExt_Test Account Enterprise PMS - 1'];
        system.assertEquals('Support', opp.Opportunity_Source__c);
        
		List<CaseSolution> cSol = new List<CaseSolution>([SELECT Id FROM CaseSolution WHERE SolutionId =: sol.Id AND CaseId =: caseclosed.Id]);
		system.assertEquals(1, cSol.size());

    }

    @isTest static void testCaseToOpportunity2() 
    {      

        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_CaseToOpportunityExt_Test Test Case #2'];
        Solution sol = [SELECT Id, SolutionNumber FROM Solution WHERE SolutionName = 'APEX TEST CLASS SOLUTION #1'];
        
       	AH_Case_Solution__c cs = new AH_Case_Solution__c();
        cs.Name = 'Support to Sales';
        cs.Solution__c = sol.SolutionNumber;
        insert cs;        

        AH_Case_Solution__c csAssertion = AH_Case_Solution__c.getValues('Support to Sales'); 
        system.assertEquals(sol.SolutionNumber, csAssertion.Solution__c);
        
        //PAGE REFERENCE
        PageReference pageRef = Page.AH_CaseToOpportunity;
        Test.setCurrentPage(pageRef);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('caseid', c.Id);
        
        //INSTANTIATE CONTROLLER
        ApexPages.StandardController ctrl = new ApexPages.standardController(c); 
        AH_CaseToOpportunityExt casectrl = new AH_CaseToOpportunityExt(ctrl);
        casectrl.save();
        casectrl.viewOpportunity();
        casectrl.closeAndReturn();
        
        Case caseclosed = [SELECT Id, Reason, Status FROM Case WHERE Id =: c.id];
        system.assertEquals('Closed', caseclosed.Status);
   
        Opportunity opp = [SELECT Id, Name, Opportunity_Source__c FROM Opportunity WHERE Name = 'AH_CaseToOpportunityExt_Test Account Enterprise PMS - 2'];
        system.assertEquals('Support', opp.Opportunity_Source__c);

		List<CaseSolution> cSol = new List<CaseSolution>([SELECT Id FROM CaseSolution WHERE SolutionId =: sol.Id AND CaseId =: caseclosed.Id]);
		system.assertEquals(1, cSol.size());
        
    }
 
    @isTest static void testCaseToOpportunity3() 
    {      

        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_CaseToOpportunityExt_Test Test Case #3'];
        Solution sol = [SELECT Id, SolutionNumber FROM Solution WHERE SolutionName = 'APEX TEST CLASS SOLUTION #1'];
        
       	AH_Case_Solution__c cs = new AH_Case_Solution__c();
        cs.Name = 'Support to Sales';
        cs.Solution__c = sol.SolutionNumber;
        insert cs;        

        AH_Case_Solution__c csAssertion = AH_Case_Solution__c.getValues('Support to Sales'); 
        system.assertEquals(sol.SolutionNumber, csAssertion.Solution__c);
        
        // PAGE REFERENCE
        PageReference pageRef = Page.AH_CaseToOpportunity;
        Test.setCurrentPage(pageRef);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('caseid', c.Id);
        
        //INSTANTIATE CONTROLLER
        ApexPages.StandardController ctrl = new ApexPages.standardController(c); 
        AH_CaseToOpportunityExt casectrl = new AH_CaseToOpportunityExt(ctrl);

        casectrl.save();
        casectrl.viewOpportunity();
        casectrl.closeAndReturn();
        
        Case caseclosed = [SELECT Id, Reason, Status FROM Case WHERE Id =: c.id];
        system.assertEquals('Closed', caseclosed.Status);
    
        Opportunity opp = [SELECT Id, Name, Opportunity_Source__c FROM Opportunity WHERE Name = 'AH_CaseToOpportunityExt_Test Account'];
        system.assertEquals('Support', opp.Opportunity_Source__c);
        
  		List<CaseSolution> cSol = new List<CaseSolution>([SELECT Id FROM CaseSolution WHERE SolutionId =: sol.Id AND CaseId =: caseclosed.Id]);
		system.assertEquals(1, cSol.size());

    }
    
/*    
    @isTest static void testCaseToOpportunity4() 
    {      

        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_CaseToOpportunityExt_Test Test Case #4'];
    
        User usr = [SELECT Id, Email FROM User WHERE Alias = 'ROU01TST'];

        // TEST AS READ ONLY USER
        system.RunAs(usr)
        { 
            // PAGE REFERENCE
            PageReference pageRef = Page.AH_CaseToOpportunity;
            Test.setCurrentPage(pageRef);
            
            // Put Id into the current page Parameters
            ApexPages.currentPage().getParameters().put('caseid', c.Id);
            
            //INSTANTIATE CONTROLLER
            ApexPages.StandardController ctrl = new ApexPages.standardController(c); 
            AH_CaseToOpportunityExt casectrl = new AH_CaseToOpportunityExt(ctrl);      
            
            casectrl.save();
            
        } 
    
    }
*/   
    
}