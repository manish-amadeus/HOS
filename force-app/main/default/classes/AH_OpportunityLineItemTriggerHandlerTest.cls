/****************************************************************************************
Name            : AH_OpportunityLineItemTriggerHandlerTest Class
Author          : Sean Harris
Created Date    : 06/06/2019 
Last Mod Date   : 11/22/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Formerly named NI_OppProduct_TriggerHandler_Test
                : Test class for AH_OpportunityLineItemTriggerHandlerTest
				: Updated per NICC-039872
				: 
******************************************************************************************/
@isTest
public class AH_OpportunityLineItemTriggerHandlerTest 
{
    
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
                
		system.debug(' *^* START AH_OpportunityLineItemTriggerHandlerTest.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        // GET OPPORTUNITY RECORD TYPES ============================================================
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtLargeDealId = OpportunityRecordTypeInfo.get('Large Deal Opportunity').getRecordTypeId();
        Id rtMTechNewId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId(); 
        Id rtSmallDealId = OpportunityRecordTypeInfo.get('Small Deal Opportunity').getRecordTypeId();   
        Id rtSalesOrderId = OpportunityRecordTypeInfo.get('Sales Order').getRecordTypeId(); 
        
        // CREATE ACCOUNT TEST RECORD ===============================================================
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_OpportunityLineItemTriggerHandlerTest Account';
        insert a;

        // CREATE CONTACT TEST RECORD ===============================================================
        Contact c = NI_TestClassData.createTestContact(1, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuser';        
        insert c; 
        
        // CREATE PRODUCT GROUP TEST RECORD =========================================================
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        // CREATE PRICEBOOK TEST RECORD =============================================================
        Id pbkId = Test.getStandardPricebookId();   
        
        
        // CREATE TEST DI INDEX RECORDS =============================================================
        List<NI_DeploymentInstanceIndex__c> lstDI_Indx = new List<NI_DeploymentInstanceIndex__c>();
        
        NI_DeploymentInstanceIndex__c diIdx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST 1');
        lstDI_Indx.add(diIdx1);
        NI_DeploymentInstanceIndex__c diIdx2 = NI_TestClassData.createDI_Index(2, 'APEX TEST 2');
        lstDI_Indx.add(diIdx2);
        NI_DeploymentInstanceIndex__c diIdx3 = NI_TestClassData.createDI_Index(3, 'APEX TEST 3');
        lstDI_Indx.add(diIdx3);
        NI_DeploymentInstanceIndex__c diIdx4 = NI_TestClassData.createDI_Index(4, 'APEX TEST 4');
        lstDI_Indx.add(diIdx4);
        
        Database.Insert(lstDI_Indx); 
        
        
        // CREATE PRODUCT TEST RECORDS ==============================================================
        List<Product2> lstProds = new List<Product2>();
        
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription');
        prd01.DI_Index__c = diIdx1.Id;
        prd01.Apttus_Config2__HasOptions__c = false;
        lstProds.add(prd01);  
        
        Product2 prd02 = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-02', 'Support');
        prd02.DI_Index__c = diIdx2.Id;
        prd02.Apttus_Config2__HasOptions__c = false;
        prd02.License_Type__c = 'Limited';        
        lstProds.add(prd02);  
        
        Product2 prd03 = NI_TestClassData.createProduct2(3, pgp.Id, 'APEX-TEST-03', 'Hosting');
        prd03.DI_Index__c = diIdx1.Id;
        prd03.Apttus_Config2__HasOptions__c = false;
        prd03.License_Type__c = 'Full';
        prd03.Unit__c = 'User';             
        lstProds.add(prd03);
        
        Product2 prd04 = NI_TestClassData.createProduct2(4, pgp.Id, 'APTTUS-TEST-BUNDLE1', 'Software');
        prd04.Apttus_Config2__ConfigurationType__c = 'Bundle';
        prd04.Revenue_Category__c = '';
        prd04.Apttus_Config2__HasOptions__c = true; 
        prd04.Unit__c = 'User';        
        lstProds.add(prd04); 
        
        Product2 prd05 = NI_TestClassData.createProduct2(5, pgp.Id, 'APTTUS-TEST-BUNDLE2', 'Software');
        prd05.Apttus_Config2__HasOptions__c = false;
        prd05.Revenue_Category__c = 'Software - Subscription';
        prd05.Unit__c = 'User';        
        lstProds.add(prd05);
        
        Product2 prd06 = NI_TestClassData.createProduct2(4, pgp.Id, 'APEX-TEST-04', 'Software');
        prd06.DI_Index__c = diIdx1.Id;
        prd06.Revenue_Category__c = '';
        prd06.Apttus_Config2__HasOptions__c = true; 
        prd06.Unit__c = 'User';        
        lstProds.add(prd06); 
        
        Database.Insert(lstProds);
        
system.debug(' *^* QUERIES ISSUED #1 = ' + Limits.getQueries() + ', DML = ' + Limits.getDmlStatements()); 
        
        // CREATE TEST ASSET =====================================================================================
        Asset di = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        di.Product_Group__c = pgp.Id;
        insert di;
             
        
        // GET DISTINCT LIST OF FAMILIES =========================================================================
        Map<String, Product2> mapFamilies = new Map<String, Product2>();
        
        for (Product2 prd : [SELECT Family FROM Product2 WHERE IsActive = true AND Family != null])
        {
            if (!mapFamilies.containsKey(prd.Family))
            {
                mapFamilies.put(prd.Family, prd);
            }
        }
        
        // CREATE TEST ROLLUP AMOUNT CUSTOM SETTINGS ============================================================
        List<NI_OpportunityCalculatedAmount__c> lstCustSets = NI_OpportunityCalculatedAmount__c.getAll().values();
        
        Set<String> setCustSetRecTypes = new Set<String>();
        
        for (NI_OpportunityCalculatedAmount__c lCS : lstCustSets)
        {
            setCustSetRecTypes.add(lCS.Opportunity_Record_Type_Name__c);                
        }
        
        List<NI_OpportunityCalculatedAmount__c> lstCS = new List<NI_OpportunityCalculatedAmount__c>();
        Integer iRecTypeCount = 0;
        
        // POPULATE CUSTOM SETTINGS =============================================================================
        for (Schema.RecordTypeInfo rt : OpportunityRecordTypeInfo.values())
        {
            if (!setCustSetRecTypes.contains(rt.getName())) // IF RECORD TYPE DOESN'T EXIST CREATE THE TEST DATA
            {
                iRecTypeCount++;             
                if ((rt.getName() == 'Large Deal Opportunity') || (rt.getName() == 'HRM New Org Opportunity') || (rt.getName() == 'Sales Order')) 
                {
                    for (Product2 f : mapFamilies.values()) 
                    {                       
                        NI_OpportunityCalculatedAmount__c cs = new NI_OpportunityCalculatedAmount__c();
                        String strFamily = f.Family; 
                        if (rt.getName().length() > 20)
                        {
                            cs.Name = rt.getName().Substring(0, 20) + ' : ' + strFamily;  // DID THIS TO AVOID EXCEEDING CHAR LENGTH
                        }   
                        else
                        {
                            cs.Name = rt.getName() + ' : ' + strFamily;
                        }
                        cs.Opportunity_Record_Type_Name__c = rt.getName();
                        cs.Product_Family__c = strFamily;
                        cs.Multiplier__c = 1;
                        if (rt.getName() == 'Large Deal Opportunity')
                        {
                            
                            if (strFamily == 'Hosting') 
                            {
                                cs.Multiplier__c = 0.5;
                            }
                            if (strFamily == 'Support') 
                            {
                                cs.Multiplier__c = 0;
                            }                         
                        }           
                        lstCS.Add(cs);
                    }
                }
            } 
        }
        
        if (lstCS.size() > 0)
        {
            Database.insert(lstCS);
        }        
        
        // CREATE PRICEBOOKENTRY RECORDS =======================================================
        List<PricebookEntry> lstPBEs = new List<PricebookEntry>();
        
        // SUBSCRIPTION RECORD
        PricebookEntry pbe01 = NI_TestClassData.createTestPricebookEntry(pbkId, prd01.Id, 1000);
        lstPBEs.add(pbe01);    
        // SUPPORT RECORD
        PricebookEntry pbe02 = NI_TestClassData.createTestPricebookEntry(pbkId, prd02.Id, 1000);
        lstPBEs.add(pbe02);   
        // HOSTING RECORD
        PricebookEntry pbe03 = NI_TestClassData.createTestPricebookEntry(pbkId, prd03.Id, 1000);
        lstPBEs.add(pbe03);        
        // HOSTING RECORD
        PricebookEntry pbe04 = NI_TestClassData.createTestPricebookEntry(pbkId, prd04.Id, 0);
        lstPBEs.add(pbe04); 
        // HOSTING RECORD
        PricebookEntry pbe05 = NI_TestClassData.createTestPricebookEntry(pbkId, prd05.Id, 0);
        lstPBEs.add(pbe05);
        // SOFTWARE RECORD
        PricebookEntry pbe06 = NI_TestClassData.createTestPricebookEntry(pbkId, prd06.Id, 0);
        lstPBEs.add(pbe06); 
        
        Database.Insert(lstPBEs);
        
system.debug(' *^* Before Test.startTest() QUERIES ISSUED = ' + Limits.getQueries() + ', DML = ' + Limits.getDmlStatements()); 
                
Test.startTest(); 

        // CREATE OPPORTUNITY RECORDS =========================================================
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.Name = '!! APEX TEST WITH LARGE DEAL OPPORTUNITY RECORD TYPE !!';
        opp1.RecordTypeId = rtLargeDealId;
        lstOppInserts.add(opp1);
        
        Opportunity opp2 = NI_TestClassData.createTestOpportunity(2, a.Id); 
        opp2.Name = '!! APEX TEST WITH HRM NEW OPPORTUNITY RECORD TYPE !!';
        opp2.RecordTypeId = rtMTechNewId;
        lstOppInserts.add(opp2);
        
        Opportunity opp3 = NI_TestClassData.createTestOpportunity(3, a.Id); 
        opp3.Name = '!! APEX TEST WITH BUNDLE !!';
        opp3.RecordTypeId = rtSmallDealId;
        lstOppInserts.add(opp3);
        
        Database.Insert(lstOppInserts);
        
system.debug(' *^* QUERIES ISSUED #2 = ' + Limits.getQueries() + ', DML = ' + Limits.getDmlStatements()); 

        
        // CREATE OPPORTUNITY LINE ITEMS =========================================================
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
        
        // SUBSCRIPTION RECORD
        OpportunityLineItem oli01 = NI_TestClassData.createTestOpportunityLineItem(1, opp1.Id, pbe01.Id, 1);
        oli01.DeploymentInstance__c = di.Id;
        oli01.Quantity = 455.33;  
        oli01.UnitPrice = 123.25017; 
        oli01.TotalPrice = null;
        lstOLIs.add(oli01);
        // SUPPORT RECORD
        OpportunityLineItem oli02 = NI_TestClassData.createTestOpportunityLineItem(2, opp1.Id, pbe02.Id, 1);
        lstOLIs.add(oli02);        
        // HOSTING RECORD
        OpportunityLineItem oli03 = NI_TestClassData.createTestOpportunityLineItem(3, opp1.Id, pbe03.Id, 1);
        lstOLIs.add(oli03);         
        // SUBSCRIPTION RECORD
        OpportunityLineItem oli04 = NI_TestClassData.createTestOpportunityLineItem(4, opp2.Id, pbe01.Id, 1);
        lstOLIs.add(oli04);
        // SUPPORT RECORD
        OpportunityLineItem oli05 = NI_TestClassData.createTestOpportunityLineItem(5, opp2.Id, pbe02.Id, 1);
        lstOLIs.add(oli05);        
        // HOSTING RECORD
        OpportunityLineItem oli06 = NI_TestClassData.createTestOpportunityLineItem(6, opp2.Id, pbe03.Id, 1);
        lstOLIs.add(oli06); 
        
        OpportunityLineItem oli07 = NI_TestClassData.createTestOpportunityLineItem(7, opp3.Id, pbe04.Id, 1);
        oli07.OptionId__c = prd04.Id;
        oli07.LineType__c = 'Option';
        lstOLIs.add(oli07);
        
        OpportunityLineItem oli08 = NI_TestClassData.createTestOpportunityLineItem(8, opp3.Id, pbe05.Id, 1);
        oli08.LineType__c = 'Product/Service';
        lstOLIs.add(oli08);         
        
        // BUNDLE TESTING  
        OpportunityLineItem oli09 = NI_TestClassData.createTestOpportunityLineItem(9, opp3.Id, pbe01.Id, 1);
        oli09.OptionId__c = prd05.Id;
        oli09.LineType__c = 'Option';
        oli09.Quantity = 1;
        oli09.TotalPrice = 2.00;
        lstOLIs.add(oli09);
        
        OpportunityLineItem oli10 = NI_TestClassData.createTestOpportunityLineItem(9, opp3.Id, pbe01.Id, 1);
        oli10.OptionId__c = prd05.Id;
        oli10.LineType__c = 'Option';
        oli10.Quantity = 1;
        oli10.TotalPrice = 2.00;        
        lstOLIs.add(oli10);
        
        OpportunityLineItem oli11 = NI_TestClassData.createTestOpportunityLineItem(9, opp3.Id, pbe01.Id, 1);
        oli11.OptionId__c = prd05.Id;
        oli11.LineType__c = 'Option';
        lstOLIs.add(oli11);
        
        OpportunityLineItem oli12 = NI_TestClassData.createTestOpportunityLineItem(12, opp3.Id, pbe05.Id, 1);
        oli12.OptionId__c = prd04.Id;
        oli12.LineType__c = 'Option';
        oli12.Quantity = 1; 
        oli12.TotalPrice = 2.00; 
        lstOLIs.add(oli12);
        
        OpportunityLineItem oli13 = NI_TestClassData.createTestOpportunityLineItem(13, opp1.Id, pbe06.Id, 1);
        lstOLIs.add(oli13);
        
        Database.insert(lstOLIs); 

		// CREATE OPPORTUNITY CONTACT ROLES =========================================================        
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
        // SPONSOR CONTACT ROLE
        OpportunityContactRole ocr5 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Sponsor');
        lstOppContcRole.add(ocr5);
        
        Database.Insert(lstOppContcRole);         
                
system.debug(' *^* Before Test.stopTest() QUERIES ISSUED = ' + Limits.getQueries()); 
        
Test.stopTest(); 
                
		system.debug(' *** END AH_OpportunityLineItemTriggerHandlerTest.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // =======================================================================================================================================   
    @isTest static void test1() 
    {    
                
		system.debug(' *^* START AH_OpportunityLineItemTriggerHandlerTest.test1() - QUERIES ISSUED = ' + Limits.getQueries());	
        

Test.startTest();
        
        List<AH_Products_Family_Unit__c> prodFamUnitList = new List<AH_Products_Family_Unit__c>();
        AH_Products_Family_Unit__c prodFamUnit = new AH_Products_Family_Unit__c();
        prodFamUnit.Name = 'Support';
        prodFamUnitList.add(prodFamUnit);
        
        AH_Products_Family_Unit__c prodFamUnit2 = new AH_Products_Family_Unit__c();
        prodFamUnit2.Name = 'Software';
        prodFamUnit2.Product_Unit__c = 'User';
        prodFamUnitList.add(prodFamUnit2);
        
        AH_Products_Family_Unit__c prodFamUnit3 = new AH_Products_Family_Unit__c();
        prodFamUnit3.Name = 'Hosting';
        prodFamUnit3.Product_Unit__c = 'User';
        prodFamUnitList.add(prodFamUnit3);
        
        AH_Products_Family_Unit__c prodFamUnit4 = new AH_Products_Family_Unit__c();
        prodFamUnit4.Name = 'Subscription';
        prodFamUnitList.add(prodFamUnit4);
        
        insert prodFamUnitList;
        
        Opportunity opp2 = [SELECT Id, Name, AccountId, StageName, Order_Status__c FROM Opportunity WHERE Name = '!! APEX TEST WITH LARGE DEAL OPPORTUNITY RECORD TYPE !!'];
        opp2.StageName = 'Closed Won';
        opp2.Order_Status__c = 'Integrated';
        update opp2;

        Opportunity opp1 = [SELECT Id, Name FROM Opportunity WHERE Name = '!! APEX TEST WITH BUNDLE !!'];
        
        List<OpportunityLineItem> lstOliProdBundles = ([SELECT li.Id FROM OpportunityLineItem li 
                                                        WHERE li.OpportunityId =: opp1.Id 
                                                        AND li.PricebookEntry.Product2.Apttus_Config2__ConfigurationType__c = 'Bundle']); 
        
        // VERIFY THERE ARE NOT RECORDS IN THE lstOliProdBundles LIST
        system.AssertEquals(0, lstOliProdBundles.size());                                          
        
        test.stopTest(); 
                
		system.debug(' *^* END AH_OpportunityLineItemTriggerHandlerTest.test1() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    

    // ======================================================================================================================================= 
    // = TEST METHOD 2: 
    // =======================================================================================================================================    
    @isTest static void test2() 
    {   
		        
		system.debug(' *^* START AH_OpportunityLineItemTriggerHandlerTest.test2() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Id pbkId = Test.getStandardPricebookId();   
        
        Account a = [SELECT Id FROM Account WHERE Name = 'AH_OpportunityLineItemTriggerHandlerTest Account'];
		Opportunity o1 = [SELECT Id FROM Opportunity WHERE Name = '!! APEX TEST WITH LARGE DEAL OPPORTUNITY RECORD TYPE !!'];
        Opportunity o2 = [SELECT Id FROM Opportunity WHERE Name = '!! APEX TEST WITH BUNDLE !!'];
        Product2 p = [SELECT Id FROM Product2 WHERE ProductCode = 'APTTUS-TEST-BUNDLE2'];
		List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>([SELECT Id, UnitPrice FROM OpportunityLineItem WHERE OpportunityId =: o1.Id]);
        
        // CREATE TEST APTTUS AGREEMENT =======================================================
        List<Apttus__APTS_Agreement__c> lstAgree = new List<Apttus__APTS_Agreement__c>();
        
        Apttus__APTS_Agreement__c apt1 = NI_TestClassData.createTestApttusAgreement(1, a.Id, o1.Id, pbkId);
        apt1.Synchronized_with_Opportunity_DateTime__c = system.now();
        lstAgree.add(apt1);  
        
        Apttus__APTS_Agreement__c apt2 = NI_TestClassData.createTestApttusAgreement(2, a.Id, o2.Id, pbkId);
        lstAgree.add(apt2);        
        
        Database.Insert(lstAgree); 
        
system.debug(' *^* apt1.Id = ' + apt1.Id);        
system.debug(' *^* apt2.Id = ' + apt2.Id);   
        
Test.StartTest();
        
        // CREATE TEST APTTUS AGREEMENT LINE ITEMS =============================================
        List<Apttus__AgreementLineItem__c> lstAgreeLIs = new List<Apttus__AgreementLineItem__c>();
        
        Apttus__AgreementLineItem__c ali1 = NI_TestClassData.createTestAgreementLineItem('Delphi - New Installation 1', 1, 1, apt1.Id, p.Id);
        lstAgreeLIs.add(ali1);   
        
        Apttus__AgreementLineItem__c ali2 = NI_TestClassData.createTestAgreementLineItem('Delphi - New Installation 2', 2, 1, apt1.Id, p.Id);
        lstAgreeLIs.add(ali2);  
        
        Apttus__AgreementLineItem__c ali3 = NI_TestClassData.createTestAgreementLineItem('Delphi - New Installation 3', 3, 1, apt1.Id, p.Id);
        lstAgreeLIs.add(ali3); 
        
        Apttus__AgreementLineItem__c ali4 = NI_TestClassData.createTestAgreementLineItem('Delphi - New Installation 4', 1, 1, apt2.Id, p.Id);
        lstAgreeLIs.add(ali4);  
        
        Database.Insert(lstAgreeLIs);         
        
Test.StopTest();        
        
        for (OpportunityLineItem oli : lstOLIs)
        {
            oli.DeploymentInstance__c = null;
        	oli.UnitPrice = 123.25; 
        }
		
        database.update(lstOLIs);
        
		system.debug(' *^* END AH_OpportunityLineItemTriggerHandlerTest.test2() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    
    
}