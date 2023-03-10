/****************************************************************************************
Name            : AH_UpdateBacklogMilestones_Ctlr_Test
Author          : Sean Harris
Created Date    : 04/25/2020
Last Mod Date   : 06/25/2020
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test for AH_UpdateBacklogMilestones_Ctlr class
                :            
******************************************************************************************/
@isTest
public class AH_UpdateBacklogMilestones_Ctlr_Test 
{

    // =======================================================================================================================================
    // = TEST METHOD 1: CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup static void createTestData() 
    {

        system.debug(' START - AH_UpdateBacklogMilestones_Ctlr_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Date dt = system.date.today();

//Test.StartTest();        
             
        // CREATE A SYSTEM ADMIN USER TO INSERT THE TEST USER RECORDS TO AVOID MIXED_DML_OPERATION 
        User saUser = NI_TestClassData.createTestUser(1, 'System Administrator'); 
        saUser.Alias = 'SA1TST'; 
        insert saUser;         
        
        system.runAs(saUser)
        {
            // CREATE TEST REGIONAL APPROVER USER
            User u1 = NI_TestClassData.createTestUser(2, 'AH PSA Administrator - Lightning'); 
            u1.FirstName = 'Regional';
            u1.LastName = 'Admin';
            u1.Alias = 'RGA1TST'; 
            insert u1; 
            
            // CREATE TEST RESOURCE MANAGER USER 
            User u2 = NI_TestClassData.createTestUser(3, 'AH PSA Management - Lightning'); 
            u2.FirstName = 'PSAResource';
            u2.LastName = 'Manager';
            u2.Alias = 'MGR1TST'; 
            insert u2; 
            
            // CREATE TEST RESOURCE USER 
            User u3 = NI_TestClassData.createTestUser(4, 'AH PSA T&E - SF - Lightning'); 
            u3.FirstName = 'PSAResource';
            u3.LastName = 'Resource';
            u3.Alias = 'RSC1TST'; 
            u3.ManagerId = u2.Id;
            insert u3;             
        }

        // GET TEST USERS CREATED BY FAKE ADMIN
        User regionApprover = [SELECT Id FROM User WHERE Alias = 'RGA1TST'];
        User resrceMgr = [SELECT Id FROM User WHERE Alias = 'MGR1TST'];
        User resrce = [SELECT Id FROM User WHERE Alias = 'RSC1TST'];
              
		// CREATE TEST ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST PSA ACCOUNT';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Property Account').getRecordTypeId();
        insert a;        
/*
        // CREATE TEST CONTACT RECORD
        Contact cust = NI_TestClassData.createTestContact(1, a.Id);
        cust.LastName = 'Smith';
        insert cust;
*/        
        // GET TEST OPPORTUNITY RECORD
        Schema.DescribeSObjectResult cfrSchema1 = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema1.getRecordTypeInfosByName(); 
        Id opptyRecTypeId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();
      
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.Name = 'APEX TEST OPPORTUNITY 1';
        o.RecordTypeId = opptyRecTypeId;
        insert o;        
/*
        // GET TEST OPPORTUNITY CONTACT ROLE RECORD
        OpportunityContactRole ocr = NI_TestClassData.createTestOpportunityContactRole(o.Id, cust.Id, 'Customer Project Contact');
        insert ocr; 
*/        
        // CREATE TEST PRODUCT GROUP RECORD
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        // CREATE TEST DI INDEX RECORD
        NI_DeploymentInstanceIndex__c diIdx = NI_TestClassData.createDI_Index(1, 'AH_UpdateBacklogMilestones_Ctlr_Test');
        insert diIdx; 
        
        // CREATE TEST PRODUCT PACKAGE RECORD
    	PSA_Product_Package__c pp = NI_TestClassData.createPSAProductPackage();
        insert pp;  
        
        // CREATE TEST PRODUCT2 RECORD
        Product2 p2 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-001', 'Subscription');
        p2.DI_Index__c = diIdx.Id;
        p2.Apttus_Config2__HasOptions__c = false;
        p2.Product_Package__c = pp.Id;
        p2.Unit__c = 'Property';
        insert p2;        

        // CREATE TEST PRICEBOOK ENTRY RECORD
        Id pbkId = Test.getStandardPricebookId(); 
        PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry(pbkId, p2.Id, 1000);
		insert pbe;
        
        // CREATE TEST OPPORTUNITY LINE ITEM RECORD
        OpportunityLineItem oli = NI_TestClassData.createTestOpportunityLineItem(1, o.Id, pbe.Id, 1);
        insert oli; 

//Test.stopTest(); 

        // CREATE TEST PSA REGION  
        pse__Region__c region = NI_TestClassData.createTestRegion(1, 'psaTestRegion');
        region.Name = 'psaTestRegion';  
        region.Central_Expense_Approver__c = regionApprover.Id;
        insert region;   
/*        
        pse__Region__c regionAssert = [SELECT Id, pse__Region_ID_Chain__c, pse__Region_Name_Chain__c FROM pse__Region__c WHERE Name = 'psaTestRegion'];
        system.assertEquals(region.Id, regionAssert.pse__Region_ID_Chain__c);
        system.assertEquals(region.Name, regionAssert.pse__Region_Name_Chain__c);               
       
        // CREATE TEST PSA SCHEDULES  
    	pse__Schedule__c sched = NI_TestClassData.createTestSchedule(dt, dt);
        insert sched;
        
    	pse__Schedule__c sched2 = NI_TestClassData.createTestSchedule(dt, dt);
        insert sched2;
*/         
        // CREATE A TEST PSA PRACTICE  
    	pse__Practice__c practice = NI_TestClassData.createTestPractice(1, 'psaTestPractice');
        practice.Name = 'psaTestPractice';
    	insert practice;

        // CREATE TEST WORK CALENDAR
        pse__Work_Calendar__c WorkCalendar = NI_TestClassData.createTestWorkCalendar('Test Work Calendar');
        insert WorkCalendar;    

        // CREATE TEST GROUP
        pse__Grp__c grp = NI_TestClassData.createTestPSEGroup('Test Group');
        insert grp;   
        
        // CREATE "RESOURCE MANAGER" CONTACT 
        Contact cntMgr = NI_TestClassData.createTestContact(1, a.Id);        
        cntMgr.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId(); 
        cntMgr.FirstName = 'PSAResource';
        cntMgr.LastName = 'Manager';
        cntMgr.pse__Region__c = region.Id;
        cntMgr.pse__Practice__c = practice.Id;
        cntMgr.pse__Work_Calendar__c = WorkCalendar.Id;
        cntMgr.pse__Group__c = grp.Id;
    	cntMgr.pse__Is_Resource_Active__c = true;
    	cntMgr.pse__Is_Resource__c = true;
        cntMgr.pse__Salesforce_User__c = resrceMgr.Id;
    	insert cntMgr; 
        
        // GRANT ACCESS TO RESOURCE MANAGER TO REGION
        pse__Permission_Control__c pc1 = NI_TestClassData.createTestPermissionControl(resrceMgr.Id);
        pc1.pse__Region__c = region.Id;
        pc1.pse__Staffing__c = true; 
        insert pc1;         
        
        // CREATE "RESOURCE" CONTACT 
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);        
        cnt.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId(); 
        cnt.FirstName = 'PSAResource';
        cnt.LastName = 'Resource';
        cnt.pse__Region__c = region.Id;
        cnt.pse__Practice__c = practice.Id;
        cnt.pse__Work_Calendar__c = WorkCalendar.Id;
        cnt.pse__Group__c = grp.Id;
    	cnt.pse__Is_Resource_Active__c = true;
    	cnt.pse__Is_Resource__c = true;
        cnt.pse__Salesforce_User__c = resrce.Id;
    	insert cnt; 

        // GRANT ACCESS TO RESOURCE MANAGER TO RESOURCE
        pse__Permission_Control__c pc2 = NI_TestClassData.createTestPermissionControl(resrceMgr.Id); 
        pc2.pse__Resource__c = cnt.Id; 
        pc2.pse__Staffing__c = true; 
        insert pc2; 

        // CREATE A TEST PSA PROJECT 
    	pse__Proj__c prj = NI_TestClassData.createTestProject(1, 'Test Project', region, practice, 'Draft', null); 
        prj.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('Standard Project').getRecordTypeId(); 
        prj.Name = 'Test Project'; 
        prj.pse__Closed_for_Expense_Entry__c = false; 
        prj.pse__Project_Manager__c = cntMgr.Id; 
        prj.pse__Start_Date__c = dt.addDays(10); 
        prj.pse__End_Date__c = dt.addDays(20); 
        prj.pse__Account__c = a.Id; 
        prj.pse__Opportunity__c = o.Id;
        //prj.Milestone_Change_Note__c = 'Test note';
    	insert prj;
            
        // CREATE TEST BILLING CONTRACT 
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(1);
        bc.Account__c = a.Id;
        bc.Name = 'APEX TEST 1';
        insert bc;

        // CREATE TEST ACTIVITY LINE ITEM 
        Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(bc.Id);
        ali.Account__c = a.Id;
        ali.Product__c = p2.Id;
        ali.Opp_Product_ID__c = oli.Id;
        insert ali; 
        
system.debug(' **^** NUMBER OF QUERIES (createTestData) = ' + Limits.getQueries());
        
        system.debug(' END - AH_UpdateBacklogMilestones_Ctlr_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }


    
    // =======================================================================================================================================
    // = TEST METHOD 1: 
    // =======================================================================================================================================    
    @isTest static void test1() 
    {

		Test.startTest(); 
        
        pse__Proj__c prj = [SELECT Id, Name, Milestone_Change_Note__c, pse__Opportunity__c FROM pse__Proj__c WHERE Name = 'Test Project'];
        Opportunity o = [SELECT Id, Opportunity_Number__c FROM Opportunity WHERE Id =: prj.pse__Opportunity__c];
		Billing_Contract__c bc = [SELECT Id FROM Billing_Contract__c WHERE Name = 'APEX TEST 1'];        
        Activity_Line_Item__c ali = [SELECT Id FROM Activity_Line_Item__c WHERE Billing_Contract__c =: bc.Id];
        
		// CREATE 3 TEST ACCOUNT RECORDS (MANAGED PROPERTIES)
        List<Account> lstAccounts = new List<Account>();
        Account a1 = NI_TestClassData.createTestAccount(1);
        a1.Name = 'Managed Property 1';
        lstAccounts.add(a1);
        Account a2 = NI_TestClassData.createTestAccount(2);
        a2.Name = 'Managed Property 2';
        lstAccounts.add(a2);
        Account a3 = NI_TestClassData.createTestAccount(3);
        a3.Name = 'Managed Property 3';
        lstAccounts.add(a3);
        database.insert(lstAccounts); 
		
        // CREATE 10 TEST MILESTONE RECORDS
        Date dt = system.today() + 730;
        List<pse__Milestone__c> lstMilestones = new List<pse__Milestone__c>();
        
        for (Integer i = 1; (i <= 10); i++)
        {
            
            pse__Milestone__c ms = NI_TestClassData.createTestMilestoneNoALI('tempName', prj, true, true, 'Billable Milestone');
            ms.Activity_Line_Item__c = ali.Id;
            ms.pse__Status__c = 'Open';
            ms.pse__Milestone_Amount__c = 1000; 
            ms.pse__Actual_Date__c = dt;
        	ms.pse__Target_Date__c = dt; 
            
            if (i < 4)
            {
                ms.Managed_Property__c = a1.Id;
                if (i == 1)
                {
                    ms.Name = a1.Name + ' - Configuration - Passive Prop Pkg - ' + o.Opportunity_Number__c;
                }
				if (i == 2)
                {
                    ms.Name = a1.Name + ' - Consulting - Passive Prop Pkg - ' + o.Opportunity_Number__c;
                } 
                if (i == 3)
                {
                    ms.Name = a1.Name + ' - Data Services - Passive Prop Pkg - ' + o.Opportunity_Number__c;
                }  
            }
            if ((i > 3) && (i < 7))
            {
                ms.Managed_Property__c = a2.Id;
                if (i == 4)
                {
                    ms.Name = a2.Name + ' - Configuration - Passive Prop Pkg - ' + o.Opportunity_Number__c;
                }
				if (i == 5)
                {
                    ms.Name = a2.Name + ' - Consulting - Passive Prop Pkg - ' + o.Opportunity_Number__c;
                } 
                if (i == 6)
                {
                    ms.Name = a2.Name + ' - Data Services - Passive Prop Pkg - ' + o.Opportunity_Number__c;
                }  
            } 
			if (i > 6)
            {
                ms.Managed_Property__c = a3.Id;
                if (i == 7)
                {
                    ms.Name = a3.Name + ' - Configuration - Passive Prop Pkg - ' + o.Opportunity_Number__c;
                }
				if (i == 8)
                {
                    ms.Name = a3.Name + ' - Consulting - Passive Prop Pkg - ' + o.Opportunity_Number__c;
                } 
                if (i == 9)
                {
                    ms.Name = a3.Name + ' - Data Services - Passive Prop Pkg - ' + o.Opportunity_Number__c;
                }  
            }    
            if (i == 10)
            {
				ms.pse__Status__c = 'Approved';
                ms.Name = a3.Name + ' - Training - Passive Prop Pkg - ' + o.Opportunity_Number__c;
            }
            lstMilestones.add(ms);
        }

        database.insert(lstMilestones); 

		Test.stopTest(); 

        String strReason = 'CHOOSE ONE';
        Schema.DescribeFieldResult dfr = pse__Milestone__c.Reason_for_Milestone_Change__c.getDescribe();

        for (Schema.PicklistEntry plv : dfr.getPicklistValues())
        {
            strReason = plv.getValue();
        } 
        
        // CREATE INSTANCE OF AH_UpdateBacklogMilestones VISUALFORCE PAGE & CONTROLLER
		PageReference pr = Page.AH_UpdateBacklogMilestones;
		pr.getParameters().put('id', prj.Id);
		Test.setCurrentPageReference(pr);
		ApexPages.StandardController std = new ApexPages.StandardController(prj);
		AH_UpdateBacklogMilestones_Ctlr ctrl = new AH_UpdateBacklogMilestones_Ctlr(std);
      
        // STEP 1: TESTS =======================================================================================
        
        // TEST CANCEL BUTTON THEN RETURN TO PAGE
        PageReference prProj = new PageReference('/' + prj.Id);
        PageReference prCanc = ctrl.step1Cancel();		
        system.assertEquals(prProj.getUrl(), prCanc.getUrl());

        // TEST PAGE VALIDATIONS 
		Test.setCurrentPageReference(pr);
        system.assertEquals('/apex/ah_updatebacklogmilestones?id=' + prj.Id, pr.getUrl());
        
        // ASSERT PROJECT IS NOT LOCKED BY AN APPROVAL PROCESS
        system.assertEquals(false, Approval.isLocked(prj.Id)); 
        
        // PRESS "Next" BUTTON WITH INVALID "Milestone Change Reason" PICKLIST VALUE
        ctrl.step1Next();  
        system.assertEquals('* Milestone Change Reason is required.', ctrl.strErrorMsg);
        
        // CHOOSE VALID "Milestone Change Reason" THEN PRESS "Next" BUTTON WITH MISSING "Milestone Change Note"
        ctrl.selMasterReason = strReason;
        ctrl.step1Next();
        system.assertEquals('* Milestone Change Note is required.', ctrl.strErrorMsg);        
        
        // ADD "Milestone Change Note" AND CLICK "Next"
        ctrl.strMilestoneChangeNote = 'AH_UpdateBacklogMilestones_Ctlr_Test.test1() Note';
system.debug(' **^** invoking step1Next() from test class');          
        ctrl.step1Next();
        // ASSERT ERROR MESSAGE WAS CLEARED
        system.assertEquals('', ctrl.strErrorMsg); 
        // ASSERT THAT "Is Consolidated" CHECKBOX IS UNCHECKED
        system.assertEquals(false, ctrl.bIsConsolidated);
        // ASSERT THAT MILESTONES WERE FOUND AND LOADED
        system.assertEquals(11, ctrl.lstMilestones.size()); 	// (11 = 1 Product Package Row + 10 Milestone Rows)     
        system.assertEquals(10, ctrl.iCount);
        
        // STEP 2: TESTS =======================================================================================
        
        // PRESS "<< Previous" BUTTON
        ctrl.step2Prev();

        // CHECK "Is Consolidated" CHECKBOX (BACK ON STEP 1)
        ctrl.bIsConsolidated = true;

        // PRESS "Next" BUTTON (BACK ON STEP 1)
        ctrl.step1Next();
        // ASSERT ERROR MESSAGE WAS CLEARED
        system.assertEquals('', ctrl.strErrorMsg); 
        // ASSERT THAT "Is Consolidated" CHECKBOX IS UNCHECKED
        system.assertEquals(true, ctrl.bIsConsolidated);
        // ASSERT THAT MILESTONES WERE FOUND AND LOADED
        system.assertEquals(14, ctrl.lstMilestones.size());		// (14 = 1 Product Package Row + 3 Property Rows + 10 Milestone Rows)  
        system.assertEquals(10, ctrl.iCount);        
        
		// PRESS "Next >>" BUTTON WITHOUT SELECTING ANY MILESTONES
        ctrl.step2Next();        
        system.assertEquals('* No Milestones were selected', ctrl.strErrorMsg);     
        
        // LOOP THROUGH AND ASSERT THE READ-ONLY PROPERTIES TO ENSURE THAT THE MILESTONES ON 3RD PROPERTY IS LOCKED BECAUSE OF APPROVED IN GROUP
        for (AH_UpdateBacklogMilestones_Ctlr.displayGridRow rw1 : ctrl.lstMilestones)
        {
            if (rw1.managedPropertyName == 'Managed Property 3')
            {
                system.assertEquals(true, rw1.bIsViewOnly);
            }
            else
            {
                system.assertEquals(false, rw1.bIsViewOnly);
            }             
        }
        
        system.assertEquals('Managed Property 1', ctrl.lstMilestones[1].strHeader);
        
        // CHECK PROPERTY 1'S HEADER ROW
        ctrl.iSelIndex = 1;
        ctrl.lstMilestones[1].bIsPropertySelected = true;
        // CHECK BOX
        ctrl.doSelectProperty();

        // LOOP THROUGH AND ASSERT THE CORRECT MILESTONES WERE SELECTED
        for (AH_UpdateBacklogMilestones_Ctlr.displayGridRow rw2 : ctrl.lstMilestones)
        {
            if (rw2.iIndex == 2 || rw2.iIndex == 3 || rw2.iIndex == 4)
            {
                system.assertEquals(true, rw2.bIsMilestoneSelected, rw2.iIndex + ' failed assertion.');
            }
            else
            {
                system.assertEquals(false, rw2.bIsMilestoneSelected, rw2.iIndex + ' failed assertion.');
            }             
        }        


        // CHECK PRODUCT PACKAGE HEADER ROW
        ctrl.iSelIndex = 0;
        ctrl.lstMilestones[0].bIsPackageSelected = true;
        // CHECK BOX
        ctrl.doSelectPackage();

        //// LOOP THROUGH AND ASSERT THE CORRECT MILESTONES WERE SELECTED (ALL MILESTONES FOR 3RD PROPERTY SHOULD BE LOCKED BECAUSE OF APPROVED IN GROUP)
        for (AH_UpdateBacklogMilestones_Ctlr.displayGridRow rw2 : ctrl.lstMilestones)
        {
            if (rw2.iIndex == 0 || rw2.iIndex == 9 || rw2.iIndex == 10 || rw2.iIndex == 11 || rw2.iIndex == 12 || rw2.iIndex == 13 || rw2.iIndex == 14)
            {
                system.assertEquals(false, rw2.bIsMilestoneSelected, rw2.iIndex + ' failed assertion.');
            }
            else
            {
                system.assertEquals(true, rw2.bIsMilestoneSelected, rw2.iIndex + ' failed assertion.');
            }             
        }  
        
        ctrl.strMSID = ctrl.lstMilestones[2].mileStone.Id;        
		PageReference prMS = ctrl.selectMS();
    	
        ctrl.strALIID = ctrl.lstMilestones[2].activityLineItemNumber;       
		PageReference prALI = ctrl.selectALI(); 
                
        ctrl.strOLIID = ctrl.lstMilestones[2].opportunityLineItemId;       
		PageReference prOLI = ctrl.selectOLI();

		// PRESS "Next >>" BUTTON
        ctrl.step2Next();
       
        // STEP 3: TESTS =======================================================================================

        // PRESS "<< Previous" BUTTON
        ctrl.step3Prev();        
        
		// PRESS "Next >>" BUTTON AGAIN
        ctrl.step2Next();   

		// ASSERT TOTAL MILESTONE AMOUNT        
        system.assertEquals(6000.00, ctrl.dTotalAmount);  
                            
        // PRESS "Save" BUTTON
        ctrl.step3Save();

        // FINAL STEP: TESTS ===================================================================================

        // TEST CLOSE BUTTON THEN RETURN TO PAGE
        PageReference prProj2 = new PageReference('/' + prj.Id);
        PageReference prClse = ctrl.step4Next();		
        system.assertEquals(prProj2.getUrl(), prClse.getUrl());        

        // ASSERT PROJECT IS LOCKED BY AN APPROVAL PROCESS
//        system.assertEquals(true, Approval.isLocked(prj.Id)); 
        
        // TEST PROJECT FOR EXPECTED UPDATES
        pse__Proj__c assertProject = [SELECT Id, Name, Milestone_Change_Note__c, Cancellation_Approval_Status__c FROM pse__Proj__c WHERE Id =: prj.Id];
        system.assertEquals('AH_UpdateBacklogMilestones_Ctlr_Test.test1() Note', assertProject.Milestone_Change_Note__c); 
        system.assertEquals('Submitted', assertProject.Cancellation_Approval_Status__c);
        
        // TEST MILESTONES FOR EXPECTED UPDATES
        Integer iMilestonesAsserted = 0;
        for (pse__Milestone__c mlstn : [SELECT Id, Managed_Property__r.Name, Reason_for_Milestone_Change__c, Milestone_Type__c FROM pse__Milestone__c])
        {
            if (mlstn.Managed_Property__r.Name == a1.Name)
            {
                system.assertEquals(strReason, mlstn.Reason_for_Milestone_Change__c); 
                system.assertEquals('Change Order Requested', mlstn.Milestone_Type__c); 
                iMilestonesAsserted++;                
            }
            if (mlstn.Managed_Property__r.Name == a2.Name)
            {
                system.assertEquals(strReason, mlstn.Reason_for_Milestone_Change__c); 
                system.assertEquals('Change Order Requested', mlstn.Milestone_Type__c); 
                iMilestonesAsserted++;                
            }                
            if (mlstn.Managed_Property__r.Name == a3.Name)
            {
                system.assertEquals(null, mlstn.Reason_for_Milestone_Change__c); 
                system.assertEquals('Billable Milestone', mlstn.Milestone_Type__c); 
                iMilestonesAsserted++;                
            } 
        }
        
        // ASSERT THAT 10 MILESTONES WERE TESTED FOR END RESULTS
        system.assertEquals(10, iMilestonesAsserted); 

        // CREATE ANOTHER INSTANCE OF AH_UpdateBacklogMilestones VISUALFORCE PAGE & CONTROLLER
		PageReference pr2 = Page.AH_UpdateBacklogMilestones;
		pr2.getParameters().put('id', prj.Id);
		Test.setCurrentPageReference(pr2);
		ApexPages.StandardController std2 = new ApexPages.StandardController(prj);
		AH_UpdateBacklogMilestones_Ctlr ctrl2 = new AH_UpdateBacklogMilestones_Ctlr(std2);
        
    }
   
}