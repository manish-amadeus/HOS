/****************************************************************************************
Name            : NeighborhoodCaseCustomListView_Test Class
Author          : Sean Harris
Created Date    : 12/14/2016
Last Mod Date   : 07/21/2017
Last Mod By     : Stuart Emery PER NICC-023213
NICC Reference  : 
Description     : Test Class for the NeighborhoodCaseCustomListView Controller
                : 
                : 
******************************************************************************************/
@isTest 
private class NeighborhoodCaseCustomListView_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {

        // INSERT CUSTOM TEST SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();        
        
        // INSERT A TEST RECORD INTO THE NI_Neighborhood_Case_Record_Types__c CUSTOM SETTING. THE CUSTOM SETTING NEEDS TO EXIST          
        NI_Neighborhood_Case_Record_Types__c cs1a = new NI_Neighborhood_Case_Record_Types__c();
        cs1a.Name = 'Case';
        cs1a.DeveloperName__c = 'Case';        
        insert cs1a;
        
        NI_Neighborhood_Case_Record_Types__c cs1b = new NI_Neighborhood_Case_Record_Types__c();
        cs1b.Name = 'Close Case';
        cs1b.DeveloperName__c = 'Close Case';        
        insert cs1b;
        
        // INSERT A TEST RECORD INTO THE NI_Neighborhood_Case_Origins__c CUSTOM SETTING. THE CUSTOM SETTING NEEDS TO EXIST  
        NI_Neighborhood_Case_Origins__c cs2 = new NI_Neighborhood_Case_Origins__c();
        cs2.Name = 'Phone';
        cs2.CaseOrigin__c = 'Phone';             
        insert cs2;
        
        // INSERT A TEST RECORD INTO THE NI_Neighborhood_Case_Types__c CUSTOM SETTING. THE CUSTOM SETTING NEEDS TO EXIST  
        NI_Neighborhood_Case_Types__c cs3 = new NI_Neighborhood_Case_Types__c();
        cs3.Name = 'Inquiry';
        cs3.CaseType__c = 'Inquiry';    
        insert cs3;           
        
        // ADDED PER FINANCIALFORCE SUPPORT TO PREVENT WEB SERVICES CALL OUT MESSAGE WHEN RUNNING TEST CLASSES THAT INVOLVE THE CONTACT OBJECT  
        //pse__Triggers__c pt = new pse__Triggers__c(); 
        //pt.pse__Resource_Geolocation_Trigger_Disabled__c = true; 
        //insert pt;         
        
        Test.startTest();
                
        // CREATE TEST ACCOUNTS  
        List<Account> lstAccountInsert = new List<Account>();
        
        Account a1 = NI_TestClassData.createTestAccount(1);
        a1.Name = 'Parent Account Test - Related';
        lstAccountInsert.Add(a1);
        
        Account a2 = NI_TestClassData.createTestAccount(2);
        a2.ParentId = a1.Id;
        a2.Name = 'Child Account Test - Related';
        lstAccountInsert.Add(a2);
        
        Account a3 = NI_TestClassData.createTestAccount(3);
        a3.ParentId = a2.Id;
        a3.Name = 'Grandchild Account Test - Related';
        lstAccountInsert.Add(a3);
        
        Account a4 = NI_TestClassData.createTestAccount(4);
        a4.ParentId = a3.Id;
        a4.Name = 'Parent Account Test - Unrelated';
        lstAccountInsert.Add(a4);
        
        Account a5 = NI_TestClassData.createTestAccount(5);
        a5.ParentId = a4.Id;
        a5.Name = 'Child Account Test - Unrelated';
        lstAccountInsert.Add(a5);
        
        Database.insert(lstAccountInsert);

        // CREATE TEST CONTACT RECORDS
        List<Contact> lstContacts = new List<Contact>();
        
        Contact cnt1 = NI_TestClassData.createTestContact(1, a4.Id);
        cnt1.FirstName = 'Jen';
        cnt1.LastName = 'Nettles';
        cnt1.Email = 'APEXTEST2@amadeushospitality.com';
        lstContacts.add(cnt1);
        
