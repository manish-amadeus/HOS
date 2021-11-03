/****************************************************************************************
Name            : NI_CendynOrdersTest Class
Author          : Suzanne LeDuc
Created Date    : 5/06/2015
Last Mod Date   : 9/9/2015
Last Mod By     : Suzanne LeDuc
NICC Reference  : 
Description     : Test Class for the NI_CendynOrders Class      
: 
: 
******************************************************************************************/
@isTest //(SeeAllData=true)                                      
public class NI_CendynOrdersTest 
{
    
    public static testMethod void NI_CendynOrdersTest() 
    {
        
        //=============================================================================
        // CREATE TEST DATA (START) ===================================================
        //=============================================================================
        
        //        Account a = NI_CendynOrdersTestDataClasses.CreateAccount();
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //        Opportunity opp = NI_CendynOrdersTestDataClasses.CreateOpportunity(a);
        Opportunity opp = NI_TestClassData.createTestOpportunity(1, a.Id); 
        insert opp;
        
        //        NI_CendynOrdersTestDataClasses.CreateNote( opp.Id);
        Note n = NI_TestClassData.createNote(1, opp.Id);
        insert n;
        
        //        Pricebook2 pb2 = [SELECT id FROM Pricebook2 WHERE isStandard = true];                                                
        
        //        Product_Group__c pg = NI_CendynOrdersTestDataClasses.CreateProductGroup();
        Product_Group__c pg = NI_TestClassData.createProductGroup(1, 'Cendyn');
        pg.IsActive__c = true;
        pg.IsCoreProduct__c = true;        
        insert pg;
        
        //        Product2 p2 =  NI_CendynOrdersTestDataClasses.CreateProduct2(  pg, 1 );
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
        insert p2;
        
        //        PricebookEntry pbe = NI_CendynOrdersTestDataClasses.CreatePriceBookEntry( pb2, p2 );
        PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry( Test.getStandardPricebookId(), p2.Id, 1000 );        
        insert pbe;
        
        //        OpportunityLineItem lineItem = NI_CendynOrdersTestDataClasses.CreateOpportunityLineItem( opp.Id,  pbe );
        //        insert lineItem;
        //        OpportunityLineItem lineItem2 = NI_CendynOrdersTestDataClasses.CreateOpportunityLineItem( opp.Id, pbe );
        //        insert lineItem2;
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
        
        Contact cntct = NI_TestClassData.createTestContact(1, a.Id);
        insert cntct;
        
        //        OpportunityContactRole contactRole = NI_CendynOrdersTestDataClasses.CreateOpportunityContactRole( opp.Id, a.Id);
        OpportunityContactRole contactRole = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Ship To');    
        insert contactRole;       
        OpportunityContactRole contactRole2 = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Customer Project Contact');      
        insert contactRole2;
        pse__Region__c testRegion = NI_TestClassData.createTestRegion(1, 'Test region');
        insert testRegion;
        pse__Practice__c testPractice = NI_TestClassData.createTestPractice(1,'Test Practice');
        insert testPractice;
        pse__Proj__c testProject = NI_TestClassData.createTestProject(1, 'Test Project', testRegion , testPractice, 'Draft at Risk', opp);
        
        insert testProject;
        //=============================================================================
        // CREATE TEST DATA ( END ) ===================================================
        //=============================================================================
        
        
        
        //=============================================================================
        // VISUALFORCE PAGE TESTING (START) ===========================================
        //=============================================================================         
        PageReference pageRef = Page.CendynOrders;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('OppId', opp.Id);
        
        
        // Instantiate a new controller with all parameters in the page
        NI_CendynOrders controller = new  NI_CendynOrders();
        
        
        controller.getProjectContact();
        controller.getOrderDate();
        controller.getProjectManager();
        
        controller.setSearchText('Cendyn');
        string sText = controller.getSearchText();
        System.assertEquals('Cendyn', sText);
        controller.runSearch();      
        
        List<OpportunityLineItem> litems = controller.GetLineItems();
        System.Debug('Line Items ' + litems.Size() );
        
        controller.newNoteBody = 'Testing adding a new Note to this Cendyn Opportunity';
        String notebody = controller.newNoteBody;
        System.AssertEquals(notebody, 'Testing adding a new Note to this Cendyn Opportunity');
        
        for( OpportunityLineItem item: litems )
        {
            item.ServiceDate = System.Today();
            item.Projected_Go_Live__c = System.Today();
            
        }
        
        controller.SaveOrder();
        
        controller.newNoteBody = 'Testing';
        controller.saveOrder();
        
        
        controller.SortExpression = 'AccountNumber';
        controller.SetSortDirection('ASC');
        String direction = controller.GetSortDirection();
        System.assertEquals ( 'ASC', direction );
        
        controller.SortExpression = 'AccountNumber';
        
        controller.SetSortDirection('DSC');
        String direction2 = controller.GetSortDirection();
        System.assertEquals ( 'DSC', direction2 );
        
        controller.sortExpression = '';
        controller.getSortDirection(); 
        
        controller.setDisableSaveButton( true );
        Boolean disable = controller.getDisableSaveButton();
        System.assertEquals ( true, disable );
        
        
        controller.getShipTo();
        controller.getOpp();
        
        PageReference pageRef2 = Page.CendynOrderDetail;
        Test.setCurrentPage(pageRef2);
        ApexPages.currentPage().getParameters().put('OppId', opp.Id);
        NI_CendynOrders controller2 = new  NI_CendynOrders();
        
        //=============================================================================
        // VISUALFORCE PAGE TESTING ( END ) ===========================================
        //=============================================================================        
        
    }
    
