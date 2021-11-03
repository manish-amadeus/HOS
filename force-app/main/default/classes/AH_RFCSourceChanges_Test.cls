/************************************************************************************************************************
Name            : AH_RFCSourceChanges_Test Test Class
Author          : Sean Harris
Created Date    : 06/04/2018
Last Mod Date   : 06/04/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description		: Test for AH_RFCSourceChanges Controller Class
     			: 
*************************************************************************************************************************/
@isTest
public class AH_RFCSourceChanges_Test 
{
    
    // =============================================================================================================
    //  TEST DATA CREATION 
    // =============================================================================================================
    static testMethod void testAH_RFCSourceChanges1() 
    {

        Test.startTest();
        
        // CREATE A TEST ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;         
        List<Account> lstAccountAsserts = new List<Account>([SELECT Id FROM Account]);
        system.assertEquals(1, lstAccountAsserts.Size(), 'Failed to create test Account record in AH_RFCSourceChanges_Test.testAH_RFCSourceChanges1()');         

        // CREATE NICC RECORD
		Id rtId = NI_TestClassData.getRecordTypeId('NI_Change_Control__c', 'Salesforce.com Change Request'); 
        
        NI_Change_Control__c nicc = NI_TestClassData.createNIChangeControl(1, 'APEX TEST'); 
        nicc.RecordTypeId = rtId; 
        nicc.Environment_s_Affected__c = 'Sandbox - SBFULL'; 
        insert nicc; 
                
        // CREATE TEST SALESFORCE SOURCE CONTROL RECORDS 
        List<AH_SFDC_Source_Control__c> lstSSCInserts = new List<AH_SFDC_Source_Control__c>();
        
        // APEX CLASS 
        AH_SFDC_Source_Control__c s1 = new AH_SFDC_Source_Control__c();
        s1.API_Name__c = 'NI_TestClassData';
        s1.Salesforce_Source_Type__c = 'Apex Class';
        s1.CRC__c = 997391997;
        s1.Description__c = 'test class';
        s1.Label__c = 'NI_TestClassData';
        s1.Salesforce_ID__c = '01p600000000iZh';
        s1.Syntax__c = 'if then else...';
        s1.Source_Last_Modified__c = system.now();
        s1.Source_Last_Modified_By__c = UserInfo.getUserId();
        lstSSCInserts.add(s1);

        // APEX CLASS 
        AH_SFDC_Source_Control__c s4 = new AH_SFDC_Source_Control__c();
        s4.API_Name__c = 'NI_TestClassData_Test';
        s4.Salesforce_Source_Type__c = 'Apex Class';
        s4.CRC__c = 997391997;
        s4.Description__c = 'test class';
        s4.Label__c = 'NI_TestClassData_Test';
        s4.Salesforce_ID__c = '01p600000000iZi';
        s4.Syntax__c = 'if then else...';
        s4.Source_Last_Modified__c = system.now();
        s4.Source_Last_Modified_By__c = UserInfo.getUserId();
        lstSSCInserts.add(s4); 
        
        // APEX TRIGGER  
        AH_SFDC_Source_Control__c s2 = new AH_SFDC_Source_Control__c();
        s2.API_Name__c = 'NI_OpportunityLineItem_BeforeInsertUpdate';
        s2.Salesforce_Source_Type__c = 'Apex Trigger';
        s2.CRC__c = 1626939573;
        s2.Description__c = 'test trigger';
        s2.Label__c = 'NI_OpportunityLineItem_BeforeInsertUpdate';
        s2.Salesforce_ID__c = '01q320000004VKgAAM';
        s2.Syntax__c = 'if then else...';
        s2.Source_Last_Modified__c = system.now();
        s2.Source_Last_Modified_By__c = UserInfo.getUserId(); 
        lstSSCInserts.add(s2);

        // PROCESS BUILDER 
        AH_SFDC_Source_Control__c s3 = new AH_SFDC_Source_Control__c();
        s3.API_Name__c = 'NI_Case_Auto_Email_for_Amadeus_PMS_v3';
        s3.Salesforce_Source_Type__c = 'Process Builder';
        // s3.CRC__c = 0;
        s3.Description__c = 'test process builder';
        s3.Label__c = 'Case Auto Email for Amadeus PMS v3';
        s3.Salesforce_ID__c = '01p32000000VSoeAAG';
        // s3.Syntax__c = '';
        s3.Source_Last_Modified__c = system.now();
        s3.Source_Last_Modified_By__c = UserInfo.getUserId();        
		lstSSCInserts.add(s3);

        database.insert(lstSSCInserts);

        // ASSERT THAT SSC RECORDS WERE CREATED
        List<AH_SFDC_Source_Control__c> lstSSCAssert1s = new List<AH_SFDC_Source_Control__c>([SELECT Id FROM AH_SFDC_Source_Control__c]); 
        system.assertEquals(4, lstSSCAssert1s.size()); 
        
        // CREATE SF SOURCE CHANGE RECORD 
        AH_SFDC_Source_Change__c sc1 = new AH_SFDC_Source_Change__c();
        sc1.AH_SFDC_Source_Control__c = [SELECT Id FROM AH_SFDC_Source_Control__c WHERE API_Name__c = 'NI_TestClassData_Test' LIMIT 1].Id;
        sc1.NI_Change_Control__c = nicc.Id;
        insert sc1;
        
        Test.stopTest();
        
        // =============================================================================================================
        // 		VISUALFORCE PAGE TESTING
        // =============================================================================================================
                
        // PAGE REFERENCE        
        PageReference pageRef = Page.AH_RFCSourceChanges;

        // ADD URL PARAM
        pageRef.getParameters().put('id', nicc.Id);        
        
        // SET TEST PAGE
		Test.setCurrentPage(pageRef); 
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_RFCSourceChanges ctrl = new AH_RFCSourceChanges(new ApexPages.StandardController(nicc));            

        // ASSERT THAT 1 (OF 2 TEST RECORD AVAILABLE) SF SOURCE CHANGE IS ATTACHED TO NICC 
        system.assertEquals(1, ctrl.lstSelectedSSCs.size());
        
        // ASSERT THAT 1 (OF 2 TEST RECORD AVAILABLE) SF SOURCE IS AVAILABLE TO CHOOSE 
        system.assertEquals(1, ctrl.lstUserSelections.size());
        
        // CHECK ALL COMPONENT CHECKBOXES
        ctrl.bApexClasses = true;
        ctrl.bApexTriggers = true;
        ctrl.bVFPages = true;
        ctrl.bVFComponents = true; 
        ctrl.bProcessBuilders = true; 
        ctrl.bValidationRules = true;
        
        // DO SEARCH 
        ctrl.strKeyword = 'NI_';
        ctrl.doSearch();
        
        // ASSERT THAT 3 (OF 4 TEST RECORD AVAILABLE) SF SOURCE ARE RETURNED IN SEARCH AND ARE AVAILABLE TO CHOOSE 
        system.assertEquals(3, ctrl.lstUserSelections.size());
        
        // CHECK 1st SELECTION
        ctrl.lstUserSelections.get(0).isSelected = true;

        // ADD SELECTED 
        ctrl.addSelected();
            
        // SAVE SELECTED
        ctrl.saveRecord();
        
        // ASSERT THAT 2 (OF 4 TEST RECORD AVAILABLE) SF SOURCE CHANGE IS ATTACHED TO NICC 
        List<AH_SFDC_Source_Change__c> lstAssertSFSourceChange1 = new List<AH_SFDC_Source_Change__c>([
            SELECT Id 
            FROM AH_SFDC_Source_Change__c 
            WHERE NI_Change_Control__c =: nicc.Id]);        
        system.assertEquals(2, lstAssertSFSourceChange1.size());  
        
        // ASSERT THAT 2 (OF 4 TEST RECORD AVAILABLE) SF SOURCE ARE RETURNED IN SEARCH AND ARE AVAILABLE TO CHOOSE 
        system.assertEquals(2, ctrl.lstUserSelections.size());        

        // CHECK 1st SELECTION
        ctrl.lstSelectedSSCs.get(0).isSelected = true;
        
        // REMOVE SELECTED 
        ctrl.removeSelected();
            
        // SAVE SELECTED
        ctrl.saveRecord();
        
        // ASSERT THAT 2 (OF 4 TEST RECORD AVAILABLE) SF SOURCE CHANGE IS ATTACHED TO NICC 
        List<AH_SFDC_Source_Change__c> lstAssertSFSourceChange2 = new List<AH_SFDC_Source_Change__c>([
            SELECT Id 
            FROM AH_SFDC_Source_Change__c 
            WHERE NI_Change_Control__c =: nicc.Id]);        
        system.assertEquals(1, lstAssertSFSourceChange2.size());  
        
        // ASSERT THAT 3 (OF 4 TEST RECORD AVAILABLE) SF SOURCE ARE RETURNED IN SEARCH AND ARE AVAILABLE TO CHOOSE 
        system.assertEquals(3, ctrl.lstUserSelections.size());         
        
        // TODO: ERROR Methods defined as TestMethod do not support Web service callouts
        // ctrl.syncSource();

        // TEST OPENING THE PAGE WITH NO URL PARAM 
        // PAGE REFERENCE        
        PageReference pageRef2 = Page.AH_RFCSourceChanges;

        // SET TEST PAGE
		Test.setCurrentPage(pageRef2); 
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_RFCSourceChanges ctrl2 = new AH_RFCSourceChanges(new ApexPages.StandardController(nicc));  
        
        // ASSERT
        system.assertEquals('ERROR: No NICC Id Param', ctrl2.pageSubTitle); 
        
    }
    
}