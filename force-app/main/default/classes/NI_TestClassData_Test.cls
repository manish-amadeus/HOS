/****************************************************************************************
Name            : NI_TestClassData_Test Test Class
Author          : Sean Harris
Created Date    : 11/21/2012
Last Mod Date   : 03/22/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : test Class for NI_TestClassData Class
                : Updated 12/19/202 per NICC-047197
                : Updated 09/19/2018 per NICC-030091
                : 
******************************************************************************************/
@isTest //(SeeAllData=true)
private class NI_TestClassData_Test
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        Test.startTest();
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        Id rtId = NI_TestClassData.getRecordTypeId('Account', 'Parent Account');
        
        // CREATE TEST USERS
        List<User> lstUserInsert = new List<User>();
        User u1 = NI_TestClassData.createTestUser(1, 'System Administrator'); 
        u1.Alias = 'SA01TST'; 
        lstUserInsert.Add(u1); 
        User u2 = NI_TestClassData.createTestUser(2, 'NI Administrator'); 
        u2.Alias = 'EMP1TST'; 
        lstUserInsert.Add(u2);        
        User u3 = NI_TestClassData.createTestUser(3, 'NI Administrator'); 
        u3.Alias = 'MGR1TST'; 
        lstUserInsert.Add(u3);
        User u4 = NI_TestClassData.createTestUser(4, 'NI Administrator'); 
        u4.Alias = 'MGR2TST'; 
        lstUserInsert.Add(u4);        
        Database.insert(lstUserInsert); 
        
        List<User> lstUserAsserts = new List<User>([SELECT Id FROM User WHERE Alias IN ('SA01TST', 'EMP1TST', 'MGR1TST', 'MGR2TST')]);
        system.assertEquals(4, lstUserAsserts.Size());
        
        // CREATE TEST ACCOUNTS
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtParentAccountId = AccountRecordTypeInfo.get('Parent Account').getRecordTypeId();
        Id rtPropertyAccountId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();        
        
        List<Account> lstAccountInsert = new List<Account>();
        
        Account a1 = NI_TestClassData.createTestAccount(1);
        a1.Name = 'APEX TEST PARENT ACCOUNT 1';
        a1.RecordTypeId = rtParentAccountId;
        lstAccountInsert.Add(a1);
        Account a2 = NI_TestClassData.createTestAccount(2);
        a2.Name = 'APEX TEST PROPERTY ACCOUNT 1';
        a2.RecordTypeId = rtPropertyAccountId;
        lstAccountInsert.Add(a2);
        Account a3 = NI_TestClassData.createTestAccount(3);
        a3.Name = 'APEX TEST PROPERTY ACCOUNT 2';
        a3.RecordTypeId = rtPropertyAccountId;
        lstAccountInsert.Add(a3);        
        
        Database.insert(lstAccountInsert); 
        
        List<Account> lstAccountAsserts = new List<Account>([SELECT Id FROM Account WHERE Name LIKE 'APEX TEST %']);
        system.assertEquals(3, lstAccountAsserts.Size());

        Test.stopTest();
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1']; 
        
        // CREATE TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'APEXTESTUSER';
        cnt.LastName = 'APEXTESTUSER';
        insert cnt;
        
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
        insert pgp;

        // GET RECORDTYPE ID
        Schema.DescribeSObjectResult cfrSchema1 = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema1.getRecordTypeInfosByName(); 
        Id opptyRecTypeId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();
        
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.Name = 'APEX TEST OPPORTUNITY 1';
        o.RecordTypeId = opptyRecTypeId;
        insert o;
        
        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription');        
        insert prd;

        system.debug('END NI_TestClassData_Test.TestClassData1() - NUMBER OF QUERIES = ' + limits.getQueries());
        
    }


    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void TestClassData1() 
    {
        
        User u = [SELECT Id FROM User WHERE Alias = 'SA01TST']; 
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1']; 
        Product_Group__c pgp = [SELECT Id FROM Product_Group__c WHERE Name = 'APEX TEST']; 
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = 'APEX TEST OPPORTUNITY 1']; 
        Product2 prd = [SELECT Id FROM Product2 WHERE ProductCode = 'APEX-TEST-01'];        

        Asset asset = NI_TestClassData.createTestAsset(1, a.Id, prd.Id);
        asset.Product_Group__c = pgp.Id;
        insert asset;

        Attachment attach = NI_TestClassData.createTestAttachment(a.Id);
        attach.Name = 'APEX TEST ATTACHMENT';
        
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        insert c;
        
        Solution sol = NI_TestClassData.createSolution(1); 
        insert sol;

        CaseSolution csol = NI_TestClassData.createCaseSolution(c.Id, sol.Id);
        insert csol;

        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        insert cnt;

        Cluster__c mpeClust = NI_TestClassData.createMPECluster(1);
        
        CaseComment cc = NI_TestClassData.createTestCaseComment(1, c.Id);
        
        EmailMessage em = NI_TestClassData.createTestEmailMessage(1, c.Id, 'Joe Doe', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'Apex Test Email', 'Apex Test Email Body', '1');

        // GET RECORDTYPE ID
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Task; 
        Map<String, Schema.RecordTypeInfo> TaskRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id taskRecTypeId = TaskRecordTypeInfo.get('NI Support').getRecordTypeId();
                
        Task tsk = NI_TestClassData.createTestTask(1, u.Id, c.Id, taskRecTypeId, 'Call', 'Completed', 'Low');

        OpportunityContactRole ocr = NI_TestClassData.createTestOpportunityContactRole(o.Id, cnt.Id, 'Bill To'); 

        Pricebook2 pb2_OLD = NI_TestClassData.createTestPricebook('APEX TEST PRICEBOOK');
        insert pb2_OLD;

//        Pricebook2 pb2 = [SELECT id FROM Pricebook2 WHERE isStandard = true];
    
