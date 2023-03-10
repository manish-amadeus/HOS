/****************************************************************************************
Name            : AH_createUpdateDIForOLI_Batch_Test
Author          : Shashikant Nikam
Created Date    : 11/21/2019
Last Mod Date   : 11/21/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for AH_LinkAccountWithProduct_Ext
				:
******************************************************************************************/
@isTest
public class AH_createUpdateDIForOLI_Batch_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {        
        
        system.debug(' *** START NI_Opportunity_TrigHndlr_Test.createTestData()'); 
        
        test.startTest();  
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtLargeDealId = OpportunityRecordTypeInfo.get('Large Deal Opportunity').getRecordTypeId();
        Id rtMTechNewId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId(); 
        Id rtSmallDealId = OpportunityRecordTypeInfo.get('Small Deal Opportunity').getRecordTypeId();   
        Id rtSalesOrderId = OpportunityRecordTypeInfo.get('Sales Order').getRecordTypeId(); 
        Id rtHRMAMOId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId(); 
        
        // CREATE A TEST USER WITH THE NI ADMINISTRATOR PROFILE TO USE AS THE RUNAS USER
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        u.FirstName = 'Apex';
        u.LastName = 'Testuser';
        insert u;    
        
        // CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TESTER ACCOUNT'; 
        insert a;
        
        Account a7 = NI_TestClassData.createTestAccount(7);
        a7.Name = 'TEST ACCOUNT NUMBER 7'; 
        insert a7;
        
        // CREATE TEST CONTACT RECORD 
        //        NI_TestClassData.disable_PSE_WebCallout();
        Contact c = NI_TestClassData.createTestContact(1, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuser';        
        insert c; 
        
        // CREATE A TEST MARKETING QUALIFIED LEAD RECORD RECORD  
        Marketing_Qualified_Lead__c mql = NI_TestClassData.createTestMarketingQualifiedLead(c.Id);
        insert mql;     
        
        // CREATE ACCT PLAN RECORD
        SFDC_Acct_Plan__c apln = NI_TestClassData.createAccountPlan(1, a.Id);
        insert apln;
        
        // CREATE STRATEGY RECORD
        SFDC_Strategy__c stgy = NI_TestClassData.createStrategy(1, a.Id, apln.Id);
        //        stgy.Invoke_Rollups__c = true;
        insert stgy;        
        
        
        // INSERT A TEST RECORD INTO THE HRM_AppsDI_Insert_Products__c CUSTOM SETTING  
        List<HRM_AppsDI_Insert_Products__c> lstHRMApps = new List<HRM_AppsDI_Insert_Products__c>(); 
        
        HRM_AppsDI_Insert_Products__c csHRM1 = new HRM_AppsDI_Insert_Products__c();
        csHRM1.Name = 'APEX-TEST-01';
        lstHRMApps.add(csHRM1);
        HRM_AppsDI_Insert_Products__c csHRM2 = new HRM_AppsDI_Insert_Products__c();
        csHRM2.Name = 'APEX-TEST-02';
        lstHRMApps.add(csHRM2);
        HRM_AppsDI_Insert_Products__c csHRM3 = new HRM_AppsDI_Insert_Products__c();
        csHRM3.Name = 'APEX-TEST-03';
        lstHRMApps.add(csHRM3);
        HRM_AppsDI_Insert_Products__c csHRM4 = new HRM_AppsDI_Insert_Products__c();
        csHRM4.Name = 'APEX-TEST-04';
        lstHRMApps.add(csHRM4);
        
        Database.Insert(lstHRMApps);    
        
        // CREATE TEST PRODUCT GROUP RECORD
        List<Product_Group__c> lstPGs = new List<Product_Group__c>();
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        lstPGs.Add(pgp);
        Product_Group__c pgp2 = NI_TestClassData.createProductGroup(2, 'Salesforce');
        lstPGs.Add(pgp2);
        
        Database.Insert(lstPGs);         
        
        system.assertNotEquals(null, pgp.Id);
        system.assertNotEquals(null, pgp2.Id);
        
        // CREATE TEST DI INDEX RECORDS
        List<NI_DeploymentInstanceIndex__c> lstDI_Indx = new List<NI_DeploymentInstanceIndex__c>();
        
        NI_DeploymentInstanceIndex__c diIdx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST');
        lstDI_Indx.add(diIdx1);
        NI_DeploymentInstanceIndex__c diIdx2 = NI_TestClassData.createDI_Index(2, 'APEX TEST');
        lstDI_Indx.add(diIdx2);
        NI_DeploymentInstanceIndex__c diIdx3 = NI_TestClassData.createDI_Index(3, 'APEX TEST');
        lstDI_Indx.add(diIdx3);
        NI_DeploymentInstanceIndex__c diIdx4 = NI_TestClassData.createDI_Index(4, 'APEX TEST');
        lstDI_Indx.add(diIdx4);
        NI_DeploymentInstanceIndex__c diIdx5 = NI_TestClassData.createDI_Index(5, 'APEX TEST');
        lstDI_Indx.add(diIdx5);
        NI_DeploymentInstanceIndex__c diIdx6 = NI_TestClassData.createDI_Index(6, 'APEX TEST');
        lstDI_Indx.add(diIdx6);
        NI_DeploymentInstanceIndex__c diIdx7 = NI_TestClassData.createDI_Index(7, 'APEX TEST');
        lstDI_Indx.add(diIdx7);
        NI_DeploymentInstanceIndex__c diIdx8 = NI_TestClassData.createDI_Index(8, 'APEX TEST');
        lstDI_Indx.add(diIdx8);
        NI_DeploymentInstanceIndex__c diIdx9 = NI_TestClassData.createDI_Index(9, 'APEX TEST');
        lstDI_Indx.add(diIdx9);
        NI_DeploymentInstanceIndex__c diIdx10 = NI_TestClassData.createDI_Index(10, 'APEX TEST');
        lstDI_Indx.add(diIdx10);
        
        NI_DeploymentInstanceIndex__c diIdx11 = NI_TestClassData.createDI_Index(11, 'APEX TEST');
        lstDI_Indx.add(diIdx11);
        
        NI_DeploymentInstanceIndex__c diIdx12 = NI_TestClassData.createDI_Index(12, 'APEX TEST');
        lstDI_Indx.add(diIdx12);
        
        Database.Insert(lstDI_Indx); 
        
        // CREATE TEST PRODUCT RECORDS 
        // VALIDATION RULES:
        // Has_Options_Checked_RevCategory_Required - Revenue Category is required when "Has Options" field is not checked
        // Has_Options_Unchecked_No_Rev_Category    - Revenue Category has to be blank when "Has Options" field is checked
        
        List<Product2> lstProds = new List<Product2>();
        
        Product2 p2_1 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Support');
        p2_1.DI_Index__c = diIdx1.Id;
        p2_1.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_1);
        
