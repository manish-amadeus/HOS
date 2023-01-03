/****************************************************************************************
Name            : AH_RecordReferenceSearch_Cntlr_Test Class
Author          : Shashikant Nikam
Created Date    : 07/11/2019
Last Mod Date   : 07/11/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : NICC-037096
Description     : Test class for AH_RecordReferenceSearch_Cntlr class
                :
                :
 ******************************************************************************************/
@isTest
public class AH_RecordReferenceSearch_Cntlr_Test
{
	public static final String DEFAULT_PRACTICE_NAME = 'psaTestPractice';
	public static final String DEFAULT_REGION_NAME = 'psaTestRegion';
	public static final String DEFAULT_RESOURCE_NAME = 'PSA Test Resource';
	public static pse__Practice__c defaultPractice;
	public static pse__Region__c defaultRegion;
	public static Contact defaultResource;
	public static pse__Work_Calendar__c defaultWorkCalendar;
	public static final String MILESTONE_STATUS_DRAFT = 'Draft/Tentative';
	public static final String PROJECT_STAGE_DRAFT = 'Draft';
	public static final String PROJECT_TYPE_CUSTOMER = 'Customer Project';

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
	@testSetup static void createTestData()
	{
		Test.startTest();

		//CREATE A TEST ACCOUNT
		Account a1 = NI_TestClassData.createTestAccount(1);
		insert a1;

		// GET RECORDTYPE INFO
		Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity;
		Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
		Id rtSmallDealId = OpportunityRecordTypeInfo.get('Small Deal Opportunity').getRecordTypeId();

		// CREATE ACCT PLAN RECORD
		SFDC_Acct_Plan__c apln = NI_TestClassData.createAccountPlan(1, a1.Id);
		insert apln;

		// CREATE STRATEGY RECORD
		SFDC_Strategy__c stgy = NI_TestClassData.createStrategy(1, a1.Id, apln.Id);
		insert stgy;

		// CREATE TEST OPPORTUNITY
		List<Opportunity> lstOpptys = new List<Opportunity>();
		Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a1.Id);
		opp1.RecordTypeId = rtSmallDealId;
		opp1.Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1';
		opp1.Strategy__c = stgy.Id;
		lstOpptys.add(opp1);
		insert lstOpptys;

		Softrax_Order_Line__c soft = NI_TestClassData.createStxOrderLines(1,opp1.Id);
		soft.Name = 'Test Softrax Order Line 1';
		soft.Opportunity_ID__c = opp1.Id;
		insert soft;

		// CREATE TEST REGION
		pse__Region__c defaultRegion = NI_TestClassData.createTestRegion(1, DEFAULT_REGION_NAME);
		insert defaultRegion;

		// CREATE TEST PRACTISE
		pse__Practice__c defaultPractice = NI_TestClassData.createTestPractice(1,DEFAULT_PRACTICE_NAME);
		insert defaultPractice;

		// CREATE TEST WORK CALENDAR
		defaultWorkCalendar = NI_TestClassData.createTestWorkCalendar('Test Work Calendar');
		insert defaultWorkCalendar;

		List<Contact> cList = [SELECT Id FROM Contact WHERE pse__Salesforce_User__c =: UserInfo.getUserId()];
		for (Contact c : cList)
		{
			c.pse__Salesforce_User__c = null;
		}

		if (!cList.isEmpty())
		{
			update cList;
		}

		// CREATE TEST CONTACT
		Contact con1 = NI_TestClassData.createTestContact(1, a1.Id);
		con1.LastName = DEFAULT_RESOURCE_NAME;
		con1.pse__Resource_Role__c = 'Systems Engineering';
		con1.pse__Is_Resource__c = true;
		con1.pse__Is_Resource_Active__c = true;
		con1.MailingStreet = '222 Oak St';
		con1.MailingCity = 'Arlington';
		con1.MailingState = 'VA';
		con1.MailingCountry = 'US';
		con1.MailingPostalCode = '22102';
		con1.pse__Salesforce_User__c = UserInfo.getUserId();
		con1.pse__Region__c = defaultRegion.Id;
		con1.pse__Practice__c = defaultPractice.Id;
		con1.pse__Work_Calendar__c = defaultWorkCalendar.Id;
		insert con1;

