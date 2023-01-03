/****************************************************************************************
Name            : NI_Case_TriggerHandlerTest Class
Author          : Stuart Emery
Created Date    : 12/7/2013
Last Mod Date   : 03/19/2018
Last Mod By     : Cybage
NICC Reference  : 
Description     : Test Class that handles all trigger code for the Case Object
                : Updated 02/13/2019 Per NICC-032948
				: 
******************************************************************************************/
@isTest 
private class NI_Case_TriggerHandlerTest 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {

		// CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        //AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPrefernces();
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        upsert caseFlagSetting;    
        
//        system.debug('NI_Case_TriggerHandlerTest.createTestData() - NUMBER OF QUERIES after NI_TestClassData.createTestWinaproachServiceNowSettings() = ' + limits.getQueries());

        // ADDED PER FINANCIALFORCE SUPPORT TO PREVENT WEB SERVICES CALL OUT MESSAGE WHEN RUNNING TEST CLASSES THAT INVOLVE THE CONTACT OBJECT 
//        pt = [SELECT Id, pse__Resource_Geolocation_Trigger_Disabled__c FROM pse__Triggers__c];
//        pt.pse__Resource_Geolocation_Trigger_Disabled__c = true;
//        update(pt);

        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtCaseId = CaseRecordTypeInfo.get('Case').getRecordTypeId();
        
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        flagRecTypes.Name = 'Default';
        flagRecTypes.Enabled_Case_Type__c = String.valueof(rtCaseId);
        flagRecTypes.Enabled_Activity_Types__c = 'Email,Call';
        flagRecTypes.Clear_Case_Origins__c = 'Phone';
        insert flagRecTypes;
        
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'NI_Case_TriggerHandlerTest ACCOUNT';
        insert a;
        
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Jack';
        cnt.LastName = 'King';
        insert cnt;
        
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-001', 'Subscription');
        insert prd;
        
        Product2 prd2 = NI_TestClassData.createProduct2(2, pgp.Id, 'ZZZFULFILL-APEX-002', 'Subscription');
        insert prd2;
        
        // CREATE SOME TEST ASSETS
        List<Asset> lstAssetInsert = new List<Asset>();
        Asset di1 = NI_TestClassData.createTestAsset(1, a.Id, prd.Id); 
        di1.Product_Group__c = pgp.Id; 
        di1.SerialNumber = '123456';
        lstAssetInsert.Add(di1);         
        Asset di2 = NI_TestClassData.createTestAsset(2, a.Id, prd2.Id); 
        di2.Product_Group__c = pgp.Id; 
        lstAssetInsert.Add(di2); 
        
        database.insert(lstAssetInsert);
        
        Solution sol = NI_TestClassData.createSolution(1); 
        sol.SolutionName = 'NI_Case_TriggerHandlerTest Solution';
        insert sol;
        
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
        
        // CREATE TEST SUPPORT TIER DESIGNATIONS
        List<Support_Tier_Designation__c> lstSupportTierInserts = new List<Support_Tier_Designation__c>();

        Support_Tier_Designation__c std1 = NI_TestClassData.createSupportTierDesignation(1, u2.Id, 'Level 1 Support');
        std1.Unique_Support_Rep__c = 'Level 1 Support Tier 1 User';  
        std1.Region__c = 'Americas'; 
        std1.Team__c = 'Representative';
        std1.Inactive__c = false; 
        std1.Manager__c = UserInfo.getUserId(); 
        std1.Business_Domain__c = 'Sales & Catering'; 
        std1.Tier__c = 'Tier 1';
        lstSupportTierInserts.add(std1);

        Support_Tier_Designation__c std2 = NI_TestClassData.createSupportTierDesignation(2, u3.Id, 'Level 2 Support');
        std2.Unique_Support_Rep__c = 'Level 2 Support User'; 
        std2.Region__c = 'Americas'; 
        std2.Team__c = 'Lead Analysts';
        std2.Inactive__c = false; 
        std2.Manager__c = UserInfo.getUserId(); 
        std2.Business_Domain__c = 'Sales & Catering'; 
        std2.Tier__c = null;
        lstSupportTierInserts.add(std2);
        
        Database.insert(lstSupportTierInserts);        
        
        
test.startTest();


        
        //CREATE A TEST VERSION RECORD
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        insert vrs01;
        
        //CREATE A TEST PART RECORD
        SFDC_CSP_Part__c prt01 = NI_TestClassData.createPart(prd.Id, vrs01.Id, 1);
        insert prt01;
        
        //CREATE A TEST CR RECORD
        SFDC_CSP_Development_Request__c cr01 = NI_TestClassData.createChangeRequest(pgp.Id, vrs01.Id, prt01.Id, 1);
        cr01.Title__c = 'NI_Case_TriggerHandlerTest CHANGE REQUEST';
        insert cr01;
        
        BusinessHours bh = [SELECT Id, Name FROM BusinessHours WHERE Name = 'Default' LIMIT 1];
        
