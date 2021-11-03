/****************************************************************************************
Name            : AH_EmailAuthor_Test
Author          : Sean Harris
Created Date    : 08/03/2017
Last Mod Date   : 08/03/2017
Last Mod By     : Sean Harris
NICC Reference  : NICC-023217
Description     : Test Class for AH_EmailAuthor controller for AH_EmailAuthor VF Page
				: 
******************************************************************************************/
@isTest
public class AH_EmailAuthor_Test 
{

    // =============================================================================================================
    // 		CREATE TEST DATA 
    // =============================================================================================================
    @testSetup static void createTestData() 
    {    

		system.debug(' *** AH_EmailDocs_Ext_Test.createTestData() - START ***'); 
		        
Test.startTest();
/*        
        // BECAUSE THIS TEST CLASS CREATES ATTACHMENTS, WE NEED TO CREATE WIN@PROACH CUSTOMSETTINGS FOR NI_Attachment_TriggerHandler CLASS
        Winaproach_Incident_Case_Record_Type__c winAppCS1 = NI_TestClassData.createIncidentCaseRecordType();
        insert winAppCS1;
        WinaproachIncidentSettings__c winAppCS2 = NI_TestClassData.createWinaproachIncidentSettings();
        insert winAppCS2;
        ServiceNowIncidentSettings__c winAppCS3 = NI_TestClassData.createServiceNowIncidentSettings();
        insert winAppCS3;
*/        
        // CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(1);        
        a.Name = 'AH_EmailAuthor_Test ACCOUNT';
        a.Type = 'Prospect';
        insert a;

        // CREATE TEST CONTACT RECORD 
        Contact c = NI_TestClassData.createTestContact(1, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuser';    
        c.Email = 'itbssharedmb@newmarketinc.com';
        insert c; 
        
        // CREATE TEST ATTACHMENT RECORD 
        Blob attBody = Blob.valueOf('Unit Test Attachment Body');
        
        Attachment att = new Attachment();   	
    	att.Name = 'Unit Test Attachment';    	
    	att.body = attBody;
        att.parentId = a.Id;
        insert att;        

Test.stopTest(); 
                
/*
        // CREATE TEST DI INDEX RECORDS 
        NI_DeploymentInstanceIndex__c testDiIndex1 = new NI_DeploymentInstanceIndex__c();
        testDiIndex1 = NI_TestClassData.createDI_Index(1, 'APEX TEST 1');
        insert testDiIndex1;

        NI_DeploymentInstanceIndex__c testDiIndex2 = new NI_DeploymentInstanceIndex__c();
        testDiIndex2 = NI_TestClassData.createDI_Index(2, 'APEX TEST 2');
        insert testDiIndex2;
        
        List<NI_DeploymentInstanceIndex__c> lstDIIndexAsserts = new List<NI_DeploymentInstanceIndex__c>([SELECT Id FROM NI_DeploymentInstanceIndex__c]);
        system.assertEquals(2, lstDIIndexAsserts.size());
        
        // CREATE TEST PRODUCT GROUP RECORD 
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST 1');
        insert pgp;

        List<Product_Group__c> lstProductGroupAsserts = new List<Product_Group__c>([SELECT Id FROM Product_Group__c]);
        system.assertEquals(1, lstProductGroupAsserts.size());
        
        // CREATE TEST PRODUCT2 RECORDS        
        Product2 prd1 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-PROD2-01', 'Subscription'); 
        prd1.DI_Index__c = testDiIndex1.Id;
        prd1.Product_Line_Global__c = 'Delphi';
        prd1.Hosted__c = true;
        insert prd1;

        Product2 prd2 = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-PROD2-02', 'Subscription'); 
        prd2.DI_Index__c = testDiIndex2.Id;
        prd2.Product_Line_Global__c = 'Delphi';
        prd2.Hosted__c = true;
        insert prd2;
        
        List<Product2> lstProduct2Asserts = new List<Product2>([SELECT Id FROM Product2]);
        system.assertEquals(2, lstProduct2Asserts.size());

        // CREATE TEST DEPLOYMENT INSTANCE RECORDS
    	Asset di1 = NI_TestClassData.createTestAsset(1, a.Id, prd1.Id);
        di1.Status = 'Purchased';        
        di1.Product_Group__c = pgp.Id;
        di1.Quantity_Provisioned__c = 0; 
        insert di1; 

    	Asset di2 = NI_TestClassData.createTestAsset(2, a.Id, prd2.Id);
        di2.Status = 'Purchased';        
        di2.Product_Group__c = pgp.Id;
        di2.Quantity_Provisioned__c = 0; 
        insert di2; 

        List<Asset> lstAssetAsserts = new List<Asset>([SELECT Id, Name, AccountId FROM Asset]);
        system.assertEquals(2, lstAssetAsserts.size());        

        // CREATE TEST OPPORTUNITY RECORD 
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rt = OpportunityRecordTypeInfo.get('Small Deal Opportunity').getRecordTypeId();  
        
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.Name = 'APEX TEST 1';
        opp1.RecordTypeId = rt;
        insert opp1;

        List<Opportunity> lstOpportunityAsserts = new List<Opportunity>([SELECT Id FROM Opportunity]);
        system.assertEquals(1, lstOpportunityAsserts.size());        

        // CREATE TEST OPPORTUNITY CONTACT ROLE RECORDS 
        List<OpportunityContactRole> lstOppContcRole = new List<OpportunityContactRole>();

        // Bill To contact 
        OpportunityContactRole ocr1 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Bill To');
        lstOppContcRole.add(ocr1);
        // Ship To contact
        OpportunityContactRole ocr2 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Ship To');
        lstOppContcRole.add(ocr2);         
        // Customer Project Contact 
        OpportunityContactRole ocr3 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Customer Project Contact');
        lstOppContcRole.add(ocr3);        
        // Decision Maker Contact 
        OpportunityContactRole ocr4 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Decision Maker');
        lstOppContcRole.add(ocr4);         
        
        database.insert(lstOppContcRole);
        
        List<OpportunityContactRole> lstOpportunityContactRoleAsserts = new List<OpportunityContactRole>([SELECT Id FROM OpportunityContactRole]);
        system.assertEquals(4, lstOpportunityContactRoleAsserts.size());    

        // CREATE TEST PRICEBOOK ENTRY RECORD
        Id pbkId = Test.getStandardPricebookId(); 
        
        PricebookEntry pbe1 = NI_TestClassData.createTestPricebookEntry(pbkId, prd1.Id, 1000);
        insert pbe1;  
        PricebookEntry pbe2 = NI_TestClassData.createTestPricebookEntry(pbkId, prd2.Id, 1000);
        insert pbe2;  
        
        // CREATE TEST OPPORTUNITY LINE ITEM RECORDS 
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();

        OpportunityLineItem oli01 = NI_TestClassData.createTestOpportunityLineItem(1, opp1.Id, pbe1.Id, 1);
        oli01.Quantity = 10;
        oli01.DeploymentInstance__c = di1.Id;
        lstOLIs.add(oli01);
        
        OpportunityLineItem oli02 = NI_TestClassData.createTestOpportunityLineItem(2, opp1.Id, pbe2.Id, 1);
        oli02.Quantity = 5;
        oli02.DeploymentInstance__c = di2.Id;
        lstOLIs.add(oli02);    
        
        Database.Insert(lstOLIs);
        
        List<OpportunityLineItem> lstOpportunityLineItemAsserts = new List<OpportunityLineItem>([SELECT Id FROM OpportunityLineItem]);
        system.assertEquals(2, lstOpportunityLineItemAsserts.size());    
        
		// CREATE BILLING CONTRACT RECORD 
        Billing_Contract__c bc1 = NI_TestClassData.createBillingContract(1);
        bc1.Account__c = a.Id;
        bc1.Opportunity__c = opp1.Id;            
        insert bc1;
        
        // CREATE ACTIVITY LINE ITEM RECORDS 
        List<Activity_Line_Item__c> aliList = new List<Activity_Line_Item__c>();
        
        Activity_Line_Item__c ali1 = NI_TestClassData.createActivityLineItem(bc1.Id);   
        ali1.Deployment_Instance__c = di1.Id;
        ali1.Opportunity__c = opp1.Id;
        ali1.Status__c = 'Inactive';
        aliList.add(ali1);
        
        Activity_Line_Item__c ali2 = NI_TestClassData.createActivityLineItem(bc1.Id);   
        ali2.Deployment_Instance__c = di2.Id;
        ali2.Opportunity__c = opp1.Id;
        ali2.Status__c = 'Inactive';
        aliList.add(ali2);
        
        database.insert(aliList);

        List<Activity_Line_Item__c> lstActivityLineItemAsserts = new List<Activity_Line_Item__c>([SELECT Id FROM Activity_Line_Item__c]);
        system.assertEquals(2, lstActivityLineItemAsserts.size());    
       
        // CREATE TEST NI DOCUMENT RECORD
        Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.NI_Documentation__c; 
        Map<String, Schema.RecordTypeInfo> nDocRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName(); 
        Id rtDoc = nDocRecordTypeInfo.get('Property Management Documentation').getRecordTypeId();  

        NI_Documentation__c nDoc = new NI_Documentation__c();
        nDoc.RecordTypeId = rtDoc;
        nDoc.Account__c = a.Id;
       	nDoc.Contact__c = c.Id;
        nDoc.Opportunity__c = opp1.Id;
        nDoc.Document_Name__c = 'License key';
        nDoc.Document_Type__c = 'Agenda';
        insert nDoc;
        system.debug(ndoc.id);

       	List<NI_Documentation__c> lstNIDocumentationAsserts = new List<NI_Documentation__c>([SELECT Id FROM NI_Documentation__c]);
        system.assertEquals(1, lstNIDocumentationAsserts.size());  
 
        // CREATE TEST ATTACHMENT RECORD 
        Blob attBody = Blob.valueOf('Unit Test Attachment Body');
        
        Attachment att = new Attachment();   	
    	att.Name = 'Unit Test Attachment';    	
    	att.body = attBody;
        att.parentId = nDoc.id;
        insert att;
    	
    	List<Attachment> lstAttachmentAsserts = new List<Attachment>([SELECT Id FROM Attachment WHERE parentId =: nDoc.id]);
    	system.assertEquals(1, lstAttachmentAsserts.size());        
*/
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_EmailDocs_Ext_Test.createTestData()'); 
        system.debug(' *** AH_EmailDocs_Ext_Test.createTestData() - END ***');

    }
    
    // =============================================================================================================
    // 		TEST AH_EmailAuthor VISUALFORCE PAGE
    // =============================================================================================================    
    @isTest static void testAH_EmailAuthor1()
    {
        
        // GET TEST RECORDS 
        //NI_Documentation__c nDoc = [SELECT Id, Name, RecordTypeId, Account__c, Contact__c, Opportunity__c, Document_Name__c, Document_Type__c, OwnerId FROM NI_Documentation__c];
        //Contact c = [SELECT Id FROM Contact LIMIT 1];
        //Activity_Line_Item__c ali = [SELECT Id FROM Activity_Line_Item__c LIMIT 1];

        Account a = [SELECT Id, OwnerId FROM Account WHERE Name = 'AH_EmailAuthor_Test ACCOUNT'];
        Contact c = [SELECT Id FROM Contact WHERE AccountId =: a.Id];
        EmailTemplate et = [SELECT Id, Name, BrandTemplateId
                            FROM EmailTemplate 
                            WHERE Folder.AccessType = 'Public' AND Folder.Type = 'Email' 
                            AND Folder.Name = 'Fulfilment Email Communications' AND Name = 'Microsoft SQL License Agreement'
                            LIMIT 1];
        
system.debug(et.BrandTemplateId);
        
        // =============================================================================================================
        // 		VISUALFORCE PAGE TESTING
        // =============================================================================================================
                
        // PAGE REFERENCE        
        PageReference pageRef = Page.AH_EmailAuthor;

        // ADD URL PARAMS
        pageRef.getParameters().put('id', a.Id);
        pageRef.getParameters().put('fid', a.OwnerId);
        pageRef.getParameters().put('to', c.Id);
        pageRef.getParameters().put('cc', c.Id);
        pageRef.getParameters().put('bcc', c.Id);
        pageRef.getParameters().put('retURL', '%2Fapex/AH_EmailDocs?Id=' + a.Id);
        pageRef.getParameters().put('tid', et.Id);
        pageRef.getParameters().put('ct', '1');
//        pageRef.getParameters().put('ali', ali.Id); 
        pageRef.getParameters().put('sb', '1');
        pageRef.getParameters().put('hb', '1');
        pageRef.getParameters().put('rtxt', '1');
        pageRef.getParameters().put('sub', 'ApexTest');
       
        // SET TEST PAGE
		Test.setCurrentPage(pageRef);       
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_EmailAuthor ctrl = new AH_EmailAuthor(); 

        // SELECT EMAIL TEMPLATE 
        try
        {
            string strOrgWideEmailChoice = ctrl.orgWideEmailOptions[1].getValue();
            ctrl.fromAddressSelected = strOrgWideEmailChoice;            
        }
        catch (Exception ex)
        {
            
        }
        
        // MIMIC USER INPUT ON VF PAGE
        ctrl.additionalTo = 'test1@testEmail.org;test2@testEmail.org'; 
        ctrl.cc = 'test1@testEmail.org;test2@testEmail.org'; 
        ctrl.bcc = 'test1@testEmail.org;test2@testEmail.org'; 
            
        // SELECT ATTACHMENT TO SEND
        ctrl.lstAttachments.get(0).isSelected = true;
     	ctrl.createTask = true;
        ctrl.sendEmail();

        // ASSERT THAT TASK WAS CREATED ON NI DOCUMENT RECORD
        List<Task> lstTaskAssert = new List<Task>([SELECT Id, WhoId, WhatId, Subject, Status, OwnerId, Priority, AccountId FROM Task]); // WHERE WhatId =: a.Id]);
        //system.assertEquals(1, lstTaskAssert.size());
system.debug('*^* lstTaskAssert = ' + lstTaskAssert);        
    }
    
}