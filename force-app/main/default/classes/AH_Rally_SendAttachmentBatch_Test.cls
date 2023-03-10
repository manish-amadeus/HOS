/****************************************************************************************
Name            : AH_Rally_SendAttachmentBatch_Test (TC Org Name: BatchToSendAttachmentTestClass)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 011/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-
Description     : Test class for AH_Rally_SendAttachmentBatch
				: 
				: 
******************************************************************************************/
@isTest
global class AH_Rally_SendAttachmentBatch_Test
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        Test.startTest();
        
        User usr = NI_TestClassData.createTestUser(1, 'System Administrator');
        usr.FirstName = 'Apex';
        usr.LastName = 'AdminTester';
        usr.Alias = 'TestAdm6';
        usr.Email = 'Apex.AdminTester@amadeushospitalityx.com';
        usr.Username = 'Apex.AdminTester@amadeushospitalityx.com';
        usr.CommunityNickname = 'TestAdmin6';
        usr.ADUserName__c = 'ApexTestAdmin';        
        insert usr;        
        
        makeTestEmailTemplates();
        
        // CREATE WIN@PROACH CUSTOM SETTINGS
        //        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        system.runAs(usr) 
        {
            
            // CREATE WIN@PROACH CUSTOM SETTINGS
            NI_TestClassData.createTestWinaproachServiceNowSettings();
            
            // CREATE TEST PRODUCT PROJECT (CUSTOM SETTING) RECORD
            ProductMapping__c pro = new ProductMapping__c();
            pro.Name = 'Mapping0';
            pro.Product_Family__c = 'Reservation Solutions';
            pro.Affected_Component__c = '';
            pro.Product__c = 'iHotelier CRS'; //'DataBridge';
            pro.Project__c = 'L3 PMSConnect';
            insert pro;
            
            COLA_Settings__c cs =  new COLA_Settings__c();
            cs.Name = 'STOMAutomation';
            cs.Allow_Product_Creation__c = true;
            cs.Project_Mapping_Row_Count__c = 100;
            insert cs;             
            
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
            
            // CREATE TEST ACCOUNT RECORD
            Account a = NI_TestClassData.createTestAccount(1);
            a.Name = 'AH_Rally_SendAttachmentBatch_Test Account';
            insert a;
            
            // CREATE TEST CONTACT RECORD
            Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
            cnt.FirstName = 'Drew';
            cnt.LastName = 'Peacock';
            cnt.Email = 'drew.peacock@somedomain.org';
            insert cnt;
            
            // CREATE 2 TEST CASE RECORDS 
            Case cs1 = NI_TestClassData.createTestCase(1, a.Id);
            cs1.Subject = 'AH_Rally_CreateUserStory_Test Case# 1';
            cs1.User_Story_Id__c = 'US90582';
            cs1.Priority = 'Medium';
            cs1.Status = 'New';
            cs1.Type = 'Approvals';
            cs1.Origin = 'Web to Case';
            cs1.Number_of_Requests__c = 1;
            cs1.L3_Ticket_Summary__c = 'abc';
            cs1.L3_Steps_To_Reproduce__c = 'abc';
            cs1.Product_Family__c = 'Reservation Solutions';
            cs1.Product__c = 'iHotelier CRS';
            cs1.UserStory_Rally_Status__c = 'In Progress';
            cs1.Rally_Artifact_Ref__c = 'https://rally1.rallydev.com/slm/webservice/1.43/defect/14961076175.js';
            cs1.Module__c = '';
            cs1.hasAttachment__c = true;
            cs1.FormAssemblyCase__c = true;
            insert cs1;
            
            // CREATE 2 TEST CASE ATTACHMENT RELATION RECORD
            Case_Attachment_Relation__c attach = new Case_Attachment_Relation__c();
            attach.case_id__c = cs1.Id;
            attach.To_be_Send__c = true;
            attach.Sf_Attachment_Id__c = '123456789123456789';
            insert attach;
            
            // CREATE 2 TEST CASE COMMENT RELATION RECORD
            Case_Comment_Relation__c comment = new Case_Comment_Relation__c();
            comment.case_Id__c = cs1.Id;
            comment.To_be_Send__c = true;
            comment.Sf_Comment_Id__c = '123456789123456789';
            insert comment;
            
            // CREATE TEST DI INDEX RECORD  
            NI_DeploymentInstanceIndex__c diIdx = NI_TestClassData.createDI_Index(1, 'APEX TEST');
            insert diIdx;
            
            // CREATE TEST PRODUCT GROUP RECORD  
            Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
            insert pgp;
            
            // CREATE TEST PRODUCT RECORD          
            Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-001', 'Subscription');
            prd.DI_Index__c = diIdx.Id;
            insert prd;
            
            // CREATE TEST DI RECORD  
            Asset di = NI_TestClassData.createTestAsset(1, a.Id, prd.Id); 
            di.Product_Group__c = pgp.Id; 
            insert di;
            
            // CREATE TEST SOLUTION RECORD  
            Solution sol = NI_TestClassData.createSolution(1); 
            sol.SolutionName = 'AH_Rally_CreateUserStory_Test Solution';
            insert sol;
            
            // ADD A SOLUTION TO CASE
            CaseSolution csSol = NI_TestClassData.createCaseSolution(cs1.Id, sol.Id);
            insert csSol;
            
            Solution_Count__c sc = new Solution_Count__c();
            sc.Case__c = cs1.Id;
            sc.Number_of_Solutions__c = 1;
            insert sc;           
            
        }
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: testBatch
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {    
        
        // final List<User> testUser = TestDataFactory.createUserRecords(1);
        User testUser = NI_TestClassData.createTestUser(3, 'NI Administrator'); 
        insert testUser;
        final Contact myContact;
        // final Account myAccount = new Account(AccountNumber = '12345', Name = 'Test', ShippingCity = 'Pune', ShippingCountry = 'India', ShippingPostalCode = '411014', ShippingState = 'Maharastra', ShippingStreet = 'Kalyani Nagar'); 
        Account myAccount = [SELECT Id FROM Account WHERE Name = 'AH_Rally_SendAttachmentBatch_Test Account'];
        
        List<Case> myCaseList = new List<Case>();
        List<Attachment> myAttachmentList = new List<Attachment>();
        String strRallySolutionDomain = ''; 
        String strTCProduct = ''; 
        String strAffectedComponent = ''; 
        String strIssue = ''; 
        String strDescription = ''; 
        
        // system.runAs(testUser[0])
        system.runAs(testUser)
        {    
            
            // CREATE TEST ACCOUNT
            //insert myAccount;
            
            // CREATE TEST CONTACT
            // myContact = new Contact(LastName = 'Sharath', AccountId = myAccount.Id, Email = 'sharathchandrat@cybage.com', Phone = '1234567890');
            // insert myContact;            
            myContact = NI_TestClassData.createTestContact(1, myAccount.Id);
            myContact.FirstName = 'APEXTESTUSER';
            myContact.LastName = 'APEXTESTUSER';
            insert myContact;
            
            for (integer i = 0; i < 5; i++)
            {
                
                strRallySolutionDomain = '';
                strTCProduct = '';
                strAffectedComponent = '';
                strIssue = '';
                strDescription = '';
                
                if (i == 0)
                {
                    strRallySolutionDomain = 'Web Solutions';
                    strTCProduct = 'Web Solution Essentials';
                    strAffectedComponent = 'Analytics & Tracking';			// 'Application Issues';
                    strIssue = 'Add/Modify/Remove Tracking on Website'; 	// Reporting';
                    strDescription = '\nCountry:India\n';
                }
                else if (i == 1)
                {
                    strRallySolutionDomain = 'Reservation Solutions';
                    strTCProduct = 'iHotelier CRS';                    
                    strAffectedComponent = 'Analytics & Tracking';
                    strIssue = 'GMS Abandonment Tag';                    
                    strDescription = '\nCountry:India\nDo you need a copy of an invoice or have a question about an invoice?:Yes\n';
                }
                else if (i == 2)
                {
                    strRallySolutionDomain = 'Reservation Solutions';
                    strTCProduct = 'iHotelier CRS';
                    strAffectedComponent = 'iHotelier Analytics';
                    strIssue = 'Dashboard Issue';
                    strDescription = '\nCountry:India\nWhere would you like your images updated?:GDS/OTA\n';
                }
                else if (i == 3)
                {
                    strRallySolutionDomain = 'Reservation Solutions';
                    strTCProduct = 'iHotelier CRS';
                    strAffectedComponent = 'Release Issues';
                    strIssue = 'Min/Max Arrival LOS';
                    strDescription = '\nCountry:India\nWhere would you like your images updated?:GDS/OTA\n';
                }
                else
                {
                    // DataBridge
                    strRallySolutionDomain = 'Web Solutions';
                    strTCProduct = 'Custom Pro';
                    strAffectedComponent = 'Content Management System Questions';
                    strIssue = 'General Questions About CMS';                    
                    strDescription = '\nCountry:India\n';
                }
                
                System.debug(strIssue); 
                Case myCase = NI_TestClassData.createTestCase(1, myAccount.Id);
                myCase.Product_Family__c = strRallySolutionDomain;
                myCase.Product_TC__c = strTCProduct;
                myCase.Affected_Component__c = strAffectedComponent;
                myCase.Issue__c = strIssue; 
                myCase.Description = strDescription;
                myCase.Subject = 'Test';                 
                myCase.AccountId = myAccount.Id; 
                myCase.ContactId = myContact.Id;
                myCase.Status = 'New'; 
                myCase.Origin = 'Web to Case';
                myCase.hasAttachment__c = true; 
                myCase.FormAssemblyCase__c = true;
                myCase.SuppliedEmail = 'sharathchandrat@cybage.com'; 
                myCase.Additional_contact_email_ids__c = 'test@test.com,test1@test.com';
                myCase.SuppliedName = 'Test1';

                myCaseList.add(myCase);
                
            }          
            
            insert myCaseList; 
            
            // Get case attachments
            myAttachmentList = getCaseAttachments(myCaseList);
            
        }
        
        insert myAttachmentList;
        system.assertEquals(5, myCaseList.size());
        
        Test.StartTest();
        
        Id batchProcessId = Database.executeBatch(new AH_Rally_SendAttachmentBatch());
        
        Test.StopTest();   
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: testBatchIfNoAcc
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {    
        
        List<Case> myCaseList = new List<Case>();
        List<Attachment> myAttachmentList = new List<Attachment>();
        
        myCaseList = getCases(5);
        
        if (myCaseList.size() > 0)
        {
            insert myCaseList;           
            myAttachmentList = getCaseAttachments(myCaseList);
            insert myAttachmentList;
            system.assertEquals(5, myCaseList.size());
            
            Test.StartTest();
            
            Id batchProcessId = Database.executeBatch(new AH_Rally_SendAttachmentBatch());
            
            Test.StopTest();
            
        }   
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: testBatchMoreAttachment
    // ======================================================================================================================================= 
    @isTest static void test3() 
    {        
        
        List<Case> myCaseList = new List<Case>();
        List<Attachment> myAttachmentList = new List<Attachment>();
        
        myCaseList = getCases(5);
        
        if (myCaseList.size() > 0)
        {
            insert myCaseList;  
            
            for (Case myCase : myCaseList)
            {
                for (Integer i = 0; i < 11; i++)
                {
                    Attachment myAttachment = new Attachment(Name = 'test', ParentId = myCase.Id, Body = Blob.valueOf('test'));
                    myAttachmentList.add(myAttachment);
                }
            }
            
            insert myAttachmentList;
            system.assertEquals(5, myCaseList.size());
            
            Test.StartTest();
            
            AH_Rally_SendAttachmentBatch myBatchApex = new AH_Rally_SendAttachmentBatch();
            myBatchApex.fileSize = 10485760;
            
            Id batchProcessId = Database.executeBatch(myBatchApex);
            
            Test.StopTest();  
            
        }             
        
    }    
    
    public static List<Attachment> getCaseAttachments(List<Case> caseList)
    {
        List<Attachment> myAttachmentList = new List<Attachment>();
        for (Case myCase : caseList)
        {
            Attachment myAttachment = new Attachment(Name = 'test', ParentId = myCase.Id, Body = Blob.valueOf('test'));
            myAttachmentList.add(myAttachment);
        }
        return myAttachmentList;
    }
    
    public static List<Case> getCases(Integer condition)
    {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'AH_Rally_SendAttachmentBatch_Test Account'];
        Contact cnt = [SELECT Id FROM Contact WHERE Email = 'drew.peacock@somedomain.org'];
        
        List<Case> myCaseList = new List<Case>();
        String strRallySolutionDomain = ''; 
        String strTCProduct = ''; 
        String strAffectedComponent = ''; 
        String strIssue = ''; 
        String strDescription = '';         
        
        for (integer i = 0; i < 5; i++)
        {
            
            strRallySolutionDomain = '';
            strTCProduct = '';
            strAffectedComponent = '';
            strIssue = '';
            strDescription = '';
            
            if (i == 0)
            {
                strRallySolutionDomain = 'Web Solutions';
                strTCProduct = 'Web Solution Essentials';
                strAffectedComponent = 'Analytics & Tracking';			// 'Application Issues';
                strIssue = 'Add/Modify/Remove Tracking on Website'; 	// Reporting';
                strDescription = '\nCountry:India\n';
            }
            else if (i == 1)
            {
                strRallySolutionDomain = 'Reservation Solutions';
                strTCProduct = 'iHotelier CRS';                    
                strAffectedComponent = 'Analytics & Tracking';
                strIssue = 'GMS Abandonment Tag';                    
                strDescription = '\nCountry:India\nDo you need a copy of an invoice or have a question about an invoice?:Yes\n';
            }
            else if (i == 2)
            {
                strRallySolutionDomain = 'Reservation Solutions';
                strTCProduct = 'iHotelier CRS';
                strAffectedComponent = 'iHotelier Analytics';
                strIssue = 'Dashboard Issue';
                strDescription = '\nCountry:India\nWhere would you like your images updated?:GDS/OTA\n';
            }
            else if (i == 3)
            {
                strRallySolutionDomain = 'Reservation Solutions';
                strTCProduct = 'iHotelier CRS';
                strAffectedComponent = 'Release Issues';
                strIssue = 'Min/Max Arrival LOS';
                strDescription = '\nCountry:India\nWhere would you like your images updated?:GDS/OTA\n';
            }
            else
            {
                // DataBridge
                strRallySolutionDomain = 'Web Solutions';
                strTCProduct = 'Custom Pro';
                strAffectedComponent = 'Content Management System Questions';
                strIssue = 'General Questions About CMS';                    
                strDescription = '\nCountry:India\n';
            }

            Case myCase = NI_TestClassData.createTestCase(1, a.Id);
            myCase.Product_Family__c = strRallySolutionDomain;
            myCase.Product_TC__c = strTCProduct;
            myCase.Affected_Component__c = strAffectedComponent;
            myCase.Issue__c = strIssue; 
            myCase.Description = strDescription;
            myCase.ContactId = cnt.Id;
            myCase.Status = 'New'; 
            myCase.Origin = 'Web to Case';
            myCase.hasAttachment__c = true; 
            myCase.Subject = 'Test'; 
            myCase.FormAssemblyCase__c = true;
            myCase.SuppliedEmail = 'sharathchandrat@cybage.com'; 
            myCase.Additional_contact_email_ids__c = 'test@test.com,test1@test.com';
            myCase.SuppliedName = 'Test1';
            
            myCaseList.add(myCase);
            
        }
        
        return myCaseList;
        
    }
    
    private static void makeTestEmailTemplates()
    {
        
        Folder f = [SELECT Id FROM Folder WHERE Name = 'AH Support Email Templates - Hotel IT'];
        BrandTemplate bt = [SELECT Id FROM BrandTemplate WHERE Name = 'Standard Letterhead (Sample)'];
        
        List<EmailTemplate> lstEmailTemplates = new List<EmailTemplate>();
        
        EmailTemplate e1 = new EmailTemplate();
        e1.Name = 'Forwarding to Web Support (EMEA & ASPAC) Web to Case';
        e1.Subject = 'Test Email Template #1';
        e1.developerName = 'TestEmailTemplate_1'; 
        e1.FolderId = f.Id; 
        e1.TemplateType = 'html'; 
        e1.HtmlValue = '<html><head></head><body><h1>HelloWorld1</h1></body></html>';
        e1.BrandTemplateId = bt.Id;
        e1.TemplateStyle = 'formalLetter';
        e1.IsActive = true;
        lstEmailTemplates.add(e1);
        
        EmailTemplate e2 = new EmailTemplate();
        e2.Name = 'Forwarding to Collections for Billing Questions';
        e2.Subject = 'Test Email Template #2';
        e2.developerName = 'TestEmailTemplate_2'; 
        e2.FolderId = f.Id; 
        e2.TemplateType = 'html'; 
        e2.HtmlValue = '<html><head></head><body><h1>HelloWorld2</h1></body></html>';
        e2.BrandTemplateId = bt.Id;
        e2.TemplateStyle = 'formalLetter';
        e2.IsActive = true;
        lstEmailTemplates.add(e2);
        
        EmailTemplate e3 = new EmailTemplate();
        e3.Name = 'Forwarding to GDS (images)';
        e3.Subject = 'Test Email Template #3';
        e3.developerName = 'TestEmailTemplate_3'; 
        e3.FolderId = f.Id; 
        e3.TemplateType = 'html'; 
        e3.HtmlValue = '<html><head></head><body><h1>HelloWorld3</h1></body></html>';
        e3.BrandTemplateId = bt.Id;
        e3.TemplateStyle = 'formalLetter';
        e3.IsActive = true;
        lstEmailTemplates.add(e3);
        
        EmailTemplate e4 = new EmailTemplate();
        e4.Name = 'Forwarding to Learning Services';
        e4.Subject = 'Test Email Template #4';
        e4.developerName = 'TestEmailTemplate_4'; 
        e4.FolderId = f.Id; 
        e4.TemplateType = 'html'; 
        e4.HtmlValue = '<html><head></head><body><h1>HelloWorld4</h1></body></html>';
        e4.BrandTemplateId = bt.Id;
        e4.TemplateStyle = 'formalLetter';
        e4.IsActive = true;
        lstEmailTemplates.add(e4);        
        
        database.insert(lstEmailTemplates);        
        
    }
    
    
}