//        PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry(pb2.Id, prd.Id, 1000);
//        insert pbe;
        
        PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry(Test.getStandardPricebookId(), prd.Id, 1000);
        
        OpportunityLineItem oli = NI_TestClassData.createTestOpportunityLineItem(1, o.Id, pbe.Id, 1);

        Group grp = NI_TestClassData.createGroup('PUBLIC TEST GRP 1', 'PUBLICTESTGRP1', 'Regular'); 
        insert grp;
        
        GroupMember grpM = NI_TestClassData.createGroupMember(grp.Id, u.Id);

        NI_Change_Control__c nicc1 = NI_TestClassData.createNIChangeControl(1, 'APEX TEST');
        insert nicc1;
        
        NICC_Artifact__c art1 = NI_TestClassData.createArtifact(1, 'APEX TEST', nicc1.Id, 'Communication Plan');

        NI_Customization_Service__c hrms1 = NI_TestClassData.createTestHRMService(1, a.Id, 'Active', 4, 10, 6);

        NI_Customization_Detail__c hrmd1 = NI_TestClassData.createTestHRMCustomization (1, a.Id, c.Id);

        NI_CustomizationDetailToService__c wha1 = NI_TestClassData.createTestWorkHourAllocation(a.Id, c.Id, hrmd1.Id, hrms1.Id);     

        NI_DI_Reference__c dir = NI_TestClassData.createTestNI_DI_Reference(1, pgp.Id, prd.Id);
        
        Id rtInit = NI_TestClassData.getRecordTypeId('NI_Org_Details__c', 'HRM Support Admin');       
        NI_Org_Details__c od = NI_TestClassData.createTestNiOrgDetails(rtInit, 1, 'Salesforce Production');
        
        NI_Org_Details_to_Accounts__c O2A = NI_TestClassData.createTestNIOrgDetails2Accounts(od.Id, a.Id); 

        NI_Org_Details_To_Accounts__C O2Ab = NI_TestClassData.CreateOrgDetailAccount(od.Id, a.Id); 
       
        newmarketsvcs__IServer__c nwsSys = NI_TestClassData.CreateTestNWS_IServer(1, 'Org.' + String.ValueOf(od.Id) + '@Delphi.fdc');
        insert nwsSys;
        
        newmarketsvcs__Location__c nwsLoc = NI_TestClassData.createTestNWS_Location(1, nwsSys.Id, a.Id);

        Marketing_Qualified_Lead__c mql = NI_TestClassData.createTestMarketingQualifiedLead(cnt.Id);
        insert mql;
                
        newmarketsvcs__Location__c nwsl = NI_TestClassData.createTestNewmarketsvcsLocation(1);
        
        newmarketsvcs__Notification__c nwsn = NI_TestClassData.createTestNewmarketsvcsNotification(1, nwsl.id, 'Error');
        
        NI_Trust__c objT1 =  NI_TestClassData.createTestNITrust('Delphi as a Service (DaaS)', 1);
        
        //NI_Trust_Outage__c objTO1 = NI_TestClassData.createTestNITrustOutage(objT1.Id, DateTime.Now(), DateTime.Now(), 1);
        NI_Trust_Outage__c objTO1 = NI_TestClassData.createTestNITrustOutage(objT1.Id, DateTime.Now(), DateTime.Now(), 1, DateTime.Now().date(), '10:00', DateTime.Now().addDays(1).date(), '18:00');
                
        Expense_Report__c er = NI_TestClassData.createTestSalesExpenseReport(1);

        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        insert vrs01;
        
        SFDC_CSP_Part__c prt01 = NI_TestClassData.createPart(prd.Id, vrs01.Id, 1);
        insert prt01;
        
        SFDC_CSP_Development_Request__c cr01 = NI_TestClassData.createChangeRequest(pgp.Id, vrs01.Id, prt01.Id, 1);

        system.debug('END NI_TestClassData_Test.TestClassData1() - NUMBER OF QUERIES = ' + limits.getQueries());
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 2: TEST ICE 
    // ======================================================================================================================================= 
    @isTest static void testICE() 
    {
        
        Account iceAcct = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1']; 
        
        NI_Change_Control__c nicc = NI_TestClassData.createNIChangeControl(1, 'APEX TEST - ' + String.ValueOf(DateTime.Now()));
        insert nicc;
        
        NICC_Risk_Setup__c niccRskSU = NI_TestClassData.createNICCRiskSetup('RISK DESC', 'HRM', 1, 1); 
        insert niccRskSU;
        
        System.assertNotEquals(nicc.Id, null);
        
        NICC_Risk__c niccRsk = NI_TestClassData.createNICCRisk('RISK DESC', 'HRM', true, false, false, false, nicc.Id, 1, 1);     
        insert niccRsk;

        system.debug('END NI_TestClassData_Test.TestClassData2() - NUMBER OF QUERIES = ' + limits.getQueries());
        
    }
