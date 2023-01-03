/****************************************************************************************
Name            : NI_Partner_Case_ListViewTest Class
Author          : Stuart Emery
Created Date    : 10/28/2015
Last Mod Date   : 08/12/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test Class for the NI_Partner_Case_ListView Controller
: 
: 
******************************************************************************************/
@isTest (SeeAllData=false)
private class NI_Partner_Case_ListViewTest 
{
    
    public static final String CASE_RECORDTYPE_NAME = 'Partner Community Case';
    
    static testMethod void test_NIN_CaseListView() 
    {    
        
        Id profileIDTest = [SELECT Id FROM Profile WHERE Name = 'AH Customer Community Plus Login User'].Id;
        
        system.assertNotEquals(null, profileIDTest);
        
        //VARIABLE TO HOLD THE CURRENT DATE  
        Date dt = Date.TODAY();
        
        Account a;
        Contact cnt;
        pse__Triggers__c pt;
        
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            // CREATE A TEST ACCOUNT  
            a = NI_TestClassData.createTestAccount(1);
            insert a;
            
            //CREATE A TEST CONTACT  
            cnt = NI_TestClassData.createTestContact(1, a.Id);
            insert cnt;
            
            //ADDED PER FINANCIALFORCE SUPPORT TO PREVENT WEB SERVICES CALL OUT MESSAGE WHEN RUNNING TEST CLASSES THAT INVOLVE THE CONTACT OBJECT  
            pt = new pse__Triggers__c(); 
            pt.pse__Resource_Geolocation_Trigger_Disabled__c = true; 
            insert pt; 
        }
        
        //PAGE REFERENCE
        PageReference pageRef = Page.PartnerCaseCustomListView;
        Test.setCurrentPage(pageRef);
        
        Account aChild;
        System.runAs(new User(Id = UserInfo.getUserId()))
        {   
            // CREATE A TEST CHILD ACCOUNT  
            aChild = NI_TestClassData.createTestAccount(2);
            aChild.ParentId = a.Id;
            insert aChild;
        } 
        
       
        //CREATE TEST CUSTOMER PORTAL USER         
        User cu = NI_TestClassData.createTestUser(2, 'AH Customer Community Plus Login User');
        cu.Username = 'j.smith@someemail.com.ahcc';
        cu.ContactId = cnt.Id;
        insert cu;
		
        // VERIFY THAT A CUSTOMER PORTAL USER WAS CREATED
        List<User> lstTestUser = new List<User>([SELECT Id FROM User WHERE ProfileId =: profileIDTest AND ContactId =: cnt.Id AND AccountId =: a.Id]);
        system.AssertEquals(1, lstTestUser.Size());
        
        /********
        // CREATE TEST STANDARD USER  
        User su = NI_TestClassData.createTestUser(3, 'System Administrator');
        insert su;
        
        system.debug('su user : '+su.id);
        
		**********/
        Id rtInit;
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            // GET RECORDTYPEID FOR 'CASE' RECORDTYPE  
            rtInit = NI_TestClassData.getRecordTypeId('Case', CASE_RECORDTYPE_NAME);  
            
            //INSERT A TEST RECORD INTO THE NI_Partner_Case_Record_Types__c CUSTOM SETTING. THE CUSTOM SETTING NEEDS TO EXIST  
            //        List<NI_Partner_Case_Record_Types__c> lstCsToInsert = new List<NI_Partner_Case_Record_Types__c>();         
            NI_Partner_Case_Record_Types__c csFields = new NI_Partner_Case_Record_Types__c();
            csFields.Name = CASE_RECORDTYPE_NAME;
            // csFields.DeveloperName__c = CASE_RECORDTYPE_NAME;        
            //        lstCsToInsert.add(csFields);        
            insert csFields;
            
            //INSERT A TEST RECORD INTO THE NI_Partner_Case_Origins__c CUSTOM SETTING. THE CUSTOM SETTING NEEDS TO EXIST  
            //        List<NI_Partner_Case_Origins__c> lstCsToInsert2 = new List<NI_Partner_Case_Origins__c>();  
            NI_Partner_Case_Origins__c csFields2 = new NI_Partner_Case_Origins__c();
            csFields2.Name = 'Phone';
            // csFields2.CaseOrigin__c = 'Phone';        
            //       lstCsToInsert2.add(csFields2);        
            insert csFields2;
            