		Case cParent = NI_TestClassData.createTestCase(1, a.Id);
        cParent.Subject = 'NI_Case_TriggerHandlerTest PARENT CASE';
        cParent.ContactId = cnt.Id;
        cParent.RecordTypeId = rtCaseId;
        cParent.AH_Enable_Case_Flag__c = true;
        cParent.Origin = 'Internal';
        cParent.BusinessHoursId = bh.Id;
        insert cParent;
        
        // ADD A SOLUTION TO PARENT CASE
        CaseSolution csSol = NI_TestClassData.createCaseSolution(cParent.Id, sol.Id);
        insert csSol;

        Solution_Count__c sc = new Solution_Count__c();
        sc.Case__c = cParent.Id;
        sc.Number_of_Solutions__c = 1;
        insert sc;   
        
        // ASSERT SOLUTION HAS BEEN ATTACHED TO PARENT CASE
        List<Case> lstParentCaseAssertion = new List<Case>([SELECT Id, Number_of_Solutions__c FROM Case WHERE Subject = 'NI_Case_TriggerHandlerTest PARENT CASE' LIMIT 1]);
        system.assertEquals(1, lstParentCaseAssertion[0].Number_of_Solutions__c);
        
        List<Case> lstCases = new List<Case>();
        
        // ADD 100 Open CASES TO INSERT LIST
        //for (integer j = 0; j < 5; j++)
        for (integer j = 0; j < 25; j++)
        {
            Case cs = NI_TestClassData.createTestCase(j, a.Id);
            cs.ContactId = cnt.Id;
            cs.Subject = 'NI_Case_TriggerHandlerTest CHILD CASE #' + String.valueOf(j);
            cs.Description = 'NI_Case_TriggerHandlerTest CHILD CASE DESCRIPTION #' + String.valueOf(j); 
            cs.Status = 'Working';
            cs.Origin = 'Internal';
            cs.AssetId = di1.Id; 
            cs.OwnerId = u.Id;
            cs.RecordTypeId = rtCaseId; 
            cs.BusinessHoursId = bh.Id;
            lstCases.Add(cs);             
        }           

        // ADD 100 CASES TO BE CLOSED 
        //for (integer j = 5; j < 10; j++)
        for (integer j = 25; j < 50; j++)
        {
            Case cs = NI_TestClassData.createTestCase(j, a.Id);
            cs.ContactId = cnt.Id;
            cs.Subject = 'NI_Case_TriggerHandlerTest CHILD CASE CLOSED #' + String.valueOf(j);
            cs.Description = 'NI_Case_TriggerHandlerTest CHILD CASE CLOSED DESCRIPTION #' + String.valueOf(j); 
            cs.Status = 'Working';
            cs.Origin = 'Internal';
            cs.Case_Reason__c = 'Training / HDI';
            cs.Resolution_Type__c = 'Duplicated case';
            cs.AssetId = di1.Id; 
            cs.ParentId = cParent.Id; 
            cs.Customer_Severity__c = '4 - Procedural';
            cs.Has_No_DI__c = false;
            cs.OwnerId = u.Id;
            cs.RecordTypeId = rtCaseId;
            lstCases.Add(cs); 
        }

        System.assertEquals(50, lstCases.Size());
        
        // INSERT 50 CASES
        Database.Insert(lstCases);  
        