/*    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: 
    // ======================================================================================================================================= 
    @isTest static void TestClassData3()
    { 
        
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = 'APEX TEST OPPORTUNITY 1'];
        
        //CREATE A TEST PSA REGION  
        pse__Region__c defaultRegion =  NI_TestClassData.createTestRegion(1, 'psaTestRegion');
        insert defaultRegion; 
        
        //CREATE A TEST PSA PRACTICE  
        pse__Practice__c defaultPractice = NI_TestClassData.createTestPractice(1, 'psaTestPractice');
        insert defaultPractice;  
        
        //CREATE A PROJECT
        pse__Proj__c tp0 = NI_TestClassData.createTestProject(2,'Assignment/Milestone Date Test Project', defaultRegion, defaultPractice, 'Draft', o);
        pse__Proj__c tp = NI_TestClassData.createTestProject(1,'Assignment/Milestone Date Test Project', defaultRegion, defaultPractice, 'Draft', null);
        insert tp;

        // CREATE A TEST MILESTONE  
        pse__Milestone__c milestone = NI_TestClassData.createTestMilestone('PSA Test Milestone', tp, false, false, 'Billable Milestone');
        insert milestone;  
        
        //CREATE A TEST MILESTONE FORECAST 
        Milestone_Forecast__c msForecast = NI_TestClassData.createTestMilestoneForecast(milestone); 
        
        Milestone_Batch_Generation__c mbg = NI_TestClassData.createPSEMilestoneBatchGen(Id ProjectId, Id productPackageId)
        
        system.debug('END NI_TestClassData_Test.TestClassData3() - NUMBER OF QUERIES = ' + limits.getQueries());
        
  }
*/    
    // ======================================================================================================================================= 
    // = TEST METHOD 4: 
    // ======================================================================================================================================= 
    @isTest static void TestClassData4()
    {        

        User u = [SELECT Id FROM User WHERE Alias = 'SA01TST'];
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1']; 
        Product_Group__c pgp = [SELECT Id FROM Product_Group__c WHERE Name = 'APEX TEST']; 
        Opportunity opp1 = [SELECT Id FROM Opportunity WHERE Name = 'APEX TEST OPPORTUNITY 1']; 
        Contact cnt = [SELECT Id FROM Contact WHERE FirstName = 'APEXTESTUSER' AND LastName = 'APEXTESTUSER']; 
        Product2 prd = [SELECT Id FROM Product2 WHERE ProductCode = 'APEX-TEST-01'];  
        
        Asset asset = NI_TestClassData.createTestAsset(1, a.Id, prd.Id);
        asset.Product_Group__c = pgp.Id;
        insert asset;

        NI_License_Audit__c NI_LicAud = NI_TestClassData.createTestNiLicenseAudit(a.Id, asset.Id); 
        
        NI_Customer_Relations_Engagement__c ni_cr_engagemnt = NI_TestClassData.createCustomerRelationsEngagement(1, a.Id, cnt.Id);
        insert ni_cr_engagemnt;

        //CREATE A TEST SOFTRAX ORDER LINE RECORD  
        Softrax_Order_Line__c sol = NI_TestClassData.createStxOrderLines(1, opp1.Id);
        insert sol;
        
        //CREATE A TEST ACCOUNT PLAN RECORD  
        SFDC_Acct_Plan__c apln = NI_TestClassData.createAccountPlan(1, a.Id);
        insert apln;
        
        //CREATE A TEST STRATEGY RECORD  
        SFDC_Strategy__c stgy = NI_TestClassData.createStrategy(1, a.Id, apln.Id);
        insert stgy;        
        
        //CREATE A TEST DI INDEX RECORD  
        NI_DeploymentInstanceIndex__c diIdx = NI_TestClassData.createDI_Index(1, 'APEX TEST');
        insert diIdx;
        
        // CREATE DI INDEX RECORD
        Note nte = NI_TestClassData.createNote(1, opp1.Id);
        insert nte;

        Billing_Contract__c blgCnrct = NI_TestClassData.createBillingContract(1);
        insert blgCnrct;

        Activity_Line_Item__c actLI = NI_TestClassData.createActivityLineItem(blgCnrct.Id);
                
        Billing_Contract_Line_Item__c bcli = NI_TestClassData.createBillingContract(blgCnrct.Id, actLI.Id);
                    
        Product2 prd2 = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-02', 'Subscription');        
        insert prd2;
        
        AH_Product_Migration__c pm = NI_TestClassData.createProductMigration(a.Id, opp1.Id, prd.Id, prd2.Id);

        system.debug('END NI_TestClassData_Test.TestClassData4() - NUMBER OF QUERIES = ' + limits.getQueries());
        
    }
                  
    // ======================================================================================================================================= 
    // = TEST METHOD 5: 
    // ======================================================================================================================================= 
    @isTest static void testEmpPerfEvals()
    {    

        User Employee = [SELECT Id FROM User WHERE Alias = 'EMP1TST']; 
        User ManagerId = [SELECT Id FROM User WHERE Alias = 'MGR1TST']; 
        User CoManagerId = [SELECT Id FROM User WHERE Alias = 'MGR2TST'];  

        // CREATE A TEST SUPPORT TIER DESIGNATION RECORD
        Support_Tier_Designation__c sptdesg = NI_TestClassData.createSupportTierDesignation(1, ManagerId.Id, 'Level 1 Support');
        insert sptdesg;
        
        // CREATE A Employee Performance Evaluation RECORD
        NI_Employee_Performance_Evaluation__c perfEval = NI_TestClassData.createEmployee_Performance_Evaluation(ManagerId.Id, CoManagerId.Id);   
        perfEval.OwnerId = Employee.Id;
        perfEval.Employee_Name__c = Employee.Id;
        insert perfEval;
        
        // CREATE A ASSESSMENT RECORD
        NI_PE_Assessment__c perfEvalAssmnt = NI_TestClassData.createPerfEvalAssessment(perfEval.Id);    
        insert perfEvalAssmnt;
        
        // CREATE A CAREER PATH RECORD
        NI_Career_Path__c perfEvalPath = NI_TestClassData.createPerfEvalCareerPath(perfEval.Id);     
        insert perfEvalPath;
        
        // CREATE A EVAL GOAL RECORD
        NI_PerfEval_Goals__c perfEvalGoal = NI_TestClassData.createPerfEvalGoals(perfEval.Id);       
        insert perfEvalGoal;
        
        // CREATE NI DEPARTMENT RECORD  
        NI_Departments__c d = NI_TestClassData.createTestNI_Department(1);
        insert d;
        
        // CREATE NI LOCATION RECORD  
        NI_Location__c l = NI_TestClassData.createTestNI_Location(1);
        insert l;

        // CREATE NI DEPARTMENT TO LOCATION RECORD  
        NI_Department_to_Location__c d2l = NI_TestClassData.createTestNI_DepartmentToLocation(1, d.Id, l.Id, ManagerId.Id, 'Exec Member');
        insert d2l;        
        
        NI_Office__c o = NI_TestClassData.createTestNI_Office(1);
        insert o;

        system.debug('END NI_TestClassData_Test.testEmpPerfEvals() - NUMBER OF QUERIES = ' + limits.getQueries());
        
    }
      
    // ======================================================================================================================================= 
    // = TEST METHOD 6: 
    // ======================================================================================================================================= 
    @isTest static void testAgreements()
    { 
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1']; 
        Opportunity opp1 = [SELECT Id FROM Opportunity WHERE Name = 'APEX TEST OPPORTUNITY 1']; 
        Product2 prd = [SELECT Id FROM Product2 WHERE ProductCode = 'APEX-TEST-01'];  

        //CREATE A TEST VENDOR AGREEMENT RECORD
        NI_Vendor_Agreement__c va = NI_TestClassData.createTestVendorAgreement(1);
        va.Royalty_Distribution_Trigger__c = 'Installed';
        insert va;

        //CREATE A TEST CUSTOMER AGREEMENT RECORD
        NI_Customer_Agreement__c ca  = NI_TestClassData.createTestCustomerAgreement(opp1.Id, prd.Id, a.Id, va.Id);
        ca.Royalty_Distribution_Trigger__c = 'Installed';
        ca.Discount__c = 20;
        insert ca;

        Id pricebookId = Test.getStandardPricebookId();
        
        // CREATE TEST APTTUS AGREEMENT
        Apttus__APTS_Agreement__c apt1 = NI_TestClassData.createTestApttusAgreement(1, a.Id, opp1.Id, pricebookId);
        insert apt1; 
        
        // CREATE TEST APTTUS AGREEMENT LINE ITEMS
        Apttus__AgreementLineItem__c ali1 = NI_TestClassData.createTestAgreementLineItem('Delphi - New Installation', 1, 1, apt1.Id, prd.Id);
        insert ali1;         
        
        system.debug('END NI_TestClassData_Test.testAgreements() - NUMBER OF QUERIES = ' + limits.getQueries());
                
    }    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 7: TEST IT HARDWARE AND SOFTWARE
    // ======================================================================================================================================= 
    @isTest static void testITHardwareSoftware()
    {    
        
        User u = [SELECT Id FROM User WHERE Alias = 'SA01TST']; 
        Product_Group__c pgp = [SELECT Id FROM Product_Group__c WHERE Name = 'APEX TEST']; 
        Product2 prd2 = [SELECT Id FROM Product2 WHERE ProductCode = 'APEX-TEST-01'];  
        
        Date myDate = Date.newInstance(2015, 1, 1);
        AIP_GDS_Monthly_Revenue__c AIP_GDS1 = NI_TestClassData.createAIP_GDS_MonthlyRevenue(1, myDate); 
        
        IT_Hardware_Model__c IT_HWM = NI_TestClassData.createITHardwareModel(1); 

        NI_Product_Release__c prdRel = NI_TestClassData.createTestNI_Product_Release(pgp.Id, u.Id, 101);
        insert prdRel;

        IT_Hardware_Asset__c IT_HWA = NI_TestClassData.createITHardwareAsset(1, prd2.Id); 
        
        IT_Software_Package__c IT_SWP = NI_TestClassData.createITSoftwarePackage(1); 
        insert IT_SWP;
        
        IT_Software_Asset__c IT_SWA = NI_TestClassData.createITSoftwareAsset(1, IT_SWP.Id); 

        system.debug('END NI_TestClassData_Test.testITHardwareSoftware() - NUMBER OF QUERIES = ' + limits.getQueries());
        
    }  
    
    // ======================================================================================================================================= 
    // = TEST METHOD 7: TEST SCMC THAT CLD CREATED
    // ======================================================================================================================================= 
    @isTest static void testSCMC()
    {  

        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1']; 
        NI_TestClassData.createSCMCurrency();
        SCMC__ICP__c v1 = NI_TestClassData.createICP('APEX TEST ICP');
        insert v1;
        SCMC__Warehouse__c v2 = NI_TestClassData.createWarehouse('APEX TEST WAREHOUSE', v1.Id);
        insert v2;
        SCMC__Supplier_Site__c v3 = NI_TestClassData.createSupplierSite('APEX TEST SUPPLIER SITE', a.Id);
        insert v3;
        SCMC__Requisition__c v4 = NI_TestClassData.createRequisition(v2.Id, v3.Id);
        insert v4;
        // GET RECORDTYPE ID
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.SCMC__Requisition_Line_Item__c; 
        Map<String, Schema.RecordTypeInfo> RequisitionLineItemRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id RecTypeId = RequisitionLineItemRecordTypeInfo.get('Capital Equipment').getRecordTypeId();        
        SCMC__Requisition_Line_Item__c v5 = NI_TestClassData.createRequisitionLines(v2.Id, v3.Id, v4.Id, RecTypeId);
        
        system.debug('END NI_TestClassData_Test.testSCMC() - NUMBER OF QUERIES = ' + limits.getQueries()); 
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 8: TEST CHANNEL_ORDERS THAT SUZANNE CREATED
    // ======================================================================================================================================= 
    @isTest static void testChannelOrders()
    {  
        CHANNEL_ORDERS__Customer__c v1 = NI_TestClassData.CreateCustomer('00D00000000abce');
        CHANNEL_ORDERS__Partner_Contract_Terms__c contractTerms = NI_TestClassData.CreateContract();
        insert contractTerms;
        CHANNEL_ORDERS__Partner_Product_Catalog__c v2 = NI_TestClassData.CreateProductCatalog(contractTerms.Id, 'APEX-TEST-01');
        CHANNEL_ORDERS__Partner_Product_Catalog__c v3 = NI_TestClassData.CreateProductCatalog(contractTerms.Id, 'APEX-TEST-EMD-01');
        CHANNEL_ORDERS__Partner_Contract_Terms__c v4 = NI_TestClassData.CreateContract();
        CHANNEL_ORDERS__Service_Order__c v5 = NI_TestClassData.createTestCO_ServiceOrder(); 
        
        system.debug('END NI_TestClassData_Test.testChannelOrders() - NUMBER OF QUERIES = ' + limits.getQueries()); 
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 9: TEST MISCELLANEOUS NI_TestClassData FUNCTIONS
    // ======================================================================================================================================= 
    @isTest static void testMisc1()
    {  
        User u = [SELECT Id FROM User WHERE Alias = 'SA01TST']; 
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1']; 
        Product_Group__c pgp = [SELECT Id FROM Product_Group__c WHERE Name = 'APEX TEST']; 
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = 'APEX TEST OPPORTUNITY 1']; 
        Product2 prd = [SELECT Id FROM Product2 WHERE ProductCode = 'APEX-TEST-01'];   
        
        // GET RECORDTYPE ID
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.NI_Job_Requisition__c; 
        Map<String, Schema.RecordTypeInfo> JobRequisitionRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id JobReqRecTypeId = JobRequisitionRecordTypeInfo.get('Standard').getRecordTypeId();   
        
        NI_Job_Requisition__c v1 = NI_TestClassData.createTestNI_Job_Requisition(1, u.Id, JobReqRecTypeId);  
        AIP_Transactions__c v2 = NI_TestClassData.createAIPTransaction(o.Id); 
        Market__c v3 = NI_TestClassData.createAIPMarket(1); 
        NI_Invoice__c v4 = NI_TestClassData.createTestNI_Invoice ('300000', a.Id, 1); 
        insert v4;
        NI_Invoice_Detail__c v5 = NI_TestClassData.createTestNI_InvoiceDetail (v4.Id, prd.Id); 
        
        NI_Sprint__c niSprnt = NI_TestClassData.createSprint('sprintName');
        
        NI_Project_Backlog__c niBkLog = NI_TestClassData.createTestProjectBacklog(1);
            
        NI_Global_Acceptance_Criterion__c niGAC = NI_TestClassData.createTestGAC(1, 'Account');
        insert niGAC;
        
        NI_Project_Acceptance_Criterion__c niPAC = NI_TestClassData.createTestPAC(1, niGAC.Id, 'Account');
            
        SFDC_CSP_Flash_Message__c flshMsg = NI_TestClassData.createFlashMessage(a.Id);
        
        NI_Cancellation__c newCxl = NI_TestClassData.createCancellation(a.Id);

        PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry(Test.getStandardPricebookId(), prd.Id, 1000);
        insert pbe;
        
        OpportunityLineItem oli = NI_TestClassData.createTestOpportunityLineItem(11, o.Id, pbe.Id, 1);
        insert oli;
        
        Subscription_Activation__c subAct = NI_TestClassData.createSubscriptionActivation();
        subAct.Opportunity__c = o.Id;
        subAct.Product_ID__c = oli.Id;
        insert subAct; 
    
        Subscription_Activation_Transaction__c subAT = NI_TestClassData.createSubscriptionActivationTransaction(subAct.Id);
        
        // CREATE A TEST FILE RECORD        
        ContentVersion cv = NI_TestClassData.createContentVersion();
        insert cv;
        
        ContentVersion cv2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id LIMIT 1];
        List<ContentDocument> lstCDocs = new List<ContentDocument>([SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument]);   
        
        ContentDocumentLink cl = NI_TestClassData.createContentDocumentLink(cv2.ContentDocumentId, a.Id);
        insert cl;
        
        system.assertEquals(1, lstCDocs.size());
        system.assertEquals(cv2.ContentDocumentId, lstCDocs[0].Id);
        system.assertEquals(cv2.Id, lstCDocs[0].LatestPublishedVersionId);
        system.assertEquals(cv2.Title, lstCDocs[0].Title);
        system.assertEquals(cv2.ContentDocumentId, cl.ContentDocumentId);           


        Partners_Form_Template__c pft = NI_TestClassData.createPartnersFormTemplate();
        insert pft;
    
        Partners_Form_Template_to_Account__c pft2a = NI_TestClassData.createPartnersFormTemplate2Account(pft.Id, a.Id);

        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        
        AH_Case_Flags_Store_Types__c cfst = NI_TestClassData.createCaseFlageStoreType();
        
        NI_Trust_Outage_Email__c toe = NI_TestClassData.createNITrustOutageCustomSettings();
        
        system.debug('END NI_TestClassData_Test.testMisc1() - NUMBER OF QUERIES = ' + limits.getQueries()); 
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: TEST PSE FUNCTIONS
    // ======================================================================================================================================= 
    @isTest static void testPSECustoms()
    {  
        
        // LOAD TEST RECORDS CREATED IN createTestData() FUNCTION
        User u = [SELECT Id FROM User WHERE Alias = 'SA01TST']; 
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1']; 
        Product2 p2 = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode = 'APEX-TEST-01'];   
        Contact c = [SELECT Id FROM Contact WHERE FirstName = 'APEXTESTUSER' AND LastName = 'APEXTESTUSER'];

        // CREATE A TEST PSA SCHEDULE  
        Date dt = system.date.today(); 
        pse__Schedule__c sched = NI_TestClassData.createTestSchedule(dt.addDays(1), dt.addDays(2));
        insert sched;
        
        // CREATE A TEST PSA REGION  
        pse__Region__c reg = NI_TestClassData.createTestRegion(1, 'Test Region');
        insert reg;
        
        // CREATE A TEST PSA PRACTICE  
        pse__Practice__c pract = NI_TestClassData.createTestPractice(1, 'Test Practice');
        insert pract;

        // CREATE A TEST PSA PROJECT
        pse__Proj__c proj = NI_TestClassData.createTestProject(1, 'Test Project', reg, pract, 'Draft', null);
        proj.pse__Allow_Timecards_Without_Assignment__c = true;
        proj.pse__Allow_Expenses_Without_Assignment__c = true;  
        proj.pse__Closed_for_Expense_Entry__c = false;
        proj.pse__Closed_for_Time_Entry__c = false;
        insert proj;
        
        // CREATE A TEST WORK CALENDAR  
        pse__Work_Calendar__c wc = NI_TestClassData.createTestWorkCalendar('Test Work Calendar');
        insert wc;
        
        // CREATE A TEST GROUP
        pse__Grp__c grp = NI_TestClassData.createTestPSEGroup('Test Group');
        insert grp;   
        
        // CREATE A TEST MILESTONE  
        pse__Milestone__c ms = NI_TestClassData.createTestMilestone('PSA Test Milestone', proj, false, false, 'Billable Milestone');
        ms.pse__Closed_for_Expense_Entry__c = false;
        insert ms; 

        // CREATE A TEST MILESTONE (WITH NO ALI)
        pse__Milestone__c msNoALI = NI_TestClassData.createTestMilestoneNoALI('PSA Test Milestone 2', proj, true, true, 'Billable Milestone');        
        
        // UPGRADE CONTACT TO A PSE RESOURCE
        c.pse__Region__c = reg.Id;
        c.pse__Practice__c = pract.Id;
        c.pse__Work_Calendar__c = wc.Id;
        c.pse__Group__c = grp.Id;
        c.pse__Is_Resource_Active__c = true;
        c.pse__Is_Resource__c = true;
        c.pse__Salesforce_User__c = u.Id;
        update c;        

        // CREATE PERMISSION CONTROL RECORDS
        List<pse__Permission_Control__c> lstPermissionControls = new List<pse__Permission_Control__c>();
        
        // GIVE RUNNING USER THE PERMISSION TO CREATE TIMECARD ENTRIES & EXPENSE REPORTS FOR TEST RESOURCE CONTACT
        pse__Permission_Control__c pm1 = NI_TestClassData.createTestPermissionControl(UserInfo.getUserId());
        pm1.pse__Resource__c = c.Id;   
        pm1.pse__Staffing__c = true; 
        pm1.pse__Timecard_Entry__c = true; 
        pm1.pse__Expense_Entry__c = true; 
        lstPermissionControls.add(pm1);   
        
        // GIVE RUNNING USER THE PERMISSION AS CENTRAL EXPENSE APPROVER FOR THE TEST REGION
        pse__Permission_Control__c pm2 = NI_TestClassData.createTestPermissionControl(UserInfo.getUserId());
        pm2.pse__Region__c = reg.Id;        
//        pm2.pse__Staffing__c = true; 
//        pm2.pse__Timecard_Entry__c = true; 
//        pm2.pse__Expense_Entry__c = true;
        pm2.pse__Billing__c = true;
        pm2.pse__Cascading_Permission__c = true;
        pm2.pse__Expense_Entry__c = true;
        pm2.pse__Expense_Ops_Edit__c = true;
        pm2.pse__Forecast_Edit__c = true;
        pm2.pse__Forecast_View__c = true;
        pm2.pse__Invoicing__c = true;
        pm2.pse__Edit_Task_Manager__c = true;
        pm2.pse__View_Task_Manager__c = true;
        pm2.pse__Compare_Project_Version__c = true;
        pm2.pse__Create_Project_Version__c = true;
        pm2.pse__Delete_Project_Version__c = true;
        pm2.pse__Resource_Request_Entry__c = true;
        pm2.pse__Skills_And_Certifications_Entry__c = true;
        pm2.pse__Skills_And_Certifications_View__c = true;
        pm2.pse__Staffing__c = true;
        pm2.pse__Team_Create__c = true;
        pm2.pse__Team_Edit__c = true;
        pm2.pse__Team_View__c = true;
        pm2.pse__Timecard_Entry__c = true;
        pm2.pse__Timecard_Ops_Edit__c = true;
        lstPermissionControls.add(pm2);

        database.insert(lstPermissionControls);

    
        system.debug(' *** NI_TestClassData_Test.testPSECustoms() - BEFORE Test.StartTest(): NUMBER OF QUERIES = ' + limits.getQueries());

Test.StartTest();
                       
        system.assertEquals(false, proj.pse__Closed_for_Expense_Entry__c);

        List<pse__Permission_Control__c> lstPMAssert = new List<pse__Permission_Control__c>(
            [SELECT Id 
             FROM pse__Permission_Control__c 
             WHERE pse__User__c =: UserInfo.getUserId() 
             AND pse__Resource__c =: c.Id]);
        system.assertEquals(1, lstPMAssert.size());        

        // CREATE A TEST PSE ASSIGNMENT
        pse__Assignment__c assmnt = NI_TestClassData.createTestAssignment(c.Id, sched.Id, proj.Id);
        assmnt.pse__Milestone__c = ms.Id;
        insert assmnt;        

        pse__Billing_Event_Batch__c beb = NI_TestClassData.createTestBillingEventBatch();
        insert beb;
        
        pse__Billing_Event__c be = NI_TestClassData.createTestBillingEvent(beb.Id, proj.Id);
        insert be;
        
        pse__Billing_Event_Item__c bei = NI_TestClassData.createTestBillingEventItem(beb.Id, be.Id, proj.Id, ms.Id);
        bei.Reverse_Softrax_Invoicing__c = true;
        insert bei;

        pse__Miscellaneous_Adjustment__c madj = NI_TestClassData.createMiscellaneousAdjustment('Test Adjust', proj.Id);
        insert madj;  
        
        // SOMETHING SETS THIS VALUE TO True
        proj.pse__Closed_for_Time_Entry__c = false;
        update proj;

        // CREATE TEST TIMECARD HEADER
        pse__Timecard_Header__c tch = NI_TestClassData.createTimecardHeader(proj.Id, ms.Id, assmnt.Id, c.Id, dt.addDays(1), dt.addDays(7));
        insert tch;

        // AMADEUS CUSTOM
        Milestone_Forecast__c msForecast = NI_TestClassData.createTestMilestoneForecast(ms); 
        
        // AMADEUS CUSTOM
        PSA_Product_Package__c pp = NI_TestClassData.createPSAProductPackage();
        insert pp;

        // AMADEUS CUSTOM
        Milestone_Batch_Generation__c mbg = NI_TestClassData.createPSEMilestoneBatchGen(proj.Id, pp.Id);
            
        system.debug(' *** NI_TestClassData_Test.testPSECustoms() - BEFORE Test.StopTest(): NUMBER OF QUERIES = ' + limits.getQueries());
        
Test.StopTest();        
        
        // ASSERT TIMECARD TEST RECORD WAS AUTO-CREATED
        List<pse__Timecard__c> lstTimecardAsserts = new List<pse__Timecard__c>(
            [SELECT Id, Name, pse__Revenue_Transaction__c, pse__Status__c, pse__Submitted__c, pse__Approved__c, pse__Include_In_Financials__c
             FROM pse__Timecard__c 
             WHERE pse__Timecard_Header__c =: tch.Id
            ]);       
        system.assertEquals(1, lstTimecardAsserts.size());
                
        // UPDATE TIMECARD TO APPROVED TO CREATE RELATED TEST pse__Transaction__c RECORDS 
        lstTimecardAsserts[0].pse__Status__c = 'Approved';
        lstTimecardAsserts[0].pse__Submitted__c = true;
        lstTimecardAsserts[0].pse__Approved__c = true;
        lstTimecardAsserts[0].pse__Include_In_Financials__c = true;
        database.update(lstTimecardAsserts);
  
        // ASSERT pse__Transaction__c WAS CREATED
        List<pse__Transaction__c> lstTransactionAsserts = new List<pse__Transaction__c>([
            SELECT Id, Name, pse__Related_Record_Deleted__c
            FROM pse__Transaction__c
            WHERE pse__Timecard__c =: lstTimecardAsserts[0].Id 
            AND pse__Type__c = 'Timecard' 
            AND pse__Category__c = 'Ready-to-Bill Revenue'
        ]);
        system.assertEquals(1, lstTransactionAsserts.size());
        system.assertEquals(true, lstTransactionAsserts[0].pse__Related_Record_Deleted__c); 
        
        reg.Central_Expense_Approver__c = u.Id;
        update reg;
        
        assmnt.pse__Milestone__c = null;
        update assmnt;
        
        // CREATE A TEST PSE EXPENSE REPORT 
        pse__Expense_Report__c xRpt = NI_TestClassData.createPSEExpenseReport(c.Id, proj.Id); 
        xRpt.Name = 'Test External Expense'; 
        xRpt.pse__Assignment__c = assmnt.Id; 
        insert xRpt; 
        
        system.debug('END NI_TestClassData_Test.testPSECustoms() - NUMBER OF QUERIES = ' + limits.getQueries()); 
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 2: TEST FFA FUNCTIONS
    // ======================================================================================================================================= 
    @isTest static void testFFACustoms()
    {      
        
        // LOAD TEST RECORDS CREATED IN createTestData() FUNCTION
        User u = [SELECT Id FROM User WHERE Alias = 'SA01TST']; 
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1']; 
        Product2 p2 = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode = 'APEX-TEST-01'];   
        Contact c = [SELECT Id FROM Contact WHERE FirstName = 'APEXTESTUSER' AND LastName = 'APEXTESTUSER'];
        Date dt = system.date.today();        

        // UPDATE ACCOUNT WITH REQUIRED FFA FIELDS      
        a.c2g__CODAAccountTradingCurrency__c = 'USD'; 
        a.c2g__CODATaxCalculationMethod__c = 'Gross';
        update a;
        
        // GET RUNNING USER RECORD
        User ru = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        // CREATE TEST COMPANY
        c2g__codaCompany__c co = NI_TestClassData.createFFACompany('APEX ACME COMP', ru, true);
        insert co;
        
        // ADD USER RUNNING TEST TO THE TEST COMPANY
        c2g__codaUserCompany__c uCo = NI_TestClassData.createFFAUserCompany(co.Id, ru.Id);
        insert uCo;  
              
//        system.assertEquals('APEX ACME CO', c2g.CODAAPICompany_2_0.GetCurrentCompanies(null)[0]);
        
        Group q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'APEX ACME COMP' LIMIT 1];
        c2g__codaYear__c yr = NI_TestClassData.createFFAYear(String.valueOf(Date.today().year()), co.Id, q.Id);
        insert yr;
        c2g.CODAYearWebService.calculatePeriods(yr.Id);
        
        c2g__codaPeriod__c prd = NI_TestClassData.createFFAPeriod('APEX_TEST', co.Id, yr.Id);
        
        c2g__codaAccountingCurrency__c ac = NI_TestClassData.createFFAAccountingCurrency('USD', co.Id, q.Id);
        insert ac;        
        
        c2g__codaExchangeRate__c exrt = NI_TestClassData.createFFAcodaExchangeRate(co.Id, ac.Id);
        
        ffrr__RecognitionYear__c ry = NI_TestClassData.createRecognitionYear(Date.Today());
        insert ry;
    
        ffrr__RecognitionPeriod__c rp = NI_TestClassData.createRecognitionPeriod(Date.Today(), ry.Id);
        
        Remittance_Info__c rmi = NI_TestClassData.createRemittanceInfo('Test Remittance Info');
        
        Test.StartTest();
                
        ffrr__Settings__c ffrrS = NI_TestClassData.createSettings();
        insert ffrrS;
        
        ffrr__Template__c ffrrT = NI_TestClassData.createffrrTemplate(ffrrS.Id);
        insert ffrrT;
        
        ffrr__ForecastScheduleDefinition__c fsd = NI_TestClassData.createForecastScheduleDefinition();
        insert fsd;
        
        ffrr__FieldMappingDefinition__c fmd = NI_TestClassData.createFieldMappingDefinition();
        insert fmd;
        
        ffrr__FieldMapping__c fmp = NI_TestClassData.createFieldMapping(fmd.Id);
        insert fmp;
        
        // THIS TEST CAUSES FOLLOWING ERROR:
        // FIELD_CUSTOM_VALIDATION_EXCEPTION, Object validation has failed. Integration Rule: Object validation has failed. 
        // You cannot specify target or source master objects without creating at least one field mapping line.: []
