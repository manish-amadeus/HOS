/****************************************************************************************
Name            : NI_PartnerOrdersTest Class
Author          : Suzanne LeDuc
Created Date    : 08/07/2017
Last Mod Date   : 04/13/2018
Last Mod By     : Sean Harris
NICC Reference  : NICC-023514
Description     : Test Class for the NI_PartnerOrders Class      
                : 
                : 
******************************************************************************************/
@isTest                                     
public class NI_PartnerOrdersTest 
{

    // ======================================================================================================================================= //
    // = TEST METHOD 1: CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
            
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'NI_PartnerOrders_Test Account';
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
        
        // ASSERT THAT THE ACCOUNT GETS CHANGED TO A PARTNER AFTER CONTACT IS ENABLED AS A PARTNER USER
        Account accAssert = [SELECT Id, IsPartner FROM Account WHERE Id =: a.Id];
        system.assertEquals(true, accAssert.IsPartner);
        
        Opportunity opp = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp.Name = 'NI_PartnerOrders_Test Opportunity';
        insert opp;

        
		// CREATE TEST OPPORTUNITY CONTACT ROLE RECORDS ==================================================================================
        List<OpportunityContactRole> lstOppContcRole = new List<OpportunityContactRole>();

        // Bill To contact
        OpportunityContactRole ocr1 = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Bill To');
        lstOppContcRole.add(ocr1);
        // Ship To contact
        OpportunityContactRole ocr2 = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Ship To');
        lstOppContcRole.add(ocr2);         
        // Customer Project Contact 
        OpportunityContactRole ocr3 = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Customer Project Contact');
        lstOppContcRole.add(ocr3);        
        // Decision Maker Contact 
        OpportunityContactRole ocr4 = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Decision Maker');
        lstOppContcRole.add(ocr4);            
        // SPONSOR CONTACT ROLE
        OpportunityContactRole ocr5 = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Sponsor');
        lstOppContcRole.add(ocr5);
        
        database.Insert(lstOppContcRole); 
        
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

        Product_Group__c pg = NI_TestClassData.createProductGroup(1, 'Cendyn');
        pg.IsActive__c = true;
        pg.IsCoreProduct__c = true;        
        insert pg;
        
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
        p2.Partner_Name__c = a.Id;
        insert p2;

        PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry(Test.getStandardPricebookId(), p2.Id, 1000);        
        insert pbe;
        
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

        // CLOSE THE OPPORTUNITY RECORD
        opp.Order_Status__c = 'Integrated';
        opp.StageName = 'Closed Won';
        upsert opp;
        
test.StopTest(); 
        
    }
    
    // ======================================================================================================================================= //
    // = TEST METHOD 1: 
    // ======================================================================================================================================= //    
    @isTest static void testNI_PartnerOrders1() 
    {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'NI_PartnerOrders_Test Account'];
		Contact cnt = [SELECT Id FROM Contact WHERE Email = 'hsmith@somedomain.com'];         
        User pu = [SELECT Id, Partner_Terms_Accepted__c FROM User WHERE ContactId =: cnt.Id AND AccountId =: a.Id];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'NI_PartnerOrders_Test Opportunity'];

        // SET THE CURRENT VF PAGE
        PageReference pr;
        NI_PartnerOrders ctrl;
        
        system.runAs(pu) 
        {
			
            pr = Page.NI_PartnerOrders;
            Test.setCurrentPage(pr);
            ctrl = new NI_PartnerOrders(); 

            system.assertEquals(pu.Id, ctrl.partnerUser.Id); 
            system.assertEquals(2, ctrl.lineItemResults.size()); 
            
            ctrl.setSortDirection('DESC');
            system.assertEquals('DESC', ctrl.getSortDirection()); 
            ctrl.ViewData();
                                
            ctrl.searchText = 'NI_PartnerOrders_Test';
            ctrl.runSearch();
            
            system.assertEquals(2, ctrl.lineItemResults.size()); 
            
            ctrl.searchText = 'xxxxxxxxxxxx';
            ctrl.runSearch();
            
            system.assertEquals(0, ctrl.lineItemResults.size()); 

            ctrl.sortExpression = '';
            ctrl.runSearch();
            
            ctrl.sortExpression = 'ASC';
            ctrl.runSearch();
            
        }
        
    }

}