        List<Case> lstCaseInsertAsserts = new List<Case>([SELECT Id FROM Case WHERE Subject LIKE 'NI_Case_TriggerHandlerTest CHILD CASE %']);
        System.assertEquals(50, lstCaseInsertAsserts.Size());

test.stopTest();
        
    }
  
    // ======================================================================================================================================= 
    // = TEST METHOD 1: TESTS BULK CLOSING OF 100 CASES
    // ======================================================================================================================================= 
    @isTest static void caseTrigTest1()     
    {       

        Solution sol = [SELECT Id FROM Solution WHERE SolutionName = 'NI_Case_TriggerHandlerTest Solution'];
        List<CaseSolution> lstCaseSolutions = new List<CaseSolution>();
        List<Solution_Count__c> lstSolutionCount = new List<Solution_Count__c>();
        User caseOwner = [SELECT Id FROM User WHERE Username = 'xxxxxxxx1@xxxxxxx.com'];
        Case cParent = [SELECT Id, Status FROM Case WHERE Subject = 'NI_Case_TriggerHandlerTest PARENT CASE'];
        
        //AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPrefernces();
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        upsert caseFlagSetting;   
   
		// CREATE TEST SUPPORT TIER DESIGNATION
        Support_Tier_Designation__c sptdesg = NI_TestClassData.createSupportTierDesignation(1, caseOwner.Id, 'Level 1 Support');
		insert sptdesg;

        // CASES ATTACH A SOLUTION TO ALL CLOSED CASES BEFORE CLOSING
        for (Case ccs : [SELECT Id, Status, Number_of_Solutions__c FROM Case WHERE Subject LIKE 'NI_Case_TriggerHandlerTest CHILD CASE CLOSED %'])
        {
            
            CaseSolution s = NI_TestClassData.createCaseSolution(ccs.Id, sol.Id);
            lstCaseSolutions.Add(s);    
            
            // THIS IS THE CUSTOM OBJECT THAT Case.Number_of_Solutions__c ROLLUP SUMMARY USES
            Solution_Count__c sc = new Solution_Count__c();
            sc.Case__c = ccs.Id;
            sc.Number_of_Solutions__c = 1;
            lstSolutionCount.Add(sc);
            
        } 
                
        Database.Insert(lstCaseSolutions);
        Database.Insert(lstSolutionCount);
        
        List<CaseSolution> lstCaseSolutionAsserts = new List<CaseSolution>([SELECT Id FROM CaseSolution]);
        List<Solution_Count__c> lstSolutionCountAsserts = new List<Solution_Count__c>([SELECT Id FROM Solution_Count__c]);
        
        system.assertEquals(26, lstCaseSolutionAsserts.size());
        system.assertEquals(26, lstSolutionCountAsserts.size());
        
        test.startTest();
        
        List<Case> lstCaseUpdates = new List<Case>();
        
        // CLOSE 100 CASES (IMPORTANT TO INCLUDE Number_of_Solutions__c FIELD SO THAT THE ROLLUP SUMMARY IS INVOKED)
        for (Case ccs2 : [SELECT Id, Status, Number_of_Solutions__c FROM Case WHERE Subject LIKE 'NI_Case_TriggerHandlerTest CHILD CASE CLOSED %'])
        {
            System.assertNotEquals(0, ccs2.Number_of_Solutions__c);
            ccs2.Status = 'Closed';
            ccs2.OwnerId = caseOwner.Id;
            lstCaseUpdates.Add(ccs2);              
        }            
        
        System.assertEquals(lstCaseUpdates.Size(), 25);
        Database.Update(lstCaseUpdates); 

        // VERIFY THAT 100 CASES WHERE CLOSED AND NOW HAVE A CLOSED CASE RECORD TYPE
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();         
        Id rtCaseCloseId = CaseRecordTypeInfo.get('Close Case').getRecordTypeId();        
        List<Case> lstCaseUpdateAsserts = new List<Case>([SELECT Id FROM Case WHERE Status = 'Closed' AND RecordTypeId =: rtCaseCloseId AND Support_Tier__c = 'Level 1 Support']); 
        system.assertEquals(25, lstCaseUpdateAsserts.size());
     
        // CLOSE PARENT TO TEST CaseSolutionTrigger
        cParent.Status = 'Closed';
        update cParent;
        
        test.stopTest();
        
        system.debug('END NI_Case_TriggerHandlerTest.caseTrigTest1() - NUMBER OF QUERIES = ' + limits.getQueries());
        
    }    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: TESTS CR FUNCTIONALITY ON CASES
    // ======================================================================================================================================= 
    @isTest static void caseTrigTest2()     
    {       

        SFDC_CSP_Development_Request__c cr = [SELECT Id FROM SFDC_CSP_Development_Request__c WHERE Title__c = 'NI_Case_TriggerHandlerTest CHANGE REQUEST'];    
        Account a = [SELECT Id FROM Account WHERE Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];        
        Contact cnt = [SELECT Id FROM Contact WHERE FirstName = 'Jack' AND LastName = 'King']; 
        Case c = [SELECT Id FROM Case WHERE Subject = 'NI_Case_TriggerHandlerTest CHILD CASE #5' LIMIT 1];
        Asset d = [SELECT Id FROM Asset WHERE AccountId =: a.Id LIMIT 1];
        
        //AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPrefernces();
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        upsert caseFlagSetting;   
        
        // UPDATE CASE WITH CR
        c.Change_Request__c = cr.Id;
        update c;
        
        // REMOVE CR FROM CASE
        c.Change_Request__c = null;
        update c;       
        
        Test.startTest();
        
        // CREATE NEW CASE WITH CR                   
        Case newCase = NI_TestClassData.createTestCase(300, a.Id);
        newCase.ContactId = cnt.Id;
        newCase.Change_Request__c = cr.Id;
        newCase.Status = 'Working';
        insert newCase;
        
        // UPDATE THE CASE WITH A DI
        newCase.AssetId = d.Id;
        update newCase;
        
        Test.stopTest();
        
        system.debug('END NI_Case_TriggerHandlerTest.caseTrigTest2() - NUMBER OF QUERIES = ' + limits.getQueries());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: TEST CASE RESHARING
    // ======================================================================================================================================= 
    @isTest static void caseTrigTest3()     
    {      
        
        User caseOwnedBy = [SELECT Id FROM User WHERE Username = 'xxxxxxxx3@xxxxxxx.com'];
        User caseOwnerTo = [SELECT Id FROM User WHERE Username = 'xxxxxxxx2@xxxxxxx.com'];
        User caseSharedTo = [SELECT Id FROM User WHERE Username = 'xxxxxxxx1@xxxxxxx.com'];
        Case c = [SELECT Id FROM Case WHERE Subject = 'NI_Case_TriggerHandlerTest CHILD CASE #9' LIMIT 1];
        
        // UPDATE OWNER ON A CASE
        c.OwnerId = caseOwnedBy.Id;
        update c;
        
        // MANUALLY SHARE A CASE TO A USER TO CHECK FOR PERSISTANT SHARING LATER
        CaseShare cs = new CaseShare(CaseAccessLevel = 'Edit', CaseId = c.Id, UserOrGroupId = caseSharedTo.Id);
		insert cs; 
        
        // CHECK IF MANUAL SHARE WAS SUCCESSFUL 
        List<CaseShare> lstCaseShareAssert = new List<CaseShare>([SELECT Id FROM CaseShare WHERE CaseId =: c.Id AND UserOrGroupId =: caseSharedTo.Id AND RowCause = 'Manual']);
        system.assertEquals(1, lstCaseShareAssert.size());
        
        // UPDATE OWNER ON A CASE
        c.OwnerId = caseOwnerTo.Id;
        update c;
        
        // CHECK IF MANUAL RE-SHARE WAS SUCCESSFUL (ASSERT NOT WORKING!) 
//        List<CaseShare> lstCaseReshareAssert = new List<CaseShare>([SELECT Id FROM CaseShare WHERE CaseId =: c.Id AND UserOrGroupId =: caseSharedTo.Id]); //AND RowCause = 'Manual'
//        system.assertEquals(1, lstCaseReshareAssert.size()); 
        
        system.debug('END NI_Case_TriggerHandlerTest.caseTrigTest3() - NUMBER OF QUERIES = ' + limits.getQueries());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 4: TEST CASE RESHARING
    // =======================================================================================================================================     
	@isTest static void caseTrigTest4() 
    {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];
        List<Case> cases = [SELECT Id FROM Case WHERE Subject LIKE 'NI_Case_TriggerHandlerTest CHILD CASE %' LIMIT 1];
        System.debug('Case list in test 4 : '+cases);
        BusinessHours stdBusinessHours = [select id from BusinessHours where Name = 'Default'];
        
        test.startTest();
        
        List<Case> update_cases = new List<Case>();
        for (Case c : cases){
            c.BusinessHoursId = stdBusinessHours.id;
            c.AH_Case_Flagged_Date__c = System.now();
            update_cases.add(c);
        }

        update update_cases;
        
        test.stopTest();
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 5: 
    // =======================================================================================================================================     
    @isTest static void caseTrigTest5() 
    {
        
        test.startTest();
        
        BusinessHours stdBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Default'];
        
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        upsert caseFlagSetting;   
        
        Account a = [SELECT Id FROM Account WHERE Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];
        List<Case> lstCases = new List<Case>(
            [SELECT Id, RecordTypeId, AH_Case_Flagged_Date__c, AH_Enable_Case_Flag__c, Status, OwnerId, 
             AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c,  
             AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c 
             FROM Case WHERE Subject LIKE 'NI_Case_TriggerHandlerTest PARENT CASE' LIMIT 1]);
        
        lstCases[0].BusinessHoursId = stdBusinessHours.Id;
        update lstCases[0];
        
        NI_Case_TriggerHandler caseHandler = new NI_Case_TriggerHandler();
        caseHandler.setCaseFlagRelatedData(lstCases, false, 'Set Flag Button');
        lstCases[0].AH_Case_Flagged_Date__c = DateTime.now().addHours(-1);
        lstCases[0].Origin = 'Phone';
        update lstCases[0];
        
        Case clonedCase = new Case();
        clonedCase = lstCases[0].clone();
        clonedCase.Has_No_DI__c = true;
        clonedCase.Origin = 'Pager';
        insert clonedCase;
        
        caseHandler.clearCaseFlagRelatedData(lstCases, false, 'Clear Flag Button');
        
        test.stopTest();
        
//System.debug('Case list in test 4 : '+cases);
//        BusinessHours stdBusinessHours = [select id from BusinessHours where Name = 'Default'];        
//        test.startTest();
//        List<Case> update_cases = new List<Case>();
//        for (Case c : cases){
//            c.BusinessHoursId = stdBusinessHours.id;
//            c.AH_Case_Flagged_Date__c = System.now();
//            update_cases.add(c);
//        }
//        update update_cases;
//        test.stopTest();
    }

    // ======================================================================================================================================= 
    // = TEST METHOD : Test resetCRLookup() FUNCTION
    // =======================================================================================================================================     
    @isTest static void caseTrigTest6() 
    {
        
        Case c = [SELECT Id, Status, Approval_Status__c, Change_Request__c FROM Case WHERE Subject = 'NI_Case_TriggerHandlerTest PARENT CASE'];
        SFDC_CSP_Development_Request__c cr = [SELECT Id FROM SFDC_CSP_Development_Request__c WHERE Title__c = 'NI_Case_TriggerHandlerTest CHANGE REQUEST']; 
        
        Group grp = [SELECT Id FROM Group WHERE DeveloperName = 'QAmericas' LIMIT 1];
        c.OwnerId = grp.Id;
        c.Approval_Status__c = 'Not Submitted';
        c.Change_Request__c = cr.Id;
        
        update c;
        
        Case cAsserts1 = [SELECT Id, Status, Approval_Status__c, Change_Request__c FROM Case WHERE Subject = 'NI_Case_TriggerHandlerTest PARENT CASE'];
        system.assertNotEquals(null, cAsserts1.Change_Request__c);
        
        Test.startTest();
        
        c.Approval_Status__c = 'Rejected';
        update c;
        
        // ASSERT THAT CHANGING Approval_Status__c TO 'Rejected' NULLS OUT Change_Request__c
        Case cAsserts2 = [SELECT Id, Status, Approval_Status__c, Change_Request__c FROM Case WHERE Subject = 'NI_Case_TriggerHandlerTest PARENT CASE'];
        system.assertEquals(null, cAsserts2.Change_Request__c);

        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 7: TESTS Validate_ClosedCaseDependencies METHOD ON CASES - ADDED PER NICC-032948
    // ======================================================================================================================================= 
    @isTest static void caseTrigTest7()     
    {       
 
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        // Invoke the Validate_ClosedCaseDependencies error message
            Try
            {
                c.Status = 'Closed';
                Update c;
            }
            catch(Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.AH_Case_Support_Case_Closed_Requirements) ? true : false;
                System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
            }                       
               
        system.debug('END NI_Case_TriggerHandlerTest.caseTrigTest7() - NUMBER OF QUERIES = ' + limits.getQueries());
        
    }
   
    // ======================================================================================================================================= 
    // = TEST METHOD 8: Test NI_Case_TriggerHandler.closeUserStoryInRally(List<Case> newTrigger, Map<Id, Case> oldMapTrigger) 
    // ======================================================================================================================================= 
    @isTest static void caseTrigTest8()     
    {      
        
        Account a = [SELECT Id FROM Account WHERE Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];
        Contact cnt = [SELECT Id FROM Contact WHERE FirstName = 'Jack' AND LastName = 'King'];
        Asset di = [SELECT Id FROM Asset WHERE AccountId =: a.Id LIMIT 1]; 
        Solution sol = [SELECT Id FROM Solution WHERE SolutionName = 'NI_Case_TriggerHandlerTest Solution'];
        
        Case cs = NI_TestClassData.createTestCase(888, a.Id);
        cs.ContactId = cnt.Id;
        cs.AssetId = di.Id; 
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId(); 
        cs.Subject = 'NI_Case_TriggerHandlerTest #8';
        cs.Description = 'NI_Case_TriggerHandlerTest #8 description...'; 
        cs.Status = 'Working';
        cs.Origin = 'Internal';
//        cs.Management_Company__c = '';
        cs.Res_Product_Retention_Risk__c = '';
        insert cs;    
        
        CaseSolution cSol = new CaseSolution();
        cSol.CaseId = cs.Id;
        cSol.SolutionId = sol.Id;
        insert cSol;

//        cs.Management_Company__c = 'NEW';
        cs.Res_Product_Retention_Risk__c = 'NEW';        
        cs.Status = 'Closed';
        update cs;
        
        // ASSERT HERE...
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 9a: Test NI_Case_TriggerHandler.writeCaseDetails(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
    // 					Tests creating case as Tier 1 L1, changing owner to Tier 2, closing case as Tier 2 
    // ======================================================================================================================================= 
    @isTest static void caseTrigTest9a()  
    {

system.debug('.    :^^: STARTING caseTrigTest9 '); 
        
        Account a = [SELECT Id FROM Account WHERE Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];        
        Contact cnt = [SELECT Id FROM Contact WHERE FirstName = 'Jack' AND LastName = 'King']; 
        Asset di = [SELECT Id FROM Asset WHERE SerialNumber = '123456'];      
        User usrSupportL1T1 = [SELECT Id, Name FROM User WHERE Username = 'xxxxxxxx2@xxxxxxx.com'];    
        User usrSupportL2 = [SELECT Id, Name FROM User WHERE Username = 'xxxxxxxx3@xxxxxxx.com']; 
        Id newCaseId;

		Test.startTest();
        
        
        // CREATE A CASE AS L1T1 User =========================================
        system.runAs(usrSupportL1T1)
        {
system.debug('.    :^^: INSERT Case as ' + usrSupportL1T1.Name);            
            Case cs = NI_TestClassData.createTestCase(115, a.Id);
            cs.ContactId = cnt.Id;
            cs.Subject = 'NI_Case_TriggerHandlerTest writeCaseDetails 1';
            cs.Description = 'Apex test class description'; 
            cs.Status = 'Working';
            cs.Origin = 'Internal';
            cs.Case_Reason__c = 'Training / HDI';
            cs.Resolution_Type__c = 'Duplicated case';
            cs.AssetId = di.Id; 
            cs.Customer_Severity__c = '4 - Procedural';
            cs.Has_No_DI__c = false;
            cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
            insert cs;    
            newCaseId = cs.Id;
        }        
        
        // ASSERT THAT AH_Case_Report_Detail__c RECORD WAS CREATED 
        List<AH_Case_Report_Detail__c> lstCRDAssert1 = 
            [SELECT Id, Case__c, Detail__c, Event_Type__c, IsOverridden__c, Log_DateTime__c, New_Value__c, Old_Value__c, Time_Elapsed__c, Name 
             FROM AH_Case_Report_Detail__c
             WHERE Case__c =: newCaseId];
system.debug('.    :^^: lstCRDAssert1.size() = ' + lstCRDAssert1.size());
        system.assertEquals(1, lstCRDAssert1.size());
        // ASSERT THAT CASE TRIGGER HANDLER IS SETTING TOGGLE
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Case_Report_Detail);         
        
        
        
        // CHANGE CASE OWNER AS L1T1 User ========================================
        
        // OPEN TOGGLE FOR 1 UPDATE IN TEST THREAD
        NI_TriggerManager.is1stInsert_Case_Report_Detail = true;

        system.runAs(usrSupportL1T1)
        {
system.debug('.    :^^: UPDATE "Change owner" Case as ' + usrSupportL1T1.Name);  
            Case cs2 = [SELECT Id, OwnerId FROM Case WHERE Id =: newCaseId];
            cs2.OwnerId = usrSupportL2.Id;
            update cs2;
            
        }

        // ASSERT THAT AH_Case_Report_Detail__c RECORD WAS CREATED 
        List<AH_Case_Report_Detail__c> lstCRDAssert2 = 
            [SELECT Id, Case__c, Detail__c, Event_Type__c, IsOverridden__c, Log_DateTime__c, New_Value__c, Old_Value__c, Time_Elapsed__c, Name 
             FROM AH_Case_Report_Detail__c
             WHERE Case__c =: newCaseId];
system.debug('.    :^^: lstCRDAssert2.size() = ' + lstCRDAssert2.size());
        system.assertEquals(2, lstCRDAssert2.size());        
        
        // ASSERT THAT CASE TRIGGER HANDLER IS CHANGING FORCED TOGGLE BACK
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Case_Report_Detail); 
        
		
        
        Test.stopTest();
        
        
        // CLOSE CASE AS L2 User ==================================================        
        
        // OPEN TOGGLE FOR 1 UPDATE IN TEST THREAD 
        NI_TriggerManager.is1stInsert_Case_Report_Detail = true;
        
        system.runAs(usrSupportL2)
        {
system.debug('.    :^^: UPDATE "Close" Case as ' + usrSupportL2.Name);  
            Case cs3 = [SELECT Id, OwnerId FROM Case WHERE Id =: newCaseId];
            cs3.Push_Back__c = 'No';
            cs3.Pushback_Stopper__c = 'Amadeus Dependency';
            cs3.Product_Family__c = 'Reservation Solutions';
            cs3.Case_Product_Line__c = 'iHotelier CRS';  
            cs3.Module__c = 'Call Center'; 
            cs3.Component__c = 'ARI Updates';             
            cs3.Status = 'Closed';
            cs3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Close Case').getRecordTypeId();
            update cs3;
            
        }
        
        // ASSERT THAT CASE TRIGGER HANDLER IS CHANGING FORCED TOGGLE BACK
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Case_Report_Detail);         

        // ASSERT THAT AH_Case_Report_Detail__c RECORD WAS CREATED 
        List<AH_Case_Report_Detail__c> lstCRDAssert3 = 
            [SELECT Id, Case__c, Detail__c, Event_Type__c, IsOverridden__c, Log_DateTime__c, New_Value__c, Old_Value__c, Time_Elapsed__c, Name 
             FROM AH_Case_Report_Detail__c
             WHERE Case__c =: newCaseId];
        
system.debug('.    :^^: lstCRDAssert3.size() = ' + lstCRDAssert3.size());
for (AH_Case_Report_Detail__c dBug : lstCRDAssert3)
{
system.debug('.    :^^:: NEW CRD: ' + dBug.Case__c + ', ' + dBug.Event_Type__c + ', ' + dBug.Old_Value__c + ', ' + dBug.New_Value__c + ', ' + dBug.Time_Elapsed__c);
}        
        system.assertEquals(3, lstCRDAssert3.size());        
 
    }        
   
    // ======================================================================================================================================= 
    // = TEST METHOD 9b: Test NI_Case_TriggerHandler.writeCaseDetails(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
    // 					Tests creating case as NON-SUPPORT, changing owner to Tier 1 L1, closing case as Tier 1 L1, reopen case as L2 
    // ======================================================================================================================================= 
    @isTest static void caseTrigTest9b()  
    {
 
system.debug('.    :^^: STARTING caseTrigTest9b '); 
        
        // THIS BLOCK TURNS OFF METHOD CALLS VIA NI_TriggerBypassSwitches__c CUSTOM SETTING TO ISOLATED AND OVERLOAD TEST TO AVOID GOVENOR LIMITS
        //NI_TriggerBypassSwitches__c bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults(); 
		//NI_TriggerBypassSwitches__c bpSwitch = [SELECT Id, Name, BypassCaseFlags_ON__c, BypassCaseReshare_ON__c 
        //                                        FROM NI_TriggerBypassSwitches__c 
        //                                        WHERE Name = 'Bypass Control Panel'];

        NI_TriggerBypassSwitches__c bpSwitch = new NI_TriggerBypassSwitches__c();
        bpSwitch.Name = 'Bypass Control Panel';
        bpSwitch.BypassCaseFlags_ON__c = true;
        bpSwitch.BypassCaseReshare_ON__c = true;
        insert bpSwitch;
        
        NI_TriggerBypassSwitches__c bpSwitchAssert = NI_TriggerBypassSwitches__c.getOrgDefaults(); 
        system.assertEquals(true, bpSwitchAssert.BypassCaseFlags_ON__c);
        system.assertEquals(true, bpSwitchAssert.BypassCaseReshare_ON__c);

        
system.debug(' :SOQL QUERIES 1: = ' + Limits.getQueries());
        
        Account a = [SELECT Id FROM Account WHERE Name = 'NI_Case_TriggerHandlerTest ACCOUNT']; 
        Contact cnt = [SELECT Id FROM Contact WHERE FirstName = 'Jack' AND LastName = 'King']; 
        Asset di = [SELECT Id FROM Asset WHERE SerialNumber = '123456']; 
        User usrNonSupport = [SELECT Id, Name FROM User WHERE Username = 'xxxxxxxx1@xxxxxxx.com']; 
        User usrSupportL1T1 = [SELECT Id, Name FROM User WHERE Username = 'xxxxxxxx2@xxxxxxx.com']; 
        User usrSupportL2 = [SELECT Id, Name FROM User WHERE Username = 'xxxxxxxx3@xxxxxxx.com']; 
        Group q = [SELECT Id FROM Group WHERE DeveloperName = 'QAmericas'];
        Id newCaseId; 
        
system.debug(' :SOQL QUERIES 2: = ' + Limits.getQueries());
        
        // ============================================================================
		//  TEST #1:	CREATE A CASE AS L1T1 User		
        // ============================================================================
        system.runAs(usrNonSupport)
        {
system.debug('.    :^^: INSERT Case as ' + usrNonSupport.Name);            
            Case cs1 = NI_TestClassData.createTestCase(111, a.Id);
            cs1.ContactId = cnt.Id;
            cs1.Subject = 'NI_Case_TriggerHandlerTest writeCaseDetails 1';
            cs1.Description = 'Apex test class description'; 
            cs1.Status = 'Working';
            cs1.Origin = 'Internal';
            cs1.Case_Reason__c = 'Training / HDI';
            cs1.Resolution_Type__c = 'Duplicated case';
            cs1.AssetId = di.Id; 
            cs1.Customer_Severity__c = '4 - Procedural';
            cs1.Has_No_DI__c = false;
            cs1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
            insert cs1;    
            newCaseId = cs1.Id;
        }

        // ============================================================================
		//  ASSERTS #1:		ASSERT THAT AH_Case_Report_Detail__c RECORD WAS CREATED	
        // ============================================================================
        List<AH_Case_Report_Detail__c> lstCRDAssert1 = 
            [SELECT Id, Case__c, Detail__c, Event_Type__c, IsOverridden__c, Log_DateTime__c, New_Value__c, Old_Value__c, Time_Elapsed__c, Name 
             FROM AH_Case_Report_Detail__c
             WHERE Case__c =: newCaseId];
system.debug('.    :^^: lstCRDAssert1.size() = ' + lstCRDAssert1.size());
        system.assertEquals(1, lstCRDAssert1.size());
        // ASSERT THAT CASE TRIGGER HANDLER IS SETTING TOGGLE
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Case_Report_Detail);  

system.debug(' :SOQL QUERIES 3: = ' + Limits.getQueries());
               

        // ============================================================================
		//  TEST #2:	CHANGE OWNER TO A QUEUE		
        // ============================================================================      
        // OPEN TOGGLE FOR 1 UPDATE IN TEST THREAD
        NI_TriggerManager.is1stInsert_Case_Report_Detail = true;      
        system.runAs(usrNonSupport)
        {
            Case cs2 = [SELECT Id, OwnerId FROM Case WHERE Id =: newCaseId];           
            cs2.OwnerId = q.Id;
            update cs2;
        }
        
        // ============================================================================
		//  ASSERTS #2:		ASSERT THAT AH_Case_Report_Detail__c RECORDS WERE CREATED	
        // ============================================================================
        List<AH_Case_Report_Detail__c> lstCRDAssert2 = 
            [SELECT Id, Case__c, Detail__c, Event_Type__c, IsOverridden__c, Log_DateTime__c, New_Value__c, Old_Value__c, Time_Elapsed__c, Name 
             FROM AH_Case_Report_Detail__c
             WHERE Case__c =: newCaseId];
system.debug('.    :^^: lstCRDAssert2.size() = ' + lstCRDAssert2.size());
        system.assertEquals(2, lstCRDAssert2.size());
        // ASSERT THAT CASE TRIGGER HANDLER IS SETTING TOGGLE
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Case_Report_Detail);         