//        c2g__codaIntegrationRule__c irl = NI_TestClassData.createIntegrationRule();
//        insert irl;
        
//        c2g__codaIntegrationRuleLineItem__c irli = NI_TestClassData.createIntegrationRuleLineItem(irl.Id, 1);
//        insert irli;
        
        // INSERT TEST DIMENSIONS
        c2g__codaDimension1__c dim1 = NI_TestClassData.createTestDimension1();
        insert dim1;
        
        c2g__codaDimension2__c dim2 = NI_TestClassData.createTestDimension2();
        insert dim2;
        
        c2g__codaDimension3__c dim3 = NI_TestClassData.createTestDimension3();
        insert dim3;
        
        c2g__codaDimension4__c dim4 = NI_TestClassData.createTestDimension4();
        insert dim4;
        
        c2g__codaGeneralLedgerAccount__c gla = NI_TestClassData.createGeneralLedgerAccount('GLA NAME');
        insert gla;
        
        c2g__codaInvoice__c sin = NI_TestClassData.createSalesInvoice(a.Id, dt, 100, dim1.Id, dim2.Id, dim3.Id, dim4.Id);
        insert sin;
        
        c2g__codaInvoiceLineItem__c sinli = NI_TestClassData.createSalesInvoiceLineItem(p2.Id, 100, sin.Id, dim1.Id, dim2.Id, dim3.Id, dim4.Id);
        insert sinli;
        
        // THIS TEST CAUSES FOLLOWING ERROR:
        // FIELD_CUSTOM_VALIDATION_EXCEPTION, Integration rule Map Analysis fields from Invoice to Credit Note not found.: []
        c2g__codaCreditNote__c cn = NI_TestClassData.createCreditNote(a.Id, dt, 100, sin.Id, dim1.Id, dim2.Id, dim3.Id, dim4.Id);
