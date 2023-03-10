/****************************************************************************************
Name            : AH_PartnerOrderDetailController_Test Class
Author          : Suzanne LeDuc
Created Date    : 08/07/2017
Last Mod Date   : 04/13/2018
Last Mod By     : Sean Harris
NICC Reference  : NICC-023514
Description     : Test Class for the AH_PartnerOrderDetailController Class      
: 
: 
******************************************************************************************/
@isTest  
public class AH_PartnerOrderDetailController_Test 
{
    
    // ======================================================================================================================================= //
    // = TEST METHOD 1: CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        // CREATE CUSTOM SETTINGS      
        NI_Partner_Channel_Order__c settings = new NI_Partner_Channel_Order__c();
        settings.Name = 'Cendyn';
        settings.CurrentUSDPriceBook__c = 'U17 - AH USD Standard';
        insert settings;
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_PartnerOrderDetailController_Test Account';
        insert a;
        
        Contact cntct = NI_TestClassData.createTestContact(1, a.Id);
        cntct.FirstName = 'Herb';
        cntct.LastName = 'Smith';
        cntct.Email = 'hsmith@somedomain.com';
        insert cntct;        
        
        // CREATE TEST PARTNER USER 
        Profile pro = [SELECT Id, UserType FROM Profile WHERE Name = 'AH PartnerCentral User'];        
        system.assertEquals('PowerPartner', pro.UserType);
        
        User pu = NI_TestClassData.createTestUser(2, 'AH PartnerCentral User');
        pu.ContactId = cntct.Id;
        pu.Partner_Permissions__c = 'Cendyn';
        pu.Partner_Terms_Accepted__c = 'True';
        insert pu;
        
        //        User pu2 = [SELECT Id, UserRoleId FROM User WHERE Id =: pu.Id];
        //        UserRole ur = [SELECT Id, Name FROM UserRole WHERE Id =: pu2.UserRoleId];
        //system.debug(' **** UserRole = ' + ur.Name);
        
        // ASSERT THAT THE ACCOUNT GETS CHANGED TO A PARTNER AFTER CONTACT IS ENABLED AS A PARTNER USER
        Account accAssert = [SELECT Id, IsPartner FROM Account WHERE Id =: a.Id];
        system.assertEquals(true, accAssert.IsPartner);
        
        Opportunity opp = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp.Name = 'AH_PartnerOrderDetailController_Test Opportunity';
        insert opp;
        
        // THIS IS NOT PREFERED BUT NEEDED FOR THE TEST CLASS TO NOT ERROR ON AH_PartnerOrderDetailController.setOpp()   
        // WITH System.QueryException: List has no rows for assignment to SObject     
        // SHARE RECORD TO PARTNER USER
        OpportunityShare osh = new OpportunityShare(OpportunityAccessLevel = 'Read', OpportunityId = opp.Id, RowCause = 'Manual', UserOrGroupId = pu.Id);
        insert osh;
        
        // ASSERT THAT THE PARTNER HAS ACCESS TO NEW OPPTY
        List<OpportunityShare> oppShareAssert = new List<OpportunityShare>
            ([SELECT OpportunityAccessLevel 
              FROM OpportunityShare
              WHERE UserOrGroupId =: pu.Id
              AND OpportunityId =: opp.Id]);
        system.assertEquals(false, oppShareAssert.isEmpty());
        
        
        
        opp.Order_Status__c = 'Integrated';
        upsert opp;
        
        // CREATE A NOTE OWNED BY PARTNER USER
        Note n = NI_TestClassData.createNote(1, opp.Id);
        n.OwnerId = pu.Id;
        insert n;
        
        // CREATE A TEST PRODUCT GROUP
        Product_Group__c pg = NI_TestClassData.createProductGroup(1, 'Cendyn');
        pg.IsActive__c = true;
        pg.IsCoreProduct__c = true;        
        insert pg;
        
        // CREATE A TEST PRODUCT
        Product2 p2 = NI_TestClassData.createProduct2(1, pg.Id, 'Cendyn-SKU-001', 'Cendyn');
        p2.Product_Line__c = 'Cendyn Test';
        p2.Revenue_Category__c = 'Subscription';
        p2.Corporate_Product_Group__c = 'Newmarket';
        p2.Unit__c = 'Subscription';
        p2.IsActive = true;
        p2.Description = 'APEX Test Class';
        p2.Family = 'Cendyn';
        p2.Name = 'Cendyn';
        p2.Revenue_Category__c = 'Subscription';
        p2.Partner_Name__c = a.Id;					// IMPORTANT FIELD TO SET
        insert p2;
        
