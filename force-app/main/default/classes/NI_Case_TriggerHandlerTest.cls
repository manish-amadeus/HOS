/****************************************************************************************
Name            : NI_Case_TriggerHandlerTest Class
Author          : Stuart Emery
Created Date    : 12/07/2013
Last Mod Date   : 12/19/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test Class that handles all trigger code for the Case Object
                : 02/13/2019 Updated Per NICC-032948
            	: 03/02/2022 Optimized to prevent "You or your organization has exceeded the maximum limit for this feature"
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

        system.debug(' ##### createTestData Before - Limits.getQueries() = ' + Limits.getQueries());
        
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        upsert caseFlagSetting;    
        
        // CREATE CASE FLAGS CUSTOM SETTING
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        flagRecTypes.Name = 'Default';
        flagRecTypes.Enabled_Case_Type__c = String.valueof(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId());
        flagRecTypes.Enabled_Activity_Types__c = 'Email,Call';
        flagRecTypes.Clear_Case_Origins__c = 'Phone';
        insert flagRecTypes;
        
        system.debug(' ##### createTestData 1 - Limits.getQueries() = ' + Limits.getQueries()); 
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'NI_Case_TriggerHandlerTest ACCOUNT';
        insert a;
        
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Joe';
        cnt.LastName = 'King';
        insert cnt;
        
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-001', 'Subscription');
        insert prd;
        
        Product2 prd2 = NI_TestClassData.createProduct2(2, pgp.Id, 'ZZZFULFILL-APEX-002', 'Subscription');
        insert prd2;
        
        system.debug(' ##### createTestData 2 - Limits.getQueries() = ' + Limits.getQueries());     
        
        // TEST ASSETS
        List<Asset> lstAssetInsert = new List<Asset>();        
        Asset di1 = NI_TestClassData.createTestAsset(1, a.Id, prd.Id); 
        di1.Product_Group__c = pgp.Id; 
        di1.SerialNumber = '123456';
        lstAssetInsert.Add(di1);             
        Asset di2 = NI_TestClassData.createTestAsset(2, a.Id, prd2.Id); 
        di2.Product_Group__c = pgp.Id; 
        lstAssetInsert.Add(di2);         
        database.insert(lstAssetInsert);
        
        system.debug(' ##### createTestData 3 - Limits.getQueries() = ' + Limits.getQueries());  
        
        // TEST SOLUTION        
        Solution sol = NI_TestClassData.createSolution(1); 
        sol.SolutionName = 'NI_Case_TriggerHandlerTest Solution';
        insert sol;
        
        // TEST USERS
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
        // INTEGRATION USER
        User u4 = NI_TestClassData.createTestUser(4, 'NI Administrator'); 
        u4.Username = 'test_integration_user@xxxxxxx.com'; 
        u4.FirstName = 'Test';
        u4.LastName = 'Integration-User';
        lstUserInsert.Add(u4);  
        // CUSTOMER EXPERIENCE USER  
        User u5 = NI_TestClassData.createTestUser(5, 'AH Customer Community Plus Login User');
        u5.ContactId = cnt.Id;
        u5.Username = 'joe.king.@amadeushospitality.com.ahcc';
        u5.Email = 'joe.king@zzzzzzzzz.org';
        lstUserInsert.Add(u5);
        database.insert(lstUserInsert);
        
        system.debug(' ##### createTestData 4 - Limits.getQueries() = ' + Limits.getQueries());
        
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
        
        system.debug(' ##### createTestData 5 - Limits.getQueries() = ' + Limits.getQueries());          
        
        // TEST VERSION 
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        insert vrs01;
        
        // TEST PART 
        SFDC_CSP_Part__c prt01 = NI_TestClassData.createPart(prd.Id, vrs01.Id, 1);
        insert prt01;
        
        // TEST CR 
        SFDC_CSP_Development_Request__c cr01 = NI_TestClassData.createChangeRequest(pgp.Id, vrs01.Id, prt01.Id, 1);
        cr01.Title__c = 'NI_Case_TriggerHandlerTest CHANGE REQUEST';
        insert cr01;
        
        
        test.startTest();
        
        system.debug(' ##### createTestData - test.startTest()');        
        
        BusinessHours bh = [SELECT Id, Name FROM BusinessHours WHERE Name = 'Default' LIMIT 1];
        
        system.debug(' ##### createTestData 6 - Limits.getQueries() = ' + Limits.getQueries());  
        
        // TEST PARENT CASE
        Case cParent = NI_TestClassData.createTestCase(1, a.Id);
        cParent.Subject = 'NI_Case_TriggerHandlerTest PARENT CASE';
        cParent.ContactId = cnt.Id;
        cParent.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
        cParent.AH_Enable_Case_Flag__c = true;
        cParent.Origin = 'Internal';
        cParent.BusinessHoursId = bh.Id;
        insert cParent;
        
        // ADD A SOLUTION TO PARENT CASE
        CaseSolution csSol = NI_TestClassData.createCaseSolution(cParent.Id, sol.Id);
        insert csSol;
        
        system.debug(' ##### createTestData 7 - Limits.getQueries() = ' + Limits.getQueries());  
        
        Solution_Count__c sc = new Solution_Count__c();
        sc.Case__c = cParent.Id;
        sc.Number_of_Solutions__c = 1;
        insert sc;   
        
        // TEST CHILD CASE
        Case cs = NI_TestClassData.createTestCase(1001, a.Id);
        cs.ContactId = cnt.Id;
        cs.Subject = 'NI_Case_TriggerHandlerTest CHILD CASE';
        cs.Description = 'NI_Case_TriggerHandlerTest CHILD CASE DESCRIPTION'; 
        cs.Status = 'Working';
        cs.Origin = 'Internal';
        cs.AssetId = di1.Id; 
        cs.OwnerId = u1.Id;
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId(); 
        cs.BusinessHoursId = bh.Id;                
        cs.Approval_Status__c = 'Not Submitted';
        insert cs;  
        
        system.debug(' ##### createTestData 8 - Limits.getQueries() = ' + Limits.getQueries());        
        system.debug(' ##### createTestData - test.stopTest()');  
        
        test.stopTest();
        
        system.debug(' ##### createTestData After - Limits.getQueries() = ' + Limits.getQueries());        
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: TEST EMAIL-TO-CASE CASE CREATION
    // =======================================================================================================================================     
    @isTest static void Test1()     
    {  
        
        system.debug(' ##### Test1 Before - Limits.getQueries() = ' + Limits.getQueries());
        
        Account a = [SELECT Id, IsCustomerPortal FROM Account WHERE Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];       
        User ccxUsr = [SELECT Id FROM User WHERE Username = 'joe.king.@amadeushospitality.com.ahcc'];       
        User iUser = [SELECT Id FROM User WHERE Username = 'test_integration_user@xxxxxxx.com'];
        Id cdId;
        
        system.runAs(iUser)
        {
            
            // EMAIL-TO-CASE CASE CREATION "EMULATION"
            // NOTE: NOT A TRUE EXECUTE PATH BECAUSE IT CAN'T BE INVOKED IN TEST CONTEXT
            Case c = NI_TestClassData.createTestCase(2002, null);
            c.Subject = 'NI_Case_TriggerHandlerTest EMAIL-TO-CASE';
            c.Description = 'NI_Case_TriggerHandlerTest EMAIL-TO-CASE DESCRIPTION'; 
            c.Priority = '3 - Medium';
            c.Origin = 'Email';       
            c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId(); 
            c.SuppliedEmail = 'joe.king@zzzzzzzzz.org';            
            insert c;            
            
            // SHARE CASE TO EXPERIENCE USER 
            // NOTE: NORMALLY SF WILL DO THIS ON A REAL EMAIL-TO-CASE BUT EMULATION IS MANUAL
            CaseShare cs = new CaseShare(CaseAccessLevel = 'Edit', CaseId = c.Id, UserOrGroupId = ccxUsr.Id);
            insert cs;             
            
            // EMAIL-TO-CASE EMAIL MESSAGE CREATION EMULATION 
            EmailMessage em = NI_TestClassData.createTestEmailMessage(1, c.Id, 'Joe King', 'joe.king@zzzzzzzzz.org', 'amadeusSpt@xxxxxxx.com', null, null, 'Apex Test Email', 'Apex Test Email Body', '1');
            em.Subject = 'From Joe King: Half these tiles are busted!';
            insert em;
            
            // EMAIL-TO-CASE ATTACHMENT CREATION EMULATION 
            ContentVersion cv = new ContentVersion(
                Title = 'Broken Sandlewood Tiles',
                PathOnClient = 'Pic.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert cv;
            
            // EMAIL-TO-CASE CONTENTDOCUMENTLINK CREATION EMULATION 
            List<ContentDocument> lstDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            cdId = lstDocs[0].Id;
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = em.Id;
            cdl.ContentDocumentId = cdId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
            
        }
        
        // ASSERTIONS =====================================================================
        
        // ASSERT ACCOUNT WAS TURNED TO PORTAL ENABLED IN THE PROCESS OF CCEX USER CREATION
        system.assert(a.IsCustomerPortal);  
        
        // ASSERT CASE WAS CREATED WITH ASSIGNED SuppliedEmail
        Case csAssert1 = [SELECT Id, Subject, Description, Priority, Origin, RecordTypeId, SuppliedEmail 
                          FROM Case 
                          WHERE Subject = 'NI_Case_TriggerHandlerTest EMAIL-TO-CASE'];
        
        system.assertEquals('joe.king@zzzzzzzzz.org', csAssert1.SuppliedEmail);
        
        // AS CUSTOMER CENTRAL EXPERIENCE USER, TRY TO ACCESS ATTACHMENT
        system.runAs(ccxUsr)
        {
            
            List<EmailMessage> lstEMAssert = new List<EmailMessage>([SELECT Id FROM EmailMessage WHERE ParentId =: csAssert1.Id]); 
            system.assertEquals(1, lstEMAssert.size(), 'EmailMessage test record failed to create!');
            
            List<ContentDocument> lstCDAssert = new List<ContentDocument>([SELECT Id, Title FROM ContentDocument WHERE Id =: cdId]); 
            system.assertNotEquals(0, lstEMAssert.size(), 'Customer Central User cannot access the attachment on EmailMessage!');
            
        }
        
        system.debug(' ##### Test1 After - Limits.getQueries() = ' + Limits.getQueries());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: TESTS CR FUNCTIONALITY ON CASES
    // ======================================================================================================================================= 
    @isTest static void Test2()     
    {       
        
        system.debug(' ##### Test2 Before - Limits.getQueries() = ' + Limits.getQueries());
        
        SFDC_CSP_Development_Request__c cr = [SELECT Id FROM SFDC_CSP_Development_Request__c WHERE Title__c = 'NI_Case_TriggerHandlerTest CHANGE REQUEST'];    
        Account a = [SELECT Id FROM Account WHERE Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];        
        Contact cnt = [SELECT Id FROM Contact WHERE FirstName = 'Joe' AND LastName = 'King']; 
        Case c = [SELECT Id FROM Case WHERE Subject = 'NI_Case_TriggerHandlerTest CHILD CASE'];
        Asset d = [SELECT Id FROM Asset WHERE AccountId =: a.Id LIMIT 1];
        
        // UPDATE CASE WITH CR
        c.Change_Request__c = cr.Id;
        update c;
        
        // REMOVE CR FROM CASE
        c.Change_Request__c = null;
        update c; 
        
        system.debug(' ##### Test2 #1 - Limits.getQueries() = ' + Limits.getQueries());
        
        Test.startTest();
        
        system.debug(' ##### test.startTest();');   
        
        // CREATE NEW CASE WITH CR                   
        Case newCase = NI_TestClassData.createTestCase(300, a.Id);
        newCase.ContactId = cnt.Id;
        newCase.Change_Request__c = cr.Id;
        newCase.Status = 'Working';
        insert newCase;
        
        // UPDATE THE CASE WITH A DI
        newCase.AssetId = d.Id;
        update newCase;
        
        system.debug(' ##### Test2 #2 - Limits.getQueries() = ' + Limits.getQueries());        
        system.debug(' ##### Test2 - test.stopTest()');   
        
        Test.stopTest();
        
        
        // TODO: CYBAGE TO CREATE UNIT TESTS HERE
        
        
        system.debug(' ##### Test2 After - Limits.getQueries() = ' + Limits.getQueries());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: TEST CASE RESHARING
    // ======================================================================================================================================= 
    @isTest static void Test3()     
    {      
        
        system.debug(' ##### Test3 Before - Limits.getQueries() = ' + Limits.getQueries());
        
        User caseOwnedBy = [SELECT Id FROM User WHERE Username = 'xxxxxxxx3@xxxxxxx.com'];
        User caseOwnerTo = [SELECT Id FROM User WHERE Username = 'xxxxxxxx2@xxxxxxx.com'];
        User caseSharedTo = [SELECT Id FROM User WHERE Username = 'xxxxxxxx1@xxxxxxx.com'];
        Case c = [SELECT Id FROM Case WHERE Subject = 'NI_Case_TriggerHandlerTest CHILD CASE'];
        
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
        List<CaseShare> lstCaseReshareAssert = new List<CaseShare>([SELECT Id FROM CaseShare WHERE CaseId =: c.Id AND UserOrGroupId =: caseSharedTo.Id]); //AND RowCause = 'Manual'
        system.assertEquals(1, lstCaseReshareAssert.size()); 
        
        system.debug(' ##### Test3 After - Limits.getQueries() = ' + Limits.getQueries());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 4: 
    // =======================================================================================================================================     
    @isTest static void Test4() 
    {
        
        system.debug(' ##### Test4 Before - Limits.getQueries() = ' + Limits.getQueries());
        
        BusinessHours stdBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Default'];
        
        system.debug(' ##### Test4 #1 - Limits.getQueries() = ' + Limits.getQueries());
        
        Test.startTest();
        
        system.debug(' ##### Test4 - test.startTest()');          
        
        List<Case> lstCases = new List<Case>();
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'NI_Case_TriggerHandlerTest CHILD CASE'];
        c.BusinessHoursId = stdBusinessHours.Id;
        c.AH_Case_Flagged_Date__c = system.now();
        update c;
        
        system.debug(' ##### Test4 #2 - Limits.getQueries() = ' + Limits.getQueries());        
        system.debug(' ##### Test4 - test.stopTest()');   
        
        Test.stopTest();
        
        
        // TODO: CYBAGE TO CREATE UNIT TESTS HERE
        
        
        system.debug(' ##### Test4 Before - Limits.getQueries() = ' + Limits.getQueries());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 5: CASE FLAG RELATED TESTING
    // =======================================================================================================================================     
    @isTest static void Test5() 
    {
        
        system.debug(' ##### Test5 Before - Limits.getQueries() = ' + Limits.getQueries());
        
        BusinessHours stdBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Default'];
        List<Case> lstCases = new List<Case>();
        Case c = [SELECT Id, RecordTypeId, AH_Case_Flagged_Date__c, AH_Enable_Case_Flag__c, Status, OwnerId, 
                  AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c,  
                  AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c 
                  FROM Case 
                  WHERE Subject = 'NI_Case_TriggerHandlerTest PARENT CASE'];
        
        c.BusinessHoursId = stdBusinessHours.Id;
        update c;
        
        system.debug(' ##### Test5 #1 - Limits.getQueries() = ' + Limits.getQueries());
        
        lstCases.add(c);
        NI_Case_TriggerHandler caseHandler = new NI_Case_TriggerHandler();
        caseHandler.setCaseFlagRelatedData(lstCases, false, 'Set Flag Button');
        c.AH_Case_Flagged_Date__c = DateTime.now().addHours(-1);
        c.Origin = 'Phone';
        update c;
        
        system.debug(' ##### Test5 #2 - Limits.getQueries() = ' + Limits.getQueries());                        
        system.debug(' ##### Test5 - test.startTest();');    
        
        test.startTest();
        
        Case clonedCase = new Case();
        clonedCase = c.clone();
        clonedCase.Has_No_DI__c = true;
        clonedCase.Origin = 'Pager';
        insert clonedCase;
        
        system.debug(' ##### Test5 #3 - Limits.getQueries() = ' + Limits.getQueries());
        
        caseHandler.clearCaseFlagRelatedData(lstCases, false, 'Clear Flag Button');
        
        system.debug(' ##### Test5 #4 - Limits.getQueries() = ' + Limits.getQueries());
        system.debug(' ##### Test5 - test.stopTest()'); 
        
        test.stopTest();
        
        
        // TODO: CYBAGE TO CREATE UNIT TESTS HERE
        
        
        system.debug(' ##### Test5 After - Limits.getQueries() = ' + Limits.getQueries());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 6: TEST resetCRLookup() FUNCTION 
    // 
    //                  NOTE: HAVING PROBLEMS WITH THIS TEST METHOD:
    //                  System.DmlException: Update failed. First exception on row 0 with id 50059000005vPSSAA2; first error: CANNOT_EXECUTE_FLOW_TRIGGER, 
    //                  We can't save this record because the “Case - Invoke CR Approval Process” process failed. Give your Salesforce admin these details. 
    //                  Too many retries of batch save in the presence of Apex triggers with failures: 
    //                  when triggers are present partial save requires that some subset of rows save without any errors in order to avoid inconsistent 
    //                  side effects from those triggers. Number of retries: 2
    //                  
    // =======================================================================================================================================     
    @isTest static void Test6() 
    {
        
        system.debug(' ##### Test6 Before - Limits.getQueries() = ' + Limits.getQueries());
        
        Case c = [SELECT Id, Status, Approval_Status__c, Change_Request__c FROM Case WHERE Subject = 'NI_Case_TriggerHandlerTest PARENT CASE'];
        SFDC_CSP_Development_Request__c cr = [SELECT Id FROM SFDC_CSP_Development_Request__c WHERE Title__c = 'NI_Case_TriggerHandlerTest CHANGE REQUEST']; 
        //        Group grp = [SELECT Id FROM Group WHERE DeveloperName = 'Q_L1_Tier_1_Support' LIMIT 1];
        
        //        c.OwnerId = grp.Id;
        c.Change_Request__c = cr.Id;
        update c;
        
        Case cAsserts1 = [SELECT Id, Status, Approval_Status__c, Change_Request__c FROM Case WHERE Subject = 'NI_Case_TriggerHandlerTest PARENT CASE'];
        system.assertNotEquals(null, cAsserts1.Change_Request__c);                
        
        system.debug(' ##### Test6 #1 - Limits.getQueries() = ' + Limits.getQueries());
        system.debug(' ##### test.startTest();');    
        
        Test.startTest();                       
        
        c.Approval_Status__c = 'Rejected';
        update c;
        
        // ASSERT THAT CHANGING Approval_Status__c TO 'Rejected' NULLS OUT Change_Request__c
        Case cAsserts2 = [SELECT Id, Status, Approval_Status__c, Change_Request__c FROM Case WHERE Subject = 'NI_Case_TriggerHandlerTest PARENT CASE'];
        system.assertEquals(null, cAsserts2.Change_Request__c);
        
        system.debug(' ##### Test6 #2 - Limits.getQueries() = ' + Limits.getQueries());
        system.debug(' ##### test.stopTest();');   
        
        test.stopTest();
        
        system.debug(' ##### Test6 After - Limits.getQueries() = ' + Limits.getQueries());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 7: TESTS Validate_ClosedCaseDependencies METHOD ON CASES - ADDED PER NICC-032948
    // ======================================================================================================================================= 
    @isTest static void Test7()     
    {       
        
        system.debug(' ##### Test7 Before - Limits.getQueries() = ' + Limits.getQueries());
        
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        
        Test.startTest();
        
        
        // Invoke the Validate_ClosedCaseDependencies error message
        try
        {
            c.Status = 'Closed';
            update c;
        }
        catch (Exception e)
        {
            Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.AH_Case_Support_Case_Closed_Requirements) ? true : false;
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
        }                       
        
        
        Test.stopTest();
        
        
        system.debug(' ##### Test7 After - Limits.getQueries() = ' + Limits.getQueries());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 8: Test NI_Case_TriggerHandler.closeUserStoryInRally(List<Case> newTrigger, Map<Id, Case> oldMapTrigger) 
    // ======================================================================================================================================= 
    @isTest static void Test8()     
    {   
        
        system.debug(' ##### Test8 Before - Limits.getQueries() = ' + Limits.getQueries());
        
        Account a = [SELECT Id FROM Account WHERE Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];
        Contact cnt = [SELECT Id FROM Contact WHERE FirstName = 'Joe' AND LastName = 'King'];
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
        cs.Res_Product_Retention_Risk__c = '';
        insert cs;    
        
        system.debug(' ##### Test8 #1 - Limits.getQueries() = ' + Limits.getQueries());
        
        CaseSolution cSol = new CaseSolution();
        cSol.CaseId = cs.Id;
        cSol.SolutionId = sol.Id;
        insert cSol;
        
        
        Test.startTest();
        
        
        cs.Res_Product_Retention_Risk__c = 'NEW';        
        cs.Status = 'Closed';
        update cs;
        
        system.debug(' ##### Test8 #2 - Limits.getQueries() = ' + Limits.getQueries());
        
        
        Test.stopTest();                       
        
        
        // TODO: CYBAGE TO CREATE UNIT TESTS HERE
        
        
        system.debug(' ##### Test8 After - Limits.getQueries() = ' + Limits.getQueries());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 9: Test NI_Case_TriggerHandler.writeCaseDetails(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
    //           Tests creating case as Tier 1 L1, changing owner to Tier 2, closing case as Tier 2 
    // ======================================================================================================================================= 
    @isTest static void Test9()  
    {
        
        system.debug(' ##### Test9 Before - Limits.getQueries() = ' + Limits.getQueries());
        
        Account a = [SELECT Id FROM Account WHERE Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];        
        Contact cnt = [SELECT Id FROM Contact WHERE FirstName = 'Joe' AND LastName = 'King']; 
        Asset di = [SELECT Id FROM Asset WHERE SerialNumber = '123456'];      
        User usrSupportL1T1 = [SELECT Id, Name FROM User WHERE Username = 'xxxxxxxx2@xxxxxxx.com'];    
        User usrSupportL2 = [SELECT Id, Name FROM User WHERE Username = 'xxxxxxxx3@xxxxxxx.com']; 
        Id newCaseId;
        
        Test.startTest();
        
        
        // CREATE A CASE AS L1T1 User =========================================
        system.runAs(usrSupportL1T1)
        {          
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
        
        system.debug(' ##### Test9 #1 - Limits.getQueries() = ' + Limits.getQueries());
        
        // ASSERT THAT AH_Case_Report_Detail__c RECORD WAS CREATED 
        List<AH_Case_Report_Detail__c> lstCRDAssert1 = 
            [SELECT Id, Case__c, Detail__c, Event_Type__c, IsOverridden__c, Log_DateTime__c, New_Value__c, Old_Value__c, Time_Elapsed__c, Name 
             FROM AH_Case_Report_Detail__c
             WHERE Case__c =: newCaseId];
        
        system.assertEquals(1, lstCRDAssert1.size());
        // ASSERT THAT CASE TRIGGER HANDLER IS SETTING TOGGLE
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Case_Report_Detail);         
        
        // CHANGE CASE OWNER AS L1T1 User ========================================
        
        // OPEN TOGGLE FOR 1 UPDATE IN TEST THREAD
        NI_TriggerManager.is1stInsert_Case_Report_Detail = true;
        
        system.runAs(usrSupportL1T1)
        {
            Case cs2 = [SELECT Id, OwnerId FROM Case WHERE Id =: newCaseId];
            cs2.OwnerId = usrSupportL2.Id;
            update cs2;
        }
        
        system.debug(' ##### Test9 #2 - Limits.getQueries() = ' + Limits.getQueries());
        
        // ASSERT THAT AH_Case_Report_Detail__c RECORD WAS CREATED 
        List<AH_Case_Report_Detail__c> lstCRDAssert2 = 
            [SELECT Id, Case__c, Detail__c, Event_Type__c, IsOverridden__c, Log_DateTime__c, New_Value__c, Old_Value__c, Time_Elapsed__c, Name 
             FROM AH_Case_Report_Detail__c
             WHERE Case__c =: newCaseId];
        
        system.assertEquals(2, lstCRDAssert2.size());        
        
        // ASSERT THAT CASE TRIGGER HANDLER IS CHANGING FORCED TOGGLE BACK
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Case_Report_Detail); 
        
        system.debug(' ##### Test9 #3 - Limits.getQueries() = ' + Limits.getQueries());
        
        Test.stopTest();
        
        
        // CLOSE CASE AS L2 User ==================================================        
        
        // OPEN TOGGLE FOR 1 UPDATE IN TEST THREAD 
        NI_TriggerManager.is1stInsert_Case_Report_Detail = true;
        
        system.runAs(usrSupportL2)
        {
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
        
        system.debug(' ##### Test9 #4 - Limits.getQueries() = ' + Limits.getQueries());
        
        // ASSERT THAT AH_Case_Report_Detail__c RECORD WAS CREATED 
        List<AH_Case_Report_Detail__c> lstCRDAssert3 = 
            [SELECT Id, Case__c, Detail__c, Event_Type__c, IsOverridden__c, Log_DateTime__c, New_Value__c, Old_Value__c, Time_Elapsed__c, Name 
             FROM AH_Case_Report_Detail__c
             WHERE Case__c =: newCaseId];
        
        system.assertEquals(3, lstCRDAssert3.size());  
        
        system.debug(' ##### Test9 After - Limits.getQueries() = ' + Limits.getQueries());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 10: Test NI_Case_TriggerHandler.writeCaseDetails(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
    //            Tests creating case as NON-SUPPORT, changing owner to Tier 1 L1, closing case as Tier 1 L1, reopen case as L2 
    // ======================================================================================================================================= 
    @isTest static void Test10()  
    {
        
        system.debug(' ##### Test10 Before - Limits.getQueries() = ' + Limits.getQueries());
        
        NI_TriggerBypassSwitches__c bpSwitch = new NI_TriggerBypassSwitches__c();
        bpSwitch.Name = 'Bypass Control Panel';
        bpSwitch.BypassCaseFlags_ON__c = true;
        bpSwitch.BypassCaseReshare_ON__c = true;
        insert bpSwitch;
        
        NI_TriggerBypassSwitches__c bpSwitchAssert = NI_TriggerBypassSwitches__c.getOrgDefaults(); 
        system.assertEquals(true, bpSwitchAssert.BypassCaseFlags_ON__c);
        system.assertEquals(true, bpSwitchAssert.BypassCaseReshare_ON__c);
        
        Account a = [SELECT Id FROM Account WHERE Name = 'NI_Case_TriggerHandlerTest ACCOUNT']; 
        Contact cnt = [SELECT Id FROM Contact WHERE FirstName = 'Joe' AND LastName = 'King']; 
        Asset di = [SELECT Id FROM Asset WHERE SerialNumber = '123456']; 
        User usrNonSupport = [SELECT Id, Name FROM User WHERE Username = 'xxxxxxxx1@xxxxxxx.com']; 
        User usrSupportL1T1 = [SELECT Id, Name FROM User WHERE Username = 'xxxxxxxx2@xxxxxxx.com']; 
        User usrSupportL2 = [SELECT Id, Name FROM User WHERE Username = 'xxxxxxxx3@xxxxxxx.com']; 
        Group q = [SELECT Id FROM Group WHERE DeveloperName = 'Q_L1_Tier_1_Support'];
        Id newCaseId; 
        
        system.debug(' %%%%% Test10 #1 - Limits.getQueries() = ' + Limits.getQueries());
        
        // ============================================================================
        //  TEST #1:  CREATE A CASE AS L1T1 User    
        // ============================================================================
        system.runAs(usrNonSupport)
        {          
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
        
        system.debug(' %%%%% Test10 #2 - Limits.getQueries() = ' + Limits.getQueries());
        
        // ============================================================================
        //  ASSERTS #1:    ASSERT THAT AH_Case_Report_Detail__c RECORD WAS CREATED  
        // ============================================================================
        List<AH_Case_Report_Detail__c> lstCRDAssert1 = 
            [SELECT Id, Case__c, Detail__c, Event_Type__c, IsOverridden__c, Log_DateTime__c, New_Value__c, Old_Value__c, Time_Elapsed__c, Name 
             FROM AH_Case_Report_Detail__c
             WHERE Case__c =: newCaseId];
        
        system.assertEquals(1, lstCRDAssert1.size());
        // ASSERT THAT CASE TRIGGER HANDLER IS SETTING TOGGLE
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Case_Report_Detail);  
        
        system.debug(' %%%%% Test10 #3 - Limits.getQueries() = ' + Limits.getQueries());
        
        // ============================================================================
        //  TEST #2:  CHANGE OWNER TO A QUEUE    
        // ============================================================================      
        // OPEN TOGGLE FOR 1 UPDATE IN TEST THREAD
        NI_TriggerManager.is1stInsert_Case_Report_Detail = true;      
        system.runAs(usrNonSupport)
        {
            Case cs2 = [SELECT Id, OwnerId FROM Case WHERE Id =: newCaseId];           
            cs2.OwnerId = q.Id;
            update cs2;
        }
        
        system.debug(' %%%%% Test10 #4 - Limits.getQueries() = ' + Limits.getQueries());
        
        // ============================================================================
        //  ASSERTS #2:    ASSERT THAT AH_Case_Report_Detail__c RECORDS WERE CREATED  
        // ============================================================================
        List<AH_Case_Report_Detail__c> lstCRDAssert2 = 
            [SELECT Id, Case__c, Detail__c, Event_Type__c, IsOverridden__c, Log_DateTime__c, New_Value__c, Old_Value__c, Time_Elapsed__c, Name 
             FROM AH_Case_Report_Detail__c
             WHERE Case__c =: newCaseId];
        
        system.assertEquals(2, lstCRDAssert2.size());
        // ASSERT THAT CASE TRIGGER HANDLER IS SETTING TOGGLE
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Case_Report_Detail);         
        
        system.debug(' %%%%% Test10 #5 - Limits.getQueries() = ' + Limits.getQueries());
        
        
        Test.startTest();
        
        
        system.debug(' %%%%% Test10 #6 - Limits.getQueries() = ' + Limits.getQueries());
        
        // ============================================================================
        //  TEST #3:  CHANGE CASE OWNER (Taking ownership) AS L1T1 User  
        // ============================================================================         
        // OPEN TOGGLE FOR 1 UPDATE IN TEST THREAD
        NI_TriggerManager.is1stInsert_Case_Report_Detail = true;
        system.runAs(usrSupportL1T1)
        {
            Case cs3 = [SELECT Id, OwnerId FROM Case WHERE Id =: newCaseId];
            cs3.OwnerId = usrSupportL1T1.Id;
            update cs3;
        }
        
        system.debug(' %%%%% Test10 #7 - Limits.getQueries() = ' + Limits.getQueries());
        
        // ============================================================================
        //  ASSERTS #3:    ASSERT THAT AH_Case_Report_Detail__c RECORDS WERE CREATED  
        // ============================================================================
        List<AH_Case_Report_Detail__c> lstCRDAssert3 = 
            [SELECT Id, Case__c, Detail__c, Event_Type__c, IsOverridden__c, Log_DateTime__c, New_Value__c, Old_Value__c, Time_Elapsed__c, Name 
             FROM AH_Case_Report_Detail__c
             WHERE Case__c =: newCaseId];
        
        system.assertEquals(3, lstCRDAssert3.size());    
        // ASSERT THAT CASE TRIGGER HANDLER IS CHANGING FORCED TOGGLE BACK
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Case_Report_Detail);         
        
        system.debug(' %%%%% Test10 #8 - Limits.getQueries() = ' + Limits.getQueries());
        
        // ============================================================================
        //  TEST #4:  CLOSE CASE AS L1 User  
        // ============================================================================          
        // OPEN TOGGLE FOR 1 UPDATE IN TEST THREAD 
        NI_TriggerManager.is1stInsert_Case_Report_Detail = true;      
        system.runAs(usrSupportL1T1)
        { 
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
        
        system.debug(' %%%%% Test10 #9 - Limits.getQueries() = ' + Limits.getQueries());
        
        // ============================================================================
        //  ASSERTS #4:    ASSERT THAT AH_Case_Report_Detail__c RECORDS WERE CREATED  
        // ============================================================================ 
        List<AH_Case_Report_Detail__c> lstCRDAssert4 = 
            [SELECT Id, Case__c, Detail__c, Event_Type__c, IsOverridden__c, Log_DateTime__c, New_Value__c, Old_Value__c, Time_Elapsed__c, Name 
             FROM AH_Case_Report_Detail__c
             WHERE Case__c =: newCaseId];
        
        // ASSERT THAT CASE TRIGGER HANDLER IS CHANGING FORCED TOGGLE BACK
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Case_Report_Detail);       
        
        // ============================================================================
        //  TEST #5:  REOPEN CASE AS L2 User  
        // ============================================================================         
        // OPEN TOGGLE FOR 1 UPDATE IN TEST THREAD 
        NI_TriggerManager.is1stInsert_Case_Report_Detail = true;           
        system.runAs(usrSupportL2)
        {
            Case cs5 = [SELECT Id, OwnerId FROM Case WHERE Id =: newCaseId];           
            cs5.Status = 'Working';
            cs5.OwnerId = usrSupportL2.Id;
            cs5.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
            update cs5;
        }
        
        system.debug(' %%%%% Test10 #10 - Limits.getQueries() = ' + Limits.getQueries());
        
        Test.stopTest();
        
        // ============================================================================
        //  ASSERTS #5:    ASSERT THAT AH_Case_Report_Detail__c RECORDS WERE CREATED  
        // ============================================================================ 
        List<AH_Case_Report_Detail__c> lstCRDAssert5 = 
            [SELECT Id, Case__c, Detail__c, Event_Type__c, IsOverridden__c, Log_DateTime__c, New_Value__c, Old_Value__c, Time_Elapsed__c, Name 
             FROM AH_Case_Report_Detail__c 
             WHERE Case__c =: newCaseId];        
        
        system.assertEquals(5, lstCRDAssert5.size());        
        // ASSERT THAT CASE TRIGGER HANDLER IS CHANGING FORCED TOGGLE BACK
        system.assertEquals(false, NI_TriggerManager.is1stInsert_Case_Report_Detail); 
        
        system.debug(' %%%%% Test10 After - Limits.getQueries() = ' + Limits.getQueries());
        
    }    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 11: Test Changing Owner of a Case
    // ======================================================================================================================================= 
    @isTest static void Test11() 
    {
        
        system.debug(' ##### Test11 Before - Limits.getQueries() = ' + Limits.getQueries());
        
        User u = [SELECT Id FROM User WHERE Username = 'xxxxxxxx3@xxxxxxx.com']; 
        User e = [SELECT Id FROM User WHERE Username = 'joe.king.@amadeushospitality.com.ahcc'];
        Case c = [SELECT Id, OwnerId FROM Case WHERE Subject = 'NI_Case_TriggerHandlerTest PARENT CASE'];
        
        // SHARE CASE TO CUSTOMER CENTRAL USER
        Case_Share__c cs = new Case_Share__c(); 
        cs.CaseAccessLevel__c = 'Read'; 
        cs.CaseId__c = c.Id; 
        cs.RowCause__c = 'Manual';
        cs.UserOrGroupId__c = e.Id;
        insert cs;        
        
        system.debug(' ##### Test11 #2 - Limits.getQueries() = ' + Limits.getQueries());        
        
        test.startTest();
        
        system.debug(' ##### Test11 - test.startTest()'); 
        
        c.OwnerId = u.Id;
        update c;
        
        system.debug(' ##### Test11 #2 - Limits.getQueries() = ' + Limits.getQueries());
        system.debug(' ##### Test11 - test.stopTest()'); 
        
        test.stopTest();        
        
        system.debug(' ##### Test1 After - Limits.getQueries() = ' + Limits.getQueries());
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 12: Test ACSP 
    // ======================================================================================================================================= 
    @isTest static void Test12() 
    {    
        
        Test.StartTest();
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'CRS CUSTOMER ACCOUNT';
        insert a;

        Case cs = NI_TestClassData.createTestCase(1013, a.Id);
        //cs.ContactId = cnt.Id;
        cs.Subject = 'MGM - NI_Case_TriggerHandlerTest CASE';
        cs.Description = 'NI_Case_TriggerHandlerTest CASE DESCRIPTION'; 
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId(); 
        insert cs;  
        
        Test.StopTest();
                
        List<Case> lstAssert = [SELECT AccountId FROM Case WHERE Subject = 'MGM - NI_Case_TriggerHandlerTest CASE'];
        system.debug(' *%*%* lstAssert[0].AccountId = ' + lstAssert[0].AccountId);
        
        
        WINAPROACH_ONLY_Membership_Customer__mdt mdt = [SELECT WinaproachAccountIdentifier__c, AH_Salesforce_Account_Id__c  
                                                        FROM WINAPROACH_ONLY_Membership_Customer__mdt
                                                        WHERE WinaproachAccountIdentifier__c = 'MGM' 
                                                        LIMIT 1];     
        
        system.debug(' *%*%* lstAssert[0].AccountId = ' + lstAssert[0].AccountId);
        system.assertEquals(mdt.AH_Salesforce_Account_Id__c, lstAssert[0].AccountId);
        
    } 
  
}