/****************************************************************************************
Name            : AH_CustomerAttachmentsExt_Test Test Class
Author          : Sean Harris
Created Date    : 07/12/2017
Last Mod Date   : 07/12/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test Class for AH_CustomerAttachmentsExt
                : 
******************************************************************************************/
@isTest
public class AH_CustomerAttachmentsExt_Test 
{

    // =============================================================================================================
    // 		CREATE TEST DATA 
    // =============================================================================================================
    @testSetup static void createTestData() 
    {    

		system.debug(' *** AH_CustomerAttachmentsExt_Test.createTestData() - START ***'); 
		        
		Test.startTest();

        // CREATE TEST COMPANY DATA
        c2g__codaGeneralLedgerAccount__c testGLA = ffaTestUtilities.create_IS_GLA();
        c2g__codaDimension2__c testDimension2 = ffaTestUtilities.createTestDimension2();
        c2g__codaDimension3__c testDimension3 = ffaTestUtilities.createTestDimension3();
        c2g__codaCompany__c testCompany = ffaTestUtilities.createFFACompany('TEST COMPANY', true, 'USD');

        // CREATE A TEST ACCOUNT RECORD  
        Account a = ffaTestUtilities.createAccount('Apex Test Account', testGLA.Id);
        a.Force_Month_End_Invoice_Date__c = true;
        update a;
        
        // CREATE A TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;   
        
        // CREATE A TEST DI INDEX RECORD
        NI_DeploymentInstanceIndex__c idx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX'); 
        insert idx1; 
        
        // CREATE A TEST PRODUCT RECORD
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-07-TEST', 'Subscription');
        prd01.DI_Index__c = idx1.Id;
        prd01.Product_Group__c = pgp.Id;
        insert prd01;        
        
        // CREATE A TEST SALES INVOICE RECORD
        c2g__codaInvoice__c testInvoice = new c2g__codaInvoice__c();
        testInvoice = ffaTestUtilities.createSIN_with_Dimensions(a, Date.today(), prd01.id, 678, null, testDimension2.id, testDimension3.id);

        List<c2g__codaInvoice__c> lstInvoiceAsserts = new List<c2g__codaInvoice__c>([SELECT Id FROM c2g__codaInvoice__c]);
        system.assertEquals(1, lstInvoiceAsserts.size());
        
        // CREATE A TEST CUSTOMER ATTACHMENT RECORD
        AH_Customer_Attachment__c ca = new AH_Customer_Attachment__c();
        ca.Sales_Invoice__c = testInvoice.Id;
        insert ca;
        
        // CREATE A TEST FILE RECORD        
        ContentVersion cv = NI_TestClassData.createContentVersion();
        insert cv;
        
        ContentVersion cv2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id LIMIT 1];
        List<ContentDocument> lstCDocs = new List<ContentDocument>([SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument]);   
        
        ContentDocumentLink cl = NI_TestClassData.createContentDocumentLink(cv2.ContentDocumentId, ca.Id);
        insert cl;
        
        system.assertEquals(1, lstCDocs.size());
        system.assertEquals(cv2.ContentDocumentId, lstCDocs[0].Id);
        system.assertEquals(cv2.Id, lstCDocs[0].LatestPublishedVersionId);
        system.assertEquals(cv2.Title, lstCDocs[0].Title);
        system.assertEquals(cv2.ContentDocumentId, cl.ContentDocumentId);        

        Test.stopTest();
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_CustomerAttachmentsExt_Test.createTestData()'); 
        system.debug(' *** AH_CustomerAttachmentsExt_Test.createTestData() - END ***');

    }
    
    // =============================================================================================================
    // 		TEST AH_CustomerAttachments VISUALFORCE PAGE
    // =============================================================================================================    
    @isTest static void testAH_CustomerAttachments()
    {        

		system.debug(' *** AH_CustomerAttachmentsExt_Test.testAH_CustomerAttachments() - START ***'); 
		        
        c2g__codaInvoice__c sInv = [SELECT Id FROM c2g__codaInvoice__c];
        
        //PAGE REFERENCE
        PageReference pageRef = Page.AH_CustomerAttachments;
        Test.setCurrentPage(pageRef);         

        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_CustomerAttachmentsExt ctrl = new AH_CustomerAttachmentsExt(new ApexPages.StandardController(sInv));            

        // ASSERT THAT ATTACHED FILES WERE FOUND AND LOADED
        system.assertNotEquals(0, ctrl.lstContentDocuments.size());

        Id docID = ctrl.lstContentDocuments.get(0).ContentDocumentId;
        
        ctrl.acdId = docID;
        PageReference pr = ctrl.viewAttachment();

    	// ASSERT VIEW ATTACHMENT PAGE REFERENCE URL 
		system.assertEquals('/' + docID, pr.getUrl());
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_CustomerAttachmentsExt_Test.testAH_CustomerAttachments()'); 
        system.debug(' *** AH_CustomerAttachmentsExt_Test.testAH_CustomerAttachments() - END ***');
        
    }

}