            //INSERT A TEST RECORD INTO THE NI_Partner_Case_Types__c CUSTOM SETTING. THE CUSTOM SETTING NEEDS TO EXIST  
            //        List<NI_Partner_Case_Types__c> lstCsToInsert3 = new List<NI_Partner_Case_Types__c>();  
            NI_Partner_Case_Types__c csFields3 = new NI_Partner_Case_Types__c();
            csFields3.Name = 'Inquiry';
            //  csFields3.CaseType__c = 'Inquiry';        
            //        lstCsToInsert3.add(csFields3);        
            insert csFields3;
        }
        
        //RUN AS CUSTOMER PORTAL USER  
        System.runAs(cu) 
        {            
            
            system.assertEquals(cu.Id, UserInfo.getUserId());
            
            //CONTROLLER 
            NI_Partner_Case_ListView ctrl = new NI_Partner_Case_ListView();
            ctrl.usrContactId = cnt.Id;
            ctrl.callMethods2();
            
            //TEST THE MY CLOSED CASES VIEW  
            ctrl.selectedValue = 'My Closed Cases';
            ctrl.startDate = '01/01/' + String.valueOf(dt.year());
            ctrl.endDate = '12/31/' + String.valueOf(dt.year());
            ctrl.callMethods2();
            
            //TEST THE MY OPEN CASES VIEW  
            ctrl.selectedValue = 'My Open Cases';
            ctrl.startDate = '01/01/' + String.valueOf(dt.year());
            ctrl.endDate = '12/31/' + String.valueOf(dt.year());
            ctrl.callMethods2();  
            
            //TEST THE ALL OF MY CASES VIEW  
            ctrl.selectedValue = 'All My Cases';
            ctrl.startDate = '01/01/' + String.valueOf(dt.year());
            ctrl.endDate = '12/31/' + String.valueOf(dt.year());
            ctrl.callMethods2();
            
            //TEST THE MY PROPERTY'S CLOSED CASES VIEW  
            ctrl.selectedValue = 'My Property\'s Closed Cases';
            ctrl.startDate = '01/01/' + String.valueOf(dt.year());
            ctrl.endDate = '12/31/' + String.valueOf(dt.year()); 
            ctrl.callMethods2();
            
            //TEST THE MY PROPERTY'S OPEN CASES VIEW  
            ctrl.selectedValue = 'My Property\'s Open Cases';
            ctrl.startDate = '01/01/' + String.valueOf(dt.year());
            ctrl.endDate = '12/31/' + String.valueOf(dt.year()); 
            ctrl.callMethods2();
            
            //TEST THE ALL OF MY PROPERTY'S CASES VIEW  
            ctrl.selectedValue = 'All My Property\'s Cases';
            ctrl.startDate = '01/01/' + String.valueOf(dt.year());
            ctrl.endDate = '12/31/' + String.valueOf(dt.year()); 
            ctrl.callMethods2();

            ctrl.selectedValue = 'All Properties\' Open Cases';
            ctrl.startDate = '01/01/' + String.valueOf(dt.year());
            ctrl.endDate = '12/31/' + String.valueOf(dt.year()); 
            ctrl.callMethods2();            
 
            ctrl.selectedValue = 'All Properties\' Closed Cases';
            ctrl.startDate = '01/01/' + String.valueOf(dt.year());
            ctrl.endDate = '12/31/' + String.valueOf(dt.year()); 
            ctrl.callMethods2();            
            
            ctrl.selectedValue = 'All Properties\' Cases';
            ctrl.startDate = '01/01/' + String.valueOf(dt.year());
            ctrl.endDate = '12/31/' + String.valueOf(dt.year()); 
            ctrl.callMethods2();

            
            //TEST SELECTEDVALUE IS NULL  
            ctrl.selectedValue = null;
            ctrl.startDate = null;
            ctrl.endDate = null;
            ctrl.callMethods2();       
            
            //CREATE A TEST CASE
            Case c = NI_TestClassData.createTestCase(1, a.Id);
            c.RecordTypeId = rtInit;
            c.ContactId = cnt.Id;
            insert c;
            
            //TEST BEGINING PAGE REFERENCE METHOD 
            ctrl.Beginning();
            
            //TEST PREVIOUS PAGE REFERENCE METHOD 
            ctrl.Previous();
            
            //TEST NEXT PAGE REFERENCE METHOD 
            ctrl.Next();
            
            //TEST END PAGE REFERENCE METHOD 
            ctrl.End();
            
            //TEST EXPORT TO EXCEL METHOD 
            ctrl.startDate = null;
            ctrl.endDate = null; 
      //      ctrl.export();
            
            //TEST CREATE NEW CASE METHOD 
            ctrl.NewCase();
            
            //TEST ACCESSING THE VIEW PICK LIST 
            ctrl.getViews();
            
            //TEST DISABLEPREVIOUS BOOLEAN  
            ctrl.getDisablePrevious();
            
            //TEST DISABLENEXT BOOLEAN  
            ctrl.getDisableNext();
            
            //TEST TOTAL_SIZE  
            ctrl.getTotal_size();
            
            //TEST PAGENUMBER  
            ctrl.getPageNumber();
            
            //TEST TOTALPAGES  
            ctrl.getTotalPages();
            
            ctrl.getRecVals();
            
            // TEST COLUMN SORTING FUNCTIONS 
            ctrl.setSortDirection('');
            string sSortDir = ctrl.getSortDirection();
            ctrl.sortExpression = 'Subject';
            ctrl.sortData();
            ctrl.sortExpression = 'Subject';
            ctrl.sortData();
            sSortDir = ctrl.getSortDirection();
            
            //TEST DISABLE EXPORT  
            ctrl.getDisableExport();
            
            //TEST GET CASES EXCEL EXPORT
            ctrl.selectedValue = null;
            ctrl.startDate = null;
            ctrl.endDate = null;
            ctrl.getCasesExcelExport();                                     
            
        } 
        
        /***********
        //RUN AS STANDARD USER  
        System.runAs(su) 
        {            
            //CONTROLLER 
            NI_Partner_Case_ListView ctrlStd = new NI_Partner_Case_ListView();
            ctrlStd.usrContactId = cu.Id;
            ctrlStd.callMethods2();            
            ctrlStd.internalUserMethod();
        }
        *******/
        //VALIDATE THE CASE WAS INSERTED
        //  for(Case caseInserted:[SELECT Id, ContactId FROM Case  
        //      WHERE Id =: c.Id])
        
        //  System.assertEquals(caseInserted.ContactId, cnt.Id);
        
    }
    
}