        // CREATE A TEST CONTACT TO BE CREATED AS A COMMUNITY USER 
        Contact cnt2 = NI_TestClassData.createTestContact(1, a1.Id);
        cnt2.FirstName = 'Mike';
        cnt2.LastName = 'Oxmaul';
        cnt2.Email = 'APEXTEST1@amadeushospitality.com';
        lstContacts.add(cnt2);
        
        database.insert(lstContacts);

        // CREATE TEST CUSTOMER COMMUNITY USER 
        User u = NI_TestClassData.createTestUser(1, 'AH Customer Community Plus Login User'); 
        u.ContactId = cnt2.Id;
        u.FirstName = 'Mike';
        u.LastName = 'Oxmaul';
        u.Alias = 'APEXTEST';
        u.Email = 'APEXTEST1@amadeushospitality.com';
        u.Username = 'APEXTEST1@amadeushospitality.com.ahcc';
        u.CommunityNickname = 'CXLTEST1'; 
        u.Cancellation_User__c = 'True';
        insert u;

        // CREATE TEST CASES 
        List<Case> lstCaseInserts = new List<Case>();         
        
        // CREATE 5 VISIBLE OPEN CASES
        for (integer i = 1; i <= 5; i++)
        {
            Case cs = NI_TestClassData.createTestCase(i, a1.Id);
            cs.ContactId = cnt2.Id;
            cs.Origin = 'Phone';
            cs.Type = 'Inquiry';
            cs.Status = 'Working';
            cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
            lstCaseInserts.add(cs);
        }

        // CREATE 5 VISIBLE CLOSED CASES
        for (integer i = 1; i <= 5; i++)
        {
            Case cs = NI_TestClassData.createTestCase(i, a1.Id);
            cs.ContactId = cnt2.Id;
            cs.Origin = 'Phone';
            cs.Type = 'Inquiry';
            cs.Status = 'Closed';
            cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Close Case').getRecordTypeId();
            lstCaseInserts.add(cs);
        }
        
        // CREATE 2 FORBIDDEN OPEN CASES (ACCOUNT NOT IN HEIRARCHY)
        for (integer i = 1; i <= 2; i++)
        {
            Case cs = NI_TestClassData.createTestCase(i, a4.Id);
            cs.ContactId = cnt1.Id;
            cs.Origin = 'Phone';
            cs.Type = 'Inquiry';
            cs.Status = 'Working';
            cs.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
            lstCaseInserts.add(cs);
        }
        
        // CREATE 2 FORBIDDEN CLOSED CASES (ACCOUNT NOT IN HEIRARCHY)
        for (integer i = 1; i <= 2; i++)
        {
            Case cs = NI_TestClassData.createTestCase(i, a4.Id);
            cs.ContactId = cnt1.Id;
            cs.Origin = 'Phone';
            cs.Type = 'Inquiry';
            cs.Status = 'Closed';
            cs.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Close Case').getRecordTypeId();
            lstCaseInserts.add(cs);
        }        
        
        database.insert(lstCaseInserts);
        
        
        // CREATE CASE SHARES (NORMALLY HANDLED BY SQL PROC IN DB AMP) =============================================================
        List<CaseShare> lstCaseShareInserts = new List<CaseShare>(); 
        
        for (Case csLst : lstCaseInserts)
        {
            if (csLst.AccountId == a1.Id)
            {
                CaseShare csh1 = new CaseShare(CaseAccessLevel = 'Edit', CaseId = csLst.Id, RowCause = 'Manual', UserOrGroupId = u.Id);
                lstCaseShareInserts.Add(csh1);                
            }
        }
        