system.debug(' :SOQL QUERIES 4: = ' + Limits.getQueries());
        
        

		Test.startTest();
        

                              
        // ============================================================================
		//  TEST #3:	CHANGE CASE OWNER (Taking ownership) AS L1T1 User	
        // ============================================================================         
        // OPEN TOGGLE FOR 1 UPDATE IN TEST THREAD
        NI_TriggerManager.is1stInsert_Case_Report_Detail = true;
        system.runAs(usrSupportL1T1)
        {
system.debug('.    :^^: UPDATE "Change owner" Case as ' + usrSupportL1T1.Name);  
            Case cs3 = [SELECT Id, OwnerId FROM Case WHERE Id =: newCaseId];
            cs3.OwnerId = usrSupportL1T1.Id;
            update cs3;
        }

        // ============================================================================
		//  ASSERTS #3:		ASSERT THAT AH_Case_Report_Detail__c RECORDS WERE CREATED	
        // ============================================================================
        List<AH_Case_Report_Detail__c> lstCRDAssert3 = 
            [SELECT Id, Case__c, Detail__c, Event_Type__c, IsOverridden__c, Log_DateTime__c, New_Value__c, Old_Value__c, Time_Elapsed__c, Name 
             FROM AH_Case_Report_Detail__c
             WHERE Case__c =: newCaseId];