		// CREATE TEST PROJECT
		pse__Proj__c testProject = NI_TestClassData.createTestProject(1, 'Assignment/Milestone Date Test Project', defaultRegion, defaultPractice, PROJECT_STAGE_DRAFT,opp1);
		testProject.pse__Is_Active__c = true;
		testProject.pse__Is_Billable__c = true;
		testProject.pse__Allow_Timecards_Without_Assignment__c = true;
		testProject.pse__Allow_Expenses_Without_Assignment__c = true;
		testProject.pse__Project_Type__c = PROJECT_TYPE_CUSTOMER;
		testProject.pse__Project_Status__c = 'Green'; 
		if (opp1 != null)
		{
			testProject.pse__Opportunity__c = opp1.Id;
		}
		insert testProject;

		// TEST BILLING CONTRACTS
		List<Billing_Contract__c> bcList = new List<Billing_Contract__c>();
		for (Integer i = 1; i <= 2; i++)
		{
			Billing_Contract__c blgCnrct = NI_TestClassData.createBillingContract(i);
			blgCnrct.Name = 'SN Test ' + i;
			blgCnrct.Account__c =  a1.Id;
			blgCnrct.Renewal_Increase_Cap_Percentage__c = 5;
			blgCnrct.Opportunity__c = opp1.id;
			blgCnrct.Bill_To_Contact__c = con1.id;
			bcList.add(blgCnrct);
		}
		insert bcList;

		// TEST ACTIVITY LINE ITEMS
		List<Activity_Line_Item__c> actList = new List<Activity_Line_Item__c>();
		for (Integer i = 1; i <= 2; i++)
		{
			Activity_Line_Item__c actLI = NI_TestClassData.createActivityLineItem(bcList[i - 1].Id);
			actLI.Cancel_Line_Item__c = false;
			actLI.Opportunity__c = opp1.id;
			actLI.Contract_Start_Date__c = Date.Today() - 100;
			actLI.Contract_End_Date__c = Date.Today() + 200;
			actLI.Units__c = 1;
			actLI.Status__c = 'Active';
			actLI.Origin__c = 'Renewal';
			actLI.Contract_Amount__c = 1000;
			actLI.Renewal_Base_Price__c = 500;
			actLI.Auto_Renewal__c = false;
			actLI.Renewal_Processed__c = false;
			actLI.Revenue_Category__c = 'Services';
			actList.add(actLI);
		}
		insert actList;

		// CREATE A MILESTONE FOR THE PROJECT
		pse__Milestone__c milestone = NI_TestClassData.createTestMilestoneNoALI('Assignment-Milestone Target Date Test',testProject,True,True,'Billable Milestone');
		milestone.pse__Target_Date__c = date.newInstance(2025, 12, 31);
		milestone.Target_Period__c = 'Year-2018';
		milestone.pse__Milestone_Amount__c = 100;
		milestone.Softrax_Order_Line_PSA__c = soft.id;
		milestone.Opportunity__c = opp1.id;
		milestone.Target_Period__c = 'Year-2018';
		milestone.Activity_Line_Item__c = actList[0].id;
		insert milestone;

