/****************************************************************************************
Name            : AH_CaseReportDetailSync_Ctlr_Test
Author          : Sean Harris
Created Date    : 04/30/2021
Last Mod Date   : 04/30/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for the AH_CaseReportDetailSync_Ctlr Controller Class.
                :            
******************************************************************************************/
@isTest
public class AH_CaseReportDetailSync_Ctlr_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        Test.startTest();

        // CREATE SOME TEST USERS
        List<User> lstUserInsert = new List<User>();
        User u1 = NI_TestClassData.createTestUser(1, 'AH Support CSR - Lightning'); 
        u1.Username = 'xxxxxxxx1@xxxxxxx.com';      
        lstUserInsert.Add(u1);
        User u2 = NI_TestClassData.createTestUser(2, 'AH Support CSR - Lightning'); 
        u2.Username = 'xxxxxxxx2@xxxxxxx.com'; 
        lstUserInsert.Add(u2);
        User u3 = NI_TestClassData.createTestUser(3, 'AH Support CSR - Lightning'); 
        u3.Username = 'xxxxxxxx3@xxxxxxx.com'; 
        lstUserInsert.Add(u3);
        
        database.insert(lstUserInsert);
        
        User u = lstUserInsert[0];
        
        // CREATE TEST ACCOUNT
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtPropertyAccountId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();        

        Account a = NI_TestClassData.createTestAccount(2);
        a.Name = 'APEX TEST ACCOUNT FOR AH_CaseReportDetailSync_Ctlr_Test';
        a.RecordTypeId = rtPropertyAccountId;
        insert a;

        // CREATE TEST SOLUTION RECORD
        Solution sol = NI_TestClassData.createSolution(1); 
        sol.SolutionName = 'ASEM BEO Test Solution';
        sol.Solution_Category__c = 'Systems Engineering';
        sol.Business_Domain__c = 'S&C';
        sol.Status = 'Active';   
        insert sol;      
        
        // CREATE TEST SUPPORT TIER DESIGNATIONS
        List<Support_Tier_Designation__c> lstSupportTierInserts = new List<Support_Tier_Designation__c>();

        Support_Tier_Designation__c std1 = NI_TestClassData.createSupportTierDesignation(1, u2.Id, 'Level 1 Support');
        std1.Region__c = 'Americas'; 
        std1.Team__c = 'Representative';
        std1.Inactive__c = false; 
        std1.Manager__c = UserInfo.getUserId(); 
        std1.Business_Domain__c = 'Sales & Catering'; 
        std1.Tier__c = 'Tier 1';
        std1.Unique_Support_Rep__c = 'APEXTEST1';
        lstSupportTierInserts.add(std1);

        Support_Tier_Designation__c std2 = NI_TestClassData.createSupportTierDesignation(2, u3.Id, 'Level 2 Support');
        std2.Region__c = 'Americas'; 
        std2.Team__c = 'Lead Analysts';
        std2.Inactive__c = false; 
        std2.Manager__c = UserInfo.getUserId(); 
        std2.Business_Domain__c = 'Sales & Catering'; 
        std2.Tier__c = null;
        std2.Unique_Support_Rep__c = 'APEXTEST2';
        lstSupportTierInserts.add(std2);

        Support_Tier_Designation__c std3 = NI_TestClassData.createSupportTierDesignation(3, UserInfo.getUserId(), 'Level 1 Support');
        std3.Region__c = 'Americas'; 
        std3.Team__c = 'Representative';
        std3.Inactive__c = false; 
        std3.Manager__c = UserInfo.getUserId(); 
        std3.Business_Domain__c = 'Sales & Catering'; 
        std3.Tier__c = 'Tier 3';
        std3.Unique_Support_Rep__c = 'APEXTEST3';
        lstSupportTierInserts.add(std3);

        Database.insert(lstSupportTierInserts);        
                
        
        // CREATE TEST CASE RECORD
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'APEX TEST CASE FOR AH_CaseReportDetailSync_Ctlr_Test';
        insert c;

        CaseSolution csol = NI_TestClassData.createCaseSolution(c.Id, sol.Id);
        insert csol;        
        
        List<AH_Case_Report_Detail__c> lstCaseRptDets = new List<AH_Case_Report_Detail__c>();
        
        AH_Case_Report_Detail__c crd01 = new AH_Case_Report_Detail__c();
        crd01.Case__c = c.Id;
        crd01.Log_DateTime__c = system.now()+1;
        crd01.Event_Type__c = 'Changed';
        crd01.Old_Value__c = 'Non-Support user';  
        crd01.New_Value__c = 'Contractor';              
        crd01.Detail__c = 'John Doe changed Support Tier Designation from Non-Support user to Contractor.';
        crd01.Time_Elapsed__c = 50000;
        lstCaseRptDets.add(crd01);
        
        AH_Case_Report_Detail__c crd02 = new AH_Case_Report_Detail__c();
        crd02.Case__c = c.Id;
        crd02.Log_DateTime__c = system.now()+2;
        crd02.Event_Type__c = 'Changed';
        crd02.Old_Value__c = 'Contractor';  
        crd02.New_Value__c = 'Level 1 Support Tier 1';              
        crd02.Detail__c = 'Jane Doe changed Support Tier Designation from Contractor to Level 1 Support Tier 1.';
        crd02.Time_Elapsed__c = 50000;
        lstCaseRptDets.add(crd02);
        
        AH_Case_Report_Detail__c crd03 = new AH_Case_Report_Detail__c();
        crd03.Case__c = c.Id;
        crd03.Log_DateTime__c = system.now()+3;
        crd03.Event_Type__c = 'Changed';
        crd03.Old_Value__c = 'Level 1 Support Tier 1';  
        crd03.New_Value__c = 'Level 1 Support Tier 2';              
        crd03.Detail__c = 'Fred Flintsone changed Support Tier Designation from Level 1 Support Tier 1 to Level 1 Support Tier 2.';
        crd03.Time_Elapsed__c = 50000;
        lstCaseRptDets.add(crd03);
        
        AH_Case_Report_Detail__c crd04 = new AH_Case_Report_Detail__c();
        crd04.Case__c = c.Id;
        crd04.Log_DateTime__c = system.now()+4;
        crd04.Event_Type__c = 'Changed';
        crd04.Old_Value__c = 'Level 1 Support Tier 2';  
        crd04.New_Value__c = 'Level 1 Support Tier 3';              
        crd04.Detail__c = 'Fred Flintsone changed Support Tier Designation from Level 1 Support Tier 1 to Level 1 Support Tier 2.';
        crd04.Time_Elapsed__c = 50000;
        lstCaseRptDets.add(crd04);        
        
        AH_Case_Report_Detail__c crd05 = new AH_Case_Report_Detail__c();
        crd05.Case__c = c.Id;
        crd05.Log_DateTime__c = system.now()+5;
        crd05.Event_Type__c = 'Changed';
        crd05.Old_Value__c = 'Level 1 Support Tier 3';  
        crd05.New_Value__c = 'Level 2 Support';              
        crd05.Detail__c = 'Fred Flintsone changed Support Tier Designation from Level 1 Support Tier 1 to Level 1 Support Tier 2.';
        crd05.Time_Elapsed__c = 50000;
        lstCaseRptDets.add(crd05);  
        
        AH_Case_Report_Detail__c crd06 = new AH_Case_Report_Detail__c();
        crd06.Case__c = c.Id;
        crd06.Log_DateTime__c = system.now()+6;
        crd06.Event_Type__c = 'Changed';
        crd06.Old_Value__c = 'Level 2 Support';  
        crd06.New_Value__c = 'Level 2 Support';              
        crd06.Detail__c = 'Fred Flintsone changed Support Tier Designation from Level 1 Support Tier 1 to Level 1 Support Tier 2.';
        crd06.Time_Elapsed__c = 50000;
        lstCaseRptDets.add(crd06);         
        
        database.insert(lstCaseRptDets);        
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        Case c = [SELECT Id, L1T1_Time__c, L1T2_Time__c, L1T3_Time__c, L1_Time__c, L2T1_Time__c, Contractor_Time__c, Total_Work_Time__c
                  FROM Case 
                  WHERE Subject = 'APEX TEST CASE FOR AH_CaseReportDetailSync_Ctlr_Test'];
        List<AH_Case_Report_Detail__c> lst = new List<AH_Case_Report_Detail__c>([SELECT Id FROM AH_Case_Report_Detail__c LIMIT 10]);
        
        Test.startTest();
     
        List<Support_Tier_Designation__c> lstSTD_Test = new List<Support_Tier_Designation__c>(
            [SELECT Id, Support_Rep__c, Support_Rep_Role__c, Unique_Support_Rep__c, 
             Department__c, Office__c, Region__c, Team__c, Support_Departure_Date__c, 
             Inactive__c, Manager__c, Business_Domain__c, Do_Not_Report__c, Tier__c 
             FROM Support_Tier_Designation__c
             //WHERE Unique_Support_Rep__c LIKE 'APEXTEST%'
            ]);
        system.assertNotEquals(0, lstSTD_Test.size());
        
        //List<CaseHistory> lstCaseHistory = new List<CaseHistory>([SELECT Id FROM CaseHistory WHERE CaseId =: c.Id]);
        //system.assertNotEquals(0, lstCaseHistory.size());

        // INSTANTIATE PAGE REFERENCE
        PageReference pr = Page.AH_CaseReportDetailSync;
        Test.setCurrentPage(pr);             
        
        // ADD URL PARAMS
        pr.getParameters().put('id', c.Id);
        
        // INSTANTIATE PAGE CONTROLLER 
        ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(lst);
        AH_CaseReportDetailSync_Ctlr ctrl = new AH_CaseReportDetailSync_Ctlr(stdSetCtrl);    

        ctrl.doRollupRecalc();
        
        ctrl.rebuildFromCaseHistory();
        
        ctrl.hideConfirmation();
        
        ctrl.rebuildPrompt();
        
        ctrl.rebuildFromCaseHistory();
        
        system.debug(ctrl.lstCaseRptDetInserts);
        
        ctrl.doRebuild();
        
        ctrl.getCurrentCaseRptDets(null);
        ctrl.doSort();
        ctrl.sortByDirection = 'DESC';
        ctrl.doSort();
        
        ctrl.closeRebuildView();
        
        ctrl.backToCase();
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: 
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {    
        Test.startTest();
    	Database.executeBatch(new AH_CaseReportDetailSyncBatch(system.now().addDays(-1), system.now(), false), 1);
        Test.stopTest();
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: 
    // ======================================================================================================================================= 
    @isTest static void test3() 
    {    
        Test.startTest();
    	Database.executeBatch(new AH_CaseReportDetailSyncBatch(system.now(), system.now(), true), 1);
        Test.stopTest();
    }    
}