        database.insert(lstCaseShareInserts);        
        
        
        Test.stopTest();
  
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 1: TEST AS COMMUNITY USER
    // ======================================================================================================================================= 
    @isTest static void test1() 
    { 
        
        Contact cnt = [SELECT Id, AccountId FROM Contact WHERE Email = 'APEXTEST1@amadeushospitality.com'];
        User u = [SELECT Id FROM User WHERE ContactId =: cnt.Id];

        List<Case> lstCaseAsserts = new List<Case>([SELECT Id FROM Case]);
        system.debug(' *^* Total Test Case Records = ' + lstCaseAsserts.size());
        system.assertEquals(14, lstCaseAsserts.size());
        
        Test.startTest();  
        
        Date dt = Date.Today();
        Datetime dtTestStartDate = DateTime.newInstance(dt.Year(), 1, 1, 0, 0, 0);
        Datetime dtTestEndDate = DateTime.newInstance(dt.Year(), 12, 31, 0, 0, 0);        
        
        system.runAs(u)
        {
            
            // PAGE REFERENCE 
            PageReference pr = Page.NeighborhoodCaseCustomListView; 
            
            // SET TEST PAGE
            Test.setCurrentPage(pr); 

            // CREATE INSTANCE OF CONTROLLER 
            NeighborhoodCaseCustomListView ctrl = new NeighborhoodCaseCustomListView();
            ctrl.usrContactId = cnt.Id;
            
            ctrl.getViews();
            ctrl.getRecVals();
            ctrl.initCaseSearch();
            
            // TEST ALL THE DIFFERENT VIEWS  
            ctrl.selectedValue = 'My Open Cases';
            ctrl.startDate = dtTestStartDate;
            ctrl.endDate = dtTestEndDate;
            ctrl.initCaseSearch();  
            
            system.debug(' *^* ctrl.mapCaseIds.size() = ' + ctrl.mapCaseIds.size());
            system.assertEquals(5, ctrl.mapCaseIds.Size());
            
            ctrl.selectedValue = 'My Closed Cases'; 
            ctrl.startDate = dtTestStartDate;
            ctrl.endDate = dtTestEndDate;
            ctrl.initCaseSearch();
            
            system.debug(' *^* My Closed Cases - ctrl.mapCaseIds.size() = ' + ctrl.mapCaseIds.size());
            system.assertEquals(5, ctrl.mapCaseIds.Size());
            
            ctrl.selectedValue = 'All My Cases';
            ctrl.startDate = dtTestStartDate;
            ctrl.endDate = dtTestEndDate;
            ctrl.initCaseSearch();
            
            system.debug(' *^* All My Cases - ctrl.mapCaseIds.size() = ' + ctrl.mapCaseIds.size());
            system.assertEquals(10, ctrl.mapCaseIds.Size());
            
            ctrl.selectedValue = 'My Property\'s Open Cases';
            ctrl.startDate = dtTestStartDate;
            ctrl.endDate = dtTestEndDate;
            ctrl.initCaseSearch();
            
            system.debug(' *^* My Propertys Open Cases - ctrl.mapCaseIds.size() = ' + ctrl.mapCaseIds.size());
            system.assertEquals(5, ctrl.mapCaseIds.Size());
            
            ctrl.selectedValue = 'My Property\'s Closed Cases';            
            ctrl.startDate = dtTestStartDate;
            ctrl.endDate = dtTestEndDate;
            ctrl.initCaseSearch();
            
            system.debug(' *^* My Propertys Closed Cases - ctrl.mapCaseIds.size() = ' + ctrl.mapCaseIds.size());
            system.assertEquals(5, ctrl.mapCaseIds.Size());
            
            ctrl.selectedValue = 'All My Property\'s Cases';
            ctrl.startDate = dtTestStartDate;
            ctrl.endDate = dtTestEndDate;
            ctrl.initCaseSearch();
            
            system.debug(' *^* All My Propertys Cases - ctrl.mapCaseIds.size() = ' + ctrl.mapCaseIds.size());
            system.assertEquals(10, ctrl.mapCaseIds.Size());
            
            ctrl.selectedValue = 'All Properties\' Open Cases';
            ctrl.startDate = dtTestStartDate;
            ctrl.endDate = dtTestEndDate;
            ctrl.initCaseSearch();            
            
            system.debug(' *^* All Properties Open Cases - ctrl.mapCaseIds.size() = ' + ctrl.mapCaseIds.size());
            system.assertEquals(5, ctrl.mapCaseIds.Size());
            
            ctrl.selectedValue = 'All Properties\' Closed Cases';
            ctrl.startDate = dtTestStartDate;
            ctrl.endDate = dtTestEndDate;
            ctrl.initCaseSearch();            
            
            system.debug(' *^* All Properties Closed Cases - ctrl.mapCaseIds.size() = ' + ctrl.mapCaseIds.size());
            system.assertEquals(5, ctrl.mapCaseIds.Size());
            
            ctrl.selectedValue = 'All Properties\' Cases';
            ctrl.startDate = dtTestStartDate;
            ctrl.endDate = dtTestEndDate;
            ctrl.initCaseSearch();
            
            system.debug(' *^* All Properties Cases - ctrl.mapCaseIds.size() = ' + ctrl.mapCaseIds.size());
            system.assertEquals(10, ctrl.mapCaseIds.Size());
            
            List<Case> lstCaseTest = new List<Case>();
            lstCaseTest = ctrl.getCases();            
            
            // TEST SELECTEDVALUE IS NULL  
            ctrl.selectedValue = null;
            ctrl.startDate = null;
            ctrl.endDate = null;
            ctrl.initCaseSearch();       
            
            // TEST NAVIGATION FUNCTIONS
            ctrl.Beginning();
            ctrl.Previous();
            ctrl.Previous();
            ctrl.Next();
            ctrl.End();
            ctrl.End();
            
            boolean btemp1 = ctrl.getDisablePrevious();
            boolean btemp2 = ctrl.getDisableNext();
            string sTemp1 = ctrl.getPageOfPages();
            
            // TEST CREATE NEW CASE METHOD 
            ctrl.NewCase();
            
            // TEST COLUMN SORTING FUNCTIONS 
            ctrl.setSortDirection('');
            string sSortDir = ctrl.getSortDirection();
            ctrl.sortExpression = 'Subject';
            ctrl.sortData();
            ctrl.sortExpression = 'Subject';
            ctrl.sortData();
            sSortDir = ctrl.getSortDirection();
            
            // TEST DISABLE EXPORT  
            ctrl.getDisableExport();
            
            //TEST EXPORT TO EXCEL METHOD 
            ctrl.startDate = null;
            ctrl.endDate = null; 
            ctrl.export();
            
            // TEST GET CASES EXCEL EXPORT
            ctrl.selectedValue = null;
            ctrl.startDate = null;
            ctrl.endDate = null;
            ctrl.getCasesExcelExport(); 
            
            // TEST SEARCH MODE
            ctrl.searchByMode = 'Case Number';
            ctrl.changeMode();
            
        }        

        Test.stopTest(); 
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 1: TEST AS INTERNAL USER
    // ======================================================================================================================================= 
    @isTest static void test2() 
    { 
        
        Contact cnt = [SELECT Id, AccountId FROM Contact WHERE Email = 'APEXTEST1@amadeushospitality.com'];
        Case c = [SELECT Id, CaseNumber FROM Case WHERE AccountId =: cnt.AccountId LIMIT 1];   
        
        // PAGE REFERENCE 
        PageReference pr = Page.NeighborhoodCaseCustomListView; 
        
        // SET TEST PAGE
        Test.setCurrentPage(pr); 
        
        // CREATE INSTANCE OF CONTROLLER 
        NeighborhoodCaseCustomListView ctrl = new NeighborhoodCaseCustomListView(); 
        
        // TEST SEARCHING BY A CASE NUMBER
        ctrl.searchByMode = 'Case Number';
        ctrl.changeMode();        
        ctrl.caseNumber = c.CaseNumber;
        ctrl.initCaseSearch();
        
        system.debug(' *^* Internal User Case Number Serach - ctrl.mapCaseIds.size() = ' + ctrl.mapCaseIds.size());
        system.assertEquals(1, ctrl.mapCaseIds.Size());        
        
    }
    
}