		Test.stopTest();
	}

    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void test1() 
	{
		Account act1 = [SELECT Id, Name FROM Account WHERE NAME =: 'Test1'];
		List<Activity_Line_Item__c> lstALIAsserts = new List<Activity_Line_Item__c>([SELECT Id, Name FROM Activity_Line_Item__c]);
		List<pse__Milestone__c> mileStoneList = [SELECT Id, Name, Activity_Line_Item__c FROM pse__Milestone__c
		                                         WHERE Activity_Line_Item__c =: lstALIAsserts[0].id];

		Test.startTest();

		PageReference pageRef = Page.AH_RecordReferenceSearch;
		Test.setCurrentPage(pageRef);
		AH_RecordReferenceSearch_Cntlr cntlr = new AH_RecordReferenceSearch_Cntlr();
		cntlr.inputSFId = lstALIAsserts[0].id;
		cntlr.findReferences();

		Map<Integer, List<String>> testMap = cntlr.objectToField;

		for (Integer k : testMap.keyset())
		{
			if (testMap.get(k)[0] != 'pse__Milestone__c')
			{
				testMap.remove(k);
			}
		}

		cntlr.objectToField = testMap;
		cntlr.exportRecords();
		cntlr.getExportRecordResult();
		cntlr.replacementSFId = lstALIAsserts[1].id;
		cntlr.replaceReferences();

		// INSERT JOB RUN HISTORY RECORD
		Job_Run_History__c runHist = new Job_Run_History__c();
		runHist.Apex_Class__c = 'AH_RecordReferenceSearch_Batch';
		runHist.Status__c = 'Run';
		runHist.No_of_Items_Processed__c = 1;
		runHist.Target_Object__c = '';
		runHist.User__c = UserInfo.getUserName();
		runHist.Created_Date__c = Datetime.now();
		runHist.Unique_Timestamp__c = cntlr.uniqueString;
		runHist.Status_Detail__c = 'Success';
		insert runHist;

		// CREATE TEST ERROR LOG
		Id RecordTypeId = Schema.SObjectType.NI_Admin_Error_Log__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
		String error = 'Error Message: entity type AccountContactRoleChangeEvent does not support query.';
		NI_Error_Logger.WriteToLog(error, cntlr.uniqueString, 'AH_RecordReferenceSearch_Batch.execute', 'SELECT', UserInfo.getUserId(), RecordTypeId);

		cntlr.getExportRecordResult();

		// ASSERT PAGE MESSAGES
		String msg1 = 'Batch Job to export the referenced records has been started.';
		String msg2 = 'Batch Job to replace the SF ID has been started.';

		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		Boolean messageFoundFlag1 = false;
		Boolean messageFoundFlag2 = false;

		if (pageMessages[0].getSummary().contains(msg1))
		{
			messageFoundFlag1 = true;
		}

		if (pageMessages[1].getSummary().contains(msg2))
		{
			messageFoundFlag2 = true;
		}

		system.assertEquals(messageFoundFlag1, true, 'Exported Records button message not found.');
		system.assertEquals(messageFoundFlag2, true, 'Replace Records button message not found.');

		Test.stopTest();
	}

    // ======================================================================================================================================= 
    // = TEST METHOD 2: 
    // ======================================================================================================================================= 
    @isTest static void test2() 
	{
		Account act1 = [SELECT Id, Name from Account WHERE Name =: 'Test1'];
		List<Activity_Line_Item__c> lstALIAsserts = new List<Activity_Line_Item__c>([SELECT Id, Name FROM Activity_Line_Item__c]);
		List<pse__Milestone__c> mileStoneList = [select Id, Name, Activity_Line_Item__c FROM pse__Milestone__c
		                                         WHERE Activity_Line_Item__c =: lstALIAsserts[0].id];


		Test.startTest();

		PageReference pageRef = Page.AH_RecordReferenceSearch;
		Test.setCurrentPage(pageRef);
		AH_RecordReferenceSearch_Cntlr cntlr = new AH_RecordReferenceSearch_Cntlr();
		cntlr.inputSFId = lstALIAsserts[0].id;
		cntlr.findReferences();

		Map<Integer,List<String> > testMap = cntlr.objectToField;

		for (Integer k : testMap.keyset())
		{
			if (testMap.get(k)[0] != 'pse__Milestone__c')
			{
				testMap.remove(k);
			}
		}

		cntlr.objectToField = testMap;
		cntlr.exportRecords();
		cntlr.getExportRecordResult();
		cntlr.replacementSFId = lstALIAsserts[1].id;
		cntlr.replaceReferences();

		// ASSERT PAGE MESSAGES
		String msg1 = 'Batch Job to export the referenced records has been started.';
		String msg2 = 'Batch Job to replace the SF ID has been started.';

		ApexPages.Message[] pageMessages = ApexPages.getMessages();

		Boolean messageFoundFlag1 = false;
		Boolean messageFoundFlag2 = false;

		if (pageMessages[0].getSummary().contains(msg1))
		{
			messageFoundFlag1 = true;
		}

		if (pageMessages[1].getSummary().contains(msg2))
		{
			messageFoundFlag2 = true;
		}

		system.assertEquals(messageFoundFlag1, true, 'Exported Records button message not found.');
		system.assertEquals(messageFoundFlag2, true, 'Replace Records button message not found.');

		Test.stopTest();
	}

    // ======================================================================================================================================= 
    // = TEST METHOD 3: 
    // ======================================================================================================================================= 
    @isTest static void test3() 
	{
		Account act1 = [SELECT Id, Name FROM Account WHERE Name =: 'Test1'];
		List<Activity_Line_Item__c> lstALIAsserts = new List<Activity_Line_Item__c>([SELECT Id, Name FROM Activity_Line_Item__c]);
		List<pse__Milestone__c> mileStoneList = [SELECT Id, Name, Activity_Line_Item__c FROM pse__Milestone__c
		                                         WHERE Activity_Line_Item__c =: lstALIAsserts[0].id];

		Test.startTest();

		PageReference pageRef = Page.AH_RecordReferenceSearch;
		Test.setCurrentPage(pageRef);

		AH_RecordReferenceSearch_Cntlr cntlr = new AH_RecordReferenceSearch_Cntlr();

		cntlr.inputSFId = lstALIAsserts[0].id;
		cntlr.findReferences();

		Map<Integer, List<String>> testMap = new Map<Integer, List<String>>();
		cntlr.objectToField = testMap;
		cntlr.exportRecords();
		cntlr.getExportRecordResult();
		cntlr.replacementSFId = lstALIAsserts[1].id;
		cntlr.replaceReferences();

		// ASSERT PAGE MESSAGES
		String msg1 = 'Either Input SF ID is missing OR user has not submitted the query';
		String msg2 = 'Either Input SF ID OR Replacement SF ID is missing OR user has not submitted the query';

		ApexPages.Message[] pageMessages = ApexPages.getMessages();

		Boolean messageFoundFlag1 = false;
		Boolean messageFoundFlag2 = false;

		if (pageMessages[0].getSummary().contains(msg1))
		{
			messageFoundFlag1 = true;
		}

		if (pageMessages[1].getSummary().contains(msg2))
		{
			messageFoundFlag2 = true;
		}

		system.assertEquals(messageFoundFlag1, true, 'Lookup ID is still in the search box.');
		system.assertEquals(messageFoundFlag2, true, 'Replacement ID is still in the search box.');

		Test.stopTest();
	}


    // ======================================================================================================================================= 
    // = TEST METHOD 4: 
    // ======================================================================================================================================= 
    @isTest static void test4() 
	{
		Test.setMock(HttpCalloutMock.class, new AH_RecordReferenceSearch_Mock());

		Test.startTest();

		PageReference pageRef = Page.AH_RecordReferenceSearch;
		Test.setCurrentPage(pageRef);

		AH_RecordReferenceSearch_Cntlr cntlr = new AH_RecordReferenceSearch_Cntlr();

		cntlr.inputObjName = 'Case';
		cntlr.SearchObject();

		ApexPages.currentPage().getParameters().put('id','Case');
		cntlr.retrieveAllFields();

		system.assertEquals(2, cntlr.fieldsOptionsList.size(), 'Fields count mismatch.');

		cntlr.selectedField = 'Status';
		cntlr.inputKeyword = 'Completed';
		cntlr.searchReferences();

		system.assertEquals(1, cntlr.mapOfValidationRule.size(), 'Validation rules count not found.');
		system.assertEquals(15, cntlr.workFlowIdNameList.size(), 'Workflow rules count mismatch.');

		Test.stopTest();
	}
}