        Product2 p2_2 = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-02', 'Subscription');
        p2_2.DI_Index__c = diIdx2.Id;
        p2_2.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_2);
        
        Product2 p2_3 = NI_TestClassData.createProduct2(3, pgp.Id, 'APEX-TEST-03', 'Software');
        p2_3.DI_Index__c = diIdx3.Id;
        p2_3.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_3);
        
        Product2 p2_4 = NI_TestClassData.createProduct2(4, pgp.Id, 'APEX-TEST-04', 'Services');
        p2_4.DI_Index__c = diIdx4.Id;
        p2_4.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_4);
        
        Product2 p2_5 = NI_TestClassData.createProduct2(5, pgp.Id, 'APEX-TEST-05', 'Hosting');
        p2_5.DI_Index__c = diIdx5.Id;
        p2_5.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_5);
        
        //        Product2 p2_6 = NI_TestClassData.createProduct2(6, pgp.Id, 'APEX-TEST-06', 'MTech');
        //        p2_6.DI_Index__c = diIdx6.Id;
        //        p2_6.Apttus_Config2__HasOptions__c = true;
        //        lstProds.add(p2_6);
        
        Product2 p2_7 = NI_TestClassData.createProduct2(7, pgp.Id, 'APTTUS-TEST-BUNDLE', 'Subscription');
        p2_7.DI_Index__c = diIdx7.Id;
        p2_7.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_7);
        
        Product2 p2_8 = NI_TestClassData.createProduct2(8, pgp.Id, 'APTTUS-TEST-BUNDLE2', 'Subscription');
        p2_8.DI_Index__c = diIdx8.Id;
        p2_8.Apttus_Config2__ConfigurationType__c = 'Bundle';
        p2_8.Revenue_Category__c = '';
        p2_8.Apttus_Config2__HasOptions__c = true;
        lstProds.add(p2_8);
        
        Product2 p2_9 = NI_TestClassData.createProduct2(9, pgp2.Id, 'APEX-TEST-09', 'Subscription'); 
        p2_9.DI_Index__c = diIdx9.Id;
        p2_9.Line__c = 'License'; 
        p2_9.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_9); 
        
        Product2 p2_10 = NI_TestClassData.createProduct2(10, pgp.Id, 'ZZZ-HRM-001', 'Subscription'); 
        p2_10.DI_Index__c = diIdx10.Id;
        p2_10.DI_DefaultStatus__c = 'Purchased';
        p2_10.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_10);           
        
        Product2 p2_11 = NI_TestClassData.createProduct2(11, pgp.Id, 'ZZZ-HRM-002 DI', 'Subscription'); 
        p2_11.DI_Index__c = diIdx11.Id;
        p2_11.DI_DefaultStatus__c = 'Installed';
        p2_11.DI_Priority__c = 200;
        p2_11.Unit__c = 'User';
        p2_11.Family = 'Software';
        p2_11.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_11); 
        
        Product2 p2_12 = NI_TestClassData.createProduct2(12, pgp.Id, 'ZZZ-HRM-002 DI 2', 'Subscription'); 
        p2_12.DI_Index__c = diIdx11.Id;
        p2_12.DI_DefaultStatus__c = 'Purchased';
        p2_12.Unit__c = 'User';
        p2_12.Family = 'Subscription';
        p2_12.License_Type__c = 'Limited';
        p2_12.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_12);         
        
        Product2 p2_13 = NI_TestClassData.createProduct2(13, pgp.Id, 'ZZZ-HRM-002 DI 3', 'Subscription'); 
        p2_13.DI_Index__c = diIdx11.Id;
        p2_13.DI_DefaultStatus__c = 'Installed';
        p2_13.DI_Priority__c = 300;
        p2_13.Unit__c = 'User';
        p2_13.Family = 'Subscription';
        p2_13.License_Type__c = 'Limited';
        p2_13.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_13); 
        
        Product2 p2_14 = NI_TestClassData.createProduct2(14, pgp.Id, 'ZZZ-HRM-002 DI 4', 'Subscription'); 
        p2_14.DI_Index__c = diIdx11.Id;
        p2_14.DI_DefaultStatus__c = 'Purchased';
        p2_14.Unit__c = 'User';
        p2_14.Family = 'Subscription';
        p2_14.License_Type__c = 'Full';
        p2_14.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_14); 
        
        Product2 p2_15 = NI_TestClassData.createProduct2(15, pgp.Id, 'ZZZ-HRM-002 DI 5', 'Subscription'); 
        p2_15.DI_Index__c = diIdx12.Id;
        p2_15.DI_DefaultStatus__c = 'Purchased';
        p2_15.Unit__c = 'User';
        p2_15.Family = 'Subscription';
        p2_15.License_Type__c = 'Full';
        p2_15.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_15); 
        
        Product2 p2_16 = NI_TestClassData.createProduct2(16, pgp.Id, 'ZZZ-HRM-002 DI 6', 'Subscription'); 
        p2_16.DI_Index__c = diIdx12.Id;
        p2_16.Unit__c = 'User';
        p2_16.Family = 'Subscription';
        p2_16.License_Type__c = 'Full';
        p2_16.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_16); 
        
        Database.Insert(lstProds); 
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset asset1 = NI_TestClassData.createTestAsset(1, a.Id, p2_1.Id);
        asset1.Status = 'Purchased';
        asset1.Product_Group__c = pgp.Id;
        Insert asset1; 
        
        // CREATE TEST CUSTOM SETTINGS DATA FOR NI_ZZZ_HRM_Product__c ============================================================================================
        List<NI_ZZZ_HRM_Product__c> lstCustomSettings = new List<NI_ZZZ_HRM_Product__c>();        
        lstCustomSettings.Add(new NI_ZZZ_HRM_Product__c(Name='ZZZ-HRM-001', Product2Id__c = p2_10.Id, DI_DefaultStatus__c ='Purchased'));
        
        Database.Insert(lstCustomSettings);      
        
        // GET DISTINCT LIST OF FAMILIES
        Map<String, Product2> mapFamilies = new Map<String, Product2>();
        
        for (Product2 prd : [SELECT Family FROM Product2 WHERE IsActive = true AND Family != null])
        {
            if (!mapFamilies.containsKey(prd.Family))
            {
                mapFamilies.put(prd.Family, prd);
            }
        }
        
        // CREATE TEST ROLLUP AMOUNT CUSTOM SETTINGS
        List<NI_OpportunityCalculatedAmount__c> lstCustSets = NI_OpportunityCalculatedAmount__c.getAll().values();
        
        Set<String> setCustSetRecTypes = new Set<String>();
        
        for (NI_OpportunityCalculatedAmount__c lCS : lstCustSets)
        {
            setCustSetRecTypes.add(lCS.Opportunity_Record_Type_Name__c);                
        }
        
        List<NI_OpportunityCalculatedAmount__c> lstCS = new List<NI_OpportunityCalculatedAmount__c>();
        Integer iRecTypeCount = 0;
        
        // POPULATE CUSTOM SETTINGS
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
        
        
        // CREATE TEST PRICEBOOK ENTRY RECORDS
        List<PricebookEntry> lstPBEs = new List<PricebookEntry>();
        
        Id pbkId = Test.getStandardPricebookId(); 
        
        PricebookEntry pbe1 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_1.Id, 1000);
        lstPBEs.add(pbe1); 
        PricebookEntry pbe2 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_2.Id, 1000);
        lstPBEs.add(pbe2); 
        PricebookEntry pbe3 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_3.Id, 1000);
        lstPBEs.add(pbe3); 
        PricebookEntry pbe4 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_4.Id, 1000);
        lstPBEs.add(pbe4); 
        PricebookEntry pbe5 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_5.Id, 1000);
        lstPBEs.add(pbe5); 
        //        PricebookEntry pbe6 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_6.Id, 1000);
        //        lstPBEs.add(pbe6);         
        PricebookEntry pbe7 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_7.Id, 1000);
        lstPBEs.add(pbe7); 
        PricebookEntry pbe8 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_8.Id, 1000);
        lstPBEs.add(pbe8); 
        PricebookEntry pbe9 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_9.Id, 1);
        lstPBEs.add(pbe9); 
        PricebookEntry pbe10 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_10.Id, 1);
        lstPBEs.add(pbe10); 
        
        PricebookEntry pbe11 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_11.Id, 1);
        lstPBEs.add(pbe11); 
        
        PricebookEntry pbe13 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_13.Id, 1);
        lstPBEs.add(pbe13); 
        
        PricebookEntry pbe14 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_14.Id, 1);
        lstPBEs.add(pbe14);
        
        PricebookEntry pbe15 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_15.Id, 1);
        lstPBEs.add(pbe15);
        
        Database.Insert(lstPBEs);   
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>([select name from PricebookEntry where id =: pbe10.id]);
        system.debug('pbeList : '+pbeList);
        
        List<PricebookEntry> pbeList1 = new List<PricebookEntry>([select name from PricebookEntry where id =: pbe11.id]);
        system.debug('pbeList1 : '+pbeList1);
        
        
        
        // CREATE TEST OPPORTUNITY RECORDS
        List<Opportunity> lstOpptys = new List<Opportunity>();
        
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id);
        //opp1.StageName = 'Closed Won';
        opp1.RecordTypeId = rtSmallDealId;
        opp1.Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1';
        opp1.Strategy__c = stgy.Id;
        lstOpptys.add(opp1);
        
        Opportunity opp2 = NI_TestClassData.createTestOpportunity(2, a.Id); 
        opp2.RecordTypeId = rtSmallDealId;   
        opp2.Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 2';
        lstOpptys.add(opp2);
        
        Opportunity opp3 = NI_TestClassData.createTestOpportunity(3, a.Id); 
        opp3.RecordTypeId = rtLargeDealId; 
        opp3.Name = 'APEX TEST - LARGE DEAL OPPORTUNITY 1';
        lstOpptys.add(opp3);    
        
        Opportunity opp4 = NI_TestClassData.createTestOpportunity(4, a.Id); 
        opp4.RecordTypeId = rtMTechNewId; 
        opp4.Name = 'APEX TEST - HRM NEW OPPORTUNITY 1';
        lstOpptys.add(opp4);
        
        Opportunity opp5 = NI_TestClassData.createTestOpportunity(5, a.Id); 
        opp5.RecordTypeId = rtSmallDealId;
        opp5.Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 3';
        opp5.Marketing_Qualified_Lead__c = mql.Id;
        lstOpptys.add(opp5);
        
        Opportunity opp6 = NI_TestClassData.createTestOpportunity(6, a.Id); 
        opp6.RecordTypeId = rtHRMAMOId;
        opp6.Name = 'APEX TEST - HRM OPPORTUNITY';
        //      opp6.StageName = 'Closed Won';
        //      opp6.Order_Status__c = 'Integrated';
        lstOpptys.add(opp6);
        
        Opportunity opp7 = NI_TestClassData.createTestOpportunity(7, a7.Id); 
        opp7.RecordTypeId = rtHRMAMOId;
        opp7.Name = 'APEX TEST - HRM OPPORTUNITY DI';
        lstOpptys.add(opp7);
        
        Database.Insert(lstOpptys);
        
        // CREATE TEST OPPORTUNITY CONTACT ROLE RECORDS ==================================================================================
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
        // Sponsor Contact 
        OpportunityContactRole ocr20 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Sponsor');
        lstOppContcRole.add(ocr20);           
        // Bill To Contact #1
        OpportunityContactRole ocr5 = NI_TestClassData.createTestOpportunityContactRole(opp3.Id, c.Id, 'Bill To');
        lstOppContcRole.add(ocr5);        
        // Bill To Contact #2
        OpportunityContactRole ocr6 = NI_TestClassData.createTestOpportunityContactRole(opp3.Id, c.Id, 'Bill To');
        lstOppContcRole.add(ocr6);         
        // Customer Project Contact 
        //        OpportunityContactRole ocr7 = NI_TestClassData.createTestOpportunityContactRole(opp3.Id, c.Id, 'Customer Project Contact');
        //        lstOppContcRole.add(ocr7);        
        // Decision Maker Contact 
        //        OpportunityContactRole ocr8 = NI_TestClassData.createTestOpportunityContactRole(opp3.Id, c.Id, 'Decision Maker');
        //        lstOppContcRole.add(ocr8);
        // Ship To Contact 
        OpportunityContactRole ocr9 = NI_TestClassData.createTestOpportunityContactRole(opp3.Id, c.Id, 'Ship To');
        lstOppContcRole.add(ocr9);
        // Bill To contact
        OpportunityContactRole ocr10 = NI_TestClassData.createTestOpportunityContactRole(opp6.Id, c.Id, 'Bill To');
        lstOppContcRole.add(ocr10);
        // Ship To contact
        OpportunityContactRole ocr11 = NI_TestClassData.createTestOpportunityContactRole(opp6.Id, c.Id, 'Ship To');
        lstOppContcRole.add(ocr11);         
        // Customer Project Contact 
        OpportunityContactRole ocr12 = NI_TestClassData.createTestOpportunityContactRole(opp6.Id, c.Id, 'Customer Project Contact');
        lstOppContcRole.add(ocr12);        
        // Decision Maker Contact 
        OpportunityContactRole ocr13 = NI_TestClassData.createTestOpportunityContactRole(opp6.Id, c.Id, 'Decision Maker');
        lstOppContcRole.add(ocr13); 
        // Sponsor Contact 
        OpportunityContactRole ocr21 = NI_TestClassData.createTestOpportunityContactRole(opp6.Id, c.Id, 'Sponsor');
        lstOppContcRole.add(ocr21);        

        // Bill To contact
        OpportunityContactRole ocr14 = NI_TestClassData.createTestOpportunityContactRole(opp7.Id, c.Id, 'Bill To');
        lstOppContcRole.add(ocr14);
        // Ship To contact
        OpportunityContactRole ocr15 = NI_TestClassData.createTestOpportunityContactRole(opp7.Id, c.Id, 'Ship To');
        lstOppContcRole.add(ocr15);         
        // Customer Project Contact 
        OpportunityContactRole ocr16 = NI_TestClassData.createTestOpportunityContactRole(opp7.Id, c.Id, 'Customer Project Contact');
        lstOppContcRole.add(ocr16);        
        // Decision Maker Contact 
        OpportunityContactRole ocr17 = NI_TestClassData.createTestOpportunityContactRole(opp7.Id, c.Id, 'Decision Maker');
        lstOppContcRole.add(ocr17);    
        // SPONSOR CONTACT ROLE
        OpportunityContactRole ocr22 = NI_TestClassData.createTestOpportunityContactRole(opp7.Id, c.Id, 'Sponsor');
        lstOppContcRole.add(ocr22);
        
        Database.Insert(lstOppContcRole); 
        
        // CREATE TEST OPPORTUNITY LINE ITEM RECORDS  ===================================================================================== 
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
        
        
        // Support Product
        OpportunityLineItem oli01 = NI_TestClassData.createTestOpportunityLineItem(1, opp1.Id, pbe1.Id, 1);
        lstOLIs.add(oli01);
        
        // Support Product
        OpportunityLineItem oli02 = NI_TestClassData.createTestOpportunityLineItem(2, opp2.Id, pbe1.Id, 1);
        lstOLIs.add(oli02);
        
        // LARGE DEAL OPPORTUNITY 
        // Support Product
        OpportunityLineItem oli03 = NI_TestClassData.createTestOpportunityLineItem(3, opp3.Id, pbe1.Id, 1);
        lstOLIs.add(oli03);
        // Subscription Product
        OpportunityLineItem oli04 = NI_TestClassData.createTestOpportunityLineItem(4, opp3.Id, pbe2.Id, 1);
        lstOLIs.add(oli04);
        // Software Product
        OpportunityLineItem oli05 = NI_TestClassData.createTestOpportunityLineItem(5, opp3.Id, pbe3.Id, 1);
        lstOLIs.add(oli05);
        // Services Product
        OpportunityLineItem oli06 = NI_TestClassData.createTestOpportunityLineItem(6, opp3.Id, pbe4.Id, 1);
        lstOLIs.add(oli06);
        // Hosting Product
        OpportunityLineItem oli07 = NI_TestClassData.createTestOpportunityLineItem(7, opp3.Id, pbe5.Id, 1);
        lstOLIs.add(oli07);
        
        // HRM NEW OPPORTUNITY 
        // Support Product
        OpportunityLineItem oli08 = NI_TestClassData.createTestOpportunityLineItem(8, opp4.Id, pbe1.Id, 1);
        lstOLIs.add(oli08);
        // Subscription Product
        OpportunityLineItem oli09 = NI_TestClassData.createTestOpportunityLineItem(9, opp4.Id, pbe2.Id, 1);
        lstOLIs.add(oli09);
        // Software Product
        OpportunityLineItem oli10 = NI_TestClassData.createTestOpportunityLineItem(10, opp4.Id, pbe3.Id, 1);
        lstOLIs.add(oli10);
        // Services Product
        OpportunityLineItem oli11 = NI_TestClassData.createTestOpportunityLineItem(11, opp4.Id, pbe4.Id, 1);
        lstOLIs.add(oli11);
        // Hosting Product
        OpportunityLineItem oli12 = NI_TestClassData.createTestOpportunityLineItem(12, opp4.Id, pbe5.Id, 1);
        lstOLIs.add(oli12);
        // Salesforce License Product
        OpportunityLineItem oli13 = NI_TestClassData.createTestOpportunityLineItem(13, opp6.Id, pbe9.Id, 1);
        lstOLIs.add(oli13);
        // HRM Product
        OpportunityLineItem oli14 = NI_TestClassData.createTestOpportunityLineItem(14, opp6.Id, pbe10.Id, 1);
        lstOLIs.add(oli14);
        
        
        OpportunityLineItem oli15 = NI_TestClassData.createTestOpportunityLineItem(15, opp7.Id, pbe11.Id, 1);
        lstOLIs.add(oli15);
        
        OpportunityLineItem oli16 = NI_TestClassData.createTestOpportunityLineItem(16, opp7.Id, pbe13.Id, 1);
        lstOLIs.add(oli16);
        
        OpportunityLineItem oli17 = NI_TestClassData.createTestOpportunityLineItem(17, opp7.Id, pbe14.Id, 1);
        lstOLIs.add(oli17);
        
        
        OpportunityLineItem oli18 = NI_TestClassData.createTestOpportunityLineItem(18, opp7.Id, pbe15.Id, 1);
        lstOLIs.add(oli18);
        
        Database.Insert(lstOLIs);
        
        // CREATE TEST NI DI REFERENCE RECORDS
        List<NI_DI_Reference__c> lstDiRefToInsert = new List<NI_DI_Reference__c>();
        
        NI_DI_Reference__c nidi1 = NI_TestClassData.createTestNI_DI_Reference(1, pgp.Id, p2_1.Id);
        nidi1.HRM_Apps_Value__c = 'Delphi.fdc TEST';
        nidi1.Deployment_Instance_Name__c = 'Delphi.fdc TEST';  
        nidi1.Active__c = true;
        lstDiRefToInsert.add(nidi1);
        
        NI_DI_Reference__c nidi2 = NI_TestClassData.createTestNI_DI_Reference(2, pgp.Id, p2_2.Id);
        nidi2.HRM_Apps_Value__c = 'Guest & Social Relations TEST';
        nidi2.Deployment_Instance_Name__c = 'Guest & Social Relations TEST'; 
        nidi2.Active__c = true;
        lstDiRefToInsert.add(nidi2);
        
        NI_DI_Reference__c nidi3 = NI_TestClassData.createTestNI_DI_Reference(3, pgp.Id, p2_3.Id);
        nidi3.HRM_Apps_Value__c = 'Loyalty Management TEST';
        nidi3.Deployment_Instance_Name__c = 'Loyalty Management TEST';  
        nidi3.Active__c = true;
        lstDiRefToInsert.add(nidi3);
        
        NI_DI_Reference__c nidi4 = NI_TestClassData.createTestNI_DI_Reference(4, pgp.Id, p2_4.Id);
        nidi4.HRM_Apps_Value__c = 'Multi-Channel Marketing TEST';
        nidi4.Deployment_Instance_Name__c = 'Multi-Channel Marketing TEST'; 
        nidi4.Active__c = false;
        lstDiRefToInsert.add(nidi4);        
        
        Database.insert(lstDiRefToInsert); 

        test.stopTest(); 
        
        system.debug(' *** END NI_Opportunity_TrigHndlr_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries()); 

    }
	
    // ======================================================================================================================================= 
    // = TEST METHODs: 
    // ======================================================================================================================================= 
    
    /*
    @isTest static void testMethod1() 
    {    
        
        User u = [SELECT Id FROM User WHERE FirstName = 'Apex' AND LastName = 'Testuser'];
        Opportunity opp = [SELECT Id, Rollup_Amount_Adjustment__c FROM Opportunity WHERE Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1']; 
        opp.Rollup_Amount_Adjustment__c = .01;
        update opp;
        
        // CREATE A TEST PSA REGION  
        pse__Region__c reg = NI_TestClassData.createTestRegion(1, 'Test Region');
        insert reg;
        
        // CREATE A TEST PSA PRACTICE  
        pse__Practice__c pract = NI_TestClassData.createTestPractice(1, 'Test Practice');
        insert pract;
        
        
        test.startTest();  
        
        system.runAs(u)        
        {
            
            // CREATE A TEST PROJECT 
            pse__Proj__c proj = NI_TestClassData.createTestProject(1, 'Test Project', reg, pract, 'Draft', null);
            proj.pse__Allow_Timecards_Without_Assignment__c = true;
            proj.pse__Allow_Expenses_Without_Assignment__c = true;  
            proj.pse__Closed_for_Expense_Entry__c = false;
            proj.pse__Closed_for_Time_Entry__c = false;
            proj.pse__Stage__c = 'Draft at Risk';
            proj.pse__Opportunity__c = opp.Id;
            insert proj; 
            
            
            AH_Opportunity_TriggerHandler handler = new AH_Opportunity_TriggerHandler();
            
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
            Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
            
            Id rtSalesOrderId = OpportunityRecordTypeInfo.get('Sales Order').getRecordTypeId();
            Id rtLargeDealId = OpportunityRecordTypeInfo.get('Large Deal Opportunity').getRecordTypeId();
            
            List<Opportunity> lstOpptys = new List<Opportunity>([SELECT Id, Name, StageName FROM Opportunity WHERE Name LIKE 'APEX TEST - %']); 
            Opportunity opp1;
            Opportunity opp2;
            Opportunity opp3;
            
            for (Opportunity o : lstOpptys)
            {
                if (o.Name == 'APEX TEST - SMALL DEAL OPPORTUNITY 1')
                {
                    opp1 = o;
                }
                if (o.Name == 'APEX TEST - SMALL DEAL OPPORTUNITY 2')
                {
                    opp2 = o;
                }
                if (o.Name == 'APEX TEST - LARGE DEAL OPPORTUNITY 1')
                {
                    opp3 = o;
                }
            }
            
            List<OpportunityContactRole> lstCRole_1 = new List<OpportunityContactRole>();
            List<OpportunityContactRole> lstCRole_2 = new List<OpportunityContactRole>();
            List<OpportunityContactRole> lstCRole_3 = new List<OpportunityContactRole>();
            
            for (OpportunityContactRole r : [SELECT Id, OpportunityId, Role FROM OpportunityContactRole])
            {
                for (Opportunity opty : lstOpptys)
                {
                    if ((opty.Id == r.OpportunityId) && (opty.Name == 'APEX TEST - SMALL DEAL OPPORTUNITY 1'))
                    {
                        lstCRole_1.add(r);
                    }
                    if ((opty.Id == r.OpportunityId) && (opty.Name == 'APEX TEST - SMALL DEAL OPPORTUNITY 2'))
                    {
                        lstCRole_2.add(r);
                    }
                    if ((opty.Id == r.OpportunityId) && (opty.Name == 'APEX TEST - LARGE DEAL OPPORTUNITY 1'))
                    {
                        lstCRole_3.add(r);
                    }
                }                
            }
            
            system.assertEquals(5, lstCRole_1.size());
            system.assertEquals(0, lstCRole_2.size());
            system.assertEquals(3, lstCRole_3.size());
            
            // Invoke the OnBeforeUpdate_BillToShipToCount Opportunity Contact Role error message
            try
            {
                opp1.StageName = 'Closed Won';
                opp1.Order_Status__c = 'Definite';
                update opp1;
            }
            catch (Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains('There can only be one Bill To and one Ship To Contact on an Opportunity in order to set the Opportunity Stage to Closed Won') ? true : false;
                System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
            }                
            
            // Invoke the missing Opportunity Contact Role error message
            try
            {
                opp2.StageName = 'Closed Won';
                update opp2;
            }
            catch (Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains('There must be an active Bill To, Ship To, Customer Project Contact, Decision Maker and Sponsor') ? true : false;
                System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
            }
            
            // Invoke the OnBeforeUpdate_VerifyContactRoles Opportunity Contact Role error message
            try
            {
                opp3.StageName = 'Closed Won';
                opp3.RecordTypeId = rtSalesOrderId;
                update opp3;
            }
            catch (Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains('There must be an active Bill To, Ship To, Customer Project Contact and Decision Maker associated with the Opportunity before the Stage can be set to "Closed Won"') ? true : false;
                //                System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
            }
            
            // RESET CHANGES FOR NEXT TEST METHOD
            List<Opportunity> lstOppUpdates = new List<Opportunity>();
            opp1.StageName = 'Prospecting';
            lstOppUpdates.add(opp1);
            opp2.StageName = 'Prospecting';
            lstOppUpdates.add(opp2);
            opp3.StageName = 'Prospecting';
            opp3.RecordTypeId = rtLargeDealId;
            lstOppUpdates.add(opp3);
            Database.Update(lstOppUpdates);
            
        }
        
        test.stopTest(); 
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: NI_Opportunity_TrigHndlr_Test.opptyTrigTest1');        
        system.debug(' *** END NI_Opportunity_TrigHndlr_Test.opptyTrigTest1()'); 
        
    }*/

    @isTest static void testMethod2()     
    {   
        
        test.startTest();  
        
        Product2 pd2Lic = [SELECT Id, DI_DefaultStatus__c FROM Product2 WHERE ProductCode = 'APEX-TEST-09' LIMIT 1];
        Product2 pd2ZZZ = [SELECT Id, DI_DefaultStatus__c FROM Product2 WHERE ProductCode = 'ZZZ-HRM-001' LIMIT 1];
                
        Opportunity opp1 = [SELECT Id, Name, AccountId, StageName, Order_Status__c FROM Opportunity WHERE Name = 'APEX TEST - HRM OPPORTUNITY'];
        
        // SET OPPORTUNITY FIELDS THAT TRIGGER CREATION OF THE SALESFORCE LICENSES AND ZZZ-HRM-001 DIs
        opp1.StageName = 'Closed Won';
        opp1.Order_Status__c = 'Integrated';
        update opp1;

        List<Asset> lstAssetTest1 = new List<Asset>([SELECT Id FROM Asset WHERE AccountId = : opp1.AccountId AND Product2Id =: pd2Lic.Id]);
        system.assertEquals(1, lstAssetTest1.size(), 'Number of license DIs created from opportunity should be 1.');
        
        List<Asset> lstAssetTest2 = new List<Asset>([SELECT Id FROM Asset WHERE AccountId = : opp1.AccountId AND Product2Id =: pd2ZZZ.Id]);
        system.assertEquals(1, lstAssetTest2.size(), 'Number of ZZZ-HRM-001 DIs created from opportunity should be 1.');
   
        test.stopTest();  
        
    }
    
    
	@isTest static void testMethod3()
    {   
        
        test.startTest();  
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtLargeDealId = OpportunityRecordTypeInfo.get('Large Deal Opportunity').getRecordTypeId();
        Id rtMTechNewId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId(); 
        Id rtSmallDealId = OpportunityRecordTypeInfo.get('Small Deal Opportunity').getRecordTypeId();   
        Id rtSalesOrderId = OpportunityRecordTypeInfo.get('Sales Order').getRecordTypeId(); 
        
        // ASSERT ROLLUPS HAVE ACCURATE VALUES (AFTER OPPORTUNITY RECORD TYPE CHANGES)
        Opportunity oppLrgDeal1 = [SELECT Id, Amount__c, RecordTypeId FROM Opportunity WHERE Name = 'APEX TEST - LARGE DEAL OPPORTUNITY 1'];        
        
        system.assertEquals(rtLargeDealId, oppLrgDeal1.RecordTypeId, 'Check to see if record type is not being reset to Large Deal in other test methods that may have changed it.');
        system.assertEquals(3500, oppLrgDeal1.Amount__c, 'Check Support, Hosting & Subscription values for Large Deal Opportunity in NI Opportunity Calculated Amount Custom Setting');
        
        Opportunity oppMTech1 = [SELECT Id, Amount__c, RecordTypeId FROM Opportunity WHERE Name = 'APEX TEST - HRM NEW OPPORTUNITY 1'];        
        system.assertEquals(rtMTechNewId, oppMTech1.RecordTypeId, 'Check to see if record type is not being reset to HRM New in other test methods that may have changed it.');
        system.assertEquals(5000, oppMTech1.Amount__c, 'Check Support, Hosting & Subscription values for HRM New Org Opportunity in NI Opportunity Calculated Amount Custom Setting');
               
        test.stopTest();  
        
    }


    @isTest static void testMethod4()     
    {   
        
        test.startTest();  

        // ASSERT ROLLUPS HAVE ACCURATE VALUES (AFTER OPPORTUNITY RECORD TYPE CHANGES)
        Opportunity opp1 = [SELECT Id, Amount__c, RecordTypeId, Order_Status__c, CloseDate FROM Opportunity WHERE Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1'];        
        opp1.StageName = 'Closed Won';       
        opp1.Order_Status__c = 'Integrated';
        opp1.CloseDate = date.Today(); 
        
        update opp1;
        
        // ASSERT RELEASE DATE UPDATES ON OPPORTUNITY LINE ITEMS
        for (OpportunityLineItem lstOLI : [SELECT Release_Date__c FROM OpportunityLineItem WHERE OpportunityId =: opp1.Id])
        {
            system.assertEquals(opp1.CloseDate, lstOLI.Release_Date__c);
        }
        
        delete opp1;
        
        List<Opportunity> lstOppTest1 = new List<Opportunity>([SELECT Id, Amount__c, RecordTypeId FROM Opportunity WHERE Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1' LIMIT 1]); 
        system.debug('lstOppTest1 size after delete = ' + lstOppTest1.Size());
        
        undelete opp1;

        test.stopTest();  
        
    }
    
    
    @isTest static void testMethod4_1()     
    {   
        
        test.startTest();  

        // ASSERT ROLLUPS HAVE ACCURATE VALUES (AFTER OPPORTUNITY RECORD TYPE CHANGES)
        Opportunity opp1 = [SELECT Id, AccountId,  Amount__c, RecordTypeId, Order_Status__c, CloseDate FROM Opportunity WHERE Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1'];        
        opp1.StageName = 'Closed Won';       
        opp1.Order_Status__c = 'Integrated';
        opp1.CloseDate = date.Today(); 
        
        update opp1;
        
        List<Asset> asetList = new List<Asset>([select ID, Product2Id, Name from Asset where AccountId =:  opp1.AccountId ]);
        system.debug('asetList size : '+asetList.size());
        system.debug('asetList : '+asetList);
        
        // assert statement to check 1 assets created 
        system.assertEquals(1, asetList.size(), 'Asset count mismatch..');
        
        Opportunity opp11 = [SELECT Id, AccountId,  Amount__c, RecordTypeId, Order_Status__c, CloseDate FROM Opportunity WHERE Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1'];        
        opp11.StageName = 'Closed Won';
        opp11.Order_Status__c = 'Tentative';
        opp11.CloseDate = date.Today(); 
        update opp11;
        
        Opportunity opp11_x = [SELECT Id, AccountId,  Amount__c, RecordTypeId, Order_Status__c, CloseDate FROM Opportunity WHERE Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1'];
        system.debug('opp11_x : '+opp11_x);

        // ADD NEW OLI - FOR THAT CREATE DI INDEX, PRODUCT & PBE
        Id pbkId = Test.getStandardPricebookId();         
        Product_Group__c pgp = [select ID, Name from Product_Group__c where Name = 'Apex Test Group'];
        
        NI_DeploymentInstanceIndex__c diIdx20 = NI_TestClassData.createDI_Index(20, 'APEX TEST');
        insert diIdx20;
        
        Product2 p2_1 = NI_TestClassData.createProduct2(20, pgp.Id, 'APEX-TEST-0111', 'Support');
        p2_1.DI_Index__c = diIdx20.Id;
        p2_1.Apttus_Config2__HasOptions__c = false;
        insert p2_1;
        
        Product2 p2_2 = NI_TestClassData.createProduct2(21, pgp.Id, 'APEX-TEST-0112', 'Support');
        p2_2.DI_Index__c = diIdx20.Id;
        p2_2.Apttus_Config2__HasOptions__c = false;
        insert p2_2;
        
        // UPDATE EXISTING ASSET WITH ANOTHER PRODUCT
        asetList[0].Product2Id = p2_2.id;
        update asetList[0];
        
        PricebookEntry pbe1 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_1.Id, 1000);
        insert pbe1;
        
        OpportunityLineItem oli_new  = NI_TestClassData.createTestOpportunityLineItem(20, opp1.Id, pbe1.Id, 1);
        insert oli_new;
        
        Opportunity opp111 = [SELECT Id, AccountId,  Amount__c, RecordTypeId, Order_Status__c, CloseDate FROM Opportunity WHERE Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1'];
        opp111.StageName = 'Closed Won';
        opp111.Order_Status__c = 'Integrated';
        opp111.CloseDate = date.Today(); 
        update opp111;
        
        test.stopTest(); 
        
        Opportunity opp111_x = [SELECT Id, AccountId,  Amount__c, RecordTypeId, Order_Status__c, CloseDate FROM Opportunity WHERE Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1'];
        system.debug('opp111_x : '+opp111_x);
        
        List<Asset> asetList1 = new List<Asset>([select ID, Name from Asset where AccountId =:  opp1.AccountId ]);
        system.debug('asetList1 size : '+asetList1.size());
        system.debug('asetList1 : '+asetList1);
        
        // assert statement to check 2 assets created 
        system.assertEquals(2, asetList1.size(), 'Asset count mismatch..');
    }
    

    @isTest static void testMethod5()
    {
        
        test.starttest();
        
        Product2 p211 = [SELECT Id, DI_DefaultStatus__c, DI_Index__c FROM Product2 WHERE ProductCode = 'ZZZ-HRM-002 DI' LIMIT 1];
        Product2 p212 = [SELECT Id, DI_DefaultStatus__c, DI_Index__c FROM Product2 WHERE ProductCode = 'ZZZ-HRM-002 DI 2' LIMIT 1];
        Product2 p216 = [SELECT Id, DI_DefaultStatus__c, DI_Index__c FROM Product2 WHERE ProductCode = 'ZZZ-HRM-002 DI 6' LIMIT 1];
        
        Opportunity opp7 = [SELECT Id, Name, AccountId, StageName, Order_Status__c FROM Opportunity WHERE Name = 'APEX TEST - HRM OPPORTUNITY DI'];
        
        // SET OPPORTUNITY FIELDS THAT TRIGGER CREATION OF THE SALESFORCE LICENSES AND ZZZ-HRM-001 DIs
        list<asset> assetToadd = new list<asset>();
        Asset asset = NI_TestClassData.createTestAsset(10, opp7.AccountId, p212.Id);
        asset.status = 'Installed';
        assetToadd.add(asset);
        
        Asset asset2 = NI_TestClassData.createTestAsset(12, opp7.AccountId, p216.Id);
        asset2.status = 'Inactive';
        assetToadd.add(asset2);
        
        database.insert(assetToadd);
        
        opp7.StageName = 'Closed Won';
        opp7.Order_Status__c = 'Integrated';
        update opp7;

        test.stoptest();
        
        OpportunityLineItem op7Oli =  [SELECT Id, Name, DeploymentInstance__c FROM OpportunityLineItem WHERE OpportunityId =: opp7.Id AND ProductCode = 'ZZZ-HRM-002 DI'];
        update op7Oli;
        
        Asset asset2Status = [SELECT Status FROM Asset WHERE Id =: asset2.Id];
        system.assertEquals(op7Oli.DeploymentInstance__c, asset.Id, 'Oppline item is linked to existing DI');
        system.assertEquals('Purchased', asset2Status.Status, 'Asset status is updated to Purchased if Product status is not Inactive');
        
    } 


    @isTest static void testMethod6()
    {
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'APEX TESTER ACCOUNT'];
        Account acc2 = [SELECT Id, Name FROM Account WHERE Name = 'TEST ACCOUNT NUMBER 7'];
        
        // ACCOUNT SET
        Set<Id> acc2set = new Set<Id>(); 
        acc2set.add(acc2.Id);
        acc2set.add(acc.Id);
        
        List<Opportunity> opp1 = [SELECT Id, Name, AccountId, StageName, Order_Status__c, 
                                  (SELECT Id, Name, Product2ID, Opportunity_Stage__c,DeploymentInstance__c FROM OpportunityLineItems) 
                                  FROM Opportunity WHERE Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1'];
        
        system.debug('opp1 : '+opp1);
        
        // CREATE LIST TO RETRIEVE PRODUCT2ID FROM OPPORTUNITYLINEITEM. GET INNER SUBQUERY VALUE ASSIGN IT TO PRODSET. 
        List<Id> prodSet = new List<Id>();
        for (Opportunity opp : opp1)
        {
            List<OpportunityLineItem> oppli = new List<OpportunityLineItem>();
            oppli = opp.getSObjects('OpportunityLineItems');
            for (OpportunityLineItem opli : oppli)
            {
                prodSet.add(opli.Product2Id);
            }
        } 
        
        system.debug('prodSet : '+prodSet); 

        // CREATE BILLING CONTRACT LIST TO STORE MAIN AND RELATED ACCOUNTS BILLING CONTRACT RECORDS.
        Billing_Contract__c Billcon = NI_TestClassData.createBillingContract(129033333);
        Billcon.Account__c = acc.Id;
        Billcon.Opportunity__c = opp1[0].Id;
        insert Billcon;

        Set<Id> ALIset = new Set<Id>();
        
        //  ACCOUNT ACTIVITYLINEITEM RECORDS.
        Activity_Line_Item__c Actli = NI_TestClassData.createActivityLineItem(Billcon.Id);
        Actli.Account__c = acc.Id;
        Actli.Product__c = prodSet[0];
        Actli.Opportunity__c = opp1[0].Id;
        insert Actli;
        ALIset.add(Actli.Id);
        
        Activity_Line_Item__c Actli2 = NI_TestClassData.createActivityLineItem(Billcon.Id);
        Actli2.Account__c = acc.Id;
        Actli2.Product__c = prodSet[0];
        Actli2.Opportunity__c = opp1[0].Id;
        insert Actli2;
        ALIset.add(Actli2.Id); 

        Test.startTest();        
        
        // INSERT AH_RELATED_ACCOUNT AND RELATED_OPPORTUNITY_LINEITEM.
        AH_Opportunity_Related_Account__c AH_Opp_Relacc = new AH_Opportunity_Related_Account__c ();
        AH_Opp_Relacc.Account__c = acc2.Id;
        AH_Opp_Relacc.Opportunity__c = opp1[0].Id;
        insert AH_Opp_Relacc;
        
        AH_Account_Product__c Related_Opp_Lineitem = new AH_Account_Product__c ();
        Related_Opp_Lineitem.Account__c = acc2.Id;
        Related_Opp_Lineitem.Opportunity__c = opp1[0].Id;
        Related_Opp_Lineitem.Product__c = prodSet[0];
        Related_Opp_Lineitem.Quantity__c = 10 ;
        insert Related_Opp_Lineitem;
        
        // WHEN OPPORTUNITY STAGE WILL GET CLOSE WON AND STATUS WOULD BE INTEGRATED.
        opp1[0].StageName = 'Closed Won';
        opp1[0].Order_Status__c = 'Integrated';
        update opp1;
        
        Test.stopTest();
        

        List<Opportunity> opp2 = [SELECT Id, Name, AccountId, StageName, Order_Status__c, 
                                  (SELECT Id, Name, Product2ID, Opportunity_Stage__c,DeploymentInstance__c FROM OpportunityLineItems) 
                                  FROM Opportunity WHERE Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1'];
        
        system.debug('opp1 : '+opp2);
        
        
        // JUNCTION OBJECT RECORD WILL GET CREATED.
        List<asset> DIlst = [SELECT Id, Name, Product2ID, AccountID, Opportunity__c 
                             FROM Asset 
                             WHERE AccountID =: acc2set 
                             AND Product2ID =: prodSet];

        Set<Id> DISet = new Set<Id>();
        for (Asset DI : DIlst)
        {
            DISet.add(DI.Id);  
        }
        
        system.debug('Main acc : '+acc.id);
        system.debug('Related acc : '+acc2.id);
        system.debug('DISet : '+DISet);
        
        // QUERY ON JUNCTION OBJECT   
        List<DI_to_Activity_Line_Item__c> DI2ALI = [SELECT Id, Activity_Line_Item__c,Deployment_Instance__c 
                                                    FROM DI_to_Activity_Line_Item__c 
                                                    WHERE Activity_Line_Item__c IN : ALIset 
                                                    AND Deployment_Instance__c IN : DISet];

        // ASSERT EQUALS STATEMENT
        system.assertEquals(4, DI2ALI.size(), 'JUNCTION OBJECT RECORD COUNT MISMATCH..');
    }
    
    
    @isTest static void testMethod7()
    {
        
        List<asset> initialDIlst = [SELECT Id, Name, Product2ID, AccountID, Opportunity__c FROM Asset ];
        system.debug('initialDIlst : '+initialDIlst);
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'APEX TESTER ACCOUNT'];
        Account acc2 = [SELECT Id, Name FROM Account WHERE Name = 'TEST ACCOUNT NUMBER 7'];
        
        // ACCOUNT SET
        Set<Id> acc2set = new Set<Id>(); 
        acc2set.add(acc2.Id);
        acc2set.add(acc.Id);
        
        List<Opportunity> opp1 = [SELECT Id, Name, AccountId, StageName, Order_Status__c, 
                                  (SELECT Id, Name, Product2ID, Opportunity_Stage__c,DeploymentInstance__c FROM OpportunityLineItems) 
                                  FROM Opportunity WHERE Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1'];
        
        system.debug('opp1 : '+opp1);
        
        // CREATE LIST TO RETRIEVE PRODUCT2ID FROM OPPORTUNITYLINEITEM. GET INNER SUBQUERY VALUE ASSIGN IT TO PRODSET. 
        List<Id> prodSet = new List<Id>();
        for (Opportunity opp : opp1)
        {
            List<OpportunityLineItem> oppli = new List<OpportunityLineItem>();
            oppli = opp.getSObjects('OpportunityLineItems');
            for (OpportunityLineItem opli : oppli)
            {
                prodSet.add(opli.Product2Id);
            }
        } 
        
        system.debug('prodSet : '+prodSet); 

        // CREATE BILLING CONTRACT LIST TO STORE MAIN AND RELATED ACCOUNTS BILLING CONTRACT RECORDS.
        Billing_Contract__c Billcon = NI_TestClassData.createBillingContract(129033333);
        Billcon.Account__c = acc.Id;
        Billcon.Opportunity__c = opp1[0].Id;
        insert Billcon;

        Set<Id> ALIset = new Set<Id>();
        
        //  ACCOUNT ACTIVITYLINEITEM RECORDS.
        Activity_Line_Item__c Actli = NI_TestClassData.createActivityLineItem(Billcon.Id);
        Actli.Account__c = acc.Id;
        Actli.Product__c = prodSet[0];
        Actli.Opportunity__c = opp1[0].Id;
        insert Actli;
        ALIset.add(Actli.Id);
        
        Activity_Line_Item__c Actli2 = NI_TestClassData.createActivityLineItem(Billcon.Id);
        Actli2.Account__c = acc.Id;
        Actli2.Product__c = prodSet[0];
        Actli2.Opportunity__c = opp1[0].Id;
        insert Actli2;
        ALIset.add(Actli2.Id); 

        Test.startTest();        
        
        // INSERT AH_RELATED_ACCOUNT AND RELATED_OPPORTUNITY_LINEITEM.
        AH_Opportunity_Related_Account__c AH_Opp_Relacc = new AH_Opportunity_Related_Account__c ();
        AH_Opp_Relacc.Account__c = acc2.Id;
        AH_Opp_Relacc.Opportunity__c = opp1[0].Id;
        insert AH_Opp_Relacc;
        
        AH_Account_Product__c Related_Opp_Lineitem = new AH_Account_Product__c ();
        Related_Opp_Lineitem.Account__c = acc2.Id;
        Related_Opp_Lineitem.Opportunity__c = opp1[0].Id;
        Related_Opp_Lineitem.Product__c = prodSet[0];
        Related_Opp_Lineitem.Quantity__c = 10 ;
        insert Related_Opp_Lineitem;
        
        // WHEN OPPORTUNITY STAGE WILL GET CLOSE WON AND STATUS WOULD BE INTEGRATED.
        opp1[0].StageName = 'Closed Won';
        opp1[0].Order_Status__c = 'Integrated';
        update opp1;
        
        opp1[0].StageName = 'Closed Won';
        opp1[0].Order_Status__c = 'Tentative';
        update opp1;
        
        opp1[0].StageName = 'Closed Won';
        opp1[0].Order_Status__c = 'Integrated';
        update opp1;
        
        Test.stopTest();
        
        List<asset> assetlist1 = new List<asset>([SELECT Id, Name, Product2ID, AccountID, Opportunity__c FROM Asset where AccountID =: acc2.id]);
        system.debug('assetlist1 size : '+assetlist1.size());
        system.debug('assetlist1 : '+assetlist1);
        
                
        // ADD NEW OLI - FOR THAT CREATE DI INDEX, PRODUCT & PBE 
        Id pbkId = Test.getStandardPricebookId();         
        Product_Group__c pgp = [select ID, Name from Product_Group__c where Name = 'Apex Test Group'];
        
        NI_DeploymentInstanceIndex__c diIdx20 = NI_TestClassData.createDI_Index(20, 'APEX TEST');
        insert diIdx20;
        
        Product2 p2_2 = NI_TestClassData.createProduct2(21, pgp.Id, 'APEX-TEST-0112', 'Support');
        p2_2.DI_Index__c = diIdx20.Id;
        p2_2.Apttus_Config2__HasOptions__c = false;
        insert p2_2;

        // UPDATE EXISTING ASSET WITH ANOTHER PRODUCT
        assetlist1[0].Product2Id = p2_2.id;
        update assetlist1[0];
        
        opp1[0].StageName = 'Closed Won';
        opp1[0].Order_Status__c = 'Tentative';
        update opp1;
        
        opp1[0].StageName = 'Closed Won';
        opp1[0].Order_Status__c = 'Integrated';
        update opp1;

    }
    
}