system.debug('.    :^^: lstCRDAssert3.size() = ' + lstCRDAssert3.size());
        system.assertEquals(3, lstCRDAssert3.size());    
        // ASSERT THAT CASE TRIGGER HANDLER IS CHANGING FORCED TOGGLE BACK
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Case_Report_Detail);         



system.debug(' :SOQL QUERIES 5: = ' + Limits.getQueries());

        // ============================================================================
		//  TEST #4:	CLOSE CASE AS L1 User	
        // ============================================================================          
        // OPEN TOGGLE FOR 1 UPDATE IN TEST THREAD 
        NI_TriggerManager.is1stInsert_Case_Report_Detail = true;      
        system.runAs(usrSupportL1T1)
        {
system.debug('.    :^^: UPDATE "Close" Case as ' + usrSupportL1T1.Name);  
            Case cs4 = [SELECT Id, OwnerId FROM Case WHERE Id =: newCaseId];
            cs4.Push_Back__c = 'No';
            cs4.Pushback_Stopper__c = 'Amadeus Dependency';
            cs4.Product_Family__c = 'Reservation Solutions';
            cs4.Case_Product_Line__c = 'iHotelier CRS';  
            cs4.Module__c = 'Call Center'; 
            cs4.Component__c = 'ARI Updates';             
            cs4.Status = 'Closed';
            cs4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Close Case').getRecordTypeId();
            update cs4;
        }
        
        // ============================================================================
		//  ASSERTS #4:		ASSERT THAT AH_Case_Report_Detail__c RECORDS WERE CREATED	
        // ============================================================================ 
        List<AH_Case_Report_Detail__c> lstCRDAssert4 = 
            [SELECT Id, Case__c, Detail__c, Event_Type__c, IsOverridden__c, Log_DateTime__c, New_Value__c, Old_Value__c, Time_Elapsed__c, Name 
             FROM AH_Case_Report_Detail__c
             WHERE Case__c =: newCaseId];
        // ASSERT THAT CASE TRIGGER HANDLER IS CHANGING FORCED TOGGLE BACK
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Case_Report_Detail);       