    public static testMethod void NI_CendynOrdersNoOppTest()
    {
        PageReference pageRef = Page.CendynOrders;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('OppId', NULL);    
        
        // Instantiate a new controller with all parameters in the page
        NI_CendynOrders controller = new  NI_CendynOrders();
    }
    
    public static testMethod void NI_CendynOrdersViewTest() 
    {
        
        PageReference pageRef = Page.CendynOrders;
        Test.setCurrentPage(pageRef);
        
        /*        
Account a = NI_CendynOrdersTestDataClasses.CreateAccount();

Opportunity opp = NI_CendynOrdersTestDataClasses.CreateOpportunity(a);

Pricebook2 pb2 = [SELECT id FROM Pricebook2 WHERE isStandard = true];

Product_Group__c pg = NI_CendynOrdersTestDataClasses.CreateProductGroup();

Product2 p2 =  NI_CendynOrdersTestDataClasses.CreateProduct2(  pg, 1 );

PricebookEntry pbe = NI_CendynOrdersTestDataClasses.CreatePriceBookEntry( pb2, p2 );

OpportunityLineItem lineItem = NI_CendynOrdersTestDataClasses.CreateOpportunityLineItem( opp.Id,  pbe );
insert lineItem;

OpportunityLineItem lineItem2 = NI_CendynOrdersTestDataClasses.CreateOpportunityLineItem( opp.Id, pbe );
insert lineItem2;

*/
        
        //=============================================================================
        // CREATE TEST DATA (START) ===================================================
        //=============================================================================
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        Opportunity opp = NI_TestClassData.createTestOpportunity(1, a.Id); 
        insert opp;
        
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
        insert p2;
        
        PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry(Test.getStandardPricebookId(), p2.Id, 1000);        
        insert pbe;
        
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
        
        // Instantiate a new controller with all parameters in the page
        NI_CendynOrders controller = new  NI_CendynOrders();
        List<OpportunityLineItem> litems = controller.GetOppLineItems();
        
        controller.ViewData();
        
    }
    
