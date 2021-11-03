/****************************************************************************************
Name            : AH_Rally_ProductMapping_Ctlr_Test (TC Org Name: ?) 
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-
Description     : Test class for AH_Rally_ProductMapping_Ctlr
				: 
				: 
******************************************************************************************/
@isTest
public class AH_Rally_ProductMapping_Ctlr_Test 
{

    static List<String> caseFieldsCs = new List<String>{'Subject','Status','Priority','Customer_Severity__c','Competitor_1_BID__c','Competitor_2_BID__c',
        'Competitor_3_BID__c','Competitor_4_BID__c','Competitor_5_BID__c','Demand_Property_ID__c','Demand_Property_ID_1__c','Demand_Property_ID_2__c',
        'Demand_Property_ID_3__c','Demand_Property_ID_4__c','Demand_Property_ID_5__c','Property_Mapping__c','Property_Mapping_1__c','Property_Mapping_2__c',
        'Property_Mapping_3__c','Management_Company__c', 'Property_Mapping_4__c','Property_Mapping_5__c', 'Competitor_1__r.Name', 'Competitor_2__r.Name', 'Competitor_3__r.Name', 'Competitor_4__r.Name', 'Competitor_5__r.Name'};
                
	static List<String> caseFields = new List<String>{'Subject','Status','Priority','Customer_Severity__c','Competitor_1_BID__c','Competitor_2_BID__c',
		'Competitor_3_BID__c','Competitor_4_BID__c','Competitor_5_BID__c','Demand_Property_ID__c','Demand_Property_ID_1__c','Demand_Property_ID_2__c',
        'Demand_Property_ID_3__c','Demand_Property_ID_4__c','Demand_Property_ID_5__c','Property_Mapping__c','Property_Mapping_1__c','Property_Mapping_2__c',
        'Property_Mapping_3__c','Property_Mapping_4__c','Property_Mapping_5__c'}; 
    
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        // CREATE RALLY SETUP RECORD
		AH_Rally_Setup__c rsm = new AH_Rally_Setup__c(); 
		rsm.API_Version__c = '1.43';
		rsm.Exception_Notification_Email__c = 'abc@abc.com';
		rsm.password__c = '12345';
		rsm.rallyUrl__c = 'https://rally1.rallydev.com';
		rsm.username__c = 'travelclick';
		rsm.workspace__c = 'jira';
		rsm.Schedular_Last_Run__c = DATETIME.now();
		rsm.Story_Field_Map__c = '{"Description":{"fldValue":"None","literalValue":""},"KanbanState":{"custom":1,"fldValue":"None","literalValue":""},"L3KanbanStage":{"custom":1,"fldValue":"Default","literalValue":"Advance Investigation"},"Moscow":{"custom":1,"fldValue":"None","literalValue":""},"Name":{"fldValue":"Subject","literalValue":""},"Owner":{"fldValue":"None","literalValue":""},"Package":{"fldValue":"None","literalValue":""},"Rank":{"fldValue":"None","literalValue":""},"ReadyDeprecated":{"custom":1,"fldValue":"None","literalValue":""},"SalesforcePriority":{"custom":1,"fldValue":"Priority","literalValue":""},"StoryType":{"custom":1,"fldValue":"Default","literalValue":"L3/Salesforce"}}';
        insert rsm;   
        
        // CREATE TEST PRODUCT PROJECT (CUSTOM SETTING) RECORDS
        List<ProductMapping__c> lstPMs = new List<ProductMapping__c>();
        
        ProductMapping__c pro0 = new ProductMapping__c();
        pro0.Name = 'Mapping0';
        pro0.Product_Family__c = 'Reservation Solutions';
        pro0.Product__c = 'iHotelier CRS'; 
        pro0.Affected_Component__c = 'Analytics and Tracking';
        pro0.Component__c = 'Access';
        pro0.Project__c = 'L3 Ihotelier';
        lstPMs.add(pro0);