//        insert cn;
        
        c2g__codaCreditNoteLineItem__c cnli = NI_TestClassData.createCreditNoteLineItem(p2.Id, 100, cn.Id, dim1.Id, dim2.Id, dim3.Id, dim4.Id);
//        insert cnli;
        
        Payment_Terms__c pyTrms = NI_TestClassData.createInvoicePaymentTerms();
        insert pyTrms;
        
        Payment_Term_Line_Item__c pyTrmsLI = NI_TestClassData.createInvoicePaymentTermsLimeItem(pyTrms.Id);
        
        c2g__codaIntegrationRule__c iRl = NI_TestClassData.createIntegrationRule();
//        insert iRl;
                
//        c2g__codaIntegrationRuleLineItem__c irli = NI_TestClassData.createIntegrationRuleLineItem(iRl.Id, 1);
        
        Test.StopTest();
        
        system.debug('END NI_TestClassData_Test.testFFACustoms() - NUMBER OF QUERIES = ' + limits.getQueries()); 
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 20: TEST FINANCE REQUEST AND RELATED NI_TestClassData FUNCTIONS
    // ======================================================================================================================================= 
    @isTest static void testMisc20()
    {  
        Test.startTest();
        
        // GET A TEST ACCOUNT
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1'];
        
        // UPDATE ACCOUNT WITH REQUIRED FFA FIELDS      
        a.c2g__CODAAccountTradingCurrency__c = 'USD'; 
        a.c2g__CODATaxCalculationMethod__c = 'Gross';
        update a;
        
        // CREATE FFA SETUP RECORDS ===========================================================================
        
        // GET RUNNING USER RECORD
        User ru = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        
        // CREATE TEST COMPANY
        c2g__codaCompany__c co = NI_TestClassData.createFFACompany('APEX ACME COM', ru, true);
        insert co;
        
        // ADD USER RUNNING TEST TO THE TEST COMPANY
        c2g__codaUserCompany__c uCo = NI_TestClassData.createFFAUserCompany(co.Id, ru.Id);
        insert uCo;  
        
        system.assertEquals('APEX ACME COM', c2g.CODAAPICompany_2_0.GetCurrentCompanies(null)[0]);
        
        // GET QUEUE CREATED BY NI_TestClassData.createFFACompany FUNCTION
        Group q = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'APEX ACME COM' LIMIT 1];
        
        c2g__codaYear__c yr = NI_TestClassData.createFFAYear(String.valueOf(Date.today().year()), co.Id, q.Id);
        insert yr;
        c2g.CODAYearWebService.calculatePeriods(yr.Id);
        
        c2g__codaAccountingCurrency__c ac = NI_TestClassData.createFFAAccountingCurrency('USD', co.Id, q.Id);
        insert ac; 
        
        // INSERT TEST DIMENSIONS
        c2g__codaDimension2__c dim2 = NI_TestClassData.createTestDimension2();
        dim2.Name = 'TEST DIM 2';
        insert dim2;
        
        c2g__codaDimension3__c dim3 = NI_TestClassData.createTestDimension3();
        dim3.Name = 'TEST DIM 3';
        insert dim3;
        
        // CREATE TEST SALES INVOICE
        Date dt = system.date.today();
        c2g__codaInvoice__c sin = NI_TestClassData.createSalesInvoice(a.Id, dt, 100, null, dim2.Id, dim3.Id, null);
        insert sin;
        
        Product2 prd = [SELECT Id FROM Product2 WHERE ProductCode = 'APEX-TEST-01'];
        
        // CREATE TEST SALES INVOICE LINE ITEM
        c2g__codaInvoiceLineItem__c sinli = NI_TestClassData.createSalesInvoiceLineItem(prd.Id, 100, sin.Id, null, dim2.Id, dim3.Id, null);
        insert sinli;        
        
        //CREATE A TEST FINANCE REQUEST RECORD
        AH_Finance_Request__c fr = NI_TestClassData.createFinanceRequest();
        insert fr;
        
        // INSERT AH_Finance_Request_to_SIN_Line_Item__c TO COVER AFTER INSERT TRIGGER & HANDLER CODE
        AH_Finance_Request_to_SIN_Line_Item__c fToSin = NI_TestClassData.createFinanceRequestToSINLineItem(sinli.Id,fr.Id);
        insert fToSin;
        
        //CREATE A TEST FINANCE REQUEST RECORD
        AH_Manual_Credit_Lines__c mc = NI_TestClassData.createManualCreditLines(fr.Id);
        insert mc;
        
        Test.stopTest();
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD: TEST NEXT FUNCTIONS
    // ======================================================================================================================================= 
    @isTest static void testNEXT()
    {  
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1'];
        User u = [SELECT Id FROM User WHERE Alias = 'SA01TST']; 
        
        Test.startTest();  
        
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        insert c;
        
        INTGR_Account__c intAcc = NI_TestClassData.createTestINTGR_Account(1, a.Id, u.Id); 
            
        List<INTGR_Field_Mapping__c> lstMaps = NI_TestClassData.createTestINTGR_AccountMapping(1, intAcc.Id);     
//      database.insert(lstMaps);
        
        INTGR_Case__c intCs = NI_TestClassData.createTestINTGR_Case(1, intAcc.Id, c.Id);     
        insert intCs; 
        
        INTGR_Case_Comment__c intCsC = NI_TestClassData.createTestINTGR_CaseComm(intCs.Id);  
        
        Case stdC1 = NI_TestClassData.createInternalCase(1, a.Id, intCs.Id, intAcc.Id);
        
        Case stdC2 = NI_TestClassData.createTestCaseIntegration(1, a.Id);
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD: TEST PLCM FUNCTIONS
    // ======================================================================================================================================= 
    @isTest static void testPLCM()
    {  
        
        // NI_Documentation__c            
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_Documentation('Portal Setup And Migration Plan', 10, '07/21/2019', '07/28/2019', '07/30/2019', 'Cross-Reference Complete', false, false, false, 'Project Plan' );
        insert niDoc;
        
        // AH_PLCM_Migration_Property__c
        AH_PLCM_Migration_Property__c migrationProperty = NI_TestClassData.createTestAH_PLCM_Migration_Property(niDoc.Id, 'WHIAY Dummy Property7', 'NewHampshire Ave', 'NH', 'Portsmouth', 'USD');
        insert migrationProperty;        
        
        // AH_PLCM_MigrationUser_Mapping__c  
        AH_PLCM_MigrationUser_Mapping__c migrationUserMap = NI_TestClassData.createTestAH_PLCM_MigrationUser_Mapping(niDoc.Id, '', 'Jim Cook', 'jcook_test@windsorcourt.com');

        // AH_PLCM_Migration_User__c        
        AH_PLCM_Migration_User__c migrationUser =  NI_TestClassData.createTestAH_PLCM_Migration_User_c(migrationProperty.Id, 'Ebony Wiggins', 'ebony.wiggins.test@hyattex.com', 'USD');

        // AH_PLCM_TargetOrg_User__c 
        AH_PLCM_TargetOrg_User__c targetOrgUser = NI_TestClassData.createTestAH_PLCM_TargetOrg_User_c(niDoc.Id, 'DirectBook User', 'delphiTest@newmarket.com');

    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD: TEST PLCM MEETING MATRIX FUNCTIONS 
    // ======================================================================================================================================= 
    @isTest static void testPLCMMM()
    {
        // NI_Documentation__c
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_DocumentationForMM('Hotel Wonderful MM Conversion', date.today().format(), date.today().format(), 'Function Room Information Provided', false, false, false, 'Project Plan', true, date.today().format());
        
        // AH_PLCM_MM_Inventory__c        
        AH_PLCM_MM_Inventory__c inventoryObj = NI_TestClassData.createTest_Inventory(true, 'Chair1', 12, 15, 6, 'aAp190000000ReD');
        
        // AH_PLCM_MM_Room_Details__c
        AH_PLCM_MM_Room_Details__c functionRoom = NI_TestClassData.createTest_FunctionRoom('Room 1','MM','Source Locations', 10, 1, '', '1', true, 'Function room descriptions');
    }    

    // ======================================================================================================================================= 
    // = TEST METHOD: TEST PLCM Email WorkFlow Functions
    // ======================================================================================================================================= 
     @isTest static void testPLCMForEmailWorkFlow()
    {
        // NI_Documentation__c
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_DocumentationForEmailWorkFlow('Hotel Wonderful MM Conversion',1, '10/09/2020', '10/09/2020','10/09/2020', 'Portal Invitation Sent', false, false, false, 'Project Plan', true);       
    }

     // ======================================================================================================================================= 
    // = TEST METHOD: TEST PLCM Email WorkFlow Functions
    // ======================================================================================================================================= 
    
    // ======================================================================================================================================= 
    // = TEST METHOD: TEST EXTRACT APPEND FUNCTIONS
    // ======================================================================================================================================= 
    @isTest static void testExtractAppend()
    {  
       
      //insert new record into NI Org Details object for testing
      NI_Org_Details__c niSourceOrgDetails = NI_TestClassData.createTestNI_OrgDetailsForEA('Eastons Hotel Group', 'Salesforce Production', 'Provisioned', 'FDC', '00D4T000000Fqno', '1.244');
      insert niSourceOrgDetails;
      NI_Org_Details__c niTargetOrgDetails = NI_TestClassData.createTestNI_OrgDetailsForEA('Standard and Essentials 5', 'Salesforce Production', '', 'FDC', '00D5w000005jbrf', '');
      insert niTargetOrgDetails;
        
        // NI_Documentation__c            
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_DocumentationForEA('Portal Setup And Migration Plan', 10, '07/21/2019', '07/28/2019', '07/30/2019', 'Cross-Reference Complete', false, false, false, 'Project Plan', niSourceOrgDetails.Id, niTargetOrgDetails.Id);
        insert niDoc;
        
        // AH_PLCM_Migration_Property__c
        AH_PLCM_Migration_Property__c migrationProperty = NI_TestClassData.createTestAH_PLCM_Migration_PropertyForEA('Courtyard by Marriott Kingston Hotel', niSourceOrgDetails.Id, 'CAD', 'CA', niSourceOrgDetails.Org_ID__c, '39', true, true, niSourceOrgDetails.Org_Name__c, 'a0Y4T000000USpcUAG', 'Kingston', 'ON', 'GMT-05:00 Eastern Daylight Time (America/New_York)', 'Delphi.Fdc', 'Standard & Essentials', 'K7K 0C4',  niDoc.Id);
        insert migrationProperty;        
        
        // AH_PLCM_MigrationUser_Mapping__c  
        AH_PLCM_MigrationUser_Mapping__c migrationUserMap = NI_TestClassData.createTestAH_PLCM_MigrationUser_MappingForEA(niDoc.Id, '', 'Jim Cook', 'jcook_test@windsorcourt.com', true, null);

        // AH_PLCM_Migration_User__c        
        AH_PLCM_Migration_User__c migrationUser =  NI_TestClassData.createTestAH_PLCM_Migration_User_cForEA(migrationProperty.Id, 'Ebony Wiggins', 'ebony.wiggins.test@hyattex.com', 'USD');

        // AH_PLCM_TargetOrg_User__c 
        AH_PLCM_TargetOrg_User__c targetOrgUser = NI_TestClassData.createTestAH_PLCM_TargetOrg_User_cForEA(niDoc.Id, 'DirectBook User', 'delphiTest@newmarket.com');

    }
    
     // ======================================================================================================================================= 
    // = TEST METHOD: TEST PROJECT BACKLOG WORKSTREAM FUNCTIONS.  Added per NICC-047197
    // ======================================================================================================================================= 
    @isTest static void testProjectBacklogWorkstream()
    {  
       
      Id rt1 = Schema.SObjectType.NI_Project_Backlog__c.getRecordTypeInfosByName().get('Business Systems').getRecordTypeId();  
      
      //GET WORKSTREAM NAME PICKLIST VALUES FROM PROJECT BACKLOG WORKSTREAM OBJECT
      String strWorkstreamName1 = SObjectType.AH_Project_Backlog_Workstreams__c.Fields.Workstream_Name__c.PicklistValues[0].getValue();
      String strWorkstreamName2 = SObjectType.AH_Project_Backlog_Workstreams__c.Fields.Workstream_Name__c.PicklistValues[1].getValue();   
        
        
        // CREATE TEST PROJECT BACKLOG RECORD     
        Integer i = 1;
        NI_Project_Backlog__c pb1 = NI_TestClassData.createTestProjectBacklog(i);
        pb1.RecordTypeId = rt1;
        insert pb1;
        
         // CREATE TEST AH WORKSTREAM RECORDS.  SET THE NAMES TO THE VALUES FROM THE WORKSTREAM NAME PICKLIST FIELD    
        AH_Workstream__c ws1 = NI_TestClassData.createTestWorkstream();
        ws1.Name = strWorkstreamName1;
        insert ws1; 
        
        //CREATE A TEST PROJECT BACKLOG WORKSTREAM RECORD
        AH_Project_Backlog_Workstreams__c pbw = NI_TestClassData.createTestProjectWorkstream(pb1.Id);
        pbw.Workstream_Name__c = ws1.Name;
        insert pbw;

    }
}