    public static testMethod void NI_CendynForeignOrdersTest() 
    {
        
        NI_Partner_Channel_Order__c pSettings;
        pSettings = NI_Partner_Channel_Order__c.getValues('Cendyn');
        
        if( pSettings == null )
        {
            pSettings = new NI_Partner_Channel_Order__c();
            pSettings.Name = 'Cendyn';
            //pSettings.CurrentUSDPriceBook__c = 'C15 - NI China Standard';
            
            pSettings.CurrentUSDPriceBook__c = '';
            pSettings.Opp_Close_Date_Months__c = 12;
            Database.insert( pSettings );
        }
        else
        {
            //pSettings.CurrentUSDPriceBook__c = 'C15 - NI China Standard';
            pSettings.CurrentUSDPRiceBook__C = '';
            database.update( pSettings );
        }
        
        
        Cendyn_Excluded_Products__c exSettings = new Cendyn_excluded_Products__c();
        exSettings.Name = 'EPROP-DFDC-ACT';
        Database.insert( exSettings );
        
        
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        Opportunity opp = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp.Name = 'Apex Test THIS IS MY TEST!';
        // SMH - ADDED STAGENAME = 'Closed Won';       
        opp.StageName = 'Closed Won';
        insert opp;
        
        List<Opportunity> oppTest = new List<Opportunity>([SELECT Id FROM Opportunity WHERE Name = 'Apex Test THIS IS MY TEST!' AND StageName = 'Closed Won']);
        system.assertEquals(1, oppTest.Size());
        
        // opp.CurrencyIsoCode = 'CNY';
        // update opp;
        
        
        Note n = NI_TestClassData.createNote(1, opp.Id);
        insert n;
        
        Product_Group__c pg = NI_TestClassData.createProductGroup(1, 'Cendyn');
        pg.IsActive__c = true;
        pg.IsCoreProduct__c = true;        
        insert pg;
        
        Product2 p2 = NI_TestClassData.createProduct2(1, pg.Id, 'OTH-EFACET-CONF-01', 'Cendyn eFaceTime Configuration (1-200 rooms)');
        p2.Product_Line__c = 'Cendyn Test';
        p2.Revenue_Category__c = 'Subscription';
        p2.Corporate_Product_Group__c = 'Newmarket';
        p2.Unit__c = 'Subscription';
        p2.IsActive = true;
        p2.Description = 'Cendyn eFaceTime Configuration (1-200 rooms)';
        p2.Family = 'Cendyn';
        p2.Name = 'Cendyn';
        p2.Revenue_Category__c = 'Subscription';
        insert p2;
        
        PricebookEntry pbe2 = NI_TestClassData.createTestPricebookEntry( Test.getStandardPricebookId(), p2.Id, 1000 );        
        insert pbe2;
        
        pSettings.CurrentUSDPRiceBook__C = 'Standard Price Book';
        database.update( pSettings );
        
        system.debug('test class price book ' + pbe2.Pricebook2.Name );
        
        
        // SMH            
        String strPBEName = 'Standard Price Book';       
        
        //PriceBook2 priceBook = NI_TestClassData.CreateTestPriceBook( 'CNY Test');
        //priceBook.CurrencyIsoCode = 'CNY';
        //insert priceBook;
        
        
        //PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry( pricebook.Id, p2.Id, 1000 );  
        //pbe.CurrencyIsoCode = 'CNY';      
        //insert pbe;
        
        
        
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p2.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        List<OpportunityLineItem> lstOpportunityLineItemInserts = new List<OpportunityLineItem>();
        
        for (integer j = 1; j < 3; j++)
        {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli = NI_TestClassData.createTestOpportunityLineItem(j, opp.Id, customPrice.Id, 10);
            lstOpportunityLineItemInserts.add(oli);
        }
        
        database.insert(lstOpportunityLineItemInserts);
        
        List<OpportunityLineItem> lstOpptyLineItemCheck = new List<OpportunityLineItem>([SELECT Id FROM OpportunityLineItem]);
        
        system.assertEquals(2, lstOpptyLineItemCheck.size());
        
        Contact cntct = NI_TestClassData.createTestContact(1, a.Id);
        insert cntct;
        
        OpportunityContactRole contactRole = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Ship To');    
        insert contactRole;       
        OpportunityContactRole contactRole2 = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Customer Project Contact');      
        insert contactRole2;
        pse__Region__c testRegion = NI_TestClassData.createTestRegion(1, 'Test region');
        insert testRegion;
        pse__Practice__c testPractice = NI_TestClassData.createTestPractice(1,'Test Practice');
        insert testPractice;
        pse__Proj__c testProject = NI_TestClassData.createTestProject(1, 'Test Project', testRegion , testPractice, 'Draft at Risk', opp);
        
        insert testProject;
        
        
        
        
        PageReference pageRef = Page.CendynOrders;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('OppId', opp.Id);
        
        
        // Instantiate a new controller with all parameters in the page
        NI_CendynOrders controller = new  NI_CendynOrders();
        
        // SMH         
        // controller.currentUSDPriceBookName = strPBEName;
        
        controller.getProjectContact();
        controller.getOrderDate();
        controller.getProjectManager();
        
        controller.setSearchText( 'Cendyn');
        string sText = controller.getSearchText();
        System.assertEquals ( 'Cendyn', sText );
        controller.runSearch();
        
        
        List<OpportunityLineItem> litems = controller.GetLineItems();
        System.Debug('Line Items ' + litems.Size() );
        
        controller.newNoteBody = 'Testing adding a new Note to this Cendyn Opportunity';
        String notebody = controller.newNoteBody;
        System.AssertEquals(notebody, 'Testing adding a new Note to this Cendyn Opportunity');
        
        for( OpportunityLineItem item: litems )
        {
            item.ServiceDate = System.Today();
            item.Projected_Go_Live__c = System.Today();
            
        }
        
        controller.SaveOrder();
        
        controller.newNoteBody = 'Testing';
        controller.saveOrder();
        
        
        controller.SortExpression = 'AccountNumber';
        controller.SetSortDirection('ASC');
        String direction = controller.GetSortDirection();
        System.assertEquals ( 'ASC', direction );
        
        controller.SortExpression = 'AccountNumber';
        
        controller.SetSortDirection('DSC');
        String direction2 = controller.GetSortDirection();
        System.assertEquals ( 'DSC', direction2 );
        
        controller.sortExpression = '';
        controller.getSortDirection(); 
        
        controller.setDisableSaveButton( true );
        Boolean disable = controller.getDisableSaveButton();
        System.assertEquals ( true, disable );
        
        
        controller.getShipTo();
        
        controller.getOpp();
        
        PageReference pageRef2 = Page.CendynOrderDetail;
        Test.setCurrentPage(pageRef2);
        ApexPages.currentPage().getParameters().put('OppId', opp.Id);
        NI_CendynOrders controller2 = new  NI_CendynOrders();
        
    }
    
    
}