        ProductMapping__c pro1 = new ProductMapping__c();
        pro1.Name = 'Mapping1';
        pro1.Product_Family__c = 'Reservation Solutions';
        pro1.Product__c = 'iHotelier CRS'; 
        pro1.Affected_Component__c = 'Analytics and Tracking';
        pro1.Component__c = 'IH Analytics';
        pro1.Project__c = 'L3 Ihotelier';		// LATER TO BE CHANGED TO 'BI L3' IN A UNIT TEST
        lstPMs.add(pro1);
        
        ProductMapping__c pro2 = new ProductMapping__c();
        pro2.Name = 'Mapping2';
        pro2.Product_Family__c = 'Reservation Solutions';
        pro2.Product__c = 'iHotelier CRS'; 
        pro2.Affected_Component__c = 'Analytics and Tracking';
        pro2.Component__c = 'iManager';
        pro2.Project__c = 'L3 Ihotelier';
        lstPMs.add(pro2);
        
        database.insert(lstPMs);
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: TEST ADDING CUSTOM SETTINGS VIA VF PAGE
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {  
        
        Test.startTest();

        // INSTANTIATE PAGE REFERENCE
        PageReference pr = Page.AH_Rally_ProductMapping;
        Test.setCurrentPage(pr);             

        // INSTANTIATE PAGE CONTROLLER 
        AH_Rally_Library.str = '{"Workspaces":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/5339961604.js","_refObjectName":"TestBed","_type":"Workspace"}],"Workspace":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/7622744606.js","_objectVersion":"13","_refObjectName":"Jira","CreationDate":"2012-08-23T21:17:43.829Z","_CreatedAt":"Aug 24, 2012","ObjectID":7622744606,"Subscription":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/subscription/5339961586.js","_refObjectName":"TravelClick","_type":"Subscription"},"Description":"","Name":"Jira","Notes":"","Owner":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/user/5402778943.js","_refObjectName":"Raj S","_type":"User"},"Environment":"Production","FixedInBuild":null,"FoundInBuild":null,"InProgressDate":null,"Iteration":null,"OpenedDate":null,"Package":null,"PlanEstimate":null,"Priority":"None","Recycled":false,"Release":null,"ReleaseNote":false,"Requirement":null,"Resolution":"None","SalesforceCaseID":null,"SalesforceCaseNumber":null,"ScheduleState":"Backlog","Severity":"None","State":"Submitted","SubmittedBy":null,"TargetBuild":null,"TargetDate":null,"TaskActualTotal":0.0,"TaskEstimateTotal":0.0,"TaskRemainingTotal":0.0,"TaskStatus":"NONE","VerifiedInBuild":null,"AffectedComponent":null,"AffectedCustomers":"","BEKanBanState":null,"BID":null,"BusinessDivision":null,"BusinessLocation":null,"BusinessLocationTest":"","BusinessName":null,"BusinessNameTest":"","CaseOwner":"Prateek Gupta","CaseOwnerEmail":null,"CustomerName":null,"CustomerURLtoSite":null,"iHotelierLicenseID":null,"iHotelierLicenseIDTest":"","JiraID":null,"JiraLink":null,"KanbanState":null,"Language":null,"NumberofCases":0,"Product":null,"ProductFamily":null,"ProductTest":"","RallyL3LinkedDefect":null,"ReadyDeprecated":null,"ReportingType":null,"ReportingTypeTest":"","Projects":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/8000236560.js","_refObjectName":"L3_Ihotelier","_type":"Project"},{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/9026848903.js","_refObjectName":"iHotelier Dev Team","_type":"Project"}],"Object":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/7999255971.js","_objectVersion":"2","_refObjectName":"test for converting to a story","LastUpdateDate":"2012-09-25T03:03:16.804Z","Release":null,"Project":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/7622744697.js","_refObjectName":"Reservations","_type":"Project"},"KanbanState":null,"_type":"HierarchicalRequirement"}]}}';
        AH_Rally_ProductMapping_Ctlr ctrl = new AH_Rally_ProductMapping_Ctlr();            
        
		// ASSERT 5 TEST Rally Projects WERE LOADED
        system.assertEquals(5, ctrl.soProjects.size());
        // ASSERT THE NEW PANEL WAS LOADED
        system.assertEquals(1, ctrl.lstNewMapping.size());
        // ASSERT 3 TEST CUSTOM SETTINGS EXIST
        system.assertEquals(3, ctrl.lstMappings.size());
        
        // TEST ADDING NEW CUSTOM SETTING
        
        // TEST WITHOUT Rally Solution Domain SPECIFIED
        ctrl.doAddRow();
        system.assertEquals('Please choose a valid value for Rally Solution Domain.', ctrl.strAddMsg);
        system.assertEquals('text-align:center;color: red !important;', ctrl.strAddMsgStyle);
        ctrl.lstNewMapping[0].myCase.Product_Family__c = 'Reservation Solutions';
        
        // TEST WITHOUT Case Product Line SPECIFIED
        ctrl.doAddRow();
        system.assertEquals('Please choose a valid value for Case Product Line.', ctrl.strAddMsg);
        system.assertEquals('text-align:center;color: red !important;', ctrl.strAddMsgStyle);
        ctrl.lstNewMapping[0].myCase.Case_Product_Line__c = 'iHotelier CRS';
        
        // TEST WITHOUT Module SPECIFIED
        ctrl.doAddRow();
        system.assertEquals('Please choose a valid value for Module.', ctrl.strAddMsg);
        system.assertEquals('text-align:center;color: red !important;', ctrl.strAddMsgStyle);
        ctrl.lstNewMapping[0].myCase.Module__c = 'Analytics and Tracking';
        ctrl.lstNewMapping[0].myCase.Component__c = 'iManager';				// INTENTIONALLY CAUSES A DUPE
        
        // TEST WITHOUT Component SPECIFIED
        //ctrl.doAddRow();
        //system.assertEquals('Please choose a valid value for Component.', ctrl.strAddMsg);
        //system.assertEquals('text-align:center;color: red !important;', ctrl.strAddMsgStyle);
        //ctrl.lstNewMapping[0].myCase.Component__c = 'iManager';
        
        // TEST WITHOUT Project SPECIFIED
        ctrl.doAddRow();
        system.assertEquals('We cannot add this new mapping because there is an existing mapping with the same values and they need to be unique.', ctrl.strAddMsg);
        system.assertEquals('text-align:center;color: red !important;', ctrl.strAddMsgStyle);
        ctrl.lstNewMapping[0].myCase.Component__c = 'iTrak';
        
		ctrl.doAddRow();
        system.assertEquals('Please choose a valid value for Project.', ctrl.strAddMsg);
        system.assertEquals('text-align:center;color: red !important;', ctrl.strAddMsgStyle);       
		ctrl.lstNewMapping[0].project = 'test for converting to a story';    
    
        // ASSERT INSERT WAS SUCCESSFUL AFTER VALIDATIONS
        Map<String, ProductMapping__c> mapBefore = ProductMapping__c.getAll();
        system.assertEquals(3, mapBefore.size());
        ctrl.doAddRow();
        system.assertEquals('Mapping added successfully', ctrl.strAddMsg);
        system.assertEquals('text-align:center;color: green !important;', ctrl.strAddMsgStyle);                 
        system.assertEquals(4, ctrl.lstMappings.size());
        
		Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: TEST EDITING CUSTOM SETTINGS VIA VF PAGE
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {  
        
        Test.startTest();

        // INSTANTIATE PAGE REFERENCE
        PageReference pr = Page.AH_Rally_ProductMapping;
        Test.setCurrentPage(pr);             

        // INSTANTIATE PAGE CONTROLLER 
        AH_Rally_Library.str = '{"Workspaces":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/5339961604.js","_refObjectName":"TestBed","_type":"Workspace"}],"Workspace":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/7622744606.js","_objectVersion":"13","_refObjectName":"Jira","CreationDate":"2012-08-23T21:17:43.829Z","_CreatedAt":"Aug 24, 2012","ObjectID":7622744606,"Subscription":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/subscription/5339961586.js","_refObjectName":"TravelClick","_type":"Subscription"},"Description":"","Name":"Jira","Notes":"","Owner":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/user/5402778943.js","_refObjectName":"Raj S","_type":"User"},"Environment":"Production","FixedInBuild":null,"FoundInBuild":null,"InProgressDate":null,"Iteration":null,"OpenedDate":null,"Package":null,"PlanEstimate":null,"Priority":"None","Recycled":false,"Release":null,"ReleaseNote":false,"Requirement":null,"Resolution":"None","SalesforceCaseID":null,"SalesforceCaseNumber":null,"ScheduleState":"Backlog","Severity":"None","State":"Submitted","SubmittedBy":null,"TargetBuild":null,"TargetDate":null,"TaskActualTotal":0.0,"TaskEstimateTotal":0.0,"TaskRemainingTotal":0.0,"TaskStatus":"NONE","VerifiedInBuild":null,"AffectedComponent":null,"AffectedCustomers":"","BEKanBanState":null,"BID":null,"BusinessDivision":null,"BusinessLocation":null,"BusinessLocationTest":"","BusinessName":null,"BusinessNameTest":"","CaseOwner":"Prateek Gupta","CaseOwnerEmail":null,"CustomerName":null,"CustomerURLtoSite":null,"iHotelierLicenseID":null,"iHotelierLicenseIDTest":"","JiraID":null,"JiraLink":null,"KanbanState":null,"Language":null,"NumberofCases":0,"Product":null,"ProductFamily":null,"ProductTest":"","RallyL3LinkedDefect":null,"ReadyDeprecated":null,"ReportingType":null,"ReportingTypeTest":"","Projects":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/8000236560.js","_refObjectName":"L3_Ihotelier","_type":"Project"},{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/9026848903.js","_refObjectName":"iHotelier Dev Team","_type":"Project"}],"Object":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/7999255971.js","_objectVersion":"2","_refObjectName":"test for converting to a story","LastUpdateDate":"2012-09-25T03:03:16.804Z","Release":null,"Project":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/7622744697.js","_refObjectName":"Reservations","_type":"Project"},"KanbanState":null,"_type":"HierarchicalRequirement"}]}}';
        AH_Rally_ProductMapping_Ctlr ctrl = new AH_Rally_ProductMapping_Ctlr();            
        
		// ASSERT 5 TEST Rally Projects WERE LOADED
        system.assertEquals(5, ctrl.soProjects.size());
        
        // ASSERT THE NEW PANEL WAS LOADED
        system.assertEquals(1, ctrl.lstNewMapping.size());
        
        // ASSERT 3 TEST CUSTOM SETTINGS EXIST
        system.assertEquals(3, ctrl.lstMappings.size());
system.debug('1. ctrl.iSelectedRow = ' + ctrl.iSelectedRow);  
        
		// EDIT 2nd RECORD IN THE LIST
		ctrl.iSelectedRow = 1;
        ctrl.doEdit();
        system.assertEquals(false, ctrl.lstMappings[0].inEditMode);
		system.assertEquals(true, ctrl.lstMappings[1].inEditMode);
        system.assertEquals(false, ctrl.lstMappings[2].inEditMode);
system.debug('2. ctrl.iSelectedRow = ' + ctrl.iSelectedRow);    
        
        // TEST CANCEL EDIT BUTTON
        ctrl.doCancelEdit();
        system.assertEquals(false, ctrl.lstMappings[0].inEditMode);
		system.assertEquals(false, ctrl.lstMappings[1].inEditMode);
        system.assertEquals(false, ctrl.lstMappings[2].inEditMode);        
        system.assertEquals('', ctrl.strEditMsg);
        system.assertEquals('color: green !important;', ctrl.strEditMsgStyle);          
system.debug('3. ctrl.iSelectedRow = ' + ctrl.iSelectedRow);         
        // MAKE AN INVALID EDIT
        ctrl.doEdit();   
/*
List<ProductMapping__c> lstDebug1 = new List<ProductMapping__c>(
[SELECT Id FROM ProductMapping__c 
WHERE Product_Family__c =: ctrl.lstMappings[ctrl.iSelectedRow].myCase.Product_Family__c
AND Product__c =: ctrl.lstMappings[ctrl.iSelectedRow].myCase.Case_Product_Line__c
AND Affected_Component__c =: ctrl.lstMappings[ctrl.iSelectedRow].myCase.Module__c
AND Component__c =: ctrl.lstMappings[ctrl.iSelectedRow].myCase.Component__c
AND Project__c =: ctrl.lstMappings[ctrl.iSelectedRow].project]);
        
system.debug(' ::::::: lstDebug1.size() = ' + lstDebug1.size());
system.debug(' ::::::: Product_Family__c = ' + ctrl.lstMappings[ctrl.iSelectedRow].myCase.Product_Family__c);
system.debug(' ::::::: Product__c = ' + ctrl.lstMappings[ctrl.iSelectedRow].myCase.Case_Product_Line__c);
system.debug(' ::::::: Affected_Component__c = ' + ctrl.lstMappings[ctrl.iSelectedRow].myCase.Module__c);
system.debug(' ::::::: Component__c = ' + ctrl.lstMappings[ctrl.iSelectedRow].myCase.Component__c);
system.debug(' ::::::: Project__c = ' + ctrl.lstMappings[ctrl.iSelectedRow].project);
        
        ctrl.lstMappings[ctrl.iSelectedRow].myCase.Component__c = 'iManager'; 
        system.assertEquals(false, ctrl.bShowEditConfirmDialog);
        ctrl.doSaveEdit();
        system.assertEquals('We cannot add this new mapping because there is an existing mapping with the same values and they need to be unique.', ctrl.strEditMsg);
        system.assertEquals('color:red !important;', ctrl.strEditMsgStyle);            
        system.assertEquals(true, ctrl.bShowEditConfirmDialog);   
*/        
        ctrl.editDialogClose();
        system.assertEquals(false, ctrl.bShowEditConfirmDialog); 
system.debug('4. ctrl.iSelectedRow = ' + ctrl.iSelectedRow);         
        // MAKE A VALID EDIT
        ctrl.lstMappings[ctrl.iSelectedRow].myCase.Component__c = 'iTrak'; 		                
        ctrl.doSaveEdit();  
        system.assertEquals('Mapping updated successfully', ctrl.strEditMsg);
        ctrl.editDialogClose();
        system.assertEquals(false, ctrl.bShowEditConfirmDialog);
                
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: TEST DELETING CUSTOM SETTINGS VIA VF PAGE
    // ======================================================================================================================================= 
    @isTest static void test3() 
    {  
        
        Test.startTest(); 

        // INSTANTIATE PAGE REFERENCE
        PageReference pr = Page.AH_Rally_ProductMapping; 
        Test.setCurrentPage(pr); 

        // INSTANTIATE PAGE CONTROLLER 
        AH_Rally_Library.str = '{"Workspaces":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/5339961604.js","_refObjectName":"TestBed","_type":"Workspace"}],"Workspace":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/7622744606.js","_objectVersion":"13","_refObjectName":"Jira","CreationDate":"2012-08-23T21:17:43.829Z","_CreatedAt":"Aug 24, 2012","ObjectID":7622744606,"Subscription":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/subscription/5339961586.js","_refObjectName":"TravelClick","_type":"Subscription"},"Description":"","Name":"Jira","Notes":"","Owner":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/user/5402778943.js","_refObjectName":"Raj S","_type":"User"},"Environment":"Production","FixedInBuild":null,"FoundInBuild":null,"InProgressDate":null,"Iteration":null,"OpenedDate":null,"Package":null,"PlanEstimate":null,"Priority":"None","Recycled":false,"Release":null,"ReleaseNote":false,"Requirement":null,"Resolution":"None","SalesforceCaseID":null,"SalesforceCaseNumber":null,"ScheduleState":"Backlog","Severity":"None","State":"Submitted","SubmittedBy":null,"TargetBuild":null,"TargetDate":null,"TaskActualTotal":0.0,"TaskEstimateTotal":0.0,"TaskRemainingTotal":0.0,"TaskStatus":"NONE","VerifiedInBuild":null,"AffectedComponent":null,"AffectedCustomers":"","BEKanBanState":null,"BID":null,"BusinessDivision":null,"BusinessLocation":null,"BusinessLocationTest":"","BusinessName":null,"BusinessNameTest":"","CaseOwner":"Prateek Gupta","CaseOwnerEmail":null,"CustomerName":null,"CustomerURLtoSite":null,"iHotelierLicenseID":null,"iHotelierLicenseIDTest":"","JiraID":null,"JiraLink":null,"KanbanState":null,"Language":null,"NumberofCases":0,"Product":null,"ProductFamily":null,"ProductTest":"","RallyL3LinkedDefect":null,"ReadyDeprecated":null,"ReportingType":null,"ReportingTypeTest":"","Projects":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/8000236560.js","_refObjectName":"L3_Ihotelier","_type":"Project"},{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/9026848903.js","_refObjectName":"iHotelier Dev Team","_type":"Project"}],"Object":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/7999255971.js","_objectVersion":"2","_refObjectName":"test for converting to a story","LastUpdateDate":"2012-09-25T03:03:16.804Z","Release":null,"Project":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/7622744697.js","_refObjectName":"Reservations","_type":"Project"},"KanbanState":null,"_type":"HierarchicalRequirement"}]}}';
        AH_Rally_ProductMapping_Ctlr ctrl = new AH_Rally_ProductMapping_Ctlr(); 
        
		// ASSERT 5 TEST Rally Projects WERE LOADED 
        system.assertEquals(5, ctrl.soProjects.size()); 
        // ASSERT THE NEW PANEL WAS LOADED 
        system.assertEquals(1, ctrl.lstNewMapping.size()); 
        // ASSERT 3 TEST CUSTOM SETTINGS EXIST 
        system.assertEquals(3, ctrl.lstMappings.size()); 
system.debug('1. ctrl.lstMappings.size() = ' + ctrl.lstMappings.size()); 
		// DELETE 2nd RECORD IN THE LIST 
		ctrl.iSelectedRow = 1; 
        ctrl.deleteConfirm(); 
        system.assertEquals(true, ctrl.bShowDeleteConfirmDialog); 
        ctrl.deleteCancel(); 
        system.assertEquals(false, ctrl.bShowDeleteConfirmDialog); 
system.debug('2. ctrl.lstMappings.size() = ' + ctrl.lstMappings.size()); 
        // PURPOSELY CAUSE AND ERROR TO COVER TRY CATCH 
        ctrl.iSelectedRow = 1000;    
        ctrl.doDelete();
        system.assertEquals(true, ctrl.strAddMsg.startsWith('The following error occurred when deleting mapping: ')); 
        system.assertEquals('text-align:center;color: red !important;', ctrl.strAddMsgStyle);   
        ctrl.deleteCancel();
system.debug('3. ctrl.lstMappings.size() = ' + ctrl.lstMappings.size()); 
system.debug('    Row 1 Name = ' + ctrl.lstMappings[0].mapName); 
system.debug('    Row 2 Name = ' + ctrl.lstMappings[1].mapName); 
system.debug('    Row 3 Name = ' + ctrl.lstMappings[2].mapName); 
        // ISSUE VALID DELETE
        ctrl.iSelectedRow = 1;
        ctrl.deleteConfirm(); 
        ctrl.doDelete(); 
system.debug('4. ctrl.lstMappings.size() = ' + ctrl.lstMappings.size()); 
        // ASSERT THAT THERE IS 1 LESS CUSTOM SETTING RECORD
        system.assertEquals(2, ctrl.lstMappings.size()); 
        system.assertEquals(false, ctrl.bShowDeleteConfirmDialog); 
        system.assertEquals('Mapping deleted successfully', ctrl.strAddMsg); 
		
        Test.stopTest(); 
        
    }
    
}