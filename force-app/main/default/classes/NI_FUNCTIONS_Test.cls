/****************************************************************************************
Name            : NI_FUNCTIONS_Test Class
Author          : Sean Harris
Created Date    : 09/16/2013
Last Mod Date   : 06/06/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : TEST OPPORTUNITY LINE ITEM CUSTOM ROLLUP CODE THAT WAS MOVED TO NI_FUNCTIONS 05/10/2017
				: Updated on 9/6/2017 per NICC-023777
                : Updated on 9/12/2017 per NICC-023837 
                : 
******************************************************************************************/
@isTest 
public class NI_FUNCTIONS_Test
{
    
     
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        system.debug(' *^* START NI_FUNCTIONS_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        // CREATE TEST CUSTOM SETTINGS =============================================================
        List<AH_Products_Family_Unit__c> prodFamUnitList = new List<AH_Products_Family_Unit__c>();
        
        AH_Products_Family_Unit__c prodFamUnit = new AH_Products_Family_Unit__c();
        prodFamUnit.Name = 'Subscription';
        prodFamUnitList.add(prodFamUnit);
        
        AH_Products_Family_Unit__c prodFamUnit2 = new AH_Products_Family_Unit__c();
        prodFamUnit2.Name = 'Software';
        prodFamUnit2.Product_Unit__c = 'User';
        prodFamUnitList.add(prodFamUnit2);
        
        insert prodFamUnitList;        
        
        // GET OPPORTUNITY RECORD TYPES ============================================================
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtLargeDealId = OpportunityRecordTypeInfo.get('Large Deal Opportunity').getRecordTypeId();
        Id rtMTechNewId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId(); 
        Id rtSmallDealId = OpportunityRecordTypeInfo.get('Small Deal Opportunity').getRecordTypeId();   
        Id rtSalesOrderId = OpportunityRecordTypeInfo.get('Sales Order').getRecordTypeId(); 
        
        // CREATE ACCOUNT TEST RECORD ===============================================================
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEXT FOR NI_FUNCTIONS_Test Class #1';
        insert a;
        
        // CREATE CONTACT TEST RECORD ===============================================================
        Contact c = NI_TestClassData.createTestContact(1, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuser';        
        insert c; 
        
        // CREATE PRODUCT GROUP TEST RECORD =========================================================
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEXT FOR NI_FUNCTIONS_Test Class #1');
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
        
        /*        
        //[SELECT Id FROM Product2 WHERE ProductCode = 'APEX-TEST-MULTI-YEAR1' AND Family = 'Software' AND Revenue_Category__c = 'Software - Subscription'];        
        Product2 prd06 = NI_TestClassData.createProduct2(4, pgp.Id, 'APEX-TEST-MULTI-YEAR1', 'Software');
        prd06.DI_Index__c = diIdx1.Id;
        prd06.Revenue_Category__c = 'Software - Subscription';
        //        prd06.Apttus_Config2__HasOptions__c = true; 
        prd06.Unit__c = 'User';        
        lstProds.add(prd06); 
        */
        
        Product2 prd06 = NI_TestClassData.createProduct2(6, pgp.Id, 'APEX-TEST-MULTI-YEAR1', 'Software');
        prd06.Apttus_Config2__HasOptions__c = false;
        prd06.Revenue_Category__c = 'Software - Subscription';
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
        
        Opportunity opp4 = NI_TestClassData.createTestOpportunity(4, a.Id); 
        opp4.Name = 'TEST ROLLUP AMOUNT AND MULTI-YEAR CHECKBOX';
        opp4.RecordTypeId = rtMTechNewId;
        lstOppInserts.add(opp4);        
        
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
        
        // MULTI-YEAR DEAL OPPORTUNITY LINE ITEMS
        OpportunityLineItem oli13 = NI_TestClassData.createTestOpportunityLineItem(13, opp4.Id, pbe06.Id, 1);
        oli13.Quantity = 1; 
        oli13.TotalPrice = 0.00; // EMULATE COMP
        oli13.Order_of_Delivery__c = 1;
        lstOLIs.add(oli13);
        
        OpportunityLineItem oli14 = NI_TestClassData.createTestOpportunityLineItem(14, opp4.Id, pbe06.Id, 1);
        oli14.Quantity = 1; 
        oli14.TotalPrice = 1500.00; 
        oli14.Order_of_Delivery__c = 2;
        lstOLIs.add(oli14);        
        
        OpportunityLineItem oli15 = NI_TestClassData.createTestOpportunityLineItem(15, opp4.Id, pbe06.Id, 1);
        oli15.Quantity = 1; 
        oli15.TotalPrice = 1500.00; 
        oli15.Order_of_Delivery__c = 3;
        lstOLIs.add(oli15);    
        
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
        
        system.debug(' *** END NI_FUNCTIONS_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // =======================================================================================================================================     
    @isTest static void test1() 
    {
        
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Support Team' LIMIT 1];
        User u = NI_TestClassData.createTestUser(1, 'NI Support CSR');
        u.UserRoleId = ur.Id;
        insert u;
        
        List<Group> lstGrps = new List<Group>();
        List<GroupMember> lstGrpMs = new List<GroupMember>();
        
        Group grp1 = NI_TestClassData.createGroup('PUBLIC TEST GRP 1', 'PUBLICTESTGRP1', 'Regular'); 
        lstGrps.Add(grp1);
        Group grp2 = NI_TestClassData.createGroup('PUBLIC TEST GRP 2', 'PUBLICTESTGRP2', 'Regular'); 
        lstGrps.Add(grp2);        
        Group grp3 = NI_TestClassData.createGroup('PUBLIC TEST GRP 3', 'PUBLICTESTGRP3', 'Regular'); 
        lstGrps.Add(grp3);
        Group grp4 = NI_TestClassData.createGroup('PUBLIC TEST GRP 4', 'PUBLICTESTGRP4', 'Queue'); 
        lstGrps.Add(grp4);
        //Group grp5 = NI_TestClassData.createGroup('PUBLIC TEST GRP 5', 'PUBLICTESTGRP5', 'RoleAndSubordinates'); 
        //grp5.RelatedId = ur.Id; 
        //lstGrps.Add(grp5);
        
        Database.Insert(lstGrps);
        
        GroupMember grpM1 = NI_TestClassData.createGroupMember(grp1.Id, u.Id);  
        lstGrpMs.Add(grpM1);      
        GroupMember grpM2 = NI_TestClassData.createGroupMember(grp2.Id, grp1.Id); 
        lstGrpMs.Add(grpM2);        
        GroupMember grpM3 = NI_TestClassData.createGroupMember(grp3.Id, grp2.Id); 
        lstGrpMs.Add(grpM3);  
        //GroupMember grpM4 = NI_TestClassData.createGroupMember(grp3.Id, grp5.Id); 
        //lstGrpMs.Add(grpM4); 
        
        Database.Insert(lstGrpMs);      
        
        system.runAs(u)
        {
            boolean bTest1 = NI_FUNCTIONS.hasAccessByPublicGroup(UserInfo.getUserId(), 'TEST PUBLIC GROUP - BOGUS GROUP FOR APEX TEST CLASS');        
            boolean bTest2 = NI_FUNCTIONS.hasAccessByPublicGroup(UserInfo.getUserId(), 'PUBLIC TEST GRP 1');
            boolean bTest3 = NI_FUNCTIONS.hasAccessByPublicGroup(UserInfo.getUserId(), 'PUBLIC TEST GRP 3');
            boolean bTest4 = NI_FUNCTIONS.hasAccessByPublicGroup(UserInfo.getUserId(), 'PUBLIC TEST GRP 4');
        } 
        
        /*

Id idTest1 = NI_FUNCTIONS.getProfileIdByAvailableLicense();

Account a = NI_TestClassData.createTestAccount(1);
insert a;

Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
insert cnt; 

NI_FUNCTIONS.createUser(cnt.Id, 'sharris@newmarketinc.com', 'Seann', 'Harriss', 'sharrisssx', null);
NI_FUNCTIONS.createCustomerPortalUserFromEmail('sharris@newmarketinc.com');
boolean bIsEmail = NI_FUNCTIONS.isValidEmailAddress('sharris@newmarketinc.com');

*/
        
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: 
    // =======================================================================================================================================     
    @isTest static void test2() 
    {
        
        
        User u = NI_TestClassData.createTestUser(108, 'System Administrator'); 
        insert u;
        
        // Custom Settings
        system.runAs(u) 
        { 
            NI_TestClassData.createTestWinaproachServiceNowSettings();
        }
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEXT FOR NI_FUNCTIONS_Test Class #1'];
        
        Product_Group__c pgp = [SELECT Id FROM Product_Group__c WHERE Name = 'APEX TEXT FOR NI_FUNCTIONS_Test Class #1'];
        
        Product2 prd1 = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-001', 'Subscription');
        insert prd1;
        
        Product2 prd2 = NI_TestClassData.createProduct2(2, pgp.Id, 'ZZZFULFILL-APEX-002', 'Software');
        insert prd2;
        
        Asset d1 = NI_TestClassData.createTestAsset(1, a.Id, prd1.Id);
        d1.Product_Group__c = pgp.Id;
        insert d1;        
        
        Asset d2 = NI_TestClassData.createTestAsset(2, a.Id, prd2.Id);
        d2.Product_Group__c = pgp.Id;
        insert d2;
        
        Test.startTest();     
        
        Case c1 = NI_TestClassData.createTestCase(1, a.Id);
        c1.AssetId = d1.Id;
        insert c1;        
        
        Case c2 = NI_TestClassData.createTestCase(2, a.Id);
        c2.AssetId = d2.Id;
        insert c2;    
        
        Test.stopTest(); 
        
        c1.AssetId = d2.Id;
        update c1;        
        
        c2.AssetId = d1.Id;
        update c2;             
        
        Set<Id> setDIs = new Set<Id>();        
        setDIs.Add(c1.AssetId);
        setDIs.Add(c2.AssetId);       
        
        Map<Id, Id> mapDHIs = NI_FUNCTIONS.getLatestDIHistoryIDMap(setDIs); 
        system.assertNotEquals(mapDHIs.Size(), 0);
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: 
    // =======================================================================================================================================     
    @isTest static void test3() 
    {
        
        // TEST bypassTriggerCode
        
        NI_TriggerBypassSwitches__c cs = new NI_TriggerBypassSwitches__c();
        cs.Name = 'Bypass Control Panel'; 
        cs.MasterSwitch_ON__c = false; 
        
        cs.BypassAccount_ON__c = true;
        cs.BypassApttusAgreement_ON__c = true;
        cs.BypassAsset_ON__c = true;
        cs.BypassCase_ON__c = true;
        cs.Bypass_AIP_GDS_Monthly_Revenue__c = true;
        cs.BypassNICancellation_ON__c = true;
        cs.BypassNIChangeControl_ON__c = true;
        cs.BypassNICREngagement_ON__c = true;
        cs.BypassNICustomizationDetail_ON__c = true;
        cs.BypassNICustomizationService_ON__c = true;
        cs.BypassNIICEProperty_ON__c = true;
        cs.BypassNIICESubscription_ON__c = true;
        cs.Bypass_NI_License_Audit_ON__c = true;
        cs.BypassNIMilestoneForecast_ON__c = true;
        cs.BypassNIOrgDetails_ON__c = true;
        cs.BypassNIPFyreAgentEvents_ON__c = true;
        cs.BypassNISalesExpenseReport_ON__c = true;
        cs.BypassNIServiceOrder_ON__c = true;
        cs.BypassNICCArtifact_ON__c = true;
        cs.BypassOpportunity_ON__c = true;
        cs.BypassOpportunityProduct_ON__c = true;
        cs.Bypass_NI_Pager_Bonus_ON__c = true;
        cs.Bypass_TopicAssignment_ON__c = true;
        cs.Bypass_PSA_Milestone__c = true;
        cs.Bypass_Softrax_Asset__c = true;
        cs.Bypass_User_ON__c = true;
        cs.BypassProduct2_ON__c = true;
        cs.Bypass_NI_Job_Requisition__c = true;
        cs.Bypass_AIP_GDS_Monthly_Revenue__c = true;
        cs.Bypass_IT_Hardware_Asset_ON__c = true;
        cs.BypassOpportunityAcctPlansStrats__c = true;
        cs.BypassOpportunityContactRoleChecks__c = true;
        cs.BypassOpportunityReleaseDateUpdate__c = true;
        cs.BypassOpportunityRollupAmount__c = true;
        cs.BypassOpportunityHRMProductCreate__c = true;     
        cs.BypassNWSLocation_ON__c = true;
        cs.BypassNWSIServer_ON__c = true;
        cs.BypassNIEmployeePerfEval_ON__c = true;
        cs.Bypass_NI_Customer_Agreement__c = true;
        cs.Bypass_NI_Invoice__c = true;
        cs.Bypass_NI_Invoice_Detail__c = true;
        cs.BypassProductRelease_ON__c = true;
        cs.Bypass_NI_Project_Backlog_ON__c = true;
        cs.Bypass_NI_Project_Backlog_Task_ON__c = true;
        cs.Bypass_ffaRequisitionLineItemTrigger__c = true;
        cs.Bypass_Task_ON__c = true;
        cs.BypassAttachment_ON__c = true;
        cs.BypassCaseComment_ON__c = true;
        cs.BypassCaseReshare_ON__c = true;
        cs.Bypass_Winaproach_ON__c = true;
        cs.BypassMTechSaaS_ON__c = true;
        cs.BypassEmailMessage_ON__c = true;
        cs.BypassSupplyReqMonthlyRenewal_ON__c = true;
        cs.Bypass_Subscription_Activation__c = true;  //ADDED PER NICC-023777
        cs.Bypass_SubscriptionActivationTransaction__c = true;  //ADDED PER NICC-023846
        cs.Bypass_Survey_Response_Data__c = true;  //ADDED PER NICC-023837
        cs.Bypass_Cancellation_Rollup__c = true; //ADDED PER NICC-025668
        cs.BypassCaseFlags_ON__c = true; 				//ADDED PER NICC-026092   
        cs.Bypass_Contact__c = true;  					//ADDED PER NICC-027123
        cs.BypassContactSunsetContact__c = true;  		//ADDED PER NICC-027123          
        cs.Bypass_AH_Account_Product__c = true;
        cs.Bypass_AH_Opportunity_Related_Account__c = true;
        cs.Bypass_NITrustOutageNotifications__c = true;
        
        // ADD NEW TESTS ABOVE HERE ...
        
        insert cs;        
        
        List<NI_TriggerBypassSwitches__c> lstCS = NI_TriggerBypassSwitches__c.getall().values();
        System.assertNotEquals(lstCS.Size(), 0);
        
        Boolean b001 = NI_FUNCTIONS.bypassTriggerCode('ACCOUNT');
        System.assertEquals(b001, true);
        Boolean b002 = NI_FUNCTIONS.bypassTriggerCode('APTTUS AGREEMENT');
        System.assertEquals(b002, true);
        Boolean b003 = NI_FUNCTIONS.bypassTriggerCode('ASSET');
        System.assertEquals(b003, true);
        Boolean b004 = NI_FUNCTIONS.bypassTriggerCode('CASE');
        System.assertEquals(b004, true);
        Boolean b005 = NI_FUNCTIONS.bypassTriggerCode('NI CANCELLATION');
        System.assertEquals(b005, true);
        Boolean b006 = NI_FUNCTIONS.bypassTriggerCode('NI CHANGE CONTROL');
        System.assertEquals(b006, true);
        Boolean b007 = NI_FUNCTIONS.bypassTriggerCode('NI CR ENGAGEMENT');
        System.assertEquals(b007, true);
        Boolean b008 = NI_FUNCTIONS.bypassTriggerCode('NI CUSTOMIZATION');
        System.assertEquals(b008, true);
        Boolean b009 = NI_FUNCTIONS.bypassTriggerCode('NI CUSTOMIZATION SERVICE');
        System.assertEquals(b009, true);
        Boolean b010 = NI_FUNCTIONS.bypassTriggerCode('NI ICE PROPERTY');
        System.assertEquals(b010, true);
        Boolean b011 = NI_FUNCTIONS.bypassTriggerCode('NI ICE SUBSCRIPTION');
        System.assertEquals(b011, true);
        Boolean b012 = NI_FUNCTIONS.bypassTriggerCode('NI MILESTONE FORECAST');
        System.assertEquals(b012, true);
        Boolean b013 = NI_FUNCTIONS.bypassTriggerCode('NI ORG DETAILS');
        System.assertEquals(b013, true);
        Boolean b014 = NI_FUNCTIONS.bypassTriggerCode('NI PRAIRIEFYRE AGENT EVENTS');
        System.assertEquals(b014, true);
        Boolean b015 = NI_FUNCTIONS.bypassTriggerCode('NI SALES EXPENSE REPORT');
        System.assertEquals(b015, true);
        Boolean b016 = NI_FUNCTIONS.bypassTriggerCode('NI SERVICE ORDER');
        System.assertEquals(b016, true);
        Boolean b017 = NI_FUNCTIONS.bypassTriggerCode('NICC ARTIFACT');
        System.assertEquals(b017, true);
        Boolean b018 = NI_FUNCTIONS.bypassTriggerCode('OPPORTUNITY');
        System.assertEquals(b018, true);
        Boolean b019 = NI_FUNCTIONS.bypassTriggerCode('OPPORTUNITY PRODUCT');
        System.assertEquals(b019, true);
        Boolean b020 = NI_FUNCTIONS.bypassTriggerCode('PAGER BONUS');
        System.assertEquals(b020, true);
        Boolean b021 = NI_FUNCTIONS.bypassTriggerCode('TOPIC ASSIGNMENT');
        System.assertEquals(b021, true);
        Boolean b022 = NI_FUNCTIONS.bypassTriggerCode('PSA MILESTONE');
        System.assertEquals(b022, true);
        Boolean b023 = NI_FUNCTIONS.bypassTriggerCode('SOFTRAX ASSET');
        System.assertEquals(b023, true);
        Boolean b024 = NI_FUNCTIONS.bypassTriggerCode('PRODUCT2');
        System.assertEquals(b024, true);
        Boolean b025 = NI_FUNCTIONS.bypassTriggerCode('NI JOB REQUISITION');
        System.assertEquals(b025, true);
        Boolean b026 = NI_FUNCTIONS.bypassTriggerCode('USER');
        System.assertEquals(b026, true);
        Boolean b027 = NI_FUNCTIONS.bypassTriggerCode('GDS MONTHLY REVENUE');
        System.assertEquals(b027, true);
        Boolean b028 = NI_FUNCTIONS.bypassTriggerCode('IT HARDWARE ASSET');        
        System.assertEquals(b028, true);       
        Boolean b029 = NI_FUNCTIONS.bypassTriggerCode('Bypass Opportunity - Acct Plans & Strats');
        System.assertEquals(b029, true);
        Boolean b030 = NI_FUNCTIONS.bypassTriggerCode('Bypass Opportunity - Contact Role Checks');
        System.assertEquals(b030, true);
        //        Boolean b031 = NI_FUNCTIONS.bypassTriggerCode('Bypass Opportunity - Embrace');
        //        System.assertEquals(b031, true);
        Boolean b032 = NI_FUNCTIONS.bypassTriggerCode('Bypass Opportunity - Release Date Update');
        System.assertEquals(b032, true);
        Boolean b033 = NI_FUNCTIONS.bypassTriggerCode('Bypass Opportunity - Rollup Amount');
        System.assertEquals(b033, true);        
        Boolean b034 = NI_FUNCTIONS.bypassTriggerCode('Bypass Opportunity - HRM Product Create');
        System.assertEquals(b034, true);
        Boolean b035 = NI_FUNCTIONS.bypassTriggerCode('NI LICENSE AUDIT');
        System.assertEquals(b035, true);
        Boolean b036 = NI_FUNCTIONS.bypassTriggerCode('NWS Location');
        System.assertEquals(b036, true);
        Boolean b037 = NI_FUNCTIONS.bypassTriggerCode('NWS IServer');
        System.assertEquals(b037, true);
        Boolean b038 = NI_FUNCTIONS.bypassTriggerCode('PERFORMANCE EVALUATION');
        System.assertEquals(b038, true);
        Boolean b039 = NI_FUNCTIONS.bypassTriggerCode('NI CUSTOMER AGREEMENT');
        System.assertEquals(b039, true);
        Boolean b040 = NI_FUNCTIONS.bypassTriggerCode('NI INVOICE');
        System.assertEquals(b040, true);
        Boolean b041 = NI_FUNCTIONS.bypassTriggerCode('NI INVOICE DETAIL');
        System.assertEquals(b041, true);
        Boolean b042 = NI_FUNCTIONS.bypassTriggerCode('PRODUCT RELEASE');
        System.assertEquals(b042, true);        
        Boolean b043 = NI_FUNCTIONS.bypassTriggerCode('NI PROJECT BACKLOG');
        System.assertEquals(b043, true);
        Boolean b044 = NI_FUNCTIONS.bypassTriggerCode('NI PROJECT BACKLOG TASK');
        System.assertEquals(b044, true);
        Boolean b045 = NI_FUNCTIONS.bypassTriggerCode('REQUISITION LINE ITEM');
        System.assertEquals(b045, true);
        Boolean b046 = NI_FUNCTIONS.bypassTriggerCode('TASK');
        System.assertEquals(b046, true);
        Boolean b047 = NI_FUNCTIONS.bypassTriggerCode('ATTACHMENT');
        System.assertEquals(b047, true);
        Boolean b048 = NI_FUNCTIONS.bypassTriggerCode('CASECOMMENT');
        System.assertEquals(b048, true);
        Boolean b049 = NI_FUNCTIONS.bypassTriggerCode('CASE RESHARE');
        System.assertEquals(b049, true);
        Boolean b050 = NI_FUNCTIONS.bypassTriggerCode('WIN@PROACH');
        System.assertEquals(b050, true);
        Boolean b051 = NI_FUNCTIONS.bypassTriggerCode('MTECH SaaS');
        System.assertEquals(b051, true);
        Boolean b052 = NI_FUNCTIONS.bypassTriggerCode('EMAILMESSAGE');
        System.assertEquals(b052, true);
        Boolean b053 = NI_FUNCTIONS.bypassTriggerCode('SUPPLYREQRENEWAL');
        System.assertEquals(b053, true);
        Boolean b054 = NI_FUNCTIONS.bypassTriggerCode('SUBSCRIPTION ACTIVATION');  //ADDED PER NICC-023777
        System.assertEquals(b054, true);
        Boolean b055 = NI_FUNCTIONS.bypassTriggerCode('SURVEY RESPONSE DATA');  //ADDED PER NICC-023837
        System.assertEquals(b055, true);
        Boolean b056 = NI_FUNCTIONS.bypassTriggerCode('SUBSCRIPTION ACTIVATION TRANSACTION');  //ADDED PER NICC-023846
        System.assertEquals(b056, true); 
        Boolean b057 = NI_FUNCTIONS.bypassTriggerCode('CANCELLATION ROLLUP');  //ADDED PER NICC-025668
        System.assertEquals(b057, true);
        Boolean b058 = NI_FUNCTIONS.bypassTriggerCode('CASE FLAGS');  			//ADDED PER NICC-026092
        System.assertEquals(b058, true);
        Boolean b059 = NI_FUNCTIONS.bypassTriggerCode('CONTACT');  				//ADDED PER NICC-027123
        System.assertEquals(b059, true);
        Boolean b060 = NI_FUNCTIONS.bypassTriggerCode('SUNSET CONTACT'); 		//ADDED PER NICC-027123 
        System.assertEquals(b060, true);
        Boolean b061 = NI_FUNCTIONS.bypassTriggerCode('AH ACCOUNT PRODUCT');
        System.assertEquals(b061, true);
        Boolean b062 = NI_FUNCTIONS.bypassTriggerCode('AH OPPORTUNITY RELATED ACCOUNT');
        System.assertEquals(b062, true);
        Boolean b063 = NI_FUNCTIONS.bypassTriggerCode('OUTAGE NOTIFICATION'); 		 
        System.assertEquals(b063, true);
        
        // ADD NEW TESTS ABOVE HERE ...
        
        cs.MasterSwitch_ON__c = true;
        update cs;
        
        Boolean bMasterSwitchTest = NI_FUNCTIONS.bypassTriggerCode('APEX TEST VALUE');  
        System.assertEquals(bMasterSwitchTest, true);
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 4: 
    // =======================================================================================================================================     
    @isTest static void test4() 
    {
        
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator'); 
        insert u;
        
        NI_Departments__c d = NI_TestClassData.createTestNI_Department(1);
        insert d;
        
        NI_Location__c l = NI_TestClassData.createTestNI_Location(1);
        insert l;
        
        NI_Department_to_Location__c d2l = NI_TestClassData.createTestNI_DepartmentToLocation(1, d.Id, l.Id, u.Id, 'Exec Member');
        insert d2l;
        
        Id idExecMem = NI_FUNCTIONS.getExecMember(l.Id, d.Id);
        
        String sRoleName = 'CEO/CFO';
        Id rID = NI_FUNCTIONS.getRoleId(sRoleName);
        system.assertNotEquals(null, rID);
        
        String sProfileName = 'System Administrator';
        Id pID = NI_FUNCTIONS.getProfileId(sProfileName);        
        system.assertNotEquals(null, pID); 
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEXT FOR NI_FUNCTIONS_Test Class #1'];
            
        Set<Id> setNoChildIds = NI_FUNCTIONS.getAllChildAccIdsInHierarchy(a.Id, 1);
        system.debug(' *^* setNoChildIds = ' + setNoChildIds.size());
        system.assertEquals(1, setNoChildIds.size());         
        
        Account acc1 = NI_TestClassData.createTestAccount(1);
        acc1.Name = 'NI_FUNCTIONS_Test Child Account';
        acc1.ParentId = a.Id;
        insert acc1;
        
        List<SelectOption> lstSOs = NI_FUNCTIONS.getPicklistValues(acc1, 'Type');
        system.debug(' *^* lstSOs = ' + lstSOs.size());
        system.assertNotEquals(0, lstSOs.size()); 
        
        Set<Id> setChildIds = NI_FUNCTIONS.getAllChildAccIdsInHierarchy(a.Id, 1);
        system.debug(' *^* setChildIds = ' + setChildIds.size());
        system.assertEquals(2, setChildIds.size()); 
        
        Map<String, Account> mapChildIds = NI_FUNCTIONS.getAccountHierarchy(a.Id, 1);
        system.debug(' *^* mapChildIds = ' + mapChildIds.size());
        system.assertEquals(2, mapChildIds.size());  
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 5: PARTNER CENTRAL FORMS Testing
    // =======================================================================================================================================     
    @isTest static void test5() 
    {     
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtId = AccountRecordTypeInfo.get('Partner Account').getRecordTypeId();
        
        // CREATE ACCOUNT TEST RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX NI_FUNCTIONS_Test Class Partners';
        a.RecordTypeId = rtId;
        insert a;        
        
        Partners_Form_Template__c pft = NI_TestClassData.createPartnersFormTemplate();
        pft.Subject__c = 'APEX SUBJECT #1'; 
        insert pft;
        
        Partners_Form_Template_to_Account__c pft2a = NI_TestClassData.createPartnersFormTemplate2Account(pft.Id, a.Id);
        insert pft2a;        
        
        Contact con = NI_TestClassData.createTestContact(1, a.Id);
        insert con;  
        
        User u = NI_TestClassData.createTestUser(1, 'AH PartnerCentral Login User'); 
        u.ContactId = con.Id;
        u.Alias = 'PARTTST1'; 
        insert u;
        
        //        system.runAs(u) {
        // statements to be executed by this test user.
        //        }        
        
        User userAssert1 = [SELECT Id, Partner_Terms_Accepted__c FROM User WHERE Alias = 'PARTTST1'];
        system.assertEquals('False', userAssert1.Partner_Terms_Accepted__c);
        
        system.assertEquals(false, NI_FUNCTIONS.allFormsAccepted(a.Id));
        
        Test.startTest();        
        pft2a.IP_Address__c = '0.0.0.0';
        pft2a.Date_Accepted__c = DateTime.Now();
        pft2a.Accepted_Terms__c = true;
        pft2a.Accepted_By__c = u.Id;
        update pft2a; 
        Test.stopTest();
        
        system.assertEquals(true, NI_FUNCTIONS.allFormsAccepted(a.Id));
        
        //        List<Contract> lstContractAsserts = new List<Contract>([SELECT Id FROM Contract WHERE AccountId =: a.Id AND ct_ContactIPAddress__c = '0.0.0.0']);
        //       system.assertEquals(1, lstContractAsserts.size());
        
        User userAssert2 = [SELECT Id, Partner_Terms_Accepted__c FROM User WHERE Alias = 'PARTTST1'];
        system.assertEquals('True', userAssert2.Partner_Terms_Accepted__c); 
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 6: Test findObjectNameFromRecordIdPrefix Function
    // =======================================================================================================================================    
    @isTest static void test6() 
    {  
        string strObjName = NI_FUNCTIONS.findObjectNameFromRecordIdPrefix('0013000000DZTOMAA5'); 
        system.assertEquals('Account', strObjName);
        strObjName = NI_FUNCTIONS.findObjectNameFromRecordIdPrefix(null); 
        system.assertEquals('', strObjName);
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 7: 
    // =======================================================================================================================================    
    @isTest static void test7() 
    {   
        
        Asset di = [SELECT Id, Quantity_Ordered__c FROM Asset WHERE ProductCode = 'APEX-TEST-01'];
        Opportunity opp1 = [SELECT Id, StageName, Order_Status__c FROM Opportunity WHERE Name = '!! APEX TEST WITH LARGE DEAL OPPORTUNITY RECORD TYPE !!'];

        system.debug(' *^* TURNING OPPTY CLOSED WON');
        
        // TEST ROLLUP OF Quantity_Ordered__c WHEN AN OPPORTUNITY Order Status IS TURNED
        opp1.StageName = 'Closed Won';
        opp1.Order_Status__c = 'Definite';
        update opp1;
        
        di.Quantity_Ordered__c = 10;
        update di; 
        
        List<OpportunityLineItem> lstOLIUpdates = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem oli : [SELECT Id, Quantity FROM OpportunityLineItem WHERE OpportunityId =: opp1.Id])
        {
            oli.Quantity = 10;
            lstOLIUpdates.add(oli);
        }

        system.debug(' *^* lstOLIUpdates.size() = ' + lstOLIUpdates.size());
        update lstOLIUpdates;        
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 8: Test FileSizeToString Function
    // =======================================================================================================================================    
    @isTest static void test8() 
    {   
        
        String strBytes = NI_FUNCTIONS.FileSizeToString(500);
        system.assertEquals('500 Bytes', strBytes);
        
        String strKBs = NI_FUNCTIONS.FileSizeToString(2048);
        system.assertEquals('2.00 KB', strKBs);
        
        String strMBs = NI_FUNCTIONS.FileSizeToString(1048576);
        system.assertEquals('1.00 MB', strMBs);
        
        String strGBs = NI_FUNCTIONS.FileSizeToString(1073741824);
        system.assertEquals('1.00 GB', strGBs);
        
    }    
    



    // ======================================================================================================================================= 
    // = TEST METHOD 6: Test GetDependentOptions Function
    // =======================================================================================================================================    
/*
    @isTest static void test6() 
    {     
        
        Map<String, List<String>> m = NI_FUNCTIONS.GetDependentOptions('NI_Cancellation__c', 'Renewal_Cancellation_Reason__c', 'General_Reason__c');
        system.assertNotEquals(0, m.size());
        
        Map<String, List<String>> m2 = NI_FUNCTIONS.GetDependentOptions('BAD_NI_Cancellation__c', 'Renewal_Cancellation_Reason__c', 'General_Reason__c');
        system.assertEquals(0, m2.size());        
        
        String strObjectName1 = NI_FUNCTIONS.findObjectNameFromRecordIdPrefix(null);   
        system.assertEquals(strObjectName1, '');
        
        String strObjectName2 = NI_FUNCTIONS.findObjectNameFromRecordIdPrefix('500');
        system.assertEquals(strObjectName2, 'Case');
        
        //String objectName2 = NI_FUNCTIONS.findObjectNameFromRecordIdPrefix('500');
        //system.assertNotEquals(objectName2, 'Account');
        
        //String objectName3 = NI_FUNCTIONS.findObjectNameFromRecordIdPrefix('101');
        //system.assertEquals(objectName3, '');
        
        //String objectName4 = NI_FUNCTIONS.findObjectNameFromRecordIdPrefix('10');
        //system.assertEquals(objectName4, '');        
        
    }
*/

    
    // ======================================================================================================================================= 
    // = TEST METHOD 8: 
    // =======================================================================================================================================    
    @isTest static void testNIFunctions8() 
    {   
        Test.startTest();
        Asset di = [SELECT Id, Quantity_Ordered__c FROM Asset WHERE ProductCode = 'APEX-TEST-01'];
        Opportunity opp1 = [SELECT Id, StageName, Order_Status__c FROM Opportunity WHERE Name = '!! APEX TEST WITH LARGE DEAL OPPORTUNITY RECORD TYPE !!'];
        system.debug('opp1 : '+opp1);

        List<OpportunityLineItem> oliList = [SELECT DeploymentInstance__c, Quantity, Product2.Family, Product2.Unit__c, Product2.License_Type__c, Opportunity.Order_Status__c 
                                             FROM OpportunityLineItem 
                                             WHERE OpportunityId =: opp1.id];
        
        system.debug('test class oliList : '+oliList);
        system.debug('test class oliList size : '+oliList.size());

        
        // CREATE ACCOUNT TEST RECORD ===============================================================
        Account a2 = NI_TestClassData.createTestAccount(21); 
        a2.Name = 'APEX TEXT FOR NI_FUNCTIONS_Test Class #2';
        a2.BillingPostalCode = '0301';
        a2.BillingCountry = 'IN';
        a2.BillingState = 'MH';
        a2.BillingStreet = '75 NH Avee';
        a2.BillingCity = 'Pune';
        a2.Type = 'Customer';
        a2.ShippingPostalCode = '0301';
        a2.ShippingCountry = 'IN';
        a2.ShippingState = 'MH';
        a2.ShippingStreet = '75 NH Avee';
        a2.ShippingCity = 'Pune';
        insert a2;
        
        // CREATE CONTACT TEST RECORD 
        Contact c2 = NI_TestClassData.createTestContact(2, a2.Id);
        c2.FirstName = 'Apex2';
        c2.LastName = 'Testuser2';        
        insert c2; 
        
        
        //INSERT RELATED OPPORTUNITY LINE ITEM
        List<AH_Account_Product__c> accProductList = new List<AH_Account_Product__c>();
        AH_Account_Product__c accPrd1 = new AH_Account_Product__c();
        accPrd1.Account__c = a2.id;
        accPrd1.Product__c = oliList[0].Product2.Id;
        accPrd1.Quantity__c = 4;
        accPrd1.Opportunity__c = opp1.Id;
        accPrd1.Deployment_Instance__c = di.id;
        accProductList.add(accPrd1);
        Database.insert(accProductList);
        
        
        // TEST ROLLUP OF Quantity_Ordered__c WHEN AN OPPORTUNITY Order Status IS TURNED
        opp1.StageName = 'Closed Won';
        opp1.Order_Status__c = 'Definite';
        update opp1;
        
        Opportunity opp11 = [SELECT Id, StageName, Order_Status__c FROM Opportunity WHERE id =: opp1.id];
        //system.debug('opp11 : '+opp11);
        
        di.Quantity_Ordered__c = 10;
        update di;        
        
        Test.stopTest();
        
        Set<Id> setDeploymentInstanceIds = new Set<Id>();
        setDeploymentInstanceIds.add(di.id);
        //system.debug('tets class : '+setDeploymentInstanceIds);
        List<AH_Account_Product__c> accProductList1 = [SELECT Deployment_Instance__c, Quantity__c,
                                                      Product__r.Family, Product__r.Unit__c, Product__r.License_Type__c,
                                                      Opportunity__r.Order_Status__c 
                                                      FROM AH_Account_Product__c 
                                                      WHERE (Opportunity__r.StageName = 'Closed Won' OR Opportunity__r.StageName = 'Sold')
                                                      AND (Product__r.DI_Index__c != null OR Product__r.DI_Index__r.Name != 'N/A') 
                                                      AND Deployment_Instance__c IN : setDeploymentInstanceIds];
        
        system.debug('test class accProductList1 : '+accProductList1);
        system.assertNotEquals(NULL, accProductList1[0].Deployment_Instance__c);
        
        NI_FUNCTIONS.updateDIRollupSummaryFields1(setDeploymentInstanceIds);

    }
    
}