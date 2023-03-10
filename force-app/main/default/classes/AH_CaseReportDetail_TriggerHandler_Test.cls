/************************************************************************************************
Name            : AH_CaseReportDetail_TriggerHandler_Test
Author          : Sean Harris
Created Date    : 02/05/2021 
Last Mod Date   : 02/05/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for AH_CaseReportDetail_TriggerHandler
                : 
                : 
*************************************************************************************************/
@isTest
public class AH_CaseReportDetail_TriggerHandler_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
		// CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        upsert caseFlagSetting;    

        test.startTest();
        
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        flagRecTypes.Name = 'Default';
        flagRecTypes.Enabled_Case_Type__c = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
        flagRecTypes.Enabled_Activity_Types__c = 'Email,Call';
        flagRecTypes.Clear_Case_Origins__c = 'Phone';
        insert flagRecTypes;        
        
        // CREATE TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'NI_Case_TriggerHandlerTest ACCOUNT';
        insert a;
        
        // CREATE TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Jack';
        cnt.LastName = 'King';
        insert cnt;
        
        // CREATE TEST PRODUCT GROUP
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        // CREATE TEST PRODUCTS
        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-001', 'Subscription');
        insert prd;        
        Product2 prd2 = NI_TestClassData.createProduct2(2, pgp.Id, 'ZZZFULFILL-APEX-002', 'Subscription');
        insert prd2;
        
        // CREATE TEST DEPLOYMENT INSTANCES
        List<Asset> lstAssetInsert = new List<Asset>();
        Asset di1 = NI_TestClassData.createTestAsset(1, a.Id, prd.Id); 
        di1.Product_Group__c = pgp.Id; 
        lstAssetInsert.Add(di1);         
        Asset di2 = NI_TestClassData.createTestAsset(2, a.Id, prd2.Id); 
        di2.Product_Group__c = pgp.Id; 
        lstAssetInsert.Add(di2);         
        database.insert(lstAssetInsert);
        
        // CREATE TEST SOLUTION
        Solution sol = NI_TestClassData.createSolution(1); 
        sol.SolutionName = 'AH_CaseReportDetail_TriggerHandler_Test Solution';
        insert sol;
        
        // CREATE TEST USERS
        List<User> lstUserInsert = new List<User>();
        User u1 = NI_TestClassData.createTestUser(1, 'NI Support CSR'); 
        u1.Username = 'xxxxxxxx1@xxxxxxx.com';      
        lstUserInsert.Add(u1);
        User u2 = NI_TestClassData.createTestUser(2, 'NI Support CSR'); 
        u2.Username = 'xxxxxxxx2@xxxxxxx.com'; 
        lstUserInsert.Add(u2);
        User u3 = NI_TestClassData.createTestUser(3, 'NI Support CSR'); 
        u3.Username = 'xxxxxxxx3@xxxxxxx.com'; 
        lstUserInsert.Add(u3);        
        database.insert(lstUserInsert);
        
        User u = lstUserInsert[0];
        
        // CREATE TEST SUPPORT TIER DESIGNATIONS FOR ALL THE TEST USERS CREATED 
        List<Support_Tier_Designation__c> lstSupportTierInserts = new List<Support_Tier_Designation__c>();
        integer i = 0;
        for (User usr : lstUserInsert)
        {
            i++;
            Support_Tier_Designation__c sptdesg = NI_TestClassData.createSupportTierDesignation(i, usr.Id, 'Level ' + string.valueOf(i) + ' Support');
            lstSupportTierInserts.add(sptdesg);   
        }
        
		database.insert(lstSupportTierInserts);       

        //CREATE TEST VERSION RECORD
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        insert vrs01;
        
        //CREATE TEST PART RECORD
        SFDC_CSP_Part__c prt01 = NI_TestClassData.createPart(prd.Id, vrs01.Id, 1);
        insert prt01;
        
        //CREATE TEST CR RECORD
        SFDC_CSP_Development_Request__c cr01 = NI_TestClassData.createChangeRequest(pgp.Id, vrs01.Id, prt01.Id, 1);
        cr01.Title__c = 'AH_CaseReportDetail_TriggerHandler_Test CHANGE REQUEST';
        insert cr01;
        
        BusinessHours bh = [SELECT Id, Name FROM BusinessHours WHERE Name = 'Default' LIMIT 1];
        
        // CREATE TEST CASE RECORD
		Case cs = NI_TestClassData.createTestCase(1, a.Id);
        cs.Subject = 'AH_CaseReportDetail_TriggerHandler_Test CASE';
        cs.ContactId = cnt.Id;
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
        cs.AH_Enable_Case_Flag__c = true;
        cs.Origin = 'Internal';
        cs.BusinessHoursId = bh.Id;
        //Support_Tier_Designation__c
        insert cs;        
        
        // ADD SOLUTION TO PARENT CASE
        CaseSolution csSol = NI_TestClassData.createCaseSolution(cs.Id, sol.Id);
        insert csSol;

        Solution_Count__c sc = new Solution_Count__c();
        sc.Case__c = cs.Id;
        sc.Number_of_Solutions__c = 1;
        insert sc;   
        
        
        test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void Test1()     
    {       
        
        Case cs = [SELECT Id, Status, L1T1_Time__c, L1T2_Time__c, L1T3_Time__c, L1_Time__c, L2T1_Time__c, Contractor_Time__c, Total_Work_Time__c   
                   FROM Case 
                   WHERE Subject = 'AH_CaseReportDetail_TriggerHandler_Test CASE'];
        
        system.debug(' ::**:: AH_CaseReportDetail_TriggerHandler_Test cs = ' + cs);        
        List<AH_Case_Report_Detail__c> lst = new List<AH_Case_Report_Detail__c>([SELECT Id FROM AH_Case_Report_Detail__c]);
        system.debug(' ::**:: AH_CaseReportDetail_TriggerHandler_Test lst = ' + lst);
        system.assert(true);
        
        List<AH_Case_Report_Detail__c> lstCaseRptDets = new List<AH_Case_Report_Detail__c>();
        AH_Case_Report_Detail__c crd01 = new AH_Case_Report_Detail__c();
        crd01.Case__c = cs.Id;
        crd01.Log_DateTime__c = system.now()+1;
        crd01.Event_Type__c = 'Changed';
        crd01.Old_Value__c = 'Non-Support user';  
        crd01.New_Value__c = 'Contractor';              
        crd01.Detail__c = 'E.Norma Stetts changed Support Tier Designation from Non-Support user to Contractor.';
        crd01.Time_Elapsed__c = 50000;
        lstCaseRptDets.add(crd01);
        AH_Case_Report_Detail__c crd02 = new AH_Case_Report_Detail__c();
        crd02.Case__c = cs.Id;
        crd02.Log_DateTime__c = system.now()+2;
        crd02.Event_Type__c = 'Changed';
        crd02.Old_Value__c = 'Contractor';  
        crd02.New_Value__c = 'Level 1 Support Tier 1';              
        crd02.Detail__c = 'Mike Oxmall changed Support Tier Designation from Contractor to Level 1 Support Tier 1.';
        crd02.Time_Elapsed__c = 50000;
        lstCaseRptDets.add(crd02);
        AH_Case_Report_Detail__c crd03 = new AH_Case_Report_Detail__c();
        crd03.Case__c = cs.Id;
        crd03.Log_DateTime__c = system.now()+3;
        crd03.Event_Type__c = 'Changed';
        crd03.Old_Value__c = 'Level 1 Support Tier 1';  
        crd03.New_Value__c = 'Level 1 Support Tier 2';              
        crd03.Detail__c = 'Drew Peacock changed Support Tier Designation from Level 1 Support Tier 1 to Level 1 Support Tier 2.';
        crd03.Time_Elapsed__c = 50000;
        lstCaseRptDets.add(crd03);
        
        database.insert(lstCaseRptDets);
 
        AH_Case_Report_Detail__c crd = lstCaseRptDets[0];
        crd.Log_DateTime__c = system.now()-1;
        update crd;
        
        Case cs2 = [SELECT Id, Status, L1T1_Time__c, L1T2_Time__c, L1T3_Time__c, L1_Time__c, L2T1_Time__c, Contractor_Time__c, Total_Work_Time__c   
                    FROM Case 
                    WHERE Subject = 'AH_CaseReportDetail_TriggerHandler_Test CASE'];        
        system.debug(' ::**:: AH_CaseReportDetail_TriggerHandler_Test cs (AFTER) = ' + cs2);  
        
    }
    
}