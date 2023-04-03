/****************************************************************************************
Name            : AH_EmailDocs_Ext_Test
Author          : Sean Harris
Created Date    : 08/03/2017
Last Mod Date   : 08/03/2017
Last Mod By     : Sean Harris
NICC Reference  : NICC-023217
Description     : Test Class for AH_EmailDocs_Ext which is a controller for 
				: AH_EmailDocs VF Page.
Unit Testing
============

******************************************************************************************/
@isTest
public class AH_EmailDocs_Ext_Test 
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
        Account a = NI_TestClassData.createTestAccount(10);        
        a.Name = 'APEX TEST 600';
        a.Type = 'Prospect';
        insert a;

        List<Account> lstAccountAsserts = new List<Account>([SELECT Id FROM Account]);
        system.assertEquals(1, lstAccountAsserts.size());
 
        // CREATE TEST CONTACT RECORD 
        Contact c = NI_TestClassData.createTestContact(1, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuser';    
        c.Email = 'itbssharedmb@newmarketinc.com';
        insert c; 

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

Test.stopTest(); 
        
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

        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_EmailDocs_Ext_Test.createTestData()'); 
        system.debug(' *** AH_EmailDocs_Ext_Test.createTestData() - END ***');

    }
    
    // =============================================================================================================
    // 		TEST AH_EmailDocs VISUALFORCE PAGE
    // =============================================================================================================    
    @isTest static void testAH_EmailDocs1()
    {

        NI_Documentation__c nDoc = [SELECT Id, Name, RecordTypeId, Account__c, Contact__c, Opportunity__c, Document_Name__c, Document_Type__c FROM NI_Documentation__c];
        
        // =============================================================================================================
        // 		VISUALFORCE PAGE TESTING
        // =============================================================================================================
                
        // PAGE REFERENCE        
        PageReference pageRef = Page.AH_EmailDocs;

        // ADD URL PARAM
        pageRef.getParameters().put('id', nDoc.Id);
        
        // SET TEST PAGE
		Test.setCurrentPage(pageRef);       
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_EmailDocs_Ext ctrl = new AH_EmailDocs_Ext(new ApexPages.StandardController(nDoc));            

        // ASSERT LISTS ARE POPULATED
        system.debug('ctrl.templateOptions.size() = ' + ctrl.templateOptions.size());
        system.assertNotEquals(0, ctrl.templateOptions.size());
        system.assertEquals(4, ctrl.lstContacts.size());
        system.assertEquals(2, ctrl.lstActivityLineItems.size());
        system.assertEquals(2, ctrl.lstAssets.size());
        
        // TEST WHEN NO EMAIL TEMPLATE IS SELECTED 
        try 
        {
            ctrl.sendEmail();
        }
        catch (Exception e)
        {
            system.debug('e.getMessage()' + e.getMessage());
            Boolean expectedExceptionThrown = e.getMessage().contains('Please select an Email template before continuing.') ? true : false;
            system.assertEquals(expectedExceptionThrown, true);
        }         
		
        // SELECT EMAIL TEMPLATE 
        string strEmailTemplateId = ctrl.templateOptions[1].getValue();
        system.debug('strEmailTemplateId = ' + strEmailTemplateId);
        ctrl.selectedTemplate = strEmailTemplateId;
        
        // TEST WHEN NO RECIPIENT IS SELECTED 
        try 
        {
            ctrl.sendEmail();
        }
        catch (Exception e)
        {
            system.debug('e.getMessage()' + e.getMessage());
            Boolean expectedExceptionThrown = e.getMessage().contains('Please select at least 1 contact recipient before continuing.') ? true : false;
            system.assertEquals(expectedExceptionThrown, true);
        }          

        // SELECT A CONTACTS FROM RECIPIENT LIST
        ctrl.lstContacts.get(0).isSelected = true;
        ctrl.lstContacts.get(1).isSelected = true;
        
        // SELECT AN ACTIVITY LINE ITEM
        ctrl.lstActivityLineItems.get(0).isSelected = true;
        
        // UPDATE A DI's Quantity_Provisioned__c 
        ctrl.lstAssets.get(0).di.Quantity_Provisioned__c = 1; 
        Id DI_Id = ctrl.lstAssets.get(0).di.Id;
        
        ctrl.sendEmail();
        
        // ASSERT THAT Quantity_Provisioned__c WAS UPDATED
        Asset diQtyAsserts = [SELECT Quantity_Provisioned__c FROM Asset WHERE Id =: DI_Id];
    	system.assertEquals(1, diQtyAsserts.Quantity_Provisioned__c);       
        
        // COVER CODE THAT CHECKS FOR NULL OPPORTUNITY
        nDoc.Opportunity__c = null;
        update nDoc;        
        
        AH_EmailDocs_Ext ctrl2 = new AH_EmailDocs_Ext(new ApexPages.StandardController(nDoc)); 
        
    }
    
    
}