system.debug(' :SOQL QUERIES 6: = ' + Limits.getQueries());
                
        // ============================================================================
		//  TEST #5:	REOPEN CASE AS L2 User	
        // ============================================================================         
        // OPEN TOGGLE FOR 1 UPDATE IN TEST THREAD 
        NI_TriggerManager.is1stInsert_Case_Report_Detail = true;           
        system.runAs(usrSupportL2)
        {
system.debug('.    :^^: UPDATE "Reopen" Case as ' + usrSupportL2.Name);  
            Case cs5 = [SELECT Id, OwnerId FROM Case WHERE Id =: newCaseId];           
            cs5.Status = 'Working';
            cs5.OwnerId = usrSupportL2.Id;
            cs5.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
            update cs5;
        }
        
        
        
        Test.stopTest();

        
          
        // ============================================================================
		//  ASSERTS #5:		ASSERT THAT AH_Case_Report_Detail__c RECORDS WERE CREATED	
        // ============================================================================ 
        List<AH_Case_Report_Detail__c> lstCRDAssert5 = 
            [SELECT Id, Case__c, Detail__c, Event_Type__c, IsOverridden__c, Log_DateTime__c, New_Value__c, Old_Value__c, Time_Elapsed__c, Name 
             FROM AH_Case_Report_Detail__c 
             WHERE Case__c =: newCaseId];        
system.debug('.    :^^: lstCRDAssert5.size() = ' + lstCRDAssert5.size());
for (AH_Case_Report_Detail__c dBug : lstCRDAssert5)
{
system.debug('.    :^^:: NEW CRD: ' + dBug.Case__c + ', ' + dBug.Event_Type__c + ', ' + dBug.Old_Value__c + ', ' + dBug.New_Value__c + ', ' + dBug.Time_Elapsed__c);
}        
        system.assertEquals(5, lstCRDAssert5.size());        
        // ASSERT THAT CASE TRIGGER HANDLER IS CHANGING FORCED TOGGLE BACK
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Case_Report_Detail); 
        

system.debug(' :SOQL QUERIES 7: = ' + Limits.getQueries());

    }        
       

    
}