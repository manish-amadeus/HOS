/************************************************************************************************
Name            : AH_CancelRenewals_Test
Author          : Sean Harris
Created Date    : 01/18/2018
Last Mod Date   : 04/29/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test for AH_CancelRenewals_Test Controller class AH_CancelRenewals 
                : 
                : 
*************************************************************************************************/
@isTest
public class AH_CancelRenewals_Test 
{

    // =======================================================================================================================================
    // = CREATE TEST DATA: 
    // =======================================================================================================================================    
    @testSetup static void createTestData()  
    {
		
		system.debug(' *** START AH_CancelRenewals_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        system.debug(' ### BEFORE Test.startTest() - Limits.getQueries() = ' + Limits.getQueries());  
        
        Test.startTest();          
        
        List<Account> lstAccounts = new List<Account>();
        
        // CREATE TEST PARENT ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX Multiprop Parent - AH_CancelRenewals_Test';
        a.Secondary_Account_Owner__c = UserInfo.getUserId();
        a.MTech_Owner__c = UserInfo.getUserId();
        //insert a;         
		//List<Account> lstAccountAsserts = new List<Account>([SELECT Id FROM Account WHERE Name = 'APEX Multiprop Parent - AH_CancelRenewals_Test']);
        //system.assertEquals(1, lstAccountAsserts.Size(), 'Failed to create test Account record in AH_CancelRenewals_Test.createTestData()');    
		lstAccounts.add(a);
        
        // CREATE TEST CHILD ACCOUNT RECORD
        Account ca = NI_TestClassData.createTestAccount(2);
        ca.Name = 'APEX Multiprop Child - AH_CancelRenewals_Test';
        ca.ParentId = a.Id;
        //insert ca;         
		//List<Account> lstAccountAssert2s = new List<Account>([SELECT Id FROM Account WHERE ParentId =: a.Id]);
        //system.assertEquals(1, lstAccountAssert2s.Size(), 'Failed to create test Account record in AH_CancelRenewals_Test.createTestData()');    
		lstAccounts.add(ca);        
        
        // CREATE TEST GRANDCHILD ACCOUNT RECORD
        Account ga1 = NI_TestClassData.createTestAccount(3);
        ga1.Name = 'APEX Multiprop GrandChild - AH_CancelRenewals_Test';
        ga1.ParentId = ca.Id;
        //insert ga1;         
		//List<Account> lstAccountAssert3s = new List<Account>([SELECT Id FROM Account WHERE ParentId =: ca.Id]);
        //system.assertEquals(1, lstAccountAssert3s.Size(), 'Failed to create test Account record in AH_CancelRenewals_Test.createTestData()'); 
		lstAccounts.add(ga1);        
        
        // CREATE TEST GRANDCHILD2 ACCOUNT RECORD
        Account ga2 = NI_TestClassData.createTestAccount(4);
        ga2.Name = 'APEX XX Multiprop GrandChild2 - AH_CancelRenewals_Test';
        ga2.ParentId = ga1.Id;
        //insert ga2;         
		//List<Account> lstAccountAssert4s = new List<Account>([SELECT Id FROM Account WHERE ParentId =: ga1.Id]);
        //system.assertEquals(1, lstAccountAssert4s.Size(), 'Failed to create test Account record in AH_CancelRenewals_Test.createTestData()'); 
        lstAccounts.add(ga2);  
        
        // CREATE TEST GRANDCHILD3 ACCOUNT RECORD
        Account ga3 = NI_TestClassData.createTestAccount(5);
        ga3.Name = 'APEX XXX Multiprop Grand Child 3 - AH_CancelRenewals_Test';
        ga3.ParentId = ga2.Id;
        ga3.Brand__c = 'APEXTEST';
        //insert ga3;         
		//List<Account> lstAccountAssert5s = new List<Account>([SELECT Id FROM Account WHERE ParentId =: ga2.Id]);
        //system.assertEquals(1, lstAccountAssert5s.Size(), 'Failed to create test Account record in AH_CancelRenewals_Test.createTestData()');         
		lstAccounts.add(ga3);  
        
        // CREATE TEST STANDALONE ACCOUNT RECORD
        Account a2 = NI_TestClassData.createTestAccount(6);
        a2.Name = 'APEX Standalone Account - AH_CancelRenewals_Test';
        a2.Brand__c = 'APEXTEST2';
        //insert a2;         
		//List<Account> lstAccountAssert6s = new List<Account>([SELECT Id FROM Account WHERE Name = 'APEX Standalone Account - AH_CancelRenewals_Test']);
        //system.assertEquals(1, lstAccountAssert6s.Size(), 'Failed to create test Account record in AH_CancelRenewals_Test.createTestData()');      
		lstAccounts.add(a2);  
        
        // CREATE TEST INVALID ACCOUNT RECORD
        Account a3 = NI_TestClassData.createTestAccount(7);
        a3.Name = 'APEX Invalid Account - AH_CancelRenewals_Test';
        a3.Brand__c = 'APEXTEST3';
        //insert a3;         
		//List<Account> lstAccountAssert7s = new List<Account>([SELECT Id FROM Account WHERE Name = 'APEX Invalid Account - AH_CancelRenewals_Test']);
        //system.assertEquals(1, lstAccountAssert7s.Size(), 'Failed to create test Account record in AH_CancelRenewals_Test.createTestData()');      
		lstAccounts.add(a3);  
        
        database.insert(lstAccounts);

        List<Account> lstParentAccounts = new List<Account>();
        ca.ParentId = a.Id;
        lstParentAccounts.add(ca);
        ga1.ParentId = ca.Id;
        lstParentAccounts.add(ga1);
        ga2.ParentId = ga1.Id;
        lstParentAccounts.add(ga2);
        ga3.ParentId = ga2.Id;
        lstParentAccounts.add(ga3);
        database.update(lstParentAccounts); 

        system.debug(' ### AFTER CREATING ACCOUNTS Limits.getQueries() = ' + Limits.getQueries()); 
        
        // CREATE A TEST CONTACT TO BE CREATED AS A PORTAL USER 
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Mike';
        cnt.LastName = 'Oxmaul';
        cnt.Email = 'CXLTEST1@amadeushospitality.com';
        insert cnt;

        system.debug(' ### AFTER CREATING CONTACT Limits.getQueries() = ' + Limits.getQueries()); 
        
        List<Contact> lstContactAssert1 = new List<Contact>([SELECT Id FROM Contact WHERE Email = 'CXLTEST1@amadeushospitality.com']);
        system.assertEquals(1, lstContactAssert1.size());
        
        // CREATE TEST CUSTOMER PORTAL USER 
        User u = NI_TestClassData.createTestUser(2, 'AH Customer Community Plus Login User'); 
        u.ContactId = cnt.Id;
        u.FirstName = 'Mike';
        u.LastName = 'Oxmaul';
        u.Alias = 'CXLTEST1';
        u.Email = 'CXLTEST1@amadeushospitality.com';
        u.Username = 'CXLTEST1@amadeushospitality.com.ahcc';
        u.CommunityNickname = 'CXLTEST1'; 
        u.Cancellation_User__c = 'True';
        insert u;
        
        List<User> lstUserAssert1 = new List<User>([SELECT Id FROM User 
                                                    WHERE Username = 'CXLTEST1@amadeushospitality.com.ahcc' 
                                                    AND AccountId =: a.Id 
                                                    AND ContactId =: cnt.Id]);
        system.assertEquals(1, lstUserAssert1.size());
        
        system.debug(' ### AFTER CREATING USER Limits.getQueries() = ' + Limits.getQueries()); 
        
        // HAD TO ADD THIS BLOCK TO SHARE ACCOUNTS TO COMMUNITY USER. NEEDED IN TEST CLASS FOR SOME REASON. NOT NEEDED IN NORMAL RUNTIME        
        List<AccountShare> shareList = new List<AccountShare>();
        
        for (Account acc : [SELECT Id FROM Account])
        {
            AccountShare accountShare = new AccountShare();
            accountShare.AccountId = acc.Id;
            accountShare.UserOrGroupId = u.Id;
            accountShare.AccountAccessLevel = 'Read';
            //		accountShare.ContactAccessLevel = 'Read';
            accountShare.CaseAccessLevel = 'Read';
            accountShare.OpportunityAccessLevel = 'Read';
            shareList.add(accountShare);
        }
        
        insert shareList;
        // ACCOUNT SHARING END -->    

        system.debug(' ### AFTER CREATING ACCOUNT SHARES Limits.getQueries() = ' + Limits.getQueries()); 

        // GET OPPORTUNITY RECORDTYPE ID
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rt = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();

        // CREATE A TEST OPPORTUNITY RECORD
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.RecordTypeId = rt;
        insert o;   
        List<Opportunity> lstOpportunityAsserts = new List<Opportunity>([SELECT Id FROM Opportunity]);
        system.assertEquals(1, lstOpportunityAsserts.size(), 'Failed to create test Opportunity record in AH_CancelRenewals_Test.createTestData()');   
        
        system.debug(' ### AFTER CREATING OPPORTUNITY Limits.getQueries() = ' + Limits.getQueries()); 
        
        // CREATE A TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;         
        List<Product_Group__c> lstProductGroupAsserts = new List<Product_Group__c>([SELECT Id FROM Product_Group__c]);
        system.assertEquals(1, lstProductGroupAsserts.size(), 'Failed to create test Product_Group__c record in AH_CancelRenewals_Test.createTestData()');   

		system.debug(' ### AFTER CREATING PRODUCT GROUP Limits.getQueries() = ' + Limits.getQueries()); 
        
        // CREATE A TEST DI INDEX RECORDS
        NI_DeploymentInstanceIndex__c idx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX 1'); 
        insert idx1; 
        NI_DeploymentInstanceIndex__c idx2 = NI_TestClassData.createDI_Index(2, 'APEX TEST INDEX 2'); 
        insert idx2; 
        List<NI_DeploymentInstanceIndex__c> lstDIIndexAsserts = new List<NI_DeploymentInstanceIndex__c>([SELECT Id FROM NI_DeploymentInstanceIndex__c]);
        system.assertEquals(2, lstDIIndexAsserts.size(), 'Failed to create test NI_DeploymentInstanceIndex__c record in AH_CancelRenewals_Test.createTestData()');   
        
        system.debug(' ### AFTER CREATING DI INDEXES Limits.getQueries() = ' + Limits.getQueries()); 
        
        // CREATE A TEST PRODUCT RECORDS
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        prd01.DI_Index__c = idx1.Id; 
        prd01.Product_Line_Global__c = 'Delphi.fdc'; 
        prd01.Solution_Domain_Global__c = 'Sales & Catering';
        insert prd01; 
        List<Product2> lstProduct2Asserts = new List<Product2>([SELECT Id FROM Product2 WHERE Product_Line_Global__c = 'Delphi.fdc']);
        system.assertEquals(1, lstProduct2Asserts.size(), 'Failed to create test Product2 record in AH_CancelRenewals_Test.createTestData()');   

        system.debug(' ### AFTER CREATING PRODUCT 1 Limits.getQueries() = ' + Limits.getQueries()); 
        
        Product2 prd02 = NI_TestClassData.createProduct2(1, pgp.Id, 'HotSOS-01-TEST', 'Subscription');
        prd02.DI_Index__c = idx2.Id; 
        prd02.Product_Line_Global__c = 'HotSOS'; 
        prd02.Solution_Domain_Global__c = 'Service Optimization';
        insert prd02; 
        List<Product2> lstProduct2Asserts2 = new List<Product2>([SELECT Id FROM Product2 WHERE Product_Line_Global__c = 'HotSOS']);
        system.assertEquals(1, lstProduct2Asserts2.size(), 'Failed to create test Product2 record in AH_CancelRenewals_Test.createTestData()');           
        
        system.debug(' ### AFTER CREATING PRODUCT 2 Limits.getQueries() = ' + Limits.getQueries()); 
        
        // CREATE A TEST ASSET RECORDS
        List<Asset> lstAssets = new List<Asset>();
        
        Asset di1 = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        di1.Product_Group__c = pgp.Id;
        //insert di1;        
		lstAssets.add(di1);
        
        Asset di2 = NI_TestClassData.createTestAsset(1, a2.Id, prd02.Id);
        di2.Product_Group__c = pgp.Id;
        //insert di2;         
        lstAssets.add(di2);
        
        database.insert(lstAssets);
        
        system.debug(' ### AFTER CREATING ASSET 2 Limits.getQueries() = ' + Limits.getQueries()); 
        
        List<Billing_Contract__c> lstBCs = new List<Billing_Contract__c>();
        
        // CREATE A TEST BILLING RECORD FOR MULTIPROP ACCOUNT
        Billing_Contract__c blgCnrct1 = NI_TestClassData.createBillingContract(1);
        blgCnrct1.Name = 'APEX BC TEST #1';
        blgCnrct1.Account__c = a.Id;
		//insert blgCnrct1; 
        lstBCs.add(blgCnrct1);

        // CREATE A TEST BILLING RECORD FOR STANDALONE ACCOUNT
        Billing_Contract__c blgCnrct2 = NI_TestClassData.createBillingContract(2);
        blgCnrct2.Name = 'APEX BC TEST #2';
        blgCnrct2.Account__c = a2.Id;
		//insert blgCnrct2;       
        lstBCs.add(blgCnrct2);
        
        database.insert(lstBCs);
        
        List<Billing_Contract__c> lstBillingContractAsserts = new List<Billing_Contract__c>([SELECT Id FROM Billing_Contract__c]);
        system.assertEquals(2, lstBillingContractAsserts.size(), 'Failed to create test Billing_Contract__c record in AH_CancelRenewals_Test.createTestData()');  

        system.debug(' ### AFTER CREATING BILLING CONTRACTS Limits.getQueries() = ' + Limits.getQueries());         

        
        List<Activity_Line_Item__c> lstALIInserts = new List<Activity_Line_Item__c>();     
        
        // CREATE A TEST ACTIVITY LINE ITEM RECORD FOR MULTIPROP ACCOUNT
		Activity_Line_Item__c actLI = NI_TestClassData.createActivityLineItem(blgCnrct1.Id);
        actLI.Cancel_Line_Item__c = false; 
        actLI.Product__c = prd01.Id; 
        actLI.Contract_Start_Date__c = Date.Today() - 200; 
        actLI.Contract_End_Date__c = Date.Today() + 200; 
        actLI.Units__c = 20; 
        actLI.Status__c = 'Active';
        actLI.Contract_Amount__c = 1000;
        actLI.Auto_Renewal__c = true; 
        actLI.Revenue_Category__c = 'Subscription';
        lstALIInserts.add(actLI);
        //insert actLI; 
        //List<Activity_Line_Item__c> lstALIAsserts = new List<Activity_Line_Item__c>([SELECT Id FROM Activity_Line_Item__c WHERE Account_Name__c = 'APEX Multiprop Parent - AH_CancelRenewals_Test']);
        //system.assertEquals(1, lstALIAsserts.size(), 'Failed to create test Activity_Line_Item__c record in AH_CancelRenewals_Test.createTestData()');   
        
        // CREATE A TEST ACTIVITY LINE ITEM RECORD FOR STANDALONE ACCOUNT
        Activity_Line_Item__c actLI2 = NI_TestClassData.createActivityLineItem(blgCnrct2.Id);
        actLI2.Cancel_Line_Item__c = false; 
        actLI2.Product__c = prd01.Id; 
        actLI2.Contract_Start_Date__c = Date.Today() - 200; 
        actLI2.Contract_End_Date__c = Date.Today() + 200; 
        actLI2.Renewal_Date__c = Date.Today();
        actLI2.Units__c = 20; 
        actLI2.Status__c = 'Active';
        actLI2.Contract_Amount__c = 20000;
        actLI2.Renewal_Base_Price__c = 1000;
        actLI2.Revenue_Category__c = 'Subscription';
        lstALIInserts.add(actLI2);
        //insert actLI2;      
        //List<Activity_Line_Item__c> lstALIAsserts2 = new List<Activity_Line_Item__c>([SELECT Id FROM Activity_Line_Item__c WHERE Account_Name__c = 'APEX Standalone Account - AH_CancelRenewals_Test']);
        //system.assertEquals(1, lstALIAsserts2.size(), 'Failed to create test Activity_Line_Item__c record in AH_CancelRenewals_Test.createTestData()');         
        
        database.insert(lstALIInserts); 

		system.debug(' ### AFTER CREATING ACTIVITY LINE ITEMS Limits.getQueries() = ' + Limits.getQueries());      

                
        Test.stopTest();
        system.debug(' ### AFTER Test.stopTest() - Limits.getQueries() = ' + Limits.getQueries());  
        

        // CREATE A CANCELLATION RECORD ON STANDALONE ACCOUNT
        NI_Cancellation__c cxl1 = new NI_Cancellation__c();
        cxl1.Account__c = a2.Id;
        cxl1.Account_Owner__c = a2.OwnerId;
        cxl1.Activity_Line_Item__c = actLI2.Id;
        // Anticipated_Revenue_Loss__c (Formula) = Renewal_Cancellation_Quantity__c * Activity_Line_Item__r.Renewal_Base_Price__c
        //cxl1.Amadeus_RSM__c = UserInfo.getUserId();
        cxl1.Brand__c = a2.Brand__c;
        cxl1.Cancellation_Notes__c = 'APEX TEST';
        //cxl1.Contact__c = u.ContactId;
        cxl1.Deployment_Instance__c = di2.Id;
        cxl1.DI_Not_Found__c = false;
        cxl1.Effective_Date__c = Date.today() + 365;   
        //cxl1.Franchisor__c = a2.Franchisor__c;
        //cxl1.Management_Company__c = selAccount.ParentId;
        //cxl1.Master_Cancellation_Record__c = null
        //cxl1.Opportunity__c = aliEdit.Opportunity__c;
        cxl1.Product2__c = prd02.Id;
        cxl1.Renewal_Cancellation_Note__c = 'comments here...'; 
        cxl1.Renewal_Cancellation_Quantity__c = 1; 
        cxl1.Renewal_Cancellation_Reason__c = 'Affiliation Change'; 
        cxl1.General_Reason__c = 'Affiliation Change';
        cxl1.Renewal_Cancellation_Request_DateTime__c = DateTime.now();
        cxl1.Renewal_Cancellation_Requested__c = true;
        cxl1.Renewal_Cancellation_Requester__c = u.Id;
        cxl1.Renewal_Cancellation_Requesters_IP__c = '192.168.0.1';
        cxl1.Late_Cancellation__c = false;
        cxl1.Retention_Completed__c = false;
        //cxl1.Specific_User_Names__c = strSpecificUserNames;
        //cxl1.Status__c = 'Pending Retention';
        //cxl1.Status__c = 'Flagged to be Cancelled';

        insert cxl1;
        
        system.debug(' ### AFTER CREATING CANCELLATION Limits.getQueries() = ' + Limits.getQueries()); 
        
		List<NI_Cancellation__c> lstCancellationAsserts = new List<NI_Cancellation__c>([SELECT Id, Anticipated_Revenue_Loss__c FROM NI_Cancellation__c WHERE Account__c =: a2.Id]); 
        system.assertEquals(1, lstCancellationAsserts.size(), 'Failed to create NI_Cancellation__c record in AH_CancelRenewals_Test.createTestData()');  
        system.assertEquals(1000, lstCancellationAsserts[0].Anticipated_Revenue_Loss__c);   
		
		system.debug(' ***  END  AH_CancelRenewals_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: UNIT TESTING FOR CANCELLATION CREATION
    // =======================================================================================================================================
    @isTest static void test1() 
    {
		
		system.debug(' *** START AH_CancelRenewals_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Account a = [SELECT Id, ParentId FROM Account WHERE Name = 'APEX Multiprop Parent - AH_CancelRenewals_Test'];
        Account ca = [SELECT Id, ParentId FROM Account WHERE ParentId =: a.Id];   
        Account ga1 = [SELECT Id, ParentId FROM Account WHERE ParentId =: ca.Id];
        Account ga2 = [SELECT Id, ParentId FROM Account WHERE ParentId =: ga1.Id];
        Account ga3 = [SELECT Id, ParentId FROM Account WHERE ParentId =: ga2.Id];
        User u = [SELECT Id FROM User WHERE Username = 'CXLTEST1@amadeushospitality.com.ahcc' AND AccountId =: a.Id];

		// SET THE ROLE ON THE COMMUNITY USER TO EXECUTIVE
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'APEX Multiprop Parent - AH_CancelRenewals_Test Customer User']; 
        u.UserRoleId = ur.Id;
        update u;

        PageReference pageRef;
		AH_CancelRenewals ctrl;
        
        // OPEN AH_CancelRenewals VF PAGE AS CANCELLATION USER
        system.runAs(u)
        {      
                    
            // PAGE REFERENCE        
            pageRef = Page.AH_CancelRenewals; 
            
            // ADD URL PARAM
            pageRef.getParameters().put('acctid', a.Id);   
            
            // SET TEST PAGE
            Test.setCurrentPage(pageRef); 
            
            // INSTANTIATE VISUALFORCE PAGE CONTROLLER
            ctrl = new AH_CancelRenewals(); 
        }
        
        // THESE ASSERTIONS OUTSIDE OF RUN AS TO AVOID PERMISSIONS ISSUES
        system.assertEquals(u.Id, ctrl.u.Id);
        system.assertEquals(a.Id, ctrl.a.Id);
        
        system.assertEquals(5, ctrl.setAccountIds.size());				// ASSERT 5 ACCOUNT IDS WERE LOADED INTO THE setAccountIds COLLECTION
        system.assertEquals(true, ctrl.bHasChildAccts);
        system.assertEquals(1, ctrl.lstActivityLineItems.size());
        //system.assertEquals(0, ctrl.lstCancellations.size()); 
        system.assertEquals(null, ctrl.lstCancellations);
        
        // PERFORM VARIOUS ACTIONS ON AH_CancelRenewals VF PAGE AS CANCELLATION USER
        system.runAs(u)
        {              
            
            // OPEN REQUEST CANCELLATION FORM 
            ctrl.iALIIndex = ctrl.lstActivityLineItems[0].iIndex;
            ctrl.aliId = ctrl.lstActivityLineItems[0].ActivityLineItemId;    
            ctrl.openForm();
            
            // VARIABLE VALUE ASSERTIONS 
            system.assertEquals(true, ctrl.displayEditCxl); 
            system.assertEquals('', ctrl.accKeyword); 
            system.assertEquals('', ctrl.selAccId); 
            system.assertEquals(null, ctrl.saveError); 
            system.assertEquals(false, ctrl.showSaveError); 
            system.assertEquals('', ctrl.strSearchMsg); 
            system.assertEquals(false, ctrl.bShowCxlDialog); 
            system.assertEquals(false, ctrl.isCxlForDiffAcct); 
            system.assertEquals(true, ctrl.hasRemainingQty); 
            
            // CLOSE REQUEST CANCELLATION FORM 
            ctrl.hideCancellation();
            
            // VARIABLE VALUE ASSERTIONS 
            system.assertEquals(false, ctrl.bShowCxlDialog); 
            system.assertEquals(true, ctrl.displayEditCxl); 
            system.assertEquals('', ctrl.accKeyword); 
            system.assertEquals('', ctrl.selAccId); 
            system.assertEquals(null, ctrl.saveError); 
            system.assertEquals(false, ctrl.showSaveError); 
            
            // REOPEN REQUEST CANCELLATION FORM 
            ctrl.openForm();
            
            // OPEN CANCEL FOR A CHILD ACCOUNT MODE
            ctrl.showCxlDialogForDiffAcct();
            
            // VARIABLE VALUE ASSERTIONS 
            system.assertEquals(true, ctrl.bShowCxlDialog);
            system.assertEquals(true, ctrl.isCxlForDiffAcct);
            
            // CLOSE CANCEL FOR A CHILD ACCOUNT MODE
            ctrl.closeCxlDialog();
            
            // VARIABLE VALUE ASSERTIONS 
            system.assertEquals(false, ctrl.bShowCxlDialog);
            system.assertEquals('', ctrl.saveError);
            system.assertEquals(false, ctrl.showSaveError);
            
            // RE-OPEN CANCEL FOR A CHILD ACCOUNT MODE
            ctrl.showCxlDialogForDiffAcct();
            
            // TEST ACCOUNT SEARCH ERROR 
            //        ctrl.accKeyword = null;
            //        ctrl.doSearch();
            //        system.assertEquals('No related account names found. Please search again.', ctrl.strSearchMsg);
            
            ctrl.accKeyword = 'astringtomakeerror';
            ctrl.doSearch();
            system.assertEquals('No related account names found. Please search again.', ctrl.strSearchMsg);        
            
            // SEARCH FOR AN ACCOUNT
            ctrl.accKeyword = 'apex';
            ctrl.doSearch();
            
            // ASSERT THAT 5 ACCOUNT WERE FOUND USING THE 'apex' KEYWORD
            system.assertEquals(5, ctrl.lstSearchResults.size());
            
            // VALIDATION RULE ASSERTIONS
//            ctrl.selReason = 'CHOOSE ONE';
//            ctrl.saveChanges();       
//            system.assertEquals('ERROR: Please select a Cancellation Reason', ctrl.saveError);

//            ctrl.selReason = 'Affiliation Change'; 
//            ctrl.saveChanges();
//            system.assertEquals('ERROR: Quantity to Cancel cannot be less than 1', ctrl.saveError);
            
            ctrl.iQuantityToCancel = 0;
            ctrl.saveChanges();
            system.assertEquals('ERROR: Quantity to Cancel cannot be less than 1', ctrl.saveError);
            
            ctrl.iQuantityToCancel = 100;
            ctrl.saveChanges();
            system.assertEquals('ERROR: Quantity to Cancel cannot be greater than the remaining amount of 20.00', ctrl.saveError);
            
            ctrl.iQuantityToCancel = 1;
            ctrl.saveChanges();
            system.assertEquals('ERROR: Please search and choose a property to request cancellation for.', ctrl.saveError);

			// SELECT A GENERAL REASON            
//            ctrl.getPickVals();
        	ctrl.selGenReason = 'Affiliation Change';
            
            // TEST SEARCHING FOR ACCOUNT
            ctrl.doSearch();
            ctrl.accKeyword = '   ';
            ctrl.doSearch();
            ctrl.accKeyword = 'APEX Multiprop Child - AH_CancelRenewals_Test';
            ctrl.doSearch();
            
            // THOUGH THERE ARE ONLY 1 ACCOUNT CONTAINING 'Child' IN THE NAME 
            // WE HAVE TO ADD 1 FOR THE 'CHOOSE ONE' DEFAULT OPTION ADDED TO LIST
            system.assertEquals(2, ctrl.lstSearchResults.size());
            
            // EMULATE MAKING AN ACCOUNT SELECTION
            ctrl.selAccId = ctrl.lstSearchResults[1].getValue();
            
            // EMULATE USER CHECKING THE "I am authorized" CHECKBOX
            ctrl.isAccepted = true;

 
Test.startTest();
            
            // ALL INPUT SHOULD BE VALID AT THIS POINT. SAVE AND ASSERT
            ctrl.saveChanges();
            
            // ASSERT 2 CANCELLATIONS WERE CREATED (FOR PARENT & CHILD)
            List<NI_Cancellation__c> lstCxlAsserts1 = new List<NI_Cancellation__c>([SELECT Id FROM NI_Cancellation__c WHERE Account__c =: a.Id]);
            system.assertEquals(1, lstCxlAsserts1.size());
            List<NI_Cancellation__c> lstCxlAsserts2 = new List<NI_Cancellation__c>([SELECT Id FROM NI_Cancellation__c WHERE Account__c =: ca.Id]);
            system.assertEquals(1, lstCxlAsserts2.size());
            
Test.stopTest();

            // ADD URL PARAM
            pageRef.getParameters().put('acctid', a.Id);   
            
            // SET TEST PAGE
            Test.setCurrentPage(pageRef); 
            
        }
        
		system.debug(' ***  END  AH_CancelRenewals_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 2: UNIT TESTING FOR CANCELLATION EDITS
    // =======================================================================================================================================
    @isTest static void test2() 
    {
        
		system.debug(' *** START AH_CancelRenewals_Test.test2() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX Standalone Account - AH_CancelRenewals_Test'];
        
        // PAGE REFERENCE        
        PageReference pageRef = Page.AH_CancelRenewals; 
        
        // ADD URL PARAM
        pageRef.getParameters().put('acctid', a.Id);   
        
        // SET TEST PAGE
        Test.setCurrentPage(pageRef); 
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_CancelRenewals ctrl = new AH_CancelRenewals(); 
        system.assertEquals(a.Id, ctrl.a.Id);        
        system.assertEquals(false, ctrl.bHasChildAccts);
        system.assertEquals(1, ctrl.lstActivityLineItems.size());
        
        // OPEN REQUEST CANCELLATION FORM 
        ctrl.iALIIndex = ctrl.lstActivityLineItems[0].iIndex; 
        ctrl.aliId = ctrl.lstActivityLineItems[0].ActivityLineItemId;    
        ctrl.openForm();
        system.assertEquals(ctrl.aliId, ctrl.aliEdit.Id);

		system.assertEquals(1, ctrl.lstCancellations.size()); 
        system.assertEquals(true, ctrl.hasCancellations); 
 
        // OPEN CANCELLATION DETAILS VIEW ONLY
        ctrl.iCxlIndex = ctrl.lstCancellations[0].iIndex;
        ctrl.cxlEditMode = false;  
        ctrl.showCancellation();
        
        // CLOSE CANCELLATION DETAILS VIEW ONLY
        ctrl.hideCancellation();
        
Test.startTest();  
        
        // OPEN CANCELLATION DETAILS EDIT MODE
        ctrl.iCxlIndex = ctrl.lstCancellations[0].iIndex;
        ctrl.cxlEditMode = true;  
        ctrl.showCancellation(); 
        
        // MAKE UPDATES AND SAVE CANCELLATION RECORD
        ctrl.lstCancellations[ctrl.iCxlIndex].CancellationQuantity = 2;
        ctrl.lstCancellations[ctrl.iCxlIndex].SpecificUserNames = 'Sophonda Cox, Jack Hennitt';
        ctrl.saveCancellationEdit();   
        
        ctrl.retractCancellation(); 
        ctrl.showConfirmation(); 
        ctrl.hideConfirmation(); 
        ctrl.showSearch(); 
        ctrl.showCxlDialog(); 
        
Test.stopTest();
      	
		system.debug(' ***  END  AH_CancelRenewals_Test.test2() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }

    // =======================================================================================================================================
    // = TEST METHOD 3: UNIT TESTING 
    // =======================================================================================================================================
    @isTest static void test3() 
    {
        
		system.debug(' *** START AH_CancelRenewals_Test.test3() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Account a3 = [SELECT Id FROM Account WHERE Name = 'APEX Invalid Account - AH_CancelRenewals_Test'];
        
        Test.startTest();
        
        // PAGE REFERENCE        
        PageReference pageRef = Page.AH_CancelRenewals; 

        // SET TEST PAGE
        Test.setCurrentPage(pageRef); 
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_CancelRenewals ctrl = new AH_CancelRenewals(); 
        
        Test.stopTest();
        
		system.debug(' ***  END  AH_CancelRenewals_Test.test3() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    } 

    // =======================================================================================================================================
    // = TEST METHOD 4: TEST CANCELLATION RESTRICTION POLICIES
    // =======================================================================================================================================
    @isTest static void test4() 
    {
        
		system.debug(' *** START AH_CancelRenewals_Test.test4() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX Multiprop Parent - AH_CancelRenewals_Test'];
        
        Billing_Contract__c bc = [SELECT Id FROM Billing_Contract__c WHERE Name = 'APEX BC TEST #1'];
        
        Date dt = Date.today();
        
        AH_Account_Finance_Policy__c afp = new AH_Account_Finance_Policy__c();
        afp.Account__c = a.Id;
        afp.Billing_Contracts__c = bc.Id;
        afp.Start_Date__c = dt.addDays(-100);
        afp.End_Date__c = dt.addDays(100);        
        afp.Solution_Domain__c = 'Sales & Catering';
        insert afp;
        
        Test.startTest();
        
        // PAGE REFERENCE        
        PageReference pageRef = Page.AH_CancelRenewals; 
        
        // ADD URL PARAM
        pageRef.getParameters().put('acctid', a.Id);   
        
        // SET TEST PAGE
        Test.setCurrentPage(pageRef); 
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_CancelRenewals ctrl = new AH_CancelRenewals(); 
        
        Test.stopTest();
        
		system.debug(' ***  END  AH_CancelRenewals_Test.test4() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }     
    
}