        //LIST TO HOLD THE VALUES FROM THE "NI Partner Channel Order" CUSTOM SETTING  
        List<NI_Partner_Channel_Order__c> lstCSPartnerChannel = NI_Partner_Channel_Order__c.getAll().values();
        string currentUSDpriceBookName = null;
        for (NI_Partner_Channel_Order__c cs : lstCSPartnerChannel)
        {
            if (cs.Name == 'Cendyn')
            {
                currentUSDpriceBookName = cs.CurrentUSDPriceBook__c;
            }
        }
        
        Pricebook2 currentUSDPricebook = NI_TestClassData.createTestPriceBook(currentUSDPriceBookName);
        insert currentUSDPricebook;
        
        PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry(Test.getStandardPricebookId(), p2.Id, 1000);        
        insert pbe;
        
        PricebookEntry pbe2 = NI_TestClassData.createTestPricebookEntry(currentUSDPricebook.Id, p2.Id, 1000);        
        insert pbe2;
        
        test.StartTest();   
        
        List<OpportunityLineItem> lstOpportunityLineItemInserts = new List<OpportunityLineItem>();
        for (integer j = 1; j < 3; j++)
        {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli = NI_TestClassData.createTestOpportunityLineItem(j, opp.Id, pbe.Id, 10);         
            lstOpportunityLineItemInserts.add(oli);
        }
        
        database.insert(lstOpportunityLineItemInserts); 
        
        List<OpportunityLineItem> lstOpptyLineItemCheck = new List<OpportunityLineItem>([SELECT Id FROM OpportunityLineItem]);         
        system.assertEquals(2, lstOpptyLineItemCheck.size()); 
        
        OpportunityContactRole contactRole = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Ship To');    
        insert contactRole; 
        
        OpportunityContactRole contactRole2 = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Customer Project Contact');      
        insert contactRole2; 
        
        pse__Region__c testRegion = NI_TestClassData.createTestRegion(1, 'Test region');
        insert testRegion; 
        
        pse__Practice__c testPractice = NI_TestClassData.createTestPractice(1, 'Test Practice');
        insert testPractice; 
        
        pse__Proj__c testProject = NI_TestClassData.createTestProject(1, 'Test Project', testRegion, testPractice, 'Draft at Risk', opp);        
        insert testProject; 
        
        test.StopTest();   
        
    }
    
    // ======================================================================================================================================= //
    // = TEST METHOD 1: 
    // ======================================================================================================================================= //    
    @isTest static void testAH_PartnerOrderDetailController1() 
    {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'AH_PartnerOrderDetailController_Test Account'];
        Contact cnt = [SELECT Id FROM Contact WHERE Email = 'hsmith@somedomain.com'];         
        User pu = [SELECT Id, Partner_Terms_Accepted__c FROM User WHERE ContactId =: cnt.Id AND AccountId =: a.Id];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'AH_PartnerOrderDetailController_Test Opportunity'];
        
        system.runAs(pu) 
        {
            // SET THE CURRENT VF PAGE
            //            PageReference pr;
            //            AH_PartnerOrderDetailController ctrl;
            
            //            Note n = NI_TestClassData.createNote(1, opp.Id);
            //            insert n;
            
            PageReference pr = Page.AH_PartnerOrderDetail;
            Test.setCurrentPage(pr);
            ApexPages.currentPage().getParameters().put('OppId', opp.Id); 
            AH_PartnerOrderDetailController ctrl = new AH_PartnerOrderDetailController(); 
            
            // ASSERTIONS
            system.assertEquals(opp.Id, ctrl.opp.Id); 
            system.assertEquals(1, ctrl.lstOppDetails.size()); 
            system.assertEquals(2, ctrl.lstOppLineItemDetails.size()); 
            system.assertEquals(pu.Id, ctrl.partnerUser.Id); 
            system.assertEquals('U17 - AH USD Standard', ctrl.currentUSDPriceBookName); 
            
